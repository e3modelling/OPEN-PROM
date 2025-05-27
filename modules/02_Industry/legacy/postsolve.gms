*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
VMVConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMVConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMVDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VMVDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VMVConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VMVConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VMVPriceElecInd.FX(runCyL,YTIME)$TIME(YTIME) = VMVPriceElecInd.L(runCyL,YTIME)$TIME(YTIME);
VMVConsFue.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VMVConsFue.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VMVConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VMVConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
*---