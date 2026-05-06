*' @title Prices postsolve
* Store values of variables as parameters for the next time step

* Prices Module

*---
p08PriceFuelAvgSub(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p08PriceFuelSubsecCarVal(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
p08PriceElecInd(runCyL,TCHP,YTIME)$TIME(YTIME) = VmPriceElecInd.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p08PriceFuelSepCarbonWght(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = V08PriceFuelSepCarbonWght.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);

option clear = Q08PriceFuelSepCarbonWght;
option clear = Q08PriceFuelSubsecCarVal;
option clear = Q08PriceFuelAvgSub;
option clear = Q08PriceElecInd;

option clear = VmPriceFuelAvgSub;
option clear = VmPriceFuelSubsecCarVal;
option clear = VmPriceElecInd;
option clear = V08PriceFuelSepCarbonWght;
*---