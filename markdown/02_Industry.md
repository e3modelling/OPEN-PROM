Industry module (02_Industry) {#id-02_Industry}
=============================

Description
-----------

This is the Industry module.


Interfaces
----------

**Interface plot missing!**

### Input


-----------------------------------------------------------------------------------
         &nbsp;                     Description                  Unit        A   B 
------------------------- -------------------------------- ---------------- --- ---
       VmCarVal \              Carbon prices for all         $US\$2015/tn    x   x 
      (allCy, NAP,                   countries                   CO2$              
         YTIME)                                                                    

     VmCstCO2SeqCsts             Cost curve for CO2          $US\$2015/tn        x 
           \                    sequestration costs               of               
     (allCy, YTIME)                                              CO2               
                                                            sequestrated$          

    VmElecConsHeatPla         Electricity consumed in           $Mtoe$       x   x 
            \                     heatpump plants                                  
      (allCy, DSBS,                                                                
         YTIME)                                                                    

        VmLft \               Lifetime of technologies         $years$       x   x 
      (allCy, DSBS,                                                                
      TECH, YTIME)                                                                 

     VmPriceElecInd        Electricity index - a function        $1$         x   x 
           \                     of industry price                                 
     (allCy, YTIME)                                                                

    VmPriceFuelAvgSub         Average fuel prices per       $k\$2015/toe$    x   x 
            \                        subsector                                     
      (allCy, DSBS,                                                                
         YTIME)                                                                    

 VmPriceFuelSubsecCarVal   Fuel prices per subsector and    $k\$2015/toe$    x   x 
            \                           fuel                                       
      (allCy, SBS,                                                                 
       EF, YTIME)                                                                  

      VmRenValue \                Renewable value           $US\$2015/KWh$       x 
         (YTIME)                                                                   
-----------------------------------------------------------------------------------

Table: module inputs (A: legacy | B: technology)



### Output


-----------------------------------------------------------------------
       &nbsp;                   Description                  Unit      
--------------------- -------------------------------- ----------------
    VmConsFuel \        Consumption of fuels in each        $Mtoe$     
    (allCy, DSBS,       demand subsector, excluding                    
     EF, YTIME)             heat from heatpumps                        

 VmCostElcAvgProdCHP   Average Electricity production   $US\$2015/KWh$ 
          \                  cost per CHP plant                        
    (allCy, CHP,                                                       
       YTIME)                                                          
-----------------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the Industry module.


```
Equations
```
***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
```
Q02IndxElecIndPrices(allCy,YTIME)                          "Compute Electricity index - a function of industry price - Estimate"
Q02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Compute electricity production cost per CHP plant and demand sector"
Q02CostTech(allCy,DSBS,rCon,EF,YTIME)                      "Compute technology cost"
Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME)                 "Compute intermediate technology cost"
Q02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                "Compute the technology cost including the maturity factor per technology and subsector"
Q02SortTechVarCost(allCy,DSBS,rCon,YTIME)                  "Compute Technology sorting based on variable cost"
Q02GapFinalDem(allCy,DSBS,YTIME)                           "Compute the gap in final demand of industry, tertiary, non-energy uses and bunkers"
Q02ShareTechNewEquip(allCy,DSBS,EF,YTIME)                  "Compute technology share in new equipment"
```
**Interdependent Equations**
```
Q02ConsFuel(allCy,DSBS,EF,YTIME)                           "Compute fuel consumption"
Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME)	           "Compute non-substituable electricity consumption in Industry and Tertiary"
Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME)                   "Compute total final demand (of substitutable fuels) per subsector"
Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME)                     "Equation for fuel consumption in Mtoe (including heat from heatpumps)"
Q02ConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)	           "Equation for consumption of remaining substitutble equipment"
Q02CostElcAvgProdCHP(allCy,CHP,YTIME)                      "Compute Average Electricity production cost per CHP plant"
;
Variables
```
***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
```
V02IndxElecIndPrices(allCy,YTIME)                          "Electricity index - a function of industry price - Estimate (1)"
V02CostElecProdCHP(allCy,DSBS,CHP,YTIME)                   "Electricity production cost per CHP plant and demand sector (US$2015/KWh)"
V02CostTech(allCy,DSBS,rCon,EF,YTIME)                      "Technology cost (KUS$2015/toe)"
V02CostTechIntrm(allCy,DSBS,rcon,EF,YTIME)                 "Intermediate technology cost (KUS$2015/toe)"
V02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME)                "Technology cost including maturity factor (KUS$2015/toe)"
V02SortTechVarCost(allCy,DSBS,rCon,YTIME)                  "Technology sorting based on variable cost (1)"
V02GapFinalDem(allCy,DSBS,YTIME)                           "Final demand gap to be filed by new technologies (Mtoe)"
V02ShareTechNewEquip(allCy,DSBS,EF,YTIME)                  "Technology share in new equipment (1)"
V02CostProdCHPDem(allCy,DSBS,CHP,YTIME)                    "Variable including fuel electricity production cost per CHP plant and demand sector (US$2015/KWh)"
```
**Interdependent Variables**
```
VmConsFuel(allCy,DSBS,EF,YTIME)                            "Consumption of fuels in each demand subsector, excluding heat from heatpumps (Mtoe)"
VmConsElecNonSubIndTert(allCy,DSBS,YTIME)                  "Consumption of non-substituable electricity in Industry and Tertiary (Mtoe)"
VmDemFinSubFuelSubsec(allCy,DSBS,YTIME)                    "Total final demand (of substitutable fuels) per subsector (Mtoe)"
VmConsFuelInclHP(allCy,DSBS,EF,YTIME)                      "Consumption of fuels in each demand subsector including heat from heatpumps (Mtoe)"
VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)               "Consumption of remaining substitutable equipment (Mtoe)"
VmCostElcAvgProdCHP(allCy,CHP,YTIME)                       "Average Electricity production cost per CHP plant (US$2015/KWh)"
VmCostVarAvgElecProd(allCy,CHP,YTIME)                      "Average variable including fuel electricity production cost per CHP plant (US$2015/KWh)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
This equation computes the consumption/demand of non-substitutable electricity for subsectors of INDUSTRY and DOMESTIC in the "typical useful energy demand equation".
The main explanatory variables are activity indicators of each subsector and electricity prices per subsector. Corresponding elasticities are applied for activity indicators
and electricity prices.
```
Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsElecNonSubIndTert(allCy,INDDOM,YTIME)
              =E=
    [
      VmConsElecNonSubIndTert(allCy,INDDOM,YTIME-1) * 
      imActv(YTIME,allCy,INDDOM) ** i02ElastNonSubElec(allCy,INDDOM,"a",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1))**i02ElastNonSubElec(allCy,INDDOM,"b1",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-2))**i02ElastNonSubElec(allCy,INDDOM,"b2",YTIME) *
      prod(KPDL,
        (
          VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-ord(KPDL)) /
          VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))
        )**(i02ElastNonSubElec(allCy,INDDOM,"c",YTIME)*imFPDL(INDDOM,KPDL))
      )      
    ]$imActv(YTIME-1,allCy,INDDOM)+0;
```
This equation determines the consumption of the remaining substitutable equipment of each energy form per each demand subsector (excluding TRANSPORT).
The "remaining" equipment is computed based on the past value of consumption (energy form, subsector) and the lifetime of the technology (energy form) for each subsector.  
For the electricity energy form, the non substitutable consumption is subtracted.
This equation expresses the "typical useful energy demand equation" where the main explanatory variables are activity indicators and fuel prices.
```
Q02ConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $runCy(allCy))..
    VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)
          =E=
    [
      (VmLft(allCy,DSBS,EF,YTIME)-1) / VmLft(allCy,DSBS,EF,YTIME) *
      (
        VmConsFuelInclHP(allCy,DSBS,EF,YTIME-1) -
        VmConsElecNonSubIndTert(allCy,DSBS,YTIME-1)$(ELCEF(EF)$INDDOM(DSBS))
      ) *
      imActv(YTIME,allCy,DSBS) ** imElastA(allCy,DSBS,"a",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) / VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1)) ** imElastA(allCy,DSBS,"b1",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1) / VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-2)) ** imElastA(allCy,DSBS,"b2",YTIME) *
      prod(KPDL,
        (
          VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-ord(KPDL)) /
          VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-(ord(KPDL)+1))
        ) ** (imElastA(allCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
      )  
    ]$(imActv(YTIME-1,allCy,DSBS));
```
This equation computes the useful energy demand in each demand subsector (excluding TRANSPORT). This demand is potentially "satisfied" by multiple energy forms/fuels (substitutable demand).
The equation follows the "typical useful energy demand" format where the main explanatory variables are activity indicators and average "weighted" fuel prices.
```
Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $runCy(allCy))..
      VmDemFinSubFuelSubsec(allCy,DSBS,YTIME)
            =E=
      [
      VmDemFinSubFuelSubsec(allCy,DSBS,YTIME-1)
      * imActv(YTIME,allCy,DSBS)**imElastA(allCy,DSBS,"a",YTIME)
      * (VmPriceFuelAvgSub(allCy,DSBS,YTIME)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-1))**imElastA(allCy,DSBS,"b1",YTIME)
      * (VmPriceFuelAvgSub(allCy,DSBS,YTIME-1)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-2))**imElastA(allCy,DSBS,"b2",YTIME)
      * prod(KPDL,
              ( (VmPriceFuelAvgSub(allCy,DSBS,YTIME-ord(KPDL))/VmPriceFuelAvgSub(allCy,DSBS,YTIME-(ord(KPDL)+1)))/(imCGI(allCy,YTIME)**(1/6))
              )**( imElastA(allCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
            )  ]$imActv(YTIME-1,allCy,DSBS)+0
;
```
This equation calculates the total consumption of electricity in industrial sectors. The consumption is obtained by summing up the electricity
consumption in each industrial subsector, excluding substitutable electricity. This equation provides an aggregate measure of electricity consumption
in the industrial sectors, considering only non-substitutable electricity.
```
$ontext
q02ConsTotElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         vmConsTotElecInd(allCy,YTIME)
         =E=
         SUM(INDSE,VmConsElecNonSubIndTert(allCy,INDSE,YTIME));       
$offtext
```
This equation calculates the total final demand for substitutable fuels in industrial sectors. The total demand is obtained by summing up the
final demand for substitutable fuels across various industrial subsectors. This equation provides a comprehensive view of the total demand for
substitutable fuels within the industrial sectors, aggregated across individual subsectors.
```
$ontext
q02DemFinSubFuelInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        vmDemFinSubFuelInd(allCy,YTIME)=E= SUM(INDSE,VmDemFinSubFuelSubsec(allCy,INDSE,YTIME));
$offtext
```
This equation calculates the total fuel consumption in each demand subsector, excluding heat from heat pumps. The fuel consumption is measured
in million tons of oil equivalent and is influenced by two main components: the consumption of fuels in each demand subsector, including
heat from heat pumps, and the electricity consumed in heat pump plants.The equation uses the fuel consumption data for each demand subsector,
considering both cases with and without heat pump influence. When heat pumps are involved, the electricity consumed in these plants is also
taken into account. The result is the total fuel consumption in each demand subsector, providing a comprehensive measure of the energy consumption pattern.
This equation offers a comprehensive view of fuel consumption, considering both traditional fuel sources and the additional electricity consumption
associated with heat pump plants.
```
Q02ConsFuel(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $runCy(allCy))..
      VmConsFuel(allCy,DSBS,EF,YTIME)
            =E=
      VmConsFuelInclHP(allCy,DSBS,EF,YTIME) + 
      VmElecConsHeatPla(allCy,DSBS,YTIME)$ELCEF(EF);
```
This equation calculates the estimated electricity index of the industry price for a given year. The estimated index is derived by considering the historical
trend of the electricity index, with a focus on the fuel prices in the industrial subsector. The equation utilizes the fuel prices for electricity generation,
both in the current and past years, and computes a weighted average based on the historical pattern. The estimated electricity index is influenced by the ratio
of fuel prices in the current and previous years, with a power of 0.3 applied to each ratio. This weighting factor introduces a gradual adjustment to reflect the
historical changes in fuel prices, providing a more dynamic estimation of the electricity index. This equation provides a method to estimate the electricity index
based on historical fuel price trends, allowing for a more flexible and responsive representation of industry price dynamics.
```
Q02IndxElecIndPrices(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V02IndxElecIndPrices(allCy,YTIME)
              =E=
      VmPriceElecInd(allCy,YTIME-1) * 
      (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)/VmPriceFuelAvgSub(allCy,"OI",YTIME-1)) ** (0.1) *
      (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-2)/VmPriceFuelAvgSub(allCy,"OI",YTIME-2)) ** (0.05) *
      (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-3)/VmPriceFuelAvgSub(allCy,"OI",YTIME-3)) ** (0.05)
      ;
```
The equation computes the electricity production cost per Combined Heat and Power plant for a specific demand sector within a given subsector.
The cost is determined based on various factors, including the discount rate, technical lifetime of CHP plants, capital cost (EUR/kW), fixed O&M cost (EUR/kW), availability rate,
variable cost(EUR/MWh), and fuel-related costs. The equation provides a comprehensive assessment of the overall expenses associated with electricity production from CHP
plants, considering both the fixed and variable components, as well as factors such as carbon prices and CO2 emission factors.
The resulting variable represents the electricity production cost per CHP plant and demand sector, expressed in Euro per kilowatt-hour (Euro/KWh).
```
Q02CostElecProdCHP(allCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
        V02CostElecProdCHP(allCy,DSBS,CHP,YTIME)
              =E=
        ( ( imDisc(allCy,"PG",YTIME) * exp(imDisc(allCy,"PG",YTIME)*i02LifChpPla(allCy,DSBS,CHP))
            / (exp(imDisc(allCy,"PG",YTIME)*i02LifChpPla(allCy,DSBS,CHP)) -1))
          * i02InvCostChp(allCy,DSBS,CHP,YTIME) * imCGI(allCy,YTIME)  + i02FixOMCostPerChp(allCy,DSBS,CHP,YTIME)
        )/(i02AvailRateChp(allCy,DSBS,CHP)*(smGwToTwhPerYear(YTIME)))/1000
        + i02VarCostChp(allCy,DSBS,CHP,YTIME)/1000
        + sum(PGEF$CHPtoEF(CHP,PGEF), (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+0.001*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
              (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
              * smTWhToMtoe /  (i02BoiEffChp(allCy,CHP,YTIME) * (VmPriceElecInd(allCy,YTIME)) + 1e-4));        
```
The equation calculates the technology cost for each technology, energy form, and consumer size group within the specified subsector.
This cost estimation is based on an intermediate technology cost and the elasticity parameter associated with the given subsector.
The intermediate technology cost is raised to the power of the elasticity parameter to determine the final technology cost. The equation
provides a comprehensive assessment of the overall expenses associated with different technologies in the given subsector and consumer size group.
```
Q02CostTech(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))$(not DSBS("DAC")) $(ord(rCon) le imNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
        V02CostTech(allCy,DSBS,rCon,EF,YTIME) 
              =E= 
        V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME)**(-i02ElaSub(allCy,DSBS)) ;   
```
The equation computes the intermediate technology cost, including the lifetime factor, for each technology, energy form, and consumer size group
within the specified subsector. This cost estimation plays a crucial role in evaluating the overall expenses associated with adopting and implementing
various technologies in the given subsector and consumer size group. The equation encompasses diverse parameters, such as discount rates, lifetime of 
technologies, capital costs, fixed operation and maintenance costs, fuel prices, annual consumption rates, the number of consumers, the capital goods 
index, and useful energy conversion factors.
```
Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le imNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
    V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) 
        =E=
    ( (( (imDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + imDisc(allCy,"PG",YTIME)$CHP(EF)) !! in case of chp plants we use the discount rate of power generation sector
          * exp((imDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + imDisc(allCy,"PG",YTIME)$CHP(EF))*VmLft(allCy,DSBS,EF,YTIME))
        )
        / (exp((imDisc(allCy,DSBS,YTIME)$(not CHP(EF)) + imDisc(allCy,"PG",YTIME)$CHP(EF))*VmLft(allCy,DSBS,EF,YTIME))- 1)
      ) * imCapCostTech(allCy,DSBS,EF,YTIME) * imCGI(allCy,YTIME)
      +
      imFixOMCostTech(allCy,DSBS,EF,YTIME)/1000
      +
      VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
      * imAnnCons(allCy,DSBS,"smallest") * (imAnnCons(allCy,DSBS,"largest")/imAnnCons(allCy,DSBS,"smallest"))**((ord(rCon)-1)/imNcon(DSBS))
    )$INDDOM(DSBS)
    +
    ( (( imDisc(allCy,DSBS,YTIME)
          * exp(imDisc(allCy,DSBS,YTIME)*VmLft(allCy,DSBS,EF,YTIME))
        )
        / (exp(imDisc(allCy,DSBS,YTIME)*VmLft(allCy,DSBS,EF,YTIME))- 1)
      ) * imCapCostTech(allCy,DSBS,EF,YTIME) * imCGI(allCy,YTIME)
      +
      imFixOMCostTech(allCy,DSBS,EF,YTIME)/1000
      +
      (
        (VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)
      )
      * imAnnCons(allCy,DSBS,"smallest") * (imAnnCons(allCy,DSBS,"largest")/imAnnCons(allCy,DSBS,"smallest"))**((ord(rCon)-1)/imNcon(DSBS))
    )$NENSE(DSBS);  
```
This equation calculates the technology cost, including the maturity factor , for each energy form  and technology  within
the specified subsector and consumer size group . The cost is determined by multiplying the maturity factor with the
technology cost based on the given parameters.
```
Q02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le imNcon(DSBS)+1) $SECTTECH(DSBS,EF) $runCy(allCy))..
        V02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME) 
            =E=
        imMatrFactor(allCy,DSBS,EF,YTIME) * V02CostTech(allCy,DSBS,rCon,EF,YTIME) ;
```
This equation calculates the technology sorting based on variable cost . It is determined by summing the technology cost,
including the maturity factor , for each energy form and technology within the specified subsector 
and consumer size group. The sorting is conducted based on variable cost considerations.
```
Q02SortTechVarCost(allCy,DSBS,rCon,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le imNcon(DSBS)+1) $runCy(allCy))..
        V02SortTechVarCost(allCy,DSBS,rCon,YTIME)
            =E=
        sum((EF)$(SECTTECH(DSBS,EF) ),V02CostTechMatFac(allCy,DSBS,rCon,EF,YTIME));
```
This equation calculates the gap in final demand for industry, tertiary, non-energy uses, and bunkers.
It is determined by subtracting the total final demand per subsector from the consumption of
remaining substitutable equipment. The square root term is included to ensure a non-negative result.
```
Q02GapFinalDem(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $runCy(allCy))..
         V02GapFinalDem(allCy,DSBS,YTIME)
                =E=
         (
          VmDemFinSubFuelSubsec(allCy,DSBS,YTIME) - 
          sum(EF$SECTTECH(DSBS,EF), VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)) +
          SQRT( SQR(VmDemFinSubFuelSubsec(allCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME))))
         ) /2
         + 1e-8;
```
This equation calculates the technology share in new equipment based on factors such as maturity factor,
cumulative distribution function of consumer size groups, number of consumers, technology cost, distribution function of consumer
size groups, and technology sorting.
```
Q02ShareTechNewEquip(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS))$(not DSBS("DAC")) $runCy(allCy))..
         V02ShareTechNewEquip(allCy,DSBS,EF,YTIME) =E=
         imMatrFactor(allCy,DSBS,EF,YTIME) / imCumDistrFuncConsSize(allCy,DSBS) *
         sum(rCon$(ord(rCon) le imNcon(DSBS)+1),
                  V02CostTech(allCy,DSBS,rCon,EF,YTIME)
                  * imDisFunConSize(allCy,DSBS,rCon)/V02SortTechVarCost(allCy,DSBS,rCon,YTIME));
```
This equation calculates the consumption of fuels in each demand subsector, including heat from heat pumps .
It considers the consumption of remaining substitutable equipment, the technology share in new equipment, and the final demand
gap to be filled by new technologies. Additionally, non-substitutable electricity consumption in Industry and Tertiary sectors is included.
```
Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $runCy(allCy))..
         VmConsFuelInclHP(allCy,DSBS,EF,YTIME)
                 =E=
         VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME) +
         (V02ShareTechNewEquip(allCy,DSBS,EF,YTIME) * V02GapFinalDem(allCy,DSBS,YTIME)) +
         (VmConsElecNonSubIndTert(allCy,DSBS,YTIME))$(INDDOM(DSBS) and ELCEF(EF));
$ontext
```
This equation calculates the variable, including fuel electricity production cost per CHP plant and demand sector, taking into account the variable cost (other than fuel)
per CHP type and the summation of fuel-related costs for each energy form . The calculation involves fuel prices, CO2 emission factors, boiler efficiency, electricity
index, and carbon prices, adjusted by various factors. The equation uses these terms to calculate the variable, including fuel electricity production cost per CHP plant and
demand sector. The result is expressed in Euro per kilowatt-hour (Euro/KWh). 
```
Q02CostProdCHPDem(allCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS) $runCy(allCy))..
         V02CostProdCHPDem(allCy,DSBS,CHP,YTIME)
                 =E=
         i02VarCostChp(allCy,DSBS,CHP,YTIME)/1000
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VmPriceFuelSubsecCarVal(allCy,"PG",PGEF,YTIME)+1e-3*imCo2EmiFac(allCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))))
                         *smTWhToMtoe/(i02BoiEffChp(allCy,CHP,YTIME)*VmPriceElecInd(allCy,YTIME)));
$offtext
```
The equation calculates the average electricity production cost per Combined Heat and Power plant .
It involves a summation over demand subsectors . The average electricity production cost is determined by considering the electricity
production cost per CHP plant for each demand subsector. The result is expressed in Euro per kilowatt-hour (Euro/KWh).
```
Q02CostElcAvgProdCHP(allCy,CHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmCostElcAvgProdCHP(allCy,CHP,YTIME)
         =E=
         (sum(INDDOM, VmConsFuel(allCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,CHP,YTIME-1))*V02CostElecProdCHP(allCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,CHP,YTIME-1)));
$ontext
```
The equation computes the average variable cost, including fuel and electricity production cost, per Combined Heat and Power plant.
The equation involves a summation over demand subsectors , where the variable cost per CHP plant is calculated based on fuel
consumption and the variable cost of electricity production . The resulting average variable cost is expressed in Euro per kilowatt-hour (Euro/KWh).
The conditional statement ensures that the denominator in the calculation is not zero, avoiding division by zero issues.
```
Q02CostVarAvgElecProd(allCy,CHP,YTIME)$(TIME(YTIME) $runCy(allCy)) ..
         VmCostVarAvgElecProd(allCy,CHP,YTIME)
         =E=
         (sum(INDDOM, VmConsFuel(allCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VmConsFuel(allCy,INDDOM2,CHP,YTIME-1))
         *V02CostProdCHPDem(allCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VmConsFuel.L(allCy,INDDOM2,CHP,YTIME-1)));
$offtext
```

```
table i02ElastNonSubElecData(SBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
Parameters
i02ExogDemOfBiomass(allCy,SBS,YTIME)	                   "Demand of tranditional biomass defined exogenously ()"
i02LifChpPla(allCy,DSBS,CHP)                               "Technical Lifetime for CHP plants (years)"
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02InvCostChp(allCy,DSBS,CHP,YTIME)                        "Capital Cost per CHP plant type (US$2015/KW)"
i02FixOMCostPerChp(allCy,DSBS,CHP,YTIME)                   "Fixed O&M cost per CHP plant type (US$2015/KW)"
i02AvailRateChp(allCy,DSBS,CHP)                            "Availability rate of CHP Plants ()"
i02VarCostChp(allCy,DSBS,CHP,YTIME)                        "Variable (other than fuel) cost per CHP Type (Gross US$2015/KW)"
i02BoiEffChp(allCy,CHP,YTIME)                              "Boiler efficiency (typical) used in adjusting CHP efficiency ()"
;
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$(SECTTECH(TRANSE,EF) $(not plugin(EF))), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$(SECTTECH(INDSE,EF)),imFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$(SECTTECH(DOMSE,EF)),imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$(SECTTECH(NENSE,EF)),imFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
i02LifChpPla(runCy,DSBS,CHP) = imDataChpPowGen(CHP,"LFT","2010");
$IFTHEN.calib %Calibration% == Calibration
variable i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity (1)";
i02ElastNonSubElec.L(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
i02ElastNonSubElec.LO(runCy,SBS,"a",YTIME)   = 0.001;
i02ElastNonSubElec.UP(runCy,SBS,"a",YTIME)   = 10;
i02ElastNonSubElec.LO(runCy,SBS,"b1",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b1",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"b2",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b2",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"c",YTIME)   = -10;
i02ElastNonSubElec.UP(runCy,SBS,"c",YTIME)   = -0.001;
$ELSE.calib
i02ElastNonSubElec(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
$ENDIF.calib
i02InvCostChp(runCy,DSBS,CHP,YTIME)      = imDataChpPowGen(CHP,"IC",YTIME);
i02FixOMCostPerChp(runCy,DSBS,CHP,YTIME) = imDataChpPowGen(CHP,"FC",YTIME);
i02AvailRateChp(runCy,DSBS,CHP)          = imDataChpPowGen(CHP,"AVAIL","2010");
i02VarCostChp(runCy,DSBS,CHP,YTIME)      = imDataChpPowGen(CHP,"VOM",YTIME);
i02BoiEffChp(runCy,CHP,YTIME)            = imDataChpPowGen(CHP,"BOILEFF",YTIME);
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
```

*VARIABLE INITIALISATION*
```
V02CostTechIntrm.L(runCy,DSBS,rcon,EF,YTIME) = 0.1;
V02SortTechVarCost.L(runCy,DSBS,rCon,YTIME) = 1e-8;
V02ShareTechNewEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 1e-8;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
VmConsElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM);
VmDemFinSubFuelSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VmConsElecNonSubIndTert.L(runCy,INDDOM,YTIME),1e-5);
VmDemFinSubFuelSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VmDemFinSubFuelSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VmConsElecNonSubIndTert.L(runCy,"HOU",YTIME)-i02ExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
VmConsFuelInclHP.LO(runCy,DSBS,EF,YTIME) = 0;
VmConsFuelInclHP.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VmElecConsHeatPla.L(runCy,DSBS,YTIME)*imUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VmElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF)
+ 0.1$(H2EF(EF) or sameas("STE1AH2F",EF));
VmConsRemSubEquipSubSec.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VmConsFuelInclHP.L(runCy ,DSBS,EF,YTIME) - (VmConsElecNonSubIndTert.L(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))));
V02GapFinalDem.scale(runCy,DSBS,YTIME) = 1e-8;
Q02GapFinalDem.scale(runCy,DSBS,YTIME) = V02GapFinalDem.scale(runCy,DSBS,YTIME);
```


> **Limitations**
> There are no known limitations.

### (B) technology

This is the legacy realization of the Industry module.


```
Equations
```
***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS EQUATIONS
```
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Compute Demand for useful substitutable energy demand in each subsector"
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Compute Remaining Equipment Capacity per Technology in each subsector (substitutable)"
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Compute Useful energy demand (substitutable) covered by remaining equipment"
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "Compute gap in useful energy demand per subsector"
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute capital cost of each technology per subsector (final)"
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)                     "Compute variable cost of each technology per subsector (final)"
Q02CostTech(allCy,DSBS,ITECH,YTIME)                        "Compute total cost of each technology per subsector (useful)"
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "Compute share of each technology in gap of useful energy"
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "Compute equipment capacity of each technology in each subsector"
Q02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "Compute non-substitutable useful electricity"
Q02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "Compute final energy of non-substitutable electricity"
Q02IndxElecIndPrices(allCy,YTIME)                          "Compute Electricity index - a function of industry price - Estimate"
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
Q02RatioRem(allCy,DSBS,ITECH,YTIME)
```
**Interdependent Equations**
```
Q02ConsFuel(allCy,DSBS,EF,YTIME)                           "Compute fuel consumption of fuels in each subsector"
;
Variables
```
***  INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
```
V02DemSubUsefulSubsec(allCy,DSBS,YTIME)                    "Demand for useful substitutable energy demand in each subsector"
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)           "Remaining Equipment Capacity per Technology in each subsector (substitutable)"
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)                "Useful energy demand (substitutable) covered by remaining equipment"
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)                    "gap in useful energy demand per subsector"
V02CapCostTech(allCy,DSBS,ITECH,YTIME)                     "capital cost of each technology per subsector (final)"
V02VarCostTech(allCy,DSBS,ITECH,YTIME)                    "variable cost of each technology per subsector (final)"
V02CostTech(allCy,DSBS,ITECH,YTIME)                        "total cost of each technology per subsector (useful)"
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)         "share of each technology in gap of useful energy"
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)              "equipment capacity of each technology in each subsector"
V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)               "non-substitutable useful electricity"
V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)                "final energy of non-substitutable electricity"
V02IndxElecIndPrices(allCy,YTIME)                          "Electricity index - a function of industry price - Estimate"
V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)                  "Average Efficiency" 
V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)                    "premature scrapping"
V02RatioRem(allCy,DSBS,ITECH,YTIME)
```
**Interdependent Variables**
```
VmConsFuel(allCy,DSBS,EF,YTIME)                            "fuel consumption of fuels in each subsector"
;
```

GENERAL INFORMATION
Industrial and domestic energy demand is divided (TO DO)
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES
This equation computes the useful energy demand in each demand subsector (excluding TRANSPORT). This demand is potentially "satisfied" by multiple energy forms/fuels (substitutable demand).
The equation follows the "typical useful energy demand" format where the main explanatory variables are activity indicators and average "weighted" technology costs.
OLD EQUATION: Q02DemFinSubFuelSubsec(allCy,DSBS,YTIME) --> NEW EQUATION:Q02DemUsefulSubsec
OLD VARIABLE: VmDemFinSubFuelSubsec(allCy,DSBS,YTIME) --> NEW VARIABLE:VmDemUsefulSubsec
Note: To check which cost should be used... (this VmPriceFuelAvgSub or another cost (weighted average per technology))
```
Q02DemSubUsefulSubsec(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME) 
        =E=
    [
      V02DemSubUsefulSubsec(allCy,DSBS,YTIME-1) *
      imActv(YTIME,allCy,DSBS) ** imElastA(allCy,DSBS,"a",YTIME) *
      (VmPriceFuelAvgSub(allCy,DSBS,YTIME)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-1) ) ** imElastA(allCy,DSBS,"b1",YTIME) *
      (VmPriceFuelAvgSub(allCy,DSBS,YTIME-1)/VmPriceFuelAvgSub(allCy,DSBS,YTIME-2) ) ** imElastA(allCy,DSBS,"b2",YTIME) *
      prod(KPDL,
        ((VmPriceFuelAvgSub(allCy,DSBS,YTIME-ord(KPDL))/VmPriceFuelAvgSub(allCy,DSBS,YTIME-(ord(KPDL)+1)))/(imCGI(allCy,YTIME)**(1/6)))**( imElastA(allCy,DSBS,"c",YTIME)*imFPDL(DSBS,KPDL))
      )
    ]$imActv(YTIME-1,allCy,DSBS)
;
```
NEW EQUATION'
This equation computes the remaining equipment capacity of each technology in each subsector in the beginning of the year YTIME based on the available capacity of the previous year
```
Q02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME-1) * 
    V02RatioRem(allCy,DSBS,ITECH,YTIME);
Q02RatioRem(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
V02RatioRem(allCy,DSBS,ITECH,YTIME) 
        =E=
    ( (1 - 1/VmLft(allCy,DSBS,ITECH,YTIME))* (1 - V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)));
Q02PremScrpIndu(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(SECTTECH(DSBS,ITECH) and not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02PremScrpIndu(allCy,DSBS,ITECH,YTIME)
        =E=
    1 - (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1)) ** (-2) /
    (
      (V02VarCostTech(allCy,DSBS,ITECH,YTIME-1) * i02util(allCy,DSBS,ITECH,YTIME-1)) ** (-2) +
      (
        i02ScaleEndogScrap(DSBS) *
        sum(ITECH2$(not sameas(ITECH2,ITECH) and SECTTECH(DSBS,ITECH2)),
          V02CostTech(allCy,DSBS,ITECH2,YTIME-1) + V02VarCostTech(allCy,DSBS,ITECH2,YTIME-1)
        )
      )**(-2)
    );
```
NEW EQUATION' - kind of --> substitutes Q02ConsRemSubEquipSubSec
```
Q02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) 
        =E=
    SUM(ITECH$SECTTECH(DSBS,ITECH),
      V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    );
```
This equation calculates the gap in useful energy demand for industry, tertiary, non-energy uses, and bunkers.
It is determined by subtracting the useful energy demand that can be satisfied by existing equipment from the total useful 
energy demand per subsector. The square root term is included to ensure a non-negative result - if the result of the 
the subtraction is negative, the gap will take a zero value.
OLD EQUATION: Q02GapFinalDem(allCy,DSBS,YTIME) --> NEW EQUATION:Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)
OLD VARIABLE: V02GapFinalDem(allCy,DSBS,YTIME) --> NEW VARIABLE:V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
```
Q02GapUsefulDemSubsec(allCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC")) $runCy(allCy))..
    V02GapUsefulDemSubsec(allCy,DSBS,YTIME) 
        =E=
    (
      V02DemSubUsefulSubsec(allCy,DSBS,YTIME) -
      V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME) +
      SQRT(SQR(V02DemSubUsefulSubsec(allCy,DSBS,YTIME) - V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)))
    )/2 + 1e-6
;
```
The equation computes the capital cost and fixed O&M cost of each technology in each subsector
OLD EQUATION: Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW EQUATION:Q02CapCostTech(allCy,DSBS,rCon,EF,YTIME)
OLD VARIABLE: V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW VARIABLE:V02CapCostTech(allCy,DSBS,rCon,EF,YTIME)
Add parameter sUnitToKUnit = 1000
Check ITECH and CHPs
```
Q02CapCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    ((
      (
        imDisc(allCy,DSBS,YTIME) * !! in case of chp plants we use the discount rate of power generation sector
        exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME))
      ) /
      (exp(imDisc(allCy,DSBS,YTIME) * VmLft(allCy,DSBS,ITECH,YTIME)) - 1)
    ) *
    imCapCostTech(allCy,DSBS,ITECH,YTIME) * imCGI(allCy,YTIME) +
    imFixOMCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit)
    / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME); !! divide with utilization rate or with efficiency as well???? depends on the CapCostTech parameter
```
The equation computes the variable cost (variable + fuel) of each technology in each subsector - to check about consumer sizes
OLD EQUATION: Q02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW EQUATION:Q02VarCostTech(allCy,DSBS,rCon,ITECH,YTIME)
OLD VARIABLE: V02CostTechIntrm(allCy,DSBS,rCon,EF,YTIME) --> NEW VARIABLE:V02VarCostTech(allCy,DSBS,rCon,ITECH,YTIME)
NEW SET TECHEF
```
Q02VarCostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
  V02VarCostTech(allCy,DSBS,ITECH,YTIME) 
      =E=
  (
    sum(EF$ITECHtoEF(ITECH,EF), 
      i02Share(allCy,DSBS,ITECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) +
      imCO2CaptRateIndustry(allCy,ITECH,YTIME) * VmCstCO2SeqCsts(allCy,YTIME-1) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME-1)  +
      (1-imCO2CaptRateIndustry(allCy,ITECH,YTIME)) * 1e-3 * imCo2EmiFac(allCy,DSBS,EF,YTIME-1)  *
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal(allCy,NAP,YTIME-1))) +
      (VmRenValue(YTIME)/1000)$(not RENEF(ITECH) and not NENSE(DSBS)) !! needs change of units
    ) +
    imVarCostTech(allCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME);
Q02CostTech(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS))$SECTTECH(DSBS,ITECH)$runCy(allCy))..
    V02CostTech(allCy,DSBS,ITECH,YTIME) 
        =E=
    V02CapCostTech(allCy,DSBS,ITECH,YTIME) +
    V02VarCostTech(allCy,DSBS,ITECH,YTIME);
```
This equation calculates the technology share in new equipment based on factors such as maturity factor,
cumulative distribution function of consumer size groups, number of consumers, technology cost, distribution function of consumer
size groups, and technology sorting.
```
Q02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,ITECH) $(not TRANSE(DSBS) and not sameas(DSBS,"DAC")) $runCy(allCy))..
    V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) 
        =E=
    imMatrFactor(allCy,DSBS,ITECH,YTIME) *
    V02CostTech(allCy,DSBS,ITECH,YTIME) ** (-i02ElaSub(allCy,DSBS)) /
    sum(ITECH2$(SECTTECH(DSBS,ITECH2)),
      imMatrFactor(allCy,DSBS,ITECH2,YTIME) *
      V02CostTech(allCy,DSBS,ITECH2,YTIME) ** (-i02ElaSub(allCy,DSBS))
    );
```
This equation computes the equipment capacity of each technology in each subsector
Check if Tech exists in main.gms
```
Q02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and TIME(YTIME)and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and runCy(allCy))..
    V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) 
        =E= 
    V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) +
    (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME)) / 
    (imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) * i02util(allCy,DSBS,ITECH,YTIME));
        
```
This equation computes the consumption/demand of non-substitutable electricity for subsectors of INDUSTRY and DOMESTIC in the "typical useful energy demand equation".
The main explanatory variables are activity indicators of each subsector and electricity prices per subsector. Corresponding elasticities are applied for activity indicators
and electricity prices.
OLD EQUATION: Q02ConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW EQUATION:Q02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)
OLD VARIABLE: VmConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW VARIABLE:V02UsefulElecNonSubIndTert(allCy,DSBS,YTIME)
```
Q02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME) 
        =E=
    [
      V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME-1) *
      imActv(YTIME,allCy,INDDOM) ** i02ElastNonSubElec(allCy,INDDOM,"a",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1)) ** i02ElastNonSubElec(allCy,INDDOM,"b1",YTIME) *
      (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-1) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-2)) ** i02ElastNonSubElec(allCy,INDDOM,"b2",YTIME) *
      prod(KPDL,
        (VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-ord(KPDL)) / VmPriceFuelSubsecCarVal(allCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))) ** (i02ElastNonSubElec(allCy,INDDOM,"c",YTIME)*imFPDL(INDDOM,KPDL))
      )
    ]$imActv(YTIME-1,allCy,INDDOM);
```
NEW EQUATION - Useful Electricity to Final Electricity (Check if needed to add equipment of electricity)
```
Q02FinalElecNonSubIndTert(allCy,INDDOM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02FinalElecNonSubIndTert(allCy,INDDOM,YTIME) 
        =E=
    V02UsefulElecNonSubIndTert(allCy,INDDOM,YTIME) / 
    imUsfEneConvSubTech(allCy,INDDOM,"TELC",YTIME)
    ;
```
This equation calculates the consumption of fuels in each demand subsector.
It considers the consumption of remaining substitutable equipment, the technology share in new equipment, and the final demand
gap to be filled by new technologies. Additionally, non-substitutable electricity consumption in Industry and Tertiary sectors is included.
OLD EQUATION: Q02ConsFuelInclHP(allCy,DSBS,EF,YTIME) --> NEW EQUATION:Q02ConsFuelIncl(allCy,DSBS,EF,YTIME)
OLD VARIABLE: VmConsElecNonSubIndTert(allCy,INDDOM,YTIME) --> NEW VARIABLE:VmUsefulElecNonSubIndTert(allCy,DSBS,YTIME)
```
Q02ConsFuel(allCy,DSBS,EF,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    VmConsFuel(allCy,DSBS,EF,YTIME) 
        =E=
    sum(ITECH$(ITECHtoEF(ITECH,EF)$SECTTECH(DSBS,ITECH)),
      i02Share(allCy,DSBS,ITECH,EF,YTIME) *
      V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) *
      i02util(allCy,DSBS,ITECH,YTIME)
    ) +
    V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS) and ELCEF(EF)) +
    VmElecConsHeatPla(allCy,DSBS,YTIME)$ELCEF(EF);
```
Average efficiency of substitutable demand
```
Q02IndAvrEffFinalUseful(allCy,DSBS,YTIME)$(TIME(YTIME)$(not TRANSE(DSBS) and not sameas(DSBS,"DAC"))$runCy(allCy))..
    V02IndAvrEffFinalUseful(allCy,DSBS,YTIME)
       =E=
    V02DemSubUsefulSubsec(allCy,DSBS,YTIME)   
    /
    (sum(EF$SECtoEF(DSBS,EF),VmConsFuel(allCy,DSBS,EF,YTIME)) - (V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$(INDDOM(DSBS)) +
    VmElecConsHeatPla(allCy,DSBS,YTIME)))
    ;
```
This equation calculates the estimated electricity index of the industry price for a given year. The estimated index is derived by considering the historical
trend of the electricity index, with a focus on the fuel prices in the industrial subsector. The equation utilizes the fuel prices for electricity generation,
both in the current and past years, and computes a weighted average based on the historical pattern. The estimated electricity index is influenced by the ratio
of fuel prices in the current and previous years, with a power of 0.3 applied to each ratio. This weighting factor introduces a gradual adjustment to reflect the
historical changes in fuel prices, providing a more dynamic estimation of the electricity index. This equation provides a method to estimate the electricity index
based on historical fuel price trends, allowing for a more flexible and responsive representation of industry price dynamics.
```
Q02IndxElecIndPrices(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V02IndxElecIndPrices(allCy,YTIME)
        =E=
    VmPriceElecInd(allCy,YTIME-1) * 
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)/VmPriceFuelAvgSub(allCy,"OI",YTIME-1)) ** (0.02) *
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-2)/VmPriceFuelAvgSub(allCy,"OI",YTIME-2)) ** (0.01) *
    (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-3)/VmPriceFuelAvgSub(allCy,"OI",YTIME-3)) ** (0.01);
```

```
table i02ElastNonSubElecData(SBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "./iElastNonSubElecData.csv"
$offdelim
;
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
Parameters
i02ExogDemOfBiomass(allCy,SBS,YTIME)	                   "Demand of tranditional biomass defined exogenously ()"
$IF NOT %Calibration% == Calibration i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)                   "Elasticities of Non Substitutable Electricity (1)"
i02util(allCy,DSBS,ITECH,YTIME)                            "Utilization rate of technology"
i02numtechnologiesUsingEF(DSBS,EF)                         "Number of technologues using an energy form"     
i02Share(allCy,DSBS,ITECH,EF,YTIME)                        "Share of each energy form in a technology"
imCO2CaptRateIndustry(allCy,ITECH,YTIME)	               "Industry CO2 capture rate (1)"
i02ScaleEndogScrap(DSBS)                            "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
;
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$SECtoEF(INDSE,EF),imFuelConsPerFueSub(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$SECtoEF(DOMSE,EF),imFuelConsPerFueSub(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$SECtoEF(NENSE,EF),imFuelConsPerFueSub(runCy,NENSE,EF,YTIME));
i02ExogDemOfBiomass(runCy,DOMSE,YTIME) = 0;
i02util(runCy,DSBS,ITECH,YTIME) = 1;
i02Share(runCy,DSBS,ITECH,EF,YTIME) = 1; !! (To be included in mrprom when mix of fuels for technologies)
$IFTHEN.calib %Calibration% == Calibration
variable i02ElastNonSubElec(allCy,SBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity (1)";
i02ElastNonSubElec.L(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
i02ElastNonSubElec.LO(runCy,SBS,"a",YTIME)   = 0.001;
i02ElastNonSubElec.UP(runCy,SBS,"a",YTIME)   = 10;
i02ElastNonSubElec.LO(runCy,SBS,"b1",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b1",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"b2",YTIME)  = -10;
i02ElastNonSubElec.UP(runCy,SBS,"b2",YTIME)  = -0.001;
i02ElastNonSubElec.LO(runCy,SBS,"c",YTIME)   = -10;
i02ElastNonSubElec.UP(runCy,SBS,"c",YTIME)   = -0.001;
$ELSE.calib
i02ElastNonSubElec(runCy,SBS,ETYPES,YTIME) = i02ElastNonSubElecData(SBS,ETYPES,YTIME);
$ENDIF.calib
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
i02ElaSub(runCy,DSBS) = 2; !!
i02ScaleEndogScrap(DSBS)$(not TRANSE(DSBS) and not sameas("DAC",DSBS)) = 6./SUM(ITECH$SECTTECH(DSBS,ITECH),1);
imCO2CaptRateIndustry(runCy,CCSTECH,YTIME) = 0.9;
alias(ITECH,ITECH2);
i02numtechnologiesUsingEF(DSBS,EF)=sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1);
```

```
 
```
*VARIABLE INITIALISATION*
```
V02FinalElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM);
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = V02FinalElecNonSubIndTert.L(runCy,INDDOM,YTIME) * imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
 
$ontext
V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
V02DemUsefulSubsecRemTech(allCy,DSBS,YTIME)
V02GapUsefulDemSubsec(allCy,DSBS,YTIME)
$offtext
V02CostTech.LO(runCy,DSBS,ITECH,YTIME) = 0;
V02CostTech.L(runCy,DSBS,ITECH,YTIME) = 0.1;
$ontext
V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME)
V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)
$offtext
alias(ITECH,ITECH2);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2) and not CCSTECH(ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not CCSTECH(ITECH) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF),imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/ i02Util(runCy,DSBS,ITECH,YTIME));
!!V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and not sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,EF,YTIME)/sum(ITECH2$(TECHtoEF(ITECH2,EF) and SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
V02EquipCapTechSubsec.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not An(YTIME) and not TRANSE(DSBS) and sameas(ITECH,"TELC")) = sum(EF$TECHtoEF(ITECH,EF), imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME) * (1-imShrNonSubElecInTotElecDem(runCy,DSBS))/sum(ITECH2$(TECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1)) / i02Util(runCy,DSBS,ITECH,YTIME);
V02EquipCapTechSubsec.FX(runCy,DSBS,CCSTECH,YTIME)$(SECTTECH(DSBS,CCSTECH) and not An(YTIME)) = 0;
display V02EquipCapTechSubsec.L;
 
V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = SUM(ITECH$SECTTECH(INDDOM,ITECH),
      V02EquipCapTechSubsec.L(runCy,INDDOM,ITECH,YTIME) *
      imUsfEneConvSubTech(runCy,INDDOM,ITECH,YTIME) *
      i02util(runCy,INDDOM,ITECH,YTIME)
    );
V02DemSubUsefulSubsec.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
 
 
 
V02UsefulElecNonSubIndTert.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * imShrNonSubElecInTotElecDem(runCy,INDDOM) / imUsfEneConvSubTech(runCy,INDDOM,"TELC",YTIME);
VmConsFuel.LO(runCy,DSBS,EF,YTIME) = 0;
VmConsFuel.L(runCy,DSBS,EF,YTIME) = 1;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(HEATPUMP(EF) or TRANSE(DSBS) or sameas("DAC", DSBS)) = 0;
VmConsFuel.FX(runCy,DSBS,EF,YTIME)$(not HEATPUMP(EF) and not TRANSE(DSBS) and DATAY(YTIME)) = imFuelConsPerFueSub(runCy,DSBS,EF,YTIME);
 
!!V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = 0.0001;
V02VarCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) =
  (
    sum(EF$ITECHtoEF(ITECH,EF),
      i02Share(runCy,DSBS,ITECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME) +
      imCO2CaptRateIndustry(runCy,ITECH,YTIME) * VmCstCO2SeqCsts.L(runCy,YTIME-1) * 1e-3 * (imCo2EmiFac(runCy,DSBS,EF,YTIME-1) + 4.17$(sameas("BMSWAS", EF))) +
      (1-imCO2CaptRateIndustry(runCy,ITECH,YTIME)) * 1e-3 * (imCo2EmiFac(runCy,DSBS,EF,YTIME-1) + 4.17$(sameas("BMSWAS", EF))) *
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME-1))) +
      VmRenValue.L(YTIME)$(not RENEF(ITECH) and not NENSE(DSBS)) !! needs change of units
    ) +
    imVarCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit
  ) / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME);
V02CapCostTech.FX(runCy,DSBS,ITECH,YTIME)$(not An(YTIME) and not TRANSE(DSBS) and not sameas(DSBS,"DAC") and SECTTECH(DSBS,ITECH)) = ((
      (
        (imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * !! in case of chp plants we use the discount rate of power generation sector
        exp((imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME))
      ) /
      (exp((imDisc(runCy,DSBS,YTIME)$(not TSTEAM(ITECH)) + imDisc(runCy,"PG",YTIME)$TSTEAM(ITECH)) * VmLft.L(runCy,DSBS,ITECH,YTIME)) - 1)
    ) *
    imCapCostTech(runCy,DSBS,ITECH,YTIME) * imCGI(runCy,YTIME) +
    imFixOMCostTech(runCy,DSBS,ITECH,YTIME) / sUnitToKUnit)
    / imUsfEneConvSubTech(runCy,DSBS,ITECH,YTIME);
V02CostTech.FX(runCy,DSBS,ITECH,YTIME)$DATAY(YTIME) = V02VarCostTech.L(runCy,DSBS,ITECH,YTIME) + V02CapCostTech.L(runCy,DSBS,ITECH,YTIME);
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


---------------------------------------------------------------------------------------
           &nbsp;                      Description                  Unit         A   B 
---------------------------- -------------------------------- ----------------- --- ---
      i02AvailRateChp            Availability rate of CHP                        x     
             \                            Plants                                       
       (allCy, DSBS,                                                                   
            CHP)                                                                       

      i02BoiEffChp \           Boiler efficiency (typical)                       x     
        (allCy, CHP,              used in adjusting CHP                                
           YTIME)                       efficiency                                     

     i02ElastNonSubElec            Elasticities of Non               $1$         x   x 
             \                  Substitutable Electricity                              
        (allCy, SBS,                                                                   
       ETYPES, YTIME)                                                                  

   i02ElastNonSubElecData          Elasticities of Non               $1$         x   x 
             \                  Substitutable Electricity                              
       (SBS, ETYPES,                                                                   
           YTIME)                                                                      

        i02ElaSub \           Elasticities by subsector for          $1$         x   x 
       (allCy, DSBS)                  all countries                                    

    i02ExogDemOfBiomass       Demand of tranditional biomass                     x   x 
             \                     defined exogenously                                 
        (allCy, SBS,                                                                   
           YTIME)                                                                      

     i02FixOMCostPerChp        Fixed O&M cost per CHP plant     $US\$2015/KW$    x     
             \                             type                                        
       (allCy, DSBS,                                                                   
        CHP, YTIME)                                                                    

      i02InvCostChp \           Capital Cost per CHP plant      $US\$2015/KW$    x     
       (allCy, DSBS,                       type                                        
        CHP, YTIME)                                                                    

      i02LifChpPla \            Technical Lifetime for CHP         $years$       x     
       (allCy, DSBS,                      plants                                       
            CHP)                                                                       

 i02numtechnologiesUsingEF     Number of technologues using                          x 
             \                        an energy form                                   
         (DSBS, EF)                                                                    

     i02ScaleEndogScrap       Scale parameter for endogenous         $1$             x 
             \                 scrapping applied to the sum                            
           (DSBS)                     of full costs                                    

        i02Share \            Share of each energy form in a                         x 
       (allCy, DSBS,                    technology                                     
         ITECH, EF,                                                                    
           YTIME)                                                                      

         i02util \            Utilization rate of technology                         x 
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

      i02VarCostChp \           Variable (other than fuel)         $Gross        x     
       (allCy, DSBS,                cost per CHP Type           US\$2015/KW$           
        CHP, YTIME)                                                                    

   imCO2CaptRateIndustry        Industry CO2 capture rate            $1$             x 
             \                                                                         
       (allCy, ITECH,                                                                  
           YTIME)                                                                      

       Q02CapCostTech          Compute capital cost of each        $final$           x 
             \                   technology per subsector                              
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

  Q02ConsElecNonSubIndTert       Compute non-substituable                        x     
             \                  electricity consumption in                             
      (allCy, INDDOM,             Industry and Tertiary                                
           YTIME)                                                                      

       Q02ConsFuel \             Compute fuel consumption                        x   x 
       (allCy, DSBS,                                                                   
         EF, YTIME)                                                                    

     Q02ConsFuelInclHP        Equation for fuel consumption      $including      x     
             \                           in Mtoe                    heat               
       (allCy, DSBS,                                                from               
         EF, YTIME)                                              heatpumps$            

  Q02ConsRemSubEquipSubSec     Equation for consumption of                       x     
             \                    remaining substitutble                               
       (allCy, DSBS,                    equipment                                      
         EF, YTIME)                                                                    

    Q02CostElcAvgProdCHP       Compute Average Electricity                       x     
             \                production cost per CHP plant                            
        (allCy, CHP,                                                                   
           YTIME)                                                                      

     Q02CostElecProdCHP       Compute electricity production                     x     
             \                cost per CHP plant and demand                            
       (allCy, DSBS,                      sector                                       
        CHP, YTIME)                                                                    

       Q02CostTech \             Compute technology cost                         x   x 
       (allCy, DSBS,                                                                   
         rCon, EF,                                                                     
           YTIME)                                                                      

      Q02CostTechIntrm             Compute intermediate                          x     
             \                       technology cost                                   
       (allCy, DSBS,                                                                   
         rCon, EF,                                                                     
           YTIME)                                                                      

     Q02CostTechMatFac         Compute the technology cost                       x     
             \                including the maturity factor                            
       (allCy, DSBS,           per technology and subsector                            
         rCon, EF,                                                                     
           YTIME)                                                                      

   Q02DemFinSubFuelSubsec     Compute total final demand (of                     x     
             \                   substitutable fuels) per                              
       (allCy, DSBS,                    subsector                                      
           YTIME)                                                                      

   Q02DemSubUsefulSubsec        Compute Demand for useful                            x 
             \                substitutable energy demand in                           
       (allCy, DSBS,                  each subsector                                   
           YTIME)                                                                      

 Q02DemUsefulSubsecRemTech     Compute Useful energy demand                          x 
             \                  (substitutable) covered by                             
       (allCy, DSBS,               remaining equipment                                 
           YTIME)                                                                      

   Q02EquipCapTechSubsec      Compute equipment capacity of                          x 
             \                   each technology in each                               
       (allCy, DSBS,                    subsector                                      
       ITECH, YTIME)                                                                   

 Q02FinalElecNonSubIndTert       Compute final energy of                             x 
             \                non-substitutable electricity                            
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

       Q02GapFinalDem            Compute the gap in final                        x     
             \                demand of industry, tertiary,                            
       (allCy, DSBS,           non-energy uses and bunkers                             
           YTIME)                                                                      

   Q02GapUsefulDemSubsec       Compute gap in useful energy                          x 
             \                     demand per subsector                                
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

  Q02IndAvrEffFinalUseful           Average Efficiency                               x 
             \                                                                         
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

    Q02IndxElecIndPrices      Compute Electricity index - a                      x   x 
             \                 function of industry price -                            
       (allCy, YTIME)                    Estimate                                      

      Q02PremScrpIndu              premature scrapping                               x 
             \                                                                         
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

       Q02RatioRem \                                                                 x 
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

  Q02RemEquipCapTechSubsec     Compute Remaining Equipment     $substitutable$       x 
             \                  Capacity per Technology in                             
       (allCy, DSBS,                  each subsector                                   
       ITECH, YTIME)                                                                   

    Q02ShareTechNewEquip       Compute technology share in                       x     
             \                        new equipment                                    
       (allCy, DSBS,                                                                   
         EF, YTIME)                                                                    

 Q02ShareTechNewEquipUseful       Compute share of each                              x 
             \                 technology in gap of useful                             
       (allCy, DSBS,                      energy                                       
       ITECH, YTIME)                                                                   

     Q02SortTechVarCost         Compute Technology sorting                       x     
             \                    based on variable cost                               
       (allCy, DSBS,                                                                   
        rCon, YTIME)                                                                   

 Q02UsefulElecNonSubIndTert     Compute non-substitutable                            x 
             \                      useful electricity                                 
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

       Q02VarCostTech         Compute variable cost of each        $final$           x 
             \                   technology per subsector                              
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

       V02CapCostTech              capital cost of each            $final$           x 
             \                   technology per subsector                              
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

     V02CostElecProdCHP        Electricity production cost     $US\$2015/KWh$    x     
             \                   per CHP plant and demand                              
       (allCy, DSBS,                      sector                                       
        CHP, YTIME)                                                                    

     V02CostProdCHPDem           Variable including fuel       $US\$2015/KWh$    x     
             \                 electricity production cost                             
       (allCy, DSBS,             per CHP plant and demand                              
        CHP, YTIME)                       sector                                       

       V02CostTech \                 Technology cost           $KUS\$2015/toe$   x   x 
       (allCy, DSBS,                                                                   
         rCon, EF,                                                                     
           YTIME)                                                                      

      V02CostTechIntrm         Intermediate technology cost    $KUS\$2015/toe$   x     
             \                                                                         
       (allCy, DSBS,                                                                   
         rcon, EF,                                                                     
           YTIME)                                                                      

     V02CostTechMatFac          Technology cost including      $KUS\$2015/toe$   x     
             \                       maturity factor                                   
       (allCy, DSBS,                                                                   
         rCon, EF,                                                                     
           YTIME)                                                                      

   V02DemSubUsefulSubsec            Demand for useful                                x 
             \                substitutable energy demand in                           
       (allCy, DSBS,                  each subsector                                   
           YTIME)                                                                      

 V02DemUsefulSubsecRemTech         Useful energy demand                              x 
             \                  (substitutable) covered by                             
       (allCy, DSBS,               remaining equipment                                 
           YTIME)                                                                      

   V02EquipCapTechSubsec        equipment capacity of each                           x 
             \                 technology in each subsector                            
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

 V02FinalElecNonSubIndTert           final energy of                                 x 
             \                non-substitutable electricity                            
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

       V02GapFinalDem          Final demand gap to be filed        $Mtoe$        x     
             \                     by new technologies                                 
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

   V02GapUsefulDemSubsec       gap in useful energy demand                           x 
             \                        per subsector                                    
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

  V02IndAvrEffFinalUseful           Average Efficiency                               x 
             \                                                                         
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

    V02IndxElecIndPrices      Electricity index - a function         $1$         x   x 
             \                 of industry price - Estimate                            
       (allCy, YTIME)                                                                  

      V02PremScrpIndu              premature scrapping                               x 
             \                                                                         
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

       V02RatioRem \                                                                 x 
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

  V02RemEquipCapTechSubsec     Remaining Equipment Capacity    $substitutable$       x 
             \                    per Technology in each                               
       (allCy, DSBS,                    subsector                                      
       ITECH, YTIME)                                                                   

    V02ShareTechNewEquip         Technology share in new             $1$         x     
             \                          equipment                                      
       (allCy, DSBS,                                                                   
         EF, YTIME)                                                                    

 V02ShareTechNewEquipUseful    share of each technology in                           x 
             \                     gap of useful energy                                
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

     V02SortTechVarCost        Technology sorting based on           $1$         x     
             \                        variable cost                                    
       (allCy, DSBS,                                                                   
        rCon, YTIME)                                                                   

 V02UsefulElecNonSubIndTert      non-substitutable useful                            x 
             \                         electricity                                     
       (allCy, DSBS,                                                                   
           YTIME)                                                                      

       V02VarCostTech             variable cost of each            $final$           x 
             \                   technology per subsector                              
       (allCy, DSBS,                                                                   
       ITECH, YTIME)                                                                   

  VmConsElecNonSubIndTert             Consumption of               $Mtoe$        x     
             \                 non-substituable electricity                            
       (allCy, DSBS,             in Industry and Tertiary                              
           YTIME)                                                                      

      VmConsFuelInclHP         Consumption of fuels in each        $Mtoe$        x     
             \                  demand subsector including                             
       (allCy, DSBS,               heat from heatpumps                                 
         EF, YTIME)                                                                    

  VmConsRemSubEquipSubSec        Consumption of remaining          $Mtoe$        x     
             \                   substitutable equipment                               
       (allCy, DSBS,                                                                   
         EF, YTIME)                                                                    

    VmCostVarAvgElecProd        Average variable including     $US\$2015/KWh$    x     
             \                 fuel electricity production                             
        (allCy, CHP,                cost per CHP plant                                 
           YTIME)                                                                      

   VmDemFinSubFuelSubsec          Total final demand (of           $Mtoe$        x     
             \                   substitutable fuels) per                              
       (allCy, DSBS,                    subsector                                      
           YTIME)                                                                      
---------------------------------------------------------------------------------------

Table: module-internal objects (A: legacy | B: technology)



### Sets


---------------------------------------------------
      &nbsp;                  description          
------------------- -------------------------------
     alias(TT,                                     
      ytime)                                       

       allCy           All Countries Used in the   
                                 Model             

     an(ytime)       Years for which the model is  
                                running            

  biomass(balef)                                   

  CCSTECH(ITECH)                                   

     CHPPGSET                                      

      conSet         Consumer size groups related  
                           to space heating        

    DOMSE(DSBS)           Tertiary SubSectors      

     DSBS(SBS)           All Demand Subsectors     

        EF                   Energy Forms          

     ELCEF(EF)                Electricity          

      ETYPES              Elasticities types       

     H2EF(EF)                  Hydrogen            

   HEATPUMP(EF)       Heatpumps are reducing the   
                       heat requirements of the    
                         sector but increasing     
                        electricity consumption    

        HOU               11.511 0.9 0.00001       

   INDDOM(DSBS)          Industry and Tertiary     

    INDSE(DSBS)          Industrial SubSectors     

    ITECH(TECH)         Industrial - Domestic -    
                         Non-energy & Bunkers      
                             Technologies          

 ITECHtoEF(ITECH,    Fuels consumed by industrial  
        EF)                  technologies          

 NAP(Policies_set)     National Allocation Plan    
                           sector categories       

 NAPtoALLSBS(NAP,    Energy sectors corresponding  
      ALLSBS)               to NAP sectors         

    NENSE(DSBS)         Non Energy and Bunkers     

     PGEF(EFS)        Energy forms used for steam  
                              production           

       rCon            counter for the number of   
                               consumers           

    RENEF(TECH)        Renewable technologies in   
                              demand side          

   runCy(allCy)      Countries for which the model 
                              is running           

   runCyL(allCy)     Countries for which the model 
                     is running (used in countries 
                                 loop)             

    SBS(ALLSBS)            Model Subsectors        

   SECtoEF(SBS,      Link between Model Subsectors 
        EF)                and Energy FORMS        

  SECTTECH(DSBS,       Link between Model Demand   
       TECH)          Subsectors and Technologies  

       TECH                  Technologies          

     TECHtoEF         (TECHEF) Fuels consumed by   
                             technologies          

   TRANSE(DSBS)        All Transport Subsectors    

      TSTEAM         CHP & DHP plant technologies  

       ytime              Model time horizon       
---------------------------------------------------

Table: sets in use



See Also
--------

[01_Transport], [03_RestOfEnergy], [04_PowerGeneration], [05_Hydrogen], [06_CO2], [08_Prices], [09_Heat], [core]

