*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
V03CapRef.FX(runCyL,YTIME)$TIME(YTIME) = V03CapRef.L(runCyL,YTIME)$TIME(YTIME);
V03Transfers.FX(runCyL,EFS,YTIME)$TIME(YTIME) = V03Transfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03InputTransfRef.FX(runCyL,"CRO",YTIME)$(TIME(YTIME)) = V03InputTransfRef.L(runCyL,"CRO",YTIME)$(TIME(YTIME));
V03ProdPrimary.FX(runCyL,PPRODEF,YTIME)$TIME(YTIME) = V03ProdPrimary.L(runCyL,PPRODEF,YTIME)$TIME(YTIME);
VMConsFinEneCountry.FX(runCyL,EFS,YTIME)$TIME(YTIME) = VMConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
V03OutTransfRefSpec.FX(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = V03OutTransfRefSpec.L(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
V03ConsGrssInlNotEneBranch.FX(runCyL,EFS,YTIME)$TIME(YTIME) =  V03ConsGrssInlNotEneBranch.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---