# Task 7: Calibrate Global Carbon Price
# Usage: Rscript start.R task_id=7 [resume_from="runs/<campaign>"]
#
# Search sequence
# 1. Preserve each region's input prices through the fixed year and connect
#    them linearly to a common price in the common year.
# 2. Solve all 39 regions for each candidate. First vary the common straight
#    slope until end-year cumulative global net CO2 reaches its one-sided
#    tolerance band. Keep that path if its full-horizon peak meets the ceiling.
# 3. If the straight path exceeds the peak ceiling, search a steeper front
#    slope to bring the first peak into its tolerance band. Bend at the first
#    year with non-positive annual global net CO2. Apply the fixed tail/front
#    slope ratio until max_price, then hold that price. Require both ceilings
#    on the resulting path. A fixed-tail path may have extra terminal slack.
# 4. Confirm the selected path with a fresh solve, then publish the prices
#    and research reports. Verify the Excel history before cleaning up.
#
# Settings in config.json under global_carbon_price_calibration
# Values below are from config.template.json. Prices use USD2015/t CO2,
# slopes use price units per year, and cumulative budgets use Gt CO2.
#
#   resume_from = null
#     Use null for a fresh campaign or a campaign directory to resume.
#     The CLI resume_from argument takes precedence. On unfinished campaigns,
#     only the evaluation cap, tolerances and resolutions can be overridden.
#   prefix_policy = "exogCV_NPi"
#     Input price row to preserve. Options are "exogCV_NPi", "exogCV_1_5C",
#     "exogCV_2C" and "exogCV_Calib".
#   fixed_through_year = 2027
#     Last year to preserve each region's input price, inclusive.
#   common_year = 2032
#     Year all regions reach the common price. The year order is
#     2024 <= fixed_through_year < common_year < end_year <= 2100.
#   common_price = 400
#     Prescribed common-year price, above every region's fixed-year price.
#   post_net_zero_slope_multiplier = 0.5
#     Positive tail/front slope ratio for bent paths. Straight paths use one
#     slope throughout. Legacy campaigns keep their saved flat/free-tail rule.
#   peak_budget_gtco2 = 550
#     Hard ceiling on the maximum cumulative total over the whole horizon.
#     Must be at least end_budget_gtco2.
#   end_budget_gtco2 = 400
#     Hard ceiling on the cumulative total at end_year.
#     For both caps, use the same 2020-based budget reference. The table
#     below uses the IPCC AR6 WGI 67% likelihood column (Table 5.8).
#     Warming is relative to 1850-1900 and budgets are in Gt CO2.
#
#     Reference warming (deg C)  1.5   1.6   1.7   1.8   1.9   2.0   2.1   2.2
#     Remaining budget          400   550   700   850  1000  1150  1250  1400
#
#     Set peak_budget_gtco2 from the peak warming reference and
#     end_budget_gtco2 from the end-year warming reference. Examples:
#       1.5 C end with a 1.5 C peak reference -> peak/end =  400/400
#       1.5 C end with a 1.6 C peak reference -> peak/end =  550/400
#       1.5 C end with a 1.7 C peak reference -> peak/end =  700/400
#       2.0 C end with a 2.1 C peak reference -> peak/end = 1250/1150
#     The earlier 1400/1200 research pair uses a 2.2 C peak reference.
#     Its end budget lies between the 2.0 and 2.1 C rows (about 2.05 C
#     by linear interpolation).
#
#     AR6 budgets refer to reaching net zero. Task 7 uses them as
#     cumulative CO2 proxies for setting the peak and end-year limits.
#     Actual peak warming and warming at end_year require a climate
#     calculation that also accounts for non-CO2 forcing and removals.
#     Source: https://www.ipcc.ch/report/ar6/wg1/chapter/chapter-5/
#   end_year = 2100
#     Last model year and year of the terminal budget check.
#   budget_start_year = 2020
#     First year included in the cumulative sum (2010 through 2024 allowed).
#     The default includes historical emissions for 2020–2023.
#   temperature_case = "1.5C"
#     "1.5C" selects exogCV_1_5C, fScenario=2 and the MAgPIE curve "1p5C".
#     "2C" selects exogCV_2C, fScenario=3 and the MAgPIE curve "2C".
#     Enter the two budgets separately.
#
#   search
#     start_slope = 18              First straight-path slope to try.
#     initial_slope_step = 40       First slope change for straight and front searches. The step doubles when expanding to find a bracket.
#     initial_end_price_step = 200  First terminal-price step in legacy free-tail campaigns only.
#     max_price = 5000              Path price ceiling, above common_price. A rising tail flattens at this price.
#     slope_resolution = 0.01       Stop refining at this slope bracket width.
#     end_price_resolution = 1      Terminal-price bracket resolution for legacy free-tail campaigns only.
#     max_evaluations = 50          Total evaluation limit across search and confirmation. Cache hits use no new call.
#     peak_tolerance_gtco2 = 5      Width of the band below the peak ceiling for the first peak of a bent path.
#     end_tolerance_gtco2 = 5       Width of the band below the end-year ceiling for straight paths.


# ---- Configuration and price construction -----------------------------------
task7Options <- function(cfg, args) {
  keys <- sub("=.*$", "", args)
  unknown <- setdiff(keys, c("task_id", "resume_from"))
  if (length(unknown)) stop("Unsupported Task 7 option(s): ", paste(unknown, collapse = ", "))
  resume <- sub("^resume_from=", "", grep("^resume_from=", args, value = TRUE))
  if (length(resume) > 1L) stop("Supply one resume_from directory")
  path <- if (length(resume)) resume else cfg$resume_from
  if (!is.null(path) && (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(trimws(path)))) {
    stop("resume_from must be null or a nonempty campaign directory")
  }
  list(resume_from = path)
}

task7Number <- function(x, name, minimum = 0, integer = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < minimum ||
      (integer && x != trunc(x))) stop("Invalid ", name, ": expected a finite number")
  invisible(x)
}

task7ValidateConfig <- function(cfg, allow_legacy = FALSE) {
  required <- c("prefix_policy", "fixed_through_year", "common_year", "common_price",
    "post_net_zero_slope_multiplier", "peak_budget_gtco2", "end_budget_gtco2", "end_year", "budget_start_year", "temperature_case", "search")
  allowed <- c(required, "resume_from")
  # Only saved campaigns may omit the new physical path parameter. Never inject
  # today's default into an older archive or change its calibrated tail rule.
  if (allow_legacy) required <- setdiff(required, "post_net_zero_slope_multiplier")
  if (!is.list(cfg) || anyDuplicated(names(cfg)) || !all(required %in% names(cfg)) ||
      any(!names(cfg) %in% allowed)) stop("Use the automatic Task 7 settings in config.template.json; new campaigns require post_net_zero_slope_multiplier")
  task7Options(cfg, character())
  for (k in c("fixed_through_year", "common_year", "end_year", "budget_start_year")) task7Number(cfg[[k]], k, 2010, TRUE)
  if (!(2024 <= cfg$fixed_through_year && cfg$fixed_through_year < cfg$common_year &&
        cfg$common_year < cfg$end_year && cfg$end_year <= 2100)) stop("Require 2024 <= fixed year < common year < end year <= 2100")
  if (cfg$budget_start_year > 2024) stop("Budget start must include the model start (2024)")
  for (k in c("common_price", "peak_budget_gtco2", "end_budget_gtco2")) task7Number(cfg[[k]], k)
  if ("post_net_zero_slope_multiplier" %in% names(cfg)) {
    task7Number(cfg$post_net_zero_slope_multiplier, "post_net_zero_slope_multiplier")
    if (cfg$post_net_zero_slope_multiplier <= 0) stop("post_net_zero_slope_multiplier must be positive")
  }
  if (cfg$peak_budget_gtco2 < cfg$end_budget_gtco2) stop(sprintf(
    "Invalid carbon budgets: peak_budget_gtco2 (%g Gt CO2) must be >= end_budget_gtco2 (%g Gt CO2). Check these settings before restarting.",
    cfg$peak_budget_gtco2, cfg$end_budget_gtco2))
  if (length(cfg$temperature_case) != 1L || !cfg$temperature_case %in% c("1.5C", "2C")) stop("temperature_case must be 1.5C or 2C")
  if (length(cfg$prefix_policy) != 1L || !cfg$prefix_policy %in% c("exogCV_NPi", "exogCV_1_5C", "exogCV_2C", "exogCV_Calib")) stop("Unsupported prefix_policy")
  keys <- c("start_slope", "initial_slope_step", "initial_end_price_step", "max_price", "slope_resolution",
    "end_price_resolution", "max_evaluations", "peak_tolerance_gtco2", "end_tolerance_gtco2")
  a <- cfg$search
  if (!is.list(a) || anyDuplicated(names(a)) || !setequal(names(a), keys)) stop("Invalid search settings")
  for (k in keys) task7Number(a[[k]], k, 0, k == "max_evaluations")
  if (any(unlist(a[c("initial_slope_step", "initial_end_price_step", "slope_resolution", "end_price_resolution")]) <= 0)) stop("Search steps and resolutions must be positive")
  if (a$max_evaluations < 2) stop("Reserve a search call and independent confirmation")
  if (a$max_price <= cfg$common_price) stop("max_price must exceed common_price")
  if (a$start_slope > task7SlopeLimit(cfg)) stop("start_slope exceeds the straight-path price-bound range")
  cfg
}



task7ReadPolicy <- function(path) {
  widths <- count.fields(path, sep = ",", quote = "\"", comment.char = "")
  if (!length(widths) || anyNA(widths) || any(widths != widths[1L])) stop("Malformed policy table")
  x <- read.csv(path, colClasses = "character", na.strings = NULL, check.names = FALSE,
                comment.char = "", fill = FALSE)
  years <- names(x)[grepl("^[0-9]{4}$", names(x))]
  if (anyDuplicated(years) || !all(as.character(2010:2100) %in% years)) {
    stop("Expected unique annual columns 2010..2100")
  }
  x
}

task7PolicyRow <- function(x, region, policy) {
  i <- which(x[[1L]] == region & x[[2L]] == policy)
  if (length(i) != 1L) stop("Expected exactly one policy row: ", region, "/", policy)
  i
}

task7Setup <- function(cfg, input, regions, allow_legacy = FALSE) {
  cfg <- task7ValidateConfig(cfg, allow_legacy)
  if (!length(regions) || anyDuplicated(regions)) stop("Regions must be distinct and nonempty")
  cfg$regions <- regions
  one_half <- cfg$temperature_case == "1.5C"
  cfg$policy <- if (one_half) "exogCV_1_5C" else "exogCV_2C"
  cfg$emulator <- if (one_half) "1p5C" else "2C"
  cfg$fScenario <- if (one_half) 2L else 3L
  cfg$anchors <- setNames(vector("list", length(regions)), regions)
  for (r in regions) {
    i <- task7PolicyRow(input, r, cfg$prefix_policy)
    task7PolicyRow(input, r, cfg$policy)
    values <- suppressWarnings(as.numeric(input[i, as.character(2010:cfg$fixed_through_year)]))
    if (any(!is.finite(values) | values < 0)) stop("Invalid prefix for ", r)
    # Preserve historical changes before 2023; reject declines during simulation.
    if (any(diff(tail(values, cfg$fixed_through_year - 2023 + 1)) < 0)) stop("Prefix decreases after 2023: ", r)
    cfg$anchors[[r]] <- tail(values, 1L)
  }
  if (cfg$common_price <= max(unlist(cfg$anchors))) stop("Common price must exceed every region's fixed-year price")
  cfg
}

task7SlopeLimit <- function(cfg, front = FALSE) {
  # Straight paths span the whole horizon; a discovered bend can be next year.
  span <- if (front) 1 else cfg$end_year - cfg$common_year
  (cfg$search$max_price - cfg$common_price) / span
}

task7FixedTail <- function(cfg) !is.null(cfg$post_net_zero_slope_multiplier)

# The coefficient fixes the rising post-net-zero segment. At max_price it joins
# a flat plateau. The legacy end-price argument still supports saved free tails.
task7TailEndPrice <- function(cfg, slope, bend_year, end_price = NA_real_) {
  if (!task7FixedTail(cfg)) return(end_price)
  expected <- min(cfg$search$max_price, cfg$common_price + slope * (bend_year - cfg$common_year) +
    cfg$post_net_zero_slope_multiplier * slope * (cfg$end_year - bend_year))
  if (!is.na(end_price)) {
    task7Number(end_price, "end price")
    if (abs(end_price - expected) > 1e-8) stop("Tail price must use the configured post-net-zero slope multiplier")
  }
  expected
}

# Continuous crossing year of the tail's ceiling; the first capped annual
# observation is at ceiling(crossing_year). NA means max_price is not reached.
task7TailCapYear <- function(cfg, slope, bend_year) {
  if (!task7FixedTail(cfg) || is.na(bend_year) || bend_year >= cfg$end_year || slope <= 0) return(NA_real_)
  knot <- cfg$common_price + slope * (bend_year - cfg$common_year)
  if (knot > cfg$search$max_price + 1e-8) return(NA_real_)
  year <- bend_year + max(0, cfg$search$max_price - knot) / (cfg$post_net_zero_slope_multiplier * slope)
  if (year <= cfg$end_year + 1e-10) min(year, cfg$end_year) else NA_real_
}


task7PriceAt <- function(cfg, slope, year, bend_year = NA_real_, end_price = NA_real_) {
  span <- pmin(year, cfg$end_year) - cfg$common_year
  if (is.na(bend_year)) {
    value <- cfg$common_price + slope * span
    value <- pmin(value, cfg$search$max_price) # Only exploratory front probes may reach this cap.
    return(value)
  }
  end_price <- task7TailEndPrice(cfg, slope, bend_year, end_price)
  if (task7FixedTail(cfg)) return(pmin(cfg$search$max_price,
    cfg$common_price + slope * pmin(span, bend_year - cfg$common_year) +
      cfg$post_net_zero_slope_multiplier * slope * pmax(0, span - (bend_year - cfg$common_year))))
  knot <- cfg$common_price + slope * (bend_year - cfg$common_year)
  if (bend_year == cfg$end_year) return(cfg$common_price + slope * span)
  cfg$common_price + slope * pmin(span, bend_year - cfg$common_year) +
    (end_price - knot) * pmax(0, span - (bend_year - cfg$common_year)) / (cfg$end_year - bend_year)
}


task7MakePrices <- function(cfg, input, slope, bend_year = NA_real_, end_price = NA_real_) {
  task7Number(slope, "slope")
  if (length(bend_year) != 1L || (!is.na(bend_year) &&
      (!is.finite(bend_year) || bend_year != trunc(bend_year) || bend_year <= cfg$common_year ||
       bend_year > cfg$end_year))) stop("Invalid price bend year")
  if (!is.na(bend_year)) {
    end_price <- task7TailEndPrice(cfg, slope, bend_year, end_price)
    task7Number(end_price, "end price")
    knot <- cfg$common_price + slope * (bend_year - cfg$common_year)
    if (end_price < knot - 1e-8 || end_price > cfg$search$max_price + 1e-8 ||
        (bend_year == cfg$end_year && abs(end_price - knot) > 1e-8)) stop("Require a nondecreasing tail within max_price")
  }
  output <- input; years <- (cfg$fixed_through_year + 1):2100; shared <- years >= cfg$common_year
  for (r in cfg$regions) {
    src <- task7PolicyRow(input, r, cfg$prefix_policy); dest <- task7PolicyRow(input, r, cfg$policy)
    prefix <- as.character(2010:cfg$fixed_through_year); output[dest, prefix] <- input[src, prefix]
    prices <- cfg$anchors[[r]] + (cfg$common_price - cfg$anchors[[r]]) *
      (years - cfg$fixed_through_year) / (cfg$common_year - cfg$fixed_through_year)
    prices[shared] <- task7PriceAt(cfg, slope, years[shared], bend_year, end_price)
    if (any(!is.finite(prices)) || any(prices > cfg$search$max_price + 1e-8)) stop("price_bound: actual price path exceeds max_price")
    output[dest, as.character(years)] <- as.list(sprintf("%.15g", prices))
    actual <- as.numeric(output[dest, as.character(2023:2100)])
    if (any(!is.finite(actual)) || any(diff(actual) < -1e-10)) stop("Invalid constructed price path")
  }
  output
}



task7WritePrices <- function(path, x) {
  if (any(grepl('[,\r\n"]', unlist(x)))) stop("Unexpected separator in policy cells")
  tmp <- paste0(path, ".tmp")
  write.table(x, tmp, sep = ",", quote = FALSE, row.names = FALSE, col.names = TRUE, na = "NA")
  if (!file.copy(tmp, path, overwrite = TRUE)) stop("Cannot write price file")
  unlink(tmp)
  if (!identical(task7ReadPolicy(path), x)) stop("Price CSV round-trip changed values")
}

task7SamePrices <- function(x, y) {
  # Excel stores numeric anchors, so reconstruction can differ in the last
  # printed decimal. Compare the actual prices rather than CSV text spelling.
  if (!identical(names(x), names(y)) || !identical(x[, 1:2], y[, 1:2])) return(FALSE)
  left <- as.vector(as.matrix(x[, -(1:2)])); right <- as.vector(as.matrix(y[, -(1:2)]))
  a <- suppressWarnings(as.numeric(left)); b <- suppressWarnings(as.numeric(right))
  numeric <- is.finite(a)
  length(a) == length(b) && identical(numeric, is.finite(b)) &&
    identical(left[!numeric], right[!numeric]) && all(abs(a[numeric] - b[numeric]) <= 1e-12 * pmax(1, abs(b[numeric])))
}

# ---- Peak and end-budget calibration ---------------------------------------
task7Metrics <- function(cfg, world) {
  world <- world[order(world$year), ]; use <- world$year >= cfg$budget_start_year
  cumulative <- rep(NA_real_, nrow(world)); cumulative[use] <- cumsum(world$emissions_mtco2[use]) / 1000
  peak <- which.max(cumulative)
  crossing <- which(use & world$emissions_mtco2 <= 0 & c(FALSE, head(world$emissions_mtco2, -1L) > 0))
  first <- if (length(crossing)) crossing[1L] else NA_integer_
  nz_peak <- if (is.na(first)) NA_integer_ else which.max(replace(cumulative, seq_along(cumulative) > first, NA_real_))
  zero_year <- if (is.na(first)) NA_real_ else world$year[first]
  list(valid = TRUE, net_zero_year = zero_year,
    net_zero_mtco2 = if (is.na(first)) NA_real_ else world$emissions_mtco2[first],
    net_zero_peak_gtco2 = if (is.na(nz_peak)) NA_real_ else cumulative[nz_peak],
    net_zero_peak_year = if (is.na(nz_peak)) NA_real_ else world$year[nz_peak],
    cumulative_gtco2 = tail(cumulative, 1L), peak_cumulative_gtco2 = cumulative[peak], peak_year = world$year[peak],
    prefix_peak_gtco2 = max(cumulative[use & world$year <= cfg$common_year]),
    later_positive_years = if (is.na(first)) integer() else world$year[world$year > zero_year & world$emissions_mtco2 > 0])
}


task7ValidMetrics <- function(a, cfg) {
  finite <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  fields <- c("cumulative_gtco2", "peak_cumulative_gtco2", "prefix_peak_gtco2", "peak_year")
  if (!isTRUE(a$valid) || !all(vapply(a[fields], finite, logical(1)))) return(FALSE)
  year <- a$net_zero_year; nz <- c("net_zero_mtco2", "net_zero_peak_gtco2", "net_zero_peak_year")
  if (!is.numeric(year) || length(year) != 1L) return(FALSE)
  if (is.na(year)) return(all(vapply(a[nz], function(x) is.numeric(x) && length(x) == 1L && is.na(x), logical(1))))
  finite(year) && year == trunc(year) && year >= cfg$budget_start_year && year <= cfg$end_year &&
    all(vapply(a[nz], finite, logical(1))) && a$net_zero_mtco2 <= 0 && a$net_zero_peak_year <= year
}



task7EndRule <- function(a, cfg) {
  if (identical(a$purpose, "Probe")) return("Not checked")
  if (is.na(a$bend_year)) return("band")
  if (task7FixedTail(cfg)) return("ceiling")
  if (is.null(a$flat_end_gtco2) || is.na(a$flat_end_gtco2)) return("Not checked")
  if (a$flat_end_gtco2 <= cfg$end_budget_gtco2) "ceiling" else "band"
}

task7PeakNear <- function(a, cfg) {
  task7ValidMetrics(a, cfg) && !is.na(a$net_zero_year) && a$net_zero_year > cfg$common_year &&
    a$net_zero_peak_gtco2 <= cfg$peak_budget_gtco2 &&
    a$net_zero_peak_gtco2 >= cfg$peak_budget_gtco2 - cfg$search$peak_tolerance_gtco2
}

task7Passes <- function(a, cfg) {
  if (!task7ValidMetrics(a, cfg) || identical(a$purpose, "Probe")) return(FALSE)
  if (a$peak_cumulative_gtco2 > cfg$peak_budget_gtco2 || a$cumulative_gtco2 > cfg$end_budget_gtco2) return(FALSE)
  if (is.na(a$bend_year)) return(a$slope <= task7SlopeLimit(cfg) + 1e-10)
  if (task7FixedTail(cfg) && (!is.numeric(a$end_price) || length(a$end_price) != 1L ||
      !is.finite(a$end_price) || a$end_price > cfg$search$max_price + 1e-8 ||
      cfg$common_price + a$slope * (a$bend_year - cfg$common_year) > cfg$search$max_price + 1e-8 ||
      abs(a$end_price - task7TailEndPrice(cfg, a$slope, a$bend_year)) > 1e-8)) return(FALSE)
  !is.na(a$net_zero_year) && a$net_zero_year > cfg$common_year &&
    isTRUE(all.equal(a$bend_year, a$net_zero_year, tolerance = 0))
}


task7Converged <- function(a, cfg) {
  if (!task7Passes(a, cfg)) return(FALSE)
  if (!is.na(a$bend_year) && !task7PeakNear(a, cfg)) return(FALSE)
  rule <- task7EndRule(a, cfg)
  rule == "ceiling" || (rule == "band" && a$cumulative_gtco2 >= cfg$end_budget_gtco2 - cfg$search$end_tolerance_gtco2)
}



task7Candidate <- function(cfg, slope, evaluate, purpose = "Straight") {
  a <- evaluate(slope, NA_real_, purpose)
  if (!task7ValidMetrics(a, cfg)) stop("invalid_run: ", a$reason)
  if (a$prefix_peak_gtco2 > cfg$peak_budget_gtco2) stop("fixed_prefix_budget: prescribed prices through common_year exceed the peak budget; start a new campaign with a different early path")
  if (purpose == "Probe") {
    if (!is.na(a$net_zero_year) && a$net_zero_year <= cfg$common_year) stop("fixed_prefix_net_zero: net zero precedes the searched front; choose an earlier common_year")
    a$path_bound <- !is.na(a$net_zero_year) && cfg$common_price + slope * (a$net_zero_year - cfg$common_year) > cfg$search$max_price + 1e-8
  }
  a
}


task7SearchScalar <- function(start, lower, upper, step, resolution, run, price, direction, residual, tolerance, label, lower_reason, upper_reason) {
  samples <- list()
  sample <- function(value) {
    x <- run(value); d <- direction(x)
    for (old in samples) if ((price(old) < value && direction(old) <= 0 && d > 0) ||
                            (price(old) > value && direction(old) > 0 && d <= 0)) stop(label, "_nonmonotone_response: search direction reversed")
    samples[[length(samples) + 1L]] <<- x
    x
  }
  current <- sample(start)
  repeat {
    d <- direction(current)
    if (d == 0L) return(current)
    if (d < 0L && price(current) <= lower) stop(label, "_lower_bound: ", lower_reason)
    if (d > 0L && price(current) >= upper) stop(label, "_upper_bound: ", upper_reason)
    candidate <- max(lower, min(upper, price(current) + d * step))
    if (candidate == price(current)) stop(label, "_precision_limit: search step cannot advance")
    message(sprintf("%s jump: %.6f -> %.6f", label, price(current), candidate))
    next_result <- sample(candidate); nd <- direction(next_result)
    if (nd == 0L) return(next_result)
    if (nd != d) {
      lo <- if (d > 0L) current else next_result; hi <- if (d > 0L) next_result else current
      repeat {
        width <- price(hi) - price(lo)
        if (width <= resolution) {
          if (label == "Peak" && is.na(lo$net_zero_year) && !isTRUE(hi$path_bound)) stop("net_zero_end_year_boundary: net zero and the peak tolerance cannot both be reached within the model horizon")
          stop(label, "_precision_limit: target remains outside tolerance; no front recalibration")
        }
        rlo <- residual(lo); rhi <- residual(hi)
        fraction <- if (is.finite(rlo) && is.finite(rhi) && rlo > rhi) (rlo + tolerance / 2) / (rlo - rhi) else 0.5
        if (!is.finite(fraction)) fraction <- 0.5
        candidate <- price(lo) + width * min(0.9, max(0.1, fraction))
        quantum <- resolution / 10; rounded <- round(candidate / quantum) * quantum
        if (rounded > price(lo) && rounded < price(hi)) candidate <- rounded
        if (candidate <= price(lo) || candidate >= price(hi)) candidate <- (price(lo) + price(hi)) / 2
        message(sprintf("%s refinement: %.6f; bracket [%.6f, %.6f]", label, candidate, price(lo), price(hi)))
        x <- sample(candidate); dx <- direction(x)
        if (dx == 0L) return(x)
        if (dx > 0L) lo <- x else hi <- x
      }
    }
    current <- next_result; step <- min(upper - lower, 2 * step)
  }
}

task7Search <- function(cfg, evaluate) {
  a <- cfg$search
  end_direction <- function(x) {
    gap <- x$cumulative_gtco2 - cfg$end_budget_gtco2
    if (gap > 0) 1L else if (gap < -a$end_tolerance_gtco2) -1L else 0L
  }
  # Always calibrate a legal single straight path before deciding to split it.
  straight <- task7SearchScalar(a$start_slope, 0, task7SlopeLimit(cfg), a$initial_slope_step, a$slope_resolution,
    function(s) task7Candidate(cfg, s, evaluate, "Straight"), function(x) x$slope, end_direction,
    function(x) x$cumulative_gtco2 - cfg$end_budget_gtco2, a$end_tolerance_gtco2, "End",
    "zero slope is already below the end-budget band; lower common_price/adjust the early path and start a new campaign; raising common_price would not help",
    "end budget not reached within max_price")
  if (task7Converged(straight, cfg)) {
    straight$calibration_note <- "Single straight path meets the end-budget band and full peak ceiling; net zero is not required or forbidden"
    return(straight)
  }
  if (straight$peak_cumulative_gtco2 <= cfg$peak_budget_gtco2) stop("Invalid straight-path result")
  message(sprintf("Straight end budget calibrated, but peak %.6f exceeds %.6f Gt; searching a net-zero-bent path", straight$peak_cumulative_gtco2, cfg$peak_budget_gtco2))
  front_direction <- function(x) {
    if (isTRUE(x$path_bound)) return(-1L)
    if (is.na(x$net_zero_year)) return(1L)
    gap <- x$net_zero_peak_gtco2 - cfg$peak_budget_gtco2
    if (gap > 0) 1L else if (gap < -a$peak_tolerance_gtco2) -1L else 0L
  }
  front_residual <- function(x) {
    if (isTRUE(x$path_bound) || is.na(x$net_zero_year)) return(NA_real_)
    x$net_zero_peak_gtco2 - cfg$peak_budget_gtco2
  }
  chosen <- task7SearchScalar(straight$slope, straight$slope, task7SlopeLimit(cfg, front = TRUE), a$initial_slope_step, a$slope_resolution,
    function(s) task7Candidate(cfg, s, evaluate, "Probe"), function(x) x$slope, front_direction, front_residual,
    a$peak_tolerance_gtco2, "Peak",
    "the straight-path slope cannot approach the first-peak band while respecting the full peak ceiling; calibration incomplete",
    "target/net zero not reached within the price ceiling and model horizon")
  if (!task7PeakNear(chosen, cfg)) stop("Peak calibration did not converge")
  year <- chosen$net_zero_year; slope <- chosen$slope
  knot <- cfg$common_price + slope * (year - cfg$common_year)
  tail_run <- function(end, purpose = "Tail", flat_trial = NA_integer_) {
    x <- evaluate(slope, year, purpose, end_price = end, flat_trial = flat_trial)
    if (!task7ValidMetrics(x, cfg)) stop("invalid_run: ", x$reason)
    before <- chosen$world$year <= year
    if (!isTRUE(all.equal(x$net_zero_year, year, tolerance = 0)) ||
        !isTRUE(all.equal(x$world$emissions_mtco2[before], chosen$world$emissions_mtco2[before], tolerance = 1e-10))) stop("prefix_changed: tail changed emissions before/at net zero")
    x
  }
  message(sprintf("Peak stage complete: slope %.6f; net-zero year %d; peak %.6f Gt", slope, year, chosen$net_zero_peak_gtco2))
  if (task7FixedTail(cfg)) {
    end <- task7TailEndPrice(cfg, slope, year)
    fixed <- tail_run(end, "FixedTail")
    if (!task7Converged(fixed, cfg)) stop("fixed_tail_budget: configured tail ratio does not meet the peak/end constraints; calibration incomplete without front recalibration")
    fixed$calibration_note <- sprintf("Peak within tolerance; tail rises at %.15g times the front slope until max_price, then stays flat; end ceiling met, including slack totals", cfg$post_net_zero_slope_multiplier)
    return(fixed)
  }
  # Legacy campaigns only: retain their original flat baseline and free-tail
  # search so existing 300/400/500 results are never reinterpreted with a ratio.
  flat <- tail_run(knot, "Flat")
  if (task7Converged(flat, cfg)) {
    flat$calibration_note <- "Peak within tolerance; flat tail meets the end ceiling, including slack totals"
    return(flat)
  }
  if (year == cfg$end_year || knot >= a$max_price) stop("Tail_upper_bound: no remaining legal tail adjustment; calibration incomplete without front recalibration")
  rule <- task7EndRule(flat, cfg)
  # The straight probe is a valid tail-price sample only if it was not clipped.
  # Reuse it as a numerical endpoint when its complete price path is identical.
  run <- function(end) {
    uncut_end <- cfg$common_price + slope * (cfg$end_year - cfg$common_year)
    if (abs(end - uncut_end) <= 1e-10 && uncut_end <= a$max_price) {
      x <- chosen; x$purpose <- "Tail"; x$bend_year <- year
      x$flat_trial <- flat$iteration; x$flat_end_gtco2 <- flat$cumulative_gtco2
      message("Reusing the unclipped straight probe as a tail-price endpoint")
      return(x)
    }
    tail_run(end, "Tail", flat$iteration)
  }
  direction <- function(x) {
    if (x$peak_cumulative_gtco2 > cfg$peak_budget_gtco2 || x$cumulative_gtco2 > cfg$end_budget_gtco2) return(1L)
    if (rule == "band" && x$cumulative_gtco2 < cfg$end_budget_gtco2 - a$end_tolerance_gtco2) return(-1L)
    0L
  }
  residual <- function(x) {
    if (x$peak_cumulative_gtco2 > cfg$peak_budget_gtco2) max(x$peak_cumulative_gtco2 - cfg$peak_budget_gtco2, x$cumulative_gtco2 - cfg$end_budget_gtco2)
    else x$cumulative_gtco2 - cfg$end_budget_gtco2
  }
  accepted <- task7SearchScalar(knot, knot, a$max_price, a$initial_end_price_step, a$end_price_resolution,
    function(end) if (end == knot) flat else run(end), function(x) x$end_price, direction, residual,
    if (rule == "band") a$end_tolerance_gtco2 else 0, "Tail",
    "cannot reduce the tail below the flat price; calibration incomplete without front recalibration",
    "end/peak constraints not reached at max_price; calibration incomplete without front recalibration")
  if (!task7Converged(accepted, cfg)) stop("Invalid two-budget result")
  accepted$calibration_note <- if (rule == "ceiling") "Peak within tolerance; flat-baseline end ceiling rule" else
    "Peak and end cumulative CO2 both within their separate tolerance bands"
  accepted
}

# ---- Shared model execution and process recovery -----------------------------
task7Hash <- function(path) digest::digest(file = path, algo = "sha256")

# Use the unchanged research writer inside the project, then copy its outputs
# to confirmation. This also works when a resumed campaign is outside the repo.
task7SaveMetadata <- function(root, trial) {
  dir.create(file.path(root, "runs"), showWarnings = FALSE)
  staging <- tempfile(".task7-metadata-", tmpdir = file.path(root, "runs"))
  if (!dir.create(staging)) stop("Cannot stage confirmation metadata")
  previous_wd <- getwd()
  on.exit({ setwd(previous_wd); unlink(staging, recursive = TRUE) }, add = TRUE)
  setwd(staging)
  saveMetadata(DevMode = 0)
  files <- file.path(staging, c("metadata.json", "git_diff.txt"))
  if (!all(file.exists(files)) || !all(file.copy(files, trial, overwrite = TRUE))) {
    stop("Cannot save confirmation metadata")
  }
  invisible(NULL)
}

task7ProcessEnvironment <- function(run_config, campaign) {
  scenario <- run_config$scenario
  if (is.null(scenario)) scenario <- list()
  c("current",
    OPENPROM_SCENARIO = as.character(jsonlite::toJSON(scenario, auto_unbox = TRUE, null = "null", digits = NA)),
    OPENPROM_CONFIG = file.path(campaign, "config.json"))
}

# Once the owned child has exited, process-tree enumeration is unnecessary.
# If interruption cleanup fails, keep its marker for verified recovery.
task7CleanupProcess <- function(p, marker) {
  tryCatch({
    if (p$is_alive()) {
      p$kill_tree()
      p$wait(timeout = 5000) # Grace period for cleanup only.
    }
    if (p$is_alive()) stop("Owned process still running")
    if (file.exists(marker) && (unlink(marker) != 0L || file.exists(marker))) {
      stop("Cannot clear owned process marker")
    }
    TRUE
  }, error = function(e) {
    # A warning promoted to an error must not replace the original failure.
    tryCatch(warning("Calibration process cleanup: ", conditionMessage(e), "; marker retained", call. = FALSE),
             error = function(e) NULL)
    FALSE
  })
}

task7RunProcess <- function(command, args, wd, log, env = NULL, marker_folder = wd,
                            process_factory = processx::process$new) {
  # Keep the persisted marker name stable across task renumbering.
  marker <- file.path(marker_folder, "task6-process.rds")
  if (file.exists(marker)) stop("Retained process needs cleanup before a new launch: ", wd)
  # NULL sends output to the console. The registered handler owns cleanup.
  p <- process_factory(command, args, wd = wd,
                       stdout = if (is.null(log)) "" else log,
                       stderr = if (is.null(log)) "" else "2>&1", env = env,
                       cleanup = FALSE, cleanup_tree = FALSE, supervise = TRUE)
  on.exit(task7CleanupProcess(p, marker), add = TRUE)
  saveRDS(list(pid = p$get_pid(), created = as.numeric(p$get_start_time()),
               wd = normalizePath(wd, winslash = "/")), marker)
  p$wait()
  status <- p$get_exit_status()
  if (status != 0) stop("process_exit_", status, if (is.null(log)) "" else paste0(": ", log))
  invisible(list(status = status))
}

# Only a recorded calibration process with the expected launch directory can be
# stopped. Full reporting runs at the project root but keeps its marker in the
# campaign; creation time prevents killing a reused OS PID.
task7StopRetainedProcess <- function(folder, expected_wd = folder) {
  marker <- file.path(folder, "task6-process.rds")
  if (!file.exists(marker)) return(invisible(NULL))
  record <- readRDS(marker)
  if (!identical(record$wd, normalizePath(expected_wd, winslash = "/")) ||
      length(record$pid) != 1L || !is.finite(record$pid) || record$pid <= 0 ||
      length(record$created) != 1L || !is.finite(record$created)) stop("Invalid retained process identity; keeping work")
  handle <- ps::ps_handle(record$pid, as.POSIXct(record$created, origin = "1970-01-01", tz = "UTC"))
  if (ps::ps_is_running(handle)) {
    # Model trials must stay in their launch directory. A full report has a
    # separate campaign marker and may temporarily chdir while knitting; its
    # recorded launch directory and PID creation time still identify it.
    if (identical(normalizePath(folder, winslash = "/"), record$wd) &&
        !identical(normalizePath(ps::ps_cwd(handle), winslash = "/"), record$wd)) {
      stop("Retained process working directory changed; keeping work")
    }
    message("Stopping interrupted calibration process ", record$pid, " in ", folder)
    children <- ps::ps_children(handle, recursive = TRUE)
    for (child in rev(children)) if (ps::ps_is_running(child)) ps::ps_kill(child)
    if (ps::ps_is_running(handle)) ps::ps_kill(handle)
    for (i in seq_len(100L)) {
      if (!any(vapply(c(children, list(handle)), ps::ps_is_running, logical(1)))) break
      Sys.sleep(0.05)
    }
    if (any(vapply(c(children, list(handle)), ps::ps_is_running, logical(1)))) stop("Interrupted process still running; keeping work")
  }
  if (unlink(marker) != 0L || file.exists(marker)) stop("Cannot clear retained process marker")
  invisible(NULL)
}

task7CheckSolves <- function(trial, regions, years) {
  lines <- readLines(file.path(trial, "modelstat.txt"), warn = FALSE)
  lines <- lines[nzchar(trimws(lines))]
  pattern <- "^\\s*Country:\\s*(\\S+)\\s+Model Status:\\s*([0-9.]+)\\s+Year:\\s*([0-9]+)\\s*$"
  fields <- regmatches(lines, regexec(pattern, lines, perl = TRUE))
  if (!length(fields) || any(lengths(fields) != 4L)) stop("Malformed modelstat records")
  values <- do.call(rbind, fields)
  key <- paste(values[, 2L], values[, 4L], sep = ":")
  expected <- as.vector(outer(regions, years, paste, sep = ":"))
  if (anyDuplicated(key) || !setequal(key, expected) || any(as.numeric(values[, 3L]) != 2)) {
    stop("Missing region/year or non-optimal final model status")
  }
  listing <- readLines(file.path(trial, "main.lst"), warn = FALSE)
  matches <- grep("SOLVER STATUS\\s+[0-9]+", listing, value = TRUE, perl = TRUE)
  status <- as.integer(sub(".*SOLVER STATUS\\s+([0-9]+).*", "\\1", matches, perl = TRUE))
  if (length(status) < length(expected) || anyNA(status) || any(status != 1L)) {
    stop("Missing solver status or non-normal solver attempt")
  }
  list(final_region_years = length(key), solver_attempts = length(status))
}

# ---- Excel history and safe temporary-file cleanup --------------------------
task7SelectedPrices <- function(cfg, prices) {
  rows <- vapply(cfg$regions, function(r) task7PolicyRow(prices, r, cfg$policy), integer(1))
  x <- prices[rows, , drop = FALSE]
  names(x) <- names(prices)
  rownames(x) <- NULL
  x
}

task7ValidateReport <- function(cfg, report) {
  annual <- report$annual; world <- report$world; years <- 2010:cfg$end_year
  if (!is.data.frame(annual) || !all(c("region", "year", "value") %in% names(annual)) ||
      !is.data.frame(world) || !all(c("year", "emissions_mtco2") %in% names(world))) stop("Incomplete annual emissions report; retaining trial")
  keys <- paste(annual$region, annual$year, sep = ":")
  expected <- as.vector(outer(cfg$regions, years, paste, sep = ":"))
  if (anyDuplicated(keys) || !setequal(keys, expected) || !is.numeric(annual$value) || any(!is.finite(annual$value)) ||
      anyDuplicated(world$year) || !identical(as.integer(world$year), years) ||
      !is.numeric(world$emissions_mtco2) || any(!is.finite(world$emissions_mtco2))) stop("Invalid annual emissions grid; retaining trial")
  totals <- aggregate(value ~ year, annual, sum)
  same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
  if (!same(totals$value[match(years, totals$year)], world$emissions_mtco2)) stop("Regional and global emissions disagree; retaining trial")
  metrics <- task7Metrics(cfg, world)
  if (!task7ValidMetrics(report$metrics, cfg)) stop("Invalid emissions metrics; retaining trial")
  for (key in names(metrics)) if (!same(metrics[[key]], report$metrics[[key]])) stop("Annual emissions and target metrics disagree: ", key)
  invisible(NULL)
}


task7AnnualRows <- function(cfg, iteration, prices = NULL, report = NULL) {
  n <- length(cfg$regions)
  x <- data.frame(Trial = rep(iteration, 2L * n + 1L),
                  Metric = c(rep("Carbon price", n), rep("Net CO2 emissions", n + 1L)),
                  Region = c(cfg$regions, cfg$regions, "World"),
                  Unit = c(rep("USD2015/t CO2", n), rep("Mt CO2/yr", n + 1L)),
                  check.names = FALSE)
  for (year in 2010:2100) x[[as.character(year)]] <- NA_real_
  if (!is.null(prices)) {
    values <- task7SelectedPrices(cfg, prices)
    for (year in as.character(2010:2100)) {
      value <- suppressWarnings(as.numeric(values[[year]]))
      if (length(value) != n || any(!is.finite(value))) stop("Incomplete annual price record; retaining trial")
      x[seq_len(n), year] <- value
    }
  }
  if (!is.null(report)) {
    if (is.null(prices)) stop("Missing prices for a reported trial; retaining trial")
    task7ValidateReport(cfg, report)
    annual <- report$annual
    for (year in sort(unique(annual$year))) {
      rows <- annual[annual$year == year, ]
      x[n + seq_len(n), as.character(year)] <- rows$value[match(cfg$regions, rows$region)]
      x[2L * n + 1L, as.character(year)] <- report$world$emissions_mtco2[report$world$year == year]
    }
  }
  x
}

task7Summary <- function(trials, cfg, accepted_iteration = NA_integer_) {
  field <- function(x, name, missing = NA_real_) if (is.null(x[[name]])) missing else x[[name]]
  row <- function(a) {
    bent <- !is.null(a$bend_year) && !is.na(a$bend_year); valid <- isTRUE(a$valid)
    # FixedTail reports the rising segment before the plateau, not the average
    # slope from the net-zero knot to the capped end price.
    tail_slope <- if (bent && a$bend_year < cfg$end_year) {
      if (task7FixedTail(cfg)) a$slope * cfg$post_net_zero_slope_multiplier else
        (a$end_price - cfg$common_price - a$slope * (a$bend_year - cfg$common_year)) / (cfg$end_year - a$bend_year)
    } else NA_real_
    d <- data.frame(Trial = field(a, "iteration", NA_integer_), Stage = field(a, "purpose", NA_character_),
      `Slope (USD2015/t CO2/year)` = field(a, "slope"), BendYear = field(a, "bend_year"),
      NetZeroYear = field(a, "net_zero_year"), `NetZeroPrice (USD2015/t CO2)` = field(a, "net_zero_price"),
      EndYear = cfg$end_year, `EndPrice (USD2015/t CO2)` = field(a, "end_price"),
      `TailSlope (USD2015/t CO2/year)` = tail_slope,
      TailFactor = if (!is.null(a$slope) && a$slope > 0) tail_slope / a$slope else NA_real_,
      # Retained archive columns: empty for new fixed-ratio campaigns; used only
      # to reconstruct the mandatory flat baseline of legacy free-tail searches.
      FlatTrial = field(a, "flat_trial", NA_integer_), `FlatEndCO2 (Gt CO2)` = field(a, "flat_end_gtco2"),
      EndRule = if (valid) task7EndRule(a, cfg) else NA_character_, ValidRun = field(a, "valid", NA),
      `NetZeroYearCO2 (Mt CO2/yr)` = field(a, "net_zero_mtco2"),
      `NetZeroPeakCO2 (Gt CO2)` = field(a, "net_zero_peak_gtco2"), NetZeroPeakYear = field(a, "net_zero_peak_year"),
      `PeakCumulativeCO2 (Gt CO2)` = field(a, "peak_cumulative_gtco2"), PeakYear = field(a, "peak_year"),
      `EndCumulativeCO2 (Gt CO2)` = field(a, "cumulative_gtco2"),
      `PeakBudget (Gt CO2)` = cfg$peak_budget_gtco2, `EndBudget (Gt CO2)` = cfg$end_budget_gtco2,
      NetZeroMet = if (valid && bent) !is.na(a$net_zero_year) else NA,
      PeakMet = if (valid) a$peak_cumulative_gtco2 <= cfg$peak_budget_gtco2 else NA,
      PeakBandMet = if (valid && bent) task7PeakNear(a, cfg) else NA,
      EndMet = if (valid) a$cumulative_gtco2 <= cfg$end_budget_gtco2 else NA,
      BothMet = if (valid) task7Passes(a, cfg) else NA, WithinTolerance = if (valid) task7Converged(a, cfg) else NA,
      Accepted = !is.na(accepted_iteration) && identical(a$iteration, accepted_iteration),
      `PrefixPeakCO2 (Gt CO2)` = field(a, "prefix_peak_gtco2"),
      LaterPositiveYears = if (length(a$later_positive_years)) paste(a$later_positive_years, collapse = ", ") else NA_character_,
      NormalRegionYears = field(a$solves, "final_region_years"), SolverAttempts = field(a$solves, "solver_attempts"),
      ElapsedSeconds = field(a, "elapsed_seconds"), FailureReason = field(a, "reason", NA_character_),
      LogExcerpt = field(a, "log_excerpt", NA_character_), check.names = FALSE)
    if (task7FixedTail(cfg)) d$TailPriceCapYear <- if (bent) task7TailCapYear(cfg, a$slope, a$bend_year) else NA_real_
    d
  }
  if (!length(trials)) return(row(list())[FALSE, , drop = FALSE])
  do.call(rbind, lapply(trials, row))
}



task7ReplaceFile <- function(staged, destination) {
  # Keep the previous archive until the replacement's hash is verified. This
  # also handles Windows file locks and failures/interrupts during publication.
  expected_hash <- task7Hash(staged)
  backup <- paste0(destination, ".previous")
  if (file.exists(backup)) stop("Previous publication needs recovery: ", backup)
  had_previous <- file.exists(destination)
  if (had_previous && !file.copy(destination, backup, overwrite = FALSE)) stop("Cannot preserve previous file: ", destination)
  if (had_previous && !identical(task7Hash(backup), task7Hash(destination))) stop("Previous copy verification failed")
  published <- FALSE
  on.exit({
    if (!published && file.exists(backup)) {
      # Prefer restoring the normal path; always retain the backup on failure.
      suppressWarnings(file.copy(backup, destination, overwrite = TRUE))
    } else if (!published && !had_previous && file.exists(destination)) {
      # A first publication that failed verification must not look finalized.
      # Move it back to staging so a failed CSV export remains recoverable.
      suppressWarnings(file.rename(destination, staged))
    }
  }, add = TRUE)
  if (!isTRUE(suppressWarnings(file.rename(staged, destination)))) {
    # POSIX can replace atomically; Windows may require removing an unlocked
    # destination first. A verified backup is already present before removal.
    if (!had_previous || unlink(destination) != 0L || file.exists(destination) ||
        !isTRUE(suppressWarnings(file.rename(staged, destination)))) stop("Cannot publish file: ", destination)
  }
  if (!identical(task7Hash(destination), expected_hash)) stop("Published file hash mismatch: ", destination)
  published <- TRUE
  if (had_previous) unlink(backup)
  invisible(NULL)
}

# openxlsx coalesces consecutive line breaks in text cells. Normalize display
# whitespace before saving or comparing a pending checkpoint to the workbook.
task7HistorySheets <- function(annual, summary, settings) {
  lapply(list(AnnualPaths = annual, SearchSummary = summary, Settings = settings), function(data) {
    text_columns <- vapply(data, is.character, logical(1))
    data[text_columns] <- lapply(data[text_columns], function(x) gsub("\n{2,}", "\n", gsub("\r\n?", "\n", x)))
    data
  })
}

task7HistoryIssue <- function(path, sheets) {
  if (!identical(openxlsx::getSheetNames(path), names(sheets))) return("Workbook sheet verification failed")
  for (name in names(sheets)) {
    expected <- sheets[[name]]
    actual <- openxlsx::read.xlsx(path, sheet = name, check.names = FALSE,
                                  skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character(), sep.names = " ")
    if (!identical(names(actual), names(expected)) || nrow(actual) != nrow(expected)) {
      return(paste0("Workbook layout verification failed: ", name))
    }
    for (j in seq_along(expected)) {
      a <- actual[[j]]
      b <- expected[[j]]
      if (!identical(is.na(a), is.na(b))) return(paste0("Workbook changed missing values: ", name))
      ok <- !is.na(b)
      if (is.numeric(b)) {
        observed <- as.numeric(a[ok])
        if (any(!is.finite(observed)) || any(abs(observed - b[ok]) > 1e-12 * pmax(1, abs(b[ok])))) {
          return("Workbook changed numeric values")
        }
      } else if (!identical(as.character(a[ok]), as.character(b[ok]))) {
        return("Workbook changed labels or flags")
      }
    }
  }
  NULL
}

task7SaveHistory <- function(path, annual, summary, settings) {
  sheets <- task7HistorySheets(annual, summary, settings)
  if (any(vapply(sheets, nrow, integer(1)) >= 1048576L)) stop("Excel row limit exceeded")
  wb <- openxlsx::createWorkbook(creator = "Yu, Songmin")
  openxlsx::modifyBaseFont(wb, fontName = "Arial", fontSize = 10)
  header <- openxlsx::createStyle(fgFill = "#243746", fontColour = "#FFFFFF", textDecoration = "bold",
                                  halign = "center", valign = "center", wrapText = TRUE)
  for (i in seq_along(sheets)) {
    name <- names(sheets)[i]; data <- sheets[[i]]
    openxlsx::addWorksheet(wb, name, gridLines = FALSE)
    if (nrow(data)) {
      openxlsx::writeDataTable(wb, name, data, tableName = c("AnnualPaths", "SearchSummary", "RunSettings")[i],
                               tableStyle = "TableStyleLight9", headerStyle = header, keepNA = FALSE)
    } else {
      openxlsx::writeData(wb, name, data, headerStyle = header, keepNA = FALSE)
    }
    openxlsx::freezePane(wb, name, firstActiveRow = 2, firstActiveCol = if (i == 1L) 5 else 3)
    openxlsx::setRowHeights(wb, name, 1, if (i == 2L) 48 else 30)
    if (i == 1L) {
      openxlsx::setColWidths(wb, name, 1:4, c(12, 24, 12, 22))
      openxlsx::setColWidths(wb, name, 5:ncol(data), 14)
    } else if (i == 2L) {
      openxlsx::setColWidths(wb, name, seq_len(ncol(data)), 18)
      openxlsx::setColWidths(wb, name, which(grepl("Price|CO2|Slope", names(data))), 25)
      openxlsx::setColWidths(wb, name, match(c("FailureReason", "LogExcerpt"), names(data)), c(55, 75))
    } else {
      openxlsx::setColWidths(wb, name, 1:2, c(32, 85))
    }
    numeric_columns <- which(vapply(data, is.numeric, logical(1)))
    if (i == 1L) numeric_columns <- 5:ncol(data)
    if (i == 2L) numeric_columns <- which(vapply(data, is.numeric, logical(1)))
    if (nrow(data) && length(numeric_columns)) {
      openxlsx::addStyle(wb, name, openxlsx::createStyle(numFmt = "#,##0.000000"),
                         rows = 2:(nrow(data) + 1L), cols = numeric_columns, gridExpand = TRUE, stack = TRUE)
    }
  }
  staged <- tempfile(".history-", tmpdir = dirname(path), fileext = ".xlsx")
  on.exit(if (file.exists(staged)) unlink(staged), add = TRUE)
  openxlsx::saveWorkbook(wb, staged, overwrite = TRUE)
  issue <- task7HistoryIssue(staged, sheets)
  if (!is.null(issue)) stop(issue)
  digest <- task7Hash(staged)
  task7ReplaceFile(staged, path)
  if (!identical(task7Hash(path), digest)) stop("Published workbook hash mismatch")
  digest
}

task7Cleanup <- function(path, parent, history, saved_hash) {
  if (!dir.exists(path)) return(invisible(NULL))
  link <- Sys.readlink(path)
  if ((!is.na(link) && nzchar(link)) ||
      !identical(normalizePath(dirname(path), winslash = "/"), normalizePath(parent, winslash = "/")) ||
      !grepl("^(\\.work|trial-[0-9]+)$", basename(path))) stop("Refusing to remove an unexpected directory")
  if (!file.exists(history) || !identical(task7Hash(history), saved_hash)) {
    stop("History changed or is missing; keeping temporary directory: ", path)
  }
  if (any(basename(list.files(path, recursive = TRUE, all.files = TRUE)) == "task6-process.rds")) {
    stop("Process cleanup has not completed; keeping temporary directory: ", path)
  }
  if (basename(path) == ".work" && any(grepl("^trial-", list.files(path, all.files = TRUE)))) {
    stop("Uncleared trial remains; keeping work directory: ", path)
  }
  if (unlink(path, recursive = TRUE) != 0L || dir.exists(path)) stop("Could not clean temporary directory: ", path)
}

# Publish final files at the run root. A confirmation marker is written last,
# so partial publication cannot be reused as a complete result. Source files and
# previous output copies stay in .work/ until final Excel/CSV publication succeeds.
task7ModelFiles <- function(folder) file.path(folder, c("blabla.gdx", "modelstat.txt", "main.lst",
  "outputData.gdx", "main.log", "metadata.json", "git_diff.txt"))

task7FinalModelMatches <- function(folder, result, cfg = NULL) {
  if (!file.exists(file.path(folder, "confirmation.rds"))) return(FALSE)
  tryCatch({
    record <- readRDS(file.path(folder, "confirmation.rds"))
    fields <- c("iteration", "purpose", "slope", "bend_year", "net_zero_year", "end_price", "flat_trial", "flat_end_gtco2", "net_zero_peak_gtco2", "peak_cumulative_gtco2", "cumulative_gtco2")
    files <- task7ModelFiles(folder)
    task7ValidMetrics(record$result, cfg) && record$result$purpose == "Confirmation" &&
      isTRUE(all.equal(record$result[fields], result[fields], tolerance = 1e-12)) &&
      identical(names(record$hashes), basename(files)) && all(file.exists(files)) &&
      all(file.info(files)$size > 0 | basename(files) == "git_diff.txt") &&
      identical(record$hashes, setNames(vapply(files, task7Hash, character(1)), basename(files)))
  }, error = function(e) FALSE)
}

task7SaveFinalModel <- function(trial, work, destination, result, cfg = NULL) {
  if (task7FinalModelMatches(destination, result, cfg)) return(invisible(NULL))
  if (is.null(trial)) stop("Final model files are unavailable; a fresh confirmation is required")
  files <- task7ModelFiles(trial)
  if (!task7ValidMetrics(result, cfg) || result$purpose != "Confirmation" ||
      !all(file.exists(files)) || any(file.info(files)$size <= 0 & basename(files) != "git_diff.txt") ||
      file.exists(file.path(trial, "task6-process.rds"))) stop("Incomplete confirmation files; keeping trial")
  hashes <- setNames(vapply(files, task7Hash, character(1)), basename(files))
  staged <- file.path(work, "final-model")
  dir.create(staged, showWarnings = FALSE)
  if (!all(file.copy(files, staged, overwrite = TRUE))) stop("Cannot copy final model files; keeping trial")
  saveRDS(list(result = result, hashes = hashes), file.path(staged, "confirmation.rds"))
  if (!task7FinalModelMatches(staged, result, cfg)) stop("Final model copy verification failed; keeping trial")
  artifacts <- c(basename(files), "confirmation.rds")
  previous <- file.path(destination, artifacts)
  previous <- previous[file.exists(previous)]
  backup <- tempfile("previous-final-model-", tmpdir = work)
  if (length(previous)) {
    if (!dir.create(backup) || !all(file.copy(previous, backup))) stop("Cannot preserve previous final model")
    if (!identical(unname(vapply(previous, task7Hash, character(1))),
                   unname(vapply(file.path(backup, basename(previous)), task7Hash, character(1))))) {
      stop("Previous model copy verification failed; keeping trial")
    }
  }
  published <- FALSE
  on.exit({
    if (!published && length(previous)) {
      suppressWarnings(file.copy(file.path(backup, basename(previous)), destination, overwrite = TRUE))
    }
  }, add = TRUE)
  # Keep the staging copy and original trial until the whole export is verified.
  for (name in artifacts) {
    source <- file.path(staged, name); target <- file.path(destination, name)
    if (!file.copy(source, target, overwrite = TRUE) ||
        !identical(task7Hash(source), task7Hash(target))) stop("Cannot publish final model file: ", name)
  }
  if (!task7FinalModelMatches(destination, result, cfg)) stop("Published final model verification failed; keeping trial")
  published <- TRUE
  invisible(NULL)
}

# Recovery data are private to this calibration and removed only after complete.
task7StateFolder <- function(campaign) {
  current <- file.path(campaign, "calibration-state")
  link <- Sys.readlink(current)
  if ((!is.na(link) && nzchar(link)) || (file.exists(current) && !dir.exists(current))) stop("Invalid calibration-state directory")
  current
}


# A completed archive keeps all seven normal model outputs and needs no recovery state.
task7ValidateComplete <- function(campaign, input, cfg, accepted, model_files = NULL) {
  if (!task7Converged(accepted, cfg) || accepted$purpose != "Confirmation") stop("Invalid completed confirmation")
  expected <- basename(task7ModelFiles(campaign))
  marker <- file.path(campaign, "confirmation.rds")
  if (file.exists(marker)) {
    if (!task7FinalModelMatches(campaign, accepted, cfg)) stop("Completed model files do not match their confirmation")
    recorded <- names(readRDS(marker)$hashes)
    if (is.null(model_files)) model_files <- recorded
    if (!identical(model_files, recorded)) stop("Completed model inventory differs from the confirmation")
  }
  if (is.null(model_files)) model_files <- expected
  if (!identical(model_files, expected)) stop("Invalid completed model inventory")
  files <- file.path(campaign, c(model_files, "calibrated-iEnvPolicies.csv",
    "reporting.mif", "emissions.csv", "plot.pdf", "Validation.pdf"))
  if (!all(file.exists(files)) || any(dir.exists(files)) ||
      any(file.info(files)$size <= 0 & basename(files) != "git_diff.txt")) {
    stop("Completed archive is missing required results; restore them or start a new campaign")
  }
  prices <- task7SelectedPrices(cfg, task7MakePrices(cfg, input, accepted$slope, accepted$bend_year, accepted$end_price))
  if (!task7SamePrices(task7ReadPolicy(file.path(campaign, "calibrated-iEnvPolicies.csv")), prices)) {
    stop("Completed price CSV differs from the accepted Excel trial")
  }
  model_files
}

# Cleanup is last: the verified workbook must already say complete. A failed
# cleanup leaves that status intact so the next resume retries no model work.
task7CleanupState <- function(campaign, history, saved_hash, input, cfg, accepted) {
  if (!file.exists(history) || !identical(task7Hash(history), saved_hash)) stop("Completed workbook changed; keeping recovery state")
  settings <- openxlsx::read.xlsx(history, sheet = "Settings")
  status <- settings$Value[settings$Parameter == "Status"]
  inventory <- settings$Value[settings$Parameter == "Final model files"]
  if (!identical(status, "complete") || length(inventory) != 1L || is.na(inventory)) {
    stop("Save complete and the final model inventory before cleaning recovery state")
  }
  task7ValidateComplete(campaign, input, cfg, accepted, strsplit(inventory, ", ", fixed = TRUE)[[1L]])
  paths <- file.path(campaign, c("calibration-state", "confirmation.rds"))
  links <- Sys.readlink(paths)
  if (any(!is.na(links) & nzchar(links))) stop("Refusing to clean symbolic-link recovery state")
  if ((file.exists(paths[1L]) && !dir.exists(paths[1L])) || dir.exists(paths[2L])) stop("Unexpected recovery-state file types; keeping them")
  for (folder in paths[1L]) if (dir.exists(folder)) {
    entries <- list.files(folder, all.files = TRUE, no.. = TRUE)
    allowed <- entries %in% c("reportEmissions.R", "industrial-processes.rds", "package-versions.rds", "full-report.rds") |
      grepl("^\\.full-report-", entries)
    if (any(!allowed) || any(dir.exists(file.path(folder, entries)))) stop("Unexpected calibration-state contents; keeping recovery state")
  }
  if (file.exists(file.path(campaign, "task6-process.rds"))) stop("Reporting process cleanup is incomplete; keeping recovery state")
  work <- file.path(campaign, ".work")
  if (dir.exists(work)) task7Cleanup(work, campaign, history, saved_hash)
  for (path in paths) if (file.exists(path)) {
    if (unlink(path, recursive = dir.exists(path)) != 0L || file.exists(path)) stop("Cannot clean completed recovery state: ", path)
  }
  invisible(NULL)
}

# Full reporting is separate from calibration publication. Its small completion
# record never rewrites confirmation.rds, so report failures cannot invalidate
# a saved model or require another confirmation solve. No runtime flags disable it.
task7FullReport <- function(root, campaign, env, result, cfg = NULL) {
  task7StopRetainedProcess(campaign, expected_wd = root)
  if (!task7FinalModelMatches(campaign, result, cfg)) stop("Verified confirmation files are required for full reporting")
  outputs <- file.path(campaign, c("reporting.mif", "emissions.csv", "plot.pdf", "Validation.pdf"))
  stamp <- file.path(task7StateFolder(campaign), "full-report.rds")
  signature <- function() {
    if (!all(file.exists(outputs)) || any(file.info(outputs)$size <= 0)) return(NULL)
    list(confirmation = task7Hash(file.path(campaign, "confirmation.rds")),
         outputs = setNames(vapply(outputs, task7Hash, character(1)), basename(outputs)))
  }
  current <- signature()
  previous <- if (file.exists(stamp)) tryCatch(readRDS(stamp), error = function(e) NULL) else NULL
  if (!is.null(current) && identical(previous, current)) {
    message("Reusing complete research reports for the saved confirmation")
    return(invisible(NULL))
  }
  message("Generating full research reports for the saved confirmation")
  # Normal report paths assume the project root as cwd. Its process marker stays
  # in the campaign; output goes to the console, without a permanent report log.
  task7RunProcess(file.path(R.home("bin"), "Rscript"),
    c(file.path(root, "scripts/tasks/task7CalibrateGlobalCarbonPrice.R"), "--task7-report", "full", campaign),
    root, log = NULL, env = env, marker_folder = campaign)
  current <- signature()
  if (is.null(current)) stop("Full reporting did not produce MIF, emissions CSV and both PDFs; calibration files retained")
  staged <- tempfile(".full-report-", tmpdir = dirname(stamp), fileext = ".rds")
  on.exit(if (file.exists(staged)) unlink(staged), add = TRUE)
  saveRDS(current, staged)
  # Only this reproducible completion marker may be replaced without a backup;
  # the model, Excel, CSV and reports are never deleted on publication failure.
  if (!isTRUE(suppressWarnings(file.rename(staged, stamp)))) {
    if ((file.exists(stamp) && unlink(stamp) != 0L) ||
        !isTRUE(suppressWarnings(file.rename(staged, stamp)))) stop("Cannot save full-report completion record")
  }
  if (!identical(readRDS(stamp), current)) stop("Full-report completion verification failed")
  invisible(NULL)
}

task7LogExcerpt <- function(paths) {
  parts <- lapply(paths[file.exists(paths)], function(p) {
    lines <- tail(readLines(p, warn = FALSE), 40L)
    paste(basename(p), substr(paste(lines, collapse = "\n"), 1L, 11000L), sep = "\n")
  })
  if (length(parts)) substr(paste(unlist(parts), collapse = "\n\n"), 1L, 29000L) else NA_character_
}

# ---- Cross-process resume: the Excel archive is the durable search history ---
task7PackageVersions <- function() {
  packages <- c("postprom", "mrprom", "gdx", "magclass", "madrat", "quitte")
  setNames(lapply(packages, function(p) as.character(utils::packageVersion(p))), packages)
}

# Match createRunFolder(): root GAMS/CSV/JSON files, solver options and the
# data/targets/core/modules/scripts directories. Do not copy companion packages.
task7Sources <- function(root) {
  entries <- list.files(root, full.names = TRUE)
  entries[basename(entries) %in% c("data", "targets", "core", "modules", "scripts", "conopt.opt") |
            grepl("\\.(gms|csv|json)$", entries)]
}

task7Snapshot <- function(root, campaign, run_config) {
  if (!all(file.copy(task7Sources(root), campaign, recursive = TRUE))) stop("Incomplete model snapshot")
  # Keep only the reporter actually sourced by the isolated reporting worker.
  state_dir <- task7StateFolder(campaign)
  if (!dir.create(state_dir)) stop("Cannot create calibration-state directory")
  if (!file.copy(file.path(root, "postprom/R/reportEmissions.R"), state_dir)) stop("Cannot freeze emissions reporter")
  # Preserve the actual configuration, including an OPENPROM_CONFIG override.
  jsonlite::write_json(run_config, file.path(campaign, "config.json"), pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
}

task7RunSettings <- function(cfg, status, reason = NULL, accepted = NA_integer_, model_files = NULL) {
  values <- list("Temperature case" = cfg$temperature_case, "Path selection" = "Automatic: straight end-budget search first; split only if peak exceeds its ceiling",
    "Prefix policy" = cfg$prefix_policy, "Keep input prices through" = cfg$fixed_through_year,
    "Common price year" = cfg$common_year, "Common price (USD2015/t CO2)" = cfg$common_price,
    "Model end year" = cfg$end_year, "Budget start year" = cfg$budget_start_year,
    "Peak budget (Gt CO2)" = cfg$peak_budget_gtco2,
    "End budget (Gt CO2)" = cfg$end_budget_gtco2,
    "Start slope" = cfg$search$start_slope, "Initial slope step" = cfg$search$initial_slope_step,
    "Initial end-price step" = cfg$search$initial_end_price_step,
    "Maximum price" = cfg$search$max_price, "Slope resolution" = cfg$search$slope_resolution,
    "End-price resolution" = cfg$search$end_price_resolution, "Maximum evaluations" = cfg$search$max_evaluations,
    "Peak tolerance (Gt CO2)" = cfg$search$peak_tolerance_gtco2, "End tolerance (Gt CO2)" = cfg$search$end_tolerance_gtco2,
    "End acceptance" = if (task7FixedTail(cfg)) "Straight: end band; bent: fixed-ratio tail must meet end ceiling, slack allowed" else
      "Straight: end band; bent: flat baseline <= end budget permits slack, otherwise end band",
    "Search method" = if (task7FixedTail(cfg)) "Automatic straight / peak-slope search; fixed-ratio tail capped at max_price; no independent end-price search or front recalibration" else
      "Automatic straight / peak-slope / end-price search; doubling jumps and safeguarded interpolation; no front recalibration",
    "Status" = status, "Reason" = if (is.null(reason)) NA_character_ else reason, "Accepted trial" = accepted)
  if (task7FixedTail(cfg)) values <- append(values, list(
    "Post-net-zero slope multiplier" = cfg$post_net_zero_slope_multiplier,
    "Tail geometry" = "Tail rises at front slope * multiplier until max_price, then stays flat; no independent tail search"), after = 5L)
  settings <- data.frame(Parameter = names(values), Value = vapply(values, as.character, character(1)), row.names = NULL)
  if (!is.null(model_files)) settings <- rbind(settings, data.frame(Parameter = "Final model files", Value = paste(model_files, collapse = ", ")))
  settings
}



task7Flags <- function(flags, cfg) {
  if (is.null(flags)) flags <- list()
  if (any(names(flags) %in% c("fCountries", "Calibration", "fBaseY", "fStartHorizon"))) {
    stop("Country subset, calibration or historical overrides are unsupported")
  }
  flags <- modifyList(flags, list(DevMode = 0, GenerateInput = "off", WriteGDX = "on",
    CountrySolveMode = "serial", softLinkMAgPIE = "off", fStartY = 2024, fPeriodOfYears = 1,
    fEndY = cfg$end_year, fScenario = cfg$fScenario, landUseEmulator = "magpie",
    emulatorCarbonPriceScenario = cfg$emulator))
  if (anyDuplicated(names(flags)) || any(!grepl("^[A-Za-z][A-Za-z0-9_]*$", names(flags))) ||
      any(lengths(flags) != 1L) || any(!grepl("^[A-Za-z0-9_.+-]+$", unlist(flags)))) stop("Invalid GAMS flag")
  flags
}

task7ReportFromRows <- function(cfg, rows, metrics) {
  years <- 2010:cfg$end_year
  regional <- rows[rows$Metric == "Net CO2 emissions" & rows$Region != "World", , drop = FALSE]
  global <- rows[rows$Metric == "Net CO2 emissions" & rows$Region == "World", , drop = FALSE]
  if (nrow(global) != 1L || nrow(regional) != length(cfg$regions) || anyDuplicated(regional$Region) ||
      !setequal(regional$Region, cfg$regions) || any(c(regional$Unit, global$Unit) != "Mt CO2/yr")) {
    stop("Incomplete archived emissions rows")
  }
  annual <- do.call(rbind, lapply(years, function(year) data.frame(region = regional$Region,
    year = year, value = as.numeric(regional[[as.character(year)]]))))
  world <- data.frame(year = years, emissions_mtco2 = as.numeric(global[1L, as.character(years)]))
  report <- list(annual = annual, world = world, metrics = metrics)
  task7ValidateReport(cfg, report)
  report
}

# Keep the legacy helper/field names for old archive compatibility. Fixed-ratio
# paths have no flat reference and instead verify their exact prescribed tail.
task7CheckFlat <- function(cfg, a, trials) {
  if (is.na(a$bend_year)) {
    if (!is.na(a$flat_trial) || !is.na(a$flat_end_gtco2)) stop("Unexpected flat-tail reference")
    return(invisible(NULL))
  }
  if (task7FixedTail(cfg)) {
    if (!is.na(a$flat_trial) || !is.na(a$flat_end_gtco2) ||
        !a$purpose %in% c("FixedTail", "Confirmation") ||
        abs(a$end_price - task7TailEndPrice(cfg, a$slope, a$bend_year)) > 1e-8 ||
        a$end_price > cfg$search$max_price + 1e-8) stop("Fixed-ratio tail disagrees with saved settings/path")
    return(invisible(NULL))
  }
  ref <- a$flat_trial
  if (length(ref) != 1L || is.na(ref) || ref != trunc(ref) || ref < 1 || ref > a$iteration) stop("Invalid flat-tail reference")
  flat <- if (a$purpose == "Flat" && ref == a$iteration) a else {
    if (ref >= a$iteration || ref > length(trials)) stop("Missing earlier flat-tail trial")
    trials[[ref]]
  }
  same <- function(x, y) isTRUE(all.equal(x, y, tolerance = 1e-12))
  if (!isTRUE(flat$valid) || flat$purpose != "Flat" || !same(flat$slope, a$slope) ||
      !same(flat$bend_year, a$bend_year) ||
      !same(flat$end_price, cfg$common_price + a$slope * (a$bend_year - cfg$common_year)) ||
      !same(a$flat_end_gtco2, flat$cumulative_gtco2)) stop("Flat-tail reference disagrees with saved results")
  invisible(NULL)
}

task7ReadHistory <- function(path, input, regions, run_config = NULL) {
  if (!file.exists(path)) stop("No calibration-history.xlsx in resume_from")
  if (!identical(openxlsx::getSheetNames(path), c("AnnualPaths", "SearchSummary", "Settings"))) stop("Not an automatic Task 7 archive")
  read <- function(sheet) openxlsx::read.xlsx(path, sheet = sheet, check.names = FALSE, sep.names = " ",
    skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character())
  annual <- read("AnnualPaths"); summary <- read("SearchSummary"); settings <- read("Settings")
  if (!identical(names(settings), c("Parameter", "Value")) || anyDuplicated(settings$Parameter)) stop("Invalid settings sheet")
  if (is.null(run_config)) run_config <- jsonlite::read_json(file.path(dirname(path), "config.json"), simplifyVector = FALSE)
  raw_cfg <- run_config$global_carbon_price_calibration
  # Verified Excel controls survive interruption between workbook/config publication.
  labels <- c(max_evaluations = "Maximum evaluations", slope_resolution = "Slope resolution", end_price_resolution = "End-price resolution",
    peak_tolerance_gtco2 = "Peak tolerance (Gt CO2)", end_tolerance_gtco2 = "End tolerance (Gt CO2)")
  for (key in names(labels)) {
    value <- settings$Value[settings$Parameter == labels[[key]]]
    if (length(value) != 1L || is.na(value)) stop("Missing saved search control: ", key)
    raw_cfg$search[[key]] <- suppressWarnings(as.numeric(value))
  }
  cfg <- task7Setup(raw_cfg, input, regions, allow_legacy = TRUE)
  saved_multiplier <- settings$Value[settings$Parameter == "Post-net-zero slope multiplier"]
  if (task7FixedTail(cfg)) {
    if (length(saved_multiplier) != 1L || is.na(saved_multiplier) ||
        !isTRUE(all.equal(suppressWarnings(as.numeric(saved_multiplier)), cfg$post_net_zero_slope_multiplier, tolerance = 1e-12)))
      stop("Archived post-net-zero slope multiplier differs from frozen configuration")
  } else if (length(saved_multiplier)) stop("Fixed-tail settings cannot be interpreted as a legacy free-tail campaign")
  if (!identical(names(summary), names(task7Summary(list(), cfg))) || !identical(names(annual), names(task7AnnualRows(cfg, 0L)))) stop("Invalid archive columns; old algorithms are not supported")
  ids <- summary$Trial
  if (anyNA(ids) || anyDuplicated(ids) || any(ids != seq_along(ids))) stop("Expected consecutive trial numbers starting at 1")
  if (nrow(annual) != length(ids) * (2L * length(regions) + 1L) || !setequal(annual$Trial, ids)) stop("Incomplete archived trial paths")
  trials <- list(); annual_rows <- list()
  fields <- c(net_zero_price = "NetZeroPrice (USD2015/t CO2)", net_zero_year = "NetZeroYear", net_zero_mtco2 = "NetZeroYearCO2 (Mt CO2/yr)",
    net_zero_peak_gtco2 = "NetZeroPeakCO2 (Gt CO2)", net_zero_peak_year = "NetZeroPeakYear",
    cumulative_gtco2 = "EndCumulativeCO2 (Gt CO2)", peak_cumulative_gtco2 = "PeakCumulativeCO2 (Gt CO2)",
    prefix_peak_gtco2 = "PrefixPeakCO2 (Gt CO2)", peak_year = "PeakYear", flat_trial = "FlatTrial", flat_end_gtco2 = "FlatEndCO2 (Gt CO2)",
    reason = "FailureReason", log_excerpt = "LogExcerpt")
  for (i in seq_along(ids)) {
    z <- summary[i, ]; rows <- annual[annual$Trial == i, , drop = FALSE]
    same <- function(x, y) isTRUE(all.equal(x, y, tolerance = 1e-12, check.attributes = FALSE))
    stages <- if (task7FixedTail(cfg)) c("Straight", "Probe", "FixedTail", "Confirmation") else c("Straight", "Probe", "Flat", "Tail", "Confirmation")
    if (!z$Stage %in% stages || is.na(z$ValidRun) || z$EndYear != cfg$end_year ||
        !same(z[["EndBudget (Gt CO2)"]], cfg$end_budget_gtco2) ||
        !same(z[["PeakBudget (Gt CO2)"]], cfg$peak_budget_gtco2) ||
        (z$Stage %in% c("Straight", "Probe") && !is.na(z$BendYear)) ||
        (z$Stage %in% c("Flat", "Tail", "FixedTail") && is.na(z$BendYear)) ||
        (z$Stage %in% c("Straight", "Confirmation") && is.na(z$BendYear) &&
          z[["Slope (USD2015/t CO2/year)"]] > task7SlopeLimit(cfg) + 1e-10)) stop("Invalid archived trial identity")
    a <- list(iteration = as.integer(i), purpose = z$Stage, valid = isTRUE(z$ValidRun), slope = z[["Slope (USD2015/t CO2/year)"]],
      bend_year = z$BendYear, end_price = z[["EndPrice (USD2015/t CO2)"]], elapsed_seconds = z$ElapsedSeconds)
    for (key in names(fields)) a[[key]] <- z[[fields[[key]]]]
    a$later_positive_years <- if (is.na(z$LaterPositiveYears)) integer() else as.integer(strsplit(z$LaterPositiveYears, ",\\s*")[[1L]])
    if (!is.na(z$NormalRegionYears)) a$solves <- list(final_region_years = z$NormalRegionYears, solver_attempts = z$SolverAttempts)
    prices <- task7MakePrices(cfg, input, a$slope, a$bend_year, a$end_price)
    expected <- task7AnnualRows(cfg, i, prices); recorded <- rows[rows$Metric == "Carbon price", , drop = FALSE]
    recorded <- recorded[match(regions, recorded$Region), , drop = FALSE]
    if (nrow(recorded) != length(regions) || anyNA(recorded$Region) || anyDuplicated(recorded$Region)) stop("Incomplete archived prices")
    if (isTRUE(a$valid) || any(!is.na(recorded[, as.character(2010:2100)]))) {
      if (any(recorded$Unit != "USD2015/t CO2") || !same(as.matrix(recorded[, as.character(2010:2100)]),
          as.matrix(expected[seq_along(regions), as.character(2010:2100)]))) stop("Archived prices differ from frozen settings")
    }
    if (isTRUE(a$valid)) {
      report <- task7ReportFromRows(cfg, rows, a); a$world <- report$world
      task7CheckFlat(cfg, a, trials)
      count <- length(regions) * (cfg$end_year - 2024 + 1L); wanted <- task7Summary(list(a), cfg)
      for (key in c("NetZeroMet", "PeakMet", "PeakBandMet", "EndMet", "BothMet", "WithinTolerance", "EndRule")) {
        left <- z[[key]]; right <- wanted[[key]]
        if (!identical(is.na(left), is.na(right)) || (!is.na(right) && !identical(as.character(left), as.character(right)))) stop("Archived target flags disagree: ", key)
      }
      for (key in c("TailSlope (USD2015/t CO2/year)", "TailFactor")) if (!same(z[[key]], wanted[[key]])) stop("Archived tail geometry differs")
      if (task7FixedTail(cfg) && !same(z$TailPriceCapYear, wanted$TailPriceCapYear)) stop("Archived tail ceiling year differs")
      zero_price <- if (!is.na(a$net_zero_year) && a$net_zero_year >= cfg$common_year) task7PriceAt(cfg, a$slope, a$net_zero_year, a$bend_year, a$end_price) else NA_real_
      if (!same(zero_price, a$net_zero_price) || !same(a$end_price, task7PriceAt(cfg, a$slope, cfg$end_year, a$bend_year, a$end_price)) ||
          is.null(a$solves) || a$solves$final_region_years != count || !is.finite(a$solves$solver_attempts) || a$solves$solver_attempts < count) stop("Archived price/solve checks disagree")
    }
    trials[[i]] <- a; annual_rows[[i]] <- rows
  }
  accepted <- which(summary$Accepted %in% TRUE)
  if (length(accepted) > 1L || (length(accepted) && (!trials[[accepted]]$valid || trials[[accepted]]$purpose != "Confirmation"))) stop("Invalid accepted confirmation")
  list(cfg = cfg, settings = settings, trials = trials, annual_rows = annual_rows, accepted = accepted)
}



# Start slope and jump step stay frozen with the campaign. Only the total
# evaluation cap and accuracy controls may change on resume.
task7ResumeSearch <- function(cfg, requested) {
  for (key in c("max_evaluations", "peak_tolerance_gtco2", "end_tolerance_gtco2", "slope_resolution", "end_price_resolution")) {
    value <- requested$search[[key]]
    if (!is.null(value)) { task7Number(value, key, 0, integer = key == "max_evaluations"); cfg$search[[key]] <- value }
  }
  cfg
}



task7ReadRegions <- function(campaign) {
  sets <- paste(readLines(file.path(campaign, "core/sets.gms"), warn = FALSE), collapse = "\n")
  block <- regmatches(sets, regexec('(?s)resCy\\s+"[^"]*"\\s*/(.*?)/', sets, perl = TRUE))[[1L]]
  if (length(block) != 2L) stop("Cannot read research regions")
  regions <- strsplit(trimws(block[2L]), "\\s+", perl = TRUE)[[1L]]
  if (length(regions) != 39L) stop("This version requires all 39 research regions")
  regions
}

task7TrialFolders <- function(work) {
  folders <- list.dirs(work, recursive = FALSE, full.names = TRUE)
  folders <- folders[grepl("^trial-[0-9]+$", basename(folders))]
  folders[order(as.integer(sub("trial-", "", basename(folders))))]
}

# ---- Task entry point: setup, resume, evaluate, checkpoint and export ---------
runTask7 <- function() {
  root <- normalizePath(getwd(), winslash = "/")
  options <- task7Options(config$global_carbon_price_calibration, commandArgs(trailingOnly = TRUE))
  resuming <- !is.null(options$resume_from)
  for (p in c("openxlsx", "filelock")) if (!requireNamespace(p, quietly = TRUE)) stop("Task 7 requires the R package ", p)
  if (resuming) {
    campaign <- normalizePath(path.expand(options$resume_from), winslash = "/", mustWork = TRUE)
    if (!dir.exists(campaign)) stop("resume_from must be a campaign directory")
  } else {
    task7ValidateConfig(config$global_carbon_price_calibration)
    dir.create(file.path(root, "runs"), showWarnings = FALSE)
    campaign <- file.path(root, "runs", paste0("calibrate-global-carbon-price-",
      Sys.getpid(), "_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S")))
    if (!dir.create(campaign)) stop("Cannot create a fresh calibration directory")
  }
  # Keep the campaign lock identity stable across task renumbering.
  lock_path <- file.path(dirname(tempdir()), paste0("openprom-task6-", digest::digest(campaign, algo = "sha256"), ".lock"))
  # Reject concurrent writers immediately; this is not a run-time limit.
  lock <- filelock::lock(lock_path, timeout = 0)
  if (is.null(lock)) stop("This calibration is already running: ", campaign)
  on.exit(filelock::unlock(lock), add = TRUE)
  if (resuming) task7StopRetainedProcess(campaign, expected_wd = root)
  if (!resuming) task7Snapshot(root, campaign, config)
  config_path <- file.path(campaign, "config.json")
  config_source <- config_path
  if ((!file.exists(config_path) && !file.exists(paste0(config_path, ".previous"))) ||
      !file.exists(file.path(campaign, "data/iEnvPolicies.csv"))) {
    stop("Campaign has no retained model snapshot; restore it before resuming")
  }
  run_config <- tryCatch(jsonlite::read_json(config_path, simplifyVector = FALSE), error = function(e) {
    backup <- paste0(config_path, ".previous")
    if (!resuming || !file.exists(backup)) stop(e)
    message("Reading the retained previous campaign configuration")
    config_source <<- backup
    jsonlite::read_json(backup, simplifyVector = FALSE)
  })
  input <- task7ReadPolicy(file.path(campaign, "data/iEnvPolicies.csv"))
  regions <- task7ReadRegions(campaign)
  history <- file.path(campaign, "calibration-history.xlsx"); work <- file.path(campaign, ".work")
  archive_source <- history; saved_history <- NULL; completed <- FALSE
  trials <- list(); annual_rows <- list()
  if (resuming) {
    saved_history <- tryCatch(task7ReadHistory(history, input, regions, run_config), error = function(e) {
      backup <- paste0(history, ".previous")
      if (!file.exists(backup)) stop(e)
      message("Reading the retained previous workbook after: ", conditionMessage(e))
      archive_source <<- backup
      task7ReadHistory(backup, input, regions, run_config)
    })
    cfg <- saved_history$cfg; trials <- saved_history$trials; annual_rows <- saved_history$annual_rows
    status <- saved_history$settings$Value[saved_history$settings$Parameter == "Status"]
    completed <- identical(status, "complete")
    # Saved mode, targets and input files stay fixed, including maturity_factors.
    # Only unfinished campaigns accept search-control changes. Completed archives
    # return their saved result; changed targets or accuracy need a new campaign.
    if (!completed) {
      cfg <- task7ResumeSearch(cfg, config$global_carbon_price_calibration)
      checked <- run_config$global_carbon_price_calibration
      checked$search <- cfg$search
      task7ValidateConfig(checked, allow_legacy = TRUE)
    }
    if (length(saved_history$accepted) == 1L) {
      a <- trials[[saved_history$accepted]]
      final <- file.path(campaign, "calibrated-iEnvPolicies.csv")
      wanted <- task7SelectedPrices(cfg, task7MakePrices(cfg, input, a$slope, a$bend_year, a$end_price))
      if (a$purpose != "Confirmation" || !task7Converged(a, cfg)) stop("Invalid archived confirmation")
      if (file.exists(final)) {
        if (!task7SamePrices(task7ReadPolicy(final), wanted)) stop("Final CSV differs from the archived confirmation")
      }
    }
  } else cfg <- task7Setup(run_config$global_carbon_price_calibration, input, regions)
  # Repair interrupted publications after validating the retained inputs.
  if (!completed || any(file.exists(paste0(c(history, config_path), ".previous")))) dir.create(work, showWarnings = FALSE)
  # Preserve both publication candidates before restoring a validated backup or
  # releasing stale .previous files. A failed copy must leave the originals intact.
  if (resuming) for (entry in list(list(path = history, source = archive_source),
                                  list(path = config_path, source = config_source))) {
    backup <- paste0(entry$path, ".previous")
    if (!file.exists(backup)) next
    for (source in c(backup, entry$path[file.exists(entry$path)])) {
      retained <- tempfile(paste0("before-resume-", basename(source), "-"), tmpdir = work,
                           fileext = paste0(".", tools::file_ext(entry$path)))
      if (!file.copy(source, retained) || !identical(task7Hash(source), task7Hash(retained))) {
        stop("Cannot retain interrupted publication: ", source)
      }
    }
    if (identical(entry$source, backup) &&
        (!file.copy(backup, entry$path, overwrite = TRUE) ||
         !identical(task7Hash(backup), task7Hash(entry$path)))) stop("Cannot restore previous publication: ", entry$path)
    if (unlink(backup) != 0L) stop("Cannot release retained publication backup: ", backup)
  }
  if (completed) {
    if (length(saved_history$accepted) != 1L) stop("Completed archive has no single accepted confirmation")
    accepted <- trials[[saved_history$accepted]]
    inventory <- saved_history$settings$Value[saved_history$settings$Parameter == "Final model files"]
    if (length(inventory) > 1L || anyNA(inventory)) stop("Invalid completed model inventory")
    model_files <- task7ValidateComplete(campaign, input, cfg, accepted,
      if (length(inventory)) strsplit(inventory, ", ", fixed = TRUE)[[1L]] else NULL)
    saved <- task7Hash(history)
    if (length(inventory) != 1L) stop("Completed archive has no final model inventory")
    task7CleanupState(campaign, history, saved, input, cfg, accepted)
    message("Calibration already complete; returning saved results: ", campaign)
    return(invisible(campaign))
  }
  task7StateFolder(campaign)
  flags <- task7Flags(run_config$scenario$gams_flags, cfg)
  process_env <- task7ProcessEnvironment(run_config, campaign)
  if (cfg$search$max_evaluations * (2L * length(regions) + 1L) >= 1048576L) stop("max_evaluations exceeds Excel capacity")
  pending_trial <- NULL; pending_export <- FALSE
  cache <- new.env(parent = emptyenv())
  price_key <- function(slope, bend, end) paste(sprintf("%.15g", c(slope, bend, if (is.na(bend)) NA_real_ else end)), collapse = ":")
  remember <- function(a) if (isTRUE(a$valid) && a$purpose != "Confirmation") cache[[price_key(a$slope, a$bend_year, a$end_price)]] <- a
  for (a in trials) remember(a)
  persistence_error <- function(e) stop(structure(list(message = paste0("Result persistence/cleanup failed: ", conditionMessage(e),
    ". Temporary results retained at ", work), call = NULL), class = c("task7_persistence_error", "error", "condition")))
  # Keep the workbook authoritative for archived trials and final publication.
  checkpoint <- function(status = "running", reason = NULL, accepted_iteration = NA_integer_, model_files = NULL) tryCatch({
    annual <- if (length(annual_rows)) do.call(rbind, annual_rows) else task7AnnualRows(cfg, 0L)[FALSE, ]
    current <- task7RunSettings(cfg, status, reason, accepted_iteration, model_files)
    task7SaveHistory(history, annual, task7Summary(trials, cfg, accepted_iteration), current)
  }, error = persistence_error, interrupt = persistence_error)
  clean <- function(path, parent, saved) tryCatch({
    force(saved) # Finish checkpoint publication before reading its hash again.
    task7Cleanup(path, parent, history, saved)
  }, error = persistence_error, interrupt = persistence_error)
  final_model <- campaign
  confirmation_folder <- function(a) {
    folders <- task7TrialFolders(work)
    folder <- folders[as.integer(sub("trial-", "", basename(folders))) == a$iteration]
    if (length(folder) != 1L) return(NULL)
    files <- task7ModelFiles(folder)
    if (!all(file.exists(files)) ||
        !isTRUE(all(file.info(files)$size > 0 | basename(files) == "git_diff.txt"))) return(NULL)
    folder
  }
  finish <- function(status, accepted = NULL, reason = NULL) {
    chosen <- if (is.null(accepted)) NA_integer_ else accepted$iteration
    staged <- NULL
    if (!is.null(accepted)) {
      pending_export <<- TRUE
      tryCatch({
        if (!task7Converged(accepted, cfg)) stop("Cannot export an unverified price path")
        prices <- task7MakePrices(cfg, input, accepted$slope, accepted$bend_year, accepted$end_price)
        staged <- file.path(work, "calibrated-iEnvPolicies.csv")
        task7WritePrices(staged, task7SelectedPrices(cfg, prices))
      }, error = persistence_error, interrupt = persistence_error)
    }
    saved <- checkpoint(if (is.null(accepted)) status else "finalizing", reason, chosen)
    if (!is.null(accepted)) tryCatch(
      task7SaveFinalModel(confirmation_folder(accepted), work, final_model, accepted, cfg),
      error = persistence_error, interrupt = persistence_error)
    if (!is.null(staged)) {
      failed_export <- function(e) { checkpoint("export_failed", conditionMessage(e), chosen); persistence_error(e) }
      tryCatch(task7ReplaceFile(staged, file.path(campaign, "calibrated-iEnvPolicies.csv")), error = failed_export, interrupt = failed_export)
      saved <- checkpoint(status, reason, chosen)
      pending_export <<- FALSE
    }
    # Valid confirmations stay on disk until the selected result is published,
    # or until a saved failure/unfinished status makes them intermediate trials.
    for (folder in task7TrialFolders(work)) {
      index <- as.integer(sub("trial-", "", basename(folder)))
      if (index <= length(trials) && isTRUE(trials[[index]]$valid) && trials[[index]]$purpose == "Confirmation") {
        clean(folder, work, saved)
        if (identical(pending_trial, folder)) pending_trial <<- NULL
      }
    }
    pending_model <- is.null(accepted) && any(grepl("^(final-model$|previous-final-model-)", list.files(work, all.files = TRUE)))
    if (is.null(pending_trial) && !pending_export && !pending_model &&
        !any(grepl("^trial-", list.files(work, all.files = TRUE)))) clean(work, campaign, saved)
    else message("Unarchived temporary results retained at ", work)
    list(status = status, reason = reason, accepted = accepted)
  }
  run <- function() {
    if (resuming) {
      for (folder in c(work, task7TrialFolders(work))) tryCatch(task7StopRetainedProcess(folder),
        error = persistence_error, interrupt = persistence_error)
      # A failed/interrupted report must not replay search or spend model calls.
      # Changed accuracy settings still return to the normal calibration path.
      status <- saved_history$settings$Value[saved_history$settings$Parameter == "Status"]
      accuracy <- c("peak_tolerance_gtco2", "end_tolerance_gtco2", "slope_resolution", "end_price_resolution")
      if (length(status) == 1L && status %in% c("postprocessing", "postprocessing_failed") &&
          length(saved_history$accepted) == 1L &&
          identical(cfg$search[accuracy], saved_history$cfg$search[accuracy]) &&
          !length(list.files(work, all.files = TRUE, no.. = TRUE))) {
        a <- trials[[saved_history$accepted]]
        if (file.exists(file.path(campaign, "calibrated-iEnvPolicies.csv")) && task7FinalModelMatches(campaign, a, cfg)) {
          message("Calibration already verified; resuming full reporting only")
          return(list(status = "verified", reason = "Saved calibration verified; reporting resumed",
                      accepted = a, reporting_only = TRUE))
        }
      }
    }
    saveRDS(cfg, file.path(work, "config.rds"))
    worker <- file.path(root, "scripts/tasks/task7CalibrateGlobalCarbonPrice.R")
    rscript <- file.path(R.home("bin"), "Rscript")
    state_dir <- task7StateFolder(campaign)
    if (!file.exists(file.path(state_dir, "package-versions.rds"))) {
      dir.create(state_dir, showWarnings = FALSE)
      if (!file.exists(file.path(state_dir, "reportEmissions.R"))) stop("Frozen emissions reporter is missing")
      task7RunProcess(rscript, c(worker, "--task7-report", "freeze", work), work, file.path(work, "freeze-reporting.log"), env = process_env)
    }
    if (!identical(task7PackageVersions(), readRDS(file.path(state_dir, "package-versions.rds")))) stop("Reporting package versions changed")
    checkpoint()
    # Keep the controller and search settings actually used by this invocation
    # with the permanent snapshot; no model/input/physical-target changes.
    if (resuming) {
      run_config$global_carbon_price_calibration$search <- cfg$search
      staged_config <- file.path(work, "updated-config.json")
      jsonlite::write_json(run_config, staged_config, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
      task7ReplaceFile(staged_config, file.path(campaign, "config.json"))
      if (!file.copy(worker, file.path(campaign, "scripts/tasks/task7CalibrateGlobalCarbonPrice.R"), overwrite = TRUE)) stop("Cannot retain updated controller")
      final <- file.path(campaign, "calibrated-iEnvPolicies.csv")
      previous <- tempfile("previously-calibrated-", tmpdir = work, fileext = ".csv")
      if (file.exists(final) && !file.rename(final, previous)) stop("Cannot retire previous export during refinement")
    }
    report_trial <- function(trial, result) {
      tryCatch({
        result$solves <- task7CheckSolves(trial, regions, 2024:cfg$end_year)
        task7RunProcess(rscript, c(worker, "--task7-report", "evaluate", work, trial), trial, file.path(trial, "report.log"), env = process_env)
        report <- readRDS(file.path(trial, "report.rds"))
        result <- modifyList(result, report$metrics, keep.null = TRUE)
        if (!task7ValidMetrics(result, cfg)) stop("Invalid reported metrics")
        task7ValidateReport(cfg, report)
        result$world <- report$world
        result$net_zero_price <- if (!is.na(result$net_zero_year) && result$net_zero_year >= cfg$common_year)
          task7PriceAt(cfg, result$slope, result$net_zero_year, result$bend_year, result$end_price) else NA_real_
        if (result$purpose == "Flat") {
          result$flat_trial <- result$iteration
          result$flat_end_gtco2 <- result$cumulative_gtco2
        }
        task7CheckFlat(cfg, result, trials)
        list(result = result, report = report)
      }, error = function(e) list(result = modifyList(result,
        list(valid = FALSE, reason = conditionMessage(e))), report = NULL))
    }
    archive <- function(trial, result, prices, report = NULL) {
      if (!isTRUE(result$valid)) { report <- NULL; result$log_excerpt <- task7LogExcerpt(file.path(trial, c("gams.log", "report.log"))) }
      saveRDS(result, file.path(trial, "outcome.rds"))
      index <- result$iteration
      trials[[index]] <<- result
      tryCatch(annual_rows[[index]] <<- task7AnnualRows(cfg, index, prices, report), error = persistence_error, interrupt = persistence_error)
      saved <- checkpoint()
      if (isTRUE(result$valid) && result$purpose == "Confirmation") {
        message("Retaining confirmation trial ", index, " until final publication")
      } else {
        clean(trial, work, saved)
        pending_trial <<- NULL
      }
      remember(result)
      if (isTRUE(result$valid)) message(sprintf("  net-zero peak=%.4f Gt; full peak=%.4f Gt; end total=%.4f Gt; net-zero year=%s; end rule=%s; converged=%s",
        result$net_zero_peak_gtco2, result$peak_cumulative_gtco2, result$cumulative_gtco2,
        result$net_zero_year, task7EndRule(result, cfg), task7Converged(result, cfg)))
      invisible(result)
    }
    # Discard only an incomplete tail. Publish the shortened history before
    # deleting its scratch directory; a failed save must leave the old state.
    discard_from <- function(index) {
      if (index < 1L || index > length(trials) + 1L) stop("Invalid restart trial number")
      if (index <= length(trials) && any(vapply(trials[index:length(trials)], function(a) isTRUE(a$valid), logical(1)))) {
        stop("Cannot discard a completed trial; keeping work")
      }
      trials <<- head(trials, index - 1L)
      annual_rows <<- head(annual_rows, index - 1L)
      checkpoint()
    }
    # Recover completed work before replay. An incomplete evaluation is reset,
    # so the next physical solve reuses its number without an extra failure row.
    for (trial in task7TrialFolders(work)) {
      pending_trial <<- trial
      index <- as.integer(sub("trial-", "", basename(trial)))
      if (index > length(trials) + 1L) stop("Gap in retained trial numbers; preserving work")
      outcome <- file.path(trial, "outcome.rds"); request <- file.path(trial, "request.rds")
      read_record <- function(path) if (file.exists(path)) tryCatch(readRDS(path), error = function(e) NULL) else NULL
      a <- read_record(outcome)
      if (is.null(a)) a <- read_record(request)
      price_file <- file.path(trial, "data/iEnvPolicies.csv")
      existing <- if (file.exists(price_file)) tryCatch(task7ReadPolicy(price_file), error = function(e) NULL) else NULL
      if (is.null(a)) {
        message("Clearing incomplete trial ", index, " before restart")
        clean(trial, work, discard_from(index)); pending_trial <<- NULL
        next
      }
      if (a$iteration != index) stop("Retained trial number mismatch; keeping work")
      prices <- task7MakePrices(cfg, input, a$slope, a$bend_year, a$end_price)
      if (index <= length(trials) && isTRUE(trials[[index]]$valid)) {
        if (is.null(existing) || !task7SamePrices(existing, prices)) stop("Retained prices do not match the completed trial")
        if (trials[[index]]$purpose == "Confirmation") {
          message("Keeping archived confirmation trial ", index, " for final publication")
        } else {
          message("Cleaning already archived trial ", index)
          clean(trial, work, checkpoint()); pending_trial <<- NULL
        }
        next
      }
      if (index <= length(trials) &&
          (!isTRUE(all.equal(a$slope, trials[[index]]$slope, tolerance = 0)) ||
           !isTRUE(all.equal(a$bend_year, trials[[index]]$bend_year, tolerance = 0)) ||
           !isTRUE(all.equal(a$end_price, trials[[index]]$end_price, tolerance = 0)) ||
           !isTRUE(all.equal(a$flat_trial, trials[[index]]$flat_trial, tolerance = 0)))) stop("Retained trial path changed")
      if (is.null(existing) || !task7SamePrices(existing, prices)) {
        message("Clearing incomplete trial ", index, " before restart")
        clean(trial, work, discard_from(index)); pending_trial <<- NULL
        next
      }
      a$valid <- FALSE; a$reason <- NULL
      if (is.null(a$elapsed_seconds)) a$elapsed_seconds <- 0
      message("Recovering retained trial ", index, " (report only; no GAMS solve)")
      recovered <- tryCatch(report_trial(trial, a), error = function(e) list(result = modifyList(a,
        list(valid = FALSE, reason = paste("Retained trial could not be completed:", conditionMessage(e)))), report = NULL))
      if (isTRUE(recovered$result$valid)) {
        message("Saving recovered result before cleanup")
        archive(trial, recovered$result, prices, recovered$report)
      } else {
        message("Clearing incomplete trial ", index, "; its number will be reused")
        clean(trial, work, discard_from(index)); pending_trial <<- NULL
      }
    }
    # An orderly interruption may already have saved and removed its scratch
    # directory. Remove that unfinished tail from both sheets as well.
    keep <- length(trials)
    while (keep > 0L && !isTRUE(trials[[keep]]$valid)) keep <- keep - 1L
    if (keep < length(trials)) {
      message("Clearing incomplete trailing records; restarting at trial ", keep + 1L)
      discard_from(keep + 1L)
    }
    gams_args <- c("main.gms", paste0("--", names(flags), "=", unlist(flags)), "lo=3", "-Idir=./data")
    # Cache search results, reserve confirmation capacity and archive each solve.
    evaluate <- function(slope, bend_year = NA_real_, purpose = "Straight", end_price = NA_real_, flat_trial = NA_integer_) {
      stages <- if (task7FixedTail(cfg)) c("Straight", "Probe", "FixedTail", "Confirmation") else c("Straight", "Probe", "Flat", "Tail", "Confirmation")
      if (!purpose %in% stages) stop("Invalid trial purpose")
      confirmation <- purpose == "Confirmation"
      if (is.na(bend_year) && purpose %in% c("Straight", "Confirmation") && slope > task7SlopeLimit(cfg) + 1e-10) stop("Straight path exceeds max_price")
      if (!is.na(bend_year)) end_price <- task7TailEndPrice(cfg, slope, bend_year, end_price)
      key <- price_key(slope, bend_year, end_price)
      if (!confirmation && exists(key, cache, inherits = FALSE)) {
        message("Reusing saved trial ", cache[[key]]$iteration, ": ", key)
        return(cache[[key]])
      }
      limit <- cfg$search$max_evaluations - if (confirmation) 0L else 1L
      if (length(trials) >= limit) stop(structure(list(message = "evaluation_budget_exhausted; increase search.max_evaluations to resume", call = NULL),
        class = c("task7_evaluation_limit", "error", "condition")))
      prices <- task7MakePrices(cfg, input, slope, bend_year, end_price)
      index <- length(trials) + 1L
      trial <- file.path(work, sprintf("trial-%03d", index))
      if (!dir.create(trial)) stop("Cannot create a fresh trial directory")
      pending_trial <<- trial
      trial_start <- proc.time()[["elapsed"]]
      report <- NULL; interrupted <- FALSE
      if (purpose == "Flat") flat_trial <- index
      flat_end <- if (!task7FixedTail(cfg) && !is.na(bend_year) && purpose %in% c("Tail", "Confirmation")) {
        if (length(flat_trial) != 1L || is.na(flat_trial) || flat_trial < 1 || flat_trial > length(trials) ||
            !isTRUE(trials[[flat_trial]]$valid) || trials[[flat_trial]]$purpose != "Flat") stop("Missing saved flat baseline")
        trials[[flat_trial]]$cumulative_gtco2
      } else NA_real_
      result <- list(iteration = index, valid = FALSE, slope = slope, bend_year = bend_year,
        end_price = task7PriceAt(cfg, slope, cfg$end_year, bend_year, end_price), purpose = purpose,
        flat_trial = flat_trial, flat_end_gtco2 = flat_end)
      saveRDS(result, file.path(trial, "request.rds"))
      result <- tryCatch({
        if (!all(file.copy(task7Sources(campaign), trial, recursive = TRUE))) stop("Incomplete trial snapshot")
        task7WritePrices(file.path(trial, "data/iEnvPolicies.csv"), prices)
        if (confirmation) task7SaveMetadata(root, trial)
        message(sprintf("Trial %d (%s): slope=%.6f; bend=%s; end price=%.4f", index, purpose, slope, bend_year, result$end_price))
        trial_args <- if (confirmation) sub("^lo=3$", "lo=4", gams_args) else gams_args
        task7RunProcess(gams, trial_args, trial, file.path(trial, "gams.log"), env = process_env)
        reported <- report_trial(trial, result)
        report <- reported$report
        reported$result
      }, error = function(e) modifyList(result, list(valid = FALSE, reason = conditionMessage(e))),
         interrupt = function(e) { interrupted <<- TRUE; modifyList(result, list(valid = FALSE, reason = "interrupted")) })
      result$elapsed_seconds <- proc.time()[["elapsed"]] - trial_start
      archive(trial, result, prices, report)
      if (interrupted) stop(structure(list(message = "interrupted", call = NULL), class = c("task7_interrupted", "error", "condition")))
      result
    }
    accepted <- task7Search(cfg, evaluate)
    bend <- accepted$bend_year
    confirmations <- Filter(function(a) a$purpose == "Confirmation" && task7Converged(a, cfg) &&
      isTRUE(all.equal(a$slope, accepted$slope, tolerance = 0)) &&
      isTRUE(all.equal(a$bend_year, bend, tolerance = 0)) &&
      isTRUE(all.equal(a$end_price, accepted$end_price, tolerance = 0)) &&
      isTRUE(all.equal(a$flat_trial, accepted$flat_trial, tolerance = 0)) &&
      (task7FinalModelMatches(final_model, a, cfg) || !is.null(confirmation_folder(a))), trials)
    confirmation <- if (length(confirmations)) tail(confirmations, 1L)[[1L]] else evaluate(accepted$slope, bend, "Confirmation", end_price = accepted$end_price, flat_trial = accepted$flat_trial)
    if (!task7Converged(confirmation, cfg) ||
        !isTRUE(all.equal(confirmation$net_zero_year, accepted$net_zero_year, tolerance = 0)) ||
        !isTRUE(all.equal(confirmation$world, accepted$world, tolerance = 1e-10))) {
      return(finish("confirmation_failed", reason = "Independent confirmation changed the calibrated emissions/path"))
    }
    finish("verified", confirmation, accepted$calibration_note)
  }

  result <- tryCatch(run(), task7_persistence_error = function(e) list(status = "persistence_failed", reason = conditionMessage(e)),
    task7_interrupted = function(e) finish("interrupted", reason = "interrupted"),
    interrupt = function(e) finish("interrupted", reason = "interrupted"),
    error = function(e) finish("unfinished", reason = conditionMessage(e)))
  message("Calibrate Global Carbon Price (Task 7): ", history)
  if (result$status != "verified") stop(result$status, ": ", result$reason)
  # Always produce the final research report, independently of behavior.withReport.
  # Keep accepted calibration and its CSV/GDX intact if reporting or LaTeX fails.
  saved <- checkpoint("postprocessing", result$reason, result$accepted$iteration)
  report_error <- tryCatch({
    if (isTRUE(result$reporting_only)) {
      run_config$global_carbon_price_calibration$search <- cfg$search
      staged_config <- file.path(work, "updated-config.json")
      jsonlite::write_json(run_config, staged_config, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
      task7ReplaceFile(staged_config, config_path)
    }
    if (!file.copy(file.path(root, "scripts/tasks/task7CalibrateGlobalCarbonPrice.R"),
                   file.path(campaign, "scripts/tasks/task7CalibrateGlobalCarbonPrice.R"), overwrite = TRUE)) {
      stop("Cannot retain updated reporting controller")
    }
    task7FullReport(root, campaign, process_env, result$accepted, cfg)
    task7ValidateComplete(campaign, input, cfg, result$accepted)
    NULL
  }, error = function(e) conditionMessage(e), interrupt = function(e) "Full reporting interrupted")
  saved <- checkpoint(if (is.null(report_error)) "complete" else "postprocessing_failed",
    if (is.null(report_error)) result$reason else report_error, result$accepted$iteration,
    if (is.null(report_error)) names(readRDS(file.path(campaign, "confirmation.rds"))$hashes) else NULL)
  if (dir.exists(work) && !length(list.files(work, all.files = TRUE, no.. = TRUE))) clean(work, campaign, saved)
  if (!is.null(report_error)) stop("Calibration verified; full reporting incomplete: ", report_error,
    ". Resume with resume_from=\"", campaign, "\" to retry reporting without another model solve.")
  task7CleanupState(campaign, history, saved, input, cfg, result$accepted)
  invisible(campaign)
}

# ---- Reporting worker: same file, isolated R process -------------------------
task7Report <- function(mode, work, trial = NULL) {
  work <- normalizePath(work, mustWork = TRUE)
  folder <- task7StateFolder(if (mode == "full") work else dirname(work))
  versions <- task7PackageVersions()
  if (mode == "freeze") {
    old <- madrat::getConfig("packages")
    madrat::setConfig(packages = unique(c("mrprom", old)))
    frozen <- madrat::readSource("IndustrialProcessesEmissionsIEAPrimes")
    if (!inherits(frozen, "magpie") || any(!is.finite(frozen))) stop("Invalid industrial reporting source")
    saveRDS(frozen, file.path(folder, "industrial-processes.rds"), version = 3)
    saveRDS(versions, file.path(folder, "package-versions.rds"))
    return(invisible(NULL))
  }
  if (!mode %in% c("evaluate", "full") || (mode == "evaluate" && is.null(trial))) stop("Expected freeze/evaluate/full")
  if (!identical(versions, readRDS(file.path(folder, "package-versions.rds")))) {
    stop("Reporting package versions changed during campaign")
  }
  # Both lightweight and full reports use the same frozen emissions function
  # and industrial input; all other full-report calculations use normal postprom.
  env <- new.env(parent = asNamespace("postprom"))
  sys.source(file.path(folder, "reportEmissions.R"), envir = env)
  frozen <- readRDS(file.path(folder, "industrial-processes.rds"))
  env$readSource <- function(type, ...) {
    if (!identical(type, "IndustrialProcessesEmissionsIEAPrimes")) stop("Unexpected reporting data lookup: ", type)
    frozen
  }
  env$interpolate_missing_periods <- quitte::interpolate_missing_periods
  if (mode == "full") {
    # The normal plotting entry silently skips PDFs without TinyTeX. Treat that
    # as incomplete post-processing here, not as successful task completion.
    if (!tinytex::is_tinytex()) stop("TinyTeX is required for plot.pdf and Validation.pdf; calibration files retained")
    original <- getFromNamespace("reportEmissions", "postprom")
    assignInNamespace("reportEmissions", env$reportEmissions, ns = "postprom")
    on.exit(assignInNamespace("reportEmissions", original, ns = "postprom"), add = TRUE)
    report_env <- new.env(parent = globalenv())
    report_env$commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) work else commandArgs()
    sys.source(file.path(work, "scripts/tasks/reportOutput.R"), envir = report_env)
    return(invisible(NULL))
  }
  cfg <- readRDS(file.path(work, "config.rds"))
  trial <- normalizePath(trial, mustWork = TRUE)
  gdx_path <- file.path(trial, "blabla.gdx")
  if (!file.exists(gdx_path) || file.info(gdx_path)$size == 0) stop("Missing GDX")
  regions <- cfg$regions
  years <- seq.int(2024L, cfg$end_year)
  report_years <- seq.int(2010L, cfg$end_year)
  key <- function(r, y) paste(r, y, sep = ":")
  grid <- function(object, r, y) {
    if (!inherits(object, "magpie") || !all(r %in% magclass::getRegions(object)) ||
        !all(y %in% magclass::getYears(object, as.integer = TRUE))) stop("Incomplete GDX grid")
    d <- as.data.frame(object[r, paste0("y", y), ])
    if (!all(c("Region", "Year", "Value") %in% names(d))) stop("Unexpected GDX layout")
    out <- data.frame(region = as.character(d$Region), year = as.integer(as.character(d$Year)), value = as.numeric(d$Value))
    expected <- expand.grid(region = r, year = y)
    if (anyDuplicated(key(out$region, out$year)) || any(!is.finite(out$value)) ||
        !setequal(key(out$region,out$year),key(expected$region,expected$year))) stop("Invalid or duplicate GDX grid")
    out
  }
  tag <- function(name) {
    x <- gdx::readGDX(gdx_path, name, react = "silent")
    if (is.null(x) || !length(x)) stop("Missing GDX tag: ", name)
    as.character(x)
  }
  if (!identical(tag("fscenario"), as.character(cfg$fScenario)) ||
      !identical(tag("activeMagpieScen"), cfg$emulator) ||
      !identical(tag("sLandEmiMode"), "curve") ||
      !setequal(tag("runCyL"), regions) || !setequal(tag("resCy"), regions) ||
      !setequal(as.integer(tag("an")), years)) stop("GDX scenario/region/year mismatch")

  # Verify the prices actually consumed by GAMS, not just the generated CSV.
  actual <- grid(gdx::readGDX(gdx_path, "iCarbValYrExog"), regions, years)
  input <- read.csv(file.path(trial, "data/iEnvPolicies.csv"), check.names = FALSE)
  expected <- do.call(rbind, lapply(regions, function(r) {
    row <- which(input[[1L]] == r & input[[2L]] == cfg$policy)
    if (length(row) != 1L) stop("Policy row mismatch")
    data.frame(region = r, year = years, value = as.numeric(input[row, as.character(years)]))
  }))
  wanted <- expected$value[match(key(actual$region,actual$year),key(expected$region,expected$year))]
  if (any(!is.finite(wanted)) || any(abs(actual$value-wanted) > 1e-8*pmax(1,abs(wanted)))) stop("Actual model prices differ")

  # Check required CO2 inputs before the reporter can substitute a fallback.
  for (symbol in c("V07GrossEmissCO2Demand","V06CO2CaptureCCS","V07GrossEmissCO2Supply",
                   "V06CapCDR","imAfoluLandEmis","imAfoluAgriEmis","V07EmiActBySrcRegTim")) {
    x <- if (startsWith(symbol,"V")) gdx::readGDX(gdx_path,symbol,field="l") else gdx::readGDX(gdx_path,symbol)
    if (!inherits(x,"magpie") || !all(regions %in% magclass::getRegions(x)) ||
        !all(report_years %in% magclass::getYears(x,as.integer=TRUE)) ||
        any(!is.finite(x[regions,paste0("y",report_years),]))) stop("Missing/invalid emissions input: ",symbol)
  }
  report <- env$reportEmissions(gdx_path,regions,paste0("y",report_years))
  # Task 8 reuses the frozen reporter and actual-price checks for annual GHG.
  metric <- if (is.null(cfg$annual_metric)) "Emissions|CO2.Mt CO2/yr" else cfg$annual_metric
  if (!metric %in% magclass::getNames(report)) stop("Missing global net CO2 metric")
  annual <- grid(report[,,metric],regions,report_years)
  world <- aggregate(value ~ year,annual,sum)
  world <- world[order(world$year),]
  names(world)[2L] <- "emissions_mtco2"
  if (!is.null(cfg$annual_metric)) {
    names(world)[2L] <- "emissions_mtco2eq"
    saveRDS(list(annual = annual, world = world), file.path(trial, "report.rds"))
    return(invisible(NULL))
  }
  result <- task7Metrics(cfg, world)
  result$accounting <- "postprom net CO2 including energy, industrial processes, AFOLU and bunkers"
  report <- list(metrics = result, annual = annual, world = world)
  task7ValidateReport(cfg, report)
  saveRDS(report, file.path(trial, "report.rds"))
}

# Sourcing from start.R only defines functions. Direct execution is reserved for
# the reporting subprocess; model runs always enter through start.R.
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) || args[1L] != "--task7-report" ||
      !((length(args) == 3L && args[2L] %in% c("freeze", "full")) ||
        (length(args) == 4L && args[2L] == "evaluate"))) {
    stop("Run with Rscript start.R task_id=7")
  }
  task7Report(args[2L], args[3L], if (length(args) == 4L) args[4L] else NULL)
}
