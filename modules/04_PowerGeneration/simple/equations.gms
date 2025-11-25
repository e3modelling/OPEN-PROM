*' @title Equations of OPEN-PROMs Power Generation
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' Power Generation

*' This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
*' The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
*' electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
*' share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
Q04ProdElecEstCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ProdElecEstCHP(allCy,YTIME) 
        =E=
    1/smTWhToMtoe *
    (  
      V03OutTransfCHP(allCy,"STE",YTIME) * VmPriceElecInd(allCy,YTIME) + 
      i04MxmShareChpElec(allCy,YTIME) * V04DemElecTot(allCy,YTIME) - 

      SQRT(SQR(
        V03OutTransfCHP(allCy,"STE",YTIME) * VmPriceElecInd(allCy,YTIME) - 
        i04MxmShareChpElec(allCy,YTIME) * V04DemElecTot(allCy,YTIME))
      )  
    )/2 + SQR(1E-4);

*' This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
*' including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
*' generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
Q04CapElecCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecCHP(allCy,YTIME)
        =E=
    V04ProdElecEstCHP(allCy,YTIME) / (1e3 * smGwToTwhPerYear(YTIME));  

*' The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
*' distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
*' which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
*' to the total electricity demand.
Q04DemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04DemElecTot(allCy,YTIME)
        =E=
$ifthen.calib %Calibration% == off
    1 / smTWhToMtoe *
    ( 
      VmConsFinEneCountry(allCy,"ELC",YTIME) + 
      VmConsFinNonEne(allCy,"ELC",YTIME) + 
      VmLossesDistr(allCy,"ELC",YTIME) +
      VmConsFiEneSec(allCy,"ELC",YTIME) - 
      VmImpNetEneBrnch(allCy,"ELC",YTIME)
    );
$ELSEIF.calib %Calibration% == MatCalibration
    t04DemElecTot(allCy,YTIME);
$endif.calib

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
    V04DemElecTot(allCy,YTIME) /
    (V04LoadFacDom(allCy,YTIME) * smGwToTwhPerYear(YTIME));

*' The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
*' the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
*' generation capacity based on the changes in peak load.
Q04CapElecTotEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapElecTotEst(allCy,YTIME)
          =E=
    VmCapElecTotEst(allCy,YTIME-1) *
    VmPeakLoad(allCy,YTIME) / VmPeakLoad(allCy,YTIME-1);          

*' This equation calculates the CAPEX and the Fixed Costs of each power generation unit, taking into account its discount rate and life expectancy, 
*' for each region (country) and year.
Q04CapexFixCostPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapexFixCostPG(allCy,PGALL,YTIME)
        =E=         
    ( 
      imDisc(allCy,"PG",YTIME) * exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL))
      / (exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL)) -1)
    ) * i04GrossCapCosSubRen(allCy,PGALL,YTIME) * 1000 * imCGI(allCy,YTIME) +
    i04FixOandMCost(allCy,PGALL,YTIME);

*' This equation estimates a multiplying factor expressing the extra grid and storage costs for RES implementation according to the RES penetration in the mixture.
Q04CostCapTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostCapTech(allCy,PGALL,YTIME) 
        =E=
    V04CapexRESRate(allCy,PGALL,YTIME) * V04CapexFixCostPG(allCy,PGALL,YTIME) / 
    (i04AvailRate(allCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000);

*' Compute the variable cost of each power plant technology for every region,
*' By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
Q04CostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostVarTech(allCy,PGALL,YTIME) 
        =E=
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (imRenValue(YTIME) * 8.6e-5)$(not (PGREN2(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
      V04CO2CaptRate(allCy,PGALL,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-V04CO2CaptRate(allCy,PGALL,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), imCarVal(allCy,NAP,YTIME)))
      ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,YTIME)
    )$(not PGREN(PGALL));

*' The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
*' including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
*' The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
*' for renewable plants (excluding certain types) and fossil fuel plants.
Q04CostHourProdInvDec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CostHourProdInvDec(allCy,PGALL,YTIME)
        =E=         
    V04CostCapTech(allCy,PGALL,YTIME) +
    V04CostVarTech(allCy,PGALL,YTIME);

*' The equation computes the endogenous scrapping index for power generation plants  during the specified year .
*' The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
*' divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
*' parameter is applied to the sum of full costs and raised to the power of -2. The resulting index is used to determine the endogenous scrapping of power plants.
Q04IndxEndogScrap(allCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
    V04IndxEndogScrap(allCy,PGALL,YTIME)
        =E=
    V04CostVarTech(allCy,PGALL,YTIME)**(-2) /
    (
      V04CostVarTech(allCy,PGALL,YTIME)**(-2) +
      (
        i04ScaleEndogScrap *
        sum(PGALL2$(not sameas(PGALL,PGALL2)),
          !!i04AvailRate(allCy,PGALL2,YTIME) / i04AvailRate(allCy,PGALL,YTIME) * 
          V04CostHourProdInvDec(allCy,PGALL2,YTIME) 
          !!+
          !!(1-i04AvailRate(allCy,PGALL2,YTIME) / i04AvailRate(allCy,PGALL,YTIME)) *
          !!V04CostVarTech(allCy,PGALL2,YTIME)
        )
      )**(-2)
    );

*' The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
*' It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
*' total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
Q04CapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNonCHP(allCy,YTIME)
        =E=
    VmCapElecTotEst(allCy,YTIME) -
    V04CapElecCHP(allCy,YTIME);      

*' In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
*' decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
Q04GapGenCapPowerDiff(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04GapGenCapPowerDiff(allCy,YTIME)
        =E=
    (
      (
        V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
        sum(PGALL, 
          VmCapElec(allCy,PGALL,YTIME-1) * V04ScrpRate(allCy,PGALL,YTIME) -
          VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04CCSRetroFit(allCy,PGALL,YTIME)) +
          (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(allCy,PGALL,YTIME)
        ) 
      ) +
      SQRT(SQR(
      (
        V04CapElecNonCHP(allCy,YTIME) - V04CapElecNonCHP(allCy,YTIME-1) +
        sum(PGALL,
          VmCapElec(allCy,PGALL,YTIME-1) * V04ScrpRate(allCy,PGALL,YTIME) -
          VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04CCSRetroFit(allCy,PGALL,YTIME)) +
          (i04PlantDecomSched(allCy,PGALL,YTIME) - i04DecInvPlantSched(allCy,PGALL,YTIME)) * i04AvailRate(allCy,PGALL,YTIME)
        )
      ))
      ) 
    )/2 + 1e-6;

*' Calculates the share of all the unflexible RES penetration into the mixture, and specifically how much above a given threshold it is.
Q04ShareMixWndSol(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareMixWndSol(allCy,YTIME)
        =E=
    sum(PGALL$(PGRENSW(PGALL)), VmCapElec(allCy,PGALL,YTIME)) /
    sum(PGALL, VmCapElec(allCy,PGALL,YTIME));
 
*' The equation calculates a temporary variable which is used to facilitate scaling in the Weibull equation. The scaling is influenced by three main factors:
*' Maturity Factor for Planned Available Capacity : This factor represents the material-specific influence on the planned available capacity for a power
*' plant. It accounts for the capacity planning aspect of the power generation technology.
*' Renewable Technologies Maturity Multiplier: This multiplier reflects the maturity level of renewable technologies. It adjusts the scaling based on how
*' mature and established the renewable technology is, with a higher maturity leading to a larger multiplier.
*' Hourly Production Costs : The summation involves the hourly production costs of the technology raised to the power of -6. This suggests that higher
*' production costs contribute less to the overall scaling, emphasizing the importance of cost efficiency in the scaling process.
*' The result is a combined measure that takes into account material factors, technology maturity, and cost efficiency in the context of the Weibull
*' equation, providing a comprehensive basis for scaling considerations.

*' The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
*' and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
*' For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
*' overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
*' as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
*' without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V04SharePowPlaNewEq(allCy,PGALL,YTIME)
        =E=
    i04MatFacPlaAvailCap(allCy,PGALL,YTIME) *
    V04ShareSatPG(allCy,PGALL,YTIME-1) *
    V04CostHourProdInvDec(allCy,PGALL,YTIME-1) ** (-2) /
    SUM(PGALL2,
      i04MatFacPlaAvailCap(allCy,PGALL2,YTIME) *
      V04ShareSatPG(allCy,PGALL2,YTIME-1) *
      V04CostHourProdInvDec(allCy,PGALL2,YTIME-1) ** (-2)
    );

*' This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
*' and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
*' The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
Q04CapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapElec(allCy,PGALL,YTIME)
          =E=
    VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04ScrpRate(allCy,PGALL,YTIME)) +
    V04NewCapElec(allCy,PGALL,YTIME) -
    i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME);

*' This equation calculates the variable representing the nominal electricity generation capacity for a specific power plant in a given country
*' and time period. The nominal capacity is determined by dividing the actual electricity generation capacity by the availability rate of the power plant.
Q04CapElecNominal(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNominal(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL,YTIME);

*' This equation calculates the variable representing the new capacity added for a specific power plant in a given country and time period.
*' The calculation considers the share of the power plant in new equipment, the gap in generation capacity, decommissioning schedules, availability rates,
*' and endogenous scrapping. The equation aims to model the addition of new capacity based on investment decisions and technology-specific factors.
Q04NewCapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04NewCapElec(allCy,PGALL,YTIME)
        =E=
    V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME) +
    i04DecInvPlantSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME) +
    SUM(PGALL2$CCS_NOCCS(PGALL,PGALL2),
      (1 - V04CCSRetroFit(allCy,PGALL2,YTIME)) * VmCapElec(allCy,PGALL2,YTIME-1)
    );

*' This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
*' in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
*' from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
*' power plants on a yearly basis.
Q04NetNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
    V04NetNewCapElec(allCy,PGALL,YTIME) 
        =E=
    VmCapElec(allCy,PGALL,YTIME) - VmCapElec(allCy,PGALL,YTIME-1);                       

*' This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
*' in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
*' possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
*' as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
*' over these eight periods.
Q04CFAvgRen(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
    V04CFAvgRen(allCy,PGALL,YTIME)
        =E=
    (i04AvailRate(allCy,PGALL,YTIME)*V04NetNewCapElec(allCy,PGALL,YTIME)+
     i04AvailRate(allCy,PGALL,YTIME-1)*V04NetNewCapElec(allCy,PGALL,YTIME-1)+
     i04AvailRate(allCy,PGALL,YTIME-2)*V04NetNewCapElec(allCy,PGALL,YTIME-2)+
     i04AvailRate(allCy,PGALL,YTIME-3)*V04NetNewCapElec(allCy,PGALL,YTIME-3)+
     i04AvailRate(allCy,PGALL,YTIME-4)*V04NetNewCapElec(allCy,PGALL,YTIME-4)+
     i04AvailRate(allCy,PGALL,YTIME-5)*V04NetNewCapElec(allCy,PGALL,YTIME-5)+
     i04AvailRate(allCy,PGALL,YTIME-6)*V04NetNewCapElec(allCy,PGALL,YTIME-6)+
     i04AvailRate(allCy,PGALL,YTIME-7)*V04NetNewCapElec(allCy,PGALL,YTIME-7)
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
    VmCapElec(allCy,pgall,ytime)$(not PGREN(PGALL)) +
    V04CFAvgRen(allCy,PGALL,YTIME-1) *
    (
      V04NetNewCapElec(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL,YTIME) +
      V04CapOverall(allCy,PGALL,YTIME-1) / V04CFAvgRen(allCy,PGALL,YTIME-1)
    )$PGREN(PGALL);

*' This equation calculates the electricity production from power generation plants for a specific country ,
*' power generation plant type , and time period . The electricity production is determined based on the overall electricity
*' demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
*' from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
*' capacity and the scaling factor for dispatching.
Q04ProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdElec(allCy,PGALL,YTIME)
        =E=
    (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME)) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME)) *
    VmCapElec(allCy,PGALL,YTIME);

*' Share of all technologies in the electricity mixture.
Q04ShareTechPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareTechPG(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME));

*'Sigmoid function used as a saturation mechanism for electricity mixture penetration of RES technologies.
Q04ShareSatPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy))$(PGREN(PGALL)))..
    V04ShareSatPG(allCy,PGALL,YTIME)
        =E=
    2 / (1+exp(9*V04ShareTechPG(allCy,PGALL,YTIME)));

*' This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
*' plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
*' electricity consumed in the given time period.
Q04CostPowGenAvgLng(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostPowGenAvgLng(allCy,YTIME)
        =E=
    (
      SUM(PGALL, VmProdElec(allCy,PGALL,YTIME) * V04CostHourProdInvDec(allCy,PGALL,YTIME))
* 0* VmCostElcAvgProdCHP(allCy,"TSTE",YTIME) * V04ProdElecEstCHP(allCy,YTIME)
    ) / 
    (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME)); 

*' This equation estimates the factor increasing the CAPEX of new RES (unflexible) capacity installation due to simultaneous need for grind upgrade and storage, 
*' for each region (country) and year. This factor depends on the existing RES (unflexible) penetration in the electriciy mixture.
Q04CapexRESRate(allCy,PGALL,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V04CapexRESRate(allCy,PGALL,YTIME)
        =E=
    1 + (V04ShareMixWndSol(allCy,YTIME-1)$PGRENSW(PGALL)) ** S04CapexBessRate;

Q04CO2CaptRate(allCy,PGALL,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V04CO2CaptRate(allCy,PGALL,YTIME)
        =E=
    imCO2CaptRate(PGALL) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    );

Q04CCSRetroFit(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy))$(NOCCS(PGALL)))..
    V04CCSRetroFit(allCy,PGALL,YTIME)
        =E=
    V04CostVarTech(allCy,PGALL,YTIME) ** (-2) /
    (
      V04CostVarTech(allCy,PGALL,YTIME) ** (-2) +
      0.01 *
      SUM(PGALL2$CCS_NOCCS(PGALL2,PGALL),
        (
          V04CostCapTech(allCy,PGALL2,YTIME) -
          i04AvailRate(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL2,YTIME) *
          V04CostCapTech(allCy,PGALL,YTIME) +
          V04CostVarTech(allCy,PGALL2,YTIME)
        ) ** (-2)
      )
    );

Q04ScrpRate(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ScrpRate(allCy,PGALL,YTIME)
        =E=
    1 - (1 - 1 / i04TechLftPlaType(allCy,PGALL)) * 
    V04IndxEndogScrap(allCy,PGALL,YTIME) *
    V04CCSRetroFit(allCy,PGALL,YTIME);

Q04ConsFuelElecProd(allCy,PGEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFuelElecProd(allCy,PGEF,YTIME)
        =E=
    SUM(PGALL$PGALLTOEF(PGALL,PGEF),
      VmProdElec(allCy,PGALL,YTIME) * smTWhToMtoe / 
      imPlantEffByType(allCy,PGALL,YTIME)
    );

$ontext
*' The equation computes the electricity production cost per Combined Heat and Power plant for a specific demand sector within a given subsector.
*' The cost is determined based on various factors, including the discount rate, technical lifetime of CHP plants, capital cost (EUR/kW), fixed O&M cost (EUR/kW), availability rate,
*' variable cost(EUR/MWh), and fuel-related costs. The equation provides a comprehensive assessment of the overall expenses associated with electricity production from CHP
*' plants, considering both the fixed and variable components, as well as factors such as carbon prices and CO2 emission factors.
*' The resulting variable represents the electricity production cost per CHP plant and demand sector, expressed in Euro per kilowatt-hour (Euro/KWh).
Q09CostElecProdCHP(allCy,DSBS,TCHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
    V09CostElecProdCHP(allCy,DSBS,TCHP,YTIME)
        =E=
    ( 
      imDisc(allCy,"PG",YTIME) * 
      exp(imDisc(allCy,"PG",YTIME) * i02LifChpPla(allCy,DSBS,TCHP)) /
      (exp(imDisc(allCy,"PG",YTIME) * i02LifChpPla(allCy,DSBS,TCHP)) -1) *
      i02InvCostChp(allCy,DSBS,TCHP,YTIME) * imCGI(allCy,YTIME) + 
      i02FixOMCostPerChp(allCy,DSBS,TCHP,YTIME)
    ) /
    (i02AvailRateChp(allCy,DSBS,TCHP) * (smGwToTwhPerYear(YTIME)) * 1000) +
    i02VarCostChp(allCy,DSBS,TCHP,YTIME) / 1000


!! FIXME
    sum(PGEF$CHPtoEF(TCHP,PGEF),
      (
        VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
        1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME) *
        sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))
      ) * smTWhToMtoe /
      (i02BoiEffChp(allCy,CHP,YTIME) * (VmPriceElecInd(allCy,CHP,YTIME)) + 1e-4)
    )  

;
*' The equation calculates the average electricity production cost per Combined Heat and Power plant .
*' It involves a summation over demand subsectors . The average electricity production cost is determined by considering the electricity
*' production cost per CHP plant for each demand subsector. The result is expressed in Euro per kilowatt-hour (Euro/KWh).
Q09CostElcAvgProdCHP(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostElcAvgProdCHP(allCy,TCHP,YTIME)
      =E=
    (
      sum(INDDOM, 
        VmConsFuel(allCy,INDDOM,"STE",YTIME-1) /
        SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,"STE",YTIME-1)) *
        V02CostElecProdCHP(allCy,INDDOM,TCHP,YTIME)
      )
    )$SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,"STE",YTIME-1))+0$(NOT SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,"STE",YTIME-1)));
$offtext