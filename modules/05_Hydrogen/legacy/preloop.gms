*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V05GapShareH2Tech1.UP(runCy,H2TECH,YTIME) = 1;
V05GapShareH2Tech1.LO(runCy,H2TECH,YTIME) = 0;
V05GapShareH2Tech1.FX(runCy,H2TECH,YTIME)$DATAY(YTIME) = 0;
*---
V05DemGapH2.L(runCy,YTIME) = 2;
V05DemGapH2.FX(runCy,YTIME)$DATAY(YTIME) = 0;
*---
VmProdH2.L(runCy,H2TECH, YTIME) = 0.5;
VmProdH2.LO(runCy,H2TECH, YTIME) = 0;
VmProdH2.FX(runCy,H2TECH, YTIME)$DATAY(YTIME) = 0;
*---
VmDemTotH2.L(runCy,YTIME) = 2;
VmDemTotH2.FX(runCy,YTIME)$DATAY(YTIME) = sum(H2TECH, VmProdH2.L(runCy,H2TECH,YTIME));
*---
VmConsFuelTechH2Prod.FX(runCy,H2TECH,EF,"%fBaseY%")$(H2TECHEFtoEF(H2TECH,EF)) = (VmProdH2.L(runCy,H2TECH,"%fBaseY%")/i05EffH2Prod(runCy,H2TECH,"%fBaseY%"));
*---
V05GapShareH2Tech2.LO(runCy,H2TECH,YTIME) = 0;
V05GapShareH2Tech2.UP(runCy,H2TECH,YTIME) = 1;
*---
V05CapScrapH2ProdTech.LO(runCy,H2TECH,YTIME) = 0;
V05CapScrapH2ProdTech.UP(runCy,H2TECH,YTIME) = 1;
*---
V05ScrapLftH2Prod.UP(runCy,H2TECH,YTIME) = 1;
V05ScrapLftH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ScrapLftH2Prod.FX(runCy,H2TECH,YTIME)$DATAY(YTIME) = 1/i05ProdLftH2(H2TECH,YTIME);
*---
V05CostProdH2Tech.LO(runCy,H2TECH,YTIME) = epsilon6;
V05CostProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05CostProdH2Tech.FX(runCy,H2TECH,YTIME)$DATAY(YTIME) = 1e-5;
*---
V05CostVarProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
*---
V05ShareCCSH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ShareCCSH2Prod.UP(runCy,H2TECH,YTIME) = 1;
*---
V05ShareNoCCSH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05ShareNoCCSH2Prod.UP(runCy,H2TECH,YTIME) = 1;
*---
VmConsFuelH2Prod.FX(runCy,EF,YTIME)$DATAY(YTIME) = sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME));
*---
V05CostProdCCSNoCCSH2Prod.LO(runCy,H2TECH,YTIME) = epsilon6;
V05CostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
*---
VmCostAvgProdH2.L(runCy,YTIME) = 2;
VmCostAvgProdH2.FX(runCy,YTIME)$DATAY(YTIME) = 0;
*---
V05DemGapH2.LO(runCy,YTIME) = 0;
*---
V05PremRepH2Prod.LO(runCy,H2TECH,YTIME) = 0;
V05PremRepH2Prod.UP(runCy,H2TECH,YTIME) = 1;
V05PremRepH2Prod.FX(runCy,H2TECH,YTIME)$(not H2TECHPM(H2TECH)) = 1;
*---