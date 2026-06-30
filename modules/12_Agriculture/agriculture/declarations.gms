*' @title Agriculture module Declarations
*' @code

Parameters
i12CaloriesIntake(allCy,FOOD_TYPES,YTIME)                  "Daily calories intake per capita (kcal/capita/day)"
i12IndexClimateShift(allCy,AGRI_MODES,YTIME)
i12IndexTechShift(allCy,AGRI_MODES,YTIME)
i12SpecificFuelCons(allCy,AGRI_MODES,EFS,YTIME)
i12IntensityFertilizers(allCy,FERT_TYPES,YTIME)
i12IndexGlobalCaloriesIntake(FOOD_TYPES,YTIME)
*i12RatioCropsIrrigated(allCy,YTIME)
;

Equations 
Q12Activity(allCy,AGRI_MODES,YTIME)
Q12EnergyService(allCy,AGRI_MODES,YTIME)
Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)
Q12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12GapActivity(allCy,AGRI_MODES,YTIME)
Q12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
;

Variables
V12Activity(allCy,AGRI_MODES,YTIME)                       "Activity indicator for the agriculture module (tn)"
                                                              !! - Tonnes of plant-based products for CROPS,GREENHOUSES,IRRIGATION
                                                              !! - Tonnes of meat-based products for LIVESTOCK
                                                              !! - Tonnes of fish-based products for FISHING
                                                              !! - Tonnes of primary wood products for FORESTRY
                                                              !! - Tonnes of primary biomass products for ENERGY CROPS
V12EnergyService(allCy,AGRI_MODES,YTIME)                  "Energy service of each agriculture mode"
                                                              !! - Area of crops CROPS,GREENHOUSES,ENERGY CROPS (ha)
                                                              !! - Livestock units for LIVESTOCK (LU)
                                                              !! - Tonnes of fish-based products for FISHING (tn)
                                                              !! - Tonnes of primary wood products for FORESTRY (tn)
                                                              !! - Water irrigated for IRRIGATION (m^3)
V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
V12ConsFertilizers(allCy,FERT_TYPES,YTIME)
V12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)
V12GapActivity(allCy,AGRI_MODES,YTIME)
V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
;
