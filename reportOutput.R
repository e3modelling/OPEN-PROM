# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(dplyr)
library(gdx)
library(quitte)
library(tidyr)
library(utils)
library(mrprom)
library(stringr)

mapping <- "regionmappingOP5.csv" # region mapping used for aggregating validation data (e.g. ENERDATA)
# this will be read in from a configuration file 

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
#scenario_name <- str_match(scenario_name, "\\s*(.*?)\\s*_")[,1]
#scenario_name <- str_sub(scenario_name, 1, - 2)
#if (is.na(scenario_name)) scenario_name <- "default"

#output <- NULL
#output <- mbind(output, reportGDP(runCY))
reportFinalEnergy(runCY,rmap)
#reportGDP(runCY)
#reportACTV(runCY)
reportEmissions(runCY)
#reportPrice(runCY)