@echo off
REM ============================================================================
REM Daily scheduled OPEN-PROM run: NPi + 1.5C + 2C
REM
REM Two-stage workflow:
REM   Stage 1 (single-mode, not batchable):
REM     - loadMadratData.R           regenerate data/ and targets/ via mrprom
REM     - start.R task_id=5          MatCalibration -> produces calibrated
REM                                  parameter files back into data/
REM   Stage 2 (batch):
REM     - start.R scripts/tools/daily_scenarios.csv
REM         Runs the three daily scenarios (NPi, 1.5C, 2C) as task 2,
REM         each in its own runs/<scenario_name>_<timestamp>/ folder.
REM
REM Scenario names + fScenario values are defined in daily_scenarios.csv.
REM config.json is not modified by this script.
REM ============================================================================

REM Install latest version of mrprom
Rscript -e "devtools::install_github('e3modelling/mrprom')"

REM Set the default model path (change for your configuration)
set mpath=C:\Users\Plessias\Desktop\Scheduled_OPEN-PROM\OPEN-PROM
cd %mpath%

REM Force a fresh data + targets generation
rmdir /s /q data
rmdir /s /q targets

REM Sync to clean main
git switch main
git reset --hard
git pull

REM ---- Stage 1: regenerate data and run material calibration -----------------
Rscript scripts/tasks/loadMadratData.R DevMode=0
Rscript start.R task_id=5

REM ---- Stage 2: batch-run NPi, 1.5C, 2C via task 2 ---------------------------
Rscript start.R scripts/tools/daily_scenarios.csv
