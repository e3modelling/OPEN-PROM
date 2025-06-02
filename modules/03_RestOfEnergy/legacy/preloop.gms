*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V03CapRef.L(runCy,YTIME) = 0.1;
V03CapRef.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
*---
V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
*---
V03ConsGrssInlNotEneBranch.L(runCy,EFS,YTIME) = 0.1;
V03ConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
*---
V03OutTransfTherm.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
*---
V03InputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
V03InputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
*---
V03ConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
*---
V03Transfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
*---
V03ProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
*---
V03Imp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
V03Imp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
V03Exp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
V03Exp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);
V03Exp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
V03OutTransfDhp.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
*---
V03OutTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
*---
V03InpTransfNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
*---
MVConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);
*---
MVInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
MVInpTransfTherm.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iInpTransfTherm(runCy,EFS,YTIME);
*---
MVConsFinEneCountry.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
*---
MVLossesDistr.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);
*---