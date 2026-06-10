*' @title PowerGeneration Inputs
*' @code

*---
table i04AvailRate(allCy,PGALL,YTIME)	                   "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
i04AvailRate(allCy,"PGH2F",YTIME) = 0.9;
*---
table i04DataElecProdNonCHP(allCy,PGALL,YTIME)           "Electricity Non-CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdNonCHP.csv"
$offdelim
;
*---
table i04DataElecProdCHP(allCy,TCHP,YTIME)           "Electricity CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdCHP.csv"
$offdelim
;
*---
table i04FIT(allCy,PGALL,YTIME)	                   "Feed-in-Tariff (US$2015/KWh)"
$ondelim
$include"./iFIT.csv"
$offdelim
;
*---
table t04SharePowPlaNewEq(allCy,PGALL,YTIME)    "Ratio of newly added capacity smoothed over 10-year period ()"
$ondelim
$include "../targets/tShares_ProdElec.csv"
$offdelim
;
t04SharePowPlaNewEq(allCy,PGALL,YTIME) = round(t04SharePowPlaNewEq(allCy,PGALL,YTIME), 3);
*---
table i04DataTechLftPlaType(PGALL, PGECONCHAR)     "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
*---
table i04GrossCapCosSubRen(allCy,PGALL,YTIME)      "Gross Capital Cost per Plant Type with subsidy for renewables (kUS$2015/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
*---
table i04FixOandMCost(allCy,PGALL,YTIME)           "Fixed O&M Gross Cost per Plant Type (US$2015/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;
*---
table i04VarCost(PGALL,YTIME)                      "Variable gross cost other than fuel per Plant Type (US$2015/MWh)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;
i04VarCost(PGALL,YTIME) = i04VarCost(PGALL,YTIME) + 1e-3;
*---
table i04InvPlants(allCy,PGALL,YTIME)	           "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
i04InvPlants(allCy,PGALL,YTIME) = 0;
*---
table i04PlantDecomSched(allCy,PGALL,YTIME)	           "Decided plant decomissioning schedule (GW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
i04PlantDecomSched(allCy,PGALL,YTIME) = 0;
*---
table iMatFacPlaAvailCapData(allCy,PGALL,YTIME)      "Maturity factor related to plant available capacity (1)"
$ondelim
$include"./iMatFacPlaAvailCap.csv"
$offdelim
;
*---
table iScaleEndogScrapData(allCy,PGALL,YTIME)      "Maturity factor related to plant available capacity (1)"
$ondelim
$include"./iScaleEndogScrapPG.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
variable i04ScaleEndogScrap(allCy,PGALL,YTIME)     "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
i04MatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 1e-2;
i04MatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 1;
i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME) = iMatFacPlaAvailCapData(runCy,PGALL,YTIME);

i04ScaleEndogScrap.LO(runCy,PGALL,YTIME) = 1e-2;
i04ScaleEndogScrap.UP(runCy,PGALL,YTIME) = 10;
i04ScaleEndogScrap.L(runCy,PGALL,YTIME) = iScaleEndogScrapData(runCy,PGALL,YTIME);
$ELSE.calib
parameter i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
parameter i04ScaleEndogScrap(allCy,PGALL,YTIME)     "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
i04MatFacPlaAvailCap(runCy,PGALL,YTIME) = iMatFacPlaAvailCapData(runCy,PGALL,YTIME);
i04ScaleEndogScrap(runCy,PGALL,YTIME) = iScaleEndogScrapData(runCy,PGALL,YTIME);
$ENDIF.calib
*---
$$ontext
parameter i04FIT(allCy,PGALL,YTIME)                  "Feed0In-Tariff (US$2015/KWh)"
/
JPN.PGAWND.YTIME 0.09
JPN.PGAWNO.YTIME 0.25
JPN.PGOTHREN.YTIME 0.21
JPN.PGLHYD.YTIME 0.13
JPN.PGSHYD.YTIME 0.20
JPN.ATHBMSWAS.YTIME 0.15
JPN.PGSOL.YTIME 0.06
/ ;
$$offtext
*---
i04TechLftPlaType(runCy,PGALL) = i04DataTechLftPlaType(PGALL, "LFT");
i04TechLftPlaType(runCy,"PGH2F") = 20;
*---
i04GrossCapCosSubRen(runCy,PGALL,YTIME) = i04GrossCapCosSubRen(runCy,PGALL,YTIME)/1000;
*---
i04DecInvPlantSched(runCy,PGALL,YTIME) = i04InvPlants(runCy,PGALL,YTIME);
*---
i04MxmShareChpElec(runCy,YTIME) = 0.2;
*---
i04Util(allCy,PGALL,YTIME) = 1;
*---
i04ShareFuels(runCy,PGALL,PGEF)$PGALLTOEF(PGALL,PGEF) = 
(
  i03InpTotTransfProcess(runCy,"PG",PGEF,"%fBaseY%") / 
  SUM(PGEF2$PGALLTOEF(PGALL,PGEF2),i03InpTotTransfProcess(runCy,"PG",PGEF2,"%fBaseY%"))
)$SUM(PGEF2$PGALLTOEF(PGALL,PGEF2),i03InpTotTransfProcess(runCy,"PG",PGEF2,"%fBaseY%")) +
(
  1 / CARD(PGALL)
)$(not SUM(PGEF2$PGALLTOEF(PGALL,PGEF2),i03InpTotTransfProcess(runCy,"PG",PGEF2,"%fBaseY%")));