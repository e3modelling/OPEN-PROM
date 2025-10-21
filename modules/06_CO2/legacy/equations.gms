*' @title Equations of OPEN-PROMs CO2 SEQUESTRATION COST CURVES
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * CO2 SEQUESTRATION COST CURVES

*' The equation calculates the CO2 captured by electricity and hydrogen production plants
*' in million tons of CO2 for a specific scenario and year. The CO2 capture is determined by summing 
*' the product of electricity production from plants with carbon capture and storage, the conversion
*' factor from terawatt-hours to million tons of oil equivalent (smTWhToMtoe), the plant efficiency,
*' the CO2 emission factor, and the plant CO2 capture rate. 
Q06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME)
      =E=
    (
      sum(PGEF,
        sum(CCS$PGALLtoEF(CCS,PGEF),
          VmProdElec(allCy,CCS,YTIME) * smTWhToMtoe /
          imPlantEffByType(allCy,CCS,YTIME) *
          imCo2EmiFac(allCy,"PG",PGEF,YTIME) *
          V04CO2CaptRate(allCy,CCS,YTIME)
        )
      )
    )$sameas("PG", CO2CAPTECH) +
    (
      sum(EF, 
        sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),
          VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME) *
          imCo2EmiFac(allCy,"H2P",EF,YTIME) *
          V05CaptRateH2(allCy,H2TECH,YTIME)
        )
      )
      !! CO2 emissions captured by plants producing hydrogen
    )$sameas("H2P", CO2CAPTECH) +
    (
      sum(DACTECH,
        V06CapDAC(allCy,DACTECH,YTIME)
      ) * 1e-6
    )$sameas("DAC", CO2CAPTECH) +
    (
      sum(DSBS,
        sum(CCSTECH$SECTTECH(DSBS,CCSTECH),
          sum(EF$ITECHtoEF(CCSTECH,EF),
            i02Share(allCy,DSBS,CCSTECH,EF,YTIME) * 
            V02EquipCapTechSubsec(allcy,DSBS,CCSTECH,YTIME) * 
            i02util(allCy,DSBS,CCSTECH,YTIME) * 
            imCO2CaptRateIndustry(allCy,CCSTECH,YTIME) * 
            imCo2EmiFac(allCy,DSBS,EF,YTIME)
          )
        )
      )
    )$sameas("IND", CO2CAPTECH)
    ;   

*' The equation calculates the cumulative CO2 captured in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
Q06CaptCummCO2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06CaptCummCO2(allCy,YTIME) 
      =E= 
    V06CaptCummCO2(allCy,YTIME-1) +
    SUM(CO2CAPTECH,
      V06CapCO2ElecHydr(allCy,CO2CAPTECH,YTIME-1)
    )
 ;   

*' The equation computes the transition weight from a linear to exponential CO2 sequestration
*' cost curve for a specific scenario and year. The transition weight is determined based on the cumulative CO2 captured
*' and parameters defining the transition characteristics.The transition weight is calculated using a logistic function.
*' This equation provides a mechanism to smoothly transition from a linear to exponential cost curve based on the cumulative CO2 captured, allowing
*' for a realistic representation of the cost dynamics associated with CO2 sequestration. The result represents the weight for
*' the transition in the specified scenario and year.
Q06TrnsWghtLinToExp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06TrnsWghtLinToExp(allCy,YTIME)
        =E=
    0.6;
$ontext
    1 /
    (1 + exp(-i06ElastCO2Seq(allCy,"mc_s") * (V06CaptCummCO2(allCy,YTIME)*1e3 /i06ElastCO2Seq(allCy,"pot")-i06ElastCO2Seq(allCy,"mc_m")))); 
$offtext
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
    !! linear component
    V06TrnsWghtLinToExp(allCy,YTIME) * 
    i06ElastCO2Seq(allCy,"mc_b") +
    !! exponential component
    (1-V06TrnsWghtLinToExp(allCy,YTIME)) *
    i06ElastCO2Seq(allCy,"mc_b") *
    exp(V06CaptCummCO2(allCy,YTIME) / i06ElastCO2Seq(allCy,"mc_d"));           

*' The equation calculates the CAPEX of each DAC technology, as it's affected by a learning curve.
Q06GrossCapDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V06GrossCapDAC(DACTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06GrossCapDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06GrossCapDACMin(DACTECH) +
      sqrt(
        sqr(
          (i06GrossCapDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06GrossCapDACMin(DACTECH)
        )
      )
    )
;

*' The equation calculates the fixed and O&M costs of each DAC technology, as they are affected by a learning curve.
Q06FixOandMDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V06FixOandMDAC(DACTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06FixOandMDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06FixOandMDACMin(DACTECH) +
      sqrt(
        sqr(
          (i06FixOandMDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06FixOandMDACMin(DACTECH)
        )
      )
    )
;

*' The equation calculates the variable costs of each DAC technology including the CO2 storage costs, as they are affected by a learning curve.
Q06VarCostDAC(DACTECH,YTIME)$(TIME(YTIME))..
    V06VarCostDAC(DACTECH,YTIME)
            =E=         
    0.5 * 
    (
      (i06VarCostDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) +
      i06VarCostDACMin(DACTECH) +
      sqrt(
        sqr(
          (i06VarCostDAC(DACTECH) * (sum(allCy$runCyL(allCy),V06CapDAC(allCy,DACTECH,YTIME-1))) ** (log(0.97)/log(2))) -
          i06VarCostDACMin(DACTECH)
        )
      )
    )
;

*' The equation calculates the Levelized Costs of DAC capacity, also taking into account its discount rate and life expectancy, 
*' for each region (country) and year.
Q06LvlCostDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06LvlCostDAC(allCy,DACTECH,YTIME)
        =E=         
    V06GrossCapDAC(DACTECH,YTIME) + 
    V06FixOandMDAC(DACTECH,YTIME) + 
    V06VarCostDAC(DACTECH,YTIME) - 20 +
    i06SpecElecDAC(allCy,DACTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME) +
    i06SpecHeatDAC(allCy,DACTECH,YTIME) * VmPriceFuelSubsecCarVal(allCy,"OI","NGS",YTIME) / 0.85 +
    VmCstCO2SeqCsts(allCy,YTIME)
;

*' The equation estimates the profitability of DAC capacity, calculating the rate between levelized costs (CAPEX, fixed and fuel needs)
*' and revenues/avoided costs (carbon values, carbon subsidies) regionally.
Q06ProfRateDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V06ProfRateDAC(allCy,DACTECH,YTIME)
        =E=
    (i06SubsFacDAC(DACTECH) * sum(NAP$NAPtoALLSBS(NAP,"DAC"),VmCarVal(allCy,NAP,YTIME))) / 
    V06LvlCostDAC(allCy,DACTECH,YTIME - 1)
;

*' The equation estimates the annual increase rate of DAC capacity regionally, according to the maturity and profitability of each technology.
Q06CapFacNewDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CapFacNewDAC(allCy,DACTECH,YTIME)
         =E=
          (
            (exp(i06MatFacDAC(DACTECH) * V06ProfRateDAC(allCy,DACTECH,YTIME) - 1)) /
           (exp(i06MatFacDAC(DACTECH) * S06ProfRateMaxDAC - 1))
          ) *
          (S06CapFacMaxNewDAC - S06CapFacMinNewDAC) +
          S06CapFacMinNewDAC
;

*' The equation calculates the DAC installed capacity annually and regionally,
*' adding capacity based on the maturity of the technology, as well as given capacities of actual scheduled DAC units.
Q06CapDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CapDAC(allCy,DACTECH,YTIME)
         =E=
          V06CapDAC(allCy,DACTECH,YTIME-1) * (1 + V06CapFacNewDAC(allCy,DACTECH,YTIME)) +
          i06SchedNewCapDAC(allCy,DACTECH,YTIME)
;

*' The equation calculates the different fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)$(TIME(YTIME) $TECHtoEF(DACTECH,EF) $(runCy(allCy)))..
         VmConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)
         =E=
         (
          (V06CapDAC(allCy,DACTECH,YTIME) * i06SpecHeatDAC(allCy,DACTECH,YTIME) / 0.85)$(sameas(EF, 'ngs')) +
          (V06CapDAC(allCy,DACTECH,YTIME) * i06SpecHeatDAC(allCy,DACTECH,YTIME) / 0.85)$(sameas(EF, 'H2F')) +
          (V06CapDAC(allCy,DACTECH,YTIME) * i06SpecElecDAC(allCy,DACTECH,YTIME))$(sameas(EF, 'elc')) 
         )
         / 1e6
;

*' The equation calculates the different fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelDACProd(allCy,EF,YTIME)$(TIME(YTIME) $(runCy(allCy)))..
    VmConsFuelDACProd(allCy,EF,YTIME)
        =E=
    sum(DACTECH$TECHtoEF(DACTECH,EF),VmConsFuelTechDACProd(allCy,DACTECH,EF,YTIME))
;