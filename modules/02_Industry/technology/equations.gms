*' Calculates substitutable useful energy demand for industry, domestic and non-energy
*' subsectors. Previous-year demand is adjusted by a calibration factor, changes in
*' activity, current and lagged average fuel-price ratios, and a distributed price lag.
*' Activity and price responses are controlled by subsector-specific elasticities.
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$runCy(allCy))..
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME) 
        =E=
    (1 + i02CalibUsefulEnergy(allCy,DSBS,YTIME)) *
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME-1) *
    imActv(YTIME,allCy,DSBS) ** imElastA(allCy,DSBS,"a",YTIME) *
    (VmPriceFuelAvgSub(allCy,DSBS,YTIME)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-1) ) ** imElastA(allCy,DSBS,"b1",YTIME) *
    (VmPriceFuelAvgSub(allCy,DSBS,YTIME-1)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-2) ) ** imElastA(allCy,DSBS,"b2",YTIME) *
    prod(KPDL,
      ((VmPriceFuelAvgSub(allCy,DSBS,YTIME-ord(KPDL))/VmPriceFuelAvgSub(allCy,DSBS,YTIME-(ord(KPDL)+1)))/(imCGI(allCy,YTIME)**(1/6)))**( imElastA(allCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
    )
    
;
*' Calculates the capacity of equipment surviving from the previous year for each
*' subsector and technology. Previous-year installed capacity is multiplied by the
*' remaining-capacity ratio, which accounts for regular and premature retirement.
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and (INDDOM(DSBS) or NENSE(DSBS)))$runCy(allCy))..
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME-1) * 
    V02RatioRem(allCy,DSBS,ITECH,YTIME);

*' Calculates the fraction of technology capacity retained from the previous year. The
*' survival fraction combines retirement implied by the inverse technical lifetime with
*' the premature scrapping fraction.
Q02RatioRem(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and (INDDOM(DSBS) or NENSE(DSBS)))$runCy(allCy))..
    V02RatioRem(allCy,DSBS,ITECH,YTIME) 
        =E=
    (1 - 1/VmLft(allCy,DSBS,ITECH,YTIME)) * 
    (1 - V02PremScrpIndu(allCy,DSBS,ITECH,YTIME));

*' Estimates premature equipment scrapping using the inverse of lagged variable cost
*' adjusted for utilization, compared with the inverse costs of alternative
*' technologies. A technology-specific scaling factor controls the contribution of
*' alternatives; small constants stabilize the ratios.
Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and (INDDOM(DSBS) or NENSE(DSBS)))$runCy(allCy))..
    V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)
        =E=
    1 - (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1) + 1e-3) ** (-1) /
    (
      (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1) + 1e-3) ** (-1) +
      0.01 * i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME) *
      sum(ITECH2$(not sameas(ITECH2,ITECH) and SECTTECH(DSBS,ITECH2)),
          (V02CostTech(allCy,DSBS,ITECH2,YTIME-1) + 1e-3) ** (-1)
      )
    );

*'NEW EQUATION' - kind of --> substitutes Q02ConsRemSubEquipSubSec
* This equation computes the useful energy covered by the remaining equipment
*' Calculates useful energy supplied by surviving equipment in a subsector. Remaining
*' capacity is summed across eligible technologies after multiplying by the
*' useful-energy conversion factor and technology utilization.
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$runCy(allCy))..
    V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) 
        =E=
    SUM(ITECH$SECTTECH(DSBS,ITECH),
      V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    );
*' Calculates the non-negative useful-energy demand gap as the positive part of total
*' substitutable useful-energy demand minus useful energy supplied by surviving
*' equipment. The square-root-of-square expression sets negative gaps to zero.
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS)) $runCy(allCy))..
    V02GapUsefulDemSubsec(allCy,DSBS,YTIME) 
        =E=
    (
      V02DemSubUsefulSubsec(allCy,DSBS,YTIME) -
      V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) +
      SQRT(SQR(V02DemSubUsefulSubsec(allCy,DSBS,YTIME) - V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)))
    )/2
;
*' Calculates annualized capital and fixed operation and maintenance costs per unit of
*' useful energy for each technology. Capital expenditure is annualized using the
*' subsector discount rate and technical lifetime, adjusted by the capital-goods index,
*' and combined with fixed O&M costs before division by the useful-energy conversion
*' factor.
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    (
      imDisc(allCy,DSBS,YTIME) * exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME)) /
      (exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME)) - 1) * 
      imCapCostTech(allCy,DSBS,ITECH,YTIME) * imCGI(allCy,YTIME) +
      imFixOMCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit
    ) / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME)
;
*' Calculates variable cost per unit of useful energy for each technology. Fuel prices
*' are weighted by technology-specific blending shares and supplemented by carbon
*' capture and sequestration costs and charges on uncaptured CO2 emissions. Non-fuel
*' variable O&M costs are added before division by the useful-energy conversion factor.
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
  V02VarCostTech(allCy,DSBS,ITECH,YTIME) 
      =E=
  (
    sum(EF$ITECHtoEF(ITECH,EF), 
      i02ShareBlend(allCy,DSBS,ITECH,EF,YTIME) *
      (
        VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) +
        imCO2CaptRateIndustry(allCy,ITECH,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME)  +
        (1-imCO2CaptRateIndustry(allCy,ITECH,YTIME)) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME)  *
        sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME))
      )
    ) +
    imVarCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME);

*' Calculates the combined technology cost as annualized capital and fixed O&M cost plus
*' variable and fuel-related cost, less the technology demand subsidy.
Q02CostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) +
    V02VarCostTech(allCy,DSBS,ITECH,YTIME) -
    VmSubsiDemTech(allCy,DSBS,ITECH,YTIME)
    ;
*' Allocates new equipment demand across eligible technologies using a normalized
*' cost-based share. Technology maturity weights inverse lagged total costs raised to
*' the subsector substitution elasticity; the denominator sums the same weights over all
*' eligible technologies.
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,ITECH)$(INDDOM(DSBS) or NENSE(DSBS)) $runCy(allCy))..
    V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) 
        =E=
    imMatrFactor(allCy,DSBS,ITECH,YTIME) *
    V02CostTech(allCy,DSBS,ITECH,YTIME-1) ** (-i02ElaSub(allCy,DSBS)) /
    sum(ITECH2$SECTTECH(DSBS,ITECH2),
      imMatrFactor(allCy,DSBS,ITECH2,YTIME) *
      V02CostTech(allCy,DSBS,ITECH2,YTIME-1) ** (-i02ElaSub(allCy,DSBS))
    );
*' Calculates total installed equipment capacity by adding surviving capacity to new
*' capacity. New capacity is derived from the technology share of the useful-energy
*' demand gap, divided by its useful-energy conversion factor and utilization rate.
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and TIME(YTIME) and (INDDOM(DSBS) or NENSE(DSBS)) and runCy(allCy))..
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E= 
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) +
    (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME)) / 
    (imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) * i02util(allCy,DSBS,ITECH,YTIME));
*' Projects non-substitutable useful electricity demand for industry and domestic
*' subsectors. Previous-year demand is scaled by activity growth and current, previous
*' and distributed-lag electricity price changes, using subsector-specific elasticities.
Q02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME) 
        =E=
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME-1) *
    imActv(YTIME,allCy,INDDOM) ** i02ElastNonSubElec(allCy,INDDOM,"a",YTIME) *
    (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1)) ** i02ElastNonSubElec(allCy,INDDOM,"b1",YTIME) *
    (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-2)) ** i02ElastNonSubElec(allCy,INDDOM,"b2",YTIME) *
    prod(KPDL,
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-ord(KPDL)) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))) ** (i02ElastNonSubElec(allCy,INDDOM,"c",YTIME)*imFPDL(INDDOM,KPDL))
    );
*' Converts non-substitutable useful electricity demand into final electricity
*' consumption for eligible industrial and residential/commercial subsectors by dividing
*' by the electricity technology useful-energy conversion factor.
Q02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(TIME(YTIME) and runCy(allCy) and (INDSE(DSBS) or RESCOM(DSBS)))..
    V02FinalElecNonSubIndTert(allCy,DSBS,YTIME) 
        =E=
    V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME) / 
    imUsfEneConvSubTech(allCy,DSBS,"TELC",YTIME);
*' Calculates final fuel consumption for each eligible non-transport subsector and fuel.
*' Technology capacity is multiplied by utilization and fuel blending shares and summed
*' over compatible technologies. Non-substitutable final electricity is additionally
*' included for eligible industry and domestic subsectors, excluding agriculture.
Q02ConsFuel(allCy,DSBS,EFS,YTIME)$(TIME(YTIME)$((INDDOM(DSBS) or NENSE(DSBS)) and SECtoEF(DSBS,EFS))$runCy(allCy))..
    VmConsFuel(allCy,DSBS,EFS,YTIME) 
        =E=
    sum(ITECH$(ITECHtoEF(ITECH,EFS) and SECTTECH(DSBS,ITECH)),
      i02ShareBlend(allCy,DSBS,ITECH,EFS,YTIME) *
      V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    ) +
    V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS) and not sameas("AG",DSBS) and ELCEF(EFS));
*' Calculates the ratio of substitutable useful-energy demand to total final fuel
*' consumption excluding non-substitutable electricity. A small constant is added to the
*' denominator to avoid division by zero.
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)$(TIME(YTIME)$(INDDOM(DSBS) or NENSE(DSBS))$runCy(allCy))..
    V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)
       =E=
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME) /
    (sum(EF$SECtoEF(DSBS,EF),VmConsFuel(allCy,DSBS,EF,YTIME)) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS)) + 1e-3)
    ;
*' Sets the industrial electricity price index for each CHP technology equal to the
*' previous-year industrial electricity price. Earlier price-ratio adjustment terms are
*' commented out and do not affect the equation.
Q02IndxElecIndPrices(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02IndxElecIndPrices(allCy,TCHP,YTIME)
        =E=
    VmPriceElecInd(allCy,TCHP,YTIME-1);
    !!(VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)/VmPriceFuelAvgSub(allCy,"OI",YTIME-1)) ** (-0.01) *
    !!(VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-2)/VmPriceFuelAvgSub(allCy,"OI",YTIME-2)) ** (-0.005) *
    !!(VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-3)/VmPriceFuelAvgSub(allCy,"OI",YTIME-3)) ** (-0.005);

*' Calculates the share of each eligible fuel in a subsector’s total final fuel
*' consumption. The denominator sums consumption plus a small stabilization term across
*' all eligible fuels.
Q02ConsFuelShare(allCy,DSBS,EF,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not CDR(DSBS) and SECtoEF(DSBS,EF))$runCy(allCy))..
    VmConsFuelShare(allCy,DSBS,EF,YTIME) 
        =E=
    VmConsFuel(allCy,DSBS,EF,YTIME) /
    SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME) + 1e-6);


*' Sums final fuel consumption across all eligible energy forms for each non-transport,
*' non-CDR demand subsector.
Q02ConsFuelSum(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not CDR(DSBS))$runCy(allCy))..
    VmConsFuelSum(allCy,DSBS,YTIME) 
        =E=
    SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME));
