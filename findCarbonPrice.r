# ============================================================

# ============================================================

suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(quitte)
  library(gdx)
  library(postprom)
})

# ----------------------------
# Paths & basic parameters
# ----------------------------
inputCsvPath   <- "data/iEnvPolicies - Copy.csv"
outputCsvPath  <- "data/iEnvPolicies_updated.csv"   # human-friendly copy after convergence
backupCsvPath  <- "data/iEnvPolicies_backup.csv"    # backup of the original input
workDir        <- getwd()

# One-time backup of the original canonical file before any overwrite
if (file.exists(inputCsvPath) && !file.exists(backupCsvPath)) {
  dir.create(dirname(backupCsvPath), showWarnings = FALSE, recursive = TRUE)
  file.copy(inputCsvPath, backupCsvPath, overwrite = FALSE)
}

# -----------------------------------
# Load file & get it into tidy form
# -----------------------------------
readEnvPolicies <- function(csvPath = inputCsvPath) {
  envWide <- data.table::fread(csvPath, na.strings = c("NA", "", "NaN"), header = TRUE)

  if (ncol(envWide) < 3) stop("Unexpected file structure: less than 3 columns found.")
  colnames(envWide)[1:2] <- c("region", "policy")

  yearCols <- grep("^[0-9]{4}$", names(envWide), value = TRUE)
  if (length(yearCols) == 0) stop("No year columns found (4-digit column names expected).")

  envLong <- envWide |>
    as_tibble() |>
    pivot_longer(cols = all_of(yearCols), names_to = "year", values_to = "value") |>
    mutate(year = as.integer(year))

  list(envWide = envWide, envLong = envLong, yearCols = yearCols)
}

envData <- readEnvPolicies(inputCsvPath)

# ---------------------------------------------------------
# Simulator wrappers and IO helpers
# ---------------------------------------------------------
run_gams <- function(
  gms = "main.gms",
  args = c("--DevMode=1", "--GenerateInput=off", "lo=4", "idir=./data"),
  log = "full.log",
  echo_on_success = FALSE
) {
  if (!file.exists(gms)) stop("OPEN-PROM not found: ", gms)
  message("Executing OPEN-PROM: ", gms)
  status <- system2("gams", args = c(gms, args), stdout = log, stderr = log)

  if (status == 0) {
    message("OPEN-PROM finished successfully (exit code 0).")
    if (echo_on_success) {
      cat("\n--- Tail of log ---\n")
      lg <- tryCatch(readLines(log, warn = FALSE), error = function(e) character())
      if (length(lg)) cat(utils::tail(lg, 5), sep = "\n")
    }
    return(TRUE)
  } else {
    msg <- paste0("OPEN-PROM exited with code ", status, ". See ", log, " for details.")
    warning(msg, call. = FALSE)
    cat("\n--- Tail of log ---\n")
    lg <- tryCatch(readLines(log, warn = FALSE), error = function(e) character())
    if (length(lg)) cat(utils::tail(lg, 60), sep = "\n")
    return(FALSE)
  }
}

applyAlphaToEnvPolicies <- function(envWide, yearCols, alpha) {
  envUpdated <- data.table::copy(envWide)
  envUpdated[, (yearCols) := lapply(.SD, function(col) col * alpha), .SDcols = yearCols]
  envUpdated
}

# write canonical + updated + optional timestamped archive
writeFinalPolicyFiles <- function(envWide, yearCols, alphaFinal,
                                  canonicalPath = file.path("data","iEnvPolicies.csv"),
                                  updatedPath   = file.path("data","iEnvPolicies_updated.csv"),
                                  alsoTimestamped = TRUE) {
  envFinal <- applyAlphaToEnvPolicies(envWide, yearCols, alphaFinal)

  dir.create(dirname(canonicalPath), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(updatedPath),   showWarnings = FALSE, recursive = TRUE)

  data.table::fwrite(envFinal, canonicalPath, na = "NA")
  data.table::fwrite(envFinal, updatedPath,   na = "NA")

  if (alsoTimestamped) {
    ts <- format(Sys.time(), "%Y%m%d-%H%M%S")
    tsPath <- sub("\\.csv$", paste0("_", ts, ".csv"), updatedPath)
    data.table::fwrite(envFinal, tsPath, na = "NA")
  }
}

# Run model for a given alpha 
emissionsOPENPROM <- function(envWide, yearCols, alpha,
                              dataDir = "data",
                              gamsArgs = c("--DevMode=1", "--GenerateInput=off", "lo=4", "idir=./data"),
                              reportScript = "reportOutput.R",
                              log = "full.log",
                              echo_on_success = FALSE) {

  canonicalCsv <- file.path(dataDir, "iEnvPolicies.csv")
  envTmp <- applyAlphaToEnvPolicies(envWide, yearCols, alpha)
  data.table::fwrite(envTmp, canonicalCsv, na = "NA")

  ok <- run_gams(args = gamsArgs, log = log, echo_on_success = echo_on_success)
  if (!ok) stop("OPEN-PROM run failed for alpha=", alpha)

  # Read csv emissions file, add CO2 emissions and sum all CO2
  # r_out <- tryCatch(
  #   system2("Rscript", args = c(reportScript, workDir), stdout = TRUE, stderr = TRUE),
  #   error = function(e) e
  # )
  # if (inherits(r_out, "error")) stop("reportOutput.R failed: ", conditionMessage(r_out))

  # emisFile <- file.path(workDir, "emissions.csv")
  # if (!file.exists(emisFile)) stop("emissions.csv not found after run. Did reportOutput.R create it?")
  # annualEmissions <- read.csv(emisFile, check.names = FALSE)

  # keep <- c("Emissions|CO2|AFOLU", "Emissions|CO2|Energy and Industrial Processes")
  # annualCO2 <- annualEmissions[annualEmissions$Variable %in% keep, ]
  # numericData <- annualCO2[sapply(annualCO2, is.numeric)]
  # cumulatedCO2Gt <- sum(as.matrix(numericData), na.rm = TRUE) / 1000

  # Instead of running and reading the csv files run some commands from postprom
  regions <- readGDX(file.path(workDir, "blabla.gdx"), "runCYL")
  years <- as.character(c(2010:2020))
  years <- c(years, as.character(readGDX(file.path(workDir,"blabla.gdx"), "an")))
  years <- paste0("y", years)
  emissions <- reportEmissions(file.path(workDir, "blabla.gdx"), regions, years)

  # Calculate the sum for the 'not Price' items
  items <- getItems(emissions, 3)
  getItemsNot <- items[!grepl("^Price|^Activity growth rate", items)]

  # Calculate the sum for the 'not Price' items
  addRegionGLO <- dimSums(emissions[, , getItemsNot], 1, na.rm = TRUE)
  getItems(addRegionGLO, 1) <- "World"
  emissionsWorld <- mbind(emissions, addRegionGLO)
  cumulatedCO2Gt <- as.numeric(emissionsWorld["World", 2100,"Emissions|CO2|Cumulated.Gt CO2"])

  return(cumulatedCO2Gt)
}

# ---------------------------------------------------------
# Alpha seeding + auto-bracketing helpers
# ---------------------------------------------------------
alpha_seed_from_two_points <- function(alpha0, E0, alphar, Er, Etarget,
                                       shape = c("loglin","power")) {
  shape <- match.arg(shape)
  stopifnot(E0 > 0, Er > 0, Etarget > 0)
  if (shape == "loglin") {
    k <- log(E0/Er) / (alphar - alpha0)
    if (!is.finite(k) || k == 0) stop("Could not infer k for log-linear seed.")
    return(alpha0 - log(Etarget/E0) / k)
  } else {
    if (alphar <= 0 || alpha0 <= 0) stop("Power-law needs positive alphas.")
    eta <- log(E0/Er) / log(alphar/alpha0)
    if (!is.finite(eta) || eta == 0) stop("Could not infer eta for power-law seed.")
    return(alpha0 * (E0/Etarget)^(1/eta))
  }
}

probe_emissions <- function(a, envWide, yearCols, simulateFn, simulatorArgs) {
  do.call(simulateFn, append(list(envWide=envWide, yearCols=yearCols, alpha=a), simulatorArgs))
}

auto_bracket_from_seed <- function(seedAlpha,
                                   budgetTarget,
                                   envWide, yearCols,
                                   simulateFn, simulatorArgs,
                                   minAlpha = 0.0,
                                   maxAlpha = 5.0,
                                   expandFactor = 1.35,
                                   maxProbes = 20,
                                   verbose = TRUE) {
  if (verbose) message(sprintf("Seeding bracket near alpha ≈ %.4f", seedAlpha))

  Eseed <- probe_emissions(seedAlpha, envWide, yearCols, simulateFn, simulatorArgs)
  if (verbose) message(sprintf("Seed probe: alpha=%.4f → E=%.6f (target=%.6f)", seedAlpha, Eseed, budgetTarget))

  if (Eseed <= budgetTarget) {
    aU <- seedAlpha; EU <- Eseed
    aL <- max(minAlpha, seedAlpha / expandFactor)
    tries <- 0
    repeat {
      EL <- probe_emissions(aL, envWide, yearCols, simulateFn, simulatorArgs); tries <- tries + 1
      if (verbose) message(sprintf("Down probe: alpha=%.4f → E=%.6f", aL, EL))
      if (EL > budgetTarget || tries >= maxProbes || aL <= minAlpha + 1e-9) break
      aL <- max(minAlpha, aL / expandFactor)
    }
    if (EL <= budgetTarget) stop("Could not find a failing lower bound; decrease minAlpha or revisit monotonicity.")
  } else {
    aL <- seedAlpha; EL <- Eseed
    aU <- min(maxAlpha, seedAlpha * expandFactor)
    tries <- 0
    repeat {
      EU <- probe_emissions(aU, envWide, yearCols, simulateFn, simulatorArgs); tries <- tries + 1
      if (verbose) message(sprintf("Up probe: alpha=%.4f → E=%.6f", aU, EU))
      if (EU <= budgetTarget || tries >= maxProbes || aU >= maxAlpha - 1e-9) break
      aU <- min(maxAlpha, aU * expandFactor)
    }
    if (EU > budgetTarget) stop("Could not find a passing upper bound; increase maxAlpha or revisit monotonicity.")
  }

  list(lowerAlpha = aL, upperAlpha = aU, EL = EL, EU = EU)
}

# ---------------------------------------------------------
# Bisection solver
# ---------------------------------------------------------
findAlphaForBudget <- function(envWide,
                               yearCols,
                               budgetTarget,
                               simulateFn,
                               simulatorArgs = list(),
                               lowerAlpha = 0.0,
                               upperAlpha = 1.5,
                               tolAlphaRel = 1e-3,
                               tolEmisAbs = 1e-3,
                               maxIter = 60,
                               verbose = TRUE,
                               writeFinalCsv = TRUE) {

  runAt <- function(a) {
    do.call(simulateFn, append(list(envWide = envWide, yearCols = yearCols, alpha = a), simulatorArgs))
  }

  eLow  <- runAt(lowerAlpha)
  eHigh <- runAt(upperAlpha)

  if (verbose) {
    message(sprintf("Initial: alpha_low=%.6f -> Emis=%.6f; alpha_high=%.6f -> Emis=%.6f; target=%.6f",
                    lowerAlpha, eLow, upperAlpha, eHigh, budgetTarget))
  }

  # We assume emissions decrease with alpha
  if (eLow <= budgetTarget) {
    if (verbose) message("lowerAlpha already meets budget; returning lowerAlpha.")
    if (writeFinalCsv) {
      writeFinalPolicyFiles(envWide, yearCols, lowerAlpha,
                            canonicalPath = file.path("data","iEnvPolicies.csv"),
                            updatedPath   = outputCsvPath,
                            alsoTimestamped = TRUE)
    }
    return(list(alpha = lowerAlpha, emissions = eLow, converged = TRUE, iters = 0))
  }
  if (eHigh > budgetTarget) {
    stop("upperAlpha still exceeds budget. Increase upperAlpha or check monotonicity/feasibility.")
  }

  aL <- lowerAlpha; aU <- upperAlpha
  emisL <- eLow;     emisU <- eHigh
  it <- 0

  while (it < maxIter) {
    it <- it + 1
    aM <- 0.5 * (aL + aU)
    emisM <- runAt(aM)

    if (verbose) {
      message(sprintf("Iter %02d: alpha_mid=%.6f -> Emis=%.6f (target=%.6f)", it, aM, emisM, budgetTarget))
    }

    if (emisM > budgetTarget) { aL <- aM; emisL <- emisM } else { aU <- aM; emisU <- emisM }

    if ((abs(aU - aL) / max(1.0, aM) < tolAlphaRel) || (abs(emisM - budgetTarget) < tolEmisAbs)) {
      if (verbose) message("Converged.")
      if (writeFinalCsv) {
        writeFinalPolicyFiles(envWide, yearCols, aU,
                              canonicalPath = file.path("data","iEnvPolicies.csv"),
                              updatedPath   = outputCsvPath,
                              alsoTimestamped = TRUE)
      }
      return(list(alpha = aU, emissions = emisU, converged = TRUE, iters = it))
    }
  }

  warning("Max iterations reached without strict tolerance convergence.")
  if (writeFinalCsv) {
    writeFinalPolicyFiles(envWide, yearCols, aU,
                          canonicalPath = file.path("data","iEnvPolicies.csv"),
                          updatedPath   = outputCsvPath,
                          alsoTimestamped = TRUE)
  }
  list(alpha = aU, emissions = emisU, converged = FALSE, iters = it)
}

# ---------------------------------------------------------
# Seed, auto-bracket, solve
# ---------------------------------------------------------

# Define your available/allowed cumulative carbon budget (Gt CO2)
budgetTarget <- 1000

# ---- Option A (recommended if you have reported points) ----
# Replace these with your real numbers from two runs with matching scope/units.
# alpha0 <- 1.00; E0 <- 1200    # emissions at α=1.0
# alphar <- 1.20; Er <- 980     # emissions at α=1.2
# seedAlpha <- alpha_seed_from_two_points(alpha0, E0, alphar, Er, Etarget = budgetTarget, shape = "loglin")

# ---- Option B (fallback if you don't have reported points) ----
seedAlpha <- 1.20

# Auto-bracket around the seed (runs a few probe simulations)
brkt <- auto_bracket_from_seed(
  seedAlpha     = seedAlpha,
  budgetTarget  = budgetTarget,
  envWide       = envData$envWide,
  yearCols      = envData$yearCols,
  simulateFn    = emissionsOPENPROM,
  simulatorArgs = list(
    dataDir = "data",
    gamsArgs = c("--DevMode=1", "--GenerateInput=off", "lo=4", "idir=./data"),
    reportScript = "reportOutput.R",
    log = "full.log",
    echo_on_success = FALSE
  ),
  minAlpha = 0.0,
  maxAlpha = 5.0,
  expandFactor = 1.35,
  maxProbes = 12,
  verbose = TRUE
)
message(sprintf("Auto-bracket: [%.4f, %.4f]", brkt$lowerAlpha, brkt$upperAlpha))

# Solve with robust bisection using the bracket
solveResult <- findAlphaForBudget(
  envWide       = envData$envWide,
  yearCols      = envData$yearCols,
  budgetTarget  = budgetTarget,
  simulateFn    = emissionsOPENPROM,
  simulatorArgs = list(
    dataDir = "data",
    gamsArgs = c("--DevMode=1", "--GenerateInput=off", "lo=4", "idir=./data"),
    reportScript = "reportOutput.R",
    log = "full.log",
    echo_on_success = FALSE
  ),
  lowerAlpha    = brkt$lowerAlpha,
  upperAlpha    = brkt$upperAlpha,
  tolAlphaRel   = 1e-2,
  tolEmisAbs    = 1e-1,
  maxIter       = 60,
  verbose       = TRUE,
  writeFinalCsv = TRUE
)

alphaStar <- solveResult$alpha
message(sprintf("Chosen alpha = %.3f; simulated cumulative emissions = %.6f; converged=%s; iters=%d",
                alphaStar, solveResult$emissions, solveResult$converged, solveResult$iters))
message(sprintf("Canonical updated: %s", file.path("data","iEnvPolicies.csv")))
message(sprintf("Human-friendly copy: %s", outputCsvPath))
message(sprintf("Backup of original: %s", backupCsvPath))

end_time <- Sys.time()
end_time-start_time