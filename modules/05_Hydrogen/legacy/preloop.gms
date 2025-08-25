*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V05CostTotH2.L(runCy,SBS,YTIME) = 2;
V05CostTotH2.FX(runCy,TRANSE,"2010") = imFuelPrice(runCy,TRANSE,"H2F","2010"); 
V05CostTotH2.FX(runCy,"PG","2010") = imFuelPrice(runCy,"PG","H2F","2010"); 
V05CostTotH2.FX(runCy,INDDOM,"2010") = imFuelPrice(runCy,INDDOM,"STE1AH2F","2010"); 
V05CostTotH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
display V05CostTotH2.L;
*---
V05GapShareH2Tech1.L(runCy,H2TECH,YTIME) = 2;
V05GapShareH2Tech1.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display V05GapShareH2Tech1.L;
*---
V05DemGapH2.LO(runCy, YTIME) = -0.5 ;
V05DemGapH2.L(runCy,YTIME) = 2;
V05DemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
display V05DemGapH2.L;
*---
VmProdH2.L(runCy,H2TECH, YTIME) = 0.5;
VmProdH2.LO(runCy,H2TECH, YTIME) = 0;
VmProdH2.FX(runCy,H2TECH, YTIME)$(not An(YTIME)) = 1e-5;
*VmProdH2.FX(runCy,H2TECH,"2010") = 1e-7;
display VmProdH2.L;
*---
VmDemTotH2.L(runCy,YTIME) = 2;
*VmDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
VmDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = sum(H2TECH, VmProdH2.L(runCy,H2TECH,YTIME));
display VmDemTotH2.L;
*---
VmConsFuelTechH2Prod.FX(runCy,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0.001;
VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,"2020")$(H2TECHEFtoEF(H2TECH,EF)) = (VmProdH2.L(runCy,H2TECH,"2020")/i05EffH2Prod(runCy,H2TECH,"2020"));
display i05EffH2Prod;
display VmConsFuelTechH2Prod.L;
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
V05H2InfrArea.L(runCy,YTIME) = 0.001;
*---
VmDemSecH2.L(runCy,SBS, YTIME) = 2;
VmDemSecH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
*---