*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
V03Transfers.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03ProdPrimary.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03Imp.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03Imp.L(runCyL,EFS,YTIME)$TIME(YTIME);
VmFinalEnergy.FX(runCyL,DSBS,EFS,YTIME)$TIME(YTIME) = VmFinalEnergy.L(runCyL,DSBS,EFS,YTIME)$TIME(YTIME);
*---