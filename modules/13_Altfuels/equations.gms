*' @title Equations of OPEN-PROMs Alternative fuels module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Alternative fuels module

Q13DemAltEFTot(allCy,ALTEF,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V13DemAltEFTot(allCy,ALTEF,YTIME)
        =E=
    V03ConsGrssInl(allCy,ALTEF,YTIME) - VmImpNetEneBrnch(allCy,ALTEF,YTIME);  
    
Q13ScrapRate(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13ScrapRate(allCy,H2TECH,YTIME)
      =E=
    1 - (1-1/20);  

Q13DemGapAltEF(allCy,ALTEF,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V13DemGapAltEF(allCy,ALTEF,YTIME)
      =E=
    ( 
      V13DemAltEFTot(allCy,YTIME) -
      sum(H2TECH,
        (1-V13ScrapRate(allCy,ALTEFTECH,YTIME)) *
        VmCapAltEF(allCy,ALTEFTECH,YTIME-1)
      ) +
      SQRT(SQR(
        V13DemAltEFTot(allCy,YTIME) -
        sum(H2TECH,
          (1-V13ScrapRate(allCy,ALTEFTECH,YTIME)) *
          VmCapAltEF(allCy,ALTEFTECH,YTIME-1)
        )
      )) 
    ) / 2 + 1e-6; 

Q05CapH2(allCy,H2TECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCapH2(allCy,H2TECH,YTIME)
        =E=
    (1-V05CapScrapH2ProdTech(allCy,H2TECH,YTIME)) * VmCapAltEF(allCy,ALTEFTECH,YTIME-1) +
    V13DemGapAltEF(allCy,ALTEF,YTIME) * V13DemAltEFTot(allCy,ALTEF,YTIME) / (i05AvailH2Prod(allCy,H2TECH,YTIME) * smGwToTwhPerYear(YTIME) * smTWhToMtoe);
