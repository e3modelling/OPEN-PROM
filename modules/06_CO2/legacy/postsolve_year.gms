*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = V06CO2CaptureCCS;
option clear = V06CaptCummCO2;
option clear = V06CaptCummCO2Glob;
option clear = V06GrossCapDAC;
option clear = V06FixOandMDAC;
option clear = V06VarCostDAC;
option clear = V06LvlCostDAC;
option clear = V06ProfRateDAC;
option clear = V06CapFacNewDAC;
option clear = V06CapCDR;
option clear = VmCstCO2SeqCsts;
option clear = VmConsFuelTechCDRProd;
option clear = VmConsFuelCDRProd;

option clear = Q06CO2CaptureCCS;
option clear = Q06CaptCummCO2;
option clear = Q06CaptCummCO2Glob;
option clear = Q06GrossCapDAC;
option clear = Q06FixOandMDAC;
option clear = Q06VarCostDAC;
option clear = Q06LvlCostDAC;
option clear = Q06ProfRateDAC;
option clear = Q06CapFacNewDAC;
option clear = Q06CapCDR;
option clear = Q06ConsFuelTechCDRProd;
option clear = Q06ConsFuelCDRProd;
option clear = Q06CstCO2SeqCsts;

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/06_CO2/legacy/preloop.gms"

*' Initialize variable levels from previous period parameter
V06CO2CaptureCCS.L(runCy,SBS,EFS,YTIME) = p06CO2CaptureCCS(runCy,SBS,EFS,YTIME-1);
V06CaptCummCO2.L(runCy,YTIME) = p06CaptCummCO2(runCy,YTIME-1);
V06CaptCummCO2Glob.L(YTIME) = p06CaptCummCO2Glob(YTIME-1);
V06GrossCapDAC.L(CDRTECH,YTIME) = p06GrossCapDAC(CDRTECH,YTIME-1);
V06FixOandMDAC.L(CDRTECH,YTIME) = p06FixOandMDAC(CDRTECH,YTIME-1);
V06VarCostDAC.L(CDRTECH,YTIME) = p06VarCostDAC(CDRTECH,YTIME-1);
V06LvlCostDAC.L(runCy,CDRTECH,YTIME) = p06LvlCostDAC(runCy,CDRTECH,YTIME-1);
V06ProfRateDAC.L(runCy,CDRTECH,YTIME) = p06ProfRateDAC(runCy,CDRTECH,YTIME-1);
V06CapFacNewDAC.L(runCy,CDRTECH,YTIME) = p06CapFacNewDAC(runCy,CDRTECH,YTIME-1);
V06CapCDR.L(runCy,CDRTECH,YTIME) = p06CapCDR(runCy,CDRTECH,YTIME-1);
VmCstCO2SeqCsts.L(runCy,YTIME) = pmCstCO2SeqCsts(runCy,YTIME-1);
VmConsFuelTechCDRProd.L(runCy,CDRTECH,EFS,YTIME) = pmConsFuelTechCDRProd(runCy,CDRTECH,EFS,YTIME-1);
VmConsFuelCDRProd.L(runCy,EFS,YTIME) = pmConsFuelCDRProd(runCy,EFS,YTIME-1);
