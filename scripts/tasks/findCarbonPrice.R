# ============================================================
# Carbon Price Optimization to Reach Emissions Targets
# ============================================================

# This script calibrates carbon prices in the OPEN-PROM model so that simulated
# emissions match user-defined budget targets for any combination of regions,
# the EU27 block, or the entire world.
#
# The script perturbs the carbon price trajectory in `data/iEnvPolicies.csv`
# by applying a scalar adjustment factor (alpha) and repeatedly runs OPEN-PROM
# through GAMS until the resulting emissions converge to each target.
#
# Core workflow:
# 1) Read the baseline policy file (`iEnvPolicies.csv`).
# 2) Multiply carbon price values from `changeCarbonPriceFromYear` onward by (1 + alpha).
# 3) Execute OPEN-PROM via GAMS.
# 4) Post-process model outputs via `reportEmissions` (postprom/gdx) to extract
#    the tracked emissions variable, scaled to the unit of the budget targets.
# 5) Iteratively adjust alpha until emissions meet the target using:
#      • automatic bracketing around a seed alpha
#      • regula falsi (false-position) root-finding, with bisection fallback on stall
# 6) Repeat sequentially for each entry in `targetList`, carrying forward the
#    updated policy file so each region builds on previously optimized prices.
#
# Solve modes (controlled by keys in `targetList`):
# • Single region  – alpha applied to that region’s rows only; fCountries in
#                    main.gms is updated so OPEN-PROM solves only that region.
# • "EU27"         – alpha applied identically to all 27 EU member rows, which
#                    share a single carbon price; emissions summed across members.
#                    main.gms is NOT modified (all regions must run).
# • "WORLD"        – alpha applied to all region rows; emissions summed globally.
#                    main.gms is NOT modified.
#
# Emissions variable:
# • Controlled by `emissionsVariable` and `emissionsScale` in the Run section.
# • Any variable name returned by reportEmissions() can be used.
# • `emissionsScale` converts the raw variable unit to match the budget targets.
#
# Dependencies:
#   data.table, dplyr, tidyr, gdx, postprom, mrprom, quitte, stringr
#   and a working GAMS installation accessible via the `gams` command.
#
# Typical usage:
# 1) Set `emissionsVariable` and `emissionsScale` to match the budget unit.
# 2) Set `selectedYear` and `changeCarbonPriceFromYear`.
# 3) Populate `targetList` with region keys and budget values.
#    Use "EU27" for the EU block and "WORLD" for a global run.
# 4) Ensure `data/iEnvPolicies.csv` and `main.gms` exist and run the script.
#
# Output:
# • Updated carbon price trajectory written to `data/iEnvPolicies.csv` and
#   `data/iEnvPolicies_updated.csv` (plus a timestamped copy).
# • Execution log stored in `Carbon_price_optimization.log`.
#
# Parameterisation (set by `parameterisation` in the Run section):
# • "scale"  – the solved parameter is a multiplier alpha applied to the existing curve:
#                  new_price(t) = old_price(t) * (1 + alpha),  t >= fromYear
#              Alpha < 0 decreases prices; alpha > 0 increases them. Preserves the shape of
#              the source trajectory, including any terminal plateau baked into it.
# • "growth" – the solved parameter is an annual growth rate r, and the forward path is
#              rebuilt as a Hotelling-style geometric curve anchored on the price already in
#              the file for `fromYear`:
#                  new_price(t) = price(fromYear) * (1 + r)^(t - fromYear),  t > fromYear
#              Years up to and including fromYear are left untouched, so near-term prices stay
#              consistent with enacted policy. Each region keeps its own anchor level, so
#              regional differentiation in the source data survives; only r is solved for.
#              Prices are capped at `carbonPriceCap` after compounding.
#
# Prefer "growth" when the target is a *cumulative* budget: a cumulative budget is an integral
# over time, so when abatement happens matters as much as the price level, and a single scalar
# on a curve that already flattens late in the century gives very little terminal leverage.
#
# Notes:
# • Only the one policy row the active scenario reads (see SCENARIO_POLICY_ROW) is modified;
#   the other scenarios' price paths and the non-price EFF/OPT/REN/TRADE rows are left alone.
# • Sequential runs update the policy file cumulatively so each region’s
#   optimization builds on the prices already set for previous regions.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)    # for as_tibble() via tibble dependency
  library(tidyr)
  library(gdx)
  library(postprom)
  library(mrprom)
  library(quitte)   # provides interpolate_missing_periods used by reportEmissions
  library(stringr)
})

# ----------------------------
# Paths
# ----------------------------
inputCsvPath   <- "data/iEnvPolicies.csv"
outputCsvPath  <- "data/iEnvPolicies_updated.csv"
backupCsvPath  <- "data/iEnvPolicies_backup.csv"
lastTestedCsvPath <- "data/iEnvPolicies_last_tested.csv" # last policy tested before a failure
workDir        <- getwd()
lastTestedPolicy  <- NULL                                # most recent policy table sent to OPEN-PROM

# One-time backup of the original canonical file
if (file.exists(inputCsvPath) && !file.exists(backupCsvPath)) {
  dir.create(dirname(backupCsvPath), showWarnings = FALSE, recursive = TRUE)
  file.copy(inputCsvPath, backupCsvPath, overwrite = FALSE)
}

# ----------------------------
# IO helpers: read/write iEnvPolicies.csv
# ----------------------------
readEnvPolicies <- function(csvPath = inputCsvPath) {
  envWide <- data.table::fread(csvPath, na.strings = c("NA", "", "NaN"), header = TRUE)
  if (ncol(envWide) < 3) stop("Unexpected file structure: less than 3 columns found.")
  setnames(envWide, 1:2, c("region", "policy"))
  yearCols <- grep("^[0-9]{4}$", names(envWide), value = TRUE)
  if (!length(yearCols)) stop("No year columns found (expect 4-digit names).")
  envLong <- envWide |>
    as_tibble() |>
    pivot_longer(cols = all_of(yearCols), names_to = "year", values_to = "value") |>
    mutate(year = as.integer(year))
  list(envWide = envWide, envLong = envLong, yearCols = yearCols)
}

# Maps a model scenario id (--fScenario) to the policy row that core/input.gms reads into
# iCarbValYrExog. Must stay in sync with the if/elseif chain in core/input.gms.
# Scenario 0 has no carbon price at all, so there is no row to scale.
SCENARIO_POLICY_ROW <- c(
  "1"   = "exogCV_NPi",
  "2"   = "exogCV_1_5C",
  "3"   = "exogCV_2C",
  "4"   = "exogCV_Calib",
  "5"   = "SoCDR_DelayedAction",
  "6"   = "SoCDR_HighestAmbition",
  "7"   = "SSP2_800f",
  "9"   = "SSP1_800f", 
  "100" = "UPT_100",
  "200" = "UPT_200",
  "400" = "UPT_400",
  "600" = "UPT_600",
  "800" = "UPT_800"
)

policyRowForScenario <- function(scenarioId) {
  key <- as.character(scenarioId)
  if (key == "0") {
    stop("fScenario=0 sets iCarbValYrExog to 0 — there is no carbon price to optimize.")
  }
  row <- SCENARIO_POLICY_ROW[[key]]
  if (is.null(row)) {
    stop(sprintf("Unknown fScenario '%s'. Known: %s",
                 key, paste(names(SCENARIO_POLICY_ROW), collapse = ", ")))
  }
  row
}

applyAlpha <- function(envWide, yearCols, alpha, targetRegion, fromYear = changeCarbonPriceFromYear,
                       policyRow = carbonPricePolicyRow) {
  x <- data.table::copy(envWide)

  yearColsFuture <- yearCols[as.integer(yearCols) >= fromYear]

  # Scale only the policy row the active scenario actually reads. iEnvPolicies.csv also holds
  # the other scenarios' price paths plus non-price rows (EFF, OPT, REN, TRADE); scaling those
  # would corrupt unrelated inputs and silently contaminate later runs of other scenarios.
  isPolicy <- x$policy == policyRow

  if (is.null(targetRegion)) {
    # GLOBAL: apply to all regions
    rows <- which(isPolicy)
  } else if (targetRegion == "EU27") {
    # EU27: apply the same alpha to all 27 member rows (they share one price)
    rows <- which(isPolicy & x$region %in% EU27_REGIONS)
  } else {
    # Single region
    rows <- which(isPolicy & x$region == targetRegion)
  }

  if (!length(rows)) {
    stop(sprintf("No rows matched policy '%s' for region '%s' — check iEnvPolicies.csv.",
                 policyRow, if (is.null(targetRegion)) "WORLD" else targetRegion))
  }

  x[rows, (yearColsFuture) := lapply(.SD, function(col) col * (1 + alpha)), .SDcols = yearColsFuture]
  x
}

# ----------------------------
# Growth-rate ("Hotelling") parameterisation
# ----------------------------
# Instead of rescaling the whole trajectory by a scalar, rebuild it as a geometric path
# anchored at the price already in the file for `anchorYear`:
#
#     P(t) = P(anchorYear) * (1 + r)^(t - anchorYear)     for t > anchorYear
#
# The anchor year itself and everything before it are left exactly as they are, so near-term
# prices stay consistent with enacted policy and only the forward path is being solved for.
#
# Why this beats a scalar multiplier for a cumulative budget:
#  * It controls the *shape* (when abatement happens), not just the level. A cumulative budget
#    is an integral over time, so timing is most of the answer.
#  * It does not inherit the terminal plateau baked into the source row. The stock SSP2_800f
#    path flattens to a hard 700 for every region by 2100; multiplying that by (1+alpha) keeps
#    the plateau and gives almost no late-century leverage. A growth path keeps rising.
#  * r is the economically meaningful parameter: under Hotelling logic an efficient carbon
#    price rises at roughly the discount rate, so a solved r is directly interpretable.
applyGrowthRate <- function(envWide, yearCols, rate, targetRegion,
                            anchorYear = carbonPriceAnchorYear,
                            policyRow = carbonPricePolicyRow,
                            priceCap = carbonPriceCap) {
  x <- data.table::copy(envWide)

  anchorCol <- as.character(anchorYear)
  if (!anchorCol %in% yearCols) {
    stop(sprintf("Anchor year %s is not a column in iEnvPolicies.csv.", anchorCol))
  }
  yearColsFuture <- yearCols[as.integer(yearCols) > anchorYear]

  isPolicy <- x$policy == policyRow
  if (is.null(targetRegion)) {
    rows <- which(isPolicy)
  } else if (targetRegion == "EU27") {
    rows <- which(isPolicy & x$region %in% EU27_REGIONS)
  } else {
    rows <- which(isPolicy & x$region == targetRegion)
  }

  if (!length(rows)) {
    stop(sprintf("No rows matched policy '%s' for region '%s' — check iEnvPolicies.csv.",
                 policyRow, if (is.null(targetRegion)) "WORLD" else targetRegion))
  }

  anchorVal <- as.numeric(x[[anchorCol]][rows])
  if (anyNA(anchorVal)) {
    stop(sprintf("Anchor year %s holds NA for policy '%s' in %d region(s); pick an anchor year with data.",
                 anchorCol, policyRow, sum(is.na(anchorVal))))
  }

  # Each region keeps its own anchor level, so regional price differentiation present in the
  # source data is preserved; only the common forward growth rate is being solved for.
  for (yc in yearColsFuture) {
    horizon <- as.integer(yc) - anchorYear
    newVal  <- anchorVal * (1 + rate)^horizon
    if (is.finite(priceCap)) newVal <- pmin(newVal, priceCap)
    data.table::set(x, i = rows, j = yc, value = newVal)
  }
  x
}

# Single entry point used by the solver, so the rest of the script is identical in both modes.
# `param` is alpha when parameterisation == "scale" and the annual growth rate r when it is
# "growth"; `fromYear` doubles as the scale start year / the growth anchor year.
applyPriceParam <- function(envWide, yearCols, param, targetRegion,
                            fromYear = changeCarbonPriceFromYear,
                            policyRow = carbonPricePolicyRow,
                            mode = parameterisation) {
  if (mode == "scale") {
    applyAlpha(envWide, yearCols, param, targetRegion, fromYear, policyRow)
  } else if (mode == "growth") {
    applyGrowthRate(envWide, yearCols, param, targetRegion, fromYear, policyRow)
  } else {
    stop(sprintf("Unknown parameterisation '%s' — use \"scale\" or \"growth\".", mode))
  }
}

# Human-readable name of the parameter being solved for, used in log messages.
paramLabel <- function(mode = parameterisation) {
  if (mode == "growth") "r" else "Alpha"
}

# Persist an already-final policy table. Takes the table verbatim — no parameter is applied —
# so it is safe in both parameterisations.
writeSolvedPolicyFiles <- function(envFinal,
                                   canonicalPath = file.path("data","iEnvPolicies.csv"),
                                   updatedPath   = file.path("data","iEnvPolicies_updated.csv"),
                                   alsoTimestamped = TRUE,
                                   restoreBackup = TRUE) {
  dir.create(dirname(canonicalPath), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(updatedPath),   showWarnings = FALSE, recursive = TRUE)
  fwrite(envFinal, canonicalPath, na = "NA")
  fwrite(envFinal, updatedPath,   na = "NA")
  if (alsoTimestamped) {
    tsPath <- sub("\\.csv$", paste0("_", format(Sys.time(), "%Y%m%d-%H%M%S"), ".csv"), updatedPath)
    fwrite(envFinal, tsPath, na = "NA")
  }
  # Restore original file
  if (restoreBackup && file.exists(backupCsvPath)) file.copy(backupCsvPath, inputCsvPath, overwrite = TRUE)
  invisible(envFinal)
}

writeFinalPolicyFiles <- function(envWide, yearCols, alphaFinal, region,
                                  fromYear = changeCarbonPriceFromYear,
                                  policyRow = carbonPricePolicyRow,
                                  canonicalPath = file.path("data","iEnvPolicies.csv"),
                                  updatedPath   = file.path("data","iEnvPolicies_updated.csv"),
                                  alsoTimestamped = TRUE) {
  envFinal <- applyPriceParam(envWide, yearCols, alphaFinal, region, fromYear, policyRow)
  writeSolvedPolicyFiles(envFinal, canonicalPath, updatedPath, alsoTimestamped)
}

# ----------------------------
# Simulator wrapper: runs GAMS and returns success/failure
# ----------------------------
run_gams <- function(gms = "main.gms",
                     args = GAMSCmdArgs,
                     log = "full.log", echo_on_success = FALSE) {
  if (!file.exists(gms)) stop("OPEN-PROM not found: ", gms)
  message("Executing OPEN-PROM: ", gms)
  status <- system2("gams", args = c(gms, args), stdout = log, stderr = log)
  if (status == 0) {
    if (echo_on_success) {
      cat("\n--- Tail of log ---\n")
      lg <- tryCatch(readLines(log, warn = FALSE), error = function(e) character())
      if (length(lg)) cat(utils::tail(lg, 5), sep = "\n")
    }
    TRUE
  } else {
    warning(paste0("OPEN-PROM exited with code ", status, ". See ", log, " for details."), call. = FALSE)
    cat("\n--- Tail of log ---\n")
    lg <- tryCatch(readLines(log, warn = FALSE), error = function(e) character())
    if (length(lg)) cat(utils::tail(lg, 60), sep = "\n")
    FALSE
  }
}

# Runs OPEN-PROM for a given alpha and returns the tracked emissions value.
emissionsOPENPROM <- function(envWide, yearCols, alpha, targetRegion, targetYear,
                              fromYear = changeCarbonPriceFromYear,
                              policyRow = carbonPricePolicyRow,
                              dataDir = "data",
                              gms = "main.gms",
                              gamsArgs = GAMSCmdArgs,
                              log = "full.log",
                              echo_on_success = FALSE) {
  canonicalCsv <- file.path(dataDir, "iEnvPolicies.csv")
  on.exit({
    if (file.exists(backupCsvPath)) file.copy(backupCsvPath, canonicalCsv, overwrite = TRUE)
  }, add = TRUE)
  
  # Remember the exact policy table sent to GAMS so it can be recovered if this run fails.
  lastTestedPolicy <<- applyPriceParam(envWide, yearCols, alpha, targetRegion, fromYear, policyRow)
  fwrite(lastTestedPolicy, canonicalCsv, na = "NA")
  ok <- run_gams(gms = gms, args = gamsArgs, log = log, echo_on_success = echo_on_success)
  if (!ok) stop("OPEN-PROM run failed for alpha=", alpha)

  # Read GDX output and extract emissions via postprom
  regions <- readGDX(file.path(workDir, "blabla.gdx"), "runCYL")
  years <- as.character(readGDX(file.path(workDir, "blabla.gdx"), "datay"))
  years <- c(years, as.character(readGDX(file.path(workDir, "blabla.gdx"), "an")))
  years <- paste0("y", years)

  # Suppress console noise from reportEmissions
  utils::capture.output({
      suppressMessages({
        suppressWarnings({
          emissions <- reportEmissions(file.path(workDir, "blabla.gdx"), regions, years)
        })
      })
    }, file = nullfile())


  CO2cum <- extractEmissions(emissions)

  if (is.null(targetRegion)) {
    # GLOBAL: sum all regions
    val <- dimSums(CO2cum, dim = 1)[, targetYear, ]
  } else if (targetRegion == "EU27") {
    # EU27: sum over member regions present in the GDX output
    eu27present <- EU27_REGIONS[EU27_REGIONS %in% getRegions(CO2cum)]
    val <- dimSums(CO2cum[eu27present, , ], dim = 1)[, targetYear, ]
  } else {
    # Single region
    val <- CO2cum[targetRegion, targetYear, ]
  }
  
  as.numeric(val)
}

# ----------------------------
# Seeding, bracketing, regula falsi solver
# ----------------------------

alphaSeedLinear <- function(alpha0, E0, alphar, Er, Etarget, warn = TRUE, stopIfOutside = FALSE) {
  stopifnot(alphar != alpha0, Er != E0)  # avoid divide-by-zero
  # check Etarget range
  Emin <- min(E0, Er)
  Emax <- max(E0, Er)
  if (Etarget < Emin || Etarget > Emax) {
    msg <- sprintf("Etarget (%.3f) is outside range [%.3f, %.3f]", Etarget, Emin, Emax)
    if (stopIfOutside) stop(msg)
    if (warn) warning(msg)
  }
  alpha0 + (Etarget - E0) * (alphar - alpha0) / (Er - E0)
}

# ----------------------------
# Response survey: measure E(param) before assuming anything about its shape
# ----------------------------
# The bracketing + regula falsi scheme below is only valid if emissions decrease monotonically
# in the parameter. OPEN-PROM does not guarantee that: the CCS availability adder
# (tau = A*(Q/10)^2, main.gms) and the biomass sustainability tax (tau = A*(Q/150)^2) are
# lagged quadratic feedbacks onto cost, so pushing the carbon price harder can make abatement
# *more* expensive and the emissions response can saturate, flatten, or turn back up.
# carbonPriceCap compounds this: once the cap binds, different parameter values produce nearly
# identical price paths and E(param) goes flat, which makes the false-position step divide by
# ~zero.
#
# So: sample the curve first, then decide whether root-finding is even meaningful.

surveyResponse <- function(grid, budgetTarget, envWide, yearCols, targetRegion, targetYear,
                           fromYear = changeCarbonPriceFromYear,
                           policyRow = carbonPricePolicyRow,
                           mode = parameterisation, verbose = TRUE) {
  grid <- sort(unique(grid))
  E <- rep(NA_real_, length(grid))
  for (k in seq_along(grid)) {
    E[k] <- emissionsOPENPROM(envWide, yearCols, grid[k], targetRegion, targetYear, fromYear, policyRow)
    if (verbose) message(sprintf("  survey %d/%d: %s=%.4f -> E=%.4f%s",
                                 k, length(grid), paramLabel(mode), grid[k], E[k],
                                 if (E[k] <= budgetTarget) "  [meets target]" else ""))
  }
  data.frame(param = grid, emissions = E)
}

# Classify the sampled curve. `flatTol` is the emissions change below which a step counts as
# flat (no usable gradient); it should be on the order of the solver's emissions tolerance.
analyseResponse <- function(survey, budgetTarget, flatTol = 1e-6) {
  p <- survey$param; E <- survey$emissions
  dE <- diff(E)

  decreasing <- dE < -flatTol
  increasing <- dE >  flatTol
  flat       <- abs(dE) <= flatTol

  monotone <- !any(increasing)
  anyMeets <- any(E <= budgetTarget)

  # Tightest window of consecutive strictly-decreasing steps that brackets the target.
  # Root-finding is only defensible inside such a window, and the tightest one converges
  # fastest — each model run is a full 2024-2100 all-region solve, so width matters.
  bracket <- NULL
  if (anyMeets) {
    best <- Inf
    for (i in seq_along(p)) {
      for (j in seq_along(p)) {
        if (j <= i) next
        seg <- seq.int(i, j - 1)
        if (all(decreasing[seg]) && E[i] > budgetTarget && E[j] <= budgetTarget) {
          width <- p[j] - p[i]
          if (width < best) {
            best <- width
            bracket <- list(lo = p[i], hi = p[j], Elo = E[i], Ehi = E[j])
          }
        }
      }
    }
  }

  list(monotone = monotone, anyMeets = anyMeets, bracket = bracket,
       nIncreasing = sum(increasing), nFlat = sum(flat),
       minE = min(E), minAt = p[which.min(E)])
}

reportResponse <- function(survey, analysis, budgetTarget, mode = parameterisation) {
  message("\n  --- response curve ---")
  lab <- paramLabel(mode)
  for (k in seq_len(nrow(survey))) {
    message(sprintf("   %s=%8.4f  E=%12.4f  %s", lab, survey$param[k], survey$emissions[k],
                    if (survey$emissions[k] <= budgetTarget) "<= target" else ""))
  }
  message(sprintf("   target=%.4f   min E=%.4f at %s=%.4f",
                  budgetTarget, analysis$minE, lab, analysis$minAt))
  if (!analysis$monotone) {
    message(sprintf("   !! NON-MONOTONE: %d step(s) increase emissions. The root-finder's core",
                    analysis$nIncreasing))
    message("      assumption does not hold across the sampled range.")
  }
  if (analysis$nFlat > 0) {
    message(sprintf("   !! %d flat step(s): no usable gradient (cap binding, or saturation).",
                    analysis$nFlat))
  }
  if (!analysis$anyMeets) {
    message("   !! Target not reached anywhere on the grid — infeasible over this range.")
  }
  invisible(NULL)
}

# Expand the upper probe away from `a`. Multiplying by expandFactor is fine for a scale
# multiplier, but collapses for a growth rate near zero (0 * 4 == 0, and 0.005 * 4 crawls),
# so fall back to an additive step that is guaranteed to make progress across the range.
stepUp <- function(a, expandFactor, maxAlpha) {
  mult <- a * expandFactor
  addStep <- max(0.01, abs(maxAlpha) / 20)
  nxt <- if (is.finite(mult) && mult > a + 1e-9) mult else a + addStep
  min(maxAlpha, nxt)
}

autoBracketFromSeed <- function(seedAlpha, budgetTarget, envWide, yearCols, targetRegion, targetYear,
                                   fromYear = changeCarbonPriceFromYear,
                                   policyRow = carbonPricePolicyRow,
                                   minAlpha = 0.0, maxAlpha = 10.0,
                                   expandFactor = 1.35, maxProbes = 20, verbose = TRUE,
                                   mode = parameterisation) {
  probe <- function(a) emissionsOPENPROM(envWide, yearCols, a, targetRegion, targetYear, fromYear, policyRow)

  # --- Feasibility probe: test the maximum carbon price first ---
  # If even the highest allowed price cannot pull emissions down to the target, the
  # target is unreachable — stop now (one run) instead of climbing toward it probe by probe.
  if (verbose) message(sprintf("Feasibility probe at max %s=%.4f", paramLabel(mode), maxAlpha))
  Emax <- probe(maxAlpha)
  if (verbose) message(sprintf("Max: %s=%.4f -> E=%.6f (target=%.6f)", paramLabel(mode), maxAlpha, Emax, budgetTarget))
  if (Emax > budgetTarget) {
    # Do NOT claim the range is simply too low. In a non-monotone response, raising the
    # parameter further can make emissions worse, so "increase maxAlpha" may be the wrong
    # direction entirely. State both possibilities and point at the real suspects.
    stop(sprintf(paste0(
      "Target not reached at the top of the range: %s=%.4f gives E=%.6f vs target %.6f.\n",
      "  This means EITHER the range is too low, OR the emissions response has saturated and\n",
      "  raising %s further will not help. These are opposite fixes, so do not just raise the\n",
      "  range — run the survey (surveyOnly <- TRUE) to see the actual shape of E(%s) first.\n",
      "  Common causes of saturation on this branch: the CCS availability adder\n",
      "  (ccsAvailabilityCostAdder, tau = A*(Q/10 Gt)^2) and the biomass sustainability tax\n",
      "  (bmswasPriceAdder, tau = A*(Q/150 EJ)^2), plus carbonPriceCap truncating the path."),
      paramLabel(mode), maxAlpha, Emax, budgetTarget, paramLabel(mode), paramLabel(mode)))
  }

  if (verbose) message(sprintf("Max feasible; seeding bracket near %s %.4f", paramLabel(mode), seedAlpha))
  Eseed <- probe(seedAlpha)
  if (verbose) message(sprintf("Seed: %s=%.4f → E=%.6f (target=%.6f)", paramLabel(mode), seedAlpha, Eseed, budgetTarget))

  if (Eseed <= budgetTarget) {
    # Seed already meets the target. Probe the floor of the search range to see whether the
    # target is met without raising prices at all — if so there is nothing to optimize.
    # In "scale" mode the floor is alpha = 0, i.e. the untouched trajectory. In "growth" mode
    # r = 0 is a FLAT price at the anchor level, which is a real (and weaker) policy change,
    # so the floor is minAlpha and "already met" does not imply "leave the file alone".
    floorParam <- if (identical(mode, "growth")) minAlpha else 0
    E0 <- probe(floorParam)
    if (verbose) message(sprintf("Floor probe: %s=%.4f -> E=%.6f (target=%.6f)",
                                 paramLabel(mode), floorParam, E0, budgetTarget))
    if (E0 <= budgetTarget) {
      if (verbose) message(sprintf(
        "Region already meets target at the floor of the search range (%s=%.4f); skipping optimization.",
        paramLabel(mode), floorParam))
      return(list(alreadyMet = TRUE, alpha = floorParam,
                  lowerAlpha = floorParam, upperAlpha = floorParam, EL = E0, EU = E0))
    }
    # Floor fails but the seed passes → [floor, seed] brackets the target.
    aL <- floorParam; EL <- E0
    aU <- seedAlpha;  EU <- Eseed
  } else {
    # Seed exceeds the target → expand upward toward the (already feasible) maxAlpha.
    aL <- seedAlpha; EL <- Eseed
    aU <- min(maxAlpha, stepUp(seedAlpha, expandFactor, maxAlpha)); tries <- 0
    repeat {
      if (aU >= maxAlpha - 1e-9) { aU <- maxAlpha; EU <- Emax; break }  # reuse feasibility probe
      EU <- probe(aU); tries <- tries + 1
      if (verbose) message(sprintf("Up probe: %s=%.4f → E=%.6f", paramLabel(mode), aU, EU))
      if (EU <= budgetTarget || tries >= maxProbes) break
      # Still above target: this probe is a tighter lower bound than the seed, so keep
      # it instead of leaving aL stuck at seedAlpha (e.g. bracket [0.4, 1.6], not [0.1, 1.6]).
      aL <- aU; EL <- EU
      aU <- min(maxAlpha, stepUp(aU, expandFactor, maxAlpha))
    }
    # Probes exhausted with the last one still above target: it is a valid lower bound too,
    # so promote it before falling back to the known-feasible max.
    if (EU > budgetTarget) { aL <- aU; EL <- EU; aU <- maxAlpha; EU <- Emax }
  }
  list(lowerAlpha = aL, upperAlpha = aU, EL = EL, EU = EU)
}

findAlphaForBudget <- function(envWide, yearCols, budgetTarget,
                               lowerAlpha, upperAlpha,
                               eLow = NULL, eHigh = NULL, targetRegion, targetYear,
                               fromYear = changeCarbonPriceFromYear,
                               policyRow = carbonPricePolicyRow,
                               tolAlphaRel = 1e-3, tolEmisAbs = 1e-3,
                               tolParamAbs = searchBounds$tolParamAbs,
                               maxIter = 60, verbose = TRUE, writeFinalCsv = TRUE) {

  # Evaluate bounds if not already provided by autoBracketFromSeed.
  if (is.null(eLow))  eLow  <- emissionsOPENPROM(envWide, yearCols, lowerAlpha, targetRegion, targetYear, fromYear, policyRow)
  if (is.null(eHigh)) eHigh <- emissionsOPENPROM(envWide, yearCols, upperAlpha, targetRegion, targetYear, fromYear, policyRow)

  if (verbose) message(sprintf(
    "Initial: %s_lo=%.6f -> E=%.6f; %s_hi=%.6f -> E=%.6f; target=%.6f",
    paramLabel(), lowerAlpha, eLow, paramLabel(), upperAlpha, eHigh, budgetTarget))

  if (eLow <= budgetTarget) {
    if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, lowerAlpha, targetRegion, fromYear, policyRow)
    return(list(alpha = lowerAlpha, emissions = eLow, converged = TRUE, iters = 0))
  }
  if (eHigh > budgetTarget) stop("upperAlpha still exceeds budget. Increase it or check monotonicity.")

  aL <- lowerAlpha; aU <- upperAlpha
  emisL <- eLow;     emisU <- eHigh
  it <- 0
  prevAM <- NA

  while (it < maxIter) {
    it <- it + 1

    # False-position (regula falsi) step: linearly interpolate toward the target.
    # Faster than bisection because it uses gradient information from both endpoints.
    # If the interpolated point repeats the previous one (stall), fall back to the
    # bisection midpoint to guarantee progress.
    aM_interp <- aL + (budgetTarget - emisL) * (aU - aL) / (emisU - emisL)
    aM_interp <- max(aL, min(aU, aM_interp))   # clamp to bracket

    if (!is.na(prevAM) && abs(aM_interp - prevAM) / max(1.0, abs(aM_interp)) < 1e-6) {
      aM <- 0.5 * (aL + aU)   # stall detected: bisection fallback
      if (verbose) message(sprintf("Iter %02d: stall detected, using bisection midpoint", it))
    } else {
      aM <- aM_interp
    }
    prevAM <- aM

    emisM <- emissionsOPENPROM(envWide, yearCols, aM, targetRegion, targetYear, fromYear, policyRow)
    if (verbose) message(sprintf("Iter %02d: %s=%.6f -> E=%.6f (target=%.6f)", it, paramLabel(), aM, emisM, budgetTarget))

    # Bracket-width test: the relative form alone is useless when the parameter is a small
    # rate (dividing by max(1, |aM|) makes it effectively absolute against 1.0), so also stop
    # once the bracket is narrower than a meaningful absolute step in the parameter.
    bracketWidth <- abs(aU - aL)
    if (abs(emisM - budgetTarget) < tolEmisAbs ||
        bracketWidth / max(1.0, abs(aM)) < tolAlphaRel ||
        bracketWidth < tolParamAbs) {
      if (verbose) message("Converged.")
      if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aM, targetRegion, fromYear, policyRow)
      return(list(alpha = aM, emissions = emisM, converged = TRUE, iters = it))
    }

    if (emisM > budgetTarget) {
      aL <- aM; emisL <- emisM
    } else {
      aU <- aM; emisU <- emisM
    }
  }

  warning("Max iterations reached without strict tolerance convergence.")
  if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU, targetRegion, fromYear, policyRow)
  list(alpha = aU, emissions = emisU, converged = FALSE, iters = it)
}
configureGamsFile <- function(gmsPath, targetRegion) {
  lines <- readLines(gmsPath, warn = FALSE)
  
  idx <- grep("fCountries", lines, ignore.case = TRUE)
  if (length(idx) > 0) {
    lines[idx[1]] <- paste0("$setGlobal fCountries '", targetRegion, "'")
    writeLines(lines, gmsPath)
    message(sprintf("  -> Updated fCountries to '%s'", targetRegion))
  } else {
    warning("Could not find '$setGlobal fCountries' in main.gms")
  }
}
extractEmissions <- function(dataMagpie) {
  # Variable and scale are set in the Run section below.
  # emissionsVariable: name of the variable in the reportEmissions magpie object
  # emissionsScale:    multiplier to convert to the same unit as the budget targets
  emissions <- dataMagpie[, , emissionsVariable] * emissionsScale
  #emissionsMt <- dimSums(emissions, dim = 3)
  #getNames(emissions) <- emissions
  emissions
}

# ----------------------------
# Run
# ----------------------------
start_time <- Sys.time()
selectedYear <- 2100              # default target year, overridable per region via targetList `year`
changeCarbonPriceFromYear <- 2026 # default first year the price is scaled, overridable per region via targetList `fromYear`

# --- How the carbon price path is parameterised ---
# "scale"  : P(t) <- P(t) * (1 + param) for t >= fromYear. One scalar on the existing curve;
#            preserves its shape, including any terminal plateau baked into the source row.
# "growth" : P(t) <- P(anchor) * (1 + param)^(t - anchor) for t > anchor. Rebuilds the forward
#            path as a Hotelling-style geometric curve anchored on the price already in the
#            file for `fromYear`. `param` is then an annual growth rate, not a multiplier.
#
# Prefer "growth" for cumulative-budget targets: a cumulative budget is an integral over time,
# so the timing of abatement matters as much as the level, and the stock SSP2_800f path
# flattens to a hard 700 for every region by 2100 — scaling that keeps the plateau and gives
# very little late-century leverage.
parameterisation <- "scale"

# Upper bound on any carbon price the growth path may produce (US$2015/tCO2), applied after
# compounding. Guards against absurd end-century values when a high r runs for ~75 years.
# Set to Inf to disable. Only used in "growth" mode.
carbonPriceCap <- 1500

# In "growth" mode the anchor year is the last year left untouched; the path is rebuilt from
# the year after it onward. It defaults to each region's fromYear so near-term prices stay
# consistent with enacted policy.
carbonPriceAnchorYear <- changeCarbonPriceFromYear

# --- Search range for the root-find, per parameterisation ---
# The two parameters live on completely different scales, so the bracket must follow the mode:
#   scale  : a multiplier. 0 = unchanged, 40 = a 41x price.
#   growth : an annual rate compounding over ~75 years. 0.02 = 2%/yr, 0.15 = 15%/yr. Anything
#            much above ~0.20 is already explosive by 2100 (1.20^74 ~= 700,000x the anchor),
#            which is why carbonPriceCap exists.
# minAlpha is the search floor, not a hard bound on the file: in growth mode r can legitimately
# be small or negative (a declining real price), so it is allowed below zero.
# Calibration note for the growth seed: the stock SSP2_800f path front-loads much harder than
# any constant rate (69%/yr in 2027, decaying below 1%/yr after 2070). Measured on CHA over
# 2027-2100, a constant rate reproduces the original path's price integral at roughly 6.5%/yr
# (r=6% gives 0.80x, r=8% gives 2.47x). So ~0.065 is "about as stringent as the baseline" and
# is the sensible seed; lower rates are genuinely weaker policy despite compounding.
searchBoundsFor <- function(mode) {
  if (mode == "growth") {
    list(seed = 0.065, min = 0.0, max = 0.20, expandFactor = 1.5, maxProbes = 7,
         tolParamAbs = 1e-3)   # 0.1 percentage point on r
  } else {
    list(seed = 0.217,  min = 0,  max = 3,   expandFactor = 4.0, maxProbes = 7,
         tolParamAbs = 1e-2)
  }
}
searchBounds <- searchBoundsFor(parameterisation)

# --- Response survey -------------------------------------------------------
# The root-finder assumes emissions fall monotonically in the parameter. On this branch that
# assumption is not safe (see surveyResponse() above), so the survey measures the curve first
# and gates the root-find on what it finds.
#
#   withSurvey  TRUE  : sample surveyGrid before each region's root-find. Costs
#                       length(surveyGrid) extra model runs per region, but they are not
#                       wasted — the bracket is taken from the sampled points.
#   surveyOnly  TRUE  : sample, report the curve, then STOP without root-finding or writing
#                       any CSV. This is the diagnostic mode — use it first.
#   requireMonotone   : if TRUE, refuse to root-find when the sampled curve is non-monotone.
#                       Set FALSE to proceed anyway on the largest decreasing window found
#                       (a warning is logged either way).
withSurvey      <- FALSE
surveyOnly      <- FALSE
requireMonotone <- FALSE

# Grid of parameter values to sample. Defaults span the search range; override for a finer or
# coarser sweep. In growth mode these are annual rates, in scale mode multipliers.
surveyGrid <- if (parameterisation == "growth") {
  c(0, 0.05, 0.10, 0.15, 0.20)
} else {
  c(0, 0.5, 2, 8, 20)
}

# Emissions change below which a survey step counts as "flat" (no usable gradient). Keep it at
# or above the solver's own emissions tolerance so cap-induced plateaus are detected.
surveyFlatTol <- 1e+1

# Where the sampled curve is written, so it can be plotted / kept across runs.
surveyCsvPath <- "carbon_price_response_survey.csv"

# Model scenario passed to GAMS via --fScenario (overrides $evalGlobal fScenario in main.gms):
#   0 = No carbon price, 1 = NPi_Default, 2 = 1.5C, 3 = 2C
selectedScenario <- 7

# The single policy row in iEnvPolicies.csv that this scenario feeds into iCarbValYrExog.
# Alpha is applied to this row only — every other row in the file (the other scenarios'
# price paths, and the non-price EFF/OPT/REN/TRADE rows) is left untouched.
carbonPricePolicyRow <- policyRowForScenario(selectedScenario)
message(sprintf("Scenario %s -> scaling policy row '%s'", selectedScenario, carbonPricePolicyRow))

# --fEndY caps the solve horizon at selectedYear instead of always running to 2100, so
# shortening a run is just a matter of lowering selectedYear (use --fEndY, never
# fEndHorizon, which triggers domain-violation errors). --fScenario selects the scenario.
GAMSCmdArgs <- c("--DevMode=0", "--GenerateInput=off", "lo=4", "idir=./data",
                 "--CountrySolveMode=parallel",
                 paste0("--fEndY=", selectedYear),
                 paste0("--fScenario=", selectedScenario))

# Keep an unmodified template of the GAMS args so we can substitute per-region end years
GAMSCmdArgsTemplate <- GAMSCmdArgs

# --- Emissions variable to track ---
# Set emissionsVariable to any variable name returned by reportEmissions().
# Set emissionsScale so that after multiplication the unit matches your budget targets.
#
# Common choices:
#   "Emissions|CO2|Cumulated.Gt CO2"          * 1000  -> Mt CO2  (cumulated)
#   "Emissions|CO2.Mt CO2/yr"                 * 1     -> Mt CO2/yr
#   "Emissions|Kyoto Gases.Mt CO2-equiv/yr"   * 1     -> Mt CO2-equiv/yr
emissionsVariable <- "Emissions|CO2|Cumulated.Gt CO2"
emissionsScale    <- 1   # Gt -> Mt

# EU27 member regions — share a single carbon price in iEnvPolicies.csv.
# Never optimised individually; always solved as one aggregated group.
EU27_REGIONS <- c("AUT","BEL","BGR","CYP","CZE","DEU","DNK","ESP","EST",
                   "FIN","FRA","GRC","HRV","HUN","IRL","ITA","LTU","LUX",
                   "LVA","MLT","NLD","POL","PRT","ROU","SVK","SVN","SWE")

# --- Target list ---
# Each entry is one of:
#  - a scalar numeric budget (backwards compatible): targetList$REGION = BUDGET
#  - a named list: targetList$REGION = list(budget = BUDGET, year = YYYY, fromYear = YYYY)
#      * budget   = emissions budget the region must reach.
#      * year     = year by which the budget must be met  (optional; defaults to selectedYear).
#      * fromYear = first year whose carbon price is scaled (optional; defaults to
#                   changeCarbonPriceFromYear). Set it per region to change the price
#                   from a different start year than the global default.
# Special keys:
#   "EU27"  -> shared alpha applied to all 27 EU member rows; emissions summed over members.
#   "WORLD" -> alpha applied to all region rows; emissions summed globally.
# Any other key must match a region code in iEnvPolicies.csv.
# Comment out any entry to skip that region in this run.
#
# Current unit: cumulated Mt CO2  (Emissions|CO2|Cumulated.Gt CO2 * 1000)
targetList <- list(
  # Examples (mix-and-match supported):
  WORLD  = list(budget = 1198, year = selectedYear)  # optional: comment out to skip world run
  # EU27  = list(budget = 0, year = 2050),
  # CAZ  = list(budget = 0,  year = 2050),
  # # CHA  = list(budget = 13447, year = 2050),
  # GBR  = list(budget = 0,  year = 2050),
  # IND  = list(budget = 0, year = 2070),
  # JPN  = list(budget = 0,  year = 2050),
  # LAM  = list(budget = 703, year = 2050),
  # MEA  = list(budget = 3245, year = 2060),
  # NEU  = list(budget = 101,  year = 2050),
  # OAS  = list(budget = 1186, year = 2060),
  # REF  = list(budget = 355, year = 2060),
  # SSA  = list(budget = 2238, year = 2050),
  # USA  = list(budget = 0, year = 2050)  # numeric form still supported: interpreted as budget with fallback year = selectedYear
)

logFilePath <- "Carbon_price_optimization.log"
file.create(logFilePath)
logCon <- file(logFilePath, open = "a")

envData <- readEnvPolicies(inputCsvPath)
currentEnvWide <- envData$envWide
yearCols       <- envData$yearCols

if (length(targetList) == 0) stop("targetList is empty. Add at least one region or 'WORLD' entry.")

if (file.exists(inputCsvPath)) file.copy(inputCsvPath, backupCsvPath, overwrite = TRUE)

sink(logCon, type = "output")
sink(logCon, type = "message")

# Restore console output even if the script crashes
on.exit({
  sink(type = "message")
  sink()
  close(logCon)
  message("Log redirection ended. Console restored.")
}, add = TRUE)
resultsLog <- list()
surveyLog  <- list()   # per-region sampled response curves + their analysis

for (regName in names(targetList)) {

  lastTestedPolicy <- NULL   # don't carry a previous region's tested policy into this run
  entry <- targetList[[regName]]
  # Support two formats: numeric (budget only) or list(budget=..., year=..., fromYear=...)
  if (is.list(entry) && !is.null(entry$budget)) {
    bg <- as.numeric(entry$budget)
    regionTargetYear <- if (!is.null(entry$year))     as.integer(entry$year)     else selectedYear
    regionFromYear   <- if (!is.null(entry$fromYear)) as.integer(entry$fromYear) else changeCarbonPriceFromYear
  } else if (is.numeric(entry) && length(entry) == 1) {
    bg <- as.numeric(entry)
    regionTargetYear <- selectedYear
    regionFromYear   <- changeCarbonPriceFromYear
  } else {
    stop(sprintf("Invalid targetList entry for '%s' — must be numeric or list(budget=..., year=..., fromYear=...)", regName))
  }

  if (regName == "WORLD") {
    actualRegion <- NULL   # NULL -> alpha applied to all region rows
    displayName  <- "World"
  } else if (regName == "EU27") {
    actualRegion <- "EU27"
    displayName  <- "EU27"
  } else {
    actualRegion <- regName
    displayName  <- regName
  }

  message(sprintf("\n--- Optimizing %s (Target: %.4f, Year: %d, From: %d) ---", displayName, bg, regionTargetYear, regionFromYear))
  skipRegion <- FALSE

  tryCatch({
  # Update fCountries in main.gms for single-region runs only.
  # EU27 and WORLD require all regions to run, so main.gms is left unchanged.
  if (!is.null(actualRegion) && actualRegion != "EU27") {
    configureGamsFile("main.gms", actualRegion)
  }

  # Ensure GAMS runs use the region-specific solve horizon (end year)
  GAMSCmdArgs <- GAMSCmdArgsTemplate
  i_endy <- grep("^--fEndY=", GAMSCmdArgs)
  if (length(i_endy)) GAMSCmdArgs[i_endy] <- paste0("--fEndY=", regionTargetYear) else GAMSCmdArgs <- c(GAMSCmdArgs, paste0("--fEndY=", regionTargetYear))

  # --- A. Survey the response curve before assuming it is monotone -----------
  brkt <- NULL
  if (isTRUE(withSurvey)) {
    message(sprintf(" Surveying %d point(s) of E(%s) for %s...",
                    length(surveyGrid), paramLabel(), displayName))
    survey <- surveyResponse(
      grid         = surveyGrid,
      budgetTarget = bg,
      envWide      = currentEnvWide,
      yearCols     = yearCols,
      targetRegion = actualRegion,
      targetYear   = regionTargetYear,
      fromYear     = regionFromYear,
      verbose      = TRUE
    )
    analysis <- analyseResponse(survey, bg, flatTol = surveyFlatTol)
    reportResponse(survey, analysis, bg)

    # Persist the curve so it can be plotted and compared across adder settings.
    surveyOut <- cbind(region = displayName, parameterisation = parameterisation,
                       target = bg, year = regionTargetYear, survey)
    fwrite(surveyOut, surveyCsvPath, na = "NA",
           append = file.exists(surveyCsvPath))
    message(sprintf("   survey written to %s", surveyCsvPath))

    surveyLog[[regName]] <- list(survey = survey, analysis = analysis)

    if (isTRUE(surveyOnly)) {
      message(" surveyOnly = TRUE -> not root-finding, not writing any policy CSV.")
      resultsLog[[regName]] <- list(status = "SURVEY",
                                    minE = analysis$minE, minAt = analysis$minAt,
                                    monotone = analysis$monotone, meets = analysis$anyMeets)
      skipRegion <- TRUE
    } else if (!analysis$anyMeets) {
      stop(sprintf(paste0(
        "Target %.4f not reached anywhere on the surveyed range [%.4f, %.4f]; the best was ",
        "E=%.4f at %s=%.4f. Raising the range further is only one possible fix — check the ",
        "CCS/biomass adders and carbonPriceCap before assuming the parameter is too low."),
        bg, min(surveyGrid), max(surveyGrid), analysis$minE, paramLabel(), analysis$minAt))
    } else if (!analysis$monotone && isTRUE(requireMonotone)) {
      stop(sprintf(paste0(
        "Emissions response is NON-MONOTONE over the surveyed range (%d increasing step(s)). ",
        "Root-finding assumes a monotone decreasing E(%s), so its result would not be ",
        "trustworthy. Either narrow surveyGrid to a monotone window, or set ",
        "requireMonotone <- FALSE to proceed on the largest decreasing window found."),
        analysis$nIncreasing, paramLabel()))
    } else if (!is.null(analysis$bracket)) {
      # Reuse the sampled points: they already bracket the target on a decreasing window,
      # so no extra model runs are needed to build the bracket.
      if (!analysis$monotone) {
        warning(sprintf("Non-monotone response; proceeding on the decreasing window [%.4f, %.4f].",
                        analysis$bracket$lo, analysis$bracket$hi), call. = FALSE)
      }
      brkt <- list(lowerAlpha = analysis$bracket$lo, upperAlpha = analysis$bracket$hi,
                   EL = analysis$bracket$Elo, EU = analysis$bracket$Ehi)
      message(sprintf(" Bracket from survey: [%.4f, %.4f] -> E [%.4f, %.4f]",
                      brkt$lowerAlpha, brkt$upperAlpha, brkt$EL, brkt$EU))
    }
  }

  # --- B. Fall back to probe-based bracketing when the survey did not supply one ---
  if (!skipRegion && is.null(brkt)) {
    brkt <- autoBracketFromSeed(
      seedAlpha    = searchBounds$seed,
      budgetTarget = bg,
      envWide      = currentEnvWide,
      yearCols     = yearCols,
      targetRegion = actualRegion,
      targetYear   = regionTargetYear,
      fromYear     = regionFromYear,
      minAlpha     = searchBounds$min,
      maxAlpha     = searchBounds$max,
      expandFactor = searchBounds$expandFactor,
      maxProbes    = searchBounds$maxProbes,
      verbose      = TRUE
    )
  }

  # C. Solve (skip entirely in surveyOnly mode; skip the root-find when the region already
  #    meets its target at the search floor)
  if (skipRegion) {
    # surveyOnly: nothing to solve and nothing to write for this region.
  } else if (isTRUE(brkt$alreadyMet)) {
    finalAlpha <- brkt$alpha
    message(sprintf(" -> %s already meets target at the search floor (%s=%.4f).",
                    displayName, paramLabel(), finalAlpha))
  } else {
    solveResult <- findAlphaForBudget(
      envWide      = currentEnvWide,
      yearCols     = yearCols,
      budgetTarget = bg,
      targetRegion = actualRegion, # Passes NULL if global
      targetYear   = regionTargetYear,
      fromYear     = regionFromYear,
      lowerAlpha   = brkt$lowerAlpha,
      upperAlpha   = brkt$upperAlpha,
      eLow         = brkt$EL,
      eHigh        = brkt$EU,
      tolAlphaRel  = 1e-2,
      tolEmisAbs   = 1e+1,
      maxIter      = 60,
      verbose      = TRUE,
      writeFinalCsv = FALSE
    )

    finalAlpha <- solveResult$alpha
    if (parameterisation == "growth") {
      message(sprintf(" -> Converged %s: r=%.4f (%.2f%%/yr from %d)",
                      displayName, finalAlpha, 100 * finalAlpha, regionFromYear))
    } else {
      message(sprintf(" -> Converged %s: Alpha=%.3f", displayName, finalAlpha))
    }
  }

  # Apply converged parameter and persist as the new baseline for subsequent regions.
  # Skipped in surveyOnly mode: a survey is a measurement, it must not mutate the policy file.
  if (!skipRegion) {
    currentEnvWide <- applyPriceParam(currentEnvWide, yearCols, finalAlpha, actualRegion, regionFromYear, carbonPricePolicyRow)
    fwrite(currentEnvWide, inputCsvPath, na = "NA")
    file.copy(inputCsvPath, backupCsvPath, overwrite = TRUE)
    resultsLog[[regName]] <- list(status = "OK", alpha = finalAlpha)
  }

  }, error = function(e) {
    message(sprintf("  !! FAILURE for %s: %s", displayName, e$message))
    # Preserve the carbon prices that were being tested when the run failed, in a
    # region-specific file, so each failing region's last-tested policy survives.
    if (!is.null(lastTestedPolicy)) {
      regionLastTestedCsvPath <- sub("\\.csv$", paste0("_", regName, ".csv"), lastTestedCsvPath)
      fwrite(lastTestedPolicy, regionLastTestedCsvPath, na = "NA")
      message(sprintf("  -> Saved last-tested policy to %s", regionLastTestedCsvPath))
    }
    message("  -> Reverting to last good state and skipping.")
    if (file.exists(backupCsvPath)) file.copy(backupCsvPath, inputCsvPath, overwrite = TRUE)
    resultsLog[[regName]] <<- list(status = "FAILED", error = e$message)
    skipRegion <<- TRUE
  })

  if (skipRegion) next
}

message("\n--- Final Summary ---")
message(sprintf(" parameterisation: %s   policy row: %s", parameterisation, carbonPricePolicyRow))
for (r in names(resultsLog)) {
  item <- resultsLog[[r]]
  if (item$status == "OK") {
    if (parameterisation == "growth") {
      message(sprintf(" [OK]     %s : r = %.4f (%.2f%%/yr)", r, item$alpha, 100 * item$alpha))
    } else {
      message(sprintf(" [OK]     %s : Alpha = %.3f", r, item$alpha))
    }
  } else if (item$status == "SURVEY") {
    message(sprintf(" [SURVEY] %s : min E = %.4f at %s = %.4f | monotone: %s | target met: %s",
                    r, item$minE, paramLabel(), item$minAt,
                    if (item$monotone) "yes" else "NO", if (item$meets) "yes" else "NO"))
  } else {
    message(sprintf(" [FAILED] %s : %s", r, item$error))
  }
}

if (isTRUE(surveyOnly)) {
  message(sprintf("\n Survey-only run: no policy CSV was written. Curves saved to %s.", surveyCsvPath))
  message(" Set surveyOnly <- FALSE to root-find once the response looks usable.")
}

sink(type = "message")
sink()

# `currentEnvWide` already holds every converged region's path (each loop iteration applied its
# solved parameter to it), so write it out as-is. Re-applying a neutral parameter here would be
# a no-op in "scale" mode but would flatten the whole path to the anchor level in "growth" mode.
# In surveyOnly mode nothing was solved, so the file must be left exactly as it was.
if (!isTRUE(surveyOnly)) {
  writeSolvedPolicyFiles(currentEnvWide)
} else if (file.exists(backupCsvPath)) {
  file.copy(backupCsvPath, inputCsvPath, overwrite = TRUE)
}
message(sprintf("Done. Total time: %s", Sys.time() - start_time))
