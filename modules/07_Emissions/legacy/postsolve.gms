*' @title Emissions Constraints postsolve
* Store values of variables as parameters for the next time step

* Emissions Module

*---
p07GrossEmissCO2Supply(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);
p07RedAbsBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07RedAbsBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07EmiActBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07EmiActBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07CostAbateBySrcRegTim(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME) = V07CostAbateBySrcRegTim.L(E07SrcMacAbate,runCyL,YTIME)$TIME(YTIME);
p07GrossEmissCO2Demand(runCyL,DSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Demand.L(runCyL,DSBS,YTIME)$TIME(YTIME);
p07EmissionsNet(runCyL,YTIME)$TIME(YTIME) = V07EmissionsNet.L(runCyL,YTIME)$TIME(YTIME);
p07EmissionsNetPart(runCyL,YTIME)$TIME(YTIME) = V07EmissionsNetPart.L(runCyL,YTIME)$TIME(YTIME);

option clear = Q07GrossEmissCO2Supply;
option clear = Q07RedAbsBySrcRegTim;
option clear = Q07CostAbateBySrcRegTim;
option clear = Q07EmiActBySrcRegTim;
option clear = Q07GrossEmissCO2Demand;
option clear = Q07EmissionsNet;
option clear = Q07EmissionsNetPart;

option clear = V07GrossEmissCO2Supply;
option clear = V07RedAbsBySrcRegTim;
option clear = V07CostAbateBySrcRegTim;
option clear = V07EmiActBySrcRegTim;
option clear = V07GrossEmissCO2Demand;
option clear = V07EmissionsNet;
option clear = V07EmissionsNetPart;
*---
