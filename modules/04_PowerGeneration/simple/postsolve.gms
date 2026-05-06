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
p04CapElecNominal(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareTechPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareTechPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04IndxEndogScrap(runCyL,PGALL,YTIME)$TIME(YTIME) = V04IndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04GapGenCapPowerDiff(runCyL,YTIME)$TIME(YTIME) = V04GapGenCapPowerDiff.L(runCyL,YTIME)$TIME(YTIME);
p04SharePowPlaNewEq(runCyL,PGALL,YTIME)$TIME(YTIME) = V04SharePowPlaNewEq.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04SortPlantDispatch(runCyL,PGALL,YTIME)$TIME(YTIME) = V04SortPlantDispatch.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04NewCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04NetNewCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04DemElecTot(runCyL,YTIME)$TIME(YTIME) = V04DemElecTot.L(runCyL,YTIME)$TIME(YTIME);
p04ProdElecEstCHP(runCyL,TCHP,YTIME)$TIME(YTIME) = V04ProdElecEstCHP.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p04CapexFixCostPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexFixCostPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CapexRESRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexRESRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CO2CaptRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CO2CaptRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CCSRetroFit(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CCSRetroFit.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ScrpRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ScrpRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ProdElec(runCyL,PGALL,YTIME)$TIME(YTIME) = VmProdElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ConsFuelElecProd(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFuelElecProd.L(runCyL,EFS,YTIME)$TIME(YTIME);

option clear = VmCapElec;
option clear = VmCostPowGenAvgLng;
option clear = VmProdElec;
option clear = VmConsFuelElecProd;
option clear = V04CapElecNominal;
option clear = V04ShareTechPG;
option clear = V04CapElecNonCHP;
option clear = V04IndxEndogScrap;
option clear = V04GapGenCapPowerDiff;
option clear = V04ShareSatPG;
option clear = V04SharePowPlaNewEq;
option clear = V04SortPlantDispatch;
option clear = V04NewCapElec;
option clear = V04NetNewCapElec;
option clear = V04DemElecTot;
option clear = V04ProdElecEstCHP;
option clear = V04CapexFixCostPG;
option clear = V04ShareMixWndSol;
option clear = V04CapexRESRate;
option clear = V04CO2CaptRate;
option clear = V04CostHourProdInvDec;
option clear = V04CostVarTech;
option clear = V04CostCapTech;
option clear = V04CCSRetroFit;
option clear = V04ScrpRate;

option clear = Q04CapElecNominal;
option clear = Q04ShareTechPG;
option clear = Q04CostHourProdInvDec;
option clear = Q04CostVarTech;
option clear = Q04IndxEndogScrap;
option clear = Q04CapElecNonCHP;
option clear = Q04GapGenCapPowerDiff;
option clear = Q04ShareSatPG;
option clear = Q04SharePowPlaNewEq;
option clear = Q04NewCapElec;
option clear = Q04NetNewCapElec;
option clear = Q04DemElecTot;
option clear = Q04ProdElecEstCHP;
option clear = Q04CapexFixCostPG;
option clear = Q04ShareMixWndSol;
option clear = Q04CapexRESRate;
option clear = Q04CO2CaptRate;
option clear = Q04CostCapTech;
option clear = Q04CCSRetroFit;
option clear = Q04ScrpRate;
option clear = Q04ProdElec;
option clear = Q04CostPowGenAvgLng;
option clear = Q04CapElec;
option clear = Q04ConsFuelElecProd;

$ifthen.calib %Calibration% == MatCalibration
i04MatFacPlaAvailCap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = i04MatFacPlaAvailCap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
$endif.calib
