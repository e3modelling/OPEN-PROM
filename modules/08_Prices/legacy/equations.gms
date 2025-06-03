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
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $TIME(YTIME) $(not sameas("NUC",EF)) $runCy(allCy))..
         VMPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)
                 =E=
         (VMPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1) +
          iMCo2EmiFac(allCy,SBS,EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SBS),(VMCarVal(allCy,NAP,YTIME)))/1000
         )$( not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF)))
         +
         (
          VMPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF)
         )
         +
         (
           ( VMPriceElecIndResConsu(allCy,"i",YTIME)$INDTRANS(SBS)+VMPriceElecIndResConsu(allCy,"r",YTIME)$RESIDENT(SBS))/sMTWhToMtoe
            +
            ((iMEffValueInDollars(allCy,SBS,YTIME))/1000)$DSBS(SBS)
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
Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
        V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
          =E= 
        iWgtSecAvgPriFueCons(allCy,DSBS,EF) * VMPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME);

*' The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
*' (using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
*' In the transport sector they feed into the calculation of the activity levels.
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VMPriceFuelAvgSub(allCy,DSBS,YTIME)
                 =E=
         sum(EF$SECTTECH(DSBS,EF), V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME));         

*' The equation calculates the electricity price for industrial and residential consumers
*' in a given scenario, energy set, and year. The electricity price is based on the previous year's production costs, incorporating
*' various factors such as fuel prices, factors affecting electricity prices to consumers, and long-term average
*' power generation costs. The equation is structured to handle different energy sets. It calculates the electricity
*' price for industrial consumers and residential consumers separately. The electricity price is influenced by fuel prices,
*' factors affecting electricity prices, and long-term average power generation costs. It provides a comprehensive representation of the
*' factors contributing to the electricity price for industrial and residential consumers in the specified scenario, energy set, and year.
Q08PriceElecIndResConsu(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..  !! The electricity price is based on previous year's production costs
        VMPriceElecIndResConsu(allCy,ESET,YTIME)
                 =E=
        (1 + iVAT(allCy,YTIME)) *
        (
           (
             (VMPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*sMTWhToMtoe)$TFIRST(YTIME-1) +
             (
                VMCostPowGenAvgLng(allCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VMPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*sMTWhToMtoe)$TFIRST(YTIME-1) +
             (
               VMCostPowGenAvgLng(allCy,"r",YTIME-1) 
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' Compute electricity price in Industrial and Residential Consumers excluding climate policies by multiplying the Factors affecting electricity prices to consumers by the sum of 
*' Fuel prices per subsector and fuel multiplied by the TWh to Mtoe conversion factor adding the Factors affecting electricity prices to consumers and the Long-term average power 
*' generation cost  excluding climate policies for Electricity of Other Industrial sectors and for Electricity for Households .
Q08PriceElecIndResNoCliPol(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..   !! The electricity price is based on previous year's production costs
        VMPriceElecIndResNoCliPol(allCy,ESET,YTIME)
                 =E=
        (1 + iVAT(allCy, YTIME)) *
        (
           (
             (VMPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*sMTWhToMtoe)$TFIRST(YTIME-1) +
             (
               V04CostPowGenLonNoClimPol(allCy,"i",YTIME-1) 
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VMPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*sMTWhToMtoe)$TFIRST(YTIME-1) +
             (
                V04CostPowGenLonNoClimPol(allCy,"r",YTIME-1) 
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
*' electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
*' factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
*' The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
*' price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
*' difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) $runCy(allCy))..
        VMPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                =E=   
             (((VMPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) + (VMRenValue(YTIME)/1000)$(not RENEF(EF))+iMVarCostTech(allCy,DSBS,EF,YTIME)/1000)/iMUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VMPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*sMFracElecPriChp*VMPriceElecInd(allCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VMPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+iMVarCostTech(allCy,DSBS,EF,YTIME)/1000)/iMUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VMPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*sMFracElecPriChp*VMPriceElecInd(allCy,YTIME))$CHP(EF))))  ) )/2;

*' This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
*' in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
*' electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
*' of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
*' for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
*' technical constraints, providing a realistic representation of the electricity market in the industrial sector.
Q08PriceElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VMPriceElecInd(allCy,YTIME) =E=
        ( V02IndxElecIndPrices(allCy,YTIME) + sMElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,YTIME)-sMElecToSteRatioChp)  ) )/2;
