*' @title Economy module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V11SubsiTot.LO(runCy,YTIME) = 0.0001;
*V11SubsiTot.L(runCy,YTIME) = 1;

*---
VmSubsiDemITech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)) = 1;
VmSubsiDemITech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or TFIRST(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
*---
VmNetSubsiTax.FX(runCy,YTIME)$(DATAY(YTIME)) = 0;