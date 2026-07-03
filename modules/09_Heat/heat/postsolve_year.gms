*' Clear variables and equations (outside country loop — preserves no bounds for next year)
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

*' Re-apply critical bounds for all active countries (outside country loop)
V09ScrapRatePremature.LO(runCyL,TSTEAM,YTIME) = 0;
V09ScrapRatePremature.UP(runCyL,TSTEAM,YTIME) = 1;
V09GapShareSte.LO(runCyL,TSTEAM,YTIME) = 0;
V09GapShareSte.UP(runCyL,TSTEAM,YTIME) = 1;
V09CaptRateSte.LO(runCyL,TSTEAM,YTIME) = 0;
V09CaptRateSte.UP(runCyL,TSTEAM,YTIME) = 1;
V09ScrapRate.LO(runCyL,TSTEAM,YTIME) = 0;
V09ScrapRate.UP(runCyL,TSTEAM,YTIME) = 1;
VmDemTotSte.LO(runCyL,YTIME) = 0;
VmCapSte.LO(runCyL,TSTEAM,YTIME) = 0;
VmProdSte.LO(runCyL,TSTEAM,YTIME) = 0;
V09CostCapProdSte.LO(runCyL,TSTEAM,YTIME) = 0;
V09CostVarProdSte.LO(runCyL,TSTEAM,YTIME) = 0;
V09CostProdSte.LO(runCyL,TSTEAM,YTIME) = 0;
VmCostAvgProdSte.LO(runCyL,YTIME) = 0;
VmConsFuelSteProd.LO(runCyL,STEMODE,EFS,YTIME) = 0;
V09DemGapSte.LO(runCyL,YTIME) = 0;

*' Re-apply data-year fixed values after option clear
VmDemTotSte.FX(runCyL,YTIME)$DATAY(YTIME) = (i03DataGrossInlCons(runCyL,"STE",YTIME) - imFuelTrade(runCyL,"IMPORTS","STE",YTIME) + imFuelTrade(runCyL,"EXPORTS","STE",YTIME));
VmCapSte.FX(runCyL,TSTEAM,YTIME)$DATAY(YTIME) =
(
  (
    (i03DataGrossInlCons(runCyL,"STE",YTIME) - imFuelTrade(runCyL,"IMPORTS","STE",YTIME) + imFuelTrade(runCyL,"EXPORTS","STE",YTIME)) /
    SUM(TSTEAM2,i04DataHeatProd(runCyL,TSTEAM2,YTIME))
  )$SUM(TSTEAM2,i04DataHeatProd(runCyL,TSTEAM2,YTIME))
) * i04DataHeatProd(runCyL,TSTEAM,YTIME);
VmProdSte.L(runCyL,TSTEAM,YTIME)$DATAY(YTIME) =
(
  (
    (i03DataGrossInlCons(runCyL,"STE",YTIME) - imFuelTrade(runCyL,"IMPORTS","STE",YTIME) + imFuelTrade(runCyL,"EXPORTS","STE",YTIME)) /
    SUM(TSTEAM2,i04DataHeatProd(runCyL,TSTEAM2,YTIME))
  )$SUM(TSTEAM2,i04DataHeatProd(runCyL,TSTEAM2,YTIME))
) * i04DataHeatProd(runCyL,TSTEAM,YTIME);
V09DemGapSte.FX(runCyL,YTIME)$DATAY(YTIME) = 0;

*' Initialize variable levels from previous period parameter
V09ScrapRate.L(runCyL,TSTEAM,YTIME+1) = p09ScrapRate(runCyL,TSTEAM,YTIME);
V09DemGapSte.L(runCyL,YTIME+1) = p09DemGapSte(runCyL,YTIME);
V09GapShareSte.L(runCyL,TSTEAM,YTIME+1) = p09GapShareSte(runCyL,TSTEAM,YTIME);
V09ScrapRatePremature.L(runCyL,TSTEAM,YTIME+1) = p09ScrapRatePremature(runCyL,TSTEAM,YTIME);
V09CaptRateSte.L(runCyL,TSTEAM,YTIME+1) = p09CaptRateSte(runCyL,TSTEAM,YTIME);
V09CostVarProdSte.L(runCyL,TSTEAM,YTIME+1) = p09CostVarProdSte(runCyL,TSTEAM,YTIME);
V09CostCapProdSte.L(runCyL,TSTEAM,YTIME+1) = p09CostCapProdSte(runCyL,TSTEAM,YTIME);
V09CostProdSte.L(runCyL,TSTEAM,YTIME+1) = p09CostProdSte(runCyL,TSTEAM,YTIME);
VmDemTotSte.L(runCyL,YTIME+1) = pmDemTotSte(runCyL,YTIME);
VmCapSte.L(runCyL,TSTEAM,YTIME+1) = pmCapSte(runCyL,TSTEAM,YTIME);
VmProdSte.L(runCyL,TSTEAM,YTIME+1) = pmProdSte(runCyL,TSTEAM,YTIME);
VmCapSte.L(runCyL,TSTEAM,YTIME+1)$(SUM(TSTEAM2, pmCapSte(runCyL,TSTEAM2,YTIME)) = 0) = i04DataHeatProd(runCyL,TSTEAM,"%fBaseY%") + 1;
VmProdSte.L(runCyL,TSTEAM,YTIME+1)$(SUM(TSTEAM2, pmCapSte(runCyL,TSTEAM2,YTIME)) = 0) = VmCapSte.L(runCyL,TSTEAM,YTIME+1);
VmCostAvgProdSte.L(runCyL,YTIME+1) = pmCostAvgProdSte(runCyL,YTIME);
VmConsFuelSteProd.L(runCyL,STEMODE,EFS,YTIME+1) = pmConsFuelSteProd(runCyL,STEMODE,EFS,YTIME);
