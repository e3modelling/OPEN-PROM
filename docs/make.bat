@echo off
set SPHINXBUILD=sphinx-build
set SOURCEDIR=.
set BUILDDIR=_build
if "%1"=="clean" (
    rmdir /s /q "%BUILDDIR%"
    goto :eof
)
if "%1"=="html" (
    %SPHINXBUILD% -b html "%SOURCEDIR%" "%BUILDDIR%\html"
    echo Build finished. The HTML pages are in %BUILDDIR%\html.
    goto :eof
)
echo Usage:
echo   make.bat html
echo   make.bat clean