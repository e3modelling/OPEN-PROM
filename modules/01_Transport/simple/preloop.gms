*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

V01RateScrPcTot.UP(runCy,TTECH,YTIME) = 1;
V01PcOwnPcLevl.UP(runCy,YTIME) = 2*i01PassCarsMarkSat(runCy);
V01PremScrp.UP(runCy,TRANSE,TTECH,YTIME) = 1;
V01RateScrPc.UP(runCy,TTECH,YTIME) = 1;

V01RateScrPc.LO(runCy,TTECH,YTIME) = 0;
V01PremScrp.LO(runCy,TRANSE,TTECH,YTIME) = 0;
*---
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,"PC");
*---
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$(DATAY(YTIME)) = imTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(DATAY(YTIME) and not sameas(TRANP,"PC")) = imActv(YTIME,runCy,TRANP); 
*---
V01NewRegPcYearly.FX(runCy,YTIME)$DATAY(ytime) = i01NewReg(runCy,YTIME);
*---
V01RateScrPc.L(runCy,TTECH,YTIME) = 0.05;
V01RateScrPc.FX(runCy,TTECH,YTIME)$(not SECTTECH("PC",TTECH)) = 0; 
V01RateScrPc.FX(runCy,TTECH,YTIME)$(DATAY(YTIME) and SECTTECH("PC",TTECH)) = 1 / i01TechLft(runCy,"PC",TTECH,YTIME); 
*---
V01RateScrPcTot.FX(runCy,TTECH,YTIME)$DATAY(YTIME) = V01RateScrPc.L(runCy,TTECH,YTIME);
*---
V01StockPcYearlyTech.L(runCy,TTECH,YTIME) = i01StockPC(runCy,TTECH,"%fBaseY%");
V01StockPcYearlyTech.FX(runCy,TTECH,YTIME)$DATAY(YTIME) = i01StockPC(runCy,TTECH,YTIME);
*---
V01NumPcScrap.FX(runCy,YTIME)$sameas(YTIME,"%fBaseY%") = SUM(TTECH,V01RateScrPcTot.L(runCy,TTECH,YTIME) * V01StockPcYearlyTech.L(runCy,TTECH,YTIME)); 
*---
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
V01PcOwnPcLevl.FX(runCy,YTIME)$(not An(YTIME)) = V01StockPcYearly.L(runCy,YTIME) / (i01Pop(YTIME,runCy) * 1000) ;
*---
i01Sigma(runCy,"S2") = 0.5;
i01Sigma(runCy,"S1") = -log(V01PcOwnPcLevl.L(runCy,"%fBaseY%") / i01PassCarsMarkSat(runCy)) * EXP(i01Sigma(runCy,"S2") * i01GDPperCapita("%fBaseY%",runCy) / 10000);
*---
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
*---
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(not sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01InitSpecFuelConsData(TRANSE,TTECH,EF);
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01SFCPC(runCy,TTECH,EF,YTIME);
*---
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not AN(YTIME))) = 0;
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not AN(YTIME))) = 0;
*---
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECtoEF(TRANSE,EF) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECtoEF(TRANSE,EF)) = 0;
*---
V01CapCostAnnualized.LO(runCy,TRANSE,TTECH,YTIME) = 0;
V01CapCostAnnualized.FX(runCy,TRANSE,TTECH,YTIME)$DATAY(YTIME) =
(
  imDisc(runCy,TRANSE,YTIME) * exp(imDisc(runCy,TRANSE,YTIME) * i01TechLft(runCy,TRANSE,TTECH,YTIME)) /
  (exp(imDisc(runCy,TRANSE,YTIME) * i01TechLft(runCy,TRANSE,TTECH,YTIME)) - 1)
) * imCapCostTech(runCy,TRANSE,TTECH,YTIME) * imCGI(runCy,YTIME);
*---
V01CostFuel.LO(runCy,TRANSE,TTECH,YTIME) = 0;
V01CostFuel.L(runCy,TRANSE,TTECH,YTIME)$SECTTECH(TRANSE,TTECH) = 1;
V01CostFuel.FX(runCy,TRANSE,TTECH,YTIME)$DATAY(YTIME) = 
(
  (
    sum(EF$TTECHtoEF(TTECH,EF),
      V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME)
    ) 
  )$(not PLUGIN(TTECH)) +
  (
    sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
      (1-i01ShareAnnMilePlugInHybrid(runCy,YTIME)) *
      V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME)
    ) +
    i01ShareAnnMilePlugInHybrid(runCy,YTIME) *
    V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,"ELC",YTIME) *
    VmPriceFuelSubsecCarVal.L(runCy,TRANSE,"ELC",YTIME)
  )$PLUGIN(TTECH) +
  imVarCostTech(runCy,TRANSE,TTECH,YTIME) +
  (VmRenValue.L(YTIME)/1000)$(not RENEF(TTECH)) 
) *
(
  1e-3 * V01ActivPassTrnsp.L(runCy,TRANSE,YTIME)$sameas(TRANSE,"PC") + !! aviation should be divided by 1000
  1e-1 * V01ActivPassTrnsp.L(runCy,TRANSE,YTIME)$(sameas(TRANSE,"PT")) +
  1e3 * V01ActivPassTrnsp.L(runCy,TRANSE,YTIME)$(sameas(TRANSE,"PB")) +
  1 * V01ActivPassTrnsp.L(runCy,TRANSE,YTIME)$(sameas(TRANSE,"PN")) +
  1 * V01ActivPassTrnsp.L(runCy,TRANSE,YTIME)$(sameas(TRANSE,"PA")) +
  1e-5 * V01ActivGoodsTransp.L(runCy,TRANSE,YTIME)$TRANG(TRANSE)  !! should be divided by number of vehicles
  !!imAnnCons(runCy,TRANSE,"modal")$(not sameas(TRANSE,"PC"))
);
*---
V01CostTranspPerMeanConsSize.LO(runCy,TRANSE,TTECH,YTIME) = epsilon6;
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME) = 1;
V01CostTranspPerMeanConsSize.FX(runCy,TRANSE,TTECH,YTIME)$DATAY(YTIME) = 
V01CapCostAnnualized.L(runCy,TRANSE,TTECH,YTIME) +
imFixOMCostTech(runCy,TRANSE,TTECH,YTIME) +
V01CostFuel.L(runCy,TRANSE,TTECH,YTIME);