*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module

*---
p02DemSubUsefulSubsec(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemSubUsefulSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
display p02DemSubUsefulSubsec;
p02RemEquipCapTechSubsec(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02RemEquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
*p02DemUsefulSubsecRemTech(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemUsefulSubsecRemTech.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02GapUsefulDemSubsec(runCyL,DSBS,YTIME)$TIME(YTIME) = V02GapUsefulDemSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02CapCostTech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02CapCostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02VarCostTech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02VarCostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02CostTech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02CostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02ShareTechNewEquipUseful(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02ShareTechNewEquipUseful.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02EquipCapTechSubsec(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02EquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02UsefulElecNonSubIndTert(runCyL,DSBS,YTIME)$TIME(YTIME) = V02UsefulElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02FinalElecNonSubIndTert(runCyL,DSBS,YTIME)$TIME(YTIME) = V02FinalElecNonSubIndTert.L(runCyL,DSBS,YTIME)$TIME(YTIME);
pmConsFuel(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VmConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
p02IndxElecIndPrices(runCyL,TCHP,YTIME)$TIME(YTIME) = V02IndxElecIndPrices.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p02IndAvrEffFinalUseful(runCyL,DSBS,YTIME)$TIME(YTIME) = V02IndAvrEffFinalUseful.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02PremScrpIndu(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02PremScrpIndu.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02RatioRem(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02RatioRem.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
*---

$ifthen.calib %Calibration% == MatCalibration
imMatrFactor.FX(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = imMatrFactor.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
i02CalibUsefulEnergy.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = i02CalibUsefulEnergy.L(runCyL,DSBS,YTIME)$TIME(YTIME);
$endif.calib