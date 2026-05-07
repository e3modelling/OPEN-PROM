*' @title Learning Curves module Declarations
*' @code

Parameters
pmCostLC(LCTECH,YTIME)             "Stored learning curve cost multiplier (1)"
p10CumCapGlobal(LCTECH,YTIME)      "Stored global cumulative capacity (GW)"
;

Equations
Q10CostLC(LCTECH,YTIME)             "Learning curve cost multiplier calculation"
Q10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity calculation"

;

Variables
VmCostLC(LCTECH,YTIME)             "Learning curve cost multiplier (1)"
V10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity (GW)"

;
