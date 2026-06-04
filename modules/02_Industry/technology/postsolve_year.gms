*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = Q02DemSubUsefulSubsec;
option clear = Q02RemEquipCapTechSubsec;
option clear = Q02DemUsefulSubsecRemTech;
option clear = Q02GapUsefulDemSubsec;
option clear = Q02CapCostTech;
option clear = Q02VarCostTech;
option clear = Q02CostTech;
option clear = Q02ShareTechNewEquipUseful;
option clear = Q02EquipCapTechSubsec;
option clear = Q02UsefulElecNonSubIndTert;
option clear = Q02FinalElecNonSubIndTert;
option clear = Q02IndxElecIndPrices;
option clear = Q02IndAvrEffFinalUseful;
option clear = Q02PremScrpIndu;
option clear = Q02RatioRem;
option clear = Q02ConsFuel;
option clear = Q02ConsFuelShare;
option clear = Q02ConsFuelSum;

option clear = V02DemSubUsefulSubsec;
option clear = V02RemEquipCapTechSubsec;
option clear = V02DemUsefulSubsecRemTech;
option clear = V02GapUsefulDemSubsec;
option clear = V02CapCostTech;
option clear = V02VarCostTech;
option clear = V02CostTech;
option clear = V02ShareTechNewEquipUseful;
option clear = V02EquipCapTechSubsec;
option clear = V02UsefulElecNonSubIndTert;
option clear = V02FinalElecNonSubIndTert;
option clear = V02IndxElecIndPrices;
option clear = V02IndAvrEffFinalUseful;
option clear = V02PremScrpIndu;
option clear = V02RatioRem;
option clear = VmConsFuel;
option clear = VmConsFuelShare;
option clear = VmConsFuelSum;

*' Re-apply critical bounds for all active countries (outside country loop)
V02EquipCapTechSubsec.LO(runCy,DSBS,ITECH,YTIME) = 0;
V02DemSubUsefulSubsec.LO(runCy,INDDOM,YTIME) = 0;
VmConsFuel.LO(runCy,DSBS,EF,YTIME) = 0;
V02VarCostTech.LO(runCy,DSBS,ITECH,YTIME) = 0;
V02CostTech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmConsFuelShare.LO(runCy,DSBS,EF,YTIME) = 0;
V02DemUsefulSubsecRemTech.LO(runCy,DSBS,YTIME) = 0;
V02RemEquipCapTechSubsec.LO(runCy,DSBS,ITECH,YTIME) = 0;
V02GapUsefulDemSubsec.LO(runCy,DSBS,YTIME) = 0;

*' Initialize parameters for every iteration forward (seed from first iteration results)
V02DemSubUsefulSubsec.L(runCyL,DSBS,YTIME+1) = p02DemSubUsefulSubsec(runCyL,DSBS,YTIME);
V02RemEquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME+1) = p02RemEquipCapTechSubsec(runCyL,DSBS,ITECH,YTIME);
V02DemUsefulSubsecRemTech.L(runCyL,DSBS,YTIME+1) = p02DemUsefulSubsecRemTech(runCyL,DSBS,YTIME);
V02GapUsefulDemSubsec.L(runCyL,DSBS,YTIME+1) = p02GapUsefulDemSubsec(runCyL,DSBS,YTIME);
V02CapCostTech.L(runCyL,DSBS,ITECH,YTIME+1) = p02CapCostTech(runCyL,DSBS,ITECH,YTIME);
V02VarCostTech.L(runCyL,DSBS,ITECH,YTIME+1) = p02VarCostTech(runCyL,DSBS,ITECH,YTIME);
V02CostTech.L(runCyL,DSBS,ITECH,YTIME+1) = p02CostTech(runCyL,DSBS,ITECH,YTIME);
V02ShareTechNewEquipUseful.L(runCyL,DSBS,ITECH,YTIME+1) = p02ShareTechNewEquipUseful(runCyL,DSBS,ITECH,YTIME);
V02EquipCapTechSubsec.L(runCyL,DSBS,ITECH,YTIME+1) = p02EquipCapTechSubsec(runCyL,DSBS,ITECH,YTIME);
V02UsefulElecNonSubIndTert.L(runCyL,DSBS,YTIME+1) = p02UsefulElecNonSubIndTert(runCyL,DSBS,YTIME);
V02FinalElecNonSubIndTert.L(runCyL,DSBS,YTIME+1) = p02FinalElecNonSubIndTert(runCyL,DSBS,YTIME);
V02IndxElecIndPrices.L(runCyL,TCHP,YTIME+1) = p02IndxElecIndPrices(runCyL,TCHP,YTIME);
V02IndAvrEffFinalUseful.L(runCyL,DSBS,YTIME+1) = p02IndAvrEffFinalUseful(runCyL,DSBS,YTIME);
V02PremScrpIndu.L(runCyL,DSBS,ITECH,YTIME+1) = p02PremScrpIndu(runCyL,DSBS,ITECH,YTIME);
V02RatioRem.L(runCyL,DSBS,ITECH,YTIME+1) = p02RatioRem(runCyL,DSBS,ITECH,YTIME);
VmConsFuel.L(runCyL,DSBS,EF,YTIME+1) = pmConsFuel(runCyL,DSBS,EF,YTIME);
