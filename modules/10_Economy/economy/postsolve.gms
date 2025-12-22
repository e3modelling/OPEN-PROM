*' @title Economy module postsolve
* Fix values of variables for the next time step

* Economy Module

*---
V10SubsiTot.FX(runCy,YTIME)$TIME(YTIME) = V10SubsiTot.L(runCy,YTIME)$TIME(YTIME);
*---
VmNetSubsiTax.FX(runCy,YTIME)$TIME(YTIME) = VmNetSubsiTax.L(runCy,YTIME)$TIME(YTIME);
*---