*' @title Heat module postsolve
* Fix values of variables for the next time step

* Heat Module

*---
pmProdSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = VmProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
pmCapSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = VmCapSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
p09CostProdSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09CostProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
pmConsFuelSteProd(runCyL,STEMODE,STEAMEF,YTIME)$TIME(YTIME) = VmConsFuelSteProd.L(runCyL,STEMODE,STEAMEF,YTIME)$TIME(YTIME);
p09CostVarProdSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09CostVarProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
pmCostAvgProdSte(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdSte.L(runCyL,YTIME)$TIME(YTIME);
p09ScrapRate(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09ScrapRate.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
p09DemGapSte(runCyL,YTIME)$TIME(YTIME) = V09DemGapSte.L(runCyL,YTIME)$TIME(YTIME);
p09CostCapProdSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09CostCapProdSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
p09GapShareSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09GapShareSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
p09CaptRateSte(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09CaptRateSte.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
p09ScrapRatePremature(runCyL,TSTEAM,YTIME)$TIME(YTIME) = V09ScrapRatePremature.L(runCyL,TSTEAM,YTIME)$TIME(YTIME);
pmDemTotSte(runCyL,YTIME)$TIME(YTIME) = VmDemTotSte.L(runCyL,YTIME)$TIME(YTIME);
*---

option clear = V09ScrapRate;
option clear = V09DemGapSte;
option clear = V09CostVarProdSte;
option clear = V09CostCapProdSte;
option clear = V09CostProdSte;
option clear = V09GapShareSte;
option clear = V09CaptRateSte;
option clear = V09ScrapRatePremature;
option clear = VmDemTotSte;
option clear = VmCapSte;
option clear = VmProdSte;
option clear = VmCostAvgProdSte;
option clear = VmConsFuelSteProd;

option clear = Q09ScrapRate;
option clear = Q09DemGapSte;
option clear = Q09CostVarProdSte;
option clear = Q09CostCapProdSte;
option clear = Q09CostProdSte;
option clear = Q09GapShareSte;
option clear = Q09CaptRateSte;
option clear = Q09ScrapRatePremature;
option clear = Q09DemTotSte;
option clear = Q09CapSte;
option clear = Q09ProdSte;
option clear = Q09CostAvgProdSte;
option clear = Q09ConsFuelSteProd;
*---
