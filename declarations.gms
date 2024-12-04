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

$ifthen %RUN_POWER_GENERATION% == yes
*' *** Power Generation
QCapElecCHP(allCy,CHP,YTIME)                               "Compute CHP electric capacity"	
QBsldEst(allCy,YTIME)	                                   "Compute estimated base load"		
QBaseLoadMax(allCy,YTIME) 	                               "Compute baseload corresponding to maximum load"
QBaseLoad(allCy,YTIME)	                                   "Compute electricity base load"
QShareNewTechCCS(allCy,PGALL,YTIME)	                       "Compute SHRCAP"
QCapElec2(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
QLambda(allCy,YTIME)	                                   "Compute Lambda parameter"	
QScalFacPlantDispatch(allCy,HOUR,YTIME)                    "Compute the scaling factor for plant dispatching"	
QPotRenCurr(allCy,PGRENEF,YTIME)	                       "Compute current renewable potential" 	
QScalWeibullSum(allCy,PGALL,YTIME)	                       "Compute sum (over hours) of temporary variable facilitating the scaling in Weibull equation"
qCostPowGenAvgShrt(allCy,ESET,YTIME)	                   "Compute short term power generation cost"		
QCostPowGenLonNoClimPol(allCy,ESET,YTIME)                  "Compute long term power generation cost excluding climate policies"	
QCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	       "Compute long term average power generation cost excluding climate policies"		
qCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)             "Compute short term power generation cost of technologies including international Prices of main fuels" 	
qCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)              "Compute long term power generation cost of technologies including international Prices of main fuels" 	
qCostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost"	
QCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	           "Compute long term power generation cost of technologies excluding climate policies"	
QShareRenGrossProd(allCy,YTIME)	                           "Compute the share of renewables in gross electricity production for subsdidized renewables"	
qSecContrTotCHPProd(allCy,SBS,CHP,YTIME)                   "Compute sector contribution to total CHP production"		
QProdElecReqCHP(allCy,YTIME)	                           "Compute total estimated CHP electricity production" 	
QProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants"	
QCapOverall(allCy,PGALL,YTIME)	                           "Compute overall capacity"
QProdElecNonCHP(allCy,YTIME)	                           "Compute non CHP electricity production" 	
QCFAvgRen(allCy,PGALL,YTIME)	                           "Compute the average capacity factor of RES"	
QNewCapElec(allCy,PGALL,YTIME)	                           "Compute the new capacity added every year"	
QSortPlantDispatch(allCy,PGALL,YTIME)	                   "Compute Power plants sorting according to variable cost to decide the plant dispatching" 	
QCostVarTechElec(allCy,PGALL,YTIME)	                       "Compute variable cost of technology" 
QCostVarTechElecTot(allCy,YTIME)	                       "Compute Electricity peak loads"	
QCapElec(allCy,PGALL,YTIME)	                               "Compute electricity generation capacity"	
QSharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Compute the power plant share in new equipment"	
QNewInvElec(allCy,YTIME)	                               "Compute for Power Plant new investment decision"		
QPotRenMaxAllow(allCy,PGRENEF,YTIME)                       "Compute maximum allowed renewable potential"
qPotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Compute minimum allowed renewable potential" 
QRenTechMatMult(allCy,PGALL,YTIME)	                       "Compute renewable technologies maturity multiplier"		 	
qScalWeibull(allCy,PGALL,HOUR,YTIME)                       "Compute temporary variable facilitating the scaling in Weibull equation"	
QCapElecNonCHP(allCy,YTIME)	                               "Compute total electricity generation capacity excluding CHP plants"
QPotRenSuppCurve(allCy,PGRENEF,YTIME)	                   "Compute renewable potential supply curve"		
QIndxEndogScrap(allCy,PGALL,YTIME)	                       "Compute endogenous scrapping index" 	
QCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Compute production cost of technology  used in premature replacement including plant availability rate"	
QCostVarTechNotPGSCRN(allCy,PGALL,YTIME)                   "Compute variable cost of technology excluding PGSCRN"	
QCostVarTech(allCy,PGALL,YTIME)	                           "Compute variable cost of technology" 	
QCapElecTotEst(allCy,YTIME)                                "Compute Estimated total electricity generation capacity"	
QCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)                "Compute hourly production cost used in investment decisions"
QCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)           "Compute hourly production cost used in investment decisions"
QSensCCS(allCy,YTIME)	                                   "Compute gamma parameter used in CCS/No CCS decision tree"
qCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)	               "Compute hourly production cost used in investment decisions taking into account CCS acceptance"
QCostProdSpecTech(allCy,PGALL,YTIME)	                   "Compute production cost used in investment decisions"
QShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Compute SHRCAP excluding CCs"
QCostProdTeCHPreReplac(allCy,PGALL,YTIME)	               "Compute production cost of technology  used in premature replacement"	
QGapGenCapPowerDiff(allCy,YTIME)	                       "Compute the gap in power generation capacity"		
QRenTechMatMultExpr(allCy,PGALL,YTIME)                     "Renewable power capacity over potential (1)"
qScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)		   "Scaling factor for plant dispatching"	
$endif						

$ifthen %RUN_TRANSPORT% == yes
*' *** Transport
QMEPcGdp(allCy,YTIME)                                      "Compute passenger cars market extension (GDP dependent)"
QMEPcNonGdp(allCy,YTIME)                                   "Compute passenger cars market extension (GDP independent)"
QStockPcYearly(allCy,YTIME)                                "Compute stock of passenger cars (in million vehicles)"
QNewRegPcYearly(allCy,YTIME)                               "Compute new registrations of passenger cars"
QActivPassTrnsp(allCy,TRANSE,YTIME)                        "Compute passenger transport acitivity"
QNumPcScrap(allCy,YTIME)                                   "Compute scrapped passenger cars"
QPcOwnPcLevl(allCy,YTIME)                                  "Compute ratio of car ownership over saturation car ownership"
QRateScrPc(allCy,YTIME)                                    "Compute passenger cars scrapping rate"	
QActivGoodsTransp(allCy,TRANSE,YTIME)                      "Compute goods transport activity"
QGapTranspActiv(allCy,TRANSE,YTIME)	                       "Compute the gap in transport activity"	
QConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	           "Compute Specific Fuel Consumption"
QCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)  "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
QTechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Compute technology sorting based on variable cost"	
QShareTechTr(allCy,TRANSE,EF,YTIME)	                       "Compute technology sorting based on variable cost and new equipment"	
QCostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
QCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost including maturity factor"	
QConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
qDemFinEneSubTransp(allCy,TRANSE,YTIME)	                   "Compute final energy demand in transport" 		
$endif				

$ifthen %RUN_INDUSTRY% == yes
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
QElecConsHeatPla(allCy,DSBS,YTIME)                         "Compute electricity consumed in heatpump plants"
QIndxElecIndPrices(allCy,YTIME)                            "Compute Electricity index - a function of industry price - Estimate"
QCostElecProdCHP(allCy,DSBS,CHP,YTIME)                     "Compute electricity production cost per CHP plant and demand sector"
QCostTech(allCy,DSBS,rCon,EF,YTIME)                        "Compute technology cost"
QCostTechIntrm(allCy,DSBS,rCon,EF,YTIME)                   "Compute intermediate technology cost"
QCostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                  "Compute the technology cost including the maturity factor per technology and subsector"
QSortTechVarCost(allCy,DSBS,rCon,YTIME)                    "Compute Technology sorting based on variable cost"
QGapFinalDem(allCy,DSBS,YTIME)                             "Compute the gap in final demand of industry, tertiary, non-energy uses and bunkers"
QShareTechNewEquip(allCy,DSBS,EF,YTIME)                    "Compute technology share in new equipment"
QCostProdCHPDem(allCy,DSBS,CHP,YTIME)                      "Compute  variable including fuel electricity production cost per CHP plant and demand sector "	
$endif

$ifthen %RUN_REST_OF_ENERGY% == yes
*' *** REST OF ENERGY BALANCE SECTORS EQUATIONS
QTransfOutputPatFuel(allCy,EFS,YTIME)	                   "Compute the  transfomration output from patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works"	
qConsTotFinEne(YTIME)                                      "Compute total final energy consumption in ALL countries"
QOutTransfDhp(allCy,EFS,YTIME)                             "Compute the transformation output from district heating plants"
QTransfInputPatFuel(allCy,EFS,YTIME)                       "Compute the transfomration input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works"
QCapRef(allCy,YTIME)	                                   "Compute refineries capacity"	
QOutTransfRefSpec(allCy,EFS,YTIME)	                       "Compute the transformation output from refineries"
QInputTransfRef(allCy,EFS,YTIME)	                       "Compute the transformation input to refineries"
QOutTransfNuclear(allCy,EFS,YTIME)	                       "Compute transformation output from nuclear plants"
QInpTransfNuclear(allCy,EFS,YTIME)	                       "Compute transformation input to nuclear plants"
QOutTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation output from thermal power plants"
QInpTotTransf(allCy,EFS,YTIME)	                           "Compute total transformation input"
QOutTotTransf(allCy,EFS,YTIME)	                           "Compute total transformation output"
QTransfers(allCy,EFS,YTIME)	                               "Compute transfers"
QConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Compute gross inland consumption not including consumption of energy branch"	
QConsGrssInl(allCy,EFS,YTIME)	                           "Compute gross inland consumption"	
QProdPrimary(allCy,EFS,YTIME)	                           "Compute primary production"	
QExp(allCy,EFS,YTIME)	                                   "Compute fake exports"	
QImp(allCy,EFS,YTIME)	                                   "Compute fake imports"	
$endif

$ifthen %RUN_CO2% == yes
*' *** CO2 SEQUESTRATION COST CURVES EQUATIONS
QCapCO2ElecHydr(allCy,YTIME)	                           "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
QCaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
QTrnsWghtLinToExp(allCy,YTIME)	                           "Transtition weight for shifting from linear to exponential CO2 sequestration cost curve"	
$endif

$ifthen %RUN_EMISSIONS% == yes
*' *** Emissions Constraints Equations
qGrnnHsEmisCO2EquivAllCntr(YTIME)	                       "Compute total CO2eq GHG emissions in all countries"
QGrnnHsEmisCO2Equiv(NAP,YTIME)	                           "Compute total CO2eq GHG emissions in all countries per NAP sector"	
qExpendHouseEne(allCy,YTIME)	                           "Compute households expenditures on energy"
$endif

$ifthen %RUN_PRICES% == yes
*' *** Prices
QPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"	
$endif

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
qConsTotElecInd(allCy,YTIME)                               "Compute Consumption of electricity in industrial sectors"
QDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Compute total final demand (of substitutable fuels) per subsector"
qDemFinSubFuelInd(allCy,YTIME)                             "Copmpute total final demand (of substitutable fuels) in industrial sectors"
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
qDummyObj                                                  "Define dummy objective function"

;

Variables
$ifthen %RUN_POWER_GENERATION% == yes
*' *** Power Generation Variables
vScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)          "Scaling factor for plant dispatching"
VRenTechMatMultExpr(allCy,PGALL,YTIME)                     "Renewable power capacity over potential (1)"
VCapElecCHP(allCy,CHP,YTIME)	                           "Capacity of CHP Plants (GW)"
VLambda(allCy,YTIME)	                                   "Parameter for load curve construction (1)"
VBsldEst(allCy,YTIME)	                                   "Estimated base load (GW)"	
VBaseLoadMax(allCy,YTIME)	                               "Baseload corresponding to Maximum Load Factor (1)"
vCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)                "Hourly production cost of technology accounting for CCS acceptance (US$2015/KWh)"
VCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	           "Long-term average power generation cost (US$2015/kWh)"
VPotRenCurr(allCy,PGRENEF,YTIME)	                       "Current renewable potential (GW)"			
VProdElecReqCHP(allCy,YTIME)	                           "Total estimated CHP electricity production (TWh)"	
VCapOverall(allCy,PGALL,YTIME)	                           "Overall Capacity (MW)"	
VCostVarTechNotPGSCRN(allCy,PGALL,YTIME)                   "Variable cost of technology excluding PGSCRN (US$2015/KWh)"
vCostPowGenAvgShrt(allCy,ESET,YTIME)                       "Short-term average power generation cost (US$2015/kWh)"		
vCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)              "Long term power generation cost of technologies including international prices of main fuels (kUS$2015/toe)"	 	
VCostPowGenLonNoClimPol(allCy,ESET,YTIME)                  "Long-term average power generation cost  excluding climate policies (US$2015/kWh)"	
VCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	       "Long-term average power generation cost excluding climate policies(US$2015/kWh)" 	
vCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)             "Short term power generation cost of technologies including international Prices of main fuels (kUS$2015/toe)"		
vCostPowGenLonMin(allCy,PGALL,YTIME)	                   "Long-term minimum power generation cost (US$2015/kWh)"		
VScalFacPlaDisp(allCy,HOUR,YTIME)	                       "Scaling factor for plant dispatching	(1)"
vSecContrTotCHPProd(allCy,SBS,CHP,YTIME)                   "Contribution of each sector in total CHP production (1)"	
VSortPlantDispatch(allCy,PGALL,YTIME)	                   "Power plants sorting according to variable cost to decide the plant dispatching (1)"
VCFAvgRen(allCy,PGALL,YTIME)	                           "The average capacity factor of RES (1)"
VNewCapElec(allCy,PGALL,YTIME)	                           "The new capacity added every year (MW)"	
VProdElecNonCHP(allCy,YTIME)	                           "Non CHP total electricity production (TWh)"				
VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)                "Hourly production cost of technology (US$2015/KWh)"
VProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants (1)"	
VCostProdSpecTech(allCy,PGALL,YTIME)	                   "Production cost of technology (US$2015/KWh)"
VScalWeibullSum(allCy,PGALL,YTIME)	                       "Sum (over hours) of temporary variable facilitating the scaling in Weibull equation (1)"
VCostVarTechElecTot(allCy,YTIME)	                       "Electricity peak loads (GW)"	
VCostVarTechElec(allCy,PGALL,YTIME)	                       "Variable cost of technology (US$2015/KWh)"	
VNewInvElec(allCy,YTIME)	                               "Power plant sorting for new investment decision according to total cost (1)"	
VSharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"	
VRenTechMatMult(allCy,PGALL,YTIME)	                       "Renewable technologies maturity multiplier (1)"	
VPotRenSuppCurve(allCy,PGRENEF,YTIME)	                   "Renewable potential supply curve	(1)"
VPotRenMaxAllow(allCy,PGRENEF,YTIME)                       "Maximum allowed renewable potential (GW)"
vPotRenMinAllow(allCy,PGRENEF,YTIME)	                   "Minimum allowed renewable potential (GW)"		
vScalWeibull(allCy,PGALL,HOUR,YTIME)                       "Temporary variable facilitating the scaling in Weibull equation"	
VCapElec(allCy,PGALL,YTIME)	                               "Electricity generation plants capacity (GW)"	
VGapGenCapPowerDiff(allCy,YTIME)	                       "Gap in total generation capacity to be filled by new equipment (GW)"		
VCostProdTeCHPreReplac(allCy,PGALL,YTIME)                  "Production cost of technology used in premature replacement (US$2015/KWh)"
VIndxEndogScrap(allCy,PGALL,YTIME)	                       "Index used for endogenous power plants scrapping (1)"			
VSensCCS(allCy,YTIME)	                                   "Variable that controlls the sensitivity of CCS acceptance (1)"			
VBaseLoad(allCy,YTIME)	                                   "Corrected base load (GW)"
VCapElec2(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
VCapElecNonCHP(allCy,YTIME)	                               "Total electricity generation capacity excluding CHP (GW)"	
VCostVarTech(allCy,PGALL,YTIME)	                           "Variable cost of technology (US$2015/KWh)"	
VShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"
VShareNewTechCCS(allCy,PGALL,YTIME)	                       "Power plant share in new equipment (1)"		
VCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)           "Hourly production cost of technology (US$2015/KWh)"	
VCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Production cost of technology used in premature replacement including plant availability rate (US$2015/KWh)"			
VCapElecTotEst(allCy,YTIME)	                               "Estimated Total electricity generation capacity (GW)"	
$endif

$ifthen %RUN_TRANSPORT% == yes
*' *** Transport Variables
VActivGoodsTransp(allCy,TRANSE,YTIME)	                   "Goods transport acitivity (Gtkm)"	
VGapTranspActiv(allCy,TRANSE,YTIME)	                       "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)	
VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	           "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
VCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)  "Transportation cost per mean and consumer size (KUS$2015/vehicle)"
VCostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost per mean and consumer size (KUS$2015/vehicle)"
VCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost including maturity factor (KUS$2015/vehicle)"	
VTechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Technology sorting based on variable cost (1)"	
VShareTechTr(allCy,TRANSE,EF,YTIME)	                       "Technology share in new equipment (1)"	
VConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
vDemFinEneSubTransp(allCy,TRANSE,YTIME)	                   "Final energy demand in transport subsectors (Mtoe)"	
VRateScrPc(allCy,YTIME)                                    "Scrapping rate of passenger cars (1)"
VNewRegPcYearly(allCy,YTIME)                               "Passenger cars new registrations (million vehicles)"
VActivPassTrnsp(allCy,TRANSE,YTIME)                        "Passenger transport acitivity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
VMEPcGdp(allCy,YTIME)                                      "Passenger cars market extension (GDP dependent)"
VMEPcNonGdp(allCy,YTIME)                                   "Passenger cars market extension (GDP independent)"
VPcOwnPcLevl(allCy,YTIME)                                  "Ratio of car ownership over saturation car ownership (1)"
VStockPcYearly(allCy,YTIME)                                "Stock of passenger cars (million vehicles)"
VNumPcScrap(allCy,YTIME)                                   "Scrapped passenger cars (million vehicles)"
$endif

$ifthen %RUN_INDUSTRY% == yes
*' ***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
VIndxElecIndPrices(allCy,YTIME)                            "Electricity index - a function of industry price - Estimate (1)"
VCostElecProdCHP(allCy,DSBS,CHP,YTIME)                     "Electricity production cost per CHP plant and demand sector (US$2015/KWh)"
VCostTech(allCy,DSBS,rCon,EF,YTIME)                        "Technology cost (KUS$2015/toe)"
VCostTechIntrm(allCy,DSBS,rcon,EF,YTIME)                   "Intermediate technology cost (KUS$2015/toe)"
VCostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                  "Technology cost including maturity factor (KUS$2015/toe)"
VSortTechVarCost(allCy,DSBS,rCon,YTIME)                    "Technology sorting based on variable cost (1)"
VGapFinalDem(allCy,DSBS,YTIME)                             "Final demand gap to be filed by new technologies (Mtoe)"
VShareTechNewEquip(allCy,DSBS,EF,YTIME)                    "Technology share in new equipment (1)"
VCostProdCHPDem(allCy,DSBS,CHP,YTIME)                      "Variable including fuel electricity production cost per CHP plant and demand sector (US$2015/KWh)"
$endif

$ifthen %RUN_REST_OF_ENERGY% == yes
*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
VPlantEffPlantType(allCy,PGALL,YTIME)	                   "Plant efficiency per plant type (1)"
vConsTotFinEne(YTIME)                                      "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
VOutTransfDhp(allCy,EFS,YTIME)                             "Transformation output from District Heating Plants (Mtoe)"
VCapRef(allCy,YTIME)	                                   "Refineries capacity (Million barrels/day)"	
VOutTransfRefSpec(allCy,EFS,YTIME)	                       "Transformation output from refineries (Mtoe)"
VInputTransfRef(allCy,EFS,YTIME)	                       "Transformation input to refineries (Mtoe)"	
VOutTransfNuclear(allCy,EFS,YTIME)	                       "Transformation output from nuclear plants (Mtoe)"
VInpTransfNuclear(allCy,EFS,YTIME)	                       "Transformation input to nuclear plants (Mtoe)"		
VOutTransfTherm(allCy,EFS,YTIME)	                       "Transformation output from thermal power stations (Mtoe)"
VInpTotTransf(allCy,EFS,YTIME)	                           "Total transformation input (Mtoe)"
VOutTotTransf(allCy,EFS,YTIME)	                           "Total transformation output (Mtoe)"
VTransfers(allCy,EFS,YTIME)	                               "Transfers (Mtoe)"
VConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Gross Inland Consumption not including consumption of energy branch (Mtoe)"
VConsGrssInl(allCy,EFS,YTIME)	                           "Gross Inland Consumption (Mtoe)"
VProdPrimary(allCy,EFS,YTIME)	                           "Primary Production (Mtoe)"	
VExp(allCy,EFS,YTIME)                        	           "Exports fake (Mtoe)" 		
VImp(allCy,EFS,YTIME)             	                       "Fake Imports for all fuels except natural gas (Mtoe)"
$endif

$ifthen %RUN_PRICES% == yes
*' *** Prices Variables
VPriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	               "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"	
VAvgPowerGenLongTrm(allCy,ESET,YTIME)	                   "Long-term average power generation cost (US$2015/kWh)"	 	
$endif

$ifthen %RUN_CO2% == yes
*' *** CO2 SEQUESTRATION COST CURVES VARIABLES
VCapCO2ElecHydr(allCy,YTIME)	                           "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
VCaptCummCO2(allCy,YTIME)	                               "Cumulative CO2 captured (Mtn CO2)"		
VTrnsWghtLinToExp(allCy,YTIME)	                           "Weight for transtition from linear CO2 sequestration cost curve to exponential (1)"
$endif

$ifthen %RUN_EMISSIONS% == yes
*' *** Emissions Constraints Variables
vGrnnHsEmisCO2EquivAllCntr(YTIME)	                       "Total CO2eq GHG emissions in all countries (1)"
VGrnnHsEmisCO2Equiv(NAP,YTIME)	                           "Total CO2eq GHG emissions in all countries per NAP sector (1)"	
vExpendHouseEne(allCy,YTIME)	                           "Households expenditures on energy (billions)"
$endif

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
vConsTotElecInd(allCy,YTIME)                               "Total Consumption of Electricity in industrial sectors (Mtoe)"
VDemFinSubFuelSubsec(allCy,DSBS,YTIME)                     "Total final demand (of substitutable fuels) per subsector (Mtoe)"
vDemFinSubFuelInd(allCy,YTIME)                             "Total final demand (of substitutable fuels) in industrial sectors (Mtoe)"
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
vDummyObj                                                  "Dummy maximisation variable (1)"
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
