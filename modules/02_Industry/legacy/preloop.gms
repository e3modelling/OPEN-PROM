*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V02CostTechIntrm.L(runCy,DSBS,rcon,EF,YTIME) = 0.1;
*---
V02SortTechVarCost.L(runCy,DSBS,rCon,YTIME) = 1e-8;
*---
V02ShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
*---
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 1e-8;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
*---
VmConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM);
*---
*vmConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmConsElecNonSubIndTert.l(runCy,INDSE,YTIME));
*---
VmDemFinSubFuelSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VmConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
VmDemFinSubFuelSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VmDemFinSubFuelSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VmConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-i02ExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
*---
*vmDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));
*---
VmConsFuelInclHP.LO(runCy,DSBS,EF,YTIME) = 0;
VmConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VmElecConsHeatPla.L(runCy,DSBS,YTIME)*imUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VmElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF)
+ 0.1$(H2EF(EF) or sameas("STE1AH2F",EF));
*---
VmConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VmConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (VmConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));
*---
V02GapFinalDem.scale(runCy,DSBS,YTIME) = 1e-8;
Q02GapFinalDem.scale(runCy,DSBS,YTIME) = V02GapFinalDem.scale(runCy,DSBS,YTIME);
*---