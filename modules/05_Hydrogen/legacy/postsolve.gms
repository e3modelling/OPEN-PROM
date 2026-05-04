*' @title Postsolve of OPEN-PROMs Hydrogen Module
*' @code
* Fix values of variables for the next time step

* Hydrogen Module

*---
VmConsFuelTechH2Prod.FX(runCyL,H2TECH,EF,YTIME)$TIME(YTIME) = VmConsFuelTechH2Prod.L(runCyL,H2TECH,EF,YTIME)$TIME(YTIME);
V05GapShareH2Tech1.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05GapShareH2Tech1.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05DemGapH2.FX(runCyL,YTIME)$TIME(YTIME) = V05DemGapH2.L(runCyL,YTIME)$TIME(YTIME);
V05CaptRateH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CaptRateH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05ProdH2(runCyL,H2TECH,YTIME)$TIME(YTIME) = VmProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostVarProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostVarProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostProdCCSNoCCSH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostProdCCSNoCCSH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostAvgProdH2(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME);

option clear = Q05CostProdH2Tech;
option clear = Q05CostVarProdH2Tech;
option clear = Q05PremRepH2Prod;
option clear = Q05DemGapH2;
option clear = Q05CostProdCCSNoCCSH2Prod;
option clear = Q05GapShareH2Tech1;
option clear = Q05GapShareH2Tech2;
option clear = Q05ProdH2;
option clear = Q05CostAvgProdH2;
option clear = VmProdH2;
option clear = V05CostVarProdH2Tech;
option clear = V05CostProdH2Tech;
option clear = V05CostProdCCSNoCCSH2Prod;
option clear = VmCostAvgProdH2;

VmProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME) = p05ProdH2(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05CostVarProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME) = p05CostVarProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05CostProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME) = p05CostProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05CostProdCCSNoCCSH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME) = p05CostProdCCSNoCCSH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME);
VmCostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME) = p05CostAvgProdH2(runCyL,YTIME)$TIME(YTIME);
*V05DelivH2InfrTech.FX(runCyL,INFRTECH,YTIME)$TIME(YTIME) = V05DelivH2InfrTech.L(runCyL,INFRTECH,YTIME)$TIME(YTIME);
*---