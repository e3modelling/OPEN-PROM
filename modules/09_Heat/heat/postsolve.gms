*' @title Heat module postsolve
* Fix values of variables for the next time step

* Heat Module

*---
VmProdSte.FX(runCyL,TCHP,YTIME)$TIME(YTIME) = VmProdSte.L(runCyL,TCHP,YTIME)$TIME(YTIME);
V09CostProdSte.FX(runCyL,TCHP,YTIME)$TIME(YTIME) = V09CostProdSte.L(runCyL,TCHP,YTIME)$TIME(YTIME);