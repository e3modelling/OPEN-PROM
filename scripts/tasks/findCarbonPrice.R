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
# Notes:
# • Alpha represents a proportional change in carbon prices:
#       new_price = old_price * (1 + alpha)
# • Alpha < 0 decreases prices; alpha > 0 increases prices.
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

applyAlpha <- function(envWide, yearCols, alpha, targetRegion) {
  x <- data.table::copy(envWide)

  yearColsFuture <- yearCols[as.integer(yearCols) >= changeCarbonPriceFromYear]

  if (is.null(targetRegion)) {
    # GLOBAL: apply to all regions
    x[, (yearColsFuture) := lapply(.SD, function(col) col * (1 + alpha)), .SDcols = yearColsFuture]
  } else if (targetRegion == "EU27") {
    # EU27: apply the same alpha to all 27 member rows (they share one price)
    x[region %in% EU27_REGIONS, (yearColsFuture) := lapply(.SD, function(col) col * (1 + alpha)), .SDcols = yearColsFuture]
  } else {
    # Single region
    x[region == targetRegion, (yearColsFuture) := lapply(.SD, function(col) col * (1 + alpha)), .SDcols = yearColsFuture]
  }
  x
}

writeFinalPolicyFiles <- function(envWide, yearCols, alphaFinal, region,
                                  canonicalPath = file.path("data","iEnvPolicies.csv"),
                                  updatedPath   = file.path("data","iEnvPolicies_updated.csv"),
                                  alsoTimestamped = TRUE) {
  envFinal <- applyAlpha(envWide, yearCols, alphaFinal, region)
  dir.create(dirname(canonicalPath), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(updatedPath),   showWarnings = FALSE, recursive = TRUE)
  fwrite(envFinal, canonicalPath, na = "NA")
  fwrite(envFinal, updatedPath,   na = "NA")
  if (alsoTimestamped) {
    tsPath <- sub("\\.csv$", paste0("_", format(Sys.time(), "%Y%m%d-%H%M%S"), ".csv"), updatedPath)
    fwrite(envFinal, tsPath, na = "NA")
  }
  # Restore original file
  if (file.exists(backupCsvPath)) file.copy(backupCsvPath, inputCsvPath, overwrite = TRUE)
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
  lastTestedPolicy <<- applyAlpha(envWide, yearCols, alpha, targetRegion)
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

autoBracketFromSeed <- function(seedAlpha, budgetTarget, envWide, yearCols, targetRegion, targetYear,
                                   minAlpha = 0.0, maxAlpha = 5.0,
                                   expandFactor = 1.35, maxProbes = 20, verbose = TRUE) {
  probe <- function(a) emissionsOPENPROM(envWide, yearCols, a, targetRegion, targetYear)

  # --- Feasibility probe: test the maximum carbon price first ---
  # If even the highest allowed price cannot pull emissions down to the target, the
  # target is unreachable — stop now (one run) instead of climbing toward it probe by probe.
  if (verbose) message(sprintf("Feasibility probe at maxAlpha=%.4f", maxAlpha))
  Emax <- probe(maxAlpha)
  if (verbose) message(sprintf("maxAlpha: alpha=%.4f -> E=%.6f (target=%.6f)", maxAlpha, Emax, budgetTarget))
  if (Emax > budgetTarget) {
    stop(sprintf(
      "maxAlpha too low: at alpha=%.4f emissions are %.6f, still above target %.6f. Increase maxAlpha.",
      maxAlpha, Emax, budgetTarget))
  }

  if (verbose) message(sprintf("maxAlpha feasible; seeding bracket near alpha %.4f", seedAlpha))
  Eseed <- probe(seedAlpha)
  if (verbose) message(sprintf("Seed: alpha=%.4f → E=%.6f (target=%.6f)", seedAlpha, Eseed, budgetTarget))

  if (Eseed <= budgetTarget) {
    # Seed already meets the target. Check whether unchanged prices (alpha = 0) meet it
    # too — if so there is nothing to optimize, so keep the original prices and skip.
    E0 <- probe(0)
    if (verbose) message(sprintf("No-change probe: alpha=0.0000 -> E=%.6f (target=%.6f)", E0, budgetTarget))
    if (E0 <= budgetTarget) {
      if (verbose) message("Region already meets target with unchanged carbon prices; skipping optimization.")
      return(list(alreadyMet = TRUE, alpha = 0,
                  lowerAlpha = 0, upperAlpha = 0, EL = E0, EU = E0))
    }
    # alpha = 0 fails but the seed passes → [0, seed] brackets the target.
    aL <- 0;         EL <- E0
    aU <- seedAlpha; EU <- Eseed
  } else {
    # Seed exceeds the target → expand upward toward the (already feasible) maxAlpha.
    aL <- seedAlpha; EL <- Eseed
    aU <- min(maxAlpha, seedAlpha * expandFactor); tries <- 0
    repeat {
      if (aU >= maxAlpha - 1e-9) { aU <- maxAlpha; EU <- Emax; break }  # reuse feasibility probe
      EU <- probe(aU); tries <- tries + 1
      if (verbose) message(sprintf("Up probe: alpha=%.4f → E=%.6f", aU, EU))
      if (EU <= budgetTarget || tries >= maxProbes) break
      aU <- min(maxAlpha, aU * expandFactor)
    }
    if (EU > budgetTarget) { aU <- maxAlpha; EU <- Emax }  # probes exhausted: fall back to feasible max
  }
  list(lowerAlpha = aL, upperAlpha = aU, EL = EL, EU = EU)
}

findAlphaForBudget <- function(envWide, yearCols, budgetTarget,
                               lowerAlpha, upperAlpha,
                               eLow = NULL, eHigh = NULL, targetRegion, targetYear,
                               tolAlphaRel = 1e-3, tolEmisAbs = 1e-3,
                               maxIter = 60, verbose = TRUE, writeFinalCsv = TRUE) {

  # Evaluate bounds if not already provided by autoBracketFromSeed.
  if (is.null(eLow))  eLow  <- emissionsOPENPROM(envWide, yearCols, lowerAlpha, targetRegion, targetYear)
  if (is.null(eHigh)) eHigh <- emissionsOPENPROM(envWide, yearCols, upperAlpha, targetRegion, targetYear)

  if (verbose) message(sprintf(
    "Initial: aL=%.6f -> E=%.6f; aU=%.6f -> E=%.6f; target=%.6f",
    lowerAlpha, eLow, upperAlpha, eHigh, budgetTarget))

  if (eLow <= budgetTarget) {
    if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, lowerAlpha, targetRegion)
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

    emisM <- emissionsOPENPROM(envWide, yearCols, aM, targetRegion, targetYear)
    if (verbose) message(sprintf("Iter %02d: aM=%.6f -> E=%.6f (target=%.6f)", it, aM, emisM, budgetTarget))

    if (abs(emisM - budgetTarget) < tolEmisAbs || abs(aU - aL) / max(1.0, abs(aM)) < tolAlphaRel) {
      if (verbose) message("Converged.")
      if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aM, targetRegion)
      return(list(alpha = aM, emissions = emisM, converged = TRUE, iters = it))
    }

    if (emisM > budgetTarget) {
      aL <- aM; emisL <- emisM
    } else {
      aU <- aM; emisU <- emisM
    }
  }

  warning("Max iterations reached without strict tolerance convergence.")
  if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU, targetRegion)
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
selectedYear <- 2030
changeCarbonPriceFromYear <- 2026

# Model scenario passed to GAMS via --fScenario (overrides $evalGlobal fScenario in main.gms):
#   0 = No carbon price, 1 = NPi_Default, 2 = 1.5C, 3 = 2C
selectedScenario <- 2

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
emissionsVariable <- "Emissions|Kyoto Gases.Mt CO2-equiv/yr"
emissionsScale    <- 1   # Gt -> Mt

# EU27 member regions — share a single carbon price in iEnvPolicies.csv.
# Never optimised individually; always solved as one aggregated group.
EU27_REGIONS <- c("AUT","BEL","BGR","CYP","CZE","DEU","DNK","ESP","EST",
                   "FIN","FRA","GRC","HRV","HUN","IRL","ITA","LTU","LUX",
                   "LVA","MLT","NLD","POL","PRT","ROU","SVK","SVN","SWE")

# --- Target list ---
# Each entry is one of:
#  - a scalar numeric budget (backwards compatible): targetList$REGION = BUDGET
#  - a named list with budget and year: targetList$REGION = list(budget = BUDGET, year = YYYY)
# Special keys:
#   "EU27"  -> shared alpha applied to all 27 EU member rows; emissions summed over members.
#   "WORLD" -> alpha applied to all region rows; emissions summed globally.
# Any other key must match a region code in iEnvPolicies.csv.
# Comment out any entry to skip that region in this run.
#
# Current unit: cumulated Mt CO2  (Emissions|CO2|Cumulated.Gt CO2 * 1000)
targetList <- list(
  # Examples (mix-and-match supported):
  # WORLD = 1257571,  # optional: comment out to skip world run
  EU27  = list(budget = 3000, year = 2027),
  CAZ  = list(budget = 1300,  year = 2028)
  # CHA  = list(budget = 13447, year = 2032),
  # GBR  = list(budget = 263,  year = 2030),
  # IND  = list(budget = 3981, year = 2040),
  # JPN  = list(budget = 766,  year = 2030),
  # LAM  = list(budget = 3618, year = 2035),
  # MEA  = list(budget = 4868, year = 2030),
  # NEU  = list(budget = 842,  year = 2030),
  # OAS  = list(budget = 5244, year = 2040),
  # REF  = list(budget = 3119, year = 2035),
  # SSA  = list(budget = 3733, year = 2030)
  # USA  = 100855  # numeric form still supported: interpreted as budget with fallback year = selectedYear
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

for (regName in names(targetList)) {

  lastTestedPolicy <- NULL   # don't carry a previous region's tested policy into this run
  entry <- targetList[[regName]]
  # Support two formats: numeric (budget only) or list(budget=..., year=...)
  if (is.list(entry) && !is.null(entry$budget)) {
    bg <- as.numeric(entry$budget)
    regionTargetYear <- if (!is.null(entry$year)) as.integer(entry$year) else selectedYear
  } else if (is.numeric(entry) && length(entry) == 1) {
    bg <- as.numeric(entry)
    regionTargetYear <- selectedYear
  } else {
    stop(sprintf("Invalid targetList entry for '%s' — must be numeric or list(budget=..., year=...)", regName))
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

  message(sprintf("\n--- Optimizing %s (Target: %.4f, Year: %d) ---", displayName, bg, regionTargetYear))
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

  brkt <- autoBracketFromSeed(
    seedAlpha    = 0.1,
    budgetTarget = bg,
    envWide      = currentEnvWide,
    yearCols     = yearCols,
    targetRegion = actualRegion,
    targetYear   = regionTargetYear,
    minAlpha     = -0.5,           # Allow price reduction up to -50% if needed
    maxAlpha     = 40.0,           # Allow up to +1000% increase
    expandFactor = 4.0,
    maxProbes    = 7,
    verbose      = TRUE
  )

  # C. Solve (skip the root-find when the region already meets its target unchanged)
  if (isTRUE(brkt$alreadyMet)) {
    finalAlpha <- 0
    message(sprintf(" -> %s already meets target; carbon prices left unchanged (Alpha=0).", displayName))
  } else {
    solveResult <- findAlphaForBudget(
      envWide      = currentEnvWide,
      yearCols     = yearCols,
      budgetTarget = bg,
      targetRegion = actualRegion, # Passes NULL if global
      targetYear   = regionTargetYear,
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
    message(sprintf(" -> Converged %s: Alpha=%.3f", displayName, finalAlpha))
  }

  # Apply converged alpha and persist as the new baseline for subsequent regions
  currentEnvWide <- applyAlpha(currentEnvWide, yearCols, finalAlpha, actualRegion)
  fwrite(currentEnvWide, inputCsvPath, na = "NA")
  file.copy(inputCsvPath, backupCsvPath, overwrite = TRUE)
  resultsLog[[regName]] <- list(status = "OK", alpha = finalAlpha)

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
for (r in names(resultsLog)) {
  item <- resultsLog[[r]]
  if (item$status == "OK") {
    message(sprintf(" [OK]     %s : Alpha = %.3f", r, item$alpha))
  } else {
    message(sprintf(" [FAILED] %s : %s", r, item$error))
  }
}

sink(type = "message")
sink()

writeFinalPolicyFiles(currentEnvWide, yearCols, 0.0, NULL)
message(sprintf("Done. Total time: %s", Sys.time() - start_time))
