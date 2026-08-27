@echo off
setlocal EnableExtensions EnableDelayedExpansion
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
REM
REM ---------------------------------------------------------------------------
REM CHANGES FROM THE ORIGINAL
REM   * devtools::install_github is replaced by install-prom-r.R, which resolves
REM     the non-CRAN dependencies (mrdrivers, gdx, gdxrrw, mip, piamValidation)
REM     that plain install_github cannot find.
REM   * The R packages go into a self-contained prefix (prom_env). Everything
REM     after the install runs inside it, so the scheduled job cannot disturb
REM     -- or be disturbed by -- any other R setup on the machine.
REM   * madrat_path is explicit and passed through at runtime.
REM   * git sync now happens BEFORE data/ is deleted. In the original, a tracked
REM     data/ would have been restored by "git reset --hard" straight after the
REM     rmdir, silently defeating the forced rebuild.
REM   * Every step is checked; the run stops at the first failure and the whole
REM     session is logged.
REM ============================================================================

REM ====================== FILL THESE FOR YOUR MACHINE ========================
REM NOTE ON QUOTING: put the quotes around the WHOLE assignment, never around
REM the value alone -- cmd stores value-side quotes as part of the string.
REM   set "madrat_path=C:\My Data\madrat"     <- correct, spaces are fine
REM   set madrat_path="C:\My Data\madrat"     <- WRONG, value keeps the quotes
REM (Stray quotes are stripped below anyway, but get the form right.)

set "mpath="
set "gams_path="
set "model_runs_path="

set "prom_env=%USERPROFILE%\prom-env"
set "madrat_path="
REM   ^^ CHANGE madrat_path if you already have a populated madrat folder.
REM      The default above creates a fresh empty one inside prom_env, which
REM      means every source gets downloaded again on the first run.
set "installer=%~dp0install-prom-r.R"
set "clean_install=0"
set "auto_clone=0"
set "repo_url=https://github.com/e3modelling/OPEN-PROM.git"

REM ---- Reporting (e3modelling/Reporting) ------------------------------------
set "report_repo="
set "reporter=%~dp0Reporting\daily_report.py"
set "runs_dir=%mpath%\runs"
set "python_exe=python"
REM   report_repo : local checkout of e3modelling/Reporting (push target)
REM   reporter    : daily_report.py (default: next to this script)
REM   runs_dir    : where OPEN-PROM writes per-scenario run folders
REM   python_exe  : python launcher (python / py / full path)

REM Strip any quotes that ended up inside the values, whichever form was used.
if defined mpath           set mpath=%mpath:"=%
if defined prom_env        set prom_env=%prom_env:"=%
if defined madrat_path     set madrat_path=%madrat_path:"=%
if defined gams_path       set gams_path=%gams_path:"=%
if defined installer       set installer=%installer:"=%
if defined report_repo     set report_repo=%report_repo:"=%
if defined reporter        set reporter=%reporter:"=%
if defined runs_dir        set runs_dir=%runs_dir:"=%
if defined model_runs_path set model_runs_path=%model_runs_path:"=%

REM OPEN-PROM builds its GAMS command as <gams_path>gams, with no separator
REM inserted, so gams_path MUST end with a backslash or you get C:\GAMS\52gams.
REM Append it if it is missing. (The --gams= flag for the R installer wants it
REM WITHOUT the backslash; gams_flag below is derived for that.)
if defined gams_path if not "%gams_path:~-1%"=="\" set "gams_path=%gams_path%\"
REM   mpath           : model root (where this repo is checked out)
REM   gams_path       : GAMS install dir, e.g. C:\GAMS\52\ (blank -> use PATH).
REM                     A trailing backslash is required and added if missing.
REM   model_runs_path : only used if behavior.withSync=true (it is false here);
REM                     may be left blank.
REM   prom_env        : self-contained R environment for this pipeline
REM   madrat_path     : madrat main folder (sources + cache). Point this at a
REM                     shared folder to reuse downloaded sources between
REM                     machines; it can hold many GB once populated.
REM   installer       : path to install-prom-r.R (default: next to this file)
REM   clean_install   : 1 = rebuild the R environment from scratch every run
REM                     (a true clean-room test, but slow). 0 = update in place.
REM   auto_clone      : 1 = git clone repo_url into mpath if it is missing
REM                     (useful when setting up a new PC). 0 = fail instead.
REM ===========================================================================

REM ---- logging ---------------------------------------------------------------
REM The whole run is redirected into the log; :say echoes milestones to the
REM console as well, so an interactive run still shows progress.
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set STAMP=%%i
if not defined STAMP set "STAMP=run"
set "LOGDIR=%~dp0logs"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
set "LOG=%LOGDIR%\daily_run_%STAMP%.log"

echo ============================================================
echo  OPEN-PROM daily integration run  %STAMP%
echo  log: %LOG%
echo ============================================================

call :main > "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (
  echo  All four scenarios completed.
) else (
  echo  [x] FAILED - full output in the log.
)
echo  log: %LOG%
echo ============================================================
endlocal & exit /b %RC%

REM ============================================================================
:say
REM echo to both the log (stdout, already redirected) and the console.
REM Messages must not contain > or < : %* is expanded before redirection is
REM parsed, so a stray angle bracket would be treated as a redirect.
echo %*
echo %*> CON
goto :eof

:blank
echo.
echo.> CON
goto :eof

REM ============================================================================
:main

if not exist "%installer%" (
  call :say [x] installer not found: %installer%
  call :say     Put install-prom-r.R next to this script, or set installer= above.
  exit /b 1
)

REM ---- 0. Locate / obtain the model repository -------------------------------
REM mpath must be the OPEN-PROM checkout itself: the folder that contains .git,
REM start.R and main.gms -- NOT the folder this script lives in.
if not exist "%mpath%" (
  if "%auto_clone%"=="1" (
    call :say Cloning %repo_url% into %mpath% ...
    git clone %repo_url% "%mpath%"  || goto :fail
  ) else (
    call :say [x] mpath does not exist: %mpath%
    call :say     Set mpath to your OPEN-PROM checkout, or set auto_clone=1.
    exit /b 1
  )
)

if not exist "%mpath%\.git" (
  call :say [x] %mpath% is not a git repository.
  call :say     mpath must point at the OPEN-PROM checkout - the folder
  call :say     containing .git, start.R and main.gms.
  call :say     It is usually NOT the folder this script lives in.
  exit /b 1
)

cd /d %mpath%

REM GAMS must actually be where gams_path says, or every solve fails at run time
REM with a non-obvious exit code rather than a "file not found".
if defined gams_path (
  if not exist "%gams_path%gams.exe" (
    call :say [x] gams.exe not found at: %gams_path%gams.exe
    call :say     Fix gams_path - it must be the GAMS install folder,
    call :say     for example C:\GAMS\52\
    exit /b 1
  )
  call :say Using GAMS at %gams_path%
)

if not exist "start.R" (
  call :say [warn] start.R not found in %mpath% - is this really the OPEN-PROM repo?
)

REM ---- 1. Sync to clean main -------------------------------------------------
REM Done first: "git reset --hard" would otherwise resurrect a tracked data/.
call :blank
call :say [1/8] Syncing repository to clean main...
git switch main                || goto :fail
git reset --hard               || goto :fail
git pull                       || goto :fail

REM ---- 2. Force a fresh data generation --------------------------------------
REM (targets/ is rebuilt by task 3's GenerateInput.)
call :blank
call :say [2/8] Removing data/ to force regeneration...
if exist data rmdir /s /q data

REM ---- 3. Refresh the R environment -----------------------------------------
REM Reinstalls mrprom and postprom at their latest main state, together with
REM their non-CRAN dependencies, into the self-contained prefix.
call :blank
call :say [3/8] Refreshing R environment at %prom_env% ...

REM Quotes were already stripped from the config values at the top. Here we
REM only drop a trailing backslash (which would otherwise sit next to the
REM closing quote) and re-quote each value so paths with spaces stay one arg.
set "madrat_flag=%madrat_path%"
if "!madrat_flag:~-1!"=="\" set "madrat_flag=!madrat_flag:~0,-1!"

REM COMMON_OPTS is reused by the --check call below, so the verification
REM inspects exactly the configuration that was just installed instead of
REM re-deriving it from defaults.
set "COMMON_OPTS=--prefix="%prom_env%" --madrat="!madrat_flag!""
set "INSTALL_OPTS=!COMMON_OPTS! --also=jsonlite"
if defined gams_path (
  set "gams_flag=%gams_path%"
  if "!gams_flag:~-1!"=="\" set "gams_flag=!gams_flag:~0,-1!"
  set "INSTALL_OPTS=!INSTALL_OPTS! --gams="!gams_flag!""
)

REM Make the folder explicit for every R process started from here on --
REM start.R, the config writer and postprom all inherit it, so nothing
REM depends on the precedence chain inside the installer.
set "MADRAT_MAINFOLDER=!madrat_flag!"
if "%clean_install%"=="1" set "INSTALL_OPTS=!INSTALL_OPTS! --clean"

if not exist "!madrat_flag!" (
  call :say [warn] madrat folder does not exist yet: !madrat_flag!
  call :say [warn] Every source will be downloaded from scratch on this run.
)

call :say Command: Rscript "%installer%" !INSTALL_OPTS!
Rscript "%installer%" !INSTALL_OPTS!   || goto :fail

REM Everything from here on runs inside that environment.
call "%prom_env%\activate.bat"         || goto :fail

call :blank
call :say [4/8] Verifying the environment...
Rscript "%installer%" --check !COMMON_OPTS!  || goto :fail

REM ---- 4. Write the daily-run config.json (also sets scenario 1 = NPi) -------
REM Paths read from the SET vars above; non-path settings mirror root config.json.
call :blank
call :say [5/9] Writing config.json ...
Rscript -e "library(jsonlite); cfg<-list(paths=list(model_runs_path=Sys.getenv('model_runs_path'), gams_path=Sys.getenv('gams_path')), behavior=list(withRunFolder=TRUE, withSync=TRUE, withReport=TRUE, uploadGDX=FALSE), scenario=list(scenario_name='DAILY_NPi', description='Daily main-branch integration test (mrprom + open-prom + postprom).', gams_flags=list(fScenario=1L, fEndY=2100L, CountrySolveMode='serial', Transport='simple', Industry='technology', RestOfEnergy='legacy', PowerGeneration='simple', Hydrogen='legacy', CO2='legacy', Emissions='legacy', Prices='legacy', Heat='heat', Curves='off', Economy='economy'))); write(toJSON(cfg, auto_unbox=TRUE, pretty=TRUE), 'config.json')"  || goto :fail

REM ---- 5. NPi: task 3 rebuilds data/+targets/ (via mrprom) then runs NPi -----
call :blank
call :say [6/9] DAILY_NPi   (task 3, rebuilds data via mrprom)
Rscript start.R task_id=3      || goto :fail

REM ---- 6. No carbon price: task 2, reuses the data/ rebuilt above -------------
call :blank
call :say [7/9] DAILY_NoCP  (task 2)
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILY_NoCP'; c$scenario$gams_flags$fScenario<-0L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"  || goto :fail
Rscript start.R task_id=2      || goto :fail

REM ---- 7. 1.5C: task 2 -------------------------------------------------------
call :blank
call :say [8/9] DAILY_1p5C  (task 2)
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILY_1p5C'; c$scenario$gams_flags$fScenario<-2L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"  || goto :fail
Rscript start.R task_id=2      || goto :fail

REM ---- 8. 2C: task 2 ---------------------------------------------------------
call :blank
call :say [8/9] DAILY_2C    (task 2)
Rscript -e "library(jsonlite); c<-fromJSON('config.json',simplifyVector=FALSE); c$scenario$scenario_name<-'DAILY_2C'; c$scenario$gams_flags$fScenario<-3L; write(toJSON(c,auto_unbox=TRUE,pretty=TRUE),'config.json')"  || goto :fail
Rscript start.R task_id=2      || goto :fail

REM ---- 9. Update the Reporting repo -----------------------------------------
REM Runs even if a scenario failed, so the report reflects reality. The report
REM step is best-effort: a push failure is logged but does not fail the run.
call :blank
call :say [9/9] Updating Reporting repo ...
if not exist "!reporter!" (
  call :say [warn] reporter not found: !reporter!  - skipping report.
) else (
  "!python_exe!" "!reporter!" --runs-dir "!runs_dir!" --repo "!report_repo!" --install-status "!INSTALL_STATUS!" --n 3
  if errorlevel 1 call :say [warn] reporter exited non-zero - see README / git_log.txt
)

call :blank
call :say All scenarios completed; report updated.
exit /b 0

:fail
set "RC=%ERRORLEVEL%"
call :blank
call :say [x] FAILED at the step above, exit code %RC%
REM Still publish a report so the failure is visible in the Reporting repo.
if not defined INSTALL_STATUS set "INSTALL_STATUS=failed"
if exist "!reporter!" (
  "!python_exe!" "!reporter!" --runs-dir "!runs_dir!" --repo "!report_repo!" --install-status "!INSTALL_STATUS!" --n 3  2>&1
)
exit /b %RC%
