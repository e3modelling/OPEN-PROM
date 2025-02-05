@echo off

REM Install latest version of mrprom
Rscript -e "devtools::install_github('e3modelling/mrprom')"

REM Set the default model path (change for your configuration)
set mpath=C:\Users\Plessias\Desktop\Scheduled_OPEN-PROM\OPEN-PROM
cd %mpath%

REM Delete the 'data' folder inside the model directory
rmdir /s /q data

REM Switch to the 'main' branch in the git repository
git switch main

REM Revert changes to local branch
git reset --hard

REM Pull the latest changes from the remote repository
git pull

REM Run the NPi default scenario
cd %mpath%
powershell "$content = Get-Content config.json; $content[3] = '    \"scenario_name\": \"DAILY_NPi\",'; Set-Content config.json $content;"
Rscript start.R task=3

REM Change the scenario to 1.5C and run the model
cd %mpath%
powershell "(Get-Content main.gms) -replace '\$evalGlobal fScenario 0', '$evalGlobal fScenario 1' | Set-Content main.gms"
powershell "$content = Get-Content config.json; $content[3] = '    \"scenario_name\": \"DAILY_1p5C\",'; Set-Content config.json $content;"
Rscript start.R task=2

REM Change the scenario to 2C and run the model
cd %mpath%
powershell "(Get-Content main.gms) -replace '\$evalGlobal fScenario 1', '$evalGlobal fScenario 2' | Set-Content main.gms"
powershell "$content = Get-Content config.json; $content[3] = '    \"scenario_name\": \"DAILY_2C\",'; Set-Content config.json $content;"
Rscript start.R task=2

