*' @title CO2 SEQUESTRATION COST CURVES postsolve
* Fix values of variables for the next time step

* CO2 Sequestration Module

*---
p06CO2CaptureCCS(runCyL,SBS,EFS,YTIME)$TIME(YTIME) = V06CO2CaptureCCS.L(runCyL,SBS,EFS,YTIME)$TIME(YTIME);
p06CaptCummCO2(runCyL,YTIME)$TIME(YTIME) = V06CaptCummCO2.L(runCyL,YTIME)$TIME(YTIME);
p06CapCDR(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapCDR.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
p06LvlCostDAC(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06LvlCostDAC.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
p06CapFacNewDAC(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06CapFacNewDAC.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
p06CaptCummCO2Glob(YTIME)$TIME(YTIME) = V06CaptCummCO2Glob.L(YTIME)$TIME(YTIME);
p06GrossCapDAC(CDRTECH,YTIME)$TIME(YTIME) = V06GrossCapDAC.L(CDRTECH,YTIME)$TIME(YTIME);
p06FixOandMDAC(CDRTECH,YTIME)$TIME(YTIME) = V06FixOandMDAC.L(CDRTECH,YTIME)$TIME(YTIME);
p06VarCostDAC(CDRTECH,YTIME)$TIME(YTIME) = V06VarCostDAC.L(CDRTECH,YTIME)$TIME(YTIME);
p06ProfRateDAC(runCyL,CDRTECH,YTIME)$TIME(YTIME) = V06ProfRateDAC.L(runCyL,CDRTECH,YTIME)$TIME(YTIME);
pmCstCO2SeqCsts(runCyL,YTIME)$TIME(YTIME) = VmCstCO2SeqCsts.L(runCyL,YTIME)$TIME(YTIME);
pmConsFuelTechCDRProd(runCyL,CDRTECH,EFS,YTIME)$TIME(YTIME) = VmConsFuelTechCDRProd.L(runCyL,CDRTECH,EFS,YTIME)$TIME(YTIME);
pmConsFuelCDRProd(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFuelCDRProd.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---

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
*---
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
