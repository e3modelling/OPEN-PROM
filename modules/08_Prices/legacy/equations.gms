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
Q08PriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)$(SECtoEF(SBS,EFS) $(not sameas("CRO",EFS)) $TIME(YTIME)
$IFTHEN %link2MAgPIE% == on 
   $(not sameas("BMSWAS",EFS))
$ENDIF
   $(not sameas("NUC",EFS)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)
        =E=
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
    (1 + (VmCostPowGenAvgLng(allCy,YTIME-1) / VmCostPowGenAvgLng(allCy,YTIME-2) - 1)$sameas("ELC",EFS)) *
    (1 + (VmCostAvgProdH2(allCy,YTIME-1) / VmCostAvgProdH2(allCy,YTIME-2) - 1)$sameas("H2F",EFS)) * 
    (1 + (VmCostAvgProdSte(allCy,YTIME-1) / VmCostAvgProdSte(allCy,YTIME-2) - 1)$sameas("STE",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.4 - 1)$sameas("NGS",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.8 - 1)$SECtoEFPROD("LQD",EFS)) +
    (
      VmCarVal(allCy,"TRADE",YTIME) * imCo2EmiFac(allCy,SBS,EFS,YTIME) * 1e-3 - 
      VmCarVal(allCy,"TRADE",YTIME-1) * imCo2EmiFac(allCy,SBS,EFS,YTIME-1) * 1e-3
    )$DSBS(SBS);

Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
    1e-6 +
    (
      (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) /
      (SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) + 1e-6)
    )$(INDDOM(DSBS) or NENSE(DSBS)) +   
    SUM(TRANSE$(sameas(TRANSE,DSBS)),
      VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
      (SUM(EF2$SECtoEF(TRANSE,EF2),VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME)) + 1e-6)
    ) +
    (
      SUM(CDRTECH,VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)) /
      (SUM((CDRTECH,EF2)$SECtoEF(DSBS,EF2),VmConsFuelTechCDRProd(allCy,CDRTECH,EF2,YTIME)) + 1e-12)
    )$sameas("DAC",DSBS) +
    (
      VmConsFuelTechCDRProd(allCy,"TEW",EF,YTIME) /
      (SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuelTechCDRProd(allCy,"TEW",EF2,YTIME)) + 1e-12)
    )$sameas("EW",DSBS);
  
*' The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
*' (using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
*' In the transport sector they feed into the calculation of the activity levels.
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceFuelAvgSub(allCy,DSBS,YTIME)
        =E=
    sum(EF$SECtoEF(DSBS,EF), 
      V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME-1) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1));         

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
Q08PriceElecInd(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecInd(allCy,TCHP,YTIME) 
        =E=
    (
      V02IndxElecIndPrices(allCy,TCHP,YTIME) + smElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,TCHP,YTIME)-smElecToSteRatioChp))
    )/2;