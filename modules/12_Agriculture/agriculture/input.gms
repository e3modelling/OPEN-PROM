*' @title Agriculture Inputs
*' @code

*' Parameters
table i12CaloriesIntake(allCy,FOOD_TYPES,YTIME)	      ""
$ondelim
$include"./iCaloriesIntake.csv"
$offdelim
;
*---
table i12DataEnergyService(allCy,AGRI_MODES,YTIME)	      ""
$ondelim
$include"./iDataAgricultureService.csv"
$offdelim
;
*---
i12IndexClimateShift(allCy,AGRI_MODES,YTIME) = 1;
i12IndexTechShift(allCy,AGRI_MODES,YTIME) = 1;
i12IndexFertiliserShift(allCy,AGRI_MODES,YTIME) = 1;
*---
i12SpecificFuelCons(allCy,AGRI_MODES,"GDO",YTIME) = 1e-6;
i12IntensityFertilizers(allCy,FERT_TYPES,YTIME) = 1;
*---
i12ConsFuel(allCy,AGRI_MODES,EFS,YTIME) = imFuelCons(allCy,"AG",EFS,YTIME) / card(AGRI_MODES);
*---
i12IndexGlobalCaloriesIntake(FOOD_TYPES,YTIME)$(ord(YTIME) > 1) = 
SUM(runCy2,i12CaloriesIntake(runCy2,FOOD_TYPES,YTIME) * i01Pop(YTIME,runCy2)) / 
SUM(runCy2,i12CaloriesIntake(runCy2,FOOD_TYPES,YTIME-1) * i01Pop(YTIME-1,runCy2));