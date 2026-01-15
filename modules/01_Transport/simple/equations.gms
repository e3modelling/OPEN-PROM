*' @title Equations of OPEN-PROMs Transport
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Transport

*' This equation calculates the lifetime of passenger cars as the inverse of their scrapping rate.
Q01Lft(allCy,"PC",TTECH,YTIME)$(TIME(YTIME) $SECTTECH("PC",TTECH) $runCy(allCy))..
    VmLft(allCy,"PC",TTECH,YTIME)
        =E=
    1 / V01RateScrPc(allCy,TTECH,YTIME);

*' This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
*' The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
*' freight transport modes.
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE) $runCy(allCy))..
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
      )$sameas(TRANSE,"GU") +      !!trucks
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
      )$(not sameas(TRANSE,"GU"));        !!other freight transport

*' This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
*' The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
*' various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
*' different types of transportation modes.
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01GapTranspActiv(allCy,TRANSE,YTIME)
            =E=
    V01NewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC") +
    (
      ( 
        [
          V01ActivPassTrnsp(allCy,TRANSE,YTIME) - 
          V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + 
          V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) /
          (sum((TTECH)$SECTTECH(TRANSE,TTECH), VmLft(allCy,TRANSE,TTECH,YTIME-1)) / TECHS(TRANSE))
        ] +
        SQRT( SQR([V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
        (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) 
      )/2
    )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC"))) +
    (
      ( 
        [
          V01ActivGoodsTransp(allCy,TRANSE,YTIME) - 
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + 
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) /
          (sum(TTECH$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))
        ] + 
        SQRT( SQR([V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
        (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) 
      )/2
    )$TRANG(TRANSE);

*' This equation computes the annualized capital cost of new transport technologies by converting upfront investment costs 
*' into equivalent annual payments. It applies the annuity factor to spread the capital cost over the technology’s lifetime.
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
          =E=
    (
      (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
      /
      (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
    ) * imCapCostTech(allCy,TRANSE,TTECH,YTIME) * imCGI(allCy,YTIME);

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
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) 
      )$(not PLUGIN(TTECH)) +
      (
        sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) *
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME) *
        VmPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
      )$PLUGIN(TTECH) +
      imVarCostTech(allCy,TRANSE,TTECH,YTIME) +
      (VmRenValue(YTIME)/1000)$( not RENEF(TTECH)) 
    ) *
    (
      1e-3 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC") + !! aviation should be divided by 1000
      1e-1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PT")) +
      1e3 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PB")) +
      1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PN")) +
      1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PA")) +
      1e-5 * V01ActivGoodsTransp(allCy,TRANSE,YTIME)$TRANG(TRANSE)  !! should be divided by number of vehicles
      !!imAnnCons(allCy,TRANSE,"modal")$(not sameas(TRANSE,"PC"))
    )
    ;

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
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME-1)**(-3) /
    sum(TTECH2$SECTTECH(TRANSE,TTECH2), 
      imMatrFactor(allCy,TRANSE,TTECH2,YTIME) * 
      V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME-1)**(-3)
    );

*' This equation calculates the consumption of each technology in transport sectors. It considers various factors such as the lifetime of the technology,
*' average capacity per vehicle, load factor, scrapping rate, and specific fuel consumption. The equation also takes into account the technology's variable
*' cost for new equipment and the gap in transport activity to be filled by new technologies. The result is expressed in million tonnes of oil equivalent.
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
            =E=
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME-1) *
    (
      (
        (VmLft(allCy,TRANSE,TTECH,YTIME-1)-1) / 
        VmLft(allCy,TRANSE,TTECH,YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      (
        1 - V01RateScrPcTot(allCy,TTECH,YTIME)
      )$sameas(TRANSE,"PC")
    ) +
    V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *
    (
      (i01ShareTTechFuel(allCy,TRANSE,TTECH,EF) *
      V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME))$(not PLUGIN(TTECH)) +
      ( 
        (
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
          i01ShareTTechFuel(allCy,TRANSE,TTECH,EF) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
        )$(not sameas("ELC",EF)) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)
      )$PLUGIN(TTECH)
    ) / 1000 *
    V01GapTranspActiv(allCy,TRANSE,YTIME) *
    (
      (
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC")
    );

*' This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
*' It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECtoEF(TRANSE,EF) $runCy(allCy))..
    VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
            =E=
    sum(TTECH$(SECTTECH(TRANSE,TTECH) and TTECHtoEF(TTECH,EF)),
      V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
    );

* -----------------------------------------------------------------------------
* Q01StockPcYearly: Computes the total stock of passenger cars (in millions).
*
* This equation estimates the yearly stock of passenger cars for each country 
* and year by applying a per-capita ownership level to the total population.
* -----------------------------------------------------------------------------
Q01StockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearly(allCy,YTIME)
            =E=
      V01PcOwnPcLevl(allCy,YTIME) * 
      (i01Pop(YTIME,allCy) * 1000);

Q01StockPcYearlyTech(allCy,TTECH,YTIME)$(TIME(YTIME)$runCy(allCy)$SECTTECH("PC",TTECH))..
      V01StockPcYearlyTech(allCy,TTECH,YTIME)
            =E=
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1) * 
      (1 - V01RateScrPcTot(allCy,TTECH,YTIME)) +
      V01ShareTechTr(allCy,"PC",TTECH,YTIME) *
      V01GapTranspActiv(allCy,"PC",YTIME);

*' This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
*' The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
Q01NewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V01NewRegPcYearly(allCy,YTIME)
                =E=
        V01StockPcYearly(allCy,YTIME) - 
        V01StockPcYearly(allCy,YTIME-1) +
        V01NumPcScrap(allCy,YTIME);     !! new cars due to scrapping

*' This equation calculates the passenger transport activity for various modes of transportation, including passenger cars, aviation, and other passenger transportation modes.
*' The activity is influenced by factors such as fuel prices, GDP per capita, and elasticities specific to each transportation mode. The equation uses past activity levels and
*' price trends to estimate the current year's activity. The coefficients and exponents in the equation represent the sensitivities of activity to changes in various factors.
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE) $runCy(allCy))..
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)
              =E=
      (  !! passenger cars
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"b1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"b2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)/(i01Pop(YTIME,allCy)*1000))/(V01PcOwnPcLevl(allCy,YTIME-1))]**imElastA(allCy,TRANSE,"b3",YTIME) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)] ** 0.2 !!imElastA(allCy,TRANSE,"b4",YTIME)
      )$sameas(TRANSE,"PC") +
      (  !! passenger aviation
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME) *
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
        )
      )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
*' The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
Q01NumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NumPcScrap(allCy,YTIME)
            =E=
    SUM(TTECH,
      V01RateScrPcTot(allCy,TTECH,YTIME) * 
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1)
    );

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

*' This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
*' reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
*' cars scrapping rate over time.
Q01RateScrPc(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH("PC",TTECH))..
    V01RateScrPc(allCy,TTECH,YTIME)
        =E=
    V01RateScrPc(allCy,TTECH,YTIME-1) *
    (
      i01GDPperCapita(YTIME,allCy) /
      i01GDPperCapita(YTIME-1,allCy)
    ) ** 0.1;

Q01RateScrPcTot(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01RateScrPcTot(allCy,TTECH,YTIME)
        =E=
    1 - (1 - V01RateScrPc(allCy,TTECH,YTIME)) *
    (1 - V01PremScrp(allCy,"PC",TTECH,YTIME));
    
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
    V01PremScrp(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 -
    (V01CostFuel(allCy,TRANSE,TTECH,YTIME) + 1e-4) ** (-2) /
    (
      (V01CostFuel(allCy,TRANSE,TTECH,YTIME) + 1e-4) ** (-2) +
      i01PremScrpFac(allCy,TRANSE,TTECH,YTIME) * 
      SUM(TTECH2$(not sameas(TTECH2,TTECH) and SECTTECH(TRANSE,TTECH2)),
        (V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME) + 1e-4) ** (-2)
      )
    );
