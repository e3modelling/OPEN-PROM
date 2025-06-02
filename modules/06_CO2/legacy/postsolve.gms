*' @title CO2 SEQUESTRATION COST CURVES postsolve
* Fix values of variables for the next time step

* CO2 Sequestration Module

*---
MVCstCO2SeqCsts.FX(runCyL,YTIME)$TIME(YTIME) = MVCstCO2SeqCsts.L(runCyL,YTIME)$TIME(YTIME);
VCapCO2ElecHydr.FX(runCyL,YTIME)$TIME(YTIME) = VCapCO2ElecHydr.L(runCyL,YTIME)$TIME(YTIME);
VCaptCummCO2.FX(runCyL,YTIME)$TIME(YTIME) = VCaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);
*---