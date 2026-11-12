*' @title Equations of OPEN-PROMs Transport
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity)
*' and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and
*' past activity indicators (with the corresponding elasticity),
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type
*' of equation captures both short term and long term reactions to energy costs.

*' * Transport

*' Projects freight transport activity from the previous year. GU activity responds to GDP
*' per capita (fixed elasticity 0.4), population (0.8), current and lagged fuel-price
*' changes, and distributed price lags adjusted by imCGI. Other TRANG modes use
*' sector-specific income and price elasticities and are additionally linked to the growth
*' of GU activity. BUN1 activity follows the exogenous imActv growth multiplier.
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $(TRANG(TRANSE) or BUN1(TRANSE)) $runCy(allCy))..
      V01ActivGoodsTransp(allCy,TRANSE,YTIME)
              =E=
      (
      V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)
        * [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)] ** 0.4 !!imElastA(allCy,TRANSE,"a",YTIME)
        * (i01Pop(YTIME,allCy)/i01Pop(YTIME-1,allCy)) ** 0.8
        * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME)
        * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
        * prod(kpdl,
              [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
          )
      )$sameas(TRANSE,"GU") +
      (
        V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        prod(kpdl,
          [
            (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl)) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1))) /
            (imCGI(allCy,YTIME)**(1/6))
          ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        ) *
        (
          (V01ActivGoodsTransp(allCy,"GU",YTIME) + 1e-6) / 
          (V01ActivGoodsTransp(allCy,"GU",YTIME-1) + 1e-6)
        )**imElastA(allCy,TRANSE,"c4",YTIME)
      )$(TRANG(TRANSE) and not sameas(TRANSE,"GU")) +
      (
        V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) *
        imActv(YTIME,allCy,TRANSE)
      )$BUN1(TRANSE);

*' Determines the non-negative transport activity requiring new capacity. For passenger
*' cars (PC), the gap equals total new registrations. For other passenger and freight
*' modes, it is the positive part of the annual activity change plus activity-equivalent
*' capacity retired through scrapping; negative replacement requirements are set to zero.
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01GapTranspActiv(allCy,TRANSE,YTIME)
            =E=
    V01NewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC") +
    (
      ( 
        V01ActivPassTrnsp(allCy,TRANSE,YTIME) - 
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + 
        SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)) +
        SQRT(SQR(
          V01ActivPassTrnsp(allCy,TRANSE,YTIME) - 
          V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + 
          SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME))
        )) 
      )/2
    )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC"))) +
    (
      ( 
        V01ActivGoodsTransp(allCy,TRANSE,YTIME) - 
        V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + 
        SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)) + 
        SQRT( SQR(
          V01ActivGoodsTransp(allCy,TRANSE,YTIME) - 
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + 
          SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME))
        )) 
      )/2
    )$(TRANG(TRANSE) or BUN1(TRANSE));

*' Calculates the annualized net investment cost of a transport technology. The
*' continuous-discounting annuity factor uses the sectoral discount rate and technology
*' lifetime; technology-specific demand subsidies are deducted from upfront capital cost,
*' and the result is multiplied by imCGI.
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
          =E=
    (
      (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
      /
      (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
    ) * (imCapCostTech(allCy,TRANSE,TTECH,YTIME) - VmSubsiDemTech(allCy,TRANSE,TTECH,YTIME)) *
    imCGI(allCy,YTIME)
;

*' Calculates technology-specific operating costs from specific fuel consumption,
*' fuel-blending shares, final fuel prices and carbon prices, plus variable technology
*' costs. Plug-in hybrids split electric and non-electric operation using the annual
*' electric-mileage share; the electric portion uses the electricity price without an
*' explicit carbon-price term. Passenger-car costs are scaled by 0.001 times passenger-car
*' activity, while other modes use a factor of one.
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CostFuel(allCy,TRANSE,TTECH,YTIME)
        =E=
    (
      (
        sum(EFS$TTECHtoEF(TTECH,EFS),
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EFS,YTIME) * 
          V01ShareBlend(allCy,TRANSE,EFS,YTIME) *
          (VmPriceFinal(allCy,TRANSE,EFS,YTIME) + VmPriceCarbon(allCy,TRANSE,EFS,YTIME))
        ) 
      )$(not PLUGIN(TTECH)) +
      (
        sum(EFS$(TTECHtoEF(TTECH,EFS) $(not sameas("ELC",EFS))),
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) * 
          V01ShareBlend(allCy,TRANSE,EFS,YTIME) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EFS,YTIME) * !! ktoe / Activity
          (VmPriceFinal(allCy,TRANSE,EFS,YTIME) + VmPriceCarbon(allCy,TRANSE,EFS,YTIME))
        ) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME) *
        VmPriceFinal(allCy,TRANSE,"ELC",YTIME)
      )$PLUGIN(TTECH) +
      imVarCostTech(allCy,TRANSE,TTECH,YTIME)
    ) *
    (
      1$(not sameas(TRANSE,"PC")) +
      1e-3 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC")
    )
    ;

*' Calculates the cost measure used in transport technology choice as fixed O&M cost plus
*' calculated fuel and variable operating costs. Although the annualized capital-cost
*' variable appears in the equation, it is multiplied by zero and therefore does not
*' contribute to the current cost measure.
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$runCy(allCy)$SECTTECH(TRANSE,TTECH))..
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)
        =E=
      0 *V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME) +
      imFixOMCostTech(allCy,TRANSE,TTECH,YTIME) +
      V01CostFuel(allCy,TRANSE,TTECH,YTIME);

*' Allocates each transport subsector among eligible technologies using a normalized
*' cost-based share. Each technology receives a weight equal to its maturity factor
*' multiplied by the inverse square of its previous-year cost measure; weights are divided
*' by the sum across eligible technologies.
Q01ShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01ShareTechTr(allCy,TRANSE,TTECH,YTIME)
      =E=
    imMatrFactor(allCy,TRANSE,TTECH,YTIME) *
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME-1) ** (-2) /
    sum(TTECH2$SECTTECH(TRANSE,TTECH2), 
      imMatrFactor(allCy,TRANSE,TTECH2,YTIME) * 
      V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME-1) ** (-2)
    );

*' Calculates the total passenger-car stock from passenger-car ownership per capita and
*' population. Population is multiplied by 1,000 to match the stock and ownership scaling
*' used in the model.
Q01StockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearly(allCy,YTIME)
            =E=
      V01PcOwnPcLevl(allCy,YTIME) * 
      (i01Pop(YTIME,allCy) * 1000);

*' Updates passenger-car stock by technology: surviving previous-year vehicles after the
*' total scrapping rate, plus new registrations of that technology.
Q01StockPcYearlyTech(allCy,TTECH,YTIME)$(TIME(YTIME)$runCy(allCy)$SECTTECH("PC",TTECH))..
      V01StockPcYearlyTech(allCy,TTECH,YTIME)
            =E=
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1) * 
      (1 - V01RateScrPcTot(allCy,"PC",TTECH,YTIME)) +
      V01NewRegPcTechYearly(allCy,TTECH,YTIME);

*' Allocates total required passenger-car registrations across technologies according to
*' their modeled technology shares.
Q01NewRegPcTechYearly(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NewRegPcTechYearly(allCy,TTECH,YTIME)
        =E=
    V01ShareTechTr(allCy,"PC",TTECH,YTIME) *
    V01GapTranspActiv(allCy,"PC",YTIME);

*' Calculates total new passenger-car registrations as the positive part of the annual
*' change in desired passenger-car stock plus the number of cars scrapped. The
*' absolute-value expression prevents negative registrations.
Q01NewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NewRegPcYearly(allCy,YTIME)
            =E=
    (
      V01StockPcYearly(allCy,YTIME) - 
      V01StockPcYearly(allCy,YTIME-1) +
      V01NumPcScrap(allCy,YTIME) +
    sqrt(sqr(
      V01StockPcYearly(allCy,YTIME) - 
      V01StockPcYearly(allCy,YTIME-1) +
      V01NumPcScrap(allCy,YTIME)))
    ) / 2;

*' Projects passenger transport activity from previous-year activity using mode-specific
*' drivers. Passenger cars respond to the change in car ownership per capita and GDP per
*' capita (fixed elasticity 0.2); the passenger-car fuel-price terms are commented out.
*' Passenger aviation responds to GDP per capita, population (elasticity 0.4), and current
*' and lagged fuel prices. Other passenger modes respond to GDP per capita, current and
*' lagged fuel prices, car stock and car activity, distributed price lags adjusted by
*' imCGI, and population (elasticity 0.4).
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE) $runCy(allCy))..
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)
              =E=
      (  !! passenger cars
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        !!(VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"b1",YTIME) *
        !!(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"b2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)/(i01Pop(YTIME,allCy)*1000))/(V01PcOwnPcLevl(allCy,YTIME-1))]**imElastA(allCy,TRANSE,"b3",YTIME) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)] ** 0.2 !!imElastA(allCy,TRANSE,"b4",YTIME)
      )$sameas(TRANSE,"PC") +
      (  !! passenger aviation
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)] ** imElastA(allCy,TRANSE,"a",YTIME) *
        [i01Pop(YTIME,allCy) / i01Pop(YTIME-1,allCy)] ** 0.4 *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
      )$sameas(TRANSE,"PA") +
      (   !! other passenger transportation modes
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)*V01ActivPassTrnsp(allCy,"PC",YTIME))/(V01StockPcYearly(allCy,YTIME-1)*V01ActivPassTrnsp(allCy,"PC",YTIME-1))]**imElastA(allCy,TRANSE,"c4",YTIME) *
        prod(kpdl,
          [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
            VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
            (imCGI(allCy,YTIME)**(1/6))
          ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        ) *
        [i01Pop(YTIME,allCy) / i01Pop(YTIME-1,allCy)] ** 0.4
      )$(TRANP(TRANSE) and not (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' Calculates the number of passenger cars scrapped in the current year by summing
*' previous-year technology-specific vehicle stocks multiplied by their corresponding
*' total scrapping rates.
Q01NumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NumPcScrap(allCy,YTIME)
            =E=
    SUM(TTECH,
      V01RateScrPcTot(allCy,"PC",TTECH,YTIME) * 
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1)
    );

*' Estimates passenger-car ownership per capita as a Gompertz function of GDP per capita.
*' The saturation parameter sets the upper asymptote, while the two sigma parameters
*' control the income response and curvature.
Q01PcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01PcOwnPcLevl(allCy,YTIME)
          =E=
    i01PassCarsMarkSat(allCy) *
    EXP(
      -i01Sigma(allCy,"S1") *
      EXP(-i01Sigma(allCy,"S2") * i01GDPperCapita(YTIME,allCy) / 10000)
    );

*' Combines normal retirement and premature scrapping into a total technology-specific
*' scrapping rate. Normal retirement is represented by the inverse of technology lifetime,
*' and premature scrapping applies to the remaining stock.
Q01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 - (1 - 1 / i01TechLft(allCy,TRANSE,TTECH,YTIME)) *
    (1 - V01PremScrp(allCy,TRANSE,TTECH,YTIME));

*' Calculates the premature-scrapping fraction using the inverse of the technology’s
*' previous-year fuel cost relative to that cost term plus a weighted sum of inverse
*' previous-year costs of alternative technologies in the same subsector. The weighting
*' includes the premature-scrapping calibration factor and a coefficient of 0.01.
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
    V01PremScrp(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 -
    (V01CostFuel(allCy,TRANSE,TTECH,YTIME-1)) ** (-1) /
    (
      V01CostFuel(allCy,TRANSE,TTECH,YTIME-1) ** (-1) +
      0.01*i01PremScrpFac(allCy,TRANSE,TTECH,YTIME) * 
      SUM(TTECH2$(not sameas(TTECH2,TTECH) and SECTTECH(TRANSE,TTECH2)),
        V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME-1) ** (-1)
      )
    );

*' Determines the share of a fuel in an eligible blending group using calibrated
*' inverse-square weights of previous-year final fuel prices plus carbon prices. A small
*' positive constant (1e-6) is added to each price before weighting; shares are normalized
*' across fuels connected by the blending mappings.
Q01ShareBlend(allCy,TRANSE,EFS,YTIME)$(TIME(YTIME)$SECtoEF(TRANSE,EFS)$runCy(allCy) and yes$SUM(EFS2,BLENDMAP(EFS2,EFS)))..
    V01ShareBlend(allCy,TRANSE,EFS,YTIME)
      =E=
    i01calibweibul(allCy,TRANSE,EFS,YTIME) * (VmPriceFinal(allCy,TRANSE,EFS,YTIME-1) + VmPriceCarbon(allCy,TRANSE,EFS,YTIME-1) + 1e-6) ** (-2) /
    SUM(EFS2$(BLENDMAP(EFS,EFS2) or BLENDMAP2(EFS,EFS2)),
      i01calibweibul(allCy,TRANSE,EFS2,YTIME) * (VmPriceFinal(allCy,TRANSE,EFS2,YTIME-1) + VmPriceCarbon(allCy,TRANSE,EFS2,YTIME-1) + 1e-6) ** (-2)
    );

$ontext
    (
      i01calibweibul(allCy,TRANSE,TTECH,EF) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-1) ** (-2) /
      SUM(EF2$TTECHtoEF(TTECH,EF2),i01calibweibul(allCy,TRANSE,TTECH,EF2) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF2,YTIME-1) ** (-2))
    )$(not PLUGIN(TTECH)) +
    (
      i01calibweibul(allCy,TRANSE,TTECH,EF) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-1) ** (-2) /
      SUM(EF2$(TTECHtoEF(TTECH,EF2) and not sameas("ELC",EF2)),i01calibweibul(allCy,TRANSE,TTECH,EF2) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF2,YTIME-1) ** (-2))
    )$(PLUGIN(TTECH) and not sameas("ELC",EF));
$offtext
    

$ontext
Q01ShareBioBlend(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
      V01ShareBioBlend(allCy,TRANSE,EF,YTIME)
      =E=
    (
      0.8 / (1 + exp(i01calb(allCy,TRANSE,EF) + 2 * log(VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME) / SUM(EF2$(BioToFossilFuel(EF,EF2)), VmPriceFuelSubsecCarVal(allCy,TRANSE,EF2,YTIME)))))
    )$BIOFUELS(EF) +
    SUM(EF2$(BioToFossilFuel(EF2,EF)),
      1 - 0.8 / (1 + exp(i01calb(allCy,TRANSE,EF2) + 2 * log(VmPriceFuelSubsecCarVal(allCy,TRANSE,EF2,YTIME) / VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME))))
    );
$offtext

*' Aggregates fuel consumption across transport technologies from installed capacity,
*' specific fuel consumption and fuel-blending shares, with a 1/1000 conversion factor.
*' Non-plug-in passenger-car consumption is additionally scaled by passenger-car activity.
*' Plug-in hybrid consumption is separated into electric and non-electric mileage using
*' the annual electric-mileage share.
Q01ConsFuelTransport(allCy,TRANSE,EFS,YTIME)$(TIME(YTIME) $SECtoEF(TRANSE,EFS) $runCy(allCy))..
    V01ConsFuelTransport(allCy,TRANSE,EFS,YTIME)
        =E=
    SUM(TTECH$(TTECHtoEF(TTECH,EFS) and SECTTECH(TRANSE,TTECH) and not PLUGIN(TTECH)),
      V01CapacityTransport(allCy,TRANSE,TTECH,YTIME) * !![pkm] mvh
      V01ShareBlend(allCy,TRANSE,EFS,YTIME) *
      V01ConsSpecificFuel(allCy,TRANSE,TTECH,EFS,YTIME) / 1000 *!!Ktoe / pkm   ktoe/km
      (1$(not sameas(TRANSE,"PC")) + V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC")) !!km/vh
    ) +
    SUM(PLUGIN$(TTECHtoEF(PLUGIN,EFS) and SECTTECH(TRANSE,PLUGIN)),
      (
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01CapacityTransport(allCy,TRANSE,PLUGIN,YTIME) * !![pkm] mvh
        V01ConsSpecificFuel(allCy,TRANSE,PLUGIN,EFS,YTIME) / 1000
      )$sameas("ELC",EFS) +
      (
        (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
        V01ShareBlend(allCy,TRANSE,EFS,YTIME) *
        V01CapacityTransport(allCy,TRANSE,PLUGIN,YTIME) * !![pkm] mvh
        V01ConsSpecificFuel(allCy,TRANSE,PLUGIN,EFS,YTIME) / 1000
      )$(not sameas("ELC",EFS))
    );

*' Updates transport capacity for each technology as surviving previous-year capacity
*' after scrapping plus newly added capacity. New capacity equals the technology’s modeled
*' share multiplied by the subsector transport-activity gap.
Q01CapacityTransport(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
  V01CapacityTransport(allCy,TRANSE,TTECH,YTIME)
      =E=
  V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * (1 - V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)) +
  V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *  V01GapTranspActiv(allCy,TRANSE,YTIME);
