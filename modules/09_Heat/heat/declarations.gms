*' @title Heat module Declarations
*' @code

Parameters
p09ScrapRate(allCy,TSTEAM,YTIME)                  "Stored heat scrapping rate"
p09DemGapSte(allCy,YTIME)                         "Stored steam demand gap"
p09CostVarProdSte(allCy,TSTEAM,YTIME)             "Stored variable cost of steam generation technologies"
p09CostCapProdSte(allCy,TSTEAM,YTIME)             "Stored capex and O&M costs of steam generation technologies"
p09CostProdSte(allCy,TSTEAM,YTIME)                "Stored cost of steam production"
p09GapShareSte(allCy,TSTEAM,YTIME)                "Stored steam gap share"
p09CaptRateSte(allCy,TSTEAM,YTIME)                "Stored steam capture rate"
p09ScrapRatePremature(allCy,TSTEAM,YTIME)         "Stored premature steam scrapping rate"
pmDemTotSte(allCy,YTIME)                          "Stored total steam demand"
pmCapSte(allCy,TSTEAM,YTIME)                      "Stored steam capacity"
pmProdSte(allCy,TSTEAM,YTIME)                     "Stored steam production"
pmCostAvgProdSte(allCy,YTIME)                     "Stored average cost of steam production"
pmConsFuelSteProd(allCy,STEMODE,EFS,YTIME)        "Stored fuel consumption for steam production"
;

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
Q09CapSte(allCy,TSTEAM,YTIME)
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
VmCapSte(allCy,TSTEAM,YTIME)
VmProdSte(allCy,TSTEAM,YTIME)
VmCostAvgProdSte(allCy,YTIME)                 "Average cost of steam production (kUS$2015/toe)"
VmConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;
