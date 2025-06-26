*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module

*---
VmConsElecNonSubIndTert.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmConsElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmDemFinSubFuelSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = VmDemFinSubFuelSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
VmConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VmConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VmConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VmConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
VmConsFuelInclHP.FX(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF)) = VmConsFuelInclHP.L(runCyL,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF));
*---