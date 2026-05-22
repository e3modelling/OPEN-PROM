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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/07_Emissions/legacy/preloop.gms"

*' Initialize variable levels from previous period parameter
V07GrossEmissCO2Supply.L(runCy,SSBS,YTIME) = p07GrossEmissCO2Supply(runCy,SSBS,YTIME-1);
V07RedAbsBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME) = p07RedAbsBySrcRegTim(E07SrcMacAbate,runCy,YTIME-1);
V07EmiActBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME) = p07EmiActBySrcRegTim(E07SrcMacAbate,runCy,YTIME-1);
V07CostAbateBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME) = p07CostAbateBySrcRegTim(E07SrcMacAbate,runCy,YTIME-1);
V07GrossEmissCO2Demand.L(runCy,DSBS,YTIME) = p07GrossEmissCO2Demand(runCy,DSBS,YTIME-1);
V07EmissionsNet.L(runCy,YTIME) = p07EmissionsNet(runCy,YTIME-1);
V07EmissionsNetPart.L(runCy,YTIME) = p07EmissionsNetPart(runCy,YTIME-1);
