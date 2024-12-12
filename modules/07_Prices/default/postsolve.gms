*' @title Prices postsolve
* Fix values of variables for the next time step

* Prices Module
VPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VPriceFuelAvgSub.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VPriceFuelSubsecCarVal.FX(runCyL,SBS,EF,YTIME)$TIME(YTIME) = VPriceFuelSubsecCarVal.L(runCyL,SBS,EF,YTIME)$TIME(YTIME);

* Export model results to GDX file
*execute_unload "outputData.gdx", ODummyObj, VPriceElecInd, VCapElecTotEst, VPeakLoad, VConsFuel, VCapElec, VProdElec, VBaseLoad;