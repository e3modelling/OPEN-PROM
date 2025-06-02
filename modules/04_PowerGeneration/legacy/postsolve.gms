*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
MVCostPowGenAvgLng.FX(runCyL,ESET,YTIME)$TIME(YTIME) = MVCostPowGenAvgLng.L(runCyL,ESET,YTIME)$TIME(YTIME);
MVCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = MVCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
VCostPowGenLonNoClimPol.FX(runCyL,ESET,YTIME)$TIME(YTIME) = VCostPowGenLonNoClimPol.L(runCyL,ESET,YTIME)$TIME(YTIME);
MVPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = MVPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
VCapOverall.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCapOverall.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VIndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VIndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
MVCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = MVCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VNetNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VNetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = VCapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
VCapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);
VCapElecNominal.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElecNominal.L(runCy,PGALL,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
iMatFacPlaAvailCap.FX(runCy,PGALL,YTIME) = iMatFacPlaAvailCap.L(runCy,PGALL,"%fEndY%");
iMatureFacPlaDisp.FX(runCy,PGALL,YTIME) = iMatureFacPlaDisp.L(runCy,PGALL,"%fEndY%");
$endif.calib
