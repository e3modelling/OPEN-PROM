*' @title Economy module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V11SubsiTot.LO(runCy,YTIME) = 0.0001;
*V11SubsiTot.L(runCy,YTIME) = 1;

*---
VmSubsiDemITech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)) = 0;
VmSubsiDemITech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or TFIRST(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
*---
VmNetSubsiTax.FX(runCy,YTIME)$(DATAY(YTIME)) = 0;
*---
VmSubsiDemTech.LO(runCy,DSBS,TECH,YTIME) = 0;
VmSubsiDemTech.L(runCy,DSBS,TECH,YTIME)$(SECTTECH(DSBS,TECH)) = 0;
VmSubsiDemTech.FX(runCy,DSBS,TECH,YTIME)$(DATAY(YTIME) or TFIRST(YTIME) or not SECTTECH(DSBS,TECH)) = 0;

*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

p11SubsiTot(runCy,YTIME) = V11SubsiTot.L(runCy,YTIME);
pmSubsiDemTechAvail(runCy,DSBS,TECH,YTIME) = VmSubsiDemTechAvail.L(runCy,DSBS,TECH,YTIME);
pmSubsiDemITech(runCy,DSBS,ITECH,YTIME) = VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME);
pmSubsiDemTech(runCy,DSBS,TECH,YTIME) = VmSubsiDemTech.L(runCy,DSBS,TECH,YTIME);
pmSubsiSupTech(runCy,STECH,YTIME) = VmSubsiSupTech.L(runCy,STECH,YTIME);
pmSubsiCapCostTech(runCy,DSBS,TECH,YTIME) = VmSubsiCapCostTech.L(runCy,DSBS,TECH,YTIME);
pmSubsiCapCostSupply(runCy,SSBS,STECH,YTIME) = VmSubsiCapCostSupply.L(runCy,SSBS,STECH,YTIME);
pmNetSubsiTax(runCy,YTIME) = VmNetSubsiTax.L(runCy,YTIME);
