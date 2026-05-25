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
V09ScrapRatePremature.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRatePremature.UP(runCy,TSTEAM,YTIME) = 1;
V09GapShareSte.LO(runCy,TSTEAM,YTIME) = 0;
V09GapShareSte.UP(runCy,TSTEAM,YTIME) = 1;
V09CaptRateSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CaptRateSte.UP(runCy,TSTEAM,YTIME) = 1;
V09ScrapRate.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRate.UP(runCy,TSTEAM,YTIME) = 1;
VmDemTotSte.LO(runCy,YTIME) = 0;
VmCapSte.LO(runCy,TSTEAM,YTIME) = 0;
VmProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostCapProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostVarProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostProdSte.LO(runCy,TSTEAM,YTIME) = 0;
VmCostAvgProdSte.LO(runCy,YTIME) = 0;
VmConsFuelSteProd.LO(runCy,STEMODE,EFS,YTIME) = 0;
V09DemGapSte.LO(runCy,YTIME) = 0;

*' Initialize variable levels from previous period parameter
V09ScrapRate.L(runCy,TSTEAM,YTIME+1) = p09ScrapRate(runCy,TSTEAM,YTIME);
V09DemGapSte.L(runCy,YTIME+1) = p09DemGapSte(runCy,YTIME);
V09GapShareSte.L(runCy,TSTEAM,YTIME+1) = p09GapShareSte(runCy,TSTEAM,YTIME);
V09ScrapRatePremature.L(runCy,TSTEAM,YTIME+1) = p09ScrapRatePremature(runCy,TSTEAM,YTIME);
V09CaptRateSte.L(runCy,TSTEAM,YTIME+1) = p09CaptRateSte(runCy,TSTEAM,YTIME);
V09CostVarProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostVarProdSte(runCy,TSTEAM,YTIME);
V09CostCapProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostCapProdSte(runCy,TSTEAM,YTIME);
V09CostProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostProdSte(runCy,TSTEAM,YTIME);
VmDemTotSte.L(runCy,YTIME+1) = pmDemTotSte(runCy,YTIME);
VmCapSte.L(runCy,TSTEAM,YTIME+1) = pmCapSte(runCy,TSTEAM,YTIME);
VmProdSte.L(runCy,TSTEAM,YTIME+1) = pmProdSte(runCy,TSTEAM,YTIME);
VmCostAvgProdSte.L(runCy,YTIME+1) = pmCostAvgProdSte(runCy,YTIME);
VmConsFuelSteProd.L(runCy,STEMODE,EFS,YTIME+1) = pmConsFuelSteProd(runCy,STEMODE,EFS,YTIME);
