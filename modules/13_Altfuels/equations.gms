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
    
Q13ScrapRate(allCy,ALTEFTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13ScrapRate(allCy,ALTEFTECH,YTIME)
      =E=
    1 - (1-1/20);  

Q13DemGapAltEF(allCy,ALTEF,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V13DemGapAltEF(allCy,ALTEF,YTIME)
      =E=
    ( 
      V13DemAltEFTot(allCy,ALTEF,YTIME) -
      sum(ALTEFTECH,
        (1-V13ScrapRate(allCy,ALTEFTECH,YTIME)) *
        V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME-1)
      ) +
      SQRT(SQR(
        V13DemAltEFTot(allCy,ALTEF,YTIME) -
        sum(ALTEFTECH,
          (1-V13ScrapRate(allCy,ALTEFTECH,YTIME)) *
          V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME-1)
        )
      )) 
    ) / 2 + 1e-6; 

Q13CapAltEF(allCy,ALTEF,ALTEFTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME)
        =E=
    V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME-1) * (1 - V13ScrapRate(allCy,ALTEF,ALTEFTECH,YTIME)) +
    V13DemGapAltEF(allCy,ALTEF,YTIME) * V13ShareGapALTEF(allCy,ALTEF,ALTEFTECH,YTIME);

Q13ShareGapALTEF(allCy,ALTEF,ALTEFTECH,YTIME)$(TIME(YTIME)$runCy(allCy)) ..
    V13ShareGapALTEF(allCy,ALTEF,ALTEFTECH,YTIME)
        =E=
    V13CostTotalALTEF(allCy,ALTEF,ALTEFTECH,YTIME-1) ** (-2) /
    SUM(ALTEFTECH2,
      !!i04MatFacPlaAvailCap(allCy,TSTEAM2,YTIME) *
      V13CostTotalALTEF(allCy,ALTEF,ALTEFTECH2,YTIME-1) ** (-2)
    );

Q13CostTotalALTEF(allCy,ALTEF,ALTEFTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13CostTotalALTEF(allCy,ALTEF,ALTEFTECH,YTIME)
        =E=
    V13CostCapexALTEF(allCy,ALTEF,ALTEFTECH,YTIME) +
    V13CostVariableALTEF(allCy,ALTEF,ALTEFTECH,YTIME);

Q13CostCapexALTEF(allCy,ALTEF,ALTEFTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13CostCapexALTEF(allCy,ALTEF,ALTEFTECH,YTIME)
      =E=
    1;

Q13CostVariableALTEF(allCy,ALTEF,ALTEFTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V13CostVariableALTEF(allCy,ALTEF,ALTEFTECH,YTIME)
      =E=
    1;

Q13CostAvgProdALTEF(allCy,ALTEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProdALTEF(allCy,ALTEF,YTIME)
      =E=
    sum(ALTEFTECH$ALTEFtoALTEFTECH(ALTEF,ALTEFTECH), 
      (V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME) + 1e-6) *
      V13CostTotalALTEF(allCy,ALTEF,ALTEFTECH,YTIME)
    ) / 
    sum(ALTEFTECH$ALTEFtoALTEFTECH(ALTEF,ALTEFTECH),V13ProdAltEF(allCy,ALTEF,ALTEFTECH,YTIME) + 1e-6);