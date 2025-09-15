*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VmCstCO2SeqCsts.L(runCy,YTIME)=1;
VmCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = i06ElastCO2Seq(runCy,"mc_b");
*---
V06CapCO2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;
*---
V06CaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
*---
*V06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*Q06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*---
V06CapexFixCostDAC.FX(runCy,DACTECH,YTIME)$(not an(YTIME)) = 100;
V06CapDAC.FX(runCy,DACTECH,YTIME)$(not an(YTIME)) = 1;