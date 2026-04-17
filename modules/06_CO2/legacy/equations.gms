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
    sum(CDRTECH,V06CapCDR(allCy,CDRTECH,YTIME) * 1e-6);   

Q06CaptCummCO2Glob(YTIME)$(TIME(YTIME))..
    V06CaptCummCO2Glob(YTIME) 
      =E= 
    sum(allCy$runCy(allCy),V06CaptCummCO2(allCy,YTIME));

*' The equation calculates the cost curve for CO2 sequestration costs in Euro per ton of CO2 sequestered
*' for a specific scenario and year. The cost curve is determined based on cumulative CO2 captured and
*' elasticities for the CO2 sequestration cost curve.The equation is formulated to represent a flexible cost curve that
*' can transition from linear to exponential. The transition is controlled by the weight for the transition from linear to exponential
*' The cost curve is expressed as a combination of linear and exponential functions, allowing for a realistic.
*' representation of the relationship between cumulative CO2 captured and sequestration costs. This equation provides a dynamic and
*' realistic approach to modeling CO2 sequestration costs, considering the cumulative CO2 captured and the associated elasticities
*' for the cost curve. The result represents the cost of sequestering one ton of CO2 in the specified scenario and year.
Q06CstCO2SeqCsts(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCstCO2SeqCsts(allCy,YTIME) 
        =E=
   i06CO2SeqData("seq_min") + 
   (i06CO2SeqData("seq_max") - i06CO2SeqData("seq_min")) / 2 *
   (1+tanh(i06CO2SeqData("sig_a") / (i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max")) * (V06CaptCummCO2Glob(YTIME) * 1e-3 - i06CO2SeqData("sig_b") * i06CO2SeqData("seq_max"))));           

*' The equation calculates the CAPEX of each DAC technology, as it's affected by a learning curve ($/tCO2).
Q06GrossCapDAC(CDRTECH,YTIME)$(TIME(YTIME))..
    V06GrossCapDAC(CDRTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06GrossCapDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06GrossCapDACMin(CDRTECH) +
      sqrt(
        sqr(
          (i06GrossCapDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06GrossCapDACMin(CDRTECH)
        )
      )
    );

*' The equation calculates the fixed and O&M costs of each DAC technology, as they are affected by a learning curve.
Q06FixOandMDAC(CDRTECH,YTIME)$(TIME(YTIME))..
    V06FixOandMDAC(CDRTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06FixOandMDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06FixOandMDACMin(CDRTECH) +
      sqrt(
        sqr(
          (i06FixOandMDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06FixOandMDACMin(CDRTECH)
        )
      )
    )
;

*' The equation calculates the variable costs of each DAC technology including the CO2 storage costs, as they are affected by a learning curve.
Q06VarCostDAC(CDRTECH,YTIME)$(TIME(YTIME))..
    V06VarCostDAC(CDRTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06VarCostDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06VarCostDACMin(CDRTECH) +
      sqrt(
        sqr(
          (i06VarCostDAC(CDRTECH) * (sum(allCy$runCyL(allCy),V06CapCDR(allCy,CDRTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06VarCostDACMin(CDRTECH)
        )
      )
    )
;

*' The equation calculates the Levelized Costs of DAC capacity, also taking into account its discount rate and life expectancy, 
*' for each region (country) and year.
Q06LvlCostDAC(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06LvlCostDAC(allCy,CDRTECH,YTIME)
        =E=         
    V06GrossCapDAC(CDRTECH,YTIME)
    - VmSubsiDemTech(allCy,"DAC",CDRTECH,YTIME)$DACTECH(CDRTECH) - VmSubsiDemTech(allCy,"EW",CDRTECH,YTIME)$sameas("TEW",CDRTECH) +
    V06FixOandMDAC(CDRTECH,YTIME) + 
    V06VarCostDAC(CDRTECH,YTIME) - 20 +
    i06SpecElecDAC(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) +
    i06SpecHeatDAC(allCy,CDRTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","NGS",YTIME) / 0.85 +
    VmCstCO2SeqCsts(allCy,YTIME)$(not sameas("TEW", CDRTECH))
;

*' The equation estimates the profitability of DAC capacity, calculating the rate between levelized costs (CAPEX, fixed and fuel needs)
*' and revenues/avoided costs (carbon values, carbon subsidies) regionally.
Q06ProfRateDAC(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06ProfRateDAC(allCy,CDRTECH,YTIME)
        =E=
    sum(NAP$NAPtoALLSBS(NAP,"DAC"),VmCarVal(allCy,NAP,YTIME)) /
    V06LvlCostDAC(allCy,CDRTECH,YTIME - 1)
;

* The equation determines the annual growth rate of new DAC capacity by region and technology. 
* The growth rate is modeled as a smooth S-shaped (tanh) function of the profitability rate, 
* scaled by the maximum allowable expansion factor and adjusted by a technology-specific 
* maturity factor. This formulation captures the idea that as DAC technologies become more profitable,
* their growth rate will accelerate, but will eventually level off as they reach market saturation or face other constraints.
*'The maturity factor allows for differentiation between technologies based on their readiness and potential for rapid deployment.
Q06CapFacNewDAC(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V06CapFacNewDAC(allCy,CDRTECH,YTIME)
      =E=
  S06CapFacMaxNewDAC
  * (tanh(2 * (V06ProfRateDAC(allCy,CDRTECH,YTIME) - 1.2)) + 1) / 2
  * (tanh(0.3 * (100 * V07EmissionsNetPart(allCy,YTIME) - 5)) + 1) / 2
  * i06MatFacDAC(CDRTECH) + 1e-6;

*' The equation calculates the DAC installed capacity annually and regionally,
*' adding capacity based on the maturity of the technology, as well as given capacities of actual scheduled DAC units.
Q06CapCDR(allCy,CDRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
          V06CapCDR(allCy,CDRTECH,YTIME)
            =E=
          V06CapCDR(allCy,CDRTECH,YTIME-1) * (1 + V06CapFacNewDAC(allCy,CDRTECH,YTIME)) +
          i06SchedNewCapDAC(allCy,CDRTECH,YTIME);

*' The equation calculates the different fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)$(TIME(YTIME) $TECHtoEF(CDRTECH,EF) $(runCy(allCy)))..
    VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)
      =E=
    (
    (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatDAC(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'ngs')) +
    (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecHeatDAC(allCy,CDRTECH,YTIME) / 0.85)$(sameas(EF, 'H2F')) +
    (V06CapCDR(allCy,CDRTECH,YTIME) * i06SpecElecDAC(allCy,CDRTECH,YTIME))$(sameas(EF, 'elc')) 
    ) / 1e6;

*' The equation calculates the different fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelCDRProd(allCy,EF,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    VmConsFuelCDRProd(allCy,EF,YTIME)
        =E=
    sum(CDRTECH$TECHtoEF(CDRTECH,EF),VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME));