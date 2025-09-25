*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V02FinalElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM);
*---
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = V02FinalElecNonSubIndTert.L(runCy,INDDOM,YTIME) * imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
*----
* Needs to be divided with average efficiency --- WHICH ONE?
V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - V02UsefulElecNonSubIndTert.L(runCy,INDDOM,YTIME), 1e-5) * 0.5;
V02DemSubUsefulSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
V02DemSubUsefulSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - V02UsefulElecNonSubIndTert.L(runCy,"HOU",YTIME)-i02ExogDemOfBiomass(runCy,"HOU",YTIME),1e-5) * 0.8;
*---
* Levels in other variables?
$ontext
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
$offtext
*---
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = 0.1;
*---
* Levels in other variables?
$ontext
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
$offtext
*---
alias(ITECH,ITECH2);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME); 
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME) * (1-imShrNonSubElecInTotElecDem(runCy,DSBS))/sum(ITECH2$(TECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME); 
display V02EquipCapTechSubsec.L;

*i02Share(runCy,DSBS,ITECH,EF,YTIME)$(SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) = (imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / V02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME);
*---
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM) / imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
*---
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 1e-8;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$((not HEATPUMP(EF)) and not TRANSE(DSBS) and not An(YTIME)) = sum(SECtoEF(DSBS,EF),imFuelConsPerFueSub(runCy,DSBS,EF,YTIME));
*---
*vmConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmConsElecNonSubIndTert.l(runCy,INDSE,YTIME));

*vmDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));
*---
$ontext
VmConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VmElecConsHeatPla.L(runCy,DSBS,YTIME)*imUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VmElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF));
$offtext
*---
*VmConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $(not An(ytime))) =
*(VmConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (VmConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));