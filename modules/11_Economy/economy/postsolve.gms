*' @title Economy module postsolve
* Fix values of variables for the next time step

* Economy Module

*---
p11SubsiTot(runCyL,YTIME)$TIME(YTIME) = V11SubsiTot.L(runCyL,YTIME)$TIME(YTIME);
pmNetSubsiTax(runCyL,YTIME)$TIME(YTIME) = VmNetSubsiTax.L(runCyL,YTIME)$TIME(YTIME);
pmSubsiDemTechAvail(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiDemTechAvail.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
pmSubsiDemITech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = VmSubsiDemITech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
pmSubsiDemTech(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiDemTech.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
pmSubsiSupTech(runCyL,STECH,YTIME)$TIME(YTIME) = VmSubsiSupTech.L(runCyL,STECH,YTIME)$TIME(YTIME);
pmSubsiCapCostTech(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiCapCostTech.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
pmSubsiCapCostSupply(runCyL,SSBS,STECH,YTIME)$TIME(YTIME) = VmSubsiCapCostSupply.L(runCyL,SSBS,STECH,YTIME)$TIME(YTIME);
*---

option clear = V11SubsiTot;
option clear = VmSubsiDemTechAvail;
option clear = VmSubsiDemITech;
option clear = VmSubsiDemTech;
option clear = VmSubsiSupTech;
option clear = VmSubsiCapCostTech;
option clear = VmSubsiCapCostSupply;
option clear = VmNetSubsiTax;

option clear = Q11SubsiTot;
option clear = Q11SubsiDemTechAvail;
option clear = Q11SubsiDemITech;
option clear = Q11SubsiDemTech;
option clear = Q11SubsiSupTech;
option clear = Q11SubsiCapCostTech;
option clear = Q11NetSubsiTax;
*---
