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
VmImpNetEneBrnch.L(runCy,EFS,YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,"%fBaseY%") - imFuelTrade(runCy,"EXPORTS",EFS,"%fBaseY%");
VmImpNetEneBrnch.FX(runCy,EFS,YTIME)$DATAY(YTIME) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME) - imFuelTrade(runCy,"EXPORTS",EFS,YTIME);
VmFinalEnergy.LO(runCy,DSBS,EFS,YTIME) = 0;
VmFinalEnergy.L(runCy,DSBS,EFS,YTIME) = imFuelCons(runCy,DSBS,EFS,"%fBaseY%");
VmFinalEnergy.FX(runCy,DSBS,EFS,YTIME)$DATAY(YTIME) = imFuelCons(runCy,DSBS,EFS,YTIME);
VmFinalEnergy.FX(runCy,DSBS,EFS,YTIME)$(not SECtoEF(DSBS,EFS)) = 0;
VmFinalEnergy.FX(runCy,"ICT","ELC",YTIME) = i02FuelConsICT(runCy,"%ICT%","%SSP%",YTIME);
*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

*' Seed parameters from historical data
p03ConsGrssInl(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03DataGrossInlCons(runCy,EFS,YTIME);
p03Transfers(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03FeedTransfr(runCy,EFS,YTIME);
p03ProdPrimary(runCy,EFS,YTIME)$(DATAY(YTIME)) = i03PrimProd(runCy,EFS,YTIME);
p03Exp(runCy,EFS,YTIME)$(DATAY(YTIME)) = imFuelTrade(runCy,"EXPORTS",EFS,YTIME);
p03Imp(runCy,EFS,YTIME)$(DATAY(YTIME)) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME);
pmImpNetEneBrnch(runCy,EFS,YTIME)$(DATAY(YTIME)) = imFuelTrade(runCy,"IMPORTS",EFS,YTIME) - imFuelTrade(runCy,"EXPORTS",EFS,YTIME);
pmConsFiEneSec(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME)) = i03DataOwnConsEne(runCy,SSBS,EFS,YTIME);
pmConsFinEneCountry(runCy,EFS,YTIME)$(DATAY(YTIME)) = sum(DSBS$(not NENSE(DSBS)), imFuelConsPerFueSub(runCy,DSBS,EFS,YTIME));
pmConsFinNonEne(runCy,EFS,YTIME)$(DATAY(YTIME)) = SUM(NENSE$(not sameas("BU",NENSE) and SECtoEF(NENSE,EFS)), imFuelConsPerFueSub(runCy,NENSE,EFS,YTIME));
pmLossesDistr(runCy,EFS,YTIME)$(DATAY(YTIME)) = imDistrLosses(runCy,EFS,YTIME);
p03InpTotTransf(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME) and SECtoEF(SSBS,EFS)) = -i03InpTotTransfProcess(runCy,SSBS,EFS,YTIME);
p03OutTotTransf(runCy,SSBS,EFS,YTIME)$(DATAY(YTIME)) = i03OutTotTransfProcess(runCy,SSBS,EFS,YTIME);
*---
*---
