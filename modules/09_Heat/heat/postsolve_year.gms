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

*' Re-apply preloop bounds for all active countries (outside country loop)
*' This re-sets VmCapSte.LO = epsilon6 for all runCy — the key fix for infeasibility
$include "./modules/09_Heat/heat/preloop.gms"

*' Initialize variable levels from previous period parameter
V09ScrapRate.L(runCy,TSTEAM,YTIME+1) = p09ScrapRate(runCy,TSTEAM,YTIME-1);
V09DemGapSte.L(runCy,YTIME+1) = p09DemGapSte(runCy,YTIME-1);
V09GapShareSte.L(runCy,TSTEAM,YTIME+1) = p09GapShareSte(runCy,TSTEAM,YTIME-1);
V09ScrapRatePremature.L(runCy,TSTEAM,YTIME+1) = p09ScrapRatePremature(runCy,TSTEAM,YTIME-1);
V09CaptRateSte.L(runCy,TSTEAM,YTIME+1) = p09CaptRateSte(runCy,TSTEAM,YTIME-1);
V09CostVarProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostVarProdSte(runCy,TSTEAM,YTIME-1);
V09CostCapProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostCapProdSte(runCy,TSTEAM,YTIME-1);
V09CostProdSte.L(runCy,TSTEAM,YTIME+1) = p09CostProdSte(runCy,TSTEAM,YTIME-1);
VmDemTotSte.L(runCy,YTIME+1) = pmDemTotSte(runCy,YTIME-1);
VmCapSte.L(runCy,TSTEAM,YTIME+1) = pmCapSte(runCy,TSTEAM,YTIME-1);
VmProdSte.L(runCy,TSTEAM,YTIME+1) = pmProdSte(runCy,TSTEAM,YTIME-1);
VmCostAvgProdSte.L(runCy,YTIME+1) = pmCostAvgProdSte(runCy,YTIME-1);
VmConsFuelSteProd.L(runCy,STEMODE,EFS,YTIME+1) = pmConsFuelSteProd(runCy,STEMODE,EFS,YTIME-1);
