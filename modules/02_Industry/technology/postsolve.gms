*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS postsolve
* Fix values of variables for the next time step

* Industry Module Module

*---
V02DemSubUsefulSubsec.FX(allCy,DSBS,YTIME)$TIME(YTIME) = V02DemSubUsefulSubsec.L(allCy,DSBS,YTIME)$TIME(YTIME);
V02RemEquipCapTechSubsec.FX(allCy,DSBS,ITECH,YTIME)$TIME(YTIME) = V02RemEquipCapTechSubsec.L(allCy,DSBS,ITECH,YTIME)$TIME(YTIME);
V02DemUsefulSubsecRemTech.FX(allCy,DSBS,YTIME)$TIME(YTIME) = V02DemUsefulSubsecRemTech.L(allCy,DSBS,YTIME)$TIME(YTIME);
V02GapUsefulDemSubsec.FX(allCy,DSBS,YTIME)$TIME(YTIME) = V02GapUsefulDemSubsec.L(allCy,DSBS,YTIME)$TIME(YTIME);           
V02CapCostTech.FX(allCy,DSBS,ITECH,YTIME)$TIME(YTIME) = V02CapCostTech.L(allCy,DSBS,ITECH,YTIME)$TIME(YTIME);                     
V02VarCostTech.FX(allCy,DSBS,rCon,ITECH,YTIME)$TIME(YTIME) = V02VarCostTech.L(allCy,DSBS,rCon,ITECH,YTIME)$TIME(YTIME);                
V02ShareTechNewEquipUseful.FX(allCy,DSBS,ITECH,YTIME)$TIME(YTIME) = V02ShareTechNewEquipUseful.L(allCy,DSBS,ITECH,YTIME)$TIME(YTIME);
V02EquipCapTechSubsec.FX(allCy,DSBS,ITECH,YTIME)$TIME(YTIME) = V02EquipCapTechSubsec.L(allCy,DSBS,ITECH,YTIME)$TIME(YTIME);  
V02UsefulElecNonSubIndTert.FX(allCy,INDDOM,YTIME)$TIME(YTIME) = V02UsefulElecNonSubIndTert.L(allCy,INDDOM,YTIME)$TIME(YTIME);            
V02FinalElecNonSubIndTert.FX(allCy,INDDOM,YTIME)$TIME(YTIME) = V02FinalElecNonSubIndTert.L(allCy,INDDOM,YTIME)$TIME(YTIME);              
V02IndxElecIndPrices.FX(allCy,YTIME)$TIME(YTIME) = V02IndxElecIndPrices.L(allCy,YTIME)$TIME(YTIME);                          
V02CostElecProdCHP.FX(allCy,DSBS,CHP,YTIME)$TIME(YTIME) = V02CostElecProdCHP.L(allCy,DSBS,CHP,YTIME)$TIME(YTIME);      
VmConsFuel.FX(allCy,DSBS,EF,YTIME)$TIME(YTIME) = VmConsFuel.L(allCy,DSBS,EF,YTIME)$TIME(YTIME);       
VmCostElcAvgProdCHP.FX(allCy,CHP,YTIME)$TIME(YTIME) = VmCostElcAvgProdCHP.L(allCy,CHP,YTIME)$TIME(YTIME);
*---