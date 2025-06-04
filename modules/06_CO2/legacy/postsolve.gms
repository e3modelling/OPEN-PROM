*' @title CO2 SEQUESTRATION COST CURVES postsolve
* Fix values of variables for the next time step

* CO2 Sequestration Module

*---
VmCstCO2SeqCsts.FX(runCyL,YTIME)$TIME(YTIME) = VmCstCO2SeqCsts.L(runCyL,YTIME)$TIME(YTIME);
V06CapCO2ElecHydr.FX(runCyL,YTIME)$TIME(YTIME) = V06CapCO2ElecHydr.L(runCyL,YTIME)$TIME(YTIME);
V06CaptCummCO2.FX(runCyL,YTIME)$TIME(YTIME) = V06CaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);
*---