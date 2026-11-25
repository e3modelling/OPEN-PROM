*' @title Agriculture module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V14Exp.LO(allCy,MATERIALS,YTIME) = 0;
V14Exp.FX(allCy,MATERIALS,YTIME)$DATAY(YTIME) = 0;
*---
V14Imp.LO(allCy,MATERIALS,YTIME) = 0;
V14Imp.FX(allCy,MATERIALS,YTIME)$DATAY(YTIME) = 0;
*---
V14NetTradeMaterials.FX(allCy,MATERIALS,YTIME)$DATAY(YTIME) = 0;
*---
V14DemandMaterials.LO(runCy,IND_SERVS,MATERIALS,YTIME) = 0;
V14DemandMaterials.FX(runCy,IND_SERVS,MATERIALS,YTIME)$DATAY(YTIME) = i02InputMaterials(runCy,IND_SERVS,MATERIALS,YTIME);