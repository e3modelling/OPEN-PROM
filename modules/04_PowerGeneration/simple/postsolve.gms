*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
VmCostPowGenAvgLng.FX(runCyL,YTIME)$TIME(YTIME) = VmCostPowGenAvgLng.L(runCyL,YTIME)$TIME(YTIME);
VmCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = VmCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
V04CostPowGenLonNoClimPol.FX(runCyL,ESET,YTIME)$TIME(YTIME) = V04CostPowGenLonNoClimPol.L(runCyL,ESET,YTIME)$TIME(YTIME);
VmPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = VmPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
V04CapOverall.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapOverall.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04IndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04IndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VmCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VmCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NetNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = V04CapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
V04CapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = V04CapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);
V04CapElecNominal.FX(runCy,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCy,PGALL,YTIME)$TIME(YTIME);
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$TIME(YTIME) = V04CapexFixCostPG.L(runCy,PGALL,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
i04MatFacPlaAvailCap.FX(runCy,PGALL,YTIME)$TIME(YTIME) = i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME)$TIME(YTIME);
i04MatureFacPlaDisp.FX(runCy,PGALL,YTIME)$TIME(YTIME) = i04MatureFacPlaDisp.L(runCy,PGALL,"%fEndY%")$TIME(YTIME);
$endif.calib
