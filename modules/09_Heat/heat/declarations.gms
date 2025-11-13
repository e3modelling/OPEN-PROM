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
V09CostVarProdSte(allCy,TSTEAM,YTIME)         "Variable cost of steam generation technologies (kUS$2015/toe)"
V09CostCapProdSte(allCy,TSTEAM,YTIME)         "Capex and O&M costs of steam generation technologies (kUS$2015/toe)"
V09CostProdSte(allCy,TSTEAM,YTIME)            "Cost of steam production (kUS$2015/toe)"
V09GapShareSte(allCy,TSTEAM,YTIME)
V09CaptRateSte(allCy,TSTEAM,YTIME)
V09ScrapRatePremature(allCy,TSTEAM,YTIME)
*'            **Interdependent Variables**
VmDemTotSte(allCy,YTIME)
VmProdSte(allCy,TSTEAM,YTIME)
VmCostAvgProdSte(allCy,YTIME)                 "Average cost of steam production (kUS$2015/toe)"
VmConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;