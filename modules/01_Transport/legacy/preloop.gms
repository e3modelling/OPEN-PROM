*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
iPassCarsMarkSat(runCy) = 0.7 ; 
*---
VShareTechTr.FX(runCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(runCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)); 
VShareTechTr.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
*---
VStockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of VStockPcYearly is 10000 million vehicles
VStockPcYearly.L(runCy,YTIME) = 0.1;
VStockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
*---
VActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
VActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
VActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
VActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
*---
VNewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = iNewReg(runCy,YTIME);
*---
VTechSortVarCost.LO(runCy,TRANSE,Rcon,YTIME) = 1e-20;
VTechSortVarCost.L(runCy,TRANSE,Rcon,YTIME) = 0.1;
*---
VRateScrPc.UP(runCy,YTIME) = 1;
VRateScrPc.l(runCy,YTIME) = 0.1;
VRateScrPc.FX(runCy,"%fBaseY%") = 0.1; 
*---
VCostTranspPerMeanConsSize.L(runCy,TRANSE,RCon,TTECH,YTIME) = 0.1;
*---
VActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
VActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
VPcOwnPcLevl.UP(runCy,YTIME) = 1;
VPcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VStockPcYearly.L(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VPcOwnPcLevl.L(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
VMEPcNonGdp.L(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.L(runCy,YTIME)))
               * VStockPcYearly.L(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));
*---
VMEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VPcOwnPcLevl.L(runCy,YTIME)))* 
                          VStockPcYearly.L(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMEPcNonGdp.L(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
VMEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");
*---
VGapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
*---
VConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);
*---
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
VConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) = 0;
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
VCostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-12;
QCostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=VCostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME);
*---
VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
*---
VLft.L(runCy,DSBS,EF,YTIME)= 0.1;
VLft.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VLft.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VLft.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF)) = 0;
VLft.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH)) = 10;
*---