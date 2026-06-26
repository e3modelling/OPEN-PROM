*' @title Agriculture module postsolve
* Fix values of variables for the next time step

* Agriculture Module

V12EnergyService.FX(runCyL,AGRI_MODES,YTIME)$TIME(YTIME) = V12EnergyService.L(runCyL,AGRI_MODES,YTIME)$TIME(YTIME);
V12Activity.FX(runCyL,AGRI_MODES,YTIME)$TIME(YTIME) = V12Activity.L(runCyL,AGRI_MODES,YTIME)$TIME(YTIME);
V12Capacity.FX(runCyL,AGRI_MODES,AGRITECH,YTIME)$TIME(YTIME) = V12Capacity.L(runCyL,AGRI_MODES,AGRITECH,YTIME)$TIME(YTIME);