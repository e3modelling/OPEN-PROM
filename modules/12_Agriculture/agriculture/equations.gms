*' @title Equations of OPEN-PROM Agriculture module
*' @code

*' GENERAL INFORMATION
*' Agricultural activity, energy services, technology capacity, fuel costs, fuel choices,
*' fuel consumption and fertiliser use are linked across countries and model years.
*' Technology choice and fuel blending depend on relative costs; capacity scrapping
*' currently follows fixed lifetimes without premature-retirement effects.

*' * Agriculture module
* We need another driver for food crops: 1st generation biofuels.

*' Defines the activity multiplier by agricultural mode. Crops, climate and irrigation
*' use the plant-calorie index; livestock and fishing use meat and fish indices.
*' Forestry uses biomass production growth and other-sector activity; postharvesting
*' follows crop energy-service growth; energy crops follow biodiesel production growth.
Q12Activity(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12Activity(allCy,AGRI_MODES,YTIME)
    =E=
  (1 + (i12IndexGlobalCaloriesIntake("PLANT",YTIME) - 1)$(sameas("CROPS",AGRI_MODES) or sameas("CLIMATE",AGRI_MODES) or sameas("IRRIGATION",AGRI_MODES))) *
  (1 + (i12IndexGlobalCaloriesIntake("MEAT",YTIME) - 1)$sameas("LIVESTOCK",AGRI_MODES)) *
  (1 + (i12IndexGlobalCaloriesIntake("FISH",YTIME) - 1)$sameas("FISHING",AGRI_MODES)) *
  (1 + ((V03ProdPrimary(allCy,"BMSWAS",YTIME) + 1e-6) / (V03ProdPrimary(allCy,"BMSWAS",YTIME-1) + 1e-6) * imActv(YTIME,allCy,"OE") - 1)$sameas("FORESTRY",AGRI_MODES)) *
  (1 + (V12EnergyService(allCy,"CROPS",YTIME) / V12EnergyService(allCy,"CROPS",YTIME-1) - 1)$sameas("POSTHARVESTING",AGRI_MODES)) *
  (1 + ((V03ProdPrimary(allCy,"BGDO",YTIME) + 1e-6) / (V03ProdPrimary(allCy,"BGDO",YTIME-1) + 1e-6) - 1)$sameas("ENERGY_CROPS",AGRI_MODES));

*' Updates agricultural energy-service requirements from the preceding year using the
*' mode-specific activity multiplier and exogenous climate, technology and fertiliser
*' shift indices.
Q12EnergyService(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12EnergyService(allCy,AGRI_MODES,YTIME)
      =E=
  V12EnergyService(allCy,AGRI_MODES,YTIME-1) *
  V12Activity(allCy,AGRI_MODES,YTIME) *
  i12IndexClimateShift(allCy,AGRI_MODES,YTIME) * 
  i12IndexTechShift(allCy,AGRI_MODES,YTIME) *
  i12IndexFertiliserShift(allCy,AGRI_MODES,YTIME);

*' Updates capacity for each agricultural technology by retaining the share of previous
*' capacity that is not scrapped and allocating the new capacity gap according to the
*' technology share.
Q12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and AGRMODEStoTECH(AGRI_MODES,AGRITECH))..
  V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
  V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME-1) * (1 - V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)) +
  V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME) *  V12GapCapacity(allCy,AGRI_MODES,YTIME);

*' Calculates non-negative replacement and expansion requirements as the positive part
*' of the change in energy-service demand plus capacity scrapped from the previous
*' period. Adds a small numerical offset.
Q12GapCapacity(allCy,AGRI_MODES,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
  V12GapCapacity(allCy,AGRI_MODES,YTIME)
    =E=
  (
    V12EnergyService(allCy,AGRI_MODES,YTIME) - 
    V12EnergyService(allCy,AGRI_MODES,YTIME-1) +
    SUM(AGRITECH$AGRMODEStoTECH(AGRI_MODES,AGRITECH),
      V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME-1) * V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
    ) +
    SQRT(SQR(
      V12EnergyService(allCy,AGRI_MODES,YTIME) - 
      V12EnergyService(allCy,AGRI_MODES,YTIME-1) +
      SUM(AGRITECH$AGRMODEStoTECH(AGRI_MODES,AGRITECH),
        V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME-1) * V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
      )
    ))
  ) / 2 + 1e-6;

* toe / activity

*' Calculates fuel expenditure per unit of agricultural activity by summing fuel-
*' specific final prices plus carbon prices, multiplied by base-year specific fuel
*' consumption and the technology fuel-blend shares. Adds a numerical offset.
Q12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) $AGRMODEStoTECH(AGRI_MODES,AGRITECH) $runCy(allCy))..
  V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
  sum(EFS$AGRITECHTOEF(AGRITECH,EFS), 
    (V12PriceFinalAgriculture(allCy,AGRI_MODES,EFS,YTIME) + VmPriceCarbon(allCy,"AG",EFS,YTIME)) *
    i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,"%fBaseY%") *
    V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
  ) + 1e-6;

*' Sets total agricultural technology cost equal to its fuel cost plus a small
*' numerical offset; no separate capital or maintenance cost is included in this
*' equation.
Q12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) $AGRMODEStoTECH(AGRI_MODES,AGRITECH) $runCy(allCy))..
  V12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
  V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME) + 1e-6;

*' Calculates a cost-competition indicator for premature scrapping from the inverse of
*' the technology fuel cost relative to the inverse costs of alternatives, weighted by
*' 0.01. This indicator does not currently affect the scrapping rate.
Q12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME)$AGRMODEStoTECH(AGRI_MODES,AGRITECH)$runCy(allCy))..
    V12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME)
        =E=
    1 -
    V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME-1) ** (-1) /
    (
      V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME-1) ** (-1) +
      0.01 *
      SUM(AGRITECH2$(not sameas(AGRITECH2,AGRITECH) and AGRMODEStoTECH(AGRI_MODES,AGRITECH2)),
        V12CostTotal(allCy,AGRI_MODES,AGRITECH2,YTIME-1) ** (-1)
      )
    );

*' Sets the annual scrapping rate to the inverse of technology lifetime. The premature-
*' scrapping term is multiplied by zero and therefore has no effect.
Q12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and AGRMODEStoTECH(AGRI_MODES,AGRITECH))..
    V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
        =E=
    1 - (1 - 1 / i12Lft(AGRI_MODES,AGRITECH)) *
    (1-0*V12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME));

*' Allocates the new capacity gap across eligible agricultural technologies in
*' proportion to the inverse of their preceding-year total costs, normalized across
*' alternatives.
Q12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME)$AGRMODEStoTECH(AGRI_MODES,AGRITECH)$runCy(allCy))..
    V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
    V12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME-1) ** (-1) /
    SUM(AGRITECH2$AGRMODEStoTECH(AGRI_MODES,AGRITECH2),
      V12CostTotal(allCy,AGRI_MODES,AGRITECH2,YTIME-1) ** (-1)
    );

*' Calculates each technology fuel-blend share from its calibration weight and the
*' inverse square of the preceding-year fuel price including carbon cost, normalized
*' across eligible fuels.
Q12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$AGRMODEStoTECH(AGRI_MODES,AGRITECH)$AGRITECHTOEF(AGRITECH,EFS))..
    V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
        =E=
    i12calibweibul(allCy,AGRI_MODES,AGRITECH,EFS,YTIME) * 
    (V12PriceFinalAgriculture(allCy,AGRI_MODES,EFS,YTIME-1) + VmPriceCarbon(allCy,"AG",EFS,YTIME-1)) ** (-2) /
    SUM(EFS2$AGRITECHTOEF(AGRITECH,EFS2),
      i12calibweibul(allCy,AGRI_MODES,AGRITECH,EFS2,YTIME) * 
      (V12PriceFinalAgriculture(allCy,AGRI_MODES,EFS2,YTIME-1) + VmPriceCarbon(allCy,"AG",EFS2,YTIME-1)) ** (-2)
    );

*' Updates the agricultural final fuel price using the preceding-year price and the
*' change in average production cost. For primary-price fuels, also applies the
*' primary-price growth factor with the final-price elasticity.
Q12PriceFinalAgriculture(allCy,AGRI_MODES,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12PriceFinalAgriculture(allCy,AGRI_MODES,EFS,YTIME)
      =E=
    V12PriceFinalAgriculture(allCy,AGRI_MODES,EFS,YTIME-1) *
    (VmCostAvgProd(allCy,EFS,YTIME) / VmCostAvgProd(allCy,EFS,YTIME-1)) ** i08ElastPriceFinal(EFS) *
    (1 + ((V08PricePrimary(allCy,EFS,YTIME) / V08PricePrimary(allCy,EFS,YTIME-1)) ** i08ElastPriceFinal(EFS) - 1)$PRIM_PRICES(EFS));

*' Calculates fuel consumption by agricultural mode and fuel as the sum across
*' compatible technologies of installed capacity times base-year specific fuel
*' consumption and the current fuel-blend share.
Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
        =E=
    SUM(AGRITECH$(AGRMODEStoTECH(AGRI_MODES,AGRITECH) and AGRITECHTOEF(AGRITECH,EFS)),
      V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME) *
      i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,"%fBaseY%") * !! Mtoe / Energy service --> ha
      V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
    );

*' Calculates consumption of each fertiliser type as the corresponding time-varying
*' fertiliser intensity multiplied by crop energy-service activity.
Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFertilizers(allCy,FERT_TYPES,YTIME)
        =E=
    i12IntensityFertilizers(allCy,FERT_TYPES,YTIME) *
    V12EnergyService(allCy,"CROPS",YTIME);