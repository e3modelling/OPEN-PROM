*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostTotH2.FX(runCy,TRANSE,"2005") = EFPRICE(runCy,TRANSE,"H2F","2005"); !! *Needs to be renamed (EFPRICE). Cannot find it in PROMETHEUS model.
VCostTotH2.FX(runCy,"PG","2005") = EFPRICE(runCy,"PG","H2F","2005"); !! *Needs to be renamed (EFPRICE).
VCostTotH2.FX(runCy,INDDOM,"2005") = EFPRICE(runCy,INDDOM,"STE1AH2F","2005"); !! *Needs to be renamed (EFPRICE).
VCostTotH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
VCostTotH2.L(runCy,SBS,YTIME) = 2;
*---
VGapShareH2Tech1.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 0;
VGapShareH2Tech1.L(runCy,h2tech, YTIME) = 2;
VGapShareH2Tech1.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VDemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 0 ;
VDemGapH2.L(runCy, YTIME) = 2;
VDemGapH2.FX(runCy, YTIME)$(not An(YTIME)) = 1e-5;
*---
VProdH2.FX(runCy,H2TECH,"2005") = 1e-7;
VProdH2.L(runCy,h2tech, YTIME) = 2;
VProdH2.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VConsFuelTechH2Prod.FX(runCy,H2TECH,EF,"2005")$(H2TECHEFtoEF(H2TECH,EF)) = (VProdH2.L(runCy,H2TECH,"2005")/iEffH2Prod(runCy,H2TECH,"2005"));
VConsFuelTechH2Prod.FX(runCy,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0;
*---
VDelivH2InfrTech.FX(runCy,INFRTECH,"2005") = 0;
VDelivH2InfrTech.L(runCy,INFRTECH,YTIME) = 2;
VDelivH2InfrTech.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VGapShareH2Tech2.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
VGapShareH2Tech2.L(runCy,h2tech, YTIME) = 2;
*---
VCapScrapH2ProdTech.L(runCy,h2tech, YTIME) = 2;
VCapScrapH2ProdTech.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VPremRepH2Prod.L(runCy,h2tech, YTIME) = 2;
VPremRepH2Prod.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VScrapLftH2Prod.L(runCy,h2tech, YTIME) = 2;
VScrapLftH2Prod.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
VCostProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostVarProdH2Tech.L(runCy,H2TECH,YTIME) = 2;
VCostVarProdH2Tech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VShareCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
VShareCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VShareNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
VShareNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VConsFuelH2Prod.L(runCy,EF,YTIME) = 2;
VConsFuelH2Prod.FX(runCy,EF,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostProdCCSNoCCSH2Prod.L(runCy,H2TECH,YTIME) = 2;
VCostProdCCSNoCCSH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostAvgProdH2.L(runCy,YTIME) = 2;
VCostAvgProdH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
*---
VInvNewReqH2Infra.L(runCy,INFRTECH,YTIME) = 2;
VInvNewReqH2Infra.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostInvTechH2Infr.L(runCy, INFRTECH,YTIME) = 2;
VCostInvTechH2Infr.FX(runCy, INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostInvCummH2Transp.L(runCy,INFRTECH,YTIME) = 2;
VCostInvCummH2Transp.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VTariffH2Infr.L(runCy,INFRTECH,YTIME) = 2;
VTariffH2Infr.FX(runCy,INFRTECH,YTIME) $(not An(YTIME)) = 1e-5;
*---
VPriceH2Infr.L(runCy,SBS,YTIME) = 2;
VPriceH2Infr.FX(runCy,SBS,YTIME)  $(not An(YTIME)) = 1e-5;
*---
VH2InfrArea.l(runCy,ytime) = 10;
*-----------------------------------------------------------------------
*' *** Miscellaneous
*---
VDemTotH2.FX(runCy,"2005") = sum(H2TECH, VProdH2.L(runCy,H2TECH,"2005"));
VDemTotH2.L(runCy,YTIME) = 2;
VDemTotH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
*---
VProdCapH2Tech.L(runCy,h2tech, YTIME) = 2;
VProdCapH2Tech.FX(runCy,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*-----------------------------------------------------------------------
VDemSecH2.FX(runCy,SBS, "2005") = VDemTotH2.L(runCy,"2005");
VDemSecH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
*VDemSecH2.L(runCy,SBS, YTIME) = 2;
*---