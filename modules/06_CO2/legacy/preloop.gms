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
parameter p06Temp(allCy,CDRTECH,YTIME);
execute_load 'D:\OPEN-PROM\blablaMA.gdx', p06Temp = V06CapCDR.L;
V06CapCDR.FX(runCy,CDRTECH,YTIME)$(not sameas(runCy,"DEU"))= p06Temp(runCy,CDRTECH,YTIME);
V06CapCDR.FX("DEU",CDRTECH,YTIME)= 0.3 * p06Temp("DEU",CDRTECH,YTIME);
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