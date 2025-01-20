*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
VShareTechTr.FX(runCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(runCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)); 
VShareTechTr.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
*---
VStockPcYearly.L(runCy,YTIME)=0.1;
VStockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of VStockPcYearly is 10000 million vehicles
VStockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
*---
VActivPassTrnsp.l(runCy,TRANSE,YTIME) = 0.1;
VActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
*---
VNewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = iNewReg(runCy,YTIME);
*---
VTechSortVarCost.l(runCy,TRANSE,Rcon,YTIME)=0.1;
VTechSortVarCost.lo(runCy,TRANSE,Rcon,YTIME)=1e-20;
*---
VRateScrPc.l(runCy,YTIME)=0.1;
VRateScrPc.UP(runCy,YTIME) = 1;
VRateScrPc.FX(runCy,"%fBaseY%") = 0.1; 
*---
VCostTranspPerMeanConsSize.l(runCy,TRANSE,RCon,TTECH,YTIME)=0.1;
*---
VActivGoodsTransp.l(runCy,TRANSE,YTIME)=0.1;
VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
VPcOwnPcLevl.UP(runCy,YTIME) = 1;
VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VStockPcYearly.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
VMEPcNonGdp.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.l(runCy,YTIME)))
               * VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));
*---
VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.l(runCy,YTIME)))* 
                          VStockPcYearly.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");
*---
VGapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
*---
VConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);
*---
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) =0;
*---
*VActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(VActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
*QActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(VActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
*---
VCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-7;
QCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=VCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME);
*---
VTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=1e-8;
QTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=VTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME);
*---
VShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=1e-6;
QShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=VShareTechTr.scale(runCy,TRANSE,EF2,YTIME);
*---