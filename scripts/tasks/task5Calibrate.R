# Task 5: OPEN-PROM CALIBRATE
# Material calibration only. Calibration=MatCalibration and fScenario=4 are hardcoded
# (scenario overrides are intentionally NOT applied). After the solve, move the
# calibration output files back into the root data/ directory.

runTask5 <- function() {
  scn <- jsonlite::fromJSON(Sys.getenv("OPENPROM_SCENARIO"))
  land_use_extra <- Sys.getenv("OPENPROM_LAND_USE_FLAGS")

  if (withRunFolder) createRunFolder(scn$scenario_name)
  saveMetadata(DevMode = 0)

  if (.Platform$OS.type == "unix") {
    cmdCommand <- paste(
      gams,
      "main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 --CountrySolveMode=parallel",
      land_use_extra,
      "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1"
    )
    system(cmdCommand)
  } else {
    cmdCommand <- paste(
      gams,
      "main.gms -o mainCalib.lst --DevMode=0 --Calibration=MatCalibration --fScenario=4 --CountrySolveMode=parallel",
      land_use_extra,
      "-logOption 4 -AsyncSolLst 1 -Idir=./data 2>&1 | tee fullCalib.log"
    )
    shell(cmdCommand)
  }

  if (withRunFolder && withSync) syncRun()

  CalibratedParams <- c("iMatFacPlaAvailCap.csv", "iScaleEndogScrapPG.csv", "iMatrFactorData.csv",
                        "iScaleEndogScrap.csv", "iCalibUsefulEnergy.csv")
  CalibratedParamsPath <- file.path(getwd(), CalibratedParams)
  newPath <- file.path(dirname(dirname(getwd())), "data", CalibratedParams)
  file.rename(CalibratedParamsPath, newPath)
}
