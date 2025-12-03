RestOfEnergy module (03_RestOfEnergy) {#id-03_RestOfEnergy}
=====================================

Description
-----------

This is the RestOfEnergy module.


Interfaces
----------

**Interface plot missing!**

### Input


-----------------------------------------------------------------------
          &nbsp;                     Description             Unit    A 
-------------------------- ------------------------------- -------- ---
      VmConsFuel \          Consumption of fuels in each    $Mtoe$   x 
      (allCy, DSBS,          demand subsector, excluding               
        EF, YTIME)               heat from heatpumps                   

    VmConsFuelDACProd         Annual fuel demand in DAC     $Mtoe$   x 
            \                        regionally                        
       (allCy, EF,                                                     
          YTIME)                                                       

    VmConsFuelElecProd                                               x 
            \                                                          
       (allCy, EFS,                                                    
          YTIME)                                                       

     VmConsFuelH2Prod        Total fuel consumption for              x 
            \                hydrogen production in Mtoe               
       (allCy, EF,                                                     
          YTIME)                                                       

    VmConsFuelSteProd                                                x 
            \                                                          
         (allCy,                                                       
      STEMODE, EFS,                                                    
          YTIME)                                                       

 VmDemFinEneTranspPerFuel      Final energy demand in       $Mtoe$   x 
            \               transport subsectors per fuel              
     (allCy, TRANSE,                                                   
        EF, YTIME)                                                     

      VmDemSecH2 \           Demand for H2 by sector in              x 
       (allCy, SBS,                     mtoe                           
          YTIME)                                                       

      VmDemTotH2 \               Hydrogen production                 x 
      (allCy, YTIME)           requirement in Mtoe for                 
                                meeting final demand                   

      VmDemTotSte \                                                  x 
      (allCy, YTIME)                                                   

      VmProdElec \             Electricity production       $TWh$    x 
      (allCy, PGALL,                                                   
          YTIME)                                                       

       VmProdH2 \              Hydrogen Production by                x 
     (allCy, H2TECH,             technology in Mtoe                    
          YTIME)                                                       

       VmProdSte \                                                   x 
     (allCy, TSTEAM,                                                   
          YTIME)                                                       
-----------------------------------------------------------------------

Table: module inputs (A: legacy)



### Output


-------------------------------------------------------------
       &nbsp;                  Description             Unit  
--------------------- ------------------------------ --------
   VmConsFiEneSec      Final consumption in energy    $Mtoe$ 
         \                        sector                     
    (allCy, EFS,                                             
       YTIME)                                                

 VmConsFinEneCountry        Total final energy        $Mtoe$ 
          \                    consumnption                  
     (allCy, EF,                                             
       YTIME)                                                

   VmConsFinNonEne     Final non energy consumption   $Mtoe$ 
         \                                                   
    (allCy, EFS,                                             
       YTIME)                                                

  VmImpNetEneBrnch             Net Imports            $Mtoe$ 
          \                                                  
    (allCy, EFS,                                             
       YTIME)                                                

   VmLossesDistr \         Distribution losses        $Mtoe$ 
    (allCy, EFS,                                             
       YTIME)                                                
-------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the RestOfEnergy module.


```
Equations
```
*** REST OF ENERGY BALANCE SECTORS EQUATIONS
```
Q03OutTransfDhp(allCy,EFS,YTIME)                           "Compute the transformation output from district heating plants"
Q03OutTransfCHP(allCy,EFS,YTIME)                            "Compute the transformation output from CHP (Mtoe)"
Q03CapRef(allCy,YTIME)	                                   "Compute refineries capacity"
Q03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Compute the transformation output from refineries"
Q03InputTransfRef(allCy,EFS,YTIME)	                       "Compute the transformation input to refineries"
Q03OutTransfTherm(allCy,ELCEF,YTIME)	                       "Compute transformation output from thermal power plants"
Q03InpTotTransf(allCy,EFS,YTIME)	                       "Compute total transformation input"
Q03OutTotTransf(allCy,EFS,YTIME)	                       "Compute total transformation output"
Q03Transfers(allCy,EFS,YTIME)	                           "Compute transfers"
Q03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Compute gross inland consumption not including consumption of energy branch"
Q03ConsGrssInl(allCy,EFS,YTIME)	                           "Compute gross inland consumption"
Q03ProdPrimary(allCy,EFS,YTIME)	                           "Compute primary production"
Q03Exp(allCy,EFS,YTIME)	                                   "Compute fake exports"
Q03Imp(allCy,EFS,YTIME)	                                   "Compute fake imports"
```
**Interdependent Equations**
```
Q03ImpNetEneBrnch(allCy,EFS,YTIME)	                       "Compute net imports"
Q03ConsFiEneSec(allCy,EFS,YTIME)	                       "Compute energy branch final consumption"
Q03InpTransfTherm(allCy,EFS,YTIME)	                       "Compute transformation input to power plants"	
Q03TransfInputDHPlants(allCy,EFS,YTIME)                    "Compute the transformation input to distrcit heating plants"
Q03TransfInputCHPlants(allCy,EFS,YTIME) 
Q03ConsFinEneCountry(allCy,EFS,YTIME)                      "Compute total final energy consumption"
Q03ConsFinNonEne(allCy,EFS,YTIME)                          "Compute final non-energy consumption"
Q03LossesDistr(allCy,EFS,YTIME)                            "Compute distribution losses"
;
Variables
```
*** REST OF ENERGY BALANCE SECTORS VARIABLES
```
V03OutTransfDhp(allCy,STEAM,YTIME)                           "Transformation output from District Heating Plants (Mtoe)"
V03OutTransfCHP(allCy,TOCTEF,YTIME)                            "Transformation output from CHP (Mtoe)"
V03CapRef(allCy,YTIME)	                                   "Refineries capacity (Million barrels/day)"
V03OutTransfRefSpec(allCy,EFS,YTIME)	                   "Transformation output from refineries (Mtoe)"
V03InputTransfRef(allCy,EFS,YTIME)	                       "Transformation input to refineries (Mtoe)"
V03OutTransfTherm(allCy,ELCEF,YTIME)	                       "Transformation output from thermal power stations (Mtoe)"
V03InpTotTransf(allCy,EFS,YTIME)	                       "Total transformation input (Mtoe)"
V03OutTotTransf(allCy,EFS,YTIME)	                       "Total transformation output (Mtoe)"
V03Transfers(allCy,EFS,YTIME)	                           "Transfers (Mtoe)"
V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)	               "Gross Inland Consumption not including consumption of energy branch (Mtoe)"
V03ConsGrssInl(allCy,EFS,YTIME)	                           "Gross Inland Consumption (Mtoe)"
V03ProdPrimary(allCy,EFS,YTIME)	                           "Primary Production (Mtoe)"
V03Exp(allCy,EFS,YTIME)                        	           "Exports fake (Mtoe)"
V03Imp(allCy,EFS,YTIME)             	                   "Fake Imports for all fuels except natural gas (Mtoe)"
```
**Interdependent Variables**
```
VmImpNetEneBrnch(allCy,EFS,YTIME)	                       "Net Imports (Mtoe)"
VmConsFiEneSec(allCy,EFS,YTIME)                            "Final consumption in energy sector (Mtoe)"
VmInpTransfTherm(allCy,EFS,YTIME)	                       "Transformation input to thermal power plants (Mtoe)"
VmTransfInputDHPlants(allCy,EFS,YTIME)                     "Transformation input to District Heating Plants (Mtoe)"
VmTransfInputCHPlants(allCy,EFS,YTIME)                    "Transformation input to CHPs (Mtoe)"
VmConsFinEneCountry(allCy,EF,YTIME)                        "Total final energy consumnption (Mtoe)"
VmConsFinNonEne(allCy,EFS,YTIME)                           "Final non energy consumption (Mtoe)"
VmLossesDistr(allCy,EFS,YTIME)                             "Distribution losses (Mtoe)"
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* REST OF ENERGY BALANCE SECTORS
The equation computes the total final energy consumption in million tonnes of oil equivalent for each country ,
energy form sector, and time period. The total final energy consumption is calculated as the sum of final energy consumption in the
Industry and Tertiary sectors and the sum of final energy demand in all transport subsectors. The consumption is determined by the 
relevant link between model subsectors and fuels.
```
Q03ConsFinEneCountry(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFinEneCountry(allCy,EFS,YTIME)
        =E=
    sum(INDDOM,
      sum(EF$(EFtoEFS(EF,EFS) $SECtoEF(INDDOM,EF) ), VmConsFuel(allCy,INDDOM,EF,YTIME))
    ) +
    sum(TRANSE,
      sum(EF$(EFtoEFS(EF,EFS) $SECtoEF(TRANSE,EF)),
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
      )
    ) +
    sum(EF$(EFtoEFS(EF,EFS) $SECtoEF("DAC",EF)),VmConsFuelDACProd(allCy,EF,YTIME));
```
The equation computes the total final energy consumption in million tonnes of oil equivalent 
for all countries at a specific time period. This is achieved by summing the final energy consumption for each energy
form sector across all countries.
```
$ontext
q03ConsTotFinEne(YTIME)$(TIME(YTIME))..
         v03ConsTotFinEne(YTIME) =E= sum((allCy,EFS), VmConsFinEneCountry(allCy,EFS,YTIME) );     
$offtext
```
The equation computes the final non-energy consumption in million tonnes of oil equivalent
for a given energy form sector. The calculation involves summing the consumption of fuels in each non-energy and bunkers
demand subsector based on the corresponding fuel aggregation for the supply side. This process is performed 
for each time period.
```
Q03ConsFinNonEne(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFinNonEne(allCy,EFS,YTIME)
        =E=
    sum(NENSE$(not sameas("BU",NENSE)),
      sum(EF$(EFtoEFS(EF,EFS)$SECtoEF(NENSE,EF)), VmConsFuel(allCy,NENSE,EF,YTIME))
    );  
```
The equation computes the distribution losses in million tonnes of oil equivalent for a given energy form sector.
The losses are determined by the rate of losses over available for final consumption multiplied by the sum of total final energy
consumption and final non-energy consumption. This calculation is performed for each time period.
Please note that distribution losses are not considered for the hydrogen sector.
```
Q03LossesDistr(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmLossesDistr(allCy,EFS,YTIME)
        =E=
    (
      imRateLossesFinCons(allCy,EFS,YTIME) * 
      (
        VmConsFinEneCountry(allCy,EFS,YTIME) + 
        VmConsFinNonEne(allCy,EFS,YTIME) +
        V03ProdPrimary(allCy,EFS,YTIME)$sameas(EFS,"CRO")
      )
    )$(not H2EF(EFS)) +
    (
      VmDemTotH2(allCy,YTIME) -
      sum(SBS$SECtoEF(SBS,"H2F"), VmDemSecH2(allCy,SBS,YTIME))
    )$H2EF(EFS);  
```
The equation calculates the transformation output from district heating plants .
This transformation output is determined by summing over different demand sectors and district heating systems 
that correspond to the specified energy form set. The equation then sums over these district heating 
systems and calculates the consumption of fuels in each of these sectors. The resulting value represents the 
transformation output from district heating plants in million tonnes of oil equivalent.
```
Q03OutTransfDhp(allCy,STEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTransfDhp(allCy,STEAM,YTIME)
        =E=
    sum(TSTEAM$TDHP(TSTEAM),
      VmProdSte(allCy,TSTEAM,YTIME)
    );
```
The equation calculates the transformation input to district heating plants.
This transformation input is determined by summing over different district heating systems that correspond to the
specified energy form set . The equation then sums over different demand sectors within each 
district heating system and calculates the consumption of fuels in each of these sectors, taking into account
the efficiency of district heating plants. The resulting value represents the transformation input to district
heating plants in million tonnes of oil equivalent.
```
Q03TransfInputDHPlants(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmTransfInputDHPlants(allCy,EFS,YTIME)
        =E=
    VmConsFuelSteProd(allCy,"DHP",EFS,YTIME);
Q03OutTransfCHP(allCy,TOCTEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTransfCHP(allCy,TOCTEF,YTIME)
        =E=
    sum(TSTEAM$TCHP(TSTEAM),
      VmProdSte(allCy,TSTEAM,YTIME)
    )$sameas("STE",TOCTEF) +
    (V04ProdElecEstCHP(allCy,YTIME) * smTWhToMtoe)$sameas("ELC",TOCTEF);
Q03TransfInputCHPlants(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmTransfInputCHPlants(allCy,EFS,YTIME)
        =E=
    VmConsFuelSteProd(allCy,"CHP",EFS,YTIME);
```
The equation calculates the refineries' capacity for a given scenario and year.
The calculation is based on a residual factor, the previous year's capacity, and a production scaling
factor that takes into account the historical consumption trends for different energy forms. The scaling factor is
influenced by the base year and the production scaling parameter. The result represents the refineries'
capacity in million barrels per day (Million Barrels/day).
```
Q03CapRef(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03CapRef(allCy,YTIME)
        =E=
    [
      i03ResRefCapacity(allCy,YTIME) * V03CapRef(allCy,YTIME-1) *
      (1$(ord(YTIME) le 10) +
      (prod(rc,
      (sum(EFS$EFtoEFA(EFS,"LQD"),VmConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VmConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
      )
      $(ord(YTIME) gt 10)
      )     
    ]$i03RefCapacity(allCy,"%fStartHorizon%")+0;
```
The equation calculates the transformation output from refineries for a specific energy form 
in a given scenario and year. The output is computed based on a residual factor, the previous year's output, and the
change in refineries' capacity. The calculation includes considerations for the base year and adjusts the result accordingly.
The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
```
Q03OutTransfRefSpec(allCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD") $runCy(allCy))..
    V03OutTransfRefSpec(allCy,EFS,YTIME)
        =E=
    [
      i03ResTransfOutputRefineries(allCy,EFS,YTIME) * 
      V03OutTransfRefSpec(allCy,EFS,YTIME-1) *
      (V03CapRef(allCy,YTIME)/V03CapRef(allCy,YTIME-1)) ** 0.3 *
      (
        1$(TFIRST(YTIME-1) or TFIRST(YTIME-2)) +
        (
          sum(EF$EFtoEFA(EF,"LQD"),VmConsFinEneCountry(allCy,EF,YTIME-1)) /
          sum(EF$EFtoEFA(EF,"LQD"),VmConsFinEneCountry(allCy,EF,YTIME-2))
        )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
      )**(0.7)
    ]$i03RefCapacity(allCy,"%fStartHorizon%"); 
```
The equation calculates the transformation input to refineries for the energy form Crude Oil
in a specific scenario and year. The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation
output from refineries for the given energy form and year to the output in the previous year. This calculation is conditional on the refineries' capacity
being active in the specified starting horizon.The result represents the transformation input to refineries for crude oil in million tons of oil equivalent.
```
Q03InputTransfRef(allCy,"CRO",YTIME)$(TIME(YTIME) $runCy(allCy))..
    V03InputTransfRef(allCy,"CRO",YTIME)
        =E=
    [
      V03InputTransfRef(allCy,"CRO",YTIME-1) *
      sum(EFS$EFtoEFA(EFS,"LQD"), V03OutTransfRefSpec(allCy,EFS,YTIME)) /
      sum(EFS$EFtoEFA(EFS,"LQD"), V03OutTransfRefSpec(allCy,EFS,YTIME-1))
    ]$i03RefCapacity(allCy,"%fStartHorizon%");                   
```
The equation computes the transformation input to thermal power plants for a specific power generation form 
in a given scenario and year. The input is calculated based on the following conditions:
For conventional power plants that are not geothermal or nuclear, the transformation input is determined by the electricity production
from the respective power plant multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (smTWhToMtoe), divided by the
plant efficiency.For geothermal power plants, the transformation input is based on the electricity production from the geothermal plant multiplied by the conversion
factor.For combined heat and power plants , the input is calculated as the sum of the consumption of fuels in various demand subsectors and the electricity
production from the CHP plant . This sum is then divided by a factor based on the year to account for variations over time.The result represents
the transformation input to thermal power plants in million tons of oil equivalent.
```
Q03InpTransfTherm(allCy,PGEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmInpTransfTherm(allCy,PGEF,YTIME)
        =E=
    VmConsFuelElecProd(allCy,PGEF,YTIME);
```
The equation calculates the transformation output from thermal power stations for a specific energy branch
in a given scenario and year. The result is computed based on the following conditions: 
If the energy branch is related to electricity, the transformation output from thermal power stations is the sum of electricity production from
conventional power plants and combined heat and power plants. The production values are converted from terawatt-hours (TWh) to
million tons of oil equivalent.
If the energy branch is associated with steam, the transformation output is determined by the sum of the consumption of fuels in various demand
subsectors, the rate of energy branch consumption over total transformation output, and losses.
The result represents the transformation output from thermal power stations in million tons of oil equivalent.
```
Q03OutTransfTherm(allCy,"ELC",YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTransfTherm(allCy,"ELC",YTIME)
        =E=
    smTWhToMtoe *
    sum(PGALL,VmProdElec(allCy,PGALL,YTIME))
    ; 
            
```
The equation calculates the total transformation input for a specific energy branch 
in a given scenario and year. The result is obtained by summing the transformation inputs from different sources, including
thermal power plants, District Heating Plants, nuclear plants, patent
fuel and briquetting plants, and refineries. In the case where the energy branch is "OGS"
(Other Gas), the total transformation input is calculated as the difference between the total transformation output and various consumption
and loss components. The outcome represents the total transformation input in million tons of oil equivalent.
```
Q03InpTotTransf(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03InpTotTransf(allCy,EFS,YTIME)
        =E=
    VmConsFuelElecProd(allCy,EFS,YTIME) + 
    VmConsFuelSteProd(allCy,"DHP",EFS,YTIME) + 
    VmConsFuelSteProd(allCy,"CHP",EFS,YTIME) +
    V03InputTransfRef(allCy,EFS,YTIME) + 
    sum(EF$(H2PRODEF(EF) and EFtoEFS(EF,EFS)),VmConsFuelH2Prod(allCy,EF,YTIME));            
```
The equation calculates the total transformation output for a specific energy branch in a given scenario and year.
The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants,
nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
```
Q03OutTotTransf(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTotTransf(allCy,EFS,YTIME)
        =E=
    V03OutTransfTherm(allCy,"ELC",YTIME)$ELCEF(EFS) + 
    VmDemTotSte(allCy,YTIME)$STEAM(EFS) +
    V03OutTransfRefSpec(allCy,EFS,YTIME) +  
    sum(H2TECH$(sameas(EFS, "H2F")), VmProdH2(allCy, H2TECH, YTIME));  !! Hydrogen production for EFS = "H2F" + TONEW(allCy,EFS,YTIME)
```
The equation calculates the transfers of a specific energy branch in a given scenario and year.
The result is computed based on a complex formula that involves the previous year's transfers,
the residual for feedstocks in transfers, and various conditions.
In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers,
and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
```
Q03Transfers(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03Transfers(allCy,EFS,YTIME) 
        =E=
    ( 
      (
        V03Transfers(allCy,EFS,YTIME-1)*
        VmConsFinEneCountry(allCy,EFS,YTIME) /
        (VmConsFinEneCountry(allCy,EFS,YTIME-1) + 0.0001)
      )$EFTOEFA(EFS,"LQD") +
      (
        V03Transfers(allCy,"CRO",YTIME-1) *
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),V03Transfers(allCy,EFS2,YTIME)) /
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),V03Transfers(allCy,EFS2,YTIME-1))
      )$sameas(EFS,"CRO")   
    )$(i03FeedTransfr(allCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS));         
```
The equation calculates the gross inland consumption excluding the consumption of a specific energy branch
in a given scenario and year. The result is computed by summing various components, including
total final energy consumption, final non-energy consumption, total transformation input and output, distribution losses, and transfers.
The outcome represents the gross inland consumption excluding the consumption of the specified energy branch in million tons of oil equivalent.
```
Q03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)
        =E=
    VmConsFinEneCountry(allCy,EFS,YTIME) + 
    VmConsFinNonEne(allCy,EFS,YTIME) + 
    V03InpTotTransf(allCy,EFS,YTIME) - 
    V03OutTotTransf(allCy,EFS,YTIME) + 
    VmLossesDistr(allCy,EFS,YTIME) - 
    V03Transfers(allCy,EFS,YTIME); 
```
The equation calculates the gross inland consumptionfor a specific energy branch in a given scenario and year.
This is computed by summing various components, including total final energy consumption, final consumption in the energy sector, final non-energy consumption,
total transformation input and output, distribution losses, and transfers. The result represents the gross inland consumption in million tons of oil equivalent.
```
Q03ConsGrssInl(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ConsGrssInl(allCy,EFS,YTIME)
        =E=
    VmConsFinEneCountry(allCy,EFS,YTIME) + 
    VmConsFiEneSec(allCy,EFS,YTIME) + 
    VmConsFinNonEne(allCy,EFS,YTIME) + 
    V03InpTotTransf(allCy,EFS,YTIME) - 
    V03OutTotTransf(allCy,EFS,YTIME) +
    VmLossesDistr(allCy,EFS,YTIME) - 
    V03Transfers(allCy,EFS,YTIME);  
```
The equation calculates the primary production for a specific primary production definition in a given scenario and year.
The computation involves different scenarios based on the type of primary production definition:
For primary production definitions the primary production is directly proportional to the rate of primary production in total primary needs,
and it depends on gross inland consumption not including the consumption of the energy branch.
For Natural Gas primary production, the calculation considers a specific formula involving the rate of primary production in total primary needs, residuals for
hard coal, natural gas, and oil primary production, the elasticity related to gross inland consumption for natural gas, and other factors. Additionally, there is a lag
effect with coefficients for primary oil production.
For Crude Oil primary production, the computation includes the rate of primary production in total primary needs, residuals for hard coal, natural gas, and oil
primary production, the fuel primary production, and a product term involving the polynomial distribution lag coefficients for primary oil production.
The result represents the primary production in million tons of oil equivalent.
```
Q03ProdPrimary(allCy,PPRODEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ProdPrimary(allCy,PPRODEF,YTIME)
        =E=  
    [
      (
        i03RatePriProTotPriNeeds(allCy,PPRODEF,YTIME) *
        (V03ConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME) +  VmConsFiEneSec(allCy,PPRODEF,YTIME))
      )$(not (sameas(PPRODEF,"CRO")or sameas(PPRODEF,"NGS"))) +
      (
        i03ResHcNgOilPrProd(allCy,PPRODEF,YTIME) * 
        V03ProdPrimary(allCy,PPRODEF,YTIME-1) *
        (
          V03ConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME) /
          V03ConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME-1)
        )**i03NatGasPriProElst(allCy)
      )$(sameas(PPRODEF,"NGS")) +
      (
        i03ResHcNgOilPrProd(allCy,PPRODEF,YTIME) * 
        i03PrimProd(allCy,PPRODEF,YTIME) *
        prod(kpdl$(ord(kpdl) lt 5),
          (
            imPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1)) /
            imPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1))
          ) ** (0.2 * i03PolDstrbtnLagCoeffPriOilPr(kpdl)))
      )$sameas(PPRODEF,"CRO")   
    ]$i03RatePriProTotPriNeeds(allCy,PPRODEF,YTIME);   
```
The equation calculates the fake exports for a specific energy branch
in a given scenario and year. The computation is based on the fuel exports for
the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
```
Q03Exp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..
    V03Exp(allCy,EFS,YTIME)
        =E=
    imFuelExprts(allCy,EFS,YTIME);
```
The equation computes the fake imports for a specific energy branch 
in a given scenario and year. The calculation is based on different conditions for various energy branches,
such as electricity, crude oil, and natural gas. The equation involves gross inland consumption,
fake exports, consumption of fuels in demand subsectors, electricity imports,
and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
```
Q03Imp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..
    V03Imp(allCy,EFS,YTIME)
        =E=
    (
      i03RatioImpFinElecDem(allCy,YTIME) * (VmConsFinEneCountry(allCy,EFS,YTIME) + VmConsFinNonEne(allCy,EFS,YTIME)) +
      V03Exp(allCy,EFS,YTIME) +
      i03ElecImp(allCy,YTIME)
    )$ELCEF(EFS) +
    (
      V03ConsGrssInl(allCy,EFS,YTIME) + 
      V03Exp(allCy,EFS,YTIME) +
      VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS) -
      V03ProdPrimary(allCy,EFS,YTIME)
    )$(sameas(EFS,"CRO")) +
    (
      V03ConsGrssInl(allCy,EFS,YTIME) + 
      V03Exp(allCy,EFS,YTIME) + 
      VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS) -
      V03ProdPrimary(allCy,EFS,YTIME)
    )$(sameas(EFS,"NGS")) +
    (
      (1-i03RatePriProTotPriNeeds(allCy,EFS,YTIME)) *
      (V03ConsGrssInl(allCy,EFS,YTIME) + V03Exp(allCy,EFS,YTIME) + VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS) )
    )$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));
```
The equation computes the net imports for a specific energy branch 
in a given scenario and year. It subtracts the fake exports from the fake imports for
all fuels except natural gas . The result represents the net imports in million tons of oil equivalent.
```
Q03ImpNetEneBrnch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmImpNetEneBrnch(allCy,EFS,YTIME)
        =E=
    V03Imp(allCy,EFS,YTIME) - V03Exp(allCy,EFS,YTIME);
                               
```
The equation calculates the final energy consumption in the energy sector.
It considers the rate of energy branch consumption over the total transformation output.
The final consumption is determined based on the total transformation output and primary production for energy
branches, excluding Oil, Coal, and Gas. The result, VmConsFiEneSec, represents the final consumption in million tons of
oil equivalent for the specified scenario and year.
```
Q03ConsFiEneSec(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFiEneSec(allCy,EFS,YTIME)
        =E=
    i03RateEneBranCons(allCy,EFS,YTIME) *
    (
      (
        V03OutTotTransf(allCy,EFS,YTIME) +
        V03ProdPrimary(allCy,EFS,YTIME)$(sameas(EFS,"CRO") or sameas(EFS,"NGS"))
      )$(not TOCTEF(EFS)) +
      (
        VmConsFinEneCountry(allCy,EFS,YTIME) + 
        VmConsFinNonEne(allCy,EFS,YTIME) + 
        VmLossesDistr(allCy,EFS,YTIME)
      )$TOCTEF(EFS)
    ) +
    sum(EF$(H2PRODEF(EF) and EFtoEFS(EF,EFS)), VmConsFuelH2Prod(allCy,EF,YTIME))$TOCTEF(EFS);                               
```

```
table i03SuppRefCapacity(allCy,SUPOTH,YTIME)	  "Supplementary Parameter for the residual in refineries Capacity (1)"
$ondelim
$include "./iSuppRefCapacity.csv"
$offdelim
;
table i03DataTransfOutputRef(allCy,EF,YTIME)	  "Data for Other transformation output  (Mtoe)"
$ondelim
$include"./iDataTransfOutputRef.csv"
$offdelim
;
table i03DataGrossInlCons(allCy,EF,YTIME)	      "Data for Gross Inland Conusmption (Mtoe)"
$ondelim
$include"./iDataGrossInlCons.csv"
$offdelim
;
table i03DataOwnConsEne(allCy,EFS,YTIME)	      "Data for Consumption of Energy Branch (Mtoe)"
$ondelim
$include"./iDataOwnConsEne.csv"
$offdelim
;
table i03DataTotTransfInputRef(allCy,EF,YTIME)	  "Total Transformation Input in Refineries (Mtoe)"
$ondelim
$include"./iDataTotTransfInputRef.csv"
$offdelim
;
table i03SuppTransfers(allCy,EFS,YTIME)	          "Supplementary Parameter for Transfers (Mtoe)"
$ondelim
$include"./iSuppTransfers.csv"
$offdelim
;
table i03PrimProd(allCy,PPRODEF,YTIME)	              "Primary Production (Mtoe)"
$ondelim
$include"./iPrimProd.csv"
$offdelim
;
table i03SuppRatePrimProd(allCy,EF,YTIME)	      "Supplementary Parameter for iRatePrimProd (1)"	
$ondelim
$include"./iSuppRatePrimProd.csv"
$offdelim
;
table i03ElcNetImpShare(allCy,SUPOTH,YTIME)	      "Ratio of electricity imports in total final demand (1)"
$ondelim
$include "./iElcNetImpShare.csv"
$offdelim
;
table i03OutTotTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iOutTotalTransfProcess.csv"
$offdelim
;
table i03InpTotTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpTotalTransfProcess.csv"
$offdelim
;
table i03InpCHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpCHPTransfProcess.csv"
$offdelim
;
table i03OutCHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iOutCHPTransfProcess.csv"
$offdelim
;
table i03InpDHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iInpDHPTransfProcess.csv"
$offdelim
;
table i03OutDHPTransfProcess(allCy,EFS,YTIME)	      ""	
$ondelim
$include"./iOutDHPTransfProcess.csv"
$offdelim
;
parameter i03NatGasPriProElst(allCy)	          "Natural Gas primary production elasticity related to gross inland consumption (1)" /
$ondelim
$include "./iNatGasPriProElst.csv"
$offdelim
/;
parameter i03PolDstrbtnLagCoeffPriOilPr(kpdl)	  "Polynomial Distribution Lag Coefficients for primary oil production (1)"
/
a1 1.666706504,
a2 1.333269594,
a3 1.000071707,
a4 0.666634797,
a5 0.33343691
/;
Parameters
i03SupTrnasfOutputRefineries(allCy,EF,YTIME)	  "Supplementary parameter for the transformation output from refineries (Mtoe)"
i03SupResRefCapacity(allCy,SUPOTH,YTIME)	      "Supplementary Parameter for the residual in refineries Capacity (1)"
i03TransfInputRef(allCy,EF,YTIME)	              "Transformation Input in Refineries (Mtoe)"
i03TotEneBranchCons(allCy,EF,YTIME)	              "Total Energy Branch Consumption (Mtoe)"
i03TransfOutputRef(allCy,EF,YTIME)	              "Transformation Output from Refineries (Mtoe)"
i03RefCapacity(allCy,YTIME)	                      "Refineries Capacity (Million Barrels/day)"
i03GrosInlCons(allCy,EF,YTIME)	                  "Gross Inland Consumtpion (Mtoe)"
i03GrossInConsNoEneBra(allCy,EF,YTIME)	          "Gross Inland Consumption,excluding energy branch (Mtoe)"
i03FeedTransfr(allCy,EFS,YTIME)	                  "Feedstocks in Transfers (Mtoe)"
i03ResRefCapacity(allCy,YTIME)	                  "Residual in Refineries Capacity (1)"
i03ResTransfOutputRefineries(allCy,EF,YTIME)      "Residual in Transformation Output from Refineries (Mtoe)"
i03RateEneBranCons(allCy,EF,YTIME)	              "Rate of Energy Branch Consumption over total transformation output (1)"
i03RatePriProTotPriNeeds(allCy,EF,YTIME)	      "Rate of Primary Production in Total Primary Needs (1)"	
i03ResHcNgOilPrProd(allCy,EF,YTIME)	              "Residuals for Hard Coal, Natural Gas and Oil Primary Production (1)"
i03RatioImpFinElecDem(allCy,YTIME)	              "Ratio of imports in final electricity demand (1)"	
i03ElecImp(allCy,YTIME)	                          "Electricity Imports (1)"
;
i03SupResRefCapacity(runCy,SUPOTH,YTIME) = 1;
i03SupTrnasfOutputRefineries(runCy,EF,YTIME) = 1;
i03TransfInputRef(runCy,EFS,YTIME)$(not An(YTIME)) = i03DataTotTransfInputRef(runCy,EFS,YTIME);
i03TotEneBranchCons(runCy,EFS,YTIME) = i03DataOwnConsEne(runCy,EFS,YTIME);
i03TransfOutputRef(runCy,EFS,YTIME)$(not An(YTIME)) = i03DataTransfOutputRef(runCy,EFS,YTIME);
i03RefCapacity(runCy,YTIME) = i03SuppRefCapacity(runCy,"REF_CAP",YTIME);
i03GrosInlCons(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME);
i03GrossInConsNoEneBra(runCy,EFS,YTIME) = 1e-6 +
i03GrosInlCons(runCy,EFS,YTIME) + i03TotEneBranchCons(runCy,EFS,YTIME)$EFtoEFA(EFS,"LQD")
- i03TotEneBranchCons(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD"));
i03FeedTransfr(runCy,EFS,YTIME) = i03SuppTransfers(runCy,EFS,YTIME);
i03ResRefCapacity(runCy,YTIME) = i03SupResRefCapacity(runCy,"REF_CAP_RES",YTIME);
i03ResTransfOutputRefineries(runCy,EFS,YTIME) = i03SupTrnasfOutputRefineries(runCy,EFS,YTIME);
i03RateEneBranCons(runCy,EFS,YTIME) =  
[
  i03TotEneBranchCons(runCy,EFS,YTIME) /
  (
    i03OutTotTransfProcess(runCy,EFS,YTIME) +
    SUM(PPRODEF$sameas(PPRODEF,EFS),i03PrimProd(runCy,PPRODEF,YTIME)) -
    i03TotEneBranchCons(runCy,EFS,YTIME)$TOCTEF(EFS)
  )
]$i03OutTotTransfProcess(runCy,EFS,YTIME);
i03RateEneBranCons(runCy,EFS,YTIME)$(AN(YTIME)) = i03RateEneBranCons(runCy,EFS,"%fBaseY%");
i03RatePriProTotPriNeeds(runCy,PPRODEF,YTIME) = i03SuppRatePrimProd(runCy,PPRODEF,YTIME);
i03ResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"HCL_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"NGS",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"NGS_PPROD",YTIME);
i03ResHcNgOilPrProd(runCy,"CRO",YTIME)$an(YTIME)   = i03SupResRefCapacity(runCy,"OIL_PPROD",YTIME);
i03RatioImpFinElecDem(runCy,YTIME)$an(YTIME) = i03ElcNetImpShare(runCy,"ELC_IMP",YTIME);
i03ElecImp(runCy,YTIME) = 0;
VmConsFinNonEne.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = 
sum(NENSE$(not sameas("BU",NENSE)),
  sum(EF$(EFtoEFS(EF,EFS) $SECtoEF(NENSE,EF)), imFuelConsPerFueSub(runCy,NENSE,EF,YTIME))
);
imRateLossesFinCons(runCy,EFS,YTIME) = 
[
  imDistrLosses(runCy,EFS,YTIME) /
  (sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)) + i03PrimProd(runCy,"CRO",YTIME)$sameas("CRO",EFS))
]$(sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)) + i03PrimProd(runCy,"CRO",YTIME)$sameas("CRO",EFS));
imRateLossesFinCons(runCy,EFS,YTIME)$AN(YTIME) = imRateLossesFinCons(runCy,EFS,"%fBaseY%");
```

*VARIABLE INITIALISATION*
```
V03CapRef.L(runCy,YTIME) = 0.1;
V03CapRef.FX(runCy,YTIME)$(not An(YTIME)) = i03RefCapacity(runCy,YTIME);
V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = i03TransfOutputRef(runCy,EFS,YTIME);
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
V03ConsGrssInlNotEneBranch.L(runCy,EFS,YTIME) = 0.1;
V03ConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03GrossInConsNoEneBra(runCy,EFS,YTIME);
V03InputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = i03TransfInputRef(runCy,"CRO",YTIME);
V03InputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
V03ConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03GrosInlCons(runCy,EFS,YTIME);
V03Transfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03FeedTransfr(runCy,EFS,YTIME);
V03ProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = i03PrimProd(runCy,PPRODEF,YTIME);
V03Imp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelImports(runCy,"NGS",YTIME);
V03Imp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
V03Exp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = imFuelExprts(runCy,EFS,YTIME);
V03Exp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelExprts(runCy,"NGS",YTIME);
V03Exp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VmConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03TotEneBranchCons(runCy,EFS,YTIME);
VmConsFinEneCountry.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
sum(DSBS$(not NENSE(DSBS)), 
  imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)
);
VmLossesDistr.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imDistrLosses(runCy,EFS,YTIME);
V03OutTotTransf.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = i03OutTotTransfProcess(runCy,EFS,YTIME);
V03InpTotTransf.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpTotTransfProcess(runCy,EFS,YTIME);
V03OutTransfDhp.FX(runCy,STEAM,YTIME)$(not AN(YTIME)) = i03OutDHPTransfProcess(runCy,STEAM,YTIME);
VmTransfInputDHPlants.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpDHPTransfProcess(runCy,EFS,YTIME);
V03OutTransfCHP.FX(runCy,TOCTEF,YTIME)$(not AN(YTIME)) = i03OutCHPTransfProcess(runCy,TOCTEF,YTIME);
VmTransfInputCHPlants.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpCHPTransfProcess(runCy,EFS,YTIME);
VmInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VmInpTransfTherm.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = -i03InpPGTransfProcess(runCy,PGEF,YTIME);
V03OutTransfTherm.FX(runCy,ELCEF,YTIME)$DATAY(YTIME) = i03OutPGTransfProcess(runCy,ELCEF,YTIME);
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


-----------------------------------------------------------------------------------
            &nbsp;                        Description                 Unit       A 
------------------------------- -------------------------------- -------------- ---
      i03DataGrossInlCons            Data for Gross Inland           $Mtoe$      x 
               \                          Conusmption                              
          (allCy, EF,                                                              
            YTIME)                                                                 

       i03DataOwnConsEne         Data for Consumption of Energy      $Mtoe$      x 
               \                             Branch                                
         (allCy, EFS,                                                              
            YTIME)                                                                 

   i03DataTotTransfInputRef      Total Transformation Input in       $Mtoe$      x 
               \                           Refineries                              
          (allCy, EF,                                                              
            YTIME)                                                                 

    i03DataTransfOutputRef       Data for Other transformation       $Mtoe$      x 
               \                             output                                
          (allCy, EF,                                                              
            YTIME)                                                                 

       i03ElcNetImpShare          Ratio of electricity imports        $1$        x 
               \                     in total final demand                         
        (allCy, SUPOTH,                                                            
            YTIME)                                                                 

         i03ElecImp \                 Electricity Imports             $1$        x 
        (allCy, YTIME)                                                             

        i03FeedTransfr              Feedstocks in Transfers          $Mtoe$      x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

        i03GrosInlCons              Gross Inland Consumtpion         $Mtoe$      x 
              \                                                                    
          (allCy, EF,                                                              
            YTIME)                                                                 

    i03GrossInConsNoEneBra                Gross Inland               $Mtoe$      x 
               \                  Consumption,excluding energy                     
          (allCy, EF,                        branch                                
            YTIME)                                                                 

    i03InpCHPTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

    i03InpDHPTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

    i03InpTotTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

      i03NatGasPriProElst        Natural Gas primary production       $1$        x 
               \                  elasticity related to gross                      
            (allCy)                    inland consumption                          

    i03OutCHPTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

    i03OutDHPTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

    i03OutTotTransfProcess                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

 i03PolDstrbtnLagCoeffPriOilPr    Polynomial Distribution Lag         $1$        x 
               \                  Coefficients for primary oil                     
            (kpdl)                         production                              

        i03PrimProd \                  Primary Production            $Mtoe$      x 
            (allCy,                                                                
        PPRODEF, YTIME)                                                            

      i03RateEneBranCons             Rate of Energy Branch            $1$        x 
               \                     Consumption over total                        
          (allCy, EF,                transformation output                         
            YTIME)                                                                 

   i03RatePriProTotPriNeeds      Rate of Primary Production in        $1$        x 
               \                      Total Primary Needs                          
          (allCy, EF,                                                              
            YTIME)                                                                 

     i03RatioImpFinElecDem         Ratio of imports in final          $1$        x 
               \                       electricity demand                          
        (allCy, YTIME)                                                             

        i03RefCapacity                Refineries Capacity            $10^6       x 
              \                                                   Barrels/day$     
        (allCy, YTIME)                                                             

      i03ResHcNgOilPrProd           Residuals for Hard Coal,          $1$        x 
               \                  Natural Gas and Oil Primary                      
          (allCy, EF,                      Production                              
            YTIME)                                                                 

       i03ResRefCapacity             Residual in Refineries           $1$        x 
               \                            Capacity                               
        (allCy, YTIME)                                                             

 i03ResTransfOutputRefineries      Residual in Transformation        $Mtoe$      x 
               \                     Output from Refineries                        
          (allCy, EF,                                                              
            YTIME)                                                                 

      i03SuppRatePrimProd         Supplementary Parameter for         $1$        x 
               \                         iRatePrimProd                             
          (allCy, EF,                                                              
            YTIME)                                                                 

      i03SuppRefCapacity          Supplementary Parameter for         $1$        x 
               \                   the residual in refineries                      
        (allCy, SUPOTH,                     Capacity                               
            YTIME)                                                                 

       i03SuppTransfers           Supplementary Parameter for        $Mtoe$      x 
               \                           Transfers                               
         (allCy, EFS,                                                              
            YTIME)                                                                 

     i03SupResRefCapacity         Supplementary Parameter for         $1$        x 
               \                   the residual in refineries                      
        (allCy, SUPOTH,                     Capacity                               
            YTIME)                                                                 

 i03SupTrnasfOutputRefineries     Supplementary parameter for        $Mtoe$      x 
               \                 the transformation output from                    
          (allCy, EF,                      refineries                              
            YTIME)                                                                 

      i03TotEneBranchCons             Total Energy Branch            $Mtoe$      x 
               \                          Consumption                              
          (allCy, EF,                                                              
            YTIME)                                                                 

       i03TransfInputRef            Transformation Input in          $Mtoe$      x 
               \                           Refineries                              
          (allCy, EF,                                                              
            YTIME)                                                                 

      i03TransfOutputRef           Transformation Output from        $Mtoe$      x 
               \                           Refineries                              
          (allCy, EF,                                                              
            YTIME)                                                                 

         Q03CapRef \              Compute refineries capacity                    x 
        (allCy, YTIME)                                                             

        Q03ConsFiEneSec           Compute energy branch final                    x 
              \                           consumption                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

     Q03ConsFinEneCountry          Compute total final energy                    x 
               \                          consumption                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

       Q03ConsFinNonEne             Compute final non-energy                     x 
               \                          consumption                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03ConsGrssInl                Compute gross inland                       x 
              \                           consumption                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

  Q03ConsGrssInlNotEneBranch          Compute gross inland                       x 
               \                   consumption not including                       
         (allCy, EFS,             consumption of energy branch                     
            YTIME)                                                                 

           Q03Exp \                   Compute fake exports                       x 
         (allCy, EFS,                                                              
            YTIME)                                                                 

           Q03Imp \                   Compute fake imports                       x 
         (allCy, EFS,                                                              
            YTIME)                                                                 

       Q03ImpNetEneBrnch              Compute net imports                        x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03InpTotTransf           Compute total transformation                   x 
              \                              input                                 
         (allCy, EFS,                                                              
            YTIME)                                                                 

       Q03InpTransfTherm          Compute transformation input                   x 
               \                        to power plants                            
         (allCy, EFS,                                                              
            YTIME)                                                                 

       Q03InputTransfRef           Compute the transformation                    x 
               \                      input to refineries                          
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03LossesDistr            Compute distribution losses                    x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03OutTotTransf           Compute total transformation                   x 
              \                              output                                
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03OutTransfCHP            Compute the transformation        $Mtoe$      x 
              \                         output from CHP                            
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03OutTransfDhp            Compute the transformation                    x 
              \                   output from district heating                     
         (allCy, EFS,                        plants                                
            YTIME)                                                                 

      Q03OutTransfRefSpec          Compute the transformation                    x 
               \                     output from refineries                        
         (allCy, EFS,                                                              
            YTIME)                                                                 

       Q03OutTransfTherm         Compute transformation output                   x 
               \                   from thermal power plants                       
        (allCy, ELCEF,                                                             
            YTIME)                                                                 

        Q03ProdPrimary             Compute primary production                    x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

        Q03Transfers \                 Compute transfers                         x 
         (allCy, EFS,                                                              
            YTIME)                                                                 

    Q03TransfInputCHPlants                                                       x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

    Q03TransfInputDHPlants         Compute the transformation                    x 
               \                   input to distrcit heating                       
         (allCy, EFS,                        plants                                
            YTIME)                                                                 

         V03CapRef \                  Refineries capacity            $10^6       x 
        (allCy, YTIME)                                            barrels/day$     

        V03ConsGrssInl              Gross Inland Consumption         $Mtoe$      x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

  V03ConsGrssInlNotEneBranch      Gross Inland Consumption not       $Mtoe$      x 
               \                    including consumption of                       
         (allCy, EFS,                    energy branch                             
            YTIME)                                                                 

           V03Exp \                       Exports fake               $Mtoe$      x 
         (allCy, EFS,                                                              
            YTIME)                                                                 

           V03Imp \                Fake Imports for all fuels        $Mtoe$      x 
         (allCy, EFS,                  except natural gas                          
            YTIME)                                                                 

        V03InpTotTransf            Total transformation input        $Mtoe$      x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

       V03InputTransfRef            Transformation input to          $Mtoe$      x 
               \                           refineries                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

        V03OutTotTransf           Total transformation output        $Mtoe$      x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

        V03OutTransfCHP          Transformation output from CHP      $Mtoe$      x 
              \                                                                    
        (allCy, TOCTEF,                                                            
            YTIME)                                                                 

        V03OutTransfDhp            Transformation output from        $Mtoe$      x 
              \                     District Heating Plants                        
        (allCy, STEAM,                                                             
            YTIME)                                                                 

      V03OutTransfRefSpec          Transformation output from        $Mtoe$      x 
               \                           refineries                              
         (allCy, EFS,                                                              
            YTIME)                                                                 

       V03OutTransfTherm           Transformation output from        $Mtoe$      x 
               \                     thermal power stations                        
        (allCy, ELCEF,                                                             
            YTIME)                                                                 

        V03ProdPrimary                 Primary Production            $Mtoe$      x 
              \                                                                    
         (allCy, EFS,                                                              
            YTIME)                                                                 

        V03Transfers \                     Transfers                 $Mtoe$      x 
         (allCy, EFS,                                                              
            YTIME)                                                                 

       VmInpTransfTherm             Transformation input to          $Mtoe$      x 
               \                      thermal power plants                         
         (allCy, EFS,                                                              
            YTIME)                                                                 

     VmTransfInputCHPlants        Transformation input to CHPs       $Mtoe$      x 
               \                                                                   
         (allCy, EFS,                                                              
            YTIME)                                                                 

     VmTransfInputDHPlants          Transformation input to          $Mtoe$      x 
               \                    District Heating Plants                        
         (allCy, EFS,                                                              
            YTIME)                                                                 
-----------------------------------------------------------------------------------

Table: module-internal objects (A: legacy)



### Sets


------------------------------------------------
    &nbsp;                description           
--------------- --------------------------------
     allCy         All Countries Used in the    
                             Model              

   an(ytime)      Years for which the model is  
                            running             

   DSBS(SBS)         All Demand Subsectors      

      EF                  Energy Forms          

    EFS(EF)       Energy Forms used in Supply   
                              Side              

  EFtoEFA(EF,    Energy Forms Aggregations (for 
     EFA)           summary balance report)     

  EFtoEFS(EF,     Fuel Aggregation for Supply   
     EFS)                     Side              

   ELCEF(EF)              Electricity           

   H2EF(EF)                 Hydrogen            

 H2PRODEF(EF)       Fuels used for hydrogen     
                           production           

    H2TECH            Hydrogen production       
                          technologies          

  IMPEF(EFS)      Fuels considered in Imports   
                          and Exports           

 INDDOM(DSBS)        Industry and Tertiary      

     kpdl            counter for Polynomial     
                        Distribution Lag        

  NENSE(DSBS)        Non Energy and Bunkers     

     PGALL        Power Generation Plant Types  

   PGEF(EFS)      Energy forms used for steam   
                           production           

 PPRODEF(EFS)     Fuels considered in primary   
                           production           

      rc                                        

 runCy(allCy)    Countries for which the model  
                           is running           

 runCyL(allCy)   Countries for which the model  
                 is running (used in countries  
                             loop)              

  SBS(ALLSBS)           Model Subsectors        

 SECtoEF(SBS,    Link between Model Subsectors  
      EF)               and Energy FORMS        

  STEAM(EFS)                 Steam              

    STEMODE          Steam production modes     

    SUPOTH        Indicators related to supply  
                              side              

 TCHP(TSTEAM)        CHP plant technologies     

 TDHP(TSTEAM)        CHP plant technologies     

  TOCTEF(EFS)    Energy forms produced by power 
                       plants and boilers       

 TRANSE(DSBS)       All Transport Subsectors    

    TSTEAM        CHP & DHP plant technologies  

      WEF            Imported Energy Forms      
                    (affecting fuel prices)     
------------------------------------------------

Table: sets in use



See Also
--------

[01_Transport], [02_Industry], [04_PowerGeneration], [05_Hydrogen], [06_CO2], [09_Heat]

