*' @title Equations of OPEN-PROM Power Generation
*' @code

*' GENERAL INFORMATION

*' These equations describe electricity demand, generation, plant costs, capacity
*' investment, technology shares, CO2 capture, retrofits, and scrapping.

*' Power Generation
*' Estimates CHP electricity production from steam production divided by the industrial
*' electricity price for the CHP technology, then converts from Mtoe to TWh.
Q04ProdElecEstCHP(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ProdElecEstCHP(allCy,TCHP,YTIME) 
        =E=
    VmProdSte(allCy,TCHP,YTIME) / VmPriceElecInd(allCy,TCHP,YTIME) / smTWhToMtoe;
*' Calculates total domestic electricity generation requirements from gross inland
*' electricity consumption minus net electricity imports, converted from Mtoe to TWh.
Q04DemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04DemElecTot(allCy,YTIME)
        =E=
    (V03ConsGrssInl(allCy,"ELC",YTIME) - VmImpNetEneBrnch(allCy,"ELC",YTIME)) / smTWhToMtoe;          
*' Calculates annualized capital and fixed operation and maintenance costs for each
*' generation technology. Capital expenditure is adjusted by the capital goods index and,
*' when enabled, technology-specific learning-curve factors.
Q04CapexFixCostPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapexFixCostPG(allCy,PGALL,YTIME)
        =E=         
    ( 
      imDisc(allCy,"PG",YTIME) * exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL))
      / (exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL)) -1)
    ) * i04GrossCapCosSubRen(allCy,PGALL,YTIME) * 1000 * imCGI(allCy,YTIME) 
    * 
    (
$ifthen.curves "%Curves%" == "LearningCurves" 
        sum(LCTECH$sameas(LCTECH,PGALL), i10LearnableFraction(LCTECH) * VmCostLC(LCTECH,YTIME) + (1 - i10LearnableFraction(LCTECH)))$LCTECH(PGALL)
        + 1$(not LCTECH(PGALL))
$else.curves
        1 
$endif.curves
    ) +
    i04FixOandMCost(allCy,PGALL,YTIME);
*' Calculates capital and fixed cost per unit of electricity output by scaling annualized
*' costs with the renewable integration cost factor and dividing by available annual
*' generation.
Q04CostCapTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostCapTech(allCy,PGALL,YTIME) 
        =E=
    V04CapexRESRate(allCy,PGALL,YTIME) * V04CapexFixCostPG(allCy,PGALL,YTIME) / 
    (i04AvailRate(allCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000)
 !!#UPT   * (imCostCapTechDisc(YTIME)$(sameas(PGALL,"ATHBMSCCS")) + 1$(not sameas(PGALL,"ATHBMSCCS")))
    ;
*' Calculates non-negative variable generation cost from variable O&M and fuel costs,
*' accounting for fuel shares, conversion efficiency, carbon prices, capture rates, and
*' CO2 storage costs. Adds a small positive offset.
Q04CostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostVarTech(allCy,PGALL,YTIME)
        =E=
      (
        i04VarCost(PGALL,YTIME) / 1e3 + 
        sum(PGEF$PGALLtoEF(PGALL,PGEF), 
          i04ShareFuels(allCy,PGALL,PGEF) * 
          (
            VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
            V04CO2CaptRate(allCy,PGALL,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$sameas("BMSWAS", PGEF)) +
            (1-V04CO2CaptRate(allCy,PGALL,YTIME)) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME)) -
            V04CO2CaptRate(allCy,PGALL,YTIME) * 1e-3 * (4.17$sameas("BMSWAS", PGEF)) * sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME))
          ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,"effELC",YTIME)
        ) +
        SQRT(SQR(
          i04VarCost(PGALL,YTIME) / 1e3 + 
          sum(PGEF$PGALLtoEF(PGALL,PGEF), 
            i04ShareFuels(allCy,PGALL,PGEF) * 
            (
              VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
              V04CO2CaptRate(allCy,PGALL,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$sameas("BMSWAS", PGEF)) +
              (1-V04CO2CaptRate(allCy,PGALL,YTIME)) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME)) -
              V04CO2CaptRate(allCy,PGALL,YTIME) * 1e-3 * (4.17$sameas("BMSWAS", PGEF)) * sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME))
            ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,"effELC",YTIME)
          )
        ))
      ) / 2 + 1e-3;
*' Calculates the cost metric used for power plant investment decisions from capital and
*' variable generation costs and the feed-in tariff. The square-root expression selects
*' the smaller of total cost and twice total cost minus the tariff.
Q04CostHourProdInvDec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CostHourProdInvDec(allCy,PGALL,YTIME)
        =E=             
    (
      (V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) +
      (2 * (V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) - i04FIT(allCy,PGALL,YTIME))
      -
      sqrt(sqr((V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) -
      (2 * (V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) - i04FIT(allCy,PGALL,YTIME))))
    ) / 2;
*' Computes an endogenous retention index for technologies eligible for scrapping. It
*' compares the inverse-square of the technology variable cost with scaled inverse-square
*' costs of alternative plants, adjusted for availability.
Q04IndxEndogScrap(allCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
    V04IndxEndogScrap(allCy,PGALL,YTIME)
        =E=
    V04CostVarTech(allCy,PGALL,YTIME-1)**(-2) /
    (
      V04CostVarTech(allCy,PGALL,YTIME-1)**(-2) +
      i04ScaleEndogScrap(allCy,PGALL,YTIME) *
      sum(PGALL2$(not sameas(PGALL,PGALL2)),
        (
          i04AvailRate(allCy,PGALL2,YTIME) / i04AvailRate(allCy,PGALL,YTIME) * 
          V04CostHourProdInvDec(allCy,PGALL2,YTIME-1) 
        ) ** (-2)
        !!+
        !!(1-i04AvailRate(allCy,PGALL2,YTIME) / i04AvailRate(allCy,PGALL,YTIME)) *
        !!V04CostVarTech(allCy,PGALL2,YTIME)
      )
    );
*' Calculates required non-CHP generation capacity by subtracting estimated CHP
*' electricity output from total electricity requirements and converting annual TWh to GW.
Q04CapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNonCHP(allCy,YTIME)
        =E=
    (
      !!VmCapElecTotEst(allCy,YTIME) -
      V04DemElecTot(allCy,YTIME) - 
      SUM(TCHP,V04ProdElecEstCHP(allCy,TCHP,YTIME)) 
    ) / smGwToTwhPerYear(YTIME);      
*' Calculates the non-negative generation capacity gap using the change in required
*' non-CHP capacity, scrapping, CCS retrofits, and scheduled decommissioning and
*' investment. Adds a small positive offset.
Q04GapGenCapPowerDiff(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04GapGenCapPowerDiff(allCy,YTIME)
        =E=
    (
      (
        V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
        sum(PGALL, 
          VmCapElec(allCy,PGALL,YTIME-1) * V04ScrpRate(allCy,PGALL,YTIME) -
          VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04CCSRetroFit(allCy,PGALL,YTIME)) +
          (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(allCy,PGALL,YTIME)
        ) 
      ) +
      SQRT(SQR(
      (
        V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
        sum(PGALL,
          VmCapElec(allCy,PGALL,YTIME-1) * V04ScrpRate(allCy,PGALL,YTIME) -
          VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04CCSRetroFit(allCy,PGALL,YTIME)) +
          (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(allCy,PGALL,YTIME)
        )
      ))
      ) 
    ) / 2 + 1e-6;
*' Calculates the share of wind and solar technologies in total installed generation
*' capacity, using the technologies identified by PGRENSW.
Q04ShareMixWndSol(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareMixWndSol(allCy,YTIME)
        =E=
    sum(PGALL$PGRENSW(PGALL), VmCapElec(allCy,PGALL,YTIME)) /
    sum(PGALL, VmCapElec(allCy,PGALL,YTIME));
*' Allocates new generation investment shares across technologies according to maturity or
*' availability factors and the inverse square of previous-year investment decision costs.
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V04SharePowPlaNewEq(allCy,PGALL,YTIME)
        =E=
    i04MatFacPlaAvailCap(allCy,PGALL,YTIME) *
    !!V04ShareSatPG(allCy,PGALL,YTIME-1) *
    V04CostHourProdInvDec(allCy,PGALL,YTIME-1) ** (-2) /
    SUM(PGALL2,
      i04MatFacPlaAvailCap(allCy,PGALL2,YTIME) *
      !!V04ShareSatPG(allCy,PGALL2,YTIME-1) *
      V04CostHourProdInvDec(allCy,PGALL2,YTIME-1) ** (-2)
    );
*' Updates available generation capacity from surviving previous-year capacity plus new
*' capacity, less scheduled decommissioning adjusted by the availability rate.
Q04CapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapElec(allCy,PGALL,YTIME)
          =E=
    VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04ScrpRate(allCy,PGALL,YTIME)) +
    V04NewCapElec(allCy,PGALL,YTIME) -
    i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME);
*' Converts available generation capacity into nominal capacity by dividing by the
*' technology availability rate.
Q04CapElecNominal(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNominal(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL,YTIME);
*' Calculates new available generation capacity from technology investment shares, the
*' capacity gap, scheduled investment, and capacity transferred from non-CCS plants
*' through retrofit.
Q04NewCapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04NewCapElec(allCy,PGALL,YTIME)
        =E=
    V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME) +
    i04DecInvPlantSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME) +
    SUM(PGALL2$CCS_NOCCS(PGALL,PGALL2),
      (1 - V04CCSRetroFit(allCy,PGALL2,YTIME)) * VmCapElec(allCy,PGALL2,YTIME-1)
    );
*' Calculates the year-on-year change in installed renewable generation capacity. The
*' difference can be negative when renewable capacity decreases.
Q04NetNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
    V04NetNewCapElec(allCy,PGALL,YTIME) 
        =E=
    VmCapElec(allCy,PGALL,YTIME) - VmCapElec(allCy,PGALL,YTIME-1);                       
*' Allocates total non-CHP electricity generation across technologies in proportion to
*' their available capacities and converts GW of capacity to annual TWh.
Q04ProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdElec(allCy,PGALL,YTIME)
        =E=
    V04CapElecNonCHP(allCy,YTIME) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME)) * 
    VmCapElec(allCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME);
    !!i04util(allCy,PGALL,YTIME) *
    !!VmCapElec(allCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME);
*' Calculates the share of each generation technology in total available electricity
*' generation capacity.
Q04ShareTechPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareTechPG(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME));
*' Calculates a sigmoid-based saturation factor for renewable generation technologies as a
*' decreasing function of their capacity share.
Q04ShareSatPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy))$(PGREN(PGALL)))..
    V04ShareSatPG(allCy,PGALL,YTIME)
        =E=
    2 / (1+exp(9*V04ShareTechPG(allCy,PGALL,YTIME)));
*' Calculates the generation-weighted average long-run electricity production cost. For
*' each technology, the cost expression selects the larger of total generation cost and
*' the feed-in tariff.
Q04CostPowGenAvgLng(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostPowGenAvgLng(allCy,YTIME)
        =E=
    SUM(PGALL,(VmProdElec(allCy,PGALL,YTIME) + 1e-6) *
        (
            (V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) + i04FIT(allCy,PGALL,YTIME)
            +
            sqrt(sqr((V04CostCapTech(allCy,PGALL,YTIME) + V04CostVarTech(allCy,PGALL,YTIME)) - i04FIT(allCy,PGALL,YTIME)))
        ) / 2
    ) / 
    SUM(PGALL,VmProdElec(allCy,PGALL,YTIME) + 1e-6); 
*' Calculates an additional capital-cost multiplier for wind and solar technologies based
*' on their previous-year capacity share and the renewable integration exponent. Other
*' technologies receive a factor of one.
Q04CapexRESRate(allCy,PGALL,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V04CapexRESRate(allCy,PGALL,YTIME)
        =E=
    1 + (V04ShareMixWndSol(allCy,YTIME-1)$PGRENSW(PGALL)) ** S04CapexBessRate;
*' Calculates the effective CO2 capture rate using the technology-specific maximum capture
*' rate and a logistic response to the ratio of CO2 storage costs to carbon prices.
Q04CO2CaptRate(allCy,PGALL,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V04CO2CaptRate(allCy,PGALL,YTIME)
        =E=
    imCO2CaptRate(PGALL) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1.1)
      )
    );
*' Calculates a non-CCS plant retention factor by comparing inverse-square variable costs
*' of the existing plant with scaled inverse-square costs of corresponding CCS
*' alternatives.
Q04CCSRetroFit(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy))$(NOCCS(PGALL)))..
    V04CCSRetroFit(allCy,PGALL,YTIME)
        =E=
    V04CostVarTech(allCy,PGALL,YTIME-1)** (-2) /
    (
      V04CostVarTech(allCy,PGALL,YTIME-1)** (-2) +
      0.002 *
      SUM(PGALL2$CCS_NOCCS(PGALL2,PGALL),
        (
          V04CostCapTech(allCy,PGALL2,YTIME-1) +
          !! - i04AvailRate(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL2,YTIME) *
          !!V04CostCapTech(allCy,PGALL,YTIME-1) +
          V04CostVarTech(allCy,PGALL2,YTIME-1)
        ) ** (-2)
      )
    );
*' Calculates the total scrapping rate from technical lifetime, the endogenous retention
*' index, and the CCS retrofit retention factor.
Q04ScrpRate(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ScrpRate(allCy,PGALL,YTIME)
        =E=
    1 - (1 - 1 / i04TechLftPlaType(allCy,PGALL)) * 
    V04IndxEndogScrap(allCy,PGALL,YTIME) *
    V04CCSRetroFit(allCy,PGALL,YTIME);


$ontext
*' Inactive equation in a GAMS text block. Estimates CHP electricity production costs from
*' annualized capital, fixed and variable O&M, fuel, carbon costs, and conversion
*' efficiency. The original block includes a FIXME.
Q09CostElecProdCHP(allCy,DSBS,TCHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
    V09CostElecProdCHP(allCy,DSBS,TCHP,YTIME)
        =E=
    ( 
      imDisc(allCy,"PG",YTIME) * 
      exp(imDisc(allCy,"PG",YTIME) * i02LifChpPla(allCy,DSBS,TCHP)) /
      (exp(imDisc(allCy,"PG",YTIME) * i02LifChpPla(allCy,DSBS,TCHP)) -1) *
      i02InvCostChp(allCy,DSBS,TCHP,YTIME) * imCGI(allCy,YTIME) + 
      i02FixOMCostPerChp(allCy,DSBS,TCHP,YTIME)
    ) /
    (i02AvailRateChp(allCy,DSBS,TCHP) * (smGwToTwhPerYear(YTIME)) * 1000) +
    i02VarCostChp(allCy,DSBS,TCHP,YTIME) / 1000


!! FIXME
    sum(PGEF$CHPtoEF(TCHP,PGEF),
      (
        VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
        1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME) *
        sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))
      ) * smTWhToMtoe /
      (i02BoiEffChp(allCy,CHP,YTIME) * (VmPriceElecInd(allCy,CHP,YTIME)) + 1e-4)
    )  

;
*' Inactive equation in a GAMS text block. Calculates a prior-year
*' steam-consumption-weighted average CHP electricity production cost across industrial
*' and domestic subsectors, with a zero-demand safeguard.
Q09CostElcAvgProdCHP(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostElcAvgProdCHP(allCy,TCHP,YTIME)
      =E=
    (
      sum(INDDOM, 
        VmConsFuel(allCy,INDDOM,"STE",YTIME-1) /
        SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,"STE",YTIME-1)) *
        V02CostElecProdCHP(allCy,INDDOM,TCHP,YTIME)
      )
    )$SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,"STE",YTIME-1))+0$(NOT SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,"STE",YTIME-1)));
$offtext