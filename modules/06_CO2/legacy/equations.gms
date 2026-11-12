*' @title Equations of OPEN-PROM CO2 Sequestration and CDR
*' @code

*' GENERAL INFORMATION
*' These equations represent CO2 capture from power generation, hydrogen production,
*' and industry, together with cumulative capture, sequestration costs, and CDR
*' deployment.
*' CDR costs include technology-specific learning, energy requirements, subsidies,
*' and applicable CO2 storage charges.

*' * CO2 SEQUESTRATION COST CURVES

*' Calculates CO2 captured from fuel use in power generation, hydrogen production,
*' and industrial technologies with carbon capture, by sector, fuel, and year.
*' Fuel inputs are multiplied by the corresponding capture rates and CO2 emission
*' factors. A biomass-specific adjustment of 4.17 is included for BMSWAS.
Q06CO2CaptureCCS(allCy,SBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECtoEF(SBS,EFS))..
    V06CO2CaptureCCS(allCy,SBS,EFS,YTIME)
      =E=
    (
      sum(PGALL$(PGALLtoEF(PGALL,EFS) and CCS(PGALL)),
        i04ShareFuels(allCy,PGALL,EFS) *
        VmProdElec(allCy,PGALL,YTIME)* smTWhToMtoe /
        imPlantEffByType(allCy,PGALL,"effELC",YTIME) *
        V04CO2CaptRate(allCy,PGALL,YTIME)
      )$sameas("PG", SBS) +
      sum(H2TECH$(H2TECHtoFEEDSTOCK(H2TECH,EFS) or H2TECHtoENERGY(H2TECH,EFS)),
        VmProdH2(allCy,H2TECH,YTIME) *
        (i05InputOverOutH2ProdFeed(allCy,H2TECH,EFS,YTIME) + i05InputOverOutH2ProdEnergy(allCy,H2TECH,EFS,YTIME)) *
        V05CaptRateH2(allCy,H2TECH,YTIME)
      )$sameas("H2P", SBS) +
      sum(DSBS$sameas(DSBS,SBS),
        sum(CCSTECH$SECTTECH(DSBS,CCSTECH),
            i02ShareBlend(allCy,DSBS,CCSTECH,EFS,YTIME) *
            V02EquipCapTechSubsec(allcy,DSBS,CCSTECH,YTIME) *
            i02util(allCy,DSBS,CCSTECH,YTIME) *
            imCO2CaptRateIndustry(allCy,CCSTECH,YTIME)
        )
      )$INDSE1(SBS)
    ) *
    (imCo2EmiFac(allCy,SBS,EFS,YTIME) + 4.17$sameas("BMSWAS",EFS));

*' Accumulates captured CO2 over time for each country.
*' Adds current-year capture from the eligible sector-fuel combinations and
*' CDR capacity converted by a factor of 1e-6 to the previous cumulative total.
Q06CaptCummCO2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CaptCummCO2(allCy,YTIME)
      =E=
    V06CaptCummCO2(allCy,YTIME-1) +
    sum((SBS,EFS)$SECtoEF(SBS,EFS),V06CO2CaptureCCS(allCy,SBS,EFS,YTIME)) +
    sum(DACTECH,V06CapCDR(allCy,DACTECH,YTIME) * 1e-6);

*' Calculates the effective CO2 sequestration cost in US$2015 per tonne of CO2.
*' The physical cost follows a hyperbolic tangent curve between minimum and
*' maximum cost levels, driven by prior-year global cumulative CO2 capture.
*' The curve shape is controlled by sig_a and sig_b; the shared CCS availability
*' cost adder is applied separately and only once.
Q06CstCO2SeqCsts(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCstCO2SeqCsts(allCy,YTIME)
        =E=
   i06CO2SeqData("seq_min") +
   (i06CO2SeqData("seq_max") - i06CO2SeqData("seq_min")) / 2 *
   (1+tanh(i06CO2SeqData("sig_a") / (i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max")) * (V06CaptCummCO2Glob.L(YTIME-1) * 1e-3 - i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max")))) +
   i06CCSAvailabilityCostAdder(YTIME);

*' Calculates the gross capital cost of each CDR technology using a learning curve.
*' Costs decline with previous-year aggregate CDR capacity, subject to a
*' technology-specific minimum capital cost. The learning exponent corresponds
*' to a 2% cost reduction for each doubling of the capacity measure.
Q06GrossCapCDR(CDRTECH,YTIME)$(TIME(YTIME))..
    V06GrossCapCDR(CDRTECH,YTIME)
            =E=
    0.5 *
    (
      (i06GrossCapCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) +
      i06GrossCapCDRMin(CDRTECH) +
      sqrt(
        sqr(
          (i06GrossCapCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) -
          i06GrossCapCDRMin(CDRTECH)
        )
      )
    );

*' Calculates fixed operation and maintenance costs for each CDR technology.
*' The learning curve depends on previous-year aggregate technology capacity,
*' with a 2% reduction per doubling and a technology-specific minimum cost.
Q06FixOandMCDR(CDRTECH,YTIME)$(TIME(YTIME))..
    V06FixOandMCDR(CDRTECH,YTIME)
            =E=
    0.5 *
    (
      (i06FixOandMCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) +
      i06FixOandMCDRMin(CDRTECH) +
      sqrt(
        sqr(
          (i06FixOandMCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) -
          i06FixOandMCDRMin(CDRTECH)
        )
      )
    )
;

*' Calculates variable operation costs for each CDR technology.
*' Previous-year aggregate installed capacity determines learning effects,
*' while a technology-specific minimum prevents costs falling below the floor.
Q06VarCostCDR(CDRTECH,YTIME)$(TIME(YTIME))..
    V06VarCostCDR(CDRTECH,YTIME)
            =E=
    0.5 *
    (
      (i06VarCostCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) +
      i06VarCostCDRMin(CDRTECH) +
      sqrt(
        sqr(
          (i06VarCostCDR(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.98)/log(2))) -
          i06VarCostCDRMin(CDRTECH)
        )
      )
    )
;

*' Calculates the pre-subsidy levelized cost of CDR by country and technology.
*' Combines learned capital, fixed and variable costs, a fixed adjustment of 20,
*' electricity and natural gas requirements, and physical CO2 storage costs for DAC.
*' The shared CCS availability cost adder is excluded at this stage.
Q06LvlCostCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06LvlCostCDR(allCy,CDRTECH,YTIME)
            =E=
    V06GrossCapCDR(CDRTECH,YTIME) +
    V06FixOandMCDR(CDRTECH,YTIME) +
    V06VarCostCDR(CDRTECH,YTIME) - 20 +
    i06SpecElecCDR(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) +
    i06SpecHeatCDR(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","NGS",YTIME) / 0.85 +
    (VmCstCO2SeqCsts(allCy,YTIME) - i06CCSAvailabilityCostAdder(YTIME))$DACTECH(CDRTECH)
;

*' Calculates the full cost of CDR after technology-specific subsidies.
*' Subtracts DAC or enhanced-weathering subsidies as applicable, then adds the
*' shared CCS availability cost adder for DAC technologies in full.
Q06CostFullCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CostFullCDR(allCy,CDRTECH,YTIME)
        =E=
    V06LvlCostCDR(allCy,CDRTECH,YTIME)
    - VmSubsiDemTech(allCy,"DAC",CDRTECH,YTIME)$DACTECH(CDRTECH) - VmSubsiDemTech(allCy,"EW",CDRTECH,YTIME)$sameas("TEW",CDRTECH)
    + i06CCSAvailabilityCostAdder(YTIME)$DACTECH(CDRTECH)
;

*' Calculates a CDR profitability ratio by country, technology, and year.
*' Divides the current carbon value applicable to DAC by the previous-year
*' full CDR cost. Higher values indicate more favorable relative economics.
Q06ProfRateCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06ProfRateCDR(allCy,CDRTECH,YTIME)
        =E=
    sum(NAP$NAPtoALLSBS(NAP,"DAC"),VmCarVal(allCy,NAP,YTIME)) /
    V06CostFullCDR(allCy,CDRTECH,YTIME - 1)
;

*' Estimates the CDR deployment gap from previous-year net emissions.
*' A policy scaling factor and a smooth profitability response determine the gap.
*' The tanh response increases around a profitability ratio of 1.5.
Q06GapCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V06GapCDR(allCy,CDRTECH,YTIME)
      =E=
  S06EmissPercCDR * V07EmissionsNet(allCy,YTIME-1) * 1e6
  * (tanh(3 * (V06ProfRateCDR(allCy,CDRTECH,YTIME) - 1.5)) + 1) / 2
  ;

*' Determines the annual addition to CDR capacity for each technology and country.
*' Uses the deployment gap and a minimum addition proportional to last-year
*' capacity, with a technology-specific maturity factor applied to the result.
*' The square-root term implements an absolute-value adjustment in the formula.
Q06CapFacNewCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V06CapFacNewCDR(allCy,CDRTECH,YTIME)
      =E=
  (
  V06GapCDR(allCy,CDRTECH,YTIME) + S06CapFacMinNewCDR * V06CapCDR(allCy,CDRTECH,YTIME-1)
  +
  sqrt(sqr(
    V06GapCDR(allCy,CDRTECH,YTIME) - S06CapFacMinNewCDR * V06CapCDR(allCy,CDRTECH,YTIME-1)
  ))) / 2
  * i06MatFacCDR(CDRTECH);

*' Updates installed CDR capacity by adding the current-year capacity increment
*' to the installed capacity of the previous year.
Q06CapCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CapCDR(allCy,CDRTECH,YTIME)
      =E=
    (V06CapCDR(allCy,CDRTECH,YTIME-1) + V06CapFacNewCDR(allCy,CDRTECH,YTIME))
    ;

*' Calculates final fuel consumption associated with installed CDR capacity.
*' Natural gas and hydrogen heat inputs use the specific heat requirement
*' divided by 0.85, while electricity uses the specific electricity requirement.
*' The resulting fuel consumption is divided by 1e6.
Q06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)$(TIME(YTIME) $TECHtoEF(CDRTECH,EF) $(runCy(allCy)))..
    VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)
      =E=
    (
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatCDR(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'ngs')) +
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatCDR(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'H2F')) +
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecElecCDR(allCy,CDRTECH,YTIME))$(sameas(EF, 'elc'))
    ) / 1e6;
