*' @title Equations of OPEN-PROMs Hydrogen
*' @code

*' This equation calculates the total hydrogen demand by aggregating the sectoral hydrogen demands from various subsectors.
*' It considers the efficiency and self-consumption of hydrogen transportation infrastructure to determine the overall demand
*' for hydrogen in the system.
Q05DemTotH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotH2(allCy,YTIME)
                 =E=
    sum(SBS$SECtoEF(SBS,"H2F"), 
      VmDemSecH2(allCy,SBS, YTIME) /
      prod(INFRTECH$H2INFRSBS(INFRTECH,SBS),
        i05EffH2Transp(allCy,INFRTECH,YTIME)*
        (1-i05ConsSelfH2Transp(allCy,INFRTECH,YTIME))
      )
    )
;

*' This equation calculates the sectoral hydrogen demand for each subsector. It aggregates the hydrogen consumption from various sources,
*' including fuel consumption, transportation energy demand, direct air capture production, and power generation.
*' It helps in understanding the distribution of hydrogen demand across different sectors.
Q05DemSecH2(allCy,SBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemSecH2(allCy,SBS,YTIME)
        =E=
    sum(INDDOM$SAMEAS(INDDOM,SBS), VmConsFuel(allCy,INDDOM,"H2F",YTIME)) +
    sum(TRANSE$SAMEAS(TRANSE,SBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"H2F",YTIME)) +
    VmConsFuelDACProd(allCy,"H2F",YTIME)$sameas("DAC",SBS) +
    VmConsFuelElecProd(allCy,"H2F",YTIME)$sameas("PG",SBS);

*' This equation calculates the scrapping of hydrogen production capacity due to the end of the plant's useful life.
*' It determines the fraction of hydrogen production capacity that is retired each year based on the technology's lifespan.
*' It helps in understanding the dynamics of hydrogen production capacity over time.
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

*' This equation calculates the premature replacement rate of hydrogen production capacity for each technology.
*' It considers economic factors such as variable production costs and availability to determine the likelihood of replacing existing capacity before the end of its useful life.
*' It helps in understanding the dynamics of hydrogen production capacity over time.
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

*' This equation calculates the total scrapped hydrogen production capacity for each technology. 
*' It includes both scrapping due to the end of the plant's useful life and premature replacement based on economic factors.
*' It helps in understanding the dynamics of hydrogen production capacity over time.
Q05CapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)
      =E=
    1 - (1-V05ScrapLftH2Prod(allCy,H2TECH,YTIME)) *
    V05PremRepH2Prod(allCy,H2TECH,YTIME);

*' This equation calculates the hydrogen demand gap, which is the difference between total hydrogen demand
*' and the available hydrogen production after accounting for scrapped capacity. It helps identify the shortfall in hydrogen supply that needs to be addressed.
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

*' This equation calculates the total production cost of hydrogen for each technology. It includes both fixed and variable costs associated with hydrogen production.
*' The production cost is essential for determining the economic viability of different hydrogen production methods.
*' It also accounts for renewable hydrogen production methods like wind electrolysis.
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

*' This equation calculates the variable production cost of hydrogen for each technology. It includes costs related to fuel consumption,
*' carbon emissions, and other operational expenses. The variable cost is essential for determining the economic viability of different hydrogen production methods.
*' It also accounts for renewable hydrogen production methods like wind electrolysis.
Q05CostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME)
        =E=
    sum(EF$H2TECHEFtoEF(H2TECH,EF),
      (
        VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME) * 1e3 +
        V05CaptRateH2(allCy,H2TECH,YTIME) * (imCo2EmiFac(allCy,"H2P",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * VmCstCO2SeqCsts(allCy,YTIME) +
        (1-V05CaptRateH2(allCy,H2TECH,YTIME)) * (imCo2EmiFac(allCy,"H2P",EF,YTIME)) *
        sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME))
      ) 
    )$(not H2TECHREN(H2TECH)) / i05EffH2Prod(allCy,H2TECH,YTIME) +
    (i04VarCost("PGSOL",YTIME) / (smTWhToMtoe))$(sameas(H2TECH,"wes")) +
    (i04VarCost("PGAWNO",YTIME) / (smTWhToMtoe))$(sameas(H2TECH,"wew"))
    
;

*' This equation models the acceptance level of carbon capture and storage (CCS) technologies in hydrogen production.
*' It considers factors such as the production cost of hydrogen with CCS and the overall carbon pricing environment.
*' The acceptance level influences the adoption rate of CCS technologies in the hydrogen production mix.
Q05AcceptCCSH2Tech(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05AcceptCCSH2Tech(allCy,YTIME)
    =E=
    i05WBLGammaH2Prod(allCy,YTIME)*2 +
    EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME -1)))))
;

*' This equation calculates the share of hydrogen production from technologies that utilize CCS.
*' It determines the proportion of hydrogen produced using CCS technologies based on their costs and acceptance levels.
*' It helps in understanding the market penetration of CCS in hydrogen production.
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

*' This equation calculates the share of hydrogen production from technologies that do not utilize CCS.
*' It complements the share of CCS technologies, ensuring that the total production share sums to one
*' across all hydrogen production methods.
Q05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy)))..
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , V05ShareCCSH2Prod(allCy,H2TECH2,YTIME) )
;

*' This equation calculates the cost of hydrogen production for technologies that do not utilize CCS.
*' It combines the costs from both CCS and non-CCS technologies based on their respective shares in the overall hydrogen production mix.
*' It helps in understanding the economic implications of choosing non-CCS methods for hydrogen production.
Q05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy))) ..
         V05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)*V05CostProdH2Tech(allCy,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), V05ShareCCSH2Prod(allCy,H2CCS,YTIME)*V05CostProdH2Tech(allCy,H2CCS,YTIME))
;

*' This equation allocates the hydrogen production gap among different technologies based on their shares.
*' It ensures that the production shortfall is distributed according to the capabilities and preferences for each technology.
*' It considers both CCS and non-CCS technologies in the allocation.
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

*' This equation allocates the hydrogen production gap among different technologies based on their market shares.
*' It ensures that the production gap is filled by technologies according to their competitiveness and availability.
*' It helps in balancing supply and demand in the hydrogen market.
Q05GapShareH2Tech1(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05GapShareH2Tech1(allCy,H2TECH,YTIME)
        =E=
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH))) +
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)*(V05ShareCCSH2Prod(allCy,H2TECH,YTIME)$H2CCS(H2TECH) +  V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))   
;

*' This equation defines the actual hydrogen production levels, considering both scrapped capacity and the demand gap.
*' It allocates production from different technologies to meet the overall demand, adjusting for changes in capacity and technology availability.
Q05ProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdH2(allCy,H2TECH,YTIME)
        =E=
    (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) * VmProdH2(allCy,H2TECH,YTIME-1) +
    V05GapShareH2Tech1(allCy,H2TECH,YTIME) * V05DemGapH2(allCy,YTIME);

*' This equation calculates the average cost of hydrogen production across all technologies in the system.
*' It accounts for varying costs of different technologies (e.g., electrolysis vs. SMR) to provide an overall assessment of hydrogen production cost.
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

*' This equation calculates the fuel consumption for each hydrogen production technology, considering 
*' the efficiency of the technology and the amount of fuel required for producing a unit of hydrogen. 
*' It provides insight into fuel demand for hydrogen production.
Q05ConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)$(TIME(YTIME) $H2TECHEFtoEF(H2TECH,EF) $(runCy(allCy)))..
         VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)
         =E=
*        VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME-1)+
         VmProdH2(allCy,H2TECH,YTIME)/i05EffH2Prod(allCy,H2TECH,YTIME)!!-
*        (VmProdH2(allCy,H2TECH,YTIME-1)/i05EffH2Prod(allCy,H2TECH,YTIME-1))
;

*' This equation aggregates the total fuel consumption across all hydrogen production technologies in the system,
*' summing up the fuel requirements from all sources. It helps track the total fuel demand for hydrogen production.
Q05ConsFuelH2Prod(allCy,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF) $(runCy(allCy)))..
    VmConsFuelH2Prod(allCy,EF,YTIME)
        =E=
    sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME))
;

*' This equation models the carbon capture rate for hydrogen production technologies that utilize CCS.
*' It calculates the proportion of CO₂ emissions captured during hydrogen production, influenced by economic and
*' technological factors.
Q05CaptRateH2(allCy,H2TECH,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    V05CaptRateH2(allCy,H2TECH,YTIME)
        =E=
    i05CaptRateH2Prod(H2TECH) /
    (1 + 
      EXP(20 * (
        ([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME)) + 1)] + 2 -
        [SQRT(SQR([VmCstCO2SeqCsts(allCy,YTIME) /
        (sum(NAP$NAPtoALLSBS(NAP,"H2P"),imCarVal(allCy,NAP,YTIME)) + 1)] - 2))])/2
        -1)
      )
    )
    ;

$ontext