*' @title Equations of OPEN-PROM
*' @code
*' Power Generation


*' This equation computes the current renewable potential, which is the average of the maximum allowed renewable potential and the minimum renewable potential
*' for a given power generation sector and energy form in a specific time period. The result is the current renewable potential in gigawatts (GW). 
QPotRenCurr(runCy,PGRENEF,YTIME)$TIME(YTIME)..

         VPotRenCurr(runCy,PGRENEF,YTIME) 
         =E=
         ( VPotRenMaxAllow(runCy,PGRENEF,YTIME) + iMinRenPotential(runCy,PGRENEF,YTIME))/2;

*' This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
*' including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
*' generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
QCapElecChp(runCy,CHP,YTIME)$TIME(YTIME)..
         VCapElecChp(runCy,CHP,YTIME)
         =E=
         1/sTWhToMtoe * sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME)) * VPriceElecInd(runCy,YTIME)/
         sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
         iUtilRateChpPlants(runCy,CHP,YTIME) /sGwToTwhPerYear;  

*' The "Lambda" parameter is computed in the context of electricity demand modeling. This formula captures the relationship between the load curve construction parameter
*' and the ratio of the differences in electricity demand and corrected base load to the difference between peak load and corrected base load. It plays a role in shaping
*' the load curve for effective electricity demand modeling.
QLambda(runCy,YTIME)$TIME(YTIME)..
         (1 - exp( -VLambda(runCy,YTIME)*sGwToTwhPerYear))  / VLambda(runCy,YTIME)
             =E=
         (VDemElecTot(runCy,YTIME) - sGwToTwhPerYear*VBaseLoad(runCy,YTIME))
         / (VPeakLoad(runCy,YTIME) - VBaseLoad(runCy,YTIME));

*' The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
*' distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
*' which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
*' to the total electricity demand.
QDemElecTot(runCy,YTIME)$TIME(YTIME)..
         VDemElecTot(runCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VConsFinEneCountry(runCy,"ELC",YTIME) + VConsFinNonEne(runCy,"ELC",YTIME) + VLossesDistr(runCy,"ELC",YTIME)
           + VConsFiEneSec(runCy,"ELC",YTIME) - iNetImp(runCy,"ELC",YTIME)
         );

*' This equation computes the estimated base load as a quantity dependent on the electricity demand per final sector,
*' as well as the baseload share of demand per sector, the rate of losses for final Consumption, the net imports,
*' distribution losses and final consumption in energy sector.
QBsldEst(runCy,YTIME)$TIME(YTIME)..
         VBsldEst(runCy,YTIME)
             =E=
         (
             sum(DSBS, iBaseLoadShareDem(runCy,DSBS,YTIME)*VConsElec(runCy,DSBS,YTIME))*(1+iRateLossesFinCons(runCy,"ELC",YTIME))*
             (1 - VImpNetEneBrnch(runCy,"ELC",YTIME)/(sum(DSBS, VConsElec(runCy,DSBS,YTIME))+VLossesDistr(runCy,"ELC",YTIME)))
             + 0.5*VConsFiEneSec(runCy,"ELC",YTIME)
         ) / sTWhToMtoe / sGwToTwhPerYear;

*' This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
*' and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
*' of electricity demand per sector
QLoadFacDom(runCy,YTIME)$TIME(YTIME)..
         VLoadFacDom(runCy,YTIME)
             =E=
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + 
         sum(TRANSE, VDemFinEneTranspPerFuel(runCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(TRANSE)));         

*' The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result
*' to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period, taking into account the domestic
*' load factor.
QPeakLoad(runCy,YTIME)$TIME(YTIME)..
         VPeakLoad(runCy,YTIME)
             =E=
         VDemElecTot(runCy,YTIME)/(VLoadFacDom(runCy,YTIME)*sGwToTwhPerYear);

*' This equation calculates the baseload corresponding to maximum load by multiplying the maximum load factor of electricity demand
*' to the electricity peak load, minus the baseload corresponding to maximum load factor.
QBaseLoadMax(runCy,YTIME)$TIME(YTIME)..
         (VDemElecTot(runCy,YTIME)-VBaseLoadMax(runCy,YTIME)*sGwToTwhPerYear)
             =E=
         iMxmLoadFacElecDem(runCy,YTIME)*(VPeakLoad(runCy,YTIME)-VBaseLoadMax(runCy,YTIME))*sGwToTwhPerYear;  

*' This equation calculates the electricity base load utilizing exponential functions that include the estimated base load,
*' the baseload corresponding to maximum load factor, and the parameter of baseload correction.
QBaseLoad(runCy,YTIME)$TIME(YTIME)..
         VBaseLoad(runCy,YTIME)
             =E=
         (1/(1+(iBslCorrection(runCy,YTIME)*(VBsldEst(runCy,YTIME)-VBaseLoadMax(runCy,YTIME)))))*VBsldEst(runCy,YTIME)
        +(1-1/(1+(iBslCorrection(runCy,YTIME)*(VBsldEst(runCy,YTIME)-VBaseLoadMax(runCy,YTIME)))))*VBaseLoadMax(runCy,YTIME);

*' This equation calculates the total required electricity production as a sum of the electricity peak load minus the corrected base load,
*' multiplied by the exponential function of the parameter for load curve construction.
QProdReqTotElec(runCy,YTIME)$TIME(YTIME)..
         VProdReqTotElec(runCy,YTIME)
             =E=
         sum(HOUR, (VPeakLoad(runCy,YTIME)-VBaseLoad(runCy,YTIME))
                   * exp(-VLambda(runCy,YTIME)*(0.25+(ord(HOUR)-1)))
             ) + 9*VBaseLoad(runCy,YTIME);   

*' The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
*' the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
*' generation capacity based on the changes in peak load.
QCapElecTotEst(runCy,YTIME)$TIME(YTIME)..
        VCapElecTotEst(runCy,YTIME)
             =E=
        VCapElecTot(runCy,YTIME-1) * VPeakLoad(runCy,YTIME)/VPeakLoad(runCy,YTIME-1);          

*' The equation sets the total electricity generation capacity for a given year equal to the estimated total electricity generation capacity for the same year.
*' This implies that the estimated capacity is considered as the actual capacity for the specified year.
QCapElecTot(runCy,YTIME)$TIME(YTIME)..
        VCapElecTot(runCy,YTIME) 
        =E=
     VCapElecTotEst(runCy,YTIME);  

*' The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
*' including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
*' The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
*' for renewable plants (excluding certain types) and fossil fuel plants.
QCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME)) ..
         VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)
                  =E=
                  
                    ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))
                        / (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
                      * iGrossCapCosSubRen(PGALL,YTIME)* 1E3 * iCGI(runCy,YTIME)  + iFixOandMCost(PGALL,YTIME)
                    )/iAvailRate(PGALL,YTIME) / (1000*(ord(HOUR)-1+0.25))
                    + iVarCost(PGALL,YTIME)/1E3 + (VRenValue(YTIME)*8.6e-5)$( not ( PGREN(PGALL) 
                    $(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) ))
                    + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)+
                        iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*
                    iCo2EmiFac(runCy,"PG",PGEF,YTIME)
                         +(1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL));

*' The equation calculates the hourly production cost for
*' a given technology without carbon capture and storage investments. 
*' The result is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The equation is based on the power plant's share in new equipment and
*' the hourly production cost of technology without CCS . Additionally, 
*' it considers the contribution of other technologies with CCS by summing their
*' shares in new equipment multiplied by their respective hourly production
*' costs. The equation reflects the cost dynamics associated with technology investments and provides
*' insights into the hourly production cost for power generation without CCS.
QCostHourProdInvDecNoCcs(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $NOCCS(PGALL)) ..
         VCostHourProdInvDecNoCcs(runCy,PGALL,HOUR,YTIME) =E=
         VShareNewTechNoCcs(runCy,PGALL,YTIME)*VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCcs(runCy,CCS,YTIME)*VCostHourProdInvDec(runCy,CCS,HOUR,YTIME)); 

*' The equation reflects a dynamic relationship where the sensitivity
*' to CCS acceptance is influenced by the carbon prices of different countries.
*' The result provides a measure of the sensitivity of CCS acceptance
*' based on the carbon values in the previous year.
QSensCcs(runCy,YTIME)$TIME(YTIME)..
         VSensCcs(runCy,YTIME) =E= 20+25*EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME-1)))));

*' The equation computes the hourly production cost used in investment decisions, taking into account the acceptance of Carbon Capture and Storage .
*' The production cost is modified based on the sensitivity of CCS acceptance. The sensitivity is used as an exponent
*' to adjust the original production cost for power generation plants during each hour and for the specified year .
*' This adjustment reflects the impact of CCS acceptance on the production cost.
qCostHourProdInvCCS(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL))) ..
         vCostHourProdInvCCS(runCy,PGALL,HOUR,YTIME) 
         =E=
          VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)**(-VSensCcs(runCy,YTIME)/4);

*' The equation calculates the production cost of a technology for a specific power plant and year. 
*' The equation involves the hourly production cost of the technology
*' and a sensitivity variable controlling carbon capture and storage acceptance.
*' The summation over hours is weighted by the inverse of the technology's hourly production cost raised to the 
*' power of minus one-fourth of the sensitivity variable. 
QCostProdSpecTech(runCy,PGALL,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) ) ..
         VCostProdSpecTech(runCy,PGALL,YTIME) 
         =E=  
         sum(HOUR,VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)**(-VSensCcs(runCy,YTIME)/4)) ;

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is implemented. The
*' share is determined based on a formulation that considers the production costs of the technology.
*' The numerator of the share calculation involves a factor of 1.1 multiplied
*' by the production cost of the technology for the specific power plant and year. The denominator
*' includes the sum of the numerator and the production costs of other power plant types without CCS.
QShareNewTechCcs(runCy,PGALL,YTIME)$(TIME(YTIME) $CCS(PGALL))..
         VShareNewTechCcs(runCy,PGALL,YTIME) =E=
         1.1 *VCostProdSpecTech(runCy,PGALL,YTIME)
         /(1.1*VCostProdSpecTech(runCy,PGALL,YTIME)
           + sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),VCostProdSpecTech(runCy,PGALL2,YTIME))
           );         

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is not implemented .
*' The equation is based on the complementarity relationship, expressing that the power plant's share in
*' new equipment without CCS is equal to one minus the sum of the shares of power plants with CCS in the
*' new equipment. The sum is taken over all power plants with CCS for the given power plant type and year .
QShareNewTechNoCcs(runCy,PGALL,YTIME)$(TIME(YTIME) $NOCCS(PGALL))..
         VShareNewTechNoCcs(runCy,PGALL,YTIME) 
         =E= 
         1 - sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCcs(runCy,CCS,YTIME));

*' Compute the variable cost of each power plant technology for every region,
*' By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
QCostVarTech(runCy,PGALL,YTIME)$(time(YTIME))..
         VCostVarTech(runCy,PGALL,YTIME) 
             =E=
         (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
         + (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
          *(sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
          *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)));

*' The equation calculates the variable for a specific
*' power plant and year when the power plant is not subject to endogenous scrapping. The calculation involves raising the variable
*' cost of the technology for the specified power plant and year to the power of -5.
QCostVarTechNotPGSCRN(runCy,PGALL,YTIME)$(time(YTIME) $(not PGSCRN(PGALL)))..
         VCostVarTechNotPGSCRN(runCy,PGALL,YTIME) 
              =E=
          VCostVarTech(runCy,PGALL,YTIME)**(-5);

*' The equation calculates the production cost of a technology 
*' for a specific power plant and year. The equation involves various factors, including discount rates, technical
*' lifetime of the plant type, gross capital cost with subsidies for renewables, capital goods index, fixed operation 
*' and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, CO2 capture rates, cost
*' curve for CO2 sequestration costs, CO2 emission factors, carbon values, plant efficiency, and specific conditions excluding
*' renewable power plants . The equation reflects the complex dynamics of calculating the production cost, considering both economic and technical parameters.
QCostProdTechPreReplac(runCy,PGALL,YTIME)$TIME(YTIME)..
         VCostProdTechPreReplac(runCy,PGALL,YTIME) =e=
                        (
                          ((iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))/
                          (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
                            * iGrossCapCosSubRen(PGALL,YTIME)* 1E3 * iCGI(runCy,YTIME)  + 
                            iFixOandMCost(PGALL,YTIME))/(8760*iAvailRate(PGALL,YTIME))
                           + (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), 
                           (VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)+
                            iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
                             (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)))
                         );

*' The equation calculates the production cost of a technology used in premature replacement,
*' considering plant availability rates. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
*' The equation involves the production cost of the technology used in premature replacement without considering availability rates 
*' and incorporates adjustments based on the availability rates of two power plants .
QCostProdTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)$TIME(YTIME)..
         VCostProdTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME) =E=
         iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME)*VCostProdTechPreReplac(runCy,PGALL,YTIME)+
         VCostVarTech(runCy,PGALL,YTIME)*(1-iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME));  

*' The equation computes the endogenous scrapping index for power generation plants  during the specified year .
*' The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
*' divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
*' parameter is applied to the sum of full costs and raised to the power of -5. The resulting index is used to determine the endogenous scrapping of power plants.
QIndexEndogScrap(runCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)))..
         VIndexEndogScrap(runCy,PGALL,YTIME)
                 =E=
         VCostVarTechNotPGSCRN(runCy,PGALL,YTIME)/
         (VCostVarTechNotPGSCRN(runCy,PGALL,YTIME)+(iScaleEndogScrap(PGALL)*
         sum(PGALL2,VCostProdTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)))**(-5));

*' The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
*' It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
*' total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
QCapElecNonChp(runCy,YTIME)$TIME(YTIME)..
         VCapElecNonChp(runCy,YTIME)
          =E=
VCapElecTot(runCy,YTIME) - SUM(CHP,VCapElecChp(runCy,CHP,YTIME)*0.85);      

*' In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
*' decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
QGapGenCapPowerDiff(runCy,YTIME)$TIME(YTIME)..
         VGapGenCapPowerDiff(runCy,YTIME)
             =E=
 (        (  VCapElecNonChp(runCy,YTIME) - VCapElecNonChp(runCy,YTIME-1) + sum(PGALL,VCapElec2(runCy,PGALL,YTIME-1) * 
 (1 - VIndexEndogScrap(runCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VCapElec(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
          iTechLftPlaType(runCy,PGALL))
       )
  + 0 + SQRT( SQR(       (  VCapElecNonChp(runCy,YTIME) - VCapElecNonChp(runCy,YTIME-1) +
        sum(PGALL,VCapElec2(runCy,PGALL,YTIME-1) * (1 - VIndexEndogScrap(runCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VCapElec(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
          iTechLftPlaType(runCy,PGALL))
       ) -0) + SQR(1e-10) ) )/2;

*' The equation  calculates a temporary variable 
*' that facilitates the scaling in the Weibull equation. The equation involves
*' the hourly production costs of technology for power plants
*' with carbon capture and storage and without CCS . The production 
*' costs are raised to the power of -6, and the result is used as a scaling factor
*' in the Weibull equation. The equation captures the cost-related considerations 
*' in determining the scaling factor for the Weibull equation based on the production costs of different technologies.
qScalWeibull(runCy,PGALL,HOUR,YTIME)$((not CCS(PGALL))$TIME(YTIME))..
          vScalWeibull(runCy,PGALL,HOUR,YTIME) 
         =E=
         (VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
         +
          VCostHourProdInvDecNoCcs(runCy,PGALL,HOUR,YTIME)$NOCCS(PGALL))**(-6);     

*' The equation calculates the renewable potential supply curve for a specified year. Including:
*' The minimum renewable potential for the given renewable energy form and country in the specified year.
*' The carbon price value associated with the country in the specified year for the purpose of renewable potential estimation,
*' the "Trade" attribute refers to tradable permits (if carbon pricing exists in the form of an emissions trading scheme).
*' The maximum renewable potential for the specified renewable energy form  and country in the given year.
*' The renewable potential supply curve is then calculated by linearly interpolating between the minimum and maximum renewable potentials based on the trade value.
*' The trade value is normalized by dividing it by 70. The equation essentially defines a linear relationship between the trade value and the renewable potential within
*' the specified range.
QPotRenSuppCurve(runCy,PGRENEF,YTIME)$TIME(YTIME)..
         VPotRenSuppCurve(runCy,PGRENEF,YTIME) =E=
         iMinRenPotential(runCy,PGRENEF,YTIME) +(VCarVal(runCy,"Trade",YTIME))/(70)*
         (iMaxRenPotential(runCy,PGRENEF,YTIME)-iMinRenPotential(runCy,PGRENEF,YTIME));

*' *The equation calculates the maximum allowed renewable potential for a specific renewable energy form and country in the
*' given year . Including:
*' VThe renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in the previous equation.
*' The maximum renewable potential for the specified renewable energy form and country in the given year.
*' The maximum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the maximum renewable potential.
*' This formulation ensures that the potential does not exceed the maximum allowed value. 
QPotRenMaxAllow(runCy,PGRENEF,YTIME)$TIME(YTIME)..      
         VPotRenMaxAllow(runCy,PGRENEF,YTIME) =E=
         ( VPotRenSuppCurve(runCy,PGRENEF,YTIME)+ iMaxRenPotential(runCy,PGRENEF,YTIME))/2;

*' The equation calculates the minimum allowed renewable potential for a specific renewable energy form and country 
*' in the given year . Including:
*' The renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in a previous equation.
*' The minimum renewable potential for the specified renewable energy form and country in the given year.
*' The minimum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the minimum renewable potential.
*' This formulation ensures that the potential does not fall below the minimum allowed value.
qPotRenMinAllow(runCy,PGRENEF,YTIME)$TIME(YTIME)..  
         vPotRenMinAllow(runCy,PGRENEF,YTIME) =E=
         ( VPotRenSuppCurve(runCy,PGRENEF,YTIME) + iMinRenPotential(runCy,PGRENEF,YTIME))/2;

*' The equation calculates a maturity multiplier for renewable technologies. If the technology is renewable , the multiplier is determined
*' based on an exponential function that involves the ratio of the planned electricity generation capacities of renewable technologies to the renewable potential
*' supply curve. This ratio is adjusted using a logistic function with parameters that influence the maturity of renewable technologies. If the technology is not
*' renewable, the maturity multiplier is set to 1. The purpose is to model the maturity level of renewable technologies based on their
*' planned capacities relative to the renewable potential supply curve.
QRenTechMatMult(runCy,PGALL,YTIME)$TIME(YTIME)..
         VRenTechMatMult(runCy,PGALL,YTIME)
          =E=
         1$(NOT PGREN(PGALL))
         +
         (
           1/(1+exp(0.01*(
                 sum(PGRENEF$PGALLtoPGRENEF(PGALL,PGRENEF),
                 sum(PGALL2$(PGALLtoPGRENEF(PGALL2,PGRENEF) $PGREN(PGALL2)),
                 VCapElec2(runCy,PGALL2,YTIME-1))/VPotRenCurr(runCy,PGRENEF,YTIME))-0.6)))
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
QScalWeibullSum(runCy,PGALL,YTIME)$((not CCS(PGALL)) $TIME(YTIME))..
         VScalWeibullSum(runCy,PGALL,YTIME) 
         =E=
              iMatFacPlaAvailCap(runCy,PGALL,YTIME) * VRenTechMatMult(runCy,PGALL,YTIME)*
              sum(HOUR,
                 (VCostHourProdInvDec(runCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
                 +
                 VCostHourProdInvDecNoCcs(runCy,PGALL,HOUR,YTIME)$NOCCS(PGALL)
                 )**(-6)
              ); 
  
*' The equation calculates the variable representing the new investment decision for power plants in a given country and time period.
*' It sums the values for all power plants that do not have carbon capture and storage technology .
*' The values capture the scaling factors influenced by material-specific factors, renewable technology maturity,
*' and cost efficiency considerations. Summing these values over relevant power plants provides an aggregated measure for informing new investment decisions, emphasizing
*' factors such as technology readiness and economic viability.
QNewInvElec(runCy,YTIME)$TIME(YTIME)..
         VNewInvElec(runCy,YTIME)
             =E=
         sum(PGALL$(not CCS(PGALL)),VScalWeibullSum(runCy,PGALL,YTIME));

*' The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
*' and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
*' For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
*' overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
*' as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
*' without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
QSharePowPlaNewEq(runCy,PGALL,YTIME)$(TIME(YTIME)) ..
        VSharePowPlaNewEq(runCy,PGALL,YTIME)
             =E=
         ( VScalWeibullSum(runCy,PGALL,YTIME)/ VNewInvElec(runCy,YTIME))$(not CCS(PGALL))
          +
          sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),VSharePowPlaNewEq(runCy,NOCCS,YTIME))$CCS(PGALL);

*' This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
*' and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
*' The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
QCapElec(runCy,PGALL,YTIME)$TIME(YTIME)..
         VCapElec(runCy,PGALL,YTIME)
             =E=
         (VCapElec2(runCy,PGALL,YTIME-1)*VIndexEndogScrap(runCy,PGALL,YTIME-1)
          +(VSharePowPlaNewEq(runCy,PGALL,YTIME) * VGapGenCapPowerDiff(runCy,YTIME))$( (not CCS(PGALL)) AND (not NOCCS(PGALL)))
          +(VSharePowPlaNewEq(runCy,PGALL,YTIME) * VShareNewTechNoCcs(runCy,PGALL,YTIME) * VGapGenCapPowerDiff(runCy,YTIME))$NOCCS(PGALL)
          +(VSharePowPlaNewEq(runCy,PGALL,YTIME) * VShareNewTechNoCcs(runCy,PGALL,YTIME) * VGapGenCapPowerDiff(runCy,YTIME))$CCS(PGALL)
          + iDecInvPlantSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
          - iPlantDecomSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
         )
         - ((VCapElec(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME-1))* 
         iAvailRate(PGALL,YTIME)*(1/iTechLftPlaType(runCy,PGALL)))$PGSCRN(PGALL);

*' This equation calculates the variable representing the planned electricity generation capacity for a specific power plant  in a given country
*' and time period. The calculation involves adjusting the actual electricity generation capacity by a small constant and the square
*' root of the sum of the square of the capacity and a small constant. The purpose of this adjustment is likely to avoid numerical issues and ensure a positive value for
*' the planned capacity.
QCapElec2(runCy,PGALL,YTIME)$TIME(YTIME)..
         VCapElec2(runCy,PGALL,YTIME)
             =E=
         ( VCapElec(runCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VCapElec(runCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*' Compute the variable cost of each power plant technology for every region,
*' by utilizing the maturity factor related to plant dispatching.
QCostVarTechElec(runCy,PGALL,YTIME)$TIME(YTIME)..
         VCostVarTechElec(runCy,PGALL,YTIME)
         =E=  
          iMatureFacPlaDisp(runCy,PGALL,YTIME)*VCostVarTech(runCy,PGALL,YTIME)**(-2);

*' Compute the electricity peak loads of each region,
*' as a sum of the variable costs of all power plant technologies.
QElecPeakLoads(runCy,YTIME)$TIME(YTIME)..
         VElecPeakLoads(runCy,YTIME) 
         =E= 
         SQRT(SQR(sum(PGALL, VCostVarTechElec(runCy,PGALL,YTIME))));     

*' Compute power plant sorting to decide the plant dispatching. 
*' This is accomplished by dividing the variable cost by the peak loads.
QSortPlantDispatch(runCy,PGALL,YTIME)$TIME(YTIME)..
         VSortPlantDispatch(runCy,PGALL,YTIME)
                 =E=
         VCostVarTechElec(runCy,PGALL,YTIME)
         /
         VElecPeakLoads(runCy,YTIME);  

*' This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
*' in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
*' from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
*' power plants on a yearly basis.
QNewCapElec(runCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME))..
         VNewCapElec(runCy,PGALL,YTIME) =e=
VCapElec2(runCy,PGALL,YTIME)- VCapElec2(runCy,PGALL,YTIME-1);                       

*' This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
*' in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
*' possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
*' as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
*' over these eight periods.
QCFAvgRen(runCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME))..
   VCFAvgRen(runCy,PGALL,YTIME)
      =E=
    (iAvailRate(PGALL,YTIME)*VNewCapElec(runCy,PGALL,YTIME)+
     iAvailRate(PGALL,YTIME-1)*VNewCapElec(runCy,PGALL,YTIME-1)+
     iAvailRate(PGALL,YTIME-2)*VNewCapElec(runCy,PGALL,YTIME-2)+
     iAvailRate(PGALL,YTIME-3)*VNewCapElec(runCy,PGALL,YTIME-3)+
     iAvailRate(PGALL,YTIME-4)*VNewCapElec(runCy,PGALL,YTIME-4)+
     iAvailRate(PGALL,YTIME-5)*VNewCapElec(runCy,PGALL,YTIME-5)+
     iAvailRate(PGALL,YTIME-6)*VNewCapElec(runCy,PGALL,YTIME-6)+
     iAvailRate(PGALL,YTIME-7)*VNewCapElec(runCy,PGALL,YTIME-7))/
(VNewCapElec(runCy,PGALL,YTIME)+VNewCapElec(runCy,PGALL,YTIME-1)+VNewCapElec(runCy,PGALL,YTIME-2)+
VNewCapElec(runCy,PGALL,YTIME-3)+VNewCapElec(runCy,PGALL,YTIME-4)+VNewCapElec(runCy,PGALL,YTIME-5)+
VNewCapElec(runCy,PGALL,YTIME-6)+VNewCapElec(runCy,PGALL,YTIME-7));

*' This equation calculates the variable representing the overall capacity for a specific power plant in a given country and time period .
*' The overall capacity is a composite measure that includes the existing capacity for non-renewable power plants and the expected capacity for renewable power plants based
*' on their average capacity factor.
QCapOverall(runCy,PGALL,YTIME)$TIME(YTIME)..
     VCapOverall(runCy,PGALL,YTIME)
     =E=
VCapElec2(runCy,pgall,ytime)$ (not PGREN(PGALL))
+VCFAvgRen(runCy,PGALL,YTIME-1)*(VNewCapElec(runCy,PGALL,YTIME)/iAvailRate(PGALL,YTIME)+
VCapOverall(runCy,PGALL,YTIME-1)
/VCFAvgRen(runCy,PGALL,YTIME-1))$PGREN(PGALL);

*' This equation calculates the scaling factor for plant dispatching in a specific country , hour of the day,
*' and time period . The scaling factor for determining the dispatch order of different power plants during a particular hour.
QScalFacPlantDispatch(runCy,HOUR,YTIME)$TIME(YTIME)..
         sum(PGALL,
                 (VCapOverall(runCy,PGALL,YTIME)+
                 sum(CHP$CHPtoEON(CHP,PGALL),VCapElecChp(runCy,CHP,YTIME)))*
                 exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/VSortPlantDispatch(runCy,PGALL,YTIME))
                 )
         =E=
         (VPeakLoad(runCy,YTIME) - VBaseLoad(runCy,YTIME))
         * exp(-VLambda(runCy,YTIME)*(0.25 + ord(HOUR)-1))
         + VBaseLoad(runCy,YTIME);

*' This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
*' The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
*' electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
*' share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
QProdEstElecChp(runCy,YTIME)$TIME(YTIME)..
         VProdEstElecChp(runCy,YTIME) 
         =E=
         ( (1/0.086 * sum((INDDOM,CHP),VConsFuel(runCy,INDDOM,CHP,YTIME)) * VPriceElecInd(runCy,YTIME)) + 
         iMxmShareChpElec(runCy,YTIME)*VDemElecTot(runCy,YTIME) - SQRT( SQR((1/0.086 * sum((INDDOM,CHP),VConsFuel(runCy,INDDOM,CHP,YTIME)) * 
         VPriceElecInd(runCy,YTIME)) - 
         iMxmShareChpElec(runCy,YTIME)*VDemElecTot(runCy,YTIME)) + SQR(1E-4) ) )/2;

*' This equation calculates the non-Combined Heat and Power electricity production in a specific country and time period .
*' It is essentially the difference between the total electricity demand and the estimated electricity generation from CHP plants .In summary,
*' the equation calculates the electricity production from technologies other than CHP by subtracting the estimated CHP electricity generation from the total electricity
*' demand. 
QProdElecNonChp(runCy,YTIME)$TIME(YTIME)..
         VProdElecNonChp(runCy,YTIME) 
         =E=
  (VDemElecTot(runCy,YTIME) - VProdEstElecChp(runCy,YTIME));  

*' This equation calculates the total required electricity production for a specific country and time period .
*' The total required electricity production is the sum of electricity generation from different technologies, including CHP plants, across all hours of the day.
*' The total required electricity production is the sum of the electricity generation from all CHP plants across all hours, considering the scaling factor for plant
*' dispatching. 
QProdReqElec(runCy,YTIME)$TIME(YTIME)..
VProdReqElec(runCy,YTIME) 
                   =E=
         sum(hour, sum(CHP,VCapElecChp(runCy,CHP,YTIME)*exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/ 
         sum(pgall$chptoeon(chp,pgall),VSortPlantDispatch(runCy,PGALL,YTIME)))));

*' This equation calculates the electricity production from power generation plants for a specific country ,
*' power generation plant type , and time period . The electricity production is determined based on the overall electricity
*' demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
*' from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
*' capacity and the scaling factor for dispatching.
QProdElec(runCy,PGALL,YTIME)$TIME(YTIME)..
         VProdElec(runCy,PGALL,YTIME)
                 =E=
         VProdElecNonChp(runCy,YTIME) /
         (VProdReqTotElec(runCy,YTIME)- VProdReqElec(runCy,YTIME))
         * VCapElec2(runCy,PGALL,YTIME)* sum(HOUR, exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/VSortPlantDispatch(runCy,PGALL,YTIME)));

*' This equation calculates the sector contribution to total Combined Heat and Power production . The contribution
*' is calculated for a specific country , industrial sector , CHP technology , and time period .The sector contribution
*' is calculated by dividing the fuel consumption of the specific industrial sector for CHP by the total fuel consumption of CHP across all industrial
*' sectors. The result represents the proportion of CHP production attributable to the specified industrial sector. The denominator has a small constant
*' (1e-6) added to avoid division by zero.
qSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)$(TIME(YTIME) $SECTTECH(INDDOM,CHP))..
         vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME) 
          =E=
         VConsFuel(runCy,INDDOM,CHP,YTIME)/(1e-6+SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME)));

*' This equation calculates the electricity production from Combined Heat and Power plants . The electricity production is computed
*' for a specific country , CHP technology , and time period.The electricity production from CHP plants is computed by taking the
*' ratio of the fuel consumption by the specified industrial sector for CHP technology to the total fuel consumption for all industrial sectors and CHP
*' technologies. This ratio is then multiplied by the difference between total electricity demand and the sum of electricity production from all power
*' generation plants. The result represents the portion of electricity production from CHP plants attributed to the specified CHP technology.
QProdElecChp(runCy,CHP,YTIME)$TIME(YTIME)..
         VProdElecChp(runCy,CHP,YTIME)
                 =E=
        sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VConsFuel(runCy,INDDOM,CHP2,YTIME)))*
        (VDemElecTot(runCy,YTIME) - SUM(PGALL,VProdElec(runCy,PGALL,YTIME)));

*' This equation calculates the share of gross electricity production attributed to renewable sources.
*' The share is computed for a specific country and time period.The share of gross electricity production from
*' renewable sources is calculated by dividing the sum of renewable electricity production by the sum of total electricity production,
*' industrial sector electricity production, and net electricity imports. The result represents the proportion of electricity production
*' attributed to renewable sources in the specified country and time period.
QShareRenGrossProd(runCy,YTIME)$TIME(YTIME)..

                 VShareRenGrossProd(runCy,YTIME) 
                 =E=
                 (SUM(PGNREN$((not sameas("PGASHYD",PGNREN)) $(not sameas("PGSHYD",PGNREN)) $(not sameas("PGLHYD",PGNREN)) ),
                         VProdElec(runCy,PGNREN,YTIME)))/
                 (SUM(PGALL,VProdElec(runCy,PGALL,YTIME))+ 
                 1e-3*sum(DSBS,sum(CHP$SECTTECH(DSBS,CHP),VConsFuel(runCy,DSBS,CHP,YTIME)))/8.6e-5*VPriceElecInd(runCy,YTIME) + 
                 1/0.086 *VImpNetEneBrnch(runCy,"ELC",YTIME));         

*' This equation calculates the long-term power generation cost of technologies excluding climate policies.
*' The cost is computed for a specific country, power generation technology , energy sector, and time period.
*' The long-term power generation cost is computed as a combination of capital costs, operating and maintenance costs, and variable costs,
*' considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the availability
*' rate and conversion factors. The equation provides a comprehensive calculation of the long-term cost associated with power generation technologies,
*' excluding climate policy-related costs.
QCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..
         VCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
              / (1000*(6$ISET(ESET)+4$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)/1.2441+
                 iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*' This equation calculates the long-term minimum power generation cost for a specific country , power generation technology,
*' and time period. The minimum cost is computed considering various factors, including discount rates, technological lifetimes, gross capital costs,
*' fixed operating and maintenance costs, availability rates, variable costs, fuel prices, carbon capture rates, carbon capture and storage costs, carbon
*' emission factors, and plant efficiency.The long-term minimum power generation cost is calculated as a combination of capital costs, operating and maintenance
*' costs, and variable costs, considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the
*' availability rate and conversion factors. This equation provides insight into the minimum cost associated with power generation technologies, excluding climate
*' policy-related costs, and uses a consistent conversion factor for power capacity.
qCostPowGenLonMin(runCy,PGALL,YTIME)$TIME(YTIME)..

         vCostPowGenLonMin(runCy,PGALL,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*sGwToTwhPerYear) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)/1.2441+

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));   

*' This equation calculates the long-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable costs
*' associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the long-term power generation
*' cost per unit of electricity produced in the given time period. The equation also includes factors such as discount rates, plant availability rates, and the gross
*' capital cost per plant type with subsidies for renewables.
qCostPowGenLongIntPri(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..

         vCostPowGenLongIntPri(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)/1.5*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))); 


*' This equation calculates the short-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable
*' costs associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the short-term power
*' generation cost per unit of electricity produced in the given time period.
qCostPowGenShortIntPri(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..

         vCostPowGenShortIntPri(runCy,PGALL,ESET,YTIME)
                 =E=
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));    

*' This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
*' plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
*' electricity consumed in the given time period.
QCostPowGenAvgLng(runCy,ESET,YTIME)$TIME(YTIME)..
         VCostPowGenAvgLng(runCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, VProdElec(runCy,PGALL,YTIME)*VCostPowGenLngTechNoCp(runCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VCostElcAvgProdCHP(runCy,CHP,YTIME)*VProdElecChp(runCy,CHP,YTIME))
         )
/VDemElecTot(runCy,YTIME); 

*' The equation represents the long-term average power generation cost excluding climate policies.
*' It calculates the cost in Euro2005 per kilowatt-hour (kWh) for a specific combination of parameters. The equation is composed 
*' of various factors, including discount rates, technical lifetime of the plant type, gross capital cost with subsidies for renewables,
*' fixed operation and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, efficiency values, CO2 emission factors,
*' CO2 capture rates, and carbon prices. The equation incorporates a summation over different plant fuel types and considers the cost curve for CO2 sequestration.
*' The final result is the average power generation cost per unit of electricity produced, taking into account various economic and technical parameters.
QCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..
         VCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)-iEffValueInEuro(runCy,"PG",ytime)/1000-iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                 sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))/1000 )/1.2441+

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*' Compute long term power generation cost excluding climate policies by summing the Electricity production multiplied by Long-term average power generation cost excluding 
*' climate policies added to the sum of Average Electricity production cost per CHP plant multiplied by the CHP electricity production and all of the above divided by 
*' the Total electricity demand.
QCostPowGenLonNoClimPol(runCy,ESET,YTIME)$TIME(YTIME)..
         VCostPowGenLonNoClimPol(runCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, (VProdElec(runCy,PGALL,YTIME))*VCostAvgPowGenLonNoClimPol(runCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VCostElcAvgProdCHP(runCy,CHP,YTIME)*VProdElecChp(runCy,CHP,YTIME))
         )
/(VDemElecTot(runCy,YTIME));  

*' Compute electricity price in Industrial and Residential Consumers excluding climate policies by multiplying the Factors affecting electricity prices to consumers by the sum of 
*' Fuel prices per subsector and fuel multiplied by the TWh to Mtoe conversion factor adding the Factors affecting electricity prices to consumers and the Long-term average power 
*' generation cost  excluding climate policies for Electricity of Other Industrial sectors and for Electricity for Households .
QPriceElecIndResNoCliPol(runCy,ESET,YTIME)$TIME(YTIME)..   !! The electricity price is based on previous year's production costs
        VPriceElecIndResNoCliPol(runCy,ESET,YTIME)
                 =E=
        (1 + iVAT(runCy, YTIME)) *
        (
           (
             (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"IND_RES",YTIME-1)+
               VCostPowGenLonNoClimPol(runCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VPriceFuelSubCarVal(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"TERT_RES",YTIME-1)+
                VCostPowGenLonNoClimPol(runCy,"r",YTIME-1)
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' This equation computes the short-term average power generation cost. It involves summing the variable production costs for different power generation plants and
*' energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of electricity
*' consumed in the given time period.
qCostPowGenAvgShrt(runCy,ESET,YTIME)$TIME(YTIME)..

        vCostPowGenAvgShrt(runCy,ESET,YTIME)
                 =E=
        (
        sum(PGALL,
        VProdElec(runCy,PGALL,YTIME)*
        (
        sum(PGEF$PGALLtoEF(PGALL,PGEF),
        (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
         (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)))
        ))
        +
         sum(CHP, VCostVarAvgElecProd(runCy,CHP,YTIME)*VProdElecChp(runCy,CHP,YTIME))
         )
         /VDemElecTot(runCy,YTIME);

*' * Transport

*' This equation calculates the lifetime of passenger cars based on the scrapping rate of passenger cars. The lifetime is inversely proportional to the scrapping rate,
*' meaning that as the scrapping rate increases, the lifetime of passenger cars decreases.
QLftPc(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $sameas(DSBS,"PC") $SECTTECH(DSBS,EF))..
         VLftPc(runCy,DSBS,EF,YTIME)
                 =E=
         1/VScrRatePc(runCy,YTIME);

*' This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
*' The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
*' freight transport modes.
QActivGoodsTransp(runCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE))..
         VActivGoodsTransp(runCy,TRANSE,YTIME)
                 =E=
         (
          VActivGoodsTransp(runCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME)
           * (iPop(YTIME,runCy)/iPop(YTIME-1,runCy))
           * (VPriceFuelAvgSub(runCy,TRANSE,YTIME)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME)
           * (VPriceFuelAvgSub(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VPriceFuelAvgSub(runCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$sameas(TRANSE,"GU")        !!trucks
         +
         (
           VActivGoodsTransp(runCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME)
           * (VPriceFuelAvgSub(runCy,TRANSE,YTIME)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME)
           * (VPriceFuelAvgSub(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VPriceFuelAvgSub(runCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
           * (VActivGoodsTransp(runCy,"GU",YTIME)/VActivGoodsTransp(runCy,"GU",YTIME-1))**iElastA(runCy,TRANSE,"c4",YTIME)
         )$(not sameas(TRANSE,"GU"));                      !!other freight transport

*' This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
*' The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
*' various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
*' different types of transportation modes.
QGapTranspActiv(runCy,TRANSE,YTIME)$TIME(YTIME)..
         VGapTranspActiv(runCy,TRANSE,YTIME)
                 =E=
         VNewRegPcYearly(runCy,YTIME)$sameas(TRANSE,"PC")
         +
         (
         ( [VActivPassTrnsp(runCy,TRANSE,YTIME)/
         (sum((TTECH)$SECTTECH(TRANSE,TTECH),VLftPc(runCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] +
          SQRT( SQR([VActivPassTrnsp(runCy,TRANSE,YTIME)/
          (sum((TTECH)$SECTTECH(TRANSE,TTECH),VLftPc(runCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
         +
         (
         ( [VActivGoodsTransp(runCy,TRANSE,YTIME)/
         (sum((EF)$SECTTECH(TRANSE,EF),VLftPc(runCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([VActivGoodsTransp(runCy,TRANSE,YTIME)/
          (sum((EF)$SECTTECH(TRANSE,EF),VLftPc(runCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$TRANG(TRANSE);

*' This equation calculates the specific fuel consumption for a given technology, subsector, energy form, and time. The specific fuel consumption depends on various factors,
*' including fuel prices and elasticities. The equation involves a product term over a set of Polynomial Distribution Lags and considers the elasticity of fuel prices.
QConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $TTECHtoEF(TTECH,EF) )..
         VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)
                 =E=
         VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME-1) * prod(KPDL,
                     (
                        VPriceFuelSubCarVal(runCy,TRANSE,EF,YTIME-ord(KPDL))/VPriceFuelSubCarVal(runCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
                      )**(iElastA(runCy,TRANSE,"c5",YTIME)*iFPDL(TRANSE,KPDL))
          );

*' This equation calculates the transportation cost per mean and consumer size in kEuro per vehicle. It involves several terms, including capital costs,
*' variable costs, and fuel costs. The equation considers different technologies and their associated costs, as well as factors like the discount rate,
*' specific fuel consumption, and annual .
QCostTranspPerMeanConsSize(runCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le iNcon(TRANSE)+1))..
         VCostTranspPerMeanConsSize(runCy,TRANSE,RCon,TTECH,YTIME)
         =E=
                       (
                         (
                           (iDisc(runCy,TRANSE,YTIME)*exp(iDisc(runCy,TRANSE,YTIME)*VLftPc(runCy,TRANSE,TTECH,YTIME)))
                           /
                           (exp(iDisc(runCy,TRANSE,YTIME)*VLftPc(runCy,TRANSE,TTECH,YTIME)) - 1)
                         ) * iCapCostTech(runCy,TRANSE,TTECH,YTIME)  * iCGI(runCy,YTIME)
                         + iFixOMCostTech(runCy,TRANSE,TTECH,YTIME)  +
                         (
                           (sum(EF$TTECHtoEF(TTECH,EF),VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubCarVal(runCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
                           +
                           (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),

                              (1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubCarVal(runCy,TRANSE,EF,YTIME))
                             + iShareAnnMilePlugInHybrid(runCy,YTIME)*VConsSpecificFuel(runCy,TRANSE,TTECH,"ELC",YTIME)*VPriceFuelSubCarVal(runCy,TRANSE,"ELC",YTIME)
                           )$PLUGIN(TTECH)

                           + iVarCostTech(runCy,TRANSE,TTECH,YTIME)
                           + (VRenValue(YTIME)/1000)$( not RENEF(TTECH))
                         )
                         *  iAnnCons(runCy,TRANSE,"smallest") * (iAnnCons(runCy,TRANSE,"largest")/iAnnCons(runCy,TRANSE,"smallest"))**((ord(Rcon)-1)/iNcon(TRANSE))
                       );

*' This equation calculates the transportation cost per mean and consumer size. It involves taking the inverse fourth power of the
*' variable representing the transportation cost per mean and consumer size.
QCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1))..
         VCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME)
         =E=
         VCostTranspPerMeanConsSize(runCy,TRANSE,rCon,TTECH,YTIME)**(-4);

*' This equation calculates the transportation cost, including the maturity factor. It involves multiplying the maturity factor for a specific technology
*' and subsector by the transportation cost per vehicle for the mean and consumer size. The result is a variable representing the transportation cost,
*' including the maturity factor.
QCostTranspMatFac(runCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1))..
         VCostTranspMatFac(runCy,TRANSE,RCon,TTECH,YTIME) 
         =E=
         iMatrFactor(runCy,TRANSE,TTECH,YTIME) * VCostTranspPerVeh(runCy,TRANSE,rCon,TTECH,YTIME);

*' This equation calculates the technology sorting based on variable cost. It involves the summation of transportation costs, including the maturity factor,
*' for each technology and subsector. The result is a variable representing the technology sorting based on variable cost.
QSortTechVarCost(runCy,TRANSE,rCon,YTIME)$(TIME(YTIME) $(ord(rCon) le iNcon(TRANSE)+1))..
         VSortTechVarCost(runCy,TRANSE,rCon,YTIME)
                 =E=
         sum((TTECH)$SECTTECH(TRANSE,TTECH), VCostTranspMatFac(runCy,TRANSE,rCon,TTECH,YTIME));

*' This equation calculates the share of each technology in the total sectoral use. It takes into account factors such as the maturity factor,
*' cumulative distribution function of consumer size groups, transportation cost per mean and consumer size, distribution function of consumer
*' size groups, and technology sorting based on variable cost. The result is a dimensionless value representing the share of each technology in the total sectoral use.
QShareTechSectoral(runCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) )..
         VShareTechSectoral(runCy,TRANSE,TTECH,YTIME)
         =E=
         iMatrFactor(runCy,TRANSE,TTECH,YTIME) / iCumDistrFuncConsSize(runCy,TRANSE)
         * sum( Rcon$(ord(Rcon) le iNcon(TRANSE)+1),
                VCostTranspPerVeh(runCy,TRANSE,RCon,TTECH,YTIME)
                * iDisFunConSize(runCy,TRANSE,RCon) / VSortTechVarCost(runCy,TRANSE,RCon,YTIME)
              );

*' This equation calculates the consumption of each technology in transport sectors. It considers various factors such as the lifetime of the technology,
*' average capacity per vehicle, load factor, scrapping rate, and specific fuel consumption. The equation also takes into account the technology's variable
*' cost for new equipment and the gap in transport activity to be filled by new technologies. The result is expressed in million tonnes of oil equivalent.
QConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) )..
         VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME)
                 =E=
         VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME-1) *
         (
                 (
                     ((VLftPc(runCy,TRANSE,TTECH,YTIME-1)-1)/VLftPc(runCy,TRANSE,TTECH,YTIME-1))
                      *(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
                      /(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (1 - VScrRatePc(runCy,YTIME))$sameas(TRANSE,"PC")
         )
         +
         VShareTechSectoral(runCy,TRANSE,TTECH,YTIME) *
         (
                 VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME)$(not PLUGIN(TTECH))
                 +
                 ( ((1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME))$(not sameas("ELC",EF))
                   + iShareAnnMilePlugInHybrid(runCy,YTIME)*VConsSpecificFuel(runCy,TRANSE,TTECH,"ELC",YTIME))$PLUGIN(TTECH)
         )/1000
         * VGapTranspActiv(runCy,TRANSE,YTIME) *
         (
                 (
                  (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
                  / (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (VActivPassTrnsp(runCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
         );

*' This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
*' It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
QDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF))..
         VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)
                 =E=
         sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), VConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME));

*' This equation calculates the final energy demand in different transport subsectors by summing up the final energy demand for each energy form within
*' each transport subsector. The result is expressed in million tonnes of oil equivalent.
qDemFinEneSubTransp(runCy,TRANSE,YTIME)$(TIME(YTIME)) ..
         vDemFinEneSubTransp(runCy,TRANSE,YTIME)
                 =E=
         sum(EF,VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME));

*' This equation calculates the GDP-dependent market extension of passenger cars. It takes into account transportation characteristics, the GDP-dependent market
*' extension from the previous year, and the ratio of GDP to population for the current and previous years. The elasticity parameter (a) influences the sensitivity
*' of market extension to changes in GDP.
QMEPcGdp(runCy,YTIME)$TIME(YTIME)..
         VMEPcGdp(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTV",YTIME) * VMEPcGdp(runCy,YTIME-1) *
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))] ** iElastA(runCy,"PC","a",YTIME);

*' This equation calculates the market extension of passenger cars that is independent of GDP. It involves various parameters such as transportation characteristics,
*' Gompertz function parameters (S1, S2, S3), the ratio of the previous year's stock of passenger cars to the previous year's population, and the saturation ratio .
QMEPcNonGdp(runCy,YTIME)$TIME(YTIME)..
         VMEPcNonGdp(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") * VPcOwnPcLevl(runCy,YTIME))) *
         VStockPcYearly(runCy,YTIME-1) / (iPop(YTIME-1,runCy) * 1000);

*' This equation calculates the stock of passenger cars in million vehicles for a given year. The stock is influenced by the previous year's stock,
*' population, and market extension factors, both GDP-dependent and independent.
QStockPcYearly(runCy,YTIME)$TIME(YTIME)..
         VStockPcYearly(runCy,YTIME)
                 =E=
         (VStockPcYearly(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000) + VMEPcNonGdp(runCy,YTIME) + VMEPcGdp(runCy,YTIME)) *
         iPop(YTIME,runCy) * 1000;

*' This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
*' The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
QNewRegPcYearly(runCy,YTIME)$TIME(YTIME)..
         VNewRegPcYearly(runCy,YTIME)
                 =E=
         (VMEPcNonGdp(runCy,YTIME) + VMEPcGdp(runCy,YTIME)) * (iPop(YTIME,runCy)*1000)  !! new cars due to GDP
         - VStockPcYearly(runCy,YTIME-1)*(1 - iPop(YTIME,runCy)/iPop(YTIME-1,runCy))    !! new cars due to population
         + VNumPcScrap(runCy,YTIME);                                                  !! new cars due to scrapping

*' This equation calculates the passenger transport activity for various modes of transportation, including passenger cars, aviation, and other passenger transportation modes.
*' The activity is influenced by factors such as fuel prices, GDP per capita, and elasticities specific to each transportation mode. The equation uses past activity levels and
*' price trends to estimate the current year's activity. The coefficients and exponents in the equation represent the sensitivities of activity to changes in various factors.
QActivPassTrnsp(runCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE))..
         VActivPassTrnsp(runCy,TRANSE,YTIME)
                 =E=
         (  !! passenger cars
            VActivPassTrnsp(runCy,TRANSE,YTIME-1) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"b1",YTIME) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"b2",YTIME) *
           [(VStockPcYearly(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000))/(VStockPcYearly(runCy,YTIME)/(iPop(YTIME,runCy)*1000))]**iElastA(runCy,TRANSE,"b3",YTIME) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"b4",YTIME)
         )$sameas(TRANSE,"PC") +
         (  !! passenger aviation
            VActivPassTrnsp(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
         )$sameas(TRANSE,"PA") +
         (   !! other passenger transportation modes
           VActivPassTrnsp(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VPriceFuelAvgSub(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME) *
           [(VStockPcYearly(runCy,YTIME)*VActivPassTrnsp(runCy,"PC",YTIME))/(VStockPcYearly(runCy,YTIME-1)*VActivPassTrnsp(runCy,"PC",YTIME-1))]**iElastA(runCy,TRANSE,"c4",YTIME) *
           prod(kpdl,
                  [(VPriceFuelAvgSub(runCy,TRANSE,YTIME-ord(kpdl))/
                    VPriceFuelAvgSub(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
*' The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
QNumPcScrap(runCy,YTIME)$TIME(YTIME)..
         VNumPcScrap(runCy,YTIME)
                 =E=
         VScrRatePc(runCy,YTIME) * VStockPcYearly(runCy,YTIME-1);

*' This equation calculates the ratio of car ownership over the saturation car ownership level. The calculation is based on a Gompertz function,
*' taking into account the stock of passenger cars, the population, and the market saturation level from the previous year. This ratio provides
*' an estimate of the level of car ownership relative to the saturation point, considering the dynamics of the market over time.
QPcOwnPcLevl(runCy,YTIME)$TIME(YTIME)..
         VPcOwnPcLevl(runCy,YTIME) !! level of saturation of gompertz function
                 =E=
         ( (VStockPcYearly(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) / iPassCarsMarkSat(runCy) + 1 - SQRT( SQR((VStockPcYearly(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) /  iPassCarsMarkSat(runCy) - 1)  ) )/2;

*' This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
*' reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
*' cars scrapping rate over time.
QScrRatePc(runCy,YTIME)$TIME(YTIME)..
         VScrRatePc(runCy,YTIME)
                  =E=
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**0.5
         * VScrRatePc(runCy,YTIME-1);

*' This equation calculates the electricity consumption for each final demand sector, considering both the industry and transport subsectors.
*' It sums the electricity consumption from industrial subsectors and transport subsectors, taking into account the final energy demand in each sector.
*' The result provides an estimate of electricity demand for different final demand sectors, offering insights into the overall electricity consumption
*' pattern across various sectors.
QConsElec(runCy,DSBS,YTIME)$TIME(YTIME)..
         VConsElec(runCy,DSBS,YTIME)
             =E=
         sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemFinEneTranspPerFuel(runCy,TRANSE,"ELC",YTIME));


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES

*' This equation calculates the consumption of non-substitutable electricity in the industry and tertiary sectors. It considers factors such as past electricity
*' consumption patterns, current activity levels, and elasticity coefficients. The dynamic approach of the equation adjusts the consumption based on changes in
*' activity levels and electricity prices over time. Polynomial distribution lags contribute to the sensitivity of consumption to historical electricity price trends.
*' The result provides an estimate of non-substitutable electricity consumption, taking into account the evolving technological and economic conditions in the industry
*' and tertiary sectors.
QConsElecNonSubIndTert(runCy,INDDOM,YTIME)$TIME(YTIME)..
         VConsElecNonSubIndTert(runCy,INDDOM,YTIME)
                 =E=
         [
         VConsElecNonSubIndTert(runCy,INDDOM,YTIME-1) * ( iActv(YTIME,runCy,INDDOM)/iActv(YTIME-1,runCy,INDDOM) )**
         iElastNonSubElec(runCy,INDDOM,"a",YTIME)
         * ( VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME)/VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME-1) )**iElastNonSubElec(runCy,INDDOM,"b1",YTIME)
         * ( VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME-1)/VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME-2) )**iElastNonSubElec(runCy,INDDOM,"b2",YTIME)
         * prod(KPDL,
                  ( VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME-ord(KPDL))/VPriceFuelSubCarVal(runCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))
                  )**( iElastNonSubElec(runCy,INDDOM,"c",YTIME)*iFPDL(INDDOM,KPDL))
                )      ]$iActv(YTIME-1,runCy,INDDOM);

*' This equation determines the consumption of the remaining substitutable equipment in a given subsector. It takes into account factors such as the lifetime of technologies,
*' past fuel consumption patterns, current activity levels, and elasticity coefficients. The equation utilizes a dynamic approach, adjusting the consumption based on changes
*' in activity levels and fuel prices over time. The polynomial distribution lags contribute to the sensitivity of consumption to historical fuel price trends. The result
*' provides an estimate of the remaining equipment consumption in the context of evolving technological and economic conditions.
QConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF))..
         VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)
                 =E=
         [
         (VLftPc(runCy,DSBS,EF,YTIME)-1)/VLftPc(runCy,DSBS,EF,YTIME)
         * (VConsFuelInclHP(runCy,DSBS,EF,YTIME-1) - (VConsElecNonSubIndTert(runCy,DSBS,YTIME-1)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))))
         * (iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS))**iElastA(runCy,DSBS,"a",YTIME)
         * (VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME)/VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME-1))**iElastA(runCy,DSBS,"b1",YTIME)
         * (VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME-1)/VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME-2))**iElastA(runCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                 (VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME-ord(KPDL))/VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME-(ord(KPDL)+1)))**(iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
               )  ]$(iActv(YTIME-1,runCy,DSBS));

*' This equation calculates the total final demand for substitutable fuels in each subsector. The demand is determined by factors such as the current activity level,
*' past activity levels, and the average fuel prices, with adjustments based on elasticity coefficients and polynomial distribution lags. The equation captures the
*' sensitivity of demand to changes in activity and fuel prices, providing a dynamic representation of the demand evolution over time.
QDemFinSubFuelSubSec(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VDemFinSubFuelSubSec(runCy,DSBS,YTIME)
                 =E=
         [
         VDemFinSubFuelSubSec(runCy,DSBS,YTIME-1)
         * ( iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS) )**iElastA(runCy,DSBS,"a",YTIME)
         * ( VPriceFuelAvgSub(runCy,DSBS,YTIME)/VPriceFuelAvgSub(runCy,DSBS,YTIME-1) )**iElastA(runCy,DSBS,"b1",YTIME)
         * ( VPriceFuelAvgSub(runCy,DSBS,YTIME-1)/VPriceFuelAvgSub(runCy,DSBS,YTIME-2) )**iElastA(runCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                  ( (VPriceFuelAvgSub(runCy,DSBS,YTIME-ord(KPDL))/VPriceFuelAvgSub(runCy,DSBS,YTIME-(ord(KPDL)+1)))/(iCGI(runCy,YTIME)**(1/6))
                  )**( iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
                )  ]$iActv(YTIME-1,runCy,DSBS)
;

*' This equation calculates the total consumption of electricity in industrial sectors. The consumption is obtained by summing up the electricity
*' consumption in each industrial subsector, excluding substitutable electricity. This equation provides an aggregate measure of electricity consumption
*' in the industrial sectors, considering only non-substitutable electricity.
qConsTotElecInd(runCy,YTIME)$TIME(YTIME)..
         vConsTotElecInd(runCy,YTIME)
         =E=
         SUM(INDSE,VConsElecNonSubIndTert(runCy,INDSE,YTIME));       

*' This equation calculates the total final demand for substitutable fuels in industrial sectors. The total demand is obtained by summing up the
*' final demand for substitutable fuels across various industrial subsectors. This equation provides a comprehensive view of the total demand for
*' substitutable fuels within the industrial sectors, aggregated across individual subsectors.
QDemFinSubFuelInd(runCy,YTIME)$TIME(YTIME)..
        vDemFinSubFuelInd(runCy,YTIME)=E= SUM(INDSE,VDemFinSubFuelSubSec(runCy,INDSE,YTIME));

*' This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
*' in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
*' electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
*' of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
*' for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
*' technical constraints, providing a realistic representation of the electricity market in the industrial sector.
QPriceElecInd(runCy,YTIME)$TIME(YTIME)..
         VPriceElecInd(runCy,YTIME) =E=
        ( VIndxElecIndPrices(runCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VIndxElecIndPrices(runCy,YTIME)-sElecToSteRatioChp) + SQR(1E-4) ) )/2;

*' This equation calculates the total fuel consumption in each demand subsector, excluding heat from heat pumps. The fuel consumption is measured
*' in million tons of oil equivalent and is influenced by two main components: the consumption of fuels in each demand subsector, including
*' heat from heat pumps, and the electricity consumed in heat pump plants.The equation uses the fuel consumption data for each demand subsector,
*' considering both cases with and without heat pump influence. When heat pumps are involved, the electricity consumed in these plants is also
*' taken into account. The result is the total fuel consumption in each demand subsector, providing a comprehensive measure of the energy consumption pattern.
*' This equation offers a comprehensive view of fuel consumption, considering both traditional fuel sources and the additional electricity consumption
*' associated with heat pump plants.
QConsFuel(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) )..
         VConsFuel(runCy,DSBS,EF,YTIME)
                 =E=
         VConsFuelInclHP(runCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
         (VConsFuelInclHP(runCy,DSBS,EF,YTIME) + VElecConsHeatPla(runCy,DSBS,YTIME))$ELCEF(EF);

*' This equation calculates the estimated electricity index of the industry price for a given year. The estimated index is derived by considering the historical
*' trend of the electricity index, with a focus on the fuel prices in the industrial subsector. The equation utilizes the fuel prices for electricity generation,
*' both in the current and past years, and computes a weighted average based on the historical pattern. The estimated electricity index is influenced by the ratio
*' of fuel prices in the current and previous years, with a power of 0.3 applied to each ratio. This weighting factor introduces a gradual adjustment to reflect the
*' historical changes in fuel prices, providing a more dynamic estimation of the electricity index. This equation provides a method to estimate the electricity index
*' based on historical fuel price trends, allowing for a more flexible and responsive representation of industry price dynamics.
QIndxElecIndPrices(runCy,YTIME)$TIME(YTIME)..
         VIndxElecIndPrices(runCy,YTIME)
                 =E=
         VPriceElecInd(runCy,YTIME-1) *
        ((VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-1)/VPriceFuelAvgSub(runCy,"OI",YTIME-1))/
        (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub(runCy,"OI",YTIME-2)))**(0.3) *
        ((VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub(runCy,"OI",YTIME-2))/
        (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-3)/VPriceFuelAvgSub(runCy,"OI",YTIME-3)))**(0.3);

*' This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
*' electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
*' factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
*' The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
*' price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
*' difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
QPriceFuelSubSecChp(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) )..
        VPriceFuelSubSecChp(runCy,DSBS,EF,YTIME)
                =E=   
             (((VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME) + (VRenValue(YTIME)/1000)$(not RENEF(EF))+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd(runCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd(runCy,YTIME))$CHP(EF))))  ) )/2;


*' The equation computes the electricity production cost per Combined Heat and Power plant for a specific demand sector within a given subsector.
*' The cost is determined based on various factors, including the discount rate, technical lifetime of CHP plants, capital cost, fixed O&M cost, availability rate,
*' variable cost, and fuel-related costs. The equation provides a comprehensive assessment of the overall expenses associated with electricity production from CHP
*' plants, considering both the fixed and variable components, as well as factors such as carbon prices and CO2 emission factors.
*' The resulting variable represents the electricity production cost per CHP plant and demand sector, expressed in Euro per kilowatt-hour (Euro/KWh).
QCostElecProdChp(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VCostElecProdChp(runCy,DSBS,CHP,YTIME)
                 =E=
                    ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP))
                        / (exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP)) -1))
                      * iInvCostChp(runCy,DSBS,CHP,YTIME)* 1000 * iCGI(runCy,YTIME)  + iFixOMCostPerChp(runCy,DSBS,CHP,YTIME)
                    )/(iAvailRateChp(runCy,DSBS,CHP)*(1000*sTWhToMtoe))/1000
                    + iVarCostChp(runCy,DSBS,CHP,YTIME)/1000
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)+0.001*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         * sTWhToMtoe /  (iBoiEffChp(runCy,CHP,YTIME) * VPriceElecInd(runCy,YTIME)) );        

*' The equation calculates the technology cost for each technology, energy form, and consumer size group within the specified subsector.
*' This cost estimation is based on an intermediate technology cost and the elasticity parameter associated with the given subsector.
*' The intermediate technology cost is raised to the power of the elasticity parameter to determine the final technology cost. The equation
*' provides a comprehensive assessment of the overall expenses associated with different technologies in the given subsector and consumer size group.
QCostTech(runCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
        VCostTech(runCy,DSBS,rCon,EF,YTIME) 
                 =E= 
                 VCostTechIntrm(runCy,DSBS,rCon,EF,YTIME)**(-iElaSub(runCy,DSBS)) ;   

*' The equation computes the intermediate technology cost, including the lifetime factor, for each technology, energy form, and consumer size group
*' within the specified subsector. This cost estimation plays a crucial role in evaluating the overall expenses associated with adopting and implementing
*' various technologies in the given subsector and consumer size group. The equation encompasses diverse parameters, such as discount rates, lifetime of 
*' technologies, capital costs, fixed operation and maintenance costs, fuel prices, annual consumption rates, the number of consumers, the capital goods 
*' index, and useful energy conversion factors.
QCostTechIntrm(runCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF))..
         VCostTechIntrm(runCy,DSBS,rCon,EF,YTIME) =E=
                  ( (( (iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF)) !! in case of chp plants we use the discount rate of power generation sector
                       * exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLftPc(runCy,DSBS,EF,YTIME))
                     )
                      / (exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLftPc(runCy,DSBS,EF,YTIME))- 1)
                    ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
                    +
                    iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
                    +
                    VPriceFuelSubSecChp(runCy,DSBS,EF,YTIME)
                    * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$INDDOM(DSBS)
                 +
                  ( (( iDisc(runCy,DSBS,YTIME)
                       * exp(iDisc(runCy,DSBS,YTIME)*VLftPc(runCy,DSBS,EF,YTIME))
                     )
                      / (exp(iDisc(runCy,DSBS,YTIME)*VLftPc(runCy,DSBS,EF,YTIME))- 1)
                    ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
                    +
                    iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
                    +
                    (
                      (VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)
                    )
                    * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$NENSE(DSBS);  

*' This equation calculates the technology cost, including the maturity factor , for each energy form  and technology  within
*' the specified subsector and consumer size group . The cost is determined by multiplying the maturity factor with the
*' technology cost based on the given parameters.
QCostTechMatFac(runCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
        VCostTechMatFac(runCy,DSBS,rCon,EF,YTIME) 
                                               =E=
        iMatrFactor(runCy,DSBS,EF,YTIME) * VCostTech(runCy,DSBS,rCon,EF,YTIME) ;

*' This equation calculates the technology sorting based on variable cost . It is determined by summing the technology cost,
*' including the maturity factor , for each energy form and technology within the specified subsector 
*' and consumer size group. The sorting is conducted based on variable cost considerations.
QSortTechVarCost(runCy,DSBS,rCon,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) )..
        VSortTechVarCost(runCy,DSBS,rCon,YTIME)
                        =E=
        sum((EF)$(SECTTECH(DSBS,EF) ),VCostTechMatFac(runCy,DSBS,rCon,EF,YTIME));

*' This equation calculates the gap in final demand for industry, tertiary, non-energy uses, and bunkers.
*' It is determined by subtracting the total final demand per subsector from the consumption of
*' remaining substitutable equipment. The square root term is included to ensure a non-negative result.
QGapFinalDem(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VGapFinalDem(runCy,DSBS,YTIME)
                 =E=
         VDemFinSubFuelSubSec(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME))
         + SQRT( SQR(VDemFinSubFuelSubSec(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)))) /2;

*' This equation calculates the technology share in new equipment based on factors such as maturity factor,
*' cumulative distribution function of consumer size groups, number of consumers, technology cost, distribution function of consumer
*' size groups, and technology sorting.
QShareTechNewEquip(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) )..
         VShareTechNewEquip(runCy,DSBS,EF,YTIME) =E=
         iMatrFactor(runCy,DSBS,EF,YTIME) / iCumDistrFuncConsSize(runCy,DSBS) *
         sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
                  VCostTech(runCy,DSBS,rCon,EF,YTIME)
                  * iDisFunConSize(runCy,DSBS,rCon)/VSortTechVarCost(runCy,DSBS,rCon,YTIME));

*' This equation calculates the consumption of fuels in each demand subsector, including heat from heat pumps .
*' It considers the consumption of remaining substitutable equipment, the technology share in new equipment, and the final demand
*' gap to be filled by new technologies. Additionally, non-substitutable electricity consumption in Industry and Tertiary sectors is included.
QConsFuelInclHP(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) )..
         VConsFuelInclHP(runCy,DSBS,EF,YTIME)
                 =E=
         VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)+
         VShareTechNewEquip(runCy,DSBS,EF,YTIME)*VGapFinalDem(runCy,DSBS,YTIME)
         + (VConsElecNonSubIndTert(runCy,DSBS,YTIME))$(INDDOM(DSBS) and ELCEF(EF));

*' This equation calculates the variable, including fuel electricity production cost per CHP plant and demand sector, taking into account the variable cost (other than fuel)
*' per CHP type and the summation of fuel-related costs for each energy form . The calculation involves fuel prices, CO2 emission factors, boiler efficiency, electricity
*' index, and carbon prices, adjusted by various factors. The equation uses these terms to calculate the variable, including fuel electricity production cost per CHP plant and
*' demand sector. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
QCostProdChpDem(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VCostProdChpDem(runCy,DSBS,CHP,YTIME)
                 =E=
         iVarCostChp(runCy,DSBS,CHP,YTIME)/1E3
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VPriceFuelSubCarVal(runCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         *sTWhToMtoe/(   iBoiEffChp(runCy,CHP,YTIME)*VPriceElecInd(runCy,YTIME)    ));

*' The equation calculates the average electricity production cost per Combined Heat and Power plant .
*' It involves a summation over demand subsectors . The average electricity production cost is determined by considering the electricity
*' production cost per CHP plant for each demand subsector. The result is expressed in Euro per kilowatt-hour (Euro/KWh).
QCostElcAvgProdCHP(runCy,CHP,YTIME)$TIME(YTIME)..
         VCostElcAvgProdCHP(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))*VCostElecProdChp(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

*' The equation computes the average variable cost, including fuel and electricity production cost, per Combined Heat and Power plant.
*' The equation involves a summation over demand subsectors , where the variable cost per CHP plant is calculated based on fuel
*' consumption and the variable cost of electricity production . The resulting average variable cost is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The conditional statement ensures that the denominator in the calculation is not zero, avoiding division by zero issues.
QCostVarAvgElecProd(runCy,CHP,YTIME)$(TIME(YTIME) ) ..
         VCostVarAvgElecProd(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))
         *VCostProdChpDem(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

*' * REST OF ENERGY BALANCE SECTORS

*' The equation computes the total final energy consumption in million tonnes of oil equivalent for each country ,
*' energy form sector, and time period. The total final energy consumption is calculated as the sum of final energy consumption in the
*' Industry and Tertiary sectors and the sum of final energy demand in all transport subsectors. The consumption is determined by the 
*' relevant link between model subsectors and fuels.
QConsFinEneCountry(runCy,EFS,YTIME)$TIME(YTIME)..
         VConsFinEneCountry(runCy,EFS,YTIME)
             =E=
         sum(INDDOM,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel(runCy,INDDOM,EF,YTIME)))
         +
         sum(TRANSE,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME)));

*' The equation computes the total final energy consumption in million tonnes of oil equivalent 
*' for all countries at a specific time period. This is achieved by summing the final energy consumption for each energy
*' form sector across all countries.
qConsTotFinEne(YTIME)$TIME(YTIME)..
         vConsTotFinEne(YTIME) =E= sum((runCy,EFS), VConsFinEneCountry(runCy,EFS,YTIME) );     

*' The equation computes the final non-energy consumption in million tonnes of oil equivalent
*' for a given energy form sector. The calculation involves summing the consumption of fuels in each non-energy and bunkers
*' demand subsector based on the corresponding fuel aggregation for the supply side. This process is performed 
*' for each time period.
QConsFinNonEne(runCy,EFS,YTIME)$TIME(YTIME)..
         VConsFinNonEne(runCy,EFS,YTIME)
             =E=
         sum(NENSE$(not sameas("BU",NENSE)),
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel(runCy,NENSE,EF,YTIME)));  

*' The equation computes the distribution losses in million tonnes of oil equivalent for a given energy form sector.
*' The losses are determined by the rate of losses over available for final consumption multiplied by the sum of total final energy
*' consumption and final non-energy consumption. This calculation is performed for each time period.
*' Please note that distribution losses are not considered for the hydrogen sector.
QLossesDistr(runCy,EFS,YTIME)$TIME(YTIME)..
         VLossesDistr(runCy,EFS,YTIME)
             =E=
         (iRateLossesFinCons(runCy,EFS,YTIME) * (VConsFinEneCountry(runCy,EFS,YTIME) + VConsFinNonEne(runCy,EFS,YTIME)))$(not H2EF(EFS));  

*' The equation calculates the transformation output from district heating plants .
*' This transformation output is determined by summing over different demand sectors and district heating systems 
*' that correspond to the specified energy form set. The equation then sums over these district heating 
*' systems and calculates the consumption of fuels in each of these sectors. The resulting value represents the 
*' transformation output from district heating plants in million tonnes of oil equivalent.
QOutTransfDhp(runCy,STEAM,YTIME)$TIME(YTIME)..
         VOutTransfDhp(runCy,STEAM,YTIME)
             =E=
         sum(DOMSE,
             sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel(runCy,DOMSE,DH,YTIME)));

*' The equation calculates the transformation input to district heating plants.
*' This transformation input is determined by summing over different district heating systems that correspond to the
*' specified energy form set . The equation then sums over different demand sectors within each 
*' district heating system and calculates the consumption of fuels in each of these sectors, taking into account
*' the efficiency of district heating plants. The resulting value represents the transformation input to district
*' heating plants in million tonnes of oil equivalent.
QTransfInputDHPlants(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfInputDHPlants(runCy,EFS,YTIME)
             =E=
         sum(DH$DHtoEF(DH,EFS),
             sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel(runCy,DOMSE,DH,YTIME)) / iEffDHPlants(runCy,EFS,YTIME));

*' The equation calculates the refineries' capacity for a given scenario and year.
*' The calculation is based on a residual factor, the previous year's capacity, and a production scaling
*' factor that takes into account the historical consumption trends for different energy forms. The scaling factor is
*' influenced by the base year and the production scaling parameter. The result represents the refineries'
*' capacity in million barrels per day (Million Barrels/day).
QCapRef(runCy,YTIME)$TIME(YTIME)..
         VCapRef(runCy,YTIME)
             =E=
         [
         iResRefCapacity(runCy,YTIME) * VCapRef(runCy,YTIME-1)
         *
         (1$(ord(YTIME) le 16) +
         (prod(rc,
         (sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry(runCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry(runCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
         )
         $(ord(YTIME) gt 16)
         )     ] $iRefCapacity(runCy,"%fStartHorizon%");

*' The equation calculates the transformation output from refineries for a specific energy form 
*' in a given scenario and year. The output is computed based on a residual factor, the previous year's output, and the
*' change in refineries' capacity. The calculation includes considerations for the base year and adjusts the result accordingly.
*' The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
QOutTransfRefSpec(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"))..
         VOutTransfRefSpec(runCy,EFS,YTIME)
             =E=
         [
         iResTransfOutputRefineries(runCy,EFS,YTIME) * VOutTransfRefSpec(runCy,EFS,YTIME-1)
         * (VCapRef(runCy,YTIME)/VCapRef(runCy,YTIME-1))**0.3
         * (
             1$(TFIRST(YTIME-1) or TFIRST(YTIME-2))
             +
             (
                sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry(runCy,EF,YTIME-1))/sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry(runCy,EF,YTIME-2))
             )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
           )**(0.7)  ]$iRefCapacity(runCy,"%fStartHorizon%"); 

*' The equation calculates the transformation input to refineries for the energy form Crude Oil
*' in a specific scenario and year. The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation
*' output from refineries for the given energy form and year to the output in the previous year. This calculation is conditional on the refineries' capacity
*' being active in the specified starting horizon.The result represents the transformation input to refineries for crude oil in million tons of oil equivalent.
QInputTransfRef(runCy,"CRO",YTIME)$(TIME(YTIME) )..
         VInputTransfRef(runCy,"CRO",YTIME)
             =E=
         [
         VInputTransfRef(runCy,"CRO",YTIME-1) *
         sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec(runCy,EFS,YTIME)) /
         sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec(runCy,EFS,YTIME-1))  ]$iRefCapacity(runCy,"%fStartHorizon%");                   

*' The equation calculates the transformation output from nuclear plants for electricity production 
*' in a specific scenario and year. The output is computed as the sum of electricity production from all nuclear power plants in the given
*' scenario and year, multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent.
*' The result represents the transformation output from nuclear plants for electricity production in million tons of oil equivalent.
QOutTransfNuclear(runCy,"ELC",YTIME)$TIME(YTIME) ..
         VOutTransfNuclear(runCy,"ELC",YTIME) =E=SUM(PGNUCL,VProdElec(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation computes the transformation input to nuclear plants for a specific scenario and year.
*' The input is calculated based on the sum of electricity production from all nuclear power plants in the given scenario and year, divided
*' by the plant efficiency and multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe).
*' The result represents the transformation input to nuclear plants in million tons of oil equivalent.
QInpTransfNuclear(runCy,"NUC",YTIME)$TIME(YTIME)..
        VInpTransfNuclear(runCy,"NUC",YTIME) =E=SUM(PGNUCL,VProdElec(runCy,PGNUCL,YTIME)/iPlantEffByType(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation computes the transformation input to thermal power plants for a specific power generation form 
*' in a given scenario and year. The input is calculated based on the following conditions:
*' For conventional power plants that are not geothermal or nuclear, the transformation input is determined by the electricity production
*' from the respective power plant multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), divided by the
*' plant efficiency.For geothermal power plants, the transformation input is based on the electricity production from the geothermal plant multiplied by the conversion
*' factor.For combined heat and power plants , the input is calculated as the sum of the consumption of fuels in various demand subsectors and the electricity
*' production from the CHP plant . This sum is then divided by a factor based on the year to account for variations over time.The result represents
*' the transformation input to thermal power plants in million tons of oil equivalent.
QInpTransfTherm(runCy,PGEF,YTIME)$TIME(YTIME)..
         VInpTransfTherm(runCy,PGEF,YTIME)
             =E=
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$((not PGGEO(PGALL)) $(not PGNUCL(PGALL)))),
             VProdElec(runCy,PGALL,YTIME) * sTWhToMtoe /  iPlantEffByType(runCy,PGALL,YTIME))
        +
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$PGGEO(PGALL)),
             VProdElec(runCy,PGALL,YTIME) * sTWhToMtoe) 
        +
        sum(CHP$CHPtoEF(CHP,PGEF),  sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME))+sTWhToMtoe*VProdElecChp(runCy,CHP,YTIME))/(0.8+0.1*(ord(YTIME)-16)/32);

*' The equation calculates the transformation output from thermal power stations for a specific energy branch
*' in a given scenario and year. The result is computed based on the following conditions: 
*' If the energy branch is related to electricity, the transformation output from thermal power stations is the sum of electricity production from
*' conventional power plants and combined heat and power plants. The production values are converted from terawatt-hours (TWh) to
*' million tons of oil equivalent.
*' If the energy branch is associated with steam, the transformation output is determined by the sum of the consumption of fuels in various demand
*' subsectors, the rate of energy branch consumption over total transformation output, and losses.
*' The result represents the transformation output from thermal power stations in million tons of oil equivalent.
QOutTransfTherm(runCy,TOCTEF,YTIME)$TIME(YTIME)..
         VOutTransfTherm(runCy,TOCTEF,YTIME)
             =E=
        (
             sum(PGALL$(not PGNUCL(PGALL)),VProdElec(runCy,PGALL,YTIME)) * sTWhToMtoe
             +
             sum(CHP,VProdElecChp(runCy,CHP,YTIME)*sTWhToMtoe)
         )$ELCEF(TOCTEF)
        +
        (                                                                                                         
          sum(INDDOM,
          sum(CHP$SECTTECH(INDDOM,CHP), VConsFuel(runCy,INDDOM,CHP,YTIME)))+
          iRateEneBranCons(runCy,TOCTEF,YTIME)*(VConsFinEneCountry(runCy,TOCTEF,YTIME) + VConsFinNonEne(runCy,TOCTEF,YTIME) + VLossesDistr(runCy,TOCTEF,YTIME)) + 
          VLossesDistr(runCy,TOCTEF,YTIME)                                                                                    
         )$STEAM(TOCTEF); 
            
*' The equation calculates the total transformation input for a specific energy branch 
*' in a given scenario and year. The result is obtained by summing the transformation inputs from different sources, including
*' thermal power plants, District Heating Plants, nuclear plants, patent
*' fuel and briquetting plants, and refineries. In the case where the energy branch is "OGS"
*' (Other Gas), the total transformation input is calculated as the difference between the total transformation output and various consumption
*' and loss components. The outcome represents the total transformation input in million tons of oil equivalent.
QInpTotTransf(runCy,EFS,YTIME)$TIME(YTIME)..
         VInpTotTransf(runCy,EFS,YTIME)
                 =E=
        (
            VInpTransfTherm(runCy,EFS,YTIME) + VTransfInputDHPlants(runCy,EFS,YTIME) + VInpTransfNuclear(runCy,EFS,YTIME) +
             VInputTransfRef(runCy,EFS,YTIME)     !!$H2PRODEF(EFS)
        )$(not sameas(EFS,"OGS"))
        +
        (
          VOutTotTransf(runCy,EFS,YTIME) - VConsFinEneCountry(runCy,EFS,YTIME) - VConsFinNonEne(runCy,EFS,YTIME) - iRateEneBranCons(runCy,EFS,YTIME)*
          VOutTotTransf(runCy,EFS,YTIME) - VLossesDistr(runCy,EFS,YTIME)
        )$sameas(EFS,"OGS");            

*' The equation calculates the total transformation output for a specific energy branch in a given scenario and year.
*' The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants,
*' nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
*' as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
QOutTotTransf(runCy,EFS,YTIME)$TIME(YTIME)..
         VOutTotTransf(runCy,EFS,YTIME)
                 =E=
         VOutTransfTherm(runCy,EFS,YTIME) + VOutTransfDhp(runCy,EFS,YTIME) + VOutTransfNuclear(runCy,EFS,YTIME) +
         VOutTransfRefSpec(runCy,EFS,YTIME);        !!+ TONEW(runCy,EFS,YTIME)

*' The equation calculates the transfers of a specific energy branch in a given scenario and year.
*' The result is computed based on a complex formula that involves the previous year's transfers,
*' the residual for feedstocks in transfers, and various conditions.
*' In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers,
*' and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
QTransfers(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfers(runCy,EFS,YTIME) =E=
         (( (VTransfers(runCy,EFS,YTIME-1)*VConsFinEneCountry(runCy,EFS,YTIME)/VConsFinEneCountry(runCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
          (
                 VTransfers(runCy,"CRO",YTIME-1)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME))/
                 SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(runCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);         

*' The equation calculates the gross inland consumption excluding the consumption of a specific energy branch
*' in a given scenario and year. The result is computed by summing various components, including
*' total final energy consumption, final non-energy consumption, total transformation input and output, distribution losses, and transfers.
*' The outcome represents the gross inland consumption excluding the consumption of the specified energy branch in million tons of oil equivalent.
 QConsGrssInlNotEneBranch(runCy,EFS,YTIME)$TIME(YTIME)..
         VConsGrssInlNotEneBranch(runCy,EFS,YTIME)
                 =E=
         VConsFinEneCountry(runCy,EFS,YTIME) + VConsFinNonEne(runCy,EFS,YTIME) + VInpTotTransf(runCy,EFS,YTIME) - VOutTotTransf(runCy,EFS,YTIME) + VLossesDistr(runCy,EFS,YTIME) - 
         VTransfers(runCy,EFS,YTIME); 

*' The equation calculates the gross inland consumption for a specific energy branch in a given scenario and year.
*' This is computed by summing various components, including total final energy consumption, final consumption in the energy sector, final non-energy consumption,
*' total transformation input and output, distribution losses, and transfers. The result represents the gross inland consumption in million tons of oil equivalent.
QConsGrssInl(runCy,EFS,YTIME)$TIME(YTIME)..
         VConsGrssInl(runCy,EFS,YTIME)
                 =E=
         VConsFinEneCountry(runCy,EFS,YTIME) + VConsFiEneSec(runCy,EFS,YTIME) + VConsFinNonEne(runCy,EFS,YTIME) + VInpTotTransf(runCy,EFS,YTIME) - VOutTotTransf(runCy,EFS,YTIME) +
          VLossesDistr(runCy,EFS,YTIME) - VTransfers(runCy,EFS,YTIME);  

*' The equation calculates the primary production for a specific primary production definition in a given scenario and year.
*' The computation involves different scenarios based on the type of primary production definition:
*' For primary production definitions the primary production is directly proportional to the rate of primary production in total primary needs,
*' and it depends on gross inland consumption not including the consumption of the energy branch.
*' For Natural Gas primary production, the calculation considers a specific formula involving the rate of primary production in total primary needs, residuals for
*' hard coal, natural gas, and oil primary production, the elasticity related to gross inland consumption for natural gas, and other factors. Additionally, there is a lag
*' effect with coefficients for primary oil production.
*' For Crude Oil primary production, the computation includes the rate of primary production in total primary needs, residuals for hard coal, natural gas, and oil
*' primary production, the fuel primary production, and a product term involving the polynomial distribution lag coefficients for primary oil production.
*' The result represents the primary production in million tons of oil equivalent.
QProdPrimary(runCy,PPRODEF,YTIME)$TIME(YTIME)..
         VProdPrimary(runCy,PPRODEF,YTIME)
                 =E=  [
         (
             iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) * (VConsGrssInlNotEneBranch(runCy,PPRODEF,YTIME) +  VConsFiEneSec(runCy,PPRODEF,YTIME))
         )$(not (sameas(PPRODEF,"CRO")or sameas(PPRODEF,"NGS")))
         +
         (
             iResHcNgOilPrProd(runCy,PPRODEF,YTIME) * VProdPrimary(runCy,PPRODEF,YTIME-1) *
             (VConsGrssInlNotEneBranch(runCy,PPRODEF,YTIME)/VConsGrssInlNotEneBranch(runCy,PPRODEF,YTIME-1))**iNatGasPriProElst(runCy)
         )$(sameas(PPRODEF,"NGS") )
        +
         (
           iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) * VProdPrimary(runCy,PPRODEF,YTIME-1) *
           ((VConsGrssInlNotEneBranch(runCy,PPRODEF,YTIME) + VExp(runCy,PPRODEF,YTIME))/
            (VConsGrssInlNotEneBranch(runCy,PPRODEF,YTIME-1) + VExp(runCy,PPRODEF,YTIME-1)))
         )$(sameas(PPRODEF,"NGS") )
         +(
           iResHcNgOilPrProd(runCy,PPRODEF,YTIME) *  iFuelPriPro(runCy,PPRODEF,YTIME) *
           prod(kpdl$(ord(kpdl) lt 5),
                         (iPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1))/iPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1)))
                         **(0.2*iPolDstrbtnLagCoeffPriOilPr(kpdl)))
         )$sameas(PPRODEF,"CRO")   ]$iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME);   

*' The equation calculates the fake exports for a specific energy branch
*' in a given scenario and year. The computation is based on the fuel exports for
*' the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
QExp(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..
         VExp(runCy,EFS,YTIME)
                 =E=
         (
                 iFuelExprts(runCy,EFS,YTIME)
         )
+  iFuelExprts(runCy,EFS,YTIME);

*' The equation computes the fake imports for a specific energy branch 
*' in a given scenario and year. The calculation is based on different conditions for various energy branches,
*' such as electricity, crude oil, and natural gas. The equation involves gross inland consumption,
*' fake exports, consumption of fuels in demand subsectors, electricity imports,
*' and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
QImp(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..

         VImp(runCy,EFS,YTIME)

                 =E=
         (
            iRatioImpFinElecDem(runCy,YTIME) * (VConsFinEneCountry(runCy,EFS,YTIME) + VConsFinNonEne(runCy,EFS,YTIME)) + VExp(runCy,EFS,YTIME)
         + iElecImp(runCy,YTIME)
         )$ELCEF(EFS)
         +
         (
            VConsGrssInl(runCy,EFS,YTIME)+ VExp(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VProdPrimary(runCy,EFS,YTIME)
         )$(sameas(EFS,"CRO"))

         +
         (
            VConsGrssInl(runCy,EFS,YTIME)+ VExp(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VProdPrimary(runCy,EFS,YTIME)
         )$(sameas(EFS,"NGS"))
         +iImpExp(runCy,"NGS",YTIME)$(sameas(EFS,"NGS"))
         +
         (
            (1-iRatePriProTotPriNeeds(runCy,EFS,YTIME)) *
            (VConsGrssInl(runCy,EFS,YTIME) + VExp(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS) )
         )$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));

*' The equation computes the net imports for a specific energy branch 
*' in a given scenario and year. It subtracts the fake exports from the fake imports for
*' all fuels except natural gas . The result represents the net imports in million tons of oil equivalent.
QImpNetEneBrnch(runCy,EFS,YTIME)$TIME(YTIME)..
         VImpNetEneBrnch(runCy,EFS,YTIME)
                 =E=
         VImp(runCy,EFS,YTIME) - VExp(runCy,EFS,YTIME);
                               
*' The equation calculates the final energy consumption in the energy sector.
*' It considers the rate of energy branch consumption over the total transformation output.
*' The final consumption is determined based on the total transformation output and primary production for energy
*' branches, excluding Oil, Coal, and Gas. The result, VConsFiEneSec, represents the final consumption in million tons of
*' oil equivalent for the specified scenario and year.
QConsFiEneSec(runCy,EFS,YTIME)$TIME(YTIME)..
         VConsFiEneSec(runCy,EFS,YTIME)
                 =E=
         iRateEneBranCons(runCy,EFS,YTIME) *
         (
           (
              VOutTotTransf(runCy,EFS,YTIME) +
              VProdPrimary(runCy,EFS,YTIME)$(sameas(EFS,"CRO") or sameas(EFS,"NGS"))
            )$(not TOCTEF(EFS))
            +
            (
              VConsFinEneCountry(runCy,EFS,YTIME) + VConsFinNonEne(runCy,EFS,YTIME) + VLossesDistr(runCy,EFS,YTIME)
            )$TOCTEF(EFS)
         );                              

*' * CO2 SEQUESTRATION COST CURVES

*' The equation calculates the CO2 captured by electricity and hydrogen production plants
*' in million tons of CO2 for a specific scenario and year. The CO2 capture is determined by summing 
*' the product of electricity production from plants with carbon capture and storage, the conversion
*' factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), the plant efficiency,
*' the CO2 emission factor, and the plant CO2 capture rate. 
QCapCo2ElecHydr(runCy,YTIME)$TIME(YTIME)..
         VCapCo2ElecHydr(runCy,YTIME)
         =E=
         sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                 VProdElec(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
                 iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)));

*' The equation calculates the cumulative CO2 captured in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
QCaptCummCo2(runCy,YTIME)$TIME(YTIME)..
         VCaptCummCo2(runCy,YTIME) =E= VCaptCummCo2(runCy,YTIME-1)+VCapCo2ElecHydr(runCy,YTIME-1);   

*' The equation computes the transition weight from a linear to exponential CO2 sequestration
*' cost curve for a specific scenario and year. The transition weight is determined based on the cumulative CO2 captured
*' and parameters defining the transition characteristics.The transition weight is calculated using a logistic function.
*' This equation provides a mechanism to smoothly transition from a linear to exponential cost curve based on the cumulative CO2 captured, allowing
*' for a realistic representation of the cost dynamics associated with CO2 sequestration. The result represents the weight for
*' the transition in the specified scenario and year.
QTrnsWghtLinToExp(runCy,YTIME)$TIME(YTIME)..
         VTrnsWghtLinToExp(runCy,YTIME)
         =E=
         1/(1+exp(-iElastCO2Seq(runCy,"mc_s")*( VCaptCummCo2(runCy,YTIME)/iElastCO2Seq(runCy,"pot")-iElastCO2Seq(runCy,"mc_m")))); 

*' The equation calculates the cost curve for CO2 sequestration costs in Euro per ton of CO2 sequestered
*' for a specific scenario and year. The cost curve is determined based on cumulative CO2 captured and
*' elasticities for the CO2 sequestration cost curve.The equation is formulated to represent a flexible cost curve that
*' can transition from linear to exponential. The transition is controlled by the weight for the transition from linear to exponential
*' The cost curve is expressed as a combination of linear and exponential functions, allowing for a realistic.
*' representation of the relationship between cumulative CO2 captured and sequestration costs. This equation provides a dynamic and
*' realistic approach to modeling CO2 sequestration costs, considering the cumulative CO2 captured and the associated elasticities
*' for the cost curve. The result represents the cost of sequestering one ton of CO2 in the specified scenario and year.
QCstCO2SeqCsts(runCy,YTIME)$TIME(YTIME)..
         VCstCO2SeqCsts(runCy,YTIME) =E=
       (1-VTrnsWghtLinToExp(runCy,YTIME))*(iElastCO2Seq(runCy,"mc_a")*VCaptCummCo2(runCy,YTIME)+iElastCO2Seq(runCy,"mc_b"))+
       VTrnsWghtLinToExp(runCy,YTIME)*(iElastCO2Seq(runCy,"mc_c")*exp(iElastCO2Seq(runCy,"mc_d")*VCaptCummCo2(runCy,YTIME)));           


*' * EMISSIONS CONSTRAINTS 

*' The equation computes the total CO2 equivalent greenhouse gas emissions in all countries
*' per National Allocation Plan (NAP) sector for a specific year. The result represents the 
*' sum of CO2 emissions for each NAP sector across all countries.The equation involves several components:
*' The consumption of fuels in each demand subsector, excluding heat from heat pumps, is considered.
*' The emissions are calculated based on the fuel consumption and the CO2 emission factor for each subsector.
*' Transformation Input to Thermal Power Plants is considered,
*' and the emissions are calculated based on the input and the CO2 emission factor.
*' Transformation Input to District Heating Plants : The transformation input to district heating plants is considered,
*' and emissions are calculated based on the input and the CO2 emission factor.
*' Final Consumption in Energy Sector : The final consumption in the energy sector is considered, and emissions are calculated based
*' on the consumption and the CO2 emission factor.
*' Electricity Production: The emissions from electricity production are considered, including adjustments for plant efficiency,
*' CO2 emission factors, and the CO2 capture rate for plants with carbon capture and storage.
*' The equation provides a comprehensive approach to calculating CO2eq emissions for each NAP sector, considering various aspects of fuel consumption
*' and transformation across different subsectors. The result represents the overall CO2 emissions for each NAP sector across
*' all countries for the specified year.
QGrnnHsEmisCo2Equiv(NAP,YTIME)$TIME(YTIME)..
         VGrnnHsEmisCo2Equiv(NAP,YTIME)
          =E=
        (
        sum(runCy,
                 sum((EFS,INDSE)$(SECTTECH(INDSE,EFS)  $NAPtoALLSBS(NAP,INDSE)),
                      VConsFuel(runCy,INDSE,EFS,YTIME) * iCo2EmiFac(runCy,INDSE,EFS,YTIME)) !! final consumption
                +
                 sum(PGEF, VInpTransfTherm(runCy,PGEF,YTIME)*iCo2EmiFac(runCy,"PG",PGEF,YTIME)$(not h2f1(pgef))) !! input to power generation sector
                 +
                 sum(EFS, VTransfInputDHPlants(runCy,EFS,YTIME)*iCo2EmiFac(runCy,"PG",EFS,YTIME)) !! input to district heating plants
                 +
                 sum(EFS, VConsFiEneSec(runCy,EFS,YTIME)*iCo2EmiFac(runCy,"PG",EFS,YTIME)) !! consumption of energy branch

                 -
                 sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                         VProdElec(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
                         iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)))));   !! CO2 captured by CCS plants in power generation

*' The equation computes the total CO2 equivalent greenhouse gas emissions in all countries for a specific year.
*' The result represents the sum of total CO2eq emissions across all countries. The summation is performed over the NAP (National Allocation Plan) sectors,
*' considering the total CO2 GHG emissions per NAP sectorfor each country. This equation provides a concise and systematic approach to aggregating
*' greenhouse gas emissions at a global level, considering contributions from different sectors and countries. 
qGrnnHsEmisCo2EquivAllCntr(YTIME)$TIME(YTIME)..

         vGrnnHsEmisCo2EquivAllCntr(YTIME) 
         =E=
         sum(NAP, VGrnnHsEmisCo2Equiv(NAP,YTIME));

*' Compute households expenditures on energy by utilizing the sum of consumption of remaining substitutable equipment multiplied by the fuel prices per subsector and fuel 
*' minus the efficiency values divided by CO2 emission factors per subsector and multiplied by the sum of carbon prices for all countries and adding the Electricity price
*' to Industrial and Residential Consumers multiplied by Consumption of non-substituable electricity in Industry and Tertiary divided by TWh to Mtoe conversion factor.
qExpendHouseEne(runCy,YTIME)$TIME(YTIME)..
                 vExpendHouseEne(runCy,YTIME)
                 =E= 
                 SUM(DSBS$HOU(DSBS),SUM(EF$SECTTECH(dSBS,EF),VConsRemSubEquipSubSec(runCy,DSBS,EF,YTIME)*(VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME)-iEffValueInEuro(runCy,DSBS,YTIME)/
                 1000-iCo2EmiFac(runCy,"PG",EF,YTIME)*sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))/1000)))
                                          +VPriceElecIndResNoCliPol(runCy,"R",YTIME)*VConsElecNonSubIndTert(runCy,"HOU",YTIME)/sTWhToMtoe;         

*' * Prices

*' The equation computes fuel prices per subsector and fuel with separate carbon values in
*' each sector for a specific scenario, subsector, fuel, and year.The equation considers various scenarios based
*' on the type of fuel and whether it is subject to changes in carbon values. It incorporates factors such as carbon emission factors
*' carbon values for all countries, electricity prices to industrial and residential consumers,
*' efficiency values, and the total hydrogen cost per sector.The result of the equation is the fuel price per 
*' subsector and fuel, adjusted based on changes in carbon values, electricity prices, efficiency, and hydrogen costs.
QPriceFuelSubCarVal(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $TIME(YTIME) $(not sameas("NUC",EF)))..
         VPriceFuelSubCarVal(runCy,SBS,EF,YTIME)
                 =E=
         (VPriceFuelSubCarVal(runCy,SBS,EF,YTIME-1) +
          iCo2EmiFac(runCy,SBS,EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SBS),(VCarVal(runCy,NAP,YTIME)))/1000
         )$( not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF)))
         +
         (
VPriceFuelSubCarVal(runCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF)
         )
         +
         (
           ( VPriceElecIndResConsu(runCy,"i",YTIME)$INDTRANS(SBS)+VPriceElecIndResConsu(runCy,"r",YTIME)$RESIDENT(SBS))/sTWhToMtoe
            +
            ((iEffValueInEuro(runCy,SBS,YTIME))/1000)$DSBS(SBS)
         )$(ELCEF(EF) or HEATPUMP(EF))
         +
         (
                 iHydrogenPri(runCy,SBS,YTIME-1)$DSBS(SBS)
         )$(H2EF(EF) or sameas("STE1AH2F",EF));

*' The equation calculates the fuel prices per subsector and fuel multiplied by weights
*' considering separate carbon values in each sector. This equation is applied for a specific scenario, subsector, fuel, and year.
*' The calculation involves multiplying the sector's average price weight based on fuel consumption by the fuel price per subsector
*' and fuel. The weights are determined by the sector's average price, considering the specific fuel consumption for the given scenario, subsector, and fuel.
*' This equation allows for a more nuanced calculation of fuel prices, taking into account the carbon values in each sector. The result represents the fuel
*' prices per subsector and fuel, multiplied by the corresponding weights, and adjusted based on the specific carbon values in each sector.
QPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $TIME(YTIME))..
        VPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME)
          =E= 
        iWgtSecAvgPriFueCons(runCy,DSBS,EF) * VPriceFuelSubCarVal(runCy,DSBS,EF,YTIME);

*' The equation calculates the average fuel price per subsector for a specific scenario, subsector, and year.
*' The calculation involves summing the product of fuel prices per subsector and fuel and their corresponding weights
*' for the specified scenario, subsector, and year.The equation is designed to compute the weighted average fuel price, considering
*' different fuels within the subsector and their respective weights.
QPriceFuelAvgSub(runCy,DSBS,YTIME)$TIME(YTIME)..
        VPriceFuelAvgSub(runCy,DSBS,YTIME)
                 =E=
         sum(EF$SECTTECH(DSBS,EF), VPriceFuelSepCarbonWght(runCy,DSBS,EF,YTIME));         

*' The equation calculates the electricity price for industrial and residential consumers
*' in a given scenario, energy set, and year. The electricity price is based on the previous year's production costs, incorporating
*' various factors such as fuel prices, factors affecting electricity prices to consumers, and long-term average
*' power generation costs. The equation is structured to handle different energy sets. It calculates the electricity
*' price for industrial consumers and residential consumers separately. The electricity price is influenced by fuel prices,
*' factors affecting electricity prices, and long-term average power generation costs. It provides a comprehensive representation of the
*' factors contributing to the electricity price for industrial and residential consumers in the specified scenario, energy set, and year.
QPriceElecIndResConsu(runCy,ESET,YTIME)$TIME(YTIME)..  !! The electricity price is based on previous year's production costs
        VPriceElecIndResConsu(runCy,ESET,YTIME)
                 =E=
        (1 + iVAT(runCy,YTIME)) *
        (
           (
             (VPriceFuelSubCarVal(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"IND_RES",YTIME-1)+
                VCostPowGenAvgLng(runCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VPriceFuelSubCarVal(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"TERT_RES",YTIME-1)+
               VCostPowGenAvgLng(runCy,"r",YTIME-1)
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' * Define dummy objective function
qDummyObj.. vDummyObj =e= 1;
