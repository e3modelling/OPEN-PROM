*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Parameters
p06CaptCummCO2(allCy,YTIME)                         "Historical cumulative captured CO2"
p06CapCDR(allCy,CDRTECH,YTIME)                     "Historical CDR capacity"
p06LvlCostDAC(allCy,CDRTECH,YTIME)                 "Historical DAC levelized cost"
p06CapFacNewDAC(allCy,CDRTECH,YTIME)               "Historical DAC new capacity factor"
p06CO2CaptureCCS(allCy,SBS,EF,YTIME)               "Historical CO2 captured by CCS"
p06CaptCummCO2Glob(YTIME)                          "Historical global cumulative captured CO2"
p06GrossCapDAC(CDRTECH,YTIME)                      "Historical DAC CAPEX with learning"
p06FixOandMDAC(CDRTECH,YTIME)                      "Historical DAC fixed O and M costs with learning"
p06VarCostDAC(CDRTECH,YTIME)                       "Historical DAC variable costs with learning"
p06ProfRateDAC(allCy,CDRTECH,YTIME)                "Historical DAC profitability rate"
p06CstCO2SeqCsts(allCy,YTIME)                      "Historical CO2 sequestration cost curve"
p06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)     "Historical fuel demand by CDR technology"
p06ConsFuelCDRProd(allCy,EF,YTIME)                 "Historical total fuel demand in CDR"
;

Equations
Q06CO2CaptureCCS(allCy,SBS,EF,YTIME)	               "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
Q06CaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
Q06CaptCummCO2Glob(YTIME)                                   "Compute global cumulative CO2 captured (Mtn of CO2)"
Q06GrossCapDAC(CDRTECH,YTIME)                        "Computes CAPEX of DAC technologies with learning curve"
Q06FixOandMDAC(CDRTECH,YTIME)                        "Computes Fixed and O&M costs of DAC technologies with learning curve"
Q06LvlCostDAC(allCy,CDRTECH,YTIME)                         "Calculates the CAPEX and the Fixed Costs of DAC capacity regionally (US$2015/tCO2)"
Q06VarCostDAC(CDRTECH,YTIME)                               "Computes variable costs of DAC technologies including carbon storage costs, with learning curve"
Q06ProfRateDAC(allCy,CDRTECH,YTIME)                        "Computes the annual profitability rate of DAC including the lifecycle costs and revenues regionally"
Q06CapFacNewDAC(allCy,CDRTECH,YTIME)                       "Computes the factor expressing the annual increase in the installed capacity of DAC regionally"
Q06CapCDR(allCy,CDRTECH,YTIME)                             "Computes the DAC installed capacity annually and regionally"
Q06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)             "Computes the annual fuel demand in each CDR technology regionally (Mtoe)"
Q06ConsFuelCDRProd(allCy,EF,YTIME)                         "Computes the annual fuel demand in CDR regionally (Mtoe)"

*'                **Interdependent Equations**
Q06CstCO2SeqCsts(allCy,YTIME)	                           "Compute cost curve for CO2 sequestration costs" 
;

Variables
V06CO2CaptureCCS(allCy,SBS,EF,YTIME)	                "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
V06CaptCummCO2(allCy,YTIME)	                              "Cumulative CO2 captured (Mtn CO2)"
V06CaptCummCO2Glob(YTIME)                                   "Global cumulative CO2 captured (Mtn of CO2)"
V06GrossCapDAC(CDRTECH,YTIME)                        "CAPEX of DAC technologies with learning curve"
V06FixOandMDAC(CDRTECH,YTIME)                        "Fixed and O&M costs of DAC technologies with learning curve"
V06VarCostDAC(CDRTECH,YTIME)                         "Variable costs of DAC technologies including carbon storage costs, with learning curve"
V06LvlCostDAC(allCy,CDRTECH,YTIME)                         "Regional CAPEX and the Fixed Costs of DAC capacity (US$2015/tCO2)"
V06ProfRateDAC(allCy,CDRTECH,YTIME)                        "The annual profitability rate of DAC including the lifecycle costs and revenues regionally"
V06CapFacNewDAC(allCy,CDRTECH,YTIME)                       "Factor expressing the annual increase in the installed capacity of DAC regionally"
V06CapCDR(allCy,CDRTECH,YTIME)                             "DAC regional installed capacity (tCO2)"

*'                **Interdependent Variables**
VmCstCO2SeqCsts(allCy,YTIME)	                           "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"
VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)              "Annual fuel demand in each DAC technology regionally (Mtoe)"
VmConsFuelCDRProd(allCy,EF,YTIME)                          "Annual fuel demand in DAC regionally (Mtoe)"
;

Scalars
S06ProfRateMaxDAC                                           "The maximum profitability rate of V06DACProfRate" /7.5/
S06CapFacMinNewDAC                                          "The minimum level of the V06DACNewCapFac" /0.015/
S06CapFacMaxNewDAC                                          "The maximum level of the V06DACNewCapFac" /1/
;