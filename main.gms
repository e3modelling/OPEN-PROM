*' @title Main
*' 
*' @description This is the OPEN-PROM model, the open version of the world energy model PROMETHEUS of E3-Modelling.
*' @code
*' *** preliminaries 
*' ----
*' Coding Etiquette:
*' Q: Equation
*' q: Equation whose main computed variable does not participate in more than one equation, thus has decreased impact on the model.
*' V: Variable, main variable computed by each equation.
*' v: Variable that does not participate in more than one equation, thus has decreased impact on the model.
*' i: Input. Inputs are datasets or constants that are exogenous to the model.
*' ----
*' Cost: Cost
*' Cap: Capacity
*' Dem: Demand
*' Pow: Power
*' Cons: Consumption
*' Price: Price
*' Fin: Final
*' Ene: Energy
*' Elec: Electricity
*' Ren: Renwable
*' Curr: Current
*' Pot: Potential
*' Transp: Transport
*' Ind: Industry
*' Dom: Domestic
*' Mat: Maturity
*' Fac: Factor
*' Pc: Passenger Cars
*' Cum: Cummulative
*' Imp: Imports
*' Exp: Exports
*' Bsl: Base Load
*' Tot: Total
*' Tech: Technology
*' Var: Variable
*' Pol: Policy
*' Chp: Combined Heat and Power plants
*' Ccs: Carbon capture and storage
*' Clim: Climate
*' Est: Estimated
*' ----
*' [Q/V/i][Cost/Cap/Dem/Cons/Price/etc.][more specific, if needed][Elec/Transp/Ind/Dom][etc.]
*' *** Generating an execution profile
option profile = 1;
*' *** number of columns that are listed for each variable in the column listing
option limcol = 30;
*' *** number of rows that are listed for each equation in the equation listing
option limrow = 30;
*' *** save a GDX file after each solve, containing all computed variables (0 off, 1 on)
option savepoint = 1;
*' *** print solution in .lst file (on/off)
option solprint = on;

*' *** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options
*' 
*' *** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
*' *** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd
*' *** onEmpty allows declarations of empty parameters
$onEmpty

*' *** GAMS "flags" definitions
*' 
*' *** Maximum number of solver attempts
$evalGlobal SolverTryMax 4
*' *** Setting research mode (0) or development mode (1) to modify settings and parameters accordingly
$setGlobal DevMode 0 

$setGlobal fCountries 'MAR,IND,USA,EGY,CHA,RWO'

$setGlobal fCountryList %countries%

$evalGlobal fPeriodOfYears 1

$evalGlobal fStartHorizon 2010
$evalGlobal fEndHorizon 2100
$evalGlobal fEndY 2030
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%

*** end of dollar commands section, no further flag definitions allowed 

*' *** load input data files
$ifthen %DevMode% == 0 $call "RScript ./loadMadratData.R DevMode=0"
$elseif %DevMode% == 1 $call "RScript ./loadMadratData.R DevMode=1"
$endif

$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms
