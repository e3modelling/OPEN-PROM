* Fix values of variables for the next time step

* Transport Module

*---
p01StockPcYearly(runCyL,YTIME)$TIME(YTIME) = V01StockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
p01RateScrPcTot(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01RateScrPcTot.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01ActivGoodsTransp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
p01ConsSpecificFuel(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
*p01ConsTechTranspSectoral(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
p01ActivPassTrnsp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
pmLft(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME) = VmLft.L(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME);
p01NewRegPcYearly(runCyL,YTIME)$TIME(YTIME) = V01NewRegPcYearly.L(runCyL,YTIME)$TIME(YTIME);
p01NewRegPcTechYearly(runCyL,TTECH,YTIME)$TIME(YTIME) = V01NewRegPcTechYearly.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01NumPcScrap(runCyL,YTIME)$TIME(YTIME) = V01NumPcScrap.L(runCyL,YTIME)$TIME(YTIME);
p01StockPcYearlyTech(runCyL,TTECH,YTIME)$TIME(YTIME) = V01StockPcYearlyTech.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01PcOwnPcLevl(runCyL,YTIME)$TIME(YTIME) = V01PcOwnPcLevl.L(runCyL,YTIME)$TIME(YTIME);
p01GapTranspActiv(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01GapTranspActiv.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
p01PremScrp(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01PremScrp.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CapCostAnnualized(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CapCostAnnualized.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME) > 0) = V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME) <= 0 and p01CostFuel(runCyL,TRANSE,TTECH,YTIME-1) > 0) = p01CostFuel(runCyL,TRANSE,TTECH,YTIME-1);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME) <= 0 and p01CostFuel(runCyL,TRANSE,TTECH,YTIME-1) <= 0) =
(
  (
    sum(EF$TTECHtoEF(TTECH,EF),
      V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME) *
      V01ShareBlend.L(runCyL,TRANSE,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCyL,TRANSE,EF,YTIME)
    )
  )$(not PLUGIN(TTECH)) +
  (
    sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),
      (1-i01ShareAnnMilePlugInHybrid(runCyL,YTIME)) *
      V01ShareBlend.L(runCyL,TRANSE,EF,YTIME) *
      V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME) *
      VmPriceFuelSubsecCarVal.L(runCyL,TRANSE,EF,YTIME)
    ) +
    i01ShareAnnMilePlugInHybrid(runCyL,YTIME) *
    V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,"ELC",YTIME) *
    VmPriceFuelSubsecCarVal.L(runCyL,TRANSE,"ELC",YTIME)
  )$PLUGIN(TTECH) +
  imVarCostTech(runCyL,TRANSE,TTECH,YTIME)
) *
(
  1$(not sameas(TRANSE,"PC")) +
  1e-3 * V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$sameas(TRANSE,"PC")
);
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME) > 0) = V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME);
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME) <= 0 and p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME-1) > 0) = p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME-1);
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME) <= 0 and p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME-1) <= 0) =
  imFixOMCostTech(runCyL,TRANSE,TTECH,YTIME) +
  p01CostFuel(runCyL,TRANSE,TTECH,YTIME);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and p01CostFuel(runCyL,TRANSE,TTECH,YTIME) <= 0) =
  p01CostFuel(runCyL,TRANSE,TTECH,"%fBaseY%");
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$(TIME(YTIME) and SECTTECH(TRANSE,TTECH) and p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME) <= 0) =
  p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,"%fBaseY%");
p01ShareTechTr(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01ShareTechTr.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CapacityTransport(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CapacityTransport.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
*---
