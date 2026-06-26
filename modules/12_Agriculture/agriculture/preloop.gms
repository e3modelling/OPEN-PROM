*' @title Agriculture module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V12EnergyService.LO(allCy,AGRI_MODES,YTIME) = 0;
V12EnergyService.FX(allCy,AGRI_MODES,YTIME)$DATAY(YTIME) = 1;
*---
V12Activity.LO(allCy,AGRI_MODES,YTIME) = 0;
V12Activity.FX(allCy,AGRI_MODES,YTIME)$DATAY(YTIME) = 1;
*---
V12ConsFuel.LO(allCy,AGRI_MODES,EFS,YTIME) = 0;
V12ConsFuel.FX(allCy,AGRI_MODES,EFS,YTIME)$DATAY(YTIME) = 1;