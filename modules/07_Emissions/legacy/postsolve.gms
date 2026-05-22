*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module

p07GrossEmissCO2Supply(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);
p07EmissionsNet(runCyL,YTIME)$TIME(YTIME) = V07EmissionsNet.L(runCyL,YTIME)$TIME(YTIME);
p07RedAbsBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07RedAbsBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07EmiActBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07EmiActBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07CostAbateBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07CostAbateBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07GrossEmissCO2Demand(runCyL,DSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Demand.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p07EmissionsNetPart(runCyL,YTIME)$TIME(YTIME) = V07EmissionsNetPart.L(runCyL,YTIME)$TIME(YTIME);
*---