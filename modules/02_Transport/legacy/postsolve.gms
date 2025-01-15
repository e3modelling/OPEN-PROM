* Fix values of variables for the next time step

* Transport Module
VStockPcYearly.FX(runCyL,YTIME)$TIME(YTIME) = VStockPcYearly.L(runCyL,YTIME)$TIME(YTIME);
VMEPcGdp.FX(runCyL,YTIME)$TIME(YTIME) = VMEPcGdp.L(runCyL,YTIME)$TIME(YTIME);
VRateScrPc.FX(runCyL,YTIME)$TIME(YTIME) = VRateScrPc.L(runCyL,YTIME)$TIME(YTIME);
VActivGoodsTransp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = VActivGoodsTransp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);
VConsSpecificFuel.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsSpecificFuel.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VConsTechTranspSectoral.FX(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME) = VConsTechTranspSectoral.L(runCyL,TRANSE,TTECH,EF,YTIME)$TIME(YTIME);
VActivPassTrnsp.FX(runCyL,TRANSE,YTIME)$TIME(YTIME) = VActivPassTrnsp.L(runCyL,TRANSE,YTIME)$TIME(YTIME);