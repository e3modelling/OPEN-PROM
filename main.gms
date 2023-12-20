*' @title Main
*' 
*' @description This is the OPEN-PROM model, the open version of the world energy model PROMETHEUS of E3-Modelling.
*' @code
*' *** preliminaries 
*' *** Generating an execution profile
option profile = 1;
*' *** number of columns that are listed for each variable in the column listing
option limcol = 300;
*' *** number of rows that are listed for each equation in the equation listing
option limrow = 300;
*' *** save a GDX file after solve, containing all computed variables
option savepoint = 1;

*' *** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options

*' *** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
*' *** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd
*' *** onEmpty allows declarations of empty parameters
$onEmpty

*** TODO: check if the contents of this block are actually used later
*' *** GAMS "flags" definitions

*' *** Maximum number of solver attempts
$evalGlobal SolverTryMax 1
*' *** Setting research mode (0) or development mode (1) to modify settings and parameters accordingly
$setGlobal DevMode 0 

$setGlobal fCountries 'MAR,IND,USA,EGY,CHA,RWO'

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
$evalGlobal fEndY 2030
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%

*** end of dollar commands section, no further flag definitions allowed 

*' *** load input data files
$call "RScript ./loadMadratData.R"

$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms
