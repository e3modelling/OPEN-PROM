*' @title Learning Curves module Declarations
*' @code

Equations
Q10CostLC(LCTECH,YTIME)             "Learning curve cost multiplier calculation"
Q10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity calculation"
Q10CoreGrossCapDAC(DACTECH,YTIME)   "Core DAC CAPEX learning term"
Q10CoreFixOandMDAC(DACTECH,YTIME)   "Core DAC fixed O&M learning term"
Q10CoreVarCostDAC(DACTECH,YTIME)    "Core DAC variable cost learning term"

;

Variables
VmCostLC(LCTECH,YTIME)             "Learning curve cost multiplier (1)"
V10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity (GW)"
V10CoreGrossCapDAC(DACTECH,YTIME)   "Core DAC CAPEX learning term ($/tCO2)"
V10CoreFixOandMDAC(DACTECH,YTIME)   "Core DAC fixed O&M learning term ($/tCO2)"
V10CoreVarCostDAC(DACTECH,YTIME)    "Core DAC variable cost learning term ($/tCO2)"

;
