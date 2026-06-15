@echo off
REM ============================================================================
REM Daily scheduled OPEN-PROM run -- main-branch integration test.
REM
REM Purpose: verify that the *current main* of the three repos still works
REM together: mrprom (input data via MADRAT), open-prom (this model), and
REM postprom (reporting). All three are exercised by the runs below:
REM   - mrprom   : task 3 turns on GenerateInput, which $calls loadMadratData.R
REM                -> retrieveData() -> mrprom rebuilds data/ and targets/.
REM   - open-prom: the GAMS solves themselves (git pull brings latest main).
REM   - postprom : reportOutput.R (run after every solve, withReport=TRUE)
REM                does library(postprom).
REM
REM Scenarios run one-by-one in single mode (Rscript start.R task_id=N), NOT
REM the CSV batch -- batch only allows task_id in {2,7}, but the first run needs
REM task 3. Order matters: the task-3 run must come first because it is the one
REM that rebuilds data/ + targets/ (and copies them back to the repo root); the
REM later task-2 runs reuse that freshly built data.
REM
REM   1. NPi          task_id=3  fScenario=1   (rebuilds data, then NPi solve)
REM   2. No carbon px task_id=2  fScenario=0   (reuses data)
REM   3. 1.5C         task_id=2  fScenario=2
REM   4. 2C           task_id=2  fScenario=3
REM
REM fScenario semantics (main.gms:237): 0=no carbon price, 1=NPi, 2=1.5C, 3=2C.
REM
REM This script writes config.json itself (see below) so the run does not depend
REM on whatever config.json happens to be committed on main. Non-path settings
REM mirror the repo-root config.json; paths come from the SET vars below; the
REM magpie block is omitted (task 7 is not run, so it has no effect).
REM ============================================================================

REM ====================== FILL THESE FOR YOUR MACHINE ========================
set mpath=D:\dailyruns
set gams_path=C:\GAMS\52\
set model_runs_path='C:\Users\gianoussakis\Ricardo Plc\Global Integrated Assessment Models - Documents\Work\PROMETHEUS Model\Runs'
REM   mpath           : model root (where this repo is checked out)
REM   gams_path       : GAMS install dir, e.g. C:\GAMS\48\ (blank -> use PATH)
REM   model_runs_path : only used if behavior.withSync=true (it is false here);
REM                     may be left blank.
REM ===========================================================================

cd %mpath%

REM Reinstall the two e3modelling R packages to their latest main state.
Rscript -e "devtools::install_github('e3modelling/mrprom'); devtools::install_github('e3modelling/postprom')"

REM Force a fresh data generation (targets is rebuilt by task 3's GenerateInput).
rmdir /s /q data
rmdir /s /q targets

REM Sync to clean main.
git switch dailyrunsag
git reset --hard
git pull

REM ---- Write the daily-run config.json (also sets scenario 1 = NPi) ----------
REM Paths read from the SET vars above; non-path settings mirror root config.json.
Rscript -e "library(jsonlite); cfg<-list(paths=list(model_runs_path=Sys.getenv('model_runs_path'), gams_path=Sys.getenv('gams_path')), behavior=list(withRunFolder=TRUE, withSync=FALSE, withReport=TRUE, uploadGDX=FALSE), scenario=list(scenario_name='DAILYAG_NPi', description='Daily main-branch integration test (mrprom + open-prom + postprom).', gams_flags=list(fScenario=1L, fEndY=2100L, CountrySolveMode='serial', Transport='simple', Industry='technology', RestOfEnergy='legacy', PowerGeneration='simple', Hydrogen='legacy', CO2='legacy', Emissions='legacy', Prices='legacy', Heat='heat', Curves='off', Economy='economy'))); write(toJSON(cfg, auto_unbox=TRUE, pretty=TRUE), 'config.json')"

REM ---- 1. NPi: task 3 rebuilds data/+targets/ (via mrprom) then runs NPi -----
Rscript start.R task_id=3

REM ---- 2. No carbon price: task 2, reuses the data/ rebuilt above -------------
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILYAG_NoCP'; c$scenario$gams_flags$fScenario<-0L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"
Rscript start.R task_id=2

REM ---- 3. 1.5C: task 2 -------------------------------------------------------
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILYAG_1p5C'; c$scenario$gams_flags$fScenario<-2L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"
Rscript start.R task_id=2

REM ---- 4. 2C: task 2 ---------------------------------------------------------
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILYAG_2C'; c$scenario$gams_flags$fScenario<-3L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"
Rscript start.R task_id=2

python "D:\Reporting\DR.py"
