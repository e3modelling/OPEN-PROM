Transport module (01_Transport) {#id-01_Transport}
===============================

Description
-----------

This is the Transport module.


Interfaces
----------

**Interface plot missing!**

### Input


----------------------------------------------------------------------------------
         &nbsp;                     Description                 Unit        A   B 
------------------------- ------------------------------- ---------------- --- ---
    VmPriceFuelAvgSub         Average fuel prices per      $k\$2015/toe$    x   x 
            \                        subsector                                    
      (allCy, DSBS,                                                               
         YTIME)                                                                   

 VmPriceFuelSubsecCarVal   Fuel prices per subsector and   $k\$2015/toe$    x   x 
            \                          fuel                                       
      (allCy, SBS,                                                                
       EF, YTIME)                                                                 

      VmRenValue \                Renewable value          $US\$2015/KWh$   x   x 
         (YTIME)                                                                  
----------------------------------------------------------------------------------

Table: module inputs (A: legacy | B: simple)



### Output


--------------------------------------------------------------------
          &nbsp;                     Description             Unit   
-------------------------- ------------------------------- ---------
 VmDemFinEneTranspPerFuel      Final energy demand in       $Mtoe$  
            \               transport subsectors per fuel           
     (allCy, TRANSE,                                                
        EF, YTIME)                                                  

         VmLft \              Lifetime of technologies      $years$ 
      (allCy, DSBS,                                                 
       TECH, YTIME)                                                 
--------------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the Transport module.


```
Equations
```
*** Transport
```
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)                    "Compute goods transport activity"
Q01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Compute the gap in transport activity"
Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Compute Specific Fuel Consumption"
Q01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)"Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
Q01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost per mean and consumer size in KUS$2015 per vehicle"
Q01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Compute transportation cost including maturity factor"
Q01TechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Compute technology sorting based on variable cost"
Q01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Compute technology sorting based on variable cost and new equipment"
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
Q01StockPcYearly(allCy,YTIME)                              "Compute stock of passenger cars (in million vehicles)"
Q01StockPcYearlyTech(allCy,TTECH,YTIME)                    "Compute stock of passenger cars (in million vehicles)"
Q01NewRegPcYearly(allCy,YTIME)                             "Compute new registrations of passenger cars per technology"
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Compute passenger transport acitivity"
Q01NumPcScrap(allCy,YTIME)                                 "Compute scrapped passenger cars"
Q01PcOwnPcLevl(allCy,YTIME)                                "Compute ratio of car ownership over saturation car ownership"
Q01RateScrPc(allCy,YTIME)                                  "Compute passenger cars scrapping rate"
```
**Interdependent Equations**
```
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)	       "Compute final energy demand in transport per fuel"
Q01Lft(allCy,DSBS,TECH,YTIME)	                               "Compute the lifetime of passenger cars" 
;
Variables
```
*** Transport Variables
```
V01ActivGoodsTransp(allCy,TRANSE,YTIME)	                   "Goods transport acitivity (Gtkm)"
V01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)
V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
V01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)"Transportation cost per mean and consumer size (KUS$2015/vehicle)"
V01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost per mean and consumer size (KUS$2015/vehicle)"!!
V01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)	       "Transportation cost including maturity factor (KUS$2015/vehicle)"
V01TechSortVarCost(allCy,TRANSE,Rcon,YTIME)	               "Technology sorting based on variable cost (1)"
V01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Technology share in new equipment (1)"
V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
V01StockPcYearly(allCy,YTIME)                              "Stock of passenger cars (million vehicles)"
V01StockPcYearlyTech(allCy,TTECH,YTIME)                    "stock of passenger cars per technology (in million vehicles)"
V01NewRegPcYearly(allCy,YTIME)                             "Passenger cars new registrations (million vehicles)"
V01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Passenger transport activity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km per vehicle
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
V01NumPcScrap(allCy,YTIME)                                 "Scrapped passenger cars (million vehicles)"
V01PcOwnPcLevl(allCy,YTIME)                                "Ratio of car ownership over saturation car ownership (1)"
V01RateScrPc(allCy,YTIME)                                  "Scrapping rate of passenger cars (1)"
```
**Interdependent Equations**
```
VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)            "Final energy demand in transport subsectors per fuel (Mtoe)"
VmLft(allCy,DSBS,TECH,YTIME)                                 "Lifetime of technologies (years)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* Transport
This equation calculates the lifetime of passenger cars based on the scrapping rate of passenger cars. The lifetime is inversely proportional to the scrapping rate,
meaning that as the scrapping rate increases, the lifetime of passenger cars decreases.
```
Q01Lft(allCy,DSBS,TTECH,YTIME)$(TIME(YTIME) $sameas(DSBS,"PC") $SECTTECH(DSBS,TTECH) $runCy(allCy))..
    VmLft(allCy,DSBS,TTECH,YTIME)
        =E=
    1 / V01RateScrPc(allCy,YTIME);
```
This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
freight transport modes.
```
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE) $runCy(allCy))..
         V01ActivGoodsTransp(allCy,TRANSE,YTIME)
                 =E=
         (
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)
           * [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME)
           * (i01Pop(YTIME,allCy)/i01Pop(YTIME-1,allCy))
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME)
           * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                    VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
                 )
         )$sameas(TRANSE,"GU") +      !!trucks
         (
            V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) *
            [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME) *
            (VmPriceFuelAvgSub(allCy,TRANSE,YTIME) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
            (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
            prod(kpdl,
              [
                (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl)) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1))) /
                (imCGI(allCy,YTIME)**(1/6))
              ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
            ) *
            (
              (V01ActivGoodsTransp(allCy,"GU",YTIME) + 1e6) / 
              (V01ActivGoodsTransp(allCy,"GU",YTIME-1) + 1e6)
            )**imElastA(allCy,TRANSE,"c4",YTIME)
          )$(not sameas(TRANSE,"GU"));        !!other freight transport
```
This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
different types of transportation modes.
```
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V01GapTranspActiv(allCy,TRANSE,YTIME)
                 =E=
         V01NewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC")
         +
         (
         ( [V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
         (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] +
          SQRT( SQR([V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
          (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
         +
         (
         ( [V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
         (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
          (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$TRANG(TRANSE);
```
This equation calculates the specific fuel consumption for a given technology, subsector, energy form, and time. The specific fuel consumption depends on various factors,
including fuel prices and elasticities. The equation involves a product term over a set of Polynomial Distribution Lags and considers the elasticity of fuel prices.
```
Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
         V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
                 =E=
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME-1) * 
        prod(KPDL,
          (
            VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-ord(KPDL)) /
            VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
          )**(imElastA(allCy,TRANSE,"c5",YTIME)*imFPDL(TRANSE,KPDL))
        );
```
This equation calculates the transportation cost per mean and consumer size in kEuro per vehicle. It involves several terms, including capital costs,
variable costs, and fuel costs. The equation considers different technologies and their associated costs, as well as factors like the discount rate,
specific fuel consumption, and annual .
```
Q01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le imNcon(TRANSE)+1) $runCy(allCy))..
    V01CostTranspPerMeanConsSize(allCy,TRANSE,RCon,TTECH,YTIME)
          =E=
    (
      (
        (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
        /
        (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
      ) * imCapCostTech(allCy,TRANSE,TTECH,YTIME)  * imCGI(allCy,YTIME)
      + imFixOMCostTech(allCy,TRANSE,TTECH,YTIME)  +
      (
        (sum(EF$TTECHtoEF(TTECH,EF),V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
        +
        (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME))*V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME))
          + i01ShareAnnMilePlugInHybrid(allCy,YTIME)*V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)*VmPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
        )$PLUGIN(TTECH)
        + imVarCostTech(allCy,TRANSE,TTECH,YTIME)
        + (VmRenValue(YTIME)/1000)$( not RENEF(TTECH))
      )
      *  imAnnCons(allCy,TRANSE,"smallest") * (imAnnCons(allCy,TRANSE,"largest")/imAnnCons(allCy,TRANSE,"smallest"))**((ord(Rcon)-1)/imNcon(TRANSE))
    );
```
This equation calculates the transportation cost per mean and consumer size. It involves taking the inverse fourth power of the
variable representing the transportation cost per mean and consumer size.
```
Q01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME)
         =E=
         V01CostTranspPerMeanConsSize(allCy,TRANSE,rCon,TTECH,YTIME)**(-1);
```
This equation calculates the transportation cost, including the maturity factor. It involves multiplying the maturity factor for a specific technology
and subsector by the transportation cost per vehicle for the mean and consumer size. The result is a variable representing the transportation cost,
including the maturity factor.
```
Q01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01CostTranspMatFac(allCy,TRANSE,RCon,TTECH,YTIME) 
         =E=
         imMatrFactor(allCy,TRANSE,TTECH,YTIME) * V01CostTranspPerVeh(allCy,TRANSE,rCon,TTECH,YTIME);
```
This equation calculates the technology sorting based on variable cost. It involves the summation of transportation costs, including the maturity factor,
for each technology and subsector. The result is a variable representing the technology sorting based on variable cost.
```
Q01TechSortVarCost(allCy,TRANSE,rCon,YTIME)$(TIME(YTIME) $(ord(rCon) le imNcon(TRANSE)+1) $runCy(allCy))..
         V01TechSortVarCost(allCy,TRANSE,rCon,YTIME)
                 =E=
         sum((TTECH)$SECTTECH(TRANSE,TTECH), V01CostTranspMatFac(allCy,TRANSE,rCon,TTECH,YTIME));
```
This equation calculates the share of each technology in the total sectoral use. It takes into account factors such as the maturity factor,
cumulative distribution function of consumer size groups, transportation cost per mean and consumer size, distribution function of consumer
size groups, and technology sorting based on variable cost. The result is a dimensionless value representing the share of each technology in the total sectoral use.
```
Q01ShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
        V01ShareTechTr(allCy,TRANSE,TTECH,YTIME)
            =E=
        imMatrFactor(allCy,TRANSE,TTECH,YTIME) / 
        imCumDistrFuncConsSize(allCy,TRANSE) *
        sum(Rcon$(ord(Rcon) le imNcon(TRANSE)+1),
          V01CostTranspPerVeh(allCy,TRANSE,RCon,TTECH,YTIME) *
          imDisFunConSize(allCy,TRANSE,RCon) /
          V01TechSortVarCost(allCy,TRANSE,RCon,YTIME)
        );
```
This equation calculates the consumption of each technology in transport sectors. It considers various factors such as the lifetime of the technology,
average capacity per vehicle, load factor, scrapping rate, and specific fuel consumption. The equation also takes into account the technology's variable
cost for new equipment and the gap in transport activity to be filled by new technologies. The result is expressed in million tonnes of oil equivalent.
```
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
            =E=
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME-1) *
    (
      (
        (VmLft(allCy,TRANSE,TTECH,YTIME-1)-1) / 
        VmLft(allCy,TRANSE,TTECH,YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      (
        1 - V01RateScrPc(allCy,YTIME)
      )$sameas(TRANSE,"PC")
    ) +
    V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *
    (
      V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)$(not PLUGIN(TTECH)) +
      ( 
        (
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
        )$(not sameas("ELC",EF)) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)
      )$PLUGIN(TTECH)
    ) / 1000 *
    V01GapTranspActiv(allCy,TRANSE,YTIME) *
    (
      (
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      (V01ActivPassTrnsp(allCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
    );
```
This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
```
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECtoEF(TRANSE,EF) $runCy(allCy))..
         VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
                 =E=
         sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME));
```
This equation calculates the final energy demand in different transport subsectors by summing up the final energy demand for each energy form within
each transport subsector. The result is expressed in million tonnes of oil equivalent.
```
$ontext
q01DemFinEneSubTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $runCy(allCy))..
         v01DemFinEneSubTransp(allCy,TRANSE,YTIME)
                 =E=
         sum(EF,VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME));
$offtext
```
This equation computes the total stock of passenger cars (in millions).
The stock evolves from the previous year's level, adjusted by:
- A saturation function that limits market expansion based on GDP per capita and ownership levels,
- Annual population size (to scale per-capita changes to total stock).
```
Q01StockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearly(allCy,YTIME)
            =E=
      V01PcOwnPcLevl(allCy,YTIME) * 
      (i01Pop(YTIME,allCy) * 1000);
Q01StockPcYearlyTech(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearlyTech(allCy,TTECH,YTIME)
            =E=
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1) * 
      (1 - V01RateScrPc(allCy,YTIME)) +
      V01ShareTechTr(allCy,"PC",TTECH,YTIME) *
      V01GapTranspActiv(allCy,"PC",YTIME);
```
This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
```
Q01NewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V01NewRegPcYearly(allCy,YTIME)
                =E=
        V01StockPcYearly(allCy,YTIME) - 
        V01StockPcYearly(allCy,YTIME-1) +
        V01NumPcScrap(allCy,YTIME);     !! new cars due to scrapping
```
This equation calculates the passenger transport activity for various modes of transportation, including passenger cars, aviation, and other passenger transportation modes.
The activity is influenced by factors such as fuel prices, GDP per capita, and elasticities specific to each transportation mode. The equation uses past activity levels and
price trends to estimate the current year's activity. The coefficients and exponents in the equation represent the sensitivities of activity to changes in various factors.
```
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE) $runCy(allCy))..
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)
              =E=
      (  !! passenger cars
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"b1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"b2",YTIME) *
        [V01PcOwnPcLevl(allCy,YTIME)/V01PcOwnPcLevl(allCy,YTIME-1)]**imElastA(allCy,TRANSE,"b3",YTIME) *
        [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)]**0.02
      )$sameas(TRANSE,"PC") +
      (  !! passenger aviation
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
      )$sameas(TRANSE,"PA") +
      (   !! other passenger transportation modes
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)*V01ActivPassTrnsp(allCy,"PC",YTIME))/(V01StockPcYearly(allCy,YTIME-1)*V01ActivPassTrnsp(allCy,"PC",YTIME-1))]**imElastA(allCy,TRANSE,"c4",YTIME) *
        prod(kpdl,
          [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
            VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
            (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        )
      )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));
```
This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
```
Q01NumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01NumPcScrap(allCy,YTIME)
              =E=
      V01RateScrPc(allCy,YTIME) * V01StockPcYearly(allCy,YTIME-1);
```
This equation estimates vehicle ownership per capita for each country and year.
It applies the Gompertz function to model how car ownership evolves in relation to GDP per capita.
The formulation includes parameters that introduce a saturation effect, ensuring the model reflects
an upper limit (asymptote) of car ownership as income levels rise.
```
    Q01PcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V01PcOwnPcLevl(allCy,YTIME)
              =E=
        i01PassCarsMarkSat(allCy) *
        EXP(
          -i01Sigma(allCy,"S1") *
          EXP(-i01Sigma(allCy,"S2") * i01GDPperCapita(YTIME,allCy) / 10000)
        );
```
This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
cars scrapping rate over time.
```
Q01RateScrPc(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V01RateScrPc(allCy,YTIME)
            =E=
        V01RateScrPc(allCy,YTIME-1) *
        (
          i01GDPperCapita(YTIME,allCy) / 
          i01GDPperCapita(YTIME-1,allCy)
        ) ** 0.1;
```

```
table i01GDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
table i01Pop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
table i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
     Cap  LF
PC   2    
PB  40   0.4
PT   300  0.4
PN  300  0.5
PA   180  0.65
GU   5    0.7
GT   600  0.8
GN   1500 0.9 
;
table i01NewReg(allCy,YTIME)                            "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;
table i01StockPC(allCy,TTECH,YTIME)                     "Car stock per technology (million vehicles)"
$ondelim
$include"./iStockPC.csv"
$offdelim
;
parameter i01PlugHybrFractData(YTIME)                   "Plug in hybrid fraction of mileage" /
2010    0.5
2011    0.504444
2012    0.508889
2013    0.513333
2014    0.517778
2015    0.522222
2016    0.526667
2017    0.531111
2018    0.535556
2019    0.54
2020    0.544444
2021    0.548889
2022    0.553333
2023    0.557778
2024    0.562222
2025    0.566667
2026    0.571111
2027    0.575556
2028    0.58
2029    0.584444
2030    0.588889
2031    0.593333
2032    0.597778
2033    0.602222
2034    0.606667
2035    0.611111
2036    0.615556
2037    0.62
2038    0.624444
2039    0.628889
2040    0.633333
2041    0.637778
2042    0.642222
2043    0.646667
2044    0.651111
2045    0.655556
2046    0.66
2047    0.664444
2048    0.668889
2049    0.673333
2050    0.677778
2051    0.682222
2052    0.686667
2053    0.691111
2054    0.695556
2055    0.7
2056    0.688889
2057    0.690741
2058    0.69216
2059    0.693076
2060    0.693404
2061    0.693045
2062    0.691886
2063    0.692385
2064    0.692659
2065    0.692743
2066    0.692687
2067    0.692567
2068    0.692488
2069    0.692588
2070    0.692622
2071    0.692616
2072    0.692595
2073    0.692579
2074    0.692581
2075    0.692597
2076    0.692598
2077    0.692594
2078    0.692591
2079    0.69259
2080    0.692592
2081    0.692594
2082    0.692593
2083    0.692592
2084    0.692592
2085    0.692592
2086    0.692593
2087    0.692593
2088    0.692593
2089    0.692593
2090    0.692593
2091    0.692593
2092    0.692593
2093    0.692593
2094    0.692593
2095    0.692593
2096    0.692593
2097    0.692593
2098    0.692593
2099    0.692593
2100    0.692593
/
;
table i01SFCPC(allCy,TTECH,EF,YTIME)                     "Initial Specific fuel consumption (toe/vkm)"
$ondelim
$include"./iSFC.csv"
$offdelim
;
parameter i01InitSpecFuelConsData(TRANSE,TTECH,EF)      "Initial Specific fuel consumption (toe/vkm)" /
PT.TGDO.GDO	18.6313
PT.TMET.MET	12.6
PT.TH2F.H2F	8.9
PT.TELC.ELC	2.73638
PA.TH2F.H2F	21.7
GU.TLPG.LPG	54.1073
GU.TGSL.GSL	60.1192
GU.TGDO.GDO	45.0894
GU.TNGS.NGS	66
GU.TMET.MET	56.2
GU.TETH.ETH	80
GU.TBGDO.BGDO	45.0894
GU.TH2F.H2F	13.5268
GU.TELC.ELC	27.0536
GU.TPHEVGSL.GSL	34.4
GU.TPHEVGSL.ELC	21.8
GU.TPHEVGDO.GDO	27.0536
GU.TPHEVGDO.ELC	21.8
GU.TCHEVGDO.GDO	21.8
GT.TGDO.GDO	33.629
GT.TMET.MET	78
GT.TH2F.H2F	92
GT.TELC.ELC	11.5245
GN.TGSL.GSL	22.8
GN.TGDO.GDO	15.2
GN.TH2F.H2F	8.14286
/
;
Parameters
i01GdpPassCarsMarkExt(allCy)	                          "GDP-dependent passenger cars market extension (GDP/capita)"
i01PassCarsScrapRate(allCy)	                          "Passenger cars scrapping rate (1)"
i01ShareAnnMilePlugInHybrid(allCy,YTIME)	           "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
i01AvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	      "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)"
i01TechLft(allCy,SBS,TECH,YTIME)	                     "Technical Lifetime. For passenger cars it is a variable (1)"
i01PassCarsMarkSat(allCy)	                          "Passenger cars ownership saturation threshold (1)"
i01GDPperCapita(YTIME,allCy)
i01Sigma(allCy,SG)                                   "S parameters of Gompertz function for passenger cars vehicle km (1)"
;
i01PassCarsMarkSat(runCy) = 0.7;
imFuelConsTRANSE(runCy,TRANSE,EF,YTIME)$(SECtoEF(TRANSE,EF) $(imFuelConsTRANSE(runCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
i01ShareAnnMilePlugInHybrid(runCy,YTIME)$an(YTIME) = i01PlugHybrFractData(YTIME);
i01AvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE);
i01TechLft(runCy,TRANSE,TTECH,YTIME) = imDataTransTech(TRANSE,TTECH,"LFT",YTIME);
i01TechLft(runCy,INDSE,ITECH,YTIME) = imDataIndTechnology(INDSE,ITECH,"LFT");
i01TechLft(runCy,DOMSE,ITECH,YTIME) = imDataDomTech(DOMSE,ITECH,"LFT");
i01TechLft(runCy,NENSE,ITECH,YTIME) = imDataNonEneSec(NENSE,ITECH,"LFT");
i01GDPperCapita(YTIME,runCy) = i01GDP(YTIME,runCy) / i01Pop(YTIME,runCy);
```

*VARIABLE INITIALISATION*
```
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,"PC");
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = imTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = imActv(YTIME,runCy,TRANP); 
V01ActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
V01NewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = i01NewReg(runCy,YTIME);
V01TechSortVarCost.LO(runCy,TRANSE,Rcon,YTIME) = 1e-20;
V01TechSortVarCost.L(runCy,TRANSE,Rcon,YTIME) = 0.1;
V01RateScrPc.FX(runCy,YTIME)$DATAY(YTIME) = 1 / VmLft.L(runCy,DSBS,TTECH,YTIME);
V01NumPcScrap.FX(runCy,"%fBaseY%") = V01RateScrPc.L(runCy,"%fBaseY%") * V01StockPcYearly.L(runCy,"%fBaseY%"); 
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME)$SECTTECH(TRANSE,TTECH) = 1;
V01StockPcYearlyTech.FX(runCy,TTECH,"%fBaseY%") = i01StockPC(runCy,TTECH,"%fBaseY%");
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
V01PcOwnPcLevl.UP(runCy,YTIME) = 2*i01PassCarsMarkSat(runCy);
V01PcOwnPcLevl.FX(runCy,YTIME)$(not An(YTIME)) = V01StockPcYearly.L(runCy,YTIME) / (i01Pop(YTIME,runCy) * 1000) ;
i01Sigma(runCy,"S2") = 0.5;
i01Sigma(runCy,"S1") = -log(V01PcOwnPcLevl.L(runCy,"%fBaseY%") / i01PassCarsMarkSat(runCy)) * EXP(i01Sigma(runCy,"S2") * i01GDPperCapita("%fBaseY%",runCy) / 10000);
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
V01ConsSpecificFuel.FX(runCy,TRANP,TTECH,EF,"%fBaseY%")$(not sameas(TRANP,"PC")$(SECTTECH(TRANP,TTECH)$TTECHtoEF(TTECH,EF))) = i01InitSpecFuelConsData(TRANP,TTECH,EF);
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01SFCPC(runCy,TTECH,EF,"%fBaseY%");
V01ConsSpecificFuel.FX(runCy,TRANG,TTECH,EF,"%fBaseY%")$((SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01InitSpecFuelConsData(TRANSE,TTECH,EF);
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) = 0;
V01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-7;
Q01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=V01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME);
V01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=1e-8;
Q01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=V01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME);
V01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME)=1e-6;
Q01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME)=V01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME);
V01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-12;
Q01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=V01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECtoEF(TRANSE,EF) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECtoEF(TRANSE,EF)) = 0;
V01RateScrPc.UP(runCy,YTIME) = 1;
```


> **Limitations**
> There are no known limitations.

### (B) simple

This is the legacy realization of the Transport module.


```
Equations
```
*** Transport
```
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)                    "Compute goods transport activity"
Q01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Compute the gap in transport activity"
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Compute transportation cost per mean in KUS$2015 per vehicle"
Q01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Compute technology sorting based on variable cost and new equipment"
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Compute consumption of each technology in transport sectors"
Q01StockPcYearly(allCy,YTIME)                              "Compute stock of passenger cars (in million vehicles)"
Q01StockPcYearlyTech(allCy,TTECH,YTIME)                    "Compute stock of passenger cars (in million vehicles)"
Q01NewRegPcYearly(allCy,YTIME)                             "Compute new registrations of passenger cars per technology"
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Compute passenger transport acitivity"
Q01NumPcScrap(allCy,YTIME)                                 "Compute scrapped passenger cars"
Q01PcOwnPcLevl(allCy,YTIME)                                "Compute ratio of car ownership over saturation car ownership"
Q01RateScrPc(allCy,TTECH,YTIME)                                  "Compute passenger cars scrapping rate"
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)
Q01RateScrPcTot(allCy,TTECH,YTIME)
```
**Interdependent Equations**
```
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)	       "Compute final energy demand in transport per fuel"
Q01Lft(allCy,DSBS,TECH,YTIME)	                               "Compute the lifetime of passenger cars" 
;
Variables
```
*** Transport Variables
```
V01ActivGoodsTransp(allCy,TRANSE,YTIME)	                   "Goods transport acitivity (Gtkm)"
V01GapTranspActiv(allCy,TRANSE,YTIME)	                   "Gap in transport activity to be filled by new technologies ()"
                                                                !! Gap for passenger cars (million vehicles)
                                                                !! Gap for all other passenger transportation modes (Gpkm)
                                                                !! Gap for all goods transport is measured (Gtkm)
V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)	       "Specific Fuel Consumption ()"
                                                                !! SFC for passenger cars (ktoe/Gkm)
                                                                !! SFC for other passsenger transportation modes (ktoe/Gpkm)
                                                                !! SFC for trucks is measured (ktoe/Gtkm)
V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)    "Transportation cost per mean (KUS$2015/vehicle)"
V01ShareTechTr(allCy,TRANSE,TECH,YTIME)	                   "Technology share in new equipment (1)"
V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)	   "Consumption of each technology and subsector (Mtoe)"
V01StockPcYearly(allCy,YTIME)                              "Stock of passenger cars (million vehicles)"
V01StockPcYearlyTech(allCy,TTECH,YTIME)                    "stock of passenger cars per technology (in million vehicles)"
V01NewRegPcYearly(allCy,YTIME)                             "Passenger cars new registrations (million vehicles)"
V01ActivPassTrnsp(allCy,TRANSE,YTIME)                      "Passenger transport activity (1)"
                                                                !! - Activity for passenger cars is measured in (000)km per vehicle
                                                                !! - Activity for passenger aviation million passengers carried
                                                                !! - Activity for all other passenger transportation modes is measured in Gpkm
V01NumPcScrap(allCy,YTIME)                                 "Scrapped passenger cars (million vehicles)"
V01PcOwnPcLevl(allCy,YTIME)                                "Ratio of car ownership over saturation car ownership (1)"
V01RateScrPc(allCy,TTECH,YTIME)                                  "Scrapping rate of passenger cars (1)"
V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
V01CostFuel(allCy,TRANSE,TTECH,YTIME)
V01PremScrp(allCy,TRANSE,TTECH,YTIME)
V01RateScrPcTot(allCy,TTECH,YTIME)
```
**Interdependent Equations**
```
VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)            "Final energy demand in transport subsectors per fuel (Mtoe)"
VmLft(allCy,DSBS,TECH,YTIME)                                 "Lifetime of technologies (years)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* Transport
This equation calculates the lifetime of passenger cars as the inverse of their scrapping rate.
```
Q01Lft(allCy,"PC",TTECH,YTIME)$(TIME(YTIME) $SECTTECH("PC",TTECH) $runCy(allCy))..
    VmLft(allCy,"PC",TTECH,YTIME)
        =E=
    1 / V01RateScrPc(allCy,TTECH,YTIME);
```
This equation calculates the activity for goods transport, considering different types of goods transport such as trucks and other freight transport.
The activity is influenced by factors such as GDP, population, fuel prices, and elasticities. The equation includes terms for trucks and other
freight transport modes.
```
Q01ActivGoodsTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE) $runCy(allCy))..
      V01ActivGoodsTransp(allCy,TRANSE,YTIME)
              =E=
      (
      V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)
        * [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)] ** 0.4 !!imElastA(allCy,TRANSE,"a",YTIME)
        * (i01Pop(YTIME,allCy)/i01Pop(YTIME-1,allCy)) ** 0.8
        * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME)
        * (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
        * prod(kpdl,
              [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
                VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                (imCGI(allCy,YTIME)**(1/6))]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
          )
      )$sameas(TRANSE,"GU") +      !!trucks
      (
        V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        prod(kpdl,
          [
            (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl)) / VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1))) /
            (imCGI(allCy,YTIME)**(1/6))
          ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        ) *
        (
          (V01ActivGoodsTransp(allCy,"GU",YTIME) + 1e-6) / 
          (V01ActivGoodsTransp(allCy,"GU",YTIME-1) + 1e-6)
        )**imElastA(allCy,TRANSE,"c4",YTIME)
      )$(not sameas(TRANSE,"GU"));        !!other freight transport
```
This equation calculates the gap in transport activity, which represents the activity that needs to be filled by new technologies.
The gap is calculated separately for passenger cars, other passenger transportation modes, and goods transport. The equation involves
various terms, including the new registrations of passenger cars, the activity of passenger and goods transport, and considerations for
different types of transportation modes.
```
Q01GapTranspActiv(allCy,TRANSE,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01GapTranspActiv(allCy,TRANSE,YTIME)
            =E=
    V01NewRegPcYearly(allCy,YTIME)$sameas(TRANSE,"PC") +
    (
      ( 
        [
          V01ActivPassTrnsp(allCy,TRANSE,YTIME) - 
          V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + 
          V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) /
          (sum((TTECH)$SECTTECH(TRANSE,TTECH), VmLft(allCy,TRANSE,TTECH,YTIME-1)) / TECHS(TRANSE))
        ] +
        SQRT( SQR([V01ActivPassTrnsp(allCy,TRANSE,YTIME) - V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) + V01ActivPassTrnsp(allCy,TRANSE,YTIME-1)/
        (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) 
      )/2
    )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC"))) +
    (
      ( 
        [
          V01ActivGoodsTransp(allCy,TRANSE,YTIME) - 
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + 
          V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) /
          (sum(TTECH$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))
        ] + 
        SQRT( SQR([V01ActivGoodsTransp(allCy,TRANSE,YTIME) - V01ActivGoodsTransp(allCy,TRANSE,YTIME-1) + V01ActivGoodsTransp(allCy,TRANSE,YTIME-1)/
        (sum((TTECH)$SECTTECH(TRANSE,TTECH),VmLft(allCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) 
      )/2
    )$TRANG(TRANSE);
```
This equation computes the annualized capital cost of new transport technologies by converting upfront investment costs 
into equivalent annual payments. It applies the annuity factor to spread the capital cost over the technology’s lifetime.
```
Q01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME)
          =E=
    (
      (imDisc(allCy,TRANSE,YTIME)*exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)))
      /
      (exp(imDisc(allCy,TRANSE,YTIME)*VmLft(allCy,TRANSE,TTECH,YTIME)) - 1)
    ) * imCapCostTech(allCy,TRANSE,TTECH,YTIME) * imCGI(allCy,YTIME);
Q01CostFuel(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
    V01CostFuel(allCy,TRANSE,TTECH,YTIME)
        =E=
    (
      (
        sum(EF$TTECHtoEF(TTECH,EF),
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) *
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) 
      )$(not PLUGIN(TTECH)) +
      (
        sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) *
          VmPriceFuelSubsecCarVal(allCy,TRANSE,EF,YTIME)
        ) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME) *
        VmPriceFuelSubsecCarVal(allCy,TRANSE,"ELC",YTIME)
      )$PLUGIN(TTECH) +
      imVarCostTech(allCy,TRANSE,TTECH,YTIME) +
      (VmRenValue(YTIME)/1000)$( not RENEF(TTECH)) 
    ) *
    (
      1e-3 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC") + !! aviation should be divided by 1000
      1e-1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PT")) +
      1e3 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PB")) +
      1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PN")) +
      1 * V01ActivPassTrnsp(allCy,TRANSE,YTIME)$(sameas(TRANSE,"PA")) +
      1e-5 * V01ActivGoodsTransp(allCy,TRANSE,YTIME)$TRANG(TRANSE)  !! should be divided by number of vehicles
      !!imAnnCons(allCy,TRANSE,"modal")$(not sameas(TRANSE,"PC"))
    )
    ;
Q01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$runCy(allCy)$SECTTECH(TRANSE,TTECH))..
    V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)
        =E=
      V01CapCostAnnualized(allCy,TRANSE,TTECH,YTIME) +
      imFixOMCostTech(allCy,TRANSE,TTECH,YTIME) +
      V01CostFuel(allCy,TRANSE,TTECH,YTIME);
Q01ShareTechTr(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $runCy(allCy))..
        V01ShareTechTr(allCy,TRANSE,TTECH,YTIME)
            =E=
        imMatrFactor(allCy,TRANSE,TTECH,YTIME) *
        V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)**(-3) /
        sum((TTECH2)$SECTTECH(TRANSE,TTECH2), 
          imMatrFactor(allCy,TRANSE,TTECH2,YTIME) * 
          V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME)**(-3)
        );
```
This equation calculates the consumption of each technology in transport sectors. It considers various factors such as the lifetime of the technology,
average capacity per vehicle, load factor, scrapping rate, and specific fuel consumption. The equation also takes into account the technology's variable
cost for new equipment and the gap in transport activity to be filled by new technologies. The result is expressed in million tonnes of oil equivalent.
```
Q01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) $runCy(allCy))..
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
            =E=
    V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME-1) *
    (
      (
        (VmLft(allCy,TRANSE,TTECH,YTIME-1)-1) / 
        VmLft(allCy,TRANSE,TTECH,YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      (
        1 - V01RateScrPcTot(allCy,TTECH,YTIME)
      )$sameas(TRANSE,"PC")
    ) +
    V01ShareTechTr(allCy,TRANSE,TTECH,YTIME) *
    (
      (i01ShareTTechFuel(allCy,TRANSE,TTECH,EF) *
      V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME))$(not PLUGIN(TTECH)) +
      ( 
        (
          (1-i01ShareAnnMilePlugInHybrid(allCy,YTIME)) *
          i01ShareTTechFuel(allCy,TRANSE,TTECH,EF) *
          V01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME)
        )$(not sameas("ELC",EF)) +
        i01ShareAnnMilePlugInHybrid(allCy,YTIME) *
        V01ConsSpecificFuel(allCy,TRANSE,TTECH,"ELC",YTIME)
      )$PLUGIN(TTECH)
    ) / 1000 *
    V01GapTranspActiv(allCy,TRANSE,YTIME) *
    (
      (
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME-1) *
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME-1) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"CAP",YTIME) /
        i01AvgVehCapLoadFac(allCy,TRANSE,"LF",YTIME)
      )$(not sameas(TRANSE,"PC")) +
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)$sameas(TRANSE,"PC")
    );
```
This equation calculates the final energy demand in transport for each fuel within a specific transport subsector.
It sums up the consumption of each technology and subsector for the given fuel. The result is expressed in million tonnes of oil equivalent.
```
Q01DemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECtoEF(TRANSE,EF) $runCy(allCy))..
    VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
            =E=
    sum(TTECH$(SECTTECH(TRANSE,TTECH) and TTECHtoEF(TTECH,EF)),
      V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EF,YTIME)
    );
Q01StockPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearly(allCy,YTIME)
            =E=
      V01PcOwnPcLevl(allCy,YTIME) * 
      (i01Pop(YTIME,allCy) * 1000);
Q01StockPcYearlyTech(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      V01StockPcYearlyTech(allCy,TTECH,YTIME)
            =E=
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1) * 
      (1 - V01RateScrPcTot(allCy,TTECH,YTIME)) +
      V01ShareTechTr(allCy,"PC",TTECH,YTIME) *
      V01GapTranspActiv(allCy,"PC",YTIME);
```
This equation calculates the new registrations of passenger cars for a given year. It considers the market extension due to GDP-dependent and independent factors.
The new registrations are influenced by the population, GDP, and the number of scrapped vehicles from the previous year.
```
Q01NewRegPcYearly(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V01NewRegPcYearly(allCy,YTIME)
                =E=
        V01StockPcYearly(allCy,YTIME) - 
        V01StockPcYearly(allCy,YTIME-1) +
        V01NumPcScrap(allCy,YTIME);     !! new cars due to scrapping
```
This equation calculates the passenger transport activity for various modes of transportation, including passenger cars, aviation, and other passenger transportation modes.
The activity is influenced by factors such as fuel prices, GDP per capita, and elasticities specific to each transportation mode. The equation uses past activity levels and
price trends to estimate the current year's activity. The coefficients and exponents in the equation represent the sensitivities of activity to changes in various factors.
```
Q01ActivPassTrnsp(allCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE) $runCy(allCy))..
      V01ActivPassTrnsp(allCy,TRANSE,YTIME)
              =E=
      (  !! passenger cars
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"b1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"b2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)/(i01Pop(YTIME,allCy)*1000))/(V01PcOwnPcLevl(allCy,YTIME-1))]**imElastA(allCy,TRANSE,"b3",YTIME) *
        [i01GDPperCapita(YTIME,allCy) / i01GDPperCapita(YTIME-1,allCy)] ** 0.2 !!imElastA(allCy,TRANSE,"b4",YTIME)
      )$sameas(TRANSE,"PC") +
      (  !! passenger aviation
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [i01GDPperCapita(YTIME,allCy)/i01GDPperCapita(YTIME-1,allCy)]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME)
      )$sameas(TRANSE,"PA") +
      (   !! other passenger transportation modes
        V01ActivPassTrnsp(allCy,TRANSE,YTIME-1) *
        [(i01GDP(YTIME,allCy)/i01Pop(YTIME,allCy))/(i01GDP(YTIME-1,allCy)/i01Pop(YTIME-1,allCy))]**imElastA(allCy,TRANSE,"a",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1))**imElastA(allCy,TRANSE,"c1",YTIME) *
        (VmPriceFuelAvgSub(allCy,TRANSE,YTIME-1)/VmPriceFuelAvgSub(allCy,TRANSE,YTIME-2))**imElastA(allCy,TRANSE,"c2",YTIME) *
        [(V01StockPcYearly(allCy,YTIME)*V01ActivPassTrnsp(allCy,"PC",YTIME))/(V01StockPcYearly(allCy,YTIME-1)*V01ActivPassTrnsp(allCy,"PC",YTIME-1))]**imElastA(allCy,TRANSE,"c4",YTIME) *
        prod(kpdl,
          [(VmPriceFuelAvgSub(allCy,TRANSE,YTIME-ord(kpdl))/
            VmPriceFuelAvgSub(allCy,TRANSE,YTIME-(ord(kpdl)+1)))/
            (imCGI(allCy,YTIME)**(1/6))
          ]**(imElastA(allCy,TRANSE,"c3",YTIME)*imFPDL(TRANSE,KPDL))
        )
      )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));
```
This equation calculates the number of scrapped passenger cars based on the scrapping rate and the stock of passenger cars from the previous year.
The scrapping rate represents the proportion of cars that are retired from the total stock, and it influences the annual number of cars taken out of service.
```
Q01NumPcScrap(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01NumPcScrap(allCy,YTIME)
            =E=
    SUM(TTECH,
      V01RateScrPcTot(allCy,TTECH,YTIME) * 
      V01StockPcYearlyTech(allCy,TTECH,YTIME-1)
    );
```
This equation estimates vehicle ownership per capita for each country and year.
It applies the Gompertz function to model how car ownership evolves in relation to GDP per capita.
The formulation includes parameters that introduce a saturation effect, ensuring the model reflects
an upper limit (asymptote) of car ownership as income levels rise.
```
Q01PcOwnPcLevl(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01PcOwnPcLevl(allCy,YTIME)
          =E=
    i01PassCarsMarkSat(allCy) *
    EXP(
      -i01Sigma(allCy,"S1") *
      EXP(-i01Sigma(allCy,"S2") * i01GDPperCapita(YTIME,allCy) / 10000)
    );
```
This equation calculates the scrapping rate of passenger cars. The scrapping rate is influenced by the ratio of Gross Domestic Product (GDP) to the population,
reflecting economic and demographic factors. The scrapping rate from the previous year is also considered, allowing for a dynamic estimation of the passenger
cars scrapping rate over time.
```
Q01RateScrPc(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH("PC",TTECH))..
    V01RateScrPc(allCy,TTECH,YTIME)
        =E=
    V01RateScrPc(allCy,TTECH,YTIME-1) *
    (
      i01GDPperCapita(YTIME,allCy) /
      i01GDPperCapita(YTIME-1,allCy)
    ) ** 0.1;
Q01RateScrPcTot(allCy,TTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V01RateScrPcTot(allCy,TTECH,YTIME)
        =E=
    1 - (1 - V01RateScrPc(allCy,TTECH,YTIME)) *
    (1 - V01PremScrp(allCy,"PC",TTECH,YTIME));
    
Q01PremScrp(allCy,TRANSE,TTECH,YTIME)$(TIME(YTIME)$SECTTECH(TRANSE,TTECH)$runCy(allCy))..
    V01PremScrp(allCy,TRANSE,TTECH,YTIME)
        =E=
    1 -
    (V01CostFuel(allCy,TRANSE,TTECH,YTIME) + 1e-4) ** (-2) /
    (
      (V01CostFuel(allCy,TRANSE,TTECH,YTIME) + 1e-4) ** (-2) +
      0.1 * 
      SUM(TTECH2$(not sameas(TTECH2,TTECH) and SECTTECH(TRANSE,TTECH2)),
        (V01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH2,YTIME) + 1e-4) ** (-2)
      )
    );
```

```
table i01GDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
table i01Pop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
table i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
     Cap  LF
PC   4    0.5
PB  40   0.4
PT   300  0.4
PN  300  0.5
PA   180  0.65
GU   5    0.7
GT   600  0.8
GN   1500 0.9 
;
table i01NewReg(allCy,YTIME)                            "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;
table i01StockPC(allCy,TTECH,YTIME)                     "Car stock per technology (million vehicles)"
$ondelim
$include"./iStockPC.csv"
$offdelim
;
parameter i01PlugHybrFractData(YTIME)                   "Plug in hybrid fraction of mileage" /
2010    0.5
2011    0.504444
2012    0.508889
2013    0.513333
2014    0.517778
2015    0.522222
2016    0.526667
2017    0.531111
2018    0.535556
2019    0.54
2020    0.544444
2021    0.548889
2022    0.553333
2023    0.557778
2024    0.562222
2025    0.566667
2026    0.571111
2027    0.575556
2028    0.58
2029    0.584444
2030    0.588889
2031    0.593333
2032    0.597778
2033    0.602222
2034    0.606667
2035    0.611111
2036    0.615556
2037    0.62
2038    0.624444
2039    0.628889
2040    0.633333
2041    0.637778
2042    0.642222
2043    0.646667
2044    0.651111
2045    0.655556
2046    0.66
2047    0.664444
2048    0.668889
2049    0.673333
2050    0.677778
2051    0.682222
2052    0.686667
2053    0.691111
2054    0.695556
2055    0.7
2056    0.688889
2057    0.690741
2058    0.69216
2059    0.693076
2060    0.693404
2061    0.693045
2062    0.691886
2063    0.692385
2064    0.692659
2065    0.692743
2066    0.692687
2067    0.692567
2068    0.692488
2069    0.692588
2070    0.692622
2071    0.692616
2072    0.692595
2073    0.692579
2074    0.692581
2075    0.692597
2076    0.692598
2077    0.692594
2078    0.692591
2079    0.69259
2080    0.692592
2081    0.692594
2082    0.692593
2083    0.692592
2084    0.692592
2085    0.692592
2086    0.692593
2087    0.692593
2088    0.692593
2089    0.692593
2090    0.692593
2091    0.692593
2092    0.692593
2093    0.692593
2094    0.692593
2095    0.692593
2096    0.692593
2097    0.692593
2098    0.692593
2099    0.692593
2100    0.692593
/
;
table i01SFCPC(allCy,TTECH,EF,YTIME)                     "Initial Specific fuel consumption (toe/vkm)"
$ondelim
$include"./iSFC.csv"
$offdelim
;
i01SFCPC(allCy,TTECH,"BGSL",YTIME) = i01SFCPC(allCy,TTECH,"GSL",YTIME);
i01SFCPC(allCy,TTECH,"BGDO",YTIME) = i01SFCPC(allCy,TTECH,"GDO",YTIME);
i01SFCPC(allCy,TTECH,"OGS",YTIME) = i01SFCPC(allCy,TTECH,"NGS",YTIME);
parameter i01InitSpecFuelConsData(TRANSE,TTECH,EF)      "Initial Specific fuel consumption: (ktoe/Gvkm)" /
PT.TGDO.GDO	11.
PT.TGDO.BGDO	11.
PT.TH2F.H2F	8.9
PT.TELC.ELC	7
PA.TKRS.KRS	20
PN.TGDO.GDO  30
PN.TGDO.BGDO  30
PN.TH2F.H2F  43
PB.TGDO.GDO  7.8
PB.TGDO.BGDO  7.8
PB.TNGS.NGS  5.6
PB.TNGS.OGS  5.6
PB.TLPG.LPG  6.6
PB.TELC.ELC  2.5
PB.TH2F.H2F  4.3
GU.TGSL.GSL	6.0
GU.TGSL.BGSL	6.0
GU.TLPG.LPG	5.0
GU.TGDO.GDO	4.0
GU.TGDO.BGDO	4.0
GU.TNGS.NGS	2.8
GU.TNGS.OGS	2.8
GU.TH2F.H2F	1.3
GU.TELC.ELC	1.0
GU.TCHEVGDO.GDO	2.7
GT.TGDO.GDO	1.9
GT.TGDO.BGDO	1.9
GT.TH2F.H2F	1.5
GT.TELC.ELC	1.9
GN.TGSL.GSL	2.0
GN.TGSL.BGSL	2.0
GN.TGDO.GDO	2.5
GN.TGDO.BGDO	2.5
GN.TH2F.H2F	1.5
/
;
Parameters
i01GdpPassCarsMarkExt(allCy)	                          "GDP-dependent passenger cars market extension (GDP/capita)"
i01PassCarsScrapRate(allCy)	                          "Passenger cars scrapping rate (1)"
i01ShareAnnMilePlugInHybrid(allCy,YTIME)	           "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
i01AvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	      "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)"
i01TechLft(allCy,SBS,TECH,YTIME)	                     "Technical Lifetime. For passenger cars it is a variable (1)"
i01PassCarsMarkSat(allCy)	                          "Passenger cars ownership saturation threshold (1)"
i01GDPperCapita(YTIME,allCy)
i01Sigma(allCy,SG)                                   "S parameters of Gompertz function for passenger cars vehicle km (1)"
i01ShareTTechFuel(allCy,TRANSE,TTECH,EF)
;
i01PassCarsMarkSat(runCy) = 0.7;
i01ShareAnnMilePlugInHybrid(runCy,YTIME) = i01PlugHybrFractData(YTIME);
i01AvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE);
i01TechLft(runCy,TRANSE,TTECH,YTIME) = imDataTransTech(TRANSE,TTECH,"LFT",YTIME);
i01TechLft(runCy,TRANSE,TTECH,YTIME) = 20;
i01TechLft(runCy,INDSE,ITECH,YTIME) = imDataIndTechnology(INDSE,ITECH,"LFT");
i01TechLft(runCy,DOMSE,ITECH,YTIME) = imDataDomTech(DOMSE,ITECH,"LFT");
i01TechLft(runCy,NENSE,ITECH,YTIME) = imDataNonEneSec(NENSE,ITECH,"LFT");
i01GDPperCapita(YTIME,runCy) = i01GDP(YTIME,runCy) / i01Pop(YTIME,runCy);
i01ShareTTechFuel(runCy,TRANSE,TTECH,EF)$(SECTTECH(TRANSE,TTECH) and not ((sameas("TPHEVGSL",TTECH) or sameas("TPHEVGDO",TTECH)) and ELCEF(EF)))
=
(
  imFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") /
  (SUM(EF2$TTECHtoEF(TTECH,EF2),imFuelConsPerFueSub(runCy,TRANSE,EF2,"%fBaseY%")))
 )$(SUM(EF2$TTECHtoEF(TTECH,EF2),imFuelConsPerFueSub(runCy,TRANSE,EF2,"%fBaseY%"))$(TTECHtoEF(TTECH,EF)));
```

*VARIABLE INITIALISATION*
```
V01RateScrPcTot.UP(runCy,TTECH,YTIME) = 1;
V01PcOwnPcLevl.UP(runCy,YTIME) = 2*i01PassCarsMarkSat(runCy);
V01PremScrp.UP(runCy,TRANSE,TTECH,YTIME) = 1;
V01RateScrPc.UP(runCy,TTECH,YTIME) = 1;
V01RateScrPc.LO(runCy,TTECH,YTIME) = 0;
V01PremScrp.LO(runCy,TRANSE,TTECH,YTIME) = 0;
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,"PC");
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = imTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = imActv(YTIME,runCy,TRANP); 
V01NewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = i01NewReg(runCy,YTIME);
V01RateScrPc.L(runCy,TTECH,YTIME) = 0.05;
V01RateScrPc.FX(runCy,TTECH,YTIME)$(not SECTTECH("PC",TTECH)) = 0; 
V01RateScrPc.FX(runCy,TTECH,YTIME)$(DATAY(YTIME) and SECTTECH("PC",TTECH)) = 1 / i01TechLft(runCy,"PC",TTECH,YTIME); 
V01RateScrPcTot.FX(runCy,TTECH,YTIME)$DATAY(YTIME) = V01RateScrPc.L(runCy,TTECH,YTIME);
V01StockPcYearlyTech.FX(runCy,TTECH,"%fBaseY%") = i01StockPC(runCy,TTECH,"%fBaseY%");
V01NumPcScrap.FX(runCy,YTIME)$sameas(YTIME,"%fBaseY%") = SUM(TTECH,V01RateScrPcTot.L(runCy,TTECH,YTIME) * V01StockPcYearlyTech.L(runCy,TTECH,YTIME)); 
V01CostTranspPerMeanConsSize.LO(runCy,TRANSE,TTECH,YTIME) = epsilon6;
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
V01PcOwnPcLevl.FX(runCy,YTIME)$(not An(YTIME)) = V01StockPcYearly.L(runCy,YTIME) / (i01Pop(YTIME,runCy) * 1000) ;
i01Sigma(runCy,"S2") = 0.5;
i01Sigma(runCy,"S1") = -log(V01PcOwnPcLevl.L(runCy,"%fBaseY%") / i01PassCarsMarkSat(runCy)) * EXP(i01Sigma(runCy,"S2") * i01GDPperCapita("%fBaseY%",runCy) / 10000);
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(not sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01InitSpecFuelConsData(TRANSE,TTECH,EF);
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01SFCPC(runCy,TTECH,EF,YTIME);
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) = 0;
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECtoEF(TRANSE,EF) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECtoEF(TRANSE,EF)) = 0;
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


---------------------------------------------------------------------------------------------
            &nbsp;                       Description                    Unit           A   B 
------------------------------ -------------------------------- --------------------- --- ---
             Cap                              LF                                       x   x 

              GN                           1500 0.9                                    x   x 

              GT                           600 0.8                                     x   x 

              GU                            5 0.7                                      x   x 

     i01AvgVehCapLoadFac         Average capacity/vehicle and          $tn/veh         x   x 
              \                          load factor                     or                  
       (allCy, TRANSE,                                            passenegers/veh$           
          TRANSUSE,                                                                          
            YTIME)                                                                           

 i01CapDataLoadFacEachTransp    Capacity data and Load factor        $passenger        x   x 
              \                  for each transportation mode            or                  
           (TRANSE,                                                tonnes/vehicle$           
          TRANSUSE)                                                                          

          i01GDP \                           GDP                      $billion         x   x 
        (YTIME, allCy)                                                US\$2015$              

    i01GdpPassCarsMarkExt        GDP-dependent passenger cars       $GDP/capita$       x   x 
              \                        market extension                                      
           (allCy)                                                                           

       i01GDPperCapita                                                                 x   x 
              \                                                                              
        (YTIME, allCy)                                                                       

   i01InitSpecFuelConsData          Initial Specific fuel             $toe/vkm$        x   x 
              \                          consumption                                         
       (TRANSE, TTECH,                                                                       
             EF)                                                                             

         i01NewReg \            new car registrations per year                         x   x 
        (allCy, YTIME)                                                                       

      i01PassCarsMarkSat           Passenger cars ownership              $1$           x   x 
              \                      saturation threshold                                    
           (allCy)                                                                           

     i01PassCarsScrapRate       Passenger cars scrapping rate            $1$           x   x 
              \                                                                              
           (allCy)                                                                           

     i01PlugHybrFractData         Plug in hybrid fraction of                           x   x 
              \                            mileage                                           
           (YTIME)                                                                           

          i01Pop \                        Population                  $billion$        x   x 
        (YTIME, allCy)                                                                       

         i01SFCPC \                 Initial Specific fuel             $toe/vkm$        x   x 
        (allCy, TTECH,                   consumption                                         
          EF, YTIME)                                                                         

 i01ShareAnnMilePlugInHybrid     Share of annual mileage of a            $1$           x   x 
              \                    plug-in hybrid which is                                   
        (allCy, YTIME)              covered by electricity                                   

      i01ShareTTechFuel                                                                    x 
              \                                                                              
       (allCy, TRANSE,                                                                       
          TTECH, EF)                                                                         

         i01Sigma \                S parameters of Gompertz              $1$           x   x 
         (allCy, SG)             function for passenger cars                                 
                                          vehicle km                                         

        i01StockPC \               Car stock per technology             $10^6          x   x 
        (allCy, TTECH,                                                vehicles$              
            YTIME)                                                                           

        i01TechLft \               Technical Lifetime. For               $1$           x   x 
         (allCy, SBS,               passenger cars it is a                                   
         TECH, YTIME)                      variable                                          

              PA                           180 0.65                                    x   x 

              PB                            40 0.4                                     x   x 

              PC                              2                                        x   x 

              PN                           300 0.5                                     x   x 

              PT                           300 0.4                                     x   x 

     Q01ActivGoodsTransp           Compute goods transport                             x   x 
              \                            activity                                          
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

      Q01ActivPassTrnsp          Compute passenger transport                           x   x 
              \                           acitivity                                          
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

     Q01CapCostAnnualized                                                                  x 
              \                                                                              
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

     Q01ConsSpecificFuel            Compute Specific Fuel                              x     
              \                          Consumption                                         
       (allCy, TRANSE,                                                                       
          TTECH, EF,                                                                         
            YTIME)                                                                           

  Q01ConsTechTranspSectoral      Compute consumption of each                           x   x 
              \                    technology in transport                                   
       (allCy, TRANSE,                     sectors                                           
          TTECH, EF,                                                                         
            YTIME)                                                                           

        Q01CostFuel \                                                                      x 
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

     Q01CostTranspMatFac         Compute transportation cost                           x     
              \                   including maturity factor                                  
       (allCy, TRANSE,                                                                       
         RCon, TTECH,                                                                        
            YTIME)                                                                           

 Q01CostTranspPerMeanConsSize    Compute transportation cost                           x   x 
              \                 per mean and consumer size in                                
       (allCy, TRANSE,               KUS$2015 per vehicle                                    
         RCon, TTECH,                                                                        
            YTIME)                                                                           

     Q01CostTranspPerVeh         Compute transportation cost                           x     
              \                 per mean and consumer size in                                
       (allCy, TRANSE,               KUS$2015 per vehicle                                    
         RCon, TTECH,                                                                        
            YTIME)                                                                           

  Q01DemFinEneTranspPerFuel     Compute final energy demand in                         x   x 
              \                       transport per fuel                                     
       (allCy, TRANSE,                                                                       
          EF, YTIME)                                                                         

      Q01GapTranspActiv          Compute the gap in transport                          x   x 
              \                            activity                                          
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

          Q01Lft \                 Compute the lifetime of                             x   x 
        (allCy, DSBS,                   passenger cars                                       
         TECH, YTIME)                                                                        

      Q01NewRegPcYearly          Compute new registrations of                          x   x 
              \                 passenger cars per technology                                
        (allCy, YTIME)                                                                       

       Q01NumPcScrap \            Compute scrapped passenger                           x   x 
        (allCy, YTIME)                       cars                                            

        Q01PcOwnPcLevl          Compute ratio of car ownership                         x   x 
              \                 over saturation car ownership                                
        (allCy, YTIME)                                                                       

        Q01PremScrp \                                                                      x 
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

       Q01RateScrPc \               Compute passenger cars                             x   x 
        (allCy, YTIME)                  scrapping rate                                       

       Q01RateScrPcTot                                                                     x 
              \                                                                              
        (allCy, TTECH,                                                                       
            YTIME)                                                                           

        Q01ShareTechTr            Compute technology sorting                           x   x 
              \                 based on variable cost and new                               
       (allCy, TRANSE,                    equipment                                          
         TECH, YTIME)                                                                        

       Q01StockPcYearly           Compute stock of passenger             $in           x   x 
              \                              cars                       10^6                 
        (allCy, YTIME)                                                vehicles$              

     Q01StockPcYearlyTech         Compute stock of passenger             $in           x   x 
              \                              cars                       10^6                 
        (allCy, TTECH,                                                vehicles$              
            YTIME)                                                                           

      Q01TechSortVarCost          Compute technology sorting                           x     
              \                     based on variable cost                                   
       (allCy, TRANSE,                                                                       
         Rcon, YTIME)                                                                        

     V01ActivGoodsTransp          Goods transport acitivity            $Gtkm$          x   x 
              \                                                                              
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

      V01ActivPassTrnsp          Passenger transport activity            $1$           x   x 
              \                                                                              
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

     V01CapCostAnnualized                                                                  x 
              \                                                                              
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

     V01ConsSpecificFuel          Specific Fuel Consumption                            x   x 
              \                                                                              
       (allCy, TRANSE,                                                                       
          TTECH, EF,                                                                         
            YTIME)                                                                           

  V01ConsTechTranspSectoral     Consumption of each technology         $Mtoe$          x   x 
              \                         and subsector                                        
       (allCy, TRANSE,                                                                       
          TTECH, EF,                                                                         
            YTIME)                                                                           

        V01CostFuel \                                                                      x 
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

     V01CostTranspMatFac        Transportation cost including    $KUS\$2015/vehicle$   x     
              \                        maturity factor                                       
       (allCy, TRANSE,                                                                       
         RCon, TTECH,                                                                        
            YTIME)                                                                           

 V01CostTranspPerMeanConsSize    Transportation cost per mean    $KUS\$2015/vehicle$   x   x 
              \                       and consumer size                                      
       (allCy, TRANSE,                                                                       
         RCon, TTECH,                                                                        
            YTIME)                                                                           

     V01CostTranspPerVeh         Transportation cost per mean    $KUS\$2015/vehicle$   x     
              \                       and consumer size                                      
       (allCy, TRANSE,                                                                       
         RCon, TTECH,                                                                        
            YTIME)                                                                           

      V01GapTranspActiv          Gap in transport activity to                          x   x 
              \                 be filled by new technologies                                
       (allCy, TRANSE,                                                                       
            YTIME)                                                                           

      V01NewRegPcYearly               Passenger cars new                $10^6          x   x 
              \                         registrations                 vehicles$              
        (allCy, YTIME)                                                                       

       V01NumPcScrap \             Scrapped passenger cars              $10^6          x   x 
        (allCy, YTIME)                                                vehicles$              

        V01PcOwnPcLevl           Ratio of car ownership over             $1$           x   x 
              \                    saturation car ownership                                  
        (allCy, YTIME)                                                                       

        V01PremScrp \                                                                      x 
       (allCy, TRANSE,                                                                       
        TTECH, YTIME)                                                                        

       V01RateScrPc \            Scrapping rate of passenger             $1$           x   x 
        (allCy, YTIME)                       cars                                            

       V01RateScrPcTot                                                                     x 
              \                                                                              
        (allCy, TTECH,                                                                       
            YTIME)                                                                           

        V01ShareTechTr             Technology share in new               $1$           x   x 
              \                           equipment                                          
       (allCy, TRANSE,                                                                       
         TECH, YTIME)                                                                        

       V01StockPcYearly            Stock of passenger cars              $10^6          x   x 
              \                                                       vehicles$              
        (allCy, YTIME)                                                                       

     V01StockPcYearlyTech        stock of passenger cars per             $in           x   x 
              \                           technology                    10^6                 
        (allCy, TTECH,                                                vehicles$              
            YTIME)                                                                           

      V01TechSortVarCost         Technology sorting based on             $1$           x     
              \                         variable cost                                        
       (allCy, TRANSE,                                                                       
         Rcon, YTIME)                                                                        
---------------------------------------------------------------------------------------------

Table: module-internal objects (A: legacy | B: simple)



### Sets


---------------------------------------------------
      &nbsp;                 description           
------------------ --------------------------------
      allCy           All Countries Used in the    
                                Model              

    an(ytime)        Years for which the model is  
                               running             

   CHYBV(TECH)           CONVENTIONAL hybrids      

      conSet         Consumer size groups related  
                           to space heating        

   DOMSE(DSBS)           Tertiary SubSectors       

    DSBS(SBS)           All Demand Subsectors      

     ECONCHAR            Technical - Economic      
                      characteristics for demand   
                             technologies          

        EF                   Energy Forms          

    ELCEF(EF)                Electricity           

      ETYPES              Elasticities types       

   INDSE(DSBS)          Industrial SubSectors      

   ITECH(TECH)         Industrial - Domestic -     
                         Non-energy & Bunkers      
                             Technologies          

       kpdl             counter for Polynomial     
                           Distribution Lag        

   NENSE(DSBS)          Non Energy and Bunkers     

   PLUGIN(TECH)            Plug-in hybrids         

       rCon           counter for the number of    
                              consumers            

   RENEF(TECH)        Renewable technologies in    
                             demand side           

   runCy(allCy)     Countries for which the model  
                              is running           

  runCyL(allCy)     Countries for which the model  
                    is running (used in countries  
                                loop)              

   SBS(ALLSBS)             Model Subsectors        

   SECtoEF(SBS,     Link between Model Subsectors  
       EF)                 and Energy FORMS        

  SECTTECH(DSBS,      Link between Model Demand    
      TECH)          Subsectors and Technologies   

        SG             S parameters in Gompertz    
                     function for passenger cars   
                              per capita           

       TECH                  Technologies          

  TRANG(TRANSE)            Goods Transport         

  TRANP(TRANSE)          Passenger Transport       

   TRANSE(DSBS)        All Transport Subsectors    

    TRANSPCHAR      Various transport data used in 
                     equations and post-solution   
                             calculations          

     TRANSUSE            Usage (average) data      
                     concerning capacity and load  
                                factor             

   TTECH(TECH)          Transport Technologies     

 TTECHtoEF(TTECH,    Fuels consumed by transport   
       EF)                   technologies          

      ytime               Model time horizon       
---------------------------------------------------

Table: sets in use



See Also
--------

[02_Industry], [03_RestOfEnergy], [04_PowerGeneration], [05_Hydrogen], [08_Prices], [core]

