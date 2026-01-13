*' @title INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES Preloop
*' @code
 
*'                *VARIABLE INITIALISATION*
V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME)$(not (ord(YTIME) > 2 and DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;

V02DemSubUsefulSubsec.FX(runCy,DSBS,YTIME)$(ord(YTIME) > 2 and DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) = [
        V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME-1) *
        imActv(YTIME,runCy,DSBS) ** imElastA(runCy,DSBS,"a",YTIME) *
        (VmPriceFuelAvgSub.L(runCy,DSBS,YTIME)/VmPriceFuelAvgSub.L(runCy,DSBS,YTIME-1) ) ** imElastA(runCy,DSBS,"b1",YTIME) *
        (VmPriceFuelAvgSub.L(runCy,DSBS,YTIME-1)/VmPriceFuelAvgSub.L(runCy,DSBS,YTIME-2) ) ** imElastA(runCy,DSBS,"b2",YTIME) * 1
        !!prod(KPDL,
        !!  ((VmPriceFuelAvgSub.L(runCy,DSBS,YTIME-ord(KPDL))/VmPriceFuelAvgSub.L(runCy,DSBS,YTIME-(ord(KPDL)+1)))/((imCGI(runCy,YTIME)**(1/6))+1))**( imElastA(runCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
        !!)
      ]$imActv(YTIME-1,runCy,DSBS)
;
*---
V02FinalElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM);
*---
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = V02FinalElecNonSubIndTert.L(runCy,INDDOM,YTIME) * imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
*---
alias(ITECH,ITECH2);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2) and not CCSTECH(ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF),imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/ i02Util(runCy,DSBS,ITECH,YTIME));
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME) * (1-imShrNonSubElecInTotElecDem(runCy,DSBS))/sum(ITECH2$(TECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
*V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and sameas(ITECH,"TELC")) = imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME) * (1-imShrNonSubElecInTotElecDem(runCy,DSBS));
V02EquipCapTechSubsec.FX(runCy,DSBS,CCSTECH,YTIME)$(SECTTECH(DSBS,CCSTECH) and not An(YTIME)) = 0;
display V02EquipCapTechSubsec.L;
*----
V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) =
  (
    sum(EF$ITECHtoEF(ITECH,EF),
      i02Share(runCy,DSBS,ITECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME) +
      imCO2CaptRateIndustry(runCy,ITECH,YTIME) * VmCstCO2SeqCsts.L(runCy,YTIME-1) * 1e-3 * (imCo2EmiFac(runCy,DSBS,EF,YTIME-1) + 4.17$(sameas("BMSWAS", EF))) +
      (1-imCO2CaptRateIndustry(runCy,ITECH,YTIME)) * 1e-3 * (imCo2EmiFac(runCy,DSBS,EF,YTIME-1) + 4.17$(sameas("BMSWAS", EF))) *
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME-1))) +
      VmRenValue.L(YTIME)$(not RENEF(ITECH) and not NENSE(DSBS)) !! needs change of units
    ) +
    imVarCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME);

V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH))) = 0;
*---
V02CapCostTech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = ((
      (
        (imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * !! in case of chp plants we use the discount rate of power generation sector
        exp((imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME))
      ) /
      (exp((imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME)) - 1)
    ) *
    imCapCostTech(runCy,DSBS,ITECH,YTIME) * imCGI(runCy,YTIME) +
    imFixOMCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit)
    / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME);

V02CapCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH))) = 0;
*----    
V02CostTech.LO(runCy,DSBS,ITECH,YTIME) = 0;
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = 0.1;
V02CostTech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and not TRANSE(DSBS) and SECTTECH(DSBS,ITECH)) = V02VarCostTech.L(runCy,DSBS,ITECH,YTIME) + V02CapCostTech.L(runCy,DSBS,ITECH,YTIME);
V02CostTech.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and not TRANSE(DSBS) and SECTTECH(DSBS,ITECH))) = 0;
*---
V02ShareTechNewEquipUseful.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) =
    imMatrFactor(runCy,DSBS,ITECH,YTIME) *
    V02CostTech.L(runCy,DSBS,ITECH,YTIME) ** (-i02ElaSub(runCy,DSBS)) /
    sum(ITECH2$(SECTTECH(DSBS,ITECH2)),
      imMatrFactor(runCy,DSBS,ITECH2,YTIME) *
      V02CostTech.L(runCy,DSBS,ITECH2,YTIME) ** (-i02ElaSub(runCy,DSBS))
    );

V02ShareTechNewEquipUseful.FX(runCy,DSBS,ITECH,YTIME)$(not(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*---
V02PremScrpIndu.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and ord(YTIME)>2) =
  1 - (V02VarCostTech.L(runCy,DSBS,ITECH,YTIME-1) * i02util(runCy,DSBS,ITECH,YTIME-1)) ** (-2) /
    (
      (V02VarCostTech.L(runCy,DSBS,ITECH,YTIME-1) * i02util(runCy,DSBS,ITECH,YTIME-1)) ** (-2) +
      (
        i02ScaleEndogScrap(DSBS) *
        sum(ITECH2$(not sameas(ITECH2,ITECH) and SECTTECH(DSBS,ITECH2)),
          V02CostTech.L(runCy,DSBS,ITECH2,YTIME-1) + V02VarCostTech.L(runCy,DSBS,ITECH2,YTIME-1)
        )
      )**(-2)
    );

V02PremScrpIndu.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*----
V02RatioRem.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) = (1 - 1/VmLft.L(runCy,DSBS,ITECH,YTIME))* (1 - V02PremScrpIndu.L(runCy,DSBS,ITECH,YTIME));
V02RatioRem.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*----
V02RemEquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) = V02EquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME-1) * V02RatioRem.L(runCy,DSBS,ITECH,YTIME);
V02RemEquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(not (DATAY(YTIME) and SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*----
V02DemUsefulSubsecRemTech.FX(runCy,DSBS,YTIME)$(DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) =
SUM(ITECH$SECTTECH(DSBS,ITECH),
      V02RemEquipCapTechSubsec.L(runCy,DSBS,ITECH,YTIME) *
      imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME) *
      i02util(runCy,DSBS,ITECH,YTIME)
    );

V02DemUsefulSubsecRemTech.FX(runCy,DSBS,YTIME)$(not (DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*----
V02GapUsefulDemSubsec.FX(runCy,DSBS,YTIME)$(DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC")) = (
      V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME) -
      V02DemUsefulSubsecRemTech.L(runCy,DSBS,YTIME) +
      SQRT(SQR(V02DemSubUsefulSubsec.L(runCy,DSBS,YTIME) - V02DemUsefulSubsecRemTech.L(runCy,DSBS,YTIME)))
    )/2 + 1e-6
;

V02GapUsefulDemSubsec.FX(runCy,DSBS,YTIME)$(not (DATAY(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))) = 0;
*----




* Needs to be divided with average efficiency --- WHICH ONE?
 
*---
* Levels in other variables?
$ontext
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
$offtext
*---

* Levels in other variables?
$ontext
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
$offtext

$ontext 
V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = SUM(ITECH$SECTTECH(INDDOM,ITECH),
      V02EquipCapTechSubsec.L(runCy,INDDOM,ITECH,YTIME) *
      imUsfEneConvSubTech(runCy,INDDOM,ITECH,YTIME) *
      i02util(runCy,INDDOM,ITECH,YTIME)
    );
*V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - V02UsefulElecNonSubIndTert.L(runCy,INDDOM,YTIME), 1e-5) * 0.5;
V02DemSubUsefulSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
*V02DemSubUsefulSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - V02UsefulElecNonSubIndTert.L(runCy,"HOU",YTIME)-i02ExogDemOfBiomass(runCy,"HOU",YTIME),1e-5) * 0.8;
$offtext
*i02Share(runCy,DSBS,ITECH,EF,YTIME)$(SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) = (imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / V02EquipCapTechSubsec(runCy,DSBS,ITECH,YTIME);
*---
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM) / imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
*---
VmConsFuel.LO(runCy,DSBS,EF,YTIME) = 0;
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 1;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(HEATPUMP(EF) or TRANSE(DSBS) or sameas("DAC", DSBS)) = 0;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(not HEATPUMP(EF) and not TRANSE(DSBS) and DATAY(YTIME)) = imFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
*---
*vmConsTotElecInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmConsElecNonSubIndTert.l(runCy,INDSE,YTIME));
 
*vmDemFinSubFuelInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VmDemFinSubFuelSubsec.L(runCy,INDSE,YTIME));
*---
!!V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = 0.0001;

*---
