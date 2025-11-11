*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$DATAY(YTIME) = imActv(YTIME,runCy,"PC");
*---
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$DATAY(YTIME) = imTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(DATAY(YTIME) and not sameas(TRANP,"PC")) = imActv(YTIME,runCy,TRANP); 
*---
V01NewRegPcYearly.FX(runCy,YTIME)$DATAY(YTIME) = i01NewReg(runCy,YTIME);
*---
V01RateScrPc.UP(runCy,YTIME) = 1;
V01RateScrPc.l(runCy,YTIME) = 0.05;
V01RateScrPc.FX(runCy,YTIME)$DATAY(YTIME) = 0.05; 
*---
V01RateScrPcTot.UP(runCy,TTECH,YTIME) = 1;
V01RateScrPcTot.FX(runCy,TTECH,YTIME)$DATAY(YTIME) = V01RateScrPc.L(runCy,YTIME);
*---
V01PremScrp.UP(runCy,TRANSE,TTECH,YTIME) = 1;
V01PremScrp.lo(runCy,TRANSE,TTECH,YTIME) = 0;
*---
V01NumPcScrap.FX(runCy,"%fBaseY%") = V01RateScrPc.L(runCy,"%fBaseY%") * V01StockPcYearly.L(runCy,"%fBaseY%"); 
*---
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME)$SECTTECH(TRANSE,TTECH) = 1e-2;
*V01CostTranspPerMeanConsSize.FX(runCy,TRANSE,TTECH,YTIME)$(not SECTTECH(TRANSE,TTECH)) = 0;
*---
V01StockPcYearlyTech.FX(runCy,TTECH,"%fBaseY%") = i01StockPC(runCy,TTECH,"%fBaseY%");
*---
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$DATAY(YTIME) = imActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
V01PcOwnPcLevl.UP(runCy,YTIME) = 2*i01PassCarsMarkSat(runCy);
*V01PcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = V01StockPcYearly.L(runCy,YTIME-1) / (i01Pop(YTIME-1,runCy)*1000) ;
V01PcOwnPcLevl.FX(runCy,YTIME)$DATAY(YTIME) = V01StockPcYearly.L(runCy,YTIME) / (i01Pop(YTIME,runCy) * 1000) ;
*---
i01Sigma(runCy,"S2") = 0.5;
i01Sigma(runCy,"S1") = -log(V01PcOwnPcLevl.L(runCy,"%fBaseY%") / i01PassCarsMarkSat(runCy)) * EXP(i01Sigma(runCy,"S2") * i01GDPperCapita("%fBaseY%",runCy) / 10000);
*---
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$DATAY(YTIME)=0;
*---
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $DATAY(YTIME)) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $DATAY(YTIME)) = 0;
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $DATAY(YTIME)) = 0;
*---
V01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME)=1e-6;
Q01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME)=V01ShareTechTr.scale(runCy,TRANSE,TTECH,YTIME);
*---
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECtoEF(TRANSE,EF) $DATAY(YTIME)) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECtoEF(TRANSE,EF)) = 0;
*---
VmLft.L(runCy,DSBS,TTECH,YTIME) = 0.1;
VmLft.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))$(not TCHP(ITECH))) = i01TechLft(runCy,DSBS,ITECH,YTIME);
VmLft.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))$TCHP(ITECH)) = 12.5;
VmLft.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = i01TechLft(runCy,TRANSE,TTECH,YTIME);
VmLft.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
VmLft.FX(runCy,"PC",TTECH,YTIME)$((DATAY(YTIME)) $SECTTECH("PC",TTECH)) = 1/V01RateScrPc.L(runCy,YTIME);
*---