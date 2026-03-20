*' @title Economy module postsolve
* Fix values of variables for the next time step

* Economy Module

*---
V11SubsiTot.FX(runCyL,YTIME)$TIME(YTIME) = V11SubsiTot.L(runCyL,YTIME)$TIME(YTIME);
*---
VmNetSubsiTax.FX(runCyL,YTIME)$TIME(YTIME) = VmNetSubsiTax.L(runCyL,YTIME)$TIME(YTIME);
*---