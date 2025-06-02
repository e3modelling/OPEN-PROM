*' @title Equations of OPEN-PROMs INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES

*' This equation computes the consumption/demand of non-substitutable electricity for subsectors of INDUSTRY and DOMESTIC in the "typical useful energy demand equation".
*' The main explanatory variables are activity indicators of each subsector and electricity prices per subsector. Corresponding elasticities are applied for activity indicators
*' and electricity prices.
Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         MVConsElecNonSubIndTert(allCy,INDDOM,YTIME)
                 =E=
         [
         MVConsElecNonSubIndTert(allCy,INDDOM,YTIME-1) * ( iActv(YTIME,allCy,INDDOM)/iActv(YTIME-1,allCy,INDDOM) )**
         iElastNonSubElec(allCy,INDDOM,"a",YTIME)
         * ( MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME)/MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1) )**iElastNonSubElec(allCy,INDDOM,"b1",YTIME)
         * ( MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1)/MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-2) )**iElastNonSubElec(allCy,INDDOM,"b2",YTIME)
         * prod(KPDL,
                  ( MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-ord(KPDL))/MVPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))
                  )**( iElastNonSubElec(allCy,INDDOM,"c",YTIME)*iFPDL(INDDOM,KPDL))
                )      ]$iActv(YTIME-1,allCy,INDDOM)+0;

*' This equation determines the consumption of the remaining substitutable equipment of each energy form per each demand subsector (excluding TRANSPORT).
*' The "remaining" equipment is computed based on the past value of consumption (energy form, subsector) and the lifetime of the technology (energy form) for each subsector.  
*' For the electricity energy form, the non substitutable consumption is subtracted.
*' This equation expresses the "typical useful energy demand equation" where the main explanatory variables are activity indicators and fuel prices.
Q02ConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $runCy(allCy))..
         MVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)
                 =E=
         [
         (MVLft(allCy,DSBS,EF,YTIME)-1)/MVLft(allCy,DSBS,EF,YTIME)
         * (MVConsFuelInclHP(allCy,DSBS,EF,YTIME-1) - (MVConsElecNonSubIndTert(allCy,DSBS,YTIME-1)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))))
         * (iActv(YTIME,allCy,DSBS)/iActv(YTIME-1,allCy,DSBS))**iElastA(allCy,DSBS,"a",YTIME)
         * (MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)/MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1))**iElastA(allCy,DSBS,"b1",YTIME)
         * (MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1)/MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-2))**iElastA(allCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                 (MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-ord(KPDL))/MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-(ord(KPDL)+1)))**(iElastA(allCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
               )  ]$(iActv(YTIME-1,allCy,DSBS));

*' This equation computes the useful energy demand in each demand subsector (excluding TRANSPORT). This demand is potentially "satisfied" by multiple energy forms/fuels (substitutable demand).
*' The equation follows the "typical useful energy demand" format where the main explanatory variables are activity indicators and average "weighted" fuel prices.
Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $runCy(allCy))..
         MVDemFinSubFuelSubsec(allCy,DSBS,YTIME)
                 =E=
         [
         MVDemFinSubFuelSubsec(allCy,DSBS,YTIME-1)
         * ( iActv(YTIME,allCy,DSBS)/iActv(YTIME-1,allCy,DSBS) )**iElastA(allCy,DSBS,"a",YTIME)
         * ( MVPriceFuelAvgSub(allCy,DSBS,YTIME)/MVPriceFuelAvgSub(allCy,DSBS,YTIME-1) )**iElastA(allCy,DSBS,"b1",YTIME)
         * ( MVPriceFuelAvgSub(allCy,DSBS,YTIME-1)/MVPriceFuelAvgSub(allCy,DSBS,YTIME-2) )**iElastA(allCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                  ( (MVPriceFuelAvgSub(allCy,DSBS,YTIME-ord(KPDL))/MVPriceFuelAvgSub(allCy,DSBS,YTIME-(ord(KPDL)+1)))/(iCGI(allCy,YTIME)**(1/6))
                  )**( iElastA(allCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
                )  ]$iActv(YTIME-1,allCy,DSBS)+0
;

*' This equation calculates the total consumption of electricity in industrial sectors. The consumption is obtained by summing up the electricity
*' consumption in each industrial subsector, excluding substitutable electricity. This equation provides an aggregate measure of electricity consumption
*' in the industrial sectors, considering only non-substitutable electricity.
$ontext
q02ConsTotElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         MvConsTotElecInd(allCy,YTIME)
         =E=
         SUM(INDSE,MVConsElecNonSubIndTert(allCy,INDSE,YTIME));       
$offtext

*' This equation calculates the total final demand for substitutable fuels in industrial sectors. The total demand is obtained by summing up the
*' final demand for substitutable fuels across various industrial subsectors. This equation provides a comprehensive view of the total demand for
*' substitutable fuels within the industrial sectors, aggregated across individual subsectors.
$ontext
q02DemFinSubFuelInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        MvDemFinSubFuelInd(allCy,YTIME)=E= SUM(INDSE,MVDemFinSubFuelSubsec(allCy,INDSE,YTIME));
$offtext

*' This equation calculates the total fuel consumption in each demand subsector, excluding heat from heat pumps. The fuel consumption is measured
*' in million tons of oil equivalent and is influenced by two main components: the consumption of fuels in each demand subsector, including
*' heat from heat pumps, and the electricity consumed in heat pump plants.The equation uses the fuel consumption data for each demand subsector,
*' considering both cases with and without heat pump influence. When heat pumps are involved, the electricity consumed in these plants is also
*' taken into account. The result is the total fuel consumption in each demand subsector, providing a comprehensive measure of the energy consumption pattern.
*' This equation offers a comprehensive view of fuel consumption, considering both traditional fuel sources and the additional electricity consumption
*' associated with heat pump plants.
Q02ConsFuel(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $runCy(allCy))..
         MVConsFuel(allCy,DSBS,EF,YTIME)
                 =E=
         MVConsFuelInclHP(allCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
         (MVConsFuelInclHP(allCy,DSBS,EF,YTIME) + VElecConsHeatPla(allCy,DSBS,YTIME))$ELCEF(EF);

*' This equation calculates the estimated electricity index of the industry price for a given year. The estimated index is derived by considering the historical
*' trend of the electricity index, with a focus on the fuel prices in the industrial subsector. The equation utilizes the fuel prices for electricity generation,
*' both in the current and past years, and computes a weighted average based on the historical pattern. The estimated electricity index is influenced by the ratio
*' of fuel prices in the current and previous years, with a power of 0.3 applied to each ratio. This weighting factor introduces a gradual adjustment to reflect the
*' historical changes in fuel prices, providing a more dynamic estimation of the electricity index. This equation provides a method to estimate the electricity index
*' based on historical fuel price trends, allowing for a more flexible and responsive representation of industry price dynamics.
QIndxElecIndPrices(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VIndxElecIndPrices(allCy,YTIME)
                =E=
        MVPriceElecInd(allCy,YTIME-1) * 
        (MVPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)/MVPriceFuelAvgSub(allCy,"OI",YTIME-1)) ** (0.6) *
        (MVPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-2)/MVPriceFuelAvgSub(allCy,"OI",YTIME-2)) ** (0.3) *
        (MVPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-3)/MVPriceFuelAvgSub(allCy,"OI",YTIME-3)) ** (0.1)
        
        ;

*' The equation computes the electricity production cost per Combined Heat and Power plant for a specific demand sector within a given subsector.
*' The cost is determined based on various factors, including the discount rate, technical lifetime of CHP plants, capital cost, fixed O&M cost, availability rate,
*' variable cost, and fuel-related costs. The equation provides a comprehensive assessment of the overall expenses associated with electricity production from CHP
*' plants, considering both the fixed and variable components, as well as factors such as carbon prices and CO2 emission factors.
*' The resulting variable represents the electricity production cost per CHP plant and demand sector, expressed in Euro per kilowatt-hour (Euro/KWh).
QCostElecProdCHP(allCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
         VCostElecProdCHP(allCy,DSBS,CHP,YTIME)
                 =E=
                    ( ( iDisc(allCy,"PG",YTIME) * exp(iDisc(allCy,"PG",YTIME)*iLifChpPla(allCy,DSBS,CHP))
                        / (exp(iDisc(allCy,"PG",YTIME)*iLifChpPla(allCy,DSBS,CHP)) -1))
                      * iInvCostChp(allCy,DSBS,CHP,YTIME)* 1000 * iCGI(allCy,YTIME)  + iFixOMCostPerChp(allCy,DSBS,CHP,YTIME)
                    )/(iAvailRateChp(allCy,DSBS,CHP)*(sGwToTwhPerYear))/1000
                    + iVarCostChp(allCy,DSBS,CHP,YTIME)/1000
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (MVPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+0.001*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),MVCarVal(allCy,NAP,YTIME))))
                         * sTWhToMtoe /  (iBoiEffChp(allCy,CHP,YTIME) * MVPriceElecInd(allCy,YTIME)) );        

*' The equation calculates the technology cost for each technology, energy form, and consumer size group within the specified subsector.
*' This cost estimation is based on an intermediate technology cost and the elasticity parameter associated with the given subsector.
*' The intermediate technology cost is raised to the power of the elasticity parameter to determine the final technology cost. The equation
*' provides a comprehensive assessment of the overall expenses associated with different technologies in the given subsector and consumer size group.
QCostTech(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
        VCostTech(allCy,DSBS,rCon,EF,YTIME) 
                 =E= 
                 VCostTechIntrm(allCy,DSBS,rCon,EF,YTIME)**(-iElaSub(allCy,DSBS)) ;   

*' The equation computes the intermediate technology cost, including the lifetime factor, for each technology, energy form, and consumer size group
*' within the specified subsector. This cost estimation plays a crucial role in evaluating the overall expenses associated with adopting and implementing
*' various technologies in the given subsector and consumer size group. The equation encompasses diverse parameters, such as discount rates, lifetime of 
*' technologies, capital costs, fixed operation and maintenance costs, fuel prices, annual consumption rates, the number of consumers, the capital goods 
*' index, and useful energy conversion factors.
QCostTechIntrm(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
         VCostTechIntrm(allCy,DSBS,rCon,EF,YTIME) =E=
                  ( (( (iDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(allCy,"PG",YTIME)$CHP(EF)) !! in case of chp plants we use the discount rate of power generation sector
                       * exp((iDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(allCy,"PG",YTIME)$CHP(EF))*MVLft(allCy,DSBS,EF,YTIME))
                     )
                      / (exp((iDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(allCy,"PG",YTIME)$CHP(EF))*MVLft(allCy,DSBS,EF,YTIME))- 1)
                    ) * iCapCostTech(allCy,DSBS,EF,YTIME) * iCGI(allCy,YTIME)
                    +
                    iFixOMCostTech(allCy,DSBS,EF,YTIME)/1000
                    +
                    MVPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                    * iAnnCons(allCy,DSBS,"smallest") * (iAnnCons(allCy,DSBS,"largest")/iAnnCons(allCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$INDDOM(DSBS)
                 +
                  ( (( iDisc(allCy,DSBS,YTIME)
                       * exp(iDisc(allCy,DSBS,YTIME)*MVLft(allCy,DSBS,EF,YTIME))
                     )
                      / (exp(iDisc(allCy,DSBS,YTIME)*MVLft(allCy,DSBS,EF,YTIME))- 1)
                    ) * iCapCostTech(allCy,DSBS,EF,YTIME) * iCGI(allCy,YTIME)
                    +
                    iFixOMCostTech(allCy,DSBS,EF,YTIME)/1000
                    +
                    (
                      (MVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+iVarCostTech(allCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(allCy,DSBS,EF,YTIME)
                    )
                    * iAnnCons(allCy,DSBS,"smallest") * (iAnnCons(allCy,DSBS,"largest")/iAnnCons(allCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$NENSE(DSBS);  

*' This equation calculates the technology cost, including the maturity factor , for each energy form  and technology  within
*' the specified subsector and consumer size group . The cost is determined by multiplying the maturity factor with the
*' technology cost based on the given parameters.
QCostTechMatFac(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
        VCostTechMatFac(allCy,DSBS,rCon,EF,YTIME) 
                                               =E=
        iMatrFactor(allCy,DSBS,EF,YTIME) * VCostTech(allCy,DSBS,rCon,EF,YTIME) ;

*' This equation calculates the technology sorting based on variable cost . It is determined by summing the technology cost,
*' including the maturity factor , for each energy form and technology within the specified subsector 
*' and consumer size group. The sorting is conducted based on variable cost considerations.
QSortTechVarCost(allCy,DSBS,rCon,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $runCy(allCy))..
        VSortTechVarCost(allCy,DSBS,rCon,YTIME)
                        =E=
        sum((EF)$(SECTTECH(DSBS,EF) ),VCostTechMatFac(allCy,DSBS,rCon,EF,YTIME));

*' This equation calculates the gap in final demand for industry, tertiary, non-energy uses, and bunkers.
*' It is determined by subtracting the total final demand per subsector from the consumption of
*' remaining substitutable equipment. The square root term is included to ensure a non-negative result.
QGapFinalDem(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $runCy(allCy))..
         VGapFinalDem(allCy,DSBS,YTIME)
                 =E=
         (MVDemFinSubFuelSubsec(allCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), MVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME))
         + SQRT( SQR(MVDemFinSubFuelSubsec(allCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), MVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME))))) /2;

*' This equation calculates the technology share in new equipment based on factors such as maturity factor,
*' cumulative distribution function of consumer size groups, number of consumers, technology cost, distribution function of consumer
*' size groups, and technology sorting.
QShareTechNewEquip(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $runCy(allCy))..
         VShareTechNewEquip(allCy,DSBS,EF,YTIME) =E=
         iMatrFactor(allCy,DSBS,EF,YTIME) / iCumDistrFuncConsSize(allCy,DSBS) *
         sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
                  VCostTech(allCy,DSBS,rCon,EF,YTIME)
                  * iDisFunConSize(allCy,DSBS,rCon)/VSortTechVarCost(allCy,DSBS,rCon,YTIME));

*' This equation calculates the consumption of fuels in each demand subsector, including heat from heat pumps .
*' It considers the consumption of remaining substitutable equipment, the technology share in new equipment, and the final demand
*' gap to be filled by new technologies. Additionally, non-substitutable electricity consumption in Industry and Tertiary sectors is included.
Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $runCy(allCy))..
         MVConsFuelInclHP(allCy,DSBS,EF,YTIME)
                 =E=
         MVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)+
         (VShareTechNewEquip(allCy,DSBS,EF,YTIME)*VGapFinalDem(allCy,DSBS,YTIME))
*'        $(VGapFinalDem.L(allCy,DSBS,YTIME)>0)
         + (MVConsElecNonSubIndTert(allCy,DSBS,YTIME))$(INDDOM(DSBS) and ELCEF(EF));

*' This equation calculates the variable, including fuel electricity production cost per CHP plant and demand sector, taking into account the variable cost (other than fuel)
*' per CHP type and the summation of fuel-related costs for each energy form . The calculation involves fuel prices, CO2 emission factors, boiler efficiency, electricity
*' index, and carbon prices, adjusted by various factors. The equation uses these terms to calculate the variable, including fuel electricity production cost per CHP plant and
*' demand sector. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
QCostProdCHPDem(allCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
         VCostProdCHPDem(allCy,DSBS,CHP,YTIME)
                 =E=
         iVarCostChp(allCy,DSBS,CHP,YTIME)/1E3
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (MVPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),MVCarVal(allCy,NAP,YTIME))))
                         *sTWhToMtoe/(iBoiEffChp(allCy,CHP,YTIME)*MVPriceElecInd(allCy,YTIME)));

*' The equation calculates the average electricity production cost per Combined Heat and Power plant .
*' It involves a summation over demand subsectors . The average electricity production cost is determined by considering the electricity
*' production cost per CHP plant for each demand subsector. The result is expressed in Euro per kilowatt-hour (Euro/KWh).
Q02CostElcAvgProdCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         MVCostElcAvgProdCHP(allCy,CHP,YTIME)
         =E=

         (sum(INDDOM, MVConsFuel(allCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,MVConsFuel(allCy,INDDOM2,CHP,YTIME-1))*VCostElecProdCHP(allCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,MVConsFuel.L(allCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,MVConsFuel.L(allCy,INDDOM2,CHP,YTIME-1)));

*' The equation computes the average variable cost, including fuel and electricity production cost, per Combined Heat and Power plant.
*' The equation involves a summation over demand subsectors , where the variable cost per CHP plant is calculated based on fuel
*' consumption and the variable cost of electricity production . The resulting average variable cost is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The conditional statement ensures that the denominator in the calculation is not zero, avoiding division by zero issues.
Q02CostVarAvgElecProd(allCy,CHP,YTIME)$(TIME(YTIME) $runCy(allCy)) ..
         MVCostVarAvgElecProd(allCy,CHP,YTIME)
         =E=

         (sum(INDDOM, MVConsFuel(allCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,MVConsFuel(allCy,INDDOM2,CHP,YTIME-1))
         *VCostProdCHPDem(allCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,MVConsFuel.L(allCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,MVConsFuel.L(allCy,INDDOM2,CHP,YTIME-1)));
