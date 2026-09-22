*' @title Agriculture module Declarations
*' @code

Parameters
i12CaloriesIntake(allCy,FOOD_TYPES,YTIME)                  "Daily calories intake per capita (kcal/capita/day)"
i12IndexClimateShift(allCy,AGRI_MODES,YTIME)
i12IndexTechShift(allCy,AGRI_MODES,YTIME)
i12IndexFertiliserShift(allCy,AGRI_MODES,YTIME)
i12IntensityFertilizers(allCy,FERT_TYPES,YTIME)
i12IndexGlobalCaloriesIntake(FOOD_TYPES,YTIME)
*i12RatioCropsIrrigated(allCy,YTIME)
i12DataEnergyService(allCy,AGRI_MODES,YTIME)
i12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
i12Lft(AGRI_MODES,AGRITECH)
i12DataShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
;

Equations 
Q12Activity(allCy,AGRI_MODES,YTIME)
Q12EnergyService(allCy,AGRI_MODES,YTIME)
Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)
Q12Capacity(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12GapCapacity(allCy,AGRI_MODES,YTIME)
Q12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)
Q12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
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
V12GapCapacity(allCy,AGRI_MODES,YTIME)
V12ScrpRate(allCy,AGRI_MODES,AGRITECH,YTIME)
V12ShareTech(allCy,AGRI_MODES,AGRITECH,YTIME)
V12ScrpPrem(allCy,AGRI_MODES,AGRITECH,YTIME)
V12CostFuel(allCy,AGRI_MODES,AGRITECH,YTIME)
V12CostTotal(allCy,AGRI_MODES,AGRITECH,YTIME)
V12ShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)
;
