*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V03CapRef.L(runCy,YTIME) = 0.1;
V03CapRef.FX(runCy,YTIME)$(not An(YTIME)) = i03RefCapacity(runCy,YTIME);
*---
V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = i03TransfOutputRef(runCy,EFS,YTIME);
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
*---
V03ConsGrssInlNotEneBranch.L(runCy,EFS,YTIME) = 0.1;
V03ConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03GrossInConsNoEneBra(runCy,EFS,YTIME);
*---
V03InputTransfRef.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = i03TransfInputRef(runCy,"CRO",YTIME);
V03InputTransfRef.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
*---
V03ConsGrssInl.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03GrosInlCons(runCy,EFS,YTIME);
*---
V03Transfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03FeedTransfr(runCy,EFS,YTIME);
*---
V03ProdPrimary.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = i03PrimProd(runCy,PPRODEF,YTIME);
*---
V03Imp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelImports(runCy,"NGS",YTIME);
V03Imp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
V03Exp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = imFuelExprts(runCy,EFS,YTIME);
V03Exp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelExprts(runCy,"NGS",YTIME);
V03Exp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VmConsFiEneSec.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03TotEneBranchCons(runCy,EFS,YTIME);
*---
VmInpTransfTherm.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VmInpTransfTherm.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03InpTransfTherm(runCy,EFS,YTIME);
*---
VmConsFinEneCountry.FX(runCy,EFS,YTIME)$(not An(YTIME)) = imFinEneCons(runCy,EFS,YTIME);
*---
VmLossesDistr.FX(runCy,EFS,YTIME)$(not An(YTIME)) = imDistrLosses(runCy,EFS,YTIME);
*---
V03OutTotTransf.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = i03OutTotTransfProcess(runCy,EFS,YTIME);
*---
V03InpTotTransf.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpTotTransfProcess(runCy,EFS,YTIME);
*---
V03OutTransfDhp.FX(runCy,STEAM,YTIME)$(not AN(YTIME)) = i03OutDHPTransfProcess(runCy,STEAM,YTIME);
*---
VmTransfInputDHPlants.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpDHPTransfProcess(runCy,EFS,YTIME);
*---
V03OutTransfCHP.FX(runCy,TOCTEF,YTIME)$(not AN(YTIME)) = i03OutCHPTransfProcess(runCy,TOCTEF,YTIME);
*---
VmTransfInputCHPlants.FX(runCy,EFS,YTIME)$(not AN(YTIME)) = -i03InpCHPTransfProcess(runCy,EFS,YTIME);