*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module
VCostPowGenAvgLng.FX(runCyL,ESET,YTIME)$TIME(YTIME) = VCostPowGenAvgLng.L(runCyL,ESET,YTIME)$TIME(YTIME);
VCapElecTotEst.FX(runCyL,YTIME)$TIME(YTIME) = VCapElecTotEst.L(runCyL,YTIME)$TIME(YTIME);
VCostPowGenLonNoClimPol.FX(runCyL,ESET,YTIME)$TIME(YTIME) = VCostPowGenLonNoClimPol.L(runCyL,ESET,YTIME)$TIME(YTIME);
VPeakLoad.FX(runCyL,YTIME)$TIME(YTIME) = VPeakLoad.L(runCyL,YTIME)$TIME(YTIME);
VCapOverall.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCapOverall.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VIndxEndogScrap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VIndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
* VCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCFAvgRen.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = VCFAvgRen.L(runCyL,PGALL,YTIME)$TIME(YTIME);
VCapElecNonCHP.FX(runCyL,YTIME)$TIME(YTIME) = VCapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
VCapElec2.FX(runCy,PGALL,YTIME)$TIME(YTIME) = VCapElec2.L(runCy,PGALL,YTIME)$TIME(YTIME);

$ifthen.calib %Calibration% == MatCalibration
iMatFacPlaAvailCap.FX(runCy,PGALL,YTIME) = iMatFacPlaAvailCap.L(runCy,PGALL,"2021");
iMatureFacPlaDisp.FX(runCy,PGALL,YTIME) = iMatureFacPlaDisp.L(runCy,PGALL,"2021");
$endif.calib