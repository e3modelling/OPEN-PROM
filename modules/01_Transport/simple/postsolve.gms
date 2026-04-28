* Fix values of variables for the next time step

* Transport Module

*---
V01RateScrPcTot.FX(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPcTot.L(runCyL,TTECH,YTIME)$TIME(YTIME);
i01ActivGoodsTransp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
V01ConsSpecificFuel.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
i01ConsTechTranspSectoral(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
V01ActivPassTrnsp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
i01ActivPassTrnsp(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
VmLft.FX(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME) = VmLft.L(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME);
imLft(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME) = VmLft.L(runCyL,DSBS,TTECH,YTIME)$TIME(YTIME);
V01NewRegPcYearly.FX(runCyL,YTIME)$TIME(YTIME) = V01NewRegPcYearly.L(runCyL,YTIME)$TIME(YTIME);
V01NumPcScrap.FX(runCyL,YTIME)$TIME(YTIME) = V01NumPcScrap.L(runCyL,YTIME)$TIME(YTIME);
i01StockPcYearlyTech(runCyL,TTECH,YTIME)$TIME(YTIME) = V01StockPcYearlyTech.L(runCyL,TTECH,YTIME)$TIME(YTIME);
i01StockPcYearly(runCyL,YTIME)$TIME(YTIME) = V01StockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
i01PcOwnPcLevl(runCyL,YTIME)$TIME(YTIME) = V01PcOwnPcLevl.L(runCyL,YTIME)$TIME(YTIME);
i01RateScrPc(runCyL,TTECH,YTIME)$TIME(YTIME) = V01RateScrPc.L(runCyL,TTECH,YTIME)$TIME(YTIME);
i01CostFuel(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
i01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);
V01PremScrp.FX(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME) = V01PremScrp.L(runCyL,TRANSE,TTECH,YTIME)$TIME(YTIME);

option clear = Q01ActivGoodsTransp;
option clear = Q01GapTranspActiv;
option clear = Q01StockPcYearlyTech;
option clear = Q01ActivPassTrnsp;
option clear = Q01NumPcScrap;
option clear = Q01ShareTechTr;
option clear = Q01ConsTechTranspSectoral;
option clear = Q01NewRegPcYearly;
option clear = Q01RateScrPc;
option clear = Q01PremScrp;
*---