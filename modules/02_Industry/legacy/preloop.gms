*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V02CostTechIntrm.L(runCy,DSBS,rcon,EF,YTIME) = 0.1;
*---
V02SortTechVarCost.L(runCy,DSBS,rCon,YTIME) = 0.00000001;
*---
V02ShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
*---
MVConsFuel.L(runCy,DSBS,EF,YTIME) = 0.0000000001;
MVConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
*---
MVConsElecNonSubIndTert.L(runCy,DSBS,YTIME)=0.1;
MVConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
*---
*MvConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,MVConsElecNonSubIndTert.l(runCy,INDSE,YTIME));
*---
MVDemFinSubFuelSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - MVConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
MVDemFinSubFuelSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
MVDemFinSubFuelSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - MVConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
*---
*MvDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,MVDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));
*---
MVConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.L(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF));
*---
MVConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(MVConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (MVConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));
*---