*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module

p07GrossEmissCO2Supply(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);
V07EmissionsNet.FX(runCyL,YTIME)$TIME(YTIME) = V07EmissionsNet.L(runCyL,YTIME)$TIME(YTIME);

option clear = Q07GrossEmissCO2Supply;
option clear = V07GrossEmissCO2Supply;

V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME) = p07GrossEmissCO2Supply(runCyL,SSBS,YTIME)$TIME(YTIME);
