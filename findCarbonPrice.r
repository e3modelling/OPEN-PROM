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
  library(mrprom)
  library(stringr)
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

applyAlpha <- function(envWide, yearCols, alpha, targetRegion) {
  x <- data.table::copy(envWide)
  
  # Identify only year columns >= 2025
  yearColsFuture <- yearCols[as.integer(yearCols) >= changeCarbonPriceFromYear]
  
  if (is.null(targetRegion)) {
    # --- GLOBAL MODE: Apply to ALL regions ---
    # Formula: new = old + (alpha * old)
    x[, (yearColsFuture) := lapply(.SD, function(col) col * (1 + alpha)), .SDcols = yearColsFuture]
  } else {
    # --- REGIONAL MODE: Apply to specific region only ---
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
# Simulator wrapper (fixed defaults)
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

# Returns cumulative CO2 (Gt) for a given alpha
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
  
  fwrite(applyAlpha(envWide, yearCols, alpha, targetRegion), canonicalCsv, na = "NA")
  ok <- run_gams(gms = gms, args = gamsArgs, log = log, echo_on_success = echo_on_success)
  if (!ok) stop("OPEN-PROM run failed for alpha=", alpha)

  # Post-process emissions via postprom
  regions <- readGDX(file.path(workDir, "blabla.gdx"), "runCYL")
  years   <- paste0("y", c(2010:2020, as.character(readGDX(file.path(workDir, "blabla.gdx"), "an"))))
  # Send text output to the void (nullfile) and suppress messages
  utils::capture.output({
      suppressMessages({
        suppressWarnings({
          emissions <- reportEmissions(file.path(workDir, "blabla.gdx"), regions, years)
        })
      })
    }, file = nullfile())


  items <- getItems(emissions, 3)
  keep  <- items[!grepl("^Price|^Activity growth rate", items)]
  addRegionGLO <- dimSums(emissions[, , keep], 1, na.rm = TRUE)
  getItems(addRegionGLO, 1) <- "World"
  emissionsWorld <- mbind(emissions, addRegionGLO)

  # Calculate GHG
  CO2eq <- calculateGhg(emissions)

  if (!is.null(targetRegion)) {
    # Specific Region Case
    val <- CO2eq[targetRegion, targetYear, ]
  } else {
    # ΕU Case: Sum over all regions (dim 1)
    # --- Filter for EU27 Regions ---
    regionMapping <- toolGetMapping(name = "EU28.csv", type = "regional", where = "mrprom")
    regionsEu27 <- regionMapping$ISO3.Code[regionMapping$ISO3.Code != "GBR"]
    dataMagpieEu27 <- CO2eq[getRegions(CO2eq) %in% regionsEu27, , ]

    val <- dimSums(dataMagpieEu27, dim = 1)[, targetYear, ]
  }
  
  # Always use Mt to be consistent for countries and regions
  as.numeric(val)

  #as.numeric(emissionsWorld["World", 2100, "Emissions|CO2|Cumulated.Gt CO2"])
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

autoBracketFromSeed <- function(seedAlpha, budgetTarget, envWide, yearCols, targetRegion, targetYear, 
                                   minAlpha = 0.0, maxAlpha = 5.0,
                                   expandFactor = 1.35, maxProbes = 20, verbose = TRUE) {
  if (verbose) message(sprintf("Seeding bracket near alpha ≈ %.4f", seedAlpha))
  probe <- function(a) emissionsOPENPROM(envWide, yearCols, a, targetRegion, targetYear)

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
                               eLow = NULL, eHigh = NULL, targetRegion, targetYear,
                               tolAlphaRel = 1e-3, tolEmisAbs = 1e-3,
                               maxIter = 60, verbose = TRUE, writeFinalCsv = TRUE) {

  # If we dont run auto-seed, then we need to now the emissions in the lower and higher bounds.
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

  while (it < maxIter) {
    it <- it + 1
    aM <- 0.5 * (aL + aU)
    emisM <- emissionsOPENPROM(envWide, yearCols, aM, targetRegion, targetYear)
    if (verbose) message(sprintf("Iter %02d: aM=%.6f -> E=%.6f (target=%.6f)", it, aM, emisM, budgetTarget))

    if (emisM > budgetTarget) { aL <- aM; emisL <- emisM } else { aU <- aM; emisU <- emisM }
    if ((abs(aU - aL) / max(1.0, aM) < tolAlphaRel) || (abs(emisM - budgetTarget) < tolEmisAbs)) {
      if (verbose) message("Converged.")
      if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU, targetRegion)
      return(list(alpha = aU, emissions = emisU, converged = TRUE, iters = it))
    }
  }

  warning("Max iterations reached without strict tolerance convergence.")
  if (writeFinalCsv) writeFinalPolicyFiles(envWide, yearCols, aU, targetRegion)
  list(alpha = aU, emissions = emisU, converged = FALSE, iters = it)
}
configureGamsFile <- function(gmsPath, targetRegion) {
  lines <- readLines(gmsPath, warn = FALSE)
  
  # Find the line with "$setGlobal fCountries" (ignoring spaces/case)
  idx <- grep("fCountries", lines, ignore.case = TRUE)
  
  if (length(idx) > 0) {
    # Replace that specific line completely
    lines[idx[1]] <- paste0("$setGlobal fCountries '", targetRegion, "'")
    message(sprintf("  -> Updated fCountries to '%s'", targetRegion))
    
    # Save the file
    writeLines(lines, gmsPath)
  } else {
    warning("Could not find 'fCountries' in main.gms")
  }
}
# --- Helper Function: Get CO2 Equivalent Factor ---
getCo2EqFactor <- function(varName) {
  # Define GWP Factors (AR4 100-year values standard for reporting)
  gwpMap <- c(
    "CH4"        = 25,
    "N2O"        = 298,
    "SF6"        = 22800,
    "HFC125"     = 3500,
    "HFC134a"    = 1430,
    "HFC143a"    = 4470,
    "HFC152a"    = 124,
    "HFC227ea"   = 3220,
    "HFC23"      = 14800,
    "HFC32"      = 675,
    "HFC43-10"   = 1640,
    "HFC245ca"   = 693,
    "HFC-236fa"  = 9810,
    "PFC"        = 7390,
    "CF4"        = 7390,
    "C2F6"       = 12200,
    "C6F14"      = 9300
  )
  
  cleanName <- sub("(\\s*\\(.*\\)|\\.[^.]*)$", "", varName)
  
  if (grepl("CH4", cleanName)) {
    return(gwpMap[["CH4"]])
  } else if (grepl("N2O", cleanName)) {
    return(gwpMap[["N2O"]] / 1000)
  } else {
    gasLeaf <- sub(".*\\|", "", cleanName)
    if (gasLeaf %in% names(gwpMap)) {
      return(gwpMap[[gasLeaf]] / 1000)
    } else {
      warning(paste("GWP not found for:", varName))
      return(0)
    }
  }
}
#' Calculate GHG Emissions (Mt CO2eq) from a magpie object
calculateGhg <- function(dataMagpie) {

  # --- Apply Conversion ---
  allVars <- getNames(dataMagpie)
  targetVars <- grep("Emissions\\|", allVars, value = TRUE)
  
  totalCo2Eq <- NULL
  
  for (var in targetVars) {
    factor <- getCo2EqFactor(var)
    
    if (factor != 0) {
      currentGas <- dataMagpie[, , var] * factor
      totalCo2Eq <- mbind(totalCo2Eq, currentGas)
    }
  }
  
  # Combine with Energy CO2
  if (flagCO2eq) {
    #emissions <- mbind(totalCo2Eq, dataMagpie[, , "Emissions|CO2|Energy and Industrial Processes.Mt CO2/yr"])
    emissions <- mbind(totalCo2Eq, dataMagpie[, , "Emissions|CO2.Mt CO2/yr"])
  } else {
    #emissions <- dataMagpie[, , "Emissions|CO2|Energy and Industrial Processes.Mt CO2/yr"]
    emissions <- dataMagpie[, , "Emissions|CO2.Mt CO2/yr"]
  }

  # --- Exclude Specific Variables (Fit for 55 logic) ---
  # emissions <- emissions[, , setdiff(getNames(emissions),
  #                                    c("Emissions|NOx|AFOLU. Mt NH3/yr",
  #                                      "Emissions|CH4|AFOLU|Land. Mt CH4/yr",
  #                                      "Emissions|N2O|AFOLU|Land. kt N2O/yr"))]
  
  # --- Aggregation ---
  emissionsCO2eq <- dimSums(emissions, dim = 3)
  getNames(emissionsCO2eq) <- "Emissions. Mt CO2-equiv/yr"

  return(emissionsCO2eq)
}

# ----------------------------
# Run
# ----------------------------
start_time <- Sys.time()
GAMSCmdArgs <- c("--DevMode=0", "--GenerateInput=off", "lo=4", "idir=./data")
selectedYear <- 2050
changeCarbonPriceFromYear <- 2031
flagCO2eq <- TRUE

# ---------------------------------------------------------
# CASE A: Specific Regions
# targetList <- list(
#   "AUT" = 30.3,
#   "BEL" = 64.305,
#   "BGR" = 36.45,
#   "HRV" = 11.3,
#   "CYP" = 2.5,
#   "CZE" = 86.5,
#   "DNK" = 35.3,
#   "EST" = 15.8,
#   "FIN" = 21.7,
#   "FRA" = 234.5,
#   "DEU" = 577.5,
#   "GRC" = 45.8,
#   "HUN" = 41.2,
#   "IRL" = 27.1,
#   "ITA" = 233.1,
#   "LVA" = 6.2,
#   "LTU" = 19.3,
#   "LUX" = 5.7,
#   "MLT" = 1.2,
#   "NLD" = 103.0,
#   "POL" = 201.3,
#   "PRT" = 29.7,
#   "ROU" = 103.7,
#   "SVK" = 29.1,
#   "SVN" = 6.5,
#   "ESP" = 114.0,
#   "SWE" = 9.0
# )
# targetConditionalMtCO2e MtCO2e/yr
# targetList <- list(
#   "CAZ" = 780.6,
#    "CHA" = 14373,
#    "GBR" = 260.3,
#    "IND" = 4816,
#    "JPN" = 760.32,
#    "LAM" = 3886,
#    "MEA" = 2164.6,
#    "NEU" = 832.1,
#    "OAS" = 5292.7,
#    "REF" = 3668,
#    "SSA" = 832.1
# )
# targetConditionalMtCO2 MtCO2/yr - ONLY CO2
# targetList <- list(
#   "CAZ" = 585,
#   "CHA" = 10780,
#   "GBR" = 195,
#   "IND" = 3612,
#   "JPN" = 570,
#   "LAM" = 2915,
#   "MEA" = 1623,
#   "NEU" = 624,
#   "OAS" = 3970,
#   "REF" = 2752,
#   "SSA" = 1735
# )
# targetConditionalMtCO2 MtCO2/yr - ONLY Emissions|CO2|Energy & Industrial Processes. MtCO2/yr
# targetList <- list(
#   "CAZ" = 777,
#   "CHA" = 11252,
#   "GBR" = 195,
#   "IND" = 3592,
#   "JPN" = 644,
#   "LAM" = 4177,
#   "MEA" = 1653,
#   "NEU" = 719,
#   "OAS" = 3583,
#   "REF" = 3813,
#   "SSA" = 2113
# )
targetList <- NULL
# CASE B: No Target Regions (Empty List) -> Implies EU27 Run
#globalParams <- 1750 # EU-27 target 2030 in MtCO2/yr - ONLY CO2
#globalParams <- 2250  # EU-27 target 2030 in MtCO2e/yr 
globalParams <- 0  # EU-27 target 2030 in MtCO2e/yr 
# LOGGING SETUP
logFilePath <- "Carbon_price_optimization.log"
file.create(logFilePath)
logCon <- file(logFilePath, open = "a")
# ---------------------------------------------------------

envData <- readEnvPolicies(inputCsvPath)
currentEnvWide <- envData$envWide
yearCols       <- envData$yearCols

# Backup original state
if (file.exists(inputCsvPath)) file.copy(inputCsvPath, backupCsvPath, overwrite = TRUE)

# PREPARE THE LOOP LIST
if (length(targetList) > 0) {
  # We have specific countries
  runQueue <- targetList
  message("Mode: Sequential Regional Optimization")
} else {
  # We have NO specific countries -> Global Mode
  # We use "NULL" as the key to signal global or EU mode to our loop
  runQueue <- list("GLOBAL" = globalParams)
  message("Mode: Global Optimization (No specific regions defined)")
}

# Redirect standard output and messages to the file connection
sink(logCon, type = "output")
sink(logCon, type = "message")

# We use on.exit to ensure console comes back even if script crashes!
on.exit({
  sink(type = "message") # Restore messages
  sink()                 # Restore output
  close(logCon)          # Close file
  message("Log redirection ended. Console restored.")
}, add = TRUE)
resultsLog <- list()

# Countries/Regions Loop
for (regName in names(runQueue)) {
  
  bg <- runQueue[[regName]]
  
  # Determine if this is a real region code or Global mode
  if (regName == "GLOBAL") {
    actualRegion <- NULL  # Pass NULL to helpers for Global
    displayName  <- "World"
  } else {
    actualRegion <- regName # Pass "DEU", "FRA", etc.
    displayName  <- regName
  }

  message(sprintf("\n--- Optimizing %s (Target: %.4f Mt) ---", displayName, bg))
  skipRegion <- FALSE
  
  tryCatch({
  # A. Update GAMS File (Only needed for specific regions)
  if (!is.null(actualRegion)) {
    configureGamsFile("main.gms", actualRegion)
  }

  # B. Auto-Bracket
  # Note: alpha is now a change factor. 0.0 = No change. 1.0 = +100% (Double price).
  brkt <- autoBracketFromSeed(
    seedAlpha    = 0.2,            
    budgetTarget = bg,
    envWide      = currentEnvWide,
    yearCols     = yearCols,
    targetRegion = actualRegion,
    targetYear   = selectedYear,
    minAlpha     = -0.5,           # Allow price reduction up to -50% if needed
    maxAlpha     = 10.0,           # Allow up to +1000% increase
    expandFactor = 2.0,
    maxProbes    = 12,
    verbose      = TRUE
  )

  # C. Solve
  solveResult <- findAlphaForBudget(
    envWide      = currentEnvWide,
    yearCols     = yearCols,
    budgetTarget = bg,
    targetRegion = actualRegion, # Passes NULL if global
    targetYear   = selectedYear,
    lowerAlpha   = brkt$lowerAlpha,
    upperAlpha   = brkt$upperAlpha,
    eLow         = brkt$EL,
    eHigh        = brkt$EU,
    tolAlphaRel  = 1e-2,
    tolEmisAbs   = 1e-1,
    maxIter      = 60,
    verbose      = TRUE,
    writeFinalCsv = FALSE
  )
  
  finalAlpha <- solveResult$alpha
  message(sprintf(" -> Converged %s: Alpha=%.3f", displayName, finalAlpha))

  # D. Update State & Backup
  currentEnvWide <- applyAlpha(currentEnvWide, yearCols, finalAlpha, actualRegion)
  fwrite(currentEnvWide, inputCsvPath, na = "NA")
  file.copy(inputCsvPath, backupCsvPath, overwrite = TRUE)
  resultsLog[[regName]] <- list(status="OK", alpha=finalAlpha)
}, error = function(e) {
    
    # --- FAILURE HANDLER ---
    message(sprintf("  !! FAILURE for %s !!", displayName))
    message(sprintf("  Error: %s", e$message))
    message("  -> Reverting file to previous state and skipping...")
    
    # Revert 'iEnvPolicies.csv' to the last known good state (backupCsvPath)
    if (file.exists(backupCsvPath)) {
      file.copy(backupCsvPath, inputCsvPath, overwrite = TRUE)
    }
    
    # Log the failure
    resultsLog[[regName]] <<- list(status = "FAILED", error = e$message)
    skipRegion <<- TRUE
  })
  
  if (skipRegion) next # Jump to the next country immediately
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
# FINAL WRAP UP
sink(type = "message")
sink()

# FINISH
writeFinalPolicyFiles(currentEnvWide, yearCols, 0.0, NULL)
message(sprintf("Done. Total time: %s", Sys.time() - start_time))

# # ---- Option A (Seed from two points) ----
# # alpha0 <- 1.00; E0 <- 641.8802
# # alphar <- 5.00; Er <- 

# # alphaSeedLinear interpolates the alpha from two points
# # seedAlpha <- alphaSeedLinear(alpha0, E0, alphar, Er, Etarget = budgetTarget)

# # ---- Option B (fallback if you don't have reported points) - Alter manually ----
# seedAlpha <- 3

# # Auto-bracket around the seed (runs a few probe simulations)
# brkt <- autoBracketFromSeed(
#   seedAlpha    = seedAlpha,
#   budgetTarget = budgetTarget,
#   envWide      = envData$envWide,
#   yearCols     = envData$yearCols,
#   targetRegion = targetRegion,
#   minAlpha     = 1.0,
#   maxAlpha     = 6.0,
#   expandFactor = 1.35,
#   maxProbes    = 12,
#   verbose      = TRUE
# )
# message(sprintf("Auto-bracket: [%.4f, %.4f]", brkt$lowerAlpha, brkt$upperAlpha))

# solveResult <- findAlphaForBudget(
#   envWide      = envData$envWide,
#   yearCols     = envData$yearCols,
#   budgetTarget = budgetTarget,
#   lowerAlpha   = brkt$lowerAlpha,
#   upperAlpha   = brkt$upperAlpha,
#   eLow         = brkt$EL,
#   eHigh        = brkt$EU,
#   targetRegion = targetRegion,
#   tolAlphaRel  = 1e-2,
#   tolEmisAbs   = 1e-1,
#   maxIter      = 60,
#   verbose      = TRUE,
#   writeFinalCsv = TRUE
# )

# alphaStar <- solveResult$alpha
# message(sprintf("Chosen alpha = %.3f; simulated cumulative emissions = %.6f; converged=%s; iters=%d",
#                 alphaStar, solveResult$emissions, solveResult$converged, solveResult$iters))

# message(sprintf("Final carbon prices : %s", outputCsvPath))
# message(sprintf("Backup of original carbon prices: %s", backupCsvPath))

# end_time <- Sys.time()
# message(sprintf("Script running time: %s", end_time - start_time))
