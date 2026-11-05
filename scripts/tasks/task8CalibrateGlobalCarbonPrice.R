# Task 8: Calibrate Global Carbon Price
#
# Core algorithm
# 1. Keep each region's prefix_policy prices through fixed_through_year.
# 2. Prescribe common_year/common_price and connect each regional prefix to
#    this anchor linearly. All prices from common_year onward are shared globally.
# 3. If net_zero_year is set, search its price until annual net CO2 is close to
#    zero from below. With null, omit this anchor and the annual constraint.
# 4. Prescribe end_year and the cumulative CO2 budget; search that year's common
#    price until cumulative net CO2 approaches the budget from below. Join all
#    three or four anchors with straight lines and independently confirm the path.
# Prices never decrease. This is ordered calibration, not cost optimization.
# Each trial runs all 39 regions annually from 2024 through end_year.
# Only the independent confirmation retains the normal research outputs and metadata.
# After publishing the confirmed result, run the normal research report once.
# Report failures preserve calibration outputs; unchanged-accuracy resumes retry reporting only.
# Keep recovery files in calibration-state/ until complete is saved, then remove
# that directory and confirmation.rds. Completed resumes return the saved archive.
#
# Configuration reference: current config.json:global_carbon_price_calibration.
# This commented copy documents the settings; edit config.json to change them.
# All prices below are USD2015/t CO2. CLI resume_from overrides the configured path.
# {
#   "resume_from": null, // null starts a campaign; a path resumes unfinished work or returns a complete archive.
#   "prefix_policy": "exogCV_NPi", // Input policy row copied through fixed_through_year.
#   "fixed_through_year": 2028, // Last year retaining regional input prices, inclusive.
#   "common_year": 2035, // Year when all regions reach common_price.
#   "common_price": 100, // Shared price; must exceed every regional fixed-year price.
#   "net_zero_year": null, // null searches only the end price; a year enables annual net CO2 <= 0 first.
#   "end_year": 2100, // Model end year and cumulative-budget check year.
#   "budget_start_year": 2020, // First year included in the budget, including historical emissions.
#   "budget_gtco2": 1150, // Global cumulative net CO2 ceiling (Gt); report reference for 2020-2100: 1.5C = 400, 2C = 1150.
#   "temperature_case": "2C", // Allowed: "1.5C" or "2C"; budget and net-zero mode stay explicit.
#   // "1.5C": policy=exogCV_1_5C, fScenario=2, emulatorCarbonPriceScenario=1p5C.
#   // "2C": policy=exogCV_2C, fScenario=3, emulatorCarbonPriceScenario=2C.
#   // Both force landUseEmulator=magpie and softLinkMAgPIE=off.
#   // Task 8 overrides matching scenario.gams_flags and skips scenario.land_use_emulator.
#   // Resume uses the saved temperature_case and net_zero_year, including null.
#   "search": {
#     "net_zero_start_price": null, // Used only with a net-zero year; then must be >= common_price.
#     "end_start_price": 400, // First end-price trial; floor is common_price, or the calibrated net-zero price in two-stage mode.
#     "initial_price_step": 100, // First upward/downward jump; doubles after each jump without a bracket. Prices never cross their legal bounds.
#     "max_price": 5000, // Maximum allowed price at both searched years; not a starting price.
#     "price_resolution": 1, // Minimum bracket width; unresolved emissions accuracy stops unfinished.
#     "max_evaluations": 50, // Only evaluation-count limit, shared across stages and resumes; includes independent confirmation; cache hits add no trial.
#     "net_zero_tolerance_mtco2": 100, // Desired annual band: [-tolerance, 0] Mt CO2/yr; unused when net_zero_year is null.
#     "budget_tolerance_gtco2": 5 // Desired cumulative band: [budget - tolerance, budget] Gt CO2.
#   }
# }
#
# Usage:
#   Rscript start.R task_id=8
#   Rscript start.R task_id=8 resume_from="runs/<previous-campaign>"

# ---- Configuration and price construction -----------------------------------
task8Options <- function(cfg, args) {
  keys <- sub("=.*$", "", args)
  unknown <- setdiff(keys, c("task_id", "resume_from"))
  if (length(unknown)) stop("Unsupported Task 8 option(s): ", paste(unknown, collapse = ", "))
  resume <- sub("^resume_from=", "", grep("^resume_from=", args, value = TRUE))
  if (length(resume) > 1L) stop("Supply one resume_from directory")
  path <- if (length(resume)) resume else cfg$resume_from
  if (!is.null(path) && (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(trimws(path)))) {
    stop("resume_from must be null or a nonempty campaign directory")
  }
  list(resume_from = path)
}

task8Number <- function(x, name, minimum = 0, integer = FALSE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) || x < minimum ||
      (integer && x != trunc(x))) stop("Invalid ", name, ": expected a finite number")
  invisible(x)
}

task8ValidateConfig <- function(cfg) {
  # Ignore retired descriptive metadata in older campaign snapshots.
  if (is.list(cfg)) cfg$budget_source <- NULL
  required <- c("prefix_policy", "fixed_through_year", "common_year", "common_price",
                "net_zero_year", "end_year", "budget_start_year", "budget_gtco2",
                "temperature_case", "search")
  if (!is.list(cfg) || anyDuplicated(names(cfg)) || !all(required %in% names(cfg)) ||
      any(!names(cfg) %in% c(required, "resume_from"))) {
    stop("Set config.json:global_carbon_price_calibration using config.template.json")
  }
  task8Options(cfg, character())
  for (k in c("fixed_through_year", "common_year", "end_year", "budget_start_year")) {
    task8Number(cfg[[k]], k, 2010, TRUE)
  }
  with(cfg, if (!(2024 <= fixed_through_year && fixed_through_year < common_year &&
                  common_year < end_year && end_year <= 2100)) {
    stop("Require 2024 <= fixed year < common year < end year <= 2100")
  })
  if (!is.null(cfg$net_zero_year)) {
    task8Number(cfg$net_zero_year, "net_zero_year", 2010, TRUE)
    if (!(cfg$common_year < cfg$net_zero_year && cfg$net_zero_year < cfg$end_year)) {
      stop("Require common year < net-zero year < end year, or net_zero_year = null")
    }
  }
  if (cfg$budget_start_year > 2024) stop("Budget start must include the model start (2024)")
  task8Number(cfg$common_price, "common_price")
  task8Number(cfg$budget_gtco2, "budget_gtco2")
  if (length(cfg$temperature_case) != 1L || !cfg$temperature_case %in% c("1.5C", "2C")) {
    stop("temperature_case must be 1.5C or 2C")
  }
  if (length(cfg$prefix_policy) != 1L || !cfg$prefix_policy %in%
      c("exogCV_NPi", "exogCV_1_5C", "exogCV_2C", "exogCV_Calib")) stop("Unsupported prefix_policy")
  # Convert legacy start names in memory; saved trials and physical targets stay unchanged.
  if (is.list(cfg$search)) {
    old_names <- c(initial_net_zero_price = "net_zero_start_price", initial_end_price = "end_start_price")
    legacy <- any(names(old_names) %in% names(cfg$search))
    for (old in names(old_names)) if (old %in% names(cfg$search)) {
      new <- old_names[[old]]
      if (!is.null(cfg$search[[new]]) && !isTRUE(all.equal(cfg$search[[new]], cfg$search[[old]], tolerance = 0))) {
        stop("Conflicting search settings: ", old, " and ", new)
      }
      cfg$search[[new]] <- cfg$search[[old]]
      cfg$search[[old]] <- NULL
    }
    if (legacy && is.null(cfg$search$initial_price_step)) cfg$search$initial_price_step <- 100
    # Older campaigns also predate the explicit emissions tolerances.
    if (is.null(cfg$search$net_zero_tolerance_mtco2)) cfg$search$net_zero_tolerance_mtco2 <- 100
    if (is.null(cfg$search$budget_tolerance_gtco2)) cfg$search$budget_tolerance_gtco2 <- 5
  }
  keys <- c("net_zero_start_price", "end_start_price", "initial_price_step", "max_price", "price_resolution",
            "max_evaluations", "net_zero_tolerance_mtco2", "budget_tolerance_gtco2")
  s <- cfg$search
  if (!is.list(s) || anyDuplicated(names(s)) || !setequal(names(s), keys)) stop("Invalid search settings")
  for (k in keys) {
    if (k == "net_zero_start_price" && is.null(cfg$net_zero_year) && is.null(s[[k]])) next
    task8Number(s[[k]], k, 0, k == "max_evaluations")
  }
  if (s$initial_price_step <= 0) stop("Initial price step must be positive")
  if (s$price_resolution <= 0) stop("Price resolution must be positive")
  if (s$max_evaluations < 2) stop("Reserve one search call and one independent confirmation")
  if (s$max_price <= cfg$common_price) stop("max_price must exceed common_price")
  for (k in c("net_zero_start_price", "end_start_price")) {
    if (k == "net_zero_start_price" && is.null(cfg$net_zero_year)) next
    if (s[[k]] < cfg$common_price || s[[k]] > s$max_price) stop(k, " outside allowed prices")
  }
  cfg
}

task8ReadPolicy <- function(path) {
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

task8PolicyRow <- function(x, region, policy) {
  i <- which(x[[1L]] == region & x[[2L]] == policy)
  if (length(i) != 1L) stop("Expected exactly one policy row: ", region, "/", policy)
  i
}

task8Setup <- function(cfg, input, regions) {
  cfg <- task8ValidateConfig(cfg)
  if (!length(regions) || anyDuplicated(regions)) stop("Regions must be distinct and nonempty")
  cfg$regions <- regions
  one_half <- cfg$temperature_case == "1.5C"
  cfg$policy <- if (one_half) "exogCV_1_5C" else "exogCV_2C"
  cfg$emulator <- if (one_half) "1p5C" else "2C"
  cfg$fScenario <- if (one_half) 2L else 3L
  cfg$anchors <- setNames(vector("list", length(regions)), regions)
  for (r in regions) {
    i <- task8PolicyRow(input, r, cfg$prefix_policy)
    task8PolicyRow(input, r, cfg$policy)
    values <- suppressWarnings(as.numeric(input[i, as.character(2010:cfg$fixed_through_year)]))
    if (any(!is.finite(values) | values < 0)) stop("Invalid prefix for ", r)
    # Preserve historical changes before 2023; reject declines during simulation.
    if (any(diff(tail(values, cfg$fixed_through_year - 2023 + 1)) < 0)) stop("Prefix decreases after 2023: ", r)
    cfg$anchors[[r]] <- tail(values, 1L)
  }
  if (cfg$common_price <= max(unlist(cfg$anchors))) stop("Common price must exceed every region's fixed-year price")
  cfg
}

task8MakePrices <- function(cfg, input, knot, end) {
  task8Number(end, "end price")
  if (is.null(cfg$net_zero_year)) {
    if (length(knot) != 1L || !is.na(knot)) stop("Budget-only paths have no net-zero price")
    if (!(cfg$common_price <= end && end <= cfg$search$max_price)) {
      stop("Require common_price <= end price <= max_price")
    }
  } else {
    task8Number(knot, "net-zero price")
    if (!(cfg$common_price <= knot && knot <= end && end <= cfg$search$max_price)) {
      stop("Require common_price <= net-zero price <= end price <= max_price")
    }
  }
  output <- input
  years <- (cfg$fixed_through_year + 1):2100
  for (r in cfg$regions) {
    src <- task8PolicyRow(input, r, cfg$prefix_policy)
    dest <- task8PolicyRow(input, r, cfg$policy)
    prefix <- as.character(2010:cfg$fixed_through_year)
    output[dest, prefix] <- input[src, prefix]
    # Omit the intermediate anchor in budget-only mode; constant after end_year.
    prices <- approx(c(cfg$fixed_through_year, cfg$common_year, cfg$net_zero_year, cfg$end_year),
                     c(cfg$anchors[[r]], cfg$common_price, if (!is.null(cfg$net_zero_year)) knot, end), xout = years,
                     method = "linear", rule = 2)$y
    output[dest, as.character(years)] <- as.list(sprintf("%.15g", prices))
    actual <- as.numeric(output[dest, as.character(2023:2100)])
    if (any(!is.finite(actual)) || any(diff(actual) < -1e-10)) stop("Invalid constructed price path")
  }
  output
}

task8WritePrices <- function(path, x) {
  if (any(grepl('[,\r\n"]', unlist(x)))) stop("Unexpected separator in policy cells")
  tmp <- paste0(path, ".tmp")
  write.table(x, tmp, sep = ",", quote = FALSE, row.names = FALSE, col.names = TRUE, na = "NA")
  if (!file.copy(tmp, path, overwrite = TRUE)) stop("Cannot write price file")
  unlink(tmp)
  if (!identical(task8ReadPolicy(path), x)) stop("Price CSV round-trip changed values")
}

task8SamePrices <- function(x, y) {
  # Excel stores numeric anchors, so reconstruction can differ in the last
  # printed decimal. Compare the actual prices rather than CSV text spelling.
  if (!identical(names(x), names(y)) || !identical(x[, 1:2], y[, 1:2])) return(FALSE)
  left <- as.vector(as.matrix(x[, -(1:2)])); right <- as.vector(as.matrix(y[, -(1:2)]))
  a <- suppressWarnings(as.numeric(left)); b <- suppressWarnings(as.numeric(right))
  numeric <- is.finite(a)
  length(a) == length(b) && identical(numeric, is.finite(b)) &&
    identical(left[!numeric], right[!numeric]) && all(abs(a[numeric] - b[numeric]) <= 1e-12 * pmax(1, abs(b[numeric])))
}

# ---- One- or two-stage calibration -----------------------------------------
task8ValidMetrics <- function(a, cfg = NULL) {
  # Calls without cfg retain the legacy requirement for both metrics.
  annual <- is.null(cfg) || !is.null(cfg$net_zero_year)
  fields <- c(if (annual) "net_zero_mtco2", "cumulative_gtco2")
  isTRUE(a$valid) && all(vapply(a[fields],
    function(x) is.numeric(x) && length(x) == 1L && is.finite(x), logical(1)))
}

task8Passes <- function(a, cfg) {
  task8ValidMetrics(a, cfg) && (is.null(cfg$net_zero_year) || a$net_zero_mtco2 <= 0) &&
    a$cumulative_gtco2 <= cfg$budget_gtco2
}

task8Search <- function(cfg, evaluate) {
  s <- cfg$search; base <- cfg$common_price; ceiling <- s$max_price
  sample <- function(k, e) {
    a <- evaluate(k, e)
    if (!task8ValidMetrics(a, cfg)) stop("invalid_run: ", a$reason)
    a
  }
  # Each refinement needs an actually evaluated failing lower and passing upper
  # bound. A price-resolution/call limit is not evidence of emissions accuracy.
  refine <- function(lo, hi, price, residual, tolerance, run, label) {
    stopifnot(residual(lo) > 0, residual(hi) <= 0, price(lo) < price(hi))
    # New evaluations are limited globally by evaluate(), including on resume.
    repeat {
      if (residual(hi) >= -tolerance) return(hi)
      width <- price(hi) - price(lo)
      if (width <= s$price_resolution) stop(label, "_precision_limit: emissions remain outside tolerance")
      fraction <- (residual(lo) + tolerance / 2) / (residual(lo) - residual(hi))
      if (!is.finite(fraction)) fraction <- 0.5
      candidate <- price(lo) + width * min(0.9, max(0.1, fraction))
      # Stable decimal prices also reproduce the same cache key after Excel
      # round-tripping; this is ten times finer than the stopping resolution.
      quantum <- s$price_resolution / 10
      candidate <- round(candidate / quantum) * quantum
      if (candidate <= price(lo) || candidate >= price(hi)) candidate <- (price(lo) + price(hi)) / 2
      message(sprintf("%s refinement: price %.4f; bracket [%.4f, %.4f]", label, candidate, price(lo), price(hi)))
      a <- run(candidate)
      if (residual(a) <= 0) hi <- a else lo <- a
    }
  }
  # Start at the configured price, then jump in the required direction until
  # the tolerance band or a failing/passing bracket is found. No automatic baseline trial.
  search_price <- function(start, lower, price, residual, tolerance, run, label, lower_message) {
    a <- run(start)
    step <- s$initial_price_step
    repeat {
      value <- residual(a)
      if (value <= 0 && value >= -tolerance) return(a)
      direction <- if (value > 0) 1 else -1
      if (direction < 0 && price(a) <= lower) {
        stop(label, "_lower_bound: emissions remain below the desired tolerance band. ", lower_message)
      }
      # Return an evaluated, failing ceiling for the caller's existing bounds
      # handling, including the budget stage's additional-early-mitigation case.
      if (direction > 0 && price(a) >= ceiling) return(a)
      candidate <- max(lower, min(ceiling, price(a) + direction * step))
      if (candidate == price(a)) stop(label, "_precision_limit: price step cannot advance")
      message(sprintf("%s jump: price %.4f -> %.4f (step %.4f; bounds [%.4f, %.4f])",
        label, price(a), candidate, step, lower, ceiling))
      next_trial <- run(candidate)
      if (direction > 0 && residual(next_trial) <= 0) {
        return(refine(a, next_trial, price, residual, tolerance, run, label))
      }
      if (direction < 0 && residual(next_trial) > 0) {
        return(refine(next_trial, a, price, residual, tolerance, run, label))
      }
      a <- next_trial
      step <- min(ceiling - lower, 2 * step)
    }
  }
  budget <- function(a) a$cumulative_gtco2 - cfg$budget_gtco2
  end_price <- function(a) a$end_price
  if (is.null(cfg$net_zero_year)) {
    message("Budget-only mode: calibrate the end-year price; no net-zero anchor or constraint")
    accepted <- search_price(s$end_start_price, base, end_price, budget, s$budget_tolerance_gtco2,
      function(e) sample(NA_real_, e), "Budget", sprintf(
        "Cannot reduce the %d carbon price below the prescribed %d price (%.15g) without creating a declining carbon-price path, which the current model cannot solve. Please consider lowering the prescribed common price and starting a new search.",
        cfg$end_year, cfg$common_year, base))
    if (!task8Passes(accepted, cfg)) stop("bounds_unmet: cumulative budget not reached at the maximum end price")
    accepted$calibration_note <- "Cumulative emissions are within calibration tolerance; no net-zero target"
    message(accepted$calibration_note)
    return(accepted)
  }
  annual <- function(a) a$net_zero_mtco2
  knot_price <- function(a) a$knot_price
  flat <- function(k) sample(k, k)
  note <- character()
  message("Stage 1: calibrate the net-zero-year price before the end-year price")
  chosen <- search_price(s$net_zero_start_price, base, knot_price, annual,
    s$net_zero_tolerance_mtco2, flat, "Net-zero", sprintf(
      "Cannot reduce the %d carbon price below %.15g without creating a declining carbon-price path, which the current model cannot solve. Please consider lowering the prescribed carbon price in %d and starting a new search.",
      cfg$net_zero_year, base, cfg$common_year))
  if (annual(chosen) > 0) stop("bounds_unmet: net zero not reached at the maximum price")
  k <- knot_price(chosen)
  # End prices must not change the already solved prefix in this recursive
  # model. Recheck this assumption using every actual tail evaluation.
  tail_run <- function(e) {
    a <- sample(k, e)
    if (abs(annual(a) - annual(chosen)) > 1e-6 * max(1, abs(annual(chosen)))) {
      stop("prefix_changed: end price changed net-zero-year emissions; two-stage assumption needs review")
    }
    a
  }
  message(sprintf("Stage 1 complete: P%d=%.4f, net CO2=%.4f Mt", cfg$net_zero_year, k, annual(chosen)))
  message("Stage 2: calibrate the end-year price against the cumulative budget")
  start <- max(k, s$end_start_price)
  if (start != s$end_start_price) message(sprintf(
    "End-year start price raised from %.4f to the calibrated net-zero price %.4f to prevent a declining path",
    s$end_start_price, start))
  accepted <- search_price(start, k, end_price, budget, s$budget_tolerance_gtco2,
    tail_run, "Budget", sprintf(
      "Cannot reduce the %d carbon price below the calibrated %d price (%.15g) without creating a declining carbon-price path, which the current model cannot solve. Please adjust the earlier price path and start a new search.",
      cfg$end_year, cfg$net_zero_year, k))
  if (budget(accepted) > 0) {
    # A tight annual target alone is insufficient within the configured tail
    # ceiling. Find the extra early mitigation required, with the tail fixed
    # at its ceiling. Never claim the annual tolerance was met in this case.
    message("End-price ceiling is binding; searching additional early mitigation")
    low <- accepted; high <- sample(ceiling, ceiling)
    if (budget(high) > 0 || annual(high) > 0) stop("bounds_unmet: both targets not reached at the maximum prices")
    accepted <- refine(low, high, knot_price, budget, s$budget_tolerance_gtco2,
      function(k) {
        a <- sample(k, ceiling)
        if (annual(a) > 0) stop("nonmonotone_annual_response: higher knot price lost net zero")
        a
      }, "Early-mitigation")
    note <- c(note, "End-price ceiling requires additional early mitigation; annual net zero may exceed tolerance")
  }
  if (!task8Passes(accepted, cfg)) stop("Calibration did not retain both hard targets")
  accepted$calibration_note <- if (length(note)) paste(note, collapse = "; ") else "Both emissions targets are within calibration tolerances"
  message(accepted$calibration_note)
  accepted
}

# ---- Isolated model execution -----------------------------------------------
task8Hash <- function(path) digest::digest(file = path, algo = "sha256")

# Use the unchanged research writer inside the project, then copy its outputs
# to confirmation. This also works when a resumed campaign is outside the repo.
task8SaveMetadata <- function(root, trial) {
  dir.create(file.path(root, "runs"), showWarnings = FALSE)
  staging <- tempfile(".task8-metadata-", tmpdir = file.path(root, "runs"))
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

task8ProcessEnvironment <- function(run_config, campaign) {
  scenario <- run_config$scenario
  if (is.null(scenario)) scenario <- list()
  c("current",
    OPENPROM_SCENARIO = as.character(jsonlite::toJSON(scenario, auto_unbox = TRUE, null = "null", digits = NA)),
    OPENPROM_CONFIG = file.path(campaign, "config.json"))
}

task8RunProcess <- function(command, args, wd, log, env = NULL, marker_folder = wd) {
  marker <- file.path(marker_folder, "task8-process.rds")
  if (file.exists(marker)) stop("Retained process needs cleanup before a new launch: ", wd)
  # NULL sends output to the normal console; trial logs stay in temporary work.
  p <- processx::process$new(command, args, wd = wd,
                             stdout = if (is.null(log)) "" else log,
                             stderr = if (is.null(log)) "" else "2>&1", env = env,
                             cleanup_tree = TRUE, supervise = TRUE)
  on.exit({
    p$kill_tree()
    # Shutdown grace period only; model execution itself has no time limit.
    p$wait(timeout = 5000)
    if (!p$is_alive()) unlink(marker)
  }, add = TRUE)
  saveRDS(list(pid = p$get_pid(), created = as.numeric(p$get_start_time()),
               wd = normalizePath(wd, winslash = "/")), marker)
  p$wait()
  status <- p$get_exit_status()
  if (status != 0) stop("process_exit_", status, if (is.null(log)) "" else paste0(": ", log))
  invisible(list(status = status))
}

# Only a recorded Task 8 process with the expected launch directory can be
# stopped. Full reporting runs at the project root but keeps its marker in the
# campaign; creation time prevents killing a reused OS PID.
task8StopRetainedProcess <- function(folder, expected_wd = folder) {
  marker <- file.path(folder, "task8-process.rds")
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
    message("Stopping interrupted Task 8 process ", record$pid, " in ", folder)
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

task8CheckSolves <- function(trial, regions, years) {
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
task8SelectedPrices <- function(cfg, prices) {
  rows <- vapply(cfg$regions, function(r) task8PolicyRow(prices, r, cfg$policy), integer(1))
  x <- prices[rows, , drop = FALSE]
  names(x) <- names(prices)
  rownames(x) <- NULL
  x
}

task8ValidateReport <- function(cfg, report) {
  annual <- report$annual; world <- report$world
  years <- 2010:cfg$end_year
  if (!is.data.frame(annual) || !all(c("region", "year", "value") %in% names(annual)) ||
      !is.data.frame(world) || !all(c("year", "emissions_mtco2") %in% names(world))) {
    stop("Incomplete annual emissions report; retaining trial")
  }
  keys <- paste(annual$region, annual$year, sep = ":")
  expected <- as.vector(outer(cfg$regions, years, paste, sep = ":"))
  if (anyDuplicated(keys) || !setequal(keys, expected) ||
      !is.numeric(annual$value) || any(!is.finite(annual$value)) ||
      anyDuplicated(world$year) || !setequal(world$year, years) ||
      !is.numeric(world$emissions_mtco2) || any(!is.finite(world$emissions_mtco2))) {
    stop("Incomplete/invalid annual emissions grid; retaining trial")
  }
  totals <- aggregate(value ~ year, annual, sum)
  totals <- totals[match(years, totals$year), "value"]
  global <- world$emissions_mtco2[match(years, world$year)]
  same <- function(a, b) length(a) == length(b) && all(is.finite(a)) && all(is.finite(b)) &&
    all(abs(a - b) <= 1e-12 * pmax(1, abs(a), abs(b)))
  if (!same(totals, global)) stop("Regional and global emissions disagree; retaining trial")
  metrics <- report$metrics
  net <- if (is.null(cfg$net_zero_year)) NA_real_ else global[years == cfg$net_zero_year]
  cumulative <- tail(cumsum(global[years >= cfg$budget_start_year]) / 1000, 1L)
  annual_matches <- if (is.null(cfg$net_zero_year)) {
    is.null(metrics$net_zero_mtco2) || (length(metrics$net_zero_mtco2) == 1L && is.na(metrics$net_zero_mtco2))
  } else same(net, metrics$net_zero_mtco2) && (net <= 0) == (metrics$net_zero_mtco2 <= 0)
  if (!task8ValidMetrics(metrics, cfg) || !annual_matches ||
      !same(cumulative, metrics$cumulative_gtco2) ||
      (cumulative <= cfg$budget_gtco2) != (metrics$cumulative_gtco2 <= cfg$budget_gtco2)) {
    stop("Annual emissions and target metrics disagree; retaining trial")
  }
  invisible(NULL)
}

task8AnnualRows <- function(cfg, iteration, prices = NULL, report = NULL) {
  n <- length(cfg$regions)
  x <- data.frame(Trial = rep(iteration, 2L * n + 1L),
                  Metric = c(rep("Carbon price", n), rep("Net CO2 emissions", n + 1L)),
                  Region = c(cfg$regions, cfg$regions, "World"),
                  Unit = c(rep("USD2015/t CO2", n), rep("Mt CO2/yr", n + 1L)),
                  check.names = FALSE)
  for (year in 2010:2100) x[[as.character(year)]] <- NA_real_
  if (!is.null(prices)) {
    values <- task8SelectedPrices(cfg, prices)
    for (year in as.character(2010:2100)) {
      value <- suppressWarnings(as.numeric(values[[year]]))
      if (length(value) != n || any(!is.finite(value))) stop("Incomplete annual price record; retaining trial")
      x[seq_len(n), year] <- value
    }
  }
  if (!is.null(report)) {
    if (is.null(prices)) stop("Missing prices for a reported trial; retaining trial")
    task8ValidateReport(cfg, report)
    annual <- report$annual
    for (year in sort(unique(annual$year))) {
      rows <- annual[annual$year == year, ]
      x[n + seq_len(n), as.character(year)] <- rows$value[match(cfg$regions, rows$region)]
      x[2L * n + 1L, as.character(year)] <- report$world$emissions_mtco2[report$world$year == year]
    }
  }
  x
}

task8Summary <- function(trials, cfg, accepted_iteration = NA_integer_) {
  field <- function(x, name, missing = NA_real_) if (is.null(x[[name]])) missing else x[[name]]
  row <- function(a) data.frame(
    Trial = field(a, "iteration", NA_integer_), Stage = field(a, "purpose", NA_character_),
    NetZeroYear = if (is.null(cfg$net_zero_year)) NA_real_ else cfg$net_zero_year,
    `NetZeroPrice (USD2015/t CO2)` = field(a, "knot_price"),
    EndYear = cfg$end_year, `EndPrice (USD2015/t CO2)` = field(a, "end_price"),
    ValidRun = field(a, "valid", NA),
    `NetZeroYearCO2 (Mt CO2/yr)` = field(a, "net_zero_mtco2"),
    `CumulativeCO2 (Gt CO2)` = field(a, "cumulative_gtco2"),
    `Budget (Gt CO2)` = cfg$budget_gtco2,
    NetZeroMet = if (isTRUE(a$valid) && !is.null(cfg$net_zero_year)) a$net_zero_mtco2 <= 0 else NA,
    BudgetMet = if (isTRUE(a$valid)) a$cumulative_gtco2 <= cfg$budget_gtco2 else NA,
    BothMet = if (isTRUE(a$valid)) task8Passes(a, cfg) else NA,
    Accepted = !is.na(accepted_iteration) && identical(a$iteration, accepted_iteration),
    `PeakCumulativeCO2 (Gt CO2)` = field(a, "peak_cumulative_gtco2"), PeakYear = field(a, "peak_year"),
    FirstNonpositiveYear = field(a, "first_nonpositive_year"),
    LaterPositiveYears = if (length(a$later_positive_years)) paste(a$later_positive_years, collapse = ", ") else NA_character_,
    NormalRegionYears = field(a$solves, "final_region_years"), SolverAttempts = field(a$solves, "solver_attempts"),
    `ElapsedSeconds` = field(a, "elapsed_seconds"), FailureReason = field(a, "reason", NA_character_),
    LogExcerpt = field(a, "log_excerpt", NA_character_),
    check.names = FALSE)
  if (!length(trials)) return(row(list())[FALSE, , drop = FALSE])
  do.call(rbind, lapply(trials, row))
}

task8ReplaceFile <- function(staged, destination) {
  # Keep the previous archive until the replacement's hash is verified. This
  # also handles Windows file locks and failures/interrupts during publication.
  expected_hash <- task8Hash(staged)
  backup <- paste0(destination, ".previous")
  if (file.exists(backup)) stop("Previous publication needs recovery: ", backup)
  had_previous <- file.exists(destination)
  if (had_previous && !file.copy(destination, backup, overwrite = FALSE)) stop("Cannot preserve previous file: ", destination)
  if (had_previous && !identical(task8Hash(backup), task8Hash(destination))) stop("Previous copy verification failed")
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
  if (!identical(task8Hash(destination), expected_hash)) stop("Published file hash mismatch: ", destination)
  published <- TRUE
  if (had_previous) unlink(backup)
  invisible(NULL)
}

task8SaveHistory <- function(path, annual, summary, settings) {
  sheets <- list(AnnualPaths = annual, SearchSummary = summary, Settings = settings)
  # openxlsx's reader coalesces consecutive line breaks in text cells. Normalize
  # display-only whitespace before writing, so real multi-log failure records
  # round-trip without weakening checks on numbers, missing values or flags.
  sheets <- lapply(sheets, function(data) {
    text_columns <- vapply(data, is.character, logical(1))
    data[text_columns] <- lapply(data[text_columns], function(x) gsub("\n{2,}", "\n", gsub("\r\n?", "\n", x)))
    data
  })
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
      openxlsx::setColWidths(wb, name, c(4, 6, 8, 9, 10, 15), 25)
      openxlsx::setColWidths(wb, name, c(22, 23), c(55, 75))
    } else {
      openxlsx::setColWidths(wb, name, 1:2, c(32, 85))
    }
    numeric_columns <- which(vapply(data, is.numeric, logical(1)))
    if (i == 1L) numeric_columns <- 5:ncol(data)
    if (i == 2L) numeric_columns <- c(4, 6, 8, 9, 10, 15, 21)
    if (nrow(data) && length(numeric_columns)) {
      openxlsx::addStyle(wb, name, openxlsx::createStyle(numFmt = "#,##0.000000"),
                         rows = 2:(nrow(data) + 1L), cols = numeric_columns, gridExpand = TRUE, stack = TRUE)
    }
  }
  staged <- tempfile(".history-", tmpdir = dirname(path), fileext = ".xlsx")
  on.exit(if (file.exists(staged)) unlink(staged), add = TRUE)
  openxlsx::saveWorkbook(wb, staged, overwrite = TRUE)
  if (!identical(openxlsx::getSheetNames(staged), names(sheets))) stop("Workbook sheet verification failed")
  for (name in names(sheets)) {
    expected <- sheets[[name]]
    actual <- openxlsx::read.xlsx(staged, sheet = name, check.names = FALSE,
                                  skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character(), sep.names = " ")
    if (!identical(names(actual), names(expected)) || nrow(actual) != nrow(expected)) {
      stop("Workbook layout verification failed: ", name)
    }
    for (j in seq_along(expected)) {
      a <- actual[[j]]; b <- expected[[j]]
      if (!identical(is.na(a), is.na(b))) stop("Workbook changed missing values: ", name)
      ok <- !is.na(b)
      if (is.numeric(b)) {
        if (any(!is.finite(as.numeric(a[ok]))) ||
            any(abs(as.numeric(a[ok]) - b[ok]) > 1e-12 * pmax(1, abs(b[ok])))) stop("Workbook changed numeric values")
      } else if (!identical(as.character(a[ok]), as.character(b[ok]))) stop("Workbook changed labels or flags")
    }
  }
  digest <- task8Hash(staged)
  task8ReplaceFile(staged, path)
  if (!identical(task8Hash(path), digest)) stop("Published workbook hash mismatch")
  digest
}

task8Cleanup <- function(path, parent, history, saved_hash) {
  if (!dir.exists(path)) return(invisible(NULL))
  link <- Sys.readlink(path)
  if ((!is.na(link) && nzchar(link)) ||
      !identical(normalizePath(dirname(path), winslash = "/"), normalizePath(parent, winslash = "/")) ||
      !grepl("^(\\.work|trial-[0-9]+)$", basename(path))) stop("Refusing to remove an unexpected directory")
  if (!file.exists(history) || !identical(task8Hash(history), saved_hash)) {
    stop("History changed or is missing; keeping temporary directory: ", path)
  }
  if (any(basename(list.files(path, recursive = TRUE, all.files = TRUE)) == "task8-process.rds")) {
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
task8ModelFiles <- function(folder) file.path(folder, c("blabla.gdx", "modelstat.txt", "main.lst",
  "outputData.gdx", "main.log", "metadata.json", "git_diff.txt"))

task8FinalModelMatches <- function(folder, result, cfg = NULL) {
  if (!file.exists(file.path(folder, "confirmation.rds"))) return(FALSE)
  tryCatch({
    record <- readRDS(file.path(folder, "confirmation.rds"))
    fields <- c("iteration", "purpose", "knot_price", "end_price", "net_zero_mtco2", "cumulative_gtco2")
    files <- task8ModelFiles(folder)
    # Existing campaigns recorded only the first three files. Reuse their
    # verified results without inventing missing outputs or forcing a new solve.
    if (identical(names(record$hashes), basename(files[1:3]))) files <- files[1:3]
    task8ValidMetrics(record$result, cfg) && record$result$purpose == "Confirmation" &&
      isTRUE(all.equal(record$result[fields], result[fields], tolerance = 1e-12)) &&
      identical(names(record$hashes), basename(files)) && all(file.exists(files)) &&
      all(file.info(files)$size > 0 | basename(files) == "git_diff.txt") &&
      identical(record$hashes, setNames(vapply(files, task8Hash, character(1)), basename(files)))
  }, error = function(e) FALSE)
}

task8SaveFinalModel <- function(trial, work, destination, result, cfg = NULL) {
  if (task8FinalModelMatches(destination, result, cfg)) return(invisible(NULL))
  if (is.null(trial)) stop("Final model files are unavailable; a fresh confirmation is required")
  files <- task8ModelFiles(trial)
  if (!task8ValidMetrics(result, cfg) || result$purpose != "Confirmation" ||
      !all(file.exists(files)) || any(file.info(files)$size <= 0 & basename(files) != "git_diff.txt") ||
      file.exists(file.path(trial, "task8-process.rds"))) stop("Incomplete confirmation files; keeping trial")
  hashes <- setNames(vapply(files, task8Hash, character(1)), basename(files))
  staged <- file.path(work, "final-model")
  dir.create(staged, showWarnings = FALSE)
  if (!all(file.copy(files, staged, overwrite = TRUE))) stop("Cannot copy final model files; keeping trial")
  saveRDS(list(result = result, hashes = hashes), file.path(staged, "confirmation.rds"))
  if (!task8FinalModelMatches(staged, result, cfg)) stop("Final model copy verification failed; keeping trial")
  artifacts <- c(basename(files), "confirmation.rds")
  previous <- file.path(destination, artifacts)
  previous <- previous[file.exists(previous)]
  backup <- tempfile("previous-final-model-", tmpdir = work)
  if (length(previous)) {
    if (!dir.create(backup) || !all(file.copy(previous, backup))) stop("Cannot preserve previous final model")
    if (!identical(unname(vapply(previous, task8Hash, character(1))),
                   unname(vapply(file.path(backup, basename(previous)), task8Hash, character(1))))) {
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
        !identical(task8Hash(source), task8Hash(target))) stop("Cannot publish final model file: ", name)
  }
  if (!task8FinalModelMatches(destination, result, cfg)) stop("Published final model verification failed; keeping trial")
  published <- TRUE
  invisible(NULL)
}

# Read old reporting/ state in place, or rename it before resuming unfinished work.
task8StateFolder <- function(campaign, migrate = FALSE) {
  current <- file.path(campaign, "calibration-state")
  legacy <- file.path(campaign, "reporting")
  links <- Sys.readlink(c(current, legacy))
  if (any(!is.na(links) & nzchar(links))) stop("Calibration state must not be a symbolic link")
  if (dir.exists(current) && dir.exists(legacy)) stop("Both calibration-state and legacy reporting exist; keeping both")
  if (!dir.exists(current) && dir.exists(legacy)) {
    if (!migrate) return(legacy)
    if (!file.rename(legacy, current)) stop("Cannot rename legacy reporting state; original retained")
  }
  current
}

# A completed archive needs no recovery state. Its Excel file keeps the model
# file inventory; older archives may have only the original three model files.
task8ValidateComplete <- function(campaign, input, cfg, accepted, model_files = NULL) {
  if (!task8Passes(accepted, cfg) || accepted$purpose != "Confirmation") stop("Invalid completed confirmation")
  expected <- basename(task8ModelFiles(campaign))
  marker <- file.path(campaign, "confirmation.rds")
  if (file.exists(marker)) {
    if (!task8FinalModelMatches(campaign, accepted, cfg)) stop("Completed model files do not match their confirmation")
    recorded <- names(readRDS(marker)$hashes)
    if (is.null(model_files)) model_files <- recorded
    if (!identical(model_files, recorded)) stop("Completed model inventory differs from the confirmation")
  }
  if (is.null(model_files)) model_files <- expected[1:3]
  if (!identical(model_files, expected) && !identical(model_files, expected[1:3])) stop("Invalid completed model inventory")
  files <- file.path(campaign, c(model_files, "calibrated-iEnvPolicies.csv",
    "reporting.mif", "emissions.csv", "plot.pdf", "Validation.pdf"))
  if (!all(file.exists(files)) || any(dir.exists(files)) ||
      any(file.info(files)$size <= 0 & basename(files) != "git_diff.txt")) {
    stop("Completed archive is missing required results; restore them or start a new campaign")
  }
  prices <- task8SelectedPrices(cfg, task8MakePrices(cfg, input, accepted$knot_price, accepted$end_price))
  if (!task8SamePrices(task8ReadPolicy(file.path(campaign, "calibrated-iEnvPolicies.csv")), prices)) {
    stop("Completed price CSV differs from the accepted Excel trial")
  }
  model_files
}

# Cleanup is last: the verified workbook must already say complete. A failed
# cleanup leaves that status intact so the next resume retries no model work.
task8CleanupState <- function(campaign, history, saved_hash, input, cfg, accepted) {
  if (!file.exists(history) || !identical(task8Hash(history), saved_hash)) stop("Completed workbook changed; keeping recovery state")
  settings <- openxlsx::read.xlsx(history, sheet = "Settings")
  status <- settings$Value[settings$Parameter == "Status"]
  inventory <- settings$Value[settings$Parameter == "Final model files"]
  if (!identical(status, "complete") || length(inventory) != 1L || is.na(inventory)) {
    stop("Save complete and the final model inventory before cleaning recovery state")
  }
  task8ValidateComplete(campaign, input, cfg, accepted, strsplit(inventory, ", ", fixed = TRUE)[[1L]])
  paths <- file.path(campaign, c("calibration-state", "reporting", "confirmation.rds"))
  links <- Sys.readlink(paths)
  if (any(!is.na(links) & nzchar(links))) stop("Refusing to clean symbolic-link recovery state")
  if (any(file.exists(paths[1:2]) & !dir.exists(paths[1:2])) || dir.exists(paths[3L])) stop("Unexpected recovery-state file types; keeping them")
  for (folder in paths[1:2]) if (dir.exists(folder)) {
    entries <- list.files(folder, all.files = TRUE, no.. = TRUE)
    allowed <- entries %in% c("reportEmissions.R", "industrial-processes.rds", "package-versions.rds", "full-report.rds") |
      grepl("^\\.full-report-", entries)
    if (any(!allowed) || any(dir.exists(file.path(folder, entries)))) stop("Unexpected calibration-state contents; keeping recovery state")
  }
  if (file.exists(file.path(campaign, "task8-process.rds"))) stop("Reporting process cleanup is incomplete; keeping recovery state")
  work <- file.path(campaign, ".work")
  if (dir.exists(work)) task8Cleanup(work, campaign, history, saved_hash)
  for (path in paths) if (file.exists(path)) {
    if (unlink(path, recursive = dir.exists(path)) != 0L || file.exists(path)) stop("Cannot clean completed recovery state: ", path)
  }
  invisible(NULL)
}

# Full reporting is separate from calibration publication. Its small completion
# record never rewrites confirmation.rds, so report failures cannot invalidate
# a saved model or require another confirmation solve. No runtime flags disable it.
task8FullReport <- function(root, campaign, env, result, cfg = NULL) {
  task8StopRetainedProcess(campaign, expected_wd = root)
  if (!task8FinalModelMatches(campaign, result, cfg)) stop("Verified confirmation files are required for full reporting")
  outputs <- file.path(campaign, c("reporting.mif", "emissions.csv", "plot.pdf", "Validation.pdf"))
  stamp <- file.path(task8StateFolder(campaign), "full-report.rds")
  signature <- function() {
    if (!all(file.exists(outputs)) || any(file.info(outputs)$size <= 0)) return(NULL)
    list(confirmation = task8Hash(file.path(campaign, "confirmation.rds")),
         outputs = setNames(vapply(outputs, task8Hash, character(1)), basename(outputs)))
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
  task8RunProcess(file.path(R.home("bin"), "Rscript"),
    c(file.path(root, "scripts/tasks/task8CalibrateGlobalCarbonPrice.R"), "--task8-report", "full", campaign),
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

task8LogExcerpt <- function(paths) {
  parts <- lapply(paths[file.exists(paths)], function(p) {
    lines <- tail(readLines(p, warn = FALSE), 40L)
    paste(basename(p), substr(paste(lines, collapse = "\n"), 1L, 11000L), sep = "\n")
  })
  if (length(parts)) substr(paste(unlist(parts), collapse = "\n\n"), 1L, 29000L) else NA_character_
}

# ---- Cross-process resume: the Excel archive is the durable search history ---
task8PackageVersions <- function() {
  packages <- c("postprom", "mrprom", "gdx", "magclass", "madrat", "quitte")
  setNames(lapply(packages, function(p) as.character(utils::packageVersion(p))), packages)
}

# Match createRunFolder(): root GAMS/CSV/JSON files, solver options and the
# data/targets/core/modules/scripts directories. Do not copy companion packages.
task8Sources <- function(root) {
  entries <- list.files(root, full.names = TRUE)
  entries[basename(entries) %in% c("data", "targets", "core", "modules", "scripts", "conopt.opt") |
            grepl("\\.(gms|csv|json)$", entries)]
}

task8Snapshot <- function(root, campaign, run_config) {
  if (!all(file.copy(task8Sources(root), campaign, recursive = TRUE))) stop("Incomplete model snapshot")
  # Keep only the reporter actually sourced by the isolated reporting worker.
  state_dir <- task8StateFolder(campaign)
  if (!dir.create(state_dir)) stop("Cannot create calibration-state directory")
  if (!file.copy(file.path(root, "postprom/R/reportEmissions.R"), state_dir)) stop("Cannot freeze emissions reporter")
  # Preserve the actual configuration, including an OPENPROM_CONFIG override.
  jsonlite::write_json(run_config, file.path(campaign, "config.json"), pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
}

task8RunSettings <- function(cfg, status, reason = NULL, accepted = NA_integer_, model_files = NULL) {
  settings <- data.frame(Parameter = c("Temperature case", "Prefix policy", "Keep input prices through", "Common price year",
    "Common price (USD2015/t CO2)", "Net-zero target year", "Budget start year", "Budget end year", "Budget (Gt CO2)",
    "Net-zero start price", "End start price", "Initial price step", "Maximum price", "Price resolution", "Maximum evaluations",
    "Net-zero tolerance (Mt CO2/yr)", "Budget tolerance (Gt CO2)",
    "Search method", "Status", "Reason", "Accepted trial"),
    Value = as.character(c(cfg$temperature_case, cfg$prefix_policy, cfg$fixed_through_year, cfg$common_year,
      cfg$common_price, if (is.null(cfg$net_zero_year)) "Not used" else cfg$net_zero_year,
      cfg$budget_start_year, cfg$end_year, cfg$budget_gtco2,
      vapply(c("net_zero_start_price", "end_start_price", "initial_price_step", "max_price", "price_resolution", "max_evaluations",
        "net_zero_tolerance_mtco2", "budget_tolerance_gtco2"), function(key) {
          if (is.null(cfg$net_zero_year) && key %in% c("net_zero_start_price", "net_zero_tolerance_mtco2")) "Not used"
          else as.character(cfg$search[[key]])
        }, character(1)),
      if (is.null(cfg$net_zero_year)) "Budget-only emissions refinement" else "Two-stage emissions refinement",
      status, if (is.null(reason)) NA_character_ else reason, accepted)), row.names = NULL)
  if (!is.null(model_files)) settings <- rbind(settings,
    data.frame(Parameter = "Final model files", Value = paste(model_files, collapse = ", ")))
  settings
}

task8Flags <- function(flags, cfg) {
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

task8ReportFromRows <- function(cfg, rows, metrics) {
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
  task8ValidateReport(cfg, report)
  report
}

task8ReadHistory <- function(path, input, regions, run_config = NULL) {
  if (!file.exists(path)) stop("No calibration-history.xlsx in resume_from")
  sheet_names <- openxlsx::getSheetNames(path)
  if (!identical(sheet_names, c("AnnualPaths", "SearchSummary", "Settings"))) stop("Not an English Task 8 archive")
  read <- function(sheet) openxlsx::read.xlsx(path, sheet = sheet, check.names = FALSE, sep.names = " ",
    skipEmptyRows = FALSE, skipEmptyCols = FALSE, na.strings = character())
  annual <- read("AnnualPaths"); summary <- read("SearchSummary"); settings <- read("Settings")
  if (!identical(names(settings), c("Parameter", "Value"))) stop("Invalid settings sheet")
  if (is.null(run_config)) run_config <- jsonlite::read_json(file.path(dirname(path), "config.json"), simplifyVector = FALSE)
  raw_cfg <- run_config$global_carbon_price_calibration
  # Old snapshots retain removed controls; ignore them without changing targets or trials.
  raw_cfg$search[c("max_net_zero_refinements", "max_tail_refinements",
                   "trial_timeout_seconds", "campaign_timeout_seconds")] <- NULL
  cfg <- task8Setup(raw_cfg, input, regions)
  if (!identical(names(summary), names(task8Summary(list(), cfg))) ||
      !identical(names(annual), names(task8AnnualRows(cfg, 0L)))) stop("Invalid archive columns")
  ids <- summary$Trial
  if (anyNA(ids) || anyDuplicated(ids) || any(ids != seq_along(ids))) stop("Expected consecutive trial numbers starting at 1")
  if (nrow(annual) != length(ids) * (2L * length(regions) + 1L) ||
      !setequal(annual$Trial, ids)) stop("Incomplete archived trial paths")
  trials <- list(); annual_rows <- list()
  for (i in seq_along(ids)) {
    s <- summary[i, ]; rows <- annual[annual$Trial == i, , drop = FALSE]
    annual_identity <- if (is.null(cfg$net_zero_year)) {
      all(is.na(c(s$NetZeroYear, s[["NetZeroPrice (USD2015/t CO2)"]], s[["NetZeroYearCO2 (Mt CO2/yr)"]], s$NetZeroMet)))
    } else !is.na(s$NetZeroYear) && s$NetZeroYear == cfg$net_zero_year
    if (!s$Stage %in% c("Search", "Confirmation") || is.na(s$ValidRun) || !annual_identity || s$EndYear != cfg$end_year ||
        s[["Budget (Gt CO2)"]] != cfg$budget_gtco2) stop("Invalid archived trial identity")
    a <- list(iteration = as.integer(i), purpose = s$Stage, valid = isTRUE(s$ValidRun),
      knot_price = if (is.null(cfg$net_zero_year)) NA_real_ else s[["NetZeroPrice (USD2015/t CO2)"]],
      end_price = s[["EndPrice (USD2015/t CO2)"]],
      elapsed_seconds = s[["ElapsedSeconds"]])
    fields <- c(net_zero_mtco2 = "NetZeroYearCO2 (Mt CO2/yr)", cumulative_gtco2 = "CumulativeCO2 (Gt CO2)",
      peak_cumulative_gtco2 = "PeakCumulativeCO2 (Gt CO2)", peak_year = "PeakYear", first_nonpositive_year = "FirstNonpositiveYear",
      reason = "FailureReason", log_excerpt = "LogExcerpt")
    for (field in names(fields)) if (!is.na(s[[fields[[field]]]])) a[[field]] <- s[[fields[[field]]]]
    if (is.null(cfg$net_zero_year)) a$net_zero_mtco2 <- NA_real_
    if (!is.na(s$LaterPositiveYears)) a$later_positive_years <- as.integer(strsplit(s$LaterPositiveYears, ",\\s*")[[1L]])
    if (!is.na(s$NormalRegionYears)) a$solves <- list(final_region_years = s$NormalRegionYears, solver_attempts = s$SolverAttempts)
    # Rebuild the actual full input, not just the two stored anchor values.
    prices <- task8MakePrices(cfg, input, a$knot_price, a$end_price)
    expected <- task8AnnualRows(cfg, i, prices)
    recorded <- rows[rows$Metric == "Carbon price", , drop = FALSE]
    recorded <- recorded[match(regions, recorded$Region), , drop = FALSE]
    expected <- expected[seq_along(regions), , drop = FALSE]
    if (nrow(recorded) != length(regions) || anyNA(recorded$Region) || anyDuplicated(recorded$Region)) stop("Incomplete archived prices")
    if (isTRUE(a$valid) || any(!is.na(recorded[, as.character(2010:2100)]))) {
      if (any(recorded$Unit != "USD2015/t CO2") ||
          !isTRUE(all.equal(as.matrix(recorded[, as.character(2010:2100)]),
                           as.matrix(expected[, as.character(2010:2100)]), check.attributes = FALSE, tolerance = 1e-12))) {
        stop("Archived annual prices differ from the frozen path settings")
      }
    }
    if (isTRUE(a$valid)) {
      task8ReportFromRows(cfg, rows, a)
      expected_solves <- length(regions) * (cfg$end_year - 2024 + 1L)
      annual_matches <- if (is.null(cfg$net_zero_year)) is.na(s$NetZeroMet) else
        !is.na(s$NetZeroMet) && s$NetZeroMet == (a$net_zero_mtco2 <= 0)
      if (is.null(a$solves) || a$solves$final_region_years != expected_solves ||
          !is.finite(a$solves$solver_attempts) || a$solves$solver_attempts < expected_solves ||
          !annual_matches || is.na(s$BudgetMet) || is.na(s$BothMet) ||
          s$BudgetMet != (a$cumulative_gtco2 <= cfg$budget_gtco2) ||
          s$BothMet != task8Passes(a, cfg)) stop("Archived solve/target checks do not match the stored results")
    }
    trials[[i]] <- a; annual_rows[[i]] <- rows
  }
  list(cfg = cfg, settings = settings, trials = trials, annual_rows = annual_rows,
       accepted = which(summary$Accepted %in% TRUE))
}

# Start prices and jump step stay frozen with the campaign. Only the total
# evaluation cap and accuracy controls may change on resume.
task8ResumeSearch <- function(cfg, requested) {
  integer_keys <- "max_evaluations"
  for (key in c(integer_keys, "net_zero_tolerance_mtco2", "budget_tolerance_gtco2", "price_resolution")) {
    value <- requested$search[[key]]
    if (!is.null(value)) {
      task8Number(value, key, 0, integer = key %in% integer_keys)
      cfg$search[[key]] <- value
    }
  }
  cfg
}

task8ReadRegions <- function(campaign) {
  sets <- paste(readLines(file.path(campaign, "core/sets.gms"), warn = FALSE), collapse = "\n")
  block <- regmatches(sets, regexec('(?s)resCy\\s+"[^"]*"\\s*/(.*?)/', sets, perl = TRUE))[[1L]]
  if (length(block) != 2L) stop("Cannot read research regions")
  regions <- strsplit(trimws(block[2L]), "\\s+", perl = TRUE)[[1L]]
  if (length(regions) != 39L) stop("This version requires all 39 research regions")
  regions
}

task8TrialFolders <- function(work) {
  folders <- list.dirs(work, recursive = FALSE, full.names = TRUE)
  folders <- folders[grepl("^trial-[0-9]+$", basename(folders))]
  folders[order(as.integer(sub("trial-", "", basename(folders))))]
}

# ---- Task entry point: setup, resume, evaluate, checkpoint and export ---------
runTask8 <- function() {
  root <- normalizePath(getwd(), winslash = "/")
  options <- task8Options(config$global_carbon_price_calibration, commandArgs(trailingOnly = TRUE))
  resuming <- !is.null(options$resume_from)
  for (p in c("openxlsx", "filelock")) if (!requireNamespace(p, quietly = TRUE)) stop("Task 8 requires the R package ", p)
  if (resuming) {
    campaign <- normalizePath(path.expand(options$resume_from), winslash = "/", mustWork = TRUE)
    if (!dir.exists(campaign)) stop("resume_from must be a campaign directory")
  } else {
    task8ValidateConfig(config$global_carbon_price_calibration)
    dir.create(file.path(root, "runs"), showWarnings = FALSE)
    campaign <- file.path(root, "runs", paste0("calibrate-global-carbon-price-",
      Sys.getpid(), "_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S")))
    if (!dir.create(campaign)) stop("Cannot create a fresh calibration directory")
  }
  lock_path <- file.path(dirname(tempdir()), paste0("openprom-task8-", digest::digest(campaign, algo = "sha256"), ".lock"))
  # Reject concurrent writers immediately; this is not a run-time limit.
  lock <- filelock::lock(lock_path, timeout = 0)
  if (is.null(lock)) stop("This calibration is already running: ", campaign)
  on.exit(filelock::unlock(lock), add = TRUE)
  if (resuming) task8StopRetainedProcess(campaign, expected_wd = root)
  if (!resuming) task8Snapshot(root, campaign, config)
  config_path <- file.path(campaign, "config.json")
  config_source <- config_path
  if ((!file.exists(config_path) && !file.exists(paste0(config_path, ".previous"))) ||
      !file.exists(file.path(campaign, "data/iEnvPolicies.csv"))) {
    stop("This old campaign has no retained model snapshot; restore it before resuming")
  }
  run_config <- tryCatch(jsonlite::read_json(config_path, simplifyVector = FALSE), error = function(e) {
    backup <- paste0(config_path, ".previous")
    if (!resuming || !file.exists(backup)) stop(e)
    message("Reading the retained previous campaign configuration")
    config_source <<- backup
    jsonlite::read_json(backup, simplifyVector = FALSE)
  })
  input <- task8ReadPolicy(file.path(campaign, "data/iEnvPolicies.csv"))
  regions <- task8ReadRegions(campaign)
  history <- file.path(campaign, "calibration-history.xlsx"); work <- file.path(campaign, ".work")
  archive_source <- history; saved_history <- NULL; completed <- FALSE
  trials <- list(); annual_rows <- list()
  if (resuming) {
    saved_history <- tryCatch(task8ReadHistory(history, input, regions, run_config), error = function(e) {
      backup <- paste0(history, ".previous")
      if (!file.exists(backup)) stop(e)
      message("Reading the retained previous workbook after: ", conditionMessage(e))
      archive_source <<- backup
      task8ReadHistory(backup, input, regions, run_config)
    })
    cfg <- saved_history$cfg; trials <- saved_history$trials; annual_rows <- saved_history$annual_rows
    status <- saved_history$settings$Value[saved_history$settings$Parameter == "Status"]
    completed <- identical(status, "complete")
    # Saved mode, targets and input files stay fixed, including maturity_factors.
    # Only unfinished campaigns accept search-control changes. Completed archives
    # return their saved result; changed targets or accuracy need a new campaign.
    if (!completed) {
      cfg <- task8ResumeSearch(cfg, config$global_carbon_price_calibration)
      checked <- run_config$global_carbon_price_calibration
      checked$search <- cfg$search
      task8ValidateConfig(checked)
    }
    if (length(saved_history$accepted) == 1L) {
      a <- trials[[saved_history$accepted]]
      final <- file.path(campaign, "calibrated-iEnvPolicies.csv")
      wanted <- task8SelectedPrices(cfg, task8MakePrices(cfg, input, a$knot_price, a$end_price))
      if (a$purpose != "Confirmation" || !task8Passes(a, cfg)) stop("Invalid archived confirmation")
      if (file.exists(final)) {
        if (!task8SamePrices(task8ReadPolicy(final), wanted)) stop("Final CSV differs from the archived confirmation")
      }
    }
  } else cfg <- task8Setup(run_config$global_carbon_price_calibration, input, regions)
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
      if (!file.copy(source, retained) || !identical(task8Hash(source), task8Hash(retained))) {
        stop("Cannot retain interrupted publication: ", source)
      }
    }
    if (identical(entry$source, backup) &&
        (!file.copy(backup, entry$path, overwrite = TRUE) ||
         !identical(task8Hash(backup), task8Hash(entry$path)))) stop("Cannot restore previous publication: ", entry$path)
    if (unlink(backup) != 0L) stop("Cannot release retained publication backup: ", backup)
  }
  if (completed) {
    if (length(saved_history$accepted) != 1L) stop("Completed archive has no single accepted confirmation")
    accepted <- trials[[saved_history$accepted]]
    inventory <- saved_history$settings$Value[saved_history$settings$Parameter == "Final model files"]
    if (length(inventory) > 1L || anyNA(inventory)) stop("Invalid completed model inventory")
    model_files <- task8ValidateComplete(campaign, input, cfg, accepted,
      if (length(inventory)) strsplit(inventory, ", ", fixed = TRUE)[[1L]] else NULL)
    saved <- task8Hash(history)
    if (!length(inventory)) {
      # Upgrade only the inventory of an old complete archive before deleting its
      # old recovery files. Trial values and the accepted result stay unchanged.
      settings <- rbind(saved_history$settings,
        data.frame(Parameter = "Final model files", Value = paste(model_files, collapse = ", ")))
      saved <- task8SaveHistory(history, do.call(rbind, annual_rows),
        task8Summary(trials, cfg, saved_history$accepted), settings)
    }
    task8CleanupState(campaign, history, saved, input, cfg, accepted)
    message("Calibration already complete; returning saved results: ", campaign)
    return(invisible(campaign))
  }
  task8StateFolder(campaign, migrate = TRUE)
  flags <- task8Flags(run_config$scenario$gams_flags, cfg)
  process_env <- task8ProcessEnvironment(run_config, campaign)
  if (cfg$search$max_evaluations * (2L * length(regions) + 1L) >= 1048576L) stop("max_evaluations exceeds Excel capacity")
  pending_trial <- NULL; pending_export <- FALSE
  cache <- new.env(parent = emptyenv())
  price_key <- function(k, e) paste(sprintf("%.12g", c(k, e)), collapse = ":")
  remember <- function(a) if (isTRUE(a$valid) && a$purpose == "Search") cache[[price_key(a$knot_price, a$end_price)]] <- a
  for (a in trials) remember(a)
  persistence_error <- function(e) stop(structure(list(message = paste0("Result persistence/cleanup failed: ", conditionMessage(e),
    ". Temporary results retained at ", work), call = NULL), class = c("task8_persistence_error", "error", "condition")))
  checkpoint <- function(status = "running", reason = NULL, accepted_iteration = NA_integer_, model_files = NULL) tryCatch({
    annual <- if (length(annual_rows)) do.call(rbind, annual_rows) else task8AnnualRows(cfg, 0L)[FALSE, ]
    current <- task8RunSettings(cfg, status, reason, accepted_iteration, model_files)
    task8SaveHistory(history, annual, task8Summary(trials, cfg, accepted_iteration), current)
  }, error = persistence_error, interrupt = persistence_error)
  clean <- function(path, parent, saved) tryCatch({
    force(saved) # Finish checkpoint publication before reading its hash again.
    task8Cleanup(path, parent, history, saved)
  }, error = persistence_error, interrupt = persistence_error)
  final_model <- campaign
  confirmation_folder <- function(a) {
    folders <- task8TrialFolders(work)
    folder <- folders[as.integer(sub("trial-", "", basename(folders))) == a$iteration]
    if (length(folder) != 1L) return(NULL)
    files <- task8ModelFiles(folder)
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
        if (!task8Passes(accepted, cfg)) stop("Cannot export an unverified price path")
        prices <- task8MakePrices(cfg, input, accepted$knot_price, accepted$end_price)
        staged <- file.path(work, "calibrated-iEnvPolicies.csv")
        task8WritePrices(staged, task8SelectedPrices(cfg, prices))
      }, error = persistence_error, interrupt = persistence_error)
    }
    saved <- checkpoint(if (is.null(accepted)) status else "finalizing", reason, chosen)
    if (!is.null(accepted)) tryCatch(
      task8SaveFinalModel(confirmation_folder(accepted), work, final_model, accepted, cfg),
      error = persistence_error, interrupt = persistence_error)
    if (!is.null(staged)) {
      failed_export <- function(e) { checkpoint("export_failed", conditionMessage(e), chosen); persistence_error(e) }
      tryCatch(task8ReplaceFile(staged, file.path(campaign, "calibrated-iEnvPolicies.csv")), error = failed_export, interrupt = failed_export)
      saved <- checkpoint(status, reason, chosen)
      pending_export <<- FALSE
    }
    # Valid confirmations stay on disk until the selected result is published,
    # or until a saved failure/unfinished status makes them intermediate trials.
    for (folder in task8TrialFolders(work)) {
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
      for (folder in c(work, task8TrialFolders(work))) tryCatch(task8StopRetainedProcess(folder),
        error = persistence_error, interrupt = persistence_error)
      # A failed/interrupted report must not replay search or spend model calls.
      # Changed accuracy settings still return to the normal calibration path.
      status <- saved_history$settings$Value[saved_history$settings$Parameter == "Status"]
      accuracy <- c("net_zero_tolerance_mtco2", "budget_tolerance_gtco2", "price_resolution")
      if (length(status) == 1L && status %in% c("postprocessing", "postprocessing_failed") &&
          length(saved_history$accepted) == 1L &&
          identical(cfg$search[accuracy], saved_history$cfg$search[accuracy]) &&
          !length(list.files(work, all.files = TRUE, no.. = TRUE))) {
        a <- trials[[saved_history$accepted]]
        if (file.exists(file.path(campaign, "calibrated-iEnvPolicies.csv")) && task8FinalModelMatches(campaign, a, cfg)) {
          message("Calibration already verified; resuming full reporting only")
          return(list(status = "verified", reason = "Saved calibration verified; reporting resumed",
                      accepted = a, reporting_only = TRUE))
        }
      }
    }
    saveRDS(cfg, file.path(work, "config.rds"))
    worker <- file.path(root, "scripts/tasks/task8CalibrateGlobalCarbonPrice.R")
    rscript <- file.path(R.home("bin"), "Rscript")
    state_dir <- task8StateFolder(campaign)
    if (!file.exists(file.path(state_dir, "package-versions.rds"))) {
      dir.create(state_dir, showWarnings = FALSE)
      # Older campaigns kept the reporter inside a full postprom snapshot.
      if (!file.exists(file.path(state_dir, "reportEmissions.R")) &&
          !file.copy(file.path(campaign, "postprom/R/reportEmissions.R"), state_dir)) stop("Cannot freeze reporter")
      task8RunProcess(rscript, c(worker, "--task8-report", "freeze", work), work, file.path(work, "freeze-reporting.log"), env = process_env)
    }
    if (!identical(task8PackageVersions(), readRDS(file.path(state_dir, "package-versions.rds")))) stop("Reporting package versions changed")
    checkpoint()
    # Keep the controller and search settings actually used by this invocation
    # with the permanent snapshot; no model/input/physical-target changes.
    if (resuming) {
      run_config$global_carbon_price_calibration$search <- cfg$search
      staged_config <- file.path(work, "updated-config.json")
      jsonlite::write_json(run_config, staged_config, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
      task8ReplaceFile(staged_config, file.path(campaign, "config.json"))
      if (!file.copy(worker, file.path(campaign, "scripts/tasks/task8CalibrateGlobalCarbonPrice.R"), overwrite = TRUE)) stop("Cannot retain updated controller")
      final <- file.path(campaign, "calibrated-iEnvPolicies.csv")
      previous <- tempfile("previously-calibrated-", tmpdir = work, fileext = ".csv")
      if (file.exists(final) && !file.rename(final, previous)) stop("Cannot retire previous export during refinement")
    }
    report_trial <- function(trial, result) {
      tryCatch({
        result$solves <- task8CheckSolves(trial, regions, 2024:cfg$end_year)
        task8RunProcess(rscript, c(worker, "--task8-report", "evaluate", work, trial), trial, file.path(trial, "report.log"), env = process_env)
        report <- readRDS(file.path(trial, "report.rds"))
        result <- modifyList(result, report$metrics, keep.null = TRUE)
        if (!task8ValidMetrics(result, cfg)) stop("Invalid reported metrics")
        list(result = result, report = report)
      }, error = function(e) list(result = modifyList(result,
        list(valid = FALSE, reason = conditionMessage(e))), report = NULL))
    }
    archive <- function(trial, result, prices, report = NULL) {
      if (!isTRUE(result$valid)) { report <- NULL; result$log_excerpt <- task8LogExcerpt(file.path(trial, c("gams.log", "report.log"))) }
      saveRDS(result, file.path(trial, "outcome.rds"))
      index <- result$iteration
      trials[[index]] <<- result
      tryCatch(annual_rows[[index]] <<- task8AnnualRows(cfg, index, prices, report), error = persistence_error, interrupt = persistence_error)
      saved <- checkpoint()
      if (isTRUE(result$valid) && result$purpose == "Confirmation") {
        message("Retaining confirmation trial ", index, " until final publication")
      } else {
        clean(trial, work, saved)
        pending_trial <<- NULL
      }
      remember(result)
      if (isTRUE(result$valid)) {
        if (is.null(cfg$net_zero_year)) message(sprintf("  cumulative=%.4f Gt; budget met=%s",
          result$cumulative_gtco2, task8Passes(result, cfg)))
        else message(sprintf("  net CO2=%.4f Mt; cumulative=%.4f Gt; both met=%s",
          result$net_zero_mtco2, result$cumulative_gtco2, task8Passes(result, cfg)))
      }
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
    for (trial in task8TrialFolders(work)) {
      pending_trial <<- trial
      index <- as.integer(sub("trial-", "", basename(trial)))
      if (index > length(trials) + 1L) stop("Gap in retained trial numbers; preserving work")
      outcome <- file.path(trial, "outcome.rds"); request <- file.path(trial, "request.rds")
      read_record <- function(path) if (file.exists(path)) tryCatch(readRDS(path), error = function(e) NULL) else NULL
      a <- read_record(outcome)
      if (is.null(a)) a <- read_record(request)
      price_file <- file.path(trial, "data/iEnvPolicies.csv")
      existing <- if (file.exists(price_file)) tryCatch(task8ReadPolicy(price_file), error = function(e) NULL) else NULL
      if (is.null(a) && !is.null(existing)) {
        row <- task8PolicyRow(existing, regions[1L], cfg$policy)
        a <- list(iteration = index, purpose = "Search",
                  knot_price = if (is.null(cfg$net_zero_year)) NA_real_ else as.numeric(existing[row, as.character(cfg$net_zero_year)]),
                  end_price = as.numeric(existing[row, as.character(cfg$end_year)]))
      }
      if (is.null(a)) {
        message("Clearing incomplete trial ", index, " before restart")
        clean(trial, work, discard_from(index)); pending_trial <<- NULL
        next
      }
      if (a$iteration != index) stop("Retained trial number mismatch; keeping work")
      prices <- task8MakePrices(cfg, input, a$knot_price, a$end_price)
      if (index <= length(trials) && isTRUE(trials[[index]]$valid)) {
        if (is.null(existing) || !task8SamePrices(existing, prices)) stop("Retained prices do not match the completed trial")
        if (trials[[index]]$purpose == "Confirmation") {
          message("Keeping archived confirmation trial ", index, " for final publication")
        } else {
          message("Cleaning already archived trial ", index)
          clean(trial, work, checkpoint()); pending_trial <<- NULL
        }
        next
      }
      if (index <= length(trials) &&
          (!isTRUE(all.equal(a$knot_price, trials[[index]]$knot_price, tolerance = 0)) ||
           a$end_price != trials[[index]]$end_price)) stop("Retained trial anchors changed")
      if (is.null(existing) || !task8SamePrices(existing, prices)) {
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
    evaluate <- function(knot, end, confirmation = FALSE) {
      key <- price_key(knot, end)
      if (!confirmation && exists(key, cache, inherits = FALSE)) {
        message("Reusing saved trial ", cache[[key]]$iteration, ": ", key)
        return(cache[[key]])
      }
      limit <- cfg$search$max_evaluations - if (confirmation) 0L else 1L
      if (length(trials) >= limit) stop(structure(list(message = "evaluation_budget_exhausted; increase search.max_evaluations to resume", call = NULL),
        class = c("task8_evaluation_limit", "error", "condition")))
      index <- length(trials) + 1L
      trial <- file.path(work, sprintf("trial-%03d", index))
      if (!dir.create(trial)) stop("Cannot create a fresh trial directory")
      pending_trial <<- trial
      trial_start <- proc.time()[["elapsed"]]
      prices <- NULL; report <- NULL; interrupted <- FALSE
      result <- list(iteration = index, valid = FALSE, knot_price = knot, end_price = end,
                     purpose = if (confirmation) "Confirmation" else "Search")
      saveRDS(result, file.path(trial, "request.rds"))
      result <- tryCatch({
        prices <- task8MakePrices(cfg, input, knot, end)
        if (!all(file.copy(task8Sources(campaign), trial, recursive = TRUE))) stop("Incomplete trial snapshot")
        task8WritePrices(file.path(trial, "data/iEnvPolicies.csv"), prices)
        if (confirmation) {
          # Use the shared research metadata writer once, immediately before
          # confirmation. Git metadata describes the repository at this point;
          # the model and inputs still come from the saved campaign snapshot.
          task8SaveMetadata(root, trial)
        }
        if (is.null(cfg$net_zero_year)) message(sprintf("Trial %d: P%d=%.4f (budget only)", index, cfg$end_year, end))
        else message(sprintf("Trial %d: P%d=%.4f, P%d=%.4f", index, cfg$net_zero_year, knot, cfg$end_year, end))
        # Research mode uses log option 4: keep the final native main.log too.
        trial_args <- if (confirmation) sub("^lo=3$", "lo=4", gams_args) else gams_args
        task8RunProcess(gams, trial_args, trial, file.path(trial, "gams.log"), env = process_env)
        reported <- report_trial(trial, result)
        report <- reported$report
        reported$result
      }, error = function(e) modifyList(result, list(valid = FALSE, reason = conditionMessage(e))),
         interrupt = function(e) { interrupted <<- TRUE; modifyList(result, list(valid = FALSE, reason = "interrupted")) })
      result$elapsed_seconds <- proc.time()[["elapsed"]] - trial_start
      archive(trial, result, prices, report)
      if (interrupted) stop(structure(list(message = "interrupted", call = NULL), class = c("task8_interrupted", "error", "condition")))
      result
    }
    accepted <- task8Search(cfg, evaluate)
    confirmations <- Filter(function(a) a$purpose == "Confirmation" && a$iteration != accepted$iteration &&
      task8Passes(a, cfg) && isTRUE(all.equal(a$knot_price, accepted$knot_price, tolerance = 0)) && a$end_price == accepted$end_price &&
      (task8FinalModelMatches(final_model, a, cfg) || !is.null(confirmation_folder(a))), trials)
    confirmation <- if (length(confirmations)) tail(confirmations, 1L)[[1L]] else evaluate(accepted$knot_price, accepted$end_price, confirmation = TRUE)
    if (!task8Passes(confirmation, cfg)) return(finish("confirmation_failed", reason = "Independent confirmation failed"))
    # Confirmation must also preserve each accuracy band attained in search.
    annual_tight <- !is.null(cfg$net_zero_year) && accepted$net_zero_mtco2 >= -cfg$search$net_zero_tolerance_mtco2
    budget_tight <- accepted$cumulative_gtco2 >= cfg$budget_gtco2 - cfg$search$budget_tolerance_gtco2
    if ((annual_tight && confirmation$net_zero_mtco2 < -cfg$search$net_zero_tolerance_mtco2) ||
        (budget_tight && confirmation$cumulative_gtco2 < cfg$budget_gtco2 - cfg$search$budget_tolerance_gtco2)) {
      return(finish("confirmation_failed", reason = "Independent confirmation is outside the calibrated emissions tolerances"))
    }
    finish("verified", confirmation, accepted$calibration_note)
  }
  result <- tryCatch(run(), task8_persistence_error = function(e) list(status = "persistence_failed", reason = conditionMessage(e)),
    task8_interrupted = function(e) finish("interrupted", reason = "interrupted"),
    interrupt = function(e) finish("interrupted", reason = "interrupted"),
    error = function(e) finish("unfinished", reason = conditionMessage(e)))
  message("Calibrate Global Carbon Price (Task 8): ", history)
  if (result$status != "verified") stop(result$status, ": ", result$reason)
  # Always produce the final research report, independently of behavior.withReport.
  # Keep accepted calibration and its CSV/GDX intact if reporting or LaTeX fails.
  saved <- checkpoint("postprocessing", result$reason, result$accepted$iteration)
  report_error <- tryCatch({
    if (isTRUE(result$reporting_only)) {
      run_config$global_carbon_price_calibration$search <- cfg$search
      staged_config <- file.path(work, "updated-config.json")
      jsonlite::write_json(run_config, staged_config, pretty = TRUE, auto_unbox = TRUE, null = "null", digits = NA)
      task8ReplaceFile(staged_config, config_path)
    }
    if (!file.copy(file.path(root, "scripts/tasks/task8CalibrateGlobalCarbonPrice.R"),
                   file.path(campaign, "scripts/tasks/task8CalibrateGlobalCarbonPrice.R"), overwrite = TRUE)) {
      stop("Cannot retain updated reporting controller")
    }
    task8FullReport(root, campaign, process_env, result$accepted, cfg)
    task8ValidateComplete(campaign, input, cfg, result$accepted)
    NULL
  }, error = function(e) conditionMessage(e), interrupt = function(e) "Full reporting interrupted")
  saved <- checkpoint(if (is.null(report_error)) "complete" else "postprocessing_failed",
    if (is.null(report_error)) result$reason else report_error, result$accepted$iteration,
    if (is.null(report_error)) names(readRDS(file.path(campaign, "confirmation.rds"))$hashes) else NULL)
  if (dir.exists(work) && !length(list.files(work, all.files = TRUE, no.. = TRUE))) clean(work, campaign, saved)
  if (!is.null(report_error)) stop("Calibration verified; full reporting incomplete: ", report_error,
    ". Resume with resume_from=\"", campaign, "\" to retry reporting without another model solve.")
  task8CleanupState(campaign, history, saved, input, cfg, result$accepted)
  invisible(campaign)
}

# ---- Reporting worker: same file, isolated R process -------------------------
task8Report <- function(mode, work, trial = NULL) {
  work <- normalizePath(work, mustWork = TRUE)
  folder <- task8StateFolder(if (mode == "full") work else dirname(work))
  versions <- task8PackageVersions()
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
  metric <- "Emissions|CO2.Mt CO2/yr"
  if (!metric %in% magclass::getNames(report)) stop("Missing global net CO2 metric")
  annual <- grid(report[,,metric],regions,report_years)
  world <- aggregate(value ~ year,annual,sum)
  world <- world[order(world$year),]
  names(world)[2L] <- "emissions_mtco2"
  budget_years <- world$year >= cfg$budget_start_year
  world$cumulative_gtco2 <- NA_real_
  world$cumulative_gtco2[budget_years] <- cumsum(world$emissions_mtco2[budget_years])/1000
  net <- if (is.null(cfg$net_zero_year)) NA_real_ else world$emissions_mtco2[world$year==cfg$net_zero_year]
  cumulative <- tail(world$cumulative_gtco2,1L)
  peak <- which.max(world$cumulative_gtco2)
  first <- world$year[budget_years & world$emissions_mtco2<=0]
  result <- list(valid=TRUE,net_zero_mtco2=net,cumulative_gtco2=cumulative,
    net_zero_met=if (is.null(cfg$net_zero_year)) NA else net<=0,budget_met=cumulative<=cfg$budget_gtco2,
    budget_gap_gtco2=cumulative-cfg$budget_gtco2,
    peak_cumulative_gtco2=world$cumulative_gtco2[peak],peak_year=world$year[peak],
    first_nonpositive_year=if(length(first)) min(first) else NULL,
    later_positive_years=I(if (is.null(cfg$net_zero_year)) integer() else
      world$year[world$year>cfg$net_zero_year & world$emissions_mtco2>0]),
    accounting="postprom net CO2 including energy, industrial processes, AFOLU and bunkers")
  saveRDS(list(metrics = result, annual = annual, world = world), file.path(trial, "report.rds"))
}

# Sourcing from start.R only defines functions. Direct execution is reserved for
# the reporting subprocess; model runs always enter through start.R.
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (!length(args) || args[1L] != "--task8-report" ||
      !((length(args) == 3L && args[2L] %in% c("freeze", "full")) ||
        (length(args) == 4L && args[2L] == "evaluate"))) {
    stop("Run with Rscript start.R task_id=8")
  }
  task8Report(args[2L], args[3L], if (length(args) == 4L) args[4L] else NULL)
}
