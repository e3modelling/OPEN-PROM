*' @title Learning Curves module Declarations
*' @code

Parameters
p10CostLC(LCTECH,YTIME)             "Snapshot of VmCostLC for lagged references"
p10CumCapGlobal(LCTECH,YTIME)       "Snapshot of V10CumCapGlobal for lagged references"
;

Equations
Q10CostLC(LCTECH,YTIME)             "Learning curve cost multiplier calculation"
Q10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity calculation"

;

Variables
VmCostLC(LCTECH,YTIME)             "Learning curve cost multiplier (1)"
V10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity (GW)"

;
