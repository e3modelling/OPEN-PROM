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
  
  Val_Mif <- ValidationMif(.path = runpath, Validation_data_for_plots = Validation_data_for_plots
  )
  
  for (i in 1:length(runpath)) {
    if (!is.null(Val_Mif)) {
      Val_Mif[Val_Mif==0]=NA
      reportOPEN_PROM <- reports[[i]]
      #mbind validation data and OPEN-PROM
      val_years <- getYears(reportOPEN_PROM)
      Val_Mif <- add_columns(Val_Mif, addnm = setdiff(getYears(reportOPEN_PROM),getYears(Val_Mif)), dim = 2, fill = NA)
      Val_Mif <- Val_Mif[,getYears(reportOPEN_PROM),]
      Val_Mif <- add_columns(Val_Mif, addnm = setdiff(getRegions(reportOPEN_PROM),getRegions(Val_Mif)), dim = 1, fill = NA)
      Val_Mif <- Val_Mif[getRegions(reportOPEN_PROM),,]
      
      Val_Mif[,val_years,"Final Energy|Industry|VAL"] <- Val_Mif[,val_years,"Final Energy|Industry|VAL"] +
        reportOPEN_PROM[,val_years,"Final Energy|Residential and Commercial"] + reportOPEN_PROM[,val_years,"Final Energy|Transportation"] +
        reportOPEN_PROM[,val_years,"Final Energy|Non Energy"] + reportOPEN_PROM[,val_years,"Final Energy|Bunkers"]
      Val_Mif[,val_years,"Final Energy|Transportation|VAL"] <- Val_Mif[,val_years,"Final Energy|Transportation|VAL"] +
        reportOPEN_PROM[,val_years,"Final Energy|Residential and Commercial"] + reportOPEN_PROM[,val_years,"Final Energy|Non Energy"] +
        reportOPEN_PROM[,val_years,"Final Energy|Bunkers"]
      
      reports_with_val <- mbind(reportOPEN_PROM, Val_Mif)
      reports[[i]] <- reports_with_val
    } else {
      dummy <- new.magpie(getRegions(reports[[i]]), getYears(reports[[i]]), c("Emissions|CO2|VAL",
                                                                              "Final Energy|Transportation|VAL",
                                                                              "Final Energy|Industry|VAL",
                                                                              "Final Energy|VAL",
                                                                              "Secondary Energy|Electricity|VAL",
                                                                              "Capacity|Electricity|VAL"), fill = NA)
      dummy <- add_dimension(dummy, dim = 3.2, add = "unit", nm  = c("Mt CO2/yr","Mtoe","Mtoe","Mtoe","GW","GW"))
      reports_with_val <- mbind(reports[[i]], dummy)
      reports[[i]] <- reports_with_val
    }
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

reportOutput(runpath = runpath, mif_name = mif_name, plot_name = plot_name, Validation_data_for_plots = TRUE)
