*' @title REST OF ENERGY BALANCE SECTORS postsolve
* Fix values of variables for the next time step

* Rest Of Energy Module

*---
VCapRef.FX(runCyL,YTIME)$TIME(YTIME) = VCapRef.L(runCyL,YTIME)$TIME(YTIME);
VTransfers.FX(runCyL,EFS,YTIME)$TIME(YTIME) = VTransfers.L(runCyL,EFS,YTIME)$TIME(YTIME);
VInputTransfRef.FX(runCyL,"CRO",YTIME)$(TIME(YTIME)) = VInputTransfRef.L(runCyL,"CRO",YTIME)$(TIME(YTIME));
VProdPrimary.FX(runCyL,PPRODEF,YTIME)$TIME(YTIME) = VProdPrimary.L(runCyL,PPRODEF,YTIME)$TIME(YTIME);
MVConsFinEneCountry.FX(runCyL,EFS,YTIME)$TIME(YTIME) = MVConsFinEneCountry.L(runCyL,EFS,YTIME)$TIME(YTIME);
VOutTransfRefSpec.FX(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD")) = VOutTransfRefSpec.L(runCyL,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"));
VConsGrssInlNotEneBranch.FX(runCyL,EFS,YTIME)$TIME(YTIME) =  VConsGrssInlNotEneBranch.L(runCyL,EFS,YTIME)$TIME(YTIME);
*---