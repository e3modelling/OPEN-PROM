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
if (any("runs" %in% dir())){
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
selected_scenario <- as.data.frame(python_output$path)
selected_scenario <- selected_scenario[,seq(2,length(selected_scenario),2)]
#selected_scenario <- python_output$path[[1]][[2]][1]
#selected_scenario <- gsub("\\\\", "/", selected_scenario)
#setwd(selected_scenario)

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

# region mapping used for aggregating validation data (e.g. ENERDATA)
mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
selected_scenario<-as.data.frame(selected_scenario)
for (i in 1 : length(selected_scenario))
{
    x <- selected_scenario[1, i]
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

    # read MENA-PROM mapping, will use it to choose the correct variables from MENA
    map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv")
    scenario_name <- basename(getwd())
    
    #output <- NULL
    #output <- mbind(output, reportGDP(runCY))
    reportFinalEnergy(runCY,rmap)
    #reportGDP(runCY)
    #reportACTV(runCY)
    reportEmissions(runCY)
    #reportPrice(runCY)

    reporting <- read.report("reporting.mif")
    setwd("..")
    if (length(selected_scenario) > 1) {
     write.report(reporting, file="compareScenarios2.mif", append = TRUE)
    } else {
    write.report(reporting, file="reporting2.mif", append = TRUE)
    }
   
}
