*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
i01PassCarsMarkSat(runCy) = 0.7 ; 
*---
V01ShareTechTr.FX(runCy,TRANSE,EF2,YTIME)$(not An(YTIME)) = imFuelConsTRANSE(runCy,TRANSE,EF2,YTIME)/sum(EF$(SECTTECH(TRANSE,EF)),imFuelConsTRANSE(runCy,TRANSE,EF,YTIME)); 
V01ShareTechTr.FX(runCy,TRANSE,TTECH,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
*---
V01StockPcYearly.UP(runCy,YTIME) = 10000; !! upper bound of V01StockPcYearly is 10000 million vehicles
V01StockPcYearly.L(runCy,YTIME) = 0.1;
V01StockPcYearly.FX(runCy,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,"PC");
*---
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = 0.1;
V01ActivPassTrnsp.FX(runCy,"PC",YTIME)$(not AN(YTIME)) = imTransChar(runCy,"KM_VEH",YTIME); 
V01ActivPassTrnsp.FX(runCy,TRANP,YTIME) $(not AN(YTIME) and not sameas(TRANP,"PC")) = imActv(YTIME,runCy,TRANP); 
V01ActivPassTrnsp.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
*---
V01NewRegPcYearly.FX(runCy,YTIME)$(not an(ytime)) = i01NewReg(runCy,YTIME);
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
V01ActivGoodsTransp.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = imActv(YTIME,runCy,TRANG);
V01ActivGoodsTransp.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
*---
V01PcOwnPcLevl.UP(runCy,YTIME) = 1;
V01PcOwnPcLevl.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (V01StockPcYearly.L(runCy,YTIME-1) / (i01Pop(YTIME-1,runCy)*1000) /
i01PassCarsMarkSat(runCy))$(i01Pop(YTIME-1,runCy))+V01PcOwnPcLevl.L(runCy,YTIME-1)$(not i01Pop(YTIME-1,runCy));
*---
V01MEPcNonGdp.L(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( imTransChar(runCy,"RES_MEXTF",YTIME) * i01Sigma(runCy,"S1") * EXP(i01Sigma(runCy,"S2") *
           EXP(i01Sigma(runCy,"S3") * V01PcOwnPcLevl.L(runCy,YTIME)))
               * V01StockPcYearly.L(runCy,YTIME-1) /(i01Pop(YTIME-1,runCy) * 1000) )$(i01Pop(YTIME-1,runCy));
*---
V01MEPcNonGdp.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( imTransChar(runCy,"RES_MEXTF",YTIME) * i01Sigma(runCy,"S1") * EXP(i01Sigma(runCy,"S2") * EXP(i01Sigma(runCy,"S3") *
                          V01PcOwnPcLevl.L(runCy,YTIME)))* 
                          V01StockPcYearly.L(runCy,YTIME-1) /(i01Pop(YTIME-1,runCy) * 1000) )$(i01Pop(YTIME-1,runCy))+V01MEPcNonGdp.L(runCy,YTIME-1)$(not i01Pop(YTIME-1,runCy));
*---
i01DataPassCars(runCy,"PC","MEXTV") = 0.01;
*---
V01MEPcGdp.FX(runCy,YTIME)$(not An(YTIME)) = i01DataPassCars(runCy,"PC","MEXTV");
*---
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
*---
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,"%fBaseY%")$(SECTTECH(TRANSE,EF) ) = i01SpeFuelConsCostBy(runCy,TRANSE,TTECH,EF);
*---
V01ConsTechTranspSectoral.FX(runCy,TRANSE,TTECH,EF,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF) $(not AN(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME); 
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
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VmDemFinEneTranspPerFuel.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
*---
VmLft.L(runCy,DSBS,EF,YTIME)= 0.1;
VmLft.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = i01TechLft(runCy,DSBS,EF,YTIME);
VmLft.FX(runCy,TRANSE,TTECH,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = i01TechLft(runCy,TRANSE,TTECH,YTIME);
VmLft.FX(runCy,DSBS,EF,YTIME)$(not SECTTECH(DSBS,EF)) = 0;
VmLft.FX(runCy,"PC",TTECH,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH)) = 10;
*---