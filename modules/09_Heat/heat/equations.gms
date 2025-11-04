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

Q09ScrapRate(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09ScrapRate(allCy,TCHP,YTIME)
        =E=
    1 - (1 - 1 / i09ProdLftSte(TCHP,YTIME)) *
    V09ScrapRatePremature(allCy,TCHP,YTIME);

Q09ProdSte(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdSte(allCy,TCHP,YTIME)
        =E=
    (1-V09ScrapRate(allCy,TCHP,YTIME)) * VmProdSte(allCy,TCHP,YTIME-1) +
    V09GapShareSte(allCy,TCHP,YTIME) * V09DemGapSte(allCy,YTIME);

Q09DemGapSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09DemGapSte(allCy,YTIME)
        =E=
  ( 
      VmDemTotSte(allCy,YTIME) -
      sum(TCHP,
        (1-V09ScrapRate(allCy,TCHP,YTIME)) *
        VmProdSte(allCy,TCHP,YTIME-1)
      ) +
  SQRT( SQR(
      VmDemTotH2(allCy,YTIME) -
      sum(TCHP,
        (1-V09ScrapRate(allCy,TCHP,YTIME)) *
        VmProdSte(allCy,TCHP,YTIME-1)
      )
  ))
  )/2 + 1e-6;

Q09CostVarProdSte(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostVarProdSte(allCy,TCHP,YTIME)
        =E=
    sum(EF$TCHPTOEF(TCHP,EF),
      (
        VmPriceFuelSubsecCarVal(allCy,"STEAMP",EF,YTIME) +
        V09CaptRateSte(allCy,TCHP,YTIME) * 
        (imCo2EmiFac(allCy,"STEAMP",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * 
        VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 +
        (1-V09CaptRateSte(allCy,TCHP,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"STEAMP",EF,YTIME)) *
        sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME))
      ) 
    ) / imUsfEneConvSubTech(allCy,"OI",TCHP,YTIME) -
    VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) *
    smFracElecPriChp *
    VmPriceElecInd(allCy,YTIME) /
    imUsfEneConvSubTech(allCy,"OI",TCHP,YTIME);

Q09CostCapProdSte(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostCapProdSte(allCy,TCHP,YTIME)
        =E=
    (
      imDisc(allCy,"STEAMP",YTIME) * 
      exp(imDisc(allCy,"STEAMP",YTIME)* i09ProdLftSte(TCHP,YTIME)) /
      (exp(imDisc(allCy,"STEAMP",YTIME) * i09ProdLftSte(TCHP,YTIME))-1) * 
      (
        imCapCostTech(allCy,"OI",TCHP,YTIME) * imCGI(allCy,YTIME) +
        imFixOMCostTech(allCy,"OI",TCHP,YTIME) / sUnitToKUnit +
        i09CostVOMSteProd(allCy,TCHP,YTIME)
      )
    ) / imUsfEneConvSubTech(allCy,"OI",TCHP,YTIME);

Q09CostProdSte(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostProdSte(allCy,TCHP,YTIME)
        =E=
    V09CostCapProdSte(allCy,TCHP,YTIME) +
    V09CostVarProdSte(allCy,TCHP,YTIME);

Q09CostAvgProdSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdSte(allCy,YTIME)
        =E=
    sum(TCHP, 
      VmProdSte(allCy,TCHP,YTIME) *
      V09CostProdSte(allCy,TCHP,YTIME)
    ) / sum(TCHP,VmProdSte(allCy,TCHP,YTIME));

Q09GapShareSte(allCy,TCHP,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V09GapShareSte(allCy,TCHP,YTIME)
        =E=
    !!i04MatFacPlaAvailCap(allCy,TCHP,YTIME) *
    V09CostProdSte(allCy,TCHP,YTIME-1) ** (-2) /
    SUM(TCHP2,
      !!i04MatFacPlaAvailCap(allCy,TCHP2,YTIME) *
      V09CostProdSte(allCy,TCHP2,YTIME-1) ** (-2)
    );

Q09CaptRateSte(allCy,TCHP,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V09CaptRateSte(allCy,TCHP,YTIME)
        =E=
    i09CaptRateSteProd(TCHP) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    );

Q09ScrapRatePremature(allCy,TCHP,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V09ScrapRatePremature(allCy,TCHP,YTIME)
        =E=
    V09CostVarProdSte(allCy,TCHP,YTIME) ** (-2) /
    (
      V09CostVarProdSte(allCy,TCHP,YTIME) ** (-2) +
      (
        i09ScaleEndogScrap *
        sum(TCHP2$(not sameas(TCHP,TCHP2)),
          V09CostProdSte(allCy,TCHP2,YTIME)
        )
      ) ** (-2)
    );