* Fix values of variables for the next time step

* Transport Module

*---
V01StockPcYearly.FX(runCyL,YTIME)$TIME(YTIME) = V01StockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
V01MEPcGdp.FX(runCyL,YTIME)$TIME(YTIME) = V01MEPcGdp.L(runCyL,YTIME)$TIME(YTIME);
V01RateScrPc.FX(runCyL,YTIME)$TIME(YTIME) = V01RateScrPc.L(runCyL,YTIME)$TIME(YTIME);
V01ActivGoodsTransp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
V01ConsSpecificFuel.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
V01ConsTechTranspSectoral.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = V01ConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
V01ActivPassTrnsp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = V01ActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
VmLft.FX(runCyL,DSBS,EF,YTIME)$TIME(YTIME) = VmLft.L(runCyL,DSBS,EF,YTIME)$TIME(YTIME);
*---