# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(madrat)
library(gdx)
library(openprom)
library(tidyr)
library(reticulate)
library(ggplot2)

installPythonPackages <- function(packages) {
  for (pkg in packages) {
    if (!py_module_available(pkg)) {
      py_install(pkg, use_python = TRUE)
    }
  }
}


getRunpath <- function() {
  py_config()
  installPythonPackages(c("seaborn", "colorama", "pandas"))
  python_output <- py_run_file("./scripts/reporting.py")
  runpath <- as.data.frame(python_output$path)
  runpath <- as.vector(runpath[, seq(2, length(runpath), 2)])
  return(unlist(runpath, use.names = FALSE))
}


reportOutput <- function(
    runpath,
    mif_name,
    aggregate = TRUE,
    fullValidation = TRUE,
    plot_info = NULL) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
  mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
  setConfig(regionmapping = mapping)

  runCY <- readGDX(file.path(runpath, "blabla.gdx"), "runCYL")
  convertGDXtoMIF(runpath, runCY,
    mif_name = mif_name, aggregate = aggregate,
    fullValidation = fullValidation,
    plot_info = plot_info
  )
  print("Report generation completed.")
}

args <- commandArgs(trailingOnly = TRUE)
runpath <- if (length(args) > 0) args[1] else getRunpath()
mif_name <- if (length(args) > 1) args[2] else "reporting.mif"

capacity_vars <- c(
  "Capacity|Electricity|Solar",
  "Capacity|Electricity|Oil",
  "Capacity|Electricity|Wind",
  "Capacity|Electricity|Coal",
  "Capacity|Electricity|Gas",
  "Capacity|Electricity|Nuclear",
  "Capacity|Electricity|Biomass",
  "Capacity|Electricity|Geothermal"
)

capacity_sol <- c(
  "Capacity|Electricity|PGADPV",
  "Capacity|Electricity|PGASOL",
  "Capacity|Electricity|PGSOL"
)

capacity_wind <- c(
  "Capacity|Electricity|PGAWND",
  "Capacity|Electricity|PGAWNO",
  "Capacity|Electricity|PGWND"
)

FE_vars <- c(
  "Final Energy|Solids",
  "Final Energy|Hydrogen",
  "Final Energy|Gases",
  "Final Energy|Electricity",
  "Final Energy|Liquids",
  "Final Energy|Heat",
  "Final Energy|Biomass"
)

FE_industry <- c(
  "Final Energy|Industry",
  "Final Energy|Transportation",
  "Final Energy|Residential and Commercial",
  "Final Energy|Non Energy and Bunkers"
)

SE_vars <- c(
  "Secondary Energy|Electricity|Solar",
  "Secondary Energy|Electricity|Oil",
  "Secondary Energy|Electricity|Wind",
  "Secondary Energy|Electricity|Coal",
  "Secondary Energy|Electricity|Gas",
  "Secondary Energy|Electricity|Nuclear",
  "Secondary Energy|Electricity|Biomass",
  "Secondary Energy|Electricity|Geothermal"
)

SE_wind <- c(
  "Secondary Energy|Electricity|PGAWND",
  "Secondary Energy|Electricity|PGAWNO",
  "Secondary Energy|Electricity|PGWND"
)
SE_sol <- c(
  "Secondary Energy|Electricity|PGADPV",
  "Secondary Energy|Electricity|PGASOL",
  "Secondary Energy|Electricity|PGSOL"
)

Emissions_vars <- c(
  "Emissions|CO2|Energy|Demand|Bunkers", "Emissions|CO2|Energy|Demand|Industry",
  "Emissions|CO2|Energy|Demand|Residential and Commercial",
  "Emissions|CO2|Energy|Demand|Transportation", "Emissions|CO2|Energy|Supply"
)

Emissions_cumulated <- c("Emissions|CO2|Cumulated")

plot_info <- list(
  "Capacity" = list(capacity_vars, capacity_wind, capacity_sol),
  "Secondary Energy" = list(SE_vars, SE_wind, SE_sol),
  "Final Energy" = list(FE_vars, FE_industry),
  "Emissions" = list(Emissions_vars, Emissions_cumulated)
)

reportOutput(runpath = runpath, mif_name = mif_name, plot_info = plot_info)