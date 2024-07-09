# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)
library(jsonlite)
library(reticulate)

# add mif from fullVALIDATION
add_fullVALIDATION_mif = TRUE

# Define the runpath variable
runpath <- NULL

if (is.null(runpath)) {
  if (any("runs" %in% dir())) {
    # Check which Python environment reticulate is using
    py_config()
  
    # Execute the Python script and capture its output
    python_output <- tryCatch(
      {
        py_run_file("./scripts/reporting.py")
      },
      error = function(e) {
        message("Error executing Python script:")
        message(e)
        NULL
      }
    )
  
    if (!is.null(python_output)) {
      runpath <- as.data.frame(python_output$path)
      runpath <- runpath[, seq(2, length(runpath), 2)]
    } else {
      stop("Python script execution failed. Please run the following command in the terminal and provide the run path manually:\nRscript reportOutput.R runname_blabla\nor open the script and paste the run path(s) in the code, then run Rscript reportOutput.R again.")
    }
  } else {
    stop("Runs directory not found. Please provide the run path manually by setting the 'runpath' variable in the script.")
  }
}

# Install necessary Python packages if not already installed
if (!py_module_available("seaborn")) {
  py_install("seaborn", use_python = TRUE)
}
if (!py_module_available("colorama")) {
  py_install("colorama", use_python = TRUE)
}
if (!py_module_available("pandas")) {
  py_install("pandas", use_python = TRUE)
}

# Region mapping used for aggregating validation data (e.g. ENERDATA)
mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
runpath <- as.data.frame(runpath)

for (i in 1:length(runpath)) {
  x <- runpath[1, i]
  x <- gsub("\\\\", "/", x)
  setwd(x)

  source("reportPrice.R")
  source("reportEmissions.R")
  source("reportACTV.R")
  source("reportGDP.R")
  source("reportFinalEnergy.R")

  runCY <- readGDX('./blabla.gdx', "runCYL") # read model regions, model reporting should contain only these
  rmap <- toolGetMapping(mapping, "regional", where = "mrprom")
  setConfig(regionmapping = mapping)

  # Read MENA-PROM mapping, will use it to choose the correct variables from MENA
  map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")
  scenario_name <- basename(getwd())

  #output <- NULL
  #output <- mbind(output, reportGDP(runCY))
  reportFinalEnergy(runCY)
  reportEmissions(runCY)
  #reportGDP(runCY)
  #reportACTV(runCY)
  #reportPrice(runCY)

  reporting <- read.report("reporting.mif")
  setwd("..")
  if (length(runpath) > 1) {
    write.report(reporting, file="compareScenarios2.mif", append=TRUE)
    reporting_run <- read.report("compareScenarios2.mif")
  } else {
    write.report(reporting, file="reporting2.mif", append=TRUE)
    reporting_run <- read.report("reporting2.mif")
  }
}


if (add_fullVALIDATION_mif == TRUE) {
  setwd("..")
  files <- list.files(pattern="mif")
  files <- as.data.frame(files)
  vals <- interaction(files$files)
  opts <- as.character(unique(vals))
  print_choices <- print(opts)
  print("Select mif VALIDATION")
  choice <- gms::getLine()
  mif_fullVALIDATION <- files[unique(vals) %in% opts[as.integer(choice)],]
  
  if (length(runpath) > 1) {
    write.report(reporting_run, file="compareScenarios_added_validation.mif", append=TRUE)
    reporting_fullVALIDATION <- read.report(mif_fullVALIDATION)
    write.report(reporting_fullVALIDATION, file="compareScenarios_added_validation.mif", append=TRUE)
  } else {
    write.report(reporting_run, file="reporting_added_validation.mif", append=TRUE)
    reporting_fullVALIDATION <- read.report(mif_fullVALIDATION)
    write.report(reporting_fullVALIDATION, file="reporting_added_validation.mif", append=TRUE)
  }
}
