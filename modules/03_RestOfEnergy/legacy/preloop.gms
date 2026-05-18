*' @title REST OF ENERGY BALANCE SECTORS Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V03ConsGrssInl.LO(runCy,EFS,YTIME) = 0;
V03ConsGrssInl.L(runCy,EFS,YTIME) = i03DataGrossInlCons(runCy,EFS,"%fBaseY%");
V03ConsGrssInl.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03DataGrossInlCons(runCy,EFS,YTIME);
*---
V03Transfers.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03FeedTransfr(runCy,EFS,YTIME);
*---
V03ProdPrimary.LO(runCy,EFS,YTIME) = 0;
V03ProdPrimary.L(runCy,EFS,YTIME) = i03PrimProd(runCy,EFS,"%fBaseY%");
V03ProdPrimary.FX(runCy,EFS,YTIME)$DATAY(YTIME) = i03PrimProd(runCy,EFS,YTIME);
*---
V03Imp.LO(runCy,EFS,YTIME) = 0;
V03Imp.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME);
*---
V03Exp.LO(runCy,EFS,YTIME) = 0;
V03Exp.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imFuelTrade(runCy,"EXPORTS",EFS,YTIME);
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

*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

p03InpTotTransf(runCy,SSBS,EFS,YTIME) = V03InpTotTransf.L(runCy,SSBS,EFS,YTIME-1);
p03OutTotTransf(runCy,SSBS,EFS,YTIME) = V03OutTotTransf.L(runCy,SSBS,EFS,YTIME-1);
p03Transfers(runCy,EFS,YTIME) = V03Transfers.L(runCy,EFS,YTIME-1);
p03ConsGrssInl(runCy,EFS,YTIME) = V03ConsGrssInl.L(runCy,EFS,YTIME-1);
p03ProdPrimary(runCy,EFS,YTIME) = V03ProdPrimary.L(runCy,EFS,YTIME-1);
p03Exp(runCy,EFS,YTIME) = V03Exp.L(runCy,EFS,YTIME-1);
p03Imp(runCy,EFS,YTIME) = V03Imp.L(runCy,EFS,YTIME-1);
pmImpNetEneBrnch(runCy,EFS,YTIME) = VmImpNetEneBrnch.L(runCy,EFS,YTIME-1);
pmConsFiEneSec(runCy,SSBS,EFS,YTIME) = VmConsFiEneSec.L(runCy,SSBS,EFS,YTIME-1);
pmConsFinEneCountry(runCy,EFS,YTIME) = VmConsFinEneCountry.L(runCy,EFS,YTIME-1);
pmConsFinNonEne(runCy,EFS,YTIME) = VmConsFinNonEne.L(runCy,EFS,YTIME-1);
pmLossesDistr(runCy,EFS,YTIME) = VmLossesDistr.L(runCy,EFS,YTIME-1);
