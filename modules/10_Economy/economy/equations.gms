*' @title Equations of OPEN-PROMs Economy module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Economy module

*' The equation computes the total state revenues from carbon taxes, as the product of all fuel consumption in all subsectors of the supply side,
*' along with the relevant fuel emission factor, and the carbon tax posed regionally that year. This is added to the 0.5% of the GDP,
*' which is assumed to be used by each state for green subsidies.
Q10SubsiTot(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V10SubsiTot(allCy,YTIME)
        =E=
        (
          sum(EF$EFS(EF),
            VmConsFinEneCountry(allCy, EF, YTIME) * !!add the supply emissions
            imCo2EmiFac(allCy,"PG", EF, YTIME))
          -
          sum(CO2CAPTECH,
          V06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME))
        ) *
        sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME)) +
        0.005 * i01GDP(YTIME,allCy) * 1000
;

*' The equation splits the available state grants to the various technologies through a policy parameter expressing this proportional division.
*' The resulting amount (in Millions US$2015) is going to be implemented to the cost calculation of each subsided technology.
Q10SubsiTech(allCy,TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmSubsiTech(allCy,TECH,YTIME)
        =E=
        V10SubsiTot(allCy,YTIME-1) * i10SubsiPerTech(allCy,TECH,YTIME)
;

*' Subsidies in demand (Millions US$2015)
Q10SubsiCapCostTech(allCy,DSBS,TECH,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECTTECH(DSBS,TECH))..
      VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)
      =E=
      ( !!Transport subsidies and grants
        (imCapCostTech(allCy,DSBS,TECH,YTIME) * imFacSubsiCapCostTech(DSBS,TECH)) * 1e-3 *
        (V01StockPcYearlyTech(allCy,"TELC",YTIME) - V01StockPcYearlyTech(allCy,"TELC",YTIME-1)) * 1e6
        +
        imGrantCapCostTech(DSBS,TECH) * 1e-3 *
        (V01StockPcYearlyTech(allCy,"TELC",YTIME) - V01StockPcYearlyTech(allCy,"TELC",YTIME-1)) * 1e6
      )$(TRANSE(DSBS) and sameas (TECH,"TELC"))
      +
      sum(ITECH$sameas(ITECH,TECH), !!Industry subsidies and grants
        imCapCostTech(allCy,DSBS,ITECH,YTIME) * 1e3 *
        imFacSubsiCapCostTech(DSBS,TECH) *
        (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME)) / 
        (imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) * i02util(allCy,DSBS,ITECH,YTIME))
        +
        imGrantCapCostTech(DSBS,TECH) *
        (V02ShareTechNewEquipUseful(allCy,DSBS,ITECH,YTIME) * V02GapUsefulDemSubsec(allCy,DSBS,YTIME)) / 
        (imUsfEneConvSubTech(allCy,DSBS,ITECH,YTIME) * i02util(allCy,DSBS,ITECH,YTIME))
      )$INDSE(DSBS)
      +
      sum(DACTECH$DACTECH(TECH), !!CDR subsidies and grants (V06GrossCapDAC is in annualized $/tCO2, so multiplied with lifetime)
        V06GrossCapDAC(DACTECH,YTIME) * 1e-6 *
        imFacSubsiCapCostTech("DAC",DACTECH) *
        (V06CapFacNewDAC(allCy,DACTECH,YTIME) * V06CapDAC(allCy,DACTECH,YTIME-1) + i06SchedNewCapDAC(allCy,DACTECH,YTIME)) *
        VmLft(allCy,"DAC",DACTECH,YTIME)
        +
        imGrantCapCostTech(DSBS,TECH) * 1e-6 *
        (V06CapFacNewDAC(allCy,DACTECH,YTIME) * V06CapDAC(allCy,DACTECH,YTIME-1) + i06SchedNewCapDAC(allCy,DACTECH,YTIME)) *
        VmLft(allCy,"DAC",DACTECH,YTIME)
      )$sameas (DSBS,"DAC")
      +
      imSubsiCapCostFuel("HOU","ELC") * VmConsFuel(allCy,"HOU","ELC",YTIME) !!Residential electricity subsidies
      +
      (imSubsiCapCostFuel(DSBS,"ELC") * VmConsFuel(allCy,DSBS,"ELC",YTIME)
       )$INDSE(DSBS) !!Industrial electricity subsidies
;

*' Subsidies in supply (Millions US$2015)
Q10SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
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

*'This equation calculated the difference between the state revenues by collected carbon taxes, and the green grants and subsidies given in
*'both the supply and demand sectors.
Q10NetSubsiTax(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
      VmNetSubsiTax(allCy,YTIME)
      =E=
        V10SubsiTot(allCy,YTIME) -
        sum((DSBS,TECH)$SECTTECH(DSBS,TECH),
          VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)
        ) -
        sum((SSBS,STECH)$SSECTTECH(SSBS,STECH),
          VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
        )
;       