*' @title Agriculture Inputs
*' @code

*' Parameters
i14ratioMaterialImports("DEU",MATERIALS,YTIME)$sameas("IRONORE",MATERIALS) = 0.1;
*---
i14ratioMaterialExports("CHA",MATERIALS,YTIME) = 1;
*---
i02SFC(runCy,"IS",IND_SERVS,INDITECH,EF,YTIME) = 
i02SFC(runCy,"IS",IND_SERVS,INDITECH,EF,YTIME) + 
SUM(MATERIALS,
  i02ratioMaterialCons(IND_SERVS,INDITECH,MATERIALS) * 
  i02EnergyPremium(MATERIALS,EF) * 
  i14ratioMaterialImports(runCy,MATERIALS,YTIME)
);