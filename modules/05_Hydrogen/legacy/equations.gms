*' Defines hydrogen production required to meet gross inland hydrogen consumption after
*' subtracting net hydrogen imports.

Q05DemTotH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotH2(allCy,YTIME)
      =E=
    V03ConsGrssInl(allCy,"H2F",YTIME) - VmImpNetEneBrnch(allCy,"H2F",YTIME);
*' Sets the lifetime-based retirement fraction to the inverse of the technology lifetime,
*' once the specified initial-period threshold has passed; otherwise it is zero.

Q05ScrapLftH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05ScrapLftH2Prod(allCy,H2TECH,YTIME)
      =E=
    (1/i05ProdLftH2(H2TECH,YTIME))$(ord(YTIME)>14+i05ProdLftH2(H2TECH,YTIME));
*' Computes the surviving fraction associated with premature replacement for eligible
*' hydrogen technologies. It compares inverse-power variable production costs with the
*' scaled inverse-power full costs of alternative technologies, using lagged costs and a
*' Weibull exponent.

Q05PremRepH2Prod(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$H2TECHPM(H2TECH))..
    V05PremRepH2Prod(allCy,H2TECH,YTIME)
        =E=
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME-1)**(-i05WBLGammaH2Prod(allCy,YTIME)) /
    (
      0.03 * iWBLPremRepH2Prod(allCy,H2TECH,YTIME) *
      (
        sum(H2TECH2$(not sameas(H2TECH,H2TECH2)),
          V05CostProdH2Tech(allCy,H2TECH2,YTIME-1) ** (-i05WBLGammaH2Prod(allCy,YTIME))
          !!V05GapShareH2Tech1(allCy,H2TECH2,YTIME)*
          !!(1/i05AvailH2Prod(allCy,H2TECH,YTIME)*
          !!V05CostProdH2Tech(allCy,H2TECH2,YTIME) +
          !!(1-1/i05AvailH2Prod(allCy,H2TECH,YTIME)) * V05CostVarProdH2Tech(allCy,H2TECH2,YTIME))
        )
      ) +
      V05CostVarProdH2Tech(allCy,H2TECH,YTIME-1)**(-i05WBLGammaH2Prod(allCy,YTIME))
    );
*' Calculates the total capacity scrapping fraction by combining lifetime retirement with
*' the premature-replacement survival fraction.

Q05CapScrapH2ProdTech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)
      =E=
    1 - (1-V05ScrapLftH2Prod(allCy,H2TECH,YTIME)) *
    V05PremRepH2Prod(allCy,H2TECH,YTIME);
*' Calculates the non-negative gap between required hydrogen production and output
*' available from surviving capacity, accounting for technology availability and energy
*' conversions. Adds a small numerical offset.

Q05DemGapH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05DemGapH2(allCy,YTIME)
      =E=
    ( 
      VmDemTotH2(allCy,YTIME) -
      sum(H2TECH,
        (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) *
        VmCapH2(allCy,H2TECH,YTIME-1) *
        i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe
      ) +
      SQRT(SQR(
        VmDemTotH2(allCy,YTIME) -
        sum(H2TECH,
          (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) *
          VmCapH2(allCy,H2TECH,YTIME-1) *
          i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe
        )
      )) 
    ) / 2 + 1e-6;
*' Calculates total hydrogen production cost per unit of output: annualized capital and
*' fixed O&M costs, additional solar or wind generation costs for selected electrolysis
*' technologies, and variable production costs. Annualized costs are divided by available
*' annual production.

Q05CostProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CostProdH2Tech(allCy,H2TECH,YTIME)
        =E=
    (
      imDisc(allCy,"H2P",YTIME) * 
      exp(imDisc(allCy,"H2P",YTIME) * i05ProdLftH2(H2TECH,YTIME)) /
      (exp(imDisc(allCy,"H2P",YTIME) * i05ProdLftH2(H2TECH,YTIME))-1) * 
      (
        i05CostCapH2Prod(allCy,H2TECH,YTIME) +
        i05CostFOMH2Prod(allCy,H2TECH,YTIME)
      ) +
      V04CapexFixCostPG(allCy,"PGSOL",YTIME)$sameas(H2TECH,"wes") + 
      V04CapexFixCostPG(allCy,"PGAWNO",YTIME)$sameas(H2TECH,"wew")
    ) / 
    (i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe) +
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME);
*' Calculates non-negative variable hydrogen production cost from feedstock and energy
*' input prices, carbon emissions and capture or storage costs, variable O&M, and
*' additional solar or wind operating costs for selected technologies. Input-output ratios
*' weight the energy and feedstock costs.

Q05CostVarProdH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05CostVarProdH2Tech(allCy,H2TECH,YTIME)
        =E=
    (
      sum(EF$(H2TECHtoFEEDSTOCK(H2TECH,EF) or H2TECHtoENERGY(H2TECH,EF)),
        (
          VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME) * 1e3 +
          V05CaptRateH2(allCy,H2TECH,YTIME) * (imCo2EmiFac(allCy,"H2P",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * VmCstCO2SeqCsts(allCy,YTIME) +
          (1-V05CaptRateH2(allCy,H2TECH,YTIME)) * imCo2EmiFac(allCy,"H2P",EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) -
          V05CaptRateH2(allCy,H2TECH,YTIME) * (4.17$sameas("BMSWAS", EF)) * sum(NAP$NAPtoALLSBS(NAP,"H2P"), VmCarVal(allCy,NAP,YTIME))
        ) * (i05InputOverOutH2ProdFeed(allCy,H2TECH,EF,YTIME) + i05InputOverOutH2ProdEnergy(allCy,H2TECH,EF,YTIME))
      ) +
      i05CostVOMH2Prod(allCy,H2TECH,YTIME) +
      (i04VarCost("PGSOL",YTIME) / smTWhToMtoe)$sameas(H2TECH,"wes") +
      (i04VarCost("PGAWNO",YTIME) / smTWhToMtoe)$sameas(H2TECH,"wew") +

      SQRT(SQR(
        sum(EF$(H2TECHtoFEEDSTOCK(H2TECH,EF) or H2TECHtoENERGY(H2TECH,EF)),
          (
            VmPriceFuelSubsecCarVal(allCy,"H2P",EF,YTIME) * 1e3 +
            V05CaptRateH2(allCy,H2TECH,YTIME) * (imCo2EmiFac(allCy,"H2P",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * VmCstCO2SeqCsts(allCy,YTIME) +
            (1-V05CaptRateH2(allCy,H2TECH,YTIME)) * imCo2EmiFac(allCy,"H2P",EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,"H2P"),VmCarVal(allCy,NAP,YTIME)) -
            V05CaptRateH2(allCy,H2TECH,YTIME) * (4.17$sameas("BMSWAS", EF)) * sum(NAP$NAPtoALLSBS(NAP,"H2P"), VmCarVal(allCy,NAP,YTIME))
          ) * (i05InputOverOutH2ProdFeed(allCy,H2TECH,EF,YTIME) + i05InputOverOutH2ProdEnergy(allCy,H2TECH,EF,YTIME))
        ) +
        i05CostVOMH2Prod(allCy,H2TECH,YTIME) +
        (i04VarCost("PGSOL",YTIME) / smTWhToMtoe)$sameas(H2TECH,"wes") +
        (i04VarCost("PGAWNO",YTIME) / smTWhToMtoe)$sameas(H2TECH,"wew")
      ))
    ) / 2 + 1e-3;
*' Allocates the hydrogen production demand gap across technologies using maturity factors
*' and inverse-square lagged total production costs. Shares are normalized across all
*' hydrogen technologies.

Q05GapShareH2Tech(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05GapShareH2Tech(allCy,H2TECH,YTIME)
        =E=
    i05MatFacH2(allCy,H2TECH,YTIME) *
    V05CostProdH2Tech(allCy,H2TECH,YTIME-1) ** (-2) /
    SUM(H2TECH2,
      i05MatFacH2(allCy,H2TECH2,YTIME) *
      V05CostProdH2Tech(allCy,H2TECH2,YTIME-1) ** (-2)
    );
*' Updates installed hydrogen production capacity as surviving capacity plus newly
*' installed capacity. New capacity is the technology share of the demand gap divided by
*' annual available hydrogen output per unit of capacity.

Q05CapH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapH2(allCy,H2TECH,YTIME)
        =E=
    (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) * VmCapH2(allCy,H2TECH,YTIME-1) +
    V05GapShareH2Tech(allCy,H2TECH,YTIME) * V05DemGapH2(allCy,YTIME) / (i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe);

*' Calculates the system-wide hydrogen utilization rate as total hydrogen demand divided
*' by the sum of available annual production from installed hydrogen capacity. The
*' resulting rate is indexed by technology but uses the same system-wide ratio.
Q05UtilRate(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V05UtilRate(allCy,H2TECH,YTIME)
        =E=
    VmDemTotH2(allCy,YTIME) /
    SUM(H2TECH2,
      VmCapH2(allCy,H2TECH2,YTIME) * 
      i05AvailH2Prod(allCy,H2TECH2,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe
    );
*' Calculates hydrogen output by multiplying installed technology capacity by the
*' system-wide utilization rate, technology availability, and annual capacity-to-energy
*' conversion factors.

Q05ProdH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmProdH2(allCy,H2TECH,YTIME)
        =E=
    V05UtilRate(allCy,H2TECH,YTIME) * 
    VmCapH2(allCy,H2TECH,YTIME) * 
    i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe;
*' Calculates the production-weighted average cost of hydrogen across technologies, adding
*' a small offset to production weights to avoid zero denominators.

Q05CostAvgProdH2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdH2(allCy,YTIME)
        =E=
    sum(H2TECH, 
      (VmProdH2(allCy,H2TECH,YTIME) + 1e-6) *
      V05CostProdH2Tech(allCy,H2TECH,YTIME)
    ) /
    sum(H2TECH,VmProdH2(allCy,H2TECH,YTIME) + 1e-6);


$ontext
!!
!!                               B. Hydrogen Infrustructure
!!
*' Inactive infrastructure equation. Uses a logistic adoption function to estimate the
*' hydrogen infrastructure coverage area from hydrogen demand relative to habitable area,
*' subject to a maximum coverage parameter.

Q05H2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05H2InfrArea(allCy,YTIME)
         =E=
          i05PolH2AreaMax(allCy)/(1 + exp( -i05H2Adopt(allCy,"B",YTIME)*( VmDemTotH2(allCy,YTIME)/(i05HabAreaCountry(allCy)/s05AreaStyle*0.275)- i05H2Adopt(allCy,"MID",YTIME))))

;
*' Inactive infrastructure equation. Computes required hydrogen throughput at final-demand
*' nodes or upstream network links, adjusted for transport efficiency and
*' self-consumption. Includes a small numerical offset.

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
*' Inactive infrastructure equation. Estimates positive growth in required hydrogen
*' infrastructure throughput between periods, using a smoothed positive-part expression.

Q05InvNewReqH2Infra(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05InvNewReqH2Infra(allCy,INFRTECH,YTIME)
         =E=
         ( V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)
          + 0 + 
          SQRT( SQR(V05DelivH2InfrTech(allCy,INFRTECH,YTIME)-V05DelivH2InfrTech(allCy,INFRTECH,YTIME-1)+0) + SQR(1e-4) ) )/2
;
*' Inactive infrastructure equation. Converts new throughput requirements or related
*' infrastructure variables into pipeline lengths and service-station counts using
*' technology-specific factors.

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
*' Inactive infrastructure equation. Computes infrastructure investment cost by technology
*' using unit transport costs, infrastructure coverage, and new requirements. The pipeline
*' terms reference the same investment-cost variable.

Q05CostInvTechH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvTechH2Infr(allCy,INFRTECH,YTIME)
         =E=
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(sameas("TPIPA",INFRTECH))
         +
         1e-6*(i05CostInvH2Transp(allCy,INFRTECH,YTIME)/V05H2InfrArea(allCy,YTIME)*V05CostInvTechH2Infr(allCy,INFRTECH,YTIME))$(PIPES(INFRTECH) $(not sameas("TPIPA",INFRTECH)))
         +
         (i05CostInvH2Transp(allCy,INFRTECH,YTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YTIME))$(sameas("SSGG",INFRTECH)) !!Service stations investment cost
;
*' Inactive infrastructure equation. Combines annualized cumulative infrastructure
*' investment, fixed and variable O&M, availability, and selected self-consumption energy
*' costs. The exact expression differs by infrastructure technology.

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
*' Inactive infrastructure equation. Calculates a cumulative investment-weighted
*' infrastructure cost over historical periods, with an exponential weighting factor.

Q05CostInvCummH2Transp(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05CostInvCummH2Transp(allCy,INFRTECH,YTIME) 
         =E=
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),

                 V05CostTechH2Infr(allCy,INFRTECH,YYTIME)*V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME)*exp(0.04*(ord(YTIME)-ord(YYTIME)))
         )
         /
         sum(YYTIME$(an(YYTIME) $(ord(YYTIME)<=ord(YTIME))),V05InvNewReqH2Infra(allCy,INFRTECH,YYTIME))
;
*' Inactive infrastructure equation. Forms an infrastructure tariff as a weighted
*' combination of the pipeline-related variable and infrastructure technology cost.

Q05TariffH2Infr(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V05TariffH2Infr(allCy,INFRTECH,YTIME)
         =E=
         i05CostAvgWeight(allCy,YTIME)* V05H2Pipe(allCy,INFRTECH,YTIME)
         +
         (1-i05CostAvgWeight(allCy,YTIME))*V05CostTechH2Infr(allCy,INFRTECH,YTIME)
;
*' Inactive infrastructure equation. Sums infrastructure tariffs mapped to each
*' hydrogen-consuming sector.

Q05PriceH2Infr(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05PriceH2Infr(allCy,SBS,YTIME)
         =E=
         sum(INFRTECH$H2INFRSBS(INFRTECH,SBS) , V05TariffH2Infr(allCy,INFRTECH,YTIME))
;
*' Inactive infrastructure equation. Adds the sectoral hydrogen infrastructure price to
*' the average hydrogen production cost.

Q05CostTotH2(allCy,SBS,YTIME)$(TIME(YTIME) $SECTTECH(SBS,"H2F") $(runCy(allCy)))..
         V05CostTotH2(allCy,SBS,YTIME)
         =E=
         V05PriceH2Infr(allCy,SBS,YTIME)+VmCostAvgProdH2(allCy,YTIME)
;
$offtext

*' Computes an endogenous hydrogen-production CO2 capture rate from the technology maximum
*' capture rate and a logistic function of CO2 storage cost relative to the
*' hydrogen-sector carbon price.
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
        -1.1)
      )
    );
