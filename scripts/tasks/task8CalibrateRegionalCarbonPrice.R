# Task 8: Calibrate Regional Carbon Price
# Usage: Rscript start.R task_id=8 [resume_from="runs/<campaign>"]
#
# Search sequence
# 1. Read annual Kyoto-GHG caps and their coverage. Enable each cap that meets
#    the coverage threshold. EU27 shares one calibrated price path, with
#    member caps summed and eligibility based on the lowest member coverage.
# 2. Keep the input prices through the fixed year. Search each eligible
#    group's NDC-year price up to its configured limit. In ndc-ltt mode,
#    hold the settled price (including a limit reached with an NDC miss)
#    and search the slope up to the first eligible LTT's price limit. Keep
#    each finished path in place until all groups complete the first pass.
#    Each trial evaluates all groups together in one world solve.
# 3. Repair misses jointly. Fix an NDC miss first while its group has room
#    to raise the NDC price. At the NDC price limit, continue repairing LTT.
#    When LTT reaches its own price limit, any LTT-driven NDC uplift is
#    bounded by the group's NDC price limit and the configured uplift fraction.
#    If the uplift reaches its limit with LTT still unmet or loses a previously
#    met NDC, restore the NDC-only price and the highest legal slope to LTT,
#    then re-evaluate the full world.
# 4. Confirm the whole price matrix with a fresh solve. Publish the prices and
#    reports with any remaining cap misses at the search limits. SearchSummary
#    records the initial NDC price, the confirmed price, and each cap's gap.
#
# The final solve for each region-year must have solver status 1 and model
# status 2. Recovered intermediate attempts are archived as warnings.
# The model selects exogCV_NPi via fScenario=1 and uses the MAgPIE NDC_LTT
# emulator. The exported CSV contains the calibrated rows under exogCV_NPi.
# Country solves use serial mode so listing diagnostics can identify retries.
# A failed trial retains evidence for resume_from. Completing the research
# report requires TinyTeX and can be retried from the accepted confirmation.
#
# Settings in config.json under regional_carbon_price_calibration
# Values below are from config.template.json. Prices use USD2015/t CO2,
# slopes use price units per year, and caps use annual Mt CO2eq.
#
#   resume_from = null
#     Use null for a fresh campaign or a campaign directory to resume.
#     The CLI resume_from argument takes precedence. The evaluation limit
#     can be increased on resume. Campaign inputs and targets stay frozen.
#   prefix_policy = "exogCV_NPi"
#     Input price row to preserve through the fixed year. Groups without
#     an eligible NDC keep this background price path for the full horizon.
#     The row must exist for every model region and satisfy the price checks.
#   fixed_through_year = 2023
#     Last preserved input year, inclusive. The default allows changes from 2024.
#   target_mode = "ndc-ltt"
#     "ndc" calibrates Nationally Determined Contribution (NDC) caps only.
#     "ndc-ltt" also calibrates the first sufficiently covered later long-term
#     target (LTT) for each NDC-enabled group, where available.
#   target_variant = "unconditional"
#     Choose "unconditional" or "conditional" to select the pledge variant
#     in both targets/tNDCLTT.csv (annual caps) and
#     targets/tNDCLTT_coverage.csv (covered shares).
#
#     Target setting                 target_mode   target_variant
#     Unconditional NDC only         "ndc"         "unconditional"
#     Unconditional NDC and LTT      "ndc-ltt"     "unconditional"
#     Conditional NDC only           "ndc"         "conditional"
#     Conditional NDC and LTT        "ndc-ltt"     "conditional"
#
#   ndc_year = 2030
#     Year of the NDC cap and first calibrated price anchor. Years other than
#     2030 require the dedicated NDC rows generated with retrieveData("TARGETS").
#   end_year = 2100
#     Last model year and latest eligible LTT year. The year order is
#     2023 <= fixed_through_year < ndc_year < end_year <= 2100.
#   min_target_coverage = 0.65
#     Minimum share of known 2019 GHG emissions represented by the target,
#     in (0, 1]. With 0.65, coverage of 65% qualifies and 64% does not.
#     EU27 requires each member to meet the threshold. A zero cap with
#     sufficient coverage is a valid target. Zero coverage means unavailable.
#   max_ndc_price_increase_for_ltt = 0.25
#     Fraction above the first settled NDC-achieving price allowed for LTT
#     repair. For a 200 anchor, 0.25 allows up to 250 within the group's NDC
#     limit. Set 0 to hold the NDC anchor during LTT repair. An actual NDC
#     miss can be repaired up to the group's NDC price limit.
#   continuation_slope_multiplier_max = 0.2
#     Maximum tail-to-previous-slope ratio. The previous segment ends at the
#     LTT anchor when enabled, or at the NDC anchor otherwise. A preceding
#     slope of 10 permits a tail slope of up to 2 with the default ratio.
#     Available headroom under max_price can reduce it further. A zero
#     multiplier gives a flat tail.
#
#   ndc_carbon_price_limit, ltt_carbon_price_limit
#     Two objects with absolute prices keyed by EU27 and each of the 12 other
#     groups. Apply the limits at their enabled target years. For each group,
#     require fixed-year price <= NDC limit <= LTT limit <= search.max_price.
#     The initial NDC limits used 2023 exogCV_NPi prices multiplied by 10
#     below 30, 8 from 30 to below 50, and 6 from 50 up. The template includes
#     manual adjustments that give low-price groups more search room. It sets
#     the limits for MEA, REF and IND to 30 and the limit for JPN to 200.
#     Enter the amounts directly. The template LTT limits are all 2000.
#     If both maps are omitted, each group uses search.max_price at both
#     target years. Task 8 uses the same search algorithm in either case.
#
#   search
#     ndc_start_price = 400          First NDC price to try, clipped to bounds.
#     initial_ndc_price_step = 200   First change when expanding the NDC search.
#     ltt_start_slope = 10           First NDC-to-LTT slope to try, clipped to bounds.
#     initial_ltt_slope_step = 10    First change when expanding the LTT search.
#     max_price = 3000               Whole-path ceiling, including the continuation after the last target.
#     price_resolution = 1          Stop refining at this NDC price bracket width.
#     slope_resolution = 0.01       Stop refining at this LTT slope bracket width.
#     max_evaluations = 150          Limit on physical attempts across search and confirmation,
#                                   including failures. Cache hits use no new attempt.
#     ndc_tolerance_mtco2eq = 10     Preferred slack below the annual NDC cap.
#     ltt_tolerance_mtco2eq = 10     Preferred slack below the annual LTT cap.
#     For a cap of 100 with tolerance 10, the preferred band is 90 to 100.
#     At a legal floor or at search resolution, the current feasible point
#     may have extra slack. A positive cap gap always fails.


# ---- Configuration, targets and price paths --------------------------------
task8SearchAlgorithm <- "regional-deferred-repair-v6"
task8Eu27Members <- c(
  "AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL",
  "ITA", "LVA", "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"
)

task8Validate <- function(cfg) {
  required <- c(
    "resume_from", "prefix_policy", "fixed_through_year", "target_mode", "target_variant",
    "ndc_year", "end_year", "min_target_coverage", "continuation_slope_multiplier_max", "search"
  )
  limit_keys <- c("ndc_carbon_price_limit", "ltt_carbon_price_limit")
  if (!is.list(cfg) || anyDuplicated(names(cfg)) || !all(required %in% names(cfg)) ||
    any(!names(cfg) %in% c(required, "max_ndc_price_increase_for_ltt", limit_keys))) {
    stop("Use the Task 8 settings in config.template.json")
  }
  cpcOptions(cfg, character(), 8L)
  policy <- cfg$prefix_policy
  if (!is.character(policy) || length(policy) != 1L || is.na(policy) || !nzchar(trimws(policy))) {
    stop("prefix_policy must be a nonempty policy name")
  }
  cpcChoice(cfg$target_mode, c("ndc", "ndc-ltt"), "target_mode")
  cpcChoice(cfg$target_variant, c("unconditional", "conditional"), "target_variant")
  supplied_limits <- !vapply(cfg[limit_keys], is.null, logical(1))
  if (sum(supplied_limits) == 1L) stop("Supply both Task 8 carbon price limit maps together")
  for (key in limit_keys[supplied_limits]) {
    limits <- cfg[[key]]
    groups <- names(limits)
    if (!is.list(limits) || !length(groups) || anyNA(groups) || any(!nzchar(groups)) || anyDuplicated(groups)) {
      stop(key, " must be an object with unique calibration group keys")
    }
    for (g in groups) cpcNumber(limits[[g]], paste0(key, ".", g))
  }
  cpcNumber(cfg$fixed_through_year, "fixed_through_year", cpcLastHistoricalYear, TRUE)
  for (k in c("ndc_year", "end_year")) cpcNumber(cfg[[k]], k, cpcFirstSolveYear, TRUE)
  if (!(cfg$fixed_through_year < cfg$ndc_year && cfg$ndc_year < cfg$end_year && cfg$end_year <= cpcLastPolicyYear)) {
    stop("Require fixed year < NDC year < end year <= ", cpcLastPolicyYear)
  }
  cpcNumber(cfg$min_target_coverage, "min_target_coverage")
  if (cfg$min_target_coverage <= 0 || cfg$min_target_coverage > 1) stop("Coverage threshold must be in (0,1]")
  if (is.null(cfg$max_ndc_price_increase_for_ltt)) cfg$max_ndc_price_increase_for_ltt <- 0.25
  cpcNumber(cfg$max_ndc_price_increase_for_ltt, "max_ndc_price_increase_for_ltt")
  cpcNumber(cfg$continuation_slope_multiplier_max, "continuation_slope_multiplier_max")
  keys <- c(
    "ndc_start_price", "initial_ndc_price_step", "ltt_start_slope", "initial_ltt_slope_step",
    "max_price", "price_resolution", "slope_resolution", "max_evaluations",
    "ndc_tolerance_mtco2eq", "ltt_tolerance_mtco2eq"
  )
  if (!is.list(cfg$search) || anyDuplicated(names(cfg$search)) || !setequal(names(cfg$search), keys)) {
    stop("Invalid Task 8 search settings")
  }
  for (k in keys) cpcNumber(cfg$search[[k]], k, 0, k == "max_evaluations")
  positive_keys <- c("initial_ndc_price_step", "initial_ltt_slope_step", "price_resolution", "slope_resolution")
  if (any(unlist(cfg$search[positive_keys]) <= 0) || cfg$search$max_evaluations < 2) {
    stop("Positive search steps/resolutions and at least two evaluations are required")
  }
  invisible(cfg)
}

task8Targets <- function(folder, regions, cfg) {
  read <- function(name) {
    x <- read.csv(file.path(folder, "targets", name), check.names = FALSE, colClasses = "character")
    if (ncol(x) < 3 || anyDuplicated(paste(x[[1]], x[[2]])) || anyDuplicated(names(x)[-(1:2)]) ||
      any(!grepl("^[0-9]{4}$", names(x)[-(1:2)]))) stop("Invalid target table: ", name)
    x
  }
  caps <- read("tNDCLTT.csv")
  cov <- read("tNDCLTT_coverage.csv")
  if (!identical(names(caps), names(cov)) || !identical(caps[1:2], cov[1:2])) {
    stop("Target/coverage keys or years differ")
  }
  values <- as.numeric(as.matrix(caps[-(1:2)]))
  shares <- as.numeric(as.matrix(cov[-(1:2)]))
  if (any(!is.finite(values)) || any(!is.finite(shares) | shares < 0 | shares > 1)) {
    stop("Nonfinite caps or invalid coverage")
  }
  if (!all(task8Eu27Members %in% regions)) stop("Research mapping lacks EU27")
  other_regions <- setdiff(regions, task8Eu27Members)
  groups <- c(list(EU27 = task8Eu27Members), setNames(as.list(other_regions), other_regions))
  variants <- c("Unconditional", "Conditional")
  ndcVariables <- paste0("targetNDC", variants, "MtCO2e")
  lttVariables <- paste0("targetLongTerm", variants, "MtCO2e")
  keys <- paste(caps[[1]], caps[[2]])
  dedicatedNdc <- any(caps[[2]] %in% ndcVariables)
  if (!dedicatedNdc && cfg$ndc_year != 2030L) {
    stop("Regenerate the NDC/LTT pair with current mrprom for NDC years other than 2030")
  }
  # The original pair is supported for the default 2030 NDC year.
  ndcPrefix <- if (dedicatedNdc) "targetNDC" else "target"
  required <- c(paste0(ndcPrefix, variants, "MtCO2e"), lttVariables)
  if (!all(as.vector(outer(regions, required, paste)) %in% keys)) {
    stop("Missing NDC/LTT source rows. Regenerate the pair with current mrprom.")
  }
  variant <- match(cfg$target_variant, tolower(variants))
  # EU members are single-country model regions; their accepted annual caps must
  # cover all members. This avoids averaging percentages with unequal emissions.
  target_value <- function(members, y, kind = "NDC") {
    if (!as.character(y) %in% names(caps)) return(c(cap = 0, coverage = 0))
    variable <- if (kind == "LTT") lttVariables[variant] else paste0(ndcPrefix, variants[variant], "MtCO2e")
    i <- match(paste(members, variable), keys)
    c(cap = sum(as.numeric(caps[i, as.character(y)])), coverage = min(as.numeric(cov[i, as.character(y)])))
  }
  out <- list()
  for (g in names(groups)) {
    d <- target_value(groups[[g]], cfg$ndc_year)
    out[[length(out) + 1L]] <- data.frame(
      Group = g, Kind = "NDC", Year = cfg$ndc_year, Cap = d["cap"], Coverage = d["coverage"],
      Enabled = d["coverage"] > 0 && d["coverage"] >= cfg$min_target_coverage, row.names = NULL
    )
    # The dedicated LTT rows exclude revised NDCs and carry earlier LTT caps.
    # Select the earliest sufficiently covered later long-term deadline.
    later <- sort(as.integer(names(caps)[-(1:2)]))
    later <- later[later > cfg$ndc_year & later <= cfg$end_year]
    if (cfg$target_mode == "ndc-ltt" && out[[length(out)]]$Enabled) for (y in later) {
      d <- target_value(groups[[g]], y, "LTT")
      if (d["coverage"] > 0 && d["coverage"] >= cfg$min_target_coverage) {
        out[[length(out) + 1L]] <- data.frame(
          Group = g, Kind = "LTT", Year = y, Cap = d["cap"], Coverage = d["coverage"],
          Enabled = TRUE, row.names = NULL
        )
        break
      }
    }
  }
  conditions <- do.call(rbind, out)
  if (!any(conditions$Kind == "NDC" & conditions$Enabled)) {
    stop("No NDC targets meet min_target_coverage=", cfg$min_target_coverage, " for ndc_year=", cfg$ndc_year)
  }
  list(groups = groups, conditions = conditions)
}

task8Setup <- function(cfg, input, regions, targets) {
  cfg <- task8Validate(cfg)
  has_group_limits <- !is.null(cfg$ndc_carbon_price_limit)
  cfg$search_algorithm <- task8SearchAlgorithm
  cfg$regions <- regions
  cfg$groups <- targets$groups
  cfg$conditions <- targets$conditions
  cfg$policy <- "exogCV_NPi"
  cfg$fScenario <- 1L
  cfg$emulator <- "NDC_LTT"
  cfg$annual_metric <- "Emissions|Kyoto Gases.Mt CO2-equiv/yr"
  cfg$anchors <- setNames(vapply(regions, function(r) {
    i <- cpcPolicyRow(input, r, cfg$prefix_policy)
    x <- as.numeric(input[i, as.character(cpcLastHistoricalYear:cfg$fixed_through_year)])
    if (any(!is.finite(x) | x < 0) || any(diff(x) < -1e-8)) stop("Invalid/decreasing input prefix: ", r)
    cpcPolicyRow(input, r, cfg$policy)
    tail(x, 1)
  }, numeric(1)), regions)
  if (diff(range(cfg$anchors[cfg$groups$EU27])) > 1e-8) stop("EU27 prefix endpoints must agree")
  if (any(cfg$anchors > cfg$search$max_price)) stop("An input endpoint exceeds max_price")
  groups <- names(cfg$groups)
  for (key in c("ndc_carbon_price_limit", "ltt_carbon_price_limit")) {
    if (!has_group_limits) cfg[[key]] <- setNames(as.list(rep(cfg$search$max_price, length(groups))), groups)
    if (!setequal(names(cfg[[key]]), groups)) {
      stop(key, " must contain each Task 8 group: ", paste(groups, collapse = ", "))
    }
    cfg[[key]] <- vapply(cfg[[key]][groups], as.numeric, numeric(1))
  }
  fixed_prices <- vapply(cfg$groups, function(members) max(cfg$anchors[members]), numeric(1))
  ndc <- cfg$ndc_carbon_price_limit
  ltt <- cfg$ltt_carbon_price_limit
  invalid <- groups[fixed_prices > ndc | ndc > ltt | ltt > cfg$search$max_price]
  if (length(invalid)) {
    stop(
      "Require fixed-year price <= NDC price limit <= LTT price limit <= search.max_price for ",
      paste(invalid, collapse = ", ")
    )
  }
  cfg
}

task8PriceLimit <- function(cfg, group, kind) {
  limits <- if (kind == "NDC") cfg$ndc_carbon_price_limit else cfg$ltt_carbon_price_limit
  unname(limits[group])
}

task8Bounds <- function(cfg, g, ndc) {
  p <- max(cfg$anchors[cfg$groups[[g]]])
  l <- cfg$conditions[cfg$conditions$Group == g & cfg$conditions$Kind == "LTT" & cfg$conditions$Enabled, ]
  ltt_slope <- if (nrow(l)) max(0, (task8PriceLimit(cfg, g, "LTT") - ndc) / (l$Year - cfg$ndc_year)) else 0
  list(ndc = c(p, task8PriceLimit(cfg, g, "NDC")), ltt = c(0, ltt_slope))
}

# Choose the largest allowed tail multiplier that keeps one straight tail below
# the price ceiling. This does not introduce a second bend when the ceiling binds.
task8Tail <- function(cfg, g, controls) {
  l <- cfg$conditions[cfg$conditions$Group == g & cfg$conditions$Kind == "LTT" & cfg$conditions$Enabled, ]
  year <- if (nrow(l)) l$Year else cfg$ndc_year
  previous <- if (nrow(l)) controls[g, "ltt"] else
    (controls[g, "ndc"] - max(cfg$anchors[cfg$groups[[g]]])) / (cfg$ndc_year - cfg$fixed_through_year)
  ltt_increase <- if (nrow(l)) previous * (year - cfg$ndc_year) else 0
  price <- controls[g, "ndc"] + ltt_increase
  available <- if (year < cfg$end_year) max(0, (cfg$search$max_price - price) / (cfg$end_year - year)) else 0
  slope <- min(cfg$continuation_slope_multiplier_max * previous, available)
  c(slope = slope, multiplier = if (previous > 0) slope / previous else 0)
}

task8InitialControls <- function(cfg) {
  x <- matrix(0, length(cfg$groups), 2, dimnames = list(names(cfg$groups), c("ndc", "ltt")))
  for (g in rownames(x)) {
    bounds <- task8Bounds(cfg, g, 0)$ndc
    x[g, "ndc"] <- max(bounds[1], min(cfg$search$ndc_start_price, bounds[2]))
  }
  x
}

# Canonical post-prefix path, shared by input construction and repair checks.
# Keep each member's original anchor, including insignificant input rounding.
task8GroupPrices <- function(cfg, g, controls, years, anchor = NULL) {
  l <- cfg$conditions[cfg$conditions$Group == g & cfg$conditions$Kind == "LTT" & cfg$conditions$Enabled, ]
  a <- if (is.null(anchor)) max(cfg$anchors[cfg$groups[[g]]]) else anchor
  h <- cfg$fixed_through_year
  n <- cfg$ndc_year
  y <- pmin(years, cfg$end_year)
  p <- controls[g, "ndc"]
  slope <- controls[g, "ltt"]
  early <- (p - a) / (n - h)
  after <- pmax(y - n, 0)
  v <- a + early * pmin(pmax(y - h, 0), n - h)
  tail_slope <- unname(task8Tail(cfg, g, controls)["slope"])
  if (nrow(l)) v <- v + (slope * pmin(after, l$Year - n) + tail_slope * pmax(y - l$Year, 0))
  else v <- v + (tail_slope * after)
  v
}

task8MakePrices <- function(cfg, input, controls) {
  x <- input
  years <- cpcFirstPolicyYear:cpcLastPolicyYear
  for (g in names(cfg$groups)) {
    cnd <- cfg$conditions[cfg$conditions$Group == g & cfg$conditions$Enabled, ]
    if (!any(cnd$Kind == "NDC")) next
    limits <- vapply(cnd$Kind, function(kind) task8PriceLimit(cfg, g, kind), numeric(1))
    for (r in cfg$groups[[g]]) {
      src <- cpcPolicyRow(input, r, cfg$prefix_policy)
      dest <- cpcPolicyRow(input, r, cfg$policy)
      v <- as.numeric(input[src, as.character(years)])
      use <- years > cfg$fixed_through_year
      v[use] <- task8GroupPrices(cfg, g, controls, years, anchor = cfg$anchors[[r]])[use]
      if (any(!is.finite(v) | v < 0) ||
        any(diff(v[years >= cpcLastHistoricalYear]) < -1e-8) ||
        any(v[years >= cpcFirstSolveYear] > cfg$search$max_price + 1e-8)) {
        stop("Invalid full price path for ", g)
      }
      if (any(v[match(cnd$Year, years)] > limits + 1e-8)) stop("Target-year price exceeds limit for ", g)
      x[dest, as.character(years)] <- vapply(v, function(z) sprintf("%.15g", z), character(1))
    }
  }
  # Regions without NDCs keep the chosen valid background/prefix policy.
  active_ndc <- cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind == "NDC"]
  active_regions <- unlist(cfg$groups[active_ndc], use.names = FALSE)
  for (r in setdiff(cfg$regions, active_regions)) {
    i <- cpcPolicyRow(input, r, cfg$prefix_policy)
    j <- cpcPolicyRow(x, r, cfg$policy)
    x[j, as.character(years)] <- input[i, as.character(years)]
    v <- as.numeric(x[j, as.character(cpcLastHistoricalYear:cfg$end_year)])
    if (any(!is.finite(v)) || any(diff(v) < -1e-8) || any(v > cfg$search$max_price)) {
      stop("Invalid background price path for ", r)
    }
  }
  x
}

# ---- Annual emissions and cap checks ---------------------------------------
task8Check <- function(cfg, annual) {
  expected <- expand.grid(region = cfg$regions, year = cpcFirstPolicyYear:cfg$end_year)
  key <- function(x) paste(x$region, x$year)
  if (anyDuplicated(key(annual)) || !setequal(key(annual), key(expected)) || any(!is.finite(annual$value))) {
    stop("Incomplete regional annual GHG report")
  }
  d <- cfg$conditions
  d$Emissions <- vapply(seq_len(nrow(d)), function(i) {
    included <- annual$region %in% cfg$groups[[d$Group[i]]] & annual$year == d$Year[i]
    sum(annual$value[included])
  }, numeric(1))
  d$Gap <- d$Emissions - d$Cap
  d$Met <- !d$Enabled | d$Gap <= 0
  d
}

task8Annual <- function(cfg, index, prices = NULL, report = NULL) {
  cpcAnnualRows(cfg, index, "Kyoto GHG emissions", "Mt CO2eq/yr", prices, report)
}

# ---- Initial search and upward joint repair --------------------------------
task8Step <- function(x, gap, bounds, step, resolution, tolerance, state = NULL) {
  if (!is.finite(gap) || !is.finite(x)) stop("Invalid annual cap residual/control")
  fresh <- function() list(low = NULL, high = NULL, history = list(), jump = step, direction = 0L,
    side = 0L, streak = 0L, bounds = bounds, last_width = NA_real_)
  if (is.null(state) || !identical(state$bounds, bounds)) state <- fresh()
  previous_width <- if (!is.null(state$low) && !is.null(state$high)) state$high$x - state$low$x else NA_real_
  point <- list(x = x, gap = gap)
  # Retain distinct local samples even while a settled control is held constant.
  state$history <- Filter(function(p) abs(p$x - x) > 1e-12, state$history)
  state$history <- tail(c(state$history, list(point)), 4L)
  lost <- FALSE
  side <- if (gap > 0) 1L else -1L
  state$streak <- if (state$side == side) state$streak + 1L else 1L
  state$side <- side
  if (gap > 0) {
    if (!is.null(state$high) && state$high$x <= x) {
      state$high <- NULL
      lost <- TRUE
    }
    if (is.null(state$low) || x >= state$low$x) state$low <- point
  } else {
    if (!is.null(state$low) && state$low$x >= x) {
      state$low <- NULL
      lost <- TRUE
    }
    if (is.null(state$high) || x <= state$high$x) state$high <- point
  }
  result <- function(value = x, done = FALSE, reason = "searching") {
    list(value = value, state = state, done = done, reason = reason)
  }
  if (gap <= 0 && (gap >= -tolerance || x <= bounds[1] + 1e-10))
    return(result(done = TRUE, reason = if (gap < -tolerance) "legal_floor" else "in_band"))
  # A held resolution endpoint stays settled while its current world result is
  # feasible. Background changes alone must not reopen mutual endpoint checks.
  if (identical(state$terminal, "resolution") && gap <= 0 && identical(x, state$terminal_x))
    return(result(done = TRUE, reason = "resolution"))
  state$terminal <- NULL
  state$terminal_x <- NULL
  if (gap > 0 && x >= bounds[2] - 1e-10) return(result(done = TRUE, reason = "upper_bound_unmet"))
  if (!is.null(state$low) && !is.null(state$high)) {
    width <- state$high$x - state$low$x
    # At resolution, accept only the currently evaluated feasible control. An
    # infeasible current point must revisit the high side before it can settle.
    if (width <= resolution) {
      if (gap <= 0) {
        state$terminal <- "resolution"
        state$terminal_x <- x
        return(result(done = TRUE, reason = "resolution"))
      }
      return(result(state$high$x, reason = "resolution"))
    }
    fraction <- (state$low$gap + tolerance / 2) / (state$low$gap - state$high$gap)
    slow <- state$streak >= 2L || (is.finite(state$last_width) && width > 0.75 * state$last_width)
    bisect <- slow || !is.finite(fraction) || fraction < 0.2 || fraction > 0.8
    if (bisect) fraction <- 0.5
    state$last_width <- width
    return(result(state$low$x + fraction * width, reason = if (bisect) "bisect" else "interpolate"))
  }
  direction <- if (gap > 0) 1L else -1L
  if (lost) {
    local <- Filter(function(p) abs(p$x - x) > 1e-12, state$history)
    delta <- NA_real_
    if (length(local)) {
      p <- tail(local, 1)[[1]]
      derivative <- (gap - p$gap) / (x - p$x)
      if (is.finite(derivative) && derivative < -1e-12) delta <- abs((gap + tolerance / 2) / derivative)
    }
    fallback <- if (is.finite(previous_width)) min(step / 10, previous_width / 2) else step / 10
    state$jump <- max(2 * resolution, min(step, if (is.finite(delta)) delta else fallback))
    state$direction <- direction
  } else if (direction != state$direction) state$jump <- step
  value <- max(bounds[1], min(bounds[2], x + direction * state$jump))
  state$jump <- state$jump * 2
  state$direction <- direction
  result(value, reason = if (lost) "local_rebracket" else "expand")
}

# The latest valid complete-matrix observation is authoritative, including a
# failed-cap independent confirmation. A new confirmation always bypasses cache.
task8CachedTrial <- function(trials, candidate) {
  for (a in rev(trials)) if (isTRUE(a$valid) && isTRUE(all.equal(a$controls, candidate, tolerance = 0))) return(a)
  NULL
}

task8Unmet <- function(checks) checks[checks$Enabled & !checks$Met, , drop = FALSE]

task8NdcSearch <- function(groups) {
  prices <- setNames(rep(NA_real_, length(groups)), groups)
  list(initial_prices = prices, ndc_only_prices = prices,
    fallback_trials = setNames(rep(NA_integer_, length(groups)), groups),
    fallback_reasons = setNames(rep(NA_character_, length(groups)), groups))
}

task8LttNdcLimit <- function(cfg, group, ndc_search) {
  initial <- ndc_search$initial_prices[[group]]
  ndc_limit <- task8PriceLimit(cfg, group, "NDC")
  if (is.null(initial) || is.na(initial)) return(ndc_limit)
  min(ndc_limit, initial * (1 + cfg$max_ndc_price_increase_for_ltt))
}

task8LimitReasons <- function(cfg, result, ndc_search) {
  d <- result$checks
  reasons <- rep(NA_character_, nrow(d))
  restored <- which(d$Enabled & d$Met & d$Kind == "LTT" & !is.na(ndc_search$fallback_trials[d$Group]))
  reasons[restored] <- unname(ndc_search$fallback_reasons[d$Group[restored]])
  for (i in which(d$Enabled & !d$Met)) {
    g <- d$Group[i]
    price <- result$controls[g, "ndc"]
    at_ndc_limit <- price >= task8PriceLimit(cfg, g, "NDC") - 1e-10
    if (d$Kind[i] == "NDC") {
      if (at_ndc_limit) reasons[i] <- "NDC price ceiling"
    } else if (result$controls[g, "ltt"] >= task8Bounds(cfg, g, price)$ltt[2] - 1e-10) {
      if (!is.na(ndc_search$fallback_trials[[g]])) {
        reasons[i] <- ndc_search$fallback_reasons[[g]]
      } else if (price >= task8LttNdcLimit(cfg, g, ndc_search) - 1e-10) {
        reasons[i] <- if (at_ndc_limit) "LTT price ceiling" else "LTT NDC price increase limit"
      }
    }
  }
  reasons
}

task8AtSearchLimit <- function(cfg, result, ndc_search) {
  missed <- result$checks$Enabled & !result$checks$Met
  any(missed) && all(!is.na(task8LimitReasons(cfg, result, ndc_search)[missed]))
}

task8GapSummary <- function(missed) {
  paste(paste(missed$Group, missed$Kind, round(missed$Gap, 3), "Mt gap"), collapse = "; ")
}

# First finish each group's NDC -> LTT path without reopening completed stages.
# After every group finishes, jointly repair actual cap misses. The searched
# segments rise during repair except for a recorded rollback. The tail is
# derived from the last searched slope.
# Optional controls/result start directly from a failed confirmation on resume.
task8Search <- function(cfg, evaluate, controls = NULL, result = NULL, repair_only = FALSE, ndc_search = NULL) {
  if (is.null(controls)) controls <- task8InitialControls(cfg)
  groups <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind == "NDC"])
  later <- if (cfg$target_mode == "ndc-ltt") {
    unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind == "LTT"])
  } else {
    character()
  }
  repair_through <- setNames(rep(cfg$end_year, length(groups)), groups)
  ltt <- cfg$conditions[cfg$conditions$Enabled & cfg$conditions$Kind == "LTT", ]
  repair_through[ltt$Group] <- ltt$Year
  if (is.null(ndc_search)) {
    if (repair_only) stop("Missing NDC search reference for confirmation repair")
    ndc_search <- task8NdcSearch(groups)
  }
  ndc_states <- ltt_states <- ndc_repair <- ltt_repair <- setNames(vector("list", length(groups)), groups)
  phase <- setNames(rep(if (repair_only) "done" else "NDC", length(groups)), groups)
  mode <- if (repair_only) "repair" else "initial"
  early_steps <- setNames(rep(cfg$search$initial_ndc_price_step, length(groups)), groups)
  last_ltt_uplifts <- character()
  seen <- character()
  if (is.null(result)) result <- evaluate(controls, paste("Regional", mode))
  if (!isTRUE(all.equal(result$controls, controls, tolerance = 0))) {
    stop("Current regional observation does not match its controls")
  }
  repeat {
    signature <- paste(format(as.vector(controls), digits = 17), collapse = ",")
    signature <- paste(mode, paste(phase, collapse = ","), signature, sep = ";")
    signature <- paste(signature, paste(!is.na(ndc_search$fallback_trials), collapse = ","))
    if (sum(seen == signature) >= 4L) stop("Regional calibration incomplete: repeated simultaneous search matrix")
    seen <- c(seen, signature)
    candidate <- controls
    boundary <- actions <- character()
    previous_phase <- phase
    restored <- raised <- ltt_uplifts <- character()
    ndc_pending <- FALSE
    if (mode == "repair") {
      missed_ndc <- task8Unmet(result$checks)
      missed_ndc <- missed_ndc$Group[missed_ndc$Kind == "NDC"]
      ndc_pending <- any(controls[missed_ndc, "ndc"] < task8PriceLimit(cfg, missed_ndc, "NDC") - 1e-10)
      raised <- groups[controls[groups, "ndc"] > ndc_search$ndc_only_prices[groups] + 1e-10]
      # An LTT-driven uplift may affect another group's NDC. Recheck the NDC
      # anchors before any further increase if a previously feasible NDC is
      # lost. Try undoing the latest uplifts first to preserve earlier successes.
      if (length(raised) && any(!is.na(ndc_search$initial_prices[missed_ndc]))) {
        restored <- intersect(raised, last_ltt_uplifts)
        if (!length(restored)) restored <- raised
        fallback_reason <- "NDC fallback after lost NDC compliance"
      }
    }
    gap <- function(g, kind) result$checks$Gap[result$checks$Group == g & result$checks$Kind == kind]
    advance <- function(g, kind, state) {
      is_ndc <- kind == "NDC"
      column <- if (is_ndc) "ndc" else "ltt"
      task8Step(controls[g, column], gap(g, kind), task8Bounds(cfg, g, controls[g, "ndc"])[[column]],
        cfg$search[[if (is_ndc) "initial_ndc_price_step" else "initial_ltt_slope_step"]],
        cfg$search[[if (is_ndc) "price_resolution" else "slope_resolution"]],
        cfg$search[[if (is_ndc) "ndc_tolerance_mtco2eq" else "ltt_tolerance_mtco2eq"]],
        state)
    }
    for (g in if (length(restored)) character() else groups) {
      if (mode == "initial") {
        if (phase[[g]] == "done") next
        kind <- phase[[g]]
        is_ndc <- kind == "NDC"
        z <- advance(g, kind, if (is_ndc) ndc_states[[g]] else ltt_states[[g]])
        if (is_ndc) ndc_states[[g]] <- z$state else ltt_states[[g]] <- z$state
        candidate[g, if (is_ndc) "ndc" else "ltt"] <- z$value
        if (z$reason == "upper_bound_unmet") {
          boundary <- c(boundary, paste(g, kind, round(gap(g, kind), 3), "Mt gap at price ceiling"))
        }
        if (z$done) {
          if (is_ndc) {
            ndc_search$ndc_only_prices[[g]] <- controls[g, "ndc"]
            if (gap(g, "NDC") <= 0) ndc_search$initial_prices[[g]] <- controls[g, "ndc"]
          }
          if (is_ndc && g %in% later) {
            phase[[g]] <- "LTT"
            candidate[g, "ltt"] <- min(cfg$search$ltt_start_slope, task8Bounds(cfg, g, candidate[g, "ndc"])$ltt[2])
            actions <- c(actions, paste(g, "start LTT"))
          } else {
            phase[[g]] <- "done"
            actions <- c(actions, paste(g, "initial path finished"))
          }
        } else if (z$value != controls[g, if (is_ndc) "ndc" else "ltt"])
          actions <- c(actions, paste(g, kind, z$reason))
        next
      }
      # Repair observes only actual hard-cap misses. Once a cap is met, discard
      # its expansion jump so a later miss cannot revive an old large step.
      ndc_missed <- gap(g, "NDC") > 0
      if (ndc_missed) {
        z <- advance(g, "NDC", ndc_repair[[g]])
        ndc_repair[[g]] <- z$state
        candidate[g, "ndc"] <- max(controls[g, "ndc"], z$value)
        candidate[g, "ltt"] <- min(controls[g, "ltt"], task8Bounds(cfg, g, candidate[g, "ndc"])$ltt[2])
        if (candidate[g, "ndc"] > controls[g, "ndc"]) {
          ndc_search$ndc_only_prices[[g]] <- candidate[g, "ndc"]
          actions <- c(actions, paste(g, "repair NDC; hold/clamp middle slope"))
        } else boundary <- c(boundary, paste(g, "NDC", round(gap(g, "NDC"), 3), "Mt gap at price ceiling"))
        # An exhausted NDC still leaves room between its limit and the LTT
        # limit. Keep the LTT search state across rounds at the NDC ceiling.
        if (z$reason != "upper_bound_unmet") {
          ltt_repair[g] <- list(NULL)
          next
        }
      }
      ndc_repair[g] <- list(NULL)
      if (!ndc_missed && is.na(ndc_search$initial_prices[[g]])) {
        ndc_search$initial_prices[[g]] <- controls[g, "ndc"]
      }
      if (!g %in% later || gap(g, "LTT") <= 0) {
        ltt_repair[g] <- list(NULL)
        next
      }
      z <- advance(g, "LTT", ltt_repair[[g]])
      ltt_repair[[g]] <- z$state
      candidate[g, "ltt"] <- max(controls[g, "ltt"], z$value)
      if (z$reason == "upper_bound_unmet") {
        if (ndc_pending) next
        limit <- task8LttNdcLimit(cfg, g, ndc_search)
        if (!is.na(ndc_search$fallback_trials[[g]])) limit <- controls[g, "ndc"]
        price <- min(limit, controls[g, "ndc"] + early_steps[[g]])
        if (price > controls[g, "ndc"]) {
          candidate[g, "ndc"] <- price
          candidate[g, "ltt"] <- min(controls[g, "ltt"], task8Bounds(cfg, g, price)$ltt[2])
          early_steps[[g]] <- early_steps[[g]] * 2
          ltt_repair[g] <- list(NULL)
          ltt_uplifts <- c(ltt_uplifts, g)
          actions <- c(actions, paste(g, "repair LTT by strengthening early anchor"))
        } else boundary <- c(boundary, paste(g, "LTT", round(gap(g, "LTT"), 3), "Mt gap at search limit"))
      } else if (candidate[g, "ltt"] > controls[g, "ltt"])
        actions <- c(actions, paste(g, "repair LTT"))
    }
    if (mode == "initial" && all(phase == "done")) {
      # Each stage settled on the currently observed value. Do not spend a
      # redundant world call solely to pass the initial/repair barrier.
      if (!isTRUE(all.equal(candidate, controls, tolerance = 0))) {
        stop("Initial-stage completion changed unevaluated controls")
      }
      mode <- "repair"
      message("All initial regional paths finished; checking joint NDC/LTT constraints")
      next
    }
    if (!length(restored) && isTRUE(all.equal(candidate, controls, tolerance = 0))) {
      if (mode == "initial" && !identical(phase, previous_phase)) next
      if (mode == "initial") stop("Regional calibration incomplete: initial search made no progress")
      if (length(boundary)) message("  Search boundaries: ", paste(unique(boundary), collapse = "; "))
      missed <- task8Unmet(result$checks)
      if (nrow(missed) && !task8AtSearchLimit(cfg, result, ndc_search)) {
        stop("Regional repair stalled below a search limit: ", task8GapSummary(missed))
      }
      restored <- intersect(raised, missed$Group[missed$Kind == "LTT"])
      fallback_reason <- "NDC fallback after LTT limit"
      if (!length(restored)) return(list(controls = controls, result = result, ndc_search = ndc_search))
    }
    # Retain the strongest legal slope from the NDC anchor and evaluate the
    # whole fallback matrix before making any acceptance decision.
    for (g in restored) {
      price <- ndc_search$ndc_only_prices[[g]]
      candidate[g, "ndc"] <- price
      candidate[g, "ltt"] <- task8Bounds(cfg, g, price)$ltt[2]
      ndc_search$fallback_trials[[g]] <- result$iteration
      ndc_search$fallback_reasons[[g]] <- fallback_reason
      ltt_repair[g] <- list(NULL)
      actions <- c(actions, paste(g, fallback_reason))
    }
    if (mode == "repair") for (g in groups) for (r in cfg$groups[[g]]) {
      years <- (cfg$fixed_through_year + 1):cfg$end_year
      before <- task8GroupPrices(cfg, g, controls, years, anchor = cfg$anchors[[r]])
      after <- task8GroupPrices(cfg, g, candidate, years, anchor = cfg$anchors[[r]])
      # Raising the NDC anchor against a fixed LTT price can flatten the
      # middle segment and its derived tail. Protect prices through the LTT.
      protected <- years <= repair_through[[g]]
      if (any(!is.finite(after) | after < 0 | after > cfg$search$max_price + 1e-8) ||
        any(diff(after) < -1e-8) || (!g %in% restored && any(after[protected] < before[protected] - 1e-8))) {
        stop("Regional repair lowered a searched segment or violated path bounds: ", g)
      }
    }
    message("  Next regional actions: ", paste(actions, collapse = "; "))
    controls <- candidate
    last_ltt_uplifts <- ltt_uplifts
    result <- evaluate(controls, paste("Regional", mode))
  }
}

# ---- Model flags and final region-year solve checks ------------------------
# In serial solves, listing LOOPS fields identify the region, year and attempt.
# Keep every summary, including failed attempts preceding a successful retry.
task8SolveDiagnostics <- function(trial, regions, years, reason) {
  expected <- as.vector(outer(regions, years, paste, sep = ":"))
  stats <- file.path(trial, "modelstat.txt")
  listing <- file.path(trial, "main.lst")
  model <- list(present = file.exists(stats), records = 0L, malformed = 0L, non2 = list(), missing = expected)
  if (model$present) {
    fields <- cpcModelStatusFields(stats)
    model$malformed <- sum(lengths(fields) != 4L)
    good <- fields[lengths(fields) == 4L]
    model$records <- length(good)
    if (length(good)) {
      d <- do.call(rbind, good)
      key <- paste(d[, 2], d[, 4], sep = ":")
      model$missing <- setdiff(expected, key)
      model$duplicates <- unique(key[duplicated(key)])
      model$unexpected <- setdiff(key, expected)
      status <- as.numeric(d[, 3])
      model$non2 <- lapply(which(!is.finite(status) | status != 2), function(i) {
        list(region = d[i, 2], year = as.integer(d[i, 4]), model_status = status[i])
      })
    }
  }
  attempts <- list()
  country <- NA_character_
  year <- NA_integer_
  attempt <- NA_character_
  if (file.exists(listing)) {
    con <- file(listing, "r")
    on.exit(close(con), add = TRUE)
    line_number <- 0L
    pattern <- paste(
      "(?:LOOPS|L O O P S)\\s+an\\s+[0-9]{4}",
      "^\\s*(?:runCyL|rcc)\\s+\\S+\\s*$",
      "(?:SOLVER|MODEL) STATUS\\s+[0-9]+",
      sep = "|"
    )
    repeat {
      block <- readLines(con, n = 10000L, warn = FALSE)
      if (!length(block)) break
      # Most listing lines are equation/statistics output. Filter in C before
      # parsing contexts, avoiding an R regex loop over millions of lines.
      relevant <- grep(pattern, block, perl = TRUE)
      for (i in relevant) {
        line <- block[i]
        number <- line_number + i
        y <- regmatches(line, regexec("(?:LOOPS|L O O P S)\\s+an\\s+([0-9]{4})\\s*$", line, perl = TRUE))[[1]]
        r <- regmatches(line, regexec("^\\s*runCyL\\s+(\\S+)\\s*$", line, perl = TRUE))[[1]]
        a <- regmatches(line, regexec("^\\s*rcc\\s+(\\S+)\\s*$", line, perl = TRUE))[[1]]
        if (length(y) == 2L) {
          year <- as.integer(y[2])
          country <- NA_character_
          attempt <- NA_character_
        }
        if (length(r) == 2L) country <- r[2]
        if (length(a) == 2L) attempt <- a[2]
        z <- regmatches(line, regexec("SOLVER STATUS\\s+([0-9]+)", line, perl = TRUE))[[1]]
        if (length(z) == 2L) attempts[[length(attempts) + 1L]] <- list(region = country, year = year, attempt = attempt,
          solver_status = as.integer(z[2]), model_status = NA_integer_, listing_line = number, summary = trimws(line))
        z <- regmatches(line, regexec("MODEL STATUS\\s+([0-9]+)", line, perl = TRUE))[[1]]
        if (length(z) == 2L && length(attempts)) attempts[[length(attempts)]]$model_status <- as.integer(z[2])
      }
      line_number <- line_number + length(block)
    }
  }
  codes <- vapply(attempts, function(a) a$solver_status, integer(1))
  bad <- attempts[which(is.na(codes) | codes != 1L)]
  counts <- table(codes, useNA = "ifany")
  classification <- if (!model$present || model$malformed || length(model$missing) || length(model$duplicates)) {
    "missing_or_invalid_model_status_records"
  } else if (length(model$non2)) {
    "non_optimal_final_model_status"
  } else if (length(bad)) {
    "non_normal_solver_attempt"
  } else if (length(codes) < length(expected)) {
    "missing_solver_status_records"
  } else {
    "other_validation_or_process_error"
  }
  list(
    reason = reason, classification = classification, expected_region_years = length(expected),
    final_model_status = model, listing_present = file.exists(listing), solver_status_records = length(codes),
    solver_status_counts = as.list(counts), abnormal_attempts = bad, all_attempts = attempts,
    acceptance_rule = paste("final-region-year-v1: each region-year's last solver status 1 / model status 2;",
                            "earlier anomalies retained as warnings")
  )
}

# Full world coverage is mandatory in both files. A recovered earlier attempt
# can warn only after that same region/year has an explicitly normal last solve.
task8CheckSolves <- function(trial, regions, years) {
  d <- task8SolveDiagnostics(trial, regions, years, "solve validation")
  m <- d$final_model_status
  expected <- as.vector(outer(regions, years, paste, sep = ":"))
  if (!m$present || m$malformed || m$records != length(expected) || length(m$missing) ||
    length(m$duplicates) || length(m$unexpected) || length(m$non2))
    stop("Missing region/year or non-optimal final model status")
  attempts <- d$all_attempts
  if (!length(attempts) || any(vapply(attempts, function(a)
    is.na(a$region) || is.na(a$year) || is.na(a$solver_status) || is.na(a$model_status), logical(1))))
    stop("Missing or unassociated solver/model status records")
  key <- vapply(attempts, function(a) paste(a$region, a$year, sep = ":"), character(1))
  if (!setequal(key, expected)) stop("Missing or unexpected region/year in solver summaries")
  final <- which(!duplicated(key, fromLast = TRUE))
  bad <- final[vapply(attempts[final], function(a) a$solver_status != 1L || a$model_status != 2L, logical(1))]
  if (length(bad)) {
    a <- attempts[[bad[1L]]]
    stop("Non-normal final solve: ", a$region, " ", a$year, " solver=", a$solver_status, " model=", a$model_status)
  }
  earlier <- setdiff(seq_along(attempts), final)
  failed_earlier <- vapply(attempts[earlier], function(a) a$solver_status != 1L || a$model_status != 2L, logical(1))
  warnings <- attempts[earlier[failed_earlier]]
  list(final_region_years = length(final), solver_attempts = length(attempts), acceptance = "final-region-year-v1",
    retry_region_years = sum(table(key) > 1L), warning_count = length(warnings), retry_warnings = warnings)
}

# ---- Durable warning and failure evidence ----------------------------------
task8PreserveWarnings <- function(campaign, result, trial) {
  if (!result$solves$warning_count) return(invisible(NULL))
  folder <- file.path(campaign, "calibration-warnings", sprintf("attempt-%06d", result$model_attempt))
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(folder)) stop("Cannot create warning archive: ", folder)
  files <- file.path(trial, c("modelstat.txt", "main.lst", "gams.log"))
  if (!all(file.copy(files, folder, overwrite = TRUE))) stop("Cannot preserve retry warning logs: ", folder)
  record <- list(trial = result$iteration, physical_attempt = result$model_attempt, solves = result$solves)
  cpcWriteJson(record, file.path(folder, "warnings.json"))
}

# A failed result stays in the checkpoint until the archive and its raw trial
# are in place. Resume repeats this operation using the same result and number.
task8PreserveFailure <- function(campaign, result, annual, trial) {
  name <- if (is.null(result$model_attempt)) sprintf("presolve-%06d", result$failure_id) else
    sprintf("attempt-%06d", result$model_attempt)
  folder <- file.path(campaign, "calibration-failures", name)
  dir.create(folder, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(folder, "failure.rds")
  if (file.exists(path)) {
    previous <- readRDS(path)
    if (!identical(previous$result, result) || !identical(previous$annual, annual)) {
      stop("Conflicting failure archive: ", path)
    }
  } else {
    cpcWriteRds(list(result = result, annual = annual,
      recorded_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3Z", tz = "UTC")), path)
  }
  target <- file.path(folder, "trial")
  if (dir.exists(trial)) {
    if (file.exists(file.path(trial, cpcProcessMarker))) stop("Retained process marker: ", trial)
    if (dir.exists(target) || !file.rename(trial, target)) stop("Cannot move failed trial into archive: ", trial)
  }
  cpcWriteJson(list(trial = result$iteration, physical_attempt = result$model_attempt, failure_id = result$failure_id,
    stage = result$stage, reason = result$reason, diagnostics = result$diagnostics,
    full_trial_retained = dir.exists(target)), file.path(folder, "failure.json"))
}

# ---- Completed archive validation ------------------------------------------
task8CompletionStatus <- function(checks) {
  if (nrow(task8Unmet(checks))) "complete_with_unmet_targets" else "complete"
}

task8IsComplete <- function(status) {
  length(status) == 1L && status %in% c("complete", "complete_with_unmet_targets")
}

task8CheckArchivedPrices <- function(paths, prices, cfg) {
  rows <- paths[paths$Metric == "Carbon price", ]
  if (anyDuplicated(rows$Region) || !setequal(rows$Region, cfg$regions)) stop("Incomplete archived price paths")
  rows <- rows[match(prices[[1L]], rows$Region), ]
  years <- as.character(cpcFirstPolicyYear:cpcLastPolicyYear)
  expected <- as.numeric(as.matrix(prices[years]))
  observed <- as.numeric(as.matrix(rows[years]))
  if (!isTRUE(all.equal(observed, expected, tolerance = 1e-12))) {
    stop("Archived price paths differ from candidate controls")
  }
}

task8SearchDetails <- function(cfg, checks, ndc_search, controls) {
  groups <- checks$Group
  initial <- if (is.null(ndc_search)) rep(NA_real_, length(groups)) else unname(ndc_search$initial_prices[groups])
  fallback_trial <- if (is.null(ndc_search)) {
    rep(NA_integer_, length(groups))
  } else {
    unname(ndc_search$fallback_trials[groups])
  }
  ltt <- cfg$conditions[cfg$conditions$Kind == "LTT" & cfg$conditions$Enabled, ]
  ltt_year <- ltt$Year[match(groups, ltt$Group)]
  has_ltt <- !is.na(ltt_year)
  ndc_limit <- task8PriceLimit(cfg, groups, "NDC")
  limit <- pmin(ndc_limit, initial * (1 + cfg$max_ndc_price_increase_for_ltt))
  limit[!has_ltt] <- NA_real_
  details <- data.frame(InitialNDCPrice = initial, LTTNDCPriceLimit = limit, LTTFallbackTrial = fallback_trial)
  has_ndc <- groups %in% cfg$conditions$Group[cfg$conditions$Kind == "NDC" & cfg$conditions$Enabled]
  details$FixedYearPrice <- vapply(cfg$groups[groups], function(members) max(cfg$anchors[members]),
    numeric(1), USE.NAMES = FALSE)
  details$NDCPriceLimit <- ndc_limit
  details$NDCPriceLimit[!has_ndc] <- NA_real_
  details$LTTPriceLimit <- task8PriceLimit(cfg, groups, "LTT")
  details$LTTPriceLimit[!has_ltt] <- NA_real_
  details$LTTPrice <- rep(NA_real_, length(groups))
  if (any(has_ltt)) {
    later <- groups[has_ltt]
    details$LTTPrice[has_ltt] <- controls[later, "ndc"] + controls[later, "ltt"] * (ltt_year[has_ltt] - cfg$ndc_year)
  }
  details
}

task8ConfirmationMatches <- function(campaign, trial) {
  files <- c(cpcModelFiles(campaign), file.path(campaign, "calibrated-iEnvPolicies.csv"))
  cpcConfirmationMatches(campaign, files, 8L, trial)
}

task8ReusableConfirmation <- function(campaign, work, trials, result, cfg, boundary_from, ndc_search) {
  matched <- Filter(function(a) isTRUE(a$valid) &&
    isTRUE(all.equal(a$controls, result$controls, tolerance = 0)), trials)
  confirmations <- Filter(function(a) {
    trial <- file.path(work, sprintf("trial-%03d", a$iteration))
    identical(a$stage, "Confirmation") &&
      (task8ConfirmationMatches(campaign, a$iteration) || cpcConfirmationTrialReady(trial))
  }, matched)
  if (!length(confirmations)) return(NULL)
  cand <- tail(confirmations, 1L)[[1L]]
  priors <- Filter(function(a) a$iteration < cand$iteration, matched)
  if (!length(priors)) return(NULL)
  agrees <- function(other) identical(cand$checks$Met, other$checks$Met) &&
    isTRUE(all.equal(cand$checks$Emissions, other$checks$Emissions, tolerance = 1e-10))
  if (!agrees(tail(priors, 1L)[[1L]]) || !agrees(result)) return(NULL)
  if (nrow(task8Unmet(cand$checks)) && (is.na(boundary_from) || !task8AtSearchLimit(cfg, cand, ndc_search))) {
    return(NULL)
  }
  cand
}

task8PublishConfirmation <- function(campaign, work, input, cfg, result) {
  if (task8ConfirmationMatches(campaign, result$iteration)) return(invisible(NULL))
  trial <- file.path(work, sprintf("trial-%03d", result$iteration))
  if (!isTRUE(result$valid) || result$stage != "Confirmation" || !cpcConfirmationTrialReady(trial)) {
    stop("Incomplete regional confirmation files; retaining the accepted trial")
  }
  prices <- cpcSelectedPrices(cfg, task8MakePrices(cfg, input, result$controls))
  actual <- cpcSelectedPrices(cfg, cpcReadPolicy(file.path(trial, "data/iEnvPolicies.csv")))
  if (!cpcSamePrices(prices, actual)) stop("Retained confirmation prices differ from the selected controls")
  csv <- file.path(trial, "calibrated-iEnvPolicies.csv")
  cpcWritePrices(csv, prices)
  cpcPublishConfirmation(c(cpcModelFiles(trial), csv), campaign, trial, 8L, result$iteration)
}

# Validate the publication against the accepted result before committing the
# complete state.
task8ValidateArchive <- function(campaign, input, state) {
  cfg <- state$cfg
  result <- state$trials[[state$accepted]]
  if (!isTRUE(result$valid) || !identical(result$stage, "Confirmation") ||
    !isTRUE(result$iteration == state$accepted)) {
    stop("Invalid archived confirmation")
  }
  if (!identical(task8CompletionStatus(result$checks), state$status)) {
    stop("Completed status disagrees with the confirmed caps")
  }
  if (nrow(task8Unmet(result$checks)) && !task8AtSearchLimit(cfg, result, state$ndc_search)) {
    stop("Completed archive contains cap misses below the search limits")
  }
  if (!cpcFilesReady(cpcResearchFiles(campaign))) stop("Completed archive lacks research results")
  if (!task8ConfirmationMatches(campaign, result$iteration)) {
    stop("Completed output files differ from the accepted confirmation")
  }
  csv <- file.path(campaign, "calibrated-iEnvPolicies.csv")
  prices <- cpcSelectedPrices(cfg, task8MakePrices(cfg, input, result$controls))
  if (!cpcSamePrices(cpcReadPolicy(csv), prices)) stop("Completed CSV differs from confirmed controls: ", csv)
  task8CheckSolves(campaign, cfg$regions, cpcFirstSolveYear:cfg$end_year)
  invisible(NULL)
}

task8SearchSummary <- function(cfg, trials, accepted, ndc_search) {
  if (!length(trials)) {
    rows <- data.frame(
      Trial = integer(), Stage = character(), cfg$conditions[FALSE, ], Emissions = numeric(),
      Gap = numeric(), Met = logical(), NDCPrice = numeric(), LTTSlope = numeric(), TailSlope = numeric(),
      TailMultiplier = numeric(), ValidRun = logical(), Accepted = logical(), FailureReason = character(),
      LogExcerpt = character(), PhysicalAttempt = integer(),
      SolverRetryWarnings = integer(), SolveAcceptance = character()
    )
    return(cbind(rows, task8SearchDetails(cfg, rows, NULL, NULL), LimitReason = character()))
  }
  enabled <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind == "NDC"])
  later <- unique(cfg$conditions$Group[cfg$conditions$Enabled & cfg$conditions$Kind == "LTT"])
  do.call(rbind, lapply(trials, function(trial) {
    checks <- trial$checks
    tails <- lapply(checks$Group, function(group) {
      if (group %in% enabled) task8Tail(cfg, group, trial$controls) else c(slope = NA_real_, multiplier = NA_real_)
    })
    row <- data.frame(
      Trial = trial$iteration, Stage = trial$stage, checks,
      NDCPrice = ifelse(checks$Group %in% enabled, trial$controls[checks$Group, "ndc"], NA_real_),
      LTTSlope = ifelse(checks$Group %in% later, trial$controls[checks$Group, "ltt"], NA_real_),
      TailSlope = vapply(tails, function(item) item[["slope"]], numeric(1)),
      TailMultiplier = vapply(tails, function(item) item[["multiplier"]], numeric(1)),
      ValidRun = trial$valid, Accepted = !is.na(accepted) && trial$iteration == accepted,
      FailureReason = if (is.null(trial$reason)) NA_character_ else trial$reason,
      LogExcerpt = if (is.null(trial$log_excerpt)) NA_character_ else trial$log_excerpt,
      PhysicalAttempt = if (is.null(trial$model_attempt)) NA_integer_ else as.integer(trial$model_attempt),
      SolverRetryWarnings = if (is.null(trial$solves$warning_count)) NA_integer_ else trial$solves$warning_count,
      SolveAcceptance = if (is.null(trial$solves$acceptance)) NA_character_ else trial$solves$acceptance,
      row.names = NULL, check.names = FALSE
    )
    limit_reason <- if (isTRUE(row$Accepted[1L])) task8LimitReasons(cfg, trial, ndc_search) else NA_character_
    cbind(row, task8SearchDetails(cfg, checks, ndc_search, trial$controls), LimitReason = limit_reason)
  }))
}

task8RunSettings <- function(state) {
  cfg <- state$cfg
  accepted <- state$accepted
  warnings <- vapply(state$trials, function(trial) {
    if (is.null(trial$solves$warning_count)) 0L else as.integer(trial$solves$warning_count)
  }, integer(1))
  values <- c(
    Status = state$status, Reason = state$reason, "Accepted trial" = as.character(accepted),
    "Target mode" = cfg$target_mode, "Target variant" = cfg$target_variant, "Annual metric" = cfg$annual_metric,
    "Prefix policy" = cfg$prefix_policy, "Exported policy row" = cfg$policy, "Model fScenario" = cfg$fScenario,
    "Land-use emulator scenario" = cfg$emulator, "Coverage threshold" = cfg$min_target_coverage,
    "Maximum continuation slope multiplier" = cfg$continuation_slope_multiplier_max,
    "Search strategy" = paste("Use group-specific NDC and LTT price limits, then repair misses jointly",
                              "with bounded NDC uplift for LTT and an NDC fallback"),
    "Search algorithm" = cfg$search_algorithm,
    "Confirmation repair origin" = as.character(state$repair_from),
    "Boundary candidate trial" = as.character(state$boundary_from),
    "Unmet enabled caps" = if (is.na(accepted)) NA_integer_ else nrow(task8Unmet(state$trials[[accepted]]$checks)),
    "Physical model attempts" = state$model_attempts,
    "Solver acceptance" = "Final solver status 1 and model status 2 for every region-year; intermediate anomalies warn",
    "Recorded solver retry warnings" = sum(warnings), "Country solve mode" = "serial",
    "Keep input prices through" = cfg$fixed_through_year, "NDC year" = cfg$ndc_year, "End year" = cfg$end_year,
    "Maximum evaluations" = cfg$search$max_evaluations,
    "Accounting" = paste(
      "Research Kyoto-GHG convention; source scopes/GWP differ;",
      "missing historical weights use known-emissions coverage"
    ),
    "Maximum NDC price increase for LTT (fraction)" = cfg$max_ndc_price_increase_for_ltt,
    "Maximum carbon price (USD2015/t CO2)" = cfg$search$max_price
  )
  data.frame(Parameter = names(values), Value = as.character(values), row.names = NULL)
}

task8CheckpointSheets <- function(state) {
  paths <- if (length(state$annual)) do.call(rbind, state$annual) else task8Annual(state$cfg, 0L)[FALSE, ]
  summary_sheet <- task8SearchSummary(state$cfg, state$trials, state$accepted, state$ndc_search)
  cpcHistorySheets(paths, summary_sheet, task8RunSettings(state))
}

task8CleanupComplete <- function(campaign, work, state_path, saved_hash) {
  if (file.exists(file.path(campaign, cpcProcessMarker))) stop("Reporting process cleanup is incomplete")
  for (folder in cpcTrialFolders(work)) cpcCleanup(folder, work, state_path, saved_hash)
  cpcCleanup(work, campaign, state_path, saved_hash)
  cpcCleanupReportState(campaign, state_path, saved_hash)
}

task8CheckState <- function(state, frozen_cfg) {
  if (length(state$status) != 1L || !is.character(state$status) || is.na(state$status) ||
    length(state$accepted) != 1L || !is.list(state$trials) || !is.list(state$annual) ||
    length(state$trials) != length(state$annual) || !is.list(state$cfg)) {
    stop("Invalid Task 8 checkpoint state")
  }
  if (!identical(state$cfg$search_algorithm, task8SearchAlgorithm)) {
    stop("Unsupported Task 8 checkpoint search algorithm: ", state$cfg$search_algorithm)
  }
  cfg <- state$cfg
  cpcNumber(cfg$search$max_evaluations, "retained evaluation budget", minimum = 2, integer = TRUE)
  frozen_cfg$search$max_evaluations <- cfg$search$max_evaluations
  if (!isTRUE(all.equal(cfg, frozen_cfg, tolerance = 0))) {
    stop("Task 8 settings, price anchors or NDC/LTT targets changed since the campaign was frozen")
  }
  if (!is.na(state$accepted)) {
    if (!cpcIsIndex(state$accepted) || state$accepted > length(state$trials)) stop("Invalid archived confirmation")
    confirmation <- state$trials[[state$accepted]]
    if (!isTRUE(confirmation$valid) || !identical(confirmation$stage, "Confirmation")) {
      stop("Invalid archived confirmation")
    }
  } else if (task8IsComplete(state$status) ||
    state$status %in% c("verified", "postprocessing", "postprocessing_failed")) {
    stop("Invalid archived confirmation")
  }
  cpcNumber(state$model_attempts, "retained physical model attempts", integer = TRUE)
  if (!is.null(state$failure_count)) cpcNumber(state$failure_count, "retained pre-solve failure count", integer = TRUE)
  p <- state[["pending"]]
  if (!is.null(p) && (!cpcIsIndex(p$iteration) || p$iteration != length(state$trials) + 1L ||
    !is.na(state$accepted) || !cpcIsIndex(p$model_attempt) || p$model_attempt != state$model_attempts + 1L)) {
    stop("Invalid pending Task 8 trial or physical attempt")
  }
}

task8SearchState <- function(cfg, config_hash, input, retained, requested_budget) {
  state <- list(cfg = cfg, config_hash = config_hash, trials = list(), annual = list(), status = "running",
    reason = NA_character_, accepted = NA_integer_, ndc_search = NULL, repair_from = NA_integer_,
    boundary_from = NA_integer_, model_attempts = 0L, failure_count = 0L, pending = NULL)
  if (is.null(retained)) return(state)
  fields <- intersect(names(state), names(retained))
  state[fields] <- retained[fields]
  cfg$search$max_evaluations <- max(retained$cfg$search$max_evaluations, requested_budget)
  state$cfg <- cfg
  if (!is.na(state$accepted)) return(state)

  if (!is.na(state$boundary_from)) {
    idx <- state$boundary_from
    origin <- state$trials[[idx]]
    if (!isTRUE(origin$valid) || !task8AtSearchLimit(cfg, origin, state$ndc_search)) {
      stop("Invalid retained boundary candidate")
    }
    prices <- cpcSelectedPrices(cfg, task8MakePrices(cfg, input, origin$controls))
    task8CheckArchivedPrices(state$annual[[idx]], prices, cfg)
  }
  # A crash after recording a confirmation can precede recording its repair decision.
  if (length(state$trials)) {
    last <- tail(state$trials, 1L)[[1L]]
    if (isTRUE(last$valid) && identical(last$stage, "Confirmation") && nrow(task8Unmet(last$checks)) &&
      (is.na(state$boundary_from) || !task8AtSearchLimit(cfg, last, state$ndc_search))) {
      state$repair_from <- last$iteration
      state$boundary_from <- NA_integer_
    }
  }
  state
}

# ---- Task entry point and campaign lifecycle -------------------------------
runTask8 <- function(config, gams, write_metadata, args) {
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  requested <- config$regional_carbon_price_calibration
  options <- cpcOptions(requested, args, 8L)
  resuming <- !is.null(options$resume_from)
  requested_budget <- requested$search$max_evaluations
  if (resuming && !is.null(requested_budget)) {
    cpcNumber(requested_budget, "search.max_evaluations", minimum = 2, integer = TRUE)
  }
  if (!resuming) requested <- task8Validate(requested)
  cpcRequirePackages()
  targetHashes <- function(folder) {
    targets <- file.path(folder, "targets")
    files <- file.path(targets, c("tNDCLTT.csv", "tNDCLTT_coverage.csv"))
    if (dir.exists(file.path(targets, ".ndcltt-publish")) || any(file.exists(paste0(files, ".previous")))) {
      stop("NDC/LTT export is active or needs recovery in ", targets)
    }
    missing <- files[!file.exists(files)]
    if (length(missing)) {
      stop(
        "Missing paired NDC/LTT target file(s): ", paste(basename(missing), collapse = ", "), " in ", targets,
        ". Task 8 requires both tNDCLTT.csv and tNDCLTT_coverage.csv exported together by mrprom."
      )
    }
    vapply(files, cpcHash, character(1), USE.NAMES = FALSE)
  }
  expectedTargets <- if (!resuming) targetHashes(root) else NULL
  opened <- cpcOpenCampaign(root, options$resume_from, "calibrate-regional-carbon-price")
  campaign <- opened$path
  on.exit(filelock::unlock(opened$lock), add = TRUE)
  if (!resuming) {
    snapshot_config <- config
    snapshot_config$regional_carbon_price_calibration <- requested
    cpcSnapshot(root, campaign, snapshot_config, write_metadata)
    if (!identical(expectedTargets, targetHashes(campaign)) || !identical(expectedTargets, targetHashes(root))) {
      stop("NDC/LTT inputs changed during the Task 8 snapshot")
    }
  }
  frozen <- cpcReadCampaignConfig(campaign)
  run_config <- frozen$config
  config_hash <- frozen$hash
  input <- cpcReadPolicy(file.path(campaign, "data/iEnvPolicies.csv"))
  regions <- cpcReadRegions(campaign)
  work <- file.path(campaign, ".work")
  history <- file.path(campaign, "calibration-history.xlsx")
  state_path <- file.path(campaign, "calibration-state.rds")
  regional_settings <- run_config$regional_carbon_price_calibration
  targets <- task8Targets(campaign, regions, regional_settings)
  cfg <- task8Setup(regional_settings, input, regions, targets)
  retained <- if (resuming) {
    cpcLoadState(state_path, 8L, config_hash, function(state) task8CheckState(state, cfg))
  } else {
    NULL
  }
  if (resuming && is.null(retained)) {
    stop("Missing calibration-state.rds in resume_from: ", campaign)
  }

  if (!is.null(retained) && task8IsComplete(retained$status)) {
    saved <- cpcHash(state_path)
    task8ValidateArchive(campaign, input, retained)
    cpcSaveHistory(history, task8CheckpointSheets(retained))
    task8CleanupComplete(campaign, work, state_path, saved)
    message("Regional calibration already complete: ", campaign)
    return(invisible(campaign))
  }

  state <- task8SearchState(cfg, config_hash, input, retained, requested_budget)
  cfg <- state$cfg
  report_only <- !is.na(state$accepted)
  if (resuming) cpcStopRetainedProcess(campaign, expected_wd = root)
  dir.create(work, showWarnings = FALSE)
  if (!dir.exists(work)) stop("Cannot open calibration work directory")
  checkpoint_error <- function(e) {
    error_message <- paste0("Checkpoint failed: ", conditionMessage(e), ". Recovery files retained at ", campaign)
    stop(structure(list(message = error_message,
      call = NULL), class = c("task8_checkpoint_error", "error", "condition")))
  }
  checkpoint <- function(export = TRUE) tryCatch({
    if (export) cpcSaveCheckpoint(state_path, 8L, state, history, task8CheckpointSheets(state)) else
      cpcSaveState(state_path, 8L, state)
  }, error = checkpoint_error, interrupt = checkpoint_error)

  record_failure <- function(result, trial, prices, report = NULL, had_marker = FALSE) {
    idx <- result$iteration
    # processx opens gams.log at launch. Charge the reserved number only when
    # the trial reached a child process, even across repeated interruptions.
    evidence <- file.path(trial, c("gams.log", cpcProcessMarker, "modelstat.txt", "main.lst", cpcGdxFile))
    if (had_marker || any(file.exists(evidence))) {
      state$model_attempts <<- result$model_attempt
    } else {
      result$model_attempt <- NULL
      state$failure_count <<- state$failure_count + 1L
      result$failure_id <- state$failure_count
    }
    result$log_excerpt <- cpcLogExcerpt(file.path(trial, c("gams.log", "report.log")))
    result$diagnostics <- task8SolveDiagnostics(trial, regions, cpcFirstSolveYear:cfg$end_year, result$reason)
    result$checks <- cfg$conditions
    result$checks$Emissions <- result$checks$Gap <- NA_real_
    result$checks$Met <- FALSE
    state$annual[[idx]] <<- task8Annual(cfg, idx, prices, report)
    state$trials[[idx]] <<- result
    state$pending <<- NULL
    state$status <<- "unfinished"
    state$reason <<- result$reason
    checkpoint()
    result
  }

  if (resuming) {
    folders <- cpcTrialFolders(work)
    indices <- as.integer(sub("^trial-", "", basename(folders)))
    unarchived <- which(indices > length(state$trials))
    if (anyNA(indices) || any(indices < 1L) || !identical(basename(folders), sprintf("trial-%03d", indices)) ||
      any(!indices[unarchived] %in% state$pending$iteration)) {
      stop("Unrecorded trial directory: ", work)
    }
    marked <- file.exists(file.path(folders[unarchived], cpcProcessMarker))
    for (folder in folders) cpcStopRetainedProcess(folder)
    if (!is.null(state$pending)) {
      interrupted <- state$pending
      interrupted$reason <- "Interrupted before valid trial archival"
      folder <- file.path(work, sprintf("trial-%03d", interrupted$iteration))
      record_failure(interrupted, folder, task8MakePrices(cfg, input, interrupted$controls), had_marker = any(marked))
    }
    # Reuse the logical trial number only after its failure archive is complete.
    if (length(state$trials) && !isTRUE(tail(state$trials, 1L)[[1L]]$valid)) {
      failed <- tail(state$trials, 1L)[[1L]]
      folder <- file.path(work, sprintf("trial-%03d", failed$iteration))
      task8PreserveFailure(campaign, failed, state$annual[[failed$iteration]], folder)
      state$trials <- head(state$trials, -1L)
      state$annual <- head(state$annual, -1L)
    }
    saved <- cpcHash(state_path)
    for (i in which(indices <= length(state$trials))) {
      if (state$trials[[indices[i]]]$stage != "Confirmation") cpcCleanup(folders[i], work, state_path, saved)
    }
    if (!report_only) {
      state$status <- "running"
      state$reason <- NA_character_
    }
  }
  report_process <- cpcReportProcess(root, campaign, run_config, cfg$annual_metric)
  env <- cpcProcessEnvironment(run_config, campaign)
  flags <- cpcFlags(run_config$scenario$gams_flags, cfg)
  saveRDS(cfg, file.path(work, "config.rds"))
  checkpoint()
  cpcFreezeReporting(campaign, report_process, fresh = !length(state$trials) && state$model_attempts == 0L)
  # Archive each physical attempt before cleanup or handing its result to search.
  evaluate <- function(candidate, stage = "NDC", confirmation = FALSE) {
    prices <- task8MakePrices(cfg, input, candidate)
    if (!confirmation) {
      cached <- task8CachedTrial(state$trials, candidate)
      if (!is.null(cached)) return(cached)
    }
    reserved <- if (confirmation) 0L else 1L
    if (state$model_attempts >= cfg$search$max_evaluations - reserved) {
      stop("evaluation_budget_exhausted; increase max_evaluations and resume")
    }
    idx <- length(state$trials) + 1L
    trial <- file.path(work, sprintf("trial-%03d", idx))
    if (dir.exists(trial)) stop("Uncleared trial directory: ", trial)
    message("Trial ", idx, " (", stage, ")")
    state$pending <<- list(iteration = idx, stage = stage, controls = candidate, valid = FALSE,
      model_attempt = state$model_attempts + 1L)
    checkpoint(export = FALSE)
    report <- NULL
    result <- state$pending
    result <- tryCatch(
      {
        if (!dir.create(trial)) stop("Cannot create trial directory: ", trial)
        cpcPrepareTrial(campaign, trial, prices, confirmation)
        message("  Physical model attempt ", result$model_attempt)
        cpcRunProcess(gams, cpcSolveArgs(flags, confirmation), trial, file.path(trial, "gams.log"), env = env)
        result$solves <- task8CheckSolves(trial, regions, cpcFirstSolveYear:cfg$end_year)
        report_process("evaluate", trial)
        report <- readRDS(file.path(trial, "report.rds"))
        task8PreserveWarnings(campaign, result, trial)
        result$checks <- task8Check(cfg, report$annual)
        result$valid <- TRUE
        result
      },
      error = function(e) {
        result$reason <- conditionMessage(e)
        result
      })
    if (!result$valid) {
      failed <- record_failure(result, trial, prices, report)
      task8PreserveFailure(campaign, failed, state$annual[[idx]], trial)
      stop("Trial ", idx, " failed: ", result$reason)
    }
    state$annual[[idx]] <<- task8Annual(cfg, idx, prices, report)
    state$trials[[idx]] <<- result
    state$model_attempts <<- result$model_attempt
    state$pending <<- NULL
    saved <- checkpoint()
    if (!confirmation) {
      tryCatch(cpcCleanup(trial, work, state_path, saved), error = checkpoint_error, interrupt = checkpoint_error)
    }
    if (result$solves$warning_count)
      message("  Solver retry warnings: ", result$solves$warning_count, "; all final region-year solves normal")
    active <- result$checks[result$checks$Enabled, ]
    message("  Unmet active caps: ", sum(!active$Met), "; largest gap: ", round(max(active$Gap), 3), " Mt CO2eq/yr")
    result
  }
  run <- function() {
    if (report_only) {
      return(state$trials[[state$accepted]])
    }
    # A cap failure in confirmation starts a durable repair-only replay. Resume
    # from that observation, not from an old cached success or first-pass stages.
    if (!is.na(state$boundary_from)) {
      origin <- state$trials[[state$boundary_from]]
      message("Confirming archived search-limit candidate from trial ", state$boundary_from)
      search_result <- list(controls = origin$controls, result = origin, ndc_search = state$ndc_search)
    } else if (!is.na(state$repair_from)) {
      origin <- state$trials[[state$repair_from]]
      if (!isTRUE(origin$valid) || origin$stage != "Confirmation" || !nrow(task8Unmet(origin$checks))) {
        stop("Invalid retained confirmation repair origin")
      }
      search_result <- task8Search(cfg, evaluate, controls = origin$controls, result = origin,
        repair_only = TRUE, ndc_search = state$ndc_search)
    } else {
      search_result <- task8Search(cfg, evaluate)
    }
    repeat {
      controls <- search_result$controls
      result <- search_result$result
      state$ndc_search <<- search_result$ndc_search
      if (is.na(state$boundary_from) && task8AtSearchLimit(cfg, result, state$ndc_search)) {
        state$boundary_from <<- result$iteration
        checkpoint()
      }
      reused <- task8ReusableConfirmation(campaign, work, state$trials, result, cfg,
        state$boundary_from, state$ndc_search)
      confirmation <- if (!is.null(reused)) {
        message("Reusing verified confirmation trial ", reused$iteration)
        reused
      } else {
        evaluate(controls, "Confirmation", TRUE)
      }
      missed <- task8Unmet(confirmation$checks)
      if (nrow(missed) && (is.na(state$boundary_from) || !task8AtSearchLimit(cfg, confirmation, state$ndc_search))) {
        state$repair_from <<- confirmation$iteration
        state$boundary_from <<- NA_integer_
        state$status <<- "running"
        state$reason <<- "Independent confirmation found cap misses; joint repair resumed"
        checkpoint()
        message("Independent confirmation found cap misses; continuing upward joint repair")
        search_result <- task8Search(cfg, evaluate, controls = confirmation$controls, result = confirmation,
          repair_only = TRUE, ndc_search = state$ndc_search)
        next
      }
      if (!identical(confirmation$checks$Met, result$checks$Met) ||
        !isTRUE(all.equal(confirmation$checks$Emissions, result$checks$Emissions, tolerance = 1e-10))) {
        stop("Independent confirmation changed results")
      }
      state$accepted <<- confirmation$iteration
      state$reason <<- NA_character_
      return(confirmation)
    }
  }
  result <- tryCatch(run(), error = function(e) {
    if (inherits(e, "task8_checkpoint_error")) stop(e)
    if (is.null(state$pending) && state$status != "unfinished") {
      state$status <<- "unfinished"
      state$reason <<- conditionMessage(e)
      checkpoint()
    }
    stop(e)
  }, interrupt = function(e) {
    stop("Regional calibration interrupted; use resume_from to continue from the last checkpoint", call. = FALSE)
  })

  complete_status <- task8CompletionStatus(result$checks)
  complete_reason <- if (identical(complete_status, "complete")) {
    "All enabled annual caps independently confirmed"
  } else {
    paste0("Independently confirmed with unmet caps at the search limits: ", task8GapSummary(task8Unmet(result$checks)))
  }
  state$status <- "postprocessing"
  checkpoint()
  postprocessing_failed <- function(e) {
    state$status <<- "postprocessing_failed"
    state$reason <<- conditionMessage(e)
    checkpoint()
    stop(e)
  }
  tryCatch(
    {
      task8PublishConfirmation(campaign, work, input, cfg, result)
      cpcFullReport(campaign, work, report_process)
      complete <- state
      complete$status <- complete_status
      task8ValidateArchive(campaign, input, complete)
    },
    error = postprocessing_failed,
    interrupt = postprocessing_failed)
  state$status <- complete_status
  state$reason <- complete_reason
  saved <- checkpoint()
  task8CleanupComplete(campaign, work, state_path, saved)
  message("Regional calibration ", state$status, ": ", campaign)
  invisible(campaign)
}
