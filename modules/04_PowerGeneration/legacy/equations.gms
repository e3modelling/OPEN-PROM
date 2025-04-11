*' @title Equations of OPEN-PROMs Power Generation
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' Power Generation

*' This equation computes the current renewable potential, which is the average of the maximum allowed renewable potential and the minimum renewable potential
*' for a given power generation sector and energy form in a specific time period. The result is the current renewable potential in gigawatts (GW). 
QPotRenCurr(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         VPotRenCurr(allCy,PGRENEF,YTIME) 
         =E=
         ( VPotRenMaxAllow(allCy,PGRENEF,YTIME) + iMinRenPotential(allCy,PGRENEF,YTIME))/2;

*' This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
*' including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
*' generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
QCapElecCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapElecCHP(allCy,CHP,YTIME)
         =E=
         1/sTWhToMtoe * sum(INDDOM,VConsFuel(allCy,INDDOM,CHP,YTIME)) * VPriceElecInd(allCy,YTIME)/
         sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
         iUtilRateChpPlants(allCy,CHP,YTIME) /sGwToTwhPerYear;  

*' The "Lambda" parameter is computed in the context of electricity demand modeling. This formula captures the relationship between the load curve construction parameter
*' and the ratio of the differences in electricity demand and corrected base load to the difference between peak load and corrected base load. It plays a role in shaping
*' the load curve for effective electricity demand modeling.
QLambda(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (1 - exp( -VLambda(allCy,YTIME)*sGwToTwhPerYear))  / (0.0001+VLambda(allCy,YTIME))
             =E=
         (VDemElecTot(allCy,YTIME) - sGwToTwhPerYear*VBaseLoad(allCy,YTIME))
         / (VPeakLoad(allCy,YTIME) - VBaseLoad(allCy,YTIME));

*' The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
*' distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
*' which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
*' to the total electricity demand.
QDemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VDemElecTot(allCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VConsFinEneCountry(allCy,"ELC",YTIME) + VConsFinNonEne(allCy,"ELC",YTIME) + VLossesDistr(allCy,"ELC",YTIME)
           + VConsFiEneSec(allCy,"ELC",YTIME) - VImpNetEneBrnch(allCy,"ELC",YTIME)
         );

*' This equation computes the estimated base load as a quantity dependent on the electricity demand per final sector,
*' as well as the baseload share of demand per sector, the rate of losses for final Consumption, the net imports,
*' distribution losses and final consumption in energy sector.
QBsldEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VBsldEst(allCy,YTIME)
             =E=
         (
             sum(DSBS, iBaseLoadShareDem(allCy,DSBS,YTIME)*VConsElec(allCy,DSBS,YTIME))*(1+iRateLossesFinCons(allCy,"ELC",YTIME))*
             (1 - VImpNetEneBrnch(allCy,"ELC",YTIME)/(sum(DSBS, VConsElec(allCy,DSBS,YTIME))+VLossesDistr(allCy,"ELC",YTIME)))
             + 0.5*VConsFiEneSec(allCy,"ELC",YTIME)
         ) / sTWhToMtoe / sGwToTwhPerYear;

*' This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
*' and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
*' of electricity demand per sector
QLoadFacDom(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VLoadFacDom(allCy,YTIME)
             =E=
         (sum(INDDOM,VConsFuel(allCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel(allCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + 
         sum(TRANSE, VDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(TRANSE)));         

*' The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result
*' to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period, taking into account the domestic
*' load factor.
QPeakLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPeakLoad(allCy,YTIME)
             =E=
         VDemElecTot(allCy,YTIME)/(VLoadFacDom(allCy,YTIME)*sGwToTwhPerYear);

*' This equation calculates the baseload corresponding to maximum load by multiplying the maximum load factor of electricity demand
*' to the electricity peak load, minus the baseload corresponding to maximum load factor.
QBaseLoadMax(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (VDemElecTot(allCy,YTIME)-VBaseLoadMax(allCy,YTIME)*sGwToTwhPerYear)
             =E=
         iMxmLoadFacElecDem(allCy,YTIME)*(VPeakLoad(allCy,YTIME)-VBaseLoadMax(allCy,YTIME))*sGwToTwhPerYear;  

*' This equation calculates the electricity base load utilizing exponential functions that include the estimated base load,
*' the baseload corresponding to maximum load factor, and the parameter of baseload correction.
QBaseLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VBaseLoad(allCy,YTIME)
             =E=
         (1/(1+exp(iBslCorrection(allCy,YTIME)*(VBsldEst(allCy,YTIME)-VBaseLoadMax(allCy,YTIME)))))*VBsldEst(allCy,YTIME)
        +(1-1/(1+exp(iBslCorrection(allCy,YTIME)*(VBsldEst(allCy,YTIME)-VBaseLoadMax(allCy,YTIME)))))*VBaseLoadMax(allCy,YTIME);

*' This equation calculates the total required electricity production as a sum of the electricity peak load minus the corrected base load,
*' multiplied by the exponential function of the parameter for load curve construction.
QProdElecReqTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdElecReqTot(allCy,YTIME)
             =E=
         sum(HOUR, (VPeakLoad(allCy,YTIME)-VBaseLoad(allCy,YTIME))
                   * exp(-VLambda(allCy,YTIME)*(0.25+(ord(HOUR)-1)))
             ) + 9*VBaseLoad(allCy,YTIME);   

*' The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
*' the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
*' generation capacity based on the changes in peak load.
QCapElecTotEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VCapElecTotEst(allCy,YTIME)
             =E=
        VCapElecTotEst(allCy,YTIME-1) * VPeakLoad(allCy,YTIME)/VPeakLoad(allCy,YTIME-1);          

*' The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
*' including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
*' The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
*' for renewable plants (excluding certain types) and fossil fuel plants.
QCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)
                  =E=
                  
                    ( ( iDisc(allCy,"PG",YTIME-1) * exp(iDisc(allCy,"PG",YTIME-1)*iTechLftPlaType(allCy,PGALL))
                        / (exp(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) -1))
                      * iGrossCapCosSubRen(allCy,PGALL,YTIME-1)* 1E3 * iCGI(allCy,YTIME-1)  + iFixOandMCost(allCy,PGALL,YTIME-1)
                    )/iAvailRate(PGALL,YTIME-1) / (1000*(ord(HOUR)-1+0.25))
                    + iVarCost(PGALL,YTIME-1)/1E3 + (VRenValue(YTIME-1)*8.6e-5)$( not ( PGREN(PGALL) 
                    $(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) ))
                    + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME-1)+
                        iCO2CaptRate(allCy,PGALL,YTIME-1)*VCstCO2SeqCsts(allCy,YTIME-1)*1e-3*
                    iCo2EmiFac(allCy,"PG",PGEF,YTIME-1)
                         +(1-iCO2CaptRate(allCy,PGALL,YTIME-1))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME-1)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME-1))))
                         *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME-1))$(not PGREN(PGALL));

*' The equation calculates the hourly production cost for
*' a given technology without carbon capture and storage investments. 
*' The result is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The equation is based on the power plant's share in new equipment and
*' the hourly production cost of technology without CCS . Additionally, 
*' it considers the contribution of other technologies with CCS by summing their
*' shares in new equipment multiplied by their respective hourly production
*' costs. The equation reflects the cost dynamics associated with technology investments and provides
*' insights into the hourly production cost for power generation without CCS.
QCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy)) ..
         VCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME) =E=
         VShareNewTechNoCCS(allCy,PGALL,YTIME)*VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS(allCy,CCS,YTIME)*VCostHourProdInvDec(allCy,CCS,HOUR,YTIME)); 

*' The equation reflects a dynamic relationship where the sensitivity
*' to CCS acceptance is influenced by the carbon prices of different countries.
*' The result provides a measure of the sensitivity of CCS acceptance
*' based on the carbon values in the previous year.
QSensCCS(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VSensCCS(allCy,YTIME) =E= 10+EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME-1)))));

*' The equation computes the hourly production cost used in investment decisions, taking into account the acceptance of Carbon Capture and Storage .
*' The production cost is modified based on the sensitivity of CCS acceptance. The sensitivity is used as an exponent
*' to adjust the original production cost for power generation plants during each hour and for the specified year .
*' This adjustment reflects the impact of CCS acceptance on the production cost.
$ontext
qCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         vCostHourProdInvCCS(allCy,PGALL,HOUR,YTIME) 
         =E=
          VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-VSensCCS(allCy,YTIME));
$offtext

*' The equation calculates the production cost of a technology for a specific power plant and year. 
*' The equation involves the hourly production cost of the technology
*' and a sensitivity variable controlling carbon capture and storage acceptance.
*' The summation over hours is weighted by the inverse of the technology's hourly production cost raised to the 
*' power of minus one-fourth of the sensitivity variable. 
QCostProdSpecTech(allCy,PGALL,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         VCostProdSpecTech(allCy,PGALL,YTIME) 
         =E=  
         sum(HOUR,VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-VSensCCS(allCy,YTIME))) ;

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is implemented. The
*' share is determined based on a formulation that considers the production costs of the technology.
*' The numerator of the share calculation involves a factor of 1.1 multiplied
*' by the production cost of the technology for the specific power plant and year. The denominator
*' includes the sum of the numerator and the production costs of other power plant types without CCS.
QShareNewTechCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $CCS(PGALL) $runCy(allCy))..
         VShareNewTechCCS(allCy,PGALL,YTIME) =E=
         1.1 *VCostProdSpecTech(allCy,PGALL,YTIME)
         /(1.1*VCostProdSpecTech(allCy,PGALL,YTIME)
           + sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),VCostProdSpecTech(allCy,PGALL2,YTIME))
           );         

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is not implemented .
*' The equation is based on the complementarity relationship, expressing that the power plant's share in
*' new equipment without CCS is equal to one minus the sum of the shares of power plants with CCS in the
*' new equipment. The sum is taken over all power plants with CCS for the given power plant type and year .
QShareNewTechNoCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy))..
         VShareNewTechNoCCS(allCy,PGALL,YTIME) 
         =E= 
         1 - sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS(allCy,CCS,YTIME));

*' Compute the variable cost of each power plant technology for every region,
*' By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
QCostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
         VCostVarTech(allCy,PGALL,YTIME) 
             =E=
         (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)
         + (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)
          *(sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))
          *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME))$(not PGREN(PGALL)));

*' The equation calculates the variable for a specific
*' power plant and year when the power plant is not subject to endogenous scrapping. The calculation involves raising the variable
*' cost of the technology for the specified power plant and year to the power of -5.
QCostVarTechNotPGSCRN(allCy,PGALL,YTIME)$(time(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         VCostVarTechNotPGSCRN(allCy,PGALL,YTIME) 
              =E=
          VCostVarTech(allCy,PGALL,YTIME)**(-5);

*' The equation calculates the production cost of a technology 
*' for a specific power plant and year. The equation involves various factors, including discount rates, technical
*' lifetime of the plant type, gross capital cost with subsidies for renewables, capital goods index, fixed operation 
*' and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, CO2 capture rates, cost
*' curve for CO2 sequestration costs, CO2 emission factors, carbon values, plant efficiency, and specific conditions excluding
*' renewable power plants . The equation reflects the complex dynamics of calculating the production cost, considering both economic and technical parameters.
QCostProdTeCHPreReplac(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostProdTeCHPreReplac(allCy,PGALL,YTIME) =e=
                        (
                          ((iDisc(allCy,"PG",YTIME) * exp(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL))/
                          (exp(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) -1))
                            * iGrossCapCosSubRen(allCy,PGALL,YTIME)* 1E3 * iCGI(allCy,YTIME)  + 
                            iFixOandMCost(allCy,PGALL,YTIME))/(8760*iAvailRate(PGALL,YTIME))
                           + (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), 
                           (VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+
                            iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                             (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))
                                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME))$(not PGREN(PGALL)))
                         );

*' The equation calculates the production cost of a technology used in premature replacement,
*' considering plant availability rates. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
*' The equation involves the production cost of the technology used in premature replacement without considering availability rates 
*' and incorporates adjustments based on the availability rates of two power plants .
QCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME) =E=
         iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME)*VCostProdTeCHPreReplac(allCy,PGALL,YTIME)+
         VCostVarTech(allCy,PGALL,YTIME)*(1-iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME));  

*' The equation computes the endogenous scrapping index for power generation plants  during the specified year .
*' The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
*' divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
*' parameter is applied to the sum of full costs and raised to the power of -5. The resulting index is used to determine the endogenous scrapping of power plants.
QIndxEndogScrap(allCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         VIndxEndogScrap(allCy,PGALL,YTIME)
                 =E=
         VCostVarTechNotPGSCRN(allCy,PGALL,YTIME)/
         (VCostVarTechNotPGSCRN(allCy,PGALL,YTIME)+(iScaleEndogScrap(PGALL)*
         sum(PGALL2,VCostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)))**(-5));

*' The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
*' It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
*' total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
QCapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapElecNonCHP(allCy,YTIME)
          =E=
VCapElecTotEst(allCy,YTIME) - SUM(CHP,VCapElecCHP(allCy,CHP,YTIME)*0.85);      

*' In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
*' decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
QGapGenCapPowerDiff(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VGapGenCapPowerDiff(allCy,YTIME)
             =E=
 (        (  VCapElecNonCHP(allCy,YTIME) - VCapElecNonCHP(allCy,YTIME-1) + sum(PGALL,VCapElec2(allCy,PGALL,YTIME-1) * 
 (1 - VIndxEndogScrap(allCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(allCy,PGALL,YTIME)-iDecInvPlantSched(allCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VCapElec(allCy,PGALL,YTIME-1)-iPlantDecomSched(allCy,PGALL,YTIME))/
          iTechLftPlaType(allCy,PGALL))
       )
  + 0 + SQRT( SQR(       (  VCapElecNonCHP(allCy,YTIME) - VCapElecNonCHP(allCy,YTIME-1) +
        sum(PGALL,VCapElec2(allCy,PGALL,YTIME-1) * (1 - VIndxEndogScrap(allCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(allCy,PGALL,YTIME)-iDecInvPlantSched(allCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VCapElec(allCy,PGALL,YTIME-1)-iPlantDecomSched(allCy,PGALL,YTIME))/
          iTechLftPlaType(allCy,PGALL))
       ) -0) + SQR(1e-10) ) )/2;

*' The equation  calculates a temporary variable 
*' that facilitates the scaling in the Weibull equation. The equation involves
*' the hourly production costs of technology for power plants
*' with carbon capture and storage and without CCS . The production 
*' costs are raised to the power of -6, and the result is used as a scaling factor
*' in the Weibull equation. The equation captures the cost-related considerations 
*' in determining the scaling factor for the Weibull equation based on the production costs of different technologies.
$ontext
qScalWeibull(allCy,PGALL,HOUR,YTIME)$((not CCS(PGALL))$TIME(YTIME) $runCy(allCy))..
          vScalWeibull(allCy,PGALL,HOUR,YTIME) 
         =E=
         (VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
         +
          VCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$NOCCS(PGALL))**(-6);     
$offtext

*' The equation calculates the renewable potential supply curve for a specified year. Including:
*' The minimum renewable potential for the given renewable energy form and country in the specified year.
*' The carbon price value associated with the country in the specified year for the purpose of renewable potential estimation,
*' the "Trade" attribute refers to tradable permits (if carbon pricing exists in the form of an emissions trading scheme).
*' The maximum renewable potential for the specified renewable energy form  and country in the given year.
*' The renewable potential supply curve is then calculated by linearly interpolating between the minimum and maximum renewable potentials based on the trade value.
*' The trade value is normalized by dividing it by 70. The equation essentially defines a linear relationship between the trade value and the renewable potential within
*' the specified range.
QPotRenSuppCurve(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPotRenSuppCurve(allCy,PGRENEF,YTIME) =E=
         iMinRenPotential(allCy,PGRENEF,YTIME) +(VCarVal(allCy,"Trade",YTIME))/(70)*
         (iMaxRenPotential(allCy,PGRENEF,YTIME)-iMinRenPotential(allCy,PGRENEF,YTIME));

*' *The equation calculates the maximum allowed renewable potential for a specific renewable energy form and country in the
*' given year . Including:
*' VThe renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in the previous equation.
*' The maximum renewable potential for the specified renewable energy form and country in the given year.
*' The maximum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the maximum renewable potential.
*' This formulation ensures that the potential does not exceed the maximum allowed value. 
QPotRenMaxAllow(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..      
         VPotRenMaxAllow(allCy,PGRENEF,YTIME) =E=
         ( VPotRenSuppCurve(allCy,PGRENEF,YTIME)+ iMaxRenPotential(allCy,PGRENEF,YTIME))/2;

*' The equation calculates the minimum allowed renewable potential for a specific renewable energy form and country 
*' in the given year . Including:
*' The renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in a previous equation.
*' The minimum renewable potential for the specified renewable energy form and country in the given year.
*' The minimum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the minimum renewable potential.
*' This formulation ensures that the potential does not fall below the minimum allowed value.
$ontext
qPotRenMinAllow(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..  
         vPotRenMinAllow(allCy,PGRENEF,YTIME) =E=
         ( VPotRenSuppCurve(allCy,PGRENEF,YTIME) + iMinRenPotential(allCy,PGRENEF,YTIME))/2;
$offtext
*' The equation calculates a maturity multiplier for renewable technologies. If the technology is renewable , the multiplier is determined
*' based on an exponential function that involves the ratio of the planned electricity generation capacities of renewable technologies to the renewable potential
*' supply curve. This ratio is adjusted using a logistic function with parameters that influence the maturity of renewable technologies. If the technology is not
*' renewable, the maturity multiplier is set to 1. The purpose is to model the maturity level of renewable technologies based on their
*' planned capacities relative to the renewable potential supply curve.
QRenTechMatMultExpr(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
VRenTechMatMultExpr(allCy,PGALL,YTIME)
=E=
                 sum(PGRENEF$PGALLtoPGRENEF(PGALL,PGRENEF),
                 sum(PGALL2$(PGALLtoPGRENEF(PGALL2,PGRENEF) $PGREN(PGALL2)),
                 VCapElec2(allCy,PGALL2,YTIME-1))/VPotRenCurr(allCy,PGRENEF,YTIME))-0.6;



QRenTechMatMult(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VRenTechMatMult(allCy,PGALL,YTIME)
          =E=
         1$(NOT PGREN(PGALL))
         +
         (
           1/(1+exp(5*VRenTechMatMultExpr(allCy,PGALL,YTIME)))
           )$PGREN(PGALL);  

*' The equation calculates a temporary variable which is used to facilitate scaling in the Weibull equation. The scaling is influenced by three main factors:
*' Maturity Factor for Planned Available Capacity : This factor represents the material-specific influence on the planned available capacity for a power
*' plant. It accounts for the capacity planning aspect of the power generation technology.
*' Renewable Technologies Maturity Multiplier: This multiplier reflects the maturity level of renewable technologies. It adjusts the scaling based on how
*' mature and established the renewable technology is, with a higher maturity leading to a larger multiplier.
*' Hourly Production Costs : The summation involves the hourly production costs of the technology raised to the power of -6. This suggests that higher
*' production costs contribute less to the overall scaling, emphasizing the importance of cost efficiency in the scaling process.
*' The result is a combined measure that takes into account material factors, technology maturity, and cost efficiency in the context of the Weibull
*' equation, providing a comprehensive basis for scaling considerations.
QScalWeibullSum(allCy,PGALL,YTIME)$((not CCS(PGALL)) $TIME(YTIME) $runCy(allCy))..
         VScalWeibullSum(allCy,PGALL,YTIME) 
         =E=
              iMatFacPlaAvailCap(allCy,PGALL,YTIME) * VRenTechMatMult(allCy,PGALL,YTIME)*
              sum(HOUR,
                 (VCostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
                 +
                 VCostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$NOCCS(PGALL)
                 )**(-6)
              ); 
  
*' The equation calculates the variable representing the new investment decision for power plants in a given country and time period.
*' It sums the values for all power plants that do not have carbon capture and storage technology .
*' The values capture the scaling factors influenced by material-specific factors, renewable technology maturity,
*' and cost efficiency considerations. Summing these values over relevant power plants provides an aggregated measure for informing new investment decisions, emphasizing
*' factors such as technology readiness and economic viability.
QNewInvElec(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VNewInvElec(allCy,YTIME)
             =E=
         sum(PGALL$(not CCS(PGALL)),VScalWeibullSum(allCy,PGALL,YTIME));

*' The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
*' and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
*' For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
*' overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
*' as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
*' without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
QSharePowPlaNewEq(allCy,PGALL,YTIME)$(TIME(YTIME) $runCy(allCy)) ..
        VSharePowPlaNewEq(allCy,PGALL,YTIME)
             =E=
         ( VScalWeibullSum(allCy,PGALL,YTIME)/ VNewInvElec(allCy,YTIME))$(not CCS(PGALL))
          +
          sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),VSharePowPlaNewEq(allCy,NOCCS,YTIME))$CCS(PGALL);

*' This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
*' and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
*' The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
QCapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapElec(allCy,PGALL,YTIME)
             =E=
         (VCapElec2(allCy,PGALL,YTIME-1)*VIndxEndogScrap(allCy,PGALL,YTIME-1)
          +(VSharePowPlaNewEq(allCy,PGALL,YTIME) * VGapGenCapPowerDiff(allCy,YTIME))$( (not CCS(PGALL)) AND (not NOCCS(PGALL)))
          +(VSharePowPlaNewEq(allCy,PGALL,YTIME) * VShareNewTechNoCCS(allCy,PGALL,YTIME) * VGapGenCapPowerDiff(allCy,YTIME))$NOCCS(PGALL)
          +(VSharePowPlaNewEq(allCy,PGALL,YTIME) * VShareNewTechNoCCS(allCy,PGALL,YTIME) * VGapGenCapPowerDiff(allCy,YTIME))$CCS(PGALL)
          + iDecInvPlantSched(allCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
          - iPlantDecomSched(allCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
         )
         - ((VCapElec(allCy,PGALL,YTIME-1)-iPlantDecomSched(allCy,PGALL,YTIME-1))* 
         iAvailRate(PGALL,YTIME)*(1/iTechLftPlaType(allCy,PGALL)))$PGSCRN(PGALL);

*' This equation calculates the variable representing the planned electricity generation capacity for a specific power plant  in a given country
*' and time period. The calculation involves adjusting the actual electricity generation capacity by a small constant and the square
*' root of the sum of the square of the capacity and a small constant. The purpose of this adjustment is likely to avoid numerical issues and ensure a positive value for
*' the planned capacity.
QCapElec2(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapElec2(allCy,PGALL,YTIME)
             =E=
         ( VCapElec(allCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VCapElec(allCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*' Compute the variable cost of each power plant technology for every region,
*' by utilizing the maturity factor related to plant dispatching.
QCostVarTechElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostVarTechElec(allCy,PGALL,YTIME)
         =E=  
          iMatureFacPlaDisp(allCy,PGALL,YTIME)*VCostVarTech(allCy,PGALL,YTIME)**(-2);

*' Compute the electricity peak loads of each region,
*' as a sum of the variable costs of all power plant technologies.
QCostVarTechElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostVarTechElecTot(allCy,YTIME) 
         =E= 
         sum(PGALL, VCostVarTechElec(allCy,PGALL,YTIME));     

*' Compute power plant sorting to decide the plant dispatching. 
*' This is accomplished by dividing the variable cost by the peak loads.
QSortPlantDispatch(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VSortPlantDispatch(allCy,PGALL,YTIME)
                 =E=
         VCostVarTechElec(allCy,PGALL,YTIME)
         /
         VCostVarTechElecTot(allCy,YTIME);  

*' This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
*' in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
*' from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
*' power plants on a yearly basis.
QNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
         VNewCapElec(allCy,PGALL,YTIME) =e=
VCapElec2(allCy,PGALL,YTIME)- VCapElec2(allCy,PGALL,YTIME-1);                       

*' This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
*' in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
*' possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
*' as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
*' over these eight periods.
QCFAvgRen(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
   VCFAvgRen(allCy,PGALL,YTIME)
      =E=
    (iAvailRate(PGALL,YTIME)*VNewCapElec(allCy,PGALL,YTIME)+
     iAvailRate(PGALL,YTIME-1)*VNewCapElec(allCy,PGALL,YTIME-1)+
     iAvailRate(PGALL,YTIME-2)*VNewCapElec(allCy,PGALL,YTIME-2)+
     iAvailRate(PGALL,YTIME-3)*VNewCapElec(allCy,PGALL,YTIME-3)+
     iAvailRate(PGALL,YTIME-4)*VNewCapElec(allCy,PGALL,YTIME-4)+
     iAvailRate(PGALL,YTIME-5)*VNewCapElec(allCy,PGALL,YTIME-5)+
     iAvailRate(PGALL,YTIME-6)*VNewCapElec(allCy,PGALL,YTIME-6)+
     iAvailRate(PGALL,YTIME-7)*VNewCapElec(allCy,PGALL,YTIME-7))/
(VNewCapElec(allCy,PGALL,YTIME)+VNewCapElec(allCy,PGALL,YTIME-1)+VNewCapElec(allCy,PGALL,YTIME-2)+
VNewCapElec(allCy,PGALL,YTIME-3)+VNewCapElec(allCy,PGALL,YTIME-4)+VNewCapElec(allCy,PGALL,YTIME-5)+
VNewCapElec(allCy,PGALL,YTIME-6)+VNewCapElec(allCy,PGALL,YTIME-7));

*' This equation calculates the variable representing the overall capacity for a specific power plant in a given country and time period .
*' The overall capacity is a composite measure that includes the existing capacity for non-renewable power plants and the expected capacity for renewable power plants based
*' on their average capacity factor.
QCapOverall(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
     VCapOverall(allCy,PGALL,YTIME)
     =E=
VCapElec2(allCy,pgall,ytime)$ (not PGREN(PGALL))
+VCFAvgRen(allCy,PGALL,YTIME-1)*(VNewCapElec(allCy,PGALL,YTIME)/iAvailRate(PGALL,YTIME)+
VCapOverall(allCy,PGALL,YTIME-1)
/VCFAvgRen(allCy,PGALL,YTIME-1))$PGREN(PGALL);

*' This equation calculates the scaling factor for plant dispatching in a specific country , hour of the day,
*' and time period . The scaling factor for determining the dispatch order of different power plants during a particular hour.
$ontext
qScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy))) ..
vScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)
=E=
-VScalFacPlaDisp(allCy,HOUR,YTIME)/VSortPlantDispatch(allCy,PGALL,YTIME);
$offtext


QScalFacPlantDispatch(allCy,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         sum(PGALL,
                 (VCapOverall(allCy,PGALL,YTIME)+
                 sum(CHP$CHPtoEON(CHP,PGALL),VCapElecCHP(allCy,CHP,YTIME)))*
                 exp(-VScalFacPlaDisp(allCy,HOUR,YTIME)/VSortPlantDispatch(allCy,PGALL,YTIME))
                 )
         =E=
         (VPeakLoad(allCy,YTIME) - VBaseLoad(allCy,YTIME))
         * exp(-VLambda(allCy,YTIME)*(0.25 + ord(HOUR)-1))
         + VBaseLoad(allCy,YTIME);

*' This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
*' The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
*' electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
*' share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
QProdElecEstCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdElecEstCHP(allCy,YTIME) 
         =E=
         ( (1/0.086 * sum((INDDOM,CHP),VConsFuel(allCy,INDDOM,CHP,YTIME)) * VPriceElecInd(allCy,YTIME)) + 
         iMxmShareChpElec(allCy,YTIME)*VDemElecTot(allCy,YTIME) - SQRT( SQR((1/0.086 * sum((INDDOM,CHP),VConsFuel(allCy,INDDOM,CHP,YTIME)) * 
         VPriceElecInd(allCy,YTIME)) - 
         iMxmShareChpElec(allCy,YTIME)*VDemElecTot(allCy,YTIME)) + SQR(1E-4) ) )/2;

*' This equation calculates the non-Combined Heat and Power electricity production in a specific country and time period .
*' It is essentially the difference between the total electricity demand and the estimated electricity generation from CHP plants .In summary,
*' the equation calculates the electricity production from technologies other than CHP by subtracting the estimated CHP electricity generation from the total electricity
*' demand. 
QProdElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdElecNonCHP(allCy,YTIME) 
         =E=
  (VDemElecTot(allCy,YTIME) - VProdElecEstCHP(allCy,YTIME));  

*' This equation calculates the total required electricity production for a specific country and time period .
*' The total required electricity production is the sum of electricity generation from different technologies, including CHP plants, across all hours of the day.
*' The total required electricity production is the sum of the electricity generation from all CHP plants across all hours, considering the scaling factor for plant
*' dispatching. 
QProdElecReqCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
VProdElecReqCHP(allCy,YTIME) 
                   =E=
         sum(hour, sum(CHP,VCapElecCHP(allCy,CHP,YTIME)*exp(-VScalFacPlaDisp(allCy,HOUR,YTIME)/ 
         sum(pgall$chptoeon(chp,pgall),VSortPlantDispatch(allCy,PGALL,YTIME)))));

*' This equation calculates the electricity production from power generation plants for a specific country ,
*' power generation plant type , and time period . The electricity production is determined based on the overall electricity
*' demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
*' from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
*' capacity and the scaling factor for dispatching.
QProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdElec(allCy,PGALL,YTIME)
                 =E=
         VProdElecNonCHP(allCy,YTIME) /
         (VProdElecReqTot(allCy,YTIME)- VProdElecReqCHP(allCy,YTIME))
         * VCapElec2(allCy,PGALL,YTIME)* sum(HOUR, exp(-VScalFacPlaDisp(allCy,HOUR,YTIME)/VSortPlantDispatch(allCy,PGALL,YTIME)));

*' This equation calculates the sector contribution to total Combined Heat and Power production . The contribution
*' is calculated for a specific country , industrial sector , CHP technology , and time period .The sector contribution
*' is calculated by dividing the fuel consumption of the specific industrial sector for CHP by the total fuel consumption of CHP across all industrial
*' sectors. The result represents the proportion of CHP production attributable to the specified industrial sector. The denominator has a small constant
*' (1e-6) added to avoid division by zero.
$ontext
qSecContrTotCHPProd(allCy,INDDOM,CHP,YTIME)$(TIME(YTIME) $SECTTECH(INDDOM,CHP) $runCy(allCy))..
         vSecContrTotCHPProd(allCy,INDDOM,CHP,YTIME) 
          =E=
         VConsFuel(allCy,INDDOM,CHP,YTIME)/(1e-6+SUM(INDDOM2,VConsFuel(allCy,INDDOM2,CHP,YTIME)));
$offtext

*' This equation calculates the electricity production from Combined Heat and Power plants . The electricity production is computed
*' for a specific country , CHP technology , and time period.The electricity production from CHP plants is computed by taking the
*' ratio of the fuel consumption by the specified industrial sector for CHP technology to the total fuel consumption for all industrial sectors and CHP
*' technologies. This ratio is then multiplied by the difference between total electricity demand and the sum of electricity production from all power
*' generation plants. The result represents the portion of electricity production from CHP plants attributed to the specified CHP technology.
QProdElecCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdElecCHP(allCy,CHP,YTIME)
                 =E=
        sum(INDDOM,VConsFuel(allCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VConsFuel(allCy,INDDOM,CHP2,YTIME)))*
        (VDemElecTot(allCy,YTIME) - SUM(PGALL,VProdElec(allCy,PGALL,YTIME)));

*' This equation calculates the long-term power generation cost of technologies excluding climate policies.
*' The cost is computed for a specific country, power generation technology , energy sector, and time period.
*' The long-term power generation cost is computed as a combination of capital costs, operating and maintenance costs, and variable costs,
*' considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the availability
*' rate and conversion factors. The equation provides a comprehensive calculation of the long-term cost associated with power generation technologies,
*' excluding climate policy-related costs.
QCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(allCy,"PG",YTIME)*EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) /
             (EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL))-1)*iGrossCapCosSubRen(allCy,PGALL,YTIME)*1000*iCGI(allCy,YTIME) +
             iFixOandMCost(allCy,PGALL,YTIME))/iAvailRate(PGALL,YTIME)
              / (1000*(6$ISET(ESET)+4$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+
                 iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                 (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME)));

*' This equation calculates the long-term minimum power generation cost for a specific country , power generation technology,
*' and time period. The minimum cost is computed considering various factors, including discount rates, technological lifetimes, gross capital costs,
*' fixed operating and maintenance costs, availability rates, variable costs, fuel prices, carbon capture rates, carbon capture and storage costs, carbon
*' emission factors, and plant efficiency.The long-term minimum power generation cost is calculated as a combination of capital costs, operating and maintenance
*' costs, and variable costs, considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the
*' availability rate and conversion factors. This equation provides insight into the minimum cost associated with power generation technologies, excluding climate
*' policy-related costs, and uses a consistent conversion factor for power capacity.
$ontext
qCostPowGenLonMin(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         vCostPowGenLonMin(allCy,PGALL,YTIME)
                 =E=

             (iDisc(allCy,"PG",YTIME)*EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) /
             (EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL))-1)*iGrossCapCosSubRen(allCy,PGALL,YTIME)*1000*iCGI(allCy,YTIME) +
             iFixOandMCost(allCy,PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*sGwToTwhPerYear) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+

                 iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME)));   
$offtext

*' This equation calculates the long-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable costs
*' associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the long-term power generation
*' cost per unit of electricity produced in the given time period. The equation also includes factors such as discount rates, plant availability rates, and the gross
*' capital cost per plant type with subsidies for renewables.
$ontext
qCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         vCostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(allCy,"PG",YTIME)*EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) /
             (EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL))-1)*iGrossCapCosSubRen(allCy,PGALL,YTIME)/1.5*1000*iCGI(allCy,YTIME) +
             iFixOandMCost(allCy,PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME))); 
$offtext

*' This equation calculates the short-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable
*' costs associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the short-term power
*' generation cost per unit of electricity produced in the given time period.
$ontext
qCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         vCostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)
                 =E=
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME)));    
$offtext

*' This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
*' plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
*' electricity consumed in the given time period.
QCostPowGenAvgLng(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostPowGenAvgLng(allCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, VProdElec(allCy,PGALL,YTIME)*VCostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VCostElcAvgProdCHP(allCy,CHP,YTIME)*VProdElecCHP(allCy,CHP,YTIME))
         )
/VDemElecTot(allCy,YTIME); 

*' The equation represents the long-term average power generation cost excluding climate policies.
*' It calculates the cost in Euro2005 per kilowatt-hour (kWh) for a specific combination of parameters. The equation is composed 
*' of various factors, including discount rates, technical lifetime of the plant type, gross capital cost with subsidies for renewables,
*' fixed operation and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, efficiency values, CO2 emission factors,
*' CO2 capture rates, and carbon prices. The equation incorporates a summation over different plant fuel types and considers the cost curve for CO2 sequestration.
*' The final result is the average power generation cost per unit of electricity produced, taking into account various economic and technical parameters.
QCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(allCy,"PG",YTIME)*EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL)) /
             (EXP(iDisc(allCy,"PG",YTIME)*iTechLftPlaType(allCy,PGALL))-1)*iGrossCapCosSubRen(allCy,PGALL,YTIME)*1000*iCGI(allCy,YTIME) +
             iFixOandMCost(allCy,PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)-iEffValueInDollars(allCy,"PG",ytime)/1000-iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))/1000 )/1.2441+

                 iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME)));

*' Compute long term power generation cost excluding climate policies by summing the Electricity production multiplied by Long-term average power generation cost excluding 
*' climate policies added to the sum of Average Electricity production cost per CHP plant multiplied by the CHP electricity production and all of the above divided by 
*' the Total electricity demand.
QCostPowGenLonNoClimPol(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostPowGenLonNoClimPol(allCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, (VProdElec(allCy,PGALL,YTIME))*VCostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VCostElcAvgProdCHP(allCy,CHP,YTIME)*VProdElecCHP(allCy,CHP,YTIME))
         )
/(VDemElecTot(allCy,YTIME));  

*' This equation establishes a common variable (with arguments) for the electricity consumption per demand subsector of INDUSTRY, [DOMESTIC/TERTIARY/RESIDENTIAL] and TRANSPORT.
*' The electricity consumption of the demand subsectors of INDUSTRY & [DOMESTIC/TERTIARY/RESIDENTIAL] is provided by the consumption of Electricity as a Fuel.
*' The electricity consumption of the demand subsectors of TRANSPORT is provided by the Demand of Transport for Electricity as a Fuel.
QConsElec(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsElec(allCy,DSBS,YTIME)
             =E=
         sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel(allCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME));


*' This equation computes the short-term average power generation cost. It involves summing the variable production costs for different power generation plants and
*' energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of electricity
*' consumed in the given time period.
$ontext
qCostPowGenAvgShrt(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

        vCostPowGenAvgShrt(allCy,ESET,YTIME)
                 =E=
        (
        sum(PGALL,
        VProdElec(allCy,PGALL,YTIME)*
        (
        sum(PGEF$PGALLtoEF(PGALL,PGEF),
        (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(allCy,PGALL,YTIME)*VCstCO2SeqCsts(allCy,YTIME)*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME) +
         (1-iCO2CaptRate(allCy,PGALL,YTIME))*1e-3*iCo2EmiFac(allCy,"PG",PGEF,YTIME)*
         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(allCy,PGALL,YTIME)))
        ))
        +
         sum(CHP, VCostVarAvgElecProd(allCy,CHP,YTIME)*VProdElecCHP(allCy,CHP,YTIME))
         )
         /VDemElecTot(allCy,YTIME);
$offtext
