*' @title Learning Curves module postsolve
* Fix values of variables for the next time step

* Learning Curves Module

*' Save current learning curve results for next time step
VmCostLC.FX(LCTECH,YTIME+1) = VmCostLC.L(LCTECH,YTIME+1);
V10CumCapGlobal.FX(LCTECH,YTIME+1) = V10CumCapGlobal.L(LCTECH,YTIME+1);

*---
