*' @title REST OF ENERGY BALANCE SECTORS Declarations
*' @code

Equations
*' *** REST OF ENERGY BALANCE SECTORS EQUATIONS
*q03ConsTotFinEne(YTIME)                                   "Compute total final energy consumption in ALL countries"
Q03OutTransfCHP(allCy,TOCTEF,YTIME)                            "Compute the transformation output from CHP (Mtoe)"
*Q03CapRef(allCy,YTIME)	                                   "Compute refineries capacity"
Q03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Compute the transformation output from refineries"
Q03OutTransfGasses(allCy,EFS,YTIME)	
Q03OutTransfSolids(allCy,EFS,YTIME)
Q03InputTransfRef(allCy,EFS,YTIME)	                       "Compute the transformation input to liquids"
Q03InputTransfSolids(allCy,EFS,YTIME)	                     "Compute the transformation input to solids"
Q03InputTransfGasses(allCy,EFS,YTIME)	                     "Compute the transformation input to gasses"
Q03InpTotTransf(allCy,SSBS,EFS,YTIME)	                       "Compute total transformation input"
Q03OutTotTransf(allCy,SSBS,EFS,YTIME)	                       "Compute total transformation output"
Q03Transfers(allCy,EFS,YTIME)	                           "Compute transfers"
Q03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Compute gross inland consumption not including consumption of energy branch"
Q03ConsGrssInl(allCy,EFS,YTIME)	                           "Compute gross inland consumption"
Q03ProdPrimary(allCy,EFS,YTIME)	                           "Compute primary production"
Q03Exp(allCy,EFS,YTIME)	                                   "Compute fake exports"
Q03Imp(allCy,EFS,YTIME)	                                   "Compute fake imports"

*'                **Interdependent Equations**
Q03ImpNetEneBrnch(allCy,EFS,YTIME)	                       "Compute net imports"
Q03ConsFiEneSec(allCy,SSBS,EFS,YTIME)	                       "Compute energy branch final consumption"
Q03ConsFinEneCountry(allCy,EFS,YTIME)                      "Compute total final energy consumption"
Q03ConsFinNonEne(allCy,EFS,YTIME)                          "Compute final non-energy consumption"
Q03LossesDistr(allCy,EFS,YTIME)                            "Compute distribution losses"
;

Variables
*' *** REST OF ENERGY BALANCE SECTORS VARIABLES
*v03ConsTotFinEne(YTIME)                                   "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
V03OutTransfCHP(allCy,TOCTEF,YTIME)                            "Transformation output from CHP (Mtoe)"
*V03CapRef(allCy,YTIME)	                                   "Refineries capacity (Million barrels/day)"
V03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Transformation output from refineries (Mtoe)"
V03OutTransfGasses(allCy,EFS,YTIME)	
V03OutTransfSolids(allCy,EFS,YTIME)
V03InputTransfRef(allCy,EFS,YTIME)	                       "Transformation input to liquids supply sector (Mtoe)"
V03InputTransfSolids(allCy,EFS,YTIME)	                     "Transformation input to solids supply sector (Mtoe)"
V03InputTransfGasses(allCy,EFS,YTIME)	                     "Transformation input to gasses supply sector (Mtoe)"
V03InpTotTransf(allCy,SSBS,EFS,YTIME)	                       "Total transformation input (Mtoe)"
V03OutTotTransf(allCy,SSBS,EFS,YTIME)	                       "Total transformation output (Mtoe)"
V03Transfers(allCy,EFS,YTIME)	                           "Transfers (Mtoe)"
V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Gross Inland Consumption not including consumption of energy branch (Mtoe)"
V03ConsGrssInl(allCy,EFS,YTIME)	                           "Gross Inland Consumption (Mtoe)"
V03ProdPrimary(allCy,EFS,YTIME)	                           "Primary Production (Mtoe)"
V03Exp(allCy,EFS,YTIME)                        	           "Exports fake (Mtoe)"
V03Imp(allCy,EFS,YTIME)             	                   "Fake Imports for all fuels except natural gas (Mtoe)"

*'                **Interdependent Variables**
VmImpNetEneBrnch(allCy,EFS,YTIME)	                       "Net Imports (Mtoe)"
VmConsFiEneSec(allCy,SSBS,EFS,YTIME)                            "Final consumption in energy sector (Mtoe)"
VmConsFinEneCountry(allCy,EF,YTIME)                        "Total final energy consumnption (Mtoe)"
VmConsFinNonEne(allCy,EFS,YTIME)                           "Final non energy consumption (Mtoe)"
VmLossesDistr(allCy,EFS,YTIME)                             "Distribution losses (Mtoe)"
;