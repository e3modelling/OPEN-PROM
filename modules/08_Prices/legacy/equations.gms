*' @title Equations of OPEN-PROMs Prices
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Prices

*' The equation computes fuel prices per subsector and fuel with separate carbon values in
*' each sector for a specific scenario, subsector, fuel, and year.The equation considers various scenarios based
*' on the type of fuel and whether it is subject to changes in carbon values. It incorporates factors such as carbon emission factors
*' carbon values for all countries, electricity prices to industrial and residential consumers,
*' efficiency values, and the total hydrogen cost per sector.The result of the equation is the fuel price per 
*' subsector and fuel, adjusted based on changes in carbon values, electricity prices, efficiency, and hydrogen costs.
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF) $TIME(YTIME)
$IFTHEN %link2MAgPIE% == on 
   $(not sameas("BMSWAS",EF))
$ENDIF
   $(not sameas("NUC",EF)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)
        =E=
    (VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)
    )$(DSBS(SBS))$(not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF) or H2EF(EF) or sameas("STE",EF))) +
       (VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)
      !!We should account for carbon tax increase for the own consumption emissions
    )$sameas(SBS,"PG") +
    VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF) +
    (
      ( VmPriceElecIndResConsu(allCy,"i",YTIME)$INDSE1(SBS)+
        VmPriceElecIndResConsu(allCy,"r",YTIME)$HOU1(SBS) +
        VmPriceElecIndResConsu(allCy,"t",YTIME)$TRANS1(SBS) +
        VmPriceElecIndResConsu(allCy,"c",YTIME)$SERV(SBS)
      )/smTWhToMtoe
      +
      ((imEffValueInDollars(allCy,SBS,YTIME))/1000)$DSBS(SBS)
    )$(ELCEF(EF) or HEATPUMP(EF)) +
    (
      VmPriceFuelSubsecCarVal(allCy,"OI",EF,YTIME)$(not sameas("BMSWAS",EF) or not sameas("CRO",EF)) +
      VmPriceFuelSubsecCarVal(allCy,"AG",EF,YTIME)$sameas("BMSWAS",EF)
    )$(sameas ("H2P",SBS) or sameas("STEAMP",SBS)) +
    (VmCostAvgProdH2(allCy,YTIME)$DSBS(SBS)/1000)$H2EF(EF) +
    (VmCostAvgProdSte(allCy,YTIME)$DSBS(SBS))$sameas("STE",EF);

$ontext
*' The equation calculates the fuel prices per subsector and fuel multiplied by weights
*' considering separate carbon values in each sector. This equation is applied for a specific scenario, subsector, fuel, and year.
*' The calculation involves multiplying the sector's average price weight based on fuel consumption by the fuel price per subsector
*' and fuel. The weights are determined by the sector's average price, considering the specific fuel consumption for the given scenario, subsector, and fuel.
*' This equation allows for a more nuanced calculation of fuel prices, taking into account the carbon values in each sector. The result represents the fuel
*' prices per subsector and fuel, multiplied by the corresponding weights, and adjusted based on the specific carbon values in each sector.
Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
    V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E= 
    !!i08WgtSecAvgPriFueCons(allCy,DSBS,EF) * 
    !!(
    1e-2+
      (
        (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) / 
        (SUM(EF2,VmConsFuel(allCy,DSBS,EF2,YTIME)- V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) )
      )$INDSE(DSBS) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)

      +
      SUM(TRANSE$TRANSE(DSBS), 
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
        1!!SUM(EF2,VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME))
      )$TRANSE(DSBS)
    ) *
    VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME);
$offtext

Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
      1e-12 +
      (
        (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) /
        (SUM(EF2,VmConsFuel(allCy,DSBS,EF2,YTIME)- V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) )
      )$(INDDOM(DSBS) or NENSE(DSBS)) +   
      SUM(TRANSE$(sameas(TRANSE,DSBS)),
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
        (SUM(EF2$SECtoEF(TRANSE,EF2),VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME))+1e-12)
      )
;
*' The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
*' (using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
*' In the transport sector they feed into the calculation of the activity levels.
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceFuelAvgSub(allCy,DSBS,YTIME)
        =E=
    sum(EF$SECtoEF(DSBS,EF), 
      V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME-1) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1));         

*' Calculates electricity price for industrial and residential consumers
*' using previous year's fuel prices. For the first year, the price is directly based on fuel data.
*' For later years, the price is scaled using a ratio of 2021 electricity price to 2021 average generation cost
*' to ensure smoothness between historical and non-historical years.
Q08PriceElecIndResConsu(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecIndResConsu(allCy,ESET,YTIME) !!Cost final electricity
        =E=
    (1 + i08VAT(allCy,YTIME)) *
    (
      (
      (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
      (
        VmPriceElecIndResConsu(allCy,"i","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
        VmCostPowGenAvgLng(allCy,YTIME-1) !!Cost secondary energy electricity
      )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"i") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"r","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"r") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"PC","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"t","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"t") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"SE","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"c","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"c") 
    );

*' This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
*' electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
*' factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
*' The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
*' price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
*' difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
$ontext
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) $runCy(allCy))..
        VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                =E=   
             (((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) + (VmRenValue(YTIME)/1000)$(not RENEF(EF))+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF))))  ) )/2;
$offtext
*' This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
*' in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
*' electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
*' of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
*' for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
*' technical constraints, providing a realistic representation of the electricity market in the industrial sector.
Q08PriceElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecInd(allCy,YTIME) 
        =E=
    (
      V02IndxElecIndPrices(allCy,YTIME) + smElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,YTIME)-smElecToSteRatioChp))
    )/2;
