*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
VMConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VMConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VMPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) = VMPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
VMConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VMConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VMConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VMConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
*---