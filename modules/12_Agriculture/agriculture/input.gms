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
table i12SpecificFuelConsData(allCy,AGRI_MODES,EFS,YTIME)	      ""
$ondelim
$include"./iDataAgricultureEff.csv"
$offdelim
;
*---
table i12ConsFuel(allCy,AGRI_MODES,EFS,YTIME)	      ""
$ondelim
$include"./iDataAgricultureTFC.csv"
$offdelim
;
*---
table i12IntensityFertilizers(allCy,FERT_TYPES,YTIME)	      ""
$ondelim
$include"./iDataIntensityFertiliser.csv"
$offdelim
;
*---
i12SpecificFuelCons(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(DATAY(YTIME) and AGRMODEStoTECH(AGRI_MODES,AGRITECH) and AGRITECHTOEF(AGRITECH,EFS)) = i12SpecificFuelConsData(allCy,AGRI_MODES,EFS,YTIME) + 0.0001;
i12SpecificFuelCons(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(not DATAY(YTIME)) = i12SpecificFuelCons(allCy,AGRI_MODES,AGRITECH,EFS,"%fBaseY%");
*---
i12IndexClimateShift(allCy,AGRI_MODES,YTIME) = 1;
i12IndexTechShift(allCy,AGRI_MODES,YTIME) = 1;
i12IndexFertiliserShift(allCy,AGRI_MODES,YTIME) = 1;
*---
i12IndexGlobalCaloriesIntake(FOOD_TYPES,YTIME)$(ord(YTIME) > 1) = 
SUM(runCy2,i12CaloriesIntake(runCy2,FOOD_TYPES,YTIME) * i01Pop(YTIME,runCy2)) / 
SUM(runCy2,i12CaloriesIntake(runCy2,FOOD_TYPES,YTIME-1) * i01Pop(YTIME-1,runCy2));
*---
i12Lft(AGRI_MODES,AGRITECH) = 25;