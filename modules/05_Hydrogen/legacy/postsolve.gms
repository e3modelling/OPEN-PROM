*' @title Postsolve of OPEN-PROMs Hydrogen Module
*' @code
* Fix values of variables for the next time step

* Hydrogen Module

*---
VmProdH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = VmProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05DemGapH2.FX(runCyL,YTIME)$TIME(YTIME) = V05DemGapH2.L(runCyL,YTIME)$TIME(YTIME);
VmCostAvgProdH2.FX(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME);
V05CaptRateH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CaptRateH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05CostProdH2Tech.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05CostVarProdH2Tech.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostVarProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
*V05DelivH2InfrTech.FX(runCyL,INFRTECH,YTIME)$TIME(YTIME) = V05DelivH2InfrTech.L(runCyL,INFRTECH,YTIME)$TIME(YTIME);
*---