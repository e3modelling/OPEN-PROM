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
Q06CapCO2ElecHydr(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CapCO2ElecHydr(allCy,YTIME)
         =E=
         sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                 VmProdElec(allCy,CCS,YTIME)*smTWhToMtoe/imPlantEffByType(allCy,CCS,YTIME)*
                 imCo2EmiFac(allCy,"PG",PGEF,YTIME)*imCO2CaptRate(allCy,CCS,YTIME)))
                + 
         (sum(EF, sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),
               VmConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)*imCo2EmiFac(allCy,"H2P",EF,YTIME)*i05CaptRateH2Prod(allCy,H2TECH,YTIME)))
          ) !! CO2 emissions captured by plants producing hydrogen
                +
            (
              sum(DACTECH,V06CapDAC(allCy,DACTECH,YTIME)) / 1e6
            )
          ;   


*' The equation calculates the cumulative CO2 captured in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
Q06CaptCummCO2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CaptCummCO2(allCy,YTIME) =E= V06CaptCummCO2(allCy,YTIME-1)+V06CapCO2ElecHydr(allCy,YTIME-1);   

*' The equation computes the transition weight from a linear to exponential CO2 sequestration
*' cost curve for a specific scenario and year. The transition weight is determined based on the cumulative CO2 captured
*' and parameters defining the transition characteristics.The transition weight is calculated using a logistic function.
*' This equation provides a mechanism to smoothly transition from a linear to exponential cost curve based on the cumulative CO2 captured, allowing
*' for a realistic representation of the cost dynamics associated with CO2 sequestration. The result represents the weight for
*' the transition in the specified scenario and year.
Q06TrnsWghtLinToExp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06TrnsWghtLinToExp(allCy,YTIME)
         =E=
         1/(1+exp(-i06ElastCO2Seq(allCy,"mc_s")*( V06CaptCummCO2(allCy,YTIME)/i06ElastCO2Seq(allCy,"pot")-i06ElastCO2Seq(allCy,"mc_m")))); 

*' The equation calculates the cost curve for CO2 sequestration costs in Euro per ton of CO2 sequestered
*' for a specific scenario and year. The cost curve is determined based on cumulative CO2 captured and
*' elasticities for the CO2 sequestration cost curve.The equation is formulated to represent a flexible cost curve that
*' can transition from linear to exponential. The transition is controlled by the weight for the transition from linear to exponential
*' The cost curve is expressed as a combination of linear and exponential functions, allowing for a realistic.
*' representation of the relationship between cumulative CO2 captured and sequestration costs. This equation provides a dynamic and
*' realistic approach to modeling CO2 sequestration costs, considering the cumulative CO2 captured and the associated elasticities
*' for the cost curve. The result represents the cost of sequestering one ton of CO2 in the specified scenario and year.
Q06CstCO2SeqCsts(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VmCstCO2SeqCsts(allCy,YTIME) =E=
       (1-V06TrnsWghtLinToExp(allCy,YTIME))*(i06ElastCO2Seq(allCy,"mc_a")*V06CaptCummCO2(allCy,YTIME)+i06ElastCO2Seq(allCy,"mc_b"))+
       V06TrnsWghtLinToExp(allCy,YTIME)*(i06ElastCO2Seq(allCy,"mc_c")*exp(i06ElastCO2Seq(allCy,"mc_d")*V06CaptCummCO2(allCy,YTIME)));           


Q06GrossCapDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06GrossCapDAC(allCy,DACTECH,YTIME)
                  =E=         
          0.5 * 
          (
            (i06GrossCapDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) +
            i06GrossCapDACMin(allCy,DACTECH) +
            sqrt(
              sqr(
                (i06GrossCapDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) - i06GrossCapDACMin(allCy,DACTECH)
              )
            )
          )
;

Q06FixOandMDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06FixOandMDAC(allCy,DACTECH,YTIME)
                  =E=         
          0.5 * 
          (
            (i06FixOandMDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) +
            i06FixOandMDACMin(allCy,DACTECH) +
            sqrt(
              sqr(
                (i06FixOandMDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) - i06FixOandMDACMin(allCy,DACTECH)
              )
            )
          )
;

Q06VarCostDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06VarCostDAC(allCy,DACTECH,YTIME)
                  =E=         
          0.5 * 
          (
            (i06VarCostDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) +
            i06VarCostDACMin(allCy,DACTECH) +
            sqrt(
              sqr(
                (i06VarCostDAC(allCy,DACTECH) * V06CapDAC(allCy,DACTECH,YTIME-1) ** (log(0.7)/log(2))) - i06VarCostDACMin(allCy,DACTECH)
              )
            )
          )
;

*' The equation calculates the Levelized Costs of DAC capacity, also taking into account its discount rate and life expectancy, 
*' for each region (country) and year.
Q06LvlCostDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06LvlCostDAC(allCy,DACTECH,YTIME)
                  =E=         
          V06GrossCapDAC(allCy,DACTECH,YTIME) + V06FixOandMDAC(allCy,DACTECH,YTIME) +  V06VarCostDAC(allCy,DACTECH,YTIME)
;

*' The equation estimates the profitability of DAC capacity, calculating the rate between levelized costs (CAPEX, fixed and electricity needs)
*' and revenues/avoided costs (carbon values, carbon subsidies) regionally.
Q06ProfRateDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06ProfRateDAC(allCy,DACTECH,YTIME)
         =E=
          (sum(NAP$NAPtoALLSBS(NAP,"DAC"),VmCarVal(allCy,NAP,YTIME)) + i06SubsDAC(allCy,DACTECH,YTIME)) / 
          (V06LvlCostDAC(allCy,DACTECH,YTIME) + i06SpecElecDAC(allCy,DACTECH,YTIME) * VmPriceElecIndResConsu(allCy,"i",YTIME-1) + i06SpecHeatDAC(allCy,DACTECH,YTIME) * VmPriceFuelSubsecCHP(allCy,"IS","NGS",YTIME-1) / 0.85)
;

*' The equation estimates the annual increase rate of DAC capacity regionally.
Q06CapFacNewDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CapFacNewDAC(allCy,DACTECH,YTIME)
         =E=
          (
            ((exp(S06MatFacDAC * V06ProfRateDAC(allCy,DACTECH,YTIME) - 1)) /
           exp(S06MatFacDAC * S06ProfRateMaxDAC - 1))
          ) *
          (S06CapFacMaxNewDAC - S06CapFacMinNewDAC) +
          S06CapFacMinNewDAC
;

*' The equation calculates the DAC installed capacity annually and regionally.
Q06CapDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06CapDAC(allCy,DACTECH,YTIME)
         =E=
          V06CapDAC(allCy,DACTECH,YTIME-1) * (1 + V06CapFacNewDAC(allCy,DACTECH,YTIME))
;

*' The equation calculates the electricity consumed by the DAC installed capacity annually and regionally (MWh).
Q06ElecDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06ElecDAC(allCy,DACTECH,YTIME)
         =E=
          V06CapDAC(allCy,DACTECH,YTIME) * i06SpecElecDAC(allCy,DACTECH,YTIME)
;

*' The equation calculates the Natural Gas consumed by the DAC installed capacity annually and regionally (MWh).
Q06NGDAC(allCy,DACTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         V06NGDAC(allCy,DACTECH,YTIME)
         =E=
          V06CapDAC(allCy,DACTECH,YTIME) * i06SpecHeatDAC(allCy,DACTECH,YTIME) / 0.85
;

*' The equation calculates the fuels consumed by the DAC installed capacity annually and regionally.
Q06ConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)$(TIME(YTIME) $DACTECHEF(EF) $(runCy(allCy)))..
         VmConsFuelTechDACProd(allCy,DACTECH,EF,YTIME)
         =E=
         (
          V06NGDAC(allCy,DACTECH,YTIME)$(sameas(EF, 'ngs'))
         + V06ElecDAC(allCy,DACTECH,YTIME)$(sameas(EF, 'elc')) 
         )
         / 1e6
         * smTWhToMtoe
;

Q06ConsFuelDACProd(allCy,EF,YTIME)$(TIME(YTIME) $DACTECHEF(EF) $(runCy(allCy)))..
         VmConsFuelDACProd(allCy,EF,YTIME)
         =E=
         sum(DACTECH$DACTECHEFtoEF(DACTECH,EF),VmConsFuelTechDACProd(allCy,DACTECH,EF,YTIME))
;