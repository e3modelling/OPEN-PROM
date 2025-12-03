 (core) {#id-core}
=======

Interfaces
----------

**Interface plot missing!**

### Input


----------------------------------------------------------------------------
          &nbsp;                     Description                  Unit      
-------------------------- -------------------------------- ----------------
       VmCapElec \          Electricity generation plants         $GW$      
      (allCy, PGALL,                   capacity                             
          YTIME)                                                            

     VmCapElecTotEst         Estimated Total electricity          $GW$      
            \                    generation capacity                        
      (allCy, YTIME)                                                        

      VmConsFuel \           Consumption of fuels in each        $Mtoe$     
      (allCy, DSBS,          demand subsector, excluding                    
        EF, YTIME)               heat from heatpumps                        

     VmCstCO2SeqCsts              Cost curve for CO2          $US\$2015/tn  
            \                    sequestration costs               of       
      (allCy, YTIME)                                              CO2       
                                                             sequestrated$  

 VmDemFinEneTranspPerFuel       Final energy demand in           $Mtoe$     
            \               transport subsectors per fuel                   
     (allCy, TRANSE,                                                        
        EF, YTIME)                                                          

         VmLft \               Lifetime of technologies         $years$     
      (allCy, DSBS,                                                         
       TECH, YTIME)                                                         

      VmPeakLoad \              Electricity peak load             $GW$      
      (allCy, YTIME)                                                        

      VmPriceElecInd        Electricity index - a function        $1$       
            \                     of industry price                         
      (allCy, YTIME)                                                        

  VmPriceElecIndResConsu         Electricity price to        $US\$2015/KWh$ 
            \                 Industrial and Residential                    
      (allCy, ESET,                   Consumers                             
          YTIME)                                                            

 VmPriceFuelSubsecCarVal    Fuel prices per subsector and    $k\$2015/toe$  
            \                            fuel                               
       (allCy, SBS,                                                         
        EF, YTIME)                                                          

      VmProdElec \              Electricity production           $TWh$      
      (allCy, PGALL,                                                        
          YTIME)                                                            
----------------------------------------------------------------------------

Table: module inputs



### Output


--------------------------------------------------------------
      &nbsp;               Description              Unit      
------------------- ------------------------- ----------------
    VmCarVal \        Carbon prices for all     $US\$2015/tn  
   (allCy, NAP,             countries               CO2$      
      YTIME)                                                  

 VmElecConsHeatPla   Electricity consumed in       $Mtoe$     
         \               heatpump plants                      
   (allCy, DSBS,                                              
      YTIME)                                                  

   VmRenValue \          Renewable value       $US\$2015/KWh$ 
      (YTIME)                                                 
--------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) core

```
Parameters
iNPDL(SBS)                                                 "Number of Polynomial Distribution Lags (PDL) (1)"
iTransfInpGasworks(allCy,EF,YTIME)                         "Transformation Input in Gasworks, Blast Furnances, Briquetting plants (Mtoe)"
iSuppExports(allCy,EF,YTIME)                	           "Supplementary parameter for  exports (Mtoe)"		
iResMargTotAvailCap(allCy,PGRES,YTIME)	                   "Reserve margins on total available capacity and peak load (1)"
iPriceTragets(allCy,SBS,EF,YTIME)	                       "Price Targets	(1)"
iPriceReform(allCy,SBS,EF,YTIME)	                       "Price reformation (1)"
iScenarioPri(WEF,NAP,YTIME)	                               "Scenario prices (KUS$2015/toe)"		
iResNonSubsElecDem(allCy,SBS,YTIME	)	                   "Residuals in Non Substitutable Electricity Demand	(1)"	
iResFuelConsPerSubAndFuel(allCy,SBS,EF,YTIME)	           "Residuals in fuel consumption per subsector and fuel (1)"	
iCarbValYrExog(allCy,ytime)	                               "Carbon value for each year when it is exogenous (US$2015/tn CO2)"
iShrHeatPumpElecCons(allCy,SBS)	                           "Share of heat pump electricity consumption in total substitutable electricity (1)"						 			
iTranfOutGasworks(allCy,EF,YTIME)	                       "Transformation Output from Gasworks, Blast Furnances and Briquetting plants (Mtoe)"	
iNetImp(allCy,EFS,YTIME)                                   "Net imports (Mtoe)"
ODummyObj                                                  "Parameter saving objective function"
```
**Interdependent Parameters**
```
imCGI(allCy,YTIME)                                         "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline)) (1)"
imFPDL(SBS,KPDL)                                           "Polynomial Distribution Lags (PDL) Coefficients per subsector (1)"
imPlantEffByType(allCy,PGALL,YTIME)                        "Plant efficiency per plant type (1)"
imCo2EmiFac(allCy,SBS,EF,YTIME)                            "CO2 emission factors per subsector (kgCO2/kgoe fuel burned)"
imNcon(SBS)                                                "Number of consumers (1)"
imDisFunConSize(allCy,DSBS,rCon)                           "Distribution function of consumer size groups (1)"
imAnnCons(allCy,DSBS,conSet)                               "Annual consumption of the smallest,modal,largest consumer, average for all countries (various)"
                                                                !! For passenger cars (Million km/vehicle)
                                                                !! For other passenger tranportation modes (Mpkm/vehicle)
                                                                !! For goods transport, (Mtkm/vehicle)  
imCumDistrFuncConsSize(allCy,DSBS)                         "Cummulative distribution function of consumer size groups (1)"
imRateLossesFinCons(allCy,EF,YTIME)                        "Rate of losses over Available for Final Consumption (1)"  
imFuelExprts(allCy,EF,YTIME)	                           "Fuel Exports (Mtoe)"
imCO2CaptRate(PGALL)	                                    "Plant CO2 capture rate (1)"		
imEffValueInDollars(allCy,SBS,YTIME)	                   "Efficiency value (US$2015/toe)" 	
imShrNonSubElecInTotElecDem(allCy,SBS)	                   "Share of non substitutable electricity in total electricity demand per subsector (1)"		
imDistrLosses(allCy,EF,YTIME)	                           "Distribution Losses (Mtoe)"		
imFuelImports(allCy,EF,YTIME)	                           "Fuel Imports (Mtoe)"							
imVarCostTech(allCy,SBS,TECH,YTIME)	                       "Variable Cost of technology ()"
                                                                !! For transport (kUS$2015/vehicle)
                                                                !! For Industrial sectors, except Iron and Steel (US$2015/toe-year)
                                                                !! For Iron and Steel  (US$2015/tn-of-steel)
                                                                !! For Domestic sectors  (US$2015/toe-year)
imFixOMCostTech(allCy,SBS,TECH,YTIME)                        "Fixed O&M cost of technology (US$2015/toe-year)"                                   
                                                                !! Fixed O&M cost of technology for Transport (kUS$2015/vehicle)
                                                                !! Fixed O&M cost of technology for Industrial sectors-except Iron and Steel (US$2015/toe-year)"                                            
                                                                !! Fixed O&M cost of technology for Iron and Steel (US$2015/tn-of-steel)"                                          
                                                                !! Fixed O&M cost of technology for Domestic sectors (US$2015/toe-year)"
imUsfEneConvSubTech(allCy,SBS,TECH,YTIME)                    "Useful Energy Conversion Factor per subsector and technology (1)"
imCapCostTech(allCy,SBS,TECH,YTIME)                          "Capital Cost of technology (various)"
                                                                !! - For transport is expressed in kUS$2015 per vehicle
                                                                !! - For Industrial sectors (except Iron and Steel) is expressed in kUS$2015/toe-year
                                                                !! - For Iron and Steel is expressed in kUS$2015/tn-of-steel
                                                                !! - For Domestic Sectors is expressed in kUS$2015/toe-year
imFuelConsPerFueSub(allCy,SBS,EF,YTIME)	                   "Fuel consumption per fuel and subsector (Mtoe)"
smGwToTwhPerYear(YTIME)                                    "convert GW mean power into TWh/y, depending on whether it's a leap year"
;
Equations
```
*** Miscellaneous'
```
qDummyObj                                                  "Define dummy objective function"
;
Variables
```
**Interdependent Variables**
*** Miscellaneous
```
vDummyObj                                                  "Dummy maximisation variable (1)"
VmElecConsHeatPla(allCy,DSBS,YTIME)                        "Electricity consumed in heatpump plants (Mtoe)"
;
Positive Variables
VmCarVal(allCy,NAP,YTIME)                                  "Carbon prices for all countries (US$2015/tn CO2)"
VmRenValue(YTIME)                                          "Renewable value (US$2015/KWh)"
;
Scalars
smTWhToMtoe                                                "TWh to Mtoe conversion factor" /0.086/
smElecToSteRatioChp                                        "Technical maximum of electricity to steam ratio in CHP plants" /2.5/
sIter                                                      "time step iterator" /0/
sSolverTryMax                                              "maximum attempts to solve each time step" /%SolverTryMax%/
sModelStat                                                 "helper parameter for solver status"
smFracElecPriChp                                           "Fraction of Electricity Price at which a CHP sells electricity to network" /0/
sCY                                                        "country iterator" /0/
sUnitToKUnit                                               "units to Kilo units conversion" /1000/
epsilon6                                                    "A small number of magnitude 6" /1e-6/
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* Define dummy objective function
```
$IFTHEN.calib %Calibration% == Calibration
qDummyObj(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy))).. vDummyObj =e=
SQRT(SUM((DSBS,TECH)$(SECTTECH(DSBS,TECH)and TECHtoEF(TECH,EF) and (INDDOM(DSBS))), SQR(imFuelConsPerFueSub(allCy,DSBS,EF,YTIME)-VmConsFuel(allCy,DSBS,EF,YTIME)))) +
SQRT(SUM((DSBS,TECH)$(SECTTECH(DSBS,TECH)and TECHtoEF(TECH,EF) and (TRANSE(DSBS))), SQR(VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)-imFuelConsPerFueSub(allCy,TRANSE,EF,YTIME)))) +
0;
$ELSEIF.calib %Calibration% == MatCalibration
qDummyObj(allCy,YTIME)$(TIME(YTIME) and runCy(allCy)).. 
  vDummyObj 
      =e=
  SUM(
    (PGALL),
    SQR(
      V04SharePowPlaNewEq(allCy,PGALL,YTIME) - 
      t04SharePowPlaNewEq(allCy,PGALL,YTIME)
    )
  );
$ELSE.calib qDummyObj.. vDummyObj =e= 1;
$ENDIF.calib
```

```
table imActv(YTIME,allCy,SBS) "Sector activity (various)"
                              !! main sectors (Billion US$2015) 
                              !! bunkers and households (1)
                              !! transport (Gpkm, or Gvehkm or Gtkm)
$ondelim
$include "./iActv.csvr"
$offdelim
;
table imTransChar(allCy,TRANSPCHAR,YTIME) "km per car, passengers per car and residuals for passenger cars market extension ()"
$ondelim
$include "./iTransChar.csv"
$offdelim
;
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
parameter imDisc(allCy,SBS,YTIME) "Discount rates per subsector for all countries ()" ;
imDisc(runCy,SBS,YTIME) = iDiscData(SBS);
imDisc(runCy,"PC",YTIME) = 0.11;
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
imCo2EmiFac(runCy,SBS,EF,YTIME) = iCo2EmiFacAllSbs(EF);
imCo2EmiFac(runCy,"IS","HCL",YTIME) = iCo2EmiFacAllSbs("SLD"); !! This is the assignment for coke
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
parameter iConsSizeDistHeat(conSet)               "Consumer sizes for district heating (1)"
/
smallest 0.425506805,
modal    0.595709528,
largest  0.833993339
/;
table imInstCapPastNonCHP(allCy,PGALL,YTIME)        "Installed Non-CHP capacity past (GW)"
$ondelim
$include"./iInstCapPastNonCHP.csv"
$offdelim
;
table imInstCapPastCHP(allCy,EF,YTIME)        "Installed CHP capacity past (GW)"
$ondelim
$include"./iInstCapPastCHP.csv"
$offdelim
;
table imFuelPrice(allCy,SBS,EF,YTIME)	 "Prices of fuels per subsector (k$2015/toe)"
$ondelim
$include"./iFuelPrice.csv"
$offdelim
;
table imPriceFuelsIntBase(WEF,YTIME)	              "International Fuel Prices USED IN BASELINE SCENARIO ($2015/toe)"
$ondelim
$include"./iPriceFuelsIntBase.csv"
$offdelim
;
table iSuppExports(allCy,EF,YTIME)	                   "Supplementary parameter for  exports (Mtoe)"		
$ondelim
$include"./iSuppExports.csv"
$offdelim
;
table imPriceFuelsInt(WEF,YTIME)                      "International Fuel Prices ($2015/toe)"
$ondelim
$include"./iPriceFuelsInt.csv"
$offdelim
;
table imPriceElecInd(allCy,YTIME)                      "Electricity power to steam ratio"
$ondelim
$include"./iDataElecInd.csv"
$offdelim
;
parameter imImpExp(allCy,EFS,YTIME)	              "Imports of exporting countries usually zero (1)" ;
imImpExp(runCy,EFS,YTIME) = 0;
parameter imTotFinEneDemSubBaseYr(allCy,SBS,YTIME)    "Total Final Energy Demand per subsector in Base year (Mtoe)";
table imDataTransTech (TRANSE, TECH, ECONCHAR, YTIME)   "Technoeconomic characteristics of transport (various)"
$ondelim
$include"./iDataTransTech.csv"
$offdelim
;
table imDataIndTechnology(INDSE,TECH,ECONCHAR)          "Technoeconomic characteristics of industry (various)"
            IC      FC      VC      LFT USC
IS.THCL      0.32196 6.8     1.36    25  0.5
IS.THCLCCS   0.34772 6.256   1.36    25  0.5
IS.TLGN      0.48295 10.2    2.04    25  0.5
IS.TLPG      0.48295 10.2    2.04    25  0.72
IS.TKRS      0.48295 10.2    2.04    25  0.72
IS.TGDO      0.48295 10.2    2.04    25  0.72
IS.TRFO      0.48295 10.2    2.04    25  0.72
IS.TOLQ      0.48295 10.2    2.04    25  0.72
IS.TNGS      0.48295 10.2    2.04    25  0.8
IS.TNGSCCS   0.52159 9.38    2.04    25  0.8
IS.TOGS      0.48295 10.2    2.04    25  0.8
IS.TBMSWAS   0.48295 10.2    2.04    25  0.5
IS.TELC      0.29367 6.8     1.36    25  0.97
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
NF.THEATPUMP 4.94477 119.819         30  1.848
NF.TH2F      4.94477 119.819 41.1163 30  0.97
CH.THCL      0.53294 5.44            25  0.5
CH.THCLCCS   0.69282 5.44            25  0.5
CH.TLGN      0.53294 5.44            25  0.5
CH.TLPG      0.44411 5.44            25  0.72
CH.TKRS      0.44411 5.44            25  0.72
CH.TGDO      0.44411 5.44            25  0.72
CH.TRFO      0.44411 5.44            25  0.72
CH.TOLQ      0.44411 5.44            25  0.72
CH.TNGS      0.35529 5.44            25  0.8
CH.TNGSCCS   0.46188 5.44            25  0.8
CH.TOGS      0.35529 5.44            25  0.8
CH.TBMSWAS   0.53294 5.44            25  0.5
CH.TELC      0.476   5.44            25  0.97
CH.THEATPUMP 0.68398 10.3404         25  1.848
CH.TH2F      3.13528 94.0585 41.1163 25  0.97
BM.THCL      4.41477 3.2096          30  0.5
BM.THCLCCS   5.25357 3.8515          30  0.5
BM.TLGN      4.41477 3.2096          30  0.5
BM.TLPG      3.67898 3.2096          30  0.72
BM.TKRS      3.67898 3.2096          30  0.72
BM.TGDO      3.67898 3.2096          30  0.72
BM.TRFO      3.67898 3.2096          30  0.72
BM.TOLQ      3.67898 3.2096          30  0.72
BM.TNGS      2.94318 3.2096          30  0.8
BM.TNGSCCS   3.50238 3.8515          30  0.8
BM.TOGS      2.94318 3.2096          30  0.8
BM.TBMSWAS   4.41477 3.2096          30  0.5
BM.TELC      3.808   3.2096          30  0.97
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
OI.THEATPUMP 1.21884 2.66781         20  1.68
OI.TH2F      2.43133 68.3668 41.1163 25  0.97
;
imDataIndTechnology(INDSE,TECH,"IC") = imDataIndTechnology(INDSE,TECH,"IC") * 1.3;
imDataIndTechnology(INDSE,TECH,"FC") = imDataIndTechnology(INDSE,TECH,"FC") * 1.3;
imDataIndTechnology(INDSE,TECH,"VC") = imDataIndTechnology(INDSE,TECH,"VC") * 1.3;
imDataIndTechnology(INDSE,"TBGDO",ECONCHAR) = imDataIndTechnology(INDSE,"TGDO",ECONCHAR);
imDataIndTechnology(INDSE,"TBMSWAS",ECONCHAR) = imDataIndTechnology("IS","TBMSWAS",ECONCHAR);
imDataIndTechnology(INDSE,"TSTE",ECONCHAR) = imDataIndTechnology(INDSE,"THCL",ECONCHAR);
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
SE.TBMSWAS    0.323544 10.88           20  0.5
SE.TELC       0.3      8.976           12  0.97
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
AG.TBMSWAS    0.323544 10.88           20  0.5
AG.TELC       0.3      8.976           12  0.97
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
HOU.TBMSWAS   0.323544 10.88           20  0.5
HOU.TELC      0.3      8.976           12  0.97
HOU.THEATPUMP 0.432    12.9254         20  1.848
;
imDataDomTech(DOMSE,TECH,"IC") = imDataDomTech(DOMSE,TECH,"IC") * 1.3;
imDataDomTech(DOMSE,TECH,"FC") = imDataDomTech(DOMSE,TECH,"FC") * 1.3;
imDataDomTech(DOMSE,TECH,"VC") = imDataDomTech(DOMSE,TECH,"VC") * 1.3;
imDataIndTechnology(INDSE,"TGSL",ECONCHAR) = imDataDomTech("SE","TGSL",ECONCHAR);
imDataDomTech(DOMSE,"TSTE",ECONCHAR) = imDataDomTech(DOMSE,"THCL",ECONCHAR);
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
imDataNonEneSec(NENSE,TECH,"IC") = imDataNonEneSec(NENSE,TECH,"IC") * 1.3;
imDataNonEneSec(NENSE,TECH,"FC") = imDataNonEneSec(NENSE,TECH,"FC") * 1.3;
imDataNonEneSec(NENSE,TECH,"VC") = imDataNonEneSec(NENSE,TECH,"VC") * 1.3;
imDataNonEneSec(NENSE,"TSTE",ECONCHAR) = imDataNonEneSec(NENSE,"THCL",ECONCHAR);
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
table iInitConsSubAndInitShaNonSubElec(DOMSE,Indu_Scon_Set)      "Initial Consumption per Subsector and Initial Shares of Non Substitutable Electricity in Total Electricity Demand (Mtoe)"
     BASE   SHR_NSE SH_HPELC
SE   1.8266 0.9     0.00001
HOU  11.511 0.9     0.00001
AG   0.2078 0.9     0.00001
;
iShrHeatPumpElecCons(runCy,INDSE) = iIndCharData(INDSE,"SH_HPELC");
iShrHeatPumpElecCons(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SH_HPELC");
imFuelExprts(runCy,EFS,YTIME) = iSuppExports(runCy,EFS,YTIME);
imNcon(TRANSE)$(sameas(TRANSE,"PC") or sameas(TRANSE,"GU")) = 10;      !! 11 different consumer size groups for cars and trucks
imNcon(TRANSE)$(not (sameas(TRANSE,"PC") or sameas(TRANSE,"GU"))) = 1; !! 2 different consumer size groups for inland navigation, trains, busses and aviation
imNcon(INDSE) = 10;                                                    !! 11 different consumer size groups for industrial sectors
imNcon(DOMSE) = 10;                                                    !! 11 different consumer size groups for domestic and tertiary sectors
imNcon(NENSE) = 10;                                                    !! 11 different consumer size groups for non energy uses
imNcon("BU") = 2;                                                      !! ... except bunkers .
imNcon("DAC") = 1;                                                      !! 
imAnnCons(runCy,'PC','smallest') = 0.5 * 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
imAnnCons(runCy,'PC' ,'modal') = 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
imAnnCons(runCy,'PC' ,'largest') = 4 * 0.952 * imTransChar(runCy,"KM_VEH","%fBaseY%") * 1000 * 1E-6;
imAnnCons(runCy,'GU','smallest') = 0.5 * 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%")* 1000 * 2 / 3  * 1E-6;
imAnnCons(runCy,'GU','modal')    = 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2  * 1E-6;
imAnnCons(runCy,'GU','largest')  = 4 * 0.706 * imTransChar(runCy,"KM_VEH_TRUCK","%fBaseY%") * 1000 * 2 * 10  * 1E-6;
imAnnCons(runCy,'PA','smallest') = 40000 * 50 * 1E-6;
imAnnCons(runCy,'PA','modal')    = 400000 * 1E-6;
imAnnCons(runCy,'PA','largest')  = 800000 * 300 * 1E-6;
imAnnCons(runCy,'PB',"smallest") = 20000 * 5 * 1E-6;
imAnnCons(runCy,'PB',"modal")    = 50000 * 15 * 1E-6;
imAnnCons(runCy,'PB',"largest")  = 200000 * 50 * 1E-6;
imAnnCons(runCy,'PT',"smallest") = 50000 * 50 * 1E-6;
imAnnCons(runCy,'PT',"modal")    = 200000 * 150 * 1e-6;
imAnnCons(runCy,'PT',"largest")  = 400000 * 500 * 1E-6;
imAnnCons(runCy,'GT',"smallest") = 50000 * 20 * 1E-6;
imAnnCons(runCy,'GT',"modal")    = 200000 * 200 * 1e-6;
imAnnCons(runCy,'GT',"largest")  = 400000 * 500 * 1E-6;
imAnnCons(runCy,'PN',"smallest") = 10000 * 50 * 1E-6;
imAnnCons(runCy,'PN',"modal")    = 50000 * 100 * 1e-6;
imAnnCons(runCy,'PN',"largest")  = 100000 * 500 * 1E-6;
imAnnCons(runCy,'GN',"smallest") = 10000 * 20 * 1E-6;
imAnnCons(runCy,'GN',"modal")    = 50000 * 300 * 1e-6;
imAnnCons(runCy,'GN',"largest")  = 100000 * 1000 * 1E-6;
imAnnCons(runCy,INDSE,"smallest") = 0.2  ;
imAnnCons(runCy,INDSE,"largest") = 0.9 ;
imAnnCons(runCy,"IS","modal") = 0.587;
imAnnCons(runCy,INDSE,"modal")$(not sameas(INDSE,"IS")) = 0.487;
imAnnCons(runCy,DOMSE,"smallest") = iConsSizeDistHeat("smallest")  ;
imAnnCons(runCy,DOMSE,"largest") = iConsSizeDistHeat("largest") ;
imAnnCons(runCy,DOMSE,"modal") = iConsSizeDistHeat("modal");
imAnnCons(runCy,NENSE,"smallest") = 0.2  ;
imAnnCons(runCy,NENSE,"largest")  = 0.9 ;
imAnnCons(runCy,NENSE,"modal") = 0.487 ;
imAnnCons(runCy,"BU","smallest") = 0.2 ;
imAnnCons(runCy,"BU","largest") = 1 ;
imAnnCons(runCy,"BU","modal") = 0.5 ;
imAnnCons(runCy,"DAC","smallest") = 0.2 ;
imAnnCons(runCy,"DAC","largest") = 1 ;
imAnnCons(runCy,"DAC","modal") = 0.5 ;
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
imCumDistrFuncConsSize(runCy,DSBS) = sum(rCon, imDisFunConSize(runCy,DSBS,rCon));
imCGI(allCy,YTIME) = 1;
table iDataDistrLosses(allCy,EF,YTIME)	     "Data for Distribution Losses (Mtoe)"
$ondelim
$include"./iDataDistrLosses.csv"
$offdelim
;
imDistrLosses(runCy,EFS,YTIME) = iDataDistrLosses(runCy,EFS,YTIME);
table imFuelCons(allCy,SBS,EF,YTIME)	      "Fuel consumption (Mtoe)"
$ondelim
$include"./iFuelCons.csv"
$offdelim
;
imFuelConsPerFueSub(runCy,SBS,EF,YTIME) = imFuelCons(runCy,SBS,EF,YTIME);
imFuelConsPerFueSub(runCy,"BU",EF,YTIME) = -imFuelConsPerFueSub(runCy,"BU",EF,YTIME);
imCO2CaptRate(PGALL)$CCS(PGALL) = 0.90; 
imEffValueInDollars(runCy,SBS,YTIME) = 0;
iScenarioPri(WEF,"NOTRADE",YTIME) = 0;
table iDataImports(allCy,EF,YTIME)	          "Data for imports (Mtoe)"
$ondelim
$include"./iDataImports.csv"
$offdelim
;
imFuelImports(runCy,EFS,YTIME)$(not An(YTIME)) = iDataImports(runCy,EFS,YTIME);
iNetImp(runCy,EFS,YTIME) = iDataImports(runCy,"ELC",YTIME)-iSuppExports(runCy,"ELC",YTIME);
table iEnvPolicies(allCy,POLICIES_SET,YTIME) "Environmental policies on emissions constraints  and subsidy on renewables (Mtn CO2)"
$ondelim
$include"./iEnvPolicies.csv"
$offdelim
;
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
table iMatrFactorData(DSBS,TECH,YTIME)          "Maturity factor per technology and subsector (1)"
$ondelim
$include"./iMatrFactorData.csv"
$offdelim
;
iMatrFactorData(DSBS,TECH,YTIME)$(TRANSE(DSBS) or INDSE(DSBS) or DOMSE(DSBS)) = 1;
iMatrFactorData(DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and (INDSE(DSBS)) and CCSTECH(ITECH)) = 1;
iMatrFactorData(DSBS,TECH,YTIME)$(sameas(DSBS, "PC")$SECTTECH(DSBS,TECH)) = 1;
$IFTHEN.calib %MatFacCalibration% == off
parameter imMatrFactor(allCy,DSBS,TECH,YTIME)   "Maturity factor per technology and subsector for all countries (1)";
imMatrFactor(runCy,DSBS,TECH,YTIME) = iMatrFactorData(DSBS,TECH,YTIME);                                          
imMatrFactor(runCy,DSBS,TECH,YTIME)$(imMatrFactor(runCy,DSBS,TECH,YTIME)=0) = 0.000001;
imMatrFactor(runCy,DSBS,"TGDO",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 0.5;
imMatrFactor(runCy,DSBS,"TGSL",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 0.5;
imMatrFactor(runCy,DSBS,"TNGSCCS",YTIME)$((ord(YTIME) > 11) and INDSE(DSBS)) = 1;
imMatrFactor(runCy,DSBS,"THCLCCS",YTIME)$((ord(YTIME) > 11) and INDSE(DSBS)) = 1;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 3;
imMatrFactor("CHA",DSBS,"TELC",YTIME)$((ord(YTIME) > 11) and TRANSE(DSBS)) = 8;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 30 and TRANSE(DSBS)) = 8;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 50 and TRANSE(DSBS)) = 15;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 50 and TRANSE(DSBS)) = 15;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 11 and DOMSE(DSBS)) = 20;
imMatrFactor(runCy,DSBS,"TBMSWAS",YTIME)$(ord(YTIME) > 11 and DOMSE(DSBS)) = 0.001;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) < 21 and INDSE(DSBS)) = 0;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) > 21 and INDSE(DSBS)) = 2;
imMatrFactor(runCy,DSBS,"TH2F",YTIME)$(ord(YTIME) > 40 and INDSE(DSBS)) = 2;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
imMatrFactor(runCy,DSBS,"TELC",YTIME)$(ord(YTIME) > 40 and TRANSE(DSBS)) = 11;
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
imShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndCharData(INDSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,INDSE)  = iIndCharData(INDSE,"SHR_NSE") - 0.2;
imShrNonSubElecInTotElecDem(runCy,INDSE)$(imShrNonSubElecInTotElecDem(runCy,INDSE)>0.98) = 0.98;
imShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE");
imShrNonSubElecInTotElecDem(runCy,DOMSE) = iInitConsSubAndInitShaNonSubElec(DOMSE,"SHR_NSE") - 0.4;
imShrNonSubElecInTotElecDem(runCy,DOMSE)$(imShrNonSubElecInTotElecDem(runCy,DOMSE)>0.98) = 0.98;
imCapCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"IC",YTIME);
imFixOMCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"FC",YTIME);
imVarCostTech(runCy,TRANSE,TECH,YTIME) = imDataTransTech(TRANSE,TECH,"VC",YTIME);
imCapCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"IC");
imFixOMCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"FC");
imVarCostTech(runCy,INDSE,TECH,YTIME) = imDataIndTechnology(INDSE,TECH,"VC");
imUsfEneConvSubTech(runCy,INDSE,TECH,YTIME)  = imDataIndTechnology(INDSE,TECH,"USC");
imUsfEneConvSubTech(runCy,INDSE,"THCL",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCL","USC") + 0.005 * (ord(YTIME)-11);
imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCLCCS","USC") + 0.005 * (ord(YTIME)-11);
imFixOMCostTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"FC");
imVarCostTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"VC");
imUsfEneConvSubTech(runCy,DOMSE,TECH,YTIME) = imDataDomTech(DOMSE,TECH,"USC");
imFixOMCostTech(runCy,NENSE,TECH,YTIME)= imDataNonEneSec(NENSE,TECH,"FC");
imVarCostTech(runCy,NENSE,TECH,YTIME) = imDataNonEneSec(NENSE,TECH,"VC");
imUsfEneConvSubTech(runCy,NENSE,TECH,YTIME) = imDataNonEneSec(NENSE,TECH,"USC");
!!imUsfEneConvSubTech(runCy,INDSE,"THCL",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCL","USC") + 0.005 * (ord(YTIME)-11);
imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$AN(YTIME)  = imDataIndTechnology(INDSE,"THCLCCS","USC") + 0.005 * (ord(YTIME)-11);
imUsfEneConvSubTech(runCy,INDSE,"THCLCCS",YTIME)$(ord(YTIME)>50)  = 0.7;
table iDataPlantEffByType(allCy,PGALL, YTIME)   "Data for plant efficiency per plant type"
$ondelim
$include "./iDataPlantEffByType.csv"
$offdelim
;
imPlantEffByType(runCy,PGALL,YTIME) = iDataPlantEffByType(runCy,PGALL, YTIME) ;
imPlantEffByType(runCy,"PGH2F",YTIME) = 0.97;
smGwToTwhPerYear(YTIME) = 8.76 + 0.024 $ (mod(YTIME.val,4) = 0 and mod (YTIME.val,100) <> 0);
```

* Calculation of polynomial distribution lags coefficients
```
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         imFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;
model openprom / all /;
option i01Pop:2:0:6;
display i01Pop;
display imDisc;
display TF;
display TFIRST;
display runCy;
display i08WgtSecAvgPriFueCons;
display imVarCostTech;
```
*VARIABLE INITIALISATION*
```
imTransChar(runCy,"RES_MEXTF",YTIME) = 0.04;
imTransChar(runCy,"RES_MEXTV",YTIME) = 0.04;
```
**Interdependent Variables**
```
VmRenValue.FX(YTIME)$(ord(YTIME)<20) = 0 ;
VmRenValue.FX(YTIME)$(ord(YTIME)>=20 and ord(YTIME)<50) = (ord(YTIME)-20) * 100;
VmRenValue.FX(YTIME)$(ord(YTIME)>=40) = 2000;
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-imShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);
VmElecConsHeatPla.FX(runCy,INDDOM,YTIME) = 1E-7;
VmCarVal.FX(runCy,"TRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
VmCarVal.FX(runCy,"NOTRADE",YTIME) = iCarbValYrExog(runCy,YTIME);
VmCstCO2SeqCsts.L(runCy,YTIME)=1;
VmCstCO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) = i06ElastCO2Seq(runCy,"mc_b");
VmPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$SECtoEF(SBS,EF) = 1.5;
VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) = 1;
VmPriceFuelSubsecCarVal.LO(runCy,SBS,"H2F",YTIME) = 1E-6;
$IFTHEN %link2MAgPIE% == on 
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BMSWAS",YTIME)$(An(YTIME)) = iPricesMagpie(runCy,SBS,YTIME);
$ENDIF
VmPriceFuelSubsecCarVal.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF)$(not HEATPUMP(EF)) and DATAY(YTIME)) = imFuelPrice(runCy,SBS,EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF)$(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
VmPriceFuelSubsecCarVal.FX(runCy,"PG","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"H2P","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP","NUC",YTIME) = 0.02; !! fixed price for nuclear fuel to 25Euro/toe
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"MET",YTIME)$(not An(YTIME)) = 1; !! fixed price methanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"ETH",YTIME)$(not An(YTIME)) = 1; !! fixed price for ethanol
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"BGDO",YTIME)$DATAY(YTIME) = 0.5; !! fixed price for biodiesel
VmPriceFuelSubsecCarVal.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"H2P",EF,YTIME)$(SECtoEF("H2P",EF)$DATAY(YTIME)) = imFuelPrice(runCy,"OI",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP",EF,YTIME)$(SECtoEF("STEAMP",EF)$DATAY(YTIME)) = imFuelPrice(runCy,"PG",EF,YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,"STEAMP","CRO",YTIME)$(not DATAY(YTIME)) = imFuelPrice(runCy,"PG","GDO","%fBaseY%") / 1.5;
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"STE",YTIME)$(SECtoEF(SBS,"STE") and DATAY(YTIME)) = imFuelPrice(runCy,"OI","ELC",YTIME);
VmPriceFuelSubsecCarVal.FX(runCy,SBS,"GEO",YTIME) = 0;
VmPriceElecInd.FX(runCy,YTIME)$DATAY(YTIME) = imPriceElecInd(runCy,YTIME);
VmLft.L(runCy,DSBS,TTECH,YTIME) = 10;
VmLft.FX(runCy,"PC",TTECH,YTIME)$(DATAY(YTIME) and SECTTECH("PC",TTECH)) = i01TechLft(runCy,"PC",TTECH,YTIME);
VmLft.FX(runCy,DSBS,TECH,YTIME)$(SECTTECH(DSBS,TECH) and (not sameas(DSBS,"PC"))) = i01TechLft(runCy,DSBS,TECH,YTIME);
VmLft.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
openprom.optfile=1;
openprom.scaleopt=1;
```

```

hour            "Segments of hours in a year (250,1250,...,8250)" /h0*h8/
posElast / a /
negElast / b1, b2, c, b3, b4, c1, c2, c3, c4, c5 /
conSet       Consumer size groups related to space heating
/
smallest
modal
largest
/
eSet         Electricity consumers used for average electricity price calculations /i,r,c,t/
iSet(eSet)   Industrial consumer /i/
rSet(eSet)   Residential consumer /r/
cSet(eSet)   Commercial consumer /c/
tSet(eSet)   Transport consumer /t/
rCon         counter for the number of consumers              /0,1*19/
nSet         auxiliary counter for the definition of Vr       /b1*b20/
kpdl         counter for Polynomial Distribution Lag          /a1*a6/
rc                                                            /1*3/
rcc                                                           /rcc1*rcc10/
ALLSBS   All sectors
/
IS    "Iron and Steel"
NF    "Non Ferrous Metals"
CH    "Chemicals"
BM    "Non Metallic Minerals"
PP    "Paper and Pulp"
FD    "Food Drink and Tobacco"
EN    "Engineering"
TX    "Textiles"
OE    "Ore Extraction"
OI    "Other Industrial sectors"
SE    "Services and Trade"
AG    "Agriculture, Fishing, Forestry etc."
HOU   "Households"
PC    "Passenger Transport - Cars"
PB    "Passenger Transport - Busses"
PT    "Passenger Transport - Rail"
PN    "Passenger Transport - Inland Navigation"
PA    "Passenger Transport - Aviation"
GU    "Goods Transport - Trucks"
GT    "Goods Transport - Rail"
GN    "Goods Transport - Inland Navigation"
BU    "Bunkers"
PCH   "Petrochemicals Industry"
NEN   "Other Non Energy Uses"
PG    "Power and Steam Generation"
H2P   "Hydrogen Production"
STEAMP "Steam Production"
H2INFR "Hydrogen storage and delivery"
LGN_PRD_CH4    "Lignite Primary Production, related with CH4"
HCL_PRD_CH4    "Hard coal primary production, related with CH4"
GAS_PRD_CH4    "Natural gas primary production, related with CH4"
TERT_CH4       "Natural gas distribution in tertiary, related with CH4"
TRAN_CH4       "Gasoline in transport, related with CH4"
AG_CH4         "Agriculture activities, related with CH4"
SE_CH4         "Waste used in housing and water charges in services, related with CH4"
TRAN_N2O       "Oil activities in transport, related with N2O"
TX_N2O         "Textile activities, related with N2O"
AG_N2O         "Agriculture activities, related with N2O"
OI_HFC         "Other Industry activities, related with HFC"
OI_PFC         "Semiconductor manufacturing, related with PFC"
NF_PFC         "Aluminium production, related with PFC"
BM_CO2         "Non metallic minerals production, related with CO2"
PG_SF6         "Electricity production, related with SF6"
OI_SF6         "Other Industries activities, related with SF6"
DAC            "Direct Air Capture"
/
SBS(ALLSBS)          Model Subsectors
/
IS    "Iron and Steel"
NF    "Non Ferrous Metals"
CH    "Chemicals"
BM    "Non Metallic Minerals"
PP    "Paper and Pulp"
FD    "Food Drink and Tobacco"
EN    "Engineering"
TX    "Textiles"
OE    "Ore Extraction"
OI    "Other Industrial sectors"
SE    "Services and Trade"
AG    "Agriculture, Fishing, Forestry etc."
HOU   "Households"
PC    "Passenger Transport - Cars"
PB    "Passenger Transport - Busses"
PT    "Passenger Transport - Rail"
PN    "Passenger Transport - Inland Navigation"
PA    "Passenger Transport - Aviation"
GU    "Goods Transport - Trucks"
GT    "Goods Transport - Rail"
GN    "Goods Transport - Inland Navigation"
BU    "Bunkers"
PCH   "Petrochemicals Industry"
NEN   "Other Non Energy Uses"
PG    "Power and Steam Generation"
H2P   "Hydrogen production"
STEAMP "Steam Production"
H2INFR "Hydrogen storage and delivery"
DAC    "Direct Air Capture"
/
SCT_GHG(ALLSBS)      Aggregate Sectors used in non-energy related GHG emissions
/
LGN_PRD_CH4    "Lignite Primary Production, related with CH4"
HCL_PRD_CH4    "Hard coal primary production, related with CH4"
GAS_PRD_CH4    "Natural gas primary production, related with CH4"
TERT_CH4       "Natural gas distribution in tertiary, related with CH4"
TRAN_CH4       "Gasoline in transport, related with CH4"
AG_CH4         "Agriculture activities, related with CH4"
SE_CH4         "Waste used in housing and water charges in services, related with CH4"
TRAN_N2O       "Oil activities in transport, related with N2O"
TX_N2O         "Textile activities, related with N2O"
AG_N2O         "Agriculture activities, related with N2O"
OI_HFC         "Other Industry activities, related with HFC"
OI_PFC         "Semiconductor manufacturing, related with PFC"
NF_PFC         "Aluminium production, related with PFC"
BM_CO2         "Non metallic minerals production, related with CO2"
PG_SF6         "Electricity production, related with SF6"
OI_SF6         "Other Industries activities, related with SF6"
/
POLICIES_set
/
TRADE
NoTrade
OPT
REN
EFF
NONE
RENE_SUBS
BIO_SUBS
BIOM_SUBS
SOLRES_SUBS
exogCV_NPi
exogCV_1_5C
exogCV_2C
exogCV_Calib
/
RegulaPolicies(POLICIES_set) Set of policies entering in the regula falsi loops
/ OPT           Carbon Value for Optimal CO2 permits allocation
  TRADE         Carbon Value for Trade sectors
  REN           Renewable value for renewable target in final demand
  EFF           Efficiency value for energy savings in final demand
  NONE          No policy
/
NAP(Policies_set) National Allocation Plan sector categories
/
Trade    Carbon Value for trading sectors
NoTrade  Carbon Value for non-trading sectors
/
NAPtoALLSBS(NAP,ALLSBS) Energy sectors corresponding to NAP sectors
/
Trade.(FD,EN,TX,OE,OI,NF,CH,IS,BM,PP,PG,BM_CO2,H2P,STEAMP,DAC)
NoTrade.(SE,AG,HOU,PC,PB,PT,PN,PA,GU,GT,GN,BU,PCH,NEN,LGN_PRD_CH4,HCL_PRD_CH4,GAS_PRD_CH4,TERT_CH4,TRAN_CH4,AG_CH4,SE_CH4,TRAN_N2O,TX_N2O,AG_N2O,OI_HFC,OI_PFC,NF_PFC,PG_SF6,OI_SF6,DAC)
/
DSBS(SBS)         All Demand Subsectors         /PC,PT,PA,PB,PN,GU,GT,GN,IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU,PCH,NEN,BU,DAC/
TRANSE(DSBS)      All Transport Subsectors      /PC,PT,PA,PB,PN,GU,GT,GN/
TRANS1(SBS)       All Transport Subsectors      /PC,PT,PA,PB,PN,GU,GT,GN/
TRANP(TRANSE)     Passenger Transport           /PC,PT,PA,PB,PN/
TRANG(TRANSE)     Goods Transport               /GU,GT,GN/
INDSE(DSBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE(DSBS)       Tertiary SubSectors           /SE,AG,HOU/
INDSE1(SBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE1(SBS)       Tertiary SubSectors           /SE,AG,HOU/
HOU(DSBS)         Households                    /HOU/
NENSE(DSBS)       Non Energy and Bunkers        /PCH,NEN,BU/
NENSE1(SBS)       Non Energy and Bunkers        /PCH,NEN,BU/
BUN(DSBS)         Bunkers                       /BU/
INDDOM(DSBS)      Industry and Tertiary         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU/
HOU1(SBS)         Households                     /HOU/
SERV(SBS)         Services                       /SE,AG/
EF           Energy Forms
/
HCL     "Hard Coal, Coke and Other Solids"
LGN     "Lignite"
CRO     "Crude Oil and Feedstocks"
LPG     "Liquefied Petroleum Gas"
GSL     "Gasoline"
KRS     "Kerosene"
GDO     "Diesel Oil"
RFO     "Residual Fuel Oil"
OLQ     "Other Liquids"
NGS     "Natural Gas"
OGS     "Other Gases"
NUC     "Nuclear"
STE     "Steam"
HYD     "Hydro"
WND     "Wind"
SOL     "Solar"
BMSWAS  "Biomass and Waste"
GEO     "Geothermal and other renewable sources eg. Tidal, etc."
MET     "Methanol"
ETH     "Ethanol"
BGDO    "Biodiesel"
BGSL    "Biogasoline"
H2F     "Hydrogen"
ELC     "Electricity"
HTDAC   "High-Temperature DAC"
H2DAC   "High-Temperature H2-fueled DAC"
LTDAC   "Low-Temperature DAC"
EWDAC   "Enhanced-Weathering DAC"
SLD     "Solid Fuels"
GAS     "Gases"
LQD     "All Liquids"
OLQT    "All liquids but GDO, RFO, GSL"
REN     "Renewables except Hydro"
NFF     "Non Fossil Fuels"
NEF     "New energy forms"
HEATPUMP "Low enthalpy heat produced by heatpumps reducing the total final consumption of the sector"
/
HEATPUMP(EF) Heatpumps are reducing the heat requirements of the sector but increasing electricity consumption
/HEATPUMP/
EFA(EF)          Aggregate Energy Forms
/
SLD   "Solid Fuels"
LQD   "Liquids"
OLQT  "All liquids but GDO, RFO, GSL"
GAS   "Gases"
REN   "Renewables except Hydro"
STE   "Steam"
NFF   "Non Fossil Fuels"
NEF   "New energy forms"
/
REFORM(EF) FUELS CONSIDERED IN PRICE REFORM
/
CRO     "Crude Oil and Feedstocks"
LPG     "Liquefied Petroleum Gas"
GSL     "Gasoline"
KRS     "Kerosene"
GDO     "Diesel Oil"
RFO     "Residual Fuel Oil"
OLQ     "Other Liquids"
NGS     "Natural Gas"
OGS     "Other Gases"
/
REFORM1(EF) FUELS CONSIDERED IN PRICE REFORM
/HCL
LGN/
OIL(EF) Liquid fuels in private road transport
/
GSL     "Gasoline"
GDO     "Diesel Oil"
/
EFtoEFA(EF,EFA)  Energy Forms Aggregations (for summary balance report)
/
(HCL,LGN).SLD
(GSL,GDO,RFO,LPG,KRS,OLQ).LQD
(LPG,KRS,OLQ).OLQT
(NGS,OGS).GAS
(WND,SOL,GEO).REN
(HYD,WND,SOL,GEO,NUC,BMSWAS).NFF
(H2F,MET,ETH).NEF
STE.STE
/
WEF              Imported Energy Forms (affecting fuel prices)
/
WHCL    Imported Hard Coal
WCOKE   Imported Coke
WCRO    Imported Crude Oil
WNGS    Imported Natural Gas
WLGN    Lignite for Industry
WGSL    Spot price of gasoline Rotterdam
WGDO    Spot price of diesel Rotterdam
WRFO    Spot price of heavy fuel oil Rotterdam
WH2F
/
WEFMAP(EF,WEF)          Link between Imported Energy Forms and Energy Forms used in Model Subsectors
/(LGN).WLGN
(HCL).WHCL
(NGS,OGS).WNGS
HCL.WCOKE
(GSL,KRS).WGSL
(GDO).WGDO
(RFO).WRFO
(OLQ,LPG).WCRO
/
EFtoWEF(DSBS,EF,WEF) Link between Imported Energy Forms and Energy Forms used in Model Subsectors
EFS(EF)          Energy Forms used in Supply Side
/
LGN
HCL
CRO
GSL
BGSL
GDO
BGDO
RFO
LPG
KRS
OLQ
NGS
OGS
NUC
STE
HYD
BMSWAS
SOL
WND
GEO
ELC
H2F
MET
ETH
/
EFtoEFS(EF,EFS)    Fuel Aggregation for Supply Side
/
LGN.LGN
HCL.HCL
CRO.CRO
GSL.GSL
GDO.GDO
RFO.RFO
LPG.LPG
KRS.KRS
OLQ.OLQ
NGS.NGS
OGS.OGS
NUC.NUC
HYD.HYD
(BGDO,BGSL,ETH,BMSWAS).BMSWAS
SOL.SOL
GEO.GEO
WND.WND
ELC.ELC
MET.MET
H2F.H2F
STE.STE
/
ELCEF(EF)        Electricity                                         /ELC/
H2EF(EF)         Hydrogen                                            /H2F/
STEAM(EFS)       Steam                                               /STE/
TOCTEF(EFS)      Energy forms produced by power plants and boilers   /ELC,STE/
ALTEF(EF)        Alternative Fuels used in transport                 /BGDO,MET,ETH/
ALTMAP(SBS,EF,EF)    Fuels whose prices affect the prices of alternative fuels
/
(PC,GU,PT,PB,GT,GN).MET.GDO
(PC,GU,PT,PB,GT,GN).ETH.GDO
(PC,GU,GN,PN).BGDO.GDO
/
PGEF(EFS)        "Energy forms used for steam production"
PPRODEF(EFS)     Fuels considered in primary production
/
LGN
OLQ
HCL
CRO
HYD
BMSWAS
NUC
SOL
GEO
WND
NGS
/
IMPEF(EFS)       Fuels considered in Imports and Exports
/
LGN
HCL
CRO
GSL
GDO
RFO
LPG
KRS
OLQ
NGS
OGS
ELC
/
TEAALL              Technology progress (Demand Side)
/
ORD   Ordinary
IMP   Improved
/
TECH      Technologies
/
TGSL      "Internal Combustion Engine fueled by Gasoline"
TLPG      "Internal Combustion Engine fueled by Liquified Petroleum Gas"
TGDO      "Internal Combustion Engine fueled by Diesel Oil"
TNGS      "Internal Combustion Engine fueled by Natural Gas"
TELC      "Pure Electirc Engine"
TKRS      "Gas Turbine fueled by Kerosene"
TETH      "Internal Combustion Engine fueled by Ethanol"
TMET      "Methanol (85% gasoline 15% methanol) coming either from ngs or bms"
TBGDO     "Biodiesel internal combustion engine"
TPHEVGSL  "Plug in Hybrid engine - gasoline"
TPHEVGDO  "Plug in Hybrid engine - diesel"
TH2F      "Fuel Cells: Hydrogen"
TCHEVGSL  "conventional Hybrid engine - gasoline"
TCHEVGDO  "conventional Hybrid engine - diesel"
TNGSCCS
TLGN
THCL
THCLCCS
TRFO
TOLQ
TOGS
TSTE
TBMSWAS
THEATPUMP
HTDAC
H2DAC
LTDAC
EWDAC
/
TTECH(TECH)      Transport Technologies
/
TGSL      "Internal Combustion Engine fueled by Gasoline"
TLPG      "Internal Combustion Engine fueled by Liquified Petroleum Gas"
TGDO      "Internal Combustion Engine fueled by Diesel Oil"
TNGS      "Internal Combustion Engine fueled by Natural Gas"
TELC      "Pure Electirc Engine"
TKRS      "Gas Turbine fueled by Kerosene"
TETH      "Internal Combustion Engine fueled by Ethanol"
TPHEVGSL  "Plug in Hybrid engine - gasoline"
TPHEVGDO  "Plug in Hybrid engine - diesel"
TH2F      "Fuel Cells: Hydrogen"
TCHEVGSL  "conventional Hybrid engine - gasoline"
TCHEVGDO  "conventional Hybrid engine - diesel"
/
DACTECH(TECH)     DAC Technologies
/
HTDAC
H2DAC
LTDAC
EWDAC
/
ITECH(TECH)      Industrial - Domestic - Non-energy & Bunkers Technologies 
/
TBGDO
TGDO
TLPG
TKRS  
TNGS
TNGSCCS
TELC    
TLGN
THCL
THCLCCS
TRFO
TOLQ
TOGS
TSTE
TH2F
TGSL
TBMSWAS
/
CCSTECH(ITECH)
/
TNGSCCS
THCLCCS
/
RENEF(TECH)        Renewable technologies in demand side
/
TELC
TPHEVGSL  "Plug in Hybrid engine - gasoline"
TPHEVGDO  "Plug in Hybrid engine - diesel"
TH2F      "Fuel Cells: Hydrogen"
TCHEVGSL  "conventional Hybrid engine - gasoline"
TCHEVGDO  "conventional Hybrid engine - diesel"
TBMSWAS  "Biomass and Waste"
TBGDO    "Biodiesel"
TNGSCCS
THCLCCS
HTDAC
H2DAC
LTDAC
EWDAC
/
TECHtoEF (TECH,EF) Fuels consumed by technologies
/
TGSL.(GSL,BGSL)
TLPG.LPG
TGDO.(GDO,BGDO,RFO)
TNGS.(NGS,OGS)
TNGSCCS.NGS
TELC.ELC
TKRS.KRS
TETH.ETH
TMET.MET
TBGDO.BGDO
TPHEVGSL.(GSL,BGSL,ELC)
TPHEVGDO.(GDO,BGDO,ELC)
TH2F.H2F
TCHEVGSL.(GSL,BGSL)
TCHEVGDO.(GDO,BGDO)     
TLGN.LGN
THCL.HCL
THCLCCS.HCL
TRFO.RFO
TOLQ.OLQ
TOGS.OGS
TSTE.STE
TBMSWAS.BMSWAS
HTDAC.(NGS,ELC)
H2DAC.(H2F,ELC)
LTDAC.ELC
EWDAC.ELC
/
TTECHtoEF(TTECH,EF) Fuels consumed by transport technologies
/
TGSL.(GSL,BGSL)
TLPG.LPG
TGDO.(GDO,BGDO,RFO)
TNGS.(NGS,OGS)
TELC.ELC
TKRS.KRS
TETH.ETH
TPHEVGSL.(GSL,BGSL,ELC)
TPHEVGDO.(GDO,BGDO,ELC)
TH2F.H2F
TCHEVGSL.(GSL,BGSL)
TCHEVGDO.(GDO,BGDO)
/
ITECHtoEF(ITECH,EF) Fuels consumed by industrial technologies
/
TBGDO.BGDO
TGDO.GDO
TLPG.LPG
TKRS.KRS  
TNGS.NGS
TNGSCCS.NGS
TELC.ELC    
TLGN.LGN
THCL.HCL
THCLCCS.HCL
TRFO.RFO
TOLQ.OLQ
TOGS.OGS
TGSL.GSL
TSTE.STE
TH2F.H2F
TBMSWAS.BMSWAS
/
DACTECHtoEF(DACTECH,EF)
/
HTDAC.(NGS,ELC)
H2DAC.(H2F,ELC)
LTDAC.ELC
EWDAC.ELC
/
PLUGIN(TECH) Plug-in hybrids
/
TPHEVGSL
TPHEVGDO
/
CHYBV(TECH) CONVENTIONAL hybrids
/
TCHEVGSL
TCHEVGDO
/
SECTTECH(DSBS,TECH) Link between Model Demand Subsectors and Technologies
/
PC.(TGSL,TLPG,TGDO,TNGS,TELC,TPHEVGSL,TPHEVGDO,TCHEVGSL,TCHEVGDO,TH2F)
PB.(TLPG,TGSL,TGDO,TNGS,TELC,TH2F)
GU.(TLPG,TGSL,TGDO,TNGS,TELC,TCHEVGDO,TH2F)
(PT,GT).(TGDO,TELC)
PA.(TKRS)
(PN,GN).(TGDO,TH2F)
(IS,NF,CH,BM,PP,FD,EN,TX,OE,OI).(TLGN,THCL,TGDO,TGSL,TRFO,TLPG,TKRS,TOLQ,TNGS,TOGS,
                                TELC,TBMSWAS,TSTE,TH2F)
(IS,BM,CH).(TNGSCCS,THCLCCS)
(HOU,AG).(TLPG,TKRS,TGDO,TNGS,TOGS,TBMSWAS,TELC,TSTE)
SE.(TLPG,TKRS,TNGS,TOGS,TELC,TSTE)
BU.(TGDO,TRFO,TKRS)
(PCH,NEN).(TLGN,THCL,TGDO,TRFO,TLPG,TOLQ,TNGS,TOGS)
DAC.(HTDAC,H2DAC,LTDAC,EWDAC)
/
SECtoEF(SBS,EF) Link between Model Subsectors and Energy FORMS
/
PG.(LGN,HCL,GDO,RFO,NGS,OGS,NUC,HYD,BMSWAS,SOL,GEO,WND,H2F)
H2P.(HCL,LGN,RFO,GDO,NGS,OGS,NUC,BMSWAS,SOL,WND,ELC)
STEAMP.(HCL,LGN,GDO,RFO,LPG,KRS,NGS,OGS,OLQ,NUC,GEO,BMSWAS,ELC,H2F)
/
PGALL            Power Generation Plant Types
/
ATHLGN  Advanced thermal monovalent lignite
ATHCOAL Advanced thermal monovalent hard coal
ATHGAS Advanced thermal monovalent natural gas
ATHBMSWAS Advanced thermal monovalent biomass and waste
ATHBMSCCS
ATHOIL Advanced gas turbines (peak devices) diesel oil
PGLHYD Large Hydro Plants
PGSHYD Small Hydro Plants
PGAWND Wind Plants
PGSOL Solar Photovoltaic Plants
PGCSP Advanced Solar Thermal Plants
PGOTHREN Advanced geothermal Plants
PGANUC New Nuclear Designs
ATHCOALCCS Supercritical coal with CCS
ATHLGNCCS Supercritical lignite with CCS
ATHGASCCS Gas turbine combined cycle with CCS
PGAWNO Wind offshore
PGH2F
/
PGCSP(PGALL)
/PGCSP/
CCS(PGALL) Plants which can be equipped with CCS
/
ATHCOALCCS
ATHLGNCCS
ATHGASCCS
ATHBMSCCS
/
NOCCS(PGALL) Plants which can be equipped with CCS but they are not
/
ATHLGN
ATHCOAL
ATHGAS
ATHBMSWAS
/
CCS_NOCCS(PGALL,PGALL) mapping
/
ATHLGNCCS.ATHLGN
ATHCOALCCS.ATHCOAL
ATHGASCCS.ATHGAS
ATHBMSCCS.ATHBMSWAS
/
PGREN(PGALL)    REN PLANTS with Saturation                /PGLHYD,PGSHYD,PGAWND,PGSOL,PGCSP,PGOTHREN,PGAWNO/
PGREN2(PGALL)     Renewable Plants                          /PGLHYD,PGSHYD,PGAWND,PGSOL,PGCSP,PGOTHREN,PGAWNO,PGANUC,ATHCOALCCS,ATHLGNCCS,ATHGASCCS,PGH2F/
PGRENSW(PGALL)   Solar and wind Plants                     /PGSOL,PGCSP,PGAWND,PGAWNO/
PGNREN(PGALL)    Advanced Renewable Plants potential      /PGCSP,PGOTHREN,PGAWNO,ATHBMSWAS/
PGRENEF          Renewable energy forms in power generation  /LHYD,SHYD,WND,WNO,SOL,DPV,BMSWAS,OTHREN/
PGALLtoPGRENEF(PGALL,PGRENEF)     Correspondence between renewable plants and renewable energy forms
/
PGLHYD.LHYD
(PGSHYD).SHYD
(PGAWND).WND
PGAWNO.WNO
(PGSOL,PGCSP).SOL
(PGOTHREN).OTHREN
(ATHBMSWAS,ATHBMSCCS).BMSWAS
/
PGALLtoEF(PGALL,EFS)     Correspondence between plants and energy forms
/
(ATHLGN,ATHLGNCCS).LGN
(ATHCOAL, ATHCOALCCS).HCL
(ATHOIL).GDO
(ATHGAS,ATHGASCCS).NGS
(ATHBMSWAS,ATHBMSCCS).BMSWAS
(PGANUC).NUC
(PGLHYD,PGSHYD).HYD
(PGAWND,PGAWNO).WND
(PGSOL,PGCSP).SOL
(PGOTHREN).GEO
(PGH2F).H2F
/
PGSCRN(PGALL)     New plants involved in endogenous scrapping (these plants are not scrapped)
/
ATHBMSWAS
PGLHYD
PGSHYD
PGAWND
PGSOL
PGCSP
PGANUC
ATHCOALCCS
ATHLGNCCS
ATHGASCCS
PGAWNO
PGOTHREN
ATHBMSCCS
PGH2F
/
EMISS            "Pollutant Emissions"
/
CO2      "Carbon dioxide"
CH4      "Methanio"
N2O      "Nitrogen dioxide"
HFC      "Hydrofluorocarbons"
PFC      "Perfluorinated Compounds "
SF6      "Sulfur Hexafluoride"
/
SCT_GHGtoEMISS(SCT_GHG,EMISS)  Mapping between sectors and emissions
/
(LGN_PRD_CH4,HCL_PRD_CH4,GAS_PRD_CH4,TERT_CH4,TRAN_CH4,AG_CH4,SE_CH4).CH4
(TRAN_N2O,TX_N2O,AG_N2O).N2O
(OI_PFC,NF_PFC).PFC
OI_HFC.HFC
BM_CO2.CO2
(PG_SF6,OI_SF6).SF6
/
CO2SEQELAST Elasticities for CO2 sequestration cost curve
/
POT      MAXIMUM POTENTIAL
mc_a     linear slope
mc_b     initial cost at x=0
mc_c
mc_d
mc_s     speed to transition to exponential
mc_m     value for the ratio of x to potential after which exponential is taking over
/
ETYPES           "Elasticities types"
/a,b1,b2,b3,b4,b5,c,c1,c2,c3,c4,c5,aend,b3end,b4end/
ECONCHAR         "Technical - Economic characteristics for demand technologies"
/
IC       "Capital Cost"
FC       "Fixed O&M Cost"
VC       "Variable Cost"
LFT      "Technical Lifetime"
USC   "Useful Energy Conversion Factor"
/
PGECONCHAR       "Technical - economic characteristics for power generation plants"
/
LFT
/
SG               "S parameters in Gompertz function for passenger cars per capita"
/S1,S2/
TRANSPCHAR       "Various transport data used in equations and post-solution calculations"
/
KM_VEH           "Thousands km per passenger car vehicle"
KM_VEH_TRUCK     "Thousands km per truck vehicle"
OCCUP_CAR        "Passengers per car (car occupancy rate)"
RES_MEXTV        "Residual for controlling the GDP-Dependent market extension of passenger cars"
RES_MEXTF        "Residual for controlling the GDP-Independent market extension of passenger cars"
/
TRANSUSE         "Usage (average) data concerning capacity and load factor"
/
CAP              "Capacity in tn/vehicle or passengers/vehicle"
LF               "Load factor"
/
TOCTSET          "Total Transformation Output and Total District Heating Output"
/
TOCT_ELC         "Electricity Total Transformation Output in Mtoe"
TOCT_STE         "Steam Total Transformation Output in Mtoe"
TONUC_ELC        "Electricity production from nuclear plants in Mtoe"
TODH_STE         "Steam produced from District Heating Plants in Mtoe"
/
SUPOTH           "Indicators related to supply side"
/
REF_CAP          "Refineries Capacity in Mbl/day"
REF_CAP_RES      "Residuals of Refineries Capacity"
HCL_PPROD        "Residual of Hard Coal Primary Production"
NGS_PPROD        "Residual of Natural Gas Primary Production"
OIL_PPROD        "Residual of Crude Oil Primary Production"
NGS_EXPORT       "Residual of Natural Gas Exports"
ELC_IMP          "Ratio of electricity imports to total final demand"
TIOTH_RES        "Residual of Total Transformation Input in Gasworks, Blast Furnances, etc."
TOOTH_RES        "Residual of Total Transformation Output from Gasworks, etc."
FEED_RES         "Residual for Feedstocks in Transfers"
/
PGOTH            "Various data related to power generation plants"
/
TOTCAP           "Total Available capacity in Base Year (GW)"
TOTNOMCAP        "Total Nominal Available capacity in Base Year (GW)"
PEAKLOAD         "Peak Load in Base Year (GW)"
BASELOAD         "Base Load in Base Year (GW)"
NON_CHP_PER      "Non-CHP capacity (percentage of total (gross) capacity)"
CHP_CAP          "CHP Capacity (gross) in GW"
CHP_ELC          "CHP electricity"
LGN
HCL
GDO
RFO
OLQ
NGS
OGS
BMSWAS
/
PGLOADTYPE(PGOTH)   "Peak and Base load of total electricity demand in GW"
/PEAKLOAD, BASELOAD/
CHPSET(PGOTH)       "Indicators related to CHP Production"                       /NON_CHP_PER,CHP_CAP/
VARIOUS_LABELS /AMAXBASE, MAXLOADSH/
PGRES
/
TOT_CAP_RES         "Residual on Total Capacity (Reserve margin on capacity)"
BASE_LOAD_RES       "Residual on Base Load "
MAX_LOAD_RES        "Residual on Peak Load (Peak Load margin)"
/
Indu_SCon_Set /Base, SHR_NSE, SH_HPELC/
CHPPGSET /IC,FC,VOM,LFT,AVAIL,effElc,effThrm,MAXCHPSHARE/
BALEF fuels in balance report
/
"Total"
"Solids"
"Hard coal"
"Lignite"
"Crude oil and Feedstocks"
"Liquids"
"Liquified petroleum gas"
"Gasoline"
"Kerosene"
"Diesel oil"
"Fuel oil"
"Other liquids"
"Gas fuels"
"Natural gas"
"Derived gases"
"Nuclear heat"
"Steam"
"Hydro"
"Wind"
"Solar energy"
"Biomass"
"Geothermal heat"
"Methanol"
"Hydrogen"
"Electricity"
/
biomass(balef)
/"biomass"/
TOTAL(BALEF)
/"TOTAL"/
BALEF2EFS(BALEF, EFS) Mapping from balance fuels to model fuels
/
"Total".(HCL,LGN,CRO,LPG,GSL,BGSL,KRS,GDO,BGDO,RFO,OLQ,NGS,OGS,NUC,STE,HYD,WND,SOL,BMSWAS,GEO,MET,ETH,H2F,ELC)
"Solids".(HCL,LGN)
"Hard coal".HCL
"Lignite".LGN
"Crude oil and Feedstocks".CRO
"Liquids".(LPG,GSL,BGSL,KRS,GDO,BGDO,RFO,OLQ)
"Liquified petroleum gas".LPG
"Gasoline".(GSL,BGSL)
"Kerosene".KRS
"Diesel oil".(GDO,BGDO)
"Fuel oil".RFO
"Other liquids".OLQ
"Gas fuels".(NGS,OGS)
"Natural gas".NGS
"Derived gases".OGS
"Nuclear heat".NUC
"Steam".STE
"Hydro".HYD
"Wind".WND
"Solar energy".SOL
"Biomass".BMSWAS
"Geothermal heat".GEO
"Methanol".MET
"Hydrogen".H2F
"Electricity".ELC
/
alias(TT, ytime);
```


> **Limitations**
> There are no known limitations.

See Also
--------

[01_Transport], [02_Industry], [04_PowerGeneration], [05_Hydrogen], [06_CO2], [08_Prices], [09_Heat]

