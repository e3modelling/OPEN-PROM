*' @title Agriculture module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V12EnergyService.LO(runCy,AGRI_MODES,YTIME) = 0;
V12EnergyService.L(runCy,AGRI_MODES,YTIME) = i12DataEnergyService(runCy,AGRI_MODES,"%fBaseY%");
V12EnergyService.FX(runCy,AGRI_MODES,YTIME)$DATAY(YTIME) = i12DataEnergyService(runCy,AGRI_MODES,YTIME);
*---
V12Activity.LO(runCy,AGRI_MODES,YTIME) = 0;
V12Activity.L(runCy,AGRI_MODES,YTIME) = 1;
V12Activity.FX(runCy,AGRI_MODES,YTIME)$DATAY(YTIME) = 1;
*---
V12ConsFuel.LO(runCy,AGRI_MODES,EFS,YTIME) = 0;
V12ConsFuel.FX(runCy,AGRI_MODES,EFS,YTIME)$DATAY(YTIME) = i12ConsFuel(runCy,AGRI_MODES,EFS,YTIME);
*---
V12GapActivity.LO(runCy,AGRI_MODES,YTIME) = 0;
*---
V12Capacity.LO(runCy,AGRI_MODES,AGRITECH,YTIME) = 0;
V12Capacity.L(runCy,AGRI_MODES,AGRITECH,YTIME) = 1;
V12Capacity.FX(runCy,AGRI_MODES,AGRITECH,YTIME)$DATAY(YTIME) = 0;
!!(
!!  (i12ConsFuel(runCy,AGRI_MODES,EFS,YTIME) / i12SpecificFuelCons(runCy,AGRI_MODES,EFS,YTIME)) /
!!  i12ConsFuel(runCy,AGRI_MODES,EFS,YTIME) / i12SpecificFuelCons(runCy,AGRI_MODES,EFS,YTIME)
!!) * i12DataEnergyService(runCy,AGRI_MODES,YTIME);