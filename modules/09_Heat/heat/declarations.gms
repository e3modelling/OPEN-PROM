*' @title Heat module Declarations
*' @code

Equations
Q09ScrapRate(allCy,TSTEAM,YTIME)
Q09DemGapSte(allCy,YTIME)
Q09CostVarProdSte(allCy,TSTEAM,YTIME)
Q09CostCapProdSte(allCy,TSTEAM,YTIME)
Q09CostProdSte(allCy,TSTEAM,YTIME)
Q09GapShareSte(allCy,TSTEAM,YTIME)
Q09CaptRateSte(allCy,TSTEAM,YTIME)
Q09ScrapRatePremature(allCy,TSTEAM,YTIME)
*'                **Interdependent Equations**
Q09DemTotSte(allCy,YTIME)
Q09ProdSte(allCy,TSTEAM,YTIME)
Q09CostAvgProdSte(allCy,YTIME)
Q09ConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;

Variables
V09ScrapRate(allCy,TSTEAM,YTIME)
V09DemGapSte(allCy,YTIME)
V09CostVarProdSte(allCy,TSTEAM,YTIME)
V09CostCapProdSte(allCy,TSTEAM,YTIME)
V09CostProdSte(allCy,TSTEAM,YTIME)
V09GapShareSte(allCy,TSTEAM,YTIME)
V09CaptRateSte(allCy,TSTEAM,YTIME)
V09ScrapRatePremature(allCy,TSTEAM,YTIME)
*'            **Interdependent Variables**
VmDemTotSte(allCy,YTIME)
VmProdSte(allCy,TSTEAM,YTIME)
VmCostAvgProdSte(allCy,YTIME)
VmConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;