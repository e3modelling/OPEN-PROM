*' @title Main
*' 
*' @description This is the OPEN-PROM model, the open version of the world energy model PROMETHEUS of E3-Modelling.
*' @code
*' *** preliminaries 
*' 
*' Coding Etiquette:
*' 
*' Below, you'll find the coding etiquette, a collection of conventions designed to streamline the development process and enhance code readability.
*' 
*' Please uphold these standards as you code! The naming convention for objects in the code is established as follows:
*' 
*' [ prefix ][ object type (e.g. Capacity, Cost, Share, etc.) ][ more specific information, if needed ][ object scope, e.g. Transport, Electricity, etc. ][ more specific information, if needed ]
*' 
*' Example:
*' 
*' [ Q/V/i ][ Cost/Cap/Dem/Cons/Price/etc. ][ Total ][ Elec/Tr/Ind/Dom ][ etc. ]
*' 
*' Q: Equation
*' 
*' q: Equation whose main computed variable does not participate in more than one equation, thus has decreased impact on the model
*' 
*' V: Variable, main variable computed by each equation
*' 
*' v: Variable that does not participate in more than one equation, thus has decreased impact on the model
*' 
*' i: Input, Inputs are datasets or constants that are exogenous to the model
*' 
*' Cost: Cost
*' 
*' Cap: Capacity
*' 
*' Dem: Demand
*' 
*' Pow: Power
*' 
*' Prod: Production
*' 
*' Cons: Consumption
*' 
*' Gen: Generation
*' 
*' Req: Required
*' 
*' Price: Pri
*' 
*' Fin: Final
*' 
*' Ene: Energy
*' 
*' Elec: Electricity
*' 
*' Ren: Renwable
*' 
*' Sec: Sector
*' 
*' Contr: Contribution
*' 
*' Curr: Current
*' 
*' Pot: Potential
*' 
*' Tr: Transport
*' 
*' Ind: Industry
*' 
*' Inv: Investment
*' 
*' Dom: Domestic
*' 
*' Dec: Decision
*' 
*' Mat: Maturity
*' 
*' Fac: Factor
*' 
*' Mult: Multiplier
*' 
*' Endog: Endogenous
*' 
*' Exog: Exogenous
*' 
*' Allow: Allowed
*' 
*' Maxm: Maximum
*' 
*' Mnm: Minimum
*' 
*' Pc: Passenger Cars
*' 
*' Cum: Cummulative
*' 
*' Imp: Imports
*' 
*' Exp: Exports
*' 
*' Bsl: Base Load
*' 
*' Tot: Total
*' 
*' Tech: Technology
*' 
*' Var: Variable
*' 
*' Pol: Policy
*' 
*' Chp: Combined Heat and Power plants
*' 
*' Ccs: Carbon capture and storage
*' 
*' Clim: Climate
*' 
*' Est: Estimated
*' 
*' Transf: Transformation
*' 
*' Capt: Captured
*' 
*' Seq: Sequestration
*' 
*' NAP: National Allocation Plan
*' 
*' Carb: Carbon
*' 
*' Val: Value
*' 
*' Sub: Subsector
*' 
*' Avg: Average
*' 
*' Consu: Consumers
*' 
*' @stop The following code will be ignored by goxygen until the next identifier.
*' *** Generating an execution profile
option profile = 1;
*' *** Number of columns that are listed for each variable in the column listing
option limcol = 30;
*' *** Number of rows that are listed for each equation in the equation listing
option limrow = 30;
*' *** Save a GDX file after each solve, containing all computed variables (0 off, 1 on)
option savepoint = 0;
*' *** Print solution in .lst file (on/off)
option solprint = off;

*' *** "dollar" ($) commands section: define GAMS flags & code control & compilation-time options
*' 
*' *** onEolCom: turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
*' *** onEnd: turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd
*' *** onEmpty allows declarations of empty parameters
$onEmpty
*' *** offOrder allows ord operator on dynamic sets
$offOrder

*' *** GAMS "flags" definitions
*' 
*' *** Maximum number of solver attempts
$evalGlobal SolverTryMax 4
*' *** Setting research mode (0) or development mode (1) to modify settings and parameters accordingly
$setGlobal DevMode 0 !! can be overwritten if VS Code Tasks are used
*' *** Write a GDX file with all data at the end of the run
$setGlobal WriteGDX on
*' *** Generate input data?
$setGlobal GenerateInput on !! can be overwritten if VS Code Tasks are used

$setGlobal fCountries 'MAR,IND,USA,EGY,RWO' !! can be overwritten if VS Code Tasks are used

$setGlobal fCountryList %countries%

$evalGlobal fPeriodOfYears 1

$evalGlobal fStartHorizon 2010
$evalGlobal fEndHorizon 2100
$evalGlobal fEndY 2030
$evalGlobal fStartY 2018
$evalGlobal fBaseY %fStartY% - %fPeriodOfYears%

*** end of dollar commands section, no further flag definitions allowed 

*' *** load input data files
$ifthen.genInp %GenerateInput% == on 
$ifthen.loadData %DevMode% == 0 $call "RScript ./loadMadratData.R DevMode=0"
$elseif.loadData %DevMode% == 1 $call "RScript ./loadMadratData.R DevMode=1"
$elseif.loadData %DevMode% == 2 $call "RScript ./loadMadratData.R DevMode=2"
$endif.loadData
$endif.genInp

$include sets.gms
$include declarations.gms
$include input.gms
$include equations.gms
$include preloop.gms
$include solve.gms
