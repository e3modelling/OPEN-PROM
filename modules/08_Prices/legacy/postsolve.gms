*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module

*---
MVPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = MVPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
MVPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = MVPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);
MVPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) =  MVPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
*---