*' @title Equations of OPEN-PROMs Prices
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Prices

*' The equation computes fuel prices per subsector and fuel with separate carbon values in
*' each sector for a specific scenario, subsector, fuel, and year.The equation considers various scenarios based
*' on the type of fuel and whether it is subject to changes in carbon values. It incorporates factors such as carbon emission factors
*' carbon values for all countries, electricity prices to industrial and residential consumers,
*' efficiency values, and the total hydrogen cost per sector.The result of the equation is the fuel price per 
*' subsector and fuel, adjusted based on changes in carbon values, electricity prices, efficiency, and hydrogen costs.
*'
*' *** BIOMASS (BMSWAS) PRICE ROUTING — compile-time switch logic ***
*'
*' Two independent compile-time flags control how BMSWAS is priced:
*'
*'   %link2MAgPIE%  (on/off, defined in main.gms)
*'     Controls the soft-link with the MAgPIE land-use model.
*'     When ON:  BMSWAS is excluded from this equation's domain entirely.
*'               Its price is instead fixed (.FX) to iPricesMagpie in core/preloop.gms.
*'     When OFF: BMSWAS is included in the domain and priced here.
*'
*'   %link2GLOBIOM%  (on/off, defined in main.gms)
*'     Controls the GLOBIOM biomass supply-curve coupling. Only meaningful when
*'     link2MAgPIE == off (otherwise BMSWAS is not in the domain regardless).
*'     When ON:  BMSWAS price is set from a fitted supply curve
*'               P = a + b * Q^c, where Q is the lagged total BMSWAS consumption
*'               summed over all demand subsectors. Coefficients a, b, c come from
*'               imBmswasSupplyCoefGLOBIOM, loaded from parameters/iBmswasSupplyCoefGLOBIOM.csv.
*'               The active GHG scenario row is selected by %globiomGHGScen% (e.g. GHG000).
*'               All other fuels (non-BMSWAS) continue to use the standard recursive dynamics.
*'               A +1e-3 floor is used inside the ratio SC(Q(t-1))/SC(Q(t-2)) to prevent
*'               0/0 in early years. The ratio formulation is self-calibrating and unit-
*'               independent: no absolute supply-curve price is used, only the year-over-year
*'               change in scarcity, which is applied as a multiplicative factor to P(t-1).
*'     When OFF: All fuels including BMSWAS use the standard recursive price dynamics (original behavior).
*'
*' Summary of the four compile-time combinations:
*'   link2MAgPIE=off, link2GLOBIOM=off  ->  BMSWAS in domain, standard recursive dynamics
*'   link2MAgPIE=off, link2GLOBIOM=on   ->  BMSWAS in domain, GLOBIOM supply curve
*'   link2MAgPIE=on,  link2GLOBIOM=off  ->  BMSWAS excluded from domain (MAgPIE handles it)
*'   link2MAgPIE=on,  link2GLOBIOM=on   ->  BMSWAS excluded from domain (MAgPIE takes priority)

Q08PriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)$(SECtoEF(SBS,EFS) $(not sameas("CRO",EFS)) $TIME(YTIME)
$IFTHEN %link2MAgPIE% == on 
   $(not sameas("BMSWAS",EFS))
$ENDIF
   $(not sameas("NUC",EFS)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)
        =E=
*' ============================================================
*' GLOBIOM path (link2GLOBIOM == on):
*'   The RHS is split into two mutually exclusive additive terms:
*'   (1) Standard recursive dynamics for all fuels EXCEPT BMSWAS,
*'       guarded by $(not sameas("BMSWAS",EFS)).
*'   (2) GLOBIOM power-law supply curve for BMSWAS only,
*'       guarded by $sameas("BMSWAS",EFS).
*'   This ensures exactly one term is non-zero for any given EFS.
*' ============================================================
$IFTHEN %link2GLOBIOM% == on
    (
      VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
      (1 + (VmCostPowGenAvgLng(allCy,YTIME-1) / VmCostPowGenAvgLng(allCy,YTIME-2) - 1)$sameas("ELC",EFS)) *
      (1 + (VmCostAvgProdH2(allCy,YTIME-1) / VmCostAvgProdH2(allCy,YTIME-2) - 1)$sameas("H2F",EFS)) * 
      (1 + (VmCostAvgProdSte(allCy,YTIME-1) / VmCostAvgProdSte(allCy,YTIME-2) - 1)$sameas("STE",EFS)) *
      (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.4 - 1)$sameas("NGS",EFS)) *
      (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.8 - 1)$SECtoEFPROD("LQD",EFS)) *
      (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.2 - 1)$(sameas("HCL",EFS) or sameas("LGN",EFS))) +
      1e-3 * (
        VmCarVal(allCy,"TRADE",YTIME) * imCo2EmiFac(allCy,SBS,EFS,YTIME) - 
        VmCarVal(allCy,"TRADE",YTIME-1) * imCo2EmiFac(allCy,SBS,EFS,YTIME-1)
      )$DSBS(SBS)
    )$(not sameas("BMSWAS",EFS))
    +
*'  --- GLOBIOM supply curve for BMSWAS: year-over-year ratio ---
*'  P(t) = P(t-1) * SC(Q(t-1)) / SC(Q(t-2))
*'  where SC(Q) = 1e-3 + a + b*(Q+1e-6)^c  (1e-3 prevents 0/0 when both years have Q=0)
*'  The ratio formulation is unit-independent and self-calibrating: in early years
*'  where BMSWAS demand is flat the ratio ~= 1 so the price tracks the calibrated
*'  historical trajectory; as biomass demand grows the supply-curve scarcity signal
*'  drives prices upward following GLOBIOM.
    (
      VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
      ( 1e-3 + imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"a",YTIME)
             + imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"b",YTIME)
             * (SUM(DSBS2$SECtoEF(DSBS2,"BMSWAS"), VmConsFuel(allCy,DSBS2,"BMSWAS",YTIME-1)) + 1e-6)
             ** imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"c",YTIME) )
      /
      ( 1e-3 + imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"a",YTIME)
             + imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"b",YTIME)
             * (SUM(DSBS2$SECtoEF(DSBS2,"BMSWAS"), VmConsFuel(allCy,DSBS2,"BMSWAS",YTIME-2)) + 1e-6)
             ** imBmswasSupplyCoefGLOBIOM("%globiomGHGScen%",allCy,"c",YTIME) )
    )$sameas("BMSWAS",EFS)
*' ============================================================
*' Original / fallback path (link2GLOBIOM == off):
*'   Standard recursive dynamics for ALL fuels including BMSWAS.
*'   This restores the pre-GLOBIOM behavior exactly.
*' ============================================================
$ELSE
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
    (1 + (VmCostPowGenAvgLng(allCy,YTIME-1) / VmCostPowGenAvgLng(allCy,YTIME-2) - 1)$sameas("ELC",EFS)) *
    (1 + (VmCostAvgProdH2(allCy,YTIME-1) / VmCostAvgProdH2(allCy,YTIME-2) - 1)$sameas("H2F",EFS)) * 
    (1 + (VmCostAvgProdSte(allCy,YTIME-1) / VmCostAvgProdSte(allCy,YTIME-2) - 1)$sameas("STE",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.4 - 1)$sameas("NGS",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.8 - 1)$SECtoEFPROD("LQD",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** 0.2 - 1)$(sameas("HCL",EFS) or sameas("LGN",EFS))) +
    1e-3 * (
      VmCarVal(allCy,"TRADE",YTIME) * imCo2EmiFac(allCy,SBS,EFS,YTIME) - 
      VmCarVal(allCy,"TRADE",YTIME-1) * imCo2EmiFac(allCy,SBS,EFS,YTIME-1)
    )$DSBS(SBS)
$ENDIF
    ;

Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
    1e-6 +
    (
      (VmConsFuel(allCy,DSBS,EF,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF)) /
      (SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuel(allCy,DSBS,EF2,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EF2)) + 1e-6)
    )$(INDDOM(DSBS) or NENSE(DSBS)) +   
    SUM(TRANSE$(sameas(TRANSE,DSBS)),
      VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME) /
      (SUM(EF2$SECtoEF(TRANSE,EF2),VmDemFinEneTranspPerFuel(allCy,TRANSE,EF2,YTIME)) + 1e-6)
    ) +
    (
      SUM(CDRTECH,VmConsFuelTechCDRProd(allCy,CDRTECH,EF,YTIME)) /
      (SUM((CDRTECH,EF2)$SECtoEF(DSBS,EF2),VmConsFuelTechCDRProd(allCy,CDRTECH,EF2,YTIME)) + 1e-6)
    )$sameas("DAC",DSBS) +
    (
      VmConsFuelTechCDRProd(allCy,"TEW",EF,YTIME) /
      (SUM(EF2$SECtoEF(DSBS,EF2),VmConsFuelTechCDRProd(allCy,"TEW",EF2,YTIME)) + 1e-6)
    )$sameas("EW",DSBS);
  
*' The equation calculates the average fuel price per subsector. These average prices are used to further compute electricity prices in industry
*' (using the OI "other industry" avg price), as well as the aggregate fuel demand (of substitutable fuels) per subsector.
*' In the transport sector they feed into the calculation of the activity levels.
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceFuelAvgSub(allCy,DSBS,YTIME)
        =E=
    sum(EF$SECtoEF(DSBS,EF), 
      V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME-1) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1));         

*' This equation calculates the fuel prices per subsector and fuel, specifically for Combined Heat and Power (CHP) plants, considering the profit earned from
*' electricity sales. The equation incorporates various factors such as the base fuel price, renewable value, variable cost of technology, useful energy conversion
*' factor, and the fraction of electricity price at which a CHP plant sells electricity to the network.
*' The fuel price for CHP plants is determined by subtracting the relevant components for CHP plants (fuel price for electricity generation and a fraction of electricity
*' price for CHP sales) from the overall fuel price for the subsector. Additionally, the equation includes a square root term to handle complex computations related to the
*' difference in fuel prices. This equation provides insights into the cost considerations for fuel in the context of CHP plants, considering various economic and technical parameters.
$ontext
Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) $runCy(allCy))..
        VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)
                =E=   
             (((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME) + (VmRenValue(YTIME)/1000)$(not RENEF(EF))+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)+imVarCostTech(allCy,DSBS,EF,YTIME)/1000)/imUsfEneConvSubTech(allCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VmPriceFuelSubsecCarVal(allCy,"OI","ELC",YTIME)*smFracElecPriChp*VmPriceElecInd(allCy,YTIME))$CHP(EF))))  ) )/2;
$offtext
*' This equation determines the electricity industry prices based on an estimated electricity index and a technical maximum of the electricity to steam ratio
*' in Combined Heat and Power plants. The industry prices are calculated as a function of the estimated electricity index and the specified maximum
*' electricity to steam ratio. The equation ensures that the electricity industry prices remain within a realistic range, considering the technical constraints
*' of CHP plants. It involves the estimated electricity index, and a technical maximum of the electricity to steam ratio in CHP plants is incorporated to account
*' for the specific characteristics of these facilities. This equation ensures that the derived electricity industry prices align with the estimated index and
*' technical constraints, providing a realistic representation of the electricity market in the industrial sector.
Q08PriceElecInd(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecInd(allCy,TCHP,YTIME) 
        =E=
    (
      V02IndxElecIndPrices(allCy,TCHP,YTIME) + smElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,TCHP,YTIME)-smElecToSteRatioChp))
    )/2;