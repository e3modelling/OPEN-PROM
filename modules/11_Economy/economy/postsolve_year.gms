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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/11_Economy/economy/preloop.gms"

*' Initialize variable levels from previous period parameter
V11SubsiTot.L(runCy,YTIME) = p11SubsiTot(runCy,YTIME-1);
VmSubsiDemTechAvail.L(runCy,DSBS,TECH,YTIME) = pmSubsiDemTechAvail(runCy,DSBS,TECH,YTIME-1);
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME) = pmSubsiDemITech(runCy,DSBS,ITECH,YTIME-1);
VmSubsiDemTech.L(runCy,DSBS,TECH,YTIME) = pmSubsiDemTech(runCy,DSBS,TECH,YTIME-1);
VmSubsiSupTech.L(runCy,STECH,YTIME) = pmSubsiSupTech(runCy,STECH,YTIME-1);
VmSubsiCapCostTech.L(runCy,DSBS,TECH,YTIME) = pmSubsiCapCostTech(runCy,DSBS,TECH,YTIME-1);
VmSubsiCapCostSupply.L(runCy,SSBS,STECH,YTIME) = pmSubsiCapCostSupply(runCy,SSBS,STECH,YTIME-1);
VmNetSubsiTax.L(runCy,YTIME) = pmNetSubsiTax(runCy,YTIME-1);
