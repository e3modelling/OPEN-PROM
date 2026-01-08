*' @title Economy module postsolve
* Fix values of variables for the next time step

* Economy Module

*---
V11SubsiTot.FX(runCy,YTIME)$TIME(YTIME) = V11SubsiTot.L(runCy,YTIME)$TIME(YTIME);
*---
VmNetSubsiTax.FX(runCy,YTIME)$TIME(YTIME) = VmNetSubsiTax.L(runCy,YTIME)$TIME(YTIME);
*---