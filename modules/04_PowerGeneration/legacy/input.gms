*' @title PowerGeneration Inputs
*' @code

*---
table iCummMnmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative minimum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMinResPot.csv"
$offdelim
;
*---
table iInstCapPast(allCy,PGALL,YTIME)        "Installed capacity past (GW)"
$ondelim
$include"./iInstCapPast.csv"
$offdelim
;
*---
table iAvailRate(PGALL,YTIME)	    "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
*---
table iDataElecSteamGen(allCy,PGOTH,YTIME)	          "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
*---
table iDataElecProd(allCy,PGALL,YTIME) "Electricity production past years (GWh)"
$ondelim
$include"./iDataElecProd.csv"
$offdelim
;
*---
table iDataTechLftPlaType(PGALL, PGECONCHAR) "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
*---
table iGrossCapCosSubRen(allCy,PGALL,YTIME)             "Gross Capital Cost per Plant Type with subsidy for renewables (kUS$2015/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
*---
table iFixOandMCost(allCy,PGALL,YTIME)    "Fixed O&M Gross Cost per Plant Type (US$2015/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;
*---
table iVarCost(PGALL,YTIME)             "Variable gross cost other than fuel per Plant Type (US$2015/MWh)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;
*---
table iInvPlants(allCy,PGALL,YTIME)	            "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
*---
table iDecomPlants(allCy,PGALL,YTIME)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
*---
table iCummMxmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative maximum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMaxResPot.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == MatCalibration
variable iMatFacPlaAvailCap(allCy,PGALL,YTIME) "Maturity factor related to plant available capacity (1)";
table iMatFacPlaAvailCapL(allCy,PGALL,YTIME) "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
iMatFacPlaAvailCap.L(runCy,PGALL,YTIME) = iMatFacPlaAvailCapL(runCy,PGALL,YTIME);
iMatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 0.00000001;
iMatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 40;
$ELSE.calib
table iMatFacPlaAvailCap(allCy,PGALL,YTIME) "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
$ENDIF.calib
*---
$IFTHEN.calib %Calibration% == MatCalibration
variable iMatureFacPlaDisp(allCy,PGALL,YTIME) "Maturity factor related to plant dispatching (1)";
table iMatureFacPlaDispL(allCy,PGALL,YTIME) "Maturity factor related to plant dispatching (1)"
$ondelim
$include "./iMatureFacPlaDisp.csv"
$offdelim
;
iMatureFacPlaDisp.L(runCy,PGALL,YTIME) = iMatureFacPlaDispL(runCy,PGALL,YTIME);
iMatureFacPlaDisp.LO(runCy, PGALL, YTIME) = 0.00001;
iMatureFacPlaDisp.UP(runCy, PGALL, YTIME) = 600; !!5 * iMatureFacPlaDispL("USA", PGALL, YTIME);
$ELSE.calib
table iMatureFacPlaDisp(allCy,PGALL,YTIME) "Maturity factor related to plant dispatching (1)"
$ondelim
$include"./iMatureFacPlaDisp.csv"
$offdelim
;
$ENDIF.calib
*---
parameter iScaleEndogScrap(PGALL) "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
*---
parameter iMxmShareChpElec "Maximum share of CHP electricity in a country (1)";
*---
parameter iDataElecAndSteamGen(allCy,CHP,YTIME)	 "Data releated to electricity and steam generation";
*---
parameter iLoadFacElecDem(DSBS)    "Load factor of electricity demand per sector (1)" /
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
NEN	0.83 / ;
*---
parameter iLoadFactorAdj(DSBS)	"Parameters for load factor adjustment iBaseLoadShareDem (1)" /
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
NEN	0.78 / ;
*---
parameter iLoadFactorAdjMxm(VARIOUS_LABELS)    "Parameter for load factor adjustment iMxmLoadFacElecDem (1)" /
AMAXBASE 3,
MAXLOADSH 0.45 / ;
*---
Parameters
iBaseLoadShareDem(allCy,DSBS,YTIME)	                       "Baseload share of demand per sector (1)"
iHisChpGrCapData(allCy,CHP,YTIME)	                       "Historical CHP  gross capacity data (GW)"
iMinRenPotential(allCy,PGRENEF,YTIME)	                   "Minimum renewable potential (GW)"
iPeakBsLoadBy(allCy,PGLOADTYPE)	                           "Peak and Base load for base year (GW)"
iTotAvailCapBsYr(allCy)	                                   "Total installed available capacity in base year (GW)"
iTotAvailNomCapBsYr(allCy,YTIME)	                         "Total nominal available installed capacity in base year (GW)"
iUtilRateChpPlants(allCy,CHP,YTIME)	                       "Utilisation rate of CHP Plants (1)"
iMxmLoadFacElecDem(allCy,YTIME)	                           "Maximum load factor of electricity demand (1)"
iBslCorrection(allCy,YTIME)	                               "Parameter of baseload correction (1)"
iTechLftPlaType(allCy,PGALL)	                           "Technical Lifetime per plant type (year)"
iScaleEndogScrap(PGALL)                                    "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
iDecInvPlantSched(allCy,PGALL,YTIME)                       "Decided plant investment schedule (GW)"
iPlantDecomSched(allCy,PGALL,YTIME)	                       "Decided plant decomissioning schedule (GW)"	
iMaxRenPotential(allCy,PGRENEF,YTIME)	                   "Maximum enewable potential (GW)"
iMxmShareChpElec(allCy,YTIME)	                           "Maximum share of CHP electricity in a country (1)"
!! iMatureFacPlaDisp(allCy,PGALL,YTIME)	                   "Maturity factor related to plant dispatching (1)"
;
*---
iBaseLoadShareDem(runCy,DSBS,YTIME)$an(YTIME)  = iLoadFactorAdj(DSBS);
*---
iDataElecAndSteamGen(runCy,CHP,YTIME) = 0 ;
*---
iHisChpGrCapData(runCy,CHP,YTIME) = iDataElecAndSteamGen(runCy,CHP,YTIME);
*---
iCummMnmInstRenCap(runCy,PGRENEF,YTIME)$(not iCummMnmInstRenCap(runCy,PGRENEF,YTIME)) = 1e-4;
iMinRenPotential(runCy,"LHYD",YTIME) = iCummMnmInstRenCap(runCy,"LHYD",YTIME);
iMinRenPotential(runCy,"SHYD",YTIME) = iCummMnmInstRenCap(runCy,"SHYD",YTIME);
iMinRenPotential(runCy,"WND",YTIME)  = iCummMnmInstRenCap(runCy,"WND",YTIME);
iMinRenPotential(runCy,"WNO",YTIME)  = iCummMnmInstRenCap(runCy,"WNO",YTIME);
iMinRenPotential(runCy,"SOL",YTIME)  = iCummMnmInstRenCap(runCy,"SOL",YTIME);
iMinRenPotential(runCy,"DPV",YTIME)  = iCummMnmInstRenCap(runCy,"DPV",YTIME);
iMinRenPotential(runCy,"BMSWAS",YTIME) = iCummMnmInstRenCap(runCy,"BMSWAS",YTIME);
iMinRenPotential(runCy,"OTHREN",YTIME) = iCummMnmInstRenCap(runCy,"OTHREN",YTIME);
*---
iPeakBsLoadBy(runCy,PGLOADTYPE) = sum(tfirst, iDataElecSteamGen(runCy,PGLOADTYPE,tfirst));
*---
iTotAvailCapBsYr(runCy) = sum(tfirst,iDataElecSteamGen(runCy,"TOTCAP",TFIRST))+sum(tfirst,iDataElecSteamGen(runCy,"CHP_CAP",TFIRST))*0.85;
iTotAvailNomCapBsYr(runCy,YTIME)$datay(YTIME) = iDataElecSteamGen(runCy,"TOTNOMCAP",YTIME);
*---
iUtilRateChpPlants(runCy,CHP,YTIME) = 0.5;
*---
iMxmLoadFacElecDem(runCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("MAXLOADSH");
*---
iBslCorrection(runCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("AMAXBASE");
*---
iTechLftPlaType(runCy,PGALL) = iDataTechLftPlaType(PGALL, "LFT");
*---
iGrossCapCosSubRen(runCy,PGALL,YTIME) = iGrossCapCosSubRen(runCy,PGALL,YTIME)/1000;
*---
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
ENDLOOP;
*---
iScaleEndogScrap(PGALL) = 0.035;
*---
iDecInvPlantSched(runCy,PGALL,YTIME) = iInvPlants(runCy,PGALL,YTIME);
*---
iPlantDecomSched(runCy,PGALL,YTIME) = iDecomPlants(runCy,PGALL,YTIME);
*---
iCummMxmInstRenCap(runCy,PGRENEF,YTIME)$(not iCummMxmInstRenCap(runCy,PGRENEF,YTIME)) = 1e-4;
*---
iMaxRenPotential(runCy,"LHYD",YTIME) = iCummMxmInstRenCap(runCy,"LHYD",YTIME);
iMaxRenPotential(runCy,"SHYD",YTIME) = iCummMxmInstRenCap(runCy,"SHYD",YTIME);
iMaxRenPotential(runCy,"WND",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"WND",YTIME);
iMaxRenPotential(runCy,"WNO",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"WNO",YTIME);
iMaxRenPotential(runCy,"SOL",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"SOL",YTIME);
iMaxRenPotential(runCy,"DPV",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"DPV",YTIME);
iMaxRenPotential(runCy,"BMSWAS",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"BMSWAS",YTIME);
iMaxRenPotential(runCy,"OTHREN",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"OTHREN",YTIME);
*---
* iMatFacPlaAvailCap(runCy,CCS,YTIME)$an(YTIME)  =50;
*---
iMxmShareChpElec(runCy,YTIME) = 0.1;
*---