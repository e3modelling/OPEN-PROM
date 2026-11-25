*' @title Agriculture module Declarations
*' @code
parameter
i14ratioMaterialImports(allCy,MATERIALS,YTIME)
i14ratioMaterialExports(allCy,MATERIALS,YTIME)
;

Equations 
Q14Exp(allCy,MATERIALS,YTIME)
Q14Imp(allCy,MATERIALS,YTIME)
Q14NetTradeMaterials(allCy,MATERIALS,YTIME)
Q14InputMaterials(allCy,IND_SERVS,MATERIALS,YTIME)
Q14CostAvgCommodities(allCy,COMMODITIES,YTIME)
;

Variables
V14Exp(allCy,MATERIALS,YTIME)
V14Imp(allCy,MATERIALS,YTIME)
V14NetTradeMaterials(allCy,MATERIALS,YTIME)
V14DemandMaterials(allCy,IND_SERVS,MATERIALS,YTIME)
V14CostAvgCommodities(allCy,COMMODITIES,YTIME)
;
