Parameters
iCGI(allCy,YTIME)                            "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline)) (1)"
iNPDL(SBS)                                   "Number of Polynomial Distribution Lags (PDL) (1)"
iFPDL(SBS,KPDL)                              "Polynomial Distribution Lags (PDL) Coefficients per subsector (1)"
iResDemSub(allCy,SBS,YTIME)                  "Residuals in total energy demand per subsector (1)"
iLifChpPla(CHP)                              "Technical Lifetime for CHP plants (years)" /
$ondelim
$include "./iLifChpPla.csv"
$offdelim
/
iCo2EmiFac(allCy,SBS,EF,YTIME)                  "CO2 emission factors per subsector (kgCO2/kgoe fuel burned)"
iUsfEnergyConvFact(allCy,SBS,EF,TEA,YTIME)      "Useful Energy Conversion Factor per subsector, technology, and country (1)"
iNcon(SBS)                                      "Number of consumers (1)"
iDisFunConSize(allCy,DSBS,rCon)                 "Distribution function of consumer size groups (1)"
iAnnCons(allCy,DSBS,conSet)                     "Annual consumtion of the smallest,modal,largest consumer, average for all countries (various)"
                                                 !! For passenger cars (Million km/vehicle)
                                                 !! For other passenger tranportation modes (Mpkm/vehicle)
                                                 !! For goods transport, (Mtkm/vehicle)  
iCumDistrFuncConsSize(allCy,DSBS)               "Cummulative distribution function of consumer size groups (1)"                                                                                                         
;


Equations
*** Power Generation
QElecDem(allCy,YTIME)         "Compute total electricity demand"
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
QElecConsInd(allCy,YTIME)                     "Compute Consumption of electricity in industrial sectors"
QDemInd(allCy,YTIME)                          "Copmpute total final demand (of substitutable fuels) in industrial sectors"
QElecIndPrices(allCy,YTIME)                   "Compute electricity industry prices"
QElecConsHeatPla(allCy,DSBS,YTIME)            "Compute electricity consumed in heatpump plants"
QFuelCons(allCy,DSBS,EF,YTIME)                "Compute fuel consumption"
QElecIndPricesEst(allCy,YTIME)                "Compute Electricity index - a function of industry price - Estimate"
QFuePriSubChp(allCy,DSBS,EF,TEA,YTIME)        "Compute fuel prices per subsector and fuel especially for chp plants"
QElecProdCosChp(allCy,DSBS,CHP,YTIME)         "Compute electricity production cost per CHP plant and demand sector"
QTechCost(allCy,DSBS,rCon,EF,TEA,YTIME)       "Compute technology cost"
QTechCostIntrm(allCy,DSBS,rCon,EF,TEA,YTIME)  "Compute intermediate technology cost"
QTechCostMatr(allCy,DSBS,rCon,EF,TEA,YTIME)   "Compute the technology cost including the maturity factor per technology and subsector"
QTechSort(allCy,DSBS,rCon,YTIME)              "Compute Technology sorting based on variable cost"
QGapFinalDem(allCy,DSBS,YTIME)                "Compute the gap in final demand of industry, tertiary, non-energy uses and bunkers"
QTechShareNewEquip(allCy,DSBS,EF,TEA,YTIME)   "Compute technology share in new equipment"
QFuelConsInclHP(allCy,DSBS,EF,YTIME)          "Equation for fuel consumption in Mtoe (including heat from heatpumps)"


*** Miscellaneous
qDummyObj                                     "Define dummy objective function"
;


Variables
VElecDem(allCy,YTIME)                 "Total electricity demand (TWh)"
VFeCons(allCy,EF,YTIME)               "Total final energy consumnption (Mtoe)"
VFNonEnCons(allCy,EFS,YTIME)          "Final non energy consumption (Mtoe)"
VLosses(allCy,EFS,YTIME)              "Distribution losses (Mtoe)"
VEnCons(allCy,EFS,YTIME)              "Final consumption in energy sector (Mtoe)"
VNetImp(allCy,EFS,YTIME)              "Net imports (Mtoe)"
VMExtV(allCy,YTIME)                   "Passenger cars market extension (GDP dependent)"
VMExtF(allCy,YTIME)                   "Passenger cars market extension (GDP independent)"
VLamda(allCy,YTIME)                   "Ratio of car ownership over saturation car ownership (1)"
VNumVeh(allCy,YTIME)                  "Stock of passenger cars (million vehicles)"
VNewReg(allCy,YTIME)                  "Passenger cars new registrations (million vehicles)"
VScrap(allCy,YTIME)                   "Scrapped passenger cars (million vehicles)"
VTrnspActiv(allCy,TRANSE,YTIME)       "Passenger transport acitivity (1)"
                                         !! - Activity for passenger cars is measured in (000)km
                                         !! - Activity for all other passenger transportation modes is measured in Gpkm
VFuelPrice(allCy,DSBS,YTIME)           "Average fuel prices per subsector (kUS$2005/toe)"
VScrRate(allCy,YTIME)                  "Scrapping rate of passenger cars (1)"
VElecConsAll(allCy,DSBS,YTIME)         "Electricity demand per final sector (Mtoe)"
VConsFuel(allCy,DSBS,EF,YTIME)         "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
VDemTr(allCy,TRANSE,EF,YTIME)          "Final energy demand in transport subsectors per fuel (Mtoe)"
VLifeTimeTech(allCy,DSBS,EF,TEA,YTIME) "Lifetime of technologies (years)"



***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
VElecNonSub(allCy,DSBS,YTIME)          "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
VElecConsInd(allCy,YTIME)              "Total Consumption of Electricity in industrial sectors (Mtoe)"
VDemInd(allCy,YTIME)                   "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
VDemSub(allCy,DSBS,YTIME)              "Total final demand (of substitutable fuels)per subsector (Mtoe)"
VElecIndPrices(allCy,YTIME)            "Electricity index - a function of industry price (1)"
VElecConsHeatPla(allCy,DSBS,YTIME)     "Electricity consumed in heatpump plants (Mtoe)"
VConsFuelSub(allCy,DSBS,EF,YTIME)      "Consumption of fuels in each demand subsector (including heat from heatpumps) (Mtoe)"
VElecIndPricesEst(allCy,YTIME)         "Electricity index - a function of industry price - Estimate (1)"
VResElecIndex(allCy,YTIME)             "Residual for electricity Index (1)"
VFuelPriceSub(allCy,SBS,EF,YTIME)      "Fuel prices per subsector and fuel (kUS$2005/toe)"
VFuePriSubChp(allCy,DSBS,EF,TEA,YTIME) "Fuel prices per subsector and fuel for CHP plants (kUS$2005/toe)"
VRenValue(YTIME)                       "Renewable value (Euro2005/KWh)"
VTechCostVar(allCy,SBS,EF,TEA,YTIME)   "Variable Cost of technology (various)"
                                        !! - For transport (kEuro05/vehicle)
                                        !! - For Industrial sectors except Iron and Steel (Euro05/toe-year)
                                        !! - For Iron and Steel (Euro05/tn-of-steel)
                                        !! - For Domestic sectors (Euro05/toe-year)
VElecProdCostChp(allCy,DSBS,CHP,YTIME)                  "Electricity production cost per CHP plant and demand sector (Euro/KWh)"
VCarVal(allCy,NAP,YTIME)                                "Carbon value for all countries (Euro2005/tn CO2)"
VTechCost(allCy,DSBS,rCon,EF,TEA,YTIME)                 "Technology cost (Keuro/toe)"
VTechCostIntrm(allCy,DSBS,rcon,EF,TEA,YTIME)            "Intermediate technology cost (Keuro/toe)"
VTechCostMatr(allCy,DSBS,rCon,EF,TEA,YTIME)             "Technology cost including maturity factor (Keuro/toe)"
VMatrFactor(allCy,SBS,EF,TEA,YTIME)                     "Maturity factor per technology and subsector (1)"
VTechSort(allCy,DSBS,rCon,YTIME)                        "Technology sorting based on variable cost (1)"
VConsRemSubEquip(allCy,DSBS,EF,YTIME)                   "Consumption of remaining substitutable equipment (Mtoe)"
VGapFinalDem(allCy,DSBS,YTIME)                          "Final Demand GAP to be filed by new technologies (Mtoe)"
VTechShareNewEquip(allCy,DSBS,EF,TEA,YTIME)             "Technology share in new equipment (1)"
VFuelConsInclHP(allCy,DSBS,EF,YTIME)                    "Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)"


*** Miscellaneous
vDummyObj                                               "Dummy maximisation variable (1)"
;


Scalars
sTWhToMtoe         "TWh to Mtoe conversion factor" /0.086/
sElecToSteRatioChp "Technical maximum of electricity to steam ratio in CHP plants" /1.15/
;