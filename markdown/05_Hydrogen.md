Hydrogen module (05_Hydrogen) {#id-05_Hydrogen}
=============================

Description
-----------

This is the Hydrogen module.


Interfaces
----------

**Interface plot missing!**

### Input


------------------------------------------------------------------------------
          &nbsp;                     Description                Unit        A 
-------------------------- ------------------------------- --------------- ---
       VmCarVal \               Carbon prices for all       $US\$2015/tn    x 
       (allCy, NAP,                   countries                 CO2$          
          YTIME)                                                              

      VmConsFuel \          Consumption of fuels in each       $Mtoe$       x 
      (allCy, DSBS,          demand subsector, excluding                      
        EF, YTIME)               heat from heatpumps                          

    VmConsFuelDACProd         Annual fuel demand in DAC        $Mtoe$       x 
            \                        regionally                               
       (allCy, EF,                                                            
          YTIME)                                                              

    VmConsFuelElecProd                                                      x 
            \                                                                 
       (allCy, EFS,                                                           
          YTIME)                                                              

     VmCstCO2SeqCsts             Cost curve for CO2         $US\$2015/tn    x 
            \                    sequestration costs             of           
      (allCy, YTIME)                                             CO2          
                                                            sequestrated$     

 VmDemFinEneTranspPerFuel      Final energy demand in          $Mtoe$       x 
            \               transport subsectors per fuel                     
     (allCy, TRANSE,                                                          
        EF, YTIME)                                                            

 VmPriceFuelSubsecCarVal    Fuel prices per subsector and   $k\$2015/toe$   x 
            \                           fuel                                  
       (allCy, SBS,                                                           
        EF, YTIME)                                                            
------------------------------------------------------------------------------

Table: module inputs (A: legacy)



### Output


-------------------------------------------------------------
        &nbsp;                   Description            Unit 
---------------------- ------------------------------- ------
   VmConsFuelH2Prod      Total fuel consumption for          
          \              hydrogen production in Mtoe         
     (allCy, EF,                                             
        YTIME)                                               

 VmConsFuelTechH2Prod   Fuel consumption by hydrogen         
          \             production technology in Mtoe        
   (allCy, H2TECH,                                           
      EF, YTIME)                                             

   VmCostAvgProdH2       Average production cost of          
          \               hydrogen in Euro per toe           
    (allCy, YTIME)                                           

    VmDemSecH2 \         Demand for H2 by sector in          
     (allCy, SBS,                   mtoe                     
        YTIME)                                               

    VmDemTotH2 \             Hydrogen production             
    (allCy, YTIME)         requirement in Mtoe for           
                            meeting final demand             

     VmProdH2 \            Hydrogen Production by            
   (allCy, H2TECH,           technology in Mtoe              
        YTIME)                                               
-------------------------------------------------------------

Table: module outputs



Realizations
------------

### (A) legacy

This is the legacy realization of the Hydrogen module.

```
sets
H2TECH "Hydrogen production technologies"
/
gsr   "gas steam reforming"
gss   "gas steam reforming with CCS"
weg   "water electrolysis from grid power"
wew   "water electrolysis with wind"
wes   "water electrolysis with solar"
cgf   "coal gasification"
cgs   "coal gasification with CCS"
bgfl  "biomass gasification large scale"
bgfls "biomass gasification large scale with CCS"
/
INFRTECH                  "Hydrogen storage and distribution technologies"
/
tpipa "turnpike pipeline used also as a storage medium"
hpipi "high pressure for industry"
hpipu "high pressure for urban"
mpipu "medium pressure for urban"
lpipu "low pressure for urban"
mpips "medium pressure for service stations of length of 2km"
ssgg  "service stations gaseous H2"
/
PIPES(INFRTECH)            "Pipelines"
/
tpipa "turnpike pipeline used also as a storage medium"
hpipi "high pressure for industry"
hpipu "high pressure for urban"
mpipu "medium pressure for urban"
lpipu "low pressure for urban"
mpips "medium pressure for service stations"
/
H2STATIONS(INFRTECH)       "Service stations for hydrogen powered cars"
/
ssgg "service stations gas"
/
INFRTECHtoEF(INFRTECH,EF)  "Type of energy consumed onsite for the operation of the infrastructure technology"
/
hpipu.h2f
ssgg.elc
/
H2NETWORK(INFRTECH,INFRTECH)
/
TPIPA.(HPIPI,HPIPU)
HPIPU.MPIPU
MPIPU.(MPIPS,LPIPU)
MPIPS.SSGG
/
H2EFFLOOP(INFRTECH)
/
HPIPI
HPIPU
MPIPU
MPIPS
LPIPU
SSGG
/
H2INFRSBS(INFRTECH,SBS)  "Infrustructure required by demand sector"
/
TPIPA.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI,SE,AG,HOU,PC,GU,PA,PT,GT)
LPIPU.(SE,AG,HOU)
(SSGG,MPIPS).(PC,GU,PA,PT,GT)
(MPIPU,HPIPU).(SE,AG,HOU,PC,GU,PA,PT,GT)
HPIPI.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI)
/
H2INFRDNODES(INFRTECH)
/
HPIPI
LPIPU
SSGG
/
H2TECHEFtoEF(H2TECH,EF)   "Mapping between production technologies and fuels"
/
(gsr,gss).ngs !! ,smr
(cgf,cgs).hcl
(bgfls,bgfl).BMSWAS !! bpy,bgfs,
weg.ELC
wes.ELC
wew.ELC
/
$ontext
H2TECHtoPGALL(H2TECH,PGALL)  "Mapping between hydrogen production technologies and power generation technologies used for water electrolysis"
/
wes.PGSOL
wew.PGAWNO
/
$offtext
H2PRODEF(EF)               "Fuels used for hydrogen production"
/
ngs
hcl
bmswas
sol
nuc
elc
wnd
rfo
/
H2TECHREN(H2TECH)          "Renewable hydrogen production technologies"
/
wew
wes
/
H2CCS(H2TECH)              "Hydrogen production technologies equipped with CCS facility"
/
gss   "gas steam reforming with CCS"
cgs   "coal gasification with CCS"
bgfls "biomass gasification large scale with CCS"
/
H2NOCCS(H2TECH)            "Hydrogen production technologies without CCS but with corresponding option with CCS"
/
gsr
cgf
bgfl
/
H2CCS_NOCCS(H2TECH,H2TECH) "Mapping between hydrogen technologies with and without CCS facility"
/
gss.gsr
cgs.cgf
bgfls.bgfl
/
H2TECHPM(H2TECH)           "Technologies for which premature replacement is active"
/
gsr
cgf
bgfl
weg
/
ARELAST                    "Set containing the names of the elasticities used in area covered by H2 logistic fucntion"
/
B        "parameter controlling the speed to the transition to hydrogen economy"
mid      "mid point after which the hydrogen economy is taking off"
/
ECONCHARHY                 "Technical - Economic characteristics for demand technologies Hydrogen"
/
IC
FC
VC
EFF
SELF
AVAIL
LFT
H2KMTOE
mpips
lpipu
mpipu
AREA
MAXAREA
B
mid
CR
/
INFRTECHLAB(INFRTECH,ECONCHARHY)
/
mpips.mpips
lpipu.lpipu
mpipu.mpipu
/
ALIAS (H2TECH2,H2TECH);
ALIAS (INFRTECH3,INFRTECH2, INFRTECH);
```

```
Variables
V05GapShareH2Tech1(allCy, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 1"
V05GapShareH2Tech2(allCy, H2TECH, YTIME)          "Shares of H2 production technologies in new market competition 2"
V05CapScrapH2ProdTech(allCy, H2TECH, YTIME)       "Decommissioning of capacity by H2 production technology"
V05PremRepH2Prod(allCy, H2TECH, YTIME)            "Premature replacement of H2 production technologies"
V05ScrapLftH2Prod(allCy, H2TECH, YTIME)           "Scrapping of equipment due to lifetime (normal scrapping)"
V05DemGapH2(allCy, YTIME)                         "Demand for H2 to be covered by new equipment in mtoe"
V05CostProdH2Tech(allCy, H2TECH, YTIME)           "Hydrogen production cost per technology in US$2015 per toe of hydrogen"
V05CostVarProdH2Tech(allCy, H2TECH, YTIME)        "Variable cost (including fuel cost) for hydrogen production by technology in US$2015 per toe"
V05ShareCCSH2Prod(allCy, H2TECH, YTIME)           "Share of CCS technology in the decision tree between CCS and no CCS"
V05ShareNoCCSH2Prod(allCy, H2TECH, YTIME)         "Share of technology without CCS in the decision tree between CCS and no CCS"
V05AcceptCCSH2Tech(allCy, YTIME)                  "Acceptance of investment in CCS technologies"
V05CostProdCCSNoCCSH2Prod(allCy, H2TECH, YTIME)   "Production cost of the composite technology with and without CCS in Euro per toe"
VmCostAvgProdH2(allCy, YTIME)                    "Average production cost of hydrogen in Euro per toe"
V05CaptRateH2(allCy,H2TECH,YTIME)
$ontext
```
**Infrastructure Variables**
```
V05H2InfrArea(allCy, YTIME)                       "Number of stylised areas covered by H2 infrastructure"
V05DelivH2InfrTech(allCy, INFRTECH, YTIME)        "Hydrogen delivered by infrastructure technology in Mtoe"
V05InvNewReqH2Infra(allCy, INFRTECH, YTIME)       "New infrastructure requirements in Mtoe of delivered hydrogen"
V05H2Pipe(allCy, INFRTECH, YTIME)                 "Required capacity to meet the new infrastructure requirements"
                                                    !! - km of pipelines
                                                    !! - number of service stations
V05CostInvTechH2Infr(allCy, INFRTECH, YTIME)      "Investment cost of infrastructure by technology in Million Euros (MEuro) for meeting the new infrastructure requirements"
V05CostInvCummH2Transp(allCy, INFRTECH, YTIME)    "Average cost of infrastructure Euro per toe"
V05CostTechH2Infr(allCy, INFRTECH, YTIME)         "Marginal cost by infrastructure technology in Euro"
V05TariffH2Infr(allCy, INFRTECH, YTIME)           "Tarrif paid by the final consumer for using the specific infrastructure technology in Euro per toe annual"
V05PriceH2Infr(allCy, SBS, YTIME)                 "Hydrogen distribution and storage price paid by final consumer in Euro per toe annual"
V05CostTotH2(allCy, SBS, YTIME)                   "Total Hydrogen Cost Per Sector in Euro per toe"
```
*** Miscellaneous
```
$offtext
```
**Interdependent Variables**	
```
VmDemTotH2(allCy, YTIME)                          "Hydrogen production requirement in Mtoe for meeting final demand"
VmProdH2(allCy, H2TECH, YTIME)                    "Hydrogen Production by technology in Mtoe"
VmConsFuelTechH2Prod(allCy, H2TECH, EF, YTIME)    "Fuel consumption by hydrogen production technology in Mtoe"
VmDemSecH2(allCy, SBS, YTIME)                     "Demand for H2 by sector in mtoe"
VmCostAvgProdH2(allCy, YTIME)                     "Average production cost of hydrogen in Euro per toe"
VmConsFuelH2Prod(allCy, EF, YTIME)                "Total fuel consumption for hydrogen production in Mtoe"
;
Equations
Q05GapShareH2Tech1(allCy, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 1"
Q05GapShareH2Tech2(allCy, H2TECH, YTIME)          "Equation for calculating the shares of technologies in hydrogen gap using Weibull equations 2"
Q05CapScrapH2ProdTech(allCy, H2TECH, YTIME)       "Equation for decommissioning of capacity by H2 production technology"
Q05PremRepH2Prod(allCy, H2TECH, YTIME)            "Equation for premature replacement of H2 production technologies"
Q05ScrapLftH2Prod(allCy, H2TECH, YTIME)           "Equation for scrapping of equipment due to lifetime (normal scrapping)"
Q05DemGapH2(allCy, YTIME)                         "Equation for gap in hydrogen demand"
Q05CostProdH2Tech(allCy, H2TECH, YTIME)           "Equation for hydrogen production cost per technology"
Q05CostVarProdH2Tech(allCy, H2TECH, YTIME)        "Equation for variable cost (including fuel cost) for hydrogen production by technology in Euro per toe"
Q05ShareCCSH2Prod(allCy, H2TECH, YTIME)           "Equation for share of CCS technology in the decision tree between CCS and no CCS"
Q05ShareNoCCSH2Prod(allCy, H2TECH, YTIME)         "Equation for share of technology without CCS in the decision tree between CCS and no CCS"
Q05AcceptCCSH2Tech(allCy, YTIME)                  "Equation for acceptance in CCS technologies"
Q05ConsFuelH2Prod(allCy, EF, YTIME)               "Equation for total fuel consumption for hydrogen production"
Q05CostProdCCSNoCCSH2Prod(allCy, H2TECH, YTIME)   "Equation for calculating the production cost of the composite technology with and without CCS"
Q05CostAvgProdH2(allCy, YTIME)                    "Equation for average production cost of hydrogen in Euro per toe"
Q05CaptRateH2(allCy,H2TECH,YTIME)
$ontext
```
**Infrastructure Equations**
```
Q05H2InfrArea(allCy, YTIME)                       "Equation for infrastructure area"
Q05DelivH2InfrTech(allCy, INFRTECH, YTIME)        "Equation for hydrogen delivered by infrastructure technology in Mtoe"
Q05InvNewReqH2Infra(allCy, INFRTECH, YTIME)       "Equation for calculating the new requirements in infrastructure in Mtoe"
Q05H2Pipe(allCy, INFRTECH, YTIME)                 "Equation for km per pipeline"
Q05CostInvTechH2Infr(allCy, INFRTECH, YTIME)      "Equation for infrastructure investment cost in Euro by technology"
Q05CostInvCummH2Transp(allCy, INFRTECH, YTIME)    "Equation for cumulative investment cost by infrastructure technology"
Q05CostTechH2Infr(allCy, INFRTECH, YTIME)         "Equation for marginal cost by infrastructure technology in Euro"
Q05TariffH2Infr(allCy, INFRTECH, YTIME)           "Equation for calculating the tariff paid by the final consumer for using the specific infrastructure technology"
Q05PriceH2Infr(allCy, SBS, YTIME)                 "Equation for calulcating the hydrogen storage and distribution price by final consumer"
Q05CostTotH2(allCy, SBS, YTIME)                   "Equation of total hydrogen cost Per Sector"
```
*** Miscellaneous
```
$offtext
```
**Interdependent Equations**	
```
Q05DemTotH2(allCy, YTIME)                         "Equation for total hydrogen demand in a country in Mtoe"
Q05ProdH2(allCy, H2TECH, YTIME)                   "Equation for H2 production by technology"
Q05ConsFuelTechH2Prod(allCy, H2TECH, EF, YTIME)   "Equation for fuel consumption by technology for hydrogen production"
Q05DemSecH2(allCy, SBS, YTIME)                    "Equation for demand of H2 by sector in mtoe"
;
Scalars
s05AreaStyle                                      "stylised area in km2" /3025/
s05SalesH2Station                                 "annual sales of a hydrogen service station in ktoe" /2.26/
s05LenH2StationConn                               "length of pipes connection service stations with the ring in km per station" /2/
s05DelivH2Turnpike                                "stylised annual hydrogen delivery in turnpike pipeline in ktoe" /275/
;
```

This equation calculates the total hydrogen demand in the system. It takes into account the overall need for hydrogen
across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
```
Q05DemTotH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotH2(allCy,YTIME)
                 =E=
    sum(SBS$SECtoEF(SBS,"H2F"), 
      VmDemSecH2(allCy,SBS, YTIME) /
      prod(INFRTECH$H2INFRSBS(INFRTECH,SBS),
        i05EffH2Transp(allCy,INFRTECH,YTIME)*
        (1-i05ConsSelfH2Transp(allCy,INFRTECH,YTIME))
      )
    )  !! increase the demand due to transportation losses
;
```
This equation calculates the sectoral hydrogen demand (VmDemSecH2) for each demand subsector (DSBS), year, and region.
It sums up hydrogen consumption from both industrial/tertiary sectors (using VmConsFuel) and transport sectors (using VmDemFinEneTranspPerFuel),
ensuring each subsector receives only the relevant demand.
```
Q05DemSecH2(allCy,SBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemSecH2(allCy,SBS,YTIME)
        =E=
    sum(INDDOM$SAMEAS(INDDOM,SBS), VmConsFuel(allCy,INDDOM,"H2F",YTIME)) +
    sum(TRANSE$SAMEAS(TRANSE,SBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"H2F",YTIME)) +
    VmConsFuelDACProd(allCy,"H2F",YTIME)$sameas("DAC",SBS) +
    VmConsFuelElecProd(allCy,"H2F",YTIME)$sameas("PG",SBS);
```
This equation defines the amount of hydrogen production capacity that is scrapped due to the expiration of the useful life of plants.
It considers the remaining lifetime of hydrogen production facilities and the impact of past production gaps.
```
Q05ScrapLftH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V05ScrapLftH2Prod(allCy,H2TECH,YTIME)
         =E=
        (1/i05ProdLftH2(H2TECH,YTIME))$(ord(YTIME)>11+i05ProdLftH2(H2TECH,YTIME))
$ontext
         (
         V05GapShareH2Tech1(allCy,H2TECH,YTIME-i05ProdLftH2(H2TECH,YTIME)) *
         V05DemGapH2(allCy,YTIME-i05ProdLftH2(H2TECH,YTIME)) /
         (VmProdH2(allCy,H2TECH,YTIME-1) + 1e-6)
         )$(ord(YTIME)>11+i05ProdLftH2(H2TECH,YTIME))
$offtext
;
```
This equation models the premature replacement of hydrogen production capacity. It adjusts for the need to replace aging
or inefficient hydrogen production technologies before their expected end of life based on economic factors such as cost,
technological progress, and demand shifts.
```
Q05PremRepH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$H2TECHPM(H2TECH))..
    V05PremRepH2Prod(allCy,H2TECH,YTIME)
        =E=
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME)**(-i05WBLGammaH2Prod(allCy,YTIME)) /
    (
      iWBLPremRepH2Prod(allCy,H2TECH,YTIME) *
      (
        sum(H2TECH2$(not sameas(H2TECH,H2TECH2)),
          V05CostProdH2Tech(allCy,H2TECH2,YTIME)
          !!V05GapShareH2Tech1(allCy,H2TECH2,YTIME)*
          !!(1/i05AvailH2Prod(allCy,H2TECH,YTIME)*
          !!V05CostProdH2Tech(allCy,H2TECH2,YTIME) +
          !!(1-1/i05AvailH2Prod(allCy,H2TECH,YTIME)) * V05CostVarProdH2Tech(allCy,H2TECH2,YTIME))
        )
      )**(-i05WBLGammaH2Prod(allCy,YTIME)) +
      V05CostVarProdH2Tech(allCy,H2TECH,YTIME)**(-i05WBLGammaH2Prod(allCy,YTIME))
    );
```
This equation calculates the total hydrogen production capacity that is scrapped as part of the premature replacement
and normal plant life cycle. It links the scrapped capacity to the overall age distribution and retirement schedule of
hydrogen production technologies.
```
Q05CapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)
      =E=
    1 - (1-V05ScrapLftH2Prod(allCy,H2TECH,YTIME)) *
    V05PremRepH2Prod(allCy,H2TECH,YTIME);
```
The hydrogen demand gap equation defines the difference between the total hydrogen demand (calculated in Q05DemTotH2) and
the actual hydrogen production capacity. It ensures that the gap value is non-negative, preventing overproduction or underproduction of hydrogen.
```
Q05DemGapH2(allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05DemGapH2(allCy, YTIME)
                 =E=
         ( 
          VmDemTotH2(allCy,YTIME) -
          sum(H2TECH,
            (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) *
            VmProdH2(allCy,H2TECH,YTIME-1)
          ) +
    SQRT( SQR(
          VmDemTotH2(allCy,YTIME) -
          sum(H2TECH,
            (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) *
            VmProdH2(allCy,H2TECH,YTIME-1)
          )
    )) )/2 + 1e-6
;
```
This equation calculates the production costs of hydrogen, including both fixed costs (e.g., capital investment) 
and variable costs (e.g., operational expenses). The costs are typically differentiated by hydrogen production 
technologies such as electrolysis, steam methane reforming (SMR), or coal gasification.
```
Q05CostProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CostProdH2Tech(allCy,H2TECH,YTIME)
        =E=
    (
      imDisc(allCy,"H2P",YTIME) * 
      exp(imDisc(allCy,"H2P",YTIME)* i05ProdLftH2(H2TECH,YTIME)) /
      (exp(imDisc(allCy,"H2P",YTIME) * i05ProdLftH2(H2TECH,YTIME))-1) * 
      (
        i05CostCapH2Prod(allCy,H2TECH,YTIME) +
        i05CostFOMH2Prod(allCy,H2TECH,YTIME) +
        i05CostVOMH2Prod(allCy,H2TECH,YTIME)
      ) +
      (
      (V04CapexFixCostPG(allCy,"PGSOL",YTIME))$sameas(H2TECH,"wes") + 
      (V04CapexFixCostPG(allCy,"PGAWNO",YTIME))$sameas(H2TECH,"wew")
      )
    ) / 
    (i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe) +
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME)  
;
```
This equation models the variable costs associated with hydrogen production, factoring in fuel prices (e.g., electricity or natural gas),
CO₂ emission costs, and the efficiency of the production technology. This helps to understand the fluctuating costs based on market conditions.
```
Q05CostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME)
        =E=
    sum(EF$H2TECHEFtoEF(H2TECH,EF),
      (
        VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME) * 1e3 +
        V05CaptRateH2(allCy,H2TECH,YTIME) * (imCo2EmiFac(allCy,"H2P",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * VmCstCO2SeqCsts(allCy,YTIME) +
        (1-V05CaptRateH2(allCy,H2TECH,YTIME)) * (imCo2EmiFac(allCy,"H2P",EF,YTIME)) *
        sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME))
      ) 
    )$(not H2TECHREN(H2TECH)) / i05EffH2Prod(allCy,H2TECH,YTIME) +
    (i04VarCost("PGSOL",YTIME) / (smTWhToMtoe))$(sameas(H2TECH,"wes")) +
    (i04VarCost("PGAWNO",YTIME) / (smTWhToMtoe))$(sameas(H2TECH,"wew"))
    
;
```
This equation models the acceptance of carbon capture and storage (CCS) technologies in hydrogen production. 
It evaluates the economic feasibility of adding CCS to the hydrogen production process, considering cost, 
environmental policies, and technology readiness.
```
Q05AcceptCCSH2Tech(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05AcceptCCSH2Tech(allCy,YTIME)
    =E=
    i05WBLGammaH2Prod(allCy,YTIME)*2 +
    EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME -1)))))
;
```
This equation determines the share of hydrogen produced using CCS technologies compared to those produced without CCS.
The share is calculated based on relative costs, technological feasibility, and policy incentives supporting CCS.
```
Q05ShareCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2CCS(H2TECH) $(runCy(allCy)))..
         V05ShareCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
                 1.5  *
         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 V05CostProdH2Tech(allCy,H2TECH,YTIME)**(-V05AcceptCCSH2Tech(allCy,YTIME)) /
         (
                 1.5  *
         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 V05CostProdH2Tech(allCy,H2TECH,YTIME)**(-V05AcceptCCSH2Tech(allCy,YTIME)) +
                 sum(H2TECH2$H2CCS_NOCCS(H2TECH,H2TECH2),
                 1  *
         iWBLShareH2Prod(allCy,H2TECH2,YTIME) *
                 V05CostProdH2Tech(allCy,H2TECH2,YTIME)**(-V05AcceptCCSH2Tech(allCy,YTIME)))
         )
;
```
Similar to Q05ShareCCSH2Prod, this equation models the share of hydrogen produced without CCS technologies.
It calculates the proportion of production from non-CCS methods like electrolysis or SMR without CO₂ capture.
```
Q05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy)))..
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , V05ShareCCSH2Prod(allCy,H2TECH2,YTIME) )
;
```
This equation computes the weighted average production cost of hydrogen, incorporating both CCS and non-CCS production methods.
It provides an overall cost perspective, helping to assess which production methods dominate the market based on cost-efficiency.
```
Q05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy))) ..
         V05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)*V05CostProdH2Tech(allCy,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), V05ShareCCSH2Prod(allCy,H2CCS,YTIME)*V05CostProdH2Tech(allCy,H2CCS,YTIME))
;
```
This equation calculates the market share of different hydrogen production technologies, considering factors
like cost competitiveness, policy support, and fuel availability. It adjusts market shares based on technological
performance and shifting cost dynamics.
```
Q05GapShareH2Tech2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)
          =E=
    (
      iWBLShareH2Prod(allCy,H2TECH,YTIME) * 
      (V05CostProdH2Tech(allCy,H2TECH,YTIME)$(not H2NOCCS(H2TECH)) + V05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))**(-i05WBLGammaH2Prod(allCy,YTIME)) /
      sum(H2TECH2$(not H2CCS(H2TECH2)),
      iWBLShareH2Prod(allCy,H2TECH2,YTIME) * 
      (V05CostProdH2Tech(allCy,H2TECH2,YTIME)$(not H2NOCCS(H2TECH2)) + V05CostProdCCSNoCCSH2Prod(allCy,H2TECH2,YTIME)$H2NOCCS(H2TECH2))**(-i05WBLGammaH2Prod(allCy,YTIME))
      )
    )$(not H2CCS(H2TECH)) +
    sum(H2NOCCS$H2CCS_NOCCS(H2TECH,H2NOCCS), V05GapShareH2Tech2(allCy,H2NOCCS,YTIME))$H2CCS(H2TECH);
```
This equation further adjusts the market share of hydrogen technologies, particularly considering 
the relative competitiveness between CCS and non-CCS technologies. It helps to model the transition 
between different production technologies over time.
```
Q05GapShareH2Tech1(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05GapShareH2Tech1(allCy,H2TECH,YTIME)
        =E=
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH))) +
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)*(V05ShareCCSH2Prod(allCy,H2TECH,YTIME)$H2CCS(H2TECH) +  V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))   
;
```
This equation defines the actual hydrogen production levels, considering both scrapped capacity and the demand gap.
It allocates production from different technologies to meet the overall demand, adjusting for changes in capacity and technology availability.
```
Q05ProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdH2(allCy,H2TECH,YTIME)
        =E=
    (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) * VmProdH2(allCy,H2TECH,YTIME-1) +
    V05GapShareH2Tech1(allCy,H2TECH,YTIME) * V05DemGapH2(allCy,YTIME);
```
This equation calculates the average cost of hydrogen production across all technologies in the system.
It accounts for varying costs of different technologies (e.g., electrolysis vs. SMR) to provide an overall assessment of hydrogen production cost.
```
Q05CostAvgProdH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdH2(allCy,YTIME)
        =E=
    ( sum(H2TECH, 
        VmProdH2(allCy,H2TECH,YTIME) *
        V05CostProdH2Tech(allCy,H2TECH,YTIME)
      ) + 1e-6
    ) /
    (sum(H2TECH,VmProdH2(allCy,H2TECH,YTIME)) + 1e-6)
;
```
This equation calculates the fuel consumption for each hydrogen production technology, considering 
the efficiency of the technology and the amount of fuel required for producing a unit of hydrogen. 
It provides insight into fuel demand for hydrogen production.
```
Q05ConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)$(TIME(YTIME) $H2TECHEFtoEF(H2TECH,EF) $(runCy(allCy)))..
         VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)
         =E=
         VmProdH2(allCy,H2TECH,YTIME)/i05EffH2Prod(allCy,H2TECH,YTIME)!!-
;
```
This equation aggregates the total fuel consumption across all hydrogen production technologies in the system,
summing up the fuel requirements from all sources. It helps track the total fuel demand for hydrogen production.
```
Q05ConsFuelH2Prod(allCy,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF) $(runCy(allCy)))..
    VmConsFuelH2Prod(allCy,EF,YTIME)
        =E=
    sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME))
;
$ontext
!!
!!                               B. Hydrogen Infrustructure
!!
```
This equation models the expansion of hydrogen infrastructure (e.g., pipelines, storage facilities)
needed to support growing demand. It takes into account the projected growth in hydrogen production 
and distribution, ensuring that infrastructure expansion aligns with demand forecasts.
```
Q05H2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05H2InfrArea(allCy,YTIME)
         =E=
          i05PolH2AreaMax(allCy)/(1 + exp( -i05H2Adopt(allCy,"B",YTIME)*( VmDemTotH2(allCy,YTIME)/(i05HabAreaCountry(allCy)/s05AreaStyle*0.275)- i05H2Adopt(allCy,"MID",YTIME))))
;
```
This equation represents the delivery or throughput capacity of hydrogen infrastructure technologies.
It calculates the total amount of hydrogen that can be delivered through the infrastructure, considering
factors such as efficiency and technological limits of the infrastructure components (e.g., pipelines, storage, etc.).
```
Q05DelivH2InfrTech(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V05DelivH2InfrTech(allCy,INFRTECH,YTIME)
         =E=
         (
         (    sum(SBS$(H2INFRSBS(INFRTECH,SBS) $SECTtoEF(SBS,"H2F")), VmDemSecH2(allCy,SBS, YTIME))/
            (i05EffH2Transp(allCy,INFRTECH,YTIME)*(1-i05ConsSelfH2Transp(allCy,INFRTECH,YTIME))) )$H2INFRDNODES(INFRTECH)  !! for final demand nodes
         +
         sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2), V05DelivH2InfrTech(allCy,INFRTECH2,YTIME)/(i05EffH2Transp(allCy,INFRTECH,YTIME)*(1-i05ConsSelfH2Transp(allCy,INFRTECH,YTIME))))$(not H2INFRDNODES(INFRTECH))
         )$i05PolH2AreaMax(allCy)
         +1e-7
;
```
This equation determines the required new investment in hydrogen infrastructure to meet the demand or capacity requirements.
It calculates the amount of investment needed to develop or upgrade the infrastructure technologies (like production, storage, and transport)
to support future hydrogen use or capacity expansion.
```
Q05InvNewReqH2Infra(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)
         =E=
         ( V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;
```
This equation focuses on the hydrogen transport capacity through pipelines. It calculates the amount of hydrogen that can be
transported through the hydrogen pipeline system, considering factors such as pipe size, pressure, flow rate, and distance.
```
Q05H2Pipe(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05H2Pipe(allCy,INFRTECH,YTIME)
         =E=
         (55*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)/(1e-3*s05DelivH2Turnpike))$sameas("TPIPA",INFRTECH)  !! turnpike pipeline km
         +
         (i05PipeH2Transp(INFRTECH,YTIME)*1e6*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("LPIPU",INFRTECH) or sameas("HPIPI",INFRTECH)) !!Low pressure urban pipelines km and industrial pipelines km
         +
         (s05LenH2StationConn*V05CostInvTechH2Infr(allCy,"SSGG",YTIME))$sameas("MPIPS",INFRTECH)   !! Pipelines connecting hydrogen service stations with the ring km
         +
         (sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2),V05CostInvTechH2Infr(allCy,INFRTECH2,YTIME)*i05KmFactH2Transp(allCy,INFRTECH2)))$(sameas("MPIPU",INFRTECH)  or sameas("HPIPU",INFRTECH)) !! Ring pipeline in km and high pressure pipelines km
         +
         (V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)/s05SalesH2Station*1E3)$sameas("SSGG",INFRTECH)   !! Number of new service stations to be built to meet the demand
;
```
This equation calculates the cost of investment in hydrogen infrastructure technologies. It includes the costs associated with 
deploying new infrastructure, such as the capital expenses required for construction, material procurement, and installation of
technologies related to hydrogen production, storage, and distribution.
```
Q05CostInvTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (i05CostInvH2Transp(allCy,INFRTECH,YTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) !!Service stations investment cost
;
```
This equation represents the cost of the hydrogen infrastructure technologies themselves, possibly including both capital and operational costs.
It may consider costs for specific technologies used in hydrogen systems (e.g., electrolyzers, compressors, storage tanks, etc.) and their maintenance.
```
Q05CostTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         ((imDisc(allCy,"H2INFR",YTIME)*exp(imDisc(allCy,"H2INFR",YTIME)* i05TranspLftH2(INFRTECH,YTIME))/(exp(imDisc(allCy,"H2INFR",YTIME)* i05TranspLftH2(INFRTECH,YTIME))-1))
         *
         V05CostInvCummH2Transp(allCy,INFRTECH,YTIME)*(1+i05CostInvFOMH2(INFRTECH,YTIME)))/i05AvailRateH2Transp(INFRTECH,YTIME) + i05CostInvVOMH2(INFRTECH,YTIME)
         *
         (imDisc(allCy,"H2INFR",YTIME)*exp(imDisc(allCy,"H2INFR",YTIME)* i05TranspLftH2(INFRTECH,YTIME))/(exp(imDisc(allCy,"H2INFR",YTIME)* i05TranspLftH2(INFRTECH,YTIME))-1))*
         V05CostInvCummH2Transp(allCy,INFRTECH,YTIME)
         +
         (
            i05ConsSelfH2Transp(allCy,INFRTECH,YTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)*
            (VmCostAvgProdH2(allCy,YTIME-1)$sameas("HPIPU",INFRTECH)+
            VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*1e3)$sameas("SSGG",INFRTECH)
         )$(sameas("SSGG",INFRTECH) or sameas("HPIPU",INFRTECH))
         /V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)
;
```
This equation calculates the cumulative costs of investments in hydrogen transportation infrastructure over time. 
It tracks the total cost accumulated as new transportation infrastructure (such as pipelines, compressors, and distribution networks) is installed to meet demand.
```
Q05CostInvCummH2Transp(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvCummH2Transp(allCy,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),
                 V05CostTechH2Infr(allCy,INFRTECH,YYTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME))
;
```
This equation defines the tariff or price structure for using the hydrogen infrastructure. It calculates the cost or
fee associated with transporting hydrogen through the infrastructure, possibly taking into account the infrastructure’s
capacity, usage, or maintenance costs. This fee is typically levied per unit of hydrogen transported.
```
Q05TariffH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05TariffH2Infr(allCy,INFRTECH,YTIME)
         =E=
         i05CostAvgWeight(allCy,YTIME)* V05H2Pipe(allCy,INFRTECH,YTIME)
         +
         (1-i05CostAvgWeight(allCy,YTIME))*V05CostTechH2Infr(allCy,INFRTECH,YTIME)
;
```
This equation calculates the price of hydrogen based on infrastructure costs. It determines the price at which hydrogen
can be delivered to end-users, including both the production cost and the infrastructure-related costs (transport, storage, etc.).
```
Q05PriceH2Infr(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05PriceH2Infr(allCy,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , V05TariffH2Infr(allCy,INFRTECH,YTIME))
;
```
This equation calculates the total cost of hydrogen production, transportation, and distribution, integrating all the costs associated
with hydrogen infrastructure and technology. It includes costs for producing hydrogen, investing in infrastructure, maintaining the infrastructure,
and any operational costs related to hydrogen transportation and storage.
```
Q05CostTotH2(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05CostTotH2(allCy,SBS,YTIME)
         =E=
         V05PriceH2Infr(allCy,SBS,YTIME)+VmCostAvgProdH2(allCy,YTIME)
;
$offtext
Q05CaptRateH2(allCy,H2TECH,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V05CaptRateH2(allCy,H2TECH,YTIME)
        =E=
    i05CaptRateH2Prod(H2TECH) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    );
```

```
table i05H2Production(ECONCHARHY,H2TECH,YTIME)	            "Data for Hydrogen production"
$ondelim
$include"./iH2Production.csv"
$offdelim
;
table i05H2Parameters(allCy,ECONCHARHY)	                    "Data for Hydrogen Parameters"
$ondelim
$include"./iH2Parameters.csv"
$offdelim
;
table i05H2InfrCapCosts(ECONCHARHY,INFRTECH,YTIME)	        "Data for Hydrogen Infrastructure Costs"
$ondelim
$include"./iH2InfrCapCosts.csv"
$offdelim
;
table iTechShareH2Prod(H2TECH,YTIME)	                      "Data for Hydrogen Infrastructure Costs"
$ondelim
$include"./iWBLShareH2Prod.csv"
$offdelim
;
Parameters
i05WBLGammaH2Prod(allCy,YTIME)              "Parameter for acceptance in new investments used in weibull function in production shares"
i05ProdLftH2(H2TECH,YTIME)                  "Lifetime of hydrogen production technologies in years"
i05CaptRateH2Prod(H2TECH)                   "CO2 capture rate of hydrogen production technologies (for those which are equipped with CCS facility)"
i05H2Adopt(allCy,ARELAST,YTIME)             "Parameters controlling the speed and the year of taking off the transition to hydrogen economy"
i05TranspLftH2(INFRTECH,YTIME)              "Technical lifetime of infrastructure technologies"
i05CostCapH2Prod(allCy,H2TECH,YTIME)        "Capital cost of hydrogen production technologies in US$2015 per kW output H2"
i05CostFOMH2Prod(allCy,H2TECH,YTIME)        "Fixed operating and maintenance costs of hydrogen production technologies in US$2015 per kW output H2"
i05CostVOMH2Prod(allCy,H2TECH,YTIME)        "Variable operating and maintenance costs of hydrogen production technologies in US$2015 per kW output H2"
i05AvailH2Prod(allCy,H2TECH,YTIME)          "Availability of hydrogen production technologies"
i05EffH2Prod(allCy,H2TECH,YTIME)            "Efficiency of hydrogen production technologies"
i05CostInvH2Transp(allCy,INFRTECH,YTIME)    "Investment cost of infrastructure technology"
                                                   !! - Turnpike pipeline in Euro per km
                                                   !! - Low pressure urban pipeline in Euro per km
                                                   !! - Medium pressure ring in Euro per km
                                                   !! - Service stations connection lines in Euro per km
                                                   !! - Gaseous hydrogen service stations in Euro per toe per year
i05EffH2Transp(allCy,INFRTECH,YTIME)        "Efficiency of hydrogen transportation per infrastructure technology"
i05ConsSelfH2Transp(allCy,INFRTECH,YTIME)   "Self consumption of infrastructure technology rate"
i05AvailRateH2Transp(INFRTECH,YTIME)        "Availability rate of infrastructure technology"
i05CostInvVOMH2(INFRTECH,YTIME)             "Annual variable O&M cost as percentage of total investment cost"
i05CostInvFOMH2(INFRTECH,YTIME)             "Annual fixed O&M cost as percentage of total investment cost"
i05PipeH2Transp(INFRTECH,YTIME)             "Kilometers of pipelines required per toe of delivered hydrogen (based on stylized model)"
i05KmFactH2Transp(allCy,INFRTECH)           "Km needed for a given infrastructure assuming that its required infrastructure has been arleady installed"
i05PolH2AreaMax(allCy)                      "Policy parameter defining the percentage of the country area supplied by hydrogen at the end of the horizon period [0...1]"
i05HabAreaCountry(allCy)                    "Inhabitable land in a country"
i05EffNetH2Transp(allCy,INFRTECH,YTIME)     "Total efficiency of the distribution network until the <infrtech> node"
i05CostAvgWeight(allCy,YTIME)               "Weight for pricing in average cost or in marginal cost"
iWBLShareH2Prod(allCy,H2TECH,YTIME)         "Maturity factors for H2 technologies"
iWBLPremRepH2Prod(allCy,H2TECH,YTIME)       "Maturity factors for premature replacement of H2 technologies"
;
iWBLShareH2Prod(runCy,H2TECH,YTIME) = iTechShareH2Prod(H2TECH,YTIME);
i05WBLGammaH2Prod(runCy,YTIME) = 1;
i05ProdLftH2(H2TECH,YTIME) = i05H2Production("LFT",H2TECH,YTIME);
i05ProdLftH2("wes",YTIME)  = i05H2Production("LFT","weg",YTIME);
i05ProdLftH2("wew",YTIME)  = i05H2Production("LFT","weg",YTIME);
i05CaptRateH2Prod(H2TECH) = i05H2Production("CR",H2TECH,"%fBaseY%");
i05CaptRateH2Prod("wes")  = i05CaptRateH2Prod("weg");
i05CaptRateH2Prod("wew")  = i05CaptRateH2Prod("weg");
i05CaptRateH2Prod(H2TECH)$(not H2CCS(H2TECH)) = 0;
i05H2Adopt(runCy,"b",YTIME)   = i05H2Parameters(runCy,"B");
i05H2Adopt(runCy,"mid",YTIME) = i05H2Parameters(runCy,"mid");
i05TranspLftH2(INFRTECH,YTIME) = i05H2InfrCapCosts("LFT",INFRTECH,YTIME);
i05CostCapH2Prod(runCy,H2TECH,YTIME) = i05H2Production("IC",H2TECH,YTIME);
i05CostCapH2Prod(runCy,"wes",YTIME)  = i05H2Production("IC","weg",YTIME);
i05CostCapH2Prod(runCy,"wew",YTIME)  = i05H2Production("IC","weg",YTIME);
i05CostFOMH2Prod(runCy,H2TECH,YTIME) = i05H2Production("FC",H2TECH,YTIME);
i05CostFOMH2Prod(runCy,"wes",YTIME)  = i05H2Production("FC","weg",YTIME);
i05CostFOMH2Prod(runCy,"wew",YTIME)  = i05H2Production("FC","weg",YTIME);
i05CostVOMH2Prod(runCy,H2TECH,YTIME) = i05H2Production("VC",H2TECH,YTIME);
i05CostVOMH2Prod(runCy,"wes",YTIME)  = i05H2Production("VC","weg",YTIME);
i05CostVOMH2Prod(runCy,"wew",YTIME)  = i05H2Production("VC","weg",YTIME);
i05AvailH2Prod(runCy,H2TECH,YTIME) = i05H2Production("AVAIL",H2TECH,YTIME);
i05AvailH2Prod(runCy,"wes",YTIME)  = min(i05AvailH2Prod(runCy,"weg",YTIME),i04AvailRate(runCy,"PGSOL",YTIME));
i05AvailH2Prod(runCy,"wew",YTIME)  = min(i05AvailH2Prod(runCy,"weg",YTIME),i04AvailRate(runCy,"PGAWNO",YTIME));
i05EffH2Prod(runCy,H2TECH,YTIME) = i05H2Production("EFF",H2TECH,YTIME);
i05EffH2Prod(runCy,"wes",YTIME)  = i05H2Production("EFF","weg",YTIME);
i05EffH2Prod(runCy,"wew",YTIME)  = i05H2Production("EFF","weg",YTIME);
i05CostInvH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("IC",INFRTECH,YTIME);
i05EffH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("EFF",INFRTECH,YTIME);
i05ConsSelfH2Transp(runCy,INFRTECH,YTIME) = i05H2InfrCapCosts("SELF",INFRTECH,YTIME);
i05AvailRateH2Transp(INFRTECH,YTIME) = i05H2InfrCapCosts("AVAIL",INFRTECH,YTIME);
i05CostInvFOMH2(INFRTECH,YTIME) = i05H2InfrCapCosts("FC",INFRTECH,YTIME);
i05CostInvVOMH2(INFRTECH,YTIME) = i05H2InfrCapCosts("VC",INFRTECH,YTIME);
i05PipeH2Transp(INFRTECH,YTIME) =  i05H2InfrCapCosts("H2KMTOE",INFRTECH,YTIME);
i05KmFactH2Transp(runCy,INFRTECH) = sum(ECONCHARHY$INFRTECHLAB(INFRTECH,ECONCHARHY), i05H2Parameters(runCy,ECONCHARHY));
i05PolH2AreaMax(runCy) = i05H2Parameters(runCy,"MAXAREA");
i05HabAreaCountry(runCy) = i05H2Parameters(runCy,"AREA");
i05EffNetH2Transp(runCy,INFRTECH,YTIME) = i05EffH2Transp(runCy,INFRTECH,YTIME)*(1-i05ConsSelfH2Transp(runCy,INFRTECH,YTIME));
iWBLPremRepH2Prod(runCy,H2TECH,YTIME) = 0.1 ;
loop H2EFFLOOP do
  loop INFRTECH2$H2NETWORK(INFRTECH2,H2EFFLOOP) do
         i05EffNetH2Transp(runCy,H2EFFLOOP,YTIME) =  i05EffNetH2Transp(runCy,INFRTECH2,YTIME)*i05EffH2Transp(runCy,H2EFFLOOP,YTIME);
  endloop;
endloop;
i05CostAvgWeight(runCy,YTIME) = 1;
loop YTIME$(An(YTIME)) do
         i05CostAvgWeight(runCy,YTIME) = -1/19+i05CostAvgWeight(runCy,YTIME-1);
endloop;
```

*VARIABLE INITIALISATION*
```
V05GapShareH2Tech1.UP(runCy,H2TECH,YTIME) = 1;
V05GapShareH2Tech1.LO(runCy,H2TECH,YTIME) = 0;
V05DemGapH2.L(runCy,YTIME) = 2;
V05DemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 0;
display V05DemGapH2.L;
VmProdH2.L(runCy,H2TECH, YTIME) = 0.5;
VmProdH2.LO(runCy,H2TECH, YTIME) = 0;
VmProdH2.FX(runCy,H2TECH, YTIME)$(not An(YTIME)) = 0;
display VmProdH2.L;
VmDemTotH2.L(runCy,YTIME) = 2;
VmDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = sum(H2TECH, VmProdH2.L(runCy,H2TECH,YTIME));
display VmDemTotH2.L;
VmConsFuelTechH2Prod.FX(runCy,H2TECH,EF,"%fBaseY%")$(H2TECHEFtoEF(H2TECH,EF)) = (VmProdH2.L(runCy,H2TECH,"%fBaseY%")/i05EffH2Prod(runCy,H2TECH,"%fBaseY%"));
display i05EffH2Prod;
display VmConsFuelTechH2Prod.L;
V05GapShareH2Tech2.LO(runCy,H2TECH,YTIME) = 0;
V05GapShareH2Tech2.UP(runCy,H2TECH,YTIME) = 1;
V05CapScrapH2ProdTech.LO(runCy,H2TECH,YTIME) = 0;
V05CapScrapH2ProdTech.UP(runCy,H2TECH,YTIME) = 1;
V05ScrapLftH2Prod.UP(runCy,H2TECH,YTIME) = 1;
V05ScrapLftH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ScrapLftH2Prod.FX(runCy,H2TECH,YTIME)$DATAY(YTIME) = 1/i05ProdLftH2(H2TECH,YTIME);
V05CostProdH2Tech.LO(runCy,H2TECH,YTIME) = epsilon6;
V05CostProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05CostProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
V05CostVarProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05ShareCCSH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ShareCCSH2Prod.UP(runCy,H2TECH,YTIME) = 1;
V05ShareNoCCSH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ShareNoCCSH2Prod.UP(runCy,H2TECH,YTIME) = 1;
VmConsFuelH2Prod.FX(runCy,EF,YTIME)$(not An(YTIME)) = sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME));
V05CostProdCCSNoCCSH2Prod.LO(runCy,H2TECH,YTIME) = epsilon6;
V05CostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
VmCostAvgProdH2.L(runCy,YTIME) = 2;
VmCostAvgProdH2.FX(runCy,YTIME)$(not An(YTIME)) = 0;
V05DemGapH2.LO(runCy,YTIME) = 0;
V05PremRepH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05PremRepH2Prod.UP(runCy,H2TECH,YTIME) = 1;
V05PremRepH2Prod.FX(runCy,H2TECH,YTIME)$(not H2TECHPM(H2TECH)) = 1;
```

```
VmConsFuelTechH2Prod.FX(runCyL,H2TECH,EF,YTIME)$TIME(YTIME) = VmConsFuelTechH2Prod.L(runCyL,H2TECH,EF,YTIME)$TIME(YTIME);
V05GapShareH2Tech1.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05GapShareH2Tech1.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
VmProdH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = VmProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05DemGapH2.FX(runCyL,YTIME)$TIME(YTIME) = V05DemGapH2.L(runCyL,YTIME)$TIME(YTIME);
VmCostAvgProdH2.FX(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME);
VmCstCO2SeqCsts.FX(runCyL,YTIME)$TIME(YTIME) = VmCstCO2SeqCsts.L(runCyL,YTIME)$TIME(YTIME);
V05CaptRateH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CaptRateH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
```


> **Limitations**
> There are no known limitations.

Definitions
-----------

### Objects


-----------------------------------------------------------------------------
          &nbsp;                      Description                Unit      A 
--------------------------- -------------------------------- ------------ ---
      i05AvailH2Prod            Availability of hydrogen                   x 
            \                   production technologies                      
      (allCy, H2TECH,                                                        
          YTIME)                                                             

   i05AvailRateH2Transp           Availability rate of                     x 
             \                 infrastructure technology                     
        (INFRTECH,                                                           
          YTIME)                                                             

     i05CaptRateH2Prod        CO2 capture rate of hydrogen       $for      x 
             \                  production technologies         those        
         (H2TECH)                                               which        
                                                                 are         
                                                               equipped      
                                                                 with        
                                                                 CCS         
                                                              facility$      

    i05ConsSelfH2Transp           Self consumption of                      x 
             \               infrastructure technology rate                  
          (allCy,                                                            
         INFRTECH,                                                           
          YTIME)                                                             

     i05CostAvgWeight        Weight for pricing in average                 x 
             \                  cost or in marginal cost                     
      (allCy, YTIME)                                                         

     i05CostCapH2Prod           Capital cost of hydrogen                   x 
             \                 production technologies in                    
      (allCy, H2TECH,           US$2015 per kW output H2                     
          YTIME)                                                             

     i05CostFOMH2Prod             Fixed operating and                      x 
             \               maintenance costs of hydrogen                   
      (allCy, H2TECH,          production technologies in                    
          YTIME)                US$2015 per kW output H2                     

      i05CostInvFOMH2           Annual fixed O&M cost as                   x 
            \                percentage of total investment                  
        (INFRTECH,                        cost                               
          YTIME)                                                             

    i05CostInvH2Transp             Investment cost of                      x 
             \                 infrastructure technology                     
          (allCy,                                                            
         INFRTECH,                                                           
          YTIME)                                                             

      i05CostInvVOMH2         Annual variable O&M cost as                  x 
            \                percentage of total investment                  
        (INFRTECH,                        cost                               
          YTIME)                                                             

     i05CostVOMH2Prod            Variable operating and                    x 
             \               maintenance costs of hydrogen                   
      (allCy, H2TECH,          production technologies in                    
          YTIME)                US$2015 per kW output H2                     

      i05EffH2Prod \             Efficiency of hydrogen                    x 
      (allCy, H2TECH,           production technologies                      
          YTIME)                                                             

      i05EffH2Transp             Efficiency of hydrogen                    x 
            \                      transportation per                        
          (allCy,              infrastructure technology                     
         INFRTECH,                                                           
          YTIME)                                                             

     i05EffNetH2Transp          Total efficiency of the                    x 
             \               distribution network until the                  
          (allCy,                   <infrtech> node                          
         INFRTECH,                                                           
          YTIME)                                                             

       i05H2Adopt \            Parameters controlling the                  x 
          (allCy,             speed and the year of taking                   
      ARELAST, YTIME)        off the transition to hydrogen                  
                                        economy                              

     i05H2InfrCapCosts             Data for Hydrogen                       x 
             \                    Infrastructure Costs                       
       (ECONCHARHY,                                                          
         INFRTECH,                                                           
          YTIME)                                                             

      i05H2Parameters         Data for Hydrogen Parameters                 x 
            \                                                                
          (allCy,                                                            
        ECONCHARHY)                                                          

      i05H2Production         Data for Hydrogen production                 x 
            \                                                                
       (ECONCHARHY,                                                          
      H2TECH, YTIME)                                                         

     i05HabAreaCountry       Inhabitable land in a country                 x 
             \                                                               
          (allCy)                                                            

     i05KmFactH2Transp           Km needed for a given                     x 
             \                infrastructure assuming that                   
          (allCy,             its required infrastructure                    
         INFRTECH)             has been arleady installed                    

      i05PipeH2Transp           Kilometers of pipelines         $based     x 
            \                required per toe of delivered        on         
        (INFRTECH,                      hydrogen               stylized      
          YTIME)                                                model$       

      i05PolH2AreaMax        Policy parameter defining the                 x 
            \                percentage of the country area                  
          (allCy)             supplied by hydrogen at the                    
                               end of the horizon period                     
                                        [0...1]                              

      i05ProdLftH2 \              Lifetime of hydrogen                     x 
      (H2TECH, YTIME)          production technologies in                    
                                         years                               

      i05TranspLftH2             Technical lifetime of                     x 
            \                 infrastructure technologies                    
        (INFRTECH,                                                           
          YTIME)                                                             

     i05WBLGammaH2Prod        Parameter for acceptance in                  x 
             \                  new investments used in                      
      (allCy, YTIME)         weibull function in production                  
                                         shares                              

     iTechShareH2Prod              Data for Hydrogen                       x 
             \                    Infrastructure Costs                       
      (H2TECH, YTIME)                                                        

     iWBLPremRepH2Prod       Maturity factors for premature                x 
             \               replacement of H2 technologies                  
      (allCy, H2TECH,                                                        
          YTIME)                                                             

      iWBLShareH2Prod           Maturity factors for H2                    x 
            \                         technologies                           
      (allCy, H2TECH,                                                        
          YTIME)                                                             

    Q05AcceptCCSH2Tech       Equation for acceptance in CCS                x 
             \                        technologies                           
      (allCy, YTIME)                                                         

   Q05CapScrapH2ProdTech      Equation for decommissioning                 x 
             \                of capacity by H2 production                   
      (allCy, H2TECH,                  technology                            
          YTIME)                                                             

      Q05CaptRateH2 \                                                      x 
      (allCy, H2TECH,                                                        
          YTIME)                                                             

     Q05ConsFuelH2Prod          Equation for total fuel                    x 
             \                  consumption for hydrogen                     
        (allCy, EF,                    production                            
          YTIME)                                                             

   Q05ConsFuelTechH2Prod     Equation for fuel consumption                 x 
             \                 by technology for hydrogen                    
      (allCy, H2TECH,                  production                            
        EF, YTIME)                                                           

     Q05CostAvgProdH2             Equation for average                     x 
             \               production cost of hydrogen in                  
      (allCy, YTIME)                  Euro per toe                           

 Q05CostProdCCSNoCCSH2Prod    Equation for calculating the                 x 
             \                   production cost of the                      
      (allCy, H2TECH,        composite technology with and                   
          YTIME)                      without CCS                            

     Q05CostProdH2Tech           Equation for hydrogen                     x 
             \               production cost per technology                  
      (allCy, H2TECH,                                                        
          YTIME)                                                             

   Q05CostVarProdH2Tech        Equation for variable cost                  x 
             \                 (including fuel cost) for                     
      (allCy, H2TECH,            hydrogen production by                      
          YTIME)               technology in Euro per toe                    

      Q05DemGapH2 \           Equation for gap in hydrogen                 x 
      (allCy, YTIME)                     demand                              

      Q05DemSecH2 \           Equation for demand of H2 by                 x 
       (allCy, SBS,                  sector in mtoe                          
          YTIME)                                                             

      Q05DemTotH2 \           Equation for total hydrogen                  x 
      (allCy, YTIME)          demand in a country in Mtoe                    

    Q05GapShareH2Tech1        Equation for calculating the                 x 
             \                 shares of technologies in                     
      (allCy, H2TECH,          hydrogen gap using Weibull                    
          YTIME)                      equations 1                            

    Q05GapShareH2Tech2        Equation for calculating the                 x 
             \                 shares of technologies in                     
      (allCy, H2TECH,          hydrogen gap using Weibull                    
          YTIME)                      equations 2                            

     Q05PremRepH2Prod            Equation for premature                    x 
             \                replacement of H2 production                   
      (allCy, H2TECH,                 technologies                           
          YTIME)                                                             

       Q05ProdH2 \           Equation for H2 production by                 x 
      (allCy, H2TECH,                  technology                            
          YTIME)                                                             

     Q05ScrapLftH2Prod         Equation for scrapping of       $normal     x 
             \                 equipment due to lifetime      scrapping$     
      (allCy, H2TECH,                                                        
          YTIME)                                                             

     Q05ShareCCSH2Prod         Equation for share of CCS                   x 
             \                 technology in the decision                    
      (allCy, H2TECH,         tree between CCS and no CCS                    
          YTIME)                                                             

    Q05ShareNoCCSH2Prod          Equation for share of                     x 
             \               technology without CCS in the                   
      (allCy, H2TECH,        decision tree between CCS and                   
          YTIME)                         no CCS                              

       s05AreaStyle               stylised area in km2                     x 

    s05DelivH2Turnpike          stylised annual hydrogen                   x 
                             delivery in turnpike pipeline                   
                                        in ktoe                              

    s05LenH2StationConn        length of pipes connection                  x 
                             service stations with the ring                  
                                   in km per station                         

     s05SalesH2Station         annual sales of a hydrogen                  x 
                                service station in ktoe                      

    V05AcceptCCSH2Tech        Acceptance of investment in                  x 
             \                      CCS technologies                         
      (allCy, YTIME)                                                         

   V05CapScrapH2ProdTech     Decommissioning of capacity by                x 
             \                  H2 production technology                     
      (allCy, H2TECH,                                                        
          YTIME)                                                             

      V05CaptRateH2 \                                                      x 
      (allCy, H2TECH,                                                        
          YTIME)                                                             

 V05CostProdCCSNoCCSH2Prod       Production cost of the                    x 
             \               composite technology with and                   
      (allCy, H2TECH,         without CCS in Euro per toe                    
          YTIME)                                                             

     V05CostProdH2Tech        Hydrogen production cost per                 x 
             \               technology in US$2015 per toe                   
      (allCy, H2TECH,                 of hydrogen                            
          YTIME)                                                             

   V05CostVarProdH2Tech      Variable cost (including fuel                 x 
             \               cost) for hydrogen production                   
      (allCy, H2TECH,         by technology in US$2015 per                   
          YTIME)                          toe                                

      V05DemGapH2 \          Demand for H2 to be covered by                x 
      (allCy, YTIME)             new equipment in mtoe                       

    V05GapShareH2Tech1          Shares of H2 production                    x 
             \                 technologies in new market                    
      (allCy, H2TECH,                competition 1                           
          YTIME)                                                             

    V05GapShareH2Tech2          Shares of H2 production                    x 
             \                 technologies in new market                    
      (allCy, H2TECH,                competition 2                           
          YTIME)                                                             

     V05PremRepH2Prod         Premature replacement of H2                  x 
             \                  production technologies                      
      (allCy, H2TECH,                                                        
          YTIME)                                                             

     V05ScrapLftH2Prod       Scrapping of equipment due to     $normal     x 
             \                          lifetime              scrapping$     
      (allCy, H2TECH,                                                        
          YTIME)                                                             

     V05ShareCCSH2Prod       Share of CCS technology in the                x 
             \               decision tree between CCS and                   
      (allCy, H2TECH,                    no CCS                              
          YTIME)                                                             

    V05ShareNoCCSH2Prod       Share of technology without                  x 
             \                  CCS in the decision tree                     
      (allCy, H2TECH,            between CCS and no CCS                      
          YTIME)                                                             
-----------------------------------------------------------------------------

Table: module-internal objects (A: legacy)



### Sets


---------------------------------------------------------
         &nbsp;                    description           
------------------------ --------------------------------
         ALIAS                   (H2TECH2H2TECH)         

         allCy              All Countries Used in the    
                                      Model              

        ARELAST            Set containing the names of   
                          the elasticities used in area  
                              covered by H2 logistic     
                                     fucntion            

     biomass(balef)                                      

       CCS(PGALL)          Plants which can be equipped  
                                     with CCS            

       DSBS(SBS)              All Demand Subsectors      

       ECONCHARHY              Technical - Economic      
                            characteristics for demand   
                              technologies Hydrogen      

           EF                      Energy Forms          

        EFS(EF)            Energy Forms used in Supply   
                                       Side              

  H2CCS_NOCCS(H2TECH,        Mapping between hydrogen    
        H2TECH)           technologies with and without  
                                   CCS facility          

     H2CCS(H2TECH)             Hydrogen production       
                          technologies equipped with CCS 
                                     facility            

  H2EFFLOOP(INFRTECH)                                    

 H2INFRDNODES(INFRTECH)                                  

  H2INFRSBS(INFRTECH,       Infrustructure required by   
          SBS)                    demand sector          

  H2NETWORK(INFRTECH,                                    
       INFRTECH)                                         

    H2NOCCS(H2TECH)            Hydrogen production       
                           technologies without CCS but  
                          with corresponding option with 
                                       CCS               

      H2PRODEF(EF)           Fuels used for hydrogen     
                                    production           

  H2STATIONS(INFRTECH)    Service stations for hydrogen  
                                   powered cars          

         H2TECH                Hydrogen production       
                                   technologies          

  H2TECHEFtoEF(H2TECH,      Mapping between production   
          EF)                 technologies and fuels     

    H2TECHPM(H2TECH)          Technologies for which     
                             premature replacement is    
                                      active             

   H2TECHREN(H2TECH)      Renewable hydrogen production  
                                   technologies          

          HOU                   11.511 0.9 0.00001       

      INDDOM(DSBS)            Industry and Tertiary      

        INFRTECH               Hydrogen storage and      
                            distribution technologies    

 INFRTECHLAB(INFRTECH,                                   
      ECONCHARHY)                                        

 INFRTECHtoEF(INFRTECH,   Type of energy consumed onsite 
          EF)                for the operation of the    
                            infrastructure technology    

   NAP(Policies_set)         National Allocation Plan    
                                sector categories        

    NAPtoALLSBS(NAP,       Energy sectors corresponding  
        ALLSBS)                   to NAP sectors         

     period(ytime)        Model can also run for periods 
                                     of years            

         PGALL             Power Generation Plant Types  

    PIPES(INFRTECH)                 Pipelines            

      runCy(allCy)        Countries for which the model  
                                    is running           

     runCyL(allCy)        Countries for which the model  
                          is running (used in countries  
                                      loop)              

      SBS(ALLSBS)                Model Subsectors        

      SECtoEF(SBS,        Link between Model Subsectors  
          EF)                    and Energy FORMS        

      TRANSE(DSBS)           All Transport Subsectors    
---------------------------------------------------------

Table: sets in use



See Also
--------

[01_Transport], [02_Industry], [03_RestOfEnergy], [04_PowerGeneration], [06_CO2], [08_Prices], [core]

