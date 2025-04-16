*' @title Core Inputs
*' @code

*---
table iActv(YTIME,allCy,SBS) "Sector activity (various)"
                              !! main sectors (Billion US$2015) 
                              !! bunkers and households (1)
                              !! transport (Gpkm, or Gvehkm or Gtkm)
$ondelim
$include "./iActv.csvr"
$offdelim
;
*---
table iTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == off
table iElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
*---
iElastA(runCy,SBS,ETYPES,YTIME) = iElastA("ELL",SBS,ETYPES,YTIME);
$ELSE.calib
variable iElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)";
table iElastAL(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
iElastA.L(runCy,SBS,ETYPES,YTIME) = iElastAL("ELL",SBS,ETYPES,YTIME);
iElastA.LO(runCy,SBS,"a",YTIME) = 0.001;
iElastA.UP(runCy,SBS,"a",YTIME) = 5*iElastAL("ELL",SBS,"a",YTIME);
iElastA.LO(runCy,SBS,"b1",YTIME) = -10;
iElastA.UP(runCy,SBS,"b1",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"b2",YTIME) = -10;
iElastA.UP(runCy,SBS,"b2",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c",YTIME) = -10;
iElastA.UP(runCy,SBS,"c",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"b3",YTIME) = -10;
iElastA.UP(runCy,SBS,"b3",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"b4",YTIME) = -10;
iElastA.UP(runCy,SBS,"b4",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c1",YTIME) = -10;
iElastA.UP(runCy,SBS,"c1",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c2",YTIME) = -10;
iElastA.UP(runCy,SBS,"c2",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c3",YTIME) = -10;
iElastA.UP(runCy,SBS,"c3",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c4",YTIME) = -10;
iElastA.UP(runCy,SBS,"c4",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c4",YTIME) = -10;
iElastA.UP(runCy,SBS,"c4",YTIME) = -0.001;
iElastA.LO(runCy,SBS,"c5",YTIME) = -10;
iElastA.UP(runCy,SBS,"c5",YTIME) = -0.001;
$ENDIF.calib
*---
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
*---
parameter iDisc(allCy,SBS,YTIME) "Discount rates per subsector for all countries ()" ;
*---
iDisc(runCy,SBS,YTIME) = iDiscData(SBS);
*---
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
*---
iCo2EmiFac(runCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
iCo2EmiFac(runCy,"IS","HCL",YTIME)   = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
*---
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
*---
parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)" /smallest 0.425506805,
                                                                                             modal    0.595709528,
                                                                                             largest 0.833993339/;
*---
table iRateLossesFinCons(allCy,EF,YTIME)               "Rate of losses over Available for Final Consumption (1)"
$ondelim
$include "./iRateLossesFinCons.csv"
$offdelim
;
*---
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
*---
$ontext
table iSuppTransfInputPatFuel(EF,YTIME)            "Supplementary Parameter for the transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
$ondelim
$include "./iSuppTransfInputPatFuel.csv"
$offdelim
; 
$offtext
*---
table iPriceFuelsIntBase(WEF,YTIME)	           "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iPriceFuelsIntBase.csv"
$offdelim
;
*---
table iSuppExports(allCy,EF,YTIME)	                 "Supplementary parameter for  exports (Mtoe)"		
$ondelim
$include"./iSuppExports.csv"
$offdelim
;
*---
parameter iImpExp(allCy,EFS,YTIME)	                 "Imports of exporting countries usually zero (1)" ;
iImpExp(runCy,EFS,YTIME)	= 0;
*---
*Sources for vehicle lifetime:
*US Department of Transportation, International Union of Railways, Statista, EU CORDIS
table iDataTransTech (TRANSE, EF, ECONCHAR, YTIME) "Technoeconomic characteristics of transport (various)"
$ondelim
$include"./iDataTransTech.csv"
$offdelim
;
*---
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
IS.H2F      1.04547 40.4451 17.68   25  5.74713
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
NF.H2F      4.94477 119.819 41.1163 30  1.848
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
CH.H2F      3.13528 94.0585 41.1163 25  1.848
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
BM.H2F      5.66602 94.0585 41.1163 30  1.848
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
PP.H2F      2.43133 68.3668 41.1163 25  1.68
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
FD.H2F      2.43133 68.3668 41.1163 25  1.68
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
EN.H2F      2.43133 68.3668 41.1163 25  1.68
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
TX.H2F      2.43133 68.3668 41.1163 25  1.68
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
OE.H2F      2.43133 68.3668 41.1163 25  1.68
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
OI.H2F      2.43133 68.3668 41.1163 25  1.68
;
*---
* Coverting EUR05 to US2015
iDataIndTechnology(INDSE,EF,"IC") = iDataIndTechnology(INDSE,EF,"IC") * 1.3;
iDataIndTechnology(INDSE,EF,"FC") = iDataIndTechnology(INDSE,EF,"FC") * 1.3;
iDataIndTechnology(INDSE,EF,"VC") = iDataIndTechnology(INDSE,EF,"VC") * 1.3;
*---
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
*---
* Coverting EUR05 to US2015
iDataDomTech(DOMSE,EF,"IC") = iDataDomTech(DOMSE,EF,"IC") * 1.3;
iDataDomTech(DOMSE,EF,"FC") = iDataDomTech(DOMSE,EF,"FC") * 1.3;
iDataDomTech(DOMSE,EF,"VC") = iDataDomTech(DOMSE,EF,"VC") * 1.3;
*---
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
*---
* Converting EUR05 to US2015
iDataNonEneSec(NENSE,EF,"IC") = iDataNonEneSec(NENSE,EF,"IC") * 1.3;
iDataNonEneSec(NENSE,EF,"FC") = iDataNonEneSec(NENSE,EF,"FC") * 1.3;
iDataNonEneSec(NENSE,EF,"VC") = iDataNonEneSec(NENSE,EF,"VC") * 1.3;
*---
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
*---
iIndChar(runCy,INDSE,Indu_Scon_Set) = iIndCharData("ELL",INDSE,Indu_Scon_Set);
*---
table iInitConsSubAndInitShaNonSubElec(DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
     BASE   SHR_NSE SH_HPELC
SE   1.8266 0.9     0.00001
HOU  11.511 0.9     0.00001
AG   0.2078 0.9     0.00001
;
*---
iShrHeatPumpElecCons(runCy,INDSE) = iIndChar(runCy,INDSE,"SH_HPELC");
iShrHeatPumpElecCons(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SH_HPELC");
*---
iFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
*iTransfInpGasworks(runCy,EFS,YTIME)= iSuppTransfInputPatFuel(EFS,YTIME);
*---
*Calculation of consumer size groups and their distribution function
iNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10; !! 11 different consumer size groups for cars and trucks
iNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
iNcon(INDSE) = 10; !! 11 different consumer size groups for industrial sectors
iNcon(DOMSE) = 10; !! 11 different consumer size groups for domestic and tertiary sectors
iNcon(NENSE) = 10; !! 11 different consumer size groups for non energy uses
iNcon("BU") = 2;   !! ... except bunkers .
*---
* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel
*---
iAnnCons(runCy,'PC','smallest')= 0.5 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'modal')=0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
iAnnCons(runCy,'PC' ,'largest')= 4 * 0.952 * iTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
*---
* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel
*---
iAnnCons(runCy,'GU','smallest')=0.5 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%")* 1000 * 2 / 3  * 1E-6;
iAnnCons(runCy,'GU','modal')=0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2  * 1E-6;
iAnnCons(runCy,'GU','largest')=4 * 0.706 * iTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2 * 10  * 1E-6;
*---
iAnnCons(runCy,'PA','smallest')=40000 * 50 * 1E-6;
iAnnCons(runCy,'PA','modal')=400000 * 100 * 1E-6;
iAnnCons(runCy,'PA','largest')=800000 * 300 * 1E-6;
*---
* Size will not play a role in buses, trains, ships and aircraft
* Following values are given only for the sake of uniformity, but iDisFunConSize is not really calculated for non-road transport!
*iAnnConsPB(runCy,'PB',"smallest") = 20000 * 5 * 1E-6;
*iAnnConsPB(runCy,'PB',"modal") = 50000* 15 * 1E-6;
*iAnnConsPB(runCy,'PB',"largest") = 200000 * 50 * 1E-6;
*---
iAnnCons(runCy,'PT',"smallest") = 50000 * 50 * 1E-6;
iAnnCons(runCy,'PT',"modal") = 200000 * 150 * 1e-6;
iAnnCons(runCy,'PT',"largest") = 400000 * 500 * 1E-6;
*---
iAnnCons(runCy,'GT',"smallest") = 50000 * 20 * 1E-6;
iAnnCons(runCy,'GT',"modal") = 200000 * 200 * 1e-6;
iAnnCons(runCy,'GT',"largest") = 400000 * 500 * 1E-6;
*---
*iAnnConsPN(runCy,'PN',"smallest") = 10000 * 50 * 1E-6;
*iAnnConsPN(runCy,'PN',"modal") = 50000 * 100 * 1e-6;
*iAnnConsPN(runCy,'PN',"largest") = 100000 * 500 * 1E-6;
*---
iAnnCons(runCy,'GN',"smallest") = 10000 * 20 * 1E-6;
iAnnCons(runCy,'GN',"modal") = 50000 * 300 * 1e-6;
iAnnCons(runCy,'GN',"largest") = 100000 * 1000 * 1E-6;
iAnnCons(runCy,INDSE,"smallest") = 0.2  ;
iAnnCons(runCy,INDSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.6 for iron & steel and 0.5 for other industry (see iterations in Excel):
iAnnCons(runCy,"IS","modal") = 0.587;
iAnnCons(runCy,INDSE,"modal")$(not sameas(INDSE,"IS")) = 0.487;
*---
iAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat("smallest")  ;
iAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat("largest") ;
iAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat("modal");
*---
iAnnCons(runCy,NENSE,"smallest") = 0.2  ;
iAnnCons(runCy,NENSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.5 for non-energy uses:
iAnnCons(runCy,NENSE,"modal") = 0.487 ;
*---
iAnnCons(runCy,"BU","smallest") = 0.2 ;
iAnnCons(runCy,"BU","largest") = 1 ;
iAnnCons(runCy,"BU","modal") = 0.5 ;
*---
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
*---
iCumDistrFuncConsSize(runCy,DSBS) = sum(rCon, iDisFunConSize(runCy,DSBS,rCon));
iCGI(allCy,YTIME) = 1;
*---
$ontext
table iResTotCapMxmLoad(allCy,PGRES,YTIME)              "Residuals for total capacity and maximum load (1)"	
$ondelim
$include"./iResTotCapMxmLoad.csv"
$offdelim
;
*---
iResMargTotAvailCap(runCy,PGRES,YTIME)$an(YTIME) = iResTotCapMxmLoad(runCy,PGRES,YTIME);
*---
table iDataOtherTransfOutput(allCy,EF,YTIME)	    "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataOtherTransfOutput.csv"
$offdelim
;
*---
iTranfOutGasworks(runCy,EFS,YTIME)$(not An(YTIME)) = iDataOtherTransfOutput(runCy,EFS,YTIME);
$offtext
*---
table iDataDistrLosses(allCy,EF,YTIME)	    "Data for Distribution Losses (Mtoe)"
$ondelim
$include"./iDataDistrLosses.csv"
$offdelim
;
*---
iDistrLosses(runCy,EFS,YTIME) = iDataDistrLosses(runCy,EFS,YTIME);
*---
table iFuelConsTRANSE(allCy,TRANSE,EF,YTIME)	 "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelConsTRANSE.csv"
$offdelim
;
*---
iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME) = iFuelConsTRANSE(runCy,TRANSE,EF,YTIME);
table iFuelConsINDSE(allCy,INDSE,EF,YTIME)	 "Fuel consumption of industry subsector (Mtoe)"
$ondelim
$include"./iFuelConsINDSE.csv"
$offdelim
;
*---
iFuelConsINDSE(runCy,INDSE,EF,YTIME)$(SECTTECH(INDSE,EF) $(iFuelConsINDSE(runCy,INDSE,EF,YTIME)<=0)) = 1e-6;
*---
table iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)	 "Fuel consumption of domestic subsector (Mtoe)"
$ondelim
$include"./iFuelConsDOMSE.csv"
$offdelim
;
*---
iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)$(SECTTECH(DOMSE,EF) $(iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)<=0)) = 1e-6;
*---
table iFuelConsNENSE(allCy,NENSE,EF,YTIME)	 "Fuel consumption of non energy and bunkers (Mtoe)"
$ondelim
$include"./iFuelConsNENSE.csv"
$offdelim
;
*---
iFuelConsNENSE(runCy,NENSE,EF,YTIME)$(SECTTECH(NENSE,EF) $(iFuelConsNENSE(runCy,NENSE,EF,YTIME)<=0)) = 1e-6;
iFuelConsPerFueSub(runCy,INDSE,EF,YTIME) = iFuelConsINDSE(runCy,INDSE,EF,YTIME);
iFuelConsPerFueSub(runCy,DOMSE,EF,YTIME) = iFuelConsDOMSE(runCy,DOMSE,EF,YTIME);
iFuelConsPerFueSub(runCy,NENSE,EF,YTIME) = iFuelConsNENSE(runCy,NENSE,EF,YTIME);
iFinEneCons(runCy,EFS,YTIME) = sum(INDDOM,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF)), iFuelConsPerFueSub(runCy,INDDOM,EF,YTIME)))
                       +
                       sum(TRANSE,
                         sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF) $(not plugin(EF)) ), iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME)));
*---
iCO2CaptRate(runCy,PGALL,YTIME) = 0; 
iEffValueInDollars(runCy,SBS,YTIME)=0;
iScenarioPri(WEF,"NOTRADE",YTIME)=0;
*---
$ontext
VCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VCapElecTotEst.L(runCy,TT) = iResMargTotAvailCap(runCy,"TOT_CAP_RES",TT) * VCapElecTotEst.L(runCy,TT-1)
        * VPeakLoad.L(runCy,TT)/VPeakLoad.L(runCy,TT-1);
*---
* FIXME: Check if iPriceReform is necessary for the model.
* author=derevirn
table iDataPriceReform(allCy,AGSECT,EF,YTIME)	 "Price reform (1)"
$ondelim
$include"./iDataPriceReform.csv"
$offdelim
;
*---
* INSERT MECHANSIM FOR PRICE REFORM!!
iPriceReform(runCy,INDSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
iPriceReform(runCy,DOMSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"DOMSE1",EF,YTIME) ;
iPriceReform(runCy,NENSE1(SBS),EF,YTIME)=iDataPriceReform(runCy,"NENSE1",EF,YTIME) ;
iPriceReform(runCy,TRANS1(SBS),EF,YTIME)=iDataPriceReform(runCy,"TRANS1",EF,YTIME) ;
iPriceReform(runCy,"PG",EF,YTIME)=iDataPriceReform(runCy,"INDSE1",EF,YTIME) ;
$offtext
*---
table iDataImports(allCy,EF,YTIME)	           "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
*---
iFuelImports(runCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(runCy,EFS,YTIME);
*---
iNetImp(runCy,EFS,YTIME) = iDataImports(runCy,"ELC",YTIME)-iSuppExports(runCy,"ELC",YTIME);
*---
* Calculation of weights for sector average fuel price
iResElecIndex(runCy,YTIME) = 1;
*---
$ontext
* FIXME: Check if iResNonSubsElecDem, iResFuelConsPerSubAndFuel and iResTranspFuelConsSubTech are necessary for the model.
* author=derevirn
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
*---
**                   Power Generation
table iEnvPolicies(allCy,POLICIES_SET,YTIME) "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;
*---
* Setting the exogenous carbon price values based on the selected model scenario
if %fScenario% eq 0 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_NPi",YTIME);
elseif %fScenario% eq 1 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_1_5C",YTIME);

elseif %fScenario% eq 2 then
     iCarbValYrExog(allCy,YTIME)$an(YTIME) = iEnvPolicies(allCy,"exogCV_2C",YTIME);

endif;
*---
table iMatrFactorData(SBS,EF,YTIME)       "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactorData.csv"
$offdelim
;
*---
$IFTHEN.calib %MatFacCalibration% == off
parameter iMatrFactor(allCy,SBS,EF,YTIME)       "Maturity factor per technology and subsector for all countries (1)";
iMatrFactor(runCy,SBS,EF,YTIME) = iMatrFactorData(SBS,EF,YTIME);                                          
iMatrFactor(runCy,SBS,EF,YTIME)$(iMatrFactor(runCy,SBS,EF,YTIME)=0) = 0.000001;
$ELSE.calib
variable iMatrFactor(allCy,SBS,EF,YTIME)       "Maturity factor per technology and subsector for all countries (1)";
iMatrFactor.L(runCy,SBS,EF,YTIME) = iMatrFactorData(SBS,EF,YTIME);                                          
iMatrFactor.L(runCy,SBS,EF,YTIME)$(iMatrFactor.L(runCy,SBS,EF,YTIME)=0) = 0.000001;
iMatrFactor.LO(runCy,SBS,EF,YTIME) = -10;                                          
iMatrFactor.UP(runCy,SBS,EF,YTIME) = 100;
$ENDIF.calib
*---
** Industry
iShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndChar(runCy,INDSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(runCy,INDSE)$(iShrNonSubElecInTotElecDem(runCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
iShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
iShrNonSubElecInTotElecDem(runCy,DOMSE)$(iShrNonSubElecInTotElecDem(runCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic
*---
**  Transport Sector
iCapCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"IC",YTIME);
iFixOMCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"FC",YTIME);
iVarCostTech(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"VC",YTIME);
*---
**  Industrial Sector
iCapCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"IC");
iFixOMCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"FC");
iVarCostTech(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"VC");
iUsfEneConvSubTech(runCy,INDSE,EF,YTIME)  = iDataIndTechnology(INDSE,EF,"USC");
*---
**  Domestic Sector
iFixOMCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"FC");
iVarCostTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"VC");
iUsfEneConvSubTech(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"USC");
*---
**  Non Energy Sector and Bunkers
iFixOMCostTech(runCy,NENSE,EF,YTIME)= iDataNonEneSec(NENSE,EF,"FC");
iVarCostTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"VC");
iUsfEneConvSubTech(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"USC");
*---
**  Power Generation
*---
table iDataPlantEffByType(allCy,PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;
*---
iPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(runCy,PGALL, YTIME) ;
*---
$ontext
**  Policies for climate change and renewables
**  Energy productivity indices and R&D indices
EN_PRD_INDX(runCy,SBS,YTIME)$an(YTIME)=EN_PRD_INDX_PRN(runCy,SBS,YTIME);
CCRES(PGALL,YTIME)$AN(YTIME)=CCRES_PRN(PGALL,YTIME)  ;
FOMRES(PGALL,YTIME)$AN(YTIME)=FOMRES_PRN(PGALL,YTIME) ;
VOMRES(PGALL,YTIME)$AN(YTIME)=VOMRES_PRN(PGALL,YTIME)  ;
EFFRES(PGALL,YTIME)$AN(YTIME)=EFFRES_PRN(PGALL,YTIME);
NUCRES(YTIME)$an(ytime)=NUCRES_PRN("RES",YTIME);
* Update efficiencies according to energy productivity index
iPlantEffByType(runCy,PGALL,YTIME)$(an(ytime) )= iPlantEffByType(runCy,PGALL,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
iEffDHPlants(runCy,EF,YTIME)$(an(ytime) )= iEffDHPlants(runCy,EF,YTIME) / iEneProdRDscenarios(runCy,"pg",ytime);
iRateLossesFinCons(allCy,EFS, YTIME)$(iFinEneCons(allCy,EFS,YTIME)>0 $(not an(ytime))) = iDistrLosses(allCy,EFS,YTIME) / iFinEneCons(allCy,EFS,YTIME);
$offtext
*---