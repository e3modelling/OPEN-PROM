*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
p08PriceFuelAvgSub(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p08PriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
p08PriceElecInd(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);

VmPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VmPriceElecInd.FX(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
V08PriceFuelSepCarbonWght.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);

option clear = VmPriceFuelAvgSub;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceElecInd;
option clear = V08PriceFuelSepCarbonWght;

VmPriceFuelAvgSub.L(allCy,DSBS,YTIME)$TIME(YTIME) = 1e-6;
VmPriceFuelAvgSub.L(allCy,DSBS,YTIME)$(TIME(YTIME) and p08PriceFuelAvgSub(allCy,DSBS,YTIME) gt 1e-6) = p08PriceFuelAvgSub(allCy,DSBS,YTIME);
VmPriceFuelSubsecCarVal.L(allCy,SBS,EF,YTIME)$TIME(YTIME) = 1e-6;
VmPriceFuelSubsecCarVal.L(allCy,SBS,EF,YTIME)$(TIME(YTIME) and p08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME) gt 1e-6) = p08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME);
VmPriceElecInd.L(allCy,TCHP,YTIME)$TIME(YTIME) = 1e-6;
VmPriceElecInd.L(allCy,TCHP,YTIME)$(TIME(YTIME) and p08PriceElecInd(allCy,TCHP,YTIME) gt 1e-6) = p08PriceElecInd(allCy,TCHP,YTIME);
V08PriceFuelSepCarbonWght.L(allCy,DSBS,EF,YTIME)$TIME(YTIME) = 1e-6;
V08PriceFuelSepCarbonWght.L(allCy,DSBS,EF,YTIME)$(TIME(YTIME) and p08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME) gt 1e-6) = p08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME);
*---