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

*' Re-apply critical bounds for all active countries (outside country loop)
V06CO2CaptureCCS.LO(runCy,SBS,EFS,YTIME) = 0;
V06CaptCummCO2.LO(runCy,YTIME) = 0;
V06CaptCummCO2Glob.LO(YTIME) = 0;
V06LvlCostDAC.LO(runCy,CDRTECH,YTIME) = 0;
V06CapCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06ProfRateDAC.LO(runCy,CDRTECH,YTIME) = 0;
V06CapFacNewDAC.LO(runCy,CDRTECH,YTIME) = 0;
VmConsFuelTechCDRProd.LO(runCy,CDRTECH,EF,YTIME) = 0;

*' Initialize variable levels from previous period parameter
V06CO2CaptureCCS.L(runCyL,SBS,EFS,YTIME+1) = p06CO2CaptureCCS(runCyL,SBS,EFS,YTIME);
V06CaptCummCO2.L(runCyL,YTIME+1) = p06CaptCummCO2(runCyL,YTIME);
V06CaptCummCO2Glob.L(YTIME+1) = p06CaptCummCO2Glob(YTIME);
V06GrossCapDAC.L(CDRTECH,YTIME+1) = p06GrossCapDAC(CDRTECH,YTIME);
V06FixOandMDAC.L(CDRTECH,YTIME+1) = p06FixOandMDAC(CDRTECH,YTIME);
V06VarCostDAC.L(CDRTECH,YTIME+1) = p06VarCostDAC(CDRTECH,YTIME);
V06LvlCostDAC.L(runCyL,CDRTECH,YTIME+1) = p06LvlCostDAC(runCyL,CDRTECH,YTIME);
V06ProfRateDAC.L(runCyL,CDRTECH,YTIME+1) = p06ProfRateDAC(runCyL,CDRTECH,YTIME);
V06CapFacNewDAC.L(runCyL,CDRTECH,YTIME+1) = p06CapFacNewDAC(runCyL,CDRTECH,YTIME);
V06CapCDR.L(runCyL,CDRTECH,YTIME+1) = p06CapCDR(runCyL,CDRTECH,YTIME);
VmCstCO2SeqCsts.L(runCyL,YTIME+1) = pmCstCO2SeqCsts(runCyL,YTIME);
VmConsFuelTechCDRProd.L(runCyL,CDRTECH,EFS,YTIME+1) = pmConsFuelTechCDRProd(runCyL,CDRTECH,EFS,YTIME);
VmConsFuelCDRProd.L(runCyL,EFS,YTIME+1) = pmConsFuelCDRProd(runCyL,EFS,YTIME);
