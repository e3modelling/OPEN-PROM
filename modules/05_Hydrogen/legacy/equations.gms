*' @title Equations of OPEN-PROMs Hydrogen
*' @code

*' This equation calculates the total hydrogen demand in the system. It takes into account the overall need for hydrogen
*' across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
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

*' This equation calculates the sectoral hydrogen demand (VmDemSecH2) for each demand subsector (DSBS), year, and region.
*' It sums up hydrogen consumption from both industrial/tertiary sectors (using VmConsFuel) and transport sectors (using VmDemFinEneTranspPerFuel),
*' ensuring each subsector receives only the relevant demand.
Q05DemSecH2(allCy,SBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemSecH2(allCy,SBS,YTIME)
        =E=
    sum(INDDOM$SAMEAS(INDDOM,SBS), VmConsFuel(allCy,INDDOM,"H2F",YTIME)) +
    sum(TRANSE$SAMEAS(TRANSE,SBS), VmDemFinEneTranspPerFuel(allCy,TRANSE,"H2F",YTIME));

*' This equation defines the amount of hydrogen production capacity that is scrapped due to the expiration of the useful life of plants.
*' It considers the remaining lifetime of hydrogen production facilities and the impact of past production gaps.
Q05ScrapLftH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05ScrapLftH2Prod(allCy,H2TECH,YTIME)
      =E=
    (
    V05GapShareH2Tech1(allCy,H2TECH,YTIME-i05ProdLftH2(H2TECH,YTIME)) *
    V05DemGapH2(allCy,YTIME-i05ProdLftH2(H2TECH,YTIME)) /
    (VmProdH2(allCy,H2TECH,YTIME-1) + 1e-6)
    )$(ord(YTIME)>11+i05ProdLftH2(H2TECH,YTIME)) !!+ 0.1
;

*' This equation models the premature replacement of hydrogen production capacity. It adjusts for the need to replace aging
*' or inefficient hydrogen production technologies before their expected end of life based on economic factors such as cost,
*' technological progress, and demand shifts.
Q05PremRepH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05PremRepH2Prod(allCy,H2TECH,YTIME)
         =E=
         1-
         (
          V05CostVarProdH2Tech(allCy,H2TECH,YTIME)**(-i05WBLGammaH2Prod(allCy,YTIME))
         /
         (
*           iWBLPremRepH2Prod(allCy,H2TECH,YTIME)*
           (sum(H2TECH2,
                         V05GapShareH2Tech1(allCy,H2TECH2,YTIME)*(1/i05AvailH2Prod(H2TECH,YTIME)*V05CostProdH2Tech(allCy,H2TECH2,YTIME)
                                                         +(1-1/i05AvailH2Prod(H2TECH,YTIME))*V05CostVarProdH2Tech(allCy,H2TECH2,YTIME)))

                        -V05GapShareH2Tech1(allCy,H2TECH,YTIME)*(1/i05AvailH2Prod(H2TECH,YTIME)*V05CostProdH2Tech(allCy,H2TECH,YTIME)
                                                        +(1-1/i05AvailH2Prod(H2TECH,YTIME))*V05CostVarProdH2Tech(allCy,H2TECH,YTIME))
           )**(-i05WBLGammaH2Prod(allCy,YTIME))

           + V05CostVarProdH2Tech(allCy,H2TECH,YTIME)**(-i05WBLGammaH2Prod(allCy,YTIME))
         + 1e-6)
         )$H2TECHPM(H2TECH)
;

*' This equation calculates the total hydrogen production capacity that is scrapped as part of the premature replacement
*' and normal plant life cycle. It links the scrapped capacity to the overall age distribution and retirement schedule of
*' hydrogen production technologies.
Q05CapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)
         =E=
* FIXME: Add premature replacement to the equation Q05CapScrapH2ProdTech.
* author=redmonkeycloud
         1-(1-V05ScrapLftH2Prod(allCy,H2TECH,YTIME))!!*(1-V05PremRepH2Prod(allCy,H2TECH,YTIME))
;

*' The hydrogen demand gap equation defines the difference between the total hydrogen demand (calculated in Q05DemTotH2) and
*' the actual hydrogen production capacity. It ensures that the gap value is non-negative, preventing overproduction or underproduction of hydrogen.
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

*' This equation calculates the production costs of hydrogen, including both fixed costs (e.g., capital investment) 
*' and variable costs (e.g., operational expenses). The costs are typically differentiated by hydrogen production 
*' technologies such as electrolysis, steam methane reforming (SMR), or coal gasification.
Q05CostProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         ((imDisc(allCy,"H2P",YTIME)*exp(imDisc(allCy,"H2P",YTIME)* i05ProdLftH2(H2TECH,YTIME))/(exp(imDisc(allCy,"H2P",YTIME)*i05ProdLftH2(H2TECH,YTIME))-1)*
         i05CostCapH2Prod(allCy,H2TECH,YTIME)+i05CostFOMH2Prod(allCy,H2TECH,YTIME))
         /(i05AvailH2Prod(H2TECH,YTIME)*0.8 )+
         i05CostVOMH2Prod(allCy,H2TECH,YTIME) )/0.000304/1000*1.31+
         sum(EF$H2TECHEFtoEF(H2TECH,EF), (VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME)*1e3+
            i05CaptRateH2Prod(allCy,H2TECH,YTIME)*imCo2EmiFac(allCy,"H2P",EF,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)+
            (1-i05CaptRateH2Prod(allCy,H2TECH,YTIME))*imCo2EmiFac(allCy,"H2P",EF,YTIME)*
            (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME))))
            /i05EffH2Prod(allCy,H2TECH,YTIME)
            )  
;

*' This equation models the variable costs associated with hydrogen production, factoring in fuel prices (e.g., electricity or natural gas),
*' CO₂ emission costs, and the efficiency of the production technology. This helps to understand the fluctuating costs based on market conditions.
Q05CostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostVarProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         sum(EF$H2TECHEFtoEF(H2TECH,EF), (VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME)*1e3+
 
            i05CaptRateH2Prod(allCy,H2TECH,YTIME)*imCo2EmiFac(allCy,"H2P",EF,YTIME)*VmCstCO2SeqCsts(allCy,YTIME)+
 
            (1-i05CaptRateH2Prod(allCy,H2TECH,YTIME))*imCo2EmiFac(allCy,"H2P",EF,YTIME)*
 
            (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME))))
 
            /i05EffH2Prod(allCy,H2TECH,YTIME)
            )
;

*' This equation models the acceptance of carbon capture and storage (CCS) technologies in hydrogen production. 
*' It evaluates the economic feasibility of adding CCS to the hydrogen production process, considering cost, 
*' environmental policies, and technology readiness.
Q05AcceptCCSH2Tech(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05AcceptCCSH2Tech(allCy,YTIME)
    =E=
    i05WBLGammaH2Prod(allCy,YTIME)*5 +
    EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME -1)))))
;

*' This equation determines the share of hydrogen produced using CCS technologies compared to those produced without CCS.
*' The share is calculated based on relative costs, technological feasibility, and policy incentives supporting CCS.
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

*' Similar to Q05ShareCCSH2Prod, this equation models the share of hydrogen produced without CCS technologies.
*' It calculates the proportion of production from non-CCS methods like electrolysis or SMR without CO₂ capture.
Q05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy)))..
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , V05ShareCCSH2Prod(allCy,H2TECH2,YTIME) )
;

*' This equation computes the weighted average production cost of hydrogen, incorporating both CCS and non-CCS production methods.
*' It provides an overall cost perspective, helping to assess which production methods dominate the market based on cost-efficiency.
Q05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy))) ..
         V05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)*V05CostProdH2Tech(allCy,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), V05ShareCCSH2Prod(allCy,H2CCS,YTIME)*V05CostProdH2Tech(allCy,H2CCS,YTIME))
;

*' This equation calculates the market share of different hydrogen production technologies, considering factors
*' like cost competitiveness, policy support, and fuel availability. It adjusts market shares based on technological
*' performance and shifting cost dynamics.
Q05GapShareH2Tech2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        V05GapShareH2Tech2(allCy,H2TECH,YTIME)
             =E=
         (
         iWBLShareH2Prod(allCy,H2TECH,YTIME) * 
         (V05CostProdH2Tech(allCy,H2TECH,YTIME)$(not H2NOCCS(H2TECH)) + V05CostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))**(-i05WBLGammaH2Prod(allCy,YTIME))
         /
         sum(H2TECH2$(not H2CCS(H2TECH2)) ,
         iWBLShareH2Prod(allCy,H2TECH2,YTIME) * 
         (V05CostProdH2Tech(allCy,H2TECH2,YTIME)$(not H2NOCCS(H2TECH2)) + V05CostProdCCSNoCCSH2Prod(allCy,H2TECH2,YTIME)$H2NOCCS(H2TECH2))**(-i05WBLGammaH2Prod(allCy,YTIME)))
         )$(not H2CCS(H2TECH))
         +
         sum(H2NOCCS$H2CCS_NOCCS(H2TECH,H2NOCCS), V05GapShareH2Tech2(allCy,H2NOCCS,YTIME))$H2CCS(H2TECH)
;

*' This equation further adjusts the market share of hydrogen technologies, particularly considering 
*' the relative competitiveness between CCS and non-CCS technologies. It helps to model the transition 
*' between different production technologies over time.
Q05GapShareH2Tech1(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05GapShareH2Tech1(allCy,H2TECH,YTIME)
        =E=
    (V05GapShareH2Tech2(allCy,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH)))
    +
    V05GapShareH2Tech2(allCy,H2TECH,YTIME)*(V05ShareCCSH2Prod(allCy,H2TECH,YTIME)$H2CCS(H2TECH) +  V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))
    )
;

*' This equation defines the actual hydrogen production levels, considering both scrapped capacity and the demand gap.
*' It allocates production from different technologies to meet the overall demand, adjusting for changes in capacity and technology availability.
Q05ProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdH2(allCy,H2TECH,YTIME)
        =E=
    (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME))*VmProdH2(allCy,H2TECH,YTIME-1) +
    V05GapShareH2Tech1(allCy,H2TECH,YTIME) * V05DemGapH2(allCy,YTIME)
;

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
         (VmProdH2(allCy,H2TECH,YTIME)/i05EffH2Prod(allCy,H2TECH,YTIME))$(sameas(YTIME,"%fBaseY%")) +
         (
         VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME-1)*
         (VmProdH2(allCy,H2TECH,YTIME)/i05EffH2Prod(allCy,H2TECH,YTIME) + 1e-6)/
         (VmProdH2(allCy,H2TECH,YTIME-1)/i05EffH2Prod(allCy,H2TECH,YTIME-1) + 1e-6)
         )$(not sameas(YTIME,"%fBaseY%"))
;

*' This equation aggregates the total fuel consumption across all hydrogen production technologies in the system,
*' summing up the fuel requirements from all sources. It helps track the total fuel demand for hydrogen production.
Q05ConsFuelH2Prod(allCy,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF) $(runCy(allCy)))..
         VmConsFuelH2Prod(allCy,EF,YTIME)
         =E=
         sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME))
;

$ontext
!!
!!                               B. Hydrogen Infrustructure
!!

*' This equation models the expansion of hydrogen infrastructure (e.g., pipelines, storage facilities)
*' needed to support growing demand. It takes into account the projected growth in hydrogen production 
*' and distribution, ensuring that infrastructure expansion aligns with demand forecasts.
Q05H2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05H2InfrArea(allCy,YTIME)
         =E=
          i05PolH2AreaMax(allCy)/(1 + exp( -i05H2Adopt(allCy,"B",YTIME)*( VmDemTotH2(allCy,YTIME)/(i05HabAreaCountry(allCy)/s05AreaStyle*0.275)- i05H2Adopt(allCy,"MID",YTIME))))

;

*' This equation represents the delivery or throughput capacity of hydrogen infrastructure technologies.
*' It calculates the total amount of hydrogen that can be delivered through the infrastructure, considering
*' factors such as efficiency and technological limits of the infrastructure components (e.g., pipelines, storage, etc.).
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

*' This equation determines the required new investment in hydrogen infrastructure to meet the demand or capacity requirements.
*' It calculates the amount of investment needed to develop or upgrade the infrastructure technologies (like production, storage, and transport)
*' to support future hydrogen use or capacity expansion.
Q05InvNewReqH2Infra(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)
         =E=
         ( V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;

*' This equation focuses on the hydrogen transport capacity through pipelines. It calculates the amount of hydrogen that can be
*' transported through the hydrogen pipeline system, considering factors such as pipe size, pressure, flow rate, and distance.
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

*' This equation calculates the cost of investment in hydrogen infrastructure technologies. It includes the costs associated with 
*' deploying new infrastructure, such as the capital expenses required for construction, material procurement, and installation of
*' technologies related to hydrogen production, storage, and distribution.
Q05CostInvTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (i05CostInvH2Transp(allCy,INFRTECH,YTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) !!Service stations investment cost
;

*' This equation represents the cost of the hydrogen infrastructure technologies themselves, possibly including both capital and operational costs.
*' It may consider costs for specific technologies used in hydrogen systems (e.g., electrolyzers, compressors, storage tanks, etc.) and their maintenance.
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
            (V,CostAvgProdH2(allCy,YTIME-1)$sameas("HPIPU",INFRTECH)+
            VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*1e3)$sameas("SSGG",INFRTECH)
         )$(sameas("SSGG",INFRTECH) or sameas("HPIPU",INFRTECH))
         /V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)
;

*' This equation calculates the cumulative costs of investments in hydrogen transportation infrastructure over time. 
*' It tracks the total cost accumulated as new transportation infrastructure (such as pipelines, compressors, and distribution networks) is installed to meet demand.
Q05CostInvCummH2Transp(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvCummH2Transp(allCy,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),

                 V05CostTechH2Infr(allCy,INFRTECH,YYTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME))
;

*' This equation defines the tariff or price structure for using the hydrogen infrastructure. It calculates the cost or
*' fee associated with transporting hydrogen through the infrastructure, possibly taking into account the infrastructure’s
*' capacity, usage, or maintenance costs. This fee is typically levied per unit of hydrogen transported.
Q05TariffH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05TariffH2Infr(allCy,INFRTECH,YTIME)
         =E=
         i05CostAvgWeight(allCy,YTIME)* V05H2Pipe(allCy,INFRTECH,YTIME)
         +
         (1-i05CostAvgWeight(allCy,YTIME))*V05CostTechH2Infr(allCy,INFRTECH,YTIME)
;

*' This equation calculates the price of hydrogen based on infrastructure costs. It determines the price at which hydrogen
*' can be delivered to end-users, including both the production cost and the infrastructure-related costs (transport, storage, etc.).
Q05PriceH2Infr(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05PriceH2Infr(allCy,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , V05TariffH2Infr(allCy,INFRTECH,YTIME))
;

*' This equation calculates the total cost of hydrogen production, transportation, and distribution, integrating all the costs associated
*' with hydrogen infrastructure and technology. It includes costs for producing hydrogen, investing in infrastructure, maintaining the infrastructure,
*' and any operational costs related to hydrogen transportation and storage.
Q05CostTotH2(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05CostTotH2(allCy,SBS,YTIME)
         =E=
         V05PriceH2Infr(allCy,SBS,YTIME)+VmCostAvgProdH2(allCy,YTIME)
;
$offtext
