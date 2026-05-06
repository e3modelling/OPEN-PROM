*' @title Learning Curves module postsolve
* Fix values of variables for the next time step

* Learning Curves Module

*---
* Store snapshot values
p10CostLC(LCTECH,YTIME)$TIME(YTIME) = VmCostLC.L(LCTECH,YTIME)$TIME(YTIME);
p10CumCapGlobal(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);

*' Clear equations for the next time step
option clear = Q10CostLC;
option clear = Q10CumCapGlobal;

*' Clear variables for the next time step
option clear = VmCostLC;
option clear = V10CumCapGlobal;

*