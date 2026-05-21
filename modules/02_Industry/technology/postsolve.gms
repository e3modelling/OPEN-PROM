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
option clear = Q02ConsFuelShare;
option clear = Q02ConsFuelSum;

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
option clear = VmConsFuelShare;
option clear = VmConsFuelSum;
*---

$ifthen.calib %Calibration% == MatCalibration
imMatrFactor.FX(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = imMatrFactor.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
i02CalibUsefulEnergy.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = i02CalibUsefulEnergy.L(runCyL,DSBS,YTIME)$TIME(YTIME);
$endif.calib
*---
*' Initialize parameters for every iteration forward (seed from first iteration results)
V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME) = p02DemSubUsefulSubsec(runCy,DSBS,YTIME-1);
display V02DemSubUsefulSubsec.L;
V02RemEquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME) = p02RemEquipCapTechSubsec(runCy,DSBS,ITECH,YTIME-1);
V02DemUsefulSubsecRemTech.L(runCy,DSBS,YTIME) = p02DemUsefulSubsecRemTech(runCy,DSBS,YTIME-1);
V02GapUsefulDemSubsec.L(runCy,DSBS,YTIME) = p02GapUsefulDemSubsec(runCy,DSBS,YTIME-1);
V02CapCostTech.L(runCy,DSBS,ITECH,YTIME) = p02CapCostTech(runCy,DSBS,ITECH,YTIME-1);
V02VarCostTech.L(runCy,DSBS,ITECH,YTIME) = p02VarCostTech(runCy,DSBS,ITECH,YTIME-1);
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = p02CostTech(runCy,DSBS,ITECH,YTIME-1);
V02ShareTechNewEquipUseful.L(runCy,DSBS,ITECH,YTIME) = p02ShareTechNewEquipUseful(runCy,DSBS,ITECH,YTIME-1);
V02EquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME) = p02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME-1);
V02UsefulElecNonSubIndTert.L(runCy,DSBS,YTIME) = p02UsefulElecNonSubIndTert(runCy,DSBS,YTIME-1);
V02FinalElecNonSubIndTert.L(runCy,DSBS,YTIME) = p02FinalElecNonSubIndTert(runCy,DSBS,YTIME-1);
V02IndxElecIndPrices.L(runCy,TCHP,YTIME) = p02IndxElecIndPrices(runCy,TCHP,YTIME-1);
V02IndAvrEffFinalUseful.L(runCy,DSBS,YTIME) = p02IndAvrEffFinalUseful(runCy,DSBS,YTIME-1);
V02PremScrpIndu.L(runCy,DSBS,ITECH,YTIME) = p02PremScrpIndu(runCy,DSBS,ITECH,YTIME-1);
V02RatioRem.L(runCy,DSBS,ITECH,YTIME) = p02RatioRem(runCy,DSBS,ITECH,YTIME-1);
VmConsFuel.L(runCy,DSBS,EF,YTIME) = pmConsFuel(runCy,DSBS,EF,YTIME-1);