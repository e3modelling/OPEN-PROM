*' @title Equations of OPEN-PROMs Hydrogen
*' @code

*' This equation calculates the total hydrogen demand in the system. It takes into account the overall need for hydrogen
*' across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
Q05DemTotH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VMVDemTotH2(allCy,YTIME)
                 =E=
         sum(SBS$H2SBS(SBS), VDemSecH2(allCy,SBS, YTIME)/
         prod(INFRTECH$H2INFRSBS(INFRTECH,SBS) , iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))))  !! increase the demand due to transportation losses
;

*' This equation defines the amount of hydrogen production capacity that is scrapped due to the expiration of the useful life of plants.
*' It considers the remaining lifetime of hydrogen production facilities and the impact of past production gaps.
QScrapLftH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VScrapLftH2Prod(allCy,H2TECH,YTIME)
         =E=
         (
         VGapShareH2Tech1(allCy,H2TECH,YTIME-iProdLftH2(H2TECH,YTIME))*VDemGapH2(allCy,YTIME-iProdLftH2(H2TECH,YTIME))
         /VMVProdH2(allCy,H2TECH,YTIME-1)
         )$(ord(YTIME)>17+iProdLftH2(H2TECH,YTIME)) + 0.1
;

*' This equation models the premature replacement of hydrogen production capacity. It adjusts for the need to replace aging
*' or inefficient hydrogen production technologies before their expected end of life based on economic factors such as cost,
*' technological progress, and demand shifts.
QPremRepH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VPremRepH2Prod(allCy,H2TECH,YTIME)
         =E=
         1-
         (
          VCostVarProdH2Tech(allCy,H2TECH,YTIME)**(-iWBLGammaH2Prod(allCy,YTIME))
         /
         (
*           iWBLPremRepH2Prod(allCy,H2TECH,YTIME)*
           (sum(H2TECH2,
                         VGapShareH2Tech1(allCy,H2TECH2,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH2,YTIME)
                                                         +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(allCy,H2TECH2,YTIME)))

                        -VGapShareH2Tech1(allCy,H2TECH,YTIME)*(1/iAvailH2Prod(H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME)
                                                        +(1-1/iAvailH2Prod(H2TECH,YTIME))*VCostVarProdH2Tech(allCy,H2TECH,YTIME))
           )**(-iWBLGammaH2Prod(allCy,YTIME))

           +VCostVarProdH2Tech(allCy,H2TECH,YTIME)**(-iWBLGammaH2Prod(allCy,YTIME))
         )
         )$H2TECHPM(H2TECH)
;

*' This equation calculates the total hydrogen production capacity that is scrapped as part of the premature replacement
*' and normal plant life cycle. It links the scrapped capacity to the overall age distribution and retirement schedule of
*' hydrogen production technologies.
QCapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapScrapH2ProdTech(allCy,H2TECH,YTIME)
         =E=
         1-(1-VScrapLftH2Prod(allCy,H2TECH,YTIME))*(1-VPremRepH2Prod(allCy,H2TECH,YTIME))
;

*' The hydrogen demand gap equation defines the difference between the total hydrogen demand (calculated in Q05DemTotH2) and
*' the actual hydrogen production capacity. It ensures that the gap value is non-negative, preventing overproduction or underproduction of hydrogen.
QDemGapH2(allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VDemGapH2(allCy, YTIME)
                 =E=
         ( VMVDemTotH2(allCy,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(allCy,H2TECH,YTIME))*VMVProdH2(allCy,H2TECH,YTIME-1))
          + 0 +
         SQRT( SQR(VMVDemTotH2(allCy,YTIME) - sum(H2TECH,(1-VCapScrapH2ProdTech(allCy,H2TECH,YTIME))*VMVProdH2(allCy,H2TECH,YTIME-1))-0) + SQR(1E-4) )
         )/2
;

*' This equation calculates the production costs of hydrogen, including both fixed costs (e.g., capital investment) 
*' and variable costs (e.g., operational expenses). The costs are typically differentiated by hydrogen production 
*' technologies such as electrolysis, steam methane reforming (SMR), or coal gasification.
QCostProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         (iDisc(allCy,"H2P",YTIME)*exp(iDisc(allCy,"H2P",YTIME)* iProdLftH2(H2TECH,YTIME))/(exp(iDisc(allCy,"H2P",YTIME)*iProdLftH2(H2TECH,YTIME))-1)*
         iCostCapH2Prod(allCy,H2TECH,YTIME)+iCostFOMH2Prod(allCy,H2TECH,YTIME))/257/365*1000000/iAvailH2Prod(H2TECH,YTIME) +
         iCostVOMH2Prod(allCy,H2TECH,YTIME) + VCostVarProdH2Tech(allCy,H2TECH,YTIME)
;

*' This equation models the variable costs associated with hydrogen production, factoring in fuel prices (e.g., electricity or natural gas),
*' CO₂ emission costs, and the efficiency of the production technology. This helps to understand the fluctuating costs based on market conditions.
QCostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostVarProdH2Tech(allCy,H2TECH,YTIME)
         =E=
         sum(EF$H2TECHEFtoEF(H2TECH,EF), (VMVPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME)*1e3+

            iCaptRateH2Prod(allCy,H2TECH,YTIME)*iCo2EmiFac(allCy,"H2P",EF,YTIME)*VMVCstCO2SeqCsts(allCy,YTIME)+

            (1-iCaptRateH2Prod(allCy,H2TECH,YTIME))*iCo2EmiFac(allCy,"H2P",EF,YTIME)*

            (sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(allCy,NAP,YTIME))))

            /iEffH2Prod(allCy,H2TECH,YTIME)
            )!!$(not H2TECHREN(H2TECH))
;

*' This equation models the acceptance of carbon capture and storage (CCS) technologies in hydrogen production. 
*' It evaluates the economic feasibility of adding CCS to the hydrogen production process, considering cost, 
*' environmental policies, and technology readiness.
QAcceptCCSH2Tech(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VAcceptCCSH2Tech(allCy,YTIME)
         =E=
         iWBLGammaH2Prod(allCy,YTIME)*5+25*EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"H2P"),VCarVal(allCy,NAP,YTIME -1)))))
;

*' This equation determines the share of hydrogen produced using CCS technologies compared to those produced without CCS.
*' The share is calculated based on relative costs, technological feasibility, and policy incentives supporting CCS.
QShareCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2CCS(H2TECH) $(runCy(allCy)))..
         VShareCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
                 1.5  *
*         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)) /
         (
                 1.5  *
*         iWBLShareH2Prod(allCy,H2TECH,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)) +

                 sum(H2TECH2$H2CCS_NOCCS(H2TECH,H2TECH2),

                 1  *
*         iWBLShareH2Prod(allCy,H2TECH2,YTIME) *
                 VCostProdH2Tech(allCy,H2TECH2,YTIME)**(-VAcceptCCSH2Tech(allCy,YTIME)))
         )
;

*' Similar to QShareCCSH2Prod, this equation models the share of hydrogen produced without CCS technologies.
*' It calculates the proportion of production from non-CCS methods like electrolysis or SMR without CO₂ capture.
QShareNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy)))..
         VShareNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         1 - sum(H2TECH2$H2CCS_NOCCS(H2TECH2,H2TECH)  , VShareCCSH2Prod(allCy,H2TECH2,YTIME) )
;

*' This equation computes the weighted average production cost of hydrogen, incorporating both CCS and non-CCS production methods.
*' It provides an overall cost perspective, helping to assess which production methods dominate the market based on cost-efficiency.
QCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME) $H2NOCCS(H2TECH) $(runCy(allCy))) ..
         VCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)
         =E=
         VShareNoCCSH2Prod(allCy,H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME)+
         sum(H2CCS$H2CCS_NOCCS(H2CCS,H2TECH), VShareCCSH2Prod(allCy,H2CCS,YTIME)*VCostProdH2Tech(allCy,H2CCS,YTIME))
;

*' This equation calculates the market share of different hydrogen production technologies, considering factors
*' like cost competitiveness, policy support, and fuel availability. It adjusts market shares based on technological
*' performance and shifting cost dynamics.
QGapShareH2Tech2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VGapShareH2Tech2(allCy,H2TECH,YTIME)
             =E=
         (
*         iWBLShareH2Prod(allCy,H2TECH,YTIME) * 
         (VCostProdH2Tech(allCy,H2TECH,YTIME)$(not H2NOCCS(H2TECH)) + VCostProdCCSNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))**(-iWBLGammaH2Prod(allCy,YTIME))
         /
         sum(H2TECH2$(not H2CCS(H2TECH2)) ,
*         iWBLShareH2Prod(allCy,H2TECH2,YTIME) * 
         (VCostProdH2Tech(allCy,H2TECH2,YTIME)$(not H2NOCCS(H2TECH2)) + VCostProdCCSNoCCSH2Prod(allCy,H2TECH2,YTIME)$H2NOCCS(H2TECH2))**(-iWBLGammaH2Prod(allCy,YTIME)))
         )$(not H2CCS(H2TECH))
         +
         sum(H2NOCCS$H2CCS_NOCCS(H2TECH,H2NOCCS), VGapShareH2Tech2(allCy,H2NOCCS,YTIME))$H2CCS(H2TECH)
;

*' This equation further adjusts the market share of hydrogen technologies, particularly considering 
*' the relative competitiveness between CCS and non-CCS technologies. It helps to model the transition 
*' between different production technologies over time.
QGapShareH2Tech1(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VGapShareH2Tech1(allCy,H2TECH,YTIME)
         =E=
         (VGapShareH2Tech2(allCy,H2TECH,YTIME)$((not H2CCS(H2TECH)) $(not H2NOCCS(H2TECH)))
          +
         VGapShareH2Tech2(allCy,H2TECH,YTIME)*(VShareCCSH2Prod(allCy,H2TECH,YTIME)$H2CCS(H2TECH) +  VShareNoCCSH2Prod(allCy,H2TECH,YTIME)$H2NOCCS(H2TECH))
         )
;

*' This equation defines the actual hydrogen production levels, considering both scrapped capacity and the demand gap.
*' It allocates production from different technologies to meet the overall demand, adjusting for changes in capacity and technology availability.
Q05ProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VMVProdH2(allCy,H2TECH,YTIME)
         =E=
         0.0001+(1-VCapScrapH2ProdTech(allCy,H2TECH,YTIME))*VMVProdH2(allCy,H2TECH,YTIME-1)+ VGapShareH2Tech1(allCy,H2TECH,YTIME)*VDemGapH2(allCy,YTIME)
;

*' This equation calculates the average cost of hydrogen production across all technologies in the system.
*' It accounts for varying costs of different technologies (e.g., electrolysis vs. SMR) to provide an overall assessment of hydrogen production cost.
QCostAvgProdH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostAvgProdH2(allCy,YTIME)
         =E=
         sum(H2TECH, VMVProdH2(allCy,H2TECH,YTIME)*VCostProdH2Tech(allCy,H2TECH,YTIME))/sum(H2TECH,VMVProdH2(allCy,H2TECH,YTIME))
;

*' This equation calculates the fuel consumption for each hydrogen production technology, considering 
*' the efficiency of the technology and the amount of fuel required for producing a unit of hydrogen. 
*' It provides insight into fuel demand for hydrogen production.
Q05ConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)$(TIME(YTIME) $H2TECHEFtoEF(H2TECH,EF) $(runCy(allCy)))..
         VMVConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)
         =E=
         (VMVProdH2(allCy,H2TECH,YTIME)/iEffH2Prod(allCy,H2TECH,YTIME))$(sameas(YTIME,"%fBaseY%"))
         +
         (
         VMVConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME-1)*
         (VMVProdH2(allCy,H2TECH,YTIME)/iEffH2Prod(allCy,H2TECH,YTIME))/
         (VMVProdH2(allCy,H2TECH,YTIME-1)/iEffH2Prod(allCy,H2TECH,YTIME-1))
         )$(not sameas(YTIME,"%fBaseY%"))
;

*' This equation aggregates the total fuel consumption across all hydrogen production technologies in the system,
*' summing up the fuel requirements from all sources. It helps track the total fuel demand for hydrogen production.
QConsFuelH2Prod(allCy,EF,YTIME)$(TIME(YTIME) $H2PRODEF(EF) $(runCy(allCy)))..
         VConsFuelH2Prod(allCy,EF,YTIME)
         =E=
         sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VMVConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME))
;


!!
!!                               B. Hydrogen Infrustructure
!!

*' This equation models the expansion of hydrogen infrastructure (e.g., pipelines, storage facilities)
*' needed to support growing demand. It takes into account the projected growth in hydrogen production 
*' and distribution, ensuring that infrastructure expansion aligns with demand forecasts.
QH2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VH2InfrArea(allCy,YTIME)
         =E=
         0.001+iPolH2AreaMax(allCy)/(1 + exp( -iH2Adopt(allCy,"B",YTIME)*( VMVDemTotH2(allCy,YTIME)/(iHabAreaCountry(allCy)/sAreaStyle*0.275)- iH2Adopt(allCy,"MID",YTIME))))

;

*' This equation represents the delivery or throughput capacity of hydrogen infrastructure technologies.
*' It calculates the total amount of hydrogen that can be delivered through the infrastructure, considering
*' factors such as efficiency and technological limits of the infrastructure components (e.g., pipelines, storage, etc.).
QDelivH2InfrTech(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VDelivH2InfrTech(allCy,INFRTECH,YTIME)
         =E=
         (
         (    sum(SBS$(H2INFRSBS(INFRTECH,SBS) $SECTTECH(SBS,"H2F")), VDemSecH2(allCy,SBS, YTIME))/
            (iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))) )$H2INFRDNODES(INFRTECH)  !! for final demand nodes

         +

         sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2), VDelivH2InfrTech(allCy,INFRTECH2,YTIME)/(iEffH2Transp(allCy,INFRTECH,YTIME)*(1-iConsSelfH2Transp(allCy,INFRTECH,YTIME))))$(not H2INFRDNODES(INFRTECH))

         )$iPolH2AreaMax(allCy)
         +1e-7
;

*' This equation determines the required new investment in hydrogen infrastructure to meet the demand or capacity requirements.
*' It calculates the amount of investment needed to develop or upgrade the infrastructure technologies (like production, storage, and transport)
*' to support future hydrogen use or capacity expansion.
QInvNewReqH2Infra(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VInvNewReqH2Infra(allCy,INFRTECH,YTIME)
         =E=
         ( VDelivH2InfrTech(allCy,INFRTECH,YTIME)-VDelivH2InfrTech(allCy,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(VDelivH2InfrTech(allCy,INFRTECH,YTIME)-VDelivH2InfrTech(allCy,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;

*' This equation focuses on the hydrogen transport capacity through pipelines. It calculates the amount of hydrogen that can be
*' transported through the hydrogen pipeline system, considering factors such as pipe size, pressure, flow rate, and distance.
QH2Pipe(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VH2Pipe(allCy,INFRTECH,YTIME)
         =E=
         (55*VInvNewReqH2Infra(allCy,INFRTECH,YTIME)/(1e-3*sDelivH2Turnpike))$sameas("TPIPA",INFRTECH)  !! turnpike pipeline km
         +
         (iPipeH2Transp(INFRTECH,YTIME)*1e6*VInvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("LPIPU",INFRTECH) or sameas("HPIPI",INFRTECH)) !!Low pressure urban pipelines km and industrial pipelines km
         +
         (sLenH2StationConn*VCostInvTechH2Infr(allCy,"SSGG",YTIME))$sameas("MPIPS",INFRTECH)   !! Pipelines connecting hydrogen service stations with the ring km
         +
         (sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2),VCostInvTechH2Infr(allCy,INFRTECH2,YTIME)*iKmFactH2Transp(allCy,INFRTECH2)))$(sameas("MPIPU",INFRTECH)  or sameas("HPIPU",INFRTECH)) !! Ring pipeline in km and high pressure pipelines km
         +
         (VInvNewReqH2Infra(allCy,INFRTECH,YTIME)/sSalesH2Station*1E3)$sameas("SSGG",INFRTECH)   !! Number of new service stations to be built to meet the demand
;

*' This equation calculates the cost of investment in hydrogen infrastructure technologies. It includes the costs associated with 
*' deploying new infrastructure, such as the capital expenses required for construction, material procurement, and installation of
*' technologies related to hydrogen production, storage, and distribution.
QCostInvTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostInvTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         1e-6*(iCostInvH2Transp(allCy,INFRTECH,YTIME)/VH2InfrArea(allCy,YTIME)*VCostInvTechH2Infr(allCy,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(iCostInvH2Transp(allCy,INFRTECH,YTIME)/VH2InfrArea(allCy,YTIME)*VCostInvTechH2Infr(allCy,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (iCostInvH2Transp(allCy,INFRTECH,YTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) !!Service stations investment cost
;

*' This equation represents the cost of the hydrogen infrastructure technologies themselves, possibly including both capital and operational costs.
*' It may consider costs for specific technologies used in hydrogen systems (e.g., electrolyzers, compressors, storage tanks, etc.) and their maintenance.
QCostTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         ((iDisc(allCy,"H2INFR",YTIME)*exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH,YTIME))/(exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH,YTIME))-1))
         *
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME)*(1+iCostInvFOMH2(INFRTECH,YTIME)))/iAvailRateH2Transp(INFRTECH,YTIME) + iCostInvVOMH2(INFRTECH,YTIME)
         *
         (iDisc(allCy,"H2INFR",YTIME)*exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH,YTIME))/(exp(iDisc(allCy,"H2INFR",YTIME)* iTranspLftH2(INFRTECH,YTIME))-1))*
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME)
         +
         (
            iConsSelfH2Transp(allCy,INFRTECH,YTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YTIME)*
            (VCostAvgProdH2(allCy,YTIME-1)$sameas("HPIPU",INFRTECH)+
            VMVPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME-1)*1e3)$sameas("SSGG",INFRTECH)
         )$(sameas("SSGG",INFRTECH) or sameas("HPIPU",INFRTECH))
         /VInvNewReqH2Infra(allCy,INFRTECH,YTIME)
;

*' This equation calculates the cumulative costs of investments in hydrogen transportation infrastructure over time. 
*' It tracks the total cost accumulated as new transportation infrastructure (such as pipelines, compressors, and distribution networks) is installed to meet demand.
QCostInvCummH2Transp(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCostInvCummH2Transp(allCy,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),

                 VCostTechH2Infr(allCy,INFRTECH,YYTIME)*VInvNewReqH2Infra(allCy,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),VInvNewReqH2Infra(allCy,INFRTECH,YYTIME))
;

*' This equation defines the tariff or price structure for using the hydrogen infrastructure. It calculates the cost or
*' fee associated with transporting hydrogen through the infrastructure, possibly taking into account the infrastructure’s
*' capacity, usage, or maintenance costs. This fee is typically levied per unit of hydrogen transported.
QTariffH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VTariffH2Infr(allCy,INFRTECH,YTIME)
         =E=
         iCostAvgWeight(allCy,YTIME)* VH2Pipe(allCy,INFRTECH,YTIME)
         +
         (1-iCostAvgWeight(allCy,YTIME))*VCostTechH2Infr(allCy,INFRTECH,YTIME)
;

*' This equation calculates the price of hydrogen based on infrastructure costs. It determines the price at which hydrogen
*' can be delivered to end-users, including both the production cost and the infrastructure-related costs (transport, storage, etc.).
QPriceH2Infr(allCy,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS) $(runCy(allCy)))..
         VPriceH2Infr(allCy,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , VTariffH2Infr(allCy,INFRTECH,YTIME))
;

*' This equation calculates the total cost of hydrogen production, transportation, and distribution, integrating all the costs associated
*' with hydrogen infrastructure and technology. It includes costs for producing hydrogen, investing in infrastructure, maintaining the infrastructure,
*' and any operational costs related to hydrogen transportation and storage.
QCostTotH2(allCy,SBS,YTIME)$(TIME(YTIME) $H2SBS(SBS) $(runCy(allCy)))..
         VCostTotH2(allCy,SBS,YTIME)
         =E=
         VPriceH2Infr(allCy,SBS,YTIME)+VCostAvgProdH2(allCy,YTIME)
;
