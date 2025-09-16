*' @title CO2 SEQUESTRATION COST CURVES Declarations
*' @code

Equations
*' *** CO2 SEQUESTRATION COST CURVES EQUATIONS
Q06CapCO2ElecHydr(allCy,YTIME)	                           "Compute CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
Q06CaptCummCO2(allCy,YTIME)	                               "Compute cumulative CO2 captured (Mtn of CO2)"
Q06TrnsWghtLinToExp(allCy,YTIME)	                       "Transtition weight for shifting from linear to exponential CO2 sequestration cost curve"
Q06CapexFixCostDAC(allCy,DACTECH,YTIME)                    "Calculates the CAPEX and the Fixed Costs of DAC capacity regionally"
Q06ProfRateDAC(allCy,DACTECH,YTIME)                        "Computes the annual profitability rate of DAC including the lifecycle costs and revenues regionally"
Q06CapFacNewDAC(allCy,DACTECH,YTIME)                       "Computes the factor expressing the annual increase in the installed capacity of DAC regionally"
Q06CapDAC(allCy,DACTECH,YTIME)                             "Computes the DAC installed capacity annually and regionally"
Q06ElecDAC(allCy,DACTECH,YTIME)                            "Computes the annual electricity consumed in DAC regionally"
Q06NGDAC(allCy,DACTECH,YTIME)                              "Computes the annual Natural Gas consumed in DAC regionally"

*'                **Interdependent Equations**
Q06CstCO2SeqCsts(allCy,YTIME)	                           "Compute cost curve for CO2 sequestration costs" 
;

Variables
*' *** CO2 SEQUESTRATION COST CURVES VARIABLES
V06CapCO2ElecHydr(allCy,YTIME)	                           "CO2 captured by electricity and hydrogen production plants (Mtn CO2)"
V06CaptCummCO2(allCy,YTIME)	                               "Cumulative CO2 captured (Mtn CO2)"
V06TrnsWghtLinToExp(allCy,YTIME)	                       "Weight for transtition from linear CO2 sequestration cost curve to exponential (1)"
V06CapexFixCostDAC(allCy,DACTECH,YTIME)                    "Regional CAPEX and the Fixed Costs of DAC capacity"
V06ProfRateDAC(allCy,DACTECH,YTIME)                        "The annual profitability rate of DAC including the lifecycle costs and revenues regionally"
V06CapFacNewDAC(allCy,DACTECH,YTIME)                       "Factor expressing the annual increase in the installed capacity of DAC regionally"
V06CapDAC(allCy,DACTECH,YTIME)                             "DAC regional installed capacity"
V06ElecDAC(allCy,DACTECH,YTIME)                            "Annual electricity consumed in DAC regionally"
V06NGDAC(allCy,DACTECH,YTIME)                              "Annual Natural Gas consumed in DAC regionally"

*'                **Interdependent Variables**
VmCstCO2SeqCsts(allCy,YTIME)	                           "Cost curve for CO2 sequestration costs (US$2015/tn of CO2 sequestrated)"
;

Scalars
S06ProfRateMaxDAC                                           "The maximum profitability rate of V06DACProfRate" /10/
S06MatFacDAC                                                "Maturity factor of DAC technology expressing its elasticity in implementation regarding its financial sustainability" /0.5/
S06CapFacMaxNewDAC                                          "The maximum level of the V06DACNewCapFac" /1/
S06CapFacMinNewDAC                                          "The minimum level of the V06DACNewCapFac" /0.01/
