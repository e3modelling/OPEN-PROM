* Transport Module

*' Clear variables and equations (outside country loop — preserves no bounds for next year)
option clear = Q01ActivGoodsTransp;
option clear = Q01GapTranspActiv;
option clear = Q01CostTranspPerMeanConsSize;
option clear = Q01ShareTechTr;
option clear = Q01StockPcYearly;
option clear = Q01StockPcYearlyTech;
option clear = Q01NewRegPcYearly;
option clear = Q01NewRegPcTechYearly;
option clear = Q01ActivPassTrnsp;
option clear = Q01NumPcScrap;
option clear = Q01PcOwnPcLevl;
option clear = Q01CapCostAnnualized;
option clear = Q01CostFuel;
option clear = Q01PremScrp;
option clear = Q01RateScrPcTot;

option clear = V01ActivGoodsTransp;
option clear = V01GapTranspActiv;
option clear = V01ConsSpecificFuel;
option clear = V01CostTranspPerMeanConsSize;
option clear = V01ShareTechTr;
option clear = V01StockPcYearly;
option clear = V01StockPcYearlyTech;
option clear = V01NewRegPcYearly;
option clear = V01NewRegPcTechYearly;
option clear = V01ActivPassTrnsp;
option clear = V01NumPcScrap;
option clear = V01PcOwnPcLevl;
option clear = V01CapCostAnnualized;
option clear = V01CostFuel;
option clear = V01PremScrp;
option clear = V01RateScrPcTot;

*' Re-apply critical bounds for all active countries (outside country loop)
V01PremScrp.UP(runCyL,TRANSE,TTECH,YTIME+1) = 1;
V01PremScrp.LO(runCyL,TRANSE,TTECH,YTIME+1) = 0;
V01PcOwnPcLevl.UP(runCyL,YTIME+1) = 2*i01PassCarsMarkSat(runCyL);
V01GapTranspActiv.LO(runCyL,TRANSE,YTIME+1) = 0;
V01GapTranspActiv.FX(runCyL,TRANSE,YTIME+1)$(not AN(YTIME+1)) = 0;
V01CapCostAnnualized.LO(runCyL,TRANSE,TTECH,YTIME+1) = 0;
V01CostFuel.LO(runCyL,TRANSE,TTECH,YTIME+1) = -epsilon6;
V01CostTranspPerMeanConsSize.LO(runCyL,TRANSE,TTECH,YTIME+1) = 0;
V01ShareTechTr.LO(runCyL,TRANSE,TTECH,YTIME+1) = 0;

*' Initialize parameters for every iteration forward (seed from first iteration results)
V01StockPcYearly.L(runCyL,YTIME+1) = p01StockPcYearly(runCyL,YTIME);
V01RateScrPcTot.L(runCyL,TRANSE,TTECH,YTIME+1) = p01RateScrPcTot(runCyL,TRANSE,TTECH,YTIME);
V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME+1) = p01ActivGoodsTransp(runCyL,TRANSE,YTIME);
V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME+1) = p01ConsSpecificFuel(runCyL,TRANSE,TTECH,EF,YTIME);
V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME+1) = p01ActivPassTrnsp(runCyL,TRANSE,YTIME);
V01NewRegPcYearly.L(runCyL,YTIME+1) = p01NewRegPcYearly(runCyL,YTIME);
V01NewRegPcTechYearly.L(runCyL,TTECH,YTIME+1) = p01NewRegPcTechYearly(runCyL,TTECH,YTIME);
V01NumPcScrap.L(runCyL,YTIME+1) = p01NumPcScrap(runCyL,YTIME);
V01StockPcYearlyTech.L(runCyL,TTECH,YTIME+1) = p01StockPcYearlyTech(runCyL,TTECH,YTIME);
V01PcOwnPcLevl.L(runCyL,YTIME+1) = p01PcOwnPcLevl(runCyL,YTIME);
V01GapTranspActiv.L(runCyL,TRANSE,YTIME+1) = p01GapTranspActiv(runCyL,TRANSE,YTIME);
V01PremScrp.L(runCyL,TRANSE,TTECH,YTIME+1) = p01PremScrp(runCyL,TRANSE,TTECH,YTIME);
V01CapCostAnnualized.L(runCyL,TRANSE,TTECH,YTIME+1) = p01CapCostAnnualized(runCyL,TRANSE,TTECH,YTIME);
V01CostTranspPerMeanConsSize.L(runCyL,TRANSE,TTECH,YTIME+1) = p01CostTranspPerMeanConsSize(runCyL,TRANSE,TTECH,YTIME);
V01CostFuel.L(runCyL,TRANSE,TTECH,YTIME+1) = p01CostFuel(runCyL,TRANSE,TTECH,YTIME);
V01ShareTechTr.L(runCyL,TRANSE,TTECH,YTIME+1) = p01ShareTechTr(runCyL,TRANSE,TTECH,YTIME);
V01CapacityTransport.L(runCyL,TRANSE,TTECH,YTIME+1) = p01CapacityTransport(runCyL,TRANSE,TTECH,YTIME);
