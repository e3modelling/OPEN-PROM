*' @title Economy module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V11SubsiTot.LO(runCy,YTIME) = 0;
*V11SubsiTot.L(runCy,YTIME) = 1;

*---
VmSubsiDemITech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)) = 0;
VmSubsiDemITech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
*---
VmNetSubsiTax.FX(runCy,YTIME)$(DATAY(YTIME)) = 0;
*---
VmSubsiDemTech.LO(runCy,DSBS,TECH,YTIME) = 0;
VmSubsiDemTech.FX(runCy,DSBS,TECH,YTIME)$(DATAY(YTIME) or not SECTTECH(DSBS,TECH)) = 0;