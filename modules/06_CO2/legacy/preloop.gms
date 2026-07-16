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
V06LvlCostCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06LvlCostCDR.L(runCy,CDRTECH,YTIME) = 100;
V06LvlCostCDR.FX(runCy,CDRTECH,YTIME)$DATAY(YTIME) = 100;
*---
V06CapCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06CapCDR.L(runCy,CDRTECH,YTIME) = 1;
V06CapCDR.FX(runCy,CDRTECH,"%fBaseY%") = 1000 * VmGDPPartGlob.L(runCy,"%fBaseY%"); !! Initial guess of 50 years to reach net zero emissions for each CDR technology, based on the net emissions in 2020
*---
V06ProfRateCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06ProfRateCDR.L(runCy,CDRTECH,YTIME) = 1;
*---
V06CapFacNewCDR.LO(runCy,CDRTECH,YTIME) = 0;
V06CapFacNewCDR.L(runCy,CDRTECH,YTIME) = 0.1;
V06CapFacNewCDR.FX(runCy,CDRTECH,YTIME)$DATAY(YTIME) = 0;
*---
VmConsFuelTechCDRProd.LO(runCy,CDRTECH,EF,YTIME) = 0;
VmConsFuelTechCDRProd.L(runCy,CDRTECH,EF,YTIME)$TECHtoEF(CDRTECH,EF) = 1;
VmConsFuelTechCDRProd.FX(runCy,CDRTECH,EF,YTIME)$(DATAY(YTIME) or not TECHtoEF(CDRTECH,EF)) = 0;