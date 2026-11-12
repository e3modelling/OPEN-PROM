*' @title Equations of OPEN-PROMs Heat module
*' @code

*' GENERAL INFORMATION

*' Steam demand is balanced against available production capacity. Technology capacity
*' evolves through scrapping and cost-based allocation of new capacity requirements.
*' Production costs include capital, fixed O&M, fuel, carbon, and capture components.

*' * Heat module

*' Calculates total steam demand as gross inland steam consumption less net imports. The
*' balance is used to determine domestic steam production requirements.
Q09DemTotSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotSte(allCy,YTIME)
        =E=
    V03ConsGrssInl(allCy,"STE",YTIME) - VmImpNetEneBrnch(allCy,"STE",YTIME);

*' Calculates the total steam capacity scrapping fraction from the technical lifetime
*' retirement rate and the endogenous premature-retirement index.
Q09ScrapRate(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09ScrapRate(allCy,TSTEAM,YTIME)
        =E=
    1 - (1 - 1 / i09ProdLftSte(TSTEAM)) *
    V09ScrapRatePremature(allCy,TSTEAM,YTIME);

*' Updates installed steam production capacity by retaining the previous-year capacity
*' after scrapping and allocating the new demand gap according to technology shares.
Q09CapSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapSte(allCy,TSTEAM,YTIME)
        =E=
    (1-V09ScrapRate(allCy,TSTEAM,YTIME)) * VmCapSte(allCy,TSTEAM,YTIME-1) +
    V09GapShareSte(allCy,TSTEAM,YTIME) * V09DemGapSte(allCy,YTIME);

*' Allocates total steam demand among production technologies in proportion to their
*' installed capacities. The technology outputs sum to total demand when aggregate
*' capacity is positive.
Q09ProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdSte(allCy,TSTEAM,YTIME)
        =E=
    VmDemTotSte(allCy,YTIME) /
    SUM(TSTEAM2, VmCapSte(allCy,TSTEAM2,YTIME)) * 
    VmCapSte(allCy,TSTEAM,YTIME);

*' Calculates the positive shortfall between total steam demand and surviving
*' previous-year capacity. The absolute-value expression implements max(demand minus
*' surviving capacity, 0), with a small positive offset.
Q09DemGapSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09DemGapSte(allCy,YTIME)
        =E=
  ( 
      VmDemTotSte(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmCapSte(allCy,TSTEAM,YTIME-1)
      ) +
  SQRT(SQR(
      VmDemTotSte(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmCapSte(allCy,TSTEAM,YTIME-1)
      )
  ))
  ) / 2 + 1e-3;

*' Calculates variable steam production cost from base-year fuel shares, fuel prices,
*' carbon capture and sequestration costs, residual emissions charges, and heat
*' efficiency. Adds variable O&M and subtracts a CHP electricity-related credit for CHP
*' technologies.
Q09CostVarProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostVarProdSte(allCy,TSTEAM,YTIME)
        =E=
    sum(EFS$TSTEAMTOEF(TSTEAM,EFS),
      i09ShareFuel(allCy,TSTEAM,EFS,"%fBaseY%") * 
      (
        VmPriceFuelSubsecCarVal(allCy,"STEAMP",EFS,YTIME) +
        V09CaptRateSte(allCy,TSTEAM,YTIME) * (imCo2EmiFac(allCy,"STEAMP",EFS,YTIME) + 4.17$(sameas("BMSWAS", EFS))) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 +
        (1-V09CaptRateSte(allCy,TSTEAM,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"STEAMP",EFS,YTIME)) * sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME))
      )
    ) / SUM(STECH$sameas(STECH,TSTEAM),imPlantEffByType(allCy,STECH,"effHeat","%fBaseY%")) + !!i09EffSteThrm(TSTEAM,YTIME) +
    i09CostVOMSteProd(TSTEAM,YTIME) * 1e-3 -!!/ smTWhToMtoe / SUM(TCHP$sameas(TCHP,TSTEAM),VmPriceElecInd(allCy,TCHP,YTIME)) -
    (
      VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) *
      smFracElecPriChp /
      SUM(TCHP$sameas(TCHP,TSTEAM),VmPriceElecInd(allCy,TCHP,YTIME))
    )$TCHP(TSTEAM);

*' Annualizes investment and fixed O&M costs using the sector discount rate and technology
*' lifetime. Adjusts for the power-to-heat ratio, availability, and energy-unit conversion
*' to obtain a unit steam production cost.
Q09CostCapProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostCapProdSte(allCy,TSTEAM,YTIME)
        =E=
    (
      imDisc(allCy,"STEAMP",YTIME) * 
      exp(imDisc(allCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM)) /
      (exp(imDisc(allCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM))-1) * 
      (
        i09CostInvCostSteProd(TSTEAM,YTIME) * imCGI(allCy,YTIME) +
        i09CostFixOMSteProd(TSTEAM,YTIME)
      )
    ) / (i09PowToHeatRatio(TSTEAM,YTIME) + 1$TDHP(TSTEAM)) /
    (
      i09AvailRateSteProd(TSTEAM,YTIME) * 
      smGwToTwhPerYear(YTIME) * 
      smTWhToMtoe * 1e3
    );

*' Calculates total unit steam production cost as the sum of annualized capital and fixed
*' costs and variable production costs.
Q09CostProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostProdSte(allCy,TSTEAM,YTIME)
        =E=
    V09CostCapProdSte(allCy,TSTEAM,YTIME) +
    V09CostVarProdSte(allCy,TSTEAM,YTIME);

*' Calculates the production-weighted average steam cost across all technologies. A small
*' positive term in each weight stabilizes the ratio when production is very low.
Q09CostAvgProdSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdSte(allCy,YTIME)
        =E=
    sum(TSTEAM, 
      (VmProdSte(allCy,TSTEAM,YTIME) + 1e-6) *
      V09CostProdSte(allCy,TSTEAM,YTIME)
    ) / 
    sum(TSTEAM,VmProdSte(allCy,TSTEAM,YTIME) + 1e-6);

*' Allocates the steam capacity demand gap among technologies using inverse-squared
*' previous-year total production costs. Technology maturity factors appear only in
*' commented-out terms and are not active.
Q09GapShareSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V09GapShareSte(allCy,TSTEAM,YTIME)
        =E=
    !!i04MatFacPlaAvailCap(allCy,TSTEAM,YTIME) *
    V09CostProdSte(allCy,TSTEAM,YTIME-1) ** (-2) /
    SUM(TSTEAM2,
      !!i04MatFacPlaAvailCap(allCy,TSTEAM2,YTIME) *
      V09CostProdSte(allCy,TSTEAM2,YTIME-1) ** (-2)
    );

*' Calculates the steam-plant CO2 capture rate as a logistic response to the ratio of
*' sequestration cost to the sector carbon value, scaled by the technology-specific
*' maximum capture rate.
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

*' Calculates the premature-retirement index using inverse-squared previous-year variable
*' costs relative to scaled alternative technology costs. Competing CHP and
*' district-heating technologies are evaluated separately.
Q09ScrapRatePremature(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V09ScrapRatePremature(allCy,TSTEAM,YTIME)
        =E=
    V09CostVarProdSte(allCy,TSTEAM,YTIME-1) ** (-2) /
    (
      V09CostVarProdSte(allCy,TSTEAM,YTIME-1) ** (-2) +
      (( 
        i09ScaleEndogScrap *
        sum(TCHP2$(not sameas(TSTEAM,TCHP2)),
          V09CostProdSte(allCy,TCHP2,YTIME-1)
        )
      ) ** (-2)
      )$TCHP(TSTEAM) +
      (( 
        i09ScaleEndogScrap *
        sum(TDHP2$(not sameas(TSTEAM,TDHP2)),
          V09CostProdSte(allCy,TDHP2,YTIME-1)
        )
      ) ** (-2)
      )$TDHP(TSTEAM)
    );

