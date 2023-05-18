Parameters
iCGI(allCy,YTIME)                            "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline)) (1)"
iNPDL(SBS)                                   "Number of Polynomial Distribution Lags (PDL) (1)"
iFPDL(SBS,KPDL)                              "Polynomial Distribution Lags (PDL) Coefficients per subsector (1)"
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
iRateLossesFinCons(allCy,EF,YTIME)              "Rate of losses over Available for Final Consumption (1)" 
iEneProdRDscenarios(allCy,SBS,YTIME)            "Energy productivity index used in R&D scenarios (1)" 
iEffDHPlants(allCy,EF,YTIME)                    "Efficiency of District Heating Plants (1)" 
iShareFueTransfInput(allCy,EF)                  "Share of fuels in transformation input to Gasworks, Blast Furnances, Briquetting plants in base year (1)"
iTransfInpGasworks(allCy,EF,YTIME)              "Transformation Input in Gasworks, Blast Furnances, Briquetting plants (Mtoe)"
iResRefCapacity(allCy,YTIME)	                "Residual in Refineries Capacity (1)"
iRefCapacity(allCy,YTIME)	                    "Refineries Capacity (Million Barrels/day)"
iResTransfOutputRefineries(allCy,EF,YTIME)      "Residual in Transformation Output from Refineries (Mtoe)"
iRateEneBranCons(allCy,EF,YTIME)	            "Rate of Energy Branch Consumption over total transformation output (1)"
iResFeedTransfr(allCy,YTIME)	                "Residual for Feedstocks in Transfers (1)"	
iFeedTransfr(allCy,EFS,YTIME)	                "Feedstocks in Transfers (Mtoe)"
iResHcNgOilPrProd(allCy,EF,YTIME)	            "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
iNatGasPriProElst(allCy)	                    "Natural Gas primary production elasticity related to gross inland consumption (1)"	/
$ondelim
$include "./iNatGasPriProElst.csv"
$offdelim
/
iFuelPriPro(allCy,EF,YTIME)                 	"Fuel Primary Production (Mtoe)"
iIntPricesMainFuels(WEF,YTIME)	                "International Prices of main fuels (kEuro05/toe)"	
iIntFuelPrices(WEF,YTIME)	                    "International Fuel Prices (dollars2015/toe)"
iIntPricesMainFuelsBsln(WEF,YTIME)          	"International Prices of main fuels in Baseline scenario (kEuro2005/toe)"
iPolDstrbtnLagCoeffPriOilPr(kpdl)	            "Polynomial Distribution Lag Coefficients for primary oil production (1)"/
$ondelim
$include "./iPolDstrbtnLagCoeffPriOilPr.csv"
$offdelim
/	
iRatePriProTotPriNeeds(allCy,EF,YTIME)	        "Rate of Primary Production in Total Primary Needs (1)"	
iFuelExprts(allCy,EF,YTIME)	                    "Fuel Exports (Mtoe)"	
iSuppExports(allCy,EF,YTIME)                	"Supplementary parameter for  exports (Mtoe)"
iRatioImpFinElecDem(allCy,YTIME)	            "Ratio of imports in final electricity demand (1)"	
iElastCO2Seq(allCy,CO2SEQELAST)	                "Elasticities for CO2 sequestration cost curve (1)"	
iBaseLoadShareDem(allCy,DSBS,YTIME)	            "Baseload share of demand per sector (1)"
iLoadFacElecDem(allCy,DSBS,YTIME)	            "Load factor of electricity demand per sector (1)"
iMxmLoadFacElecDem(allCy,YTIME)	                "Maximum load factor of electricity demand (1)"	
iBslCorrection(allCy,YTIME)	                    "Parameter of baseload correction (1)"
iLoadCurveConstr(allCy,YTIME)	                "Parameter for load curve construction (1)"
iResMargTotAvailCap(allCy,PGRES,YTIME)	        "Reserve margins on total available capacity and peak load (1)"
iTechLftPlaType(PGALL)	                        "Technical Lifetime per plant type (year)"/
$ondelim
$include "./iTechLftPlaType.csv"
$offdelim
/
iPlantAvailRate(allCy,PGALL,YTIME)	      "Plant availability rate (1)"
iGrossCapCosSubRen(allCy,PGALL,YTIME)	  "Gross Capital Cost per Plant Type with subsidy for renewables (kEuro2005/KW)"		
iVarGroCostPlaType(allCy,PGALL,YTIME)	  "Variable gross cost other than fuel per Plant Type (Euro2005/KW)"
iCapGrossCosPlanType(allCy,PGALL,YTIME)	  "Capital gross cost per plant type (kEuro2005/KW)"	
iFixGrosCostPlaType(allCy,PGALL,YTIME)	  "Fixed O&M Gross Cost per Plant Type (Euro2005/KW)"
*iDataElecSteamGen(PGOTH,YTIME)	          "Various Data releated to electricity and steam generation (1)"
iCO2CaptRate(allCy,PGALL,YTIME)	          "Plant CO2 capture rate (1)"
iCO2CaptRateData(PGALL)	                  "Plant CO2 capture rate Data (1)"/
$ondelim
$include "./iCO2CaptRateData.csv"
$offdelim
/
iScaleEndogScrap(allCy,PGALL,YTIME)	"Scale parameter for endogenous scrapping applied to the sum of full costs (1)"	
iPremReplacem(allCy,PGALL)	    "Premature replacement (1)"/
$ondelim
$include"./iPremReplacem.csv"
$offdelim
/
;


Equations
*** Power Generation
QElecDem(allCy,YTIME)                      "Compute total electricity demand"
QElecConsAll(allCy,DSBS,YTIME)             "Compute electricity consumption per final demand sector"
QEstBaseLoad(allCy,YTIME)	               "Compute estimated base load"	
QLoadFacDom(allCy,YTIME)	               "Compute load factor of entire domestic system"
QElecPeakLoad(allCy,YTIME)	               "Compute elerctricity peak load"		
QBslMaxmLoad(allCy,YTIME) 	               "Compute baseload corresponding to maximum load"
QElecBaseLoad(allCy,YTIME)	               "Compute electricity base load"
QShrcap(allCy,PGALL,YTIME)	               "Compute SHRCAP"	
QEndogScrapIndex(allCy,PGALL,YTIME)	       "Compute endogenous scrapping index" 	
QProdCostTechPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	"Compute production cost of technology  used in premature replacement including plant availability rate"	
QVarCostTechNotPGSCRN(allCy,PGALL,YTIME)   "Compute variable cost of technology excluding PGSCRN"	
QVarCostTech(allCy,PGALL,YTIME)	           "Compute variable cost of technology" 	
QTotReqElecProd(allCy,YTIME)               "Compute total required electricity production"
QTotEstElecGenCap(allCy,YTIME)             "Compute Estimated total electricity generation capacity"	
QTotElecGenCap(allCy,YTIME)	               "Compute total electricity generation capacity"
QHourProdCostInv(allCy,PGALL,HOUR,YTIME)   "Compute hourly production cost used in investment decisions"
QHourProdCostInvDec(allCy,PGALL,HOUR,YTIME)"Compute hourly production cost used in investment decisions"
QGammaInCcsDecTree(allCy,YTIME)	           "Compute gamma parameter used in CCS/No CCS decision tree"
QHourProdCostInvDecisions(allCy,PGALL,HOUR,YTIME)	"Compute hourly production cost used in investment decisions"
QProdCostInvDecis(allCy,PGALL,YTIME)	            "Compute production cost used in investment decisions"
QShrcapNoCcs(allCy,PGALL,YTIME)	                    "Compute SHRCAP excluding CCs"
QProdCostTechPreReplac(allCy,PGALL,YTIME)	        "Compute production cost of technology  used in premature replacement"												
*** Transport
QMExtV(allCy,YTIME)            "Compute passenger cars market extension (GDP dependent)"
QMExtF(allCy,YTIME)            "Compute passenger cars market extension (GDP independent)"
QNumVeh(allCy,YTIME)           "Compute stock of passenger cars (in million vehicles)"
QNewReg(allCy,YTIME)           "Compute new registrations of passenger cars"
QTrnspActiv(allCy,TRANSE,YTIME)"Compute passenger transport acitivity"
QScrap(allCy,YTIME)            "Compute scrapped passenger cars"
QLevl(allCy,YTIME)             "Compute ratio of car ownership over saturation car ownership"
QScrRate(allCy,YTIME)          "Compute passenger cars scrapping rate"


***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
QDemSub(allCy,DSBS,YTIME)                     "Compute total final demand per subsector"
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
QVarProCostPerCHPDem(allCy,DSBS,CHP,YTIME)    "Compute  variable including fuel electricity production cost per CHP plant and demand sector "
QAvgElcProCostCHP(allCy,CHP,YTIME)            "Compute Average Electricity production cost per CHP plant"
QAvgVarElecProd(allCy,CHP,YTIME)              "Compute Average variable including fuel electricity production cost per CHP plant"

*** REST OF ENERGY BALANCE SECTORS EQUATIONS
QTotFinEneCons(allCy,EFS,YTIME)              "Compute total final energy consumption"
QTotFinEneConsAll(YTIME)                     "Compute total final energy consumption in ALL countries"
QFinNonEneCons(allCy,EFS,YTIME)              "Compute final non-energy consumption"
QDistrLosses(allCy,EFS,YTIME)                "Compute distribution losses"
QTranfOutputDHPlants(allCy,EFS,YTIME)        "Compute the transformation output from district heating plants"
QTransfInputDHPlants(allCy,EFS,YTIME)        "Compute the transformation input to distrcit heating plants"
QTransfInputPatFuel(allCy,EFS,YTIME)         "Compute the transfomration input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works"
QRefCapacity(allCy,YTIME)	                 "Compute refineries capacity"	
QTranfOutputRefineries(allCy,EFS,YTIME)	     "Compute the transformation output from refineries"
QTransfInputRefineries(allCy,EFS,YTIME)	     "Compute the transformation input to refineries"
QTransfOutputNuclear(allCy,EFS,YTIME)	     "Compute transformation output from nuclear plants"
QTransfInNuclear(allCy,EFS,YTIME)	         "Compute transformation input to nuclear plants"
QTransfInPowerPls(allCy,EFS,YTIME)	         "Compute transformation input to power plants"	
QTransfOutThermPP(allCy,EFS,YTIME)	         "Compute transformation output from thermal power plants"
QTotTransfInput(allCy,EFS,YTIME)	         "Compute total transformation input"
QTotTransfOutput(allCy,EFS,YTIME)	         "Compute total transformation output"
QTransfers(allCy,EFS,YTIME)	                 "Compute transfers"
QGrsInlConsNotEneBranch(allCy,EFS,YTIME)	 "Compute gross inland consumption not including consumption of energy branch"	
QGrssInCons(allCy,EFS,YTIME)	             "Compute gross inland consumption"	
QPrimProd(allCy,EFS,YTIME)	                 "Compute primary production"	
QFakeExp(allCy,EFS,YTIME)	                 "Compute fake exports"	
QFakeImprts(allCy,EFS,YTIME)	             "Compute fake imports"	
QNetImports(allCy,EFS,YTIME)	             "Compute net imports"
QEneBrnchEneCons(allCy,EFS,YTIME)	         "Compute energy branch final consumption"

*** CO2 SEQUESTRATION COST CURVES EQUATIONS
QCO2ElcHrg(allCy,YTIME)	                     "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
QCumCO2Capt(allCy,YTIME)	                 "Compute cumulative CO2 captured (Mtn of CO2)"
QWghtTrnstLinToExpo(allCy,YTIME)	         "Transtition weight for shifting from linear to exponential CO2 sequestration cost curve"
QCstCO2SeqCsts(allCy,YTIME)	                 "Compute cost curve for CO2 sequestration costs" 														
*** Miscellaneous
qDummyObj                                     "Define dummy objective function"
;


Variables

*** Power Generation Variables
VEstBaseLoad(allCy,YTIME)	              "Estimated base load (GW)"	
VElecDem(allCy,YTIME)                     "Total electricity demand (TWh)"
VCapChpPlants(allCy,YTIME)                "Capacity of CHP Plants (GW)"	
VElecPeakLoad(allCy,YTIME)	              "Electricity peak load (GW)"	
VBslMaxmLoad(allCy,YTIME)	              "Baseload corresponding to Maximum Load Factor (1)"
VHourProdCostOfTech(allCy,PGALL,HOUR,YTIME)"Hourly production cost of technology (Euro/KWh)"
VVarCostTechNotPGSCRN(allCy,PGALL,YTIME)   "Variable cost of technology excluding PGSCRN (Euro/KWh)"		
VHourProdTech(allCy,PGALL,HOUR,YTIME)     "Hourly production cost of technology (Euro/KWh)"
VProdCostTechnology(allCy,PGALL,YTIME)	  "Production cost of technology (Euro/KWh)"
VProdCostTechPreReplac(allCy,PGALL,YTIME) "Production cost of technology used in premature replacement (Euro/KWh)"
VEndogScrapIndex(allCy,PGALL,YTIME)	      "Index used for endogenous power plants scrapping (1)"			
VSensCcs(allCy,YTIME)	                  "Variable that controlls the sensitivity of CCS acceptance (1)"			
VCorrBaseLoad(allCy,YTIME)	              "Corrected base load (GW)"
VVarCostTech(allCy,PGALL,YTIME)	          "Variable cost of technology (Euro/KWh)"	
VPowerPlantNewEq(allCy,PGALL,YTIME)	      "Power plant share in new equipment (1)"
VPowerPlaShrNewEq(allCy,PGALL,YTIME)	  "Power plant share in new equipment (1)"		
VHourProdCostTech(allCy,PGALL,HOUR,YTIME) "Hourly production cost of technology (Euro/KWh)"	
VProdCostTechPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	"Production cost of technology used in premature replacement  including plant availability rate (Euro/KWh)"		
VTotReqElecProd(allCy,YTIME)	      "Total required electricity production (TWh)"	
VTotElecGenCapEst(allCy,YTIME)	      "Estimated Total electricity generation capacity (GW)"	
VTotElecGenCap(allCy,YTIME)	          "Total electricity generation capacity (GW)"	
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
VProCostCHPDem(allCy,DSBS,CHP,YTIME)                    "Variable including fuel electricity production cost per CHP plant and demand sector (Euro/KWh)"
VAvgElcProCHP(allCy,CHP,YTIME)                          "Average Electricity production cost per CHP plant (Euro/KWh)"
VAvgVarProdCostCHP(allCy,CHP,YTIME)                     "Average variable including fuel electricity production cost per CHP plant (Euro/KWh)"

*** REST OF ENERGY BALANCE SECTORS VARIABLES
VTotFinEneCons(allCy,EF,YTIME)                          "Total final energy Consumption (Mtoe)"
VTotFinEneConsAll(YTIME)                                "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
VDistrLosses(allCy,EFS,YTIME)                           "Distribution losses (Mtoe)"
VTransfOutputDHPlants(allCy,EFS,YTIME)                  "Transformation output from District Heating Plants (Mtoe)"
VTransfInputDHPlants(allCy,EFS,YTIME)                   "Transformation input to District Heating Plants (Mtoe)"
VTransfInputPatFuel(allCy,EFS,YTIME)                    "Transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
VTransfOutputPatFuel(allCy,EFS,YTIME)                   "Transformation input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works (1)"
VRefCapacity(allCy,YTIME)	                            "Refineries capacity (Million barrels/day)"	
VTransfOutputRefineries(allCy,EFS,YTIME)	            "Transformation output from refineries (Mtoe)"
VTransfInputRefineries(allCy,EFS,YTIME)	                "Transformation input to refineries (Mtoe)"	
VTransfOutputNuclear(allCy,EFS,YTIME)	                "Transformation output from nuclear plants (Mtoe)"
VElecProd(allCy,PGALL,YTIME)	                        "Electricity production (TWh)"
VTransfInNuclear(allCy,EFS,YTIME)	                    "Transformation input to nuclear plants (Mtoe)"	
VPlantEffPlantType(allCy,PGALL,YTIME)	                "Plant efficiency per plant type (1)"	
VTransfInThermPowPls(allCy,EFS,YTIME)	                "Transformation input to thermal power plants (Mtoe)"
VChpElecProd(allCy,CHP,YTIME)	                        "CHP electricity production (TWh)"
VTransfOutThermPowSta(allCy,EFS,YTIME)	                "Transformation output from thermal power stations (Mtoe)"
VTotTransfInput(allCy,EFS,YTIME)	                    "Total transformation input (Mtoe)"
VTotTransfOutput(allCy,EFS,YTIME)	                    "Total transformation output (Mtoe)"
VTransfers(allCy,EFS,YTIME)	                            "Transfers (Mtoe)"
VGrsInlConsNotEneBranch(allCy,EFS,YTIME)	            "Gross Inland Consumption not including consumption of energy branch (Mtoe)"
VGrssInCons(allCy,EFS,YTIME)	                        "Gross Inland Consumption (Mtoe)"
VPrimProd(allCy,EFS,YTIME)	                            "Primary Production (Mtoe)"	
VExportsFake(allCy,EFS,YTIME)                        	"Exports fake (Mtoe)" 		
VFkImpAllFuelsNotNatGas(allCy,EFS,YTIME)             	"Fake Imports for all fuels except natural gas (Mtoe)"
VNetImports(allCy,EFS,YTIME)	                        "Net Imports (Mtoe)"

*** CO2 SEQUESTRATION COST CURVES VARIABLES
VCO2ElcHrgProd(allCy,YTIME)	                            "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
VCumCO2Capt(allCy,YTIME)	                            "Cumulative CO2 captured (Mtn CO2)"		
VWghtTrnstLnrToExpo(allCy,YTIME)	                    "Weight for transtition from linear CO2 sequestration cost curve to exponential (1)"
VCO2CO2SeqCsts(allCy,YTIME)	                            "Cost curve for CO2 sequestration costs (Euro/tn of CO2 sequestrated)"				 	 				
*** Miscellaneous
vDummyObj                                               "Dummy maximisation variable (1)"
;


Scalars
sTWhToMtoe         "TWh to Mtoe conversion factor" /0.086/
sElecToSteRatioChp "Technical maximum of electricity to steam ratio in CHP plants" /1.15/
sGwToTwhPerYear     "convert GW mean power into TWh/y" /8.76/
;