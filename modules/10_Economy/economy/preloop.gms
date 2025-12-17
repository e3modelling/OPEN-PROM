*' @title Economy module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V10SubsiTot.FX(runCy,YTIME)$(not AN(YTIME)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;