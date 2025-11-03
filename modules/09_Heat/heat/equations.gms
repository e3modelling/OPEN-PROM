*' @title Equations of OPEN-PROMs Heat module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Heat module

*' This equation calculates the total heat demand in the system. It takes into account the overall need for steam
*' across sectors like transportation, industry, and power generation, adjusted for any transportation losses or distribution inefficiencies.
Q09DemTotSte(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmDemTotSte(allCy,YTIME)
        =E=
    1;