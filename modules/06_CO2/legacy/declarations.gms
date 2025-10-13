*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Equations
Q06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME)	                           "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
Q06CaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
Q06TrnsWghtLinToExp(allCy,YTIME)	                       "Transtition weight for shifting from linear to exponential CO2 sequestration cost curve"
Q06GrossCapDAC(DACTECH,YTIME)                        "Computes CAPEX of DAC technologies with learning curve"
Q06FixOandMDAC(DACTECH,YTIME)                        "Computes Fixed and O&M costs of DAC technologies with learning curve"
Q06LvlCostDAC(allCy,DACTECH,YTIME)                         "Calculates the CAPEX and the Fixed Costs of DAC capacity regionally (US$2015/tCO2)"
Q06VarCostDAC(DACTECH,YTIME)                         "Computes variable costs of DAC technologies including carbon storage costs, with learning curve"
Q06ProfRateDAC(allCy,DACTECH,YTIME)                        "Computes the annual profitability rate of DAC including the lifecycle costs and revenues regionally"
Q06CapFacNewDAC(allCy,DACTECH,YTIME)                       "Computes the factor expressing the annual increase in the installed capacity of DAC regionally"
Q06CapDAC(allCy,DACTECH,YTIME)                             "Computes the DAC installed capacity annually and regionally"
Q06ConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)             "Computed the annual fuel demand in each DAC technology regionally (Mtoe)"
Q06ConsFuelDACProd(allCy,EF,YTIME)                         "Computed the annual fuel demand in DAC regionally (Mtoe)"

*'                **Interdependent Equations**
Q06CstCO2SeqCsts(allCy,YTIME)	                           "Compute cost curve for CO2 sequestration costs" 
;

Variables
V06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME)	                "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
V06CaptCummCO2(allCy,YTIME)	                              "Cumulative CO2 captured (Mtn CO2)"
V06TrnsWghtLinToExp(allCy,YTIME)	                       "Weight for transtition from linear CO2 sequestration cost curve to exponential (1)"
V06GrossCapDAC(DACTECH,YTIME)                        "CAPEX of DAC technologies with learning curve"
V06FixOandMDAC(DACTECH,YTIME)                        "Fixed and O&M costs of DAC technologies with learning curve"
V06VarCostDAC(DACTECH,YTIME)                         "Variable costs of DAC technologies including carbon storage costs, with learning curve"
V06LvlCostDAC(allCy,DACTECH,YTIME)                         "Regional CAPEX and the Fixed Costs of DAC capacity (US$2015/tCO2)"
V06ProfRateDAC(allCy,DACTECH,YTIME)                        "The annual profitability rate of DAC including the lifecycle costs and revenues regionally"
V06CapFacNewDAC(allCy,DACTECH,YTIME)                       "Factor expressing the annual increase in the installed capacity of DAC regionally"
V06CapDAC(allCy,DACTECH,YTIME)                             "DAC regional installed capacity (tCO2)"
VmConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)              "Annual fuel demand in each DAC technology regionally (Mtoe)"
VmConsFuelDACProd(allCy,EF,YTIME)                          "Annual fuel demand in DAC regionally (Mtoe)"
*'                **Interdependent Variables**
VmCstCO2SeqCsts(allCy,YTIME)	                           "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"
;

Scalars
S06ProfRateMaxDAC                                           "The maximum profitability rate of V06DACProfRate" /6/
S06CapFacMaxNewDAC                                          "The maximum level of the V06DACNewCapFac" /0.10/
S06CapFacMinNewDAC                                          "The minimum level of the V06DACNewCapFac" /0/
;