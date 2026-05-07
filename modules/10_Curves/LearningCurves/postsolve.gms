*' @title Learning Curves module postsolve
* Fix values of variables for the next time step

* Learning Curves Module

*---
pmCostLC(LCTECH,YTIME)$TIME(YTIME) = VmCostLC.L(LCTECH,YTIME)$TIME(YTIME);
p10CumCapGlobal(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);
*---

option clear = VmCostLC;
option clear = V10CumCapGlobal;

option clear = Q10CostLC;
option clear = Q10CumCapGlobal;
*---
