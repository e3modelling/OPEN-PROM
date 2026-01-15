*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
* V03CapRef.FX(runCyL,YTIME)$TIME(YTIME) = V03CapRef.L(runCyL,YTIME)$TIME(YTIME);
V03Transfers.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03InputTransfRef.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03InputTransfRef.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03InputTransfSolids.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03InputTransfSolids.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03InputTransfGasses.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03InputTransfGasses.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03ProdPrimary.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,EFS,YTIME)$TIME(YTIME);
VmConsFinEneCountry.FX(runCyL,EFS,YTIME)$TIME(YTIME) = VmConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03OutTransfRefSpec.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03OutTransfRefSpec.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03OutTransfGasses.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03OutTransfGasses.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03OutTransfSolids.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03OutTransfSolids.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03ConsGrssInlNotEneBranch.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03ConsGrssInlNotEneBranch.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---