*' @title Equations of OPEN-PROMs Transport
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Transport

*' This equation calculates the lifetime of passenger cars based on the scrapping rate of passenger cars. The lifetime is inversely proportional to the scrapping rate,
*' meaning that as the scrapping rate increases, the lifetime of passenger cars decreases.
Q01Lft(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $sameas(DSBS,"PC") $SECTTECH(DSBS,EF) $runCy(allCy))..
         VmLft(allCy,DSBS,EF,YTIME)
                 =E=
         1/V01RateScrPc(allCy,YTIME);

*' This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
*' The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
*' freight transport modes.
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE) $runCy(allCy))..
         V01ActivGoodsTransp(allCy,TRANSE,YTIME)
                 =E=
         (
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)
           * [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME)
           * (i01Pop(YTIME,allCy)/i01Pop(YTIME-1,allCy))
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME)
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
                 )
         )$sameas(TRANSE,"GU")        !!trucks
         +
         (
           V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)
           * [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME)
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME)
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
                 )
           * (V01ActivGoodsTransp(allCy,"GU",YTIME)/V01ActivGoodsTransp(allCy,"GU",YTIME-1))**imElastA(allCy,TRANSE,"c4",YTIME)
         )$(not sameas(TRANSE,"GU"));                      !!other freight transport

*' This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
*' The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
*' various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
*' different types of transportation modes.
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01GapTranspActiv(allCy,TRANSE,YTIME)
                 =E=
         V01NewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC")
         +
         (
         ( [V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
         (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] +
          SQRT( SQR([V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
          (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
         +
         (
         ( [V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
         (sum((EF)$SECTTECH(TRANSE,EF),VmLft(allCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
          (sum((EF)$SECTTECH(TRANSE,EF),VmLft(allCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$TRANG(TRANSE);

*' This equation calculates the specific fuel consumption for a given technology, subsector, energy form, and time. The specific fuel consumption depends on various factors,
*' including fuel prices and elasticities. The equation involves a product term over a set of Polynomial Distribution Lags and considers the elasticity of fuel prices.
Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
         V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
                 =E=
         V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME-1) * prod(KPDL,
                     (
                        VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-ord(KPDL))/VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
                      )**(imElastA(allCy,TRANSE,"c5",YTIME)*imFPDL(TRANSE,KPDL))
          );

*' This equation calculates the transportation cost per mean and consumer size in kEuro per vehicle. It involves several terms, including capital costs,
*' variable costs, and fuel costs. The equation considers different technologies and their associated costs, as well as factors like the discount rate,
*' specific fuel consumption, and annual .
Q01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)
         =E=
                       (
                         (
                           (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
                           /
                           (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
                         ) * imCapCostTech(allCy,TRANSE,TTECH,YTIME)  * imCGI(allCy,YTIME)
                         + imFixOMCostTech(allCy,TRANSE,TTECH,YTIME)  +
                         (
                           (sum(EF$TTECHtoEF(TTECH,EF),V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
                           +
                           (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),

                              (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME))*V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME))
                             + i01ShareAnnMilePlugInHybrid(allCy,YTIME)*V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
                           )$PLUGIN(TTECH)

                           + imVarCostTech(allCy,TRANSE,TTECH,YTIME)
                           + (VmRenValue(YTIME)/1000)$( not RENEF(TTECH))
                         )
                         *  imAnnCons(allCy,TRANSE,"smallest") * (imAnnCons(allCy,TRANSE,"largest")/imAnnCons(allCy,TRANSE,"smallest"))**((ord(Rcon)-1)/imNcon(TRANSE))
                       );

*' This equation calculates the transportation cost per mean and consumer size. It involves taking the inverse fourth power of the
*' variable representing the transportation cost per mean and consumer size.
Q01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)
         =E=
         V01CostTranspPerMeanConsSize(allCy,TRANSE,rCon,TTECH,YTIME)**(-1);

*' This equation calculates the transportation cost, including the maturity factor. It involves multiplying the maturity factor for a specific technology
*' and subsector by the transportation cost per vehicle for the mean and consumer size. The result is a variable representing the transportation cost,
*' including the maturity factor.
Q01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME) 
         =E=
         imMatrFactor(allCy,TRANSE,TTECH,YTIME) * V01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME);

*' This equation calculates the technology sorting based on variable cost. It involves the summation of transportation costs, including the maturity factor,
*' for each technology and subsector. The result is a variable representing the technology sorting based on variable cost.
Q01TechSortVarCost(allCy,TRANSE,rCon,YTIME)$(TIME(YTIME) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01TechSortVarCost(allCy,TRANSE,rCon,YTIME)
                 =E=
         sum((TTECH)$SECTTECH(TRANSE,TTECH), V01CostTranspMatFac(allCy,TRANSE,rCon,TTECH,YTIME));

*' This equation calculates the share of each technology in the total sectoral use. It takes into account factors such as the maturity factor,
*' cumulative distribution function of consumer size groups, transportation cost per mean and consumer size, distribution function of consumer
*' size groups, and technology sorting based on variable cost. The result is a dimensionless value representing the share of each technology in the total sectoral use.
Q01ShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
         V01ShareTechTr(allCy,TRANSE,TTECH,YTIME)
         =E=
         imMatrFactor(allCy,TRANSE,TTECH,YTIME) / imCumDistrFuncConsSize(allCy,TRANSE)
         * sum( Rcon$(ord(Rcon) le imNcon(TRANSE)+1),
                V01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)
                * imDisFunConSize(allCy,TRANSE,RCon) / V01TechSortVarCost(allCy,TRANSE,RCon,YTIME)
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
                     ((VmLft(allCy,TRANSE,TTECH,YTIME-1)-1)/VmLft(allCy,TRANSE,TTECH,YTIME-1))
                      *(i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1)*i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1))
                      /(i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME)*i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (1 - V01RateScrPc(allCy,YTIME))$sameas(TRANSE,"PC")
         )
         +
         V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *
         (
                 V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(not PLUGIN(TTECH))
                 +
                 ( ((1-i01ShareAnnMilePlugInHybrid(allCy,YTIME))*V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME))$(not sameas("ELC",EF))
                   + i01ShareAnnMilePlugInHybrid(allCy,YTIME)*V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME))$PLUGIN(TTECH)
         )/1000
         * V01GapTranspActiv(allCy,TRANSE,YTIME) *
         (
          (
          (i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1)*i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1))
          / (i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME)*i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME))
          )$(not sameas(TRANSE,"PC"))
          +
          (V01ActivPassTrnsp(allCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
         );

*' This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
*' It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $runCy(allCy))..
         VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
                 =E=
         sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME));

*' This equation calculates the final energy demand in different transport subsectors by summing up the final energy demand for each energy form within
*' each transport subsector. The result is expressed in million tonnes of oil equivalent.
$ontext
q01DemFinEneSubTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $runCy(allCy))..
         v01DemFinEneSubTransp(allCy,TRANSE,YTIME)
                 =E=
         sum(EF,VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME));
$offtext

*' This equation calculates the GDP-dependent market extension of passenger cars. It takes into account transportation characteristics, the GDP-dependent market
*' extension from the previous year, and the ratio of GDP to population for the current and previous years. The elasticity parameter (a) influences the sensitivity
*' of market extension to changes in GDP.
Q01MEPcGdp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01MEPcGdp(allCy,YTIME)
                 =E=
         imTransChar(allCy,"RES_MEXTV",YTIME) * V01MEPcGdp(allCy,YTIME-1) *
         [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy)) / (i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))] ** imElastA(allCy,"PC","a",YTIME);

*' This equation calculates the market extension of passenger cars that is independent of GDP. It involves various parameters such as transportation characteristics,
*' Gompertz function parameters (S1, S2, S3), the ratio of the previous year's stock of passenger cars to the previous year's population, and the saturation ratio .
Q01MEPcNonGdp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01MEPcNonGdp(allCy,YTIME)
                 =E=
         imTransChar(allCy,"RES_MEXTF",YTIME) * i01Sigma(allCy,"S1") * EXP(i01Sigma(allCy,"S2") * EXP(i01Sigma(allCy,"S3") * V01PcOwnPcLevl(allCy,YTIME))) *
         V01StockPcYearly(allCy,YTIME-1) / (i01Pop(YTIME-1,allCy) * 1000);

*' This equation calculates the stock of passenger cars in million vehicles for a given year. The stock is influenced by the previous year's stock,
*' population, and market extension factors, both GDP-dependent and independent.
Q01StockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01StockPcYearly(allCy,YTIME)
                 =E=
         (V01StockPcYearly(allCy,YTIME-1)/(i01Pop(YTIME-1,allCy)*1000) + V01MEPcNonGdp(allCy,YTIME) + V01MEPcGdp(allCy,YTIME)) *
         i01Pop(YTIME,allCy) * 1000;

*' This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
*' The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
Q01NewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01NewRegPcYearly(allCy,YTIME)
                 =E=
         (V01MEPcNonGdp(allCy,YTIME) + V01MEPcGdp(allCy,YTIME)) * (i01Pop(YTIME,allCy)*1000)  !! new cars due to GDP
         - V01StockPcYearly(allCy,YTIME-1)*(1 - i01Pop(YTIME,allCy)/i01Pop(YTIME-1,allCy))    !! new cars due to population
         + V01NumPcScrap(allCy,YTIME);                                                  !! new cars due to scrapping

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
           [(V01StockPcYearly(allCy,YTIME-1)/(i01Pop(YTIME-1,allCy)*1000))/(V01StockPcYearly(allCy,YTIME)/(i01Pop(YTIME,allCy)*1000))]**imElastA(allCy,TRANSE,"b3",YTIME) *
           [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"b4",YTIME)
         )$sameas(TRANSE,"PC") +
         (  !! passenger aviation
            V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
           [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
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
                    (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
                 )
         )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
*' The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
Q01NumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01NumPcScrap(allCy,YTIME)
                 =E=
         V01RateScrPc(allCy,YTIME) * V01StockPcYearly(allCy,YTIME-1);

*' This equation calculates the ratio of car ownership over the saturation car ownership level. The calculation is based on a Gompertz function,
*' taking into account the stock of passenger cars, the population, and the market saturation level from the previous year. This ratio provides
*' an estimate of the level of car ownership relative to the saturation point, considering the dynamics of the market over time.
Q01PcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01PcOwnPcLevl(allCy,YTIME) !! level of saturation of gompertz function
                 =E=
         ( (V01StockPcYearly(allCy,YTIME-1)/(i01Pop(YTIME-1,allCy)*1000)) / i01PassCarsMarkSat(allCy) + 1 - SQRT( SQR((V01StockPcYearly(allCy,YTIME-1)/(i01Pop(YTIME-1,allCy)*1000)) /  i01PassCarsMarkSat(allCy) - 1)  ) )/2;

*' This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
*' reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
*' cars scrapping rate over time.
Q01RateScrPc(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01RateScrPc(allCy,YTIME)
                  =E=
         [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy)) / (i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**0.5
         * V01RateScrPc(allCy,YTIME-1);
