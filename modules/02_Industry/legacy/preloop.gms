*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
* Needs to be divided with average efficiency
V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VmConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
V02DemSubUsefulSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
V02DemSubUsefulSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VmConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-i02ExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
*---
* Levels in other variables?
$ontext
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
$offtext
*---
V02CapCostTech.L(runCy,DSBS,rcon,ITECH,YTIME) = 0.1;
*---
V02VarCostTech.L(runCy,DSBS,rcon,ITECH,YTIME) = 0.1;
*---
* Levels in other variables?
$ontext
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
$offtext
*---
alias(ITECH,ITECH2)
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$SECTTECH(DSBS,ITECH)$(not An(YTIME) and not TRANSE(DSBS)) = sum(EF$ITECHtoEF(ITECH,EF),
imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(allCy,DSBS,ITECH,YTIME); 
*---
i02Share.L(runCy,DSBS,ITECH,EF,YTIME)$(SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) = (imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / V02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME);
*---
V02UsefulElecNonSubIndTert.L(runCy,DSBS,YTIME)=0.1;
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM) / imUsfEneConvSubTech(allCy,DSBS,"TELC",YTIME);
*---
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 0.0000000001;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$($(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = sum(ITECH$(SECTTECH(DSBS,ITECH)$ITECHtoEF(ITECH,EF)),imFuelConsPerFueSub(runCy,DSBS,EF,YTIME));
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
VmConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VmConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (VmConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));
*---