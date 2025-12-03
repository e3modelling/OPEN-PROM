Heat module (09_Heat) {#id-09_Heat}
=====================

Description
-----------

This is the Heat module.


Interfaces
----------

**Interface plot missing!**

### Input


------------------------------------------------------------------------------
         &nbsp;                     Description                 Unit        A 
------------------------- -------------------------------- --------------- ---
       VmCarVal \              Carbon prices for all        $US\$2015/tn    x 
      (allCy, NAP,                   countries                  CO2$          
         YTIME)                                                               

     VmConsFiEneSec         Final consumption in energy        $Mtoe$       x 
           \                           sector                                 
      (allCy, EFS,                                                            
         YTIME)                                                               

      VmConsFuel \          Consumption of fuels in each       $Mtoe$       x 
      (allCy, DSBS,         demand subsector, excluding                       
       EF, YTIME)               heat from heatpumps                           

     VmCstCO2SeqCsts             Cost curve for CO2         $US\$2015/tn    x 
           \                    sequestration costs              of           
     (allCy, YTIME)                                              CO2          
                                                            sequestrated$     

     VmLossesDistr \            Distribution losses            $Mtoe$       x 
      (allCy, EFS,                                                            
         YTIME)                                                               

     VmPriceElecInd        Electricity index - a function        $1$        x 
           \                     of industry price                            
     (allCy, YTIME)                                                           

 VmPriceFuelSubsecCarVal   Fuel prices per subsector and    $k\$2015/toe$   x 
            \                           fuel                                  
      (allCy, SBS,                                                            
       EF, YTIME)                                                             
------------------------------------------------------------------------------

Table: module inputs (A: heat)



### Output


-------------------------------------------------------------
      &nbsp;              Description             Unit       
------------------- ----------------------- -----------------
 VmConsFuelSteProd                                           
         \                                                   
      (allCy,                                                
   STEMODE, EFS,                                             
      YTIME)                                                 

 VmCostAvgProdSte    Average cost of steam   $kUS\$2015/toe$ 
         \                production                         
  (allCy, YTIME)                                             

  VmDemTotSte \                                              
  (allCy, YTIME)                                             

   VmProdSte \                                               
  (allCy, TSTEAM,                                            
      YTIME)                                                 
-------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) heat

This is the heat realization of the Heat module.

```
sets
TSTEAM "CHP & DHP plant technologies"
/
TSTE1AL           "Lignite powered advanced CHP"
TSTE1AH           "Hard Coal powered advanced CHP"
TSTE1AD           "Diesel Oil powered advanced CHP"
TSTE1AG           "Natural Gas powered advanced CHP"
TSTE1AB           "Biomass-Waste powered advanced CHP"
TSTE1AH2F         "HYDROGEN powered FUEL CELL CHP"
TSTE2LGN
TSTE2OSL
TSTE2GDO
TSTE2NGS
TSTE2BMS
TSTE2GEO
TSTE2OTH
/
TCHP(TSTEAM) "CHP plant technologies"
/
TSTE1AL           "Utilisation rate of Lignite powered advanced CHP"
TSTE1AH           "Utilisation rate of Hard Coal powered advanced CHP"
TSTE1AD           "Utilisation rate of Diesel Oil powered advanced CHP"
TSTE1AG           "Utilisation rate of Natural Gas powered advanced CHP"
TSTE1AB           "Utilisation rate of Biomass-Waste powered advanced CHP"
TSTE1AH2F         "Utilisation rate of Hydrogen powered fuel cell CHP"
/
TDHP(TSTEAM) "CHP plant technologies"
/
TSTE2LGN
TSTE2OSL
TSTE2GDO
TSTE2NGS
TSTE2BMS
TSTE2GEO
TSTE2OTH
/
TSTEAMTOEF(TSTEAM,EF)   Correspondence between chp plants and energy forms
/
(TSTE1AL,TSTE2LGN).LGN
(TSTE1AH,TSTE2OSL).HCL
(TSTE1AD,TSTE2GDO).(GDO,RFO,OLQ,LPG,KRS)
(TSTE1AG,TSTE2NGS).(NGS,OGS)
(TSTE1AB,TSTE2BMS).BMSWAS
TSTE1AH2F.H2F
TSTE2GEO.GEO
TSTE2OTH.NUC
/
STEAMEF(EFS)    "Fuels used for steam production"
STEMODE         "Steam production modes"                       /CHP,DHP/
;
ALIAS (TSTEAM2,TSTEAM);
ALIAS (TCHP2,TCHP);
ALIAS (TDHP2,TDHP);
STEAMEF(EFS) = yes$(sum(TSTEAM, TSTEAMTOEF(TSTEAM,EFS)));
```

```
Equations
Q09ScrapRate(allCy,TSTEAM,YTIME)
Q09DemGapSte(allCy,YTIME)
Q09CostVarProdSte(allCy,TSTEAM,YTIME)
Q09CostCapProdSte(allCy,TSTEAM,YTIME)
Q09CostProdSte(allCy,TSTEAM,YTIME)
Q09GapShareSte(allCy,TSTEAM,YTIME)
Q09CaptRateSte(allCy,TSTEAM,YTIME)
Q09ScrapRatePremature(allCy,TSTEAM,YTIME)
```
**Interdependent Equations**
```
Q09DemTotSte(allCy,YTIME)
Q09ProdSte(allCy,TSTEAM,YTIME)
Q09CostAvgProdSte(allCy,YTIME)
Q09ConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;
Variables
V09ScrapRate(allCy,TSTEAM,YTIME)
V09DemGapSte(allCy,YTIME)
V09CostVarProdSte(allCy,TSTEAM,YTIME)         "Variable cost of steam generation technologies (kUS$2015/toe)"
V09CostCapProdSte(allCy,TSTEAM,YTIME)         "Capex and O&M costs of steam generation technologies (kUS$2015/toe)"
V09CostProdSte(allCy,TSTEAM,YTIME)            "Cost of steam production (kUS$2015/toe)"
V09GapShareSte(allCy,TSTEAM,YTIME)
V09CaptRateSte(allCy,TSTEAM,YTIME)
V09ScrapRatePremature(allCy,TSTEAM,YTIME)
```
**Interdependent Variables**
```
VmDemTotSte(allCy,YTIME)
VmProdSte(allCy,TSTEAM,YTIME)
VmCostAvgProdSte(allCy,YTIME)                 "Average cost of steam production (kUS$2015/toe)"
VmConsFuelSteProd(allCy,STEMODE,EFS,YTIME)
;
```

GENERAL INFORMATION
Equation format: "typical useful energy demand equation"
The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 
* Heat module
This equation calculates the total heat demand in the system. It takes into account the overall need for steam
across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
```
Q09DemTotSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotSte(allCy,YTIME)
        =E=
    sum(DSBS,VmConsFuel(allCy,DSBS,"STE",YTIME)) +
    VmConsFiEneSec(allCy,"STE",YTIME) +
    VmLossesDistr(allCy,"STE",YTIME) +
    V03Transfers(allCy,"STE",YTIME);
Q09ScrapRate(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09ScrapRate(allCy,TSTEAM,YTIME)
        =E=
    1 - (1 - 1 / i09ProdLftSte(TSTEAM)) *
    V09ScrapRatePremature(allCy,TSTEAM,YTIME);
Q09ProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdSte(allCy,TSTEAM,YTIME)
        =E=
    (1-V09ScrapRate(allCy,TSTEAM,YTIME)) * VmProdSte(allCy,TSTEAM,YTIME-1) +
    V09GapShareSte(allCy,TSTEAM,YTIME) * V09DemGapSte(allCy,YTIME);
Q09DemGapSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09DemGapSte(allCy,YTIME)
        =E=
  ( 
      VmDemTotSte(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmProdSte(allCy,TSTEAM,YTIME-1)
      ) +
  SQRT(SQR(
      VmDemTotSte(allCy,YTIME) -
      sum(TSTEAM,
        (1-V09ScrapRate(allCy,TSTEAM,YTIME)) *
        VmProdSte(allCy,TSTEAM,YTIME-1)
      )
  ))
  )/2 + 1e-6;
Q09CostVarProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostVarProdSte(allCy,TSTEAM,YTIME)
        =E=
    sum(EFS$TSTEAMTOEF(TSTEAM,EFS),
      ( 
        i09ShareFuel(allCy,TSTEAM,EFS,"%fBaseY%") *
        VmPriceFuelSubsecCarVal(allCy,"STEAMP",EFS,YTIME) +
        V09CaptRateSte(allCy,TSTEAM,YTIME) * 
        (imCo2EmiFac(allCy,"STEAMP",EFS,YTIME) + 4.17$(sameas("BMSWAS", EFS))) * 
        VmCstCO2SeqCsts(allCy,YTIME) * 1e-3 +
        (1-V09CaptRateSte(allCy,TSTEAM,YTIME)) * 1e-3 * (imCo2EmiFac(allCy,"STEAMP",EFS,YTIME)) *
        sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME))
      ) 
    ) / i09EffSteThrm(TSTEAM,YTIME) +
    i09CostVOMSteProd(TSTEAM,YTIME) * 1e-3 / smTWhToMtoe * VmPriceElecInd(allCy,YTIME) -
    (
      VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) *
      smFracElecPriChp *
      VmPriceElecInd(allCy,YTIME)
    )$TCHP(TSTEAM);
Q09CostCapProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostCapProdSte(allCy,TSTEAM,YTIME)
        =E=
    (
      imDisc(allCy,"STEAMP",YTIME) * 
      exp(imDisc(allCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM)) /
      (exp(imDisc(allCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM))-1) * 
      (
        i09CostInvCostSteProd(TSTEAM,YTIME) * imCGI(allCy,YTIME) +
        i09CostFixOMSteProd(TSTEAM,YTIME)
      )
    ) / (i09PowToHeatRatio(TSTEAM,YTIME) + 1$TDHP(TSTEAM)) /
    (
      i09AvailRateSteProd(TSTEAM,YTIME) * 
      smGwToTwhPerYear(YTIME) * 
      smTWhToMtoe * 1e3
    );
Q09CostProdSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V09CostProdSte(allCy,TSTEAM,YTIME)
        =E=
    V09CostCapProdSte(allCy,TSTEAM,YTIME) +
    V09CostVarProdSte(allCy,TSTEAM,YTIME);
Q09CostAvgProdSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdSte(allCy,YTIME)
        =E=
    sum(TSTEAM, 
      VmProdSte(allCy,TSTEAM,YTIME) *
      V09CostProdSte(allCy,TSTEAM,YTIME)
    ) / 
    sum(TSTEAM,VmProdSte(allCy,TSTEAM,YTIME));
Q09GapShareSte(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V09GapShareSte(allCy,TSTEAM,YTIME)
        =E=
    !!i04MatFacPlaAvailCap(allCy,TSTEAM,YTIME) *
    V09CostProdSte(allCy,TSTEAM,YTIME-1) ** (-2) /
    SUM(TSTEAM2,
      !!i04MatFacPlaAvailCap(allCy,TSTEAM2,YTIME) *
      V09CostProdSte(allCy,TSTEAM2,YTIME-1) ** (-2)
    );
Q09CaptRateSte(allCy,TSTEAM,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V09CaptRateSte(allCy,TSTEAM,YTIME)
        =E=
    i09CaptRateSteProd(TSTEAM) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    );
Q09ScrapRatePremature(allCy,TSTEAM,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V09ScrapRatePremature(allCy,TSTEAM,YTIME)
        =E=
    V09CostVarProdSte(allCy,TSTEAM,YTIME) ** (-2) /
    (
      V09CostVarProdSte(allCy,TSTEAM,YTIME) ** (-2) +
      (( 
        i09ScaleEndogScrap *
        sum(TCHP2$(not sameas(TSTEAM,TCHP2)),
          V09CostProdSte(allCy,TCHP2,YTIME)
        )
      ) ** (-2)
      )$TCHP(TSTEAM) +
      (( 
        i09ScaleEndogScrap *
        sum(TDHP2$(not sameas(TSTEAM,TDHP2)),
          V09CostProdSte(allCy,TDHP2,YTIME)
        )
      ) ** (-2)
      )$TDHP(TSTEAM)
    );
Q09ConsFuelSteProd(allCy,STEMODE,STEAMEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFuelSteProd(allCy,STEMODE,STEAMEF,YTIME)
      =E=
    SUM(TDHP$(TSTEAMTOEF(TDHP,STEAMEF)),
      VmProdSte(allCy,TDHP,YTIME) *
      i09ShareFuel(allCy,TDHP,STEAMEF,"%fBaseY%") / i09EffSteThrm(TDHP,YTIME)
    )$sameas("DHP",STEMODE) +
    SUM(TCHP$(TSTEAMTOEF(TCHP,STEAMEF)),
      VmProdSte(allCy,TCHP,YTIME) *
      i09ShareFuel(allCy,TCHP,STEAMEF,"%fBaseY%") / i09EffSteThrm(TCHP,YTIME)
    )$sameas("CHP",STEMODE);
```

```
Parameters
i09ProdLftSte(TSTEAM)                   "Lifetime of steam production technologies in years"
i09CaptRateSteProd(TSTEAM)
i09ScaleEndogScrap
i09AvailRateSteProd(TSTEAM,YTIME)       "Availability rate of STEAM Plants ()"
i09CostVOMSteProd(TSTEAM,YTIME)         "Variable cost per steam plant type (US$2015/toe)"
i09EffSteThrm(TSTEAM,YTIME)
i09EffSteElc(TSTEAM,YTIME)
i09PowToHeatRatio(TSTEAM,YTIME)
i09ParDHEffData(EFS)
i09CostInvCostSteProd(TSTEAM,YTIME)     "Capital Cost per steam plant type (US$2015/(KWe or KWThrm) )"
i09CostFixOMSteProd(TSTEAM,YTIME)       "Fixed O&M cost per steam plant type (US$2015/KW )"
i09ShareFuel(allCy,TSTEAM,EFS,YTIME)
;
i09CaptRateSteProd(TSTEAM) = 0;
i09ScaleEndogScrap = 15 / card(TSTEAM);
table imDataIndTechnologyCHP(INDDOM,TSTEAM,ECONCHAR)          "Technoeconomic characteristics of industry (various)"
              IC      FC      VC      LFT USC
IS.TSTE1AL    1.04547 17.284  17.68   25  0.35
IS.TSTE1AH    1.04547 17.284  17.68   25  0.35
IS.TSTE1AD    0.78340 23.3335 4.896   25  0.34
IS.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
IS.TSTE1AB    1.00334 28.8752 8.16    25  0.37
IS.TSTE1AH2F  1.34817 40.4451         25  0.5
NF.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
NF.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
NF.TSTE1AD    1.82186 54.264  11.386  25  0.34
NF.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
NF.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
NF.TSTE1AH2F  3.13528 94.0585         30  0.5
CH.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
CH.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
CH.TSTE1AD    1.82186 54.264  11.386  25  0.34
CH.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
CH.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
CH.TSTE1AH2F  3.13528 94.0585         25  0.5
BM.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
BM.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
BM.TSTE1AD    1.82186 54.264  11.386  25  0.34
BM.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
BM.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
BM.TSTE1AH2F  3.13528 94.0585         30  0.5
PP.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
PP.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
PP.TSTE1AD    1.82186 54.264  11.386  25  0.34
PP.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
PP.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
PP.TSTE1AH2F  2.27889 68.3668         25  0.5
FD.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
FD.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
FD.TSTE1AD    1.82186 54.264  11.386  25  0.34
FD.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
FD.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
FD.TSTE1AH2F  2.27889 68.3668         25  0.5
EN.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
EN.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
EN.TSTE1AD    1.82186 54.264  11.386  25  0.34
EN.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
EN.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
EN.TSTE1AH2F  2.27889 68.3668         25  0.5
TX.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
TX.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
TX.TSTE1AD    1.82186 54.264  11.386  25  0.34
TX.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
TX.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
TX.TSTE1AH2F  2.27889 68.3668         20  0.5
OE.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
OE.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
OE.TSTE1AD    1.82186 54.264  11.386  25  0.34
OE.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
OE.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
OE.TSTE1AH2F  2.27889 68.3668         25  0.5
OI.TSTE1AL    2.43133 40.1956 41.1163 25  0.35
OI.TSTE1AH    2.43133 40.1956 41.1163 25  0.35
OI.TSTE1AD    1.82186 54.264  11.386  25  0.34
OI.TSTE1AG    1.18376 30.1467 31.6279 20  0.44
OI.TSTE1AB    2.33335 67.1517 18.9767 25  0.37
OI.TSTE1AH2F  2.27889 68.3668         20  0.5
SE.TSTE1AL    2.43133 40.1956 41.1163 30  0.375
SE.TSTE1AH    2.43133 40.1956 41.1163 30  0.375
SE.TSTE1AD    1.82186 54.264  11.386  30  0.3475
SE.TSTE1AG    1.18376 30.1467 31.6279 25  0.485
SE.TSTE1AB    2.33335 67.1517 18.9767 30  0.3975
SE.TSTE1AH2F  2.68089 80.4266         20  0.465
SE.TSTE2LGN   0.29644 1.00489 2.37209 20 0.816667
SE.TSTE2OSL   0.29644 1.00489 2.37209 20 0.816667
SE.TSTE2GDO   0.29644 1.00489 2.37209 20 0.856667
SE.TSTE2NGS   0.29644 1.00489 2.37209 20 0.896667
SE.TSTE2BMS   0.29644 1.00489 2.37209 20 0.816667
AG.TSTE1AL    2.43133 40.1956 41.1163 30 0.375
AG.TSTE1AH    2.43133 40.1956 41.1163 30 0.375
AG.TSTE1AD    1.82186 54.2640  11.386  30 0.3475
AG.TSTE1AG    1.18376 30.1467 31.6279 25 0.485
AG.TSTE1AB    2.33335 67.1517 18.9767 30 0.3975
AG.TSTE1AH2F  2.68089 80.4266         20 0.465
AG.TSTE2LGN   0.29644 1.00489 2.37209 20 0.816667
AG.TSTE2OSL   0.29644 1.00489 2.37209 20 0.816667
AG.TSTE2GDO   0.29644 1.00489 2.37209 20 0.856667
AG.TSTE2NGS   0.29644 1.00489 2.37209 20 0.896667
AG.TSTE2BMS   0.29644 1.00489 2.37209 20 0.816667
HOU.TSTE1AL   2.43133 40.1956 41.1163 30 0.375
HOU.TSTE1AH   2.43133 40.1956 41.1163 30 0.375
HOU.TSTE1AD   1.82186 54.264  11.386  30 0.3475
HOU.TSTE1AG   1.18376 30.1467 31.6279 25 0.485
HOU.TSTE1AB   2.33335 67.1517 18.9767 30 0.3975
HOU.TSTE1AH2F 2.68089 80.4266 0       20 0.465
HOU.TSTE2LGN 0.296442 1.00489 2.37209 20 0.816667
HOU.TSTE2OSL 0.296442 1.00489 2.37209 20 0.816667
HOU.TSTE2GDO 0.296442 1.00489 2.37209 20 0.856667
HOU.TSTE2NGS 0.296442 1.00489 2.37209 20 0.896667
HOU.TSTE2BMS 0.296442 1.00489 2.37209 20 0.816667
;
imDataIndTechnologyCHP(INDDOM,TSTEAM,"IC") = imDataIndTechnologyCHP(INDDOM,TSTEAM,"IC") * 1.3;
imDataIndTechnologyCHP(INDDOM,TSTEAM,"FC") = imDataIndTechnologyCHP(INDDOM,TSTEAM,"FC") * 1.3;
imDataIndTechnologyCHP(INDDOM,TSTEAM,"VC") = imDataIndTechnologyCHP(INDDOM,TSTEAM,"VC") * 1.3;
table imDataChpPowGen(TSTEAM,CHPPGSET,YTIME)   "Data for power generation costs (various)"
$ondelim
$include"./iChpPowGen.csv"
$offdelim
;
parameter i09ParDHEffData(EFS)                  "Parameter of  district heating Efficiency (1)" 
/
HCL		  0.76,
LGN		  0.75,
GDO		  0.78,
RFO		  0.78,
OLQ		  0.78,
NGS		  0.8,
OGS		  0.78,
BMSWAS    0.76 
/
;
i09ProdLftSte(TSTEAM) = imDataChpPowGen(TSTEAM,"LFT","%fBaseY%");
i09CostInvCostSteProd(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"IC",YTIME);
i09CostFixOMSteProd(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"FC",YTIME);
i09CostVOMSteProd(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"VOM",YTIME);
imDataChpPowGen("TSTE2GEO","effThrm",YTIME) = 1;
$ontext
i09EffSteThrm(TDHP,YTIME) = imDataChpPowGen(TDHP,"effThrm","2020");
i09EffSteThrm(TDHP,YTIME)$(not sameas("TSTE2GEO",TDHP)) = 
i09EffSteThrm(TDHP,YTIME) * (i03OutDHPTransfProcess("CHA","STE","2020") + 1e-6) /
(1e-6 - SUM((TDHP2,STEAMEF)$(TSTEAMTOEF(TDHP2,STEAMEF) and (not sameas("TSTE2GEO",TDHP))),imDataChpPowGen(TDHP2,"effThrm","2020") *i03InpDHPTransfProcess("CHA",STEAMEF,"2020")));
$offtext
i09EffSteElc(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"effElc",YTIME);
i09EffSteThrm(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"effThrm",YTIME);
i09AvailRateSteProd(TSTEAM,YTIME) = imDataChpPowGen(TSTEAM,"AVAIL",YTIME);
!!FIXME : What is the difference between imDataChpPowGen vs imDataIndTechnologyCHP?
i09PowToHeatRatio(TSTEAM,YTIME) = i09EffSteElc(TSTEAM,YTIME) / i09EffSteThrm(TSTEAM,YTIME);
i09ShareFuel(allCy,TCHP,EFS,YTIME)$(DATAY(YTIME) and TSTEAMTOEF(TCHP,EFS)) = 
[
  (i03InpCHPTransfProcess(allCy,EFS,YTIME) - 1e-6) /
  (SUM(EFS2$TSTEAMTOEF(TCHP,EFS2),i03InpCHPTransfProcess(allCy,EFS2,YTIME) - 1e-6))
];
i09ShareFuel(allCy,TDHP,EFS,YTIME)$(DATAY(YTIME) and TSTEAMTOEF(TDHP,EFS)) = 
[
  (i03InpDHPTransfProcess(allCy,EFS,YTIME) - 1e-6) /
  (SUM(EFS2$TSTEAMTOEF(TDHP,EFS2),i03InpDHPTransfProcess(allCy,EFS2,YTIME) - 1e-6))
];
```

*VARIABLE INITIALISATION*
```
V09DemGapSte.LO(runCy,YTIME) = 0;
V09ScrapRatePremature.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRatePremature.UP(runCy,TSTEAM,YTIME) = 1;
V09GapShareSte.LO(runCy,TSTEAM,YTIME) = 0;
V09GapShareSte.UP(runCy,TSTEAM,YTIME) = 1;
V09CaptRateSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CaptRateSte.UP(runCy,TSTEAM,YTIME) = 1;
V09ScrapRate.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRate.UP(runCy,TSTEAM,YTIME) = 1;
VmDemTotSte.LO(runCy,YTIME) = 0;
VmDemTotSte.FX(runCy,YTIME)$DATAY(YTIME) = 
SUM(DSBS, imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
i03TotEneBranchCons(runCy,"STE",YTIME) +
imDistrLosses(runCy,"STE",YTIME) +
i03FeedTransfr(runCy,"STE",YTIME);
VmProdSte.LO(runCy,TSTEAM,YTIME) = 0;
VmProdSte.L(runCy,TSTEAM,YTIME) = 1;
VmProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) /
  SUM(EFS$STEAMEF(EFS),i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) * 
  (
    SUM(DSBS$(not DOMSE(DSBS)), imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
    i03TotEneBranchCons(runCy,"STE",YTIME) +
    imDistrLosses(runCy,"STE",YTIME) / 2 +
    i03FeedTransfr(runCy,"STE",YTIME) / 2
  )
)$(TCHP(TSTEAM) and SUM(EFS,i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME))) +
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) /
  SUM(EFS$STEAMEF(EFS),i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) * 
  (
    SUM(DSBS$DOMSE(DSBS), imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
    imDistrLosses(runCy,"STE",YTIME) / 2 +
    i03FeedTransfr(runCy,"STE",YTIME) / 2
  )
)$(TDHP(TSTEAM) and SUM(EFS,i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)));
V09CaptRateSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = i09CaptRateSteProd(TSTEAM);
V09CostCapProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostCapProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
(
  imDisc(runCy,"STEAMP",YTIME) * 
  exp(imDisc(runCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM)) /
  (exp(imDisc(runCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM))-1) * 
  (
    i09CostInvCostSteProd(TSTEAM,YTIME) * imCGI(runCy,YTIME) +
    i09CostFixOMSteProd(TSTEAM,YTIME)
  )
) / (i09PowToHeatRatio(TSTEAM,YTIME) + 1$TDHP(TSTEAM)) /
(
  i09AvailRateSteProd(TSTEAM,YTIME) * 
  smGwToTwhPerYear(YTIME) * 
  smTWhToMtoe * 1e3
);
V09CostVarProdSte.LO(runCy,TSTEAM,YTIME) = epsilon6;
V09CostVarProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
sum(EF$TSTEAMTOEF(TSTEAM,EF),
  (
    VmPriceFuelSubsecCarVal.L(runCy,"STEAMP",EF,YTIME) +
    V09CaptRateSte.L(runCy,TSTEAM,YTIME) * 
    (imCo2EmiFac(runCy,"STEAMP",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * 
    VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 +
    (1-V09CaptRateSte.L(runCy,TSTEAM,YTIME)) * 1e-3 * (imCo2EmiFac(runCy,"STEAMP",EF,YTIME)) *
    sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal.L(runCy,NAP,YTIME))
  )
) / i09EffSteThrm(TSTEAM,YTIME) +
i09CostVOMSteProd(TSTEAM,YTIME) * 1e-3 / smTWhToMtoe * VmPriceElecInd.L(runCy,YTIME) -
(
  VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME) *
  smFracElecPriChp *
  VmPriceElecInd.L(runCy,YTIME)
)$TCHP(TSTEAM);
V09CostProdSte.LO(runCy,TSTEAM,YTIME) = epsilon6;
V09CostProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = V09CostCapProdSte.L(runCy,TSTEAM,YTIME) +
V09CostVarProdSte.L(runCy,TSTEAM,YTIME);
VmCostAvgProdSte.LO(runCy,YTIME) = epsilon6;
VmCostAvgProdSte.FX(runCy,YTIME)$DATAY(YTIME) = 0;
VmConsFuelSteProd.LO(runCy,STEMODE,EFS,YTIME) = 0;
VmConsFuelSteProd.FX(runCy,STEMODE,EFS,YTIME)$(not STEAMEF(EFS)) = 0;
VmConsFuelSteProd.FX(runCy,"CHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpCHPTransfProcess(runCy,STEAMEF,YTIME);
VmConsFuelSteProd.FX(runCy,"DHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpDHPTransfProcess(runCy,STEAMEF,YTIME);
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


-------------------------------------------------------------------------------
         &nbsp;                    Description                  Unit         A 
------------------------ -------------------------------- ----------------- ---
       AG.TSTE1AB           2.33335 67.1517 18.9767 30                       x 
                                      0.3975                                   

       AG.TSTE1AD           1.82186 54.2640 11.386 30                        x 
                                      0.3475                                   

       AG.TSTE1AG           1.18376 30.1467 31.6279 25                       x 
                                      0.485                                    

       AG.TSTE1AH           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

      AG.TSTE1AH2F           2.68089 80.4266 20 0.465                        x 

       AG.TSTE1AL           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

      AG.TSTE2BMS           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

      AG.TSTE2GDO           0.29644 1.00489 2.37209 20                       x 
                                     0.856667                                  

      AG.TSTE2LGN           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

      AG.TSTE2NGS           0.29644 1.00489 2.37209 20                       x 
                                     0.896667                                  

      AG.TSTE2OSL           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

       BM.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       BM.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       BM.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       BM.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      BM.TSTE1AH2F            3.13528 94.0585 30 0.5                         x 

       BM.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       CH.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       CH.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       CH.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       CH.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      CH.TSTE1AH2F            3.13528 94.0585 25 0.5                         x 

       CH.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       EN.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       EN.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       EN.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       EN.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      EN.TSTE1AH2F            2.27889 68.3668 25 0.5                         x 

       EN.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       FD.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       FD.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       FD.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       FD.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      FD.TSTE1AH2F            2.27889 68.3668 25 0.5                         x 

       FD.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      HOU.TSTE1AB           2.33335 67.1517 18.9767 30                       x 
                                      0.3975                                   

      HOU.TSTE1AD            1.82186 54.264 11.386 30                        x 
                                      0.3475                                   

      HOU.TSTE1AG           1.18376 30.1467 31.6279 25                       x 
                                      0.485                                    

      HOU.TSTE1AH           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

     HOU.TSTE1AH2F          2.68089 80.4266 0 20 0.465                       x 

      HOU.TSTE1AL           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

      HOU.TSTE2BMS         0.296442 1.00489 2.37209 20                       x 
                                     0.816667                                  

      HOU.TSTE2GDO         0.296442 1.00489 2.37209 20                       x 
                                     0.856667                                  

      HOU.TSTE2LGN         0.296442 1.00489 2.37209 20                       x 
                                     0.816667                                  

      HOU.TSTE2NGS         0.296442 1.00489 2.37209 20                       x 
                                     0.896667                                  

      HOU.TSTE2OSL         0.296442 1.00489 2.37209 20                       x 
                                     0.816667                                  

  i09AvailRateSteProd       Availability rate of STEAM                       x 
           \                          Plants                                   
    (TSTEAM, YTIME)                                                            

   i09CaptRateSteProd                                                        x 
           \                                                                   
        (TSTEAM)                                                               

  i09CostFixOMSteProd     Fixed O&M cost per steam plant    $US\$2015/KW     x 
           \                           type                       $            
    (TSTEAM, YTIME)                                                            

 i09CostInvCostSteProd     Capital Cost per steam plant    $US\$2015/(KWe    x 
           \                           type                      or            
    (TSTEAM, YTIME)                                            KWThrm)         
                                                                  $            

   i09CostVOMSteProd      Variable cost per steam plant    $US\$2015/toe$    x 
           \                           type                                    
    (TSTEAM, YTIME)                                                            

    i09EffSteElc \                                                           x 
    (TSTEAM, YTIME)                                                            

    i09EffSteThrm \                                                          x 
    (TSTEAM, YTIME)                                                            

    i09ParDHEffData                                                          x 
           \                                                                   
         (EFS)                                                                 

   i09PowToHeatRatio                                                         x 
           \                                                                   
    (TSTEAM, YTIME)                                                            

    i09ProdLftSte \        Lifetime of steam production                      x 
        (TSTEAM)              technologies in years                            

   i09ScaleEndogScrap                                                        x 

    i09ShareFuel \                                                           x 
    (allCy, TSTEAM,                                                            
      EFS, YTIME)                                                              

           IC                     FC VC LFT USC                              x 

    imDataChpPowGen         Data for power generation         $various$      x 
           \                          costs                                    
        (TSTEAM,                                                               
       CHPPGSET,                                                               
         YTIME)                                                                

 imDataIndTechnologyCHP   Technoeconomic characteristics      $various$      x 
           \                       of industry                                 
        (INDDOM,                                                               
        TSTEAM,                                                                
       ECONCHAR)                                                               

       IS.TSTE1AB          1.00334 28.8752 8.16 25 0.37                      x 

       IS.TSTE1AD         0.78340 23.3335 4.896 25 0.34                      x 

       IS.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       IS.TSTE1AH          1.04547 17.284 17.68 25 0.35                      x 

      IS.TSTE1AH2F            1.34817 40.4451 25 0.5                         x 

       IS.TSTE1AL          1.04547 17.284 17.68 25 0.35                      x 

       NF.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       NF.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       NF.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       NF.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      NF.TSTE1AH2F            3.13528 94.0585 30 0.5                         x 

       NF.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       OE.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       OE.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       OE.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       OE.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      OE.TSTE1AH2F            2.27889 68.3668 25 0.5                         x 

       OE.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       OI.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       OI.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       OI.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       OI.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      OI.TSTE1AH2F            2.27889 68.3668 20 0.5                         x 

       OI.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

       PP.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       PP.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       PP.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       PP.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      PP.TSTE1AH2F            2.27889 68.3668 25 0.5                         x 

       PP.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

     Q09CaptRateSte                                                          x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

   Q09ConsFuelSteProd                                                        x 
           \                                                                   
        (allCy,                                                                
     STEMODE, EFS,                                                             
         YTIME)                                                                

   Q09CostAvgProdSte                                                         x 
           \                                                                   
     (allCy, YTIME)                                                            

   Q09CostCapProdSte                                                         x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

     Q09CostProdSte                                                          x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

   Q09CostVarProdSte                                                         x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

    Q09DemGapSte \                                                           x 
     (allCy, YTIME)                                                            

    Q09DemTotSte \                                                           x 
     (allCy, YTIME)                                                            

     Q09GapShareSte                                                          x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

     Q09ProdSte \                                                            x 
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

    Q09ScrapRate \                                                           x 
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

 Q09ScrapRatePremature                                                       x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

       SE.TSTE1AB           2.33335 67.1517 18.9767 30                       x 
                                      0.3975                                   

       SE.TSTE1AD            1.82186 54.264 11.386 30                        x 
                                      0.3475                                   

       SE.TSTE1AG           1.18376 30.1467 31.6279 25                       x 
                                      0.485                                    

       SE.TSTE1AH           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

      SE.TSTE1AH2F           2.68089 80.4266 20 0.465                        x 

       SE.TSTE1AL           2.43133 40.1956 41.1163 30                       x 
                                      0.375                                    

      SE.TSTE2BMS           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

      SE.TSTE2GDO           0.29644 1.00489 2.37209 20                       x 
                                     0.856667                                  

      SE.TSTE2LGN           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

      SE.TSTE2NGS           0.29644 1.00489 2.37209 20                       x 
                                     0.896667                                  

      SE.TSTE2OSL           0.29644 1.00489 2.37209 20                       x 
                                     0.816667                                  

       TX.TSTE1AB           2.33335 67.1517 18.9767 25                       x 
                                       0.37                                    

       TX.TSTE1AD         1.82186 54.264 11.386 25 0.34                      x 

       TX.TSTE1AG           1.18376 30.1467 31.6279 20                       x 
                                       0.44                                    

       TX.TSTE1AH           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

      TX.TSTE1AH2F            2.27889 68.3668 20 0.5                         x 

       TX.TSTE1AL           2.43133 40.1956 41.1163 25                       x 
                                       0.35                                    

     V09CaptRateSte                                                          x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

   V09CostCapProdSte       Capex and O&M costs of steam    $kUS\$2015/toe$   x 
           \                 generation technologies                           
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

     V09CostProdSte          Cost of steam production      $kUS\$2015/toe$   x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

   V09CostVarProdSte          Variable cost of steam       $kUS\$2015/toe$   x 
           \                 generation technologies                           
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

    V09DemGapSte \                                                           x 
     (allCy, YTIME)                                                            

     V09GapShareSte                                                          x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

    V09ScrapRate \                                                           x 
    (allCy, TSTEAM,                                                            
         YTIME)                                                                

 V09ScrapRatePremature                                                       x 
           \                                                                   
    (allCy, TSTEAM,                                                            
         YTIME)                                                                
-------------------------------------------------------------------------------

Table: module-internal objects (A: heat)



### Sets


----------------------------------------------------
       &nbsp;                  description          
-------------------- -------------------------------
       ALIAS                 (H2TECH2H2TECH)        

       allCy            All Countries Used in the   
                                  Model             

      CHPPGSET                                      

    DOMSE(DSBS)            Tertiary SubSectors      

     DSBS(SBS)            All Demand Subsectors     

      ECONCHAR            Technical - Economic      
                       characteristics for demand   
                              technologies          

         EF                   Energy Forms          

      EFS(EF)          Energy Forms used in Supply  
                                  Side              

        HOU                11.511 0.9 0.00001       

    INDDOM(DSBS)          Industry and Tertiary     

 NAP(Policies_set)      National Allocation Plan    
                            sector categories       

  NAPtoALLSBS(NAP,    Energy sectors corresponding  
      ALLSBS)                to NAP sectors         

    runCy(allCy)      Countries for which the model 
                               is running           

   runCyL(allCy)      Countries for which the model 
                      is running (used in countries 
                                  loop)             

    SBS(ALLSBS)             Model Subsectors        

     STEAM(EFS)                   Steam             

    STEAMEF(EFS)          Fuels used for steam      
                               production           

      STEMODE            Steam production modes     

    TCHP(TSTEAM)         CHP plant technologies     

    TDHP(TSTEAM)         CHP plant technologies     

       TSTEAM         CHP & DHP plant technologies  

 TSTEAMTOEF(TSTEAM,    Correspondence between chp   
        EF)              plants and energy forms    
----------------------------------------------------

Table: sets in use



See Also
--------

[02_Industry], [03_RestOfEnergy], [06_CO2], [08_Prices], [core]

