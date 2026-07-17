*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Equations
Q06CO2CaptureCCS(allCy,SBS,EF,YTIME)	               "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
Q06CaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
Q06CaptCummCO2Glob(YTIME)                                   "Compute global cumulative CO2 captured (Mtn of CO2)"
Q06GrossCapCDR(CDRTECH,YTIME)                        "Computes CAPEX of CDR technologies with learning curve"
Q06FixOandMCDR(CDRTECH,YTIME)                        "Computes Fixed and O&M costs of CDR technologies with learning curve"
Q06LvlCostCDR(allCy,CDRTECH,YTIME)                         "Calculates the CAPEX and the Fixed Costs of CDR capacity regionally (US$2015/tCO2)"
Q06VarCostCDR(CDRTECH,YTIME)                               "Computes variable costs of CDR technologies including carbon storage costs, with learning curve"
Q06CostFullCDR(allCy,CDRTECH,YTIME)                        "Calculates the Levelized Costs of CDR capacity including its subsidy, for each region (country) and year"
Q06ProfRateCDR(allCy,CDRTECH,YTIME)                        "Computes the annual profitability rate of CDR including the lifecycle costs and revenues regionally"
Q06CapFacNewCDR(allCy,CDRTECH,YTIME)                       "Computes the factor expressing the annual increase in the installed capacity of CDR regionally"
Q06GapCDR(allCy,CDRTECH,YTIME)                             "Computes the CDR deployment gap for each region, technology and year (tCO2)"
Q06CapCDR(allCy,CDRTECH,YTIME)                             "Computes the CDR installed capacity annually and regionally (tCO2)"
Q06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)             "Computes the annual fuel demand in each CDR technology regionally (Mtoe)"
*'                **Interdependent Equations**
Q06CstCO2SeqCsts(allCy,YTIME)	                           "Compute cost curve for CO2 sequestration costs" 
;

Variables
V06CO2CaptureCCS(allCy,SBS,EF,YTIME)	                "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
V06CaptCummCO2(allCy,YTIME)	                              "Cumulative CO2 captured (Mtn CO2)"
V06CaptCummCO2Glob(YTIME)                                   "Global cumulative CO2 captured (Mtn of CO2)"
V06GrossCapCDR(CDRTECH,YTIME)                        "CAPEX of CDR technologies with learning curve"
V06FixOandMCDR(CDRTECH,YTIME)                        "Fixed and O&M costs of CDR technologies with learning curve"
V06VarCostCDR(CDRTECH,YTIME)                         "Variable costs of CDR technologies including carbon storage costs, with learning curve"
V06LvlCostCDR(allCy,CDRTECH,YTIME)                         "Regional CAPEX and the Fixed Costs of CDR capacity (US$2015/tCO2)"
V06CostFullCDR(allCy,CDRTECH,YTIME)                        "Levelized Costs of CDR capacity including its subsidy, for each region (country) and year (US$2015/tCO2)"
V06ProfRateCDR(allCy,CDRTECH,YTIME)                        "The annual profitability rate of CDR including the lifecycle costs and revenues regionally"
V06CapFacNewCDR(allCy,CDRTECH,YTIME)                       "Factor expressing the annual increase in the installed capacity of CDR regionally"
V06GapCDR(allCy,CDRTECH,YTIME)                            "The CDR deployment gap for each region, technology and year (tCO2)"
V06CapCDR(allCy,CDRTECH,YTIME)                             "CDR regional installed capacity (tCO2)"

*'                **Interdependent Variables**
VmCstCO2SeqCsts(allCy,YTIME)	                           "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"
VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)              "Annual fuel demand in each CDR technology regionally (Mtoe)"
;

Scalars
S06EmissPercCDR                                        "The percentage of emissions that needs to be captured by new CDR equipment" /0.03/
S06CapFacMinNewCDR                                     "The minimum level of CDR capacity expansion as a percentage of last year's capacity" /0.05/
;