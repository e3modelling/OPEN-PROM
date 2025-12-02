*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
VmCostPowGenAvgLng.FX(runCyL,YTIME)$TIME(YTIME) = VmCostPowGenAvgLng.L(runCyL,YTIME)$TIME(YTIME);
VmCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = VmCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
VmPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = VmPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
V04IndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04IndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VmCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VmCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NetNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = V04CapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
V04CapElecNominal.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapexFixCostPG.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexFixCostPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04ShareMixWndSol.FX(runCyL,YTIME)$TIME(YTIME) = V04ShareMixWndSol.L(runCyL,YTIME)$TIME(YTIME);
V04CapexRESRate.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexRESRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04ShareTechPG.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareTechPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04ShareSatPG.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareSatPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CostHourProdInvDec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostHourProdInvDec.L(runCyL,PGALL,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
i04MatFacPlaAvailCap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = i04MatFacPlaAvailCap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
i04MatureFacPlaDisp.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = i04MatureFacPlaDisp.L(runCyL,PGALL,"%fEndY%")$TIME(YTIME);
$endif.calib
