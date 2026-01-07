*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
!!VmCstCO2SeqCsts.L(runCy,YTIME)=1;
!!VmCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = i06ElastCO2Seq(runCy,"mc_b");
*---
V06CapCO2ElecHydr.FX(runCy,CO2CAPTECH,YTIME)$(not An(YTIME)) = 0;
*---
V06CaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
*---
*V06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*Q06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*---
V06LvlCostDAC.L(allCy,DACTECH,YTIME) = 100;
V06LvlCostDAC.FX(runCyL,DACTECH,YTIME)$(not an(YTIME)) = 100;
V06LvlCostDAC.LO(runCyL,DACTECH,YTIME) = 70;
V06CapDAC.FX(runCyL,DACTECH,YTIME)$(not an(YTIME)) = 1;
V06CapFacNewDAC.FX(runCyL,DACTECH,YTIME)$(not an(YTIME)) = S06CapFacMinNewDAC;
V06CapFacNewDAC.L(runCyL,DACTECH,YTIME) = S06CapFacMinNewDAC;