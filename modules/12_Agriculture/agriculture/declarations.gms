*' @title Agriculture module Declarations
*' @code

Parameters
i12CaloriesIntake(allCy,FOOD_TYPES,YTIME)                  "Daily calories intake per capita (kcal/capita/day)"
i12IndexClimateShift(allCy,AGRI_MODES,YTIME)
i12IndexTechShift(allCy,AGRI_MODES,YTIME)
i12SpecificFuelCons(allCy,AGRI_MODES,EFS,YTIME)
i12IntensityFertilizers(allCy,FERT_TYPES,YTIME)
;

Equations 
Q12Activity(allCy,AGRI_MODES,YTIME)
Q12EnergyService(allCy,AGRI_MODES,YTIME)
Q12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
Q12ConsFertilizers(allCy,FERT_TYPES,YTIME)
;

Variables
V12Activity(allCy,AGRI_MODES,YTIME)                       "Activity indicator for the agriculture module"
V12EnergyService(allCy,AGRI_MODES,YTIME)
V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)
V12ConsFertilizers(allCy,FERT_TYPES,YTIME)
;
