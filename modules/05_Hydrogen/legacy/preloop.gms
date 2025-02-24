*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostTotH2.FX(cyrun,TRANSE,"2005") = EFPRICE(cyrun,TRANSE,"H2F","2005"); !! *Needs to be renamed (EFPRICE). Cannot find it in PROMETHEUS model.
VCostTotH2.FX(cyrun,"PG","2005") = EFPRICE(cyrun,"PG","H2F","2005"); !! *Needs to be renamed (EFPRICE).
VCostTotH2.FX(cyrun,INDDOM,"2005") = EFPRICE(cyrun,INDDOM,"STE1AH2F","2005"); !! *Needs to be renamed (EFPRICE).
VCostTotH2.FX(CYall,SBS,YTIME)$(not An(YTIME)) = 1e-5;
VCostTotH2.L(CYall,SBS,YTIME) = 2;
*---
VGapShareH2Tech1.FX(cyrun,H2TECH,YTIME)$(not An(YTIME)) = 0;
VGapShareH2Tech1.L(CYall,h2tech, YTIME) = 2;
VGapShareH2Tech1.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VDemGapH2.FX(cyrun,YTIME)$(not An(YTIME)) = 0 ;
VDemGapH2.L(CYall, YTIME) = 2;
VDemGapH2.FX(CYall, YTIME)$(not An(YTIME)) = 1e-5;
*---
VProdH2.FX(cyrun,H2TECH,"2005") = 1e-7;
VProdH2.L(CYall,h2tech, YTIME) = 2;
VProdH2.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VConsFuelTechH2Prod.FX(cyrun,H2TECH,EF,"2005")$(H2TECHEFtoEF(H2TECH,EF)) = (VProdH2.L(cyrun,H2TECH,"2005")/iEffH2Prod(cyrun,H2TECH,"2005"));
VConsFuelTechH2Prod.FX(CYALL,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0;
*---
VDelivH2InfrTech.FX(cyrun,INFRTECH,"2005") = 0;
VDelivH2InfrTech.L(CYall,INFRTECH,YTIME) = 2;
VDelivH2InfrTech.FX(CYall,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VGapShareH2Tech2.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
VGapShareH2Tech2.L(CYall,h2tech, YTIME) = 2;
*---
VCapScrapH2ProdTech.L(CYall,h2tech, YTIME) = 2;
VCapScrapH2ProdTech.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VPremRepH2Prod.L(CYall,h2tech, YTIME) = 2;
VPremRepH2Prod.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VScrapLftH2Prod.L(CYall,h2tech, YTIME) = 2;
VScrapLftH2Prod.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostProdH2Tech.L(CYall,H2TECH,YTIME) = 2;
VCostProdH2Tech.FX(CYall,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostVarProdH2Tech.L(CYall,H2TECH,YTIME) = 2;
VCostVarProdH2Tech.FX(CYall,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VShareCCSH2Prod.L(CYall,H2TECH,YTIME) = 2;
VShareCCSH2Prod.FX(CYall,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VShareNoCCSH2Prod.L(CYall,H2TECH,YTIME) = 2;
VShareNoCCSH2Prod.FX(CYall,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VConsFuelH2Prod.L(CYall,EF,YTIME) = 2;
VConsFuelH2Prod.FX(CYall,EF,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostProdCCSNoCCSH2Prod.L(CYall,H2TECH,YTIME) = 2;
VCostProdCCSNoCCSH2Prod.FX(CYall,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostAvgProdH2.L(CYall,YTIME) = 2;
VCostAvgProdH2.FX(CYall,YTIME)$(not An(YTIME)) = 1e-5;
*---
VInvNewReqH2Infra.L(CYall,INFRTECH,YTIME) = 2;
VInvNewReqH2Infra.FX(CYall,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostInvTechH2Infr.L(CYall, INFRTECH,YTIME) = 2;
VCostInvTechH2Infr.FX(CYall, INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCostInvCummH2Transp.L(CYall,INFRTECH,YTIME) = 2;
VCostInvCummH2Transp.FX(CYall,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VTariffH2Infr.L(CYall,INFRTECH,YTIME) = 2;
VTariffH2Infr.FX(CYall,INFRTECH,YTIME) $(not An(YTIME)) = 1e-5;
*---
VPriceH2Infr.L(CYall,SBS,YTIME) = 2;
VPriceH2Infr.FX(CYall,SBS,YTIME)  $(not An(YTIME)) = 1e-5;
*---
VH2InfrArea.l(cyall,ytime) = 10;
*-----------------------------------------------------------------------
*' *** Miscellaneous
*---
VDemTotH2.FX(cyrun,"2005") = sum(H2TECH, VProdH2.L(cyrun,H2TECH,"2005"));
VDemTotH2.L(CYall,YTIME) = 2;
VDemTotH2.FX(CYall,YTIME)$(not An(YTIME)) = 1e-5;
*---
VProdCapH2Tech.L(CYall,h2tech, YTIME) = 2;
VProdCapH2Tech.FX(CYall,h2tech, YTIME)$(not An(YTIME)) = 1e-5;
*-----------------------------------------------------------------------
VDemSecH2.FX(cyrun,SBS, "2005") = VDemTotH2.L(cyrun,"2005");
VDemSecH2.FX(CYall,SBS,YTIME)$(not An(YTIME)) = 1e-5;
*VDemSecH2.L(CYall,SBS, YTIME) = 2;
*---