*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
MVConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = MVConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
MVDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = MVDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
MVConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = MVConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
MVPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) = MVPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
MVConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = MVConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
MVConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = MVConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
*---