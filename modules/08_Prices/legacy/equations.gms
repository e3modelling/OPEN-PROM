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
*' BMSWAS price modes are derived in main.gms:
*'   static: standard recursive fuel-price dynamics.
*'   softfx: price fixed to iPricesMagpie in core/preloop.gms.
*'   curve/globiom: year-over-year P=a+b*Q^c ratio using lagged BMSWAS Q.
*'   curve/magpie: H12 P=pa+pb*Q+pc*Q^2 using effective 2G Q,
*'                 0.4*BMSWAS + 0.6*(BGSL+BKRS+BGAS). Non-EUR regions use
*'                 current regional Q; all EU28 members use the common EUR
*'                 price based on preceding-year EU28 Q.
*'
*' V08BmswasPriceFactor equals the GLOBIOM curve ratio, the MAgPIE H12 target
*' divided by the preceding PG price, the soft-link price ratio, or one.
$IFTHEN.magpieQuantityEquation "%bmswasPriceMode%" == "curve"
$IFTHEN.magpieQuantityEquationSource "%landUseEmulator%" == "magpie"
* Non-EUR H12 regions use current regional Q. EUR uses preceding-year EU28 Q
* so its common price is independent of country solve order.
Q08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)
        =E=
    sum(MAGPIEH12REG$mapMagpieH12Cy(MAGPIEH12REG,allCy),
      sum(allCy2$mapMagpieH12Cy(MAGPIEH12REG,allCy2),
        sum(EFS$i08Bioenergy2GWeightMagpie(EFS),
          i08Bioenergy2GWeightMagpie(EFS) * (
            V03ProdPrimary(allCy2,EFS,YTIME)$(not sameas(MAGPIEH12REG,"EUR"))
          + V03ProdPrimary(allCy2,EFS,YTIME-1)$sameas(MAGPIEH12REG,"EUR")
          )
        )
      )
    )
    ;
$ENDIF.magpieQuantityEquationSource
$ENDIF.magpieQuantityEquation

Q08BmswasPriceFactor(allCy,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V08BmswasPriceFactor(allCy,YTIME)
        =E=
$IFTHEN.mode %bmswasPriceMode% == curve
$IFTHEN.emulatorCurve %landUseEmulator% == globiom
    ( 1e-3 + sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"a",YTIME))
           + sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"b",YTIME))
           * (V03ProdPrimary(allCy,"BMSWAS",YTIME-1) + 1e-6)
           ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"c",YTIME)) )
    /
    ( 1e-3 + sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"a",YTIME))
           + sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"b",YTIME))
           * (V03ProdPrimary(allCy,"BMSWAS",YTIME-2) + 1e-6)
           ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"c",YTIME)) )
$ELSEIF.emulatorCurve %landUseEmulator% == magpie
    sum(MAGPIEH12REG$mapMagpieH12Cy(MAGPIEH12REG,allCy),
      sum(activeMagpieScen,
          i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pa",YTIME)
        + i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pb",YTIME)
          * V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)
        + i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pc",YTIME)
          * sqr(V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME))
      )
    )
    / VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME-1)
$ENDIF.emulatorCurve
$ELSEIF.mode %bmswasPriceMode% == softfx
    VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME) / VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME-1)
$ELSE.mode
    1
$ENDIF.mode
    ;

Q08PriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)$(SECtoEF(SBS,EFS) $(not sameas("CRO",EFS)) $TIME(YTIME)
$IFTHEN %softLinkMAgPIE% == on
   $(not sameas("BMSWAS",EFS))
$ENDIF
$IFTHEN.magpiePriceDomain "%bmswasPriceMode%" == "curve"
$IFTHEN.magpiePriceDomainSource "%landUseEmulator%" == "magpie"
   $(not sameas("BMSWAS",EFS))
$ENDIF.magpiePriceDomainSource
$ENDIF.magpiePriceDomain
   $(not sameas("NUC",EFS)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)
        =E=
*' Fuel prices follow the preceding value, production-cost or supply indices,
*' crude-oil pass-through, and the change in carbon cost.
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
    (1 + (VmCostPowGenAvgLng(allCy,YTIME-1) / VmCostPowGenAvgLng(allCy,YTIME-2) - 1)$sameas("ELC",EFS)) *
    (1 + (VmCostAvgProdH2(allCy,YTIME-1) / VmCostAvgProdH2(allCy,YTIME-2) - 1)$sameas("H2F",EFS)) *
    (1 + (VmCostAvgProdSte(allCy,YTIME-1) / VmCostAvgProdSte(allCy,YTIME-2) - 1)$sameas("STE",EFS)) *
    (1 + (V08BmswasPriceFactor(allCy,YTIME) ** i08PriceTransElast(EFS,"BMSWAS") - 1)$(BIOFUELS(EFS) or sameas("BMSWAS",EFS))) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$sameas("NGS",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$SECtoEFPROD("LQD",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$(sameas("HCL",EFS) or sameas("LGN",EFS))) +
    VmPriceCarbon(allCy,SBS,EFS,YTIME) - VmPriceCarbon(allCy,SBS,EFS,YTIME-1);

$IFTHEN.magpiePriceEquation "%bmswasPriceMode%" == "curve"
$IFTHEN.magpiePriceEquationSource "%landUseEmulator%" == "magpie"
* Apply the H12 MAgPIE BMSWAS price to every subsector; EU28 share EUR price.
Q08PriceBmswasMagpie(allCy,SBS,YTIME)$(
  SECtoEF(SBS,"BMSWAS") $TIME(YTIME) $runCy(allCy)
)..
  VmPriceFuelSubsecCarVal(allCy,SBS,"BMSWAS",YTIME)
    =E=
  V08BmswasPriceFactor(allCy,YTIME)
  * VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME-1)
  ;
$ENDIF.magpiePriceEquationSource
$ENDIF.magpiePriceEquation

Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
    SUM(EFS$sameas(EF,EFS),
      (VmFinalEnergy(allCy,DSBS,EFS,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EFS) + 1e-6) /
      SUM(EFS2$SECtoEF(DSBS,EFS2), (VmFinalEnergy(allCy,DSBS,EFS2,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EFS2)) + 1e-6)
    );
  
Q08PriceCarbon(allCy,SBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceCarbon(allCy,SBS,EFS,YTIME)
     =E=
    1e-3 * (
      VmCarVal(allCy,"TRADE",YTIME)$(INDSE1(SBS) or ((DOMSE1(SBS) or TRANS1(SBS)) and ord(YTIME) > 17))
    ) * imCo2EmiFac(allCy,SBS,EFS,YTIME);

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
