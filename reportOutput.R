# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(madrat)
library(gdx)
library(openprom)
library(tidyr)
library(reticulate)
library(ggplot2)
library(dplyr)

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

plotPDF <- function(report, save_pdf) {
  plot_groups <- function(vars, name, ...) {
    category <- strsplit(name, "\\|")[[1]][1] # e.g. Capacity
    vars <- paste0(sub("\\|[^|]*$", "|", name), vars) # retrieve variable names
    magpie_obj <- report[, , vars]
    plot <- plotReport(magpie_obj, label = category, ...)
    return(plot)
  }

  plot_mappings <- read.csv(system.file(package = "openprom", file.path("extdata", "plot_mapping.csv")))
  # for each unique plot, use filter the magpie obj and plot its vars
  plots_list <- plot_mappings %>%
    group_by(Name) %>%
    group_map(~ plot_groups(.x$Variables, .y$Name))

  print(paste0("Saving pdf in ", save_pdf))
  pdf(save_pdf, width = 10, height = 8)
  for (plot in plots_list) print(plot)
  invisible(dev.off())
}

reportOutput <- function(
    runpath,
    mif_name,
    aggregate = TRUE,
    fullValidation = TRUE,
    plot = NULL) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
  mapping <- jsonlite::read_json("metadata.json")[["Model Information"]][["Region Mapping"]][[1]]
  setConfig(regionmapping = mapping)

  reports <- convertGDXtoMIF(runpath, mif_name = mif_name,
    aggregate = aggregate, fullValidation = fullValidation)
  print("Report generation completed.")

  if (!is.null(plot)) {
    save_name <- file.path(runpath, plot)
    mapply( # for each scenario, unpack the magpie obj and a pdf savename
      function(report, save) {
        plotPDF(report, save)
      },
      reports, save_name
    )
  }
}

args <- commandArgs(trailingOnly = TRUE)
runpath <- if (length(args) > 0) args[1] else getRunpath()
mif_name <- if (length(args) > 1) args[2] else "reporting.mif"
plot_name <- if (length(args) > 2) args[3] else "plot.pdf"

reportOutput(runpath = runpath, mif_name = mif_name, plot = plot_name)
