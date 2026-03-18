*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
*V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
V03OutTransfRefSpec.FX(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03OutTotTransfProcess(runCy,"LQD",EFS,YTIME);
*---
V03OutTransfSolids.FX(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03OutTotTransfProcess(runCy,"SLD",EFS,YTIME);
*---
V03OutTransfGasses.FX(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03OutTotTransfProcess(runCy,"GAS",EFS,YTIME);
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
V03ConsGrssInl.LO(runCy,EFS,YTIME) = 0;
V03ConsGrssInl.L(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,"%fBaseY%");
V03ConsGrssInl.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME);
*---
V03Transfers.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03FeedTransfr(runCy,EFS,YTIME);
*---
V03ProdPrimary.LO(runCy,EFS,YTIME) = 0;
V03ProdPrimary.L(runCy,EFS,YTIME) = i03PrimProd(runCy,EFS,"%fBaseY%") + 1;
V03ProdPrimary.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03PrimProd(runCy,EFS,YTIME);
*---
V03Imp.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME);
*---
V03Exp.FX(runCy,EFS,YTIME)$DATAY(YTIME) =  imFuelTrade(runCy,"EXPORTS",EFS,YTIME);
*---
VmConsFiEneSec.LO(runCy,SSBS,EFS,YTIME) = 0;
VmConsFiEneSec.L(runCy,SSBS,EFS,YTIME) = i03DataOwnConsEne(runCy,SSBS,EFS,"%fBaseY%");
VmConsFiEneSec.FX(runCy,SSBS,EFS,YTIME)$DATAY(YTIME) = i03DataOwnConsEne(runCy,SSBS,EFS,YTIME);
*---
VmLossesDistr.LO(runCy,EFS,YTIME) = 0;
VmLossesDistr.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imDistrLosses(runCy,EFS,YTIME);
*---
V03OutTotTransf.LO(runCy,SSBS,EFS,YTIME) = 0;
V03OutTotTransf.L(runCy,SSBS,EFS,YTIME) = i03OutTotTransfProcess(runCy,SSBS,EFS,"%fBaseY%");
V03OutTotTransf.FX(runCy,SSBS,EFS,YTIME)$DATAY(YTIME) = i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME);
*---
V03InpTotTransf.LO(runCy,SSBS,EFS,YTIME) = 0;
V03InpTotTransf.L(runCy,SSBS,EFS,YTIME) = -i03InpTotTransfProcess(runCy,SSBS,EFS,"%fBaseY%");
V03InpTotTransf.FX(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME) and SECtoEF(SSBS,EFS)) = -i03InpTotTransfProcess(runCy,SSBS,EFS,YTIME);
V03InpTotTransf.FX(runCy,SSBS,EFS,YTIME)$(not SECtoEF(SSBS,EFS)) = 0;
*---
VmConsFinEneCountry.LO(runCy,EFS,YTIME) = 0;
VmConsFinEneCountry.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
sum(DSBS$(not NENSE(DSBS)), 
  imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME)
);
*---
VmConsFinNonEne.FX(runCy,EFS,YTIME)$DATAY(YTIME) = 
SUM(NENSE$(not sameas("BU",NENSE) and SECtoEF(NENSE,EFS)),
  imFuelConsPerFueSub(runCy,NENSE,EFS,YTIME)
);
*---
VmImpNetEneBrnch.L(runCy,EFS,YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,"%fBaseY%") - imFuelTrade(runCy,"EXPORTS",EFS,"%fBaseY%");
VmImpNetEneBrnch.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME) - imFuelTrade(runCy,"EXPORTS",EFS,YTIME);