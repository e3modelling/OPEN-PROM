*' @title Heat module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V10CarbTaxTot.FX(runCy,YTIME)$(not AN(YTIME)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;