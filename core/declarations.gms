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
*'                **Interdependent Equations**

*' * Power Generation *
QLoadFacDom(allCy,YTIME)	                               "Compute load factor of entire domestic system"
QPeakLoad(allCy,YTIME)	                                   "Compute elerctricity peak load"	
QPriceElecIndResNoCliPol(allCy,ESET,YTIME)                 "Compute electricity price in Industrial and Residential Consumers excluding climate policies"
QDemElecTot(allCy,YTIME)                                   "Compute total electricity demand"
QProdElec(allCy,PGALL,YTIME)                               "Compute electricity production from power generation plants"
QProdElecCHP(allCy,CHP,YTIME)	                           "Compute electricity production from CHP plants" 
QProdElecReqTot(allCy,YTIME)                               "Compute total required electricity production"
QCostPowGenAvgLng(allCy,ESET,YTIME)	                       "Compute long term power generation cost"

*' * Transport *
QDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)	           "Compute final energy demand in transport per fuel"
QConsElec(allCy,DSBS,YTIME)                                "Compute electricity consumption per final demand sector"
QLft(allCy,DSBS,EF,YTIME)	                               "Compute the lifetime of passenger cars" 

*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *
QConsFuel(allCy,DSBS,EF,YTIME)                             "Compute fuel consumption"
QConsElecNonSubIndTert(allCy,INDDOM,YTIME)	               "Compute non-substituable electricity consumption in Industry and Tertiary"
*qConsTotElecInd(allCy,YTIME)                               "Compute Consumption of electricity in industrial sectors"
QDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Compute total final demand (of substitutable fuels) per subsector"
*qDemFinSubFuelInd(allCy,YTIME)                             "Copmpute total final demand (of substitutable fuels) in industrial sectors"
QPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                   "Compute fuel prices per subsector and fuel especially for chp plants"
QConsFuelInclHP(allCy,DSBS,EF,YTIME)                       "Equation for fuel consumption in Mtoe (including heat from heatpumps)"
QConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)	               "Equation for consumption of remaining substitutble equipment"
QPriceElecInd(allCy,YTIME)                                 "Compute electricity industry prices"
QCostElcAvgProdCHP(allCy,CHP,YTIME)                        "Compute Average Electricity production cost per CHP plant"
QCostVarAvgElecProd(allCy,CHP,YTIME)                       "Compute Average variable including fuel electricity production cost per CHP plant"

*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
QImpNetEneBrnch(allCy,EFS,YTIME)	                       "Compute net imports"
QConsFiEneSec(allCy,EFS,YTIME)	                           "Compute energy branch final consumption"
QInpTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation input to power plants"	
QTransfInputDHPlants(allCy,EFS,YTIME)                      "Compute the transformation input to distrcit heating plants"
QConsFinEneCountry(allCy,EFS,YTIME)                        "Compute total final energy consumption"
QConsFinNonEne(allCy,EFS,YTIME)                            "Compute final non-energy consumption"
QLossesDistr(allCy,EFS,YTIME)                              "Compute distribution losses"

*' * Prices *
QPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                 "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
QPriceElecIndResConsu(allCy,ESET,YTIME)                    "Compute electricity price in Industrial and Residential Consumers"
QPriceFuelAvgSub(allCy,DSBS,YTIME)	                       "Compute average fuel price per subsector" 	

*' *** CO2 SEQUESTRATION COST CURVES EQUATIONS
QCstCO2SeqCsts(allCy,YTIME)	                               "Compute cost curve for CO2 sequestration costs" 

*' *** Miscellaneous
*qDummyObj                                                  "Define dummy objective function"

;

Variables
*'                **Interdependent Variables**

*' * Power Generation *
VLoadFacDom(allCy,YTIME)                                   "Electricity load factor for entire domestic system"	
VPeakLoad(allCy,YTIME)	                                   "Electricity peak load (GW)"	
VPriceElecIndResNoCliPol(allCy,ESET,YTIME)                 "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VDemElecTot(allCy,YTIME)                                   "Total electricity demand (TWh)"
VProdElec(allCy,PGALL,YTIME)                               "Electricity production (TWh)"	
VProdElecCHP(allCy,CHP,YTIME)	                           "CHP electricity production (TWh)"
VProdElecReqTot(allCy,YTIME)	                           "Total required electricity production (TWh)"
VCostPowGenAvgLng(allCy,ESET,YTIME)	                       "Long-term average power generation cost (US$2015/kWh)"

*' * Transport *
VDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)             "Final energy demand in transport subsectors per fuel (Mtoe)"
VConsElec(allCy,DSBS,YTIME)                                "Electricity demand per final sector (Mtoe)"
VLft(allCy,DSBS,EF,YTIME)                                  "Lifetime of technologies (years)"

*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES *
VConsFuel(allCy,DSBS,EF,YTIME)                             "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
VConsElecNonSubIndTert(allCy,DSBS,YTIME)                   "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
*vConsTotElecInd(allCy,YTIME)                               "Total Consumption of Electricity in industrial sectors (Mtoe)"
VDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Total final demand (of substitutable fuels) per subsector (Mtoe)"
*vDemFinSubFuelInd(allCy,YTIME)                             "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
VPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)                   "Fuel prices per subsector and fuel for CHP plants (kUS$2015/toe)"
VConsFuelInclHP(allCy,DSBS,EF,YTIME)                       "Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)"
VConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)                "Consumption of remaining substitutable equipment (Mtoe)"
VPriceElecInd(allCy,YTIME)                                 "Electricity index - a function of industry price (1)"
VCostElcAvgProdCHP(allCy,CHP,YTIME)                        "Average Electricity production cost per CHP plant (US$2015/KWh)"
VCostVarAvgElecProd(allCy,CHP,YTIME)                       "Average variable including fuel electricity production cost per CHP plant (US$2015/KWh)"

*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
VImpNetEneBrnch(allCy,EFS,YTIME)	                       "Net Imports (Mtoe)"
VConsFiEneSec(allCy,EFS,YTIME)                             "Final consumption in energy sector (Mtoe)"
VInpTransfTherm(allCy,EFS,YTIME)	                       "Transformation input to thermal power plants (Mtoe)"
VTransfInputDHPlants(allCy,EFS,YTIME)                      "Transformation input to District Heating Plants (Mtoe)"
VConsFinEneCountry(allCy,EF,YTIME)                         "Total final energy consumnption (Mtoe)"
VConsFinNonEne(allCy,EFS,YTIME)                            "Final non energy consumption (Mtoe)"
VLossesDistr(allCy,EFS,YTIME)                              "Distribution losses (Mtoe)"

*' * Prices *
VPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                 "Fuel prices per subsector and fuel (k$2015/toe)"
VPriceElecIndResConsu(allCy,ESET,YTIME)	                   "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VPriceFuelAvgSub(allCy,DSBS,YTIME)                         "Average fuel prices per subsector (k$2015/toe)"

*' *** CO2 SEQUESTRATION COST CURVES VARIABLES
VCstCO2SeqCsts(allCy,YTIME)	                               "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"

*' *** Miscellaneous
*vDummyObj                                                  "Dummy maximisation variable (1)"
VFuelPriSubNoCarb(allCy,SBS,EF,YTIME)	                   "Fuel prices per subsector and fuel  without carbon value (kUS$2015/toe)"
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
iFracElecPriChp                                            "Fraction of Electricity Price at which a CHP sells electricity to network" /0.3/
cy                                                         "country iterator" /0/
;
