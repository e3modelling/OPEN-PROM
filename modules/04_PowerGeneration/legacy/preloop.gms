*' @title Power Generation Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VmCostPowGenAvgLng.L(runCy,ESET,"2010") = 0;
VmCostPowGenAvgLng.L(runCy,ESET,"%fBaseY%") = 0;
*---
V04SensCCS.L(runCy,YTIME) = 1;
*---
V04CostProdSpecTech.LO(runCy,PGALL2,YTIME) = 0.00000001;
*---
V04CostVarTech.L(runCy,PGALL,YTIME) = 0.1;
*---
V04CostProdTeCHPreReplacAvail.L(runCy,PGALL,PGALL2,YTIME) = 0.1;
*---
V04ShareNewTechNoCCS.L(runCy,PGALL,TT)=0.1;
V04ShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
V04ShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL))) = 0;
*---
*v04CostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)=0.1;
*---
V04ShareNewTechCCS.L(runCy,PGALL,TT) = 0.1;
V04ShareNewTechCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
V04ShareNewTechCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL))) = 0;
*---
V04CostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,TT) = V04ShareNewTechNoCCS.L(runCy,PGALL,TT)*0.1 + sum(CCS$CCS_NOCCS(CCS,PGALL), V04ShareNewTechCCS.L(runCy,CCS,TT)*0.1);
*---
V04NewInvElec.L(runCy,YTIME) = 0.1;
V04NewInvElec.FX(runCy,YTIME)$(NOT AN(YTIME)) = 1;
*---
V04CostVarTechElec.L(runCy,PGALL,YTIME) = 0.1;
*---
V04CostVarTechElecTot.L(runCy,YTIME) = 0.1;
*---
alias(datay, dataylag)
loop (runCy,PGALL,datay,dataylag)$(ord(datay) = ord(dataylag) + 1 and PGREN(PGALL)) DO
  V04NetNewCapElec.FX(runCy,PGALL,datay) = imInstCapPast(runCy,PGALL,datay) - imInstCapPast(runCy,PGALL,dataylag) + 1E-10;
ENDLOOP;
V04NetNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;
*---
V04CFAvgRen.L(runCy,PGALL,YTIME) = 0.1;
V04CFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = i04AvailRate(PGALL,YTIME);
*---
*V04SortPlantDispatch.lo(runCy,PGALL,YTIME)=1e-10;
V04SortPlantDispatch.l(runCy,PGALL,YTIME)=V04CostVarTechElec.L(runCy,PGALL,YTIME)/V04CostVarTechElecTot.L(runCy,YTIME);
*---
V04ProdElecReqCHP.L(runCy,YTIME) = 0.01;
*---
V04ScalFacPlaDisp.LO(runCy, HOUR, YTIME) = -1;
*V04ScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-20;
*---
V04RenTechMatMult.L(runCy,PGALL,YTIME) = 1;
*---
V04ScalWeibullSum.L(runCy,PGALL,YTIME) = 2000;
*---
V04RenTechMatMultExpr.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL)) = 0;
*---
V04CostHourProdInvDec.L(runCy,PGALL,HOUR,TT) = 0.0001;
V04CostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME))) = 0;
*---
VmCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = i04TotAvailCapBsYr(runCy);
*---
V04CapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = i04TotAvailCapBsYr(runCy);
*---
V04CapElecCHP.FX(runCy,CHP,YTIME)$(not An(YTIME)) = imInstCapPastCHP(runCy,CHP,YTIME);
*---
V04SharePowPlaNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) ) = 0;
*---
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  imInstCapPast(runCy,PGALL,YTIME);
V04CapElec2.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPast(runCy,PGALL,YTIME);
V04CapOverall.FX(runCy,PGALL,"%fBaseY%") =  imInstCapPast(runCy,PGALL,"%fBaseY%");
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPast(runCy,PGALL,YTIME)/i04AvailRate(PGALL,YTIME);
*---
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
V04IndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants
*---
V04CostPowGenLonNoClimPol.L(runCy,ESET,"2010") = 0;
V04CostPowGenLonNoClimPol.L(runCy,ESET,"%fBaseY%") = 0;
*---
*v04CostPowGenAvgShrt.L(runCy,ESET,"2010") = 0;
*v04CostPowGenAvgShrt.L(runCy,ESET,"%fBaseY%") = 0;
*---
V04CostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"2010") = 0;
V04CostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"%fBaseY%") = 0;
*---
V04CostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
V04CostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;
*---
V04Lambda.LO(runCy,YTIME) = 0;
V04Lambda.L(runCy,YTIME) = 0.21;
*---
V04CostProdSpecTech.scale(runCy,PGALL,YTIME)=1e12;
Q04CostProdSpecTech.scale(runCy,PGALL,YTIME)=V04CostProdSpecTech.scale(runCy,PGALL,YTIME);
*---
V04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=1e6;
Q04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=V04CostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME);
*---
V04ScalFacPlaDisp.scale(runCy,HOUR,YTIME)=1e-4;
Q04ScalFacPlantDispatch.scale(runCy,HOUR,YTIME)=V04ScalFacPlaDisp.scale(runCy,HOUR,YTIME);
*---
V04SortPlantDispatch.scale(runCy,PGALL,YTIME)=1e-12;
Q04SortPlantDispatch.scale(runCy,PGALL,YTIME)=V04SortPlantDispatch.scale(runCy,PGALL,YTIME);
*---
V04CostVarTechElec.scale(runCy,PGALL,YTIME)=1e5;
Q04CostVarTechElec.scale(runCy,PGALL,YTIME)=V04CostVarTechElec.scale(runCy,PGALL,YTIME);
*---
V04NewInvElec.scale(runCy,YTIME)=1e8;
Q04NewInvElec.scale(runCy,YTIME)=V04NewInvElec.scale(runCy,YTIME);
*---
V04CostVarTech.scale(runCy,PGALL,YTIME)=1e-5;
Q04CostVarTech.scale(runCy,PGALL,YTIME)=V04CostVarTech.scale(runCy,PGALL,YTIME);
*---
V04ScalWeibullSum.scale(runCy,PGALL,YTIME)=1e6;
Q04ScalWeibullSum.scale(runCy,PGALL,YTIME)=V04ScalWeibullSum.scale(runCy,PGALL,YTIME);
*---
V04LoadFacDom.L(runCy,YTIME)=0.5;
V04LoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         i04LoadFacElecDem(TRANSE)));
*---
V04DemElecTot.L(runCy,YTIME)=10;
V04DemElecTot.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( imFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, imFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + imDistrLosses(runCy,"ELC",YTIME)
                                             + i03TotEneBranchCons(runCy,"ELC",YTIME) - (imFuelImports(runCy,"ELC",YTIME)-imFuelExprts(runCy,"ELC",YTIME)));
*---
VmPeakLoad.L(runCy,YTIME) = 1;
VmPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = V04DemElecTot.L(runCy,YTIME)/(V04LoadFacDom.L(runCy,YTIME)*8.76);
*---
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME)=i04DataElecProd(runCy,pgall,YTIME)/1000;
*---
V04ProdElecReqTot.FX(runCy,"%fBaseY%")=sum(pgall,VmProdElec.L(runCy,pgall,"%fBaseY%"));
*---
V04ConsElec.L(runCy,DSBS,YTIME)=0.1;
V04ConsElec.FX(runCy,DSBS,YTIME)$(not AN(YTIME)) = 0.1;
*---