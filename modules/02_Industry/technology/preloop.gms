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
V02RemEquipCapTechSubsec(runCy,DSBS,ITECH,YTIME)
V02DemUsefulSubsecRemTech(runCy,DSBS,YTIME)
V02GapUsefulDemSubsec(runCy,DSBS,YTIME)
$offtext
*---
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = 0.1;
*---
* Levels in other variables?
$ontext
V02ShareTechNewEquipUseful(runCy,DSBS,ITECH,YTIME)
V02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME)
$offtext
*---
alias(ITECH,ITECH2);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2) and not CCSTECH(ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME); 
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF),imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/ i02Util(runCy,DSBS,ITECH,YTIME)); 
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME); 
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME) * (1-imShrNonSubElecInTotElecDem(runCy,DSBS))/sum(ITECH2$(TECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME); 
V02EquipCapTechSubsec.FX(runCy,DSBS,CCSTECH,YTIME)$(SECTTECH(DSBS,CCSTECH) and not An(YTIME)) = 0;
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
!!V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = 0.0001;
V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = 
  (
    sum(EF$ITECHtoEF(ITECH,EF), 
      i02Share(runCy,DSBS,ITECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME) +
      imCo2EmiFac(runCy,DSBS,EF,YTIME-1) * 1e-3 * sum(NAP$NAPtoALLSBS(NAP,DSBS), VmCarVal.L(runCy,NAP,YTIME-1)) +
      imCO2CaptRateIndustry(runCy,ITECH,YTIME) * (VmCstCO2SeqCsts.L(runCy,YTIME-1) - sum(NAP$NAPtoALLSBS(NAP,DSBS), VmCarVal.L(runCy,NAP,YTIME-1))) * 1e-3 * (imCo2EmiFac(runCy,DSBS,EF,YTIME-1) + 4.17$(sameas("BMSWAS", EF)) + 4.17$(sameas("STE2BMS", EF))) +
      VmRenValue.L(YTIME)$(not RENEF(ITECH) and not NENSE(DSBS)) !! needs change of units
    ) +
    imVarCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME) -
  (
    VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME) *
    smFracElecPriChp *
    VmPriceElecInd.L(runCy,YTIME) 
    / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME)
  )$TCHP(ITECH);



V02CapCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = ((
      (
        (imDisc(runCy,DSBS,YTIME)$(not TCHP(ITECH)) + imDisc(runCy,"PG",YTIME)$TCHP(ITECH)) * !! in case of chp plants we use the discount rate of power generation sector
        exp((imDisc(runCy,DSBS,YTIME)$(not TCHP(ITECH)) + imDisc(runCy,"PG",YTIME)$TCHP(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME))
      ) /
      (exp((imDisc(runCy,DSBS,YTIME)$(not TCHP(ITECH)) + imDisc(runCy,"PG",YTIME)$TCHP(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME)) - 1)
    ) *
    imCapCostTech(runCy,DSBS,ITECH,YTIME) * imCGI(runCy,YTIME) +
    imFixOMCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit)
    / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME);

V02CostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME)) = V02VarCostTech.L(runCy,DSBS,ITECH,YTIME) + V02CapCostTech.L(runCy,DSBS,ITECH,YTIME);
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