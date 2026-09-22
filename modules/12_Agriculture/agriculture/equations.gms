*' @title Equations of OPEN-PROMs Agriculture module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Agriculture module
* We need another driver for food crops: 1st generation biofuels.
Q12Activity(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12Activity(allCy,AGRI_MODES,YTIME)
    =E=
  (1 + (i12IndexGlobalCaloriesIntake("PLANT",YTIME) - 1)$(sameas("CROPS",AGRI_MODES) or sameas("CLIMATE",AGRI_MODES) or sameas("IRRIGATION",AGRI_MODES))) *
  (1 + (i12IndexGlobalCaloriesIntake("MEAT",YTIME) - 1)$sameas("LIVESTOCK",AGRI_MODES)) *
  (1 + (i12IndexGlobalCaloriesIntake("FISH",YTIME) - 1)$sameas("FISHING",AGRI_MODES)) *
  (1 + ((V03ProdPrimary(allCy,"BMSWAS",YTIME) + 1e-6) / (V03ProdPrimary(allCy,"BMSWAS",YTIME-1) + 1e-6) * imActv(YTIME,allCy,"OE") - 1)$sameas("FORESTRY",AGRI_MODES)) *
  (1 + (V12EnergyService(allCy,"CROPS",YTIME) / V12EnergyService(allCy,"CROPS",YTIME-1) - 1)$sameas("POSTHARVESTING",AGRI_MODES)) *
  (1 + ((V03ProdPrimary(allCy,"BGDO",YTIME) + 1e-6) / (V03ProdPrimary(allCy,"BGDO",YTIME-1) + 1e-6) - 1)$sameas("ENERGY_CROPS",AGRI_MODES));

Q12EnergyService(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12EnergyService(allCy,AGRI_MODES,YTIME)
      =E=
  V12EnergyService(allCy,AGRI_MODES,YTIME-1) *
  V12Activity(allCy,AGRI_MODES,YTIME) *
  i12IndexClimateShift(allCy,AGRI_MODES,YTIME) * 
  i12IndexTechShift(allCy,AGRI_MODES,YTIME) *
  i12IndexFertiliserShift(allCy,AGRI_MODES,YTIME);

Q12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and AGRMODEStoTECH(AGRI_MODES,AGRITECH))..
  V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)
        =E=
  V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME-1) * (1 - V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)) +
  V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME) *  V12GapCapacity(allCy,AGRI_MODES,YTIME);

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
Q12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) $AGRMODEStoTECH(AGRI_MODES,AGRITECH) $runCy(allCy))..
  V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
  sum(EFS$AGRITECHTOEF(AGRITECH,EFS), 
      VmPriceFuelSubsecCarVal(allCy,"AG",EFS,YTIME) * 
      i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,"%fBaseY%") *
      V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
  ) + 1e-6;

Q12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) $AGRMODEStoTECH(AGRI_MODES,AGRITECH) $runCy(allCy))..
  V12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
  V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME) + 1e-6;

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

Q12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME) and runCy(allCy) and AGRMODEStoTECH(AGRI_MODES,AGRITECH))..
    V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
        =E=
    1 - (1 - 1 / i12Lft(AGRI_MODES,AGRITECH)) *
    (1-V12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME));

Q12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)$(TIME(YTIME)$AGRMODEStoTECH(AGRI_MODES,AGRITECH)$runCy(allCy))..
    V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
      =E=
    V12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME-1) ** (-1) /
    SUM(AGRITECH2$AGRMODEStoTECH(AGRI_MODES,AGRITECH2),
      V12CostTotal(allCy,AGRI_MODES,AGRITECH2,YTIME-1) ** (-1)
    );

Q12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$AGRMODEStoTECH(AGRI_MODES,AGRITECH)$AGRITECHTOEF(AGRITECH,EFS))..
    V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
        =E=
    i12DataShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,"%fBaseY%");

Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
        =E=
    SUM(AGRITECH$(AGRMODEStoTECH(AGRI_MODES,AGRITECH) and AGRITECHTOEF(AGRITECH,EFS)),
      V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME) *
      !! Mtoe / Energy service --> ha
      i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,"%fBaseY%") *
      V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
    );

Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFertilizers(allCy,FERT_TYPES,YTIME)
        =E=
    i12IntensityFertilizers(allCy,FERT_TYPES,YTIME) * !! Mtoe / Energy service --> ha
    V12EnergyService(allCy,"CROPS",YTIME);