*' @title Heat module postsolve
* Fix values of variables for the next time step

* Heat Module

*---
VmProdSte.FX(runCyL,TSTEAM,YTIME)$TIME(YTIME) = VmProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
V09CostProdSte.FX(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09CostProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
*V09CostElecProdCHP.FX(runCyL,DSBS,TSTEAM,YTIME)$TIME(YTIME) = V09CostElecProdCHP.L(runCyL,DSBS,TSTEAM,YTIME)$TIME(YTIME);      
*VmCostElcAvgProdCHP.FX(runCyL,TSTEAM,YTIME)$TIME(YTIME) = VmCostElcAvgProdCHP.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
*VmCostAvgProdSte.FX(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdSte.L(runCyL,YTIME)$TIME(YTIME);