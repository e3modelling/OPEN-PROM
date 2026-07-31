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
* Init for the BMSWAS price factor (positive; neutral start = 1)
V08BmswasPriceFactor.LO(runCy,YTIME) = 0;
V08BmswasPriceFactor.L(runCy,YTIME)  = 1;
*---
$IFTHEN %landEmiMode% == curve
* Both emulator backends use the same native-MAgPIE AFOLU history on DATAY.
* TIME values are calculated by the selected backend in postsolve.
imAfoluLandEmis(runCy,EMTYPE,YTIME)$(DATAY(YTIME) $sameas(EMTYPE,"CO2LandUse")) =
  i08AfoluLandCO2Hist(runCy,EMTYPE,YTIME);
imAfoluAgriEmis(runCy,EMTYPE,YTIME)$(DATAY(YTIME) $(sameas(EMTYPE,"CH4LandUse") or sameas(EMTYPE,"N2OLandUse"))) =
  i08AfoluAgriEmisHist(runCy,EMTYPE,YTIME);
$ENDIF
*---
