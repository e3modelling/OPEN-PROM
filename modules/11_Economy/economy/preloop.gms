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

VmSubsiDemTechAvail.L(runCy,DSBS,TECH,YTIME) = 1e-6;
VmSubsiSupTech.L(runCy,STECH,YTIME) = 1e-6;
VmSubsiCapCostSupply.L(runCy,SSBS,STECH,YTIME) = 1e-6;

*' Seed parameters from historical data
p11SubsiTot(runCy,YTIME)$(DATAY(YTIME)) = 0.0001;
pmSubsiDemTechAvail(runCy,DSBS,TECH,YTIME)$(DATAY(YTIME)) = 1e-6;
pmSubsiDemITech(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME)) = 0;
pmSubsiDemTech(runCy,DSBS,TECH,YTIME)$(DATAY(YTIME)) = 0;
pmSubsiSupTech(runCy,STECH,YTIME)$(DATAY(YTIME)) = 1e-6;
pmSubsiCapCostTech(runCy,DSBS,TECH,YTIME)$(DATAY(YTIME)) = 0;
pmSubsiCapCostSupply(runCy,SSBS,STECH,YTIME)$(DATAY(YTIME)) = 1e-6;
pmNetSubsiTax(runCy,YTIME)$(DATAY(YTIME)) = 0;

*' Initialize variable levels from previous period parameter
V11SubsiTot.L(runCy,YTIME) = p11SubsiTot(runCy,YTIME-1);
VmSubsiDemTechAvail.L(runCy,DSBS,TECH,YTIME) = pmSubsiDemTechAvail(runCy,DSBS,TECH,YTIME-1);
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME) = pmSubsiDemITech(runCy,DSBS,ITECH,YTIME-1);
VmSubsiDemTech.L(runCy,DSBS,TECH,YTIME) = pmSubsiDemTech(runCy,DSBS,TECH,YTIME-1);
VmSubsiSupTech.L(runCy,STECH,YTIME) = pmSubsiSupTech(runCy,STECH,YTIME-1);
VmSubsiCapCostTech.L(runCy,DSBS,TECH,YTIME) = pmSubsiCapCostTech(runCy,DSBS,TECH,YTIME-1);
VmSubsiCapCostSupply.L(runCy,SSBS,STECH,YTIME) = pmSubsiCapCostSupply(runCy,SSBS,STECH,YTIME-1);
VmNetSubsiTax.L(runCy,YTIME) = pmNetSubsiTax(runCy,YTIME-1);