*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
pmPriceFuelAvgSub(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
pmPriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
pmPriceElecInd(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
*---

option clear = V08PriceFuelSepCarbonWght;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceFuelAvgSub;
option clear = VmPriceElecInd;

option clear = Q08PriceFuelSepCarbonWght;
option clear = Q08PriceFuelSubsecCarVal;
option clear = Q08PriceFuelAvgSub;
option clear = Q08PriceElecInd;
*---

VmPriceFuelSubsecCarVal.FX(runCy,SBS,"NUC",YTIME)$(An(YTIME) and SECtoEF(SBS,"NUC")) = 0.2;
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"SOL",YTIME)$(An(YTIME)) = 0;
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"GEO",YTIME)$(An(YTIME)) = 0;
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"CRO",YTIME)$(An(YTIME)) = imFuelPrice(runCy,SBS,"CRO",YTIME);
$IFTHEN %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
$ENDIF
