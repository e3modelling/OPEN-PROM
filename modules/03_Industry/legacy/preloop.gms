*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostTechIntrm.l(runCy,DSBS,rcon,EF,YTIME) = 0.1;
*---
VSortTechVarCost.l(runCy,DSBS,rCon,YTIME) = 0.00000001;
*---
VShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
*---