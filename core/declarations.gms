*' @title Declarations
*' @code
Parameters
iCGI(allCy,YTIME)                                          "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline)) (1)"
iNPDL(SBS)                                                 "Number of Polynomial Distribution Lags (PDL) (1)"
iFPDL(SBS,KPDL)                                            "Polynomial Distribution Lags (PDL) Coefficients per subsector (1)"
iLifChpPla(allCy,DSBS,CHP)                                 "Technical Lifetime for CHP plants (years)"
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
iEffDHPlants(allCy,EF,YTIME)                               "Efficiency of District Heating Plants (1)" 
iTransfInpGasworks(allCy,EF,YTIME)                         "Transformation Input in Gasworks, Blast Furnances, Briquetting plants (Mtoe)"
iResRefCapacity(allCy,YTIME)	                           "Residual in Refineries Capacity (1)"
iRefCapacity(allCy,YTIME)	                               "Refineries Capacity (Million Barrels/day)"
iResTransfOutputRefineries(allCy,EF,YTIME)                 "Residual in Transformation Output from Refineries (Mtoe)"
iRateEneBranCons(allCy,EF,YTIME)	                       "Rate of Energy Branch Consumption over total transformation output (1)"
iFeedTransfr(allCy,EFS,YTIME)	                           "Feedstocks in Transfers (Mtoe)"
iResHcNgOilPrProd(allCy,EF,YTIME)	                       "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
iFuelPriPro(allCy,EF,YTIME)                 	           "Fuel Primary Production (Mtoe)"
iRatePriProTotPriNeeds(allCy,EF,YTIME)	                   "Rate of Primary Production in Total Primary Needs (1)"	
iFuelExprts(allCy,EF,YTIME)	                               "Fuel Exports (Mtoe)"	
iSuppExports(allCy,EF,YTIME)                	           "Supplementary parameter for  exports (Mtoe)"
iRatioImpFinElecDem(allCy,YTIME)	                       "Ratio of imports in final electricity demand (1)"	
iElastCO2Seq(allCy,CO2SEQELAST)	                           "Elasticities for CO2 sequestration cost curve (1)"	
iBaseLoadShareDem(allCy,DSBS,YTIME)	                       "Baseload share of demand per sector (1)"
iMxmLoadFacElecDem(allCy,YTIME)	                           "Maximum load factor of electricity demand (1)"	
iBslCorrection(allCy,YTIME)	                               "Parameter of baseload correction (1)"
iResMargTotAvailCap(allCy,PGRES,YTIME)	                   "Reserve margins on total available capacity and peak load (1)"
iTechLftPlaType(allCy,PGALL)	                           "Technical Lifetime per plant type (year)"
iElecImp(allCy,YTIME)	                                   "Electricity Imports (1)"
iPlantAvailRate(allCy,PGALL,YTIME)	                       "Plant availability rate (1)"
iTotAvailCapBsYr(allCy)	                                   "Total installed available capacity in base year (GW)"
iCO2CaptRate(allCy,PGALL,YTIME)	                           "Plant CO2 capture rate (1)"
iPlantDecomSched(allCy,PGALL,YTIME)	                       "Decided plant decomissioning schedule (GW)"
iDecInvPlantSched(allCy,PGALL,YTIME)                       "Decided plant investment schedule (GW)"
iMinRenPotential(allCy,PGRENEF,YTIME)	                   "Minimum renewable potential (GW)"	
iMaxRenPotential(allCy,PGRENEF,YTIME)	                   "Maximum enewable potential (GW)"
iMatureFacPlaDisp(allCy,PGALL,YTIME)	                   "Maturity factor related to plant dispatching (1)"		
iEffValueInDollars(allCy,SBS,YTIME)	                       "Efficiency value (US$2015/toe)"
iVAT(allCy,YTIME)                                          "VAT (value added tax) rates (1)"
iPriceTragets(allCy,SBS,EF,YTIME)	                       "Price Targets	(1)"
iPriceReform(allCy,SBS,EF,YTIME)	                       "Price reformation (1)"
iScenarioPri(WEF,NAP,YTIME)	                               "Scenario prices (KUS$2015/toe)"	
iWgtSecAvgPriFueCons(allCy,SBS,EF)	                       "Weights for sector's average price, based on fuel consumption (1)"	
iFuelConsPerFueSub(allCy,SBS,EF,YTIME)	                   "Fuel consumption per fuel and subsector (Mtoe)"
iTotFinEneDemSubBaseYr(allCy,SBS,YTIME)	                   "Total Final Energy Demand per subsector in Base year (Mtoe)"
iResNonSubsElecDem(allCy,SBS,YTIME	)	                   "Residuals in Non Substitutable Electricity Demand	(1)"	
iResFuelConsPerSubAndFuel(allCy,SBS,EF,YTIME)	           "Residuals in fuel consumption per subsector and fuel (1)"	
iShareAnnMilePlugInHybrid(allCy,YTIME)	                   "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
iAvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	           "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)" 
iUtilRateChpPlants(allCy,CHP,YTIME)	                       "Utilisation rate of CHP Plants (1)"	
iHydrogenPri(allCy,SBS,YTIME)	                           "Total Hydrogen Cost Per Sector (US$2015/toe)"
iTechLft(allCy,SBS,EF,YTIME)	                           "Technical Lifetime. For passenger cars it is a variable (1)"
iSpeFuelConsCostBy(allCy,SBS,TTECH,EF)	                   "Specific fuel consumption cost in Base year (ktoe/Gpkm or ktoe/Gtkm or ktoe/Gvkm)"	
iShrNonSubElecInTotElecDem(allCy,SBS)	                   "Share of non substitutable electricity in total electricity demand per subsector (1)"
iElecIndex(allCy,YTIME)	                                   "Electricity Index (1)"	
iExogDemOfBiomass(allCy,SBS,YTIME)	                       "Demand of tranditional biomass defined exogenously ()"	
iFinEneConsPrevYear(allCy,EF,YTIME)	                       "Final energy consumption used for holding previous year results (Mtoe)"	
iCarbValYrExog(allCy,ytime)	                               "Carbon value for each year when it is exogenous (US$2015/tn CO2)"
iShrHeatPumpElecCons(allCy,SBS)	                           "Share of heat pump electricity consumption in total substitutable electricity (1)"						 			
iTranfOutGasworks(allCy,EF,YTIME)	                       "Transformation Output from Gasworks, Blast Furnances and Briquetting plants (Mtoe)"	
iDistrLosses(allCy,EF,YTIME)	                           "Distribution Losses (Mtoe)"	
iTransfOutputRef(allCy,EF,YTIME)	                       "Transformation Output from Refineries (Mtoe)"	
iFinEneCons(allCy,EF,YTIME)	                               "Final energy consumption (Mtoe)"	
iTotEneBranchCons(allCy,EF,YTIME)	                       "Total Energy Branch Consumption (Mtoe)"	
iFuelImports(allCy,EF,YTIME)	                           "Fuel Imports (Mtoe)"	
iGrosInlCons(allCy,EF,YTIME)	                           "Gross Inland Consumtpion (Mtoe)"	
iGrossInConsNoEneBra(allCy,EF,YTIME)	                   "Gross Inland Consumption,excluding energy branch (Mtoe)"	
iPeakBsLoadBy(allCy,PGLOADTYPE)	                           "Peak and Base load for base year (GW)"	
iHisChpGrCapData(allCy,CHP,YTIME)	                       "Historical CHP  gross capacity data (GW)"	
iTransfInputRef(allCy,EF,YTIME)	                           "Transformation Input in Refineries (Mtoe)"	
iSigma(allCy,SG)                                           "S parameters of Gompertz function for passenger cars vehicle km (1)"
iPassCarsMarkSat(allCy)	                                   "Passenger cars market saturation (1)"	
iGdpPassCarsMarkExt(allCy)	                               "GDP-dependent passenger cars market extension (GDP/capita)"	
iPassCarsScrapRate(allCy)	                               "Passenger cars scrapping rate (1)"	
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
iInvCostChp(allCy,DSBS,CHP,YTIME)                          "Capital Cost per CHP plant type (kUS$2015/KW)"
iFixOMCostPerChp(allCy,DSBS,CHP,YTIME)                     "Fixed O&M cost per CHP plant type (US$2015/KW)"
iVarCostChp(allCy,DSBS,CHP,YTIME)                          "Variable (other than fuel) cost per CHP Type (Gross US$2015/KW)"
iAvailRateChp(allCy,DSBS,CHP)                              "Availability rate of CHP Plants ()"
iBoiEffChp(allCy,CHP,YTIME)                                "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
iCapCostTech(allCy,SBS,EF,YTIME)                           "Capital Cost of technology (various)"
                                                                !! - For transport is expressed in kUS$2015 per vehicle
                                                                !! - For Industrial sectors (except Iron and Steel) is expressed in kUS$2015/toe-year
                                                                !! - For Iron and Steel is expressed in kUS$2015/tn-of-steel
                                                                !! - For Domestic Sectors is expressed in kUS$2015/toe-year
iDiffFuelsInSec(SBS)                                       "auxiliary parameter holding the number of different fuels in a sector"
iResElecIndex(allCy,YTIME)                                 "Residual for electricity Index (1)"
iElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
iIndChar(allCy,INDSE,Indu_Scon_Set)                        "Industry sector charactetistics (various)"
iNetImp(allCy,EFS,YTIME)                                   "Net imports (Mtoe)"
iMxmShareChpElec(allCy,YTIME)	                           "Maximum share of CHP electricity in a country (1)"
iScaleEndogScrap(PGALL)                                    "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
iInpTransfTherm(allCy,EFS,YTIME)                           "Historic data of VInpTransfTherm (Transformation input to thermal power plants) (Mtoe)"
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
*' *** Miscellaneous
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