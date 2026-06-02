*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V07GrossEmissCO2Supply;
option clear = V07RedAbsBySrcRegTim;
option clear = V07EmiActBySrcRegTim;
option clear = V07CostAbateBySrcRegTim;
option clear = V07GrossEmissCO2Demand;
option clear = V07EmissionsNet;
option clear = V07EmissionsNetPart;

option clear = Q07GrossEmissCO2Supply;
option clear = Q07RedAbsBySrcRegTim;
option clear = Q07CostAbateBySrcRegTim;
option clear = Q07EmiActBySrcRegTim;
option clear = Q07GrossEmissCO2Demand;
option clear = Q07EmissionsNet;
option clear = Q07EmissionsNetPart;

*' No non-default bounds in Emissions preloop — option clear defaults are sufficient

*' Initialize variable levels from previous period parameter
V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME+1) = p07GrossEmissCO2Supply(runCy,SSBS,YTIME);
V07RedAbsBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME+1) = p07RedAbsBySrcRegTim(E07SrcMacAbate,runCy,YTIME);
V07EmiActBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME+1) = p07EmiActBySrcRegTim(E07SrcMacAbate,runCy,YTIME);
V07CostAbateBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME+1) = p07CostAbateBySrcRegTim(E07SrcMacAbate,runCy,YTIME);
V07GrossEmissCO2Demand.L(runCyL,DSBS,YTIME+1) = p07GrossEmissCO2Demand(runCy,DSBS,YTIME);
V07EmissionsNet.L(runCyL,YTIME+1) = p07EmissionsNet(runCy,YTIME);
V07EmissionsNetPart.L(runCyL,YTIME+1) = p07EmissionsNetPart(runCy,YTIME);
