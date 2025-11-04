*' @title Equations of OPEN-PROMs Power Generation
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' Power Generation


*' This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
*' including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
*' generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
Q04CapElecCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CapElecCHP(allCy,CHP,YTIME)
         =E=
         sum(INDDOM,VmConsFuel(allCy,INDDOM,CHP,YTIME)) * 1/smTWhToMtoe *
         VmPriceElecInd(allCy,YTIME) / 
         sum(PGALL$CHPtoEON(CHP,PGALL), i04AvailRate(PGALL,YTIME)) / 
         i04UtilRateChpPlants(allCy,CHP,YTIME) /
         smGwToTwhPerYear(YTIME);  

* Lambda (λₜ) defines the exponential decay rate of the peak load over time.
* It is calibrated to match total electricity production given peak and base load levels.
* The equation ensures (by integrating) 
* that the area under the decaying load curve equals total electricity demand.
Q04Lambda(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (1 - exp( -V04Lambda(allCy,YTIME)*smGwToTwhPerYear(YTIME)))  / (0.0001+V04Lambda(allCy,YTIME))
             =E=
         (V04DemElecTot(allCy,YTIME) - smGwToTwhPerYear*VmBaseLoad(allCy,YTIME))
         / (VmPeakLoad(allCy,YTIME) - VmBaseLoad(allCy,YTIME));

*' The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
*' distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
*' which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
*' to the total electricity demand.
Q04DemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04DemElecTot(allCy,YTIME)
             =E=
         1/smTWhToMtoe *
         ( VmConsFinEneCountry(allCy,"ELC",YTIME) + VmConsFinNonEne(allCy,"ELC",YTIME) + VmLossesDistr(allCy,"ELC",YTIME)
           + VmConsFiEneSec(allCy,"ELC",YTIME) - VmImpNetEneBrnch(allCy,"ELC",YTIME)
         );

*' This equation computes the estimated base load as a quantity dependent on the electricity demand per final sector,
*' as well as the baseload share of demand per sector, the rate of losses for final Consumption, the net imports,
*' distribution losses and final consumption in energy sector.
Q04BsldEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04BsldEst(allCy,YTIME)
             =E=
         (
             sum(DSBS, i04BaseLoadShareDem(allCy,DSBS,YTIME)*V04ConsElec(allCy,DSBS,YTIME))*(1+imRateLossesFinCons(allCy,"ELC",YTIME))*
             (1 - VmImpNetEneBrnch(allCy,"ELC",YTIME)/(sum(DSBS, V04ConsElec(allCy,DSBS,YTIME))+VmLossesDistr(allCy,"ELC",YTIME)))
             + 0.5*VmConsFiEneSec(allCy,"ELC",YTIME)
         ) / smTWhToMtoe / smGwToTwhPerYear;

*' This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
*' and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
*' of electricity demand per sector
Q04LoadFacDom(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04LoadFacDom(allCy,YTIME)
             =E=
         (sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME))) /
         (
          sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + 
          sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)/i04LoadFacElecDem(TRANSE))
        );         

*' The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result
*' to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period, taking into account the domestic
*' load factor.
Q04PeakLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmPeakLoad(allCy,YTIME)
             =E=
         V04DemElecTot(allCy,YTIME)/(V04LoadFacDom(allCy,YTIME)*smGwToTwhPerYear(YTIME));

*' This equation calculates the baseload corresponding to maximum load by multiplying the maximum load factor of electricity demand
*' to the electricity peak load, minus the baseload corresponding to maximum load factor.
Q04BaseLoadMax(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (V04DemElecTot(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)*smGwToTwhPerYear(YTIME))
             =E=
         i04MxmLoadFacElecDem(allCy,YTIME)*(VmPeakLoad(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME))*smGwToTwhPerYear(YTIME);  

*' This equation calculates the electricity base load utilizing exponential functions that include the estimated base load,
*' the baseload corresponding to maximum load factor, and the parameter of baseload correction.
Q04BaseLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmBaseLoad(allCy,YTIME)
             =E=
         (1/(1+exp(i04BslCorrection(allCy,YTIME)*(V04BsldEst(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)))))*V04BsldEst(allCy,YTIME)
        +(1-1/(1+exp(i04BslCorrection(allCy,YTIME)*(V04BsldEst(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)))))*V04BaseLoadMax(allCy,YTIME);

* The peak load follows an exponential decay function defined by the parameter lambda.
* Total electricity production is approximated with midpoint approximation of the peak load integral.
Q04ProdElecReqTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04ProdElecReqTot(allCy,YTIME)
             =E=
         sum(HOUR, (VmPeakLoad(allCy,YTIME)-VmBaseLoad(allCy,YTIME))
                   * exp(-V04Lambda(allCy,YTIME)*(0.25+(ord(HOUR)-1)))
             ) + 9*VmBaseLoad(allCy,YTIME);   

*' The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
*' the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
*' generation capacity based on the changes in peak load.
Q04CapElecTotEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmCapElecTotEst(allCy,YTIME)
             =E=
        VmCapElecTotEst(allCy,YTIME-1) * VmPeakLoad(allCy,YTIME)/VmPeakLoad(allCy,YTIME-1);          

*' The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
*' including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
*' The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
*' for renewable plants (excluding certain types) and fossil fuel plants.
Q04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)
                  =E=
                  
        ( 
          ( 
            imDisc(allCy,"PG",YTIME-1) * exp(imDisc(allCy,"PG",YTIME-1) * i04TechLftPlaType(allCy,PGALL)) /
            (exp(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) -1)
          ) *
          i04GrossCapCosSubRen(allCy,PGALL,YTIME-1) * 1E3 * imCGI(allCy,YTIME-1)  + i04FixOandMCost(allCy,PGALL,YTIME-1)
        ) /
        i04AvailRate(PGALL,YTIME-1) / (1000*(ord(HOUR)-1+0.25))
        + i04VarCost(PGALL,YTIME-1) / 1E3 + 
        (imRenValue(YTIME-1)*8.6e-5)$(not (PGREN(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
        sum(PGEF$PGALLtoEF(PGALL,PGEF), 
          (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME-1) +
          imCO2CaptRate(allCy,PGALL,YTIME-1) * VmCstCO2SeqCsts(allCy,YTIME-1) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME-1) +
          (1-imCO2CaptRate(allCy,PGALL,YTIME-1)) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME-1) *
          (sum(NAP$NAPtoALLSBS(NAP,"PG"), imCarVal(allCy,NAP,YTIME-1)))
          ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,YTIME-1)
        )$(not PGREN(PGALL));

*' The equation calculates the hourly production cost for
*' a given technology without carbon capture and storage investments. 
*' The result is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The equation is based on the power plant's share in new equipment and
*' the hourly production cost of technology without CCS . Additionally, 
*' it considers the contribution of other technologies with CCS by summing their
*' shares in new equipment multiplied by their respective hourly production
*' costs. The equation reflects the cost dynamics associated with technology investments and provides
*' insights into the hourly production cost for power generation without CCS.
Q04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy)) ..
         V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME) =E=
         V04ShareNewTechNoCCS(allCy,PGALL,YTIME)*V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS(allCy,CCS,YTIME)*V04CostHourProdInvDec(allCy,CCS,HOUR,YTIME)); 

*' The equation reflects a dynamic relationship where the sensitivity
*' to CCS acceptance is influenced by the carbon prices of different countries.
*' The result provides a measure of the sensitivity of CCS acceptance
*' based on the carbon values in the previous year.
Q04SensCCS(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04SensCCS(allCy,YTIME) =E= 10+EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME-1)))));

*' The equation computes the hourly production cost used in investment decisions, taking into account the acceptance of Carbon Capture and Storage .
*' The production cost is modified based on the sensitivity of CCS acceptance. The sensitivity is used as an exponent
*' to adjust the original production cost for power generation plants during each hour and for the specified year .
*' This adjustment reflects the impact of CCS acceptance on the production cost.
$ontext
q04CostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         v04CostHourProdInvCCS(allCy,PGALL,HOUR,YTIME) 
         =E=
          V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-V04SensCCS(allCy,YTIME));
$offtext

*' The equation calculates the production cost of a technology for a specific power plant and year. 
*' The equation involves the hourly production cost of the technology
*' and a sensitivity variable controlling carbon capture and storage acceptance.
*' The summation over hours is weighted by the inverse of the technology's hourly production cost raised to the 
*' power of minus one-fourth of the sensitivity variable. 
Q04CostProdSpecTech(allCy,PGALL,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         V04CostProdSpecTech(allCy,PGALL,YTIME) 
         =E=  
         sum(HOUR,V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-V04SensCCS(allCy,YTIME))) ;

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is implemented. The
*' share is determined based on a formulation that considers the production costs of the technology.
*' The numerator of the share calculation involves a factor of 1.1 multiplied
*' by the production cost of the technology for the specific power plant and year. The denominator
*' includes the sum of the numerator and the production costs of other power plant types without CCS.
Q04ShareNewTechCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $CCS(PGALL) $runCy(allCy))..
         V04ShareNewTechCCS(allCy,PGALL,YTIME) =E=
         1.1 *V04CostProdSpecTech(allCy,PGALL,YTIME)
         /(1.1*V04CostProdSpecTech(allCy,PGALL,YTIME)
           + sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),V04CostProdSpecTech(allCy,PGALL2,YTIME))
           );         

*' The equation calculates the power plant's share in new equipment 
*' for a specific power plant and year when carbon capture and storage is not implemented .
*' The equation is based on the complementarity relationship, expressing that the power plant's share in
*' new equipment without CCS is equal to one minus the sum of the shares of power plants with CCS in the
*' new equipment. The sum is taken over all power plants with CCS for the given power plant type and year .
Q04ShareNewTechNoCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy))..
         V04ShareNewTechNoCCS(allCy,PGALL,YTIME) 
         =E= 
         1 - sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS(allCy,CCS,YTIME));

*' Compute the variable cost of each power plant technology for every region,
*' By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
Q04CostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
        V04CostVarTech(allCy,PGALL,YTIME) 
             =E=
        i04VarCost(PGALL,YTIME)/1E3 + 
        sum(
          PGEF$PGALLtoEF(PGALL,PGEF),
          (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441 +
          imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
          (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)
          *(sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))
          *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)
        )$(not PGREN(PGALL));

*' The equation calculates the variable for a specific
*' power plant and year when the power plant is not subject to endogenous scrapping. The calculation involves raising the variable
*' cost of the technology for the specified power plant and year to the power of -5.
Q04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)$(time(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME) 
              =E=
          V04CostVarTech(allCy,PGALL,YTIME)**(-5);

*' The equation calculates the production cost of a technology 
*' for a specific power plant and year. The equation involves various factors, including discount rates, technical
*' lifetime of the plant type, gross capital cost with subsidies for renewables, capital goods index, fixed operation 
*' and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, CO2 capture rates, cost
*' curve for CO2 sequestration costs, CO2 emission factors, carbon values, plant efficiency, and specific conditions excluding
*' renewable power plants . The equation reflects the complex dynamics of calculating the production cost, considering both economic and technical parameters.
Q04CostProdTeCHPreReplac(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostProdTeCHPreReplac(allCy,PGALL,YTIME) =e=
                        (
                          ((imDisc(allCy,"PG",YTIME) * exp(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))/
                          (exp(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) -1))
                            * i04GrossCapCosSubRen(allCy,PGALL,YTIME)* 1E3 * imCGI(allCy,YTIME)  + 
                            i04FixOandMCost(allCy,PGALL,YTIME))/(smGwToTwhPerYear(YTIME)*1000*i04AvailRate(PGALL,YTIME))
                           + (i04VarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), 
                           (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+
                            imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                             (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))
                                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME))$(not PGREN(PGALL)))
                         );

*' The equation calculates the production cost of a technology used in premature replacement,
*' considering plant availability rates. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
*' The equation involves the production cost of the technology used in premature replacement without considering availability rates 
*' and incorporates adjustments based on the availability rates of two power plants .
Q04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME) =E=
         i04AvailRate(PGALL,YTIME)/i04AvailRate(PGALL2,YTIME)*V04CostProdTeCHPreReplac(allCy,PGALL,YTIME)+
         V04CostVarTech(allCy,PGALL,YTIME)*(1-i04AvailRate(PGALL,YTIME)/i04AvailRate(PGALL2,YTIME));  

*' The equation computes the endogenous scrapping index for power generation plants  during the specified year .
*' The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
*' divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
*' parameter is applied to the sum of full costs and raised to the power of -5. The resulting index is used to determine the endogenous scrapping of power plants.
Q04IndxEndogScrap(allCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         V04IndxEndogScrap(allCy,PGALL,YTIME)
                 =E=
         V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)/
         (V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)+(i04ScaleEndogScrap(PGALL)*
         sum(PGALL2,V04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)))**(-5));

*' The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
*' It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
*' total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
Q04CapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V04CapElecNonCHP(allCy,YTIME)
          =E=
      VmCapElecTotEst(allCy,YTIME) - 0*SUM(CHP,V04CapElecCHP(allCy,CHP,YTIME) * 0.85);      

*' In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
*' decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
Q04GapGenCapPowerDiff(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04GapGenCapPowerDiff(allCy,YTIME)
            =E=
        (
          (
            V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
            sum(PGALL, V04CapElec2(allCy,PGALL,YTIME-1) * (1 - V04IndxEndogScrap(allCy,PGALL,YTIME))) +
            sum(PGALL, (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(PGALL,YTIME)) + 
            sum(PGALL$PGSCRN(PGALL),
              (VmCapElec(allCy,PGALL,YTIME-1) - i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(PGALL,YTIME)) /
              i04TechLftPlaType(allCy,PGALL))
          ) + 0 +
          SQRT(SQR(
          (
            V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
            sum(PGALL,V04CapElec2(allCy,PGALL,YTIME-1) * (1 - V04IndxEndogScrap(allCy,PGALL,YTIME))) +
            sum(PGALL, (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(PGALL,YTIME)) +
            sum(PGALL$PGSCRN(PGALL), 
              (VmCapElec(allCy,PGALL,YTIME-1) - i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(PGALL,YTIME)) /
              i04TechLftPlaType(allCy,PGALL))
       ) -0) + SQR(1e-10) ) 
       )/2;

*' The equation  calculates a temporary variable 
*' that facilitates the scaling in the Weibull equation. The equation involves
*' the hourly production costs of technology for power plants
*' with carbon capture and storage and without CCS . The production 
*' costs are raised to the power of -6, and the result is used as a scaling factor
*' in the Weibull equation. The equation captures the cost-related considerations 
*' in determining the scaling factor for the Weibull equation based on the production costs of different technologies.
$ontext
q04ScalWeibull(allCy,PGALL,HOUR,YTIME)$((not CCS(PGALL))$TIME(YTIME) $runCy(allCy))..
          v04ScalWeibull(allCy,PGALL,HOUR,YTIME) 
         =E=
         (V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
         +
          V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$NOCCS(PGALL))**(-6);     
$offtext



*' The equation calculates the minimum allowed renewable potential for a specific renewable energy form and country 
*' in the given year . Including:
*' The renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in a previous equation.
*' The minimum renewable potential for the specified renewable energy form and country in the given year.
*' The minimum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the minimum renewable potential.
*' This formulation ensures that the potential does not fall below the minimum allowed value.
$ontext
q04PotRenMinAllow(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..  
         v04PotRenMinAllow(allCy,PGRENEF,YTIME) =E=
         ( V04PotRenSuppCurve(allCy,PGRENEF,YTIME) + iMinRenPotential(allCy,PGRENEF,YTIME))/2;
$offtext
*' The equation calculates a maturity multiplier for renewable technologies. If the technology is renewable , the multiplier is determined
*' based on an exponential function that involves the ratio of the planned electricity generation capacities of renewable technologies to the renewable potential
*' supply curve. This ratio is adjusted using a logistic function with parameters that influence the maturity of renewable technologies. If the technology is not
*' renewable, the maturity multiplier is set to 1. The purpose is to model the maturity level of renewable technologies based on their
*' planned capacities relative to the renewable potential supply curve.
Q04RenTechMatMultExpr(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
          V04RenTechMatMultExpr(allCy,PGALL,YTIME)
              =E=
          (
            V04CapElecNominal(allCy,PGALL,YTIME-1) /
            sum(PGALL2, V04CapElecNominal(allCy,PGALL2,YTIME-1))
          )
          $(PGREN(PGALL));

Q04RenTechMatMult(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04RenTechMatMult(allCy,PGALL,YTIME)
          =E=
         2 / (1+exp(9*V04RenTechMatMultExpr(allCy,PGALL,YTIME)));  

*' The equation calculates a temporary variable which is used to facilitate scaling in the Weibull equation. The scaling is influenced by three main factors:
*' Maturity Factor for Planned Available Capacity : This factor represents the material-specific influence on the planned available capacity for a power
*' plant. It accounts for the capacity planning aspect of the power generation technology.
*' Renewable Technologies Maturity Multiplier: This multiplier reflects the maturity level of renewable technologies. It adjusts the scaling based on how
*' mature and established the renewable technology is, with a higher maturity leading to a larger multiplier.
*' Hourly Production Costs : The summation involves the hourly production costs of the technology raised to the power of -6. This suggests that higher
*' production costs contribute less to the overall scaling, emphasizing the importance of cost efficiency in the scaling process.
*' The result is a combined measure that takes into account material factors, technology maturity, and cost efficiency in the context of the Weibull
*' equation, providing a comprehensive basis for scaling considerations.
Q04ScalWeibullSum(allCy,PGALL,YTIME)$((not CCS(PGALL)) $TIME(YTIME) $runCy(allCy))..
         V04ScalWeibullSum(allCy,PGALL,YTIME) 
         =E=
              i04MatFacPlaAvailCap(allCy,PGALL,YTIME) * V04RenTechMatMult(allCy,PGALL,YTIME)*
              sum(HOUR,
                 (V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
                 +
                 V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$NOCCS(PGALL)
                 )**(-1)
              ); 
  
*' The equation calculates the variable representing the new investment decision for power plants in a given country and time period.
*' It sums the values for all power plants that do not have carbon capture and storage technology .
*' The values capture the scaling factors influenced by material-specific factors, renewable technology maturity,
*' and cost efficiency considerations. Summing these values over relevant power plants provides an aggregated measure for informing new investment decisions, emphasizing
*' factors such as technology readiness and economic viability.
Q04NewInvElec(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04NewInvElec(allCy,YTIME)
             =E=
         sum(PGALL$(not CCS(PGALL)),V04ScalWeibullSum(allCy,PGALL,YTIME));

*' The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
*' and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
*' For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
*' overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
*' as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
*' without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)$(TIME(YTIME) $runCy(allCy)) ..
        V04SharePowPlaNewEq(allCy,PGALL,YTIME)
             =E=
        (V04ScalWeibullSum(allCy,PGALL,YTIME)/ V04NewInvElec(allCy,YTIME))$(not CCS(PGALL)) +
        sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),V04SharePowPlaNewEq(allCy,NOCCS,YTIME))$CCS(PGALL);

*' This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
*' and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
*' The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
Q04CapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmCapElec(allCy,PGALL,YTIME)
             =E=
         (V04CapElec2(allCy,PGALL,YTIME-1)*V04IndxEndogScrap(allCy,PGALL,YTIME-1) +
          V04NewCapElec(allCy,PGALL,YTIME) -
          i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(PGALL,YTIME)
         ) -
         ((VmCapElec(allCy,PGALL,YTIME-1)-i04PlantDecomSched(allCy,PGALL,YTIME-1))* 
         i04AvailRate(PGALL,YTIME)*(1/i04TechLftPlaType(allCy,PGALL)))$PGSCRN(PGALL);

Q04CapElecNominal(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
          V04CapElecNominal(allCy,PGALL,YTIME)
              =E=
          VmCapElec(allCy,PGALL,YTIME) / i04AvailRate(PGALL,YTIME);
         
Q04NewCapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V04NewCapElec(allCy,PGALL,YTIME)
          =E=
      (
        (V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME))$( (not CCS(PGALL)) AND (not NOCCS(PGALL))) +
        (V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04ShareNewTechNoCCS(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME))$NOCCS(PGALL) +
        (V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04ShareNewTechNoCCS(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME))$CCS(PGALL) +
        i04DecInvPlantSched(allCy,PGALL,YTIME) * i04AvailRate(PGALL,YTIME)
      );
  
*' This equation calculates the variable representing the planned electricity generation capacity for a specific power plant  in a given country
*' and time period. The calculation involves adjusting the actual electricity generation capacity by a small constant and the square
*' root of the sum of the square of the capacity and a small constant. The purpose of this adjustment is likely to avoid numerical issues and ensure a positive value for
*' the planned capacity.
Q04CapElec2(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CapElec2(allCy,PGALL,YTIME)
             =E=
         ( VmCapElec(allCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VmCapElec(allCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*' Compute the variable cost of each power plant technology for every region,
*' by utilizing the maturity factor related to plant dispatching.
Q04CostVarTechElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04CostVarTechElec(allCy,PGALL,YTIME)
            =E=  
        i04MatureFacPlaDisp(allCy,PGALL,YTIME)*V04CostVarTech(allCy,PGALL,YTIME)**(-1);

*' Compute the electricity peak loads of each region,
*' as a sum of the variable costs of all power plant technologies.
Q04CostVarTechElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostVarTechElecTot(allCy,YTIME) 
         =E= 
         sum(PGALL, V04CostVarTechElec(allCy,PGALL,YTIME));     

*' Compute power plant sorting to decide the plant dispatching. 
*' This is accomplished by dividing the variable cost by the peak loads.
Q04SortPlantDispatch(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04SortPlantDispatch(allCy,PGALL,YTIME)
                 =E=
         V04CostVarTechElec(allCy,PGALL,YTIME)
         /
         V04CostVarTechElecTot(allCy,YTIME);  

*' This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
*' in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
*' from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
*' power plants on a yearly basis.
Q04NetNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
        V04NetNewCapElec(allCy,PGALL,YTIME) 
            =E=
        V04CapElec2(allCy,PGALL,YTIME)- V04CapElec2(allCy,PGALL,YTIME-1);                       

*' This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
*' in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
*' possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
*' as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
*' over these eight periods.
Q04CFAvgRen(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
    V04CFAvgRen(allCy,PGALL,YTIME)
        =E=
    (i04AvailRate(PGALL,YTIME)*V04NetNewCapElec(allCy,PGALL,YTIME)+
     i04AvailRate(PGALL,YTIME-1)*V04NetNewCapElec(allCy,PGALL,YTIME-1)+
     i04AvailRate(PGALL,YTIME-2)*V04NetNewCapElec(allCy,PGALL,YTIME-2)+
     i04AvailRate(PGALL,YTIME-3)*V04NetNewCapElec(allCy,PGALL,YTIME-3)+
     i04AvailRate(PGALL,YTIME-4)*V04NetNewCapElec(allCy,PGALL,YTIME-4)+
     i04AvailRate(PGALL,YTIME-5)*V04NetNewCapElec(allCy,PGALL,YTIME-5)+
     i04AvailRate(PGALL,YTIME-6)*V04NetNewCapElec(allCy,PGALL,YTIME-6)+
     i04AvailRate(PGALL,YTIME-7)*V04NetNewCapElec(allCy,PGALL,YTIME-7)
    ) /
    (V04NetNewCapElec(allCy,PGALL,YTIME) + V04NetNewCapElec(allCy,PGALL,YTIME-1)+
    V04NetNewCapElec(allCy,PGALL,YTIME-2) + V04NetNewCapElec(allCy,PGALL,YTIME-3)+
    V04NetNewCapElec(allCy,PGALL,YTIME-4) + V04NetNewCapElec(allCy,PGALL,YTIME-5)+
    V04NetNewCapElec(allCy,PGALL,YTIME-6) + V04NetNewCapElec(allCy,PGALL,YTIME-7)
    );

*' This equation calculates the variable representing the overall capacity for a specific power plant in a given country and time period .
*' The overall capacity is a composite measure that includes the existing capacity for non-renewable power plants and the expected capacity for renewable power plants based
*' on their average capacity factor.
Q04CapOverall(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapOverall(allCy,PGALL,YTIME)
          =E=
    V04CapElec2(allCy,pgall,ytime)$ (not PGREN(PGALL)) +
    V04CFAvgRen(allCy,PGALL,YTIME-1) *
    (
      V04NetNewCapElec(allCy,PGALL,YTIME) / i04AvailRate(PGALL,YTIME) +
      V04CapOverall(allCy,PGALL,YTIME-1) / V04CFAvgRen(allCy,PGALL,YTIME-1)
    )$PGREN(PGALL);

*' This equation calculates the scaling factor for plant dispatching in a specific country , hour of the day,
*' and time period . The scaling factor for determining the dispatch order of different power plants during a particular hour.
$ontext
q04ScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy))) ..
v04ScalFacPlantDispatchExpr(allCy,PGALL,HOUR,YTIME)
=E=
-V04ScalFacPlaDisp(allCy,HOUR,YTIME)/V04SortPlantDispatch(allCy,PGALL,YTIME);
$offtext


Q04ScalFacPlantDispatch(allCy,HOUR,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        sum(PGALL,
          (
            V04CapOverall(allCy,PGALL,YTIME) +
            !! Multiplying with a chp cf (0.85) to get effective capacity
            sum(CHP$CHPtoEON(CHP,PGALL), V04CapElecCHP(allCy,CHP,YTIME) * 0.85)
          ) *
          exp(-V04ScalFacPlaDisp(allCy,HOUR,YTIME) / V04SortPlantDispatch(allCy,PGALL,YTIME))
        )
                =E=
        (VmPeakLoad(allCy,YTIME) - VmBaseLoad(allCy,YTIME))
        * exp(-V04Lambda(allCy,YTIME)*(0.25 + ord(HOUR)-1))
        + VmBaseLoad(allCy,YTIME);

*' This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
*' The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
*' electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
*' share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
Q04ProdElecEstCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecEstCHP(allCy,YTIME) 
            =E=
        (
          (1/0.086 * 
          sum((INDDOM,CHP), VmConsFuel(allCy,INDDOM,CHP,YTIME)) * VmPriceElecInd(allCy,YTIME)) + 
          i04MxmShareChpElec(allCy,YTIME) * V04DemElecTot(allCy,YTIME) - 
          
          SQRT( SQR((1/0.086 * sum((INDDOM,CHP), VmConsFuel(allCy,INDDOM,CHP,YTIME)) * 
          VmPriceElecInd(allCy,YTIME)) - 
          i04MxmShareChpElec(allCy,YTIME)*V04DemElecTot(allCy,YTIME)) )  
        )/2 +
        SQR(1E-4);

*' This equation calculates the non-Combined Heat and Power electricity production in a specific country and time period .
*' It is essentially the difference between the total electricity demand and the estimated electricity generation from CHP plants .In summary,
*' the equation calculates the electricity production from technologies other than CHP by subtracting the estimated CHP electricity generation from the total electricity
*' demand. 
Q04ProdElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecNonCHP(allCy,YTIME) 
            =E=
        (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME));  

*' This equation calculates the total required electricity production for a specific country and time period .
*' The total required electricity production is the sum of electricity generation from different technologies, including CHP plants, across all hours of the day.
*' The total required electricity production is the sum of the electricity generation from all CHP plants across all hours, considering the scaling factor for plant
*' dispatching. 
Q04ProdElecReqCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecReqCHP(allCy,YTIME) 
                =E=
        sum(hour,
          sum(CHP, 
            V04CapElecCHP(allCy,CHP,YTIME) * 0.85 * 
            exp(-V04ScalFacPlaDisp(allCy,HOUR,YTIME) / sum(pgall$chptoeon(chp,pgall), V04SortPlantDispatch(allCy,PGALL,YTIME)))
          )
        );

*' This equation calculates the electricity production from power generation plants for a specific country ,
*' power generation plant type , and time period . The electricity production is determined based on the overall electricity
*' demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
*' from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
*' capacity and the scaling factor for dispatching.
Q04ProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmProdElec(allCy,PGALL,YTIME)
                =E=
        V04ProdElecNonCHP(allCy,YTIME) / (V04ProdElecReqTot(allCy,YTIME) - V04ProdElecReqCHP(allCy,YTIME)) *
        V04CapElec2(allCy,PGALL,YTIME) *
        sum(HOUR,
          exp(-V04ScalFacPlaDisp(allCy,HOUR,YTIME)/V04SortPlantDispatch(allCy,PGALL,YTIME))
        );

*' This equation calculates the sector contribution to total Combined Heat and Power production . The contribution
*' is calculated for a specific country , industrial sector , CHP technology , and time period .The sector contribution
*' is calculated by dividing the fuel consumption of the specific industrial sector for CHP by the total fuel consumption of CHP across all industrial
*' sectors. The result represents the proportion of CHP production attributable to the specified industrial sector. The denominator has a small constant
*' (1e-6) added to avoid division by zero.
$ontext
q04SecContrTotCHPProd(allCy,INDDOM,CHP,YTIME)$(TIME(YTIME) $SECTTECH(INDDOM,CHP) $runCy(allCy))..
         v04SecContrTotCHPProd(allCy,INDDOM,CHP,YTIME) 
          =E=
         VmConsFuel(allCy,INDDOM,CHP,YTIME)/(1e-6+SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,CHP,YTIME)));
$offtext

*' This equation calculates the electricity production from Combined Heat and Power plants . The electricity production is computed
*' for a specific country , CHP technology , and time period.The electricity production from CHP plants is computed by taking the
*' ratio of the fuel consumption by the specified industrial sector for CHP technology to the total fuel consumption for all industrial sectors and CHP
*' technologies. This ratio is then multiplied by the difference between total electricity demand and the sum of electricity production from all power
*' generation plants. The result represents the portion of electricity production from CHP plants attributed to the specified CHP technology.
Q04ProdElecCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecCHP(allCy,CHP,YTIME)
                 =E=
        sum(INDDOM,VmConsFuel(allCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VmConsFuel(allCy,INDDOM,CHP2,YTIME)))*
        (V04DemElecTot(allCy,YTIME) - SUM(PGALL,VmProdElec(allCy,PGALL,YTIME)));

*' This equation calculates the long-term power generation cost of technologies excluding climate policies.
*' The cost is computed for a specific country, power generation technology , energy sector, and time period.
*' The long-term power generation cost is computed as a combination of capital costs, operating and maintenance costs, and variable costs,
*' considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the availability
*' rate and conversion factors. The equation provides a comprehensive calculation of the long-term cost associated with power generation technologies,
*' excluding climate policy-related costs.
Q04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)
                 =E=
      (imDisc(allCy,"PG",YTIME)*EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) /
      (EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))-1)*i04GrossCapCosSubRen(allCy,PGALL,YTIME)*1000*imCGI(allCy,YTIME) +
      i04FixOandMCost(allCy,PGALL,YTIME)
      ) /i04AvailRate(PGALL,YTIME)
              / (1000*(6$ISET(ESET)+4$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+(VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+
                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));

*' This equation calculates the long-term minimum power generation cost for a specific country , power generation technology,
*' and time period. The minimum cost is computed considering various factors, including discount rates, technological lifetimes, gross capital costs,
*' fixed operating and maintenance costs, availability rates, variable costs, fuel prices, carbon capture rates, carbon capture and storage costs, carbon
*' emission factors, and plant efficiency.The long-term minimum power generation cost is calculated as a combination of capital costs, operating and maintenance
*' costs, and variable costs, considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the
*' availability rate and conversion factors. This equation provides insight into the minimum cost associated with power generation technologies, excluding climate
*' policy-related costs, and uses a consistent conversion factor for power capacity.
$ontext
q04CostPowGenLonMin(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         v04CostPowGenLonMin(allCy,PGALL,YTIME)
                 =E=

             (imDisc(allCy,"PG",YTIME)*EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) /
             (EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))-1)*i04GrossCapCosSubRen(allCy,PGALL,YTIME)*1000*imCGI(allCy,YTIME) +
             i04FixOandMCost(allCy,PGALL,YTIME))/i04AvailRate(PGALL,YTIME)
             / (1000*smGwToTwhPerYear(YTIME)) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+(VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+

                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))

                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));   
$offtext

*' This equation calculates the long-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable costs
*' associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the long-term power generation
*' cost per unit of electricity produced in the given time period. The equation also includes factors such as discount rates, plant availability rates, and the gross
*' capital cost per plant type with subsidies for renewables.
$ontext
q04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         v04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME)
                 =E=

             (imDisc(allCy,"PG",YTIME)*EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) /
             (EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))-1)*i04GrossCapCosSubRen(allCy,PGALL,YTIME)/1.5*1000*imCGI(allCy,YTIME) +
             i04FixOandMCost(allCy,PGALL,YTIME))/i04AvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), imPriceFuelsInt(WEF,YTIME))*smTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))

                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME))); 
$offtext

*' This equation calculates the short-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable
*' costs associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the short-term power
*' generation cost per unit of electricity produced in the given time period.
$ontext
q04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

         v04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)
                 =E=
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), imPriceFuelsInt(WEF,YTIME))*smTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))

                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));    
$offtext

*' This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
*' plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
*' electricity consumed in the given time period.
Q04CostPowGenAvgLng(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmCostPowGenAvgLng(allCy,ESET,YTIME)
              =E=
        (
          SUM(PGALL, VmProdElec(allCy,PGALL,YTIME) * V04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)) +
          sum(CHP, VmCostElcAvgProdCHP(allCy,CHP,YTIME) * V04ProdElecCHP(allCy,CHP,YTIME))
        ) / 
        V04DemElecTot(allCy,YTIME); 

*' The equation represents the long-term average power generation cost excluding climate policies.
*' It calculates the cost in Euro2005 per kilowatt-hour (kWh) for a specific combination of parameters. The equation is composed 
*' of various factors, including discount rates, technical lifetime of the plant type, gross capital cost with subsidies for renewables,
*' fixed operation and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, efficiency values, CO2 emission factors,
*' CO2 capture rates, and carbon prices. The equation incorporates a summation over different plant fuel types and considers the cost curve for CO2 sequestration.
*' The final result is the average power generation cost per unit of electricity produced, taking into account various economic and technical parameters.
Q04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)
                 =E=
             (imDisc(allCy,"PG",YTIME)*EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) /
             (EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))-1)*i04GrossCapCosSubRen(allCy,PGALL,YTIME)*1000*imCGI(allCy,YTIME) +
             i04FixOandMCost(allCy,PGALL,YTIME))/i04AvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+((VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)-imEffValueInDollars(allCy,"PG",ytime)/1000-imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))/1000 )/1.2441+

                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +

                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))

                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));

*' Compute long term power generation cost excluding climate policies by summing the Electricity production multiplied by Long-term average power generation cost excluding 
*' climate policies added to the sum of Average Electricity production cost per CHP plant multiplied by the CHP electricity production and all of the above divided by 
*' the Total electricity demand.
Q04CostPowGenLonNoClimPol(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostPowGenLonNoClimPol(allCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, (VmProdElec(allCy,PGALL,YTIME))*V04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)) +
         sum(CHP, VmCostElcAvgProdCHP(allCy,CHP,YTIME)*V04ProdElecCHP(allCy,CHP,YTIME))
         ) /
         (V04DemElecTot(allCy,YTIME));  

*' This equation establishes a common variable (with arguments) for the electricity consumption per demand subsector of INDUSTRY, [DOMESTIC/TERTIARY/RESIDENTIAL] and TRANSPORT.
*' The electricity consumption of the demand subsectors of INDUSTRY & [DOMESTIC/TERTIARY/RESIDENTIAL] is provided by the consumption of Electricity as a Fuel.
*' The electricity consumption of the demand subsectors of TRANSPORT is provided by the Demand of Transport for Electricity as a Fuel.
Q04ConsElec(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ConsElec(allCy,DSBS,YTIME)
            =E=
        sum(INDDOM $SAMEAS(INDDOM,DSBS), VmConsFuel(allCy,INDDOM,"ELC",YTIME)) + 
        sum(TRANSE $SAMEAS(TRANSE,DSBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME));

*' This equation computes the short-term average power generation cost. It involves summing the variable production costs for different power generation plants and
*' energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of electricity
*' consumed in the given time period.
$ontext
q04CostPowGenAvgShrt(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..

        v04CostPowGenAvgShrt(allCy,ESET,YTIME)
                 =E=
        (
        sum(PGALL,
        VmProdElec(allCy,PGALL,YTIME)*
        (
        sum(PGEF$PGALLtoEF(PGALL,PGEF),
        (i04VarCost(PGALL,YTIME)/1000+(VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441+
         imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
         (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
         (sum(NAP$NAPtoALLSBS(NAP,"PG"),imCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)))
        ))
        +
         sum(CHP, VmCostVarAvgElecProd(allCy,CHP,YTIME)*V04ProdElecCHP(allCy,CHP,YTIME))
         )
         /V04DemElecTot(allCy,YTIME);
$offtext
