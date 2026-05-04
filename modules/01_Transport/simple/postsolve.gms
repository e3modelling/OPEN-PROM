* Store values of variables as parameters for the next time step

* Transport Module

*---
p01ActivGoodsTransp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
p01ActivPassTrnsp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
p01ConsTechTranspSectoral(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
pmLft(runCyL,DSBS,TECH,YTIME)$TIME(YTIME) = VmLft.L(runCyL,DSBS,TECH,YTIME)$TIME(YTIME);
p01StockPcYearlyTech(runCyL,TTECH,YTIME)$TIME(YTIME) = V01StockPcYearlyTech.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01StockPcYearly(runCyL,YTIME)$TIME(YTIME) = V01StockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
p01PcOwnPcLevl(runCyL,YTIME)$TIME(YTIME) = V01PcOwnPcLevl.L(runCyL,YTIME)$TIME(YTIME);
p01RateScrPc(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPc.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01RateScrPcTot(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPcTot.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01NewRegPcYearly(runCyL,YTIME)$TIME(YTIME) = V01NewRegPcYearly.L(runCyL,YTIME)$TIME(YTIME);
p01NewRegPcTechYearly(runCyL,TTECH,YTIME)$TIME(YTIME) = V01NewRegPcTechYearly.L(runCyL,TTECH,YTIME)$TIME(YTIME);
p01NumPcScrap(runCyL,YTIME)$TIME(YTIME) = V01NumPcScrap.L(runCyL,YTIME)$TIME(YTIME);
p01PremScrp(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01PremScrp.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CostFuel(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);

*---
*' Clear variables for the next time step'
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
*' Clear equations for the next time step'
option clear = Q01Lft;
option clear = Q01ActivGoodsTransp;
option clear = Q01GapTranspActiv;
option clear = Q01CapCostAnnualized;
option clear = Q01CostFuel;
option clear = Q01CostTranspPerMeanConsSize;
option clear = Q01ShareTechTr;
option clear = Q01ConsTechTranspSectoral;
option clear = Q01DemFinEneTranspPerFuel;
option clear = Q01StockPcYearly;
option clear = Q01StockPcYearlyTech;
option clear = Q01NewRegPcYearly;
option clear = Q01NewRegPcTechYearly;
option clear = Q01ActivPassTrnsp;
option clear = Q01NumPcScrap;
option clear = Q01PcOwnPcLevl;
option clear = Q01RateScrPc;
option clear = Q01RateScrPcTot;
option clear = Q01PremScrp;

V01ActivGoodsTransp.L(allCy,TRANSE,YTIME)$TIME(YTIME) = p01ActivGoodsTransp(allCy,TRANSE,YTIME)$TIME(YTIME);
V01ActivPassTrnsp.L(allCy,TRANSE,YTIME)$TIME(YTIME) = p01ActivPassTrnsp(allCy,TRANSE,YTIME)$TIME(YTIME);
V01StockPcYearly.L(allCy,YTIME)$TIME(YTIME) = p01StockPcYearly(allCy,YTIME)$TIME(YTIME);
V01PcOwnPcLevl.L(allCy,YTIME)$TIME(YTIME) = p01PcOwnPcLevl(allCy,YTIME)$TIME(YTIME);
V01RateScrPc.LO(allCy,TTECH,YTIME)$TIME(YTIME) = 1e-3;
V01RateScrPc.UP(allCy,TTECH,YTIME)$TIME(YTIME) = 1;
V01RateScrPc.L(allCy,TTECH,YTIME)$TIME(YTIME) = 1e-3;
V01RateScrPc.L(allCy,TTECH,YTIME)$(TIME(YTIME) and p01RateScrPc(allCy,TTECH,YTIME) gt 1e-3) = p01RateScrPc(allCy,TTECH,YTIME);
V01NewRegPcTechYearly.L(allCy,TTECH,YTIME)$TIME(YTIME) = p01NewRegPcTechYearly(allCy,TTECH,YTIME)$TIME(YTIME);
V01CostFuel.L(allCy,TRANSE,TTECH,YTIME)$TIME(YTIME) = p01CostFuel(allCy,TRANSE,TTECH,YTIME)$TIME(YTIME);
V01CostTranspPerMeanConsSize.L(allCy,TRANSE,TTECH,YTIME)$TIME(YTIME) = p01CostTranspPerMeanConsSize(allCy,TRANSE,TTECH,YTIME)$TIME(YTIME);
VmLft.LO(allCy,DSBS,TECH,YTIME)$TIME(YTIME) = 1e-3;
VmLft.L(allCy,DSBS,TECH,YTIME)$TIME(YTIME) = 1;
VmLft.L(allCy,DSBS,TECH,YTIME)$(TIME(YTIME) and pmLft(allCy,DSBS,TECH,YTIME) gt 1) = pmLft(allCy,DSBS,TECH,YTIME);
VmDemFinEneTranspPerFuel.L(allCy,TRANSE,EF,YTIME)$TIME(YTIME) = 1;
*---