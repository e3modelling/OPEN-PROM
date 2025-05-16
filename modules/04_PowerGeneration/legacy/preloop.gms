*' @title Power Generation Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostPowGenAvgLng.L(runCy,ESET,"2010") = 0;
VCostPowGenAvgLng.L(runCy,ESET,"%fBaseY%") = 0;
*---
VSensCCS.L(runCy,YTIME) = 1;
*---
VCostProdSpecTech.LO(runCy,PGALL2,YTIME) = 0.00000001;
*---
VCostVarTech.L(runCy,PGALL,YTIME) = 0.1;
*---
VCostProdTeCHPreReplacAvail.L(runCy,PGALL,PGALL2,YTIME) = 0.1;
*---
VPotRenSuppCurve.L(runCy,PGRENEF,YTIME) = 0.1;
VPotRenSuppCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);
*---
VPotRenCurr.L(runCy,PGRENEF, YTIME)$(AN(YTIME)) = 1000;
VPotRenCurr.FX(runCy,PGRENEF, YTIME)$(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);
*---
VShareNewTechNoCCS.L(runCy,PGALL,TT)=0.1;
VShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
VShareNewTechNoCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL))) = 0;
*---
*vCostHourProdInvCCS.L(runCy,PGALL,HOUR,TT)=0.1;
*---
VShareNewTechCCS.L(runCy,PGALL,TT) = 0.1;
VShareNewTechCCS.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME))) = 0;
VShareNewTechCCS.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL))) = 0;
*---
VCostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,TT) = VShareNewTechNoCCS.L(runCy,PGALL,TT)*0.1 + sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS.L(runCy,CCS,TT)*0.1);
*---
VNewInvElec.L(runCy,YTIME) = 0.1;
VNewInvElec.FX(runCy,YTIME)$(NOT AN(YTIME)) = 1;
*---
VCostVarTechElec.L(runCy,PGALL,YTIME) = 0.1;
*---
VCostVarTechElecTot.L(runCy,YTIME) = 0.1;
*---
alias(datay, dataylag)
loop (runCy,PGALL,datay,dataylag)$(ord(datay) = ord(dataylag) + 1 and PGREN(PGALL)) DO
  VNetNewCapElec.FX(runCy,PGALL,datay) = iInstCapPast(runCy,PGALL,datay) - iInstCapPast(runCy,PGALL,dataylag) + 1E-10;
ENDLOOP;
VNetNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;
*---
VCFAvgRen.L(runCy,PGALL,YTIME) = 0.1;
VCFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iAvailRate(PGALL,YTIME);
*---
VSortPlantDispatch.LO(runCy,PGALL,YTIME) = 1.E-13;
*VSortPlantDispatch.l(runCy,PGALL,YTIME)=VCostVarTechElec.L(runCy,PGALL,YTIME)/VCostVarTechElecTot.L(runCy,YTIME);
*---
VProdElecReqCHP.L(runCy,YTIME) = 0.01;
*---
VScalFacPlaDisp.LO(runCy, HOUR, YTIME) = -1;
*VScalFacPlaDisp.L(runCy,HOUR,YTIME) = 1.e-20;
*---
VRenTechMatMult.L(runCy,PGALL,YTIME) = 1;
*---
VScalWeibullSum.L(runCy,PGALL,YTIME) = 2000;
*---
VCostHourProdInvDec.L(runCy,PGALL,HOUR,TT) = 0.0001;
VCostHourProdInvDec.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME))) = 0;
*---
VBaseLoad.L(runCy,YTIME) = 0.5;
VBaseLoad.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");
*---
VCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*---
VCapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
*---
VCapElecCHP.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);
*---
VSharePowPlaNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) ) = 0;
*---
VCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iInstCapPast(runCy,PGALL,YTIME);
VCapElec2.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = iInstCapPast(runCy,PGALL,YTIME);
VCapOverall.FX(runCy,PGALL,"%fBaseY%") =  iInstCapPast(runCy,PGALL,"%fBaseY%");
*---
VIndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
VIndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants
*---
VCostPowGenLonNoClimPol.L(runCy,ESET,"2010") = 0;
VCostPowGenLonNoClimPol.L(runCy,ESET,"%fBaseY%") = 0;
*---
*vCostPowGenAvgShrt.L(runCy,ESET,"2010") = 0;
*vCostPowGenAvgShrt.L(runCy,ESET,"%fBaseY%") = 0;
*---
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"2010") = 0;
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,"%fBaseY%") = 0;
*---
VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,"2010") = 0;
VCostAvgPowGenLonNoClimPol.FX(runCy,PGALL,ESET,"%fBaseY%") = 0;
*---
VLambda.LO(runCy,YTIME) = 0;
VLambda.L(runCy,YTIME) = 0.21;
*---
VCostProdSpecTech.scale(runCy,PGALL,YTIME)=1e12;
QCostProdSpecTech.scale(runCy,PGALL,YTIME)=VCostProdSpecTech.scale(runCy,PGALL,YTIME);
*---
VCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=1e6;
QCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=VCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME);
*---
VScalFacPlaDisp.scale(runCy,HOUR,YTIME)=1e-11;
QScalFacPlantDispatch.scale(runCy,HOUR,YTIME)=VScalFacPlaDisp.scale(runCy,HOUR,YTIME);
*---
$ontext
VSortPlantDispatch.scale(runCy,PGALL,YTIME)=1e-11;
QSortPlantDispatch.scale(runCy,PGALL,YTIME)=VSortPlantDispatch.scale(runCy,PGALL,YTIME);
$offtext
*---
VCostVarTechElec.scale(runCy,PGALL,YTIME)=1e5;
QCostVarTechElec.scale(runCy,PGALL,YTIME)=VCostVarTechElec.scale(runCy,PGALL,YTIME);
*---
VNewInvElec.scale(runCy,YTIME)=1e8;
QNewInvElec.scale(runCy,YTIME)=VNewInvElec.scale(runCy,YTIME);
*---
VCostVarTech.scale(runCy,PGALL,YTIME)=1e-5;
QCostVarTech.scale(runCy,PGALL,YTIME)=VCostVarTech.scale(runCy,PGALL,YTIME);
*---
VScalWeibullSum.scale(runCy,PGALL,YTIME)=1e6;
QScalWeibullSum.scale(runCy,PGALL,YTIME)=VScalWeibullSum.scale(runCy,PGALL,YTIME);
*---
VLoadFacDom.L(runCy,YTIME)=0.5;
VLoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(TRANSE)));
*---
VDemElecTot.L(runCy,YTIME)=10;
VDemElecTot.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));
*---
VPeakLoad.L(runCy,YTIME) = 1;
VPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = VDemElecTot.L(runCy,YTIME)/(VLoadFacDom.L(runCy,YTIME)*8.76);
*---
VProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME)=iDataElecProd(runCy,pgall,YTIME)/1000;
*---
VProdElecReqTot.FX(runCy,"%fBaseY%")=sum(pgall,VProdElec.L(runCy,pgall,"%fBaseY%"));
*---
VConsElec.L(runCy,DSBS,YTIME)=0.1;
VConsElec.FX(runCy,DSBS,YTIME)$(not AN(YTIME)) = 0.1;
*---