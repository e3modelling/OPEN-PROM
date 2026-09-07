*' @title Agriculture Inputs
*' @code

*' Parameters
i12CaloriesIntake(allCy,FOOD_TYPES,YTIME) = 1000;
i12IndexClimateShift(allCy,AGRI_MODES,YTIME) = 1;
i12IndexTechShift(allCy,AGRI_MODES,YTIME) = 1;
i12SpecificFuelCons(allCy,AGRI_MODES,"GDO",YTIME) = 1.5;
i12IntensityFertilizers(allCy,FERT_TYPES,YTIME) = 1;
*---
i12DataEnergyService(allCy,AGRI_MODES,YTIME) = 1;
*---
i12ConsFuel(allCy,AGRI_MODES,EFS,YTIME) = 1;
*---
i12IndexGlobalCaloriesIntake(FOOD_TYPES,YTIME)$(ord(YTIME) > 1) = 
SUM(allCy2,i12CaloriesIntake(allCy2,FOOD_TYPES,YTIME) * i01Pop(YTIME,allCy2)) / 
SUM(allCy2,i12CaloriesIntake(allCy2,FOOD_TYPES,YTIME-1) * i01Pop(YTIME-1,allCy2));