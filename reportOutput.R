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

source("reportPrice.R")
source("reportEmissions.R")
source("reportACTV.R")
source("reportGDP.R")
source("reportPOP.R")
source("reportFinalEnergy.R")
source("reportSE.R")
source("reportPE.R")
source("reportPriceCarbon.R")
source("reportCapacityElectricity.R")

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
  FE <- reportFinalEnergy(runCY)
  EMI <- reportEmissions(runCY)
  SE <- reportSE(runCY)
  PE <- reportPE(runCY)
  GDP <- reportGDP(runCY)
  POP <- reportPOP(runCY)
  PCar <- reportPriceCarbon(runCY)
  #reportACTV(runCY)
  Price <- reportPrice(runCY)
  CapElec <- reportCapacityElectricity(runCY)
  
  magpie_reporting <- mbind(FE, EMI, SE, PE, GDP, POP, PCar, Price, CapElec)
  
  # write data in mif file
  write.report(magpie_reporting,file="reporting.mif",model="OPEN-PROM",scenario=scenario_name)
  
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
    
    z <- as.data.frame(getItems(reporting_run[[i]][[1]],3))
    get_items <- z[grep("^Price", getItems(reporting_run[[i]][[1]],3)),1]
    get_items_not <- z[!grepl("^Price", getItems(reporting_run[[i]][[1]],3)),1]
    
    add_region_GLO <- dimSums(reporting_run[[i]][[1]][,,get_items_not], 1, na.rm = TRUE)
    
    getItems(add_region_GLO, 1) <- "World"
    gdp <- reporting_run[[i]][[1]][,,"GDP|PPP (billion US$2015/yr)"]
    rmap_world <- getRegions(reporting_run[[i]][[1]])
    rmap_world <- as.data.frame(rmap_world)
    names(rmap_world) <- "Region.Code"
    rmap_world[ ,2] <- "World"
    add_region_GLO_mean <- toolAggregate(reporting_run[[i]][[1]][,,get_items], weight = gdp, rel = rmap_world, from = "Region.Code", to = "V2")
    getItems(add_region_GLO_mean, 1) <- "World"
    world_reg <- mbind(add_region_GLO, add_region_GLO_mean)
    reporting_run[[i]][[1]] <- mbind(reporting_run[[i]][[1]], world_reg)
  }
  
if (add_fullVALIDATION_mif == TRUE) {
  setwd("..")
  write.report(reporting_run, file = paste0("reporting_with_validation.mif"))
  reporting_fullVALIDATION <- read.report("fullVALIDATION.mif")
  write.report(reporting_fullVALIDATION, file = "reporting_with_validation.mif", append=TRUE)
}
