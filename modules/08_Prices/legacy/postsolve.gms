*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
VMVPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMVPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMVPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VMVPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
VMVPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) =  VMVPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
*---