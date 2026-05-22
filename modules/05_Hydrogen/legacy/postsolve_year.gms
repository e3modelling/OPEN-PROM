*' Clear variables and equations (outside country loop — preserves no bounds for next year)
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

*' Re-apply preloop bounds for all active countries (outside country loop)
$include "./modules/05_Hydrogen/legacy/preloop.gms"

*' Initialize variable levels from previous period parameter
V05GapShareH2Tech1.L(runCy,H2TECH,YTIME) = p05GapShareH2Tech1(runCy,H2TECH,YTIME-1);
V05GapShareH2Tech2.L(runCy,H2TECH,YTIME) = p05GapShareH2Tech2(runCy,H2TECH,YTIME-1);
V05CapScrapH2ProdTech.L(runCy,H2TECH,YTIME) = p05CapScrapH2ProdTech(runCy,H2TECH,YTIME-1);
V05PremRepH2Prod.L(runCy,H2TECH,YTIME) = p05PremRepH2Prod(runCy,H2TECH,YTIME-1);
V05ScrapLftH2Prod.L(runCy,H2TECH,YTIME) = p05ScrapLftH2Prod(runCy,H2TECH,YTIME-1);
V05DemGapH2.L(runCy,YTIME) = p05DemGapH2(runCy,YTIME-1);
V05CostProdH2Tech.L(runCy,H2TECH,YTIME) = p05CostProdH2Tech(runCy,H2TECH,YTIME-1);
V05CostVarProdH2Tech.L(runCy,H2TECH,YTIME) = p05CostVarProdH2Tech(runCy,H2TECH,YTIME-1);
V05ShareCCSH2Prod.L(runCy,H2TECH,YTIME) = p05ShareCCSH2Prod(runCy,H2TECH,YTIME-1);
V05ShareNoCCSH2Prod.L(runCy,H2TECH,YTIME) = p05ShareNoCCSH2Prod(runCy,H2TECH,YTIME-1);
V05AcceptCCSH2Tech.L(runCy,YTIME) = p05AcceptCCSH2Tech(runCy,YTIME-1);
V05CostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = p05CostProdCCSNoCCSH2Prod(runCy,H2TECH,YTIME-1);
V05CaptRateH2.L(runCy,H2TECH,YTIME) = p05CaptRateH2(runCy,H2TECH,YTIME-1);
VmDemTotH2.L(runCy,YTIME) = pmDemTotH2(runCy,YTIME-1);
VmProdH2.L(runCy,H2TECH,YTIME) = pmProdH2(runCy,H2TECH,YTIME-1);
VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME) = pmConsFuelTechH2Prod(runCy,H2TECH,EF,YTIME-1);
VmDemSecH2.L(runCy,SBS,YTIME) = pmDemSecH2(runCy,SBS,YTIME-1);
VmCostAvgProdH2.L(runCy,YTIME) = pmCostAvgProdH2(runCy,YTIME-1);
VmConsFuelH2Prod.L(runCy,EF,YTIME) = pmConsFuelH2Prod(runCy,EF,YTIME-1);
