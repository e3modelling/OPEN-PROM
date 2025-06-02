*' @title Hydrogen Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
VCostTotH2.L(runCy,SBS,YTIME) = 2;
VCostTotH2.FX(runCy,TRANSE,"2010") = iFuelPrice(runCy,TRANSE,"H2F","2010"); 
VCostTotH2.FX(runCy,"PG","2010") = iFuelPrice(runCy,"PG","H2F","2010"); 
VCostTotH2.FX(runCy,INDDOM,"2010") = iFuelPrice(runCy,INDDOM,"STE1AH2F","2010"); 
VCostTotH2.FX(runCy,SBS,YTIME)$(not An(YTIME)) = 1e-5;
display VCostTotH2.L;
*---
VGapShareH2Tech1.L(runCy,H2TECH,YTIME) = 2;
VGapShareH2Tech1.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display VGapShareH2Tech1.L;
*---
VDemGapH2.L(runCy,YTIME) = 2;
VDemGapH2.FX(runCy,YTIME)$(not An(YTIME)) = 1e-5;
display VDemGapH2.L;
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
VDelivH2InfrTech.L(runCy,INFRTECH,YTIME) = 2;
VDelivH2InfrTech.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
VDelivH2InfrTech.FX(runCy,INFRTECH,"2010") = 0;
display VDelivH2InfrTech.L;
*---
VGapShareH2Tech2.L(runCy,H2TECH,YTIME) = 2;
VGapShareH2Tech2.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VCapScrapH2ProdTech.L(runCy,H2TECH,YTIME) = 2;
VCapScrapH2ProdTech.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
display VCapScrapH2ProdTech.L;
*---
VPremRepH2Prod.L(runCy,H2TECH,YTIME) = 2;
VPremRepH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
*---
VScrapLftH2Prod.L(runCy,H2TECH,YTIME) = 2;
VScrapLftH2Prod.FX(runCy,H2TECH,YTIME)$(not An(YTIME)) = 1e-5;
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
VH2InfrArea.L(runCy,YTIME) = 10;
*-----------------------------------------------------------------------
*' *** Miscellaneous
*---
VDemSecH2.FX(runCy,SBS,YTIME) = 1e-5;
*---
*-----------------------------------------------------------------------