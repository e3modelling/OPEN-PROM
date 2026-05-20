*' @title CO2 SEQUESTRATION COST CURVES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V06CO2CaptureCCS.LO(runCy,SBS,EFS,YTIME) = 0;
V06CO2CaptureCCS.L(runCy,SBS,EFS,YTIME)$SECtoEF(SBS,EFS) = 1;
V06CO2CaptureCCS.FX(runCy,SBS,EFS,YTIME)$(DATAY(YTIME) or not SECtoEF(SBS,EFS)) = 0;
*---
V06CaptCummCO2.LO(runCy,YTIME) = 0;
V06CaptCummCO2.L(runCy,YTIME) = 1;
V06CaptCummCO2.FX(runCy,YTIME)$DATAY(YTIME) = 0;
*---
V06CaptCummCO2Glob.LO(YTIME) = 0;
V06CaptCummCO2Glob.L(YTIME) = 1;
V06CaptCummCO2Glob.FX(YTIME)$DATAY(YTIME) = 0;
*---
V06LvlCostDAC.LO(runCy,CDRTECH,YTIME) = 0;
V06LvlCostDAC.L(runCy,CDRTECH,YTIME) = 100;
V06LvlCostDAC.FX(runCy,CDRTECH,YTIME)$DATAY(YTIME) = 100;
*---
V06CapCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06CapCDR.L(runCy,CDRTECH,YTIME) = 1;
V06CapCDR.FX(runCy,CDRTECH,"%fBaseY%") = 1000 * VmGDPPartGlob.L(runCy,"%fBaseY%"); !! Initial guess of 50 years to reach net zero emissions for each CDR technology, based on the net emissions in 2020
*---
V06ProfRateDAC.LO(runCy,CDRTECH,YTIME) = 0;
V06ProfRateDAC.L(runCy,CDRTECH,YTIME) = 1;
*---
V06CapFacNewDAC.LO(runCy,CDRTECH,YTIME) = 0;
V06CapFacNewDAC.L(runCy,CDRTECH,YTIME) = 0.1;
V06CapFacNewDAC.FX(runCy,CDRTECH,YTIME)$DATAY(YTIME) = 0;
*---
VmConsFuelTechCDRProd.LO(runCy,CDRTECH,EF,YTIME) = 0;
VmConsFuelTechCDRProd.L(runCy,CDRTECH,EF,YTIME)$TECHtoEF(CDRTECH,EF) = 1;
VmConsFuelTechCDRProd.FX(runCy,CDRTECH,EF,YTIME)$(DATAY(YTIME) or not TECHtoEF(CDRTECH,EF)) = 0;

*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

V06GrossCapDAC.L(CDRTECH,YTIME) = 1e-6;
V06FixOandMDAC.L(CDRTECH,YTIME) = 1e-6;
V06VarCostDAC.L(CDRTECH,YTIME) = 1e-6;
VmConsFuelTechCDRProd.L(runCy,CDRTECH,EFS,YTIME) = 1e-6;
VmConsFuelCDRProd.L(runCy,EFS,YTIME) = 1e-6;

*' Seed parameters from historical data
p06CO2CaptureCCS(runCy,SBS,EFS,YTIME)$(DATAY(YTIME)) = 0;
p06CaptCummCO2(runCy,YTIME)$(DATAY(YTIME)) = 0;
p06CaptCummCO2Glob(YTIME)$(DATAY(YTIME)) = 0;
p06GrossCapDAC(CDRTECH,YTIME)$(DATAY(YTIME)) = 1e-6;
p06FixOandMDAC(CDRTECH,YTIME)$(DATAY(YTIME)) = 1e-6;
p06VarCostDAC(CDRTECH,YTIME)$(DATAY(YTIME)) = 1e-6;
p06LvlCostDAC(runCy,CDRTECH,YTIME)$(DATAY(YTIME)) = 100;
p06ProfRateDAC(runCy,CDRTECH,YTIME)$(DATAY(YTIME)) = 1;
p06CapFacNewDAC(runCy,CDRTECH,YTIME)$(DATAY(YTIME)) = 0;
p06CapCDR(runCy,CDRTECH,YTIME)$(DATAY(YTIME)) = V06CapCDR.L(runCy,CDRTECH,YTIME);
pmCstCO2SeqCsts(runCy,YTIME)$(DATAY(YTIME)) = VmCstCO2SeqCsts.L(runCy,YTIME);
pmConsFuelTechCDRProd(runCy,CDRTECH,EFS,YTIME)$(DATAY(YTIME)) = 0;
pmConsFuelCDRProd(runCy,EFS,YTIME)$(DATAY(YTIME)) = 1e-6;

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
