*' @title Equations of OPEN-PROMs Transport
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Transport

Q01TransportActivity(allCy,TRANSE,YTIME)$(TIME(YTIME)$runCy(allCy))..
      V01TransportActivity(allCy,TRANSE,YTIME)
              =E=
      (
       V01PcOwnPcLevl(allCy,YTIME) * (i01Pop(YTIME,allCy) * 1000)
      )$sameas(TRANSE,"PC") +
      (
        V01TransportActivity(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)] ** imElastA(allCy,TRANSE,"a",YTIME) *
        [i01Pop(YTIME,allCy) / i01Pop(YTIME-1,allCy)] ** 0.4 *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
      )$sameas(TRANSE,"PA") +
      (
        V01TransportActivity(allCy,TRANSE,YTIME-1) *
        [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        [(V01TransportActivity(allCy,"PC",YTIME)*imTransChar(allCy,"KM_VEH","%fBaseY%"))/(V01TransportActivity(allCy,"PC",YTIME-1)*imTransChar(allCy,"KM_VEH","%fBaseY%"))]**imElastA(allCy,TRANSE,"c4",YTIME) *
        prod(kpdl,
          [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
            VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
            (imCGI(allCy,YTIME)**(1/6))
          ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        ) *
        [i01Pop(YTIME,allCy) / i01Pop(YTIME-1,allCy)] ** 0.4
      )$(TRANP(TRANSE) and NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA"))) +
      (
        V01TransportActivity(allCy,TRANSE,YTIME-1)
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
        V01TransportActivity(allCy,TRANSE,YTIME-1) *
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
          (V01TransportActivity(allCy,"GU",YTIME) + 1e-6) / 
          (V01TransportActivity(allCy,"GU",YTIME-1) + 1e-6)
        ) ** imElastA(allCy,TRANSE,"c4",YTIME)
      )$(TRANG(TRANSE) and not sameas(TRANSE,"GU"));  

*' This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
*' The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
*' various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
*' different types of transportation modes.
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01GapTranspActiv(allCy,TRANSE,YTIME)
            =E=
    ( 
      V01TransportActivity(allCy,TRANSE,YTIME) - 
      V01TransportActivity(allCy,TRANSE,YTIME-1) + 
      SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)) +
      SQRT(SQR(
        V01TransportActivity(allCy,TRANSE,YTIME) - 
        V01TransportActivity(allCy,TRANSE,YTIME-1) + 
        SUM(TTECH$SECTTECH(TRANSE,TTECH),V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME))
      )) 
    )/2;

*' This equation computes the annualized capital cost of new transport technologies by converting upfront investment costs 
*' into equivalent annual payments. It applies the annuity factor to spread the capital cost over the technology’s lifetime.
*' It also includes state subsidy, as the amount that is purposed to each technology, except if a low cost bound is reached.
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
          =E=
    (
      (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
      /
      (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
    ) * (imCapCostTech(allCy,TRANSE,TTECH,YTIME) - VmSubsiDemTech(allCy,TRANSE,TTECH,YTIME)) *
    imCGI(allCy,YTIME);

* -----------------------------------------------------------------------------
* Q01CostFuel: Calculates the total fuel cost for transport technologies.
* 
* This equation includes:
* - Specific Fuel consumption multiplied by fuel prices for each fuel type (EF).
* - Special handling for plug-in hybrid technologies:
*     - Non-electric portion weighted by (1 - share of electric mileage).
*     - Electric portion weighted by share of electric mileage.
* - Additional variable costs specific to the technology.
* - Renewable value adjustment for non-renewable technologies.
* 
* The total cost is scaled by:
* - Transport activity (in 1000 vehicle-km) for passenger cars.
* - Annual consumption (Gpkm/Gtkm per transport unit) for other transport modes.
* -----------------------------------------------------------------------------
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CostFuel(allCy,TRANSE,TTECH,YTIME)
        =E=
    (
      (
        sum(EF$TTECHtoEF(TTECH,EF),
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) * 
          V01ShareBlend(allCy,TRANSE,EF,YTIME) *
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) 
      )$(not PLUGIN(TTECH)) +
      (
        sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) * 
          V01ShareBlend(allCy,TRANSE,EF,YTIME) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) * !! ktoe / Activity
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME) *
        VmPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
      )$PLUGIN(TTECH) +
      imVarCostTech(allCy,TRANSE,TTECH,YTIME)
    ) *
    (
      1$(not sameas(TRANSE,"PC")) +
      1e-3 * imTransChar(allCy,"KM_VEH","%fBaseY%")$sameas(TRANSE,"PC")
    );

* -----------------------------------------------------------------------------
* Q01CostTranspPerMeanConsSize: Calculates the total cost per transport unit.
*
* This equation sums up the following cost components for each transport 
* technology and year:
* - Annualized capital cost (V01CapCostAnnualized)
* - Fixed operation and maintenance cost (imFixOMCostTech)
* - Fuel cost (V01CostFuel)
*
* The result represents the total cost per mean consumption size:
* - In k$US2015 per vehicle for passenger cars
* - In k$US2015 per Gpkm or Gtkm for other transport modes
* -----------------------------------------------------------------------------
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$runCy(allCy)$SECTTECH(TRANSE,TTECH))..
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)
        =E=
      V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME) +
      imFixOMCostTech(allCy,TRANSE,TTECH,YTIME) +
      V01CostFuel(allCy,TRANSE,TTECH,YTIME);

* -------------------------------------------------------------------------------
* Q01ShareTechTr: Calculates the share of each transport technology in total sectoral use.
*
* Key components:
* - imMatrFactor: Maturity factor of the technology, representing readiness or adoption potential.
* - V01CostTranspPerMeanConsSize: Transportation cost per mean consumer size, reflecting cost efficiency.
*
* Result:
* - V01ShareTechTr: Dimensionless value representing the share of each technology in total sectoral use.
* -------------------------------------------------------------------------------
Q01ShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01ShareTechTr(allCy,TRANSE,TTECH,YTIME)
      =E=
    imMatrFactor(allCy,TRANSE,TTECH,YTIME) *
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME-1) ** (-2) /
    sum(TTECH2$SECTTECH(TRANSE,TTECH2), 
      imMatrFactor(allCy,TRANSE,TTECH2,YTIME) * 
      V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME-1) ** (-2)
    );

* This equation computes the new registrations of passenger cars per technology for each country. 
Q01NewRegPcTechYearly(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NewRegPcTechYearly(allCy,TTECH,YTIME)
        =E=
    V01ShareTechTr(allCy,"PC",TTECH,YTIME) *
    V01GapTranspActiv(allCy,"PC",YTIME);

*' This equation estimates vehicle ownership per capita for each country and year.
*' It applies the Gompertz function to model how car ownership evolves in relation to GDP per capita.
*' The formulation includes parameters that introduce a saturation effect, ensuring the model reflects
*' an upper limit (asymptote) of car ownership as income levels rise.
Q01PcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01PcOwnPcLevl(allCy,YTIME)
          =E=
    i01PassCarsMarkSat(allCy) *
    EXP(
      -i01Sigma(allCy,"S1") *
      EXP(-i01Sigma(allCy,"S2") * i01GDPperCapita(YTIME,allCy) / 10000)
    );

Q01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 - (1 - 1 / i01TechLft(allCy,TRANSE,TTECH,YTIME)) *
    (1 - V01PremScrp(allCy,TRANSE,TTECH,YTIME));
    
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
    V01PremScrp(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 -
    (V01CostFuel(allCy,TRANSE,TTECH,YTIME-1)) ** (-2) /
    (
      V01CostFuel(allCy,TRANSE,TTECH,YTIME-1) ** (-2) +
      0.05*i01PremScrpFac(allCy,TRANSE,TTECH,YTIME) * 
      SUM(TTECH2$(not sameas(TTECH2,TTECH) and SECTTECH(TRANSE,TTECH2)),
        V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME-1) ** (-2)
      )
    );

Q01ShareBlend(allCy,TRANSE,EF,YTIME)$(TIME(YTIME)$SECtoEF(TRANSE,EF)$runCy(allCy) and yes$SUM(EF2,BLENDMAP(EF2,EF)))..
    V01ShareBlend(allCy,TRANSE,EF,YTIME)
      =E=
    i01calibweibul(allCy,TRANSE,EF,YTIME) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-1) ** (-2) /
    SUM(EF2$(BLENDMAP(EF,EF2) or BLENDMAP2(EF,EF2)),
      i01calibweibul(allCy,TRANSE,EF2,YTIME) * VmPriceFuelSubsecCarVal(allCy,TRANSE,EF2,YTIME-1) ** (-2)
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


Q01ConsFuelTransport(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECtoEF(TRANSE,EF) $runCy(allCy))..
    V01ConsFuelTransport(allCy,TRANSE,EF,YTIME)
        =E=
    SUM(TTECH$(TTECHtoEF(TTECH,EF) and SECTTECH(TRANSE,TTECH) and not PLUGIN(TTECH)),
      V01CapacityTransport(allCy,TRANSE,TTECH,YTIME) * !![pkm] mvh
      V01ShareBlend(allCy,TRANSE,EF,YTIME) *
      V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) / 1000 *!!Ktoe / pkm   ktoe/km
      (1$(not sameas(TRANSE,"PC")) + imTransChar(allCy,"KM_VEH",YTIME)$sameas(TRANSE,"PC")) !!km/vh
    ) +
    SUM(PLUGIN$(TTECHtoEF(PLUGIN,EF) and SECTTECH(TRANSE,PLUGIN)),
      (
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01CapacityTransport(allCy,TRANSE,PLUGIN,YTIME) * !![pkm] mvh
        V01ConsSpecificFuel(allCy,TRANSE,PLUGIN,EF,YTIME) / 1000
      )$sameas("ELC",EF) +
      (
        (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
        V01ShareBlend(allCy,TRANSE,EF,YTIME) *
        V01CapacityTransport(allCy,TRANSE,PLUGIN,YTIME) * !![pkm] mvh
        V01ConsSpecificFuel(allCy,TRANSE,PLUGIN,EF,YTIME) / 1000
      )$(not sameas("ELC",EF))
    );

Q01CapacityTransport(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
  V01CapacityTransport(allCy,TRANSE,TTECH,YTIME)
      =E=
  V01CapacityTransport(allCy,TRANSE,TTECH,YTIME-1) * (1 - V01RateScrPcTot(allCy,TRANSE,TTECH,YTIME)) +
  V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *  V01GapTranspActiv(allCy,TRANSE,YTIME);