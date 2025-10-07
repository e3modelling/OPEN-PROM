*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V05GapShareH2Tech1.L(runCy,H2TECH,YTIME) = 1;
display V05GapShareH2Tech1.L;
*---
V05DemGapH2.L(runCy,YTIME) = 2;
V05DemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 0;
display V05DemGapH2.L;
*---
VmProdH2.L(runCy,H2TECH, YTIME) = 0.5;
VmProdH2.LO(runCy,H2TECH, YTIME) = 0;
VmProdH2.FX(runCy,H2TECH, YTIME)$(not An(YTIME)) = 0;
display VmProdH2.L;
*---
VmDemTotH2.L(runCy,YTIME) = 2;
VmDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = sum(H2TECH, VmProdH2.L(runCy,H2TECH,YTIME));
display VmDemTotH2.L;
*---
VmConsFuelTechH2Prod.FX(runCy,H2TECH,EF,"%fBaseY%")$(H2TECHEFtoEF(H2TECH,EF)) = (VmProdH2.L(runCy,H2TECH,"%fBaseY%")/i05EffH2Prod(runCy,H2TECH,"%fBaseY%"));
display i05EffH2Prod;
display VmConsFuelTechH2Prod.L;
*---
V05GapShareH2Tech2.L(runCy,H2TECH,YTIME) = 2;
V05GapShareH2Tech2.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CapScrapH2ProdTech.L(runCy,H2TECH,YTIME) = 2;
V05CapScrapH2ProdTech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display V05CapScrapH2ProdTech.L;
*---
V05ScrapLftH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ScrapLftH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1/i05ProdLftH2(H2TECH,YTIME);
*---
V05CostProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
V05CostProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05CostVarProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
*---
V05ShareCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ShareCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ShareNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05ShareNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VmConsFuelH2Prod.FX(runCy,EF,YTIME)$(not An(YTIME)) = sum(H2TECH$H2TECHEFtoEF(H2TECH,EF),VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME));
*---
V05CostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
V05CostProdCCSNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VmCostAvgProdH2.L(runCy,YTIME) = 2;
VmCostAvgProdH2.FX(runCy,YTIME)$(not An(YTIME)) = 0;
*---
*VmDemSecH2.L(runCy,SBS, YTIME) = 2;
*VmDemSecH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05DemGapH2.scale(runCy,YTIME) = 1e-10;
Q05DemGapH2.scale(runCy,YTIME) = V05DemGapH2.scale(runCy,YTIME);
*---

*--- Ammonia Variable Initializations and Bounds ---

*---
V05ProdAmmHB.LO(runCy,YTIME)                        = 0;
V05ProdAmmHB.UP(runCy,YTIME)                        = i05MaxAmmCapHB(runCy,YTIME);
V05ProdAmmHB.FX(runCy,YTIME)$(not An(YTIME))        = 1e-5;
*---
V05ProdH2AmmHB.LO(runCy,YTIME)                      = 1e-5;
V05ProdH2AmmHB.UP(runCy,YTIME)                      = i05MaxAmmCapHB(runCy,YTIME) * i05EffAmmHB(runCy,YTIME);
V05ProdH2AmmHB.FX(runCy,YTIME)$(not An(YTIME))      = 1e-5;
*---
V05CostProdAmmHB.LO(runCy,YTIME)                    = 1e-5;
V05CostProdAmmHB.FX(runCy,YTIME)$(not An(YTIME))    = 1e-5;
*---`
V05ProdAmmHBCCS.LO(runCy,YTIME)                     = 1e-5;
V05ProdAmmHBCCS.UP(runCy,YTIME)                     = i05MaxAmmCap(runCy,YTIME);
V05ProdAmmHBCCS.FX(runCy,YTIME)$(not An(YTIME))     = 1e-5;
*---
V05ProdH2AmmHBCCS.LO(runCy,YTIME)                   = 1e-5;
V05ProdH2AmmHBCCS.UP(runCy,YTIME)                   = i05MaxAmmCap(runCy,YTIME) * i05EffAmmHB(runCy,YTIME);
V05ProdH2AmmHBCCS.FX(runCy,YTIME)$(not An(YTIME))   = 1e-5;
*---
V05CostProdAmmHBCCS.LO(runCy,YTIME)                 = 1e-5;
V05CostProdAmmHBCCS.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
*---
V05ProdAmmElec.LO(runCy,YTIME)                      = 1e-5;
V05ProdAmmElec.UP(runCy,YTIME)                      = i05MaxAmmCap(runCy,YTIME);
V05ProdAmmElec.FX(runCy,YTIME)$(not An(YTIME))      = 1e-5;
*---
V05ConsElecAmmElec.LO(runCy,YTIME)                  = 1e-5;
V05ConsElecAmmElec.UP(runCy,YTIME)                  = i05MaxAmmCap(runCy,YTIME) * i05EffAmmElec(runCy,YTIME);
V05ConsElecAmmElec.FX(runCy,YTIME)$(not An(YTIME))  = 1e-5;
*---
V05CostProdAmmElec.LO(runCy,YTIME)                  = 1e-5;
V05CostProdAmmElec.FX(runCy,YTIME)$(not An(YTIME))  = 1e-5;
*---
V05ProdAmmCrk.LO(runCy,YTIME)                       = 1e-5;
V05ProdAmmCrk.UP(runCy,YTIME)                       = i05MaxAmmCap(runCy,YTIME);
V05ProdAmmCrk.FX(runCy,YTIME)$(not An(YTIME))       = 1e-5;
*---
V05FeedstockAmmCrk.LO(runCy,YTIME)                  = 1e-5;
V05FeedstockAmmCrk.UP(runCy,YTIME)                  = i05MaxAmmCap(runCy,YTIME) * i05EffAmmCrk(runCy,YTIME);
V05FeedstockAmmCrk.FX(runCy,YTIME)$(not An(YTIME))  = 1e-5;
*---
V05CostProdAmmCrk.LO(runCy,YTIME)                   = 1e-5;
V05CostProdAmmCrk.FX(runCy,YTIME)$(not An(YTIME))   = 1e-5;
*---

$ontext
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
VmConsFuelH2Prod.L(runCy,EF,YTIME) = 2;
*---
V05DelivH2InfrTech.L(runCy,INFRTECH,YTIME) = 2;
V05DelivH2InfrTech.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
V05DelivH2InfrTech.FX(runCy,INFRTECH,"%fBaseY%") = 0;
display V05DelivH2InfrTech.L;
*---
VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0;
*---
V05CostTotH2.L(runCy,SBS,YTIME) = 2;
V05CostTotH2.FX(runCy,TRANSE,YTIME)$(not An(YTIME)) = imFuelPrice(runCy,TRANSE,"H2F",YTIME)$(not An(YTIME)); 
V05CostTotH2.FX(runCy,"PG",YTIME)$(not An(YTIME))   = imFuelPrice(runCy,"PG","H2F",YTIME)$(not An(YTIME)); 
V05CostTotH2.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelPrice(runCy,INDDOM,"STE1AH2F",YTIME)$(not An(YTIME)); 
display V05CostTotH2.L;
*---
$offtext