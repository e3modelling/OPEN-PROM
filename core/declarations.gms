*' @title Core Declarations
*' @code
Parameters
iCGI(allCy,YTIME)                                          "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline)) (1)"
iNPDL(SBS)                                                 "Number of Polynomial Distribution Lags (PDL) (1)"
iFPDL(SBS,KPDL)                                            "Polynomial Distribution Lags (PDL) Coefficients per subsector (1)"
iPlantEffByType(allCy,PGALL,YTIME)                         "Plant efficiency per plant type (1)"
iCo2EmiFac(allCy,SBS,EF,YTIME)                             "CO2 emission factors per subsector (kgCO2/kgoe fuel burned)"
iNcon(SBS)                                                 "Number of consumers (1)"
iDisFunConSize(allCy,DSBS,rCon)                            "Distribution function of consumer size groups (1)"
iAnnCons(allCy,DSBS,conSet)                                "Annual consumption of the smallest,modal,largest consumer, average for all countries (various)"
                                                                !! For passenger cars (Million km/vehicle)
                                                                !! For other passenger tranportation modes (Mpkm/vehicle)
                                                                !! For goods transport, (Mtkm/vehicle)  
iCumDistrFuncConsSize(allCy,DSBS)                          "Cummulative distribution function of consumer size groups (1)"
iRateLossesFinCons(allCy,EF,YTIME)                         "Rate of losses over Available for Final Consumption (1)"  
iTransfInpGasworks(allCy,EF,YTIME)                         "Transformation Input in Gasworks, Blast Furnances, Briquetting plants (Mtoe)"
iFuelExprts(allCy,EF,YTIME)	                               "Fuel Exports (Mtoe)"	
iSuppExports(allCy,EF,YTIME)                	           "Supplementary parameter for  exports (Mtoe)"		
iResMargTotAvailCap(allCy,PGRES,YTIME)	                   "Reserve margins on total available capacity and peak load (1)"
iPlantAvailRate(allCy,PGALL,YTIME)	                       "Plant availability rate (1)"
iCO2CaptRate(allCy,PGALL,YTIME)	                           "Plant CO2 capture rate (1)"		
iEffValueInDollars(allCy,SBS,YTIME)	                       "Efficiency value (US$2015/toe)"
iPriceTragets(allCy,SBS,EF,YTIME)	                       "Price Targets	(1)"
iPriceReform(allCy,SBS,EF,YTIME)	                       "Price reformation (1)"
iScenarioPri(WEF,NAP,YTIME)	                               "Scenario prices (KUS$2015/toe)"		
iResNonSubsElecDem(allCy,SBS,YTIME	)	                   "Residuals in Non Substitutable Electricity Demand	(1)"	
iResFuelConsPerSubAndFuel(allCy,SBS,EF,YTIME)	           "Residuals in fuel consumption per subsector and fuel (1)"	 	
iShrNonSubElecInTotElecDem(allCy,SBS)	                   "Share of non substitutable electricity in total electricity demand per subsector (1)"		
iFinEneConsPrevYear(allCy,EF,YTIME)	                       "Final energy consumption used for holding previous year results (Mtoe)"	
iCarbValYrExog(allCy,ytime)	                               "Carbon value for each year when it is exogenous (US$2015/tn CO2)"
iShrHeatPumpElecCons(allCy,SBS)	                           "Share of heat pump electricity consumption in total substitutable electricity (1)"						 			
iTranfOutGasworks(allCy,EF,YTIME)	                       "Transformation Output from Gasworks, Blast Furnances and Briquetting plants (Mtoe)"	
iDistrLosses(allCy,EF,YTIME)	                           "Distribution Losses (Mtoe)"		
iFinEneCons(allCy,EF,YTIME)	                               "Final energy consumption (Mtoe)"		
iFuelImports(allCy,EF,YTIME)	                           "Fuel Imports (Mtoe)"							
iVarCostTech(allCy,SBS,EF,YTIME)	                       "Variable Cost of technology ()"
                                                                !! For transport (kUS$2015/vehicle)
                                                                !! For Industrial sectors, except Iron and Steel (US$2015/toe-year)
                                                                !! For Iron and Steel  (US$2015/tn-of-steel)
                                                                !! For Domestic sectors  (US$2015/toe-year)
iFixOMCostTech(allCy,SBS,EF,YTIME)                         "Fixed O&M cost of technology (US$2015/toe-year)"                                   
                                                                !! Fixed O&M cost of technology for Transport (kUS$2015/vehicle)
                                                                !! Fixed O&M cost of technology for Industrial sectors-except Iron and Steel (US$2015/toe-year)"                                            
                                                                !! Fixed O&M cost of technology for Iron and Steel (US$2015/tn-of-steel)"                                          
                                                                !! Fixed O&M cost of technology for Domestic sectors (US$2015/toe-year)"
iUsfEneConvSubTech(allCy,SBS,EF,YTIME)                     "Useful Energy Conversion Factor per subsector and technology (1)"
iCapCostTech(allCy,SBS,EF,YTIME)                           "Capital Cost of technology (various)"
                                                                !! - For transport is expressed in kUS$2015 per vehicle
                                                                !! - For Industrial sectors (except Iron and Steel) is expressed in kUS$2015/toe-year
                                                                !! - For Iron and Steel is expressed in kUS$2015/tn-of-steel
                                                                !! - For Domestic Sectors is expressed in kUS$2015/toe-year
iResElecIndex(allCy,YTIME)                                 "Residual for electricity Index (1)"
iIndChar(allCy,INDSE,Indu_Scon_Set)                        "Industry sector charactetistics (various)"
iNetImp(allCy,EFS,YTIME)                                   "Net imports (Mtoe)"
iFuelConsPerFueSub(allCy,SBS,EF,YTIME)	                   "Fuel consumption per fuel and subsector (Mtoe)"
ODummyObj                                                  "Parameter saving objective function"
;

Equations
*' *** Miscellaneous'
qDummyObj                                                  "Define dummy objective function"
;

Variables
*'                **Interdependent Variables**

*' *** Miscellaneous
vDummyObj                                                  "Dummy maximisation variable (1)"
VElecConsHeatPla(allCy,DSBS,YTIME)                         "Electricity consumed in heatpump plants (Mtoe)"
;

Positive Variables
VCarVal(allCy,NAP,YTIME)                                   "Carbon prices for all countries (US$2015/tn CO2)"
VRenValue(YTIME)                                           "Renewable value (US$2015/KWh)"
;

Scalars
sTWhToMtoe                                                 "TWh to Mtoe conversion factor" /0.086/
sElecToSteRatioChp                                         "Technical maximum of electricity to steam ratio in CHP plants" /1.15/
sGwToTwhPerYear                                            "convert GW mean power into TWh/y" /8.76/
s                                                          "time step iterator" /0/
sSolverTryMax                                              "maximum attempts to solve each time step" /%SolverTryMax%/
sModelStat                                                 "helper parameter for solver status"
sExogCarbValue	                                           "switch for exogenous carbon value (0=endogenous 1=exogenous)" /1/
sFracElecPriChp                                            "Fraction of Electricity Price at which a CHP sells electricity to network" /0.3/
cy                                                         "country iterator" /0/
;