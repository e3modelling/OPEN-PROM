*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V06CapCO2ElecHydr.FX(runCy,CO2CAPTECH,YTIME)$(not An(YTIME)) = 0;
*---
V06CaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
*---
V06LvlCostDAC.LO(runCy,DACTECH,YTIME) = epsilon6;
V06LvlCostDAC.L(runCy,DACTECH,YTIME) = 100;
V06LvlCostDAC.FX(runCy,DACTECH,YTIME)$DATAY(YTIME) = 100;
*---
V06CapDAC.FX(runCy,DACTECH,YTIME)$(not an(YTIME)) = 1;
*---
V06ProfRateDAC.LO(runCy,DACTECH,YTIME) = 0;