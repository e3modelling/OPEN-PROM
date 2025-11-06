*' @title REST OF ENERGY BALANCE SECTORS Declarations
*' @code

Equations
*' *** REST OF ENERGY BALANCE SECTORS EQUATIONS
*q03ConsTotFinEne(YTIME)                                   "Compute total final energy consumption in ALL countries"
Q03OutTransfDhp(allCy,EFS,YTIME)                           "Compute the transformation output from district heating plants"
Q03OutTransfCHP(allCy,EFS,YTIME)                            "Compute the transformation output from CHP (Mtoe)"
Q03CapRef(allCy,YTIME)	                                   "Compute refineries capacity"
Q03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Compute the transformation output from refineries"
Q03InputTransfRef(allCy,EFS,YTIME)	                       "Compute the transformation input to refineries"
Q03OutTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation output from thermal power plants"
Q03InpTotTransf(allCy,EFS,YTIME)	                       "Compute total transformation input"
Q03OutTotTransf(allCy,EFS,YTIME)	                       "Compute total transformation output"
Q03Transfers(allCy,EFS,YTIME)	                           "Compute transfers"
Q03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Compute gross inland consumption not including consumption of energy branch"
Q03ConsGrssInl(allCy,EFS,YTIME)	                           "Compute gross inland consumption"
Q03ProdPrimary(allCy,EFS,YTIME)	                           "Compute primary production"
Q03Exp(allCy,EFS,YTIME)	                                   "Compute fake exports"
Q03Imp(allCy,EFS,YTIME)	                                   "Compute fake imports"

*'                **Interdependent Equations**
Q03ImpNetEneBrnch(allCy,EFS,YTIME)	                       "Compute net imports"
Q03ConsFiEneSec(allCy,EFS,YTIME)	                       "Compute energy branch final consumption"
Q03InpTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation input to power plants"	
Q03TransfInputDHPlants(allCy,EFS,YTIME)                    "Compute the transformation input to distrcit heating plants"
Q03TransfInputCHPlants(allCy,EFS,YTIME) 
Q03ConsFinEneCountry(allCy,EFS,YTIME)                      "Compute total final energy consumption"
Q03ConsFinNonEne(allCy,EFS,YTIME)                          "Compute final non-energy consumption"
Q03LossesDistr(allCy,EFS,YTIME)                            "Compute distribution losses"
Q03CarbTaxTot(allCy,YTIME)                                 "Compute the total annual state revenues from carbon taxes per region (Millions US$2015)"
Q03SubsiStat(allCy,SBS,YTIME)                               ""
;

Variables
*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
*v03ConsTotFinEne(YTIME)                                   "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
V03OutTransfDhp(allCy,STEAM,YTIME)                           "Transformation output from District Heating Plants (Mtoe)"
V03OutTransfCHP(allCy,TOCTEF,YTIME)                            "Transformation output from CHP (Mtoe)"
V03CapRef(allCy,YTIME)	                                   "Refineries capacity (Million barrels/day)"
V03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Transformation output from refineries (Mtoe)"
V03InputTransfRef(allCy,EFS,YTIME)	                       "Transformation input to refineries (Mtoe)"
V03OutTransfTherm(allCy,EFS,YTIME)	                       "Transformation output from thermal power stations (Mtoe)"
V03InpTotTransf(allCy,EFS,YTIME)	                       "Total transformation input (Mtoe)"
V03OutTotTransf(allCy,EFS,YTIME)	                       "Total transformation output (Mtoe)"
V03Transfers(allCy,EFS,YTIME)	                           "Transfers (Mtoe)"
V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Gross Inland Consumption not including consumption of energy branch (Mtoe)"
V03ConsGrssInl(allCy,EFS,YTIME)	                           "Gross Inland Consumption (Mtoe)"
V03ProdPrimary(allCy,EFS,YTIME)	                           "Primary Production (Mtoe)"
V03Exp(allCy,EFS,YTIME)                        	           "Exports fake (Mtoe)"
V03Imp(allCy,EFS,YTIME)             	                   "Fake Imports for all fuels except natural gas (Mtoe)"
V03CarbTaxTot(allCy,YTIME)                                 "Total annual state revenues from carbon taxes per region (Millions US$2015)"

*'                **Interdependent Variables**
VmImpNetEneBrnch(allCy,EFS,YTIME)	                       "Net Imports (Mtoe)"
VmConsFiEneSec(allCy,EFS,YTIME)                            "Final consumption in energy sector (Mtoe)"
VmInpTransfTherm(allCy,EFS,YTIME)	                       "Transformation input to thermal power plants (Mtoe)"
VmTransfInputDHPlants(allCy,EFS,YTIME)                     "Transformation input to District Heating Plants (Mtoe)"
VmTransfInputCHPlants(allCy,EFS,YTIME)                    "Transformation input to CHPs (Mtoe)"
VmConsFinEneCountry(allCy,EF,YTIME)                        "Total final energy consumnption (Mtoe)"
VmConsFinNonEne(allCy,EFS,YTIME)                           "Final non energy consumption (Mtoe)"
VmLossesDistr(allCy,EFS,YTIME)                             "Distribution losses (Mtoe)"
VmSubsiStat(allCy,SBS,YTIME)                               "State subsidies per subsector (Millions US$2015)"
;