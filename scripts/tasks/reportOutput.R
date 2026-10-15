library(madrat)
library(postprom)
library(dplyr)
library(quitte)
library(crayon)
library(stringr)

getRunpath <- function() {
  # Main execution
  source("scripts/tasks/helpersOfCompareScenarios.R")
  source("scripts/tasks/scanRunFolder.R")
  result <- scanRunFolder()
  runpath <- as.data.frame(result)
  runpath <- as.vector(runpath[, seq(2, length(runpath), 2)])
  return(unlist(runpath, use.names = FALSE))
}

reportOutput <- function(
    runpath,
    mif_name,
    aggregate = TRUE,
    fullValidation = FALSE,
    plot_name = NULL,
    Validation_data_for_plots = Validation_data_for_plots,
    Validation2050 = Validation2050,
    emissions = emissions,
    htmlReport = htmlReport, model = model,
    dashboard = dashboard,
    project_template = project_template,
    stripScenarioTimestamp = stripScenarioTimestamp,
    PngFiles = PngFiles) {
    
  mappings <- vapply(runpath, function(path) {
    metadata_path <- file.path(path, "metadata.json")
    if (!file.exists(metadata_path)) return(NA_character_)
    metadata <- jsonlite::fromJSON(metadata_path, simplifyVector = FALSE)
    metadata[["Model Information"]][["Region Mapping"]][[1]]
  }, character(1))
  if (length(unique(stats::na.omit(mappings))) == 1L) {
    setConfig(regionmapping = stats::na.omit(mappings)[[1]])
  }

  emissions_mif_backups <- character()
  on.exit({
    for (mif_path in names(emissions_mif_backups)) {
      file.copy(emissions_mif_backups[[mif_path]], mif_path, overwrite = TRUE)
    }
    unlink(emissions_mif_backups)
  }, add = TRUE)

  for (path in runpath) {
    gdx_path <- file.path(path, "blabla.gdx")
    mif_path <- file.path(path, "iEmissions_magpie.mif")
    if (!file.exists(gdx_path) || !file.exists(mif_path)) next

    years <- c(
      as.character(gdx::readGDX(gdx_path, "datay")),
      as.character(gdx::readGDX(gdx_path, "an"))
    )
    years <- paste0("y", years)
    emissions_mif <- magclass::read.report(mif_path)
    for (scenario in names(emissions_mif)) {
      for (model in names(emissions_mif[[scenario]])) {
        emissions_mif[[scenario]][[model]] <- emissions_mif[[scenario]][[model]][, years, ]
      }
    }

    backup_path <- tempfile(fileext = ".mif")
    if (!file.copy(mif_path, backup_path)) {
      stop("Could not back up emissions input before report conversion: ", mif_path)
    }
    emissions_mif_backups[[mif_path]] <- backup_path
    magclass::write.report(emissions_mif, file = mif_path, ndigit = 15)
  }

  reports <- convertGDXtoMIF(runpath,
    mif_name = mif_name,
    aggregate = aggregate, fullValidation = fullValidation,
    emissions = emissions, htmlReport = htmlReport,
    project_template = project_template, model = model,
    stripScenarioTimestamp = stripScenarioTimestamp,
    dashboard = dashboard
  )
  metadata <- getMetadata(path = runpath)
  print("Report generation completed.")

  # add validation data for plots
  for (i in 1:length(runpath)) {
    reportOPEN_PROM <- reports[[i]]
    metadata_run <- getMetadata(path = runpath[[i]])
    reports[[i]] <- ValidationMif(
      .path = runpath, Validation_data_for_plots = Validation_data_for_plots,
      reportOPEN_PROM = reportOPEN_PROM, metadata_run = metadata_run,
      Validation2050 = Validation2050
    )
  }

  if (!is.null(plot_name)) {
    save_names <- file.path(runpath, plot_name)
    mapply( # for each scenario, unpack the magpie obj and a pdf savename
      function(report, metadata, save, PngFiles) {
        batchPlotReport(report = report, metadata = metadata, save_pdf = save, PngFiles = PngFiles)
      },
      reports, metadata, save_names, PngFiles
    )
  }
  invisible(NULL)
}

args <- commandArgs(trailingOnly = TRUE)
runpath <- if (length(args) > 0) args[1] else getRunpath()
mif_name <- if (length(args) > 1) args[2] else "reporting.mif"
plot_name <- if (length(args) > 2) args[3] else "plot.tex"

reportOutput(runpath = runpath, mif_name = mif_name, plot_name = plot_name,
             Validation_data_for_plots = FALSE, Validation2050 = FALSE,
             emissions = TRUE, htmlReport = FALSE, model = "OPEN-PROM 2.2",
             project_template = NULL, dashboard = FALSE,
             stripScenarioTimestamp = FALSE, PngFiles = TRUE)