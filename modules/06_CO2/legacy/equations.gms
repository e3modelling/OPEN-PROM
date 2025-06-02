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
*' factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), the plant efficiency,
*' the CO2 emission factor, and the plant CO2 capture rate. 
QCapCO2ElecHydr(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapCO2ElecHydr(allCy,YTIME)
         =E=
         sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                 MVProdElec(allCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(allCy,CCS,YTIME)*
                 iCo2EmiFac(allCy,"PG",PGEF,YTIME)*iCO2CaptRate(allCy,CCS,YTIME)))
                + 
         (sum(EF, sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),
               MVConsFuelTechH2Prod(allCy,H2TECH,EF,YTIME)*iCo2EmiFac(allCy,"PG",EF,YTIME)*iCaptRateH2Prod(allCy,H2TECH,YTIME)))
          )  ;    !! CO2 emissions captured by plants producing hydrogen


*' The equation calculates the cumulative CO2 captured in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
QCaptCummCO2(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCaptCummCO2(allCy,YTIME) =E= VCaptCummCO2(allCy,YTIME-1)+VCapCO2ElecHydr(allCy,YTIME-1);   

*' The equation computes the transition weight from a linear to exponential CO2 sequestration
*' cost curve for a specific scenario and year. The transition weight is determined based on the cumulative CO2 captured
*' and parameters defining the transition characteristics.The transition weight is calculated using a logistic function.
*' This equation provides a mechanism to smoothly transition from a linear to exponential cost curve based on the cumulative CO2 captured, allowing
*' for a realistic representation of the cost dynamics associated with CO2 sequestration. The result represents the weight for
*' the transition in the specified scenario and year.
QTrnsWghtLinToExp(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VTrnsWghtLinToExp(allCy,YTIME)
         =E=
         1/(1+exp(-iElastCO2Seq(allCy,"mc_s")*( VCaptCummCO2(allCy,YTIME)/iElastCO2Seq(allCy,"pot")-iElastCO2Seq(allCy,"mc_m")))); 

*' The equation calculates the cost curve for CO2 sequestration costs in Euro per ton of CO2 sequestered
*' for a specific scenario and year. The cost curve is determined based on cumulative CO2 captured and
*' elasticities for the CO2 sequestration cost curve.The equation is formulated to represent a flexible cost curve that
*' can transition from linear to exponential. The transition is controlled by the weight for the transition from linear to exponential
*' The cost curve is expressed as a combination of linear and exponential functions, allowing for a realistic.
*' representation of the relationship between cumulative CO2 captured and sequestration costs. This equation provides a dynamic and
*' realistic approach to modeling CO2 sequestration costs, considering the cumulative CO2 captured and the associated elasticities
*' for the cost curve. The result represents the cost of sequestering one ton of CO2 in the specified scenario and year.
Q06CstCO2SeqCsts(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         MVCstCO2SeqCsts(allCy,YTIME) =E=
       (1-VTrnsWghtLinToExp(allCy,YTIME))*(iElastCO2Seq(allCy,"mc_a")*VCaptCummCO2(allCy,YTIME)+iElastCO2Seq(allCy,"mc_b"))+
       VTrnsWghtLinToExp(allCy,YTIME)*(iElastCO2Seq(allCy,"mc_c")*exp(iElastCO2Seq(allCy,"mc_d")*VCaptCummCO2(allCy,YTIME)));           
