# map <- read.csv("MENA-PROM mapping - mena_prom_mapping.csv") NOT USED?
# rmap <- toolGetMapping(mapping, "regional", where = "mrprom") IS IT USED?
# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(madrat)
library(gdx)
library(ggplot2)
library(openprom)
library(tidyr)
library(reticulate)


installPythonPackages <- function(packages) {
  for (pkg in packages) {
    if (!py_module_available(pkg)) {
      py_install(pkg, use_python = TRUE)
    }
  }
}


getRunpath <- function() {
  python_output <- py_run_file("./scripts/reporting.py")
  runpath <- as.data.frame(python_output$path)
  runpath <- as.vector(runpath[, seq(2, length(runpath), 2)])
  return(unlist(runpath, use.names = FALSE))
}


reportOutput <- function(
    runpath,
    mif_name,
    path_fullValidation = NULL) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
  mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
  setConfig(regionmapping = mapping)

  runCY <- readGDX(file.path(runpath, "blabla.gdx"), "runCYL")
  convertGDXtoMIF(runpath, runCY, mif_name = mif_name)
  # aggregateMIF(path_report = file.path(runpath, mif_name), path_save = "runs/reporting_with_validation.mif")

  if (!is.null(path_fullValidation)) {
    reporting_fullVALIDATION <- read.report(path_fullValidation)
    write.report(reporting_fullVALIDATION, file = "runs/reporting_with_validation.mif", append = TRUE)
  }
  print("Report generation completed.")
}

py_config()
installPythonPackages(c("seaborn", "colorama", "pandas"))
runpath <- getRunpath()
reportOutput(runpath, "new.mif")
