PowerGeneration module (04_PowerGeneration) {#id-04_PowerGeneration}
===========================================

Description
-----------

This is the PowerGeneration module.


Interfaces
----------

**Interface plot missing!**

### Input


------------------------------------------------------------------------------------
          &nbsp;                     Description                  Unit        A   B 
-------------------------- -------------------------------- ---------------- --- ---
       VmCarVal \               Carbon prices for all         $US\$2015/tn    x   x 
       (allCy, NAP,                   countries                   CO2$              
          YTIME)                                                                    

      VmConsFiEneSec         Final consumption in energy         $Mtoe$       x   x 
            \                           sector                                      
       (allCy, EFS,                                                                 
          YTIME)                                                                    

   VmConsFinEneCountry            Total final energy             $Mtoe$       x   x 
            \                        consumnption                                   
       (allCy, EF,                                                                  
          YTIME)                                                                    

     VmConsFinNonEne         Final non energy consumption        $Mtoe$       x   x 
            \                                                                       
       (allCy, EFS,                                                                 
          YTIME)                                                                    

      VmConsFuel \           Consumption of fuels in each        $Mtoe$       x   x 
      (allCy, DSBS,          demand subsector, excluding                            
        EF, YTIME)               heat from heatpumps                                

   VmCostElcAvgProdCHP      Average Electricity production   $US\$2015/KWh$   x     
            \                     cost per CHP plant                                
       (allCy, CHP,                                                                 
          YTIME)                                                                    

     VmCstCO2SeqCsts              Cost curve for CO2          $US\$2015/tn    x   x 
            \                    sequestration costs               of               
      (allCy, YTIME)                                              CO2               
                                                             sequestrated$          

 VmDemFinEneTranspPerFuel       Final energy demand in           $Mtoe$       x   x 
            \               transport subsectors per fuel                           
     (allCy, TRANSE,                                                                
        EF, YTIME)                                                                  

     VmImpNetEneBrnch                Net Imports                 $Mtoe$       x   x 
            \                                                                       
       (allCy, EFS,                                                                 
          YTIME)                                                                    

     VmLossesDistr \             Distribution losses             $Mtoe$       x   x 
       (allCy, EFS,                                                                 
          YTIME)                                                                    

      VmPriceElecInd        Electricity index - a function        $1$         x   x 
            \                     of industry price                                 
      (allCy, YTIME)                                                                

 VmPriceFuelSubsecCarVal    Fuel prices per subsector and    $k\$2015/toe$    x   x 
            \                            fuel                                       
       (allCy, SBS,                                                                 
        EF, YTIME)                                                                  

      VmRenValue \                 Renewable value           $US\$2015/KWh$   x   x 
         (YTIME)                                                                    
------------------------------------------------------------------------------------

Table: module inputs (A: legacy | B: simple)



### Output


---------------------------------------------------------------------
       &nbsp;                  Description                 Unit      
-------------------- ------------------------------- ----------------
    VmCapElec \       Electricity generation plants        $GW$      
   (allCy, PGALL,               capacity                             
       YTIME)                                                        

  VmCapElecTotEst      Estimated Total electricity         $GW$      
         \                 generation capacity                       
   (allCy, YTIME)                                                    

 VmConsFuelElecProd                                                  
         \                                                           
    (allCy, EFS,                                                     
       YTIME)                                                        

 VmCostPowGenAvgLng      Long-term average power      $US\$2015/kWh$ 
         \                   generation cost                         
   (allCy, ESET,                                                     
       YTIME)                                                        

   VmPeakLoad \           Electricity peak load            $GW$      
   (allCy, YTIME)                                                    

   VmProdElec \          Electricity production           $TWh$      
   (allCy, PGALL,                                                    
       YTIME)                                                        
---------------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the PowerGeneration module.


```
Equations
```
*** Power Generation
```
Q04CapElec2(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
Q04CapElecNominal(allCy,PGALL,YTIME)	                   "Compute nominal electricity generation capacity"
Q04RenTechMatMultExpr(allCy,PGALL,YTIME)                   "Renewable power capacity over potential (1)"
Q04CapElecCHP(allCy,YTIME)                             "Compute CHP electric capacity"	
Q04Lambda(allCy,YTIME)	                                   "Compute Lambda parameter"
Q04BsldEst(allCy,YTIME)	                                   "Compute estimated base load"
Q04BaseLoadMax(allCy,YTIME) 	                           "Compute baseload corresponding to maximum load"	
Q04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)              "Compute hourly production cost used in investment decisions"
Q04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)         "Compute hourly production cost used in investment decisions"
Q04SensCCS(allCy,YTIME)	                                   "Compute gamma parameter used in CCS/No CCS decision tree"
Q04CostProdSpecTech(allCy,PGALL,YTIME)	                   "Compute production cost used in investment decisions"
Q04ShareNewTechCCS(allCy,PGALL,YTIME)	                   "Compute SHRCAP"
Q04ShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Compute SHRCAP excluding CCs"
Q04CostVarTech(allCy,PGALL,YTIME)	                       "Compute variable cost of technology" 	
Q04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)                 "Compute variable cost of technology excluding PGSCRN"	
Q04CostProdTeCHPreReplac(allCy,PGALL,YTIME)	               "Compute production cost of technology  used in premature replacement"	
Q04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Compute production cost of technology  used in premature replacement including plant availability rate"	
Q04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Compute endogenous scrapping index" 	
Q04CapElecNonCHP(allCy,YTIME)	                           "Compute total electricity generation capacity excluding CHP plants"
Q04GapGenCapPowerDiff(allCy,YTIME)	                       "Compute the gap in power generation capacity"		
Q04RenTechMatMult(allCy,PGALL,YTIME)	                   "Compute renewable technologies maturity multiplier"		 	
Q04ScalWeibullSum(allCy,PGALL,YTIME)	                   "Compute sum (over hours) of temporary variable facilitating the scaling in Weibull equation"
Q04NewInvElec(allCy,YTIME)	                               "Compute for Power Plant new investment decision"		
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Compute the power plant share in new equipment"	
Q04CostVarTechElec(allCy,PGALL,YTIME)	                   "Compute variable cost of technology" 
Q04CostVarTechElecTot(allCy,YTIME)	                       "Compute Electricity peak loads"	
Q04SortPlantDispatch(allCy,PGALL,YTIME)	                   "Compute Power plants sorting according to variable cost to decide the plant dispatching" 	
Q04NewCapElec(allCy,PGALL,YTIME)	                       "Compute the new capacity added every year"
Q04NetNewCapElec(allCy,PGALL,YTIME)	                       "Compute the yearly difference in installed capacity"		
Q04CFAvgRen(allCy,PGALL,YTIME)	                           "Compute the average capacity factor of RES"	
Q04CapOverall(allCy,PGALL,YTIME)	                       "Compute overall capacity"
Q04ScalFacPlantDispatch(allCy,HOUR,YTIME)                  "Compute the scaling factor for plant dispatching"
Q04ProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants"	
Q04ProdElecNonCHP(allCy,YTIME)	                           "Compute non CHP electricity production" 	
Q04ProdElecReqCHP(allCy,YTIME)	                           "Compute total estimated CHP electricity production" 	
Q04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	       "Compute long term power generation cost of technologies excluding climate policies"	
Q04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	   "Compute long term average power generation cost excluding climate policies"		
Q04CostPowGenLonNoClimPol(allCy,ESET,YTIME)                "Compute long term power generation cost excluding climate policies"	
Q04ConsElec(allCy,DSBS,YTIME)                              "Compute electricity consumption per final demand sector"
Q04LoadFacDom(allCy,YTIME)                                 "Compute electricity load factor for entire domestic system"	
Q04DemElecTot(allCy,YTIME)                                 "Compute total electricity demand (TWh)"
Q04ProdElecReqTot(allCy,YTIME)                             "Compute total required electricity production (TWh)"
Q04ProdElecCHP(allCy,YTIME)                            "Compute CHP electricity production (TWh)"
```
**Interdependent Equations**
```
Q04ProdElec(allCy,PGALL,YTIME)                             "Compute electricity production from power generation plants"
Q04CostPowGenAvgLng(allCy,ESET,YTIME)	                   "Compute long term power generation cost"
Q04CapElecTotEst(allCy,YTIME)                              "Compute Estimated total electricity generation capacity"
Q04PeakLoad(allCy,YTIME)	                               "Compute elerctricity peak load"	
Q04CapElec(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
Q04BaseLoad(allCy,YTIME)	                               "Compute electricity base load"
;
Variables
```
*** Power Generation Variables
```
V04CapElec2(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
V04CapElecNominal(allCy,PGALL,YTIME)	                   "Nominal electricity generation plants capacity (GW)"
V04RenTechMatMultExpr(allCy,PGALL,YTIME)                   "Renewable power capacity over potential (1)"
V04CapElecCHP(allCy,YTIME)	                           "Capacity of CHP Plants (GW)"
V04Lambda(allCy,YTIME)	                                   "Parameter for load curve construction (1)"
V04BsldEst(allCy,YTIME)	                                   "Estimated base load (GW)"
V04BaseLoadMax(allCy,YTIME)	                               "Baseload corresponding to Maximum Load Factor (1)"
V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)              "Hourly production cost of technology (US$2015/KWh)"
V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)         "Hourly production cost of technology (US$2015/KWh)"	
V04SensCCS(allCy,YTIME)	                                   "Variable that controlls the sensitivity of CCS acceptance (1)"			
V04CostProdSpecTech(allCy,PGALL,YTIME)	                   "Production cost of technology (US$2015/KWh)"
V04ShareNewTechCCS(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"		
V04ShareNewTechNoCCS(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"
V04CostVarTech(allCy,PGALL,YTIME)	                       "Variable cost of technology (US$2015/KWh)"	
V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)                 "Variable cost of technology excluding PGSCRN (US$2015/KWh)"
V04CostProdTeCHPreReplac(allCy,PGALL,YTIME)                "Production cost of technology used in premature replacement (US$2015/KWh)"
V04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)	   "Production cost of technology used in premature replacement including plant availability rate (US$2015/KWh)"			
V04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Index used for endogenous power plants scrapping (1)"			
V04CapElecNonCHP(allCy,YTIME)	                           "Total electricity generation capacity excluding CHP (GW)"	
V04GapGenCapPowerDiff(allCy,YTIME)	                       "Gap in total generation capacity to be filled by new equipment (GW)"		
V04RenTechMatMult(allCy,PGALL,YTIME)	                   "Renewable technologies maturity multiplier (1)"	
V04ScalWeibullSum(allCy,PGALL,YTIME)	                   "Sum (over hours) of temporary variable facilitating the scaling in Weibull equation (1)"
V04NewInvElec(allCy,YTIME)	                               "Power plant sorting for new investment decision according to total cost (1)"	
V04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"			
V04CostVarTechElec(allCy,PGALL,YTIME)	                   "Variable cost of technology (US$2015/KWh)"	
V04CostVarTechElecTot(allCy,YTIME)	                       "Electricity peak loads (GW)"	
V04SortPlantDispatch(allCy,PGALL,YTIME)	                   "Power plants sorting according to variable cost to decide the plant dispatching (1)"
V04NewCapElec(allCy,PGALL,YTIME)	                       "The new capacity added every year (MW)"	
V04NetNewCapElec(allCy,PGALL,YTIME)	                       "Yearly difference in installed capacity (MW)"	
V04CFAvgRen(allCy,PGALL,YTIME)	                           "The average capacity factor of RES (1)"
V04CapOverall(allCy,PGALL,YTIME)	                       "Overall Capacity (MW)"	
V04ScalFacPlaDisp(allCy,HOUR,YTIME)	                       "Scaling factor for plant dispatching	(1)"
V04ProdElecEstCHP(allCy,YTIME)	                           "Estimate the electricity of CHP Plants (1)"	
V04ProdElecNonCHP(allCy,YTIME)	                           "Non CHP total electricity production (TWh)"				
V04ProdElecReqCHP(allCy,YTIME)	                           "Total estimated CHP electricity production (TWh)"	
V04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)	       "Long-term average power generation cost (US$2015/kWh)"
V04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)	   "Long-term average power generation cost excluding climate policies(US$2015/kWh)" 	
V04CostPowGenLonNoClimPol(allCy,ESET,YTIME)                "Long-term average power generation cost  excluding climate policies (US$2015/kWh)"	
V04ConsElec(allCy,DSBS,YTIME)                              "Electricity demand per final sector (Mtoe)"
V04LoadFacDom(allCy,YTIME)                                 "Electricity load factor for entire domestic system"	
V04ProdElecCHP(allCy,YTIME)	                           "CHP electricity production (TWh)"
V04ProdElecReqTot(allCy,YTIME)	                           "Total required electricity production (TWh)"
V04DemElecTot(allCy,YTIME)                                 "Total electricity demand (TWh)"
```
**Interdependent Variables**	
```
VmProdElec(allCy,PGALL,YTIME)                              "Electricity production (TWh)"	
VmCostPowGenAvgLng(allCy,ESET,YTIME)	                   "Long-term average power generation cost (US$2015/kWh)"
VmCapElecTotEst(allCy,YTIME)	                           "Estimated Total electricity generation capacity (GW)"
VmPeakLoad(allCy,YTIME)	                                   "Electricity peak load (GW)"	
VmCapElec(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
VmBaseLoad(allCy,YTIME)	                                   "Corrected base load (GW)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
Power Generation
This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
```
Q04CapElecCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CapElecCHP(allCy,YTIME)
         =E=
         sum(INDDOM,VmConsFuel(allCy,INDDOM,"STE",YTIME)) * 1/smTWhToMtoe *
         VmPriceElecInd(allCy,YTIME) / 
         !!i04UtilRateChpPlants(allCy,TCHP,YTIME) /
         smGwToTwhPerYear(YTIME);  
Q04Lambda(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (1 - exp( -V04Lambda(allCy,YTIME)*smGwToTwhPerYear(YTIME)))  / (0.0001+V04Lambda(allCy,YTIME))
             =E=
         (V04DemElecTot(allCy,YTIME) - smGwToTwhPerYear*VmBaseLoad(allCy,YTIME))
         / (VmPeakLoad(allCy,YTIME) - VmBaseLoad(allCy,YTIME));
```
The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
to the total electricity demand.
```
Q04DemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04DemElecTot(allCy,YTIME)
             =E=
         1/smTWhToMtoe *
         ( VmConsFinEneCountry(allCy,"ELC",YTIME) + VmConsFinNonEne(allCy,"ELC",YTIME) + VmLossesDistr(allCy,"ELC",YTIME)
           + VmConsFiEneSec(allCy,"ELC",YTIME) - VmImpNetEneBrnch(allCy,"ELC",YTIME)
         );
```
This equation computes the estimated base load as a quantity dependent on the electricity demand per final sector,
as well as the baseload share of demand per sector, the rate of losses for final Consumption, the net imports,
distribution losses and final consumption in energy sector.
```
Q04BsldEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04BsldEst(allCy,YTIME)
             =E=
         (
             sum(DSBS, i04BaseLoadShareDem(allCy,DSBS,YTIME)*V04ConsElec(allCy,DSBS,YTIME))*(1+imRateLossesFinCons(allCy,"ELC",YTIME))*
             (1 - VmImpNetEneBrnch(allCy,"ELC",YTIME)/(sum(DSBS, V04ConsElec(allCy,DSBS,YTIME))+VmLossesDistr(allCy,"ELC",YTIME)))
             + 0.5*VmConsFiEneSec(allCy,"ELC",YTIME)
         ) / smTWhToMtoe / smGwToTwhPerYear;
```
This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
of electricity demand per sector
```
Q04LoadFacDom(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04LoadFacDom(allCy,YTIME)
             =E=
         (sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME))) /
         (
          sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + 
          sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)/i04LoadFacElecDem(TRANSE))
        );         
```
The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result
to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period, taking into account the domestic
load factor.
```
Q04PeakLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmPeakLoad(allCy,YTIME)
             =E=
         V04DemElecTot(allCy,YTIME)/(V04LoadFacDom(allCy,YTIME)*smGwToTwhPerYear(YTIME));
```
This equation calculates the baseload corresponding to maximum load by multiplying the maximum load factor of electricity demand
to the electricity peak load, minus the baseload corresponding to maximum load factor.
```
Q04BaseLoadMax(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         (V04DemElecTot(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)*smGwToTwhPerYear(YTIME))
             =E=
         i04MxmLoadFacElecDem(allCy,YTIME)*(VmPeakLoad(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME))*smGwToTwhPerYear(YTIME);  
```
This equation calculates the electricity base load utilizing exponential functions that include the estimated base load,
the baseload corresponding to maximum load factor, and the parameter of baseload correction.
```
Q04BaseLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmBaseLoad(allCy,YTIME)
             =E=
         (1/(1+exp(i04BslCorrection(allCy,YTIME)*(V04BsldEst(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)))))*V04BsldEst(allCy,YTIME)
        +(1-1/(1+exp(i04BslCorrection(allCy,YTIME)*(V04BsldEst(allCy,YTIME)-V04BaseLoadMax(allCy,YTIME)))))*V04BaseLoadMax(allCy,YTIME);
Q04ProdElecReqTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04ProdElecReqTot(allCy,YTIME)
             =E=
         sum(HOUR, (VmPeakLoad(allCy,YTIME)-VmBaseLoad(allCy,YTIME))
                   * exp(-V04Lambda(allCy,YTIME)*(0.25+(ord(HOUR)-1)))
             ) + 9*VmBaseLoad(allCy,YTIME);   
```
The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
generation capacity based on the changes in peak load.
```
Q04CapElecTotEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmCapElecTotEst(allCy,YTIME)
             =E=
        VmCapElecTotEst(allCy,YTIME-1) * VmPeakLoad(allCy,YTIME)/VmPeakLoad(allCy,YTIME-1);          
```
The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
for renewable plants (excluding certain types) and fossil fuel plants.
```
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
        (VmRenValue(YTIME-1)*8.6e-5)$(not (PGREN(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
        sum(PGEF$PGALLtoEF(PGALL,PGEF), 
          (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME-1) +
          imCO2CaptRate(allCy,PGALL,YTIME-1) * VmCstCO2SeqCsts(allCy,YTIME-1) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME-1) +
          (1-imCO2CaptRate(allCy,PGALL,YTIME-1)) * 1e-3 * imCo2EmiFac(allCy,"PG",PGEF,YTIME-1) *
          (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME-1)))
          ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,YTIME-1)
        )$(not PGREN(PGALL));
```
The equation calculates the hourly production cost for
a given technology without carbon capture and storage investments. 
The result is expressed in Euro per kilowatt-hour (Euro/KWh).
The equation is based on the power plant's share in new equipment and
the hourly production cost of technology without CCS . Additionally, 
it considers the contribution of other technologies with CCS by summing their
shares in new equipment multiplied by their respective hourly production
costs. The equation reflects the cost dynamics associated with technology investments and provides
insights into the hourly production cost for power generation without CCS.
```
Q04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy)) ..
         V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME) =E=
         V04ShareNewTechNoCCS(allCy,PGALL,YTIME)*V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS(allCy,CCS,YTIME)*V04CostHourProdInvDec(allCy,CCS,HOUR,YTIME)); 
```
The equation reflects a dynamic relationship where the sensitivity
to CCS acceptance is influenced by the carbon prices of different countries.
The result provides a measure of the sensitivity of CCS acceptance
based on the carbon values in the previous year.
```
Q04SensCCS(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04SensCCS(allCy,YTIME) =E= 10+EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME-1)))));
```
The equation computes the hourly production cost used in investment decisions, taking into account the acceptance of Carbon Capture and Storage .
The production cost is modified based on the sensitivity of CCS acceptance. The sensitivity is used as an exponent
to adjust the original production cost for power generation plants during each hour and for the specified year .
This adjustment reflects the impact of CCS acceptance on the production cost.
```
$ontext
q04CostHourProdInvCCS(allCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         v04CostHourProdInvCCS(allCy,PGALL,HOUR,YTIME) 
         =E=
          V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-V04SensCCS(allCy,YTIME));
$offtext
```
The equation calculates the production cost of a technology for a specific power plant and year. 
The equation involves the hourly production cost of the technology
and a sensitivity variable controlling carbon capture and storage acceptance.
The summation over hours is weighted by the inverse of the technology's hourly production cost raised to the 
power of minus one-fourth of the sensitivity variable. 
```
Q04CostProdSpecTech(allCy,PGALL,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) $runCy(allCy)) ..
         V04CostProdSpecTech(allCy,PGALL,YTIME) 
         =E=  
         sum(HOUR,V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)**(-V04SensCCS(allCy,YTIME))) ;
```
The equation calculates the power plant's share in new equipment 
for a specific power plant and year when carbon capture and storage is implemented. The
share is determined based on a formulation that considers the production costs of the technology.
The numerator of the share calculation involves a factor of 1.1 multiplied
by the production cost of the technology for the specific power plant and year. The denominator
includes the sum of the numerator and the production costs of other power plant types without CCS.
```
Q04ShareNewTechCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $CCS(PGALL) $runCy(allCy))..
         V04ShareNewTechCCS(allCy,PGALL,YTIME) =E=
         1.1 *V04CostProdSpecTech(allCy,PGALL,YTIME)
         /(1.1*V04CostProdSpecTech(allCy,PGALL,YTIME)
           + sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),V04CostProdSpecTech(allCy,PGALL2,YTIME))
           );         
```
The equation calculates the power plant's share in new equipment 
for a specific power plant and year when carbon capture and storage is not implemented .
The equation is based on the complementarity relationship, expressing that the power plant's share in
new equipment without CCS is equal to one minus the sum of the shares of power plants with CCS in the
new equipment. The sum is taken over all power plants with CCS for the given power plant type and year .
```
Q04ShareNewTechNoCCS(allCy,PGALL,YTIME)$(TIME(YTIME) $NOCCS(PGALL) $runCy(allCy))..
         V04ShareNewTechNoCCS(allCy,PGALL,YTIME) 
         =E= 
         1 - sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS(allCy,CCS,YTIME));
```
Compute the variable cost of each power plant technology for every region,
By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
```
Q04CostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
        V04CostVarTech(allCy,PGALL,YTIME) 
             =E=
        i04VarCost(PGALL,YTIME)/1E3 + 
        sum(
          PGEF$PGALLtoEF(PGALL,PGEF),
          (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)/1.2441 +
          imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
          (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)
          *(sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
          *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)
        )$(not PGREN(PGALL));
```
The equation calculates the variable for a specific
power plant and year when the power plant is not subject to endogenous scrapping. The calculation involves raising the variable
cost of the technology for the specified power plant and year to the power of -5.
```
Q04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)$(time(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME) 
              =E=
          V04CostVarTech(allCy,PGALL,YTIME)**(-5);
```
The equation calculates the production cost of a technology 
for a specific power plant and year. The equation involves various factors, including discount rates, technical
lifetime of the plant type, gross capital cost with subsidies for renewables, capital goods index, fixed operation 
and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, CO2 capture rates, cost
curve for CO2 sequestration costs, CO2 emission factors, carbon values, plant efficiency, and specific conditions excluding
renewable power plants . The equation reflects the complex dynamics of calculating the production cost, considering both economic and technical parameters.
```
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
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME))$(not PGREN(PGALL)))
                         );
```
The equation calculates the production cost of a technology used in premature replacement,
considering plant availability rates. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
The equation involves the production cost of the technology used in premature replacement without considering availability rates 
and incorporates adjustments based on the availability rates of two power plants .
```
Q04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME) =E=
         i04AvailRate(PGALL,YTIME)/i04AvailRate(PGALL2,YTIME)*V04CostProdTeCHPreReplac(allCy,PGALL,YTIME)+
         V04CostVarTech(allCy,PGALL,YTIME)*(1-i04AvailRate(PGALL,YTIME)/i04AvailRate(PGALL2,YTIME));  
```
The equation computes the endogenous scrapping index for power generation plants  during the specified year .
The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
parameter is applied to the sum of full costs and raised to the power of -5. The resulting index is used to determine the endogenous scrapping of power plants.
```
Q04IndxEndogScrap(allCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)) $runCy(allCy))..
         V04IndxEndogScrap(allCy,PGALL,YTIME)
                 =E=
         V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)/
         (V04CostVarTechNotPGSCRN(allCy,PGALL,YTIME)+(i04ScaleEndogScrap(PGALL)*
         sum(PGALL2,V04CostProdTeCHPreReplacAvail(allCy,PGALL,PGALL2,YTIME)))**(-5));
```
The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
```
Q04CapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V04CapElecNonCHP(allCy,YTIME)
          =E=
      VmCapElecTotEst(allCy,YTIME) - 0*V04CapElecCHP(allCy,YTIME) * 0.85;      
```
In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
```
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
```
The equation  calculates a temporary variable 
that facilitates the scaling in the Weibull equation. The equation involves
the hourly production costs of technology for power plants
with carbon capture and storage and without CCS . The production 
costs are raised to the power of -6, and the result is used as a scaling factor
in the Weibull equation. The equation captures the cost-related considerations 
in determining the scaling factor for the Weibull equation based on the production costs of different technologies.
```
$ontext
q04ScalWeibull(allCy,PGALL,HOUR,YTIME)$((not CCS(PGALL))$TIME(YTIME) $runCy(allCy))..
          v04ScalWeibull(allCy,PGALL,HOUR,YTIME) 
         =E=
         (V04CostHourProdInvDec(allCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
         +
          V04CostHourProdInvDecNoCCS(allCy,PGALL,HOUR,YTIME)$NOCCS(PGALL))**(-6);     
$offtext
```
The equation calculates the minimum allowed renewable potential for a specific renewable energy form and country 
in the given year . Including:
The renewable potential supply curve for the specified renewable energy form, country, and year, as calculated in a previous equation.
The minimum renewable potential for the specified renewable energy form and country in the given year.
The minimum allowed renewable potential is computed as the average between the calculated renewable potential supply curve and the minimum renewable potential.
This formulation ensures that the potential does not fall below the minimum allowed value.
```
$ontext
q04PotRenMinAllow(allCy,PGRENEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..  
         v04PotRenMinAllow(allCy,PGRENEF,YTIME) =E=
         ( V04PotRenSuppCurve(allCy,PGRENEF,YTIME) + iMinRenPotential(allCy,PGRENEF,YTIME))/2;
$offtext
```
The equation calculates a maturity multiplier for renewable technologies. If the technology is renewable , the multiplier is determined
based on an exponential function that involves the ratio of the planned electricity generation capacities of renewable technologies to the renewable potential
supply curve. This ratio is adjusted using a logistic function with parameters that influence the maturity of renewable technologies. If the technology is not
renewable, the maturity multiplier is set to 1. The purpose is to model the maturity level of renewable technologies based on their
planned capacities relative to the renewable potential supply curve.
```
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
```
The equation calculates a temporary variable which is used to facilitate scaling in the Weibull equation. The scaling is influenced by three main factors:
Maturity Factor for Planned Available Capacity : This factor represents the material-specific influence on the planned available capacity for a power
plant. It accounts for the capacity planning aspect of the power generation technology.
Renewable Technologies Maturity Multiplier: This multiplier reflects the maturity level of renewable technologies. It adjusts the scaling based on how
mature and established the renewable technology is, with a higher maturity leading to a larger multiplier.
Hourly Production Costs : The summation involves the hourly production costs of the technology raised to the power of -6. This suggests that higher
production costs contribute less to the overall scaling, emphasizing the importance of cost efficiency in the scaling process.
The result is a combined measure that takes into account material factors, technology maturity, and cost efficiency in the context of the Weibull
equation, providing a comprehensive basis for scaling considerations.
```
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
  
```
The equation calculates the variable representing the new investment decision for power plants in a given country and time period.
It sums the values for all power plants that do not have carbon capture and storage technology .
The values capture the scaling factors influenced by material-specific factors, renewable technology maturity,
and cost efficiency considerations. Summing these values over relevant power plants provides an aggregated measure for informing new investment decisions, emphasizing
factors such as technology readiness and economic viability.
```
Q04NewInvElec(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04NewInvElec(allCy,YTIME)
             =E=
         sum(PGALL$(not CCS(PGALL)),V04ScalWeibullSum(allCy,PGALL,YTIME));
```
The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
```
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)$(TIME(YTIME) $runCy(allCy)) ..
        V04SharePowPlaNewEq(allCy,PGALL,YTIME)
             =E=
        (V04ScalWeibullSum(allCy,PGALL,YTIME)/ V04NewInvElec(allCy,YTIME))$(not CCS(PGALL)) +
        sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),V04SharePowPlaNewEq(allCy,NOCCS,YTIME))$CCS(PGALL);
```
This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
```
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
  
```
This equation calculates the variable representing the planned electricity generation capacity for a specific power plant  in a given country
and time period. The calculation involves adjusting the actual electricity generation capacity by a small constant and the square
root of the sum of the square of the capacity and a small constant. The purpose of this adjustment is likely to avoid numerical issues and ensure a positive value for
the planned capacity.
```
Q04CapElec2(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CapElec2(allCy,PGALL,YTIME)
             =E=
         ( VmCapElec(allCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VmCapElec(allCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;
```
Compute the variable cost of each power plant technology for every region,
by utilizing the maturity factor related to plant dispatching.
```
Q04CostVarTechElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04CostVarTechElec(allCy,PGALL,YTIME)
            =E=  
        i04MatureFacPlaDisp(allCy,PGALL,YTIME)*V04CostVarTech(allCy,PGALL,YTIME)**(-1);
```
Compute the electricity peak loads of each region,
as a sum of the variable costs of all power plant technologies.
```
Q04CostVarTechElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostVarTechElecTot(allCy,YTIME) 
         =E= 
         sum(PGALL, V04CostVarTechElec(allCy,PGALL,YTIME));     
```
Compute power plant sorting to decide the plant dispatching. 
This is accomplished by dividing the variable cost by the peak loads.
```
Q04SortPlantDispatch(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04SortPlantDispatch(allCy,PGALL,YTIME)
                 =E=
         V04CostVarTechElec(allCy,PGALL,YTIME)
         /
         V04CostVarTechElecTot(allCy,YTIME);  
```
This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
power plants on a yearly basis.
```
Q04NetNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
        V04NetNewCapElec(allCy,PGALL,YTIME) 
            =E=
        V04CapElec2(allCy,PGALL,YTIME)- V04CapElec2(allCy,PGALL,YTIME-1);                       
```
This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
over these eight periods.
```
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
```
This equation calculates the variable representing the overall capacity for a specific power plant in a given country and time period .
The overall capacity is a composite measure that includes the existing capacity for non-renewable power plants and the expected capacity for renewable power plants based
on their average capacity factor.
```
Q04CapOverall(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapOverall(allCy,PGALL,YTIME)
          =E=
    V04CapElec2(allCy,pgall,ytime)$ (not PGREN(PGALL)) +
    V04CFAvgRen(allCy,PGALL,YTIME-1) *
    (
      V04NetNewCapElec(allCy,PGALL,YTIME) / i04AvailRate(PGALL,YTIME) +
      V04CapOverall(allCy,PGALL,YTIME-1) / V04CFAvgRen(allCy,PGALL,YTIME-1)
    )$PGREN(PGALL);
```
This equation calculates the scaling factor for plant dispatching in a specific country , hour of the day,
and time period . The scaling factor for determining the dispatch order of different power plants during a particular hour.
```
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
```
This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
```
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
```
This equation calculates the non-Combined Heat and Power electricity production in a specific country and time period .
It is essentially the difference between the total electricity demand and the estimated electricity generation from CHP plants .In summary,
the equation calculates the electricity production from technologies other than CHP by subtracting the estimated CHP electricity generation from the total electricity
demand. 
```
Q04ProdElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecNonCHP(allCy,YTIME) 
            =E=
        (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME));  
```
This equation calculates the total required electricity production for a specific country and time period .
The total required electricity production is the sum of electricity generation from different technologies, including CHP plants, across all hours of the day.
The total required electricity production is the sum of the electricity generation from all CHP plants across all hours, considering the scaling factor for plant
dispatching. 
```
Q04ProdElecReqCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecReqCHP(allCy,YTIME) 
                =E=
        sum(hour,
          sum(CHP, 
            V04CapElecCHP(allCy,CHP,YTIME) * 0.85 * 
            exp(-V04ScalFacPlaDisp(allCy,HOUR,YTIME) / sum(pgall$chptoeon(chp,pgall), V04SortPlantDispatch(allCy,PGALL,YTIME)))
          )
        );
```
This equation calculates the electricity production from power generation plants for a specific country ,
power generation plant type , and time period . The electricity production is determined based on the overall electricity
demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
capacity and the scaling factor for dispatching.
```
Q04ProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmProdElec(allCy,PGALL,YTIME)
                =E=
        V04ProdElecNonCHP(allCy,YTIME) / (V04ProdElecReqTot(allCy,YTIME) - V04ProdElecReqCHP(allCy,YTIME)) *
        V04CapElec2(allCy,PGALL,YTIME) *
        sum(HOUR,
          exp(-V04ScalFacPlaDisp(allCy,HOUR,YTIME)/V04SortPlantDispatch(allCy,PGALL,YTIME))
        );
```
This equation calculates the sector contribution to total Combined Heat and Power production . The contribution
is calculated for a specific country , industrial sector , CHP technology , and time period .The sector contribution
is calculated by dividing the fuel consumption of the specific industrial sector for CHP by the total fuel consumption of CHP across all industrial
sectors. The result represents the proportion of CHP production attributable to the specified industrial sector. The denominator has a small constant
(1e-6) added to avoid division by zero.
```
$ontext
q04SecContrTotCHPProd(allCy,INDDOM,CHP,YTIME)$(TIME(YTIME) $SECTTECH(INDDOM,CHP) $runCy(allCy))..
         v04SecContrTotCHPProd(allCy,INDDOM,CHP,YTIME) 
          =E=
         VmConsFuel(allCy,INDDOM,CHP,YTIME)/(1e-6+SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,CHP,YTIME)));
$offtext
```
This equation calculates the electricity production from Combined Heat and Power plants . The electricity production is computed
for a specific country , CHP technology , and time period.The electricity production from CHP plants is computed by taking the
ratio of the fuel consumption by the specified industrial sector for CHP technology to the total fuel consumption for all industrial sectors and CHP
technologies. This ratio is then multiplied by the difference between total electricity demand and the sum of electricity production from all power
generation plants. The result represents the portion of electricity production from CHP plants attributed to the specified CHP technology.
```
Q04ProdElecCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ProdElecCHP(allCy,CHP,YTIME)
                 =E=
        sum(INDDOM,VmConsFuel(allCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VmConsFuel(allCy,INDDOM,CHP2,YTIME)))*
        (V04DemElecTot(allCy,YTIME) - SUM(PGALL,VmProdElec(allCy,PGALL,YTIME)));
```
This equation calculates the long-term power generation cost of technologies excluding climate policies.
The cost is computed for a specific country, power generation technology , energy sector, and time period.
The long-term power generation cost is computed as a combination of capital costs, operating and maintenance costs, and variable costs,
considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the availability
rate and conversion factors. The equation provides a comprehensive calculation of the long-term cost associated with power generation technologies,
excluding climate policy-related costs.
```
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
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));
```
This equation calculates the long-term minimum power generation cost for a specific country , power generation technology,
and time period. The minimum cost is computed considering various factors, including discount rates, technological lifetimes, gross capital costs,
fixed operating and maintenance costs, availability rates, variable costs, fuel prices, carbon capture rates, carbon capture and storage costs, carbon
emission factors, and plant efficiency.The long-term minimum power generation cost is calculated as a combination of capital costs, operating and maintenance
costs, and variable costs, considering factors such as discount rates, technological lifetimes, and subsidies. The resulting cost is adjusted based on the
availability rate and conversion factors. This equation provides insight into the minimum cost associated with power generation technologies, excluding climate
policy-related costs, and uses a consistent conversion factor for power capacity.
```
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
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));   
$offtext
```
This equation calculates the long-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable costs
associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the long-term power generation
cost per unit of electricity produced in the given time period. The equation also includes factors such as discount rates, plant availability rates, and the gross
capital cost per plant type with subsidies for renewables.
```
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
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME))); 
$offtext
```
This equation calculates the short-term power generation cost of technologies, including international prices of main fuels. It involves summing the variable
costs associated with each power generation plant and energy form, taking into account international prices of main fuels. The result is the short-term power
generation cost per unit of electricity produced in the given time period.
```
$ontext
q04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         v04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME)
                 =E=
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), imPriceFuelsInt(WEF,YTIME))*smTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +
                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));    
$offtext
```
This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
electricity consumed in the given time period.
```
Q04CostPowGenAvgLng(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VmCostPowGenAvgLng(allCy,ESET,YTIME)
              =E=
        (
          SUM(PGALL, VmProdElec(allCy,PGALL,YTIME) * V04CostPowGenLngTechNoCp(allCy,PGALL,ESET,YTIME)) +
          sum(CHP, VmCostElcAvgProdCHP(allCy,CHP,YTIME) * V04ProdElecCHP(allCy,CHP,YTIME))
        ) / 
        V04DemElecTot(allCy,YTIME); 
```
The equation represents the long-term average power generation cost excluding climate policies.
It calculates the cost in Euro2005 per kilowatt-hour (kWh) for a specific combination of parameters. The equation is composed 
of various factors, including discount rates, technical lifetime of the plant type, gross capital cost with subsidies for renewables,
fixed operation and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, efficiency values, CO2 emission factors,
CO2 capture rates, and carbon prices. The equation incorporates a summation over different plant fuel types and considers the cost curve for CO2 sequestration.
The final result is the average power generation cost per unit of electricity produced, taking into account various economic and technical parameters.
```
Q04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)
                 =E=
             (imDisc(allCy,"PG",YTIME)*EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL)) /
             (EXP(imDisc(allCy,"PG",YTIME)*i04TechLftPlaType(allCy,PGALL))-1)*i04GrossCapCosSubRen(allCy,PGALL,YTIME)*1000*imCGI(allCy,YTIME) +
             i04FixOandMCost(allCy,PGALL,YTIME))/i04AvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (i04VarCost(PGALL,YTIME)/1000+((VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)-imEffValueInDollars(allCy,"PG",ytime)/1000-imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))/1000 )/1.2441+
                 imCO2CaptRate(allCy,PGALL,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME) +
                 (1-imCO2CaptRate(allCy,PGALL,YTIME))*1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)));
```
Compute long term power generation cost excluding climate policies by summing the Electricity production multiplied by Long-term average power generation cost excluding 
climate policies added to the sum of Average Electricity production cost per CHP plant multiplied by the CHP electricity production and all of the above divided by 
the Total electricity demand.
```
Q04CostPowGenLonNoClimPol(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V04CostPowGenLonNoClimPol(allCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, (VmProdElec(allCy,PGALL,YTIME))*V04CostAvgPowGenLonNoClimPol(allCy,PGALL,ESET,YTIME)) +
         sum(CHP, VmCostElcAvgProdCHP(allCy,CHP,YTIME)*V04ProdElecCHP(allCy,CHP,YTIME))
         ) /
         (V04DemElecTot(allCy,YTIME));  
```
This equation establishes a common variable (with arguments) for the electricity consumption per demand subsector of INDUSTRY, [DOMESTIC/TERTIARY/RESIDENTIAL] and TRANSPORT.
The electricity consumption of the demand subsectors of INDUSTRY & [DOMESTIC/TERTIARY/RESIDENTIAL] is provided by the consumption of Electricity as a Fuel.
The electricity consumption of the demand subsectors of TRANSPORT is provided by the Demand of Transport for Electricity as a Fuel.
```
Q04ConsElec(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V04ConsElec(allCy,DSBS,YTIME)
            =E=
        sum(INDDOM $SAMEAS(INDDOM,DSBS), VmConsFuel(allCy,INDDOM,"ELC",YTIME)) + 
        sum(TRANSE $SAMEAS(TRANSE,DSBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME));
```
This equation computes the short-term average power generation cost. It involves summing the variable production costs for different power generation plants and
energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of electricity
consumed in the given time period.
```
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
         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                 *smTWhToMtoe/imPlantEffByType(allCy,PGALL,YTIME)))
        ))
        +
         sum(CHP, VmCostVarAvgElecProd(allCy,CHP,YTIME)*V04ProdElecCHP(allCy,CHP,YTIME))
         )
         /V04DemElecTot(allCy,YTIME);
$offtext
```

```
table i04CummMnmInstRenCap(allCy,PGRENEF,YTIME)	   "Cummulative minimum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMinResPot.csv"
$offdelim
;
table i04AvailRate(allCy,PGALL,YTIME)	                   "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
table i04DataElecSteamGen(allCy,PGOTH,YTIME)	   "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
table i04DataElecProd(allCy,PGALL,YTIME)           "Electricity production past years (GWh)"
$ondelim
$include"./iDataElecProd.csv"
$offdelim
;
table i04DataTechLftPlaType(PGALL, PGECONCHAR)     "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
table i04GrossCapCosSubRen(allCy,PGALL,YTIME)      "Gross Capital Cost per Plant Type with subsidy for renewables (kUS$2015/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
table i04FixOandMCost(allCy,PGALL,YTIME)           "Fixed O&M Gross Cost per Plant Type (US$2015/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;
table i04VarCost(PGALL,YTIME)                      "Variable gross cost other than fuel per Plant Type (US$2015/MWh)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;
table i04InvPlants(allCy,PGALL,YTIME)	           "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
table i04DecomPlants(allCy,PGALL,YTIME)	           "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
table i04CummMxmInstRenCap(allCy,PGRENEF,YTIME)	   "Cummulative maximum potential installed Capacity for Renewables (GW)"
$ondelim
$include"./iMaxResPot.csv"
$offdelim
;
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
table i04MatFacPlaAvailCapL(allCy,PGALL,YTIME)     "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME)    = i04MatFacPlaAvailCapL(runCy,PGALL,YTIME);
i04MatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 0.00000001;
i04MatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 40;
$ELSE.calib
table i04MatFacPlaAvailCap(allCy,PGALL,YTIME)      "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
$ENDIF.calib
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatureFacPlaDisp(allCy,PGALL,YTIME)    "Maturity factor related to plant dispatching (1)";
table i04MatureFacPlaDispL(allCy,PGALL,YTIME)      "Maturity factor related to plant dispatching (1)"
$ondelim
$include "./iMatureFacPlaDisp.csv"
$offdelim
;
i04MatureFacPlaDisp.L(runCy,PGALL,YTIME)    = i04MatureFacPlaDispL(runCy,PGALL,YTIME);
i04MatureFacPlaDisp.LO(runCy, PGALL, YTIME) = 1e-8;
i04MatureFacPlaDisp.UP(runCy, PGALL, YTIME) = 600;
$ELSE.calib
table i04MatureFacPlaDisp(allCy,PGALL,YTIME)       "Maturity factor related to plant dispatching (1)"
$ondelim
$include"./iMatureFacPlaDisp.csv"
$offdelim
;
$ENDIF.calib
parameter i04ScaleEndogScrap(PGALL)                "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
parameter i04MxmShareChpElec                       "Maximum share of CHP electricity in a country (1)";
parameter i04DataElecAndSteamGen(allCy,CHP,YTIME)  "Data releated to electricity and steam generation";
parameter i04LoadFacElecDem(DSBS)                  "Load factor of electricity demand per sector (1)"
/
IS 	0.92,
NF 	0.94,
CH 	0.83,
BM 	0.82,
PP 	0.74,
FD 	0.65,
EN 	0.7,
TX 	0.61,
OE 	0.92,
OI 	0.67,
SE 	0.64,
AG 	0.52,
HOU	0.72,
PC 	0.7,
PB 	0.7,
PT 	0.62,
PN 	0.7,
PA 	0.7,
GU 	0.7,
GT 	0.62,
GN 	0.7,
BU 	0.7,
PCH	0.83,
NEN	0.83 
/ ;
parameter i04LoadFactorAdj(DSBS)	               "Parameters for load factor adjustment i04BaseLoadShareDem (1)"
/
IS 	0.9,
NF 	0.92,
CH 	0.78,
BM 	0.81,
PP 	0.91,
FD 	0.61,
EN 	0.65,
TX 	0.6,
OE 	0.9,
OI 	0.59,
SE 	0.58,
AG 	0.45,
HOU	0.55,
PC 	0.43,
PB 	0.43,
PT 	0.29,
PN 	0.43,
PA 	0.43,
GU 	0.43,
GT 	0.29,
GN 	0.43,
BU 	0.43,
PCH	0.78,
NEN	0.78 
/ ;
parameter i04LoadFactorAdjMxm(VARIOUS_LABELS)      "Parameter for load factor adjustment i04MxmLoadFacElecDem (1)"
/
AMAXBASE  3,
MAXLOADSH 0.45
/ ;
Parameters
i04BaseLoadShareDem(allCy,DSBS,YTIME)	           "Baseload share of demand per sector (1)"
i04PeakBsLoadBy(allCy,PGLOADTYPE)	               "Peak and Base load for base year (GW)"
i04TotAvailCapBsYr(allCy)	                       "Total installed available capacity in base year (GW)"
iTotAvailNomCapBsYr(allCy,YTIME)	               "Total nominal available installed capacity in base year (GW)"
i04UtilRateChpPlants(allCy,CHP,YTIME)	           "Utilisation rate of CHP Plants (1)"
i04MxmLoadFacElecDem(allCy,YTIME)	               "Maximum load factor of electricity demand (1)"
i04BslCorrection(allCy,YTIME)	                   "Parameter of baseload correction (1)"
i04TechLftPlaType(allCy,PGALL)	                   "Technical Lifetime per plant type (year)"
i04ScaleEndogScrap(PGALL)                          "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
i04DecInvPlantSched(allCy,PGALL,YTIME)             "Decided plant investment schedule (GW)"
i04PlantDecomSched(allCy,PGALL,YTIME)	           "Decided plant decomissioning schedule (GW)"	
i04MxmShareChpElec(allCy,YTIME)	                   "Maximum share of CHP electricity in a country (1)"
!! i04MatureFacPlaDisp(allCy,PGALL,YTIME)	       "Maturity factor related to plant dispatching (1)"
;
i04BaseLoadShareDem(runCy,DSBS,YTIME)$an(YTIME)  = i04LoadFactorAdj(DSBS);
i04DataElecAndSteamGen(runCy,CHP,YTIME) = 0 ;
i04CummMnmInstRenCap(runCy,PGRENEF,YTIME)$(not i04CummMnmInstRenCap(runCy,PGRENEF,YTIME)) = 1e-4;
i04PeakBsLoadBy(runCy,PGLOADTYPE) = sum(TFIRST, i04DataElecSteamGen(runCy,PGLOADTYPE,TFIRST));
i04TotAvailCapBsYr(runCy) = sum(TFIRST,i04DataElecSteamGen(runCy,"TOTCAP",TFIRST))+sum(TFIRST,i04DataElecSteamGen(runCy,"CHP_CAP",TFIRST))*0.85;
iTotAvailNomCapBsYr(runCy,YTIME)$datay(YTIME) = i04DataElecSteamGen(runCy,"TOTNOMCAP",YTIME);
i04UtilRateChpPlants(runCy,CHP,YTIME) = 0.5;
i04MxmLoadFacElecDem(runCy,YTIME)$an(YTIME) = i04LoadFactorAdjMxm("MAXLOADSH");
i04BslCorrection(runCy,YTIME)$an(YTIME) = i04LoadFactorAdjMxm("AMAXBASE");
i04TechLftPlaType(runCy,PGALL) = i04DataTechLftPlaType(PGALL, "LFT");
i04GrossCapCosSubRen(runCy,PGALL,YTIME) = i04GrossCapCosSubRen(runCy,PGALL,YTIME)/1000;
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(i04GrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", i04GrossCapCosSubRen
ENDLOOP;
i04ScaleEndogScrap(PGALL) = 0.035;
i04DecInvPlantSched(runCy,PGALL,YTIME) = i04InvPlants(runCy,PGALL,YTIME);
i04PlantDecomSched(runCy,PGALL,YTIME) = i04DecomPlants(runCy,PGALL,YTIME);
i04MxmShareChpElec(runCy,YTIME) = 0.1;
```

*VARIABLE INITIALISATION*
```
V04SensCCS.L(runCy,YTIME) = 1;
V04CostProdSpecTech.LO(runCy,PGALL2,YTIME) = 0.00000001;
V04CostVarTech.L(runCy,PGALL,YTIME) = 0.1;
V04CostProdTeCHPreReplacAvail.L(runCy,PGALL,PGALL2,YTIME) = 0.1;
V04ShareNewTechNoCCS.L(runCy,PGALL,TT)=0.1;
V04ShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
V04ShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL))) = 0;
V04ShareNewTechCCS.L(runCy,PGALL,TT) = 0.1;
V04ShareNewTechCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
V04ShareNewTechCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL))) = 0;
V04CostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,TT) = V04ShareNewTechNoCCS.L(runCy,PGALL,TT)*0.1 + sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS.L(runCy,CCS,TT)*0.1);
V04NewInvElec.L(runCy,YTIME) = 0.1;
V04NewInvElec.FX(runCy,YTIME)$(NOT AN(YTIME)) = 1;
V04CostVarTechElec.L(runCy,PGALL,YTIME) = 0.1;
V04CostVarTechElecTot.L(runCy,YTIME) = 0.1;
alias(datay, dataylag)
loop (runCy,PGALL,datay,dataylag)$(ord(datay) = ord(dataylag) + 1 and PGREN(PGALL)) DO
  V04NetNewCapElec.FX(runCy,PGALL,datay) = imInstCapPastNonCHP(runCy,PGALL,datay) - imInstCapPastNonCHP(runCy,PGALL,dataylag);
ENDLOOP;
V04NetNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;
V04CFAvgRen.L(runCy,PGALL,YTIME) = 0.1;
V04CFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = i04AvailRate(PGALL,YTIME);
V04SortPlantDispatch.l(runCy,PGALL,YTIME)=V04CostVarTechElec.L(runCy,PGALL,YTIME)/V04CostVarTechElecTot.L(runCy,YTIME);
V04ProdElecReqCHP.L(runCy,YTIME) = 0.01;
V04ScalFacPlaDisp.LO(runCy, HOUR, YTIME) = -1;
V04RenTechMatMult.L(runCy,PGALL,YTIME) = 1;
V04ScalWeibullSum.L(runCy,PGALL,YTIME) = 2000;
V04RenTechMatMultExpr.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL)) = 0;
V04CostHourProdInvDec.L(runCy,PGALL,HOUR,TT) = 0.0001;
V04CostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME))) = 0;
VmCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = i04TotAvailCapBsYr(runCy);
V04CapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = i04TotAvailCapBsYr(runCy);
V04CapElecCHP.FX(runCy,CHP,YTIME)$(not An(YTIME)) = imInstCapPastCHP(runCy,CHP,YTIME);
V04SharePowPlaNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) ) = 0;
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  imInstCapPastNonCHP(runCy,PGALL,YTIME);
V04CapElec2.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME);
V04CapOverall.FX(runCy,PGALL,"%fBaseY%") =  imInstCapPastNonCHP(runCy,PGALL,"%fBaseY%");
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME)/i04AvailRate(PGALL,YTIME);
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
V04IndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants
V04CostPowGenLonNoClimPol.L(runCy,ESET,"2010") = 0;
V04CostPowGenLonNoClimPol.L(runCy,ESET,"%fBaseY%") = 0;
V04CostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
V04CostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;
V04Lambda.LO(runCy,YTIME) = 0;
V04Lambda.L(runCy,YTIME) = 0.21;
V04CostProdSpecTech.scale(runCy,PGALL,YTIME)=1e12;
Q04CostProdSpecTech.scale(runCy,PGALL,YTIME)=V04CostProdSpecTech.scale(runCy,PGALL,YTIME);
V04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=1e6;
Q04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=V04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME);
V04ScalFacPlaDisp.scale(runCy,HOUR,YTIME)=1e-4;
Q04ScalFacPlantDispatch.scale(runCy,HOUR,YTIME)=V04ScalFacPlaDisp.scale(runCy,HOUR,YTIME);
V04SortPlantDispatch.scale(runCy,PGALL,YTIME)=1e-12;
Q04SortPlantDispatch.scale(runCy,PGALL,YTIME)=V04SortPlantDispatch.scale(runCy,PGALL,YTIME);
V04CostVarTechElec.scale(runCy,PGALL,YTIME)=1e5;
Q04CostVarTechElec.scale(runCy,PGALL,YTIME)=V04CostVarTechElec.scale(runCy,PGALL,YTIME);
V04NewInvElec.scale(runCy,YTIME)=1e8;
Q04NewInvElec.scale(runCy,YTIME)=V04NewInvElec.scale(runCy,YTIME);
V04CostVarTech.scale(runCy,PGALL,YTIME)=1e-5;
Q04CostVarTech.scale(runCy,PGALL,YTIME)=V04CostVarTech.scale(runCy,PGALL,YTIME);
V04ScalWeibullSum.scale(runCy,PGALL,YTIME)=1e6;
Q04ScalWeibullSum.scale(runCy,PGALL,YTIME)=V04ScalWeibullSum.scale(runCy,PGALL,YTIME);
V04LoadFacDom.L(runCy,YTIME)=0.5;
V04LoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         i04LoadFacElecDem(TRANSE)));
V04DemElecTot.L(runCy,YTIME)=10;
V04DemElecTot.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( imFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, imFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + imDistrLosses(runCy,"ELC",YTIME)
                                             + i03TotEneBranchCons(runCy,"ELC",YTIME) - (imFuelImports(runCy,"ELC",YTIME)-imFuelExprts(runCy,"ELC",YTIME)));
VmPeakLoad.L(runCy,YTIME) = 1;
VmPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = V04DemElecTot.L(runCy,YTIME)/(V04LoadFacDom.L(runCy,YTIME)*8.76);
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME)=i04DataElecProd(runCy,pgall,YTIME)/1000;
V04ProdElecReqTot.FX(runCy,"%fBaseY%")=sum(pgall,VmProdElec.L(runCy,pgall,"%fBaseY%"));
V04ConsElec.L(runCy,DSBS,YTIME)=0.1;
V04ConsElec.FX(runCy,DSBS,YTIME)$(not AN(YTIME)) = 0.1;
```


> **Limitations**
> There are no known limitations.

### (B) simple

This is the legacy realization of the PowerGeneration module.


```
Equations
```
*** Power Generation
```
Q04CapElecNominal(allCy,PGALL,YTIME)	                   "Compute nominal electricity generation capacity"
Q04ShareTechPG(allCy,PGALL,YTIME)                          "Share of all technologies in the electricity mixture"
Q04CostHourProdInvDec(allCy,PGALL,YTIME)                    "Compute production cost used in investment decisions"
Q04CostVarTech(allCy,PGALL,YTIME)	                       "Compute variable cost of technology" 	
Q04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Compute endogenous scrapping index" 	
Q04CapElecNonCHP(allCy,YTIME)	                           "Compute total electricity generation capacity excluding CHP plants"
Q04GapGenCapPowerDiff(allCy,YTIME)	                       "Compute the gap in power generation capacity"		
Q04ShareSatPG(allCy,PGALL,YTIME)	                       "Saturation mechanism for electricity mixture penetration of RES technologies"		 	
Q04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Compute the power plant share in new equipment"	
Q04NewCapElec(allCy,PGALL,YTIME)	                       "Compute the new capacity added every year"
Q04NetNewCapElec(allCy,PGALL,YTIME)	                       "Compute the yearly difference in installed capacity"		
Q04CFAvgRen(allCy,PGALL,YTIME)	                           "Compute the average capacity factor of RES"	
Q04CapOverall(allCy,PGALL,YTIME)	                       "Compute overall capacity"
Q04LoadFacDom(allCy,YTIME)                                 "Compute electricity load factor for entire domestic system"	
$ifthen.calib %Calibration% == off
Q04DemElecTot(allCy,YTIME)                                 "Compute total electricity demand (TWh)"
$endif.calib
Q04CapElecCHP(allCy,YTIME)                             "Compute CHP electric capacity"	
Q04ProdElecEstCHP(allCy,YTIME)	                       "Estimate the electricity of CHP Plants"	
Q04CapexFixCostPG(allCy,PGALL,YTIME)                       "Computes the capex and fixed costs of any power generation technology"
Q04ShareMixWndSol(allCy,YTIME)                             "Computes the participation of solar and wind in the energy mixture (%)"
Q04CapexRESRate(allCy,PGALL,YTIME)                         "Estimates a multiplying factor expressing the extra grid and storage costs for RES implementation according to the RES penetration in the mixture"
Q04CO2CaptRate(allCy,PGALL,YTIME)
Q04CostCapTech(allCy,PGALL,YTIME)
Q04CCSRetroFit(allCy,PGALL,YTIME)
Q04ScrpRate(allCy,PGALL,YTIME)
```
**Interdependent Equations**
```
Q04ProdElec(allCy,PGALL,YTIME)                             "Compute electricity production from power generation plants"
Q04CostPowGenAvgLng(allCy,YTIME)	                   "Compute long term power generation cost"
Q04CapElecTotEst(allCy,YTIME)                              "Compute Estimated total electricity generation capacity"
Q04PeakLoad(allCy,YTIME)	                               "Compute elerctricity peak load"	
Q04CapElec(allCy,PGALL,YTIME)	                           "Compute electricity generation capacity"
Q04ConsFuelElecProd(allCy,EFS,YTIME)
;
Variables
```
*** Power Generation Variables
```
V04CapElecNominal(allCy,PGALL,YTIME)	                   "Nominal electricity generation plants capacity (GW)"
V04ShareTechPG(allCy,PGALL,YTIME)                          "Share of all technologies in the electricity mixture"
V04CapElecCHP(allCy,YTIME)	                           "Capacity of CHP Plants (GW)"
V04CostHourProdInvDec(allCy,PGALL,YTIME)                    "Production cost of technology (US$2015/KWh)"
V04CostVarTech(allCy,PGALL,YTIME)	                       "Variable cost of technology (US$2015/KWh)"	
V04IndxEndogScrap(allCy,PGALL,YTIME)	                   "Index used for endogenous power plants scrapping (1)"			
V04CapElecNonCHP(allCy,YTIME)	                           "Total electricity generation capacity excluding CHP (GW)"	
V04GapGenCapPowerDiff(allCy,YTIME)	                       "Gap in total generation capacity to be filled by new equipment (GW)"		
V04ShareSatPG(allCy,PGALL,YTIME)	                           "Saturation for electricity mixture penetration of RES technologies"	
V04SharePowPlaNewEq(allCy,PGALL,YTIME)	                   "Power plant share in new equipment (1)"			
V04SortPlantDispatch(allCy,PGALL,YTIME)	                   "Power plants sorting according to variable cost to decide the plant dispatching (1)"
V04NewCapElec(allCy,PGALL,YTIME)	                       "The new capacity added every year (MW)"	
V04NetNewCapElec(allCy,PGALL,YTIME)	                       "Yearly difference in installed capacity (MW)"	
V04CFAvgRen(allCy,PGALL,YTIME)	                           "The average capacity factor of RES (1)"
V04CapOverall(allCy,PGALL,YTIME)	                       "Overall Capacity (MW)"	
V04LoadFacDom(allCy,YTIME)                                 "Electricity load factor for entire domestic system"	
V04DemElecTot(allCy,YTIME)                                 "Total electricity demand (TWh)"
V04ProdElecEstCHP(allCy,YTIME)	                       "Estimate the electricity of CHP Plants (1)"	
V04CapexFixCostPG(allCy,PGALL,YTIME)                       "CAPEX and fixed costs of any power generation technology (US$2015/kW)"
V04ShareMixWndSol(allCy,YTIME)                             "The participation of solar and wind in the energy mixture(%)"
V04CapexRESRate(allCy,PGALL,YTIME)                         "Multiplying factor expressing the extra grid and storage costs for RES implementation according to the RES penetration in the mixture"
V04CO2CaptRate(allCy,PGALL,YTIME)
V04CostCapTech(allCy,PGALL,YTIME)
V04CCSRetroFit(allCy,PGALL,YTIME)
V04ScrpRate(allCy,PGALL,YTIME)
```
**Interdependent Variables**	
```
VmProdElec(allCy,PGALL,YTIME)                              "Electricity production (TWh)"	
VmCostPowGenAvgLng(allCy,YTIME)	                   "Long-term average power generation cost (US$2015/kWh)"
VmCapElecTotEst(allCy,YTIME)	                           "Estimated Total electricity generation capacity (GW)"
VmPeakLoad(allCy,YTIME)	                                   "Electricity peak load (GW)"	
VmCapElec(allCy,PGALL,YTIME)	                           "Electricity generation plants capacity (GW)"
VmConsFuelElecProd(allCy,EFS,YTIME)
;
Scalars
S04CapexBessRate                                            "The power expressing the rate of the increase in the solar & wind CAPEX because of storage need and grid upgrade" /1.3/
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
Power Generation
This equation calculates the estimated electricity generation of Combined Heat and Power plantsin a specific countryand time period.
The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall
electricity demand. The equation essentially estimates the electricity generation of CHP plants by considering their fuel consumption, electricity prices, and the maximum
share of CHP electricity in total demand. The square root expression ensures that the estimated electricity generation remains non-negative.
```
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
```
This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors,
including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power
generation plants, and the utilization rate of CHP plants. The result represents the electric capacity of CHP plants in GW.
```
Q04CapElecCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecCHP(allCy,YTIME)
        =E=
    V04ProdElecEstCHP(allCy,YTIME) / (1e3 * smGwToTwhPerYear(YTIME));  
$ifthen.calib %Calibration% == off
```
The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity,
distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor 
which converts terawatt-hours (TWh) to million tonnes of oil equivalent (Mtoe). The formula provides a comprehensive measure of the factors contributing
to the total electricity demand.
```
Q04DemElecTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04DemElecTot(allCy,YTIME)
        =E=
    1 / smTWhToMtoe *
    ( 
      VmConsFinEneCountry(allCy,"ELC",YTIME) + 
      VmConsFinNonEne(allCy,"ELC",YTIME) + 
      VmLossesDistr(allCy,"ELC",YTIME) +
      VmConsFiEneSec(allCy,"ELC",YTIME) - 
      VmImpNetEneBrnch(allCy,"ELC",YTIME)
    );
$endif.calib
```
This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
of electricity demand per sector
```
Q04LoadFacDom(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04LoadFacDom(allCy,YTIME)
        =E=
    (sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME))) /
    (
    sum(INDDOM,VmConsFuel(allCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + 
    sum(TRANSE, VmDemFinEneTranspPerFuel(allCy,TRANSE,"ELC",YTIME)/i04LoadFacElecDem(TRANSE))
    );         
```
The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result
to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period, taking into account the domestic
load factor.
```
Q04PeakLoad(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPeakLoad(allCy,YTIME)
        =E=
    V04DemElecTot(allCy,YTIME) /
    (V04LoadFacDom(allCy,YTIME) * smGwToTwhPerYear(YTIME));
```
The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with
the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required
generation capacity based on the changes in peak load.
```
Q04CapElecTotEst(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapElecTotEst(allCy,YTIME)
          =E=
    VmCapElecTotEst(allCy,YTIME-1) *
    VmPeakLoad(allCy,YTIME) / VmPeakLoad(allCy,YTIME-1);          
```
This equation calculates the CAPEX and the Fixed Costs of each power generation unit, taking into account its discount rate and life expectancy, 
for each region (country) and year.
```
Q04CapexFixCostPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapexFixCostPG(allCy,PGALL,YTIME)
        =E=         
    ( 
      imDisc(allCy,"PG",YTIME) * exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL))
      / (exp(imDisc(allCy,"PG",YTIME) * i04TechLftPlaType(allCy,PGALL)) -1)
    ) * i04GrossCapCosSubRen(allCy,PGALL,YTIME) * 1000 * imCGI(allCy,YTIME) +
    i04FixOandMCost(allCy,PGALL,YTIME);
Q04CostCapTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostCapTech(allCy,PGALL,YTIME) 
        =E=
    V04CapexRESRate(allCy,PGALL,YTIME) * V04CapexFixCostPG(allCy,PGALL,YTIME) / 
    (i04AvailRate(allCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000);
```
Compute the variable cost of each power plant technology for every region,
By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
```
Q04CostVarTech(allCy,PGALL,YTIME)$(time(YTIME) $runCy(allCy))..
    V04CostVarTech(allCy,PGALL,YTIME) 
        =E=
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (VmRenValue(YTIME) * 8.6e-5)$(not (PGREN2(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME) +
      V04CO2CaptRate(allCy,PGALL,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-V04CO2CaptRate(allCy,PGALL,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME)))
      ) * smTWhToMtoe / imPlantEffByType(allCy,PGALL,YTIME)
    )$(not PGREN(PGALL));
```
The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors,
including the discount rate, gross capital cost, fixed operation and maintenance cost, availability rate, variable cost, renewable value, and fuel prices.
The production cost is normalized per unit of electricity generated (kEuro2005/kWh) and is considered for each hour of the day. The equation includes considerations
for renewable plants (excluding certain types) and fossil fuel plants.
```
Q04CostHourProdInvDec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CostHourProdInvDec(allCy,PGALL,YTIME)
        =E=         
    V04CostCapTech(allCy,PGALL,YTIME) +
    V04CostVarTech(allCy,PGALL,YTIME);
```
The equation computes the endogenous scrapping index for power generation plants  during the specified year .
The index is calculated as the variable cost of technology excluding power plants flagged as not subject to scrapping 
divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping . The scale
parameter is applied to the sum of full costs and raised to the power of -2. The resulting index is used to determine the endogenous scrapping of power plants.
```
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
```
The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year .
It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 (assuming an efficiency of 85%) from the
total electricity generation capacity . This provides the total electricity generation capacity without considering the contribution of CHP plants.
```
Q04CapElecNonCHP(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNonCHP(allCy,YTIME)
        =E=
    VmCapElecTotEst(allCy,YTIME) -
    V04CapElecCHP(allCy,YTIME);      
```
In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity,
decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
```
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
```
Calculates the share of all the unflexible RES penetration into the mixture, and specifically how much above a given threshold it is.
```
Q04ShareMixWndSol(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareMixWndSol(allCy,YTIME)
        =E=
    sum(PGALL$(PGRENSW(PGALL)), VmCapElec(allCy,PGALL,YTIME)) /
    sum(PGALL, VmCapElec(allCy,PGALL,YTIME));
 
```
The equation calculates a temporary variable which is used to facilitate scaling in the Weibull equation. The scaling is influenced by three main factors:
Maturity Factor for Planned Available Capacity : This factor represents the material-specific influence on the planned available capacity for a power
plant. It accounts for the capacity planning aspect of the power generation technology.
Renewable Technologies Maturity Multiplier: This multiplier reflects the maturity level of renewable technologies. It adjusts the scaling based on how
mature and established the renewable technology is, with a higher maturity leading to a larger multiplier.
Hourly Production Costs : The summation involves the hourly production costs of the technology raised to the power of -6. This suggests that higher
production costs contribute less to the overall scaling, emphasizing the importance of cost efficiency in the scaling process.
The result is a combined measure that takes into account material factors, technology maturity, and cost efficiency in the context of the Weibull
equation, providing a comprehensive basis for scaling considerations.
The equation calculates the variable  representing the power plant share in new equipment for a specific power plant  in a given country 
and time period . The calculation depends on whether the power plant has carbon capture and storage technology .
For power plants without CCS , the share in new equipment is determined by the ratio of the value for the specific power plant to the
overall new investment decision for power plants . This ratio provides a proportionate share of new equipment for each power plant, considering factors such
as material-specific scaling and economic considerations.For power plants with CCS , the share is determined by summing the shares of corresponding power plants
without CCS. This allows for the allocation of shares in new equipment for CCS and non-CCS versions of the same power plant.
```
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
```
This equation calculates the variable representing the electricity generation capacity for a specific power plant in a given country
and time period. The calculation takes into account various factors related to new investments, decommissioning, and technology-specific parameters.
The equation aims to model the evolution of electricity generation capacity over time, considering new investments, decommissioning, and technology-specific parameters.
```
Q04CapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapElec(allCy,PGALL,YTIME)
          =E=
    VmCapElec(allCy,PGALL,YTIME-1) * (1 - V04ScrpRate(allCy,PGALL,YTIME)) +
    V04NewCapElec(allCy,PGALL,YTIME) -
    i04PlantDecomSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME);
Q04CapElecNominal(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapElecNominal(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL,YTIME);
         
Q04NewCapElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04NewCapElec(allCy,PGALL,YTIME)
        =E=
    V04SharePowPlaNewEq(allCy,PGALL,YTIME) * V04GapGenCapPowerDiff(allCy,YTIME) +
    i04DecInvPlantSched(allCy,PGALL,YTIME) * i04AvailRate(allCy,PGALL,YTIME) +
    SUM(PGALL2$CCS_NOCCS(PGALL,PGALL2),
      (1 - V04CCSRetroFit(allCy,PGALL2,YTIME)) * VmCapElec(allCy,PGALL2,YTIME-1)
    );
```
This equation calculates the variable representing the newly added electricity generation capacity for a specific renewable power plant 
in a given country and time period. The calculation involves subtracting the planned electricity generation capacity in the current time period
from the planned capacity in the previous time period. The purpose of this equation is to quantify the increase in electricity generation capacity for renewable
power plants on a yearly basis.
```
Q04NetNewCapElec(allCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME)$runCy(allCy))..
    V04NetNewCapElec(allCy,PGALL,YTIME) 
        =E=
    VmCapElec(allCy,PGALL,YTIME) - VmCapElec(allCy,PGALL,YTIME-1);                       
```
This equation calculates the variable representing the average capacity factor of renewable energy sources for a specific renewable power plant
in a given country  and time period. The capacity factor is a measure of the actual electricity generation output relative to the maximum
possible output.The calculation involves considering the availability rates for the renewable power plant in the current and seven previous time periods,
as well as the newly added capacity in these periods. The average capacity factor is then computed as the weighted average of the availability rates
over these eight periods.
```
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
```
This equation calculates the variable representing the overall capacity for a specific power plant in a given country and time period .
The overall capacity is a composite measure that includes the existing capacity for non-renewable power plants and the expected capacity for renewable power plants based
on their average capacity factor.
```
Q04CapOverall(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04CapOverall(allCy,PGALL,YTIME)
          =E=
    VmCapElec(allCy,pgall,ytime)$(not PGREN(PGALL)) +
    V04CFAvgRen(allCy,PGALL,YTIME-1) *
    (
      V04NetNewCapElec(allCy,PGALL,YTIME) / i04AvailRate(allCy,PGALL,YTIME) +
      V04CapOverall(allCy,PGALL,YTIME-1) / V04CFAvgRen(allCy,PGALL,YTIME-1)
    )$PGREN(PGALL);
```
This equation calculates the electricity production from power generation plants for a specific country ,
power generation plant type , and time period . The electricity production is determined based on the overall electricity
demand, the required electricity production, and the capacity of the power generation plants.The equation calculates the electricity production
from power generation plants based on the proportion of electricity demand that needs to be met by power generation plants, considering their
capacity and the scaling factor for dispatching.
```
Q04ProdElec(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdElec(allCy,PGALL,YTIME)
        =E=
    (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME)) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME)) *
    VmCapElec(allCy,PGALL,YTIME);
```
Share of all technologies in the electricity mixture.
```
Q04ShareTechPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V04ShareTechPG(allCy,PGALL,YTIME)
        =E=
    VmCapElec(allCy,PGALL,YTIME) /
    sum(PGALL2, VmCapElec(allCy,PGALL2,YTIME));
```
Sigmoid function used as a saturation mechanism for electricity mixture penetration of RES technologies.
```
Q04ShareSatPG(allCy,PGALL,YTIME)$(TIME(YTIME)$(runCy(allCy))$(PGREN(PGALL)))..
    V04ShareSatPG(allCy,PGALL,YTIME)
        =E=
    2 / (1+exp(9*V04ShareTechPG(allCy,PGALL,YTIME)));
```
This equation computes the long-term average power generation cost. It involves summing the long-term average power generation costs for different power generation
plants and energy forms, considering the specific characteristics and costs associated with each. The result is the average power generation cost per unit of
electricity consumed in the given time period.
```
Q04CostPowGenAvgLng(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostPowGenAvgLng(allCy,YTIME)
        =E=
    (
      SUM(PGALL, VmProdElec(allCy,PGALL,YTIME) * V04CostHourProdInvDec(allCy,PGALL,YTIME))
    ) / 
    (V04DemElecTot(allCy,YTIME) - V04ProdElecEstCHP(allCy,YTIME)); 
```
This equation estimates the factor increasing the CAPEX of new RES (unflexible) capacity installation due to simultaneous need for grind upgrade and storage, 
for each region (country) and year. This factor depends on the existing RES (unflexible) penetration in the electriciy mixture.
```
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
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
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
```
The equation computes the electricity production cost per Combined Heat and Power plant for a specific demand sector within a given subsector.
The cost is determined based on various factors, including the discount rate, technical lifetime of CHP plants, capital cost (EUR/kW), fixed O&M cost (EUR/kW), availability rate,
variable cost(EUR/MWh), and fuel-related costs. The equation provides a comprehensive assessment of the overall expenses associated with electricity production from CHP
plants, considering both the fixed and variable components, as well as factors such as carbon prices and CO2 emission factors.
The resulting variable represents the electricity production cost per CHP plant and demand sector, expressed in Euro per kilowatt-hour (Euro/KWh).
```
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
```
The equation calculates the average electricity production cost per Combined Heat and Power plant .
It involves a summation over demand subsectors . The average electricity production cost is determined by considering the electricity
production cost per CHP plant for each demand subsector. The result is expressed in Euro per kilowatt-hour (Euro/KWh).
```
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
```

```
table i04AvailRate(allCy,PGALL,YTIME)	                   "Plant availability rate (1)"
$ondelim
$include"./iAvailRate.csv"
$offdelim
;
i04AvailRate(allCy,"PGH2F",YTIME) = 0.9;
table i04DataElecSteamGen(allCy,PGOTH,YTIME)	   "Various Data related to electricity and steam generation (1)"
$ondelim
$include"./iDataElecSteamGen.csv"
$offdelim
;
table i04DataElecProdNonCHP(allCy,PGALL,YTIME)           "Electricity Non-CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdNonCHP.csv"
$offdelim
;
table i04DataElecProdCHP(allCy,EF,YTIME)           "Electricity CHP production past years (GWh)"
$ondelim
$include"./iDataElecProdCHP.csv"
$offdelim
;
$ifthen.calib %Calibration% == MatCalibration
table t04DemElecTot(allCy, YTIME)                   "Secondary energy electricity - target demand (TWh)"
$ondelim
$include "../targets/tDemand.csv"
$offdelim
;
table t04SharePowPlaNewEq(allCy,PGALL,YTIME)    "Ratio of newly added capacity smoothed over 10-year period ()"
$ondelim
$include "../targets/tShares_ProdElec.csv"
$offdelim
;
$endif.calib
table i04DataTechLftPlaType(PGALL, PGECONCHAR)     "Data for power generation costs (various)"
$ondelim
$include"./iDataTechLftPlaType.csv"
$offdelim
;
table i04GrossCapCosSubRen(allCy,PGALL,YTIME)      "Gross Capital Cost per Plant Type with subsidy for renewables (kUS$2015/KW)"
$ondelim
$include"./iGrossCapCosSubRen.csv"
$offdelim
;
table i04FixOandMCost(allCy,PGALL,YTIME)           "Fixed O&M Gross Cost per Plant Type (US$2015/KW)"
$ondelim
$include"./iFixOandMCost.csv"
$offdelim
;
table i04VarCost(PGALL,YTIME)                      "Variable gross cost other than fuel per Plant Type (US$2015/MWh)"
$ondelim
$include"./iVarCost.csv"
$offdelim
;
i04VarCost(PGALL,YTIME) = i04VarCost(PGALL,YTIME) + 1e-3;
table i04InvPlants(allCy,PGALL,YTIME)	           "Investment Plants (MW)"
$ondelim
$include"./iInvPlants.csv"
$offdelim
;
table i04DecomPlants(allCy,PGALL,YTIME)	           "Decomissioning Plants (MW)"
$ondelim
$include"./iDecomPlants.csv"
$offdelim
;
table i03InpPGTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpPGTransfProcess.csv"
$offdelim
;
table i03OutPGTransfProcess(allCy,ELCEF,YTIME)	      ""	
$ondelim
$include"./iOutPGTransfProcess.csv"
$offdelim
;
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatFacPlaAvailCap(allCy,PGALL,YTIME)   "Maturity factor related to plant available capacity (1)";
table i04MatFacPlaAvailCapL(allCy,PGALL,YTIME)     "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
i04MatFacPlaAvailCap.L(runCy,PGALL,YTIME)    = i04MatFacPlaAvailCapL(runCy,PGALL,YTIME);
i04MatFacPlaAvailCap.LO(runCy, PGALL, YTIME) = 1e-8;
i04MatFacPlaAvailCap.UP(runCy, PGALL, YTIME) = 40;
$ELSE.calib
table i04MatFacPlaAvailCap(allCy,PGALL,YTIME)      "Maturity factor related to plant available capacity (1)"
$ondelim
$include "./iMatFacPlaAvailCap.csv"
$offdelim
;
$ENDIF.calib
$IFTHEN.calib %Calibration% == MatCalibration
variable i04MatureFacPlaDisp(allCy,PGALL,YTIME)    "Maturity factor related to plant dispatching (1)";
table i04MatureFacPlaDispL(allCy,PGALL,YTIME)      "Maturity factor related to plant dispatching (1)"
$ondelim
$include "./iMatureFacPlaDisp.csv"
$offdelim
;
i04MatureFacPlaDisp.L(runCy,PGALL,YTIME)    = i04MatureFacPlaDispL(runCy,PGALL,YTIME);
i04MatureFacPlaDisp.LO(runCy, PGALL, YTIME) = 1e-8;
i04MatureFacPlaDisp.UP(runCy, PGALL, YTIME) = 600;
$ELSE.calib
table i04MatureFacPlaDisp(allCy,PGALL,YTIME)       "Maturity factor related to plant dispatching (1)"
$ondelim
$include"./iMatureFacPlaDisp.csv"
$offdelim
;
$ENDIF.calib
parameter i04MxmShareChpElec                       "Maximum share of CHP electricity in a country (1)";
parameter i04LoadFacElecDem(DSBS)                  "Load factor of electricity demand per sector (1)"
/
IS 	0.92,
NF 	0.94,
CH 	0.83,
BM 	0.82,
PP 	0.74,
FD 	0.65,
EN 	0.7,
TX 	0.61,
OE 	0.92,
OI 	0.67,
SE 	0.64,
AG 	0.52,
HOU	0.72,
PC 	0.7,
PB 	0.7,
PT 	0.62,
PN 	0.7,
PA 	0.7,
GU 	0.7,
GT 	0.62,
GN 	0.7,
BU 	0.7,
PCH	0.83,
NEN	0.83 
/ ;
parameter i04LoadFactorAdj(DSBS)	               "Parameters for load factor adjustment i04BaseLoadShareDem (1)"
/
IS 	0.9,
NF 	0.92,
CH 	0.78,
BM 	0.81,
PP 	0.91,
FD 	0.61,
EN 	0.65,
TX 	0.6,
OE 	0.9,
OI 	0.59,
SE 	0.58,
AG 	0.45,
HOU	0.55,
PC 	0.43,
PB 	0.43,
PT 	0.29,
PN 	0.43,
PA 	0.43,
GU 	0.43,
GT 	0.29,
GN 	0.43,
BU 	0.43,
PCH	0.78,
NEN	0.78 
/ ;
parameter i04LoadFactorAdjMxm(VARIOUS_LABELS)      "Parameter for load factor adjustment i04MxmLoadFacElecDem (1)"
/
AMAXBASE  3,
MAXLOADSH 0.45
/ ;
Parameters
i04BaseLoadShareDem(allCy,DSBS,YTIME)	           "Baseload share of demand per sector (1)"
iTotAvailNomCapBsYr(allCy,YTIME)	               "Total nominal available installed capacity in base year (GW)"
i04MxmLoadFacElecDem(allCy,YTIME)	               "Maximum load factor of electricity demand (1)"
i04TechLftPlaType(allCy,PGALL)	                   "Technical Lifetime per plant type (year)"
i04ScaleEndogScrap                              "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
i04DecInvPlantSched(allCy,PGALL,YTIME)             "Decided plant investment schedule (GW)"
i04PlantDecomSched(allCy,PGALL,YTIME)	           "Decided plant decomissioning schedule (GW)"	
i04MxmShareChpElec(allCy,YTIME)	                   "Maximum share of CHP electricity in a country (1)"
!! i04MatureFacPlaDisp(allCy,PGALL,YTIME)	       "Maturity factor related to plant dispatching (1)"
;
i04BaseLoadShareDem(runCy,DSBS,YTIME)$an(YTIME)  = i04LoadFactorAdj(DSBS);
iTotAvailNomCapBsYr(runCy,YTIME)$datay(YTIME) = i04DataElecSteamGen(runCy,"TOTNOMCAP",YTIME);
i04MxmLoadFacElecDem(runCy,YTIME)$an(YTIME) = i04LoadFactorAdjMxm("MAXLOADSH");
i04TechLftPlaType(runCy,PGALL) = i04DataTechLftPlaType(PGALL, "LFT");
i04TechLftPlaType(runCy,"PGH2F") = 20;
i04GrossCapCosSubRen(runCy,PGALL,YTIME) = i04GrossCapCosSubRen(runCy,PGALL,YTIME)/1000;
loop(runCy,PGALL,YTIME)$AN(YTIME) DO
         abort $(i04GrossCapCosSubRen(runCy,PGALL,YTIME)<0) "CAPITAL COST IS NEGATIVE", i04GrossCapCosSubRen
ENDLOOP;
i04ScaleEndogScrap = 2 / card(PGALL);
i04DecInvPlantSched(runCy,PGALL,YTIME) = i04InvPlants(runCy,PGALL,YTIME);
i04PlantDecomSched(runCy,PGALL,YTIME) = i04DecomPlants(runCy,PGALL,YTIME);
i04MxmShareChpElec(runCy,YTIME) = 0.6;
```

*VARIABLE INITIALISATION*
```
V04ShareTechPG.LO(runCy,PGALL,YTIME)$DATAY(YTIME) = 0;
V04ShareTechPG.UP(runCy,PGALL,YTIME)$DATAY(YTIME) = 1;
V04ScrpRate.UP(runCy,PGALL,YTIME) = 1;
V04ScrpRate.LO(runCy,PGALL,YTIME) = 0;
V04CostVarTech.LO(runCy,PGALL,YTIME) = epsilon6;
V04CostVarTech.L(runCy,PGALL,YTIME) = 0.1;
V04CostVarTech.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (VmRenValue.L(YTIME) * 8.6e-5)$(not (PGREN(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      (VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) +
      imCO2CaptRate(PGALL) * VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-imCO2CaptRate(PGALL)) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME)))
      ) * smTWhToMtoe / imPlantEffByType(runCy,PGALL,YTIME)
    )$(not PGREN(PGALL));
V04CapexRESRate.L(runCy,PGALL,YTIME)=1;
alias(datay, dataylag)
loop (runCy,PGALL,datay,dataylag)$(ord(datay) = ord(dataylag) + 1 and PGREN(PGALL)) DO
  V04NetNewCapElec.FX(runCy,PGALL,datay) = imInstCapPastNonCHP(runCy,PGALL,datay) - imInstCapPastNonCHP(runCy,PGALL,dataylag) + 1E-10;
ENDLOOP;
V04NetNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;
V04CFAvgRen.L(runCy,PGALL,YTIME) = 0.1;
V04CFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = i04AvailRate(runCy,PGALL,YTIME);
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$(DATAY(YTIME)) = (imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL))
          / (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1))
          * i04GrossCapCosSubRen(runCy,PGALL,YTIME) * 1000 * imCGI(runCy,YTIME)
          + i04FixOandMCost(runCy,PGALL,YTIME);
V04CostCapTech.FX(runCy,PGALL,YTIME)$(not AN(YTIME)) = 
V04CapexRESRate.L(runCy,PGALL,YTIME) * V04CapexFixCostPG.L(runCy,PGALL,YTIME) / 
    (i04AvailRate(runCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000); 
V04CostHourProdInvDec.LO(runCy,PGALL,YTIME) = epsilon6;
V04CostHourProdInvDec.L(runCy,PGALL,YTIME) = 0.1;     
V04CostHourProdInvDec.FX(runCy,PGALL,YTIME)$(NOT AN(YTIME)) = 
V04CostCapTech.L(runCy,PGALL,YTIME) + V04CostVarTech.L(runCy,PGALL,YTIME);
VmCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME)) + SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
V04CapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME));
V04CapElecCHP.FX(runCy,YTIME)$(not An(YTIME)) = SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
VmCapElec.L(runCy,PGALL,YTIME) = 1;
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  imInstCapPastNonCHP(runCy,PGALL,YTIME);
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) / i04AvailRate(runCy,PGALL,YTIME);
V04ShareTechPG.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  VmCapElec.L(runCy,PGALL,YTIME) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
V04ShareSatPG.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL) or not AN(YTIME)) = 1;
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
V04IndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants
V04LoadFacDom.L(runCy,YTIME)=0.5;
V04LoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         i04LoadFacElecDem(TRANSE)));
$ifthen.calib %Calibration% == MatCalibration
V04DemElecTot.FX(runCy,YTIME) = t04DemElecTot(runCy,YTIME);
$else.calib
V04DemElecTot.L(runCy,YTIME) = 10;
V04DemElecTot.FX(runCy,YTIME)$DATAY(YTIME) = 
1/smTWhToMtoe * 
(
  sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME)) +
  imDistrLosses(runCy,"ELC",YTIME) +
  i03TotEneBranchCons(runCy,"ELC",YTIME) -
  (imFuelImports(runCy,"ELC",YTIME)- imFuelExprts(runCy,"ELC",YTIME))
);
$endif.calib
VmPeakLoad.L(runCy,YTIME) = 1;
VmPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = V04DemElecTot.L(runCy,YTIME)/(V04LoadFacDom.L(runCy,YTIME)*8.76);
VmProdElec.L(runCy,pgall,YTIME) = 1;
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME) = i04DataElecProdNonCHP(runCy,pgall,YTIME) / 1000;
V04ProdElecEstCHP.FX(runCy,YTIME)$DATAY(YTIME) = SUM(EF,i04DataElecProdCHP(runCy,EF,YTIME)) / 1000;
V04ShareMixWndSol.FX(runCy,YTIME)$DATAY(YTIME) = sum(PGALL$PGRENSW(PGALL), VmCapElec.L(runCy,PGALL,YTIME)) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
V04CCSRetroFit.UP(runCy,PGALL,YTIME) = 1;
V04CCSRetroFit.LO(runCy,PGALL,YTIME) = 0;
V04CCSRetroFit.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) or not NOCCS(PGALL)) = 1;
V04CO2CaptRate.UP(runCy,PGALL,YTIME) = 1;
V04CO2CaptRate.LO(runCy,PGALL,YTIME) = 0;
VmConsFuelElecProd.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VmConsFuelElecProd.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = 
SUM(PGALL$PGALLTOEF(PGALL,PGEF),
  VmProdElec.L(runCy,PGALL,YTIME) * smTWhToMtoe / 
  imPlantEffByType(runCy,PGALL,YTIME)
);
VmConsFuelElecProd.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = -i03InpPGTransfProcess(runCy,PGEF,YTIME);
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


-----------------------------------------------------------------------------------------
            &nbsp;                        Description                  Unit        A   B 
------------------------------- -------------------------------- ---------------- --- ---
              =E=                                                                  x   x 

     i03InpPGTransfProcess                                                             x 
               \                                                                         
         (allCy, EFS,                                                                    
            YTIME)                                                                       

     i03OutPGTransfProcess                                                             x 
               \                                                                         
        (allCy, ELCEF,                                                                   
            YTIME)                                                                       

        i04AvailRate \              Plant availability rate            $1$         x   x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      i04BaseLoadShareDem         Baseload share of demand per         $1$         x   x 
               \                             sector                                      
         (allCy, DSBS,                                                                   
            YTIME)                                                                       

       i04BslCorrection              Parameter of baseload             $1$         x     
               \                           correction                                    
        (allCy, YTIME)                                                                   

     i04CummMnmInstRenCap        Cummulative minimum potential         $GW$        x     
               \                     installed Capacity for                              
            (allCy,                        Renewables                                    
        PGRENEF, YTIME)                                                                  

     i04CummMxmInstRenCap        Cummulative maximum potential         $GW$        x     
               \                     installed Capacity for                              
            (allCy,                        Renewables                                    
        PGRENEF, YTIME)                                                                  

    i04DataElecAndSteamGen        Data releated to electricity                     x     
               \                      and steam generation                               
         (allCy, CHP,                                                                    
            YTIME)                                                                       

        i04DataElecProd           Electricity production past         $GWh$        x     
              \                              years                                       
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      i04DataElecProdCHP           Electricity CHP production         $GWh$            x 
               \                           past years                                    
          (allCy, EF,                                                                    
            YTIME)                                                                       

     i04DataElecProdNonCHP       Electricity Non-CHP production       $GWh$            x 
               \                           past years                                    
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      i04DataElecSteamGen           Various Data related to            $1$         x   x 
               \                     electricity and steam                               
        (allCy, PGOTH,                     generation                                    
            YTIME)                                                                       

     i04DataTechLftPlaType         Data for power generation        $various$      x   x 
               \                             costs                                       
            (PGALL,                                                                      
          PGECONCHAR)                                                                    

      i04DecInvPlantSched           Decided plant investment           $GW$        x   x 
               \                            schedule                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        i04DecomPlants               Decomissioning Plants             $MW$        x   x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        i04FixOandMCost          Fixed O&M Gross Cost per Plant   $US\$2015/KW$    x   x 
              \                               Type                                       
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     i04GrossCapCosSubRen         Gross Capital Cost per Plant    $kUS\$2015/KW$   x   x 
               \                     Type with subsidy for                               
        (allCy, PGALL,                     renewables                                    
            YTIME)                                                                       

        i04InvPlants \                 Investment Plants               $MW$        x   x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

       i04LoadFacElecDem           Load factor of electricity          $1$         x   x 
               \                       demand per sector                                 
            (DSBS)                                                                       

       i04LoadFactorAdj            Parameters for load factor          $1$         x   x 
               \                 adjustment i04BaseLoadShareDem                          
            (DSBS)                                                                       

      i04LoadFactorAdjMxm          Parameter for load factor           $1$         x   x 
               \                           adjustment                                    
       (VARIOUS_LABELS)               i04MxmLoadFacElecDem                               

     i04MatFacPlaAvailCap          Maturity factor related to          $1$         x   x 
               \                    plant available capacity                             
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     i04MatFacPlaAvailCapL         Maturity factor related to          $1$         x   x 
               \                    plant available capacity                             
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      i04MatureFacPlaDisp          Maturity factor related to          $1$         x   x 
               \                       plant dispatching                                 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     i04MatureFacPlaDispL          Maturity factor related to          $1$         x   x 
               \                       plant dispatching                                 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     i04MxmLoadFacElecDem            Maximum load factor of            $1$         x   x 
               \                       electricity demand                                
        (allCy, YTIME)                                                                   

      i04MxmShareChpElec              Maximum share of CHP             $1$         x   x 
                                    electricity in a country                             

        i04PeakBsLoadBy           Peak and Base load for base          $GW$        x     
              \                               year                                       
            (allCy,                                                                      
          PGLOADTYPE)                                                                    

      i04PlantDecomSched          Decided plant decomissioning         $GW$        x   x 
               \                            schedule                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      i04ScaleEndogScrap         Scale parameter for endogenous        $1$         x   x 
               \                  scrapping applied to the sum                           
            (PGALL)                      of full costs                                   

       i04TechLftPlaType          Technical Lifetime per plant        $year$       x   x 
               \                              type                                       
        (allCy, PGALL)                                                                   

      i04TotAvailCapBsYr           Total installed available           $GW$        x     
               \                     capacity in base year                               
            (allCy)                                                                      

     i04UtilRateChpPlants        Utilisation rate of CHP Plants        $1$         x     
               \                                                                         
         (allCy, CHP,                                                                    
            YTIME)                                                                       

         i04VarCost \            Variable gross cost other than   $US\$2015/MWh$   x   x 
        (PGALL, YTIME)                fuel per Plant Type                                

      iTotAvailNomCapBsYr           Total nominal available            $GW$        x   x 
               \                   installed capacity in base                            
        (allCy, YTIME)                        year                                       

        Q04BaseLoad \            Compute electricity base load                     x     
        (allCy, YTIME)                                                                   

        Q04BaseLoadMax           Compute baseload corresponding                    x     
              \                         to maximum load                                  
        (allCy, YTIME)                                                                   

         Q04BsldEst \             Compute estimated base load                      x     
        (allCy, YTIME)                                                                   

         Q04CapElec \            Compute electricity generation                    x   x 
        (allCy, PGALL,                      capacity                                     
            YTIME)                                                                       

        Q04CapElec2 \            Compute electricity generation                    x     
        (allCy, PGALL,                      capacity                                     
            YTIME)                                                                       

        Q04CapElecCHP \          Compute CHP electric capacity                     x   x 
        (allCy, YTIME)                                                                   

       Q04CapElecNominal          Compute nominal electricity                      x   x 
               \                      generation capacity                                
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

       Q04CapElecNonCHP            Compute total electricity                       x   x 
               \                 generation capacity excluding                           
        (allCy, YTIME)                     CHP plants                                    

       Q04CapElecTotEst             Compute Estimated total                        x   x 
               \                     electricity generation                              
        (allCy, YTIME)                      capacity                                     

       Q04CapexFixCostPG          Computes the capex and fixed                         x 
               \                 costs of any power generation                           
        (allCy, PGALL,                     technology                                    
            YTIME)                                                                       

        Q04CapexRESRate          Estimates a multiplying factor                        x 
              \                  expressing the extra grid and                           
        (allCy, PGALL,               storage costs for RES                               
            YTIME)                implementation according to                            
                                   the RES penetration in the                            
                                            mixture                                      

        Q04CapOverall \             Compute overall capacity                       x   x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04CCSRetroFit                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04CFAvgRen \             Compute the average capacity                     x   x 
        (allCy, PGALL,                   factor of RES                                   
            YTIME)                                                                       

        Q04CO2CaptRate                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04ConsElec \                 Compute electricity                          x     
         (allCy, DSBS,            consumption per final demand                           
            YTIME)                           sector                                      

      Q04ConsFuelElecProd                                                              x 
               \                                                                         
         (allCy, EFS,                                                                    
            YTIME)                                                                       

 Q04CostAvgPowGenLonNoClimPol      Compute long term average                       x     
               \                     power generation cost                               
        (allCy, PGALL,             excluding climate policies                            
         ESET, YTIME)                                                                    

        Q04CostCapTech                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     Q04CostHourProdInvDec       Compute hourly production cost                    x   x 
               \                  used in investment decisions                           
        (allCy, PGALL,                                                                   
         HOUR, YTIME)                                                                    

  Q04CostHourProdInvDecNoCCS     Compute hourly production cost                    x     
               \                  used in investment decisions                           
        (allCy, PGALL,                                                                   
         HOUR, YTIME)                                                                    

      Q04CostPowGenAvgLng           Compute long term power                        x   x 
               \                        generation cost                                  
         (allCy, ESET,                                                                   
            YTIME)                                                                       

   Q04CostPowGenLngTechNoCp         Compute long term power                        x     
               \                       generation cost of                                
        (allCy, PGALL,           technologies excluding climate                          
         ESET, YTIME)                       policies                                     

   Q04CostPowGenLonNoClimPol        Compute long term power                        x     
               \                   generation cost excluding                             
         (allCy, ESET,                  climate policies                                 
            YTIME)                                                                       

      Q04CostProdSpecTech         Compute production cost used                     x     
               \                    in investment decisions                              
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

   Q04CostProdTeCHPreReplac        Compute production cost of                      x     
               \                  technology used in premature                           
        (allCy, PGALL,                    replacement                                    
            YTIME)                                                                       

 Q04CostProdTeCHPreReplacAvail     Compute production cost of                      x     
               \                  technology used in premature                           
        (allCy, PGALL,            replacement including plant                            
        PGALL2, YTIME)                 availability rate                                 

        Q04CostVarTech              Compute variable cost of                       x   x 
              \                            technology                                    
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      Q04CostVarTechElec            Compute variable cost of                       x     
               \                           technology                                    
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     Q04CostVarTechElecTot       Compute Electricity peak loads                    x     
               \                                                                         
        (allCy, YTIME)                                                                   

    Q04CostVarTechNotPGSCRN         Compute variable cost of                       x     
               \                  technology excluding PGSCRN                            
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04DemElecTot \            Compute total electricity          $TWh$        x   x 
        (allCy, YTIME)                       demand                                      

     Q04GapGenCapPowerDiff          Compute the gap in power                       x   x 
               \                      generation capacity                                
        (allCy, YTIME)                                                                   

       Q04IndxEndogScrap          Compute endogenous scrapping                     x   x 
               \                             index                                       
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

         Q04Lambda \                Compute Lambda parameter                       x     
        (allCy, YTIME)                                                                   

        Q04LoadFacDom \             Compute electricity load                       x   x 
        (allCy, YTIME)             factor for entire domestic                            
                                             system                                      

       Q04NetNewCapElec          Compute the yearly difference                     x   x 
               \                     in installed capacity                               
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04NewCapElec \          Compute the new capacity added                    x   x 
        (allCy, PGALL,                     every year                                    
            YTIME)                                                                       

        Q04NewInvElec \           Compute for Power Plant new                      x     
        (allCy, YTIME)                investment decision                                

        Q04PeakLoad \            Compute elerctricity peak load                    x   x 
        (allCy, YTIME)                                                                   

        Q04ProdElec \            Compute electricity production                    x   x 
        (allCy, PGALL,            from power generation plants                           
            YTIME)                                                                       

        Q04ProdElecCHP              Compute CHP electricity           $TWh$        x     
              \                            production                                    
        (allCy, YTIME)                                                                   

       Q04ProdElecEstCHP          Estimate the electricity of                      x   x 
               \                           CHP Plants                                    
        (allCy, YTIME)                                                                   

       Q04ProdElecNonCHP          Compute non CHP electricity                      x     
               \                           production                                    
        (allCy, YTIME)                                                                   

       Q04ProdElecReqCHP          Compute total estimated CHP                      x     
               \                     electricity production                              
        (allCy, YTIME)                                                                   

       Q04ProdElecReqTot             Compute total required           $TWh$        x     
               \                     electricity production                              
        (allCy, YTIME)                                                                   

       Q04RenTechMatMult         Compute renewable technologies                    x     
               \                      maturity multiplier                                
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     Q04RenTechMatMultExpr       Renewable power capacity over         $1$         x     
               \                           potential                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

    Q04ScalFacPlantDispatch      Compute the scaling factor for                    x     
               \                       plant dispatching                                 
         (allCy, HOUR,                                                                   
            YTIME)                                                                       

       Q04ScalWeibullSum          Compute sum (over hours) of                      x     
               \                       temporary variable                                
        (allCy, PGALL,            facilitating the scaling in                            
            YTIME)                      Weibull equation                                 

        Q04ScrpRate \                                                                  x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

         Q04SensCCS \             Compute gamma parameter used                     x     
        (allCy, YTIME)            in CCS/No CCS decision tree                            

       Q04ShareMixWndSol         Computes the participation of         $\%$            x 
               \                  solar and wind in the energy                           
        (allCy, YTIME)                      mixture                                      

      Q04ShareNewTechCCS                 Compute SHRCAP                            x     
               \                                                                         
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     Q04ShareNewTechNoCCS         Compute SHRCAP excluding CCs                     x     
               \                                                                         
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      Q04SharePowPlaNewEq        Compute the power plant share                     x   x 
               \                        in new equipment                                 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        Q04ShareSatPG \             Saturation mechanism for                           x 
        (allCy, PGALL,                electricity mixture                                
            YTIME)                     penetration of RES                                
                                          technologies                                   

        Q04ShareTechPG            Share of all technologies in                         x 
              \                     the electricity mixture                              
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     Q04SortPlantDispatch         Compute Power plants sorting                     x     
               \                 according to variable cost to                           
        (allCy, PGALL,            decide the plant dispatching                           
            YTIME)                                                                       

       S04CapexBessRate          The power expressing the rate                         x 
                                 of the increase in the solar &                          
                                 wind CAPEX because of storage                           
                                     need and grid upgrade                               

        t04DemElecTot \          Secondary energy electricity -       $TWh$            x 
        (allCy, YTIME)                   target demand                                   

      t04SharePowPlaNewEq        Ratio of newly added capacity                         x 
               \                  smoothed over 10-year period                           
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04BaseLoadMax             Baseload corresponding to           $1$         x     
              \                       Maximum Load Factor                                
        (allCy, YTIME)                                                                   

         V04BsldEst \                 Estimated base load              $GW$        x     
        (allCy, YTIME)                                                                   

        V04CapElec2 \            Electricity generation plants         $GW$        x     
        (allCy, PGALL,                      capacity                                     
            YTIME)                                                                       

        V04CapElecCHP \              Capacity of CHP Plants            $GW$        x   x 
        (allCy, YTIME)                                                                   

       V04CapElecNominal         Nominal electricity generation        $GW$        x   x 
               \                        plants capacity                                  
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

       V04CapElecNonCHP           Total electricity generation         $GW$        x   x 
               \                     capacity excluding CHP                              
        (allCy, YTIME)                                                                   

       V04CapexFixCostPG          CAPEX and fixed costs of any    $US\$2015/kW$        x 
               \                  power generation technology                            
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04CapexRESRate          Multiplying factor expressing                         x 
              \                    the extra grid and storage                            
        (allCy, PGALL,            costs for RES implementation                           
            YTIME)                    according to the RES                               
                                   penetration in the mixture                            

        V04CapOverall \                 Overall Capacity               $MW$        x   x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04CCSRetroFit                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04CFAvgRen \            The average capacity factor of        $1$         x   x 
        (allCy, PGALL,                        RES                                        
            YTIME)                                                                       

        V04CO2CaptRate                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04ConsElec \             Electricity demand per final        $Mtoe$       x     
         (allCy, DSBS,                       sector                                      
            YTIME)                                                                       

 V04CostAvgPowGenLonNoClimPol       Long-term average power                        x     
               \                   generation cost excluding                             
        (allCy, PGALL,           climate policies(US$2015/kWh)                           
         ESET, YTIME)                                                                    

        V04CostCapTech                                                                 x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     V04CostHourProdInvDec         Hourly production cost of      $US\$2015/KWh$   x   x 
               \                           technology                                    
        (allCy, PGALL,                                                                   
         HOUR, YTIME)                                                                    

  V04CostHourProdInvDecNoCCS       Hourly production cost of      $US\$2015/KWh$   x     
               \                           technology                                    
        (allCy, PGALL,                                                                   
         HOUR, YTIME)                                                                    

   V04CostPowGenLngTechNoCp         Long-term average power       $US\$2015/kWh$   x     
               \                        generation cost                                  
        (allCy, PGALL,                                                                   
         ESET, YTIME)                                                                    

   V04CostPowGenLonNoClimPol        Long-term average power       $US\$2015/kWh$   x     
               \                   generation cost excluding                             
         (allCy, ESET,                  climate policies                                 
            YTIME)                                                                       

      V04CostProdSpecTech        Production cost of technology    $US\$2015/KWh$   x     
               \                                                                         
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

   V04CostProdTeCHPreReplac      Production cost of technology    $US\$2015/KWh$   x     
               \                 used in premature replacement                           
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

 V04CostProdTeCHPreReplacAvail   Production cost of technology    $US\$2015/KWh$   x     
               \                 used in premature replacement                           
        (allCy, PGALL,            including plant availability                           
        PGALL2, YTIME)                        rate                                       

        V04CostVarTech            Variable cost of technology     $US\$2015/KWh$   x   x 
              \                                                                          
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      V04CostVarTechElec          Variable cost of technology     $US\$2015/KWh$   x     
               \                                                                         
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     V04CostVarTechElecTot           Electricity peak loads            $GW$        x     
               \                                                                         
        (allCy, YTIME)                                                                   

    V04CostVarTechNotPGSCRN       Variable cost of technology     $US\$2015/KWh$   x     
               \                        excluding PGSCRN                                 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04DemElecTot \             Total electricity demand          $TWh$        x   x 
        (allCy, YTIME)                                                                   

     V04GapGenCapPowerDiff          Gap in total generation            $GW$        x   x 
               \                  capacity to be filled by new                           
        (allCy, YTIME)                     equipment                                     

       V04IndxEndogScrap           Index used for endogenous           $1$         x   x 
               \                     power plants scrapping                              
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

         V04Lambda \                Parameter for load curve           $1$         x     
        (allCy, YTIME)                    construction                                   

        V04LoadFacDom \           Electricity load factor for                      x   x 
        (allCy, YTIME)               entire domestic system                              

       V04NetNewCapElec          Yearly difference in installed        $MW$        x   x 
               \                            capacity                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04NewCapElec \           The new capacity added every         $MW$        x   x 
        (allCy, PGALL,                        year                                       
            YTIME)                                                                       

        V04NewInvElec \           Power plant sorting for new          $1$         x     
        (allCy, YTIME)           investment decision according                           
                                         to total cost                                   

        V04ProdElecCHP             CHP electricity production         $TWh$        x     
              \                                                                          
        (allCy, YTIME)                                                                   

       V04ProdElecEstCHP          Estimate the electricity of          $1$         x   x 
               \                           CHP Plants                                    
        (allCy, YTIME)                                                                   

       V04ProdElecNonCHP           Non CHP total electricity          $TWh$        x     
               \                           production                                    
        (allCy, YTIME)                                                                   

       V04ProdElecReqCHP              Total estimated CHP             $TWh$        x     
               \                     electricity production                              
        (allCy, YTIME)                                                                   

       V04ProdElecReqTot           Total required electricity         $TWh$        x     
               \                           production                                    
        (allCy, YTIME)                                                                   

       V04RenTechMatMult             Renewable technologies            $1$         x     
               \                      maturity multiplier                                
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     V04RenTechMatMultExpr       Renewable power capacity over         $1$         x     
               \                           potential                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

       V04ScalFacPlaDisp            Scaling factor for plant                       x     
               \                         dispatching	(1)                                  
         (allCy, HOUR,                                                                   
            YTIME)                                                                       

       V04ScalWeibullSum         Sum (over hours) of temporary         $1$         x     
               \                   variable facilitating the                             
        (allCy, PGALL,            scaling in Weibull equation                            
            YTIME)                                                                       

        V04ScrpRate \                                                                  x 
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

         V04SensCCS \             Variable that controlls the          $1$         x     
        (allCy, YTIME)           sensitivity of CCS acceptance                           

       V04ShareMixWndSol         The participation of solar and                        x 
               \                 wind in the energy mixture(%)                           
        (allCy, YTIME)                                                                   

      V04ShareNewTechCCS            Power plant share in new           $1$         x     
               \                           equipment                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     V04ShareNewTechNoCCS           Power plant share in new           $1$         x     
               \                           equipment                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

      V04SharePowPlaNewEq           Power plant share in new           $1$         x   x 
               \                           equipment                                     
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

        V04ShareSatPG \            Saturation for electricity                          x 
        (allCy, PGALL,             mixture penetration of RES                            
            YTIME)                        technologies                                   

        V04ShareTechPG            Share of all technologies in                         x 
              \                     the electricity mixture                              
        (allCy, PGALL,                                                                   
            YTIME)                                                                       

     V04SortPlantDispatch        Power plants sorting according        $1$         x   x 
               \                 to variable cost to decide the                          
        (allCy, PGALL,                 plant dispatching                                 
            YTIME)                                                                       

         VmBaseLoad \                 Corrected base load              $GW$        x     
        (allCy, YTIME)                                                                   
-----------------------------------------------------------------------------------------

Table: module-internal objects (A: legacy | B: simple)



### Sets


----------------------------------------------------
      &nbsp;                  description           
------------------- --------------------------------
     alias(TT,                                      
      ytime)                                        

       allCy           All Countries Used in the    
                                 Model              

     an(ytime)        Years for which the model is  
                                running             

 CCS_NOCCS(PGALL,               mapping             
      PGALL)                                        

    CCS(PGALL)        Plants which can be equipped  
                                with CCS            

   datay(ytime)       Historical years before the   
                        start year of the model     

     DSBS(SBS)           All Demand Subsectors      

        EF                    Energy Forms          

      EFS(EF)         Energy Forms used in Supply   
                                  Side              

     ELCEF(EF)                Electricity           

        HOU                11.511 0.9 0.00001       

       hour           Segments of hours in a year   
                          (250,1250,...,8250)       

   INDDOM(DSBS)          Industry and Tertiary      

 NAP(Policies_set)      National Allocation Plan    
                           sector categories        

 NAPtoALLSBS(NAP,     Energy sectors corresponding  
      ALLSBS)                to NAP sectors         

    NENSE(DSBS)          Non Energy and Bunkers     

   NOCCS(PGALL)       Plants which can be equipped  
                       with CCS but they are not    

   period(ytime)     Model can also run for periods 
                                of years            

       PGALL          Power Generation Plant Types  

 PGALLtoEF(PGALL,    Correspondence between plants  
       EFS)                 and energy forms        

    PGECONCHAR            Technical - economic      
                       characteristics for power    
                           generation plants        

     PGEF(EFS)        Energy forms used for steam   
                               production           

 PGLOADTYPE(PGOTH)    Peak and Base load of total   
                        electricity demand in GW    

       PGOTH         Various data related to power  
                           generation plants        

   PGREN(PGALL)        REN PLANTS with Saturation   

   PGREN2(PGALL)            Renewable Plants        

      PGRENEF          Renewable energy forms in    
                            power generation        

  PGRENSW(PGALL)         Solar and wind Plants      

   PGSCRN(PGALL)         New plants involved in     
                      endogenous scrapping (these   
                        plants are not scrapped)    

   runCy(allCy)      Countries for which the model  
                               is running           

   runCyL(allCy)     Countries for which the model  
                     is running (used in countries  
                                 loop)              

    SBS(ALLSBS)             Model Subsectors        

    time(ytime)        Model time horizon used in   
                          equation definitions      

    TOCTEF(EFS)      Energy forms produced by power 
                           plants and boilers       

   TRANSE(DSBS)         All Transport Subsectors    

  VARIOUS_LABELS                                    

       ytime               Model time horizon       
----------------------------------------------------

Table: sets in use



See Also
--------

[01_Transport], [02_Industry], [03_RestOfEnergy], [05_Hydrogen], [06_CO2], [08_Prices], [core]

