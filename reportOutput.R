# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(madrat)
library(gdx)
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
    fullValidation = TRUE) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
  mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
  setConfig(regionmapping = mapping)

  runCY <- readGDX(file.path(runpath, "blabla.gdx"), "runCYL")
  convertGDXtoMIF(runpath, runCY,
    mif_name = mif_name, aggregate = aggregate,
    fullValidation = fullValidation
  )
  print("Report generation completed.")
}

args <- commandArgs(trailingOnly = TRUE)
runpath <- if (length(args) > 0) args[1] else getRunpath()
mif_name <- if (length(args) > 1) args[2] else "reporting.mif"

reportOutput(runpath = runpath, mif_name = mif_name)