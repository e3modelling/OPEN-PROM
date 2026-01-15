*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
*V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEFPROD("LQD",EFS)) = i03OutTotTransfProcess(runCy,"LQD",EFS,YTIME);
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(not SECtoEFPROD("LQD",EFS)) = 0;
*---
V03OutTransfSolids.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEFPROD("SLD",EFS)) = i03OutTotTransfProcess(runCy,"SLD",EFS,YTIME);
V03OutTransfSolids.FX(runCy,EFS,YTIME)$(not SECtoEFPROD("SLD",EFS)) = 0;
*---
V03OutTransfGasses.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEFPROD("GAS",EFS)) = i03OutTotTransfProcess(runCy,"GAS",EFS,YTIME);
V03OutTransfGasses.FX(runCy,EFS,YTIME)$(not SECtoEFPROD("GAS",EFS)) = 0;
*---
V03ConsGrssInlNotEneBranch.L(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,"%fBaseY%") - i03TotEneBranchCons(runCy,EFS,"%fBaseY%");
V03ConsGrssInlNotEneBranch.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME) - i03TotEneBranchCons(runCy,EFS,YTIME);
*---
V03InputTransfRef.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEF("LQD",EFS)) = -i03InpTotTransfProcess(runCy,"LQD",EFS,YTIME);
V03InputTransfRef.FX(runCy,EFS,YTIME)$(not SECtoEF("LQD",EFS)) = 0;
*---
V03InputTransfSolids.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEF("SLD",EFS)) = -i03InpTotTransfProcess(runCy,"SLD",EFS,YTIME);
V03InputTransfSolids.FX(runCy,EFS,YTIME)$(not SECtoEF("SLD",EFS)) = 0;
*---
V03InputTransfGasses.FX(runCy,EFS,YTIME)$(DATAY(YTIME) and SECtoEF("GAS",EFS)) = -i03InpTotTransfProcess(runCy,"GAS",EFS,YTIME);
V03InputTransfGasses.FX(runCy,EFS,YTIME)$(not SECtoEF("GAS",EFS)) = 0;
*---
V03ConsGrssInl.L(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,"%fBaseY%");
V03ConsGrssInl.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME);
*---
V03Transfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = i03FeedTransfr(runCy,EFS,YTIME);
*---
*V03ProdPrimary.LO(runCy,EFS,YTIME) = 0;
V03ProdPrimary.L(runCy,EFS,YTIME) = i03PrimProd(runCy,EFS,"%fBaseY%") + 1;
V03ProdPrimary.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03PrimProd(runCy,EFS,YTIME);
*---
V03Imp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelImports(runCy,"NGS",YTIME);
V03Imp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
V03Exp.FX(runCy,EFS,YTIME)$(not An(YTIME)) = imFuelExprts(runCy,EFS,YTIME);
V03Exp.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = imFuelExprts(runCy,"NGS",YTIME);
V03Exp.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
*---
VmConsFiEneSec.L(runCy,SSBS,EFS,YTIME) = i03DataOwnConsEne(runCy,SSBS,EFS,"%fBaseY%");
VmConsFiEneSec.FX(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME) and SECtoEF(SSBS,EFS)) = i03DataOwnConsEne(runCy,SSBS,EFS,YTIME);
VmConsFiEneSec.FX(runCy,SSBS,EFS,YTIME)$(not SECtoEF(SSBS,EFS)) = 0;
*---
VmLossesDistr.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imDistrLosses(runCy,EFS,YTIME);
*---
V03OutTotTransf.L(runCy,SSBS,EFS,YTIME) = i03OutTotTransfProcess(runCy,SSBS,EFS,"%fBaseY%");
V03OutTotTransf.FX(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME) and SECtoEFPROD(SSBS,EFS)) = i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME);
V03OutTotTransf.FX(runCy,SSBS,EFS,YTIME)$(not SECtoEFPROD(SSBS,EFS)) = 0;
*---
V03InpTotTransf.FX(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME) and SECtoEF(SSBS,EFS)) = -i03InpTotTransfProcess(runCy,SSBS,EFS,YTIME);
V03InpTotTransf.FX(runCy,SSBS,EFS,YTIME)$(not SECtoEF(SSBS,EFS)) = 0;
*---
V03OutTransfDhp.FX(runCy,STEAM,YTIME)$DATAY(YTIME) = i03OutTotTransfProcess(runCy,"STEAMP",STEAM,YTIME);
*---
VmTransfInputDHPlants.FX(runCy,EFS,YTIME)$DATAY(YTIME) = -i03InpTotTransfProcess(runCy,"STEAMP",EFS,YTIME);
*---
V03OutTransfCHP.FX(runCy,TOCTEF,YTIME)$DATAY(YTIME) = i03OutTotTransfProcess(runCy,"CHP",TOCTEF,YTIME);
*---
VmConsFinEneCountry.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
sum(DSBS$(not NENSE(DSBS)), 
  imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)
);
*---
VmConsFinNonEne.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
SUM(NENSE$(not sameas("BU",NENSE) and SECtoEF(NENSE,EFS)),
  imFuelConsPerFueSub(runCy,NENSE,EFS,YTIME)
);