*** preliminaries

*** Generating an execution profile
option profile = 1;
*** number of columns that are listed for each variable in the column listing
option limcol = 300;
*** number of rows that are listed for each equation in the equation listing
option limrow = 300;
*** save a GDX file after solve, containing all computed variables
option savepoint = 1;

*** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options

*** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
*** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd
*** onEmpty allows declarations of empty parameters
$onEmpty

*** TODO: check if the contents of this block are actually used later
*** GAMS "flags" definitions

*** Maximum number of solver attempts
$evalGlobal SolverTryMax 1

$setGlobal fCountries 'RAS,RWO,REU,REP,RAF,RLA,ARG,OCE,AUT,BEL,BRA,BGR,CAN,CHA,HRV,CYP,CZE,DNK,EGY,EST,FIN,FRA,DEU,GRC,HUN,NSI,IND,IDN,IRN,IRL,ISR,ITA,JPN,KOR,LVA,LTU,LUX,MLT,MEX,MAR,NLD,NGA,POL,PRT,ROU,RUS,SAU,SVK,SVN,ZAF,ESP,SWE,TUN,TUR,GBR,USA'

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
$evalGlobal fEndY 2020
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%

*** end of dollar commands section, no further flag definitions allowed 

*** load input data files
* $call "RScript ./loadMadratData.R"

$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms

* FIXME: This issue will be created after the PR is merged.
* author=derevirn

* FIXME: Testing GH Action changed permissions.
* author=derevirn