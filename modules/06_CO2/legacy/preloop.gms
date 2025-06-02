*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VMCstCO2SeqCsts.L(runCy,YTIME)=1;
VMCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = iElastCO2Seq(runCy,"mc_b");
*---
V06CapCO2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;
*---
V06CaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
*---
*V06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*Q06TrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*---