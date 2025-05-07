*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
VConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) = VPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
VConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
*---