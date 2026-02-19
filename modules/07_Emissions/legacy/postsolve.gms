*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module

V07GrossEmissCO2Supply.FX(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);