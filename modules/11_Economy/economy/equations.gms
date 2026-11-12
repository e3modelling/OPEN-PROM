*' @title Equations of OPEN-PROM's Economy module
*' @code

*' * Economy module
*' Subsidy budgets, technology allocations, capital grants and net subsidy balances.

*' Defines the available subsidy budget as the positive part of prior-year gross demand
*' and supply CO2 emissions minus the change in cumulative CO2 capture, multiplied by the
*' prior-year PG-sector carbon value. Adds 0.5% of current GDP, converted by 1000, and the
*' previous subsidy-tax balance. The square-root-of-square term implements the positive
*' part.
Q11SubsiTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V11SubsiTot(allCy,YTIME)
        =E=
    (
      SUM(DSBS, V07GrossEmissCO2Demand(allCy,DSBS,YTIME-1)) +
      sum(SSBS, V07GrossEmissCO2Supply(allCy,SSBS,YTIME-1)) -
      (V06CaptCummCO2(allCy,YTIME-1) - V06CaptCummCO2(allCy,YTIME-2))
      +
      sqrt(sqr(
        SUM(DSBS, V07GrossEmissCO2Demand(allCy,DSBS,YTIME-1))
      + sum(SSBS,V07GrossEmissCO2Supply(allCy,SSBS,YTIME-1))
        -
        (V06CaptCummCO2(allCy,YTIME-1) - V06CaptCummCO2(allCy,YTIME-2))
      ))
    ) / 2
    *
    sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME-1))
    + 0.005 * i01GDP(YTIME,allCy) * 1000
    + VmNetSubsiTax(allCy,YTIME-1)
;
*' Allocates the total subsidy budget to eligible demand-sector technologies using the
*' country-, sector-, technology-, and year-specific subsidy allocation parameter.
Q11SubsiDemTechAvail(allCy,DSBS,TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH(DSBS,TECH))..
    VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME)
        =E=
    V11SubsiTot(allCy,YTIME) * i11SubsiPerDemTechAvail(allCy,DSBS,TECH,YTIME);
*' Sets industrial technology subsidy per unit of capacity to zero because the entire
*' calculated expression is multiplied by zero. The inactive expression uses available
*' grants, previous useful-demand equipment additions, lifetime, and a capital-cost floor.
Q11SubsiDemITech(allCy,DSBS,ITECH,YTIME)$(INDSE(DSBS) and SECTTECH(DSBS,ITECH) and TIME(YTIME) and runCy(allCy))..
    VmSubsiDemITech(allCy,DSBS,ITECH,YTIME)
        =E=
    0 * (
      VmSubsiDemTechAvail(allCy,DSBS,ITECH,YTIME) * 1e3 /
      (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME-1) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME-1) * 1e6 * VmLft(allCy,DSBS,ITECH,YTIME) + 1e-6) +
      (1 - imCapCostTechMin(allCy,DSBS,ITECH,YTIME)) * V02CostTech(allCy,DSBS,ITECH,YTIME-1)
    -
    sqrt(sqr(
      VmSubsiDemTechAvail(allCy,DSBS,ITECH,YTIME) * 1e3 /
      (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME-1) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME-1) * 1e6 * VmLft(allCy,DSBS,ITECH,YTIME) + 1e-6) -
      (1 - imCapCostTechMin(allCy,DSBS,ITECH,YTIME)) * V02CostTech(allCy,DSBS,ITECH,YTIME-1)
    ))
    )$(ord(YTIME) > 15) / 2;
*' Calculates the CDR technology subsidy as the minimum of available grant per
*' previous-year new CDR capacity and the subsidy-eligible fraction of current CDR
*' levelized cost. The transport and industry terms are enclosed in a disabled $$ontext
*' block. The CDR term applies after the specified initial periods.
Q11SubsiDemTech(allCy,DSBS,TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH(DSBS,TECH))..
    VmSubsiDemTech(allCy,DSBS,TECH,YTIME)
        =E=
    $$ontext
    (sum(TTECH$(sameas(TECH,TTECH)), !! Transport
      ( !! Transport (EVs)
        (
          VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME) * 1e3 / (V01NewRegPcTechYearly(allCy,TTECH,YTIME-1) * 1e6 + 1e-6) +
           (1 - imCapCostTechMin(allCy,DSBS,TECH,YTIME)) * imCapCostTech(allCy,DSBS,TECH,YTIME)
          + (1 - imCapCostTechMin(allCy,DSBS,TECH,YTIME)) * imCapCostTech(allCy,DSBS,TECH,YTIME)
        ) -
        sqrt(sqr(
        VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME) * 1e3 / (V01NewRegPcTechYearly(allCy,TTECH,YTIME-1) * 1e6 + 1e-6)
        - (1 - imCapCostTechMin(allCy,DSBS,TECH,YTIME)) * imCapCostTech(allCy,DSBS,TECH,YTIME)))
      ) / 2
    )$(ord(YTIME) > 15 and TRANSE(DSBS) and sameas(DSBS,"PC") and sameas(TECH,"TELC")))
    +
    (sum(ITECH$(sameas(TECH,ITECH)), !! Industry
      VmSubsiDemITech(allCy,DSBS,ITECH,YTIME)
    )$INDSE(DSBS))
    
    +
$$offtext 
* CDR levelized cost excludes the storage tax; only technology cost is subsidized.
    sum(CDRTECH$(sameas(TECH,CDRTECH)), !! CDR
      (
        VmSubsiDemTechAvail(allCy,DSBS,CDRTECH,YTIME) * 1e6 / V06CapFacNewCDR(allCy,CDRTECH,YTIME-1)
      + (1 - imCapCostTechMin(allCy,DSBS,CDRTECH,YTIME))
        * V06LvlCostCDR(allCy,CDRTECH,YTIME)
      -
      sqrt(sqr(VmSubsiDemTechAvail(allCy,DSBS,CDRTECH,YTIME) * 1e6 / V06CapFacNewCDR(allCy,CDRTECH,YTIME-1)
      - (1 - imCapCostTechMin(allCy,DSBS,CDRTECH,YTIME))
        * V06LvlCostCDR(allCy,CDRTECH,YTIME)))
      ) / 2
    )$(CDR(DSBS) and ord(YTIME) > 15)
;
*' Sets the subsidy amount for every eligible supply technology equal to the full subsidy
*' budget. The technology-specific allocation factor is commented out and therefore does
*' not scale the result.
Q11SubsiSupTech(allCy,STECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmSubsiSupTech(allCy,STECH,YTIME)
        =E=
        V11SubsiTot(allCy,YTIME) !!* i11SubsiPerSupTech(allCy,STECH,YTIME)
;
*' Calculates demand-side capital subsidies for passenger-car transport and industry. Each
*' term takes the minimum of the available grant and the eligible capital expenditure,
*' using the identity (a+b-abs(a-b))/2. CDR and household electricity terms are commented
*' out.
Q11SubsiCapCostTech(allCy,DSBS,TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH(DSBS,TECH))..
      VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)
      =E=
      sum(TTECH$(sameas(TECH,TTECH)), !!Transport subsidies and grants
        VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME)
        + (1 - imCapCostTechMin(allCy,DSBS,TECH,YTIME)) * imCapCostTech(allCy,DSBS,TECH,YTIME) * 1e-3
          * (V01NewRegPcTechYearly(allCy,TTECH,YTIME-1) * 1e6)
        -
        sqrt(sqr(VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME)
        - (1 - imCapCostTechMin(allCy,DSBS,TECH,YTIME)) * imCapCostTech(allCy,DSBS,TECH,YTIME) * 1e-3
          * (V01NewRegPcTechYearly(allCy,TTECH,YTIME-1) * 1e6)))
      )$(TRANSE(DSBS) and sameas(DSBS,"PC"))
      / 2
      +
      sum(ITECH$(sameas(TECH,ITECH)), !!Industry subsidies and grants
        VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME) 
        + (1 - imCapCostTechMin(allCy,DSBS,ITECH,YTIME)) * V02CostTech(allCy,DSBS,ITECH,YTIME) * 1e3
        * ((V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) - V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)) * VmLft(allCy,DSBS,ITECH,YTIME))
        -
        sqrt(sqr(VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME) 
        - (1 - imCapCostTechMin(allCy,DSBS,ITECH,YTIME)) * V02CostTech(allCy,DSBS,ITECH,YTIME) * 1e3
        * ((V02EquipCapTechSubsec(allCy,DSBS,ITECH,YTIME) - V02RemEquipCapTechSubsec(allCy,DSBS,ITECH,YTIME)) * VmLft(allCy,DSBS,ITECH,YTIME))))
      )$INDSE(DSBS)
      / 2
    !!  +
    !!  sum(DACTECH$DACTECH(TECH), !!CDR subsidies and grants (V06GrossCapDAC is in annualized $/tCO2, so multiplied with lifetime)
     !!   VmSubsiDemTechAvail(allCy,"DAC",DACTECH,YTIME)
    !!    + V06LvlCostDAC(allCy,DACTECH,YTIME-1) * 1e-6 * imCapCostTechMin(allCy,"DAC",DACTECH,YTIME) *
    !!    (V06CapFacNewDAC(allCy,DACTECH,YTIME) * V06CapCDR(allCy,DACTECH,YTIME-1)) * VmLft(allCy,"DAC",DACTECH,YTIME)
    !!    -
    !!    sqrt(sqr(VmSubsiDemTechAvail(allCy,"DAC",DACTECH,YTIME)
    !!    - V06LvlCostDAC(allCy,DACTECH,YTIME-1) * 1e-6 * imCapCostTechMin(allCy,"DAC",DACTECH,YTIME) *
    !!    (V06CapFacNewDAC(allCy,DACTECH,YTIME) * V06CapCDR(allCy,DACTECH,YTIME-1)) * VmLft(allCy,"DAC",DACTECH,YTIME)))
    !!  ) / 2
      !!  +
       !! imGrantCapCostTech(DSBS,TECH) * 1e-6 *
      !!  (V06CapFacNewDAC(allCy,DACTECH,YTIME) * V06CapCDR(allCy,DACTECH,YTIME-1) + i06SchedNewCapDAC(allCy,DACTECH,YTIME)) *
      !!  VmLft(allCy,"DAC",DACTECH,YTIME)
    !!  )$sameas (DSBS,"DAC")
    !!  +
    !!  imSubsiCapCostFuel("HOU","ELC") * VmConsFuel(allCy,"HOU","ELC",YTIME) !!Residential electricity subsidies
;

$ontext
*' Inactive equation for supply-side subsidies to power generation and hydrogen
*' production. The power term uses new capacity, capital costs, availability and grants;
*' the hydrogen term uses production costs, demand, technology shares and grant
*' parameters.
Q11SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
      =E=
      sum(PGALL$sameas(PGALL,STECH),
        i04GrossCapCosSubRen(allCy,PGALL,YTIME) * imFacSubsiCapCostSupply(SSBS,STECH) *
        V04NewCapElec(allCy,PGALL,YTIME) * 1e3 / i04AvailRate(allCy,PGALL,YTIME)
        +
        imGrantCapCostSupply(SSBS,STECH) *
        V04NewCapElec(allCy,PGALL,YTIME) * 1e3 / i04AvailRate(allCy,PGALL,YTIME)
      )$sameas(SSBS,"PG")
      +
      sum(H2TECH$sameas(H2TECH,STECH),
        V05CostProdH2Tech(allCy,H2TECH,YTIME) *
        VmDemTotH2(allCy,YTIME) * (1 - V05ShareCCSH2Prod(allCy,H2TECH,YTIME)) * (1 - V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)) *
        imFacSubsiCapCostSupply(SSBS,STECH)
        +
        VmDemTotH2(allCy,YTIME) * (1 - V05ShareCCSH2Prod(allCy,H2TECH,YTIME)) * (1 - V05ShareNoCCSH2Prod(allCy,H2TECH,YTIME)) *
        imGrantCapCostSupply(SSBS,STECH)
      )$sameas(SSBS,"H2P")
;
$offtext
*' Defines the remaining subsidy-tax balance as the current subsidy budget less total
*' demand-side capital subsidies over eligible sector-technology pairs. The deduction for
*' supply-side subsidies is commented out.
Q11NetSubsiTax(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      VmNetSubsiTax(allCy,YTIME)
      =E=
        V11SubsiTot(allCy,YTIME) -
        sum((DSBS,TECH)$SECTTECH(DSBS,TECH),
          VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)
        )
!!        -
!!        sum((SSBS,STECH)$SSECTTECH(SSBS,STECH),
!!          VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
!!        )
;