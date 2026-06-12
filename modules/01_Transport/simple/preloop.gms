*' @title Transport Preloop
*' @code

*'                *VARIABLE INITIALISATION*

V01TransportActivity.LO(runCy,TRANSE,YTIME) = 0;
V01TransportActivity.L(runCy,TRANSE,YTIME) = imActv("%fBaseY%",runCy,TRANSE);
V01TransportActivity.FX(runCy,TRANSE,YTIME)$DATAY(YTIME) = imActv(YTIME,runCy,TRANSE); 
*---
V01ShareBlend.LO(runCy,TRANSE,EF,YTIME) = 0;
V01ShareBlend.FX(runCy,TRANSE,EF,YTIME)$DATAY(YTIME) = i01ShareBlend(runCy,TRANSE,EF,"%fBaseY%");
V01ShareBlend.FX(runCy,TRANSE,EF,YTIME)$(SECtoEF(TRANSE,EF) and not yes$SUM(EF2,BLENDMAP(EF2,EF))) = 1;
*---
V01RateScrPcTot.UP(runCy,TRANSE,TTECH,YTIME) = 1;
*---
V01PremScrp.UP(runCy,TRANSE,TTECH,YTIME) = 1;
V01PremScrp.LO(runCy,TRANSE,TTECH,YTIME) = 0;
V01PremScrp.FX(runCy,TRANSE,TTECH,YTIME)$(not SECTTECH(TRANSE,TTECH)) = 0;
*---
V01RateScrPcTot.FX(runCy,TRANSE,TTECH,YTIME)$DATAY(YTIME) = 1 / i01TechLft(runCy,TRANSE,TTECH,YTIME);
*---
V01PcOwnPcLevl.UP(runCy,YTIME) = 2*i01PassCarsMarkSat(runCy);
V01PcOwnPcLevl.L(runCy,YTIME) = 0.5;
V01PcOwnPcLevl.FX(runCy,YTIME)$DATAY(YTIME) = imActv(YTIME,runCy,"PC") / (i01Pop(YTIME,runCy) * 1000) ;
*---
i01Sigma(runCy,"S2") = 0.4;
i01Sigma(runCy,"S1") = -log(V01PcOwnPcLevl.L(runCy,"%fBaseY%") / i01PassCarsMarkSat(runCy)) * EXP(i01Sigma(runCy,"S2") * i01GDPperCapita("%fBaseY%",runCy) / 10000);
*---
V01GapTranspActiv.LO(runCy,TRANSE,YTIME) = 0;
V01GapTranspActiv.FX(runCy,TRANSE,YTIME)$DATAY(YTIME) = 0;
*---
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(not sameas(TRANSE,"PC") and SECTTECH(TRANSE,TTECH) and TTECHtoEF(TTECH,EF)) = testSFC(runCy,TRANSE,TTECH);
V01ConsSpecificFuel.FX(runCy,TRANSE,TTECH,EF,YTIME)$(sameas(TRANSE,"PC")$(SECTTECH(TRANSE,TTECH)$TTECHtoEF(TTECH,EF))) = i01SFCPC(runCy,TTECH,EF,"%fBaseY%") * 
SUM(EFS,imFuelCons(runCy,"PC",EFS,"%fBaseY%")) * 1e3 / 
SUM((TTECH2,EF2)$TTECHtoEF(TTECH2,EF2), i01SFCPC(runCy,TTECH2,EF2,"%fBaseY%") * i01StockPC(runCy,TTECH2,"%fBaseY%") * i01ShareBlend(runCy,TRANSE,EF2,"%fBaseY%") * imTransChar(runCy,"KM_VEH","%fBaseY%"))
;


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
      V01ShareBlend.L(runCy,TRANSE,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME)
    ) 
  )$(not PLUGIN(TTECH)) +
  (
    sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
      (1-i01ShareAnnMilePlugInHybrid(runCy,YTIME)) *
      V01ShareBlend.L(runCy,TRANSE,EF,YTIME) *
      V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME)
    ) +
    i01ShareAnnMilePlugInHybrid(runCy,YTIME) *
    V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,"ELC",YTIME) *
    VmPriceFuelSubsecCarVal.L(runCy,TRANSE,"ELC",YTIME)
  )$PLUGIN(TTECH) +
  imVarCostTech(runCy,TRANSE,TTECH,YTIME)
) *
(
  1$(not sameas(TRANSE,"PC")) +
  1e-3 * imTransChar(runCy,"KM_VEH",YTIME)$sameas(TRANSE,"PC") !! aviation should be divided by 1000
);
V01CostFuel.FX(runCy,TRANSE,TTECH,YTIME)$(not SECTTECH(TRANSE,TTECH)) = 0;
*---
V01CostTranspPerMeanConsSize.LO(runCy,TRANSE,TTECH,YTIME) = 0;
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME)$SECTTECH(TRANSE,TTECH) = 1;
V01CostTranspPerMeanConsSize.FX(runCy,TRANSE,TTECH,YTIME)$DATAY(YTIME) = 
V01CapCostAnnualized.L(runCy,TRANSE,TTECH,YTIME) +
imFixOMCostTech(runCy,TRANSE,TTECH,YTIME) +
V01CostFuel.L(runCy,TRANSE,TTECH,YTIME);
V01CostTranspPerMeanConsSize.FX(runCy,TRANSE,TTECH,YTIME)$(not SECTTECH(TRANSE,TTECH)) = 0;
*---
V01ShareTechTr.LO(runCy,TRANSE,TTECH,YTIME) = 0;
*---
!!imFuelCons(runCy,TRANSE,EF,YTIME) / SUM(EF2$(BioToFossilFuel(EF2,EF) or BioToFossilFuel(EF,EF2)), imFuelCons(runCy,TRANSE,EF,YTIME) + imFuelCons(runCy,TRANSE,EF2,YTIME) + 1e-8);
!!V01ShareBioBlend.FX(runCy,TRANSE,TTECH,EF,YTIME)$(not BLEND(EF) and SECtoEF(TRANSE,EF)) = 1;
!!V01ShareBioBlend.FX(runCy,TRANSE,TTECH,EF,YTIME)$(not SECtoEF(TRANSE,EF))  = 0;
*---
V01ConsFuelTransport.FX(runCy,TRANSE,EF,YTIME)$DATAY(YTIME) = imFuelCons(runCy,TRANSE,EF,YTIME);
V01ConsFuelTransport.FX(runCy,TRANSE,EF,YTIME)$(not SECtoEF(TRANSE,EF)) = 0;
*---
V01CapacityTransport.FX(runCy,"GU","TCHEVGDO",YTIME)$DATAY(YTIME) = 0;
V01CapacityTransport.FX(runCy,TRANSE,TTECH,YTIME)$(DATAY(YTIME) and SECTTECH(TRANSE,TTECH)) = 
(
  SUM(EF$(TTECHtoEF(TTECH,EF)),
  imFuelCons(runCy,TRANSE,EF,YTIME) / testSFC(runCy,TRANSE,TTECH)
  + 1e-6) /
  SUM((TTECH2,EF2)$(SECTTECH(TRANSE,TTECH2) and TTECHtoEF(TTECH2,EF2)),
    imFuelCons(runCy,TRANSE,EF2,YTIME) / (testSFC(runCy,TRANSE,TTECH2))
  + 1e-6) * imActv(YTIME,runCy,TRANSE)
)$(not sameas("PC",TRANSE)) +
(
  i01StockPC(runCy,TTECH,YTIME)
)$sameas("PC",TRANSE);

