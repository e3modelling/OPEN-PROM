*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
VmPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VmPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VmPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) =  VmPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
*---