Prices module (08_Prices) {#id-08_Prices}
=========================

Description
-----------

This is the Prices module.


Interfaces
----------

**Interface plot missing!**

### Input


--------------------------------------------------------------------------------
          &nbsp;                     Description                 Unit         A 
-------------------------- ------------------------------- ----------------- ---
       VmCarVal \               Carbon prices for all        $US\$2015/tn     x 
       (allCy, NAP,                   countries                  CO2$           
          YTIME)                                                                

      VmConsFuel \          Consumption of fuels in each        $Mtoe$        x 
      (allCy, DSBS,          demand subsector, excluding                        
        EF, YTIME)               heat from heatpumps                            

     VmCostAvgProdH2         Average production cost of                       x 
            \                 hydrogen in Euro per toe                          
      (allCy, YTIME)                                                            

     VmCostAvgProdSte           Average cost of steam       $kUS\$2015/toe$   x 
            \                        production                                 
      (allCy, YTIME)                                                            

    VmCostPowGenAvgLng         Long-term average power      $US\$2015/kWh$    x 
            \                      generation cost                              
      (allCy, ESET,                                                             
          YTIME)                                                                

 VmDemFinEneTranspPerFuel      Final energy demand in           $Mtoe$        x 
            \               transport subsectors per fuel                       
     (allCy, TRANSE,                                                            
        EF, YTIME)                                                              
--------------------------------------------------------------------------------

Table: module inputs (A: legacy)



### Output


---------------------------------------------------------------------------
         &nbsp;                     Description                  Unit      
------------------------- -------------------------------- ----------------
     VmPriceElecInd        Electricity index - a function        $1$       
           \                     of industry price                         
     (allCy, YTIME)                                                        

 VmPriceElecIndResConsu         Electricity price to        $US\$2015/KWh$ 
            \                Industrial and Residential                    
      (allCy, ESET,                  Consumers                             
         YTIME)                                                            

    VmPriceFuelAvgSub         Average fuel prices per       $k\$2015/toe$  
            \                        subsector                             
      (allCy, DSBS,                                                        
         YTIME)                                                            

 VmPriceFuelSubsecCarVal   Fuel prices per subsector and    $k\$2015/toe$  
            \                           fuel                               
      (allCy, SBS,                                                         
       EF, YTIME)                                                          
---------------------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the Prices module.


```
Equations
```
*** Prices
```
Q08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
```
**Interdependent Equations**
```
Q08PriceElecIndResConsu(allCy,ESET,YTIME)                  "Compute electricity price in Industrial and Residential Consumers"
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)               "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)	                   "Compute average fuel price per subsector" 	
Q08PriceElecInd(allCy,YTIME)                               "Compute electricity industry prices"
;
Variables
```
*** Prices Variables
```
V08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME)	           "Fuel prices per subsector and fuel  mutliplied by weights (kUS$2015/toe)"
```
**Interdependent Variables**
```
VmPriceElecIndResConsu(allCy,ESET,YTIME)	               "Electricity price to Industrial and Residential Consumers (US$2015/KWh)"
VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)                "Fuel prices per subsector and fuel (k$2015/toe)"
VmPriceFuelAvgSub(allCy,DSBS,YTIME)                        "Average fuel prices per subsector (k$2015/toe)"
VmPriceElecInd(allCy,YTIME)                                "Electricity index - a function of industry price (1)"
```
*** Miscellaneous
```
V08FuelPriSubNoCarb(allCy,SBS,EF,YTIME)	                   "Fuel prices per subsector and fuel  without carbon value (kUS$2015/toe)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* Prices
The equation computes fuel prices per subsector and fuel with separate carbon values in
each sector for a specific scenario, subsector, fuel, and year.The equation considers various scenarios based
on the type of fuel and whether it is subject to changes in carbon values. It incorporates factors such as carbon emission factors
carbon values for all countries, electricity prices to industrial and residential consumers,
efficiency values, and the total hydrogen cost per sector.The result of the equation is the fuel price per 
subsector and fuel, adjusted based on changes in carbon values, electricity prices, efficiency, and hydrogen costs.
```
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF) $TIME(YTIME)
$IFTHEN %link2MAgPIE% == on 
   $(not sameas("BMSWAS",EF))
$ENDIF
   $(not sameas("NUC",EF)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)
        =E=
    (VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1) +
      sum(NAP$NAPtoALLSBS(NAP,SBS),
      VmCarVal(allCy,NAP,YTIME)*imCo2EmiFac(allCy,SBS,EF,YTIME) - 
      VmCarVal(allCy,NAP,YTIME-1)*imCo2EmiFac(allCy,SBS,EF,YTIME-1)
      )
      /1000
    )$(DSBS(SBS))$(not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF) or H2EF(EF) or sameas("STE",EF))) +
    (
      VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)
      !!We should account for carbon tax increase for the own consumption emissions
    )$sameas(SBS,"PG") +
    VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF) +
    (
      ( VmPriceElecIndResConsu(allCy,"i",YTIME)$INDSE1(SBS)+
        VmPriceElecIndResConsu(allCy,"r",YTIME)$HOU1(SBS) +
        VmPriceElecIndResConsu(allCy,"t",YTIME)$TRANS1(SBS) +
        VmPriceElecIndResConsu(allCy,"c",YTIME)$SERV(SBS)
      )/smTWhToMtoe
      +
      ((imEffValueInDollars(allCy,SBS,YTIME))/1000)$DSBS(SBS)
    )$(ELCEF(EF) or HEATPUMP(EF)) +
    (
      VmPriceFuelSubsecCarVal(allCy,"OI",EF,YTIME)$(not sameas("BMSWAS",EF) or not sameas("CRO",EF)) +
      VmPriceFuelSubsecCarVal(allCy,"AG",EF,YTIME)$sameas("BMSWAS",EF)
    )$(sameas ("H2P",SBS) or sameas("STEAMP",SBS)) +
    (VmCostAvgProdH2(allCy,YTIME)$DSBS(SBS)/1000)$H2EF(EF) +
    (VmCostAvgProdSte(allCy,YTIME)$DSBS(SBS))$sameas("STE",EF);
$ontext
```
The equation calculates the fuel prices per subsector and fuel multiplied by weights
considering separate carbon values in each sector. This equation is applied for a specific scenario, subsector, fuel, and year.
The calculation involves multiplying the sector's average price weight based on fuel consumption by the fuel price per subsector
and fuel. The weights are determined by the sector's average price, considering the specific fuel consumption for the given scenario, subsector, and fuel.
This equation allows for a more nuanced calculation of fuel prices, taking into account the carbon values in each sector. The result represents the fuel
prices per subsector and fuel, multiplied by the corresponding weights, and adjusted based on the specific carbon values in each sector.
```
Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
    V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E= 
    !!i08WgtSecAvgPriFueCons(allCy,DSBS,EF) * 
    !!(
    1e-2+
      (
        (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) / 
        (SUM(EF2,VmConsFuel(allCy,DSBS,EF2,YTIME)- V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) )
      )$INDSE(DSBS) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)
      +
      SUM(TRANSE$TRANSE(DSBS), 
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
        1!!SUM(EF2,VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME))
      )$TRANSE(DSBS)
    ) *
    VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME);
$offtext
Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
      1e-12 +
      (
        (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) /
        (SUM(EF2,VmConsFuel(allCy,DSBS,EF2,YTIME)- V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) )
      )$(INDDOM(DSBS) or NENSE(DSBS)) +   
      SUM(TRANSE$(sameas(TRANSE,DSBS)),
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
        (SUM(EF2$SECtoEF(TRANSE,EF2),VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME))+1e-12)
      )
;
```
The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
(using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
In the transport sector they feed into the calculation of the activity levels.
```
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceFuelAvgSub(allCy,DSBS,YTIME)
        =E=
    sum(EF$SECtoEF(DSBS,EF), 
      V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME-1) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1));         
```
Calculates electricity price for industrial and residential consumers
using previous year's fuel prices. For the first year, the price is directly based on fuel data.
For later years, the price is scaled using a ratio of 2021 electricity price to 2021 average generation cost
to ensure smoothness between historical and non-historical years.
```
Q08PriceElecIndResConsu(allCy,ESET,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecIndResConsu(allCy,ESET,YTIME) !!Cost final electricity
        =E=
    (1 + i08VAT(allCy,YTIME)) *
    (
      (
      (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
      (
        VmPriceElecIndResConsu(allCy,"i","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
        VmCostPowGenAvgLng(allCy,YTIME-1) !!Cost secondary energy electricity
      )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"i") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"HOU","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"r","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"r") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"PC","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"t","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"t") +
      (
        (VmPriceFuelSubsecCarVal(allCy,"SE","ELC",YTIME-1)*smTWhToMtoe)$TFIRST(YTIME-1) +
        (
          VmPriceElecIndResConsu(allCy,"c","%fStartY%") / VmCostPowGenAvgLng(allCy, "%fStartY%") *
          VmCostPowGenAvgLng(allCy,YTIME-1) 
        )$(not TFIRST(YTIME-1))
      )$sameas(ESET,"c") 
    );
```
This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
```
$ontext
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) $runCy(allCy))..
        VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                =E=   
             (((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) + (VmRenValue(YTIME)/1000)$(not RENEF(EF))+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF))))  ) )/2;
$offtext
```
This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
technical constraints, providing a realistic representation of the electricity market in the industrial sector.
```
Q08PriceElecInd(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecInd(allCy,YTIME) 
        =E=
    (
      V02IndxElecIndPrices(allCy,YTIME) + smElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,YTIME)-smElecToSteRatioChp))
    )/2;
```

```
$IFTHEN %link2MAgPIE% == on
table iPricesMagpie(allCy,SBS,YTIME)	"Prices of biomass per subsector (k$2015/toe)"
$ondelim
$include "./iPrices_magpie.csv"
$offdelim
;
$ENDIF
Parameters
i08DiffFuelsInSec(SBS)                    "Auxiliary parameter holding the number of different fuels in a sector"
i08WgtSecAvgPriFueCons(allCy,SBS,EF)	    "Weights for sector's average price, based on fuel consumption (1)"
i08VAT(allCy,YTIME)                       "VAT (value added tax) rates (1)"
;
loop SBS do
         i08DiffFuelsInSec(SBS) = 0;
         loop EF$(SECtoEF(SBS,EF))  do
              i08DiffFuelsInSec(SBS) = i08DiffFuelsInSec(SBS)+1;
         endloop;
endloop;
i08WgtSecAvgPriFueCons(runCy,TRANSE,EF)$SECtoEF(TRANSE,EF) = (imFuelConsPerFueSub(runCy,TRANSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"))$imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%")
                                               + (1/i08DiffFuelsInSec(TRANSE))$(not imTotFinEneDemSubBaseYr(runCy,TRANSE,"%fBaseY%"));
i08WgtSecAvgPriFueCons(runCy,NENSE,EF)$SECtoEF(NENSE,EF) = ( imFuelConsPerFueSub(runCy,NENSE,EF,"%fBaseY%") / imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%") )$imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%")
                                             + (1/i08DiffFuelsInSec(NENSE))$(not imTotFinEneDemSubBaseYr(runCy,NENSE,"%fBaseY%"));
i08WgtSecAvgPriFueCons(runCy,INDDOM,EF)$(SECtoEF(INDDOM,EF)) = 
(
  (imFuelConsPerFueSub(runCy,INDDOM,EF,"%fBaseY%") - (imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"))$ELCEF(EF)) / 
  (imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%")) 
)$(imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"))
+ (1/i08DiffFuelsInSec(INDDOM))$(not imTotFinEneDemSubBaseYr(runCy,INDDOM,"%fBaseY%") - imShrNonSubElecInTotElecDem(runCy,INDDOM) * imFuelConsPerFueSub(runCy,INDDOM,"ELC","%fBaseY%"));
i08WgtSecAvgPriFueCons(runCy,SBS,EF)$(SECtoEF(SBS,EF) $sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2))) = i08WgtSecAvgPriFueCons(runCy,SBS,EF)/sum(ef2$SECtoEF(SBS,EF),i08WgtSecAvgPriFueCons(runCy,SBS,EF2));
i08VAT(runCy, YTIME) = 0;
imFuelPrice(runCy,SBS,EF,YTIME) = imFuelPrice(runCy,SBS,EF,YTIME)/1000; !! change units $15 -> k$15
imFuelPrice(runCy,"BU","KRS",YTIME) = imFuelPrice(runCy,"PA","KRS",YTIME);
```

*VARIABLE INITIALISATION*
```
VmPriceElecIndResConsu.FX(runCy,"i",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"r",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"t",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"PC","ELC",YTIME)*smTWhToMtoe;
VmPriceElecIndResConsu.FX(runCy,"c",YTIME)$(not An(YTIME)) = VmPriceFuelSubsecCarVal.L(runCy,"SE","ELC",YTIME)*smTWhToMtoe;
V08PriceFuelSepCarbonWght.FX(runCy,DSBS,EF,YTIME)$(not AN(YTIME)) = i08WgtSecAvgPriFueCons(runCy,DSBS,EF);
VmPriceFuelAvgSub.L(runCy,DSBS,YTIME) = 0.001;
VmPriceFuelAvgSub.FX(runCy,DSBS,YTIME)$DATAY(YTIME) = sum(EF$SECtoEF(DSBS,EF), i08WgtSecAvgPriFueCons(runCy,DSBS,EF) * imFuelPrice(runCy,DSBS,EF,YTIME));
V08FuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECtoEF(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = imFuelPrice(runCy,SBS,EF,YTIME);
V08FuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECtoEF(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),imFuelPrice(runCy,SBS,EF,YTIME));
V08FuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
V08FuelPriSubNoCarb.FX(runCy,INDDOM,"HEATPUMP",YTIME)$(SECtoEF(INDDOM,"HEATPUMP")$(not An(YTIME))) = imFuelPrice(runCy,INDDOM,"ELC",YTIME);
$ontext
VmPriceFuelSubsecCHP.FX(runCy,DSBS,EF,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECtoEF(DSBS,EF)) =
(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VmPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+imVarCostTech(runCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*smFracElecPriChp*i08ElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
$offtext
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


----------------------------------------------------------------------------------
          &nbsp;                      Description                  Unit         A 
--------------------------- -------------------------------- ----------------- ---
     i08DiffFuelsInSec        Auxiliary parameter holding                       x 
             \               the number of different fuels                        
           (SBS)                      in a sector                                 

         i08VAT \             VAT (value added tax) rates           $1$         x 
      (allCy, YTIME)                                                              

  i08WgtSecAvgPriFueCons      Weights for sector's average          $1$         x 
             \                    price, based on fuel                            
       (allCy, SBS,                   consumption                                 
            EF)                                                                   

      iPricesMagpie \            Prices of biomass per         $k\$2015/toe$    x 
       (allCy, SBS,                    subsector                                  
          YTIME)                                                                  

      Q08PriceElecInd         Compute electricity industry                      x 
            \                            prices                                   
      (allCy, YTIME)                                                              

  Q08PriceElecIndResConsu     Compute electricity price in                      x 
             \                 Industrial and Residential                         
       (allCy, ESET,                   Consumers                                  
          YTIME)                                                                  

    Q08PriceFuelAvgSub       Compute average fuel price per                     x 
             \                         subsector                                  
       (allCy, DSBS,                                                              
          YTIME)                                                                  

 Q08PriceFuelSepCarbonWght      Compute fuel prices per                         x 
             \                subsector and fuel, separate                        
       (allCy, SBS,           carbon value in each sector                         
        EF, YTIME)                                                                

 Q08PriceFuelSubsecCarVal       Compute fuel prices per                         x 
             \                subsector and fuel, separate                        
       (allCy, SBS,           carbon value in each sector                         
        EF, YTIME)                                                                

    V08FuelPriSubNoCarb      Fuel prices per subsector and    $kUS\$2015/toe$   x 
             \                 fuel without carbon value                          
       (allCy, SBS,                                                               
        EF, YTIME)                                                                

 V08PriceFuelSepCarbonWght   Fuel prices per subsector and    $kUS\$2015/toe$   x 
             \                 fuel mutliplied by weights                         
       (allCy, SBS,                                                               
        EF, YTIME)                                                                
----------------------------------------------------------------------------------

Table: module-internal objects (A: legacy)



### Sets


---------------------------------------------------
      &nbsp;                  description          
------------------- -------------------------------
       allCy           All Countries Used in the   
                                 Model             

     ALTEF(EF)         Alternative Fuels used in   
                               transport           

  ALTMAP(SBS, EF,    Fuels whose prices affect the 
        EF)           prices of alternative fuels  

  biomass(balef)                                   

     DSBS(SBS)           All Demand Subsectors     

        EF                   Energy Forms          

     ELCEF(EF)                Electricity          

     H2EF(EF)                  Hydrogen            

   HEATPUMP(EF)       Heatpumps are reducing the   
                       heat requirements of the    
                         sector but increasing     
                        electricity consumption    

        HOU               11.511 0.9 0.00001       

     HOU1(SBS)                Households           

   INDDOM(DSBS)          Industry and Tertiary     

    INDSE1(SBS)          Industrial SubSectors     

 NAP(Policies_set)     National Allocation Plan    
                           sector categories       

 NAPtoALLSBS(NAP,    Energy sectors corresponding  
      ALLSBS)               to NAP sectors         

    NENSE(DSBS)         Non Energy and Bunkers     

   runCy(allCy)      Countries for which the model 
                              is running           

   runCyL(allCy)     Countries for which the model 
                     is running (used in countries 
                                 loop)             

    SBS(ALLSBS)            Model Subsectors        

   SECtoEF(SBS,      Link between Model Subsectors 
        EF)                and Energy FORMS        

     SERV(SBS)                 Services            

    TRANS1(SBS)        All Transport Subsectors    

   TRANSE(DSBS)        All Transport Subsectors    
---------------------------------------------------

Table: sets in use



See Also
--------

[01_Transport], [02_Industry], [04_PowerGeneration], [05_Hydrogen], [06_CO2], [09_Heat], [core]

