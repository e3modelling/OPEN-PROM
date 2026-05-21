* Fix values of variables for the next time step

* Transport Module

*---
p01StockPcYearly(runCyL,YTIME)$TIME(YTIME) = V01StockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
p01RateScrPc(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPc.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01RateScrPcTot(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPcTot.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01ActivGoodsTransp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
p01ConsSpecificFuel(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
p01ConsTechTranspSectoral(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
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
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01ShareTechTr(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01ShareTechTr.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
pmDemFinEneTranspPerFuel(runCyL,TRANSE,EF,YTIME)$TIME(YTIME) = VmDemFinEneTranspPerFuel.L(runCyL,TRANSE,EF,YTIME)$TIME(YTIME);
*---

option clear = Q01ActivGoodsTransp;
option clear = Q01GapTranspActiv;
option clear = Q01CostTranspPerMeanConsSize;
option clear = Q01ShareTechTr;
option clear = Q01ConsTechTranspSectoral;
option clear = Q01StockPcYearly;
option clear = Q01StockPcYearlyTech;
option clear = Q01NewRegPcYearly;
option clear = Q01NewRegPcTechYearly;
option clear = Q01ActivPassTrnsp;
option clear = Q01NumPcScrap;
option clear = Q01PcOwnPcLevl;
option clear = Q01RateScrPc;
option clear = Q01CapCostAnnualized;
option clear = Q01CostFuel;
option clear = Q01PremScrp;
option clear = Q01RateScrPcTot;
option clear = Q01DemFinEneTranspPerFuel;
option clear = Q01Lft;

option clear = V01ActivGoodsTransp;
option clear = V01GapTranspActiv;
option clear = V01ConsSpecificFuel;
option clear = V01CostTranspPerMeanConsSize;
option clear = V01ShareTechTr;
option clear = V01ConsTechTranspSectoral;
option clear = V01StockPcYearly;
option clear = V01StockPcYearlyTech;
option clear = V01NewRegPcYearly;
option clear = V01NewRegPcTechYearly;
option clear = V01ActivPassTrnsp;
option clear = V01NumPcScrap;
option clear = V01PcOwnPcLevl;
option clear = V01RateScrPc;
option clear = V01CapCostAnnualized;
option clear = V01CostFuel;
option clear = V01PremScrp;
option clear = V01RateScrPcTot;
option clear = VmDemFinEneTranspPerFuel;
option clear = VmLft;

*---
*' Initialize parameters for every iteration forward (seed from first iteration results)
VmLft.L(runCy,DSBS,TTECH,YTIME) = pmLft(runCy,DSBS,TTECH,YTIME-1);
*' Restore correct .L for DATAY years (pmLft(YTIME-1) is zero for the first historical year)
VmLft.L(runCy,DSBS,TTECH,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,TTECH)) = pmLft(runCy,DSBS,TTECH,YTIME);
V01StockPcYearly.L(runCy,YTIME) = p01StockPcYearly(runCy,YTIME-1);
V01RateScrPc.L(runCy,TTECH,YTIME) = p01RateScrPc(runCy,TTECH,YTIME-1);
V01RateScrPcTot.L(runCy,TTECH,YTIME) = p01RateScrPcTot(runCy,TTECH,YTIME-1);
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME) = p01ActivGoodsTransp(runCy,TRANSE,YTIME-1);
V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME) = p01ConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME-1);
V01ConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME) = p01ConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME-1);
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME) = p01ActivPassTrnsp(runCy,TRANSE,YTIME-1);
V01NewRegPcYearly.L(runCy,YTIME) = p01NewRegPcYearly(runCy,YTIME-1);
V01NewRegPcTechYearly.L(runCy,TTECH,YTIME) = p01NewRegPcTechYearly(runCy,TTECH,YTIME-1);
V01NumPcScrap.L(runCy,YTIME) = p01NumPcScrap(runCy,YTIME-1);
V01StockPcYearlyTech.L(runCy,TTECH,YTIME) = p01StockPcYearlyTech(runCy,TTECH,YTIME-1);
V01PcOwnPcLevl.L(runCy,YTIME) = p01PcOwnPcLevl(runCy,YTIME-1);
V01GapTranspActiv.L(runCy,TRANSE,YTIME) = p01GapTranspActiv(runCy,TRANSE,YTIME-1);
V01PremScrp.L(runCy,TRANSE,TTECH,YTIME) = p01PremScrp(runCy,TRANSE,TTECH,YTIME-1);
V01CapCostAnnualized.L(runCy,TRANSE,TTECH,YTIME) = p01CapCostAnnualized(runCy,TRANSE,TTECH,YTIME-1);
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME) = p01CostTranspPerMeanConsSize(runCy,TRANSE,TTECH,YTIME-1);
V01CostFuel.L(runCy,TRANSE,TTECH,YTIME) = p01CostFuel(runCy,TRANSE,TTECH,YTIME-1);
V01ShareTechTr.L(runCy,TRANSE,TTECH,YTIME) = p01ShareTechTr(runCy,TRANSE,TTECH,YTIME-1);
VmDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME) = pmDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME-1);
