### Script for OPEN-PROM model execution and other associated tasks.
library(jsonlite)

# Various flags used to modify script behavior
withRunFolder <- TRUE # Set to FALSE to disable model run folder creation and file copying
withSync <- FALSE # Set to FALSE to disable model run sync to SharePoint
withReport <- FALSE # Set to FALSE to disable the report output script execution (applicable to research mode only)
uploadGDX <- TRUE # Set to TRUE to include GDX files in the uploaded archive

### Define function that saves model metadata into a JSON file.

saveMetadata <- function(DevMode) {
  # Gather Git information with system calls
  commit_author <- system("git log -1 --format=%an", intern = TRUE)
  commit_hash <- system("git log -1 --format=%H", intern = TRUE)
  commit_comment <- system("git log -1 --format=%B", intern = TRUE)
  commit_date <- system("git log -1 --format=%ad", intern = TRUE)
  branch_name <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
  git_status <- system("git status -s", intern = TRUE)
  system("git diff --output=git_diff.txt")

  if (length(git_status) == 0) git_status <- "There are no changes made."

  # Organize Git information into a list
  git_info <- list(
    "Author" = commit_author,
    "Branch Name" = branch_name,
    "Commit Comment" = commit_comment,
    "Git Status" = git_status,
    "Commit Hash" = commit_hash,
    "Date" = commit_date
  )

  # Save the appropriate region mapping for each type of run (Development / Research).
  if (DevMode == 0) {
    mapping <- "regionmappingOPDEV5.csv"
  } else if (DevMode == 1) {
    mapping <- "regionmappingOPDEV4.csv"
  }

  # Get the model run description from config file
  run_desc <- NULL
  if (file.exists("config.json")) {
    config <- fromJSON("config.json")
    desc_config <- config$description
  }

  if (!is.null(desc_config) && nzchar(trimws(desc_config))) {
    run_desc <- desc_config
  } else {
    run_desc <- "Default model run description."
  }

  # Collect model information in a list
  model_info <- list(
    "Region Mapping" = mapping,
    "Run Description" = run_desc
  )

  # Convert to JSON and save to file
  data_to_save <- list("Git Information" = git_info, "Model Information" = model_info)
  json_data <- toJSON(data_to_save, pretty = TRUE)
  write(json_data, file = "metadata.json")

  cat("Metadata has been saved to metadata.json\n")
}

### Define a function that creates a separate folder for each model run.

createRunFolder <- function(scenario = "default") {
  # generate name of run folder
  folderName <- paste(scenario, format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), sep = "_")

  # create run folder under /runs
  if (!file.exists("runs")) dir.create("runs")
  runfolder <- paste0("runs/", folderName)
  dir.create(runfolder)

  # copy necessary files to folder
  file.copy(grep(".gms$", dir(), value = TRUE), to = runfolder)
  file.copy(grep(".csv$", dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.R$", dir(), value = TRUE), to = runfolder)
  file.copy(grep("*.json$", dir(), value = TRUE), to = runfolder)
  file.copy("conopt.opt", to = runfolder)
  file.copy("git_diff.txt", to = runfolder)
  file.copy("data", to = runfolder, recursive = TRUE)
  file.copy("targets", to = runfolder, recursive = TRUE)
  file.copy("core", to = runfolder, recursive = TRUE)
  file.copy("modules", to = runfolder, recursive = TRUE)

  # switch to the run folder
  setwd(runfolder)
}

### Define a function that archives and uploads each model run to a cloud
syncRun <- function() {
  folder_path <- getwd()
  archive_name <- paste0(basename(folder_path), ".tgz")

  # Create tgz archive with the files of each model run
  all_files <- list.files(folder_path, recursive = TRUE, all.files = TRUE)

  # Define what you want to exclude (Files OR Folders)
  itemsToExclude <- c("mainCalib.lst", "main.lst")

  if (isRunSuccessful("modelstat.txt")) {
    
    message("Run Successful. Excluding temporary files from archive...")

    for (item in itemsToExclude) {
      # This Regex means: Match the item at the start (^) AND 
      # ensure it ends there ($) OR is a folder parent (/)
      # This prevents "temp.gdx" from accidentally matching "temp.gdx_final"
      pattern <- paste0("^", item, "($|/)")
      all_files <- all_files[!grepl(pattern, all_files)]
    }
    
  } else {
    message("Run had errors. Archiving ALL files for debugging.")
  }

  # Include GDX files based on user preference
  if (uploadGDX) {
    files_to_archive <- all_files
  } else {
    files_to_archive <- all_files[!grepl("\\.gdx$", all_files, ignore.case = TRUE)]
  }

  # Validate the model runs SharePoint path
  if (file.exists("config.json")) {
    config <- fromJSON("config.json")
    model_runs_path <- config$model_runs_path

    if (!is.null(model_runs_path) && file.exists(model_runs_path) && file.info(model_runs_path)$isdir) {
      # Copy the archive to the user-specified directory
      tar(tarfile = archive_name, files = files_to_archive, compression = "gzip", tar = "internal")

      destination_path <- file.path(model_runs_path, basename(archive_name))
      if (file.copy(archive_name, destination_path, overwrite = TRUE)) {
        cat("File copied successfully to", destination_path, "\n")
      }
    } else {
      cat("Please enter a valid model runs SharePoint directory path.\n")
      quit()
    }
  } else if (!file.exists("config.json")) {
    cat("Please create a configuration file (config.json).\n")
    quit()
  }

  # Delete the archive if it exists
  if (file.exists(archive_name)) {
    file.remove(archive_name)
  }
}

### Define a function that returns the scenario name
setScenarioName <- function(scen_default) {
  scen_config <- NULL
  # Reading the scenario name from config file
  if (file.exists("config.json")) {
    config <- fromJSON("config.json")
    scen_config <- config$scenario_name
  }

  # Checking if the scenario name is NULL or empty string
  if (!is.null(scen_config) && nzchar(trimws(scen_config))) {
    scen <- scen_config
  } else {
    # If the config scenario name is not valid, get the default one
    # as specified in each VS Code task, e.g. DEV, DEVNEWDATA etc
    cat("Invalid scenario name or missing config file, setting default name.\n")
    scen <- scen_default
  }

  return(scen)
}

### Function that check if all country and year runs are successfull
isRunSuccessful <- function(statusFilePath) {
  if (!file.exists(statusFilePath)) return(FALSE)

  lines <- readLines(statusFilePath)
  modelStatus <- as.numeric(sub(".*Model Status:([0-9.]+).*", "\\1", lines))
  allAreValid <- all(modelStatus %in% c(2.0, 5.0))

  return(allAreValid)
}

### Executing the VS Code tasks

# Optionally setting a custom GAMS path
if (file.exists("config.json")) {
  config <- fromJSON("config.json")
  gams_path <- config$gams_path

  # Checking if the specified path exists and is a directory
  if (!is.null(gams_path) && file.exists(gams_path) && file.info(gams_path)$isdir) {
    gams <- paste0(gams_path, "gams")
  } else {
    cat("The specified custom GAMS path is not valid. Using the default path.\n")
    gams <- "gams"
  }
} else {
  # Use the default gams command if config.json doesn't exist.
  gams <- "gams"
}

# Parsing the command line argument
args <- commandArgs(trailingOnly = TRUE)
task <- NULL

for (arg in args) {
  key_value <- strsplit(arg, "=")[[1]]

  if (key_value[1] == "task") {
    task <- as.numeric(key_value[2])
  }
}

if (is.null(task)) stop("Task parameter is missing or invalid.")

# Setting the appropriate GAMS flags for each task
if (task == 0) {
  # Running task OPEN-PROM DEV
  saveMetadata(DevMode = 1)
  if (withRunFolder) createRunFolder(setScenarioName("DEV"))

  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(gams, " main.gms --DevMode=1 --GenerateInput=off -logOption 4 -Idir=./data 2>&1")
    system(paste0("sh -c ", shQuote(cmdCommand)))
  } else {
    cmdCommand <- paste0(gams, " main.gms --DevMode=1 --GenerateInput=off -logOption 4 -Idir=./data 2>&1 | tee full.log")
    shell(cmdCommand)
  }

  if (withRunFolder && withReport) {
    run_path <- getwd()
    setwd("../../") # Going back to root folder
    cat("Executing the report output script\n")
    report_cmd <- paste0("Rscript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
    system(report_cmd)
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
} else if (task == 1) {
  # Running task OPEN-PROM DEV NEW DATA
  saveMetadata(DevMode = 1)
  if (withRunFolder) createRunFolder(setScenarioName("DEVNEWDATA"))


  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(gams, " main.gms --DevMode=1 --GenerateInput=on -logOption 4 -Idir=./data 2>&1")
    system(cmdCommand)
  } else {
    cmdCommand <- paste0(gams, " main.gms --DevMode=1 --GenerateInput=on -logOption 4 -Idir=./data 2>&1 | tee full.log")
    shell(cmdCommand)
  }
  if (withRunFolder) {
    file.copy("data", to = "../../", recursive = TRUE) # Copying generated data to parent folder for future runs
    file.copy("targets", to = "../../", recursive = TRUE)
    if (withSync) syncRun()
  }
} else if (task == 2) {
  # Running task OPEN-PROM RESEARCH
  saveMetadata(DevMode = 0)
  if (withRunFolder) createRunFolder(setScenarioName("RES"))

  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(gams, " main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data 2>&1")
    system(cmdCommand)
  } else {
    cmdCommand <- paste0(gams, " main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data 2>&1 | tee full.log")
    shell(cmdCommand)
  }

  if (withRunFolder && withReport) {
    run_path <- getwd()
    setwd("../../") # Going back to root folder
    cat("Executing the report output script\n")
    report_cmd <- paste0("Rscript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
    system(report_cmd)
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()

} else if (task == 3) {
  # Running task OPEN-PROM RESEARCH NEW DATA
  saveMetadata(DevMode = 0)
  if (withRunFolder) createRunFolder(setScenarioName("RESNEWDATA"))

  # NEW DATA & CALIBRATE
  if (.Platform$OS.type == "unix") {
    calib_cmd <- paste0(
    gams,
    " main.gms -o mainCalib.lst --WriteGDX=off --DevMode=0 --fScenario=4 --GenerateInput=on --Calibration=MatCalibration -logOption 4 -Idir=./data 2>&1"
    )
    exit_code <- system(calib_cmd)
  } else {
    calib_cmd <- paste0(
    gams,
    " main.gms -o mainCalib.lst --WriteGDX=off --DevMode=0 --fScenario=4 --GenerateInput=on --Calibration=MatCalibration -logOption 4 -Idir=./data 2>&1 | tee fullCalib.log"
    )
    exit_code <- shell(calib_cmd)
  }
  cat("Executing calibration with data generation:\n", calib_cmd, "\n")

  # Check for calibration execution failure
  if (exit_code != 0) {
    cat("ERROR: GAMS calibration failed with exit code:", exit_code, "\n")
    cat("Calibration and data generation failed. Check fullCalib.log for details.\n")
    stop("GAMS calibration execution failed during data generation. Terminating run.")
  }
  
  # Verify calibration output files exist
  CalibratedParams <- c("iMatFacPlaAvailCap.csv", "iMatrFactorData.csv")
  missing_files <- CalibratedParams[!file.exists(CalibratedParams)]
  if (length(missing_files) > 0) {
    cat("ERROR: Calibrated parameter files missing:", paste(missing_files, collapse = ", "), "\n")
    stop("Calibration failed to generate required parameter files. Terminating run.")
  }
  
  newNames <- gsub("[0-9]", "", CalibratedParams) # remove numbers
  CalibratedParamsPath <- file.path(getwd(), CalibratedParams)
  newPath <- file.path(getwd(), "data", newNames)
  rename_success <- file.rename(CalibratedParamsPath, newPath)
  
  if (!all(rename_success)) {
    cat("ERROR: Failed to rename calibrated parameter files\n")
    stop("File operation failed during calibration cleanup. Terminating run.")
  }
  
  cat("Calibration completed successfully.\n")

  # RESEARCH
  if (.Platform$OS.type == "unix") {
    research_cmd <- paste0(gams, " main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data 2>&1")
    exit_code <- system(paste0("sh -c ", shQuote(research_cmd)))
  } else {
    research_cmd <- paste0(gams, " main.gms --DevMode=0 --GenerateInput=off -logOption 4 -Idir=./data 2>&1 | tee full.log")
    exit_code <- shell(research_cmd)
  }
  cat("Executing research run:\n", research_cmd, "\n")
  # Check for research execution failure
  if (exit_code != 0) {
    cat("ERROR: GAMS research execution failed with exit code:", exit_code, "\n")
    cat("Research run failed. Check full.log for details.\n")
    stop("GAMS research execution failed. Terminating run.")
  }
  
  cat("Research run completed successfully.\n")
  if (withRunFolder) file.copy("data", to = "../../", recursive = TRUE)
  if (withRunFolder) file.copy("targets", to = "../../", recursive = TRUE)

  if (withRunFolder && withReport) {
    run_path <- getwd()
    setwd("../../") # Going back to root folder
    cat("Executing the report output script\n")
    report_cmd <- paste0("Rscript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
    system(report_cmd)
    setwd(run_path)
  }

  if (withRunFolder && withSync) syncRun()
} else if (task == 4) {
  # Debugging mode

  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(gams, " main.gms -logOption 4 -Idir=./data 2>&1")
    system(cmdCommand)
  } else {
    cmdCommand <- paste0(gams, " main.gms -logOption 4 -Idir=./data 2>&1 | tee full.log")
    shell(cmdCommand)
  }

} else if (task == 5) {
  # Running task OPEN-PROM CALIBRATE
  saveMetadata(DevMode = 0)
  if (withRunFolder) createRunFolder(setScenarioName("CALIB"))

  cmdCommand <- paste0(
      gams,
      " main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 -logOption 4 -Idir=./data 2>&1 | tee fullCalib.log"
    )
  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(
      gams,
      " main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 -logOption 4 -Idir=./data 2>&1"
    )
    system(cmdCommand)
  } else {
    cmdCommand <- paste0(
      gams,
      " main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 -logOption 4 -Idir=./data 2>&1 | tee fullCalib.log"
    )
    shell(cmdCommand)
  }

  if (withRunFolder && withSync) syncRun()

  CalibratedParams <- c("iMatFacPlaAvailCap.csv", "iMatrFactorData.csv")
  CalibratedParamsPath <- file.path(getwd(), CalibratedParams)
  newPath <- file.path(dirname(dirname(getwd())), "data", CalibratedParams)
  file.rename(CalibratedParamsPath, newPath)

} else if (task == 6) {
  # Running task OPEN-PROM CALIBRATE CARBON PRICES
  saveMetadata(DevMode = 0)
  if (withRunFolder) createRunFolder(setScenarioName("CARBONPRICES"))

  run_path <- getwd()
  print(run_path)
  report_cmd <- paste0("Rscript ./findCarbonPrice.R ", run_path)
  system(report_cmd)

  if (withRunFolder && withReport) {
    setwd("../../") # Going back to root folder
    cat("Executing the report output script\n")
    report_cmd <- paste0("Rscript ./reportOutput.R ", run_path) # Executing the report output script on the current run path
    system(report_cmd)
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
} else if (task == 7) {
  # Running task OPEN-PROM <-> MAgPIE SOFT-LINK (coupling-channel, mif-based)
  # Pipeline: open-prom (link2MAgPIE=off)
  #            -> couplePromToMagpie()   # OPEN-PROM gdx  -> coupling.mif
  #            -> magpie (Rscript start.R, reads env-vars OPENPROM_COUPLING_*)
  #            -> coupleMagpieToProm()   # MAgPIE report.mif -> iPrices/iEmissions
  #            -> open-prom (link2MAgPIE=on)
  #            -> reportOutput.R (postprom)
  saveMetadata(DevMode = 0)
  sceName <- "SSP2-PkBudg650"

  magpieRoot  <- NULL
  existingRun <- NULL
  if (file.exists("config.json")) {
    config      <- fromJSON("config.json")
    magpieRoot  <- config$magpie_path
    existingRun <- config$task7_existingRun
  }
  if (is.null(magpieRoot) || !nzchar(magpieRoot)) {
    stop("[task 7] config.json must define magpie_path (absolute path to the magpie/ directory).")
  }

  reuseExisting <- !is.null(existingRun) && nzchar(existingRun)
  if (reuseExisting) {
    if (!dir.exists(existingRun)) {
      stop("[task 7] task7_existingRun folder does not exist: ", existingRun)
    }
    openPromRun <- normalizePath(existingRun, winslash = "/", mustWork = TRUE)
    setwd(openPromRun)
    cat(">>> [task 7] reusing existing run folder:", openPromRun, "\n")
  } else {
    if (withRunFolder) createRunFolder(setScenarioName(sceName))
    openPromRun <- getwd()
  }
  couplingMif <- file.path(openPromRun, "openprom_coupling.mif")

  # ---- Step 1: OPEN-PROM run with link2MAgPIE = off -----------------------
  if (!reuseExisting) {
    cat(">>> [task 7] Step 1/6: OPEN-PROM run (link2MAgPIE=off)\n")
    cmd1 <- paste0(gams,
                   " main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=off",
                   " -logOption 4 -Idir=./data 2>&1")
    if (.Platform$OS.type == "unix") {
      system(paste0("sh -c ", shQuote(cmd1)))
    } else {
      shell(paste0(cmd1, " | tee full_round1.log"))
    }
    if (!isRunSuccessful("modelstat.txt")) {
      stop("[task 7] First OPEN-PROM run failed. Aborting soft-link.")
    }
    file.copy(file.path(openPromRun, "blabla.gdx"),
              file.path(openPromRun, "blabla_round1.gdx"),
              overwrite = TRUE)
  } else {
    cat(">>> [task 7] Step 1/6: SKIPPED (reusing existing round-1)\n")
    if (!file.exists(file.path(openPromRun, "blabla_round1.gdx"))) {
      srcGdx <- file.path(openPromRun, "blabla.gdx")
      if (!file.exists(srcGdx)) {
        stop("[task 7] Existing run folder has neither blabla_round1.gdx nor blabla.gdx: ",
             openPromRun)
      }
      file.copy(srcGdx, file.path(openPromRun, "blabla_round1.gdx"), overwrite = FALSE)
    }
  }
  openPromGdx <- file.path(openPromRun, "blabla_round1.gdx")

  # ---- Step 2: OPEN-PROM -> MAgPIE via couplePromToMagpie() --------------
  cat(">>> [task 7] Step 2/6: couplePromToMagpie() -> ", couplingMif, "\n")
  library(postprom)
  couplePromToMagpie(
    gdxPath    = openPromGdx,
    outMifPath = couplingMif,
    scenario   = sceName
  )

  # ---- Step 3: MAgPIE run (reads coupling mif via env-vars) --------------
  cat(">>> [task 7] Step 3/6: MAgPIE run\n")
  setwd(magpieRoot)
  Sys.setenv(
    OPENPROM_COUPLING_MIF       = couplingMif,
    OPENPROM_COUPLING_SCENARIO  = sceName,
    OPENPROM_COUPLING_GHG       = "on",
    OPENPROM_COUPLING_BIOENERGY = "on"
  )
  magpie_exit <- system("Rscript start.R")
  Sys.unsetenv(c("OPENPROM_COUPLING_MIF", "OPENPROM_COUPLING_SCENARIO",
                 "OPENPROM_COUPLING_GHG", "OPENPROM_COUPLING_BIOENERGY"))
  if (magpie_exit != 0) {
    setwd(openPromRun)
    stop("[task 7] MAgPIE run failed with exit code ", magpie_exit, ".")
  }
  magpieOutDirs   <- list.dirs("output", recursive = FALSE)
  latestMagpieRun <- magpieOutDirs[which.max(file.info(magpieOutDirs)$mtime)]
  magpieReport    <- file.path(normalizePath(latestMagpieRun, winslash = "/"), "report.mif")

  # ---- Step 4: MAgPIE -> OPEN-PROM via coupleMagpieToProm() --------------
  cat(">>> [task 7] Step 4/6: coupleMagpieToProm()\n")
  setwd(openPromRun)
  coupleMagpieToProm(
    reportMifPath       = magpieReport,
    outCsvPath          = file.path(openPromRun, "iPrices_magpie.csv"),
    outEmissionsCsvPath = file.path(openPromRun, "iEmissions_magpie.csv"),
    gdxPath             = openPromGdx
  )

  # ---- Step 5: OPEN-PROM run with link2MAgPIE = on ------------------------
  cat(">>> [task 7] Step 5/6: OPEN-PROM run (link2MAgPIE=on)\n")
  cmd2 <- paste0(gams,
                 " main.gms --DevMode=0 --GenerateInput=off --link2MAgPIE=on",
                 " -logOption 4 -Idir=./data 2>&1")
  if (.Platform$OS.type == "unix") {
    system(paste0("sh -c ", shQuote(cmd2)))
  } else {
    shell(paste0(cmd2, " | tee full_round2.log"))
  }

  # ---- Step 6: postprom / reportOutput.R + sync ---------------------------
  if (withRunFolder && withReport) {
    cat(">>> [task 7] Step 6/6: reportOutput.R\n")
    run_path <- getwd()
    setwd("../../") # Going back to OPEN-PROM root
    report_cmd <- paste0("Rscript ./reportOutput.R ", run_path)
    system(report_cmd)
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
}