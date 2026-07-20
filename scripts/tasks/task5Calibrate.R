# Task 5: OPEN-PROM CALIBRATE
# Material calibration only. Calibration=MatCalibration and fScenario=4 are hardcoded
# (scenario overrides are intentionally NOT applied). After the solve, move the
# calibration output files back into the root data/ directory.

runTask5 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))

  if (withRunFolder) createRunFolder(scn$scenario_name)
  saveMetadata(DevMode = 0)

  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste0(
      gams,
      " main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 --CountrySolveMode=parallel -logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
    )
    system(cmdCommand)
  } else {
    cmdCommand <- paste0(
      gams,
      " main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 --CountrySolveMode=parallel -logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
    )
    shell(cmdCommand)
  }

  if (withRunFolder && withSync) syncRun()

  CalibratedParams <- c("iMatFacPlaAvailCap.csv", "iMatrFactorData.csv",
                        "iScaleEndogScrap.csv", "iCalibUsefulEnergy.csv")
  CalibratedParamsPath <- file.path(getwd(), CalibratedParams)
  newPath <- file.path(dirname(dirname(getwd())), "data", CalibratedParams)
  file.rename(CalibratedParamsPath, newPath)
}
