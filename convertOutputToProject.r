
# Helper functions
convertUnitsToExpected <- function(
  magpieObj,
  unitTable,                 # data.frame with columns: variable, magpieUnit, expectedUnit, unitMatches
  usd2015to2010,             # numeric scalar: multiply 2015 USD to get 2010 USD
  allowUnrecognized = FALSE, # if TRUE, skip unsupported conversions with a warning
  quiet = FALSE              # if FALSE, prints a short audit summary
) {

  trim <- function(x) trimws(as.character(x))
  cleanVar <- function(x) sub("\\s*\\(.*\\)$", "", x) # drop trailing " (unit)"
  safeEq <- function(a, b) trim(a) == trim(b)

  # normalize unit strings (case-insensitive)
  normUnit <- function(u) {
    u <- trim(u)
    u <- gsub("KWh", "kWh", u, fixed = TRUE) # harmonize capitalization
    u <- gsub("US\\$","USD_", u)             # normalize currency prefix
    u <- gsub("USD__", "USD_", u)            # double underscore guard
    u <- gsub("tn CO2", "t CO2", u, fixed = TRUE) # treat tn and t as same
    u
  }

  # exact constants (audited)
  TOE_PER_GJ   <- 1/41.868             # toe per GJ (for per-energy prices)
  GJ_PER_TOE   <- 41.868               # GJ per toe
  EJ_PER_MTOE  <- 0.041868             # EJ per Mtoe
  EJ_PER_TWH   <- 0.0036               # EJ per TWh
  GJ_PER_KWH   <- 0.0036               # GJ per kWh
  KWH_PER_GJ   <- 1 / GJ_PER_KWH       # 277.7777777778
  BILLION_TO_MILLION <- 1000

  # compute factor for one pair of units
  computeFactor <- function(fromU, toU) {
    fromU0 <- normUnit(fromU)
    toU0   <- normUnit(toU)

    # identical after normalization -> factor 1
    if (fromU0 == toU0) return(1)

    # ---- energy quantity flows ----
    # Mtoe -> EJ(/yr)
    if (fromU0 == "Mtoe" && grepl("^EJ", toU0)) return(EJ_PER_MTOE)

    # TWh -> EJ(/yr)
    if (fromU0 == "TWh" && grepl("^EJ", toU0)) return(EJ_PER_TWH)

    # ---- population ----
    if (fromU0 == "billion" && toU0 == "million") return(BILLION_TO_MILLION)

    # ---- prices ----
    # KUSD_2015/toe -> USD_2010/GJ
    if (fromU0 == "KUSD_2015/toe" && toU0 == "USD_2010/GJ")
      return(1000 * usd2015to2010 * (1 / GJ_PER_TOE))  # ×1000 (KUSD->USD) × deflator × 1/41.868

    # USD_2015/kWh -> USD_2010/GJ
    if (fromU0 == "USD_2015/kWh" && toU0 == "USD_2010/GJ")
      return(usd2015to2010 * KWH_PER_GJ)               # × deflator × 277.777...

    # US$2015/KWh cases may have been normalized above
    if (fromU0 == "USD_2015/kWh" && toU0 == "USD_2010/GJ")
      return(usd2015to2010 * KWH_PER_GJ)

    # Carbon price: USD_2015/t CO2 -> USD_2010/t CO2
    if (fromU0 == "USD_2015/t CO2" && toU0 == "USD_2010/t CO2")
      return(usd2015to2010)

    # Some sources write USD_2015/tn CO2; normalized to t CO2 above
    if (fromU0 == "USD_2015/t CO2" && toU0 == "USD_2010/t CO2")
      return(usd2015to2010)

    # ---- macro aggregates ----
    # GDP: billion USD_2015/yr -> billion USD_2010/yr
    if (fromU0 == "billion USD_2015/yr" && toU0 == "billion USD_2010/yr")
      return(usd2015to2010)

    # ---- unsupported pair ----
    return(NA_real_)
  }

  # current 3rd-dimension item names and their clean labels
  curNames <- magclass::getItems(magpieObj, dim = 3)
  curClean <- cleanVar(curNames)

  # keep only rows that actually differ and exist in the object
  unitTable$variable    <- trim(unitTable$variable)
  unitTable$magpieUnit  <- trim(unitTable$magpieUnit)
  unitTable$expectedUnit<- trim(unitTable$expectedUnit)

  toFix <- subset(unitTable, !isTRUE(unitMatches))
  toFix <- toFix[toFix$variable %in% curClean, , drop = FALSE]

  if (nrow(toFix) == 0L) {
    if (!quiet) message("No unit mismatches found to convert.")
    return(list(object = magpieObj, log = data.frame(), skipped = character()))
  }

  # containers for audit
  audit <- list()
  skipped <- character()

  # perform conversions variable by variable
  for (i in seq_len(nrow(toFix))) {
    v   <- toFix$variable[i]
    uIn <- toFix$magpieUnit[i]
    uEx <- toFix$expectedUnit[i]

    idx <- which(curClean == v)
    if (!length(idx)) next

    factor <- computeFactor(uIn, uEx)

    if (is.na(factor)) {
      msg <- paste0("Unsupported conversion: '", uIn, "' -> '", uEx, "' for variable '", v, "'.")
      if (allowUnrecognized) {
        warning(msg)
        skipped <- c(skipped, v)
        next
      } else {
        stop(msg, call. = FALSE)
      }
    }

    # scale values
    magpieObj[,, idx] <- magpieObj[,, idx] * factor

    # update unit label in the 3rd-dimension name(s)
    curNames[idx] <- paste0(v, " (", uEx, ")")

    # add to audit
    audit[[length(audit) + 1]] <- data.frame(
      variable    = v,
      fromUnit    = uIn,
      toUnit      = uEx,
      factorUsed  = factor,
      stringsAsFactors = FALSE
    )
  }

  # write back updated names
  getItems(magpieObj, dim = 3) <- curNames

  auditDf <- if (length(audit)) do.call(rbind, audit) else data.frame()

  if (!quiet && nrow(auditDf)) {
    message("Converted ", nrow(auditDf), " variables. Example:\n",
            utils::capture.output(print(utils::head(auditDf), row.names = FALSE)) |> paste(collapse = "\n"))
    if (length(skipped)) message("Skipped (unsupported): ", paste(unique(skipped), collapse = "; "))
  }

  return(list(object = magpieObj, log = auditDf, skipped = unique(skipped)))
}


lapply(c("mrprom","madrat","readxl","dplyr","tidyr","quitte","postprom","gdx","openxlsx"), require, character.only = TRUE)

# --- Read data ---
dataMagpie <- read.report("C:\\Users\\at39\\2-Models\\OPEN-PROM\\runs\\1.5CnewCCSAndHydrogenCleanupNewCPrice_2025-10-14_16-32-21\\reporting.mif")
scenarioName <- names(dataMagpie)[1]
modelName <- names(dataMagpie[[1]])[1]
dataMagpie <- dataMagpie[[1]][[1]]
project <- read.csv("C:\\Users\\at39\\2-Models\\socdr-edition-3-template.csv")

# --- Mapping ---
map <- toolGetMapping(
  name = "prom-socdr-edition-3-template.csv",
  type = "sectoral",
  where = "mrprom"
)

# --- Extract variable names and units ---
varNames <- getItems(dataMagpie, dim = 3)
varsClean <- trimws(gsub("\\s*\\(.*\\)$", "", varNames))
units <- gsub(".*\\((.*)\\)$", "\\1", varNames)
hasUnits <- grepl("\\(.*\\)$", varNames)

# --- Rename setup ---
map$OPEN_PROM <- trimws(map$OPEN_PROM)
rename_lookup <- setNames(map$socdr_edition_3_template, map$OPEN_PROM)

# --- Rename variables ---
renamedVars <- ifelse(varsClean %in% names(rename_lookup),
                      rename_lookup[varsClean],
                      varsClean)

# --- Preserve units ---
renamedVarsFinal <- ifelse(hasUnits,
                           paste0(renamedVars, " (", units, ")"),
                           renamedVars)

# --- Apply names to magpie object ---
getItems(dataMagpie, dim = 3) <- renamedVarsFinal

# --- Clean renamed variable list ---
renamedClean <- gsub("\\s*\\(.*\\)$", "", renamedVarsFinal)

# --- Intersection with project variables ---
commonVars <- intersect(renamedClean, project$variable)

# --- Find indices in magpie object ---
keepIndices <- match(commonVars, renamedClean)

# --- Extract current units (after rename) ---
currentVarNames <- getItems(dataMagpie, dim = 3)
currentUnits <- gsub(".*\\((.*)\\)$", "\\1", currentVarNames)
currentUnits[!grepl("\\(.*\\)$", currentVarNames)] <- NA

# --- Get expected units from project ---
expectedUnits <- project$unit[match(commonVars, project$variable)]
commonUnits <- currentUnits[keepIndices]
unitMatch <- commonUnits == expectedUnits

# --- Build units table for checking---
checkUnits <- data.frame(
  variable = commonVars,
  magpieUnit = commonUnits,
  expectedUnit = expectedUnits,
  unitMatches = unitMatch,
  stringsAsFactors = FALSE
)
filteredMagpie <- dataMagpie[, , keepIndices]

# Run the conversion of units
usd2015to2010 <- 0.9253 # https://www.in2013dollars.com/us/inflation/2015?amount=15&endYear=2010

finalResults <- convertUnitsToExpected(
  magpieObj       = filteredMagpie,     
  unitTable       = checkUnits,
  usd2015to2010   = usd2015to2010,
  allowUnrecognized = FALSE,
  quiet           = TRUE
)
#print(finalResults$log)

# Add variables from the project needs as 0 values. 
# Select multiple tiers and get variable and units as vectors
selectedVariables <- project %>%
  filter(tier %in% c(1, 2)) %>%  
  pull(variable)                  
selectedUnits <- project %>%
  filter(tier %in% c(1, 2)) %>%  
  pull(unit)                 

combinedVector <- paste(selectedVariables, selectedUnits, sep = " (")  # needed formatting for units
combinedVector <- paste0(combinedVector, ")") 

allRegions <- getRegions(finalResults$object)
allYears <- getYears(finalResults$object)

tierMagpie <-new.magpie(cells = allRegions, years = allYears, names  = combinedVector, fill = 0)
names(dimnames(tierMagpie))[3] <- "variable"

finalDataMagpie <- mbind(finalResults$object,tierMagpie)

write.report(finalDataMagpie,"outputForSODR-3.mif", model = modelName, scenario = scenarioName)
