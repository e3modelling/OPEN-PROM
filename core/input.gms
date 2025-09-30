*' @title Core Inputs
*' @code

*---
table imActv(YTIME,allCy,SBS) "Sector activity (various)"
                              !! main sectors (Billion US$2015) 
                              !! bunkers and households (1)
                              !! transport (Gpkm, or Gvehkm or Gtkm)
$ondelim
$include "./iActv.csvr"
$offdelim
;
*---
table imTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == Calibration
variable imElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)";
table imElastAL(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
imElastA.L(runCy, SBS, ETYPES, YTIME) = imElastAL("ELL", SBS, ETYPES, YTIME);
imElastA.LO(runCy, SBS, posElast, YTIME) = 0.001;
imElastA.UP(runCy, SBS, posElast, YTIME) = 5 * imElastAL("ELL", SBS, posElast, YTIME);
imElastA.LO(runCy, SBS, negElast, YTIME) = -10;
imElastA.UP(runCy, SBS, negElast, YTIME) = -0.001;

$ELSE.calib
table imElastA(allCy,SBS,ETYPES,YTIME) "Activity Elasticities per subsector (1)"
$ondelim
$include "./iElastA.csv"
$offdelim
;
imElastA(runCy,SBS,ETYPES,YTIME) = imElastA("ELL",SBS,ETYPES,YTIME);
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
PB      0.12
PT      0.08
PA      0.12
PN      0.12
GU      0.12
GT      0.08
GN      0.12
BU      0.12
NEN     0.08
PG      0.1
H2P     0.08
H2INFR  0.08
DAC     0.08 
/;
*---
parameter imDisc(allCy,SBS,YTIME) "Discount rates per subsector for all countries ()" ;
*---
imDisc(runCy,SBS,YTIME) = iDiscData(SBS);
imDisc(runCy,"PC",YTIME) = 0.11;
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
imCo2EmiFac(runCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
imCo2EmiFac(runCy,"IS","HCL",YTIME) = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
*imCo2EmiFac(runCy,"H2P","NGS",YTIME) = 3.107;
imCo2EmiFac(runCy,SBS,EF,YTIME)$CHP(EF) = SUM(EF2$(CHPtoEF(EF,EF2)),imCo2EmiFac(runCy,SBS,EF2,YTIME));
*imCo2EmiFac(runCy,"H2P","BMSWAS",YTIME) = 0.497;
*---
parameter imElaSubData(DSBS)       "Elasticities by subsector (1)" /
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
parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)"
/
smallest 0.425506805,
modal    0.595709528,
largest  0.833993339
/;
*---
table imRateLossesFinCons(allCy,EF,YTIME)               "Rate of losses over Available for Final Consumption (1)"
$ondelim
$include "./iRateLossesFinCons.csv"
$offdelim
;
*---
table imInstCapPastNonCHP(allCy,PGALL,YTIME)        "Installed Non-CHP capacity past (GW)"
$ondelim
$include"./iInstCapPastNonCHP.csv"
$offdelim
;
*---
table imInstCapPastCHP(allCy,CHP,YTIME)        "Installed CHP capacity past (GW)"
$ondelim
$include"./iInstCapPastCHP.csv"
$offdelim
;
*---
table imFuelPrice(allCy,SBS,EF,YTIME)	 "Prices of fuels per subsector (k$2015/toe)"
$ondelim
$include"./iFuelPrice.csv"
$offdelim
;
*---
table imPriceFuelsIntBase(WEF,YTIME)	              "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iPriceFuelsIntBase.csv"
$offdelim
;
*---
table iSuppExports(allCy,EF,YTIME)	                   "Supplementary parameter for  exports (Mtoe)"		
$ondelim
$include"./iSuppExports.csv"
$offdelim
;
*---
table imPriceFuelsInt(WEF,YTIME)                      "International Fuel Prices ($2015/toe)"
$ondelim
$include"./iPriceFuelsInt.csv"
$offdelim
;
*---
parameter imImpExp(allCy,EFS,YTIME)	              "Imports of exporting countries usually zero (1)" ;
imImpExp(runCy,EFS,YTIME) = 0;
*---
parameter imTotFinEneDemSubBaseYr(allCy,SBS,YTIME)    "Total Final Energy Demand per subsector in Base year (Mtoe)";
*---
*Sources for vehicle lifetime:
*US Department of Transportation, International Union of Railways, Statista, EU CORDIS
table imDataTransTech (TRANSE, TECH, ECONCHAR, YTIME)   "Technoeconomic characteristics of transport (various)"
$ondelim
$include"./iDataTransTech.csv"
$offdelim
;
*---
table imDataIndTechnology(INDSE,TECH,ECONCHAR)          "Technoeconomic characteristics of industry (various)"
            IC      FC      VC      LFT USC
*IS.THCL      0.32196 6.8     1.36    25  2.3255
IS.THCL      0.32196 6.8     1.36    25  0.5
IS.TLGN      0.48295 10.2    2.04    25  0.5
IS.TLPG      0.48295 10.2    2.04    25  0.72
IS.TKRS      0.48295 10.2    2.04    25  0.72
IS.TGDO      0.48295 10.2    2.04    25  0.72
IS.TRFO      0.48295 10.2    2.04    25  0.72
IS.TOLQ      0.48295 10.2    2.04    25  0.72
IS.TNGS      0.48295 10.2    2.04    25  0.8
IS.TOGS      0.48295 10.2    2.04    25  0.8
IS.TBMSWAS   0.48295 10.2    2.04    25  0.5
* IS.TELC      0.29367 6.8     1.36    25  5.74713
IS.TELC      0.29367 6.8     1.36    25  0.97
IS.TSTE1AL   1.04547 17.284  17.68   25  0.35
IS.TSTE1AH   1.04547 17.284  17.68   25  0.35
IS.TSTE1AD   0.78340 23.3335 4.896   25  0.34
IS.TSTE1AR   0.78340 23.3335 4.896   25  0.34
*IS.TSTE1AG   0.50901 12.9631 13.6    20  0.44
IS.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
IS.TSTE1AB   1.00334 28.8752 8.16    25  0.37
IS.TSTE1AH2F 1.34817 40.4451         25  0.5
IS.THEATPUMP 0.92974 19.3882 3.1021  25  1.848
IS.TH2F      1.04547 40.4451 17.68   25  0.97
NF.THCL      3.8528  63.036          30  0.5
NF.TLGN      3.8528  63.036          30  0.5
NF.TLPG      3.21067 63.036          30  0.72
NF.TKRS      3.21067 63.036          30  0.72
NF.TGDO      3.21067 63.036          30  0.72
NF.TRFO      3.21067 63.036          30  0.72
NF.TOLQ      3.21067 63.036          30  0.72
NF.TNGS      2.56853 63.036          30  0.8
NF.TOGS      2.56853 63.036          30  0.8
NF.TBMSWAS   3.8528  63.036          30  0.5
NF.TELC      3.4     63.036          30  0.97
NF.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
NF.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
NF.TSTE1AD   1.82186 54.264  11.386  25  0.34
NF.TSTE1AR   1.82186 54.264  11.386  25  0.34
NF.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
NF.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
NF.TSTE1AH2F 3.13528 94.0585         30  0.5
NF.THEATPUMP 4.94477 119.819         30  1.848
NF.TH2F      4.94477 119.819 41.1163 30  0.97
CH.THCL      0.53294 5.44            25  0.5
CH.TLGN      0.53294 5.44            25  0.5
CH.TLPG      0.44411 5.44            25  0.72
CH.TKRS      0.44411 5.44            25  0.72
CH.TGDO      0.44411 5.44            25  0.72
CH.TRFO      0.44411 5.44            25  0.72
CH.TOLQ      0.44411 5.44            25  0.72
CH.TNGS      0.35529 5.44            25  0.8
CH.TOGS      0.35529 5.44            25  0.8
CH.TBMSWAS   0.53294 5.44            25  0.5
CH.TELC      0.476   5.44            25  0.97
CH.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
CH.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
CH.TSTE1AD   1.82186 54.264  11.386  25  0.34
CH.TSTE1AR   1.82186 54.264  11.386  25  0.34
CH.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
CH.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
CH.TSTE1AH2F 3.13528 94.0585         25  0.5
CH.THEATPUMP 0.68398 10.3404         25  1.848
CH.TH2F      3.13528 94.0585 41.1163 25  0.97
BM.THCL      4.41477 3.2096          30  0.5
BM.TLGN      4.41477 3.2096          30  0.5
BM.TLPG      3.67898 3.2096          30  0.72
BM.TKRS      3.67898 3.2096          30  0.72
BM.TGDO      3.67898 3.2096          30  0.72
BM.TRFO      3.67898 3.2096          30  0.72
BM.TOLQ      3.67898 3.2096          30  0.72
BM.TNGS      2.94318 3.2096          30  0.8
BM.TOGS      2.94318 3.2096          30  0.8
BM.TBMSWAS   4.41477 3.2096          30  0.5
BM.TELC      3.808   3.2096          30  0.97
BM.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
BM.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
BM.TSTE1AD   1.82186 54.264  11.386  25  0.34
BM.TSTE1AR   1.82186 54.264  11.386  25  0.34
BM.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
BM.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
BM.TSTE1AH2F 3.13528 94.0585         30  0.5
BM.THEATPUMP 5.66602 6.10081         30  1.848
BM.TH2F      5.66602 94.0585 41.1163 30  0.97
PP.THCL      0.90179 1.632           25  0.5
PP.TLGN      0.90179 1.632           25  0.5
PP.TLPG      0.75149 1.632           25  0.72
PP.TKRS      0.75149 1.632           25  0.72
PP.TGDO      0.75149 1.632           25  0.72
PP.TRFO      0.75149 1.632           25  0.72
PP.TOLQ      0.75149 1.632           25  0.72
PP.TNGS      0.60119 1.632           25  0.8
PP.TOGS      0.60119 1.632           25  0.8
PP.TBMSWAS   0.90179 1.632           25  0.5
PP.TELC      0.884   1.632           25  0.97
PP.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
PP.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
PP.TSTE1AD   1.82186 54.264  11.386  25  0.34
PP.TSTE1AR   1.82186 54.264  11.386  25  0.34
PP.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
PP.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
PP.TSTE1AH2F 2.27889 68.3668         25  0.5
PP.THEATPUMP 1.15738 3.10211         25  1.68
PP.TH2F      2.43133 68.3668 41.1163 25  0.97
FD.THCL      0.63096 0.5372          25  0.5
FD.TLGN      0.63096 0.5372          25  0.5
FD.TLPG      0.42064 0.5372          25  0.72
FD.TKRS      0.42064 0.5372          25  0.72
FD.TGDO      0.42064 0.5372          25  0.72
FD.TRFO      0.42064 0.5372          25  0.72
FD.TOLQ      0.42064 0.5372          25  0.72
FD.TNGS      0.33651 0.5372          25  0.8
FD.TOGS      0.33651 0.5372          25  0.8
FD.TBMSWAS   0.63096 0.5372          25  0.5
FD.TELC      0.476   0.5372          25  0.97
FD.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
FD.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
FD.TSTE1AD   1.82186 54.264  11.386  25  0.34
FD.TSTE1AR   1.82186 54.264  11.386  25  0.34
FD.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
FD.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
FD.TSTE1AH2F 2.27889 68.3668         25  0.5
FD.THEATPUMP 0.64783 1.02111         25  1.68
FD.TH2F      2.43133 68.3668 41.1163 25  0.97
EN.THCL      1.00937 0.31769         25  0.5
EN.TLGN      1.00937 0.31769         25  0.5
EN.TLPG      0.84114 0.31769         25  0.72
EN.TKRS      0.84114 0.31769         25  0.72
EN.TGDO      0.84114 0.31769         25  0.72
EN.TRFO      0.84114 0.31769         25  0.72
EN.TOLQ      0.84114 0.31769         25  0.72
EN.TNGS      0.67291 0.31769         25  0.8
EN.TOGS      0.67291 0.31769         25  0.8
EN.TBMSWAS   1.00937 0.31769         25  0.5
EN.TELC      0.748   0.31769         20  0.97
EN.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
EN.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
EN.TSTE1AD   1.82186 54.264  11.386  25  0.34
EN.TSTE1AR   1.82186 54.264  11.386  25  0.34
EN.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
EN.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
EN.TSTE1AH2F 2.27889 68.3668         25  0.5
EN.THEATPUMP 1.29545 0.60387         25  1.68
EN.TH2F      2.43133 68.3668 41.1163 25  0.97
TX.THCL      0.67371 0.16959         20  0.5
TX.TLGN      0.67371 0.16959         20  0.5
TX.TLPG      0.44914 0.16959         20  0.72
TX.TKRS      0.44914 0.16959         20  0.72
TX.TGDO      0.44914 0.16959         20  0.72
TX.TRFO      0.44914 0.16959         20  0.72
TX.TOLQ      0.44914 0.16959         20  0.72
TX.TNGS      0.35931 0.16959         20  0.8
TX.TOGS      0.35931 0.16959         20  0.8
TX.TBMSWAS   0.476   0.16959         20  0.5
TX.TELC      0.476   0.16959         20  0.97
TX.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
TX.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
TX.TSTE1AD   1.82186 54.264  11.386  25  0.34
TX.TSTE1AR   1.82186 54.264  11.386  25  0.34
TX.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
TX.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
TX.TSTE1AH2F 2.27889 68.3668         20  0.5
TX.THEATPUMP 0.69173 0.32236         20  1.68
TX.TH2F      2.43133 68.3668 41.1163 25  0.97
OE.THCL      1.00937 0.31769         25  0.5
OE.TLGN      1.00937 0.31769         25  0.5
OE.TLPG      0.84114 0.31769         25  0.72
OE.TKRS      0.84114 0.31769         25  0.72
OE.TGDO      0.84114 0.31769         25  0.72
OE.TRFO      0.84114 0.31769         25  0.72
OE.TOLQ      0.84114 0.31769         25  0.72
OE.TNGS      0.67291 0.31769         25  0.8
OE.TOGS      0.67291 0.31769         25  0.8
OE.TBMSWAS   1.00937 0.31769         25  0.5
OE.TELC      0.84114 0.31769         25  0.97
OE.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
OE.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
OE.TSTE1AD   1.82186 54.264  11.386  25  0.34
OE.TSTE1AR   1.82186 54.264  11.386  25  0.34
OE.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
OE.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
OE.TSTE1AH2F 2.27889 68.3668         25  0.5
OE.THEATPUMP 1.29545 0.60387         25  1.68
OE.TH2F      2.43133 68.3668 41.1163 25  0.97
OI.THCL      0.94967 1.40352         20  0.5
OI.TLGN      0.94967 1.40352         20  0.5
OI.TLPG      0.79139 1.40352         20  0.72
OI.TKRS      0.79139 1.40352         20  0.72
OI.TGDO      0.79139 1.40352         20  0.72
OI.TRFO      0.79139 1.40352         20  0.72
OI.TOLQ      0.79139 1.40352         20  0.72
OI.TNGS      0.63311 1.40352         20  0.8
OI.TOGS      0.63311 1.40352         20  0.8
OI.TBMSWAS   0.94967 1.40352         20  0.5
OI.TELC      0.68    1.40352         20  0.97
OI.TSTE1AL   2.43133 40.1956 41.1163 25  0.35
OI.TSTE1AH   2.43133 40.1956 41.1163 25  0.35
OI.TSTE1AD   1.82186 54.264  11.386  25  0.34
OI.TSTE1AR   1.82186 54.264  11.386  25  0.34
OI.TSTE1AG   1.18376 30.1467 31.6279 20  0.44
OI.TSTE1AB   2.33335 67.1517 18.9767 25  0.37
OI.TSTE1AH2F 2.27889 68.3668         20  0.5
OI.THEATPUMP 1.21884 2.66781         20  1.68
OI.TH2F      2.43133 68.3668 41.1163 25  0.97
;
*---
* Coverting EUR05 to US2015
imDataIndTechnology(INDSE,TECH,"IC") = imDataIndTechnology(INDSE,TECH,"IC") * 1.3;
imDataIndTechnology(INDSE,TECH,"FC") = imDataIndTechnology(INDSE,TECH,"FC") * 1.3;
imDataIndTechnology(INDSE,TECH,"VC") = imDataIndTechnology(INDSE,TECH,"VC") * 1.3;
*---

table imDataChpPowGen(EF,CHPPGSET,YTIME)   "Data for power generation costs (various)"
$ondelim
$include"./iChpPowGen.csv"
$offdelim
;
*---
* Converting EUR2015 to US2015
imDataChpPowGen(EF,"IC",YTIME)  = imDataChpPowGen(EF,"IC",YTIME) * 1.1;
imDataChpPowGen(EF,"FC",YTIME)  = imDataChpPowGen(EF,"FC",YTIME) * 1.1;
imDataChpPowGen(EF,"VOM",YTIME) = imDataChpPowGen(EF,"VOM",YTIME) * 1.1;
*---
table imDataDomTech(DOMSE,TECH,ECONCHAR)                "Technical lifetime of Industry (years)"
             IC       FC      VC      LFT USC
SE.THCL       0.323544 10.88           20  0.7
SE.TLGN       0.323544 10.88           20  0.5
SE.TLPG       0.24888  10.88           20  0.8
SE.TGSL       0.323544 10.88           20  0.7
SE.TKRS       0.24888  10.88           20  0.8
SE.TGDO       0.24888  6.8             20  0.85
SE.TRFO       0.24888  10.88           20  0.8
SE.TOLQ       0.24888  10.88           20  0.8
SE.TNGS       0.2244   6.8             20  0.88
SE.TOGS       0.2244   10.88           20  0.8
*SE.PGTSOL     0.86224  1.36            20  0.97
SE.TBMSWAS    0.323544 10.88           20  0.5
SE.TELC       0.3      8.976           12  0.97
SE.TSTE1AL    2.43133  40.1956 41.1163 30  0.375
SE.TSTE1AH    2.43133  40.1956 41.1163 30  0.375
SE.TSTE1AD    1.82186  54.264  11.386  30  0.3475
SE.TSTE1AR    1.82186  54.264  11.386  30  0.3475
SE.TSTE1AG    1.18376  30.1467 31.6279 25  0.485
SE.TSTE1AB    2.33335  67.1517 18.9767 30  0.3975
SE.TSTE1AH2F  2.68089  80.4266         20  0.465
SE.TSTE2LGN   0.296442 1.00489 2.37209 20  0.816667
SE.TSTE2OSL   0.296442 1.00489 2.37209 20  0.816667
SE.TSTE2GDO   0.296442 1.00489 2.37209 20  0.856667
SE.TSTE2RFO   0.296442 1.00489 2.37209 20  0.856667
SE.TSTE2OLQ   0.296442 1.00489 2.37209 20  0.856667
SE.TSTE2NGS   0.296442 1.00489 2.37209 20  0.896667
SE.TSTE2OGS   0.296442 1.00489 2.37209 20  0.896667
SE.TSTE2BMS   0.296442 1.00489 2.37209 20  0.816667
SE.THEATPUMP  0.432    12.9254         20  1.848
AG.THCL       0.323544 10.88           20  0.7
AG.TLGN       0.323544 10.88           20  0.5
AG.TLPG       0.24888  10.88           20  0.8
AG.TGSL       0.323544 10.88           20  0.7
AG.TKRS       0.24888  10.88           20  0.8
AG.TGDO       0.24888  6.8             20  0.85
AG.TRFO       0.24888  10.88           20  0.8
AG.TOLQ       0.24888  10.88           20  0.8
AG.TNGS       0.2244   6.8             20  0.88
AG.TOGS       0.2244   10.88           20  0.8
*AG.PGTSOL     0.86224  1.36            20  0.97
AG.TBMSWAS    0.323544 10.88           20  0.5
AG.TELC       0.3      8.976           12  0.97
AG.TSTE1AL    2.43133  40.1956 41.1163 30  0.375
AG.TSTE1AH    2.43133  40.1956 41.1163 30  0.375
AG.TSTE1AD    1.82186  54.264  11.386  30  0.3475
AG.TSTE1AR    1.82186  54.264  11.386  30  0.3475
AG.TSTE1AG    1.18376  30.1467 31.6279 25  0.485
AG.TSTE1AB    2.33335  67.1517 18.9767 30  0.3975
AG.TSTE1AH2F  2.68089  80.4266         20  0.465
AG.TSTE2LGN   0.296442 1.00489 2.37209 20  0.816667
AG.TSTE2OSL   0.296442 1.00489 2.37209 20  0.816667
AG.TSTE2GDO   0.296442 1.00489 2.37209 20  0.856667
AG.TSTE2RFO   0.296442 1.00489 2.37209 20  0.856667
AG.TSTE2OLQ   0.296442 1.00489 2.37209 20  0.856667
AG.TSTE2NGS   0.296442 1.00489 2.37209 20  0.896667
AG.TSTE2OGS   0.296442 1.00489 2.37209 20  0.896667
AG.TSTE2BMS   0.296442 1.00489 2.37209 20  0.816667
AG.THEATPUMP  0.432    12.9254         20  1.848
HOU.THCL      0.323544 10.88           20  0.7
HOU.TLGN      0.323544 10.88           20  0.5
HOU.TLPG      0.24888  10.88           20  0.8
HOU.TGSL      0.323544 10.88           20  0.7
HOU.TKRS      0.24888  10.88           20  0.8
HOU.TGDO      0.24888  6.8             20  0.85
HOU.TRFO      0.24888  10.88           20  0.8
HOU.TOLQ      0.24888  10.88           20  0.8
HOU.TNGS      0.2244   6.8             20  0.88
HOU.TOGS      0.2244   10.88           20  0.8
*HOU.PGTSOL    0.86224  1.36            20  0.97
HOU.TBMSWAS   0.323544 10.88           20  0.5
HOU.TELC      0.3      8.976           12  0.97
HOU.TSTE1AL   2.43133  40.1956 41.1163 30  0.375
HOU.TSTE1AH   2.43133  40.1956 41.1163 30  0.375
HOU.TSTE1AD   1.82186  54.264  11.386  30  0.3475
HOU.TSTE1AR   1.82186  54.264  11.386  30  0.3475
HOU.TSTE1AG   1.18376  30.1467 31.6279 25  0.485
HOU.TSTE1AB   2.33335  67.1517 18.9767 30  0.3975
HOU.TSTE1AH2F 2.68089  80.4266         20  0.465
HOU.TSTE2LGN  0.296442 1.00489 2.37209 20  0.816667
HOU.TSTE2OSL  0.296442 1.00489 2.37209 20  0.816667
HOU.TSTE2GDO  0.296442 1.00489 2.37209 20  0.856667
HOU.TSTE2RFO  0.296442 1.00489 2.37209 20  0.856667
HOU.TSTE2OLQ  0.296442 1.00489 2.37209 20  0.856667
HOU.TSTE2NGS  0.296442 1.00489 2.37209 20  0.896667
HOU.TSTE2OGS  0.296442 1.00489 2.37209 20  0.896667
HOU.TSTE2BMS  0.296442 1.00489 2.37209 20  0.816667
HOU.THEATPUMP 0.432    12.9254         20  1.848
;
*---
* Coverting EUR05 to US2015
imDataDomTech(DOMSE,TECH,"IC") = imDataDomTech(DOMSE,TECH,"IC") * 1.3;
imDataDomTech(DOMSE,TECH,"FC") = imDataDomTech(DOMSE,TECH,"FC") * 1.3;
imDataDomTech(DOMSE,TECH,"VC") = imDataDomTech(DOMSE,TECH,"VC") * 1.3;
*---
table imDataNonEneSec(NENSE,TECH,ECONCHAR)              "Technical data of non energy uses and bunkers (various)"
        IC      FC      VC      LFT USC
PCH.THCL 0.26227 45.22   2.37209 20  0.65
PCH.TLGN 0.26227 47.6    2.37209 20  0.5
PCH.TLPG 0.18088 20.4    2.37209 20  0.72
PCH.TGDO 0.18088 9.044   2.37209 20  0.72
PCH.TRFO 0.18088 18.088  2.37209 20  0.72
PCH.TOLQ 0.18088 20.4    2.37209 20  0.72
PCH.TNGS 0.18088 0.9044  2.37209 20  0.8
PCH.TOGS 0.18088 1.36    2.37209 20  0.8
BU.TGDO  0.204   0.136           25  0.72
BU.TRFO  0.204   0.136           25  0.72
BU.TOLQ  0.136   6.8             25  0.72
NEN.THCL 0.26227 45.22   2.37209 20  0.65
NEN.TLGN 0.26227 47.6    2.37209 20  0.5
NEN.TLPG 0.612   20.4    2.37209 20  0.72
NEN.TGDO 0.18088 9.044   2.37209 20  0.72
NEN.TRFO 0.18088 18.088  2.37209 20  0.72
NEN.TOLQ 0.612   20.4    2.37209 20  0.72
NEN.TNGS 0.18088 0.9044  2.37209 20  0.8
NEN.TOGS 0.18088 1.36    2.37209 20  0.8
;
*---
* Converting EUR05 to US2015
imDataNonEneSec(NENSE,TECH,"IC") = imDataNonEneSec(NENSE,TECH,"IC") * 1.3;
imDataNonEneSec(NENSE,TECH,"FC") = imDataNonEneSec(NENSE,TECH,"FC") * 1.3;
imDataNonEneSec(NENSE,TECH,"VC") = imDataNonEneSec(NENSE,TECH,"VC") * 1.3;
*---
* FIXME: check if country-specific data is needed; move to mrprom
* author=giannou
table iIndCharData(INDSE,Indu_Scon_Set)         "Industry sector charactetistics (various)"
     BASE           SHR_NSE   SH_HPELC
IS   0.4397         0.7       0.00001
NF   0              0.85      0.00001
CH   0.1422         0.95      0.00001
BM   2.1062         0.95      0.00001
PP   0              0.95      0.00001
FD   0.6641         0.9       0.00001
TX   0.0638         0.9       0.00001
EN   1.6664         0.95      0.00001
OE   0.00000001     0.95      0.00001
OI   1.5161         0.9       0.00001
;
*---
table iInitConsSubAndInitShaNonSubElec(DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
     BASE   SHR_NSE SH_HPELC
SE   1.8266 0.9     0.00001
HOU  11.511 0.9     0.00001
AG   0.2078 0.9     0.00001
;
*---
iShrHeatPumpElecCons(runCy,INDSE) = iIndCharData(INDSE,"SH_HPELC");
iShrHeatPumpElecCons(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SH_HPELC");
*---
imFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
*---
*Calculation of consumer size groups and their distribution function
imNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10;      !! 11 different consumer size groups for cars and trucks
imNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
imNcon(INDSE) = 10;                                                    !! 11 different consumer size groups for industrial sectors
imNcon(DOMSE) = 10;                                                    !! 11 different consumer size groups for domestic and tertiary sectors
imNcon(NENSE) = 10;                                                    !! 11 different consumer size groups for non energy uses
imNcon("BU") = 2;                                                      !! ... except bunkers .
imNcon("DAC") = 1;                                                      !! 
*---
* 11 vehicle mileage groups
* 0.952 turned out to be a (constant) ratio between modal and average mileage through iterations in Excel
*---
imAnnCons(runCy,'PC','smallest') = 0.5 * 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
imAnnCons(runCy,'PC' ,'modal') = 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
imAnnCons(runCy,'PC' ,'largest') = 4 * 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
*---
* modal value is assumed to be 2 tonnes/vehicle, min = 1/3*modal and max = 10*modal tkm.
* 0.706 is the constant ratio of modal/average tkm through iterations in Excel
*---
imAnnCons(runCy,'GU','smallest') = 0.5 * 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%")* 1000 * 2 / 3  * 1E-6;
imAnnCons(runCy,'GU','modal')    = 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2  * 1E-6;
imAnnCons(runCy,'GU','largest')  = 4 * 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2 * 10  * 1E-6;
*---
imAnnCons(runCy,'PA','smallest') = 40000 * 50 * 1E-6;
imAnnCons(runCy,'PA','modal')    = 400000 * 1E-6;
imAnnCons(runCy,'PA','largest')  = 800000 * 300 * 1E-6;
*---
* Size will not play a role in buses, trains, ships and aircraft
* Following values are given only for the sake of uniformity, but imDisFunConSize is not really calculated for non-road transport!
imAnnCons(runCy,'PB',"smallest") = 20000 * 5 * 1E-6;
imAnnCons(runCy,'PB',"modal")    = 50000 * 15 * 1E-6;
imAnnCons(runCy,'PB',"largest")  = 200000 * 50 * 1E-6;
*---
imAnnCons(runCy,'PT',"smallest") = 50000 * 50 * 1E-6;
imAnnCons(runCy,'PT',"modal")    = 200000 * 150 * 1e-6;
imAnnCons(runCy,'PT',"largest")  = 400000 * 500 * 1E-6;
*---
imAnnCons(runCy,'GT',"smallest") = 50000 * 20 * 1E-6;
imAnnCons(runCy,'GT',"modal")    = 200000 * 200 * 1e-6;
imAnnCons(runCy,'GT',"largest")  = 400000 * 500 * 1E-6;
*---
imAnnCons(runCy,'PN',"smallest") = 10000 * 50 * 1E-6;
imAnnCons(runCy,'PN',"modal")    = 50000 * 100 * 1e-6;
imAnnCons(runCy,'PN',"largest")  = 100000 * 500 * 1E-6;
*---
imAnnCons(runCy,'GN',"smallest") = 10000 * 20 * 1E-6;
imAnnCons(runCy,'GN',"modal")    = 50000 * 300 * 1e-6;
imAnnCons(runCy,'GN',"largest")  = 100000 * 1000 * 1E-6;
imAnnCons(runCy,INDSE,"smallest") = 0.2  ;
imAnnCons(runCy,INDSE,"largest") = 0.9 ;
* assuming an average utilisation rate of 0.6 for iron & steel and 0.5 for other industry (see iterations in Excel):
imAnnCons(runCy,"IS","modal") = 0.587;
imAnnCons(runCy,INDSE,"modal")$(not sameas(INDSE,"IS")) = 0.487;
*---
imAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat("smallest")  ;
imAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat("largest") ;
imAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat("modal");
*---
imAnnCons(runCy,NENSE,"smallest") = 0.2  ;
imAnnCons(runCy,NENSE,"largest")  = 0.9 ;
* assuming an average utilisation rate of 0.5 for non-energy uses:
imAnnCons(runCy,NENSE,"modal") = 0.487 ;
*---
imAnnCons(runCy,"BU","smallest") = 0.2 ;
imAnnCons(runCy,"BU","largest") = 1 ;
imAnnCons(runCy,"BU","modal") = 0.5 ;

imAnnCons(runCy,"DAC","smallest") = 0.2 ;
imAnnCons(runCy,"DAC","largest") = 1 ;
imAnnCons(runCy,"DAC","modal") = 0.5 ;
*---
* Consumer size groups distribution function
Loop (runCy,DSBS) DO
     Loop rCon$(ord(rCon) le imNcon(DSBS)+1) DO
          imDisFunConSize(runCy,DSBS,rCon) =
                 Prod(nSet$(ord(Nset) le imNcon(DSBS)),ord(nSet))
                 /
                 (
                  (
                   Prod(nSet$(ord(nSet) le imNcon(DSBS)-(ord(rCon)-1)),ord(nSet))$(ord(rCon) lt imNcon(DSBS)+1)
                       +1$(ord(rCon) eq imNcon(DSBS)+1)
                   )
                   *
                   (
                      Prod(nSet$(ord(nSet) le ord(rCon)-1),ord(nSet))$(ord(rCon) ne 1)+1$(ord(rCon) eq 1))
                 )
                 *
                 Power(log(imAnnCons(runCy,DSBS,"modal")/imAnnCons(runCy,DSBS,"smallest")),ord(rCon)-1)
                 *
                 Power(log(imAnnCons(runCy,DSBS,"largest")/imAnnCons(runCy,DSBS,"modal")),imNcon(DSBS)-(ord(rCon)-1))
                 /
                (Power(log(imAnnCons(runCy,DSBS,"largest")/imAnnCons(runCy,DSBS,"smallest")),imNcon(DSBS)) )
                *
                imAnnCons(runCy,DSBS,"smallest")*(imAnnCons(runCy,DSBS,"largest")/imAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/imNcon(DSBS))
;
     ENDLOOP;
ENDLOOP;
*---
imCumDistrFuncConsSize(runCy,DSBS) = sum(rCon, imDisFunConSize(runCy,DSBS,rCon));
imCGI(allCy,YTIME) = 1;
*---
table iDataDistrLosses(allCy,EF,YTIME)	     "Data for Distribution Losses (Mtoe)"
$ondelim
$include"./iDataDistrLosses.csv"
$offdelim
;
*---
imDistrLosses(runCy,EFS,YTIME) = iDataDistrLosses(runCy,EFS,YTIME);
*---
table imFuelConsTRANSE(allCy,TRANSE,EF,YTIME)	      "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelConsTRANSE.csv"
$offdelim
;
*---
imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME) = imFuelConsTRANSE(runCy,TRANSE,EF,YTIME);
table iFuelConsINDSE(allCy,INDSE,EF,YTIME)	"Fuel consumption of industry subsector (Mtoe)"
$ondelim
$include"./iFuelConsINDSE.csv"
$offdelim
;
*---
iFuelConsINDSE(runCy,INDSE,EF,YTIME)$(SECtoEF(INDSE,EF) $(iFuelConsINDSE(runCy,INDSE,EF,YTIME)<=0)) = 1e-6;
*---
table iFuelConsDOMSE(allCy,DOMSE,EF,YTIME)	"Fuel consumption of domestic subsector (Mtoe)"
$ondelim
$include"./iFuelConsDOMSE.csv"
$offdelim
;
*---
iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)$(SECtoEF(DOMSE,EF) $(iFuelConsDOMSE(runCy,DOMSE,EF,YTIME)<=0)) = 1e-6;
*---
table iFuelConsNENSE(allCy,NENSE,EF,YTIME)	"Fuel consumption of non energy and bunkers (Mtoe)"
$ondelim
$include"./iFuelConsNENSE.csv"
$offdelim
;
*---
iFuelConsNENSE(runCy,NENSE,EF,YTIME)$(SECtoEF(NENSE,EF) $(iFuelConsNENSE(runCy,NENSE,EF,YTIME)<=0)) = 1e-6;
imFuelConsPerFueSub(runCy,INDSE,EF,YTIME) = iFuelConsINDSE(runCy,INDSE,EF,YTIME);
imFuelConsPerFueSub(runCy,INDSE,"STE1AG",YTIME) = iFuelConsINDSE(runCy,INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub(runCy,INDSE,"STE1AH",YTIME) = iFuelConsINDSE(runCy,INDSE,"STE1AG",YTIME);
imFuelConsPerFueSub("IND",INDSE,"STE1AB",YTIME) = iFuelConsINDSE("IND",INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub("IND",INDSE,"STE1AH",YTIME) = iFuelConsINDSE("IND",INDSE,"STE1AB",YTIME);
imFuelConsPerFueSub("CHA",INDSE,"STE1AH",YTIME) = iFuelConsINDSE("IND",INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub("CHA",INDSE,"STE1AG",YTIME) = iFuelConsINDSE("IND",INDSE,"STE1AG",YTIME);
imFuelConsPerFueSub("OAS",INDSE,"STE1AH",YTIME) = iFuelConsINDSE("OAS",INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub("OAS",INDSE,"STE1AG",YTIME) = iFuelConsINDSE("OAS",INDSE,"STE1AG",YTIME);
imFuelConsPerFueSub("POL",INDSE,"STE1AH",YTIME) = iFuelConsINDSE("POL",INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub("POL",INDSE,"STE1AG",YTIME) = iFuelConsINDSE("POL",INDSE,"STE1AG",YTIME);
imFuelConsPerFueSub("LAM",INDSE,"STE1AB",YTIME) = iFuelConsINDSE("LAM",INDSE,"STE1AH",YTIME);
imFuelConsPerFueSub("LAM",INDSE,"STE1AH",YTIME) = iFuelConsINDSE("LAM",INDSE,"STE1AB",YTIME);
imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME) = iFuelConsDOMSE(runCy,DOMSE,EF,YTIME);
imFuelConsPerFueSub(runCy,NENSE,EF,YTIME) = iFuelConsNENSE(runCy,NENSE,EF,YTIME);
* NEED TO CHECK IF CORRECT
imFinEneCons(runCy,EFS,YTIME) =
     sum((INDDOM,EF)$(EFtoEFS(EF,EFS) and sum(TECH$(SECTTECH(INDDOM,TECH) and TECHtoEF(TECH,EF)),1)),imFuelConsPerFueSub(runCy,INDDOM,EF,YTIME))
     +
     sum((TRANSE,EF)$(EFtoEFS(EF,EFS) and sum(TECH$(SECTTECH(TRANSE,TECH) and TECHtoEF(TECH,EF)$(not plugin(TECH))),1)), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
*---
imCO2CaptRate(PGALL)$CCS(PGALL) = 0.96; 
imEffValueInDollars(runCy,SBS,YTIME) = 0;
iScenarioPri(WEF,"NOTRADE",YTIME) = 0;
*---
table iDataImports(allCy,EF,YTIME)	          "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
*---
imFuelImports(runCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(runCy,EFS,YTIME);
*---
iNetImp(runCy,EFS,YTIME) = iDataImports(runCy,"ELC",YTIME)-iSuppExports(runCy,"ELC",YTIME);
*---
* Calculation of weights for sector average fuel price
iResElecIndex(runCy,YTIME) = 1;
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
     iCarbValYrExog(allCy,YTIME) = 0;
elseif %fScenario% eq 1 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"exogCV_NPi",YTIME); !!$an(YTIME)
elseif %fScenario% eq 2 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"exogCV_1_5C",YTIME);
elseif %fScenario% eq 3 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"exogCV_2C",YTIME);
elseif %fScenario% eq 4 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"exogCV_Calib",YTIME);
endif;
*---
table iMatrFactorData(DSBS,TECH,YTIME)          "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactorData.csv"
$offdelim
;
iMatrFactorData(DSBS,TECH,YTIME)$(TRANSE(DSBS) or INDSE(DSBS) or DOMSE(DSBS)) = 1;
iMatrFactorData(DSBS,TECH,YTIME)$(sameas(DSBS, "PC")$SECTTECH(DSBS,TECH)) = 1;
*---
$IFTHEN.calib %MatFacCalibration% == off
parameter imMatrFactor(allCy,DSBS,TECH,YTIME)   "Maturity factor per technology and subsector for all countries (1)";
imMatrFactor(runCy,DSBS,TECH,YTIME) = iMatrFactorData(DSBS,TECH,YTIME);                                          
imMatrFactor(runCy,DSBS,TECH,YTIME)$(imMatrFactor(runCy,DSBS,TECH,YTIME)=0) = 0.000001;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 3;
imMatrFactor("CHA",DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 8;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 8;
$ELSE.calib
variable imMatrFactor(allCy,DSBS,TECH,YTIME)    "Maturity factor per technology and subsector for all countries (1)";
imMatrFactor.L(runCy,DSBS,TECH,YTIME) = iMatrFactorData(DSBS,TECH,YTIME) + 1e-6;                                          
imMatrFactor.L(runCy,DSBS,EF,YTIME)$(imMatrFactor.L(runCy,DSBS,TECH,YTIME)=0) = 0.000001;
imMatrFactor.LO(runCy,DSBS,EF,YTIME) = -10;                                          
imMatrFactor.UP(runCy,DSBS,EF,YTIME) = 100;
$ENDIF.calib
*---
** Industry
imShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndCharData(INDSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,INDSE)$(imShrNonSubElecInTotElecDem(runCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
imShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,DOMSE)$(imShrNonSubElecInTotElecDem(runCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic
*---
**  Transport Sector
imCapCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"IC",YTIME);
imFixOMCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"FC",YTIME);
imVarCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"VC",YTIME);
*---
**  Industrial Sector
imCapCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"IC");
imFixOMCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"FC");
imVarCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"VC");
imUsfEneConvSubTech(runCy,INDSE,TECH,YTIME)  = imDataIndTechnology(INDSE,TECH,"USC");
*---
**  Domestic Sector
imFixOMCostTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"FC");
imVarCostTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"VC");
imUsfEneConvSubTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"USC");
*---
**  Non Energy Sector and Bunkers
imFixOMCostTech(runCy,NENSE,TECH,YTIME)= imDataNonEneSec(NENSE,TECH,"FC");
imVarCostTech(runCy,NENSE,TECH,YTIME) = imDataNonEneSec(NENSE,TECH,"VC");
imUsfEneConvSubTech(runCy,NENSE,TECH,YTIME) = imDataNonEneSec(NENSE,TECH,"USC");
*---
**  Power Generation
*---
table iDataPlantEffByType(allCy,PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;
*---
imPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(runCy,PGALL, YTIME) ;
*---
**   Conversion of GW mean power into TWh/y, depending on whether it's a leap year
smGwToTwhPerYear(YTIME) = 8.76 + 0.024 $ (mod(YTIME.val,4) = 0 and mod (YTIME.val,100) <> 0);