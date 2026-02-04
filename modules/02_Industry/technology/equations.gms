*' @title Equations of OPEN-PROMs INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
*' @code

*' GENERAL INFORMATION

*' Industrial and domestic energy demand is divided (TO DO)

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
*' This equation computes the useful energy demand in each demand subsector (excluding TRANSPORT). This demand is potentially "satisfied" by multiple energy forms/fuels (substitutable demand).
*' The equation follows the "typical useful energy demand" format where the main explanatory variables are activity indicators and average "weighted" technology costs.
*' OLD EQUATION: Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME) --> NEW EQUATION:Q02DemUsefulSubsec
*' OLD VARIABLE: VmDemFinSubFuelSubsec(allCy,DSBS,YTIME) --> NEW VARIABLE:VmDemUsefulSubsec
*' Note: To check which cost should be used... (this VmPriceFuelAvgSub or another cost (weighted average per technology))
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME) 
        =E=
    [
      V02DemSubUsefulSubsec(allCy,DSBS,YTIME-1) *
      imActv(YTIME,allCy,DSBS) ** imElastA(allCy,DSBS,"a",YTIME) *
      (VmPriceFuelAvgSub(allCy,DSBS,YTIME)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-1) ) ** imElastA(allCy,DSBS,"b1",YTIME) *
      (VmPriceFuelAvgSub(allCy,DSBS,YTIME-1)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-2) ) ** imElastA(allCy,DSBS,"b2",YTIME) *
      prod(KPDL,
        ((VmPriceFuelAvgSub(allCy,DSBS,YTIME-ord(KPDL))/VmPriceFuelAvgSub(allCy,DSBS,YTIME-(ord(KPDL)+1)))/(imCGI(allCy,YTIME)**(1/6)))**( imElastA(allCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
      )
    ]$imActv(YTIME-1,allCy,DSBS)
;
*'NEW EQUATION'
*' This equation computes the remaining equipment capacity of each technology in each subsector in the beginning of the year YTIME based on the available capacity of the previous year
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME-1) * 
    V02RatioRem(allCy,DSBS,ITECH,YTIME);

Q02RatioRem(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
V02RatioRem(allCy,DSBS,ITECH,YTIME) 
        =E=
    ( (1 - 1/VmLft(allCy,DSBS,ITECH,YTIME))* (1 - V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)));


Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)
        =E=
    1 - (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1)) ** (-2) /
    (
      (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1)) ** (-2) +
      (
        i02ScaleEndogScrap(DSBS) *
        sum(ITECH2$(not sameas(ITECH2,ITECH) and SECTTECH(DSBS,ITECH2)),
          V02CostTech(allCy,DSBS,ITECH2,YTIME-1) + V02VarCostTech(allCy,DSBS,ITECH2,YTIME-1)
        )
      )**(-2)
    );

*'NEW EQUATION' - kind of --> substitutes Q02ConsRemSubEquipSubSec
* This equation computes the useful energy covered by the remaining equipment
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) 
        =E=
    SUM(ITECH$SECTTECH(DSBS,ITECH),
      V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    );

*' This equation calculates the gap in useful energy demand for industry, tertiary, non-energy uses, and bunkers.
*' It is determined by subtracting the useful energy demand that can be satisfied by existing equipment from the total useful 
*' energy demand per subsector. The square root term is included to ensure a non-negative result - if the result of the 
*' the subtraction is negative, the gap will take a zero value.
*' OLD EQUATION: Q02GapFinalDem(allCy,DSBS,YTIME) --> NEW EQUATION:Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)
*' OLD VARIABLE: V02GapFinalDem(allCy,DSBS,YTIME) --> NEW VARIABLE:V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC")) $runCy(allCy))..
    V02GapUsefulDemSubsec(allCy,DSBS,YTIME) 
        =E=
    (
      V02DemSubUsefulSubsec(allCy,DSBS,YTIME) -
      V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) +
      SQRT(SQR(V02DemSubUsefulSubsec(allCy,DSBS,YTIME) - V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)))
    )/2 + 1e-6
;

*' The equation computes the capital cost and fixed O&M cost of each technology in each subsector
*' OLD EQUATION: Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW EQUATION:Q02CapCostTech(allCy,DSBS,rCon,EF,YTIME)
*' OLD VARIABLE: V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW VARIABLE:V02CapCostTech(allCy,DSBS,rCon,EF,YTIME)
*' Add parameter sUnitToKUnit = 1000
*' Check ITECH and CHPs
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    (
        (
            (
                (imDisc(allCy,DSBS,YTIME) * !! in case of chp plants we use the discount rate of power generation sector
                    exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME))
                ) /
                (exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME)) - 1)
            ) *
            imCapCostTech(allCy,DSBS,ITECH,YTIME) * imCGI(allCy,YTIME) +
            imFixOMCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit
        ) / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME)
    )
;

*' The equation computes the variable cost (variable + fuel) of each technology in each subsector - to check about consumer sizes
*' OLD EQUATION: Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW EQUATION:Q02VarCostTech(allCy,DSBS,rCon,ITECH,YTIME)
*' OLD VARIABLE: V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW VARIABLE:V02VarCostTech(allCy,DSBS,rCon,ITECH,YTIME)
*' NEW SET TECHEF
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
  V02VarCostTech(allCy,DSBS,ITECH,YTIME) 
      =E=
  (
    sum(EF$ITECHtoEF(ITECH,EF), 
      i02Share(allCy,DSBS,ITECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) +
      imCO2CaptRateIndustry(allCy,ITECH,YTIME) * VmCstCO2SeqCsts(allCy,YTIME-1) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME-1)  +
      (1-imCO2CaptRateIndustry(allCy,ITECH,YTIME)) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME-1)  *
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME))) +
      (VmRenValue(YTIME)/1000)$(not RENEF(ITECH) and not NENSE(DSBS)) !! needs change of units
    ) +
    imVarCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME);

Q02CostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) +
    V02VarCostTech(allCy,DSBS,ITECH,YTIME) -
    VmSubsiDemTech(allCy,DSBS,ITECH,YTIME);

*' This equation calculates the technology share in new equipment based on factors such as maturity factor,
*' cumulative distribution function of consumer size groups, number of consumers, technology cost, distribution function of consumer
*' size groups, and technology sorting.
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,ITECH) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC")) $runCy(allCy))..
    V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) 
        =E=
    imMatrFactor(allCy,DSBS,ITECH,YTIME) *
    V02CostTech(allCy,DSBS,ITECH,YTIME-1) ** (-i02ElaSub(allCy,DSBS)) /
    sum(ITECH2$SECTTECH(DSBS,ITECH2),
      imMatrFactor(allCy,DSBS,ITECH2,YTIME) *
      V02CostTech(allCy,DSBS,ITECH2,YTIME-1) ** (-i02ElaSub(allCy,DSBS))
    );

*' This equation computes the equipment capacity of each technology in each subsector
*'Check if Tech exists in main.gms
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and TIME(YTIME)and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and runCy(allCy))..
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E= 
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) +
    (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME)) / 
    (imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) * i02util(allCy,DSBS,ITECH,YTIME));
        
*' This equation computes the consumption/demand of non-substitutable electricity for subsectors of INDUSTRY and DOMESTIC in the "typical useful energy demand equation".
*' The main explanatory variables are activity indicators of each subsector and electricity prices per subsector. Corresponding elasticities are applied for activity indicators
*' and electricity prices.
*' OLD EQUATION: Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW EQUATION:Q02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)
*' OLD VARIABLE: VmConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW VARIABLE:V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)

Q02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME) 
        =E=
    [
      V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME-1) *
      imActv(YTIME,allCy,INDDOM) ** i02ElastNonSubElec(allCy,INDDOM,"a",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1)) ** i02ElastNonSubElec(allCy,INDDOM,"b1",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-2)) ** i02ElastNonSubElec(allCy,INDDOM,"b2",YTIME) *
      prod(KPDL,
        (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-ord(KPDL)) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))) ** (i02ElastNonSubElec(allCy,INDDOM,"c",YTIME)*imFPDL(INDDOM,KPDL))
      )
    ]$imActv(YTIME-1,allCy,INDDOM);

*' NEW EQUATION - Useful Electricity to Final Electricity (Check if needed to add equipment of electricity)
Q02FinalElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02FinalElecNonSubIndTert(allCy,INDDOM,YTIME) 
        =E=
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME) / 
    imUsfEneConvSubTech(allCy,INDDOM,"TELC",YTIME)
    ;

*' This equation calculates the consumption of fuels in each demand subsector.
*' It considers the consumption of remaining substitutable equipment, the technology share in new equipment, and the final demand
*' gap to be filled by new technologies. Additionally, non-substitutable electricity consumption in Industry and Tertiary sectors is included.
*' OLD EQUATION: Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME) --> NEW EQUATION:Q02ConsFuelIncl(allCy,DSBS,EF,YTIME)

*' OLD VARIABLE: VmConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW VARIABLE:VmUsefulElecNonSubIndTert(allCy,DSBS,YTIME)
Q02ConsFuel(allCy,DSBS,EF,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    VmConsFuel(allCy,DSBS,EF,YTIME) 
        =E=
    sum(ITECH$(ITECHtoEF(ITECH,EF)$SECTTECH(DSBS,ITECH)),
      i02Share(allCy,DSBS,ITECH,EF,YTIME) *
      V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    ) +
    V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS) and ELCEF(EF)) +
    VmElecConsHeatPla(allCy,DSBS,YTIME)$ELCEF(EF);

*' Average efficiency of substitutable demand
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)
       =E=
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME)   
    /
    (sum(EF$SECtoEF(DSBS,EF),VmConsFuel(allCy,DSBS,EF,YTIME)) - (V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS)) +
    VmElecConsHeatPla(allCy,DSBS,YTIME)))
    ;

*' This equation calculates the estimated electricity index of the industry price for a given year. The estimated index is derived by considering the historical
*' trend of the electricity index, with a focus on the fuel prices in the industrial subsector. The equation utilizes the fuel prices for electricity generation,
*' both in the current and past years, and computes a weighted average based on the historical pattern. The estimated electricity index is influenced by the ratio
*' of fuel prices in the current and previous years, with a power of 0.3 applied to each ratio. This weighting factor introduces a gradual adjustment to reflect the
*' historical changes in fuel prices, providing a more dynamic estimation of the electricity index. This equation provides a method to estimate the electricity index
*' based on historical fuel price trends, allowing for a more flexible and responsive representation of industry price dynamics.
Q02IndxElecIndPrices(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02IndxElecIndPrices(allCy,YTIME)
        =E=
    VmPriceElecInd(allCy,YTIME-1) * 
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)/VmPriceFuelAvgSub(allCy,"OI",YTIME-1)) ** (0.02) *
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-2)/VmPriceFuelAvgSub(allCy,"OI",YTIME-2)) ** (0.01) *
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-3)/VmPriceFuelAvgSub(allCy,"OI",YTIME-3)) ** (0.01);
