*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostTechIntrm.L(runCy,DSBS,rcon,EF,YTIME) = 0.1;
*---
VSortTechVarCost.L(runCy,DSBS,rCon,YTIME) = 0.00000001;
*---
VShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
*---
VMVConsFue.L(runCy,DSBS,EF,YTIME) = 0.0000000001;
VMVConsFue.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
*---
VMVConsElecNonSubIndTert.L(runCy,DSBS,YTIME)=0.1;
VMVConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
*---
*VMvConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VMVConsElecNonSubIndTert.l(runCy,INDSE,YTIME));
*---
VMVDemFinSubFuelSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VMVConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
VMVDemFinSubFuelSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VMVDemFinSubFuelSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VMVConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
*---
*VMvDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VMVDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));
*---
VMVConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.L(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF));
*---
VMVConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VMVConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (VMVConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));
*---