*' @title Equations of OPEN-PROMs Heat module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Heat module

*' This equation calculates the total heat demand in the system. It takes into account the overall need for steam
*' across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
Q09DemTotSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotSte(allCy,YTIME)
        =E=
    sum(DSBS$(INDDOM(DSBS) or NENSE(DSBS)), 
      VmConsFuel(allCy,DSBS,"STE",YTIME)
    ); !! FIXME: Add transportation losses and own consumption

Q09ScrapRate(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09ScrapRate(allCy,TSTEAM,YTIME)
        =E=
    1 - (1 - 1 / i09ProdLftSte(TSTEAM,YTIME)) *
    V09ScrapRatePremature(allCy,TSTEAM,YTIME);

Q09ProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdSte(allCy,TSTEAM,YTIME)
        =E=
    (1-V09ScrapRate(allCy,TSTEAM,YTIME)) * VmProdSte(allCy,TSTEAM,YTIME-1) +
    V09GapShareSte(allCy,TSTEAM,YTIME) * V09DemGapSte(allCy,YTIME);

Q09DemGapSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09DemGapSte(allCy,YTIME)
        =E=
  ( 
      VmDemTotSte(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmProdSte(allCy,TSTEAM,YTIME-1)
      ) +
  SQRT( SQR(
      VmDemTotH2(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmProdSte(allCy,TSTEAM,YTIME-1)
      )
  ))
  )/2 + 1e-6;

Q09CostVarProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostVarProdSte(allCy,TSTEAM,YTIME)
        =E=
    sum(EF$TSTEAMTOEF(TSTEAM,EF),
      (
        VmPriceFuelSubsecCarVal(allCy,"STEAMP",EF,YTIME) +
        V09CaptRateSte(allCy,TSTEAM,YTIME) * 
        (imCo2EmiFac(allCy,"STEAMP",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * 
        VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 +
        (1-V09CaptRateSte(allCy,TSTEAM,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"STEAMP",EF,YTIME)) *
        sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME))
      ) 
    ) / 0.8 -!! FIXME: / imUsfEneConvSubTech(allCy,"OI",TSTEAM,YTIME) -
    VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) *
    smFracElecPriChp *
    VmPriceElecInd(allCy,YTIME) / 0.8 !! imUsfEneConvSubTech(allCy,"OI",TSTEAM,YTIME)
  ;

Q09CostCapProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostCapProdSte(allCy,TSTEAM,YTIME)
        =E=
    (
      imDisc(allCy,"STEAMP",YTIME) * 
      exp(imDisc(allCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM,YTIME)) /
      (exp(imDisc(allCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM,YTIME))-1) * 
      (
        imDataIndTechnologyCHP("OI",TSTEAM,"IC") * imCGI(allCy,YTIME) +
        imDataIndTechnologyCHP("OI",TSTEAM,"FC") / sUnitToKUnit +
        i09CostVOMSteProd(allCy,TSTEAM,YTIME)
      )
    ) / 0.8 !! imUsfEneConvSubTech(allCy,"OI",TSTEAM,YTIME)
    ;

Q09CostProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostProdSte(allCy,TSTEAM,YTIME)
        =E=
    V09CostCapProdSte(allCy,TSTEAM,YTIME) +
    V09CostVarProdSte(allCy,TSTEAM,YTIME);

Q09CostAvgProdSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdSte(allCy,YTIME)
        =E=
    sum(TSTEAM, 
      VmProdSte(allCy,TSTEAM,YTIME) *
      V09CostProdSte(allCy,TSTEAM,YTIME)
    ) / sum(TSTEAM,VmProdSte(allCy,TSTEAM,YTIME));

Q09GapShareSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V09GapShareSte(allCy,TSTEAM,YTIME)
        =E=
    !!i04MatFacPlaAvailCap(allCy,TSTEAM,YTIME) *
    V09CostProdSte(allCy,TSTEAM,YTIME-1) ** (-2) /
    SUM(TSTEAM2,
      !!i04MatFacPlaAvailCap(allCy,TSTEAM2,YTIME) *
      V09CostProdSte(allCy,TSTEAM2,YTIME-1) ** (-2)
    );

Q09CaptRateSte(allCy,TSTEAM,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V09CaptRateSte(allCy,TSTEAM,YTIME)
        =E=
    i09CaptRateSteProd(TSTEAM) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    );

Q09ScrapRatePremature(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V09ScrapRatePremature(allCy,TSTEAM,YTIME)
        =E=
    1
$ontext
    V09CostVarProdSte(allCy,TSTEAM,YTIME) ** (-2) /
    (
      V09CostVarProdSte(allCy,TSTEAM,YTIME) ** (-2) +
      (
        i09ScaleEndogScrap *
        sum(TSTEAM2$(not sameas(TSTEAM,TSTEAM2)),
          V09CostProdSte(allCy,TSTEAM2,YTIME)
        )
      ) ** (-2)
    )
$offtext
;

Q09ConsFuelSteProd(allCy,EF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFuelSteProd(allCy,EF,YTIME)
      =E=
    SUM(TSTEAM$TSTEAMTOEF(TSTEAM,EF),
      VmProdSte(allCy,TSTEAM,YTIME) / i09EffSteProd(TSTEAM)
    )
;