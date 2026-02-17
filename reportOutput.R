library(madrat)
library(postprom)
library(dplyr)
library(quitte)


getRunpath <- function() {
  # Main execution
  result <- call_functions()
  runpath <- as.data.frame(result)
  runpath <- as.vector(runpath[, seq(2, length(runpath), 2)])
  return(unlist(runpath, use.names = FALSE))
}

reportOutput <- function(
    runpath,
    mif_name,
    aggregate = TRUE,
    fullValidation = TRUE,
    plot_name = NULL,
    Validation_data_for_plots = Validation_data_for_plots,
    Validation2050 = Validation2050,
    emissions = TRUE,
    htmlReport = FALSE, projectReport = FALSE) {
  # Region mapping used for aggregating validation data (e.g. ENERDATA)
  if (length(runpath) > 1) {
    reg_map <- jsonlite::read_json(paste0((runpath[1]),"/metadata.json"))[["Model Information"]][["Region Mapping"]][[1]]
  } else {
    reg_map <- jsonlite::read_json(paste0((runpath),"/metadata.json"))[["Model Information"]][["Region Mapping"]][[1]]
  }
    
  # setConfig(regionmapping = mapping)

  reports <- convertGDXtoMIF(runpath,
    mif_name = mif_name,
    aggregate = aggregate, fullValidation = fullValidation
  )
  metadata <- getMetadata(path = runpath)
  print("Report generation completed.")
  
  # add validation data for plots
  for (i in 1:length(runpath)) {
      reportOPEN_PROM <- reports[[i]]
      metadata_run <- getMetadata(path = runpath[[i]])
      reports[[i]] <- ValidationMif(.path = runpath, Validation_data_for_plots = Validation_data_for_plots,
                                    reportOPEN_PROM = reportOPEN_PROM, metadata_run = metadata_run,
                                    Validation2050 = Validation2050)
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

reportOutput(runpath = runpath, mif_name = mif_name, plot_name = plot_name, Validation_data_for_plots = FALSE, Validation2050 = FALSE)
