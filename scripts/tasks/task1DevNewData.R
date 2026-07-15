# Task 1: OPEN-PROM DEV NEW DATA
# DevMode=1 + GenerateInput=on. After the solve, copy the freshly generated
# data/ and targets/ back to the repo root for use by subsequent runs.

runTask1 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  if (withRunFolder) createRunFolder(scn$scenario_name)
  saveMetadata(DevMode = 1)

  # ---- Stage 1: calibration + new data generation (not affected by scenario gams_flags) ----
  if (.Platform$OS.type == "unix") {
    calib_cmd <- paste0(
      gams,
      " main.gms -o mainCalib.lst --WriteGDX=off --DevMode=1 --fScenario=4 --GenerateInput=on --Calibration=MatCalibration --CountrySolveMode=parallel -logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
    )
    exit_code <- system(calib_cmd)
  } else {
    calib_cmd <- paste0(
      gams,
      " main.gms -o mainCalib.lst --WriteGDX=off --DevMode=1 --fScenario=4 --GenerateInput=on --Calibration=MatCalibration --CountrySolveMode=parallel -logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1 | tee fullCalib.log"
    )
    exit_code <- shell(calib_cmd)
  }
  cat("Executing calibration with data generation:\n", calib_cmd, "\n")

  if (exit_code != 0) {
    cat("ERROR: GAMS calibration failed with exit code:", exit_code, "\n")
    cat("Calibration and data generation failed. Check fullCalib.log for details.\n")
    stop("GAMS calibration execution failed during data generation. Terminating run.")
  }

  # Verify calibration outputs exist
  CalibratedParams <- c("iMatFacPlaAvailCap.csv", "iMatrFactorData.csv",
                        "iScaleEndogScrap.csv", "iCalibUsefulEnergy.csv")
  missing_files <- CalibratedParams[!file.exists(CalibratedParams)]
  if (length(missing_files) > 0) {
    cat("ERROR: Calibrated parameter files missing:", paste(missing_files, collapse = ", "), "\n")
    stop("Calibration failed to generate required parameter files. Terminating run.")
  }

  # Rename calibration outputs and move them into data/
  newNames <- gsub("[0-9]", "", CalibratedParams)
  CalibratedParamsPath <- file.path(getwd(), CalibratedParams)
  newPath <- file.path(getwd(), "data", newNames)
  rename_success <- file.rename(CalibratedParamsPath, newPath)
  if (!all(rename_success)) {
    cat("ERROR: Failed to rename calibrated parameter files\n")
    stop("File operation failed during calibration cleanup. Terminating run.")
  }
  cat("Calibration completed successfully.\n")

  # ---- Stage 2: research solve (picks up scenario gams_flags) ----
  extra <- Sys.getenv("OPENPROM_EXTRA_FLAGS")
  if (.Platform$OS.type == "unix") {
    research_cmd <- paste(
      gams, "main.gms --DevMode=1 --GenerateInput=off", extra,
      "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
    )
    exit_code <- system(paste0("sh -c ", shQuote(research_cmd)))
  } else {
    research_cmd <- paste(
      gams, "main.gms --DevMode=1 --GenerateInput=off", extra,
      "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1 | tee full.log"
    )
    exit_code <- shell(research_cmd)
  }
  cat("Executing research run:\n", research_cmd, "\n")
  if (exit_code != 0) {
    cat("ERROR: GAMS research execution failed with exit code:", exit_code, "\n")
    cat("Research run failed. Check full.log for details.\n")
    stop("GAMS research execution failed. Terminating run.")
  }
  cat("Research run completed successfully.\n")

  if (withRunFolder) file.copy("data",    to = "../../", recursive = TRUE)
  if (withRunFolder) file.copy("targets", to = "../../", recursive = TRUE)

  if (withRunFolder && withReport) {
    run_path <- getwd()
    setwd("../../")
    cat("Executing the report output script\n")
    system(paste0("Rscript ./scripts/tasks/reportOutput.R ", run_path))
    setwd(run_path)
  }
  if (withRunFolder && withSync) syncRun()
}
