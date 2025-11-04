*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Variables
VmDemTotSte(allCy,YTIME)
V09ScrapRate(allCy,TCHP,YTIME)
VmProdSte(allCy,TCHP,YTIME)
V09DemGapSte(allCy,YTIME)
VmCostAvgProdSte(allCy,YTIME)
V09CostVarProdSte(allCy,TCHP,YTIME)
V09CostCapProdSte(allCy,TCHP,YTIME)
V09CostProdSte(allCy,TCHP,YTIME)
V09GapShareSte(allCy,TCHP,YTIME)
V09CaptRateSte(allCy,TCHP,YTIME)
V09ScrapRatePremature(allCy,TCHP,YTIME)
;

Equations
Q09DemTotSte(allCy,YTIME)
Q09ScrapRate(allCy,TCHP,YTIME)
Q09ProdSte(allCy,TCHP,YTIME)
Q09DemGapSte(allCy,YTIME)
Q09CostAvgProdSte(allCy,YTIME)
Q09CostVarProdSte(allCy,TCHP,YTIME)
Q09CostCapProdSte(allCy,TCHP,YTIME)
Q09CostProdSte(allCy,TCHP,YTIME)
Q09GapShareSte(allCy,TCHP,YTIME)
Q09CaptRateSte(allCy,TCHP,YTIME)
Q09ScrapRatePremature(allCy,TCHP,YTIME)
;