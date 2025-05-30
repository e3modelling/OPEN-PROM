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
QPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $TIME(YTIME) $(not sameas("NUC",EF)) $runCy(allCy))..
         VPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)
                 =E=
         (VPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1) +
          iCo2EmiFac(allCy,SBS,EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SBS),(VCarVal(allCy,NAP,YTIME)))/1000
         )$( not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF)))
         +
         (
          VPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF)
         )
         +
         (
           ( VPriceElecIndResConsu(allCy,"i",YTIME)$INDTRANS(SBS)+VPriceElecIndResConsu(allCy,"r",YTIME)$RESIDENT(SBS))/sTWhToMtoe
            +
            ((iEffValueInDollars(allCy,SBS,YTIME))/1000)$DSBS(SBS)
         )$(ELCEF(EF) or HEATPUMP(EF))
         +
         (
                 iHydrogenPri(allCy,SBS,YTIME-1)$DSBS(SBS)
         )$(H2EF(EF) or sameas("STE1AH2F",EF));

*' The equation calculates the fuel prices per subsector and fuel multiplied by weights
*' considering separate carbon values in each sector. This equation is applied for a specific scenario, subsector, fuel, and year.
*' The calculation involves multiplying the sector's average price weight based on fuel consumption by the fuel price per subsector
*' and fuel. The weights are determined by the sector's average price, considering the specific fuel consumption for the given scenario, subsector, and fuel.
*' This equation allows for a more nuanced calculation of fuel prices, taking into account the carbon values in each sector. The result represents the fuel
*' prices per subsector and fuel, multiplied by the corresponding weights, and adjusted based on the specific carbon values in each sector.
QPriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
        VPriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
          =E= 
        iWgtSecAvgPriFueCons(allCy,DSBS,EF) * VPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME);

*' The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
*' (using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
*' In the transport sector they feed into the calculation of the activity levels.
QPriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VPriceFuelAvgSub(allCy,DSBS,YTIME)
                 =E=
         sum(EF$SECTTECH(DSBS,EF), VPriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME));         

*' The equation calculates the electricity price for industrial and residential consumers
*' in a given scenario, energy set, and year. The electricity price is based on the previous year's production costs, incorporating
*' various factors such as fuel prices, factors affecting electricity prices to consumers, and long-term average
*' power generation costs. The equation is structured to handle different energy sets. It calculates the electricity
*' price for industrial consumers and residential consumers separately. The electricity price is influenced by fuel prices,
*' factors affecting electricity prices, and long-term average power generation costs. It provides a comprehensive representation of the
*' factors contributing to the electricity price for industrial and residential consumers in the specified scenario, energy set, and year.
QPriceElecIndResConsu(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..  !! The electricity price is based on previous year's production costs
        VPriceElecIndResConsu(allCy,ESET,YTIME)
                 =E=
        (1 + iVAT(allCy,YTIME)) *
        (
           (
             (VPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (
                VCostPowGenAvgLng(allCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (
               VCostPowGenAvgLng(allCy,"r",YTIME-1) 
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' Compute electricity price in Industrial and Residential Consumers excluding climate policies by multiplying the Factors affecting electricity prices to consumers by the sum of 
*' Fuel prices per subsector and fuel multiplied by the TWh to Mtoe conversion factor adding the Factors affecting electricity prices to consumers and the Long-term average power 
*' generation cost  excluding climate policies for Electricity of Other Industrial sectors and for Electricity for Households .
QPriceElecIndResNoCliPol(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..   !! The electricity price is based on previous year's production costs
        VPriceElecIndResNoCliPol(allCy,ESET,YTIME)
                 =E=
        (1 + iVAT(allCy, YTIME)) *
        (
           (
             (VPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (
               VCostPowGenLonNoClimPol(allCy,"i",YTIME-1) 
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (
                VCostPowGenLonNoClimPol(allCy,"r",YTIME-1) 
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
*' electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
*' factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
*' The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
*' price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
*' difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
QPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) $runCy(allCy))..
        VPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                =E=   
             (((VPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) + (VRenValue(YTIME)/1000)$(not RENEF(EF))+iVarCostTech(allCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*sFracElecPriChp*VPriceElecInd(allCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+iVarCostTech(allCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*sFracElecPriChp*VPriceElecInd(allCy,YTIME))$CHP(EF))))  ) )/2;

*' This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
*' in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
*' electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
*' of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
*' for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
*' technical constraints, providing a realistic representation of the electricity market in the industrial sector.
QPriceElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPriceElecInd(allCy,YTIME) =E=
        ( VIndxElecIndPrices(allCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VIndxElecIndPrices(allCy,YTIME)-sElecToSteRatioChp)  ) )/2;
