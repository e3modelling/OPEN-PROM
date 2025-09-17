*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
V02DemSubUsefulSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemSubUsefulSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);
V02RemEquipCapTechSubsec.FX(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02RemEquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
V02DemUsefulSubsecRemTech.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = V02DemUsefulSubsecRemTech.L(runCyL,DSBS,YTIME)$TIME(YTIME);
V02GapUsefulDemSubsec.FX(runCyL,DSBS,YTIME)$TIME(YTIME) = V02GapUsefulDemSubsec.L(runCyL,DSBS,YTIME)$TIME(YTIME);           
V02CapCostTech.FX(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02CapCostTech.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);                     
V02VarCostTech.FX(runCyL,DSBS,rCon,ITECH,YTIME)$TIME(YTIME) = V02VarCostTech.L(runCyL,DSBS,rCon,ITECH,YTIME)$TIME(YTIME);                
V02ShareTechNewEquipUseful.FX(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02ShareTechNewEquipUseful.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);
V02EquipCapTechSubsec.FX(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME) = V02EquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME)$TIME(YTIME);  
V02UsefulElecNonSubIndTert.FX(runCyL,INDDOM,YTIME)$TIME(YTIME) = V02UsefulElecNonSubIndTert.L(runCyL,INDDOM,YTIME)$TIME(YTIME);            
V02FinalElecNonSubIndTert.FX(runCyL,INDDOM,YTIME)$TIME(YTIME) = V02FinalElecNonSubIndTert.L(runCyL,INDDOM,YTIME)$TIME(YTIME);                                      
V02CostElecProdCHP.FX(runCyL,DSBS,CHP,YTIME)$TIME(YTIME) = V02CostElecProdCHP.L(runCyL,DSBS,CHP,YTIME)$TIME(YTIME);      
VmConsFuel.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VmConsFuel.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);       
VmCostElcAvgProdCHP.FX(runCyL,CHP,YTIME)$TIME(YTIME) = VmCostElcAvgProdCHP.L(runCyL,CHP,YTIME)$TIME(YTIME);
V02IndxElecIndPrices.FX(runCyL,YTIME)$TIME(YTIME) = V02IndxElecIndPrices.L(runCyL,YTIME)$TIME(YTIME);  
*---
