*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Store values of variables as parameters for the next time step

* Industry Module Module

*---
p02DemSubUsefulSubsec(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemSubUsefulSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02GapUsefulDemSubsec(runCyL,DSBS,YTIME)$TIME(YTIME) = V02GapUsefulDemSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p02EquipCapTechSubsec(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02EquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02VarCostTech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02VarCostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02CostTech(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02CostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02ShareTechNewEquipUseful(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02ShareTechNewEquipUseful.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
p02UsefulElecNonSubIndTert(runCyL,INDDOM,YTIME)$TIME(YTIME) = V02UsefulElecNonSubIndTert.L(runCyL,INDDOM,YTIME)$TIME(YTIME);

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

V02GapUsefulDemSubsec.L(allCy,DSBS,YTIME)$TIME(YTIME) = p02GapUsefulDemSubsec(allCy,DSBS,YTIME)$TIME(YTIME);
V02ShareTechNewEquipUseful.L(allCy,DSBS,ITECH,YTIME)$TIME(YTIME) = p02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
imMatrFactor.FX(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = round(imMatrFactor.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME), 3);
$endif.calib