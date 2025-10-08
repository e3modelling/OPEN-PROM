# ============================================================
# Find Optimal Carbon price to reach a certain carbon budget
# ============================================================

# This script provides a tuner for the iEnvPolicies input used by the OPEN-PROM model: 
# it perturbs a baseline per-region policy time-series by a scalar alpha, runs the model, 
# and searches for the alpha that yields a specified cumulative CO₂ budget (Gt CO₂).
# Key features:
# Wraps model execution (run_gams) and post-processing via postprom/gdx helpers to extract cumulative world CO₂ in 2050 (emissionsOPENPROM).
# Applies a scalar multiplier to all year columns (applyAlpha) and writes final updated CSVs with optional timestamped backups (writeFinalPolicyFiles). 
# Provides seeding/bracketing logic (alphaSeedLinear, autoBracketFromSeed) and a bisection solver (findAlphaForBudget) to find an alpha that meets the budgetTarget.

# Dependencies: data.table, dplyr, tidyr, gdx, postprom and a working GAMS installation accessible via the gams command.
# Typical workflow: 
# 1) set budgetTarget - The budget target must take into account the emissions from the start of OPEN-PROM run, 
#                       e.g., budget=EmissIPCC(2020-2100)+Emiss(2010-2020 of OPEN-PROM)
# 2) ensure data/iEnvPolicies.csv and main.gms are present, 
# 3) then run the script — it will probe the model, bracket a root, bisect to tolerance, and save the final scaled carbon prices file.

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)    # for as_tibble() via tibble dependency
  library(tidyr)
  library(gdx)
  library(postprom)
})

# ----------------------------
# Paths
# ----------------------------
inputCsvPath   <- "data/iEnvPolicies.csv"
outputCsvPath  <- "data/iEnvPolicies_updated.csv"
backupCsvPath  <- "data/iEnvPolicies_backup.csv"
workDir        <- getwd()

# One-time backup of the original canonical file
if (file.exists(inputCsvPath) && !file.exists(backupCsvPath)) {
  dir.create(dirname(backupCsvPath), showWarnings = FALSE, recursive = TRUE)
  file.copy(inputCsvPath, backupCsvPath, overwrite = FALSE)
}

# ----------------------------
# IO helpers
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

applyAlpha <- function(envWide, yearCols, alpha) {
  x <- data.table::copy(envWide)
  # Identify only year columns >= 2025
  yearColsFuture <- yearCols[as.integer(yearCols) >= 2025]
  # Apply scaling only to those columns
  x[, (yearColsFuture) := lapply(.SD, function(col) col * alpha), .SDcols = yearColsFuture]
  x

}

writeFinalPolicyFiles <- function(envWide, yearCols, alphaFinal,
                                  canonicalPath = file.path("data","iEnvPolicies.csv"),
                                  updatedPath   = file.path("data","iEnvPolicies_updated.csv"),
                                  alsoTimestamped = TRUE) {
  envFinal <- applyAlpha(envWide, yearCols, alphaFinal)
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
# Simulator wrapper (fixed defaults)
# ----------------------------
run_gams <- function(gms = "main.gms",
                     args = c("--DevMode=0", "--GenerateInput=off", "lo=4", "idir=./data"),
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

# Returns cumulative CO2 (Gt) for a given alpha
emissionsOPENPROM <- function(envWide, yearCols, alpha,
                              dataDir = "data",
                              gms = "main.gms",
                              gamsArgs = c("--DevMode=0", "--GenerateInput=off", "lo=4", "idir=./data"),
                              log = "full.log",
                              echo_on_success = FALSE) {
  canonicalCsv <- file.path(dataDir, "iEnvPolicies.csv")
  on.exit({
    if (file.exists(backupCsvPath)) file.copy(backupCsvPath, canonicalCsv, overwrite = TRUE)
  }, add = TRUE)

  fwrite(applyAlpha(envWide, yearCols, alpha), canonicalCsv, na = "NA")
  ok <- run_gams(gms = gms, args = gamsArgs, log = log, echo_on_success = echo_on_success)
  if (!ok) stop("OPEN-PROM run failed for alpha=", alpha)

  # Post-process emissions via postprom
  regions <- readGDX(file.path(workDir, "blabla.gdx"), "runCYL")
  years   <- paste0("y", c(2010:2020, as.character(readGDX(file.path(workDir, "blabla.gdx"), "an"))))
  emissions <- reportEmissions(file.path(workDir, "blabla.gdx"), regions, years)

  items <- getItems(emissions, 3)
  keep  <- items[!grepl("^Price|^Activity growth rate", items)]
  addRegionGLO <- dimSums(emissions[, , keep], 1, na.rm = TRUE)
  getItems(addRegionGLO, 1) <- "World"
  emissionsWorld <- mbind(emissions, addRegionGLO)

  as.numeric(emissionsWorld["World", 2100, "Emissions|CO2|Cumulated.Gt CO2"])
}

# ----------------------------
# Seeding, bracketing, solving
# ----------------------------

 # linear interpolation
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

autoBracketFromSeed <- function(seedAlpha, budgetTarget, envWide, yearCols,
                                   minAlpha = 0.0, maxAlpha = 5.0,
                                   expandFactor = 1.35, maxProbes = 20, verbose = TRUE) {
  if (verbose) message(sprintf("Seeding bracket near alpha ≈ %.4f", seedAlpha))
  probe <- function(a) emissionsOPENPROM(envWide, yearCols, a)

  Eseed <- probe(seedAlpha)
  if (verbose) message(sprintf("Seed: alpha=%.4f → E=%.6f (target=%.6f)", seedAlpha, Eseed, budgetTarget))

  if (Eseed <= budgetTarget) {
    aU <- seedAlpha; EU <- Eseed
    aL <- max(minAlpha, seedAlpha / expandFactor); tries <- 0
    repeat {
      EL <- probe(aL); tries <- tries + 1
      if (verbose) message(sprintf("Down probe: alpha=%.4f → E=%.6f", aL, EL))
      if (EL > budgetTarget || tries >= maxProbes || aL <= minAlpha + 1e-9) break
      aL <- max(minAlpha, aL / expandFactor)
    }
    if (EL <= budgetTarget) stop("No failing lower bound; decrease minAlpha or revisit monotonicity.")
  } else {
    aL <- seedAlpha; EL <- Eseed
    aU <- min(maxAlpha, seedAlpha * expandFactor); tries <- 0
    repeat {
      EU <- probe(aU); tries <- tries + 1
      if (verbose) message(sprintf("Up probe: alpha=%.4f → E=%.6f", aU, EU))
      if (EU <= budgetTarget || tries >= maxProbes || aU >= maxAlpha - 1e-9) break
      aU <- min(maxAlpha, aU * expandFactor)
    }
    if (EU > budgetTarget) stop("No passing upper bound; increase maxAlpha or revisit monotonicity.")
  }
  list(lowerAlpha = aL, upperAlpha = aU, EL = EL, EU = EU)
}

findAlphaForBudget <- function(envWide, yearCols, budgetTarget,
                               lowerAlpha, upperAlpha,
                               eLow = NULL, eHigh = NULL,
                               tolAlphaRel = 1e-3, tolEmisAbs = 1e-3,
                               maxIter = 60, verbose = TRUE, writeFinalCsv = TRUE) {

  # If we dont run auto-seed, then we need to now the emissions in the lower and higher bounds.
  if (is.null(eLow))  eLow  <- emissionsOPENPROM(envWide, yearCols, lowerAlpha)
  if (is.null(eHigh)) eHigh <- emissionsOPENPROM(envWide, yearCols, upperAlpha)

  if (verbose) message(sprintf(
    "Initial: aL=%.6f -> E=%.6f; aU=%.6f -> E=%.6f; target=%.6f",
    lowerAlpha, eLow, upperAlpha, eHigh, budgetTarget))

  if (eLow <= budgetTarget) {
    if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, lowerAlpha)
    return(list(alpha = lowerAlpha, emissions = eLow, converged = TRUE, iters = 0))
  }
  if (eHigh > budgetTarget) stop("upperAlpha still exceeds budget. Increase it or check monotonicity.")

  aL <- lowerAlpha; aU <- upperAlpha
  emisL <- eLow;     emisU <- eHigh
  it <- 0

  while (it < maxIter) {
    it <- it + 1
    aM <- 0.5 * (aL + aU)
    emisM <- emissionsOPENPROM(envWide, yearCols, aM)
    if (verbose) message(sprintf("Iter %02d: aM=%.6f -> E=%.6f (target=%.6f)", it, aM, emisM, budgetTarget))

    if (emisM > budgetTarget) { aL <- aM; emisL <- emisM } else { aU <- aM; emisU <- emisM }
    if ((abs(aU - aL) / max(1.0, aM) < tolAlphaRel) || (abs(emisM - budgetTarget) < tolEmisAbs)) {
      if (verbose) message("Converged.")
      if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU)
      return(list(alpha = aU, emissions = emisU, converged = TRUE, iters = it))
    }
  }

  warning("Max iterations reached without strict tolerance convergence.")
  if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU)
  list(alpha = aU, emissions = emisU, converged = FALSE, iters = it)
}

# ----------------------------
# Run
# ----------------------------
start_time <- Sys.time()

budgetTarget <- 1521  # Gt CO2
envData <- readEnvPolicies(inputCsvPath)

# ---- Option A (Seed from two points) ----
# alpha0 <- 1.00; E0 <- 641.8802
# alphar <- 5.00; Er <- 

# alphaSeedLinear interpolates the alpha from two points
# seedAlpha <- alphaSeedLinear(alpha0, E0, alphar, Er, Etarget = budgetTarget)

# ---- Option B (fallback if you don't have reported points) - Alter manually ----
seedAlpha <- 0.5

# Auto-bracket around the seed (runs a few probe simulations)
brkt <- autoBracketFromSeed(
  seedAlpha    = seedAlpha,
  budgetTarget = budgetTarget,
  envWide      = envData$envWide,
  yearCols     = envData$yearCols,
  minAlpha     = 0.1,
  maxAlpha     = 1.0,
  expandFactor = 1.35,
  maxProbes    = 12,
  verbose      = TRUE
)
message(sprintf("Auto-bracket: [%.4f, %.4f]", brkt$lowerAlpha, brkt$upperAlpha))

solveResult <- findAlphaForBudget(
  envWide      = envData$envWide,
  yearCols     = envData$yearCols,
  budgetTarget = budgetTarget,
  lowerAlpha   = brkt$lowerAlpha,
  upperAlpha   = brkt$upperAlpha,
  eLow         = brkt$EL,
  eHigh        = brkt$EU,
  tolAlphaRel  = 1e-2,
  tolEmisAbs   = 1e-1,
  maxIter      = 60,
  verbose      = TRUE,
  writeFinalCsv = TRUE
)

alphaStar <- solveResult$alpha
message(sprintf("Chosen alpha = %.3f; simulated cumulative emissions = %.6f; converged=%s; iters=%d",
                alphaStar, solveResult$emissions, solveResult$converged, solveResult$iters))

message(sprintf("Final carbon prices : %s", outputCsvPath))
message(sprintf("Backup of original carbon prices: %s", backupCsvPath))

end_time <- Sys.time()
message(sprintf("Script running time: %s", end_time - start_time))
