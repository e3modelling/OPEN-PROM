*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VMVCstCO2SeqCsts.L(runCy,YTIME)=1;
VMVCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = iElastCO2Seq(runCy,"mc_b");
*---
VCapCO2ElecHydr.FX(runCy,YTIME)$(not An(YTIME)) = 0;
*---
VCaptCummCO2.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;
*---
*VTrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*QTrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*---