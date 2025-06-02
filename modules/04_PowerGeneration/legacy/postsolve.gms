*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
MVCostPowGenAvgLng.FX(runCyL,ESET,YTIME)$TIME(YTIME) = MVCostPowGenAvgLng.L(runCyL,ESET,YTIME)$TIME(YTIME);
MVCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = MVCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
V04CostPowGenLonNoClimPol.FX(runCyL,ESET,YTIME)$TIME(YTIME) = V04CostPowGenLonNoClimPol.L(runCyL,ESET,YTIME)$TIME(YTIME);
MVPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = MVPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
V04CapOverall.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapOverall.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04IndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04IndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
MVCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = MVCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NetNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = V04CapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
V04CapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = V04CapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);
V04CapElecNominal.FX(runCy,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCy,PGALL,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
iMatFacPlaAvailCap.FX(runCy,PGALL,YTIME) = iMatFacPlaAvailCap.L(runCy,PGALL,"%fEndY%");
iMatureFacPlaDisp.FX(runCy,PGALL,YTIME) = iMatureFacPlaDisp.L(runCy,PGALL,"%fEndY%");
$endif.calib
