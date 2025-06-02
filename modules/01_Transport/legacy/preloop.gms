*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
iPassCarsMarkSat(runCy) = 0.7 ; 
*---
V01ShareTechTr.FX(runCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = iFuelConsTRANSE(runCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)); 
V01ShareTechTr.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
*---
V01StockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of V01StockPcYearly is 10000 million vehicles
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
*---
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = iActv(YTIME,runCy,TRANP); 
V01ActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
*---
V01NewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = iNewReg(runCy,YTIME);
*---
V01TechSortVarCost.LO(runCy,TRANSE,Rcon,YTIME) = 1e-20;
V01TechSortVarCost.L(runCy,TRANSE,Rcon,YTIME) = 0.1;
*---
V01RateScrPc.UP(runCy,YTIME) = 1;
V01RateScrPc.l(runCy,YTIME) = 0.1;
V01RateScrPc.FX(runCy,"%fBaseY%") = 0.1; 
*---
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,RCon,TTECH,YTIME) = 0.1;
*---
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
V01PcOwnPcLevl.UP(runCy,YTIME) = 1;
V01PcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (V01StockPcYearly.L(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+V01PcOwnPcLevl.L(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
V01MEPcNonGdp.L(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * V01PcOwnPcLevl.L(runCy,YTIME)))
               * V01StockPcYearly.L(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));
*---
V01MEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          V01PcOwnPcLevl.L(runCy,YTIME)))* 
                          V01StockPcYearly.L(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+V01MEPcNonGdp.L(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
*---
V01MEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");
*---
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
*---
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);
*---
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) = 0;
*---
*V01ActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(V01ActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
*Q01ActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(V01ActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
*---
V01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-7;
Q01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=V01CostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME);
*---
V01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=1e-8;
Q01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=V01TechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME);
*---
V01ShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=1e-6;
Q01ShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=V01ShareTechTr.scale(runCy,TRANSE,EF2,YTIME);
*---
V01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-12;
Q01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME)=V01CostTranspPerVeh.scale(runCy,TRANSE,RCon,TTECH,YTIME);
*---
VMDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VMDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
*---
VMLft.L(runCy,DSBS,EF,YTIME)= 0.1;
VMLft.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,YTIME);
VMLft.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,YTIME);
VMLft.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF)) = 0;
VMLft.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH)) = 10;
*---