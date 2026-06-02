*' Clear variables and equations (outside country loop — preserves no bounds for next year)
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

*' Re-apply critical bounds for all active countries (outside country loop)
V11SubsiTot.LO(runCy,YTIME) = 0;
VmSubsiDemITech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmSubsiDemTech.LO(runCy,DSBS,TECH,YTIME) = 0;

*' Initialize variable levels from previous period parameter
V11SubsiTot.L(runCyL,YTIME+1) = p11SubsiTot(runCy,YTIME);
VmSubsiDemTechAvail.L(runCyL,DSBS,TECH,YTIME+1) = pmSubsiDemTechAvail(runCy,DSBS,TECH,YTIME);
VmSubsiDemITech.L(runCyL,DSBS,ITECH,YTIME+1) = pmSubsiDemITech(runCy,DSBS,ITECH,YTIME);
VmSubsiDemTech.L(runCyL,DSBS,TECH,YTIME+1) = pmSubsiDemTech(runCy,DSBS,TECH,YTIME);
VmSubsiSupTech.L(runCyL,STECH,YTIME+1) = pmSubsiSupTech(runCy,STECH,YTIME);
VmSubsiCapCostTech.L(runCyL,DSBS,TECH,YTIME+1) = pmSubsiCapCostTech(runCy,DSBS,TECH,YTIME);
VmSubsiCapCostSupply.L(runCyL,SSBS,STECH,YTIME+1) = pmSubsiCapCostSupply(runCy,SSBS,STECH,YTIME);
VmNetSubsiTax.L(runCyL,YTIME+1) = pmNetSubsiTax(runCy,YTIME);
