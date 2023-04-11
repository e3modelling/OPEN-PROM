Parameters
iCGI(allCy,YTIME)         "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline))"
iNPDL(SBS)                "Number of Polynomial Distribution Lags (PDL)"
iFPDL(SBS,KPDL)           "Polynomial Distribution Lags (PDL) Coefficients per subsector"
;


Equations
*** Power Generation
QElecDem(allCy,YTIME)     "Compute total electricity demand"
QElecConsAll(allCy,DSBS,YTIME)"Compute electricity consumption per final demand sector"

*** Transport
QMExtV(allCy,YTIME)            "Compute passenger cars market extension (GDP dependent)"
QMExtF(allCy,YTIME)            "Compute passenger cars market extension (GDP independent)"
QNumVeh(allCy,YTIME)           "Compute stock of passenger cars (in million vehicles)"
QNewReg(allCy,YTIME)           "Compute new registrations of passenger cars"
QTrnspActiv(allCy,TRANSE,YTIME)"Compute passenger transport acitivity"
QScrap(allCy,YTIME)            "Compute scrapped passenger cars"
QLevl(allCy,YTIME)             "Compute ratio of car ownership over saturation car ownership"
QScrRate(allCy,YTIME)          "Compute passenger cars scrapping rate"



***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
QElecConsInd(allCy,YTIME)             "Compute Consumption of electricity in industrial sectors"
QDemInd(allCy,YTIME)                  "Copmpute total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
QElecIndPrices(allCy,YTIME)           "Compute electricity industry prices"
QElecConsHeatPla(allCy, DSBS, YTIME)  "Compute electricity consumed in heatpump plants"
qDummyObj                             "Define dummy objective function"
;


Variables
VElecDem(allCy,YTIME)          "Total electricity demand (TWh)"
VFeCons(allCy,EF,YTIME)        "Total final energy consumnption (Mtoe)"
VFNonEnCons(allCy,EFS,YTIME)   "Final non energy consumption (Mtoe)"
VLosses(allCy,EFS,YTIME)       "Distribution losses (Mtoe)"
VEnCons(allCy,EFS,YTIME)       "Final consumption in energy sector (Mtoe)"
VNetImp(allCy,EFS,YTIME)       "Net imports (Mtoe)"
VMExtV(allCy,YTIME)            "Passenger cars market extension (GDP dependent)"
VMExtF(allCy,YTIME)            "Passenger cars market extension (GDP independent)"
VLamda(allCy,YTIME)            "Ratio of car ownership over saturation car ownership (1)"
VNumVeh(allCy,YTIME)           "Stock of passenger cars (million vehicles)"
VNewReg(allCy,YTIME)           "Passenger cars new registrations (million vehicles)"
VScrap(allCy,YTIME)            "Scrapped passenger cars (million vehicles)"
VTrnspActiv(allCy,TRANSE,YTIME)"Passenger transport acitivity"
                                !! - Activity for passenger cars is measured in (000)km
                                !! - Activity for all other passenger transportation modes is measured in Gpkm
VFuelPrice(allCy,TRANSE,YTIME) "Average fuel prices per subsector (kUS$2005/toe)"
VScrRate(allCy,YTIME)          "Scrapping rate of passenger cars (1)"
VElecConsAll(allCy,DSBS,YTIME) "Electricity demand per final sector (Mtoe)"
VConsFuel(allCy,DSBS,EF,YTIME) "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
VDemTr(allCy,TRANSE,EF,YTIME)  "Final energy demand in transport subsectors per fuel (Mtoe)"


***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
VElecNonSub(allCy,DSBS,YTIME)        "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
VElecConsInd(allCy,YTIME)            "Total Consumption of Electricity in industrial sectors (Mtoe)"
VDemInd(allCy,YTIME)                 "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
VDemSub(allCy,DSBS,YTIME)            "Total final demand (of substitutable fuels)per subsector (Mtoe)"
VElecIndPrices(allCy,YTIME)          "Electricity index - a function of industry price"
VElecIndPricesEst(allCy, YTIME)      "Electricity index - a function of industry price - Estimate"
VElecConsHeatPla(allCy, DSBS, YTIME) "Electricity consumed in heatpump plants"

vDummyObj                      "Dummy maximisation variable (1)"
;


Scalars
sTWhToMtoe         "TWh to Mtoe conversion factor" /0.086/
sElecToSteRatioChp "Technical maximum of electricity to steam ratio in CHP plants" /1.15/
;