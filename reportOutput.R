# This script generates a mif file for comparison of OPEN-PROM data with MENA-EDS and ENERDATA
library(madrat)
library(postprom)
library(reticulate)
library(dplyr)
library(quitte)

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
    plot_name = NULL,
    Validation_data_for_plots = TRUE) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
    reg_map <- jsonlite::read_json(paste0((runpath),"/metadata.json"))[["Model Information"]][["Region Mapping"]][[1]]
  # setConfig(regionmapping = mapping)

  reports <- convertGDXtoMIF(runpath,
    mif_name = mif_name,
    aggregate = aggregate, fullValidation = fullValidation, Validation_data_for_plots = Validation_data_for_plots
  )
  metadata <- getMetadata(path = runpath)
  print("Report generation completed.")
  
  if (reg_map != "regionmappingOPDEV3.csv") {
    reports <- reports[[1]]
  } else {
    # rename GLO to World
    reports <- lapply(reports, function(x) {
      regions <- getRegions(x)
      if ("GLO" %in% regions) {
        getRegions(x)[regions == "GLO"] <- "World"
      }
      x
    })
    # do not take open-prom
    reports_val <- reports[-1]
    
    region_sig <- function(x) paste(sort(getRegions(x)), collapse = "|")
    sigs <- vapply(reports_val, region_sig, FUN.VALUE = character(1))
    
    # Find the most common region set
    most_common_sig <- names(sort(table(sigs), decreasing = TRUE))[1]
    
    # Keep only magpie objects with that region set
    same_region_list <- reports_val[sigs == most_common_sig]
    
    # Combine them
    if (length(same_region_list) > 1) {
      combined_all <- do.call(mbind, same_region_list)
    } else if (length(same_region_list) == 1) {
      combined_all <- same_region_list[[1]]
    } else {
      combined_all <- NULL
      warning("No magpie objects with identical regions found.")
    }
    reports_val <- combined_all
    reports_val <- as.quitte(reports_val) %>% as.magpie()
    getItems(reports_val, 3.1) <- paste0(getItems(reports_val, 3.1), "|VAL")
    
    reportOPEN_PROM <- reports[[1]]
    #mbind validation data and OPEN-PROM
    reports_val <- add_columns(reports_val, addnm = setdiff(getYears(reportOPEN_PROM),getYears(reports_val)), dim = 2, fill = NA)
    reports_val <- reports_val[,getYears(reportOPEN_PROM),]
    reports <- mbind(reportOPEN_PROM, reports_val)
    reports <- list(reports)
    print(str(reports))
  }

  if (!is.null(plot_name)) {
    save_names <- file.path(runpath, plot_name)
    mapply( # for each scenario, unpack the magpie obj and a pdf savename
      function(report, metadata, save) {
        batchPlotReport(report = report, metadata = metadata, save_pdf = save)
      },
      reports, metadata, save_names
    )
  }
  invisible(NULL)
}

args <- commandArgs(trailingOnly = TRUE)
runpath <- if (length(args) > 0) args[1] else getRunpath()
mif_name <- if (length(args) > 1) args[2] else "reporting.mif"
plot_name <- if (length(args) > 2) args[3] else "plot.tex"

reportOutput(runpath = runpath, mif_name = mif_name, plot_name = plot_name)
