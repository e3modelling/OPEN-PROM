*' @title Economy module postsolve
* Store values of variables as parameters for the next time step

* Economy Module

*---
* Store snapshot value
p11NetSubsiTax(runCyL,YTIME)$TIME(YTIME) = VmNetSubsiTax.L(runCyL,YTIME)$TIME(YTIME);
p11SubsiTot(runCyL,YTIME)$TIME(YTIME) = V11SubsiTot.L(runCyL,YTIME)$TIME(YTIME);
p11SubsiDemTechAvail(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiDemTechAvail.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
p11SubsiDemITech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = VmSubsiDemITech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p11SubsiDemTech(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiDemTech.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
p11SubsiSupTech(runCyL,STECH,YTIME)$TIME(YTIME) = VmSubsiSupTech.L(runCyL,STECH,YTIME)$TIME(YTIME);
p11SubsiCapCostTech(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmSubsiCapCostTech.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
p11SubsiCapCostSupply(runCyL,SSBS,STECH,YTIME)$TIME(YTIME) = VmSubsiCapCostSupply.L(runCyL,SSBS,STECH,YTIME)$TIME(YTIME);

*' Clear variables and equations for the next time step
option clear = V11SubsiTot;
option clear = VmNetSubsiTax;
option clear = VmSubsiDemTechAvail;
option clear = VmSubsiDemITech;
option clear = VmSubsiDemTech;
option clear = VmSubsiSupTech;
option clear = VmSubsiCapCostTech;
option clear = VmSubsiCapCostSupply;
option clear = Q11SubsiTot;
option clear = Q11SubsiDemTechAvail;
option clear = Q11SubsiDemITech;
option clear = Q11SubsiDemTech;
option clear = Q11SubsiSupTech;
option clear = Q11SubsiCapCostTech;
option clear = Q11SubsiCapCostSupply;
option clear = Q11NetSubsiTax;