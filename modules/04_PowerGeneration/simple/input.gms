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
table i04DataElecSteamGen(allCy,PGOTH,YTIME)	   "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
*---
table i04DataElecProdNonCHP(allCy,PGALL,YTIME)           "Electricity Non-CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdNonCHP.csv"
$offdelim
;
*---
table i04DataElecProdCHP(allCy,EF,YTIME)           "Electricity CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdCHP.csv"
$offdelim
;
*---
$ifthen.calib %Calibration% == MatCalibration
table t04DemElecTot(allCy, YTIME)                   "Secondary energy electricity - target demand (TWh)"
$ondelim
$include "../targets/tDemand.csv"
$offdelim
;
*---
table t04SharePowPlaNewEq(allCy,PGALL,YTIME)    "Ratio of newly added capacity smoothed over 10-year period ()"
$ondelim
$include "../targets/tShares_ProdElec.csv"
$offdelim
;
$endif.calib
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
table i04DecInvPlantSched(allCy,PGALL,YTIME)	           "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
*---
table i04PlantDecomSched(allCy,PGALL,YTIME)	           "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
*---
table i03InpPGTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpPGTransfProcess.csv"
$offdelim
;
*---
table i03OutPGTransfProcess(allCy,ELCEF,YTIME)	      ""	
$ondelim
$include"./iOutPGTransfProcess.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
table i04MatFacPlaAvailCapL(allCy,PGALL,YTIME)     "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
i04MatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 0;
*i04MatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 40;
i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME)    = 1;
$ELSE.calib
table i04MatFacPlaAvailCap(allCy,PGALL,YTIME)      "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
$ENDIF.calib
*---
parameter i04MxmShareChpElec                       "Maximum share of CHP electricity in a country (1)";
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
parameter i04LoadFactorAdjMxm(VARIOUS_LABELS)      "Parameter for load factor adjustment i04MxmLoadFacElecDem (1)"
/
AMAXBASE  3,
MAXLOADSH 0.45
/ ;
*---
Parameters
i04BaseLoadShareDem(allCy,DSBS,YTIME)	           "Baseload share of demand per sector (1)"
iTotAvailNomCapBsYr(allCy,YTIME)	               "Total nominal available installed capacity in base year (GW)"
i04MxmLoadFacElecDem(allCy,YTIME)	               "Maximum load factor of electricity demand (1)"
i04TechLftPlaType(allCy,PGALL)	                   "Technical Lifetime per plant type (year)"
i04ScaleEndogScrap                              "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
i04DecInvPlantSched(allCy,PGALL,YTIME)             "Decided plant investment schedule (GW)"
i04PlantDecomSched(allCy,PGALL,YTIME)	           "Decided plant decomissioning schedule (GW)"	
i04MxmShareChpElec(allCy,YTIME)	                   "Maximum share of CHP electricity in a country (1)"
;
*---
i04BaseLoadShareDem(runCy,DSBS,YTIME)$an(YTIME)  = i04LoadFactorAdj(DSBS);
*---
iTotAvailNomCapBsYr(runCy,YTIME)$datay(YTIME) = i04DataElecSteamGen(runCy,"TOTNOMCAP",YTIME);
*---
i04MxmLoadFacElecDem(runCy,YTIME)$an(YTIME) = i04LoadFactorAdjMxm("MAXLOADSH");
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
i04ScaleEndogScrap = 2 / card(PGALL);
*---
i04MxmShareChpElec(runCy,YTIME) = 0.6;
*---
i04DecInvPlantSched(allCy,PGALL,YTIME)$(ord(YTIME) < 16) = 0;
*---
i04PlantDecomSched(allCy,PGALL,YTIME)$(ord(YTIME) < 16) = 0;