*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V05CostTotH2.L(runCy,SBS,YTIME) = 2;
V05CostTotH2.FX(runCy,TRANSE,"2010") = iFuelPrice(runCy,TRANSE,"H2F","2010"); 
V05CostTotH2.FX(runCy,"PG","2010") = iFuelPrice(runCy,"PG","H2F","2010"); 
V05CostTotH2.FX(runCy,INDDOM,"2010") = iFuelPrice(runCy,INDDOM,"STE1AH2F","2010"); 
V05CostTotH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
display V05CostTotH2.L;
*---
V05GapShareH2Tech1.L(runCy,H2TECH,YTIME) = 2;
V05GapShareH2Tech1.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display V05GapShareH2Tech1.L;
*---
V05DemGapH2.L(runCy,YTIME) = 2;
V05DemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
display V05DemGapH2.L;
*---
MVProdH2.L(runCy,H2TECH, YTIME) = 2;
MVProdH2.FX(runCy,H2TECH, YTIME)$(not An(YTIME)) = 1e-5;
MVProdH2.FX(runCy,H2TECH,"2010") = 1e-7;
display MVProdH2.L;
*---
MVDemTotH2.L(runCy,YTIME) = 2;
MVDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
MVDemTotH2.FX(runCy,"2010") = sum(H2TECH, MVProdH2.L(runCy,H2TECH,"2010"));
display MVDemTotH2.L;
*---
MVConsFuelTechH2Prod.FX(runCy,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0;
MVConsFuelTechH2Prod.FX(runCy,H2TECH,EF,"2010")$(H2TECHEFtoEF(H2TECH,EF)) = (MVProdH2.L(runCy,H2TECH,"2010")/iEffH2Prod(runCy,H2TECH,"2010"));
display iEffH2Prod;
display MVConsFuelTechH2Prod.L;
*---
V05DelivH2InfrTech.L(runCy,INFRTECH,YTIME) = 2;
V05DelivH2InfrTech.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
V05DelivH2InfrTech.FX(runCy,INFRTECH,"2010") = 0;
display V05DelivH2InfrTech.L;
*---
V05GapShareH2Tech2.L(runCy,H2TECH,YTIME) = 2;
V05GapShareH2Tech2.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CapScrapH2ProdTech.L(runCy,H2TECH,YTIME) = 2;
V05CapScrapH2ProdTech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display V05CapScrapH2ProdTech.L;
*---
V05PremRepH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05PremRepH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ScrapLftH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ScrapLftH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05CostProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostVarProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05CostVarProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ShareCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ShareCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ShareNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ShareNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ConsFuelH2Prod.L(runCy,EF,YTIME) = 2;
V05ConsFuelH2Prod.FX(runCy,EF,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05CostProdCCSNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostAvgProdH2.L(runCy,YTIME) = 2;
V05CostAvgProdH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05InvNewReqH2Infra.L(runCy,INFRTECH,YTIME) = 2;
V05InvNewReqH2Infra.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostInvTechH2Infr.L(runCy, INFRTECH,YTIME) = 2;
V05CostInvTechH2Infr.FX(runCy, INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostInvCummH2Transp.L(runCy,INFRTECH,YTIME) = 2;
V05CostInvCummH2Transp.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05TariffH2Infr.L(runCy,INFRTECH,YTIME) = 2;
V05TariffH2Infr.FX(runCy,INFRTECH,YTIME) $(not An(YTIME)) = 1e-5;
*---
V05PriceH2Infr.L(runCy,SBS,YTIME) = 2;
V05PriceH2Infr.FX(runCy,SBS,YTIME)  $(not An(YTIME)) = 1e-5;
*---
V05H2InfrArea.L(runCy,YTIME) = 10;
*-----------------------------------------------------------------------
*' *** Miscellaneous
*---
V05DemSecH2.FX(runCy,SBS,YTIME) = 1e-5;
*---
*-----------------------------------------------------------------------