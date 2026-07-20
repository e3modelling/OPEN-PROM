*' @title Equations of OPEN-PROMs CO2 SEQUESTRATION COST CURVES
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * CO2 SEQUESTRATION COST CURVES

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
      sum(H2TECH$H2TECHEFtoEF(H2TECH,EFS),
        VmConsFuelTechH2Prod(allCy,H2TECH,EFS,YTIME) *
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

*' The equation calculates the cumulative CO2 captured in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
Q06CaptCummCO2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CaptCummCO2(allCy,YTIME) 
      =E= 
    V06CaptCummCO2(allCy,YTIME-1) +
    sum((SBS,EFS)$SECtoEF(SBS,EFS),V06CO2CaptureCCS(allCy,SBS,EFS,YTIME)) +
    sum(DACTECH,V06CapCDR(allCy,DACTECH,YTIME) * 1e-6);   

Q06CaptCummCO2Glob(YTIME)$(TIME(YTIME))..
    V06CaptCummCO2Glob(YTIME) 
      =E= 
    sum(allCy$runCy(allCy),V06CaptCummCO2(allCy,YTIME));

*' The equation calculates the CO2 sequestration cost in Euro per ton of CO2 sequestered for a given scenario 
*' and year. The cost curve is determined based on global cumulative CO2 captured and sequestration cost parameters.
*' The cost curve transitions smoothly from a minimum to a maximum cost using a hyperbolic tangent function, 
*' representing a realistic relationship between cumulative CO2 captured and sequestration costs. The transition 
*' behavior is controlled by shape parameters that define the steepness and midpoint of the cost curve. This 
*' equation provides a dynamic approach to modeling CO2 sequestration costs, reflecting increasing costs as 
*' cumulative CO2 captured expands. The result represents the cost of sequestering one ton of CO2 in the 
*' specified scenario and year.
Q06CstCO2SeqCsts(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCstCO2SeqCsts(allCy,YTIME) 
        =E=
   i06CO2SeqData("seq_min") + 
   (i06CO2SeqData("seq_max") - i06CO2SeqData("seq_min")) / 2 *
   (1+tanh(i06CO2SeqData("sig_a") / (i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max")) * (V06CaptCummCO2Glob(YTIME) * 1e-3 - i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max"))));           

*' The equation calculates the CAPEX of each CDR technology, as it's affected by a learning curve ($/tCO2).
Q06GrossCapCDR(CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
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

*' The equation calculates the fixed and O&M costs of each CDR technology, as they are affected by a learning curve.
Q06FixOandMCDR(CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
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

*' The equation calculates the variable costs of each CDR technology including the CO2 storage costs, as they are affected by a learning curve.
Q06VarCostCDR(CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
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

*' The equation calculates the Levelized Costs of CDR capacity, also taking into account its discount rate and life expectancy, 
*' for each region (country) and year.
Q06LvlCostCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06LvlCostCDR(allCy,CDRTECH,YTIME)
            =E=         
    V06GrossCapCDR(CDRTECH,YTIME) +
    V06FixOandMCDR(CDRTECH,YTIME) + 
    V06VarCostCDR(CDRTECH,YTIME) - 20 +
    i06SpecElecCDR(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) +
    i06SpecHeatCDR(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","NGS",YTIME) / 0.85 +
    VmCstCO2SeqCsts(allCy,YTIME)$(not sameas("TEW", CDRTECH))
;

*' The equation calculates the Levelized Costs of CDR capacity, also taking into account its subsidy, for each region (country) and year.
Q06CostFullCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CostFullCDR(allCy,CDRTECH,YTIME)
        =E=         
    V06LvlCostCDR(allCy,CDRTECH,YTIME)
    - VmSubsiDemTech(allCy,"DAC",CDRTECH,YTIME)$DACTECH(CDRTECH) - VmSubsiDemTech(allCy,"EW",CDRTECH,YTIME)$sameas("TEW",CDRTECH)
;

*' The equation estimates the profitability of CDR capacity, calculating the rate between levelized costs (CAPEX, fixed and fuel needs)
*' and revenues/avoided costs (carbon values, carbon subsidies) regionally.
Q06ProfRateCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06ProfRateCDR(allCy,CDRTECH,YTIME)
        =E=
    sum(NAP$NAPtoALLSBS(NAP,"DAC"),VmCarVal(allCy,NAP,YTIME)) /
    V06CostFullCDR(allCy,CDRTECH,YTIME - 1)
;

*' The equation estimates the CDR deployment gap for each region, technology and year based on previous-year net emissions
*' and the profitability rate of CDR technologies. The emissions term is scaled by a policy parameter and transformed
*' through a smooth hyperbolic tangent function,
*' so profitability above a threshold increases deployment pressure while lower profitability keeps the gap close to zero.
*' This gap is subsequently used to determine the annual increase in CDR capacity.
Q06GapCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V06GapCDR(allCy,CDRTECH,YTIME)
      =E=
  S06EmissPercCDR * V07EmissionsNet(allCy,YTIME-1) * 1e6
  * (tanh(3 * (V06ProfRateCDR(allCy,CDRTECH,YTIME) - 1.5)) + 1) / 2
  ;


* The equation determines the annual growth rate of new DAC capacity by region and technology. 
* The growth rate is modeled as a smooth S-shaped (tanh) function of the profitability rate, 
* scaled by the maximum allowable expansion factor and adjusted by a technology-specific 
* maturity factor. This formulation captures the idea that as DAC technologies become more profitable,
* their growth rate will accelerate, but will eventually level off as they reach market saturation or face other constraints.
*'It also chooses the higher between the gap and a minimum growth rate based on last year's capacity.
*'The maturity factor allows for differentiation between technologies based on their readiness and potential for rapid deployment.
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

*' The equation calculates the CDR installed capacity annually and regionally.
Q06CapCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CapCDR(allCy,CDRTECH,YTIME)
      =E=
    (V06CapCDR(allCy,CDRTECH,YTIME-1) + V06CapFacNewCDR(allCy,CDRTECH,YTIME))
    ;

*' The equation calculates the different fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)$(TIME(YTIME) $TECHtoEF(CDRTECH,EF) $(runCy(allCy)))..
    VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)
      =E=
    (
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatCDR(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'ngs')) +
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatCDR(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'H2F')) +
      (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecElecCDR(allCy,CDRTECH,YTIME))$(sameas(EF, 'elc')) 
    ) / 1e6;
