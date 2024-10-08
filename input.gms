table iGDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
table iPop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
table iActv(YTIME,allCy,SBS) "Sector activity (various)"
                              !! main sectors (Billion US$2015) 
                              !! bunkers and households (1)
                              !! transport (Gpkm, or Gvehkm or Gtkm)
$ondelim
$include "./iActv.csvr"
$offdelim
;
table iTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
table iElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;

iElastA(runCy,SBS,ETYPES,YTIME) = iElastA("ELL",SBS,ETYPES,YTIME);

table iElastNonSubElecData(SBS,ETYPES,YTIME) "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
iElastNonSubElec(runCy,SBS,ETYPES,YTIME) = iElastNonSubElecData(SBS,ETYPES,YTIME);

parameter iNatGasPriProElst(allCy)	          "Natural Gas primary production elasticity related to gross inland consumption (1)" /
$ondelim
$include "./iNatGasPriProElst.csv"
$offdelim
/;

parameter iDiscData(SBS) "Discount rates per subsector ()" /
PCH     0.12
IS      0.12
NF      0.12
CH      0.12
BM      0.12
PP      0.12
FD      0.12
EN      0.12
TX      0.12
OE      0.12
OI      0.12
SE      0.12
AG      0.12
HOU     0.175
PC      0.175
PT      0.08
PA      0.12
GU      0.12
GT      0.08
GN      0.12
BU      0.12
NEN     0.08
PG      0.1
H2P     0.08
H2INFR  0.08 
/;

parameter iDisc(allCy,SBS,YTIME) "Discount rates per subsector for all countries ()" ;
iDisc(runCy,SBS,YTIME) = iDiscData(SBS);

* FIXME: Drive the emission factors with mrprom
* author=giannou
parameter iCo2EmiFacAllSbs(EF) "CO2 emission factors (kgCO2/kgoe fuel burned)" /
LGN 4.15330622,
HCL 3.941453651,
SLD 4.438008647,
GSL 2.872144882,
GDO 3.068924588,
LPG 2.612562612,
KRS 2.964253636,
RFO 3.207089028,
OLQ 3.207089028,
NGS 2.336234395,
OGS 3.207089028,
BMSWAS 0/;

iCo2EmiFac(runCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
iCo2EmiFac(runCy,"IS","HCL",YTIME)   = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
table iDataPassCars(allCy,GompSet1,Gompset2)        "Initial Data for Passenger Cars ()"
          scr
CHA.PC    0.0201531648401507
IND.PC    0.0201531648401507
USA.PC    0.0418811968705786
;

iDataPassCars(runCy,"PC","S1") = 1.0;
iSigma(runCy,"S1") = iDataPassCars(runCy,"PC","S1");
iDataPassCars(runCy,"PC","S2") = -0.01;
iSigma(runCy,"S2") = iDataPassCars(runCy,"PC","S2");
iDataPassCars(runCy,"PC","S3") = 6.5;
iSigma(runCy,"S3") = iDataPassCars(runCy,"PC","S3");
iPassCarsMarkSat(runCy) = iDataPassCars(runCy,"PC","SAT");
iGdpPassCarsMarkExt(runCy) = iDataPassCars(runCy,"PC","MEXTV");
iPassCarsScrapRate(runCy)  = iDataPassCars(runCy,"PC", "SCR");

parameter iInitSpecFuelConsData(TRANSE,TTECH,EF)        "Initial Specific fuel consumption ()" /
PC.LPG.LPG	65.88
PC.GSL.GSL	73.2
PC.GDO.GDO	54.9
PC.NGS.NGS	84.3391
PC.MET.MET	71.84
PC.ETH.ETH	102.1
PC.BGDO.BGDO	54.9
PC.H2F.H2F	24.15
PC.ELC.ELC	20.496
PC.PHEVGSL.GSL	43.92
PC.PHEVGSL.ELC	20.496
PC.PHEVGDO.GDO	32.94
PC.PHEVGDO.ELC	20.496
PC.CHEVGSL.GSL	45.384
PC.CHEVGDO.GDO	40.8456
PT.GDO.GDO	18.6313
PT.MET.MET	12.6
PT.H2F.H2F	8.9
PT.ELC.ELC	2.73638
PA.H2F.H2F	21.7
GU.LPG.LPG	54.1073
GU.GSL.GSL	60.1192
GU.GDO.GDO	45.0894
GU.NGS.NGS	66
GU.MET.MET	56.2
GU.ETH.ETH	80
GU.BGDO.BGDO	45.0894
GU.H2F.H2F	13.5268
GU.ELC.ELC	27.0536
GU.PHEVGSL.GSL	34.4
GU.PHEVGSL.ELC	21.8
GU.PHEVGDO.GDO	27.0536
GU.PHEVGDO.ELC	21.8
GU.CHEVGDO.GDO	21.8
GT.GDO.GDO	33.629
GT.MET.MET	78
GT.H2F.H2F	92
GT.ELC.ELC	11.5245
GN.GSL.GSL	22.8
GN.GDO.GDO	15.2
GN.H2F.H2F	8.14286
/;

table iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,YTIME)        "Initial Specific fuel consumption for all countries ()";
iInitSpecFuelCons(runCy,TRANSE,TTECH,EF,YTIME) = iInitSpecFuelConsData(TRANSE,TTECH,EF) ; 
iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF) = iInitSpecFuelCons(runCy,TRANSE,TTECH,EF,"2017");

parameter iElaSubData(DSBS)       "Elasticities by subsector (1)" /
PCH	2
IS	2.57
NF	1.99
CH	2.23
BM	3.43
PP	2.27
FD	2.54
EN	2.61
TX	3.02
OE	1.49
OI	1.61
SE	1.47
AG	1.82
HOU	2.41
BU	2
NEN	2
/;

table iElaSub(allCy,DSBS)                           "Elasticities by subsector for all countries (1)";
iElaSub(runCy,DSBS) = iElaSubData(DSBS);

parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)" /smallest 0.425506805,
                                                                                             modal    0.595709528,
                                                                                             largest 0.833993339/;

table iRateLossesFinCons(allCy,EF,YTIME)               "Rate of losses over Available for Final Consumption (1)"
$ondelim
$include "./iRateLossesFinCons.csv"
$offdelim
;

parameter iParDHEffData(PGEFS) "Parameter of  district heating Efficiency (1)" /
HCL		0.76,
LGN		0.75,
GDO		0.78,
RFO		0.78,
OLQ		0.78,
NGS		0.8,
OGS		0.78,
BMSWAS    0.76 
/;

parameter iParDHEfficiency(PGEFS,YTIME)                 "Parameter of  district heating Efficiency for all years (1)" ;
iParDHEfficiency(PGEFS,YTIME) = iParDHEffData(PGEFS) ;

$ontext
table iSuppTransfInputPatFuel(EF,YTIME)            "Supplementary Parameter for the transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
$ondelim
$include "./iSuppTransfInputPatFuel.csv"
$offdelim
; 
$offtext

parameter iSupResRefCapacity(allCy,SUPOTH,YTIME)	           "Supplementary Parameter for the residual in refineries Capacity (1)";
iSupResRefCapacity(runCy,SUPOTH,YTIME) = 1;

table iSuppRefCapacity(allCy,SUPOTH,YTIME)	          "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
parameter iSupTrnasfOutputRefineries(allCy,EF,YTIME)	     "Supplementary parameter for the transformation output from refineries (Mtoe)";
iSupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;

table iSupRateEneBranCons(allCy,EF,YTIME)	          "Rate of Energy Branch Consumption over total transformation output of iRateEneBranCons (1)"
$ondelim
$include"./iSupRateEneBranCons.csv"
$offdelim
;
table iSuppTransfers(allCy,EFS,YTIME)	                "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
table iSuppPrimProd(allCy,PPRODEF,YTIME)	          "Supplementary Parameter for Primary Production (Mtoe)"
$ondelim
$include"./iSuppPrimProd.csv"
$offdelim
;
iFuelPriPro(runCy,PPRODEF,YTIME) = iSuppPrimProd(runCy,PPRODEF,YTIME);
table iPriceFuelsInt(WEF,YTIME)                "International Fuel Prices ($2015/toe)"
$ondelim
$include"./iPriceFuelsInt.csv"
$offdelim
;
table iPriceFuelsIntBase(WEF,YTIME)	           "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iPriceFuelsIntBase.csv"
$offdelim
;
table iSuppRatePrimProd(allCy,EF,YTIME)	              "Supplementary Parameter for iRatePrimProd (1)"	
$ondelim
$include"./iSuppRatePrimProd.csv"
$offdelim
;
table iSuppExports(allCy,EF,YTIME)	                 "Supplementary parameter for  exports (Mtoe)"		
$ondelim
$include"./iSuppExports.csv"
$offdelim
;
parameter iImpExp(allCy,EFS,YTIME)	                 "Imports of exporting countries usually zero (1)" ;
iImpExp(runCy,EFS,YTIME)	= 0;

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
*PB 	0.43,
PT 	0.29,
*PN 	0.43,
PA 	0.43,
GU 	0.43,
GT 	0.29,
GN 	0.43,
BU 	0.43,
PCH	0.78,
NEN	0.78 / ;
iBaseLoadShareDem(runCy,DSBS,YTIME)$an(YTIME)  = iLoadFactorAdj(DSBS);
parameter iCO2SeqData(CO2SEQELAST)	       "Data for CO2 sequestration (1)" /
POT	9175,
mc_a	0.00125928,
mc_b	6.6,
mc_c	0.02,
mc_d	0.000839237,
mc_s	120,
mc_m	1.013
/ ;
iElastCO2Seq(runCy,CO2SEQELAST) = iCO2SeqData(CO2SEQELAST);

*Sources for vehicle lifetime:
*US Department of Transportation, International Union of Railways, Statista, EU CORDIS
table iDataTransTech (TRANSE, EF, ECONCHAR, YTIME) "Technoeconomic characteristics of transport (various)"
$ondelim
$include"./iDataTransTech.csv"
$offdelim
;
table iDataIndTechnology(INDSE,EF,ECONCHAR)                  "Technoeconomic characteristics of industry (various)"
            IC      FC      VC      LFT USC
IS.HCL      0.32196 6.8     1.36    25  2.3255
IS.LGN      0.48295 10.2    2.04    25  0.5
IS.LPG      0.48295 10.2    2.04    25  0.72
IS.KRS      0.48295 10.2    2.04    25  0.72
IS.GDO      0.48295 10.2    2.04    25  0.72
IS.RFO      0.48295 10.2    2.04    25  0.72
IS.OLQ      0.48295 10.2    2.04    25  0.72
IS.NGS      0.48295 10.2    2.04    25  0.8
IS.OGS      0.48295 10.2    2.04    25  0.8
IS.BMSWAS   0.48295 10.2    2.04    25  0.5
IS.ELC      0.29367 6.8     1.36    25  5.74713
IS.STE1AL   1.04547 17.284  17.68   25  0.35
IS.STE1AH   1.04547 17.284  17.68   25  0.35
IS.STE1AD   0.78340 23.3335 4.896   25  0.34
IS.STE1AR   0.78340 23.3335 4.896   25  0.34
IS.STE1AG   0.50901 12.9631 13.6    20  0.44
IS.STE1AB   1.00334 28.8752 8.16    25  0.37
IS.STE1AH2F 1.34817 40.4451         25  0.5
IS.HEATPUMP 0.92974 19.3882 3.1021  25  1.848
NF.HCL      3.8528  63.036          30  0.5
NF.LGN      3.8528  63.036          30  0.5
NF.LPG      3.21067 63.036          30  0.72
NF.KRS      3.21067 63.036          30  0.72
NF.GDO      3.21067 63.036          30  0.72
NF.RFO      3.21067 63.036          30  0.72
NF.OLQ      3.21067 63.036          30  0.72
NF.NGS      2.56853 63.036          30  0.8
NF.OGS      2.56853 63.036          30  0.8
NF.BMSWAS   3.8528  63.036          30  0.5
NF.ELC      3.4     63.036          30  0.97
NF.STE1AL   2.43133 40.1956 41.1163 25  0.35
NF.STE1AH   2.43133 40.1956 41.1163 25  0.35
NF.STE1AD   1.82186 54.264  11.386  25  0.34
NF.STE1AR   1.82186 54.264  11.386  25  0.34
NF.STE1AG   1.18376 30.1467 31.6279 20  0.44
NF.STE1AB   2.33335 67.1517 18.9767 25  0.37
NF.STE1AH2F 3.13528 94.0585         30  0.5
NF.HEATPUMP 4.94477 119.819         30  1.848
CH.HCL      0.53294 5.44            25  0.5
CH.LGN      0.53294 5.44            25  0.5
CH.LPG      0.44411 5.44            25  0.72
CH.KRS      0.44411 5.44            25  0.72
CH.GDO      0.44411 5.44            25  0.72
CH.RFO      0.44411 5.44            25  0.72
CH.OLQ      0.44411 5.44            25  0.72
CH.NGS      0.35529 5.44            25  0.8
CH.OGS      0.35529 5.44            25  0.8
CH.BMSWAS   0.53294 5.44            25  0.5
CH.ELC      0.476   5.44            25  0.97
CH.STE1AL   2.43133 40.1956 41.1163 25  0.35
CH.STE1AH   2.43133 40.1956 41.1163 25  0.35
CH.STE1AD   1.82186 54.264  11.386  25  0.34
CH.STE1AR   1.82186 54.264  11.386  25  0.34
CH.STE1AG   1.18376 30.1467 31.6279 20  0.44
CH.STE1AB   2.33335 67.1517 18.9767 25  0.37
CH.STE1AH2F 3.13528 94.0585         25  0.5
CH.HEATPUMP 0.68398 10.3404         25  1.848
BM.HCL      4.41477 3.2096          30  0.5
BM.LGN      4.41477 3.2096          30  0.5
BM.LPG      3.67898 3.2096          30  0.72
BM.KRS      3.67898 3.2096          30  0.72
BM.GDO      3.67898 3.2096          30  0.72
BM.RFO      3.67898 3.2096          30  0.72
BM.OLQ      3.67898 3.2096          30  0.72
BM.NGS      2.94318 3.2096          30  0.8
BM.OGS      2.94318 3.2096          30  0.8
BM.BMSWAS   4.41477 3.2096          30  0.5
BM.ELC      3.808   3.2096          30  0.97
BM.STE1AL   2.43133 40.1956 41.1163 25  0.35
BM.STE1AH   2.43133 40.1956 41.1163 25  0.35
BM.STE1AD   1.82186 54.264  11.386  25  0.34
BM.STE1AR   1.82186 54.264  11.386  25  0.34
BM.STE1AG   1.18376 30.1467 31.6279 20  0.44
BM.STE1AB   2.33335 67.1517 18.9767 25  0.37
BM.STE1AH2F 3.13528 94.0585         30  0.5
BM.HEATPUMP 5.66602 6.10081         30  1.848
PP.HCL      0.90179 1.632           25  0.5
PP.LGN      0.90179 1.632           25  0.5
PP.LPG      0.75149 1.632           25  0.72
PP.KRS      0.75149 1.632           25  0.72
PP.GDO      0.75149 1.632           25  0.72
PP.RFO      0.75149 1.632           25  0.72
PP.OLQ      0.75149 1.632           25  0.72
PP.NGS      0.60119 1.632           25  0.8
PP.OGS      0.60119 1.632           25  0.8
PP.BMSWAS   0.90179 1.632           25  0.5
PP.ELC      0.884   1.632           25  0.97
PP.STE1AL   2.43133 40.1956 41.1163 25  0.35
PP.STE1AH   2.43133 40.1956 41.1163 25  0.35
PP.STE1AD   1.82186 54.264  11.386  25  0.34
PP.STE1AR   1.82186 54.264  11.386  25  0.34
PP.STE1AG   1.18376 30.1467 31.6279 20  0.44
PP.STE1AB   2.33335 67.1517 18.9767 25  0.37
PP.STE1AH2F 2.27889 68.3668         25  0.5
PP.HEATPUMP 1.15738 3.10211         25  1.68
FD.HCL      0.63096 0.5372          25  0.5
FD.LGN      0.63096 0.5372          25  0.5
FD.LPG      0.42064 0.5372          25  0.72
FD.KRS      0.42064 0.5372          25  0.72
FD.GDO      0.42064 0.5372          25  0.72
FD.RFO      0.42064 0.5372          25  0.72
FD.OLQ      0.42064 0.5372          25  0.72
FD.NGS      0.33651 0.5372          25  0.8
FD.OGS      0.33651 0.5372          25  0.8
FD.BMSWAS   0.63096 0.5372          25  0.5
FD.ELC      0.476   0.5372          25  0.97
FD.STE1AL   2.43133 40.1956 41.1163 25  0.35
FD.STE1AH   2.43133 40.1956 41.1163 25  0.35
FD.STE1AD   1.82186 54.264  11.386  25  0.34
FD.STE1AR   1.82186 54.264  11.386  25  0.34
FD.STE1AG   1.18376 30.1467 31.6279 20  0.44
FD.STE1AB   2.33335 67.1517 18.9767 25  0.37
FD.STE1AH2F 2.27889 68.3668         25  0.5
FD.HEATPUMP 0.64783 1.02111         25  1.68
EN.HCL      1.00937 0.31769         25  0.5
EN.LGN      1.00937 0.31769         25  0.5
EN.LPG      0.84114 0.31769         25  0.72
EN.KRS      0.84114 0.31769         25  0.72
EN.GDO      0.84114 0.31769         25  0.72
EN.RFO      0.84114 0.31769         25  0.72
EN.OLQ      0.84114 0.31769         25  0.72
EN.NGS      0.67291 0.31769         25  0.8
EN.OGS      0.67291 0.31769         25  0.8
EN.BMSWAS   1.00937 0.31769         25  0.5
EN.ELC      0.748   0.31769         20  0.97
EN.STE1AL   2.43133 40.1956 41.1163 25  0.35
EN.STE1AH   2.43133 40.1956 41.1163 25  0.35
EN.STE1AD   1.82186 54.264  11.386  25  0.34
EN.STE1AR   1.82186 54.264  11.386  25  0.34
EN.STE1AG   1.18376 30.1467 31.6279 20  0.44
EN.STE1AB   2.33335 67.1517 18.9767 25  0.37
EN.STE1AH2F 2.27889 68.3668         25  0.5
EN.HEATPUMP 1.29545 0.60387         25  1.68
TX.HCL      0.67371 0.16959         20  0.5
TX.LGN      0.67371 0.16959         20  0.5
TX.LPG      0.44914 0.16959         20  0.72
TX.KRS      0.44914 0.16959         20  0.72
TX.GDO      0.44914 0.16959         20  0.72
TX.RFO      0.44914 0.16959         20  0.72
TX.OLQ      0.44914 0.16959         20  0.72
TX.NGS      0.35931 0.16959         20  0.8
TX.OGS      0.35931 0.16959         20  0.8
TX.BMSWAS   0.476   0.16959         20  0.5
TX.ELC      0.476   0.16959         20  0.97
TX.STE1AL   2.43133 40.1956 41.1163 25  0.35
TX.STE1AH   2.43133 40.1956 41.1163 25  0.35
TX.STE1AD   1.82186 54.264  11.386  25  0.34
TX.STE1AR   1.82186 54.264  11.386  25  0.34
TX.STE1AG   1.18376 30.1467 31.6279 20  0.44
TX.STE1AB   2.33335 67.1517 18.9767 25  0.37
TX.STE1AH2F 2.27889 68.3668         20  0.5
TX.HEATPUMP 0.69173 0.32236         20  1.68
OE.HCL      1.00937 0.31769         25  0.5
OE.LGN      1.00937 0.31769         25  0.5
OE.LPG      0.84114 0.31769         25  0.72
OE.KRS      0.84114 0.31769         25  0.72
OE.GDO      0.84114 0.31769         25  0.72
OE.RFO      0.84114 0.31769         25  0.72
OE.OLQ      0.84114 0.31769         25  0.72
OE.NGS      0.67291 0.31769         25  0.8
OE.OGS      0.67291 0.31769         25  0.8
OE.BMSWAS   1.00937 0.31769         25  0.5
OE.ELC      0.84114 0.31769         25  0.97
OE.STE1AL   2.43133 40.1956 41.1163 25  0.35
OE.STE1AH   2.43133 40.1956 41.1163 25  0.35
OE.STE1AD   1.82186 54.264  11.386  25  0.34
OE.STE1AR   1.82186 54.264  11.386  25  0.34
OE.STE1AG   1.18376 30.1467 31.6279 20  0.44
OE.STE1AB   2.33335 67.1517 18.9767 25  0.37
OE.STE1AH2F 2.27889 68.3668         25  0.5
OE.HEATPUMP 1.29545 0.60387         25  1.68
OI.HCL      0.94967 1.40352         20  0.5
OI.LGN      0.94967 1.40352         20  0.5
OI.LPG      0.79139 1.40352         20  0.72
OI.KRS      0.79139 1.40352         20  0.72
OI.GDO      0.79139 1.40352         20  0.72
OI.RFO      0.79139 1.40352         20  0.72
OI.OLQ      0.79139 1.40352         20  0.72
OI.NGS      0.63311 1.40352         20  0.8
OI.OGS      0.63311 1.40352         20  0.8
OI.BMSWAS   0.94967 1.40352         20  0.5
OI.ELC      0.68    1.40352         20  0.97
OI.STE1AL   2.43133 40.1956 41.1163 25  0.35
OI.STE1AH   2.43133 40.1956 41.1163 25  0.35
OI.STE1AD   1.82186 54.264  11.386  25  0.34
OI.STE1AR   1.82186 54.264  11.386  25  0.34
OI.STE1AG   1.18376 30.1467 31.6279 20  0.44
OI.STE1AB   2.33335 67.1517 18.9767 25  0.37
OI.STE1AH2F 2.27889 68.3668         20  0.5
OI.HEATPUMP 1.21884 2.66781         20  1.68
;

* Coverting EUR05 to US2015
iDataIndTechnology(INDSE,EF,"IC") = iDataIndTechnology(INDSE,EF,"IC") * 1.3;
iDataIndTechnology(INDSE,EF,"FC") = iDataIndTechnology(INDSE,EF,"FC") * 1.3;
iDataIndTechnology(INDSE,EF,"VC") = iDataIndTechnology(INDSE,EF,"VC") * 1.3;

table iDataDomTech(DOMSE,EF,ECONCHAR)                  "Technical lifetime of Industry (years)"
             IC       FC      VC      LFT USC
SE.HCL       0.323544 10.88           20  0.7
SE.LGN       0.323544 10.88           20  0.5
SE.LPG       0.24888  10.88           20  0.8
SE.GSL       0.323544 10.88           20  0.7
SE.KRS       0.24888  10.88           20  0.8
SE.GDO       0.24888  6.8             20  0.85
SE.RFO       0.24888  10.88           20  0.8
SE.OLQ       0.24888  10.88           20  0.8
SE.NGS       0.2244   6.8             20  0.88
SE.OGS       0.2244   10.88           20  0.8
SE.SOL       0.86224  1.36            20  0.97
SE.BMSWAS    0.323544 10.88           20  0.5
SE.ELC       0.3      8.976           12  0.97
SE.STE1AL    2.43133  40.1956 41.1163 30  0.375
SE.STE1AH    2.43133  40.1956 41.1163 30  0.375
SE.STE1AD    1.82186  54.264  11.386  30  0.3475
SE.STE1AR    1.82186  54.264  11.386  30  0.3475
SE.STE1AG    1.18376  30.1467 31.6279 25  0.485
SE.STE1AB    2.33335  67.1517 18.9767 30  0.3975
SE.STE1AH2F  2.68089  80.4266         20  0.465
SE.STE2LGN   0.296442 1.00489 2.37209 20  0.816667
SE.STE2OSL   0.296442 1.00489 2.37209 20  0.816667
SE.STE2GDO   0.296442 1.00489 2.37209 20  0.856667
SE.STE2RFO   0.296442 1.00489 2.37209 20  0.856667
SE.STE2OLQ   0.296442 1.00489 2.37209 20  0.856667
SE.STE2NGS   0.296442 1.00489 2.37209 20  0.896667
SE.STE2OGS   0.296442 1.00489 2.37209 20  0.896667
SE.STE2BMS   0.296442 1.00489 2.37209 20  0.816667
SE.HEATPUMP  0.432    12.9254         20  1.848
AG.HCL       0.323544 10.88           20  0.7
AG.LGN       0.323544 10.88           20  0.5
AG.LPG       0.24888  10.88           20  0.8
AG.GSL       0.323544 10.88           20  0.7
AG.KRS       0.24888  10.88           20  0.8
AG.GDO       0.24888  6.8             20  0.85
AG.RFO       0.24888  10.88           20  0.8
AG.OLQ       0.24888  10.88           20  0.8
AG.NGS       0.2244   6.8             20  0.88
AG.OGS       0.2244   10.88           20  0.8
AG.SOL       0.86224  1.36            20  0.97
AG.BMSWAS    0.323544 10.88           20  0.5
AG.ELC       0.3      8.976           12  0.97
AG.STE1AL    2.43133  40.1956 41.1163 30  0.375
AG.STE1AH    2.43133  40.1956 41.1163 30  0.375
AG.STE1AD    1.82186  54.264  11.386  30  0.3475
AG.STE1AR    1.82186  54.264  11.386  30  0.3475
AG.STE1AG    1.18376  30.1467 31.6279 25  0.485
AG.STE1AB    2.33335  67.1517 18.9767 30  0.3975
AG.STE1AH2F  2.68089  80.4266         20  0.465
AG.STE2LGN   0.296442 1.00489 2.37209 20  0.816667
AG.STE2OSL   0.296442 1.00489 2.37209 20  0.816667
AG.STE2GDO   0.296442 1.00489 2.37209 20  0.856667
AG.STE2RFO   0.296442 1.00489 2.37209 20  0.856667
AG.STE2OLQ   0.296442 1.00489 2.37209 20  0.856667
AG.STE2NGS   0.296442 1.00489 2.37209 20  0.896667
AG.STE2OGS   0.296442 1.00489 2.37209 20  0.896667
AG.STE2BMS   0.296442 1.00489 2.37209 20  0.816667
AG.HEATPUMP  0.432    12.9254         20  1.848
HOU.HCL      0.323544 10.88           20  0.7
HOU.LGN      0.323544 10.88           20  0.5
HOU.LPG      0.24888  10.88           20  0.8
HOU.GSL      0.323544 10.88           20  0.7
HOU.KRS      0.24888  10.88           20  0.8
HOU.GDO      0.24888  6.8             20  0.85
HOU.RFO      0.24888  10.88           20  0.8
HOU.OLQ      0.24888  10.88           20  0.8
HOU.NGS      0.2244   6.8             20  0.88
HOU.OGS      0.2244   10.88           20  0.8
HOU.SOL      0.86224  1.36            20  0.97
HOU.BMSWAS   0.323544 10.88           20  0.5
HOU.ELC      0.3      8.976           12  0.97
HOU.STE1AL   2.43133  40.1956 41.1163 30  0.375
HOU.STE1AH   2.43133  40.1956 41.1163 30  0.375
HOU.STE1AD   1.82186  54.264  11.386  30  0.3475
HOU.STE1AR   1.82186  54.264  11.386  30  0.3475
HOU.STE1AG   1.18376  30.1467 31.6279 25  0.485
HOU.STE1AB   2.33335  67.1517 18.9767 30  0.3975
HOU.STE1AH2F 2.68089  80.4266         20  0.465
HOU.STE2LGN  0.296442 1.00489 2.37209 20  0.816667
HOU.STE2OSL  0.296442 1.00489 2.37209 20  0.816667
HOU.STE2GDO  0.296442 1.00489 2.37209 20  0.856667
HOU.STE2RFO  0.296442 1.00489 2.37209 20  0.856667
HOU.STE2OLQ  0.296442 1.00489 2.37209 20  0.856667
HOU.STE2NGS  0.296442 1.00489 2.37209 20  0.896667
HOU.STE2OGS  0.296442 1.00489 2.37209 20  0.896667
HOU.STE2BMS  0.296442 1.00489 2.37209 20  0.816667
HOU.HEATPUMP 0.432    12.9254         20  1.848
;

* Coverting EUR05 to US2015
iDataDomTech(DOMSE,EF,"IC") = iDataDomTech(DOMSE,EF,"IC") * 1.3;
iDataDomTech(DOMSE,EF,"FC") = iDataDomTech(DOMSE,EF,"FC") * 1.3;
iDataDomTech(DOMSE,EF,"VC") = iDataDomTech(DOMSE,EF,"VC") * 1.3;

table iDataNonEneSec(NENSE,EF,ECONCHAR)                  "Technical data of non energy uses and bunkers (various)"
        IC      FC      VC      LFT USC
PCH.HCL 0.26227 45.22   2.37209 20  0.65
PCH.LGN 0.26227 47.6    2.37209 20  0.5
PCH.LPG 0.18088 20.4    2.37209 20  0.72
PCH.GDO 0.18088 9.044   2.37209 20  0.72
PCH.RFO 0.18088 18.088  2.37209 20  0.72
PCH.OLQ 0.18088 20.4    2.37209 20  0.72
PCH.NGS 0.18088 0.9044  2.37209 20  0.8
PCH.OGS 0.18088 1.36    2.37209 20  0.8
BU.GDO  0.204   0.136           25  0.72
BU.RFO  0.204   0.136           25  0.72
BU.OLQ  0.136   6.8             25  0.72
NEN.HCL 0.26227 45.22   2.37209 20  0.65
NEN.LGN 0.26227 47.6    2.37209 20  0.5
NEN.LPG 0.612   20.4    2.37209 20  0.72
NEN.GDO 0.18088 9.044   2.37209 20  0.72
NEN.RFO 0.18088 18.088  2.37209 20  0.72
NEN.OLQ 0.612   20.4    2.37209 20  0.72
NEN.NGS 0.18088 0.9044  2.37209 20  0.8
NEN.OGS 0.18088 1.36    2.37209 20  0.8
;

* Converting EUR05 to US2015
iDataNonEneSec(NENSE,EF,"IC") = iDataNonEneSec(NENSE,EF,"IC") * 1.3;
iDataNonEneSec(NENSE,EF,"FC") = iDataNonEneSec(NENSE,EF,"FC") * 1.3;
iDataNonEneSec(NENSE,EF,"VC") = iDataNonEneSec(NENSE,EF,"VC") * 1.3;

* FIXME: check if country-specific data is needed; move to mrprom
* author=giannou
table iIndCharData(allCy,INDSE,Indu_Scon_Set)               "Industry sector charactetistics (various)"
         BASE           SHR_NSE   SH_HPELC
ELL.IS   0.4397         0.7       0.00001
ELL.NF   0              0.95      0.00001
ELL.CH   0.1422         0.95      0.00001
ELL.BM   2.1062         0.95      0.00001
ELL.PP   0              0.95      0.00001
ELL.FD   0.6641         0.95      0.00001
ELL.TX   0.0638         0.95      0.00001
ELL.EN   1.6664         0.95      0.00001
ELL.OE   0.00000001     0.95      0.00001
ELL.OI   1.5161         0.95      0.00001
;

iIndChar(runCy,INDSE,Indu_Scon_Set) = iIndCharData("ELL",INDSE,Indu_Scon_Set);
table iInitConsSubAndInitShaNonSubElec(DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
     BASE   SHR_NSE SH_HPELC
SE   1.8266 0.9     0.00001
HOU  11.511 0.9     0.00001
AG   0.2078 0.9     0.00001
;

table iElcNetImpShare(allCy,SUPOTH,YTIME)	          "Ratio of electricity imports in total final demand (1)"
$ondelim
$include "./iElcNetImpShare.csv"
$offdelim
;

iShrHeatPumpElecCons(runCy,INDSE) = iIndChar(runCy,INDSE,"SH_HPELC");
iShrHeatPumpElecCons(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SH_HPELC");
iExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
*iElastCO2Seq(runCy,CO2SEQELAST) = iCO2SeqData(CO2SEQELAST,"%fBaseY%");
iRatioImpFinElecDem(runCy,YTIME)$an(YTIME) = iElcNetImpShare(runCy,"ELC_IMP",YTIME);
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = iSuppRatePrimProd(runCy,PPRODEF,YTIME);
iResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"HCL_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"NGS_PPROD",YTIME);
iResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = iSupResRefCapacity(runCy,"OIL_PPROD",YTIME);
iFeedTransfr(runCy,EFS,YTIME) = iSuppTransfers(runCy,EFS,YTIME);
iRateEneBranCons(runCy,EFS,YTIME)= iSupRateEneBranCons(runCy,EFS,YTIME);
iResTransfOutputRefineries(runCy,EFS,YTIME) = iSupTrnasfOutputRefineries(runCy,EFS,YTIME);;
iRefCapacity(runCy,YTIME)= iSuppRefCapacity(runCy,"REF_CAP",YTIME);
iResRefCapacity(runCy,YTIME) = iSupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
*iTransfInpGasworks(runCy,EFS,YTIME)= iSuppTransfInputPatFuel(EFS,YTIME);

parameter iLoadFactorAdjMxm(VARIOUS_LABELS)    "Parameter for load factor adjustment iMxmLoadFacElecDem (1)" /
AMAXBASE 3,
MAXLOADSH 0.45 / ;
iBslCorrection(runCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("AMAXBASE");
iMxmLoadFacElecDem(runCy,YTIME)$an(YTIME) = iLoadFactorAdjMxm("MAXLOADSH");
parameter iPolDstrbtnLagCoeffPriOilPr(kpdl)	  "Polynomial Distribution Lag Coefficients for primary oil production (1)"/
a1 1.666706504,
a2 1.333269594,
a3 1.000071707,
a4 0.666634797,
a5 0.33343691 /;

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
*PB 	0.7,
PT 	0.62,
*PN 	0.7,
PA 	0.7,
GU 	0.7,
GT 	0.62,
GN 	0.7,
BU 	0.7,
PCH	0.83,
NEN	0.83 / ;

*Calculation of consumer size groups and their distribution function
iNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10; !! 11 different consumer size groups for cars and trucks
iNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
iNcon(INDSE) = 10; !! 11 different consumer size groups for industrial sectors
iNcon(DOMSE) = 10; !! 11 different consumer size groups for domestic and tertiary sectors
iNcon(NENSE) = 10; !! 11 different consumer size groups for non energy uses
iNcon("BU") = 2;   !! ... except bunkers .


* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel


iAnnCons(runCy,'PC','smallest')= 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'modal')=0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'largest')= 4 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;


* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel

iAnnCons(runCy,'GU','smallest')=0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%")* 1000 * 2 / 3  * 1E-6;
iAnnCons(runCy,'GU','modal')=0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2  * 1E-6;
iAnnCons(runCy,'GU','largest')=4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2 * 10  * 1E-6;

iAnnCons(runCy,'PA','smallest')=40000 * 50 * 1E-6;
iAnnCons(runCy,'PA','modal')=400000 * 100 * 1E-6;
iAnnCons(runCy,'PA','largest')=800000 * 300 * 1E-6;

* Size will not play a role in buses, trains, ships and aircraft
* Following values are given only for the sake of uniformity, but iDisFunConSize is not really calculated for non-road transport!

*iAnnConsPB(runCy,'PB',"smallest") = 20000 * 5 * 1E-6;
*iAnnConsPB(runCy,'PB',"modal") = 50000* 15 * 1E-6;
*iAnnConsPB(runCy,'PB',"largest") = 200000 * 50 * 1E-6;


iAnnCons(runCy,'PT',"smallest") = 50000 * 50 * 1E-6;
iAnnCons(runCy,'PT',"modal") = 200000 * 150 * 1e-6;
iAnnCons(runCy,'PT',"largest") = 400000 * 500 * 1E-6;


iAnnCons(runCy,'GT',"smallest") = 50000 * 20 * 1E-6;
iAnnCons(runCy,'GT',"modal") = 200000 * 200 * 1e-6;
iAnnCons(runCy,'GT',"largest") = 400000 * 500 * 1E-6;

*iAnnConsPN(runCy,'PN',"smallest") = 10000 * 50 * 1E-6;
*iAnnConsPN(runCy,'PN',"modal") = 50000 * 100 * 1e-6;
*iAnnConsPN(runCy,'PN',"largest") = 100000 * 500 * 1E-6;


iAnnCons(runCy,'GN',"smallest") = 10000 * 20 * 1E-6;
iAnnCons(runCy,'GN',"modal") = 50000 * 300 * 1e-6;
iAnnCons(runCy,'GN',"largest") = 100000 * 1000 * 1E-6;

iAnnCons(runCy,INDSE,"smallest") = 0.2  ;
iAnnCons(runCy,INDSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.6 for iron & steel and 0.5 for other industry (see iterations in Excel):
iAnnCons(runCy,"IS","modal") = 0.587;
iAnnCons(runCy,INDSE,"modal")$(not sameas(INDSE,"IS")) = 0.487;

iAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat("smallest")  ;
iAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat("largest") ;
iAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat("modal");

iAnnCons(runCy,NENSE,"smallest") = 0.2  ;
iAnnCons(runCy,NENSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.5 for non-energy uses:
iAnnCons(runCy,NENSE,"modal") = 0.487 ;

iAnnCons(runCy,"BU","smallest") = 0.2 ;
iAnnCons(runCy,"BU","largest") = 1 ;
iAnnCons(runCy,"BU","modal") = 0.5 ;

* Consumer size groups distribution function

Loop (runCy,DSBS) DO
     Loop rCon$(ord(rCon) le iNcon(DSBS)+1) DO
          iDisFunConSize(runCy,DSBS,rCon) =
                 Prod(nSet$(ord(Nset) le iNcon(DSBS)),ord(nSet))
                 /
                 (
                  (
                   Prod(nSet$(ord(nSet) le iNcon(DSBS)-(ord(rCon)-1)),ord(nSet))$(ord(rCon) lt iNcon(DSBS)+1)
                       +1$(ord(rCon) eq iNcon(DSBS)+1)
                   )
                   *
                   (
                      Prod(nSet$(ord(nSet) le ord(rCon)-1),ord(nSet))$(ord(rCon) ne 1)+1$(ord(rCon) eq 1))
                 )
                 *
                 Power(log(iAnnCons(runCy,DSBS,"modal")/iAnnCons(runCy,DSBS,"smallest")),ord(rCon)-1)
                 *
                 Power(log(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"modal")),iNcon(DSBS)-(ord(rCon)-1))
                 /
                (Power(log(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest")),iNcon(DSBS)) )
                *
                iAnnCons(runCy,DSBS,"smallest")*(iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
;
     ENDLOOP;
ENDLOOP;

iCumDistrFuncConsSize(runCy,DSBS) = sum(rCon, iDisFunConSize(runCy,DSBS,rCon));
iCGI(allCy,YTIME) = 1;

$ontext
table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
iResMargTotAvailCap(runCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(runCy,PGRES,YTIME);
$offtext

table iVarCost(PGALL,YTIME)             "Variable gross cost other than fuel per Plant Type (US$2015/MWh)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;

table iFixOandMCost(PGALL,YTIME)    "Fixed O&M Gross Cost per Plant Type (US$2015/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;

table iAvailRate(PGALL,YTIME)	    "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
table iDataElecProd(allCy,PGALL,YTIME) "Electricity production past years (GWh)"
$ondelim
$include"./iDataElecProd.csv"
$offdelim
;

table iDataDistrLosses(allCy,EF,YTIME)	    "Data for Distribution Losses (Mtoe)"
$ondelim
$include"./iDataDistrLosses.csv"
$offdelim
;
$ontext
table iDataOtherTransfOutput(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataOtherTransfOutput.csv"
$offdelim
;
iTranfOutGasworks(runCy,EFS,YTIME)$(not An(YTIME)) = iDataOtherTransfOutput(runCy,EFS,YTIME);
$offtext

iDistrLosses(runCy,EFS,YTIME) = iDataDistrLosses(runCy,EFS,YTIME);
table iDataTransfOutputRef(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
table iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)	 "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelConsTRANSE.csv"
$offdelim
;
iTransfOutputRef(runCy,EFS,YTIME)$(not An(YTIME)) = iDataTransfOutputRef(runCy,EFS,YTIME);
iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME) = iFuelConsTRANSE(runCy,TRANSE,EF,YTIME);
table iFuelConsINDSE(allCy,INDSE,EF,YTIME)	 "Fuel consumption of industry subsector (Mtoe)"
$ondelim
$include"./iFuelConsINDSE.csv"
$offdelim
;
iFuelConsINDSE(runCy,INDSE,EF,YTIME)$(SECTTECH(INDSE,EF) $(iFuelConsINDSE(runCy,INDSE,EF,YTIME)<=0)) = 1e-6;
table iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)	 "Fuel consumption of domestic subsector (Mtoe)"
$ondelim
$include"./iFuelConsDOMSE.csv"
$offdelim
;
iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)$(SECTTECH(DOMSE,EF) $(iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)<=0)) = 1e-6;
table iFuelConsNENSE(allCy,NENSE,EF,YTIME)	 "Fuel consumption of non energy and bunkers (Mtoe)"
$ondelim
$include"./iFuelConsNENSE.csv"
$offdelim
;

iFuelConsNENSE(runCy,NENSE,EF,YTIME)$(SECTTECH(NENSE,EF) $(iFuelConsNENSE(runCy,NENSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(runCy,INDSE,EF,YTIME) = iFuelConsINDSE(runCy,INDSE,EF,YTIME);
iFuelConsPerFueSub(runCy,DOMSE,EF,YTIME) = iFuelConsDOMSE(runCy,DOMSE,EF,YTIME);
iFuelConsPerFueSub(runCy,NENSE,EF,YTIME) = iFuelConsNENSE(runCy,NENSE,EF,YTIME);
iFinEneCons(runCy,EFS,YTIME) = sum(INDDOM,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF)), iFuelConsPerFueSub(runCy,INDDOM,EF,YTIME)))
                       +
                       sum(TRANSE,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF) $(not plugin(EF)) ), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME)));

table iGrossCapCosSubRen(PGALL,YTIME)             "Gross Capital Cost per Plant Type with subsidy for renewables (kUS$2015/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
iGrossCapCosSubRen(PGALL,YTIME) = iGrossCapCosSubRen(PGALL,YTIME)/1000;
loop(PGALL,YTIME)$AN(YTIME) DO
         abort $(iGrossCapCosSubRen(PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", iGrossCapCosSubRen
ENDLOOP;

*VCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*VCapElecTotEst.L(runCy,TT) = iResMargTotAvailCap(runCy,"TOT_CAP_RES",TT) * VCapElecTotEst.L(runCy,TT-1)
*        * VPeakLoad.L(runCy,TT)/VPeakLoad.L(runCy,TT-1);
table iDataElecSteamGen(allCy,PGOTH,YTIME)	          "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
iTotAvailCapBsYr(runCy) = sum(tfirst,iDataElecSteamGen(runCy,"TOTCAP",TFIRST))+sum(tfirst,iDataElecSteamGen(runCy,"CHP_CAP",TFIRST))*0.85;
iElecImp(runCy,YTIME)=0;

parameter iScaleEndogScrap(PGALL) "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
iScaleEndogScrap(PGALL) = 0.035;

table iDecomPlants(allCy,PGALL,YTIME)	            "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;

iPlantDecomSched(runCy,PGALL,YTIME) = iDecomPlants(runCy,PGALL,YTIME);

table iInvPlants(allCy,PGALL,YTIME)	            "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
iDecInvPlantSched(runCy,PGALL,YTIME) = iInvPlants(runCy,PGALL,YTIME);

table iCummMxmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative maximum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMaxResPot.csv"
$offdelim
;
iCummMxmInstRenCap(runCy,PGRENEF,YTIME)$(not iCummMxmInstRenCap(runCy,PGRENEF,YTIME)) = 1e-4;
iMaxRenPotential(runCy,"LHYD",YTIME) = iCummMxmInstRenCap(runCy,"LHYD",YTIME);
iMaxRenPotential(runCy,"SHYD",YTIME) = iCummMxmInstRenCap(runCy,"SHYD",YTIME);
iMaxRenPotential(runCy,"WND",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"WND",YTIME);
iMaxRenPotential(runCy,"WNO",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"WNO",YTIME);
iMaxRenPotential(runCy,"SOL",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"SOL",YTIME);
iMaxRenPotential(runCy,"DPV",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"DPV",YTIME);
iMaxRenPotential(runCy,"BMSWAS",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"BMSWAS",YTIME);
iMaxRenPotential(runCy,"OTHREN",YTIME)$AN(YTIME) = iCummMxmInstRenCap(runCy,"OTHREN",YTIME);
table iCummMnmInstRenCap(allCy,PGRENEF,YTIME)	 "Cummulative minimum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMinResPot.csv"
$offdelim
;
iCummMnmInstRenCap(runCy,PGRENEF,YTIME)$(not iCummMnmInstRenCap(runCy,PGRENEF,YTIME)) = 1e-4;
iMinRenPotential(runCy,"LHYD",YTIME) = iCummMnmInstRenCap(runCy,"LHYD",YTIME);
iMinRenPotential(runCy,"SHYD",YTIME) = iCummMnmInstRenCap(runCy,"SHYD",YTIME);
iMinRenPotential(runCy,"WND",YTIME)  = iCummMnmInstRenCap(runCy,"WND",YTIME);
iMinRenPotential(runCy,"WNO",YTIME)  = iCummMnmInstRenCap(runCy,"WNO",YTIME);
iMinRenPotential(runCy,"SOL",YTIME)  = iCummMnmInstRenCap(runCy,"SOL",YTIME);
iMinRenPotential(runCy,"DPV",YTIME)  = iCummMnmInstRenCap(runCy,"DPV",YTIME);
iMinRenPotential(runCy,"BMSWAS",YTIME) = iCummMnmInstRenCap(runCy,"BMSWAS",YTIME);
iMinRenPotential(runCy,"OTHREN",YTIME) = iCummMnmInstRenCap(runCy,"OTHREN",YTIME);

table iMatFacPlaAvailCap(allCy,PGALL,YTIME)	 "Maturity factor related to plant available capacity (1)"
$ondelim
$include"./iMatFacPlaAvailCap.csv"
$offdelim
;

iMatFacPlaAvailCap(runCy,CCS,YTIME)$an(YTIME)  =0;
parameter
iDataMatureFacPlaDisp(PGALL) /
*CTHLGN	20.00000,
*CTHHCL	20.00000,
*CTHRFO	20.00000,
*CTHNGS	20.00000,
CTHBMSWAS	20.00000,
ATHLGN	20.00000,
ATHHCL	20.00000,
ATHRFO	60.00000,
ATHNGS	40.00000,
ATHBMSWAS	20.00000,
SUPCRL	20.00000,
SUPCR	20.00000,
FBCLGN	20.00000,
FBCHCL	20.00000,
IGCCLGN	20.00000,
IGCCHCL	20.00000,
IGCCBMS	20.00000,
CCCGT	40.00000,
*ACCHT	0.00000010,
ACCGT	50.00000,
*CGTGDO	20.00000,
*CGTNGS	20.00000,
AGTGDO	40.00000,
AGTNGS	40.00000,
*ICEH2	20.00000,
*FC1	20.00000,
*FC2	20.00000,
*PGNUC	1.00000000,
PGLHYD	0.20000,
PGSHYD	0.00100,
PGWND	0.60000,
PGSOL	0.00050,
*PGOTHREN	0.00000,
PGASHYD	0.00050,
PGAWND	0.60000,
PGASOL	0.00050,
PGADPV	0.00010,
PGAOTHREN	0.0000001,
PGANUC	1.00000,
PGAPSS	20.00000,
PGAPSSL	20.00000,
PGACGSL	20.00000,
PGACGS	20.00000,
PGAGGS	20.00000,
PGAWNO	0.60000000/;
iMatureFacPlaDisp(runCy,PGALL,YTIME)$an(YTIME) = iDataMatureFacPlaDisp(PGALL);

iCO2CaptRate(runCy,PGALL,YTIME) = 0; 

parameter iMxmShareChpElec "Maximum share of CHP electricity in a country (1)";
iMxmShareChpElec(runCy,YTIME) = 0.1;

iEffValueInDollars(runCy,SBS,YTIME)=0;
iScenarioPri(WEF,"NOTRADE",YTIME)=0;

* FIXME: Check if VAT (value added tax) rates are necessary for the model.
iVAT(runCy, YTIME) = 0;

* FIXME: Check if iPriceReform is necessary for the model.
* author=derevirn
$ontext
table iDataPriceReform(allCy,AGSECT,EF,YTIME)	 "Price reform (1)"
$ondelim
$include"./iDataPriceReform.csv"
$offdelim
;
* INSERT MECHANSIM FOR PRICE REFORM!!
iPriceReform(runCy,INDSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
iPriceReform(runCy,DOMSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"DOMSE1",EF,YTIME) ;
iPriceReform(runCy,NENSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"NENSE1",EF,YTIME) ;
iPriceReform(runCy,TRANS1(SBS),EF,YTIME)=iDataPriceReform(runCy,"TRANS1",EF,YTIME) ;
iPriceReform(runCy,"PG",EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
$offtext

* FIXME: iHydrogenPri should be computed with mrprom
* author=giannou
iHydrogenPri(runCy,SBS,YTIME)=4.3;
table iFuelPrice(allCy,SBS,EF,YTIME)	 "Prices of fuels per subsector (k$2015/toe)"
$ondelim
$include"./iFuelPrice.csv"
$offdelim
;
iFuelPrice(runCy,SBS,EF,YTIME) = iFuelPrice(runCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
table iDataGrossInlCons(allCy,EF,YTIME)	 "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
table iDataConsEneBranch(allCy,EF,YTIME)	 "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataConsEneBranch.csv"
$offdelim
;
iTotEneBranchCons(runCy,EFS,YTIME) = iDataConsEneBranch(runCy,EFS,YTIME);
table iDataImports(allCy,EF,YTIME)	           "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
iFuelImports(runCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(runCy,EFS,YTIME);

iNetImp(runCy,EFS,YTIME) = iDataImports(runCy,"ELC",YTIME)-iSuppExports(runCy,"ELC",YTIME);

iGrosInlCons(runCy,EFS,YTIME) = iDataGrossInlCons(runCy,EFS,YTIME);
iGrossInConsNoEneBra(runCy,EFS,YTIME) = iGrosInlCons(runCy,EFS,YTIME) + iTotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
                                               - iTotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));

iPeakBsLoadBy(runCy,PGLOADTYPE) = sum(tfirst, iDataElecSteamGen(runCy,PGLOADTYPE,tfirst));

parameter iDataElecAndSteamGen(allCy,CHP,YTIME)	 "Data releated to electricity and steam generation";
iDataElecAndSteamGen(runCy,CHP,YTIME) = 0 ;
iHisChpGrCapData(runCy,CHP,YTIME) = iDataElecAndSteamGen(runCy,CHP,YTIME);

table iDataTotTransfInputRef(allCy,EF,YTIME)	 "Total Transformation Input in Refineries (Mtoe)"
$ondelim
$include"./iDataTotTransfInputRef.csv"
$offdelim
;
iTransfInputRef(runCy,EFS,YTIME)$(not An(YTIME)) = iDataTotTransfInputRef(runCy,EFS,YTIME);

* Calculation of weights for sector average fuel price
iResElecIndex(runCy,YTIME) = 1;

loop SBS do
         iDiffFuelsInSec(SBS) = 0;
         loop EF$(SECTTECH(SBS,EF) $(not plugin(EF)))  do
              iDiffFuelsInSec(SBS) = iDiffFuelsInSec(SBS)+1;
         endloop;
endloop;

iTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME) = sum(EF$(SECTTECH(TRANSE,EF) $(not plugin(EF))), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$(SECTTECH(INDSE,EF)),iFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$(SECTTECH(DOMSE,EF)),iFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$(SECTTECH(NENSE,EF)),iFuelConsPerFueSub(runCy,NENSE,EF,YTIME));


iWgtSecAvgPriFueCons(runCy,TRANSE,EF)$(SECTTECH(TRANSE,EF) $(not plugin(EF)) ) = (iFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/iDiffFuelsInSec(TRANSE))$(not iTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));

iWgtSecAvgPriFueCons(runCy,NENSE,EF)$SECTTECH(NENSE,EF) = ( iFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/iDiffFuelsInSec(NENSE))$(not iTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));


iWgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECTTECH(INDDOM,EF)$(not sameas(EF,"ELC"))) = ( iFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") / (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) )$( iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%") )
                                                                        + (1/(iDiffFuelsInSec(INDDOM)-1))$(not (iTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - iFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")));



* Rescaling the weights
iWgtSecAvgPriFueCons(runCy,SBS,EF)$(SECTTECH(SBS,EF) $sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2))) = iWgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECTTECH(SBS,EF),iWgtSecAvgPriFueCons(runCy,SBS,EF2));

* FIXME: Check if iResNonSubsElecDem, iResFuelConsPerSubAndFuel and iResTranspFuelConsSubTech are necessary for the model.
* author=derevirn

$ontext
table iResNonSubElec(allCy,INDSE,YTIME)	 "Residuals for non subsitutable electricity (1)"
$ondelim
$include"./iResNonSubElec.csv"
$offdelim
;
table iResNonSubElecCons(allCy,DOMSE,YTIME)	 "Residuals in Non Substitutable Electricity Consumption per substector (1)"
$ondelim
$include"./iResNonSubElecCons.csv"
$offdelim
;
iResNonSubsElecDem(runCy,INDSE,YTIME)$an(YTIME) = iResNonSubElec(runCy,INDSE,YTIME);
iResNonSubsElecDem(runCy,DOMSE,YTIME)$an(YTIME) = iResNonSubElecCons(runCy,DOMSE,YTIME);

table iResFuelConsSub(allCy,INDSE,EF,YTIME)	 "Residuals for fuel consumption per subsector (1)"
$ondelim
$include"./iResFuelConsSub.csv"
$offdelim
;
table iResFuelConsPerFuelAndSub(allCy,DOMSE,EF,YTIME)	 "Residuals in fuel consumption per fuel and subsector (1)"
$ondelim
$include"./iResFuelConsPerFuelAndSub.csv"
$offdelim
;
table iResInFuelConsPerFuelAndSub(allCy,NENSE,EF,YTIME)	 "Residuals in fuel consumption per fuel and subsector (1)"
$ondelim
$include"./iResInFuelConsPerFuelAndSub.csv"
$offdelim
;
iResFuelConsPerSubAndFuel(runCy,INDSE,EF,YTIME)$an(YTIME) = iResFuelConsSub(runCy,INDSE,EF,YTIME);
iResFuelConsPerSubAndFuel(runCy,DOMSE,EF,YTIME)$an(YTIME) = iResFuelConsPerFuelAndSub(runCy,DOMSE,EF,YTIME);
iResFuelConsPerSubAndFuel(runCy,NENSE,EF,YTIME)$an(YTIME) = iResInFuelConsPerFuelAndSub(runCy,NENSE,EF,YTIME);

table iResTranspFuelConsSubTech(allCy,TRANSE,EF,YTIME)	 "Residual Transport on Specific Fuel Consumption per Subsector and Technology (1)"
$ondelim
$include"./iResTranspFuelConsSubTech.csv"
$offdelim
;
$offtext

parameter iPlugHybrFractData(YTIME)  "Plug in hybrid fraction of mileage" /
2010    0.5
2011    0.504444
2012    0.508889
2013    0.513333
2014    0.517778
2015    0.522222
2016    0.526667
2017    0.531111
2018    0.535556
2019    0.54
2020    0.544444
2021    0.548889
2022    0.553333
2023    0.557778
2024    0.562222
2025    0.566667
2026    0.571111
2027    0.575556
2028    0.58
2029    0.584444
2030    0.588889
2031    0.593333
2032    0.597778
2033    0.602222
2034    0.606667
2035    0.611111
2036    0.615556
2037    0.62
2038    0.624444
2039    0.628889
2040    0.633333
2041    0.637778
2042    0.642222
2043    0.646667
2044    0.651111
2045    0.655556
2046    0.66
2047    0.664444
2048    0.668889
2049    0.673333
2050    0.677778
2051    0.682222
2052    0.686667
2053    0.691111
2054    0.695556
2055    0.7
2056    0.688889
2057    0.690741
2058    0.69216
2059    0.693076
2060    0.693404
2061    0.693045
2062    0.691886
2063    0.692385
2064    0.692659
2065    0.692743
2066    0.692687
2067    0.692567
2068    0.692488
2069    0.692588
2070    0.692622
2071    0.692616
2072    0.692595
2073    0.692579
2074    0.692581
2075    0.692597
2076    0.692598
2077    0.692594
2078    0.692591
2079    0.69259
2080    0.692592
2081    0.692594
2082    0.692593
2083    0.692592
2084    0.692592
2085    0.692592
2086    0.692593
2087    0.692593
2088    0.692593
2089    0.692593
2090    0.692593
2091    0.692593
2092    0.692593
2093    0.692593
2094    0.692593
2095    0.692593
2096    0.692593
2097    0.692593
2098    0.692593
2099    0.692593
2100    0.692593
/;

parameter iPlugHybrFractOfMileage(ELSH_SET,YTIME)	 "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)" ;
iPlugHybrFractOfMileage(ELSH_SET,YTIME) = iPlugHybrFractData(YTIME);

iShareAnnMilePlugInHybrid(runCy,YTIME)$an(YTIME) = iPlugHybrFractOfMileage("ELSH",YTIME);
table iCapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
     Cap  LF
PC   2    
*PB  40   0.4
PT   300  0.4
*PN  300  0.5
PA   180  0.65
GU   5    0.7
GT   600  0.8
GN   1500 0.9 
;
table iNewReg(allCy,YTIME) "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;

iUtilRateChpPlants(runCy,CHP,YTIME) = 0.5;

**                   Power Generation
table iInstCapPast(allCy,PGALL,YTIME)        "Installed capacity past (GW)"
$ondelim
$include"./iInstCapPast.csv"
$offdelim
;
display iInstCapPast;
table iEnvPolicies(allCy,POLICIES_SET,YTIME) "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;

parameter iCarbonPricesREMIND(YTIME) "Exogenous Carbon Prices from REMIND-MagPIE 3.2-4.6, Scenario 1.5C Default" /
2010	2.420452997154
2011	2.3689024109412
2012	2.3173518247284
2013	2.2658012385156
2014	2.2142506523028
2015	2.16270006609
2016	4.352072517448
2017	6.541444968806
2018	8.730817420164
2019	10.920189871522
2020	13.10956232288
2021	33.6084313513832
2022	54.1073003798864
2023	74.6061694083896
2024	95.1050384368928
2025	115.603907465396
2026	123.311633081363
2027	131.01935869733
2028	138.727084313296
2029	146.434809929263
2030	154.14253554523
2031	161.85118632349
2032	169.55983710175
2033	177.26848788001
2034	184.97713865827
2035	192.68578943653
2036	200.392161726539
2037	208.098534016548
2038	215.804906306556
2039	223.511278596565
2040	231.217650886574
2041	238.924843790375
2042	246.632036694176
2043	254.339229597976
2044	262.046422501777
2045	269.753615405578
2046	277.460443574906
2047	285.167271744235
2048	292.874099913563
2049	300.580928082892
2050	308.28775625222
2051	315.994945345395
2052	323.70213443857
2053	331.409323531746
2054	339.116512624921
2055	346.823701718096
2056	354.531215600639
2057	362.238729483182
2058	369.946243365726
2059	377.653757248269
2060	385.361271130812
2061	388.684842494863
2062	392.008413858913
2063	395.331985222964
2064	398.655556587014
2065	401.979127951065
2066	405.302699315116
2067	408.626270679166
2068	411.949842043217
2069	415.273413407267
2070	418.596984771318
2071	421.920469521178
2072	425.243954271038
2073	428.567439020898
2074	431.890923770758
2075	435.214408520618
2076	438.537893270478
2077	441.861378020338
2078	445.184862770198
2079	448.508347520058
2080	451.831832269918
2081	455.155479480926
2082	458.479126691935
2083	461.802773902943
2084	465.126421113952
2085	468.45006832496
2086	471.773715535968
2087	475.097362746977
2088	478.421009957985
2089	481.744657168994
2090	485.068304380002
2091	488.392824822452
2092	491.717345264903
2093	495.041865707353
2094	498.366386149804
2095	501.690906592254
2096	505.015427034704
2097	508.339947477155
2098	511.664467919605
2099	514.988988362056
2100	518.313508804506
/;

* iCarbValYrExog(allCy,YTIME)$an(YTIME) = iCarbonPricesREMIND(YTIME); !! Testing the exogenous carbon prices from REMIND

* Setting the exogenous carbon price values based on the selected model scenario
if %fScenario% eq 0 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_NPi",YTIME);

elseif %fScenario% eq 1 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_1_5C",YTIME);

elseif %fScenario% eq 2 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_2C",YTIME);

endif;


table iMatrFactorData(SBS,EF,YTIME)       "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactorData.csv"
$offdelim
;

parameter iMatrFactor(allCy,SBS,EF,YTIME)       "Maturity factor per technology and subsector for all countries (1)";
iMatrFactor(runCy,SBS,EF,YTIME) = iMatrFactorData(SBS,EF,YTIME);                                          
iMatrFactor(runCy,SBS,EF,YTIME)$(iMatrFactor(runCy,SBS,EF,YTIME)=0) = 0.000001;
** Industry
iShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndChar(runCy,INDSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(runCy,INDSE)$(iShrNonSubElecInTotElecDem(runCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
iShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(runCy,DOMSE)$(iShrNonSubElecInTotElecDem(runCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic


**  Transport Sector
iCapCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"IC",YTIME);
iFixOMCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"FC",YTIME);
iVarCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"VC",YTIME);
iTechLft(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"LFT",YTIME);
iAvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = iCapDataLoadFacEachTransp(TRANSE,TRANSUSE);

**  Industrial Sector
iCapCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"IC");
iFixOMCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"FC");
iVarCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"VC");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)  = iDataIndTechnology(INDSE,EF,"USC");
iTechLft(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"LFT");

**  Domestic Sector
iFixOMCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"FC");
iVarCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"VC");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"USC");
iTechLft(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"LFT");

**  Non Energy Sector and Bunkers
iFixOMCostTech(runCy,NENSE,EF,YTIME)= iDataNonEneSec(NENSE,EF,"FC");
iVarCostTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"VC");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"USC");
iTechLft(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"LFT");

**  Power Generation
table iDataTechLftPlaType(PGALL, PGECONCHAR) "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
iTechLftPlaType(runCy,PGALL) = iDataTechLftPlaType(PGALL, "LFT");

iEffDHPlants(runCy,EFS,YTIME)$(ord(YTIME)>(ordfirst-8))  = sum(PGEFS$sameas(EFS,PGEFS),iParDHEfficiency(PGEFS,"2010"));


table iDataPlantEffByType(PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;

iPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(PGALL, YTIME) ;

** CHP economic and technical data initialisation for electricity production
table iDataChpPowGen(EF,YTIME,CHPPGSET)   "Data for power generation costs (various)"
               IC      FC      LFT VOM     AVAIL BOILEFF
STE1AL.2010    2.75    58.4621 35  5.19746 0.85  0.699301
STE1AL.2020    2.75    52.9702     5.01869       0.699301
STE1AL.2050    2.75    48.5081     3.3689        0.699301
STE1AH.2010    2.2814  50.609  35  4.4306  0.85  0.746269
STE1AH.2020    2.2814  43.5126     4.2842        0.746269
STE1AH.2050    2.2814  37.7468     4.08204       0.746269
STE1AD.2010    1.276   20.01   15  2.67042 0.29  0.813008
STE1AD.2020    1.276   20.01       2.67042       0.813008
STE1AD.2050    1.276   20.01       2.67042       0.813008
STE1AR.2010    1.782   27.945  30  3.72938 0.8   0.78125
STE1AR.2020    1.782   27.945      3.72938       0.78125
STE1AR.2050    1.782   27.945      3.72938       0.78125
STE1AG.2010    1.16358 19.35   25  2.56461 0.8   0.819672
STE1AG.2020    1.09263 19.35       2.44861       0.819672
STE1AG.2050    1.06425 19.35       2.23212       0.819672
STE1AB.2010    3.2208  57.096  30  6.29638 0.85  0.746269
STE1AB.2020    3.0866  54.717      6.05137       0.746269
STE1AB.2050    2.8853  51.1485     5.61708       0.746269
STE1AH2F.2010  1.16358 19.35   15  2.56461 0.8   0.829672
STE1AH2F.2020  1.09263 19.35       2.44861       0.829672
STE1AH2F.2050  1.06425 19.35       2.23212       0.829672
;

* Converting EUR2005 to US2015
iDataChpPowGen(EF,YTIME,"IC") = iDataChpPowGen(EF,YTIME,"IC") * 1.3;
iDataChpPowGen(EF,YTIME,"FC") = iDataChpPowGen(EF,YTIME,"FC") * 1.3;
iDataChpPowGen(EF,YTIME,"VOM") = iDataChpPowGen(EF,YTIME,"VOM") * 1.3;

iInvCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","IC");
iFixOMCostPerChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","FC");
iVarCostChp(runCy,DSBS,CHP,YTIME) = iDataChpPowGen(CHP,"2010","VOM");
iLifChpPla(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","LFT");
iAvailRateChp(runCy,DSBS,CHP) = iDataChpPowGen(CHP,"2010","AVAIL");
iBoiEffChp(runCy,CHP,YTIME) = iDataChpPowGen(CHP,"2010","BOILEFF");

**  Policies for climate change and renewables


$ontext
**  Energy productivity indices and R&D indices

EN_PRD_INDX(runCy,SBS,YTIME)$an(YTIME)=EN_PRD_INDX_PRN(runCy,SBS,YTIME);
CCRES(PGALL,YTIME)$AN(YTIME)=CCRES_PRN(PGALL,YTIME)  ;
FOMRES(PGALL,YTIME)$AN(YTIME)=FOMRES_PRN(PGALL,YTIME) ;
VOMRES(PGALL,YTIME)$AN(YTIME)=VOMRES_PRN(PGALL,YTIME)  ;
EFFRES(PGALL,YTIME)$AN(YTIME)=EFFRES_PRN(PGALL,YTIME);
NUCRES(YTIME)$an(ytime)=NUCRES_PRN("RES",YTIME);
$offtext
* Update efficiencies according to energy productivity index
***iPlantEffByType(runCy,PGALL,YTIME)$(an(ytime) )= iPlantEffByType(runCy,PGALL,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
***iEffDHPlants(runCy,EF,YTIME)$(an(ytime) )= iEffDHPlants(runCy,EF,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
iElecIndex(runCy,YTIME) = 0.9;
*iRateLossesFinCons(allCy,EFS, YTIME)$(iFinEneCons(allCy,EFS,YTIME)>0 $(not an(ytime))) = iDistrLosses(allCy,EFS,YTIME) / iFinEneCons(allCy,EFS,YTIME);




