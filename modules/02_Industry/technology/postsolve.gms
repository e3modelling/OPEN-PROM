*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module

*---
p02DemSubUsefulSubsec(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemSubUsefulSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
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

option clear = V02DemSubUsefulSubsec;
option clear = V02RemEquipCapTechSubsec;
option clear = V02DemUsefulSubsecRemTech;
option clear = V02GapUsefulDemSubsec;
option clear = V02CapCostTech;
option clear = V02VarCostTech;
option clear = V02CostTech;
option clear = V02ShareTechNewEquipUseful;
option clear = V02EquipCapTechSubsec;
option clear = V02UsefulElecNonSubIndTert;
option clear = V02FinalElecNonSubIndTert;
option clear = V02IndxElecIndPrices;
option clear = V02IndAvrEffFinalUseful;
option clear = V02PremScrpIndu;
option clear = V02RatioRem;
option clear = VmConsFuel;

option clear = Q02DemSubUsefulSubsec;
option clear = Q02RemEquipCapTechSubsec;
option clear = Q02DemUsefulSubsecRemTech;
option clear = Q02GapUsefulDemSubsec;
option clear = Q02CapCostTech;
option clear = Q02VarCostTech;
option clear = Q02CostTech;
option clear = Q02ShareTechNewEquipUseful;
option clear = Q02EquipCapTechSubsec;
option clear = Q02UsefulElecNonSubIndTert;
option clear = Q02FinalElecNonSubIndTert;
option clear = Q02IndxElecIndPrices;
option clear = Q02IndAvrEffFinalUseful;
option clear = Q02PremScrpIndu;
option clear = Q02RatioRem;
option clear = Q02ConsFuel;
*---

$ifthen.calib %Calibration% == MatCalibration
imMatrFactor.FX(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = imMatrFactor.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
i02CalibUsefulEnergy.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = i02CalibUsefulEnergy.L(runCyL,DSBS,YTIME)$TIME(YTIME);
$endif.calib
