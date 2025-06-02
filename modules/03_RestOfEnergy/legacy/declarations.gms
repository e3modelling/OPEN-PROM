*' @title REST OF ENERGY BALANCE SECTORS Declarations
*' @code

Equations
*' *** REST OF ENERGY BALANCE SECTORS EQUATIONS
*qConsTotFinEne(YTIME)                                     "Compute total final energy consumption in ALL countries"
QOutTransfDhp(allCy,EFS,YTIME)                             "Compute the transformation output from district heating plants"
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

*'                **Interdependent Equations**
Q03ImpNetEneBrnch(allCy,EFS,YTIME)	                       "Compute net imports"
Q03ConsFiEneSec(allCy,EFS,YTIME)	                       "Compute energy branch final consumption"
Q03InpTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation input to power plants"	
Q03TransfInputDHPlants(allCy,EFS,YTIME)                    "Compute the transformation input to distrcit heating plants"
Q03ConsFinEneCountry(allCy,EFS,YTIME)                      "Compute total final energy consumption"
Q03ConsFinNonEne(allCy,EFS,YTIME)                          "Compute final non-energy consumption"
Q03LossesDistr(allCy,EFS,YTIME)                            "Compute distribution losses"
;

Variables
*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
*vConsTotFinEne(YTIME)                                     "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
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

*'                **Interdependent Variables**
MVImpNetEneBrnch(allCy,EFS,YTIME)	                       "Net Imports (Mtoe)"
MVConsFiEneSec(allCy,EFS,YTIME)                            "Final consumption in energy sector (Mtoe)"
MVInpTransfTherm(allCy,EFS,YTIME)	                       "Transformation input to thermal power plants (Mtoe)"
MVTransfInputDHPlants(allCy,EFS,YTIME)                     "Transformation input to District Heating Plants (Mtoe)"
MVConsFinEneCountry(allCy,EF,YTIME)                        "Total final energy consumnption (Mtoe)"
MVConsFinNonEne(allCy,EFS,YTIME)                           "Final non energy consumption (Mtoe)"
MVLossesDistr(allCy,EFS,YTIME)                             "Distribution losses (Mtoe)"
;