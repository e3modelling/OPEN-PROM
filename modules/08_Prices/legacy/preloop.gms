*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.LO(runCy,DSBS,EF,YTIME) = 0;
V08PriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
V08PriceFuelSepCarbonWght.FX(runCy,DSBS,EF,YTIME)$DATAY(YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
p08PriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)$DATAY(YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
*---
p08PriceFuelSubsecCarVal(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF) and DATAY(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME);
*---
p08PriceFuelAvgSub(runCy,DSBS,YTIME)$DATAY(YTIME) = VmPriceFuelAvgSub.L(runCy,DSBS,YTIME);
*---
p08PriceElecInd(runCy,TCHP,YTIME)$DATAY(YTIME) = VmPriceElecInd.L(runCy,TCHP,YTIME);
*---
$ontext
VmPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECtoEF(DSBS,EF)) =
(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
*---
$offtext
*---
