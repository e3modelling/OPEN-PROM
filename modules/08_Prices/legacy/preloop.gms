*' @title Prices Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V08PriceFuelSepCarbonWght.LO(runCy,DSBS,EF,YTIME) = 0;
V08PriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
V08PriceFuelSepCarbonWght.FX(runCy,DSBS,EF,YTIME)$DATAY(YTIME) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
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
* Init for the BMSWAS bio-supply index variable (positive; neutral start = 1)
V08IndexBioSupply.LO(runCy,YTIME) = 0;
V08IndexBioSupply.L(runCy,YTIME)  = 1;
*---
VmPriceCarbon.LO(runCy,SBS,EFS,YTIME) = 0;
VmPriceCarbon.FX(runCy,SBS,EFS,YTIME)$DATAY(YTIME) = 1e-3 * (
      iCarbValYrExog(runCy,YTIME)$(INDSE1(SBS) or ((DOMSE1(SBS) or TRANS1(SBS)) and ord(YTIME) > 17))
    ) * imCo2EmiFac(runCy,SBS,EFS,YTIME);