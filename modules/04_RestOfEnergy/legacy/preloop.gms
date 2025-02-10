*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCapRef.l(runCy,YTIME)=0.1;
VCapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
*---
VOutTransfRefSpec.l(runCy,EFS,YTIME)=0.1;
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VOutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
*---
VConsGrssInlNotEneBranch.l(runCy,EFS,YTIME)=0.1;
VConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
*---
VOutTransfTherm.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
*---
VInputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VInputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
*---
VConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
*---
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
*---
VProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
*---
VImp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VImp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VExp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VExp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);
VExp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VOutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
*---
VOutTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
*---
VInpTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
*---