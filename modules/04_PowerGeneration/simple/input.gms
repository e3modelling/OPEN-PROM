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
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
i04MatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 1e-6;
i04MatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 10;
i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME) = iMatFacPlaAvailCapData(runCy,PGALL,YTIME);
$ELSE.calib
parameter i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
i04MatFacPlaAvailCap(runCy,PGALL,YTIME) = iMatFacPlaAvailCapData(runCy,PGALL,YTIME);
$ENDIF.calib
*--- EU + UK
i04MatFacPlaAvailCap(EU28,"ATHBMSCCS",YTIME)$(ord(YTIME)<41) = i04MatFacPlaAvailCap(EU28,"ATHBMSCCS","2024") + 0.004 * (ord(YTIME)-14);
i04MatFacPlaAvailCap(EU28,"ATHGASCCS",YTIME)$(ord(YTIME)<41) = i04MatFacPlaAvailCap(EU28,"ATHGASCCS","2024")+ 0.002 * (ord(YTIME)-14);

* i04MatFacPlaAvailCap(EU28,"ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap(EU28,"ATHBMSCCS","2024") + 0.004 * 26;
* i04MatFacPlaAvailCap(EU28,"ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap(EU28,"ATHGASCCS","2024")+ 0.002 * 26;

*--- IND
i04MatFacPlaAvailCap("IND","ATHBMSCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("IND","ATHBMSCCS","2024") + 0.002 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("IND","ATHGASCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("IND","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("IND","ATHBMSCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("IND","ATHBMSCCS","2024") + 0.002 * 31;
* i04MatFacPlaAvailCap("IND","ATHGASCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("IND","ATHGASCCS","2024")+ 0.001 * 31;


*---

*--- REF
i04MatFacPlaAvailCap("REF","ATHBMSCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("REF","ATHBMSCCS","2024") + 0.002 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("REF","ATHGASCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("REF","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("REF","ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("REF","ATHBMSCCS","2024") + 0.002 * 21;
* i04MatFacPlaAvailCap("REF","ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("REF","ATHGASCCS","2024")+ 0.001 * 21;

*--- JPN
i04MatFacPlaAvailCap("JPN","ATHBMSCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("JPN","ATHBMSCCS","2024") + 0.01 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("JPN","ATHGASCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("JPN","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("JPN","ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("JPN","ATHBMSCCS","2024") + 0.002 * 21;
* i04MatFacPlaAvailCap("JPN","ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("JPN","ATHGASCCS","2024")+ 0.001 * 21;

*--- LAM
i04MatFacPlaAvailCap("LAM","ATHBMSCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("LAM","ATHBMSCCS","2024") + 0.002 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("LAM","ATHGASCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("LAM","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("LAM","ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("LAM","ATHBMSCCS","2024") + 0.002 * 21;
* i04MatFacPlaAvailCap("LAM","ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("LAM","ATHGASCCS","2024")+ 0.001 * 21;

*--- USA
i04MatFacPlaAvailCap("USA","ATHBMSCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("USA","ATHBMSCCS","2024") + 0.01 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("USA","ATHGASCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("USA","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("USA","ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("USA","ATHBMSCCS","2024") + 0.002 * 21;
* i04MatFacPlaAvailCap("USA","ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("USA","ATHGASCCS","2024")+ 0.001 * 21;

*---OAS
i04MatFacPlaAvailCap("OAS","ATHBMSCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("OAS","ATHBMSCCS","2024") + 0.002 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("OAS","ATHGASCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("OAS","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("OAS","ATHBMSCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("OAS","ATHBMSCCS","2024") + 0.002 * 31;
* i04MatFacPlaAvailCap("OAS","ATHGASCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("OAS","ATHGASCCS","2024")+ 0.001 * 31;

*---CAZ
i04MatFacPlaAvailCap("CAZ","ATHBMSCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("CAZ","ATHBMSCCS","2024") + 0.002 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("CAZ","ATHGASCCS",YTIME)$(ord(YTIME)<41 and ord(YTIME)>20) = i04MatFacPlaAvailCap("CAZ","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("CAZ","ATHBMSCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("CAZ","ATHBMSCCS","2024") + 0.002 * 21;
* i04MatFacPlaAvailCap("CAZ","ATHGASCCS",YTIME)$(ord(YTIME)>=41) = i04MatFacPlaAvailCap("CAZ","ATHGASCCS","2024")+ 0.001 * 21;
*---CHA
i04MatFacPlaAvailCap("CHA","ATHBMSCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("CHA","ATHBMSCCS","2024") + 0.0015 * (ord(YTIME)-20);
i04MatFacPlaAvailCap("CHA","ATHGASCCS",YTIME)$(ord(YTIME)<51 and ord(YTIME)>20) = i04MatFacPlaAvailCap("CHA","ATHGASCCS","2024")+ 0.001 * (ord(YTIME)-20);

* i04MatFacPlaAvailCap("CHA","ATHBMSCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("CHA","ATHBMSCCS","2024") + 0.0015 * 31;
* i04MatFacPlaAvailCap("CHA","ATHGASCCS",YTIME)$(ord(YTIME)>=51) = i04MatFacPlaAvailCap("CHA","ATHGASCCS","2024")+ 0.001 * 31;
*---
parameter i04LoadFacElecDem(DSBS)                  "Load factor of electricity demand per sector (1)"
/
IS 	0.92,
NF 	0.94,
CH 	0.83,
BM 	0.82,
PP 	0.74,
FD 	0.65,
EN 	0.7,
TX 	0.61,
OE 	0.92,
OI 	0.67,
SE 	0.64,
AG 	0.52,
HOU	0.72,
PC 	0.7,
PB 	0.7,
PT 	0.62,
PN 	0.7,
PA 	0.7,
GU 	0.7,
GT 	0.62,
GN 	0.7,
BU 	0.7,
PCH	0.83,
NEN	0.83 
/ ;
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
parameter i04LoadFactorAdj(DSBS)	               "Parameters for load factor adjustment i04BaseLoadShareDem (1)"
/
IS 	0.9,
NF 	0.92,
CH 	0.78,
BM 	0.81,
PP 	0.91,
FD 	0.61,
EN 	0.65,
TX 	0.6,
OE 	0.9,
OI 	0.59,
SE 	0.58,
AG 	0.45,
HOU	0.55,
PC 	0.43,
PB 	0.43,
PT 	0.29,
PN 	0.43,
PA 	0.43,
GU 	0.43,
GT 	0.29,
GN 	0.43,
BU 	0.43,
PCH	0.78,
NEN	0.78 
/ ;
*---
i04TechLftPlaType(runCy,PGALL) = i04DataTechLftPlaType(PGALL, "LFT");
i04TechLftPlaType(runCy,"PGH2F") = 20;
*---
i04GrossCapCosSubRen(runCy,PGALL,YTIME) = i04GrossCapCosSubRen(runCy,PGALL,YTIME)/1000;
*---
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(i04GrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", i04GrossCapCosSubRen
ENDLOOP;
*---
i04ScaleEndogScrap = 3 / card(PGALL);
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


i04SensCarbon(allCy,YTIME) = 0;
*--- EU+UK
i04SensCarbon(EU28,YTIME) = 0.4;
i04SensCarbon(EU27,YTIME)$(ord(YTIME)>34) = 0.6;
*--- IND
i04SensCarbon("IND",YTIME)$(ord(YTIME)>34) = 0.4;
*--- REF
i04SensCarbon("REF",YTIME) = 0.4;
*--- JPN
i04SensCarbon("JPN",YTIME) = 0.6;
*--- LAM
i04SensCarbon("LAM",YTIME) = 0.6;

*--- USA
i04SensCarbon("USA",YTIME) = 0.6;

*--- OAS
i04SensCarbon("OAS",YTIME) = 0.4;
*--- CAZ
i04SensCarbon("CAZ",YTIME) = 0.4;

*---NEU
i04SensCarbon("NEU",YTIME) = 0.4;

*--- COAL PHASE OUT ---
i04MatFacPlaAvailCap(EU28,"ATHCOAL",YTIME) = 0;
i04MatFacPlaAvailCap(EU28,"ATHOIL",YTIME) = 0;
i04MatFacPlaAvailCap(EU28,"ATHLGN",YTIME) = 0;

i04MatFacPlaAvailCap(EU28,"ATHCOALCCS",YTIME) = 0;
i04MatFacPlaAvailCap(EU28,"ATHLGNCCS",YTIME) = 0;

*--- Limit Lifetime to force phase out
i04TechLftPlaType(EU28,"ATHCOAL") = 10;
i04TechLftPlaType(EU28,"ATHOIL") = 10;
i04TechLftPlaType(EU28,"ATHLGN") = 10;

