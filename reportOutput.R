# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA

# Load necessary libraries
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

# Function to install Python packages if not available
installPythonPackages <- function(packages) {
  for (pkg in packages) {
    if (!py_module_available(pkg)) {
      py_install(pkg, use_python = TRUE)
    }
  }
}

# Check if command line arguments are provided
args <- commandArgs(trailingOnly = TRUE)

# Check if the user provided a path as an argument
if (length(args) > 0) {
  runpath <- args[1]  # If the first argument is the runpath
} else {
  runpath <- NULL
}
# Encapsulate runpath initialization and Python script execution in tryCatch
tryCatch({  
    # Define the runpath variable if not provided via command line
    if (is.null(runpath)) {
      if (any("runs" %in% dir())) {
        # Check which Python environment reticulate is using
        py_config()
        installPythonPackages(c("seaborn", "colorama", "pandas"))
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
  },
    error = function(e) {
            message("Python script execution failed. Please run the following command in the terminal and provide the run path manually:\nRscript reportOutput.R runname_blabla\nor open the script and paste the run path(s) in the code, then run Rscript reportOutput.R again.")
            message(e)
            NULL
    }
  )

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
    source("reportPOP.R")
    source("reportFinalEnergy.R")
    source("reportSE.R")
    source("reportPE.R")
  
    # Add error handling for GDX file reading
    runCY <- tryCatch(
      {
        readGDX('./blabla.gdx', "runCYL") # read model regions, model reporting should contain only these
      },
      error = function(e) {
        message("Error reading GDX file at path: ", x)
        message(e)
        NULL
      }
    )
    
    if (is.null(runCY)) {
      next  # Skip to the next runpath if the GDX file could not be read
    }
    
    rmap <- toolGetMapping(mapping, "regional", where = "mrprom")
    setConfig(regionmapping = mapping)
  
    # Read MENA-PROM mapping, will use it to choose the correct variables from MENA
  map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")
    scenario_name <- basename(getwd())
  
  #output <- NULL
  #output <- mbind(output, reportGDP(runCY))
  reportFinalEnergy(runCY)
  reportEmissions(runCY)
  reportSE(runCY)
  reportPE(runCY)
  reportGDP(runCY)
  reportPOP(runCY)
  #reportACTV(runCY)
  #reportPrice(runCY)

  reporting <- read.report("reporting.mif")
  setwd("..")
  if (length(runpath) > 1) {
    write.report(reporting, file = "compareScenarios2.mif", append=TRUE)
    reporting_run <- read.report("compareScenarios2.mif")
  } else {
    write.report(reporting, file = "reporting2.mif")
    reporting_run <- read.report("reporting2.mif")
  }
}

  for (i in 1 : length(reporting_run)) {
    add_region_GLO <- dimSums(reporting_run[[i]][[1]], 1)
    getItems(add_region_GLO, 1) <- "World"
    reporting_run[[i]][[1]] <- mbind(reporting_run[[i]][[1]], add_region_GLO)
  }
  
if (add_fullVALIDATION_mif == TRUE) {
  setwd("..")
  write.report(reporting_run, file = paste0("reporting_with_validation.mif"))
  reporting_fullVALIDATION <- read.report("fullVALIDATION.mif")
  write.report(reporting_fullVALIDATION, file = "reporting_with_validation.mif", append=TRUE)
}
