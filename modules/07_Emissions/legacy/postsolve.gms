*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module

V07EmissCO2Supply.FX(runCyL,SSBS,YTIME)$TIME(YTIME) = V07EmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);