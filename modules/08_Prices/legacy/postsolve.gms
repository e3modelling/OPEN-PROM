*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
VMPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VMPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VMPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) =  VMPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
*---