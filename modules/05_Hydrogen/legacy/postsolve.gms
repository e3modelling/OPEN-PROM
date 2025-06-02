*' @title Postsolve of OPEN-PROMs Hydrogen Module
*' @code
* Fix values of variables for the next time step

* Hydrogen Module

*---
MVConsFuelTechH2Prod.FX(runCyL,H2TECH,EF,YTIME)$TIME(YTIME) = MVConsFuelTechH2Prod.L(runCyL,H2TECH,EF,YTIME)$TIME(YTIME);
V05GapShareH2Tech1.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05GapShareH2Tech1.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
MVProdH2.FX(runCyL,H2TECH,YTIME)$TIME(YTIME) = MVProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
V05DemGapH2.FX(runCyL,YTIME)$TIME(YTIME) = V05DemGapH2.L(runCyL,YTIME)$TIME(YTIME);
V05CostAvgProdH2.FX(runCyL,YTIME)$TIME(YTIME) = V05CostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME);
V05DelivH2InfrTech.FX(runCyL,INFRTECH,YTIME)$TIME(YTIME) = V05DelivH2InfrTech.L(runCyL,INFRTECH,YTIME)$TIME(YTIME);
*---