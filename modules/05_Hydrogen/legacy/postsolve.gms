*' @title Postsolve of OPEN-PROMs Hydrogen Module
*' @code
* Fix values of variables for the next time step

* Hydrogen Module

*---
pmConsFuelTechH2Prod(runCyL,H2TECH,EF,YTIME)$TIME(YTIME) = VmConsFuelTechH2Prod.L(runCyL,H2TECH,EF,YTIME)$TIME(YTIME);
p05GapShareH2Tech1(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05GapShareH2Tech1.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
pmProdH2(runCyL,H2TECH,YTIME)$TIME(YTIME) = VmProdH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05DemGapH2(runCyL,YTIME)$TIME(YTIME) = V05DemGapH2.L(runCyL,YTIME)$TIME(YTIME);
pmCostAvgProdH2(runCyL,YTIME)$TIME(YTIME) = VmCostAvgProdH2.L(runCyL,YTIME)$TIME(YTIME);
p05CaptRateH2(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CaptRateH2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostProdCCSNoCCSH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostProdCCSNoCCSH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CostVarProdH2Tech(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CostVarProdH2Tech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05GapShareH2Tech2(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05GapShareH2Tech2.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05CapScrapH2ProdTech(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05CapScrapH2ProdTech.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05PremRepH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05PremRepH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05ScrapLftH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05ScrapLftH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05ShareCCSH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05ShareCCSH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05ShareNoCCSH2Prod(runCyL,H2TECH,YTIME)$TIME(YTIME) = V05ShareNoCCSH2Prod.L(runCyL,H2TECH,YTIME)$TIME(YTIME);
p05AcceptCCSH2Tech(runCyL,YTIME)$TIME(YTIME) = V05AcceptCCSH2Tech.L(runCyL,YTIME)$TIME(YTIME);
pmDemTotH2(runCyL,YTIME)$TIME(YTIME) = VmDemTotH2.L(runCyL,YTIME)$TIME(YTIME);
pmDemSecH2(runCyL,SBS,YTIME)$TIME(YTIME) = VmDemSecH2.L(runCyL,SBS,YTIME)$TIME(YTIME);
pmConsFuelH2Prod(runCyL,EF,YTIME)$TIME(YTIME) = VmConsFuelH2Prod.L(runCyL,EF,YTIME)$TIME(YTIME);
*---

option clear = V05GapShareH2Tech1;
option clear = V05GapShareH2Tech2;
option clear = V05CapScrapH2ProdTech;
option clear = V05PremRepH2Prod;
option clear = V05ScrapLftH2Prod;
option clear = V05DemGapH2;
option clear = V05CostProdH2Tech;
option clear = V05CostVarProdH2Tech;
option clear = V05ShareCCSH2Prod;
option clear = V05ShareNoCCSH2Prod;
option clear = V05AcceptCCSH2Tech;
option clear = V05CostProdCCSNoCCSH2Prod;
option clear = V05CaptRateH2;
option clear = VmDemTotH2;
option clear = VmProdH2;
option clear = VmConsFuelTechH2Prod;
option clear = VmDemSecH2;
option clear = VmCostAvgProdH2;
option clear = VmConsFuelH2Prod;

option clear = Q05GapShareH2Tech1;
option clear = Q05GapShareH2Tech2;
option clear = Q05CapScrapH2ProdTech;
option clear = Q05PremRepH2Prod;
option clear = Q05ScrapLftH2Prod;
option clear = Q05DemGapH2;
option clear = Q05CostProdH2Tech;
option clear = Q05CostVarProdH2Tech;
option clear = Q05ShareCCSH2Prod;
option clear = Q05ShareNoCCSH2Prod;
option clear = Q05AcceptCCSH2Tech;
option clear = Q05ConsFuelH2Prod;
option clear = Q05CostProdCCSNoCCSH2Prod;
option clear = Q05CostAvgProdH2;
option clear = Q05CaptRateH2;
option clear = Q05DemTotH2;
option clear = Q05ProdH2;
option clear = Q05ConsFuelTechH2Prod;
option clear = Q05DemSecH2;
*---
