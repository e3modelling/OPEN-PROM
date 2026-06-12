*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Parameters
p06CO2CaptureCCS(allCy,SBS,EF,YTIME)                    "Stored CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
p06CaptCummCO2(allCy,YTIME)                             "Stored cumulative CO2 captured (Mtn CO2)"
p06CaptCummCO2Glob(YTIME)                               "Stored global cumulative CO2 captured (Mtn CO2)"
p06GrossCapDAC(CDRTECH,YTIME)                           "Stored CAPEX of DAC technologies with learning curve"
p06FixOandMDAC(CDRTECH,YTIME)                           "Stored fixed and O&M costs of DAC technologies with learning curve"
p06VarCostDAC(CDRTECH,YTIME)                            "Stored variable costs of DAC technologies"
p06LvlCostDAC(allCy,CDRTECH,YTIME)                      "Stored regional DAC levelized cost (US$2015/tCO2)"
p06ProfRateDAC(allCy,CDRTECH,YTIME)                     "Stored annual profitability rate of DAC"
p06CapFacNewDAC(allCy,CDRTECH,YTIME)                    "Stored annual increase factor for DAC installed capacity"
p06CapCDR(allCy,CDRTECH,YTIME)                          "Stored DAC regional installed capacity (tCO2)"
pmCstCO2SeqCsts(allCy,YTIME)                            "Stored CO2 sequestration cost curve (US$2015/tn CO2)"
pmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)           "Stored annual fuel demand in each DAC technology (Mtoe)"
pmConsFuelCDRProd(allCy,EF,YTIME)                       "Stored annual fuel demand in DAC (Mtoe)"
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
;

Scalars
S06ProfRateMaxDAC                                           "The maximum profitability rate of V06DACProfRate" /7.5/
S06CapFacMinNewDAC                                          "The minimum level of the V06DACNewCapFac" /0.015/
S06CapFacMaxNewDAC                                          "The maximum level of the V06DACNewCapFac" /1/
;
