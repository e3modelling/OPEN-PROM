*' @title Equations of OPEN-PROMs Agriculture module
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * Agriculture module
Q12Activity(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12Activity(allCy,AGRI_MODES,YTIME)
        =E=
  SUM(allcy2,
    i12CaloriesIntake(allcy2,"PLANT",YTIME)$sameas("CROPS",AGRI_MODES) +
    i12CaloriesIntake(allcy2,"MEAT",YTIME)$sameas("LIVESTOCK",AGRI_MODES) +
    i12CaloriesIntake(allcy2,"FISH",YTIME)$sameas("FISHING",AGRI_MODES)
  ) +
  V03ProdPrimary(allCy,"BMSWAS",YTIME)$sameas("FORESTRY",AGRI_MODES) +
  0.1;

Q12EnergyService(allCy,AGRI_MODES,YTIME)$(TIME(YTIME) and runCy(allCy))..
  V12EnergyService(allCy,AGRI_MODES,YTIME)
        =E=
  V12EnergyService(allCy,AGRI_MODES,YTIME-1) *
  V12Activity(allCy,AGRI_MODES,YTIME) / V12Activity(allCy,AGRI_MODES,YTIME-1) *
  i12IndexClimateShift(allCy,AGRI_MODES,YTIME) * 
  i12IndexTechShift(allCy,AGRI_MODES,YTIME);

Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
        =E=
    i12SpecificFuelCons(allCy,AGRI_MODES,EFS,YTIME) * !! Mtoe / Energy servie --> ha
    V12EnergyService(allCy,AGRI_MODES,YTIME);

Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)$(TIME(YTIME) and runCy(allCy))..
    V12ConsFertilizers(allCy,FERT_TYPES,YTIME)
        =E=
    i12IntensityFertilizers(allCy,FERT_TYPES,YTIME) * !! Mtoe / Energy servie --> ha
    V12EnergyService(allCy,"CROPS",YTIME);