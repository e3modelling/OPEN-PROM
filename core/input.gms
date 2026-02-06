*' @title Core Inputs
*' @code

*---
table imActv(YTIME,allCy,DSBS) "Sector activity (various)"
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
imElastA(runCy,DSBS,"b1",YTIME)$(not TRANSE(DSBS)) = imElastA(runCy,DSBS,"b1",YTIME) / 4;
imElastA(runCy,DSBS,"b2",YTIME)$(not TRANSE(DSBS)) = imElastA(runCy,DSBS,"b2",YTIME) / 4;
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
STEAMP  0.08
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
CRO 2.76
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
OGS 2.336234395,
BMSWAS 0/;
*---
imCo2EmiFac(runCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
imCo2EmiFac(runCy,"IS","HCL",YTIME) = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
*imCo2EmiFac(runCy,"H2P","NGS",YTIME) = 3.107;
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
table imInstCapPastNonCHP(allCy,PGALL,YTIME)        "Installed Non-CHP capacity past (GW)"
$ondelim
$include"./iInstCapPastNonCHP.csv"
$offdelim
;
*---
table imInstCapPastCHP(allCy,EF,YTIME)        "Installed CHP capacity past (GW)"
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
table imPriceElecInd(allCy,YTIME)                      "Electricity power to steam ratio"
$ondelim
$include"./iDataElecInd.csv"
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
* The share for IS +8% CAPEX -8%OPEX
IS.THCLCCS   0.34772 6.256   1.36    25  0.5
IS.TLGN      0.48295 10.2    2.04    25  0.5
IS.TLPG      0.48295 10.2    2.04    25  0.72
IS.TKRS      0.48295 10.2    2.04    25  0.72
IS.TGDO      0.48295 10.2    2.04    25  0.72
IS.TRFO      0.48295 10.2    2.04    25  0.72
IS.TOLQ      0.48295 10.2    2.04    25  0.72
IS.TNGS      0.48295 10.2    2.04    25  0.8
* The share for IS +8% CAPEX -8%OPEX
IS.TNGSCCS   0.52159 9.38    2.04    25  0.8
IS.TOGS      0.48295 10.2    2.04    25  0.8
IS.TBMSWAS   0.48295 10.2    2.04    25  0.5
IS.TELC      0.29367 6.8     1.36    25  0.85
IS.THEATPUMP 0.92974 19.3882 3.1021  25  1.848
IS.TH2F      1.04547 40.4451 17.68   25  0.85
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
NF.TELC      3.4     63.036          30  0.85
NF.THEATPUMP 4.94477 119.819         30  1.848
NF.TH2F      4.94477 119.819 41.1163 30  0.85
CH.THCL      0.53294 5.44            25  0.5
* The share for CH +30% CAPEX 0%OPEX
CH.THCLCCS   0.69282 5.44            25  0.5
CH.TLGN      0.53294 5.44            25  0.5
CH.TLPG      0.44411 5.44            25  0.72
CH.TKRS      0.44411 5.44            25  0.72
CH.TGDO      0.44411 5.44            25  0.72
CH.TRFO      0.44411 5.44            25  0.72
CH.TOLQ      0.44411 5.44            25  0.72
CH.TNGS      0.35529 5.44            25  0.8
* The share for CH +30% CAPEX 0%OPEX
CH.TNGSCCS   0.46188 5.44            25  0.8
CH.TOGS      0.35529 5.44            25  0.8
CH.TBMSWAS   0.53294 5.44            25  0.5
CH.TELC      0.476   5.44            25  0.85
CH.THEATPUMP 0.68398 10.3404         25  1.848
CH.TH2F      3.13528 94.0585 41.1163 25  0.85
BM.THCL      4.41477 3.2096          30  0.5
* The share for BM +19% CAPEX +20%OPEX
BM.THCLCCS   5.25357 3.8515          30  0.5
BM.TLGN      4.41477 3.2096          30  0.5
BM.TLPG      3.67898 3.2096          30  0.72
BM.TKRS      3.67898 3.2096          30  0.72
BM.TGDO      3.67898 3.2096          30  0.72
BM.TRFO      3.67898 3.2096          30  0.72
BM.TOLQ      3.67898 3.2096          30  0.72
BM.TNGS      2.94318 3.2096          30  0.8
* The share for BM +19% CAPEX +20%OPEX
BM.TNGSCCS   3.50238 3.8515          30  0.8
BM.TOGS      2.94318 3.2096          30  0.8
BM.TBMSWAS   4.41477 3.2096          30  0.5
BM.TELC      3.808   3.2096          30  0.85
BM.THEATPUMP 5.66602 6.10081         30  1.848
BM.TH2F      5.66602 94.0585 41.1163 30  0.85
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
PP.TELC      0.884   1.632           25  0.85
PP.THEATPUMP 1.15738 3.10211         25  1.68
PP.TH2F      2.43133 68.3668 41.1163 25  0.85
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
FD.TELC      0.476   0.5372          25  0.85
FD.THEATPUMP 0.64783 1.02111         25  1.68
FD.TH2F      2.43133 68.3668 41.1163 25  0.85
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
EN.TELC      0.748   0.31769         20  0.85
EN.THEATPUMP 1.29545 0.60387         25  1.68
EN.TH2F      2.43133 68.3668 41.1163 25  0.85
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
TX.TELC      0.476   0.16959         20  0.85
TX.THEATPUMP 0.69173 0.32236         20  1.68
TX.TH2F      2.43133 68.3668 41.1163 25  0.85
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
OE.TELC      0.84114 0.31769         25  0.85
OE.THEATPUMP 1.29545 0.60387         25  1.68
OE.TH2F      2.43133 68.3668 41.1163 25  0.85
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
OI.TELC      0.68    1.40352         20  0.85
OI.THEATPUMP 1.21884 2.66781         20  1.68
OI.TH2F      2.43133 68.3668 41.1163 25  0.85
;
*---
* Coverting EUR05 to US2015
imDataIndTechnology(INDSE,TECH,"IC") = imDataIndTechnology(INDSE,TECH,"IC") * 1.3;
imDataIndTechnology(INDSE,TECH,"FC") = imDataIndTechnology(INDSE,TECH,"FC") * 1.3;
imDataIndTechnology(INDSE,TECH,"VC") = imDataIndTechnology(INDSE,TECH,"VC") * 1.3;

imDataIndTechnology(INDSE,"TBGDO",ECONCHAR) = imDataIndTechnology(INDSE,"TGDO",ECONCHAR);
imDataIndTechnology(INDSE,"TBMSWAS",ECONCHAR) = imDataIndTechnology("IS","TBMSWAS",ECONCHAR);
imDataIndTechnology(INDSE,"TSTE",ECONCHAR) = imDataIndTechnology(INDSE,"THCL",ECONCHAR);
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
*SE.PGTSOL     0.86224  1.36            20  0.85
SE.TBMSWAS    0.323544 10.88           20  0.5
SE.TELC       0.3      8.976           12  0.85
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
*AG.PGTSOL     0.86224  1.36            20  0.85
AG.TBMSWAS    0.323544 10.88           20  0.5
AG.TELC       0.3      8.976           12  0.85
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
*HOU.PGTSOL    0.86224  1.36            20  0.85
HOU.TBMSWAS   0.323544 10.88           20  0.5
HOU.TELC      0.3      8.976           12  0.85
HOU.THEATPUMP 0.432    12.9254         20  1.848
;
*---
* Coverting EUR05 to US2015
imDataDomTech(DOMSE,TECH,"IC") = imDataDomTech(DOMSE,TECH,"IC") * 1.3;
imDataDomTech(DOMSE,TECH,"FC") = imDataDomTech(DOMSE,TECH,"FC") * 1.3;
imDataDomTech(DOMSE,TECH,"VC") = imDataDomTech(DOMSE,TECH,"VC") * 1.3;
imDataIndTechnology(INDSE,"TGSL",ECONCHAR) = imDataDomTech("SE","TGSL",ECONCHAR);
imDataDomTech(DOMSE,"TSTE",ECONCHAR) = imDataDomTech(DOMSE,"THCL",ECONCHAR);
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
BU.TKRS  0.136   6.8             25  0.72
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
imDataNonEneSec(NENSE,"TSTE",ECONCHAR) = imDataNonEneSec(NENSE,"THCL",ECONCHAR);
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
table imFuelCons(allCy,SBS,EF,YTIME)	      "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelCons.csv"
$offdelim
;
*---
imFuelConsPerFueSub(runCy,SBS,EF,YTIME) = imFuelCons(runCy,SBS,EF,YTIME);
imFuelConsPerFueSub(runCy,"BU",EF,YTIME) = -imFuelConsPerFueSub(runCy,"BU",EF,YTIME);
*---
imCO2CaptRate(PGALL)$CCS(PGALL) = 0.90; 
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
elseif %fScenario% eq 5 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"Full_C200",YTIME);
elseif %fScenario% eq 6 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"Full_C400",YTIME);   
elseif %fScenario% eq 7 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"Full_C600",YTIME);
elseif %fScenario% eq 8 then
     iCarbValYrExog(allCy,YTIME) = iEnvPolicies(allCy,"Full_C800",YTIME);
endif;
*---
table iMatrFactorData(DSBS,TECH,YTIME)          "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactorData.csv"
$offdelim
;
iMatrFactorData(DSBS,TECH,YTIME)$(TRANSE(DSBS) or INDSE(DSBS) or DOMSE(DSBS)) = 1;
iMatrFactorData(DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and (INDSE(DSBS)) and CCSTECH(ITECH)) = 1;
iMatrFactorData(DSBS,TECH,YTIME)$(sameas(DSBS, "PC")$SECTTECH(DSBS,TECH)) = 1;
*---
$IFTHEN.calib %MatFacCalibration% == off
parameter imMatrFactor(allCy,DSBS,TECH,YTIME)   "Maturity factor per technology and subsector for all countries (1)";
imMatrFactor(runCy,DSBS,TECH,YTIME) = iMatrFactorData(DSBS,TECH,YTIME);                                          
imMatrFactor(runCy,DSBS,TECH,YTIME)$(imMatrFactor(runCy,DSBS,TECH,YTIME)=0) = 0.000001;

imMatrFactor(runCy,DSBS,"TGDO",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 0.5;
imMatrFactor(runCy,DSBS,"TGSL",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 0.5;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 3;
imMatrFactor("CHA",DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 8;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 8;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 50 and TRANSE(DSBS)) = 15;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 50 and TRANSE(DSBS)) = 15;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TNGSCCS",YTIME)$((ord(YTIME) > 11) and INDSE(DSBS)) = 1;
imMatrFactor(runCy,DSBS,"THCLCCS",YTIME)$((ord(YTIME) > 11) and INDSE(DSBS)) = 1;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 11 and DOMSE(DSBS)) = 20;
imMatrFactor(runCy,DSBS,"TBMSWAS",YTIME)$(ord(YTIME) > 11 and DOMSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) < 21 and INDSE(DSBS)) = 0;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) > 21 and INDSE(DSBS)) = 2;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) > 40 and INDSE(DSBS)) = 2;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 11 and INDSE(DSBS)) = 4;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) > 11 and INDSE(DSBS)) = 20;
imMatrFactor(runCy,DSBS,"TGDO",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TGSL",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TNGS",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TLPG",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TPHEVGSL",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TPHEVGDO",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TCHEVGSL",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TCHEVGDO",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 0.001;

$ELSE.calib
variable imMatrFactor(allCy,DSBS,TECH,YTIME)    "Maturity factor per technology and subsector for all countries (1)";
imMatrFactor.L(runCy,DSBS,TECH,YTIME) = iMatrFactorData(DSBS,TECH,YTIME) + 1e-6;                                          
imMatrFactor.LO(runCy,DSBS,EF,YTIME) = -10;                                          
imMatrFactor.UP(runCy,DSBS,EF,YTIME) = 100;
$ENDIF.calib
*---
parameters
!!imFacSubsiCapCostTech(DSBS,TECH)                            !!State subsidy (%) factor in technology capex (demand side)
!!imGrantCapCostTech(DSBS,TECH)                               !!State granting in technology capex (demand side)
!!imSubsiCapCostFuel(SBS,EF)                                  !!State subsidy in fuel cost
!!imFacSubsiCapCostSupply(SSBS,STECH)                         !!State subsidy (%) factor in technology capex (supply side)
!!imGrantCapCostSupply(SSBS,STECH)                            !!State granting in technology capex (supply side)
imCapCostTechMin(allCy,DSBS,TECH,YTIME)                    !!Factor for the minimum capex of a demand technology after the state subsidy
;

$ontext
if %fScenario% eq 0 then
     imFacSubsiCapCostTech("PC","TELC") = 0;
     imFacSubsiCapCostTech("CH","TELC") = 0;
     imFacSubsiCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;
     imGrantCapCostTech("PC","TELC") = 0;                        !!kUS$2015 per vehicle
     imGrantCapCostTech("CH","TELC") = 0;                        !!kUS$2015/toe-year for Industry sectors
     imGrantCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;         !!US$2015/tCO2
     imSubsiCapCostFuel("HOU","ELC") = 0;                        !!kUS$2015/toe
     imSubsiCapCostFuel(SBS,"ELC")$INDSE1(SBS) = 0;              !!kUS$2015/toe
     imFacSubsiCapCostSupply("PG",PGREN) = 0;
     imFacSubsiCapCostSupply("H2P",H2TECH) = 0;
     imGrantCapCostSupply("PG",PGREN) = 0;                       !!kUS$2015/kW
     imGrantCapCostSupply("H2P",H2TECH) = 0;                     !!US$2015/toe H2
elseif %fScenario% eq 1 then
     imFacSubsiCapCostTech("PC","TELC") = 0;
     imFacSubsiCapCostTech("CH","TELC") = 0;
     imFacSubsiCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;
     imGrantCapCostTech("PC","TELC") = 1;                        !!kUS$2015 per vehicle
     imGrantCapCostTech("CH","TELC") = 0;                        !!kUS$2015/toe-year for Industry sectors
     imGrantCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 90;        !!US$2015/tCO2
     imSubsiCapCostFuel("HOU","ELC") = 0;                        !!kUS$2015/toe
     imSubsiCapCostFuel(SBS,"ELC")$INDSE1(SBS) = 0;              !!kUS$2015/toe
     imFacSubsiCapCostSupply("PG",PGREN) = 0.1;
     imFacSubsiCapCostSupply("H2P",H2TECH) = 0.2;
     imGrantCapCostSupply("PG",PGREN) = 0;                       !!kUS$2015/kW
     imGrantCapCostSupply("H2P",H2TECH) = 0;                     !!US$2015/toe H2
elseif %fScenario% eq 2 then
     imFacSubsiCapCostTech("PC","TELC") = 0;
     imFacSubsiCapCostTech("CH","TELC") = 0.40;
     imFacSubsiCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;
     imGrantCapCostTech("PC","TELC") = 9;                        !!kUS$2015 per vehicle
     imGrantCapCostTech("CH","TELC") = 0;                        !!kUS$2015/toe-year for Industry sectors
     imGrantCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 90;        !!US$2015/tCO2
     imSubsiCapCostFuel("HOU","ELC") = 0;                        !!kUS$2015/toe
     imSubsiCapCostFuel(SBS,"ELC")$INDSE1(SBS) = 0;              !!kUS$2015/toe
     imFacSubsiCapCostSupply("PG",PGREN) = 0.3;
     imFacSubsiCapCostSupply("H2P",H2TECH) = 0.4;
     imGrantCapCostSupply("PG",PGREN) = 0;                       !!kUS$2015/kW
     imGrantCapCostSupply("H2P",H2TECH) = 0;                     !!US$2015/toe H2
elseif %fScenario% eq 3 then
     imFacSubsiCapCostTech("PC","TELC") = 0;
     imFacSubsiCapCostTech("CH","TELC") = 0.10;
     imFacSubsiCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;
     imGrantCapCostTech("PC","TELC") = 7;                        !!kUS$2015 per vehicle
     imGrantCapCostTech("CH","TELC") = 0;                        !!kUS$2015/toe-year for Industry sectors
     imGrantCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 90;        !!US$2015/tCO2
     imSubsiCapCostFuel("HOU","ELC") = 0;                        !!kUS$2015/toe
     imSubsiCapCostFuel(SBS,"ELC")$INDSE1(SBS) = 0;              !!kUS$2015/toe
     imFacSubsiCapCostSupply("PG",PGREN) = 0.3;
     imFacSubsiCapCostSupply("H2P",H2TECH) = 0.3;
     imGrantCapCostSupply("PG",PGREN) = 0;                       !!kUS$2015/kW
     imGrantCapCostSupply("H2P",H2TECH) = 0;                     !!US$2015/toe H2
elseif %fScenario% eq 4 then
     imFacSubsiCapCostTech("PC","TELC") = 0;
     imFacSubsiCapCostTech("CH","TELC") = 0;
     imFacSubsiCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 0;
     imGrantCapCostTech("PC","TELC") = 1;                        !!kUS$2015 per vehicle
     imGrantCapCostTech("CH","TELC") = 0;                        !!kUS$2015/toe-year for Industry sectors
     imGrantCapCostTech("DAC",TECH)$(DACTECH(TECH)) = 90;        !!US$2015/tCO2
     imSubsiCapCostFuel("HOU","ELC") = 0;                        !!kUS$2015/toe
     imSubsiCapCostFuel(SBS,"ELC")$INDSE1(SBS) = 0;              !!kUS$2015/toe
     imFacSubsiCapCostSupply("PG",PGREN) = 0.1;
     imFacSubsiCapCostSupply("H2P",H2TECH) = 0.2;
     imGrantCapCostSupply("PG",PGREN) = 0;                       !!kUS$2015/kW
     imGrantCapCostSupply("H2P",H2TECH) = 0;                     !!US$2015/toe H2
endif;
$offtext
*---
** Industry
imShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndCharData(INDSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndCharData(INDSE,"SHR_NSE") - 0.2;
imShrNonSubElecInTotElecDem(runCy,INDSE)$(imShrNonSubElecInTotElecDem(runCy,INDSE)>0.98) = 0.98;
**Domestic - Tertiary
imShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE") - 0.4;
imShrNonSubElecInTotElecDem(runCy,DOMSE)$(imShrNonSubElecInTotElecDem(runCy,DOMSE)>0.98) = 0.98;
**   Macroeconomic
*---
**  Transport Sector
imCapCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"IC",YTIME);
imCapCostTechMin(allCy,TRANSE,TECH,YTIME) = 0.4;
imFixOMCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"FC",YTIME);
imVarCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"VC",YTIME);
*---
**  Industrial Sector
imCapCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"IC");
imCapCostTechMin(allCy,INDSE,TECH,YTIME) = 0.5;
imFixOMCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"FC");
imVarCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"VC");
imUsfEneConvSubTech(runCy,INDSE,TECH,YTIME)  = imDataIndTechnology(INDSE,TECH,"USC");
*imUsfEneConvSubTech(runCy,INDSE,"THCL",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCL","USC") + 0.005 * (ord(YTIME)-11);
*imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCLCCS","USC") + 0.005 * (ord(YTIME)-11);
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
**  CDR
imCapCostTechMin(allCy,"DAC","HTDAC",YTIME) = 0.4;
imCapCostTechMin(allCy,"DAC","H2DAC",YTIME) = 0.2;
imCapCostTechMin(allCy,"DAC","LTDAC",YTIME) = 0.2;
imCapCostTechMin(allCy,"DAC","EWDAC",YTIME) = 0.2;
*---
!!imUsfEneConvSubTech(runCy,INDSE,"THCL",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCL","USC") + 0.005 * (ord(YTIME)-11);
imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCLCCS","USC") + 0.005 * (ord(YTIME)-11);
imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$(ord(YTIME)>50)  = 0.7;

**  Power Generation
*---
table iDataPlantEffByType(allCy,PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;
*---
imPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(runCy,PGALL, YTIME) ;
imPlantEffByType(runCy,"PGH2F",YTIME) = 0.85;
*---
**   Conversion of GW mean power into TWh/y, depending on whether it's a leap year
smGwToTwhPerYear(YTIME) = 8.76 + 0.024 $ (mod(YTIME.val,4) = 0 and mod (YTIME.val,100) <> 0);
*--
