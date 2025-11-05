*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Variables
VmDemTotSte(allCy,YTIME)
V09ScrapRate(allCy,TSTEAM,YTIME)
VmProdSte(allCy,TSTEAM,YTIME)
V09DemGapSte(allCy,YTIME)
VmCostAvgProdSte(allCy,YTIME)
V09CostVarProdSte(allCy,TSTEAM,YTIME)
V09CostCapProdSte(allCy,TSTEAM,YTIME)
V09CostProdSte(allCy,TSTEAM,YTIME)
V09GapShareSte(allCy,TSTEAM,YTIME)
V09CaptRateSte(allCy,TSTEAM,YTIME)
V09ScrapRatePremature(allCy,TSTEAM,YTIME)
VmConsFuelSteProd(allCy,EF,YTIME)
;

Equations
Q09DemTotSte(allCy,YTIME)
Q09ScrapRate(allCy,TSTEAM,YTIME)
Q09ProdSte(allCy,TSTEAM,YTIME)
Q09DemGapSte(allCy,YTIME)
Q09CostAvgProdSte(allCy,YTIME)
Q09CostVarProdSte(allCy,TSTEAM,YTIME)
Q09CostCapProdSte(allCy,TSTEAM,YTIME)
Q09CostProdSte(allCy,TSTEAM,YTIME)
Q09GapShareSte(allCy,TSTEAM,YTIME)
Q09CaptRateSte(allCy,TSTEAM,YTIME)
Q09ScrapRatePremature(allCy,TSTEAM,YTIME)
Q09ConsFuelSteProd(allCy,EF,YTIME)
;