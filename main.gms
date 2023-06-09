option limcol = 2000;
option limrow = 2000;

*** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options

*** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
*** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd
*** onEmpty allows declarations of empty parameters
$onEmpty

*** TODO: check if the contents of this block are actually used later
*** GAMS "flags" definitions
$setGlobal fCountries 'RAS,MAR'

$setGlobal fSingleCountryRun 'yes'

$setGlobal fCountryList %countries%

$setGlobal fScenario 'DECARB_400'
$setGlobal fBaseline 'BASE'

$evalGlobal fPeriodOfYears 1

$setGlobal fIncludeNonCO2 no

$setGlobal fReadCommonDB 'yes'
$setGlobal fReadCountryDB 'yes'
$setGlobal fReadCountryCalib 'yes'

$evalGlobal fStartHorizon 2010
$evalGlobal fEndHorizon 2100
$evalGlobal fEndY 2018
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%

*** end of dollar commands section, no further flag definitions allowed 

file name / '' /; !! construct for printing diagnostic output into log file
put name;

*$call '"C:\Program Files\R\R-4.2.2\bin\Rscript.exe" ".\loadMadratData.R"'
$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms
