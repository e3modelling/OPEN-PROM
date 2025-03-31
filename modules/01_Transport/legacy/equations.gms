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
QLft(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $sameas(DSBS,"PC") $SECTTECH(DSBS,EF) $runCy(allCy))..
         VLft(allCy,DSBS,EF,YTIME)
                 =E=
         1/VRateScrPc(allCy,YTIME);

*' This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
*' The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
*' freight transport modes.
QActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE) $runCy(allCy))..
         VActivGoodsTransp(allCy,TRANSE,YTIME)
                 =E=
         (
          VActivGoodsTransp(allCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,allCy)/iPop(YTIME,allCy))/(iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**iElastA(allCy,TRANSE,"a",YTIME)
           * (iPop(YTIME,allCy)/iPop(YTIME-1,allCy))
           * (VPriceFuelAvgSub(allCy,TRANSE,YTIME)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**iElastA(allCy,TRANSE,"c1",YTIME)
           * (VPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**iElastA(allCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(allCy,YTIME)**(1/6))]**(iElastA(allCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$sameas(TRANSE,"GU")        !!trucks
         +
         (
           VActivGoodsTransp(allCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,allCy)/iPop(YTIME,allCy))/(iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**iElastA(allCy,TRANSE,"a",YTIME)
           * (VPriceFuelAvgSub(allCy,TRANSE,YTIME)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**iElastA(allCy,TRANSE,"c1",YTIME)
           * (VPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**iElastA(allCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(allCy,YTIME)**(1/6))]**(iElastA(allCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
           * (VActivGoodsTransp(allCy,"GU",YTIME)/VActivGoodsTransp(allCy,"GU",YTIME-1))**iElastA(allCy,TRANSE,"c4",YTIME)
         )$(not sameas(TRANSE,"GU"));                      !!other freight transport

*' This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
*' The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
*' various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
*' different types of transportation modes.
QGapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VGapTranspActiv(allCy,TRANSE,YTIME)
                 =E=
         VNewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC")
         +
         (
         ( [VActivPassTrnsp(allCy,TRANSE,YTIME) - VActivPassTrnsp(allCy,TRANSE,YTIME-1) + VActivPassTrnsp(allCy,TRANSE,YTIME-1)/
         (sum((TTECH)$SECTTECH(TRANSE,TTECH),VLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] +
          SQRT( SQR([VActivPassTrnsp(allCy,TRANSE,YTIME) - VActivPassTrnsp(allCy,TRANSE,YTIME-1) + VActivPassTrnsp(allCy,TRANSE,YTIME-1)/
          (sum((TTECH)$SECTTECH(TRANSE,TTECH),VLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
         +
         (
         ( [VActivGoodsTransp(allCy,TRANSE,YTIME) - VActivGoodsTransp(allCy,TRANSE,YTIME-1) + VActivGoodsTransp(allCy,TRANSE,YTIME-1)/
         (sum((EF)$SECTTECH(TRANSE,EF),VLft(allCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([VActivGoodsTransp(allCy,TRANSE,YTIME) - VActivGoodsTransp(allCy,TRANSE,YTIME-1) + VActivGoodsTransp(allCy,TRANSE,YTIME-1)/
          (sum((EF)$SECTTECH(TRANSE,EF),VLft(allCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$TRANG(TRANSE);

*' This equation calculates the specific fuel consumption for a given technology, subsector, energy form, and time. The specific fuel consumption depends on various factors,
*' including fuel prices and elasticities. The equation involves a product term over a set of Polynomial Distribution Lags and considers the elasticity of fuel prices.
QConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
         VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
                 =E=
         VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME-1) * prod(KPDL,
                     (
                        VPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-ord(KPDL))/VPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
                      )**(iElastA(allCy,TRANSE,"c5",YTIME)*iFPDL(TRANSE,KPDL))
          );

*' This equation calculates the transportation cost per mean and consumer size in kEuro per vehicle. It involves several terms, including capital costs,
*' variable costs, and fuel costs. The equation considers different technologies and their associated costs, as well as factors like the discount rate,
*' specific fuel consumption, and annual .
QCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le iNcon(TRANSE)+1) $runCy(allCy))..
         VCostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)
         =E=
                       (
                         (
                           (iDisc(allCy,TRANSE,YTIME)*exp(iDisc(allCy,TRANSE,YTIME)*VLft(allCy,TRANSE,TTECH,YTIME)))
                           /
                           (exp(iDisc(allCy,TRANSE,YTIME)*VLft(allCy,TRANSE,TTECH,YTIME)) - 1)
                         ) * iCapCostTech(allCy,TRANSE,TTECH,YTIME)  * iCGI(allCy,YTIME)
                         + iFixOMCostTech(allCy,TRANSE,TTECH,YTIME)  +
                         (
                           (sum(EF$TTECHtoEF(TTECH,EF),VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
                           +
                           (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),

                              (1-iShareAnnMilePlugInHybrid(allCy,YTIME))*VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME))
                             + iShareAnnMilePlugInHybrid(allCy,YTIME)*VConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)*VPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
                           )$PLUGIN(TTECH)

                           + iVarCostTech(allCy,TRANSE,TTECH,YTIME)
                           + (VRenValue(YTIME)/1000)$( not RENEF(TTECH))
                         )
                         *  iAnnCons(allCy,TRANSE,"smallest") * (iAnnCons(allCy,TRANSE,"largest")/iAnnCons(allCy,TRANSE,"smallest"))**((ord(Rcon)-1)/iNcon(TRANSE))
                       );

*' This equation calculates the transportation cost per mean and consumer size. It involves taking the inverse fourth power of the
*' variable representing the transportation cost per mean and consumer size.
QCostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1) $runCy(allCy))..
         VCostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)
         =E=
         VCostTranspPerMeanConsSize(allCy,TRANSE,rCon,TTECH,YTIME)**(-1);

*' This equation calculates the transportation cost, including the maturity factor. It involves multiplying the maturity factor for a specific technology
*' and subsector by the transportation cost per vehicle for the mean and consumer size. The result is a variable representing the transportation cost,
*' including the maturity factor.
QCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1) $runCy(allCy))..
         VCostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME) 
         =E=
         iMatrFactor(allCy,TRANSE,TTECH,YTIME) * VCostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME);

*' This equation calculates the technology sorting based on variable cost. It involves the summation of transportation costs, including the maturity factor,
*' for each technology and subsector. The result is a variable representing the technology sorting based on variable cost.
QTechSortVarCost(allCy,TRANSE,rCon,YTIME)$(TIME(YTIME) $(ord(rCon) le iNcon(TRANSE)+1) $runCy(allCy))..
         VTechSortVarCost(allCy,TRANSE,rCon,YTIME)
                 =E=
         sum((TTECH)$SECTTECH(TRANSE,TTECH), VCostTranspMatFac(allCy,TRANSE,rCon,TTECH,YTIME));

*' This equation calculates the share of each technology in the total sectoral use. It takes into account factors such as the maturity factor,
*' cumulative distribution function of consumer size groups, transportation cost per mean and consumer size, distribution function of consumer
*' size groups, and technology sorting based on variable cost. The result is a dimensionless value representing the share of each technology in the total sectoral use.
QShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
         VShareTechTr(allCy,TRANSE,TTECH,YTIME)
         =E=
         iMatrFactor(allCy,TRANSE,TTECH,YTIME) / iCumDistrFuncConsSize(allCy,TRANSE)
         * sum( Rcon$(ord(Rcon) le iNcon(TRANSE)+1),
                VCostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)
                * iDisFunConSize(allCy,TRANSE,RCon) / VTechSortVarCost(allCy,TRANSE,RCon,YTIME)
              );

*' This equation calculates the consumption of each technology in transport sectors. It considers various factors such as the lifetime of the technology,
*' average capacity per vehicle, load factor, scrapping rate, and specific fuel consumption. The equation also takes into account the technology's variable
*' cost for new equipment and the gap in transport activity to be filled by new technologies. The result is expressed in million tonnes of oil equivalent.
QConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
         VConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
                 =E=
         VConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME-1) *
         (
                 (
                     ((VLft(allCy,TRANSE,TTECH,YTIME-1)-1)/VLft(allCy,TRANSE,TTECH,YTIME-1))
                      *(iAvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1))
                      /(iAvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (1 - VRateScrPc(allCy,YTIME))$sameas(TRANSE,"PC")
         )
         +
         VShareTechTr(allCy,TRANSE,TTECH,YTIME) *
         (
                 VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(not PLUGIN(TTECH))
                 +
                 ( ((1-iShareAnnMilePlugInHybrid(allCy,YTIME))*VConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME))$(not sameas("ELC",EF))
                   + iShareAnnMilePlugInHybrid(allCy,YTIME)*VConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME))$PLUGIN(TTECH)
         )/1000
         * VGapTranspActiv(allCy,TRANSE,YTIME) *
         (
                 (
                  (iAvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1))
                  / (iAvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (VActivPassTrnsp(allCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
         );

*' This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
*' It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
QDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $runCy(allCy))..
         VDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
                 =E=
         sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), VConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME));

*' This equation calculates the final energy demand in different transport subsectors by summing up the final energy demand for each energy form within
*' each transport subsector. The result is expressed in million tonnes of oil equivalent.
$ontext
qDemFinEneSubTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $runCy(allCy))..
         vDemFinEneSubTransp(allCy,TRANSE,YTIME)
                 =E=
         sum(EF,VDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME));
$offtext

*' This equation calculates the GDP-dependent market extension of passenger cars. It takes into account transportation characteristics, the GDP-dependent market
*' extension from the previous year, and the ratio of GDP to population for the current and previous years. The elasticity parameter (a) influences the sensitivity
*' of market extension to changes in GDP.
QMEPcGdp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VMEPcGdp(allCy,YTIME)
                 =E=
         iTransChar(allCy,"RES_MEXTV",YTIME) * VMEPcGdp(allCy,YTIME-1) *
         [(iGDP(YTIME,allCy)/iPop(YTIME,allCy)) / (iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))] ** iElastA(allCy,"PC","a",YTIME);

*' This equation calculates the market extension of passenger cars that is independent of GDP. It involves various parameters such as transportation characteristics,
*' Gompertz function parameters (S1, S2, S3), the ratio of the previous year's stock of passenger cars to the previous year's population, and the saturation ratio .
QMEPcNonGdp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VMEPcNonGdp(allCy,YTIME)
                 =E=
         iTransChar(allCy,"RES_MEXTF",YTIME) * iSigma(allCy,"S1") * EXP(iSigma(allCy,"S2") * EXP(iSigma(allCy,"S3") * VPcOwnPcLevl(allCy,YTIME))) *
         VStockPcYearly(allCy,YTIME-1) / (iPop(YTIME-1,allCy) * 1000);

*' This equation calculates the stock of passenger cars in million vehicles for a given year. The stock is influenced by the previous year's stock,
*' population, and market extension factors, both GDP-dependent and independent.
QStockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VStockPcYearly(allCy,YTIME)
                 =E=
         (VStockPcYearly(allCy,YTIME-1)/(iPop(YTIME-1,allCy)*1000) + VMEPcNonGdp(allCy,YTIME) + VMEPcGdp(allCy,YTIME)) *
         iPop(YTIME,allCy) * 1000;

*' This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
*' The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
QNewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VNewRegPcYearly(allCy,YTIME)
                 =E=
         (VMEPcNonGdp(allCy,YTIME) + VMEPcGdp(allCy,YTIME)) * (iPop(YTIME,allCy)*1000)  !! new cars due to GDP
         - VStockPcYearly(allCy,YTIME-1)*(1 - iPop(YTIME,allCy)/iPop(YTIME-1,allCy))    !! new cars due to population
         + VNumPcScrap(allCy,YTIME);                                                  !! new cars due to scrapping

*' This equation calculates the passenger transport activity for various modes of transportation, including passenger cars, aviation, and other passenger transportation modes.
*' The activity is influenced by factors such as fuel prices, GDP per capita, and elasticities specific to each transportation mode. The equation uses past activity levels and
*' price trends to estimate the current year's activity. The coefficients and exponents in the equation represent the sensitivities of activity to changes in various factors.
QActivPassTrnsp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE) $runCy(allCy))..
         VActivPassTrnsp(allCy,TRANSE,YTIME)
                 =E=
         (  !! passenger cars
            VActivPassTrnsp(allCy,TRANSE,YTIME-1) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**iElastA(allCy,TRANSE,"b1",YTIME) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**iElastA(allCy,TRANSE,"b2",YTIME) *
           [(VStockPcYearly(allCy,YTIME-1)/(iPop(YTIME-1,allCy)*1000))/(VStockPcYearly(allCy,YTIME)/(iPop(YTIME,allCy)*1000))]**iElastA(allCy,TRANSE,"b3",YTIME) *
           [(iGDP(YTIME,allCy)/iPop(YTIME,allCy))/(iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**iElastA(allCy,TRANSE,"b4",YTIME)
         )$sameas(TRANSE,"PC") +
         (  !! passenger aviation
            VActivPassTrnsp(allCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,allCy)/iPop(YTIME,allCy))/(iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**iElastA(allCy,TRANSE,"a",YTIME) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**iElastA(allCy,TRANSE,"c1",YTIME) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**iElastA(allCy,TRANSE,"c2",YTIME)
         )$sameas(TRANSE,"PA") +
         (   !! other passenger transportation modes
           VActivPassTrnsp(allCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,allCy)/iPop(YTIME,allCy))/(iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**iElastA(allCy,TRANSE,"a",YTIME) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**iElastA(allCy,TRANSE,"c1",YTIME) *
           (VPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**iElastA(allCy,TRANSE,"c2",YTIME) *
           [(VStockPcYearly(allCy,YTIME)*VActivPassTrnsp(allCy,"PC",YTIME))/(VStockPcYearly(allCy,YTIME-1)*VActivPassTrnsp(allCy,"PC",YTIME-1))]**iElastA(allCy,TRANSE,"c4",YTIME) *
           prod(kpdl,
                  [(VPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(allCy,YTIME)**(1/6))]**(iElastA(allCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
*' The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
QNumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VNumPcScrap(allCy,YTIME)
                 =E=
         VRateScrPc(allCy,YTIME) * VStockPcYearly(allCy,YTIME-1);

*' This equation calculates the ratio of car ownership over the saturation car ownership level. The calculation is based on a Gompertz function,
*' taking into account the stock of passenger cars, the population, and the market saturation level from the previous year. This ratio provides
*' an estimate of the level of car ownership relative to the saturation point, considering the dynamics of the market over time.
QPcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPcOwnPcLevl(allCy,YTIME) !! level of saturation of gompertz function
                 =E=
         ( (VStockPcYearly(allCy,YTIME-1)/(iPop(YTIME-1,allCy)*1000)) / iPassCarsMarkSat(allCy) + 1 - SQRT( SQR((VStockPcYearly(allCy,YTIME-1)/(iPop(YTIME-1,allCy)*1000)) /  iPassCarsMarkSat(allCy) - 1)  ) )/2;

*' This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
*' reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
*' cars scrapping rate over time.
QRateScrPc(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VRateScrPc(allCy,YTIME)
                  =E=
         [(iGDP(YTIME,allCy)/iPop(YTIME,allCy)) / (iGDP(YTIME-1,allCy)/iPop(YTIME-1,allCy))]**0.5
         * VRateScrPc(allCy,YTIME-1);
