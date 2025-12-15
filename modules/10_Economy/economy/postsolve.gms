*' @title Economy module postsolve
* Fix values of variables for the next time step

* Economy Module

*---
V10CarbTaxTot.FX(runCy,YTIME)$TIME(YTIME) = V10CarbTaxTot.L(runCy,YTIME)$TIME(YTIME);
*---