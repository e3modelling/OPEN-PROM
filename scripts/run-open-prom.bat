@echo off

REM Install latest version of mrprom
Rscript -e "devtools::install_github('e3modelling/mrprom')"

REM Change directory to the target folder (change this based on your local configuration)
cd C:\Users\Plessias\Desktop\Scheduled_OPEN-PROM\OPEN-PROM

REM Switch to the 'main' branch in the git repository
git switch main

REM Revert changes to local branch
git reset --hard

REM Pull the latest changes from the remote repository
git pull

REM Run the R script with the specified task argument
Rscript start.R task=3

