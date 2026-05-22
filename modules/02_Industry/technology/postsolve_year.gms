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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/02_Industry/technology/preloop.gms"

*' Initialize parameters for every iteration forward (seed from first iteration results)
V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME) = p02DemSubUsefulSubsec(runCy,DSBS,YTIME-1);
display V02DemSubUsefulSubsec.L;
V02RemEquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME) = p02RemEquipCapTechSubsec(runCy,DSBS,ITECH,YTIME-1);
V02DemUsefulSubsecRemTech.L(runCy,DSBS,YTIME) = p02DemUsefulSubsecRemTech(runCy,DSBS,YTIME-1);
V02GapUsefulDemSubsec.L(runCy,DSBS,YTIME) = p02GapUsefulDemSubsec(runCy,DSBS,YTIME-1);
V02CapCostTech.L(runCy,DSBS,ITECH,YTIME) = p02CapCostTech(runCy,DSBS,ITECH,YTIME-1);
V02VarCostTech.L(runCy,DSBS,ITECH,YTIME) = p02VarCostTech(runCy,DSBS,ITECH,YTIME-1);
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = p02CostTech(runCy,DSBS,ITECH,YTIME-1);
V02ShareTechNewEquipUseful.L(runCy,DSBS,ITECH,YTIME) = p02ShareTechNewEquipUseful(runCy,DSBS,ITECH,YTIME-1);
V02EquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME) = p02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME-1);
V02UsefulElecNonSubIndTert.L(runCy,DSBS,YTIME) = p02UsefulElecNonSubIndTert(runCy,DSBS,YTIME-1);
V02FinalElecNonSubIndTert.L(runCy,DSBS,YTIME) = p02FinalElecNonSubIndTert(runCy,DSBS,YTIME-1);
V02IndxElecIndPrices.L(runCy,TCHP,YTIME) = p02IndxElecIndPrices(runCy,TCHP,YTIME-1);
V02IndAvrEffFinalUseful.L(runCy,DSBS,YTIME) = p02IndAvrEffFinalUseful(runCy,DSBS,YTIME-1);
V02PremScrpIndu.L(runCy,DSBS,ITECH,YTIME) = p02PremScrpIndu(runCy,DSBS,ITECH,YTIME-1);
V02RatioRem.L(runCy,DSBS,ITECH,YTIME) = p02RatioRem(runCy,DSBS,ITECH,YTIME-1);
VmConsFuel.L(runCy,DSBS,EF,YTIME) = pmConsFuel(runCy,DSBS,EF,YTIME-1);
