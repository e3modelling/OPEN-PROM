*' @title Power Generation postsolve
* Fix values of variables for the next time step

* Power Generation Module

*---
pmCostPowGenAvgLng(runCyL,YTIME)$TIME(YTIME) = VmCostPowGenAvgLng.L(runCyL,YTIME)$TIME(YTIME);
pmCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = VmCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04NewCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04NetNewCapElec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04NetNewCapElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CapElecNonCHP(runCyL,YTIME)$TIME(YTIME) = V04CapElecNonCHP.L(runCyL,YTIME)$TIME(YTIME);
p04CapElecNominal(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapElecNominal.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CapexFixCostPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexFixCostPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareMixWndSol(runCyL,YTIME)$TIME(YTIME) = V04ShareMixWndSol.L(runCyL,YTIME)$TIME(YTIME);
p04CapexRESRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CapexRESRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareSatPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareSatPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CostHourProdInvDec(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostHourProdInvDec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CostVarTech(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostVarTech.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CostCapTech(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CostCapTech.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04CO2CaptRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CO2CaptRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ShareTechPG(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ShareTechPG.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04IndxEndogScrap(runCyL,PGALL,YTIME)$TIME(YTIME) = V04IndxEndogScrap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04GapGenCapPowerDiff(runCyL,YTIME)$TIME(YTIME) = V04GapGenCapPowerDiff.L(runCyL,YTIME)$TIME(YTIME);
p04SharePowPlaNewEq(runCyL,PGALL,YTIME)$TIME(YTIME) = V04SharePowPlaNewEq.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04SortPlantDispatch(runCyL,PGALL,YTIME)$TIME(YTIME) = V04SortPlantDispatch.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04DemElecTot(runCyL,YTIME)$TIME(YTIME) = V04DemElecTot.L(runCyL,YTIME)$TIME(YTIME);
p04ProdElecEstCHP(runCyL,TCHP,YTIME)$TIME(YTIME) = V04ProdElecEstCHP.L(runCyL,TCHP,YTIME)$TIME(YTIME);
p04CCSRetroFit(runCyL,PGALL,YTIME)$TIME(YTIME) = V04CCSRetroFit.L(runCyL,PGALL,YTIME)$TIME(YTIME);
p04ScrpRate(runCyL,PGALL,YTIME)$TIME(YTIME) = V04ScrpRate.L(runCyL,PGALL,YTIME)$TIME(YTIME);
pmProdElec(runCyL,PGALL,YTIME)$TIME(YTIME) = VmProdElec.L(runCyL,PGALL,YTIME)$TIME(YTIME);
pmConsFuelElecProd(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFuelElecProd.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---

option clear = V04CapElecNominal;
option clear = V04ShareTechPG;
option clear = V04CostHourProdInvDec;
option clear = V04CostVarTech;
option clear = V04IndxEndogScrap;
option clear = V04CapElecNonCHP;
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
option clear = V04CostCapTech;
option clear = V04CCSRetroFit;
option clear = V04ScrpRate;
option clear = VmProdElec;
option clear = VmCostPowGenAvgLng;
option clear = VmCapElec;
option clear = VmConsFuelElecProd;

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
*---

$ifthen.calib %Calibration% == MatCalibration
i04MatFacPlaAvailCap.FX(runCyL,PGALL,YTIME)$TIME(YTIME) = i04MatFacPlaAvailCap.L(runCyL,PGALL,YTIME)$TIME(YTIME);
$endif.calib
*---
*' Initialize variable levels from previous period parameter
V04CapElecNominal.L(runCy,PGALL,YTIME) = p04CapElecNominal(runCy,PGALL,YTIME-1);
V04ShareTechPG.L(runCy,PGALL,YTIME) = p04ShareTechPG(runCy,PGALL,YTIME-1);
V04CostHourProdInvDec.L(runCy,PGALL,YTIME) = p04CostHourProdInvDec(runCy,PGALL,YTIME-1);
V04CostVarTech.L(runCy,PGALL,YTIME) = p04CostVarTech(runCy,PGALL,YTIME-1);
V04IndxEndogScrap.L(runCy,PGALL,YTIME) = p04IndxEndogScrap(runCy,PGALL,YTIME-1);
V04CapElecNonCHP.L(runCy,YTIME) = p04CapElecNonCHP(runCy,YTIME-1);
V04GapGenCapPowerDiff.L(runCy,YTIME) = p04GapGenCapPowerDiff(runCy,YTIME-1);
V04ShareSatPG.L(runCy,PGALL,YTIME) = p04ShareSatPG(runCy,PGALL,YTIME-1);
V04SharePowPlaNewEq.L(runCy,PGALL,YTIME) = p04SharePowPlaNewEq(runCy,PGALL,YTIME-1);
V04SortPlantDispatch.L(runCy,PGALL,YTIME) = p04SortPlantDispatch(runCy,PGALL,YTIME-1);
V04NewCapElec.L(runCy,PGALL,YTIME) = p04NewCapElec(runCy,PGALL,YTIME-1);
V04NetNewCapElec.L(runCy,PGALL,YTIME) = p04NetNewCapElec(runCy,PGALL,YTIME-1);
V04DemElecTot.L(runCy,YTIME) = p04DemElecTot(runCy,YTIME-1);
V04ProdElecEstCHP.L(runCy,TCHP,YTIME) = p04ProdElecEstCHP(runCy,TCHP,YTIME-1);
V04CapexFixCostPG.L(runCy,PGALL,YTIME) = p04CapexFixCostPG(runCy,PGALL,YTIME-1);
V04ShareMixWndSol.L(runCy,YTIME) = p04ShareMixWndSol(runCy,YTIME-1);
V04CapexRESRate.L(runCy,PGALL,YTIME) = p04CapexRESRate(runCy,PGALL,YTIME-1);
V04CO2CaptRate.L(runCy,PGALL,YTIME) = p04CO2CaptRate(runCy,PGALL,YTIME-1);
V04CostCapTech.L(runCy,PGALL,YTIME) = p04CostCapTech(runCy,PGALL,YTIME-1);
V04CCSRetroFit.L(runCy,PGALL,YTIME) = p04CCSRetroFit(runCy,PGALL,YTIME-1);
V04ScrpRate.L(runCy,PGALL,YTIME) = p04ScrpRate(runCy,PGALL,YTIME-1);
VmProdElec.L(runCy,PGALL,YTIME) = pmProdElec(runCy,PGALL,YTIME-1);
VmCostPowGenAvgLng.L(runCy,YTIME) = pmCostPowGenAvgLng(runCy,YTIME-1);
VmCapElec.L(runCy,PGALL,YTIME) = pmCapElec(runCy,PGALL,YTIME-1);
VmConsFuelElecProd.L(runCy,EFS,YTIME) = pmConsFuelElecProd(runCy,EFS,YTIME-1);