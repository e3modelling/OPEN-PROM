*' @title Agriculture module postsolve
* Fix values of variables for the next time step

* Agriculture Module

V12EnergyService.FX(runCyL,AGRI_MODES,YTIME)$TIME(YTIME) = V12EnergyService.L(runCyL,AGRI_MODES,YTIME)$TIME(YTIME);