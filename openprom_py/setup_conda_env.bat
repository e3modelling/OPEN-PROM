@echo off
REM Run this script from "Anaconda Prompt" (Start Menu). Double-click or: openprom_py\setup_conda_env.bat
REM It creates a conda env "openprom" with Python, Ipopt, and pip dependencies.

cd /d "%~dp0"

echo Creating conda environment "openprom" with Python 3.14...
call conda create -n openprom python=3.14 -y
if errorlevel 1 goto :error

echo.
echo Activating and installing Ipopt from conda-forge...
call conda activate openprom
call conda install -c conda-forge ipopt -y
if errorlevel 1 goto :error

echo.
echo Installing Python packages (Pyomo, pandas)...
pip install -r requirements.txt
if errorlevel 1 goto :error

echo.
echo Done. To use this environment:
echo   1. Open "Anaconda Prompt" from Start Menu
echo   2. Run: conda activate openprom
echo   3. cd to this folder and run: python run_poc.py
goto :eof

:error
echo Setup failed. Check the messages above.
exit /b 1
