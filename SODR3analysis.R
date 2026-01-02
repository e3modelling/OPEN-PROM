lapply(c("mrprom", "madrat", "readxl", "dplyr", "tidyr", "quitte", "postprom", "gdx", "openxlsx", "stringr"), require, character.only = TRUE)

# Define a function to generate the multiplier to get to Mt CO2eq based on the gas name
getCo2EqFactor <- function(varName) {
  
  # A. Define GWP Factors (AR4 100-year values standard for reporting)
  # Update these numbers to AR5/AR6 if your project requires it.
  gwpMap <- c(
    "CH4"      = 25,
    "N2O"      = 298,
    "SF6"      = 22800,
    "HFC125"   = 3500,
    "HFC134a"  = 1430,
    "HFC143a"  = 4470,
    "HFC152a"  = 124,
    "HFC227ea" = 3220,
    "HFC23"    = 14800,
    "HFC32"    = 675,
    "HFC43-10" = 1640,
    "HFC245ca" = 693,
    "HFC-236fa" = 9810,
    "PFC"      = 7390,
    "CF4"      = 7390,
    "C2F6"     = 12200,
    "C6F14"     = 9300
  )

  # Remove the unit part "(...)" if present to get clean names for matching
  cleanName <- sub("\\s*\\(.*\\)", "", varName)
  
  # B. Logic to find factor
    if (grepl("CH4", cleanName)) {
    # CH4 is usually Mt. Convert Mt CH4 -> Mt CO2eq
    return(gwpMap[["CH4"]])
    
  } else if (grepl("N2O", cleanName)) {
    # N2O is usually kt. Convert kt -> Mt (/1000) then * GWP
    return(gwpMap[["N2O"]] / 1000)
    
  } else {
    # For HFCs/SF6/PFCs, we extract the specific gas name
    # Logic: Take the text after the last '|'
    gasLeaf <- sub(".*\\|", "", cleanName)
    
    # Check if this leaf exists in our GWP map
    if (gasLeaf %in% names(gwpMap)) {
      # F-Gases are usually kt. Convert kt -> Mt (/1000) then * GWP
      return(gwpMap[[gasLeaf]] / 1000)
    } else {
      # Return 0 or NA if it's not a recognized GHG (to avoid breaking sums)
      warning(paste("GWP not found for:", varName))
      return(0)
    }
  }
}

# 1. Setup paths and read data
workDir <- "C:\\Users\\at39\\2-Models\\OPEN-PROM\\runs\\test_nonCO2MACC_2026-01-02_16-03-15\\"
setwd(workDir)

rawData <- read.report(paste0(workDir, 'reporting.mif'))
scenarioName <- names(rawData)[1]
modelName <- names(rawData[[1]])[1]

# Extract the actual magpie object
dataMagpie <- rawData[[1]][[1]]

# Filter for EU27 Regions
regionMapping <- toolGetMapping(name = "EU28.csv", type = "regional", where = "mrprom")
regionsEu27 <- regionMapping$ISO3.Code[regionMapping$ISO3.Code != "GBR"]
dataMagpieEu27 <- dataMagpie[getRegions(dataMagpie) %in% regionsEu27, , ]


# Apply Conversion and Aggregate ---

# Get list of all variables in the object
allVars <- getNames(dataMagpieEu27)

# Identify which variables are GHGs we want to sum
# (Adjust this regex if you only want specific "Emissions|..." variables)
targetVars <- grep("Emissions\\|", allVars, value = TRUE)

# Initialize an empty magpie object for the sum
totalCo2Eq <- NULL

for (var in targetVars) {
  
  factor <- getCo2EqFactor(var)
  
  if (factor != 0) {
    # Extract variable, multiply by factor, and add to total
    # We use drop=FALSE to keep dimensions intact
    currentGas <- dataMagpieEu27[, , var] * factor
    totalCo2Eq <- mbind(totalCo2Eq, currentGas)
  }
}
emissions <- mbind(totalCo2Eq, dataMagpieEu27[, , "Emissions|CO2|Energy and Industrial Processes (Mt CO2/yr)"])
# Excluding land use is necessary for 55% reduction in under Fit for 55!
emissions <- emissions[, , setdiff(getNames(emissions), 
              c("Emissions|NOx|AFOLU (Mt NH3/yr)","Emissions|CH4|AFOLU|Land (Mt CH4/yr)", "Emissions|N2O|AFOLU|Land (kt N2O/yr)"))]
emissionsAgg <- dimSums(emissions, dim = "variable")
getNames(emissionsAgg) <- "Emissions (Mt CO2-equiv/yr)"
# --- Regional Aggregation ---
emissionsEu27Agg <- dimSums(emissionsAgg, dim = "region")

# View Result for 2030
print('CO2 net emissions level (absolute) in 2030 - GtCO₂:')
dimSums(dataMagpieEu27[, 2030, "Emissions|CO2|Energy and Industrial Processes (Mt CO2/yr)"], dim='region')/ 1000
print('GHG net emissions level (absolute) in 2030 -  GtCO₂e:')
emissionsEu27Agg[, 2030, ] / 1000