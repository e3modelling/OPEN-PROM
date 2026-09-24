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
table i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,YTIME)	      ""
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
i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,YTIME)$(DATAY(YTIME) and AGRMODEStoTECH(AGRI_MODES,AGRITECH)) = i12SpecificFuelConsData(allCy,AGRI_MODES,AGRITECH,YTIME) + 1e-6;
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
*---
i12DataShareBlend(allCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(DATAY(YTIME) and AGRMODEStoTECH(AGRI_MODES,AGRITECH) and AGRITECHTOEF(AGRITECH,EFS)) = 
(i12ConsFuel(allCy,AGRI_MODES,EFS,YTIME) + 1e-6) /
SUM(EFS2$AGRITECHTOEF(AGRITECH,EFS2),
    i12ConsFuel(allCy,AGRI_MODES,EFS2,YTIME) + 1e-6
);
*---
i12calibweibul(runCy,AGRI_MODES,AGRITECH,EFS,YTIME)$DATAY(YTIME) = i12DataShareBlend(runCy,AGRI_MODES,AGRITECH,EFS,YTIME) * imFuelPrice(runCy,"AG",EFS,YTIME) ** 2;
i12calibweibul(runCy,AGRI_MODES,AGRITECH,EFS,YTIME)$(not DATAY(YTIME)) = i12calibweibul(runCy,AGRI_MODES,AGRITECH,EFS,"%fBaseY%");