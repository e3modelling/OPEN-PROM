*' @title Equations of OPEN-PROMs Prices
*' @code




$IFTHEN.magpieQuantityEquation "%bmswasPriceMode%" == "curve"
$IFTHEN.magpieQuantityEquationSource "%landUseEmulator%" == "magpie"
* Non-EUR H12 regions use current regional Q. EUR uses preceding-year EU28 Q
* so its common price is independent of country solve order.
*' Computes effective second-generation bioenergy supply for each MAGPIE H12 region.
*' Fuel-specific weights aggregate primary production across mapped countries. Non-EUR
*' regions use current-year production, while EUR uses previous-year production.
Q08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME)
        =E=
    sum((MAGPIEH12REG,allCy2,EFS)$(mapMagpieH12Cy(MAGPIEH12REG,allCy) and mapMagpieH12Cy(MAGPIEH12REG,allCy2) and i08Bioenergy2GWeightMagpie(EFS)),
      i08Bioenergy2GWeightMagpie(EFS) * 
      (
        V03ProdPrimary(allCy2,EFS,YTIME)$(not sameas(MAGPIEH12REG,"EUR")) +
        V03ProdPrimary(allCy2,EFS,YTIME-1)$sameas(MAGPIEH12REG,"EUR")
      )
    );
$ENDIF.magpieQuantityEquationSource
$ENDIF.magpieQuantityEquation

*' Calculates the year-over-year ratio of the BMSWAS fuel price in power generation. A
*' small offset prevents division by zero; the factor is used for biofuel price
*' pass-through.
Q08BmswasPriceFactor(allCy,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V08BmswasPriceFactor(allCy,YTIME)
        =E=
    (VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME) + 1e-6) /
    (VmPriceFuelSubsecCarVal(allCy,"PG","BMSWAS",YTIME-1) + 1e-6);

*' Defines the supply-curve index for BMSWAS, depending on the selected land-use backend.
*' Softlink reads MAGPIE prices; MAGPIE curve mode uses a quadratic function of effective
*' bioenergy supply; GLOBIOM curve mode uses a power-law function of BMSWAS output. Other
*' fuels receive an index of one.
Q08SupplyCurves(allCy,EFS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V08SupplyCurves(allCy,EFS,YTIME)
      =E=
    (
$IFTHEN.bmswasBackend %bmswasPriceMode% == softlink
        iPricesMagpie(allCy,SBS,YTIME)
$ELSEIF.bmswasBackend %bmswasPriceMode% == curve
$IFTHEN.bmswasEmulatorBackend %landUseEmulator% == magpie
          sum((MAGPIEH12REG,activeMagpieScen)$mapMagpieH12Cy(MAGPIEH12REG,allCy),
            i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pa",YTIME) +
            i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pb",YTIME) * V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME) + 
            i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pc",YTIME) * sqr(V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME))
          )
$ELSE.bmswasEmulatorBackend
          1e-3 +
          sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"a",YTIME)) + 
          sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"b",YTIME)) * 
          V03ProdPrimary(allCy,"BMSWAS",YTIME) ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"c",YTIME)) 
$ENDIF.bmswasEmulatorBackend
$ELSE.bmswasBackend
        1
$ENDIF.bmswasBackend
    )$sameas("BMSWAS",EFS) +
    1$(not sameas("BMSWAS",EFS));

*' Updates primary energy prices relative to their base values using crude-oil and
*' natural-gas price changes and the BMSWAS supply-curve ratio, each with fuel-specific
*' elasticities. For BMSWAS, removes the previous price adder before updating and adds the
*' current one.
Q08PricePrimary(allCy,EFS,YTIME)$(TIME(YTIME) and runCy(allCy) and PRIM_PRICES(EFS) and not sameas("CRO",EFS))..
    V08PricePrimary(allCy,EFS,YTIME)
      =E=
    i08PriceBase(EFS) +
    (V08PricePrimary(allCy,EFS,YTIME-1) - i08PriceBase(EFS) - i08BmswasPriceAdder(YTIME-1)$sameas(EFS,"BMSWAS")) * 
    (V08PricePrimary(allCy,"CRO",YTIME) / V08PricePrimary(allCy,"CRO",YTIME-1)) ** i08ElastPricePrimary(EFS,"CRO") *
    (V08PricePrimary(allCy,"NGS",YTIME) / V08PricePrimary(allCy,"NGS",YTIME-1)) ** i08ElastPricePrimary(EFS,"NGS") *
    (V08SupplyCurves(allCy,"BMSWAS",YTIME) / V08SupplyCurves(allCy,"BMSWAS",YTIME-1)) ** i08ElastPriceSupplyCurve(EFS,"BMSWAS") +
    i08BmswasPriceAdder(YTIME)$sameas(EFS,"BMSWAS");

*' Updates secondary energy prices by applying the change in average production costs to
*' the previous-year price, raised to a fuel-specific elasticity.
Q08PriceSecondary(allCy,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    VmPriceSecondary(allCy,EFS,YTIME)
      =E=
    VmPriceSecondary(allCy,EFS,YTIME-1) *
    (VmCostAvgProd(allCy,EFS,YTIME) / VmCostAvgProd(allCy,EFS,YTIME-1)) ** i08ElastPriceSecondary(EFS);

*' Updates final energy prices by applying changes in average production costs and, for
*' primary-priced fuels, primary fuel prices. Both adjustments use the final-price
*' elasticity.
Q08PriceFinal(allCy,DSBS,EFS,YTIME)$(TIME(YTIME) and runCy(allCy) and SECtoEF(DSBS,EFS))..
    VmPriceFinal(allCy,DSBS,EFS,YTIME)
      =E=
    VmPriceFinal(allCy,DSBS,EFS,YTIME-1) *
    (VmCostAvgProd(allCy,EFS,YTIME) / VmCostAvgProd(allCy,EFS,YTIME-1)) ** i08ElastPriceFinal(EFS) *
    (1 + ((V08PricePrimary(allCy,EFS,YTIME) / V08PricePrimary(allCy,EFS,YTIME-1)) ** i08ElastPriceFinal(EFS) - 1)$PRIM_PRICES(EFS));

*' Updates subsector fuel prices, excluding crude oil, BMSWAS and nuclear fuel. Applies
*' lagged electricity, hydrogen or steam production-cost changes, biofuel price
*' pass-through, and crude-oil-linked changes for selected fuels. Adds the change in the
*' sector-specific carbon price.
Q08PriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)$(SECtoEF(SBS,EFS) $(not sameas("CRO",EFS))
   $(not sameas("BMSWAS",EFS)) $TIME(YTIME)
   $(not sameas("NUC",EFS)) $runCy(allCy))..
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME)
        =E=
    VmPriceFuelSubsecCarVal(allCy,SBS,EFS,YTIME-1) *
    (1 + (VmCostPowGenAvgLng(allCy,YTIME-1) / VmCostPowGenAvgLng(allCy,YTIME-2) - 1)$sameas("ELC",EFS)) *
    (1 + ((VmCostAvgProdH2(allCy,YTIME-1) / VmCostAvgProdH2(allCy,YTIME-2)) ** 0.7 - 1)$sameas("H2F",EFS)) * 
    (1 + (VmCostAvgProdSte(allCy,YTIME-1) / VmCostAvgProdSte(allCy,YTIME-2) - 1)$sameas("STE",EFS)) *
    (1 + (V08BmswasPriceFactor(allCy,YTIME) ** i08PriceTransElast(EFS,"BMSWAS") - 1)$BIOFUELS(EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$sameas("NGS",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$SECtoEFPROD("LQD",EFS)) *
    (1 + ((VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME) / VmPriceFuelSubsecCarVal(allCy,SBS,"CRO",YTIME-1)) ** i08PriceTransElast(EFS,"CRO") - 1)$(sameas("HCL",EFS) or sameas("LGN",EFS))) +
    VmPriceCarbon(allCy,SBS,EFS,YTIME) - VmPriceCarbon(allCy,SBS,EFS,YTIME-1);

* Select the land-use backend price, then apply the global sustainability tax once.
*' Sets the subsector BMSWAS price according to the selected backend: absolute softlink
*' prices, a MAGPIE quadratic supply curve, a GLOBIOM year-over-year supply-curve ratio,
*' or the previous price in static mode. Applies the current BMSWAS price adder once.
Q08PriceBmswas(allCy,SBS,YTIME)$(
  SECtoEF(SBS,"BMSWAS") $TIME(YTIME) $runCy(allCy)
)..
  VmPriceFuelSubsecCarVal(allCy,SBS,"BMSWAS",YTIME)
    =E=
  (
$IFTHEN.bmswasBackend %bmswasPriceMode% == softlink
    iPricesMagpie(allCy,SBS,YTIME)
$ELSEIF.bmswasBackend %bmswasPriceMode% == curve
$IFTHEN.bmswasEmulatorBackend %landUseEmulator% == magpie
      sum((MAGPIEH12REG,activeMagpieScen)$mapMagpieH12Cy(MAGPIEH12REG,allCy),
        i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pa",YTIME) +
        i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pb",YTIME) * V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME) + 
        i08BmswasPriceH12Magpie(activeMagpieScen,MAGPIEH12REG,"pc",YTIME) * sqr(V08Bioenergy2GEffectiveQH12Magpie(allCy,YTIME))
      )
$ELSE.bmswasEmulatorBackend
      (VmPriceFuelSubsecCarVal(allCy,SBS,"BMSWAS",YTIME-1) - i08BmswasPriceAdder(YTIME-1)) *
      (1e-3 + 
        sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"a",YTIME)) + 
        sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"b",YTIME)) * 
        (V03ProdPrimary(allCy,"BMSWAS",YTIME-1) + 1e-6) ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"c",YTIME)) 
      ) /
      (1e-3 + 
        sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"a",YTIME)) +
        sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"b",YTIME)) *
          (V03ProdPrimary(allCy,"BMSWAS",YTIME-2) + 1e-6) ** sum(activeGlobiomScen, i08BmswasSupplyCoefGlobiom(activeGlobiomScen,allCy,"c",YTIME))
      )
$ENDIF.bmswasEmulatorBackend
$ELSE.bmswasBackend
    VmPriceFuelSubsecCarVal(allCy,SBS,"BMSWAS",YTIME-1) - i08BmswasPriceAdder(YTIME-1)
$ENDIF.bmswasBackend
  ) + 
  i08BmswasPriceAdder(YTIME);

*' Calculates each fuel share in subsector final energy use. Excludes non-substitutable
*' electricity from both the fuel numerator and the total denominator, and includes small
*' offsets for numerical stability.
Q08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)$(SECtoEF(DSBS,EF) $TIME(YTIME) $runCy(allCy))..
V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME)
      =E=
    SUM(EFS$sameas(EF,EFS),
      (VmFinalEnergy(allCy,DSBS,EFS,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EFS) + 1e-6) /
      SUM(EFS2$SECtoEF(DSBS,EFS2), (VmFinalEnergy(allCy,DSBS,EFS2,YTIME) - V02FinalElecNonSubIndTert(allCy,DSBS,YTIME)$ELCEF(EFS2)) + 1e-6)
    );
  
*' Calculates the fuel-specific carbon price component from the TRADE carbon value and the
*' energy CO2 emissions factor. Applies the carbon value to industry and, after the
*' specified year threshold, selected domestic, transport, bunker and agricultural
*' sectors.
Q08PriceCarbon(allCy,SBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceCarbon(allCy,SBS,EFS,YTIME)
     =E=
    1e-3 * (
      VmCarVal(allCy,"TRADE",YTIME)$(INDSE1(SBS) or ((DOMSE1(SBS) or TRANS1(SBS) or BUN(SBS) or sameas("AG",SBS)) and ord(YTIME) > 17))
    ) * imFactorEmissEnergyCO2(allCy,SBS,EFS);

*' Calculates a subsector average fuel price as a weighted sum of previous-year fuel
*' prices, using previous-year final-energy fuel shares. The resulting index feeds into
*' demand and transport activity calculations.
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceFuelAvgSub(allCy,DSBS,YTIME)
        =E=
    sum(EF$SECtoEF(DSBS,EF), 
      V08PriceFuelSepCarbonWght(allCy,DSBS,EF,YTIME-1) *
      VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME-1));         

*' Limits the industrial electricity price index for each CHP technology to the technical
*' electricity-to-steam ratio ceiling. The absolute-value expression implements the
*' minimum of the index and that ceiling.
Q08PriceElecInd(allCy,TCHP,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmPriceElecInd(allCy,TCHP,YTIME) 
        =E=
    (
      V02IndxElecIndPrices(allCy,TCHP,YTIME) + smElecToSteRatioChp - SQRT( SQR(V02IndxElecIndPrices(allCy,TCHP,YTIME)-smElecToSteRatioChp))
    )/2;

*' Defines average production cost by fuel. Electricity, hydrogen and steam use their
*' respective generation-cost estimates. Gasoline and diesel use transformation input and
*' energy-sector costs, including carbon charges, divided by transformation output. Other
*' fuels follow a lagged cost rule, with a biofuel adjustment.
Q08CostAvgProd(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmCostAvgProd(allCy,EFS,YTIME)
      =E=
    VmCostPowGenAvgLng(allCy,YTIME)$sameas("ELC",EFS) +
    VmCostAvgProdH2(allCy,YTIME)$sameas("H2F",EFS) +
    VmCostAvgProdSte(allCy,YTIME)$sameas("STE",EFS) +
    (
      SUM((SSBS,EFS2)$(SECtoEFPROD(SSBS,EFS) and SECtoEF(SSBS,EFS2)),
        (V03InpTotTransf(allCy,SSBS,EFS2,YTIME) + VmConsFiEneSec(allCy,SSBS,EFS2,YTIME)) * V08PricePrimary(allCy,EFS2,YTIME) +
        1e-3 * imFactorEmissProcessesCO2(allCy,SSBS,EFS2,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SSBS), VmCarVal(allCy,NAP,YTIME)) * V03InpTotTransf(allCy,SSBS,EFS2,YTIME) +
        1e-3 * imFactorEmissEnergyCO2(allCy,SSBS,EFS2) * sum(NAP$NAPtoALLSBS(NAP,SSBS), VmCarVal(allCy,NAP,YTIME)) * VmConsFiEneSec(allCy,SSBS,EFS2,YTIME) + 1e-3
      ) / SUM((SSBS,EFS2)$(SECtoEFPROD(SSBS,EFS) and SECtoEF(SSBS,EFS2)), V03OutTotTransf(allCy,SSBS,EFS2,YTIME) + 1e-3)
    )$(sameas("GSL",EFS) or sameas("GDO",EFS)) +
    (
      VmCostAvgProd(allCy,EFS,YTIME-1) *
      (1 + (V08SupplyCurves(allCy,"BMSWAS",YTIME) / V08SupplyCurves(allCy,"BMSWAS",YTIME) - 1)$BIOFUELS(EFS)) *
      (1 - 0.008$BIOFUELS(EFS))
    )$(not (sameas(EFS,"STE") or sameas(EFS,"H2F") or sameas(EFS,"ELC") or sameas("GSL",EFS) or sameas("GDO",EFS)));