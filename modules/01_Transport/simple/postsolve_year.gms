* Transport Module

*' Clear variables and equations (outside country loop — preserves no bounds for next year)
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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/01_Transport/simple/preloop.gms"

*' Initialize parameters for every iteration forward (seed from first iteration results)
VmLft.L(runCy,DSBS,TTECH,YTIME+1) = pmLft(runCy,DSBS,TTECH,YTIME-1);
V01StockPcYearly.L(runCy,YTIME+1) = p01StockPcYearly(runCy,YTIME-1);
V01RateScrPc.L(runCy,TTECH,YTIME+1) = p01RateScrPc(runCy,TTECH,YTIME-1);
V01RateScrPcTot.L(runCy,TTECH,YTIME+1) = p01RateScrPcTot(runCy,TTECH,YTIME-1);
V01ActivGoodsTransp.L(runCy,TRANSE,YTIME+1) = p01ActivGoodsTransp(runCy,TRANSE,YTIME-1);
V01ConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME+1) = p01ConsSpecificFuel(runCy,TRANSE,TTECH,EF,YTIME-1);
V01ConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME+1) = p01ConsTechTranspSectoral(runCy,TRANSE,TTECH,EF,YTIME-1);
V01ActivPassTrnsp.L(runCy,TRANSE,YTIME+1) = p01ActivPassTrnsp(runCy,TRANSE,YTIME-1);
V01NewRegPcYearly.L(runCy,YTIME+1) = p01NewRegPcYearly(runCy,YTIME-1);
V01NewRegPcTechYearly.L(runCy,TTECH,YTIME+1) = p01NewRegPcTechYearly(runCy,TTECH,YTIME-1);
V01NumPcScrap.L(runCy,YTIME+1) = p01NumPcScrap(runCy,YTIME-1);
V01StockPcYearlyTech.L(runCy,TTECH,YTIME+1) = p01StockPcYearlyTech(runCy,TTECH,YTIME-1);
V01PcOwnPcLevl.L(runCy,YTIME+1) = p01PcOwnPcLevl(runCy,YTIME-1);
V01GapTranspActiv.L(runCy,TRANSE,YTIME+1) = p01GapTranspActiv(runCy,TRANSE,YTIME-1);
V01PremScrp.L(runCy,TRANSE,TTECH,YTIME+1) = p01PremScrp(runCy,TRANSE,TTECH,YTIME-1);
V01CapCostAnnualized.L(runCy,TRANSE,TTECH,YTIME+1) = p01CapCostAnnualized(runCy,TRANSE,TTECH,YTIME-1);
V01CostTranspPerMeanConsSize.L(runCy,TRANSE,TTECH,YTIME+1) = p01CostTranspPerMeanConsSize(runCy,TRANSE,TTECH,YTIME-1);
V01CostFuel.L(runCy,TRANSE,TTECH,YTIME+1) = p01CostFuel(runCy,TRANSE,TTECH,YTIME-1);
V01ShareTechTr.L(runCy,TRANSE,TTECH,YTIME+1) = p01ShareTechTr(runCy,TRANSE,TTECH,YTIME-1);
VmDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME+1) = pmDemFinEneTranspPerFuel(runCy,TRANSE,EF,YTIME-1);