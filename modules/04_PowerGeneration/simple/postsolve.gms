*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
p04CostPowGenAvgLng(runCyL,YTIME)$TIME(YTIME) = VmCostPowGenAvgLng.L(runCyL,YTIME)$TIME(YTIME);
p04CostVarTech(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostVarTech.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CostHourProdInvDec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostHourProdInvDec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CapElecNonCHP(runCyL,YTIME)$TIME(YTIME) = V04CapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
pmCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = VmCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareSatPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareSatPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareMixWndSol(runCyL,YTIME)$TIME(YTIME) = V04ShareMixWndSol.L(runCyL,YTIME)$TIME(YTIME);
p04CostCapTech(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostCapTech.L(runCyL,PGALL,YTIME)$TIME(YTIME);

V04NewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04NetNewCapElec.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapElecNominal.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapexFixCostPG.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexFixCostPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CapexRESRate.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexRESRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
V04CO2CaptRate.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CO2CaptRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);

option clear = VmCapElec;
option clear = VmCostPowGenAvgLng;
option clear = V04CapElecNonCHP;
option clear = V04ShareSatPG;
option clear = V04ShareMixWndSol;
option clear = V04CostHourProdInvDec;
option clear = V04CostVarTech;
option clear = V04CostCapTech;

VmCostPowGenAvgLng.L(allCy,YTIME)$TIME(YTIME) = p04CostPowGenAvgLng(allCy,YTIME)$TIME(YTIME);
VmCapElec.L(allCy,PGALL,YTIME)$TIME(YTIME) = 1e-6;
VmCapElec.L(allCy,PGALL,YTIME)$(TIME(YTIME) and pmCapElec(allCy,PGALL,YTIME) gt 1e-6) = pmCapElec(allCy,PGALL,YTIME);
V04CapElecNonCHP.L(allCy,YTIME)$TIME(YTIME) = p04CapElecNonCHP(allCy,YTIME);
V04ShareSatPG.L(allCy,PGALL,YTIME)$TIME(YTIME) = 1e-6;
V04ShareSatPG.L(allCy,PGALL,YTIME)$(TIME(YTIME) and p04ShareSatPG(allCy,PGALL,YTIME) gt 1e-6) = p04ShareSatPG(allCy,PGALL,YTIME);
V04ShareMixWndSol.L(allCy,YTIME)$TIME(YTIME) = p04ShareMixWndSol(allCy,YTIME);
V04CostHourProdInvDec.L(allCy,PGALL,YTIME)$TIME(YTIME) = 1e-3;
V04CostHourProdInvDec.L(allCy,PGALL,YTIME)$(TIME(YTIME) and p04CostHourProdInvDec(allCy,PGALL,YTIME) gt 1e-3) = p04CostHourProdInvDec(allCy,PGALL,YTIME);
V04CostVarTech.L(allCy,PGALL,YTIME)$TIME(YTIME) = 1e-3;
V04CostVarTech.L(allCy,PGALL,YTIME)$(TIME(YTIME) and p04CostVarTech(allCy,PGALL,YTIME) gt 1e-3) = p04CostVarTech(allCy,PGALL,YTIME);
V04CostCapTech.L(allCy,PGALL,YTIME)$TIME(YTIME) = 1e-6;
V04CostCapTech.L(allCy,PGALL,YTIME)$(TIME(YTIME) and p04CostCapTech(allCy,PGALL,YTIME) gt 1e-6) = p04CostCapTech(allCy,PGALL,YTIME);

$ifthen.calib %Calibration% == MatCalibration
i04MatFacPlaAvailCap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = i04MatFacPlaAvailCap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
$endif.calib
