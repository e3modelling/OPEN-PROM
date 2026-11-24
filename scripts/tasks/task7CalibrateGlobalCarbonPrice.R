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
#    and research reports. Save the RDS checkpoint and export the workbook
#    before cleaning up. A failed trial stops the campaign. Resume
#    with resume_from, or retry reporting from the accepted confirmation after
#    installing TinyTeX if the PDF report failed.
#
# Settings in config.json under global_carbon_price_calibration
# Values below are from config.template.json. Prices use USD2015/t CO2,
# slopes use price units per year, and cumulative budgets use Gt CO2.
#
#   resume_from = null
#     Use null for a fresh campaign or a campaign directory to resume.
#     The CLI resume_from argument takes precedence. On unfinished campaigns,
#     only the evaluation cap, tolerances and slope resolution can be overridden.
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
#     slope throughout.
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
#     initial_slope_step = 40       First slope change for straight and front searches.
#                                   The step doubles when expanding to find a bracket.
#     max_price = 5000              Path price ceiling, above common_price. A rising tail flattens at this price.
#     slope_resolution = 0.01       Stop refining at this slope bracket width.
#     max_evaluations = 50          Total evaluation limit across search and confirmation. Cache hits use no new call.
#     peak_tolerance_gtco2 = 5      Width of the band below the peak ceiling for the first peak of a bent path.
#     end_tolerance_gtco2 = 5       Width of the band below the end-year ceiling for straight paths.


# ---- Configuration and price construction -----------------------------------

task7ValidateConfig <- function(cfg) {
  required <- c(
    "prefix_policy", "fixed_through_year", "common_year", "common_price",
    "post_net_zero_slope_multiplier", "peak_budget_gtco2", "end_budget_gtco2",
    "end_year", "budget_start_year", "temperature_case", "search"
  )
  allowed <- c(required, "resume_from")
  if (!is.list(cfg) || anyDuplicated(names(cfg)) || !all(required %in% names(cfg)) ||
    any(!names(cfg) %in% allowed)) {
    stop("Use the automatic Task 7 settings in config.template.json")
  }
  cpcOptions(cfg, character(), 7L)
  for (k in c("fixed_through_year", "common_year", "end_year", "budget_start_year")) {
    cpcNumber(cfg[[k]], k, cpcFirstPolicyYear, TRUE)
  }
  if (!(cpcFirstSolveYear <= cfg$fixed_through_year && cfg$fixed_through_year < cfg$common_year &&
    cfg$common_year < cfg$end_year && cfg$end_year <= cpcLastPolicyYear)) {
    stop("Require ", cpcFirstSolveYear, " <= fixed year < common year < end year <= ", cpcLastPolicyYear)
  }
  if (cfg$budget_start_year > cpcFirstSolveYear) {
    stop("Budget start must include the model start (", cpcFirstSolveYear, ")")
  }
  for (k in c("common_price", "peak_budget_gtco2", "end_budget_gtco2")) cpcNumber(cfg[[k]], k)
  cpcNumber(cfg$post_net_zero_slope_multiplier, "post_net_zero_slope_multiplier")
  if (cfg$post_net_zero_slope_multiplier <= 0) stop("post_net_zero_slope_multiplier must be positive")
  if (cfg$peak_budget_gtco2 < cfg$end_budget_gtco2) {
    stop(sprintf(
      paste(
        "Invalid carbon budgets: peak_budget_gtco2 (%g Gt CO2) must be >= end_budget_gtco2 (%g Gt CO2).",
        "Check these settings before restarting."
      ),
      cfg$peak_budget_gtco2, cfg$end_budget_gtco2
    ))
  }
  cpcChoice(cfg$temperature_case, c("1.5C", "2C"), "temperature_case")
  cpcChoice(cfg$prefix_policy, c("exogCV_NPi", "exogCV_1_5C", "exogCV_2C", "exogCV_Calib"), "prefix_policy")
  keys <- c(
    "start_slope", "initial_slope_step", "max_price", "slope_resolution",
    "max_evaluations", "peak_tolerance_gtco2", "end_tolerance_gtco2"
  )
  a <- cfg$search
  if (!is.list(a) || anyDuplicated(names(a)) || !setequal(names(a), keys)) stop("Invalid search settings")
  for (k in keys) cpcNumber(a[[k]], k, 0, k == "max_evaluations")
  if (any(unlist(a[c("initial_slope_step", "slope_resolution")]) <= 0)) {
    stop("Search steps and resolutions must be positive")
  }
  if (a$max_evaluations < 2) stop("Reserve a search call and independent confirmation")
  if (a$max_price <= cfg$common_price) stop("max_price must exceed common_price")
  if (a$start_slope > task7SlopeLimit(cfg)) stop("start_slope exceeds the straight-path price-bound range")
  cfg
}


task7Setup <- function(cfg, input, regions) {
  cfg <- task7ValidateConfig(cfg)
  if (!length(regions) || anyDuplicated(regions)) stop("Regions must be distinct and nonempty")
  cfg$regions <- regions
  one_half <- cfg$temperature_case == "1.5C"
  cfg$policy <- if (one_half) "exogCV_1_5C" else "exogCV_2C"
  cfg$emulator <- if (one_half) "1p5C" else "2C"
  cfg$fScenario <- if (one_half) 2L else 3L
  cfg$anchors <- setNames(vector("list", length(regions)), regions)
  for (r in regions) {
    i <- cpcPolicyRow(input, r, cfg$prefix_policy)
    cpcPolicyRow(input, r, cfg$policy)
    values <- suppressWarnings(as.numeric(input[i, as.character(cpcFirstPolicyYear:cfg$fixed_through_year)]))
    if (any(!is.finite(values) | values < 0)) stop("Invalid prefix for ", r)
    # Preserve historical changes and reject declines during simulation.
    n <- cfg$fixed_through_year - cpcLastHistoricalYear + 1L
    if (any(diff(tail(values, n)) < 0)) stop("Prefix decreases after ", cpcLastHistoricalYear, ": ", r)
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

# Continuous crossing year of the tail's ceiling; the first capped annual
# observation is at ceiling(crossing_year). NA means max_price is not reached.
task7TailCapYear <- function(cfg, slope, bend_year) {
  if (is.na(bend_year) || bend_year >= cfg$end_year || slope <= 0) return(NA_real_)
  knot <- cfg$common_price + slope * (bend_year - cfg$common_year)
  if (knot > cfg$search$max_price + 1e-8) return(NA_real_)
  year <- bend_year + max(0, cfg$search$max_price - knot) / (cfg$post_net_zero_slope_multiplier * slope)
  if (year <= cfg$end_year + 1e-10) min(year, cfg$end_year) else NA_real_
}


task7PriceAt <- function(cfg, slope, year, bend_year = NA_real_) {
  span <- pmin(year, cfg$end_year) - cfg$common_year
  if (is.na(bend_year)) {
    return(pmin(cfg$search$max_price, cfg$common_price + slope * span))
  }
  pmin(
    cfg$search$max_price,
    cfg$common_price + slope * pmin(span, bend_year - cfg$common_year) +
      cfg$post_net_zero_slope_multiplier * slope * pmax(0, span - (bend_year - cfg$common_year))
  )
}


task7MakePrices <- function(cfg, input, slope, bend_year = NA_real_) {
  cpcNumber(slope, "slope")
  if (length(bend_year) != 1L || (!is.na(bend_year) &&
    (!is.finite(bend_year) || bend_year != trunc(bend_year) || bend_year <= cfg$common_year ||
      bend_year > cfg$end_year))) stop("Invalid price bend year")
  if (!is.na(bend_year) && cfg$common_price + slope * (bend_year - cfg$common_year) > cfg$search$max_price + 1e-8) {
    stop("Require a nondecreasing tail within max_price")
  }
  output <- input
  years <- (cfg$fixed_through_year + 1):cpcLastPolicyYear
  shared <- years >= cfg$common_year
  common_path <- task7PriceAt(cfg, slope, years[shared], bend_year)
  prefix <- as.character(cpcFirstPolicyYear:cfg$fixed_through_year)
  for (r in cfg$regions) {
    src <- cpcPolicyRow(input, r, cfg$prefix_policy)
    dest <- cpcPolicyRow(input, r, cfg$policy)
    output[dest, prefix] <- input[src, prefix]
    prices <- cfg$anchors[[r]] + (cfg$common_price - cfg$anchors[[r]]) *
      (years - cfg$fixed_through_year) / (cfg$common_year - cfg$fixed_through_year)
    prices[shared] <- common_path
    if (any(!is.finite(prices)) || any(prices > cfg$search$max_price + 1e-8)) {
      stop("price_bound: actual price path exceeds max_price")
    }
    output[dest, as.character(years)] <- as.list(sprintf("%.15g", prices))
  }
  output
}


# ---- Peak and end-budget calibration ---------------------------------------
task7Metrics <- function(cfg, world) {
  world <- world[order(world$year), ]
  use <- world$year >= cfg$budget_start_year
  cumulative <- rep(NA_real_, nrow(world))
  cumulative[use] <- cumsum(world$emissions_mtco2[use]) / 1000
  peak <- which.max(cumulative)
  crossing <- which(use & world$emissions_mtco2 <= 0 & c(FALSE, head(world$emissions_mtco2, -1L) > 0))
  first <- if (length(crossing)) crossing[1L] else NA_integer_
  nz_peak <- if (is.na(first)) NA_integer_ else which.max(replace(cumulative, seq_along(cumulative) > first, NA_real_))
  zero_year <- if (is.na(first)) NA_real_ else world$year[first]
  later_positive <- if (is.na(first)) integer() else world$year[world$year > zero_year & world$emissions_mtco2 > 0]
  list(
    valid = TRUE, net_zero_year = zero_year,
    net_zero_mtco2 = if (is.na(first)) NA_real_ else world$emissions_mtco2[first],
    net_zero_peak_gtco2 = if (is.na(nz_peak)) NA_real_ else cumulative[nz_peak],
    net_zero_peak_year = if (is.na(nz_peak)) NA_real_ else world$year[nz_peak],
    cumulative_gtco2 = tail(cumulative, 1L), peak_cumulative_gtco2 = cumulative[peak], peak_year = world$year[peak],
    prefix_peak_gtco2 = max(cumulative[use & world$year <= cfg$common_year]),
    later_positive_years = later_positive
  )
}


task7ValidMetrics <- function(a, cfg) {
  finite <- function(x) is.numeric(x) && length(x) == 1L && is.finite(x)
  fields <- c("cumulative_gtco2", "peak_cumulative_gtco2", "prefix_peak_gtco2", "peak_year")
  if (!isTRUE(a$valid) || !all(vapply(a[fields], finite, logical(1)))) return(FALSE)
  year <- a$net_zero_year
  nz <- c("net_zero_mtco2", "net_zero_peak_gtco2", "net_zero_peak_year")
  if (!is.numeric(year) || length(year) != 1L) return(FALSE)
  if (is.na(year)) {
    return(all(vapply(a[nz], function(x) is.numeric(x) && length(x) == 1L && is.na(x), logical(1))))
  }
  finite(year) && year == trunc(year) && year >= cfg$budget_start_year && year <= cfg$end_year &&
    all(vapply(a[nz], finite, logical(1))) && a$net_zero_mtco2 <= 0 && a$net_zero_peak_year <= year
}


task7EndRule <- function(a) {
  if (identical(a$purpose, "Probe")) return("Not checked")
  if (is.na(a$bend_year)) "band" else "ceiling"
}

task7PeakNear <- function(a, cfg) {
  task7ValidMetrics(a, cfg) && !is.na(a$net_zero_year) && a$net_zero_year > cfg$common_year &&
    a$net_zero_peak_gtco2 <= cfg$peak_budget_gtco2 &&
    a$net_zero_peak_gtco2 >= cfg$peak_budget_gtco2 - cfg$search$peak_tolerance_gtco2
}

task7Passes <- function(a, cfg) {
  if (!task7ValidMetrics(a, cfg) || identical(a$purpose, "Probe")) return(FALSE)
  if (a$peak_cumulative_gtco2 > cfg$peak_budget_gtco2 || a$cumulative_gtco2 > cfg$end_budget_gtco2) return(FALSE)
  expected_end <- task7PriceAt(cfg, a$slope, cfg$end_year, a$bend_year)
  if (!isTRUE(abs(a$end_price - expected_end) <= 1e-8)) return(FALSE)
  if (is.na(a$bend_year)) return(a$slope <= task7SlopeLimit(cfg) + 1e-10)
  if (cfg$common_price + a$slope * (a$bend_year - cfg$common_year) > cfg$search$max_price + 1e-8) return(FALSE)
  !is.na(a$net_zero_year) && a$net_zero_year > cfg$common_year &&
    isTRUE(all.equal(a$bend_year, a$net_zero_year, tolerance = 0))
}


task7Converged <- function(a, cfg) {
  if (!task7Passes(a, cfg)) return(FALSE)
  if (!is.na(a$bend_year) && !task7PeakNear(a, cfg)) return(FALSE)
  rule <- task7EndRule(a)
  rule == "ceiling" ||
    (rule == "band" && a$cumulative_gtco2 >= cfg$end_budget_gtco2 - cfg$search$end_tolerance_gtco2)
}


task7Candidate <- function(cfg, slope, evaluate, purpose = "Straight") {
  a <- evaluate(slope, NA_real_, purpose)
  if (!task7ValidMetrics(a, cfg)) stop("invalid_run: ", a$reason)
  if (a$prefix_peak_gtco2 > cfg$peak_budget_gtco2) {
    stop("fixed_prefix_budget: prescribed prices through common_year exceed the peak budget; ",
         "start a new campaign with a different early path")
  }
  if (purpose == "Probe") {
    if (!is.na(a$net_zero_year) && a$net_zero_year <= cfg$common_year) {
      stop("fixed_prefix_net_zero: net zero precedes the searched front; choose an earlier common_year")
    }
    a$path_bound <- !is.na(a$net_zero_year) &&
      cfg$common_price + slope * (a$net_zero_year - cfg$common_year) > cfg$search$max_price + 1e-8
  }
  a
}


task7SearchScalar <- function(spec, run, price, direction, residual) {
  lower <- spec$lower
  upper <- spec$upper
  step <- spec$step
  resolution <- spec$resolution
  label <- spec$label
  samples <- list()
  sample <- function(value) {
    x <- run(value)
    d <- direction(x)
    for (old in samples) {
      if ((price(old) < value && direction(old) <= 0 && d > 0) ||
        (price(old) > value && direction(old) > 0 && d <= 0)) {
        stop(label, "_nonmonotone_response: search direction reversed")
      }
    }
    samples[[length(samples) + 1L]] <<- x
    x
  }
  current <- sample(spec$start)
  repeat {
    d <- direction(current)
    if (d == 0L) return(current)
    if (d < 0L && price(current) <= lower) stop(label, "_lower_bound: ", spec$lower_reason)
    if (d > 0L && price(current) >= upper) stop(label, "_upper_bound: ", spec$upper_reason)
    candidate <- max(lower, min(upper, price(current) + d * step))
    if (candidate == price(current)) stop(label, "_precision_limit: search step cannot advance")
    message(sprintf("%s jump: %.6f -> %.6f", label, price(current), candidate))
    next_result <- sample(candidate)
    nd <- direction(next_result)
    if (nd == 0L) return(next_result)
    if (nd != d) {
      lo <- if (d > 0L) current else next_result
      hi <- if (d > 0L) next_result else current
      repeat {
        width <- price(hi) - price(lo)
        if (width <= resolution) {
          if (label == "Peak" && is.na(lo$net_zero_year) && !isTRUE(hi$path_bound)) {
            stop("net_zero_end_year_boundary: net zero and the peak tolerance cannot both be reached ",
                 "within the model horizon")
          }
          stop(label, "_precision_limit: target remains outside tolerance; no front recalibration")
        }
        rlo <- residual(lo)
        rhi <- residual(hi)
        fraction <- if (is.finite(rlo) && is.finite(rhi) && rlo > rhi) (rlo + spec$tolerance / 2) / (rlo - rhi) else 0.5
        if (!is.finite(fraction)) fraction <- 0.5
        candidate <- price(lo) + width * min(0.9, max(0.1, fraction))
        quantum <- resolution / 10
        rounded <- round(candidate / quantum) * quantum
        if (rounded > price(lo) && rounded < price(hi)) candidate <- rounded
        if (candidate <= price(lo) || candidate >= price(hi)) candidate <- (price(lo) + price(hi)) / 2
        message(sprintf("%s refinement: %.6f; bracket [%.6f, %.6f]", label, candidate, price(lo), price(hi)))
        x <- sample(candidate)
        dx <- direction(x)
        if (dx == 0L) return(x)
        if (dx > 0L) lo <- x else hi <- x
      }
    }
    current <- next_result
    step <- min(upper - lower, 2 * step)
  }
}

task7Search <- function(cfg, evaluate) {
  a <- cfg$search
  end_direction <- function(x) {
    gap <- x$cumulative_gtco2 - cfg$end_budget_gtco2
    if (gap > 0) 1L else if (gap < -a$end_tolerance_gtco2) -1L else 0L
  }
  # Always calibrate a legal single straight path before deciding to split it.
  straight <- task7SearchScalar(
    list(
      label = "End", start = a$start_slope, lower = 0, upper = task7SlopeLimit(cfg),
      step = a$initial_slope_step, resolution = a$slope_resolution, tolerance = a$end_tolerance_gtco2,
      lower_reason = paste("zero slope is already below the end-budget band; lower common_price/adjust the early",
        "path and start a new campaign; raising common_price would not help"),
      upper_reason = "end budget not reached within max_price"
    ),
    run = function(s) task7Candidate(cfg, s, evaluate, "Straight"),
    price = function(x) x$slope,
    direction = end_direction,
    residual = function(x) x$cumulative_gtco2 - cfg$end_budget_gtco2
  )
  if (task7Converged(straight, cfg)) {
    straight$calibration_note <- paste("Single straight path meets the end-budget band and full peak ceiling;",
                                       "net zero is not required or forbidden")
    return(straight)
  }
  if (straight$peak_cumulative_gtco2 <= cfg$peak_budget_gtco2) stop("Invalid straight-path result")
  message(sprintf("Straight end budget calibrated, but peak %.6f exceeds %.6f Gt; searching a net-zero-bent path",
                  straight$peak_cumulative_gtco2, cfg$peak_budget_gtco2))
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
  chosen <- task7SearchScalar(
    list(
      label = "Peak", start = straight$slope, lower = straight$slope, upper = task7SlopeLimit(cfg, front = TRUE),
      step = a$initial_slope_step, resolution = a$slope_resolution, tolerance = a$peak_tolerance_gtco2,
      lower_reason = paste("the straight-path slope cannot approach the first-peak band while respecting the full",
        "peak ceiling; calibration incomplete"),
      upper_reason = "target/net zero not reached within the price ceiling and model horizon"
    ),
    run = function(s) task7Candidate(cfg, s, evaluate, "Probe"),
    price = function(x) x$slope,
    direction = front_direction,
    residual = front_residual
  )
  if (!task7PeakNear(chosen, cfg)) stop("Peak calibration did not converge")
  year <- chosen$net_zero_year
  slope <- chosen$slope
  message(sprintf(
    "Peak stage complete: slope %.6f; net-zero year %d; peak %.6f Gt",
    slope, year, chosen$net_zero_peak_gtco2
  ))
  fixed <- evaluate(slope, year, "FixedTail")
  if (!task7ValidMetrics(fixed, cfg)) stop("invalid_run: ", fixed$reason)
  before <- chosen$world$year <= year
  if (!isTRUE(all.equal(fixed$net_zero_year, year, tolerance = 0)) ||
    !isTRUE(all.equal(fixed$world$emissions_mtco2[before], chosen$world$emissions_mtco2[before], tolerance = 1e-10))) {
    stop("prefix_changed: tail changed emissions before/at net zero")
  }
  if (!task7Converged(fixed, cfg)) {
    stop(
      "fixed_tail_budget: configured tail ratio does not meet the peak/end constraints; ",
      "calibration incomplete without front recalibration"
    )
  }
  fixed$calibration_note <- sprintf(
    paste(
      "Peak within tolerance; tail rises at %.15g times the front slope until max_price,",
      "then stays flat; end ceiling met, including slack totals"
    ),
    cfg$post_net_zero_slope_multiplier
  )
  fixed
}

# ---- Global calibration solve acceptance ------------------------------------

task7CheckSolves <- function(trial, regions, years) {
  fields <- cpcModelStatusFields(file.path(trial, "modelstat.txt"))
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

# ---- History and final archive ----------------------------------------------
task7CheckPriceCsv <- function(path, cfg, input, accepted) {
  prices <- cpcSelectedPrices(cfg, task7MakePrices(cfg, input, accepted$slope, accepted$bend_year))
  matches <- tryCatch(cpcSamePrices(cpcReadPolicy(path), prices), error = function(e) FALSE)
  if (!isTRUE(matches)) stop("Final CSV differs from the archived confirmation: ", path)
}

task7ValidateReport <- function(cfg, report) {
  annual <- report$annual
  world <- report$world
  years <- cpcFirstPolicyYear:cfg$end_year
  if (!is.data.frame(annual) || !all(c("region", "year", "value") %in% names(annual)) ||
    !is.data.frame(world) || !all(c("year", "emissions_mtco2") %in% names(world))) {
    stop("Incomplete annual emissions report; retaining trial")
  }
  keys <- paste(annual$region, annual$year, sep = ":")
  expected <- as.vector(outer(cfg$regions, years, paste, sep = ":"))
  if (anyDuplicated(keys) || !setequal(keys, expected) || !is.numeric(annual$value) || any(!is.finite(annual$value)) ||
    anyDuplicated(world$year) || !identical(as.integer(world$year), years) ||
    !is.numeric(world$emissions_mtco2) || any(!is.finite(world$emissions_mtco2))) {
    stop("Invalid annual emissions grid; retaining trial")
  }
  totals <- aggregate(value ~ year, annual, sum)
  same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
  if (!same(totals$value[match(years, totals$year)], world$emissions_mtco2)) {
    stop("Regional and global emissions disagree; retaining trial")
  }
  invisible(NULL)
}

# Read one solved trial and derive its budget metrics from the validated emissions grid.
task7ReportTrial <- function(trial, a, cfg, report_process) {
  report_process("evaluate", trial)
  report <- readRDS(file.path(trial, "report.rds"))
  task7ValidateReport(cfg, report)
  a <- modifyList(a, task7Metrics(cfg, report$world), keep.null = TRUE)
  if (!task7ValidMetrics(a, cfg)) stop("Invalid emissions metrics")
  a$accounting <- "postprom net CO2 including energy, industrial processes, AFOLU and bunkers"
  a$world <- report$world
  a$net_zero_price <- if (!is.na(a$net_zero_year) && a$net_zero_year >= cfg$common_year) {
    task7PriceAt(cfg, a$slope, a$net_zero_year, a$bend_year)
  } else {
    NA_real_
  }
  list(result = a, report = report)
}


task7AnnualRows <- function(cfg, iteration, prices = NULL, report = NULL) {
  cpcAnnualRows(cfg, iteration, "Net CO2 emissions", "Mt CO2/yr", prices, report)
}

task7Summary <- function(trials, cfg, accepted_iteration = NA_integer_) {
  field <- function(x, name, missing = NA_real_) if (is.null(x[[name]])) missing else x[[name]]
  row <- function(a) {
    bent <- !is.null(a$bend_year) && !is.na(a$bend_year)
    valid <- isTRUE(a$valid)
    # FixedTail reports the rising segment before the plateau, not the average
    # slope from the net-zero knot to the capped end price.
    tail_slope <- if (bent && a$bend_year < cfg$end_year) a$slope * cfg$post_net_zero_slope_multiplier else NA_real_
    later_pos <- if (length(a$later_positive_years)) paste(a$later_positive_years, collapse = ", ") else NA_character_
    data.frame(
      Trial = field(a, "iteration", NA_integer_), Stage = field(a, "purpose", NA_character_),
      `Slope (USD2015/t CO2/year)` = field(a, "slope"), BendYear = field(a, "bend_year"),
      NetZeroYear = field(a, "net_zero_year"), `NetZeroPrice (USD2015/t CO2)` = field(a, "net_zero_price"),
      EndYear = cfg$end_year, `EndPrice (USD2015/t CO2)` = field(a, "end_price"),
      `TailSlope (USD2015/t CO2/year)` = tail_slope,
      TailFactor = if (!is.null(a$slope) && a$slope > 0) tail_slope / a$slope else NA_real_,
      TailPriceCapYear = if (bent) task7TailCapYear(cfg, a$slope, a$bend_year) else NA_real_,
      EndRule = if (valid) task7EndRule(a) else NA_character_, ValidRun = field(a, "valid", NA),
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
      LaterPositiveYears = later_pos,
      NormalRegionYears = field(a$solves, "final_region_years"), SolverAttempts = field(a$solves, "solver_attempts"),
      ElapsedSeconds = field(a, "elapsed_seconds"), FailureReason = field(a, "reason", NA_character_),
      LogExcerpt = field(a, "log_excerpt", NA_character_), check.names = FALSE
    )
  }
  if (!length(trials)) return(row(list())[FALSE, , drop = FALSE])
  do.call(rbind, lapply(trials, row))
}


# Publish directly from the retained confirmation, with its manifest last.
task7FinalModelMatches <- function(campaign, accepted) {
  cpcConfirmationMatches(campaign, cpcModelFiles(campaign), 7L, accepted$iteration)
}

task7SaveFinalModel <- function(campaign, trial, accepted, prices) {
  if (task7FinalModelMatches(campaign, accepted)) return(invisible(NULL))
  if (!cpcConfirmationTrialReady(trial)) stop("Missing or incomplete confirmation files: ", trial)
  if (!cpcSamePrices(cpcReadPolicy(file.path(trial, "data/iEnvPolicies.csv")), prices)) {
    stop("Retained confirmation prices differ from the accepted trial: ", trial)
  }
  cpcPublishConfirmation(cpcModelFiles(trial), campaign, trial, 7L, accepted$iteration)
}

task7ValidateComplete <- function(campaign, input, cfg, accepted) {
  if (!task7Converged(accepted, cfg) || accepted$purpose != "Confirmation") stop("Invalid completed confirmation")
  if (!task7FinalModelMatches(campaign, accepted)) stop("Completed model files do not match their confirmation")
  csv <- file.path(campaign, "calibrated-iEnvPolicies.csv")
  if (!cpcFilesReady(c(csv, cpcResearchFiles(campaign)))) stop("Completed archive is missing required results")
  task7CheckPriceCsv(csv, cfg, input, accepted)
}

# Clean up only after the complete state and confirmed artifacts are saved.
task7CleanupState <- function(campaign, state_path, saved_hash, trials) {
  marker <- file.path(campaign, "confirmation.rds")
  link <- Sys.readlink(marker)
  if ((!is.na(link) && nzchar(link)) || dir.exists(marker)) {
    stop("Unexpected confirmation marker; keeping recovery state")
  }
  if (file.exists(file.path(campaign, cpcProcessMarker))) stop("Reporting process cleanup is incomplete")
  work <- file.path(campaign, ".work")
  if (dir.exists(work)) {
    # Clean archived confirmation trials first while keeping unverified evidence.
    for (folder in cpcTrialFolders(work)) {
      index <- as.integer(sub("trial-", "", basename(folder)))
      if (index >= 1L && index <= length(trials) && isTRUE(trials[[index]]$valid) &&
        identical(trials[[index]]$purpose, "Confirmation")) {
        cpcCleanup(folder, work, state_path, saved_hash)
      }
    }
    cpcCleanup(work, campaign, state_path, saved_hash)
  }
  cpcCleanupReportState(campaign, state_path, saved_hash)
  invisible(NULL)
}

task7RunSettings <- function(cfg, status, reason = NULL, accepted = NA_integer_) {
  values <- list(
    "Temperature case" = cfg$temperature_case,
    "Path selection" = "Automatic: straight end-budget search first; split only if peak exceeds its ceiling",
    "Prefix policy" = cfg$prefix_policy,
    "Keep input prices through" = cfg$fixed_through_year,
    "Common price year" = cfg$common_year,
    "Common price (USD2015/t CO2)" = cfg$common_price,
    "Post-net-zero slope multiplier" = cfg$post_net_zero_slope_multiplier,
    "Tail geometry" = "Tail rises at front slope * multiplier until max_price, then stays flat",
    "Model end year" = cfg$end_year,
    "Budget start year" = cfg$budget_start_year,
    "Peak budget (Gt CO2)" = cfg$peak_budget_gtco2,
    "End budget (Gt CO2)" = cfg$end_budget_gtco2,
    "Start slope" = cfg$search$start_slope,
    "Initial slope step" = cfg$search$initial_slope_step,
    "Maximum price" = cfg$search$max_price,
    "Slope resolution" = cfg$search$slope_resolution,
    "Maximum evaluations" = cfg$search$max_evaluations,
    "Peak tolerance (Gt CO2)" = cfg$search$peak_tolerance_gtco2,
    "End tolerance (Gt CO2)" = cfg$search$end_tolerance_gtco2,
    "End acceptance" = "Straight: end band; bent: fixed-ratio tail must meet end ceiling, slack allowed",
    "Search method" = paste(
      "Automatic straight / peak-slope search; fixed-ratio tail capped at max_price;",
      "no independent end-price search or front recalibration"
    ),
    "Status" = status,
    "Reason" = if (is.null(reason)) NA_character_ else reason,
    "Accepted trial" = accepted
  )
  if (identical(status, "complete")) {
    values[["Final model files"]] <- paste(basename(cpcModelFiles(".")), collapse = ", ")
  }
  data.frame(Parameter = names(values), Value = vapply(values, as.character, character(1)), row.names = NULL)
}

# Start slope and jump step stay frozen with the campaign. Only the total
# evaluation cap and accuracy controls may change on resume.
task7ResumeSearch <- function(cfg, requested) {
  for (key in c("max_evaluations", "peak_tolerance_gtco2", "end_tolerance_gtco2", "slope_resolution")) {
    value <- requested$search[[key]]
    if (!is.null(value)) {
      cpcNumber(value, key, 0, integer = key == "max_evaluations")
      cfg$search[[key]] <- value
    }
  }
  cfg
}


task7CheckpointSheets <- function(state) {
  cfg <- state$cfg
  annual <- if (length(state$annual_rows)) do.call(rbind, state$annual_rows) else task7AnnualRows(cfg, 0L)[FALSE, ]
  cpcHistorySheets(
    annual, task7Summary(state$trials, cfg, state$accepted),
    task7RunSettings(cfg, state$status, state$reason, state$accepted)
  )
}

task7CheckState <- function(state, settings, requested) {
  if (length(state$status) != 1L || !is.character(state$status) || is.na(state$status) ||
    length(state$accepted) != 1L || !is.list(state$trials) || !is.list(state$annual_rows) ||
    length(state$trials) != length(state$annual_rows) || !is.list(state$cfg)) {
    stop("Invalid Task 7 checkpoint or changed campaign configuration")
  }
  if (!is.na(state$accepted)) {
    if (!cpcIsIndex(state$accepted) || state$accepted > length(state$trials)) stop("Invalid archived confirmation")
    accepted <- state$trials[[state$accepted]]
    if (!is.list(accepted) || !identical(accepted$purpose, "Confirmation") || !task7Converged(accepted, state$cfg)) {
      stop("Invalid archived confirmation")
    }
  }
  if (identical(state$status, "complete") && (is.na(state$accepted) || is.null(state$confirmation_hash))) {
    stop("Completed archive has no confirmation inventory")
  }
  if (!identical(state$status, "complete")) {
    settings$search <- task7ResumeSearch(state$cfg, requested)$search
    task7ValidateConfig(settings)
  }
}

task7RestoreCompleted <- function(campaign, state, input, state_path, history) {
  saved <- cpcHash(state_path)
  marker <- file.path(campaign, "confirmation.rds")
  task7ValidateComplete(campaign, input, state$cfg, state$trials[[state$accepted]])
  if (!identical(state$confirmation_hash, cpcHash(marker))) {
    stop("Confirmation manifest differs from the completed checkpoint")
  }
  cpcSaveHistory(history, task7CheckpointSheets(state))
  task7CleanupState(campaign, state_path, saved, state$trials)
  message("Calibration already complete; returning saved results: ", campaign)
}

# An interrupted solve may be retried. Once its GDX exists, report it under
# the original request and keep the solver files if reporting fails.
task7RecoverTrial <- function(trial, index, cfg, input, report_process) {
  evidence <- file.path(trial, c("gams.log", "modelstat.txt", "main.lst", cpcGdxFile))
  if (!any(file.exists(evidence))) return(NULL)
  request <- file.path(trial, "request.rds")
  if (!file.exists(request)) stop("Missing request for retained solver files: ", trial)
  a <- readRDS(request)
  if (!cpcIsIndex(a$iteration) || a$iteration != index ||
    !isTRUE(a$purpose %in% c("Straight", "Probe", "FixedTail", "Confirmation"))) {
    stop("Invalid request for retained trial: ", trial)
  }
  prices <- task7MakePrices(cfg, input, a$slope, a$bend_year)
  expected_end <- task7PriceAt(cfg, a$slope, cfg$end_year, a$bend_year)
  if (!isTRUE(all.equal(a$end_price, expected_end, tolerance = 1e-12)) ||
    (is.na(a$bend_year) && a$purpose == "FixedTail") ||
    (!is.na(a$bend_year) && !a$purpose %in% c("FixedTail", "Confirmation"))) {
    stop("Invalid retained price path: ", trial)
  }
  if (!cpcSamePrices(cpcReadPolicy(file.path(trial, "data/iEnvPolicies.csv")), prices)) {
    stop("Retained trial prices differ from its request: ", trial)
  }
  if (!cpcFilesReady(file.path(trial, cpcGdxFile))) return(NULL)
  message("Recovering retained trial ", index, " from its model output")
  a$solves <- task7CheckSolves(trial, cfg$regions, cpcFirstSolveYear:cfg$end_year)
  reported <- task7ReportTrial(trial, a, cfg, report_process)
  reported$prices <- prices
  reported
}

# ---- Task entry point: setup, resume, evaluate, checkpoint and export ---------
runTask7 <- function(config, gams, write_metadata, args) {
  root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  requested <- config$global_carbon_price_calibration
  options <- cpcOptions(requested, args, 7L)
  resuming <- !is.null(options$resume_from)
  if (!resuming) task7ValidateConfig(requested)
  cpcRequirePackages()
  opened <- cpcOpenCampaign(root, options$resume_from, "calibrate-global-carbon-price")
  campaign <- opened$path
  on.exit(filelock::unlock(opened$lock), add = TRUE)
  if (resuming) cpcStopRetainedProcess(campaign, expected_wd = root)
  if (!resuming) cpcSnapshot(root, campaign, config, write_metadata)

  frozen <- cpcReadCampaignConfig(campaign)
  run_config <- frozen$config
  config_hash <- frozen$hash
  input <- cpcReadPolicy(file.path(campaign, "data/iEnvPolicies.csv"))
  regions <- cpcReadRegions(campaign)
  history <- file.path(campaign, "calibration-history.xlsx")
  final_csv <- file.path(campaign, "calibrated-iEnvPolicies.csv")
  work <- file.path(campaign, ".work")
  state_path <- file.path(campaign, "calibration-state.rds")
  if (resuming) {
    saved_state <- cpcLoadState(state_path, 7L, config_hash, function(state) {
      task7CheckState(state, run_config$global_carbon_price_calibration, requested)
    })
    if (is.null(saved_state)) {
      stop("Missing calibration-state.rds in resume_from: ", campaign)
    }
    cfg <- saved_state$cfg
    trials <- saved_state$trials
    annual_rows <- saved_state$annual_rows
    if (identical(saved_state$status, "complete")) {
      task7RestoreCompleted(campaign, saved_state, input, state_path, history)
      return(invisible(campaign))
    }
    if (!is.na(saved_state$accepted) && file.exists(final_csv)) {
      task7CheckPriceCsv(final_csv, cfg, input, trials[[saved_state$accepted]])
    }
    cfg <- task7ResumeSearch(cfg, requested)
  } else {
    cfg <- task7Setup(run_config$global_carbon_price_calibration, input, regions)
    trials <- list()
    annual_rows <- list()
  }
  dir.create(work, showWarnings = FALSE)
  if (!dir.exists(work)) stop("Cannot open calibration work directory")
  flags <- cpcFlags(run_config$scenario$gams_flags, cfg)
  process_env <- cpcProcessEnvironment(run_config, campaign)
  if (cfg$search$max_evaluations * (2L * length(regions) + 1L) >= 1048576L) {
    stop("max_evaluations exceeds Excel capacity")
  }
  cache <- new.env(parent = emptyenv())
  price_key <- function(slope, bend) paste(sprintf("%.15g", c(slope, bend)), collapse = ":")
  remember <- function(a) {
    if (isTRUE(a$valid) && a$purpose != "Confirmation") cache[[price_key(a$slope, a$bend_year)]] <- a
  }
  for (a in trials) remember(a)
  retain_on_error <- function(expr) {
    failed <- function(e) {
      msg <- paste0(conditionMessage(e), "\nTemporary results retained at ", work)
      stop(structure(list(message = msg, call = NULL), class = c("task7_retained_error", "error", "condition")))
    }
    tryCatch(expr, error = failed, interrupt = failed)
  }
  report_process <- cpcReportProcess(root, campaign, run_config, "Emissions|CO2.Mt CO2/yr")
  checkpoint <- function(status = "running", reason = NULL, accepted_iteration = NA_integer_,
                         confirmation_hash = NULL) {
    state <- list(
      cfg = cfg, config_hash = config_hash, trials = trials, annual_rows = annual_rows,
      status = status, reason = reason, accepted = accepted_iteration, confirmation_hash = confirmation_hash
    )
    retain_on_error(cpcSaveCheckpoint(state_path, 7L, state, history, task7CheckpointSheets(state)))
  }
  clean <- function(path, parent, saved) retain_on_error(cpcCleanup(path, parent, state_path, saved))
  trial_folder <- function(index) file.path(work, sprintf("trial-%03d", index))
  finish <- function(status, accepted = NULL, reason = NULL) {
    if (is.null(accepted)) {
      checkpoint(status, reason)
    } else {
      if (!task7Converged(accepted, cfg)) stop("Cannot export an unverified price path")
      chosen <- accepted$iteration
      checkpoint("finalizing", reason, chosen)
      prices <- task7MakePrices(cfg, input, accepted$slope, accepted$bend_year)
      retain_on_error(task7SaveFinalModel(campaign, trial_folder(chosen), accepted, prices))
      failed_export <- function(e) {
        checkpoint("export_failed", conditionMessage(e), chosen)
        stop(e)
      }
      retain_on_error(tryCatch(cpcWritePrices(final_csv, cpcSelectedPrices(cfg, prices)), error = failed_export))
      checkpoint(status, reason, chosen)
    }
    list(status = status, reason = reason, accepted = accepted)
  }
  run <- function() {
    if (resuming) {
      for (folder in c(work, cpcTrialFolders(work))) {
        retain_on_error(cpcStopRetainedProcess(folder))
      }
      # Reuse a confirmed path after publication or reporting failure. A change
      # to search accuracy returns to calibration with the frozen physical inputs.
      status <- saved_state$status
      accuracy <- c("peak_tolerance_gtco2", "end_tolerance_gtco2", "slope_resolution")
      if (status %in% c("finalizing", "export_failed", "verified", "postprocessing", "postprocessing_failed") &&
        !is.na(saved_state$accepted) && identical(cfg$search[accuracy], saved_state$cfg$search[accuracy])) {
        a <- trials[[saved_state$accepted]]
        if (file.exists(final_csv) && task7FinalModelMatches(campaign, a)) {
          message("Calibration already verified; resuming full reporting only")
          return(list(status = "verified", reason = "Saved calibration verified; reporting resumed", accepted = a))
        }
        return(finish("verified", a, saved_state$reason))
      }
      previous <- tempfile("previously-calibrated-", tmpdir = work, fileext = ".csv")
      if (file.exists(final_csv) && !file.rename(final_csv, previous)) {
        stop("Cannot retire previous export: ", final_csv)
      }
    }
    saveRDS(cfg, file.path(work, "config.rds"))
    retained_folders <- cpcTrialFolders(work)
    fresh <- !length(trials) && !length(retained_folders)
    # An orderly interruption may have checkpointed its failure. Reuse its number on replay.
    if (length(trials) && !isTRUE(tail(trials, 1L)[[1L]]$valid)) {
      trials <<- head(trials, -1L)
      annual_rows <<- head(annual_rows, -1L)
    }
    saved <- checkpoint()
    cpcFreezeReporting(campaign, report_process, fresh = fresh)
    archive <- function(trial, result, prices, report = NULL) {
      if (!isTRUE(result$valid)) {
        report <- NULL
        result$log_excerpt <- cpcLogExcerpt(file.path(trial, c("gams.log", "report.log")))
      }
      index <- result$iteration
      annual_rows[[index]] <<- retain_on_error(task7AnnualRows(cfg, index, prices, report))
      trials[[index]] <<- result
      saved <- checkpoint()
      if (isTRUE(result$valid) && result$purpose == "Confirmation") {
        message("Retaining confirmation trial ", index, " until final publication")
      } else {
        clean(trial, work, saved)
      }
      remember(result)
      if (isTRUE(result$valid)) {
        message(sprintf(
          paste(
            "  net-zero peak=%.4f Gt; full peak=%.4f Gt; end total=%.4f Gt;",
            "net-zero year=%s; end rule=%s; converged=%s"
          ),
          result$net_zero_peak_gtco2, result$peak_cumulative_gtco2, result$cumulative_gtco2,
          result$net_zero_year, task7EndRule(result), task7Converged(result, cfg)
        ))
      }
      invisible(saved)
    }
    for (trial in retained_folders) {
      index <- as.integer(sub("trial-", "", basename(trial)))
      if (index <= length(trials)) {
        if (trials[[index]]$purpose != "Confirmation") clean(trial, work, saved)
        next
      }
      if (index != length(trials) + 1L) retain_on_error(stop("Gap in retained trial numbers: ", trial))
      recovered <- retain_on_error(task7RecoverTrial(trial, index, cfg, input, report_process))
      if (is.null(recovered)) {
        clean(trial, work, saved)
      } else {
        saved <- archive(trial, recovered$result, recovered$prices, recovered$report)
      }
    }
    # Cache search results, reserve confirmation capacity and archive each solve.
    evaluate <- function(slope, bend_year = NA_real_, purpose = "Straight") {
      if (!purpose %in% c("Straight", "Probe", "FixedTail", "Confirmation")) stop("Invalid trial purpose")
      confirmation <- purpose == "Confirmation"
      if (is.na(bend_year) && purpose %in% c("Straight", "Confirmation") && slope > task7SlopeLimit(cfg) + 1e-10) {
        stop("Straight path exceeds max_price")
      }
      key <- price_key(slope, bend_year)
      if (!confirmation && exists(key, cache, inherits = FALSE)) {
        message("Reusing saved trial ", cache[[key]]$iteration, ": ", key)
        return(cache[[key]])
      }
      reserved <- if (confirmation) 0L else 1L
      limit <- cfg$search$max_evaluations - reserved
      if (length(trials) >= limit) {
        stop("evaluation_budget_exhausted; increase search.max_evaluations to resume")
      }
      prices <- task7MakePrices(cfg, input, slope, bend_year)
      index <- length(trials) + 1L
      trial <- trial_folder(index)
      if (!dir.create(trial)) stop("Cannot create a fresh trial directory")
      trial_start <- proc.time()[["elapsed"]]
      report <- NULL
      interrupted <- NULL
      result <- list(
        iteration = index, valid = FALSE, slope = slope, bend_year = bend_year,
        end_price = task7PriceAt(cfg, slope, cfg$end_year, bend_year), purpose = purpose
      )
      cpcWriteRds(result, file.path(trial, "request.rds"))
      result <- tryCatch(
        {
          cpcPrepareTrial(campaign, trial, prices, confirmation)
          message(sprintf(
            "Trial %d (%s): slope=%.6f; bend=%s; end price=%.4f",
            index, purpose, slope, bend_year, result$end_price
          ))
          cpcRunProcess(gams, cpcSolveArgs(flags, confirmation), trial, file.path(trial, "gams.log"), env = process_env)
          result$solves <- task7CheckSolves(trial, regions, cpcFirstSolveYear:cfg$end_year)
          result
        },
        error = function(e) modifyList(result, list(valid = FALSE, reason = conditionMessage(e))),
        interrupt = function(e) {
          interrupted <<- e
          modifyList(result, list(valid = FALSE, reason = "interrupted"))
        }
      )
      if (!is.null(result$solves)) {
        reported <- retain_on_error(task7ReportTrial(trial, result, cfg, report_process))
        result <- reported$result
        report <- reported$report
      }
      result$elapsed_seconds <- proc.time()[["elapsed"]] - trial_start
      archive(trial, result, prices, report)
      if (!is.null(interrupted)) stop(interrupted)
      result
    }
    accepted <- task7Search(cfg, evaluate)
    bend <- accepted$bend_year
    confirmations <- Filter(
      function(a) {
        fields <- c("slope", "bend_year", "end_price")
        a$purpose == "Confirmation" && task7Converged(a, cfg) &&
          isTRUE(all.equal(a[fields], accepted[fields], tolerance = 0)) &&
          isTRUE(all.equal(a$world, accepted$world, tolerance = 1e-10)) &&
          (cpcConfirmationTrialReady(trial_folder(a$iteration)) || task7FinalModelMatches(campaign, a))
      },
      trials
    )
    confirmation <- if (length(confirmations)) {
      tail(confirmations, 1L)[[1L]]
    } else {
      evaluate(accepted$slope, bend, "Confirmation")
    }
    if (!task7Converged(confirmation, cfg) ||
      !isTRUE(all.equal(confirmation$net_zero_year, accepted$net_zero_year, tolerance = 0)) ||
      !isTRUE(all.equal(confirmation$world, accepted$world, tolerance = 1e-10))) {
      return(finish("confirmation_failed", reason = "Independent confirmation changed the calibrated emissions/path"))
    }
    finish("verified", confirmation, accepted$calibration_note)
  }

  result <- tryCatch(
    run(),
    interrupt = function(e) finish("interrupted", reason = "interrupted"),
    error = function(e) {
      if (inherits(e, "task7_retained_error")) stop(e)
      finish("unfinished", reason = conditionMessage(e))
    }
  )
  message("Calibrate Global Carbon Price (Task 7): ", history)
  if (result$status != "verified") stop(result$status, ": ", result$reason)
  # Always produce the final research report, independently of behavior.withReport.
  # Keep accepted calibration and its CSV/GDX intact if reporting or LaTeX fails.
  report_error <- tryCatch(
    {
      cpcFullReport(campaign, work, report_process)
      task7ValidateComplete(campaign, input, cfg, result$accepted)
      NULL
    },
    error = function(e) conditionMessage(e),
    interrupt = function(e) "Full reporting interrupted"
  )
  saved <- checkpoint(
    if (is.null(report_error)) "complete" else "postprocessing_failed",
    if (is.null(report_error)) result$reason else report_error, result$accepted$iteration,
    if (is.null(report_error)) cpcHash(file.path(campaign, "confirmation.rds"))
  )
  if (!is.null(report_error)) {
    stop(
      "Calibration verified; full reporting incomplete: ", report_error,
      ". Resume with resume_from=\"", campaign, "\" to retry reporting without another model solve."
    )
  }
  task7CleanupState(campaign, state_path, saved, trials)
  invisible(campaign)
}
