*' @title Heat module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
V09ScrapRatePremature.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRatePremature.UP(runCy,TSTEAM,YTIME) = 1;
V09ScrapRatePremature.L(runCy,TSTEAM,YTIME) = 0.7;
*---
V09GapShareSte.LO(runCy,TSTEAM,YTIME) = 0;
V09GapShareSte.UP(runCy,TSTEAM,YTIME) = 1;
*---
V09CaptRateSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CaptRateSte.UP(runCy,TSTEAM,YTIME) = 1;
*---
V09ScrapRate.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRate.UP(runCy,TSTEAM,YTIME) = 1;
*---
VmDemTotSte.LO(runCy,YTIME) = 0;
VmDemTotSte.L(runCy,YTIME) = i03DataGrossInlCons(runCy,"STE","%fBaseY%");
VmDemTotSte.FX(runCy,YTIME)$DATAY(YTIME) = i03DataGrossInlCons(runCy,"STE",YTIME);
*---
VmCapSte.LO(runCy,TSTEAM,YTIME) = 0;
VmCapSte.L(runCy,TSTEAM,YTIME) = i04DataHeatProd(runCy,TSTEAM,"%fBaseY%") + 1;
VmCapSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
(
  (
    i03DataGrossInlCons(runCy,"STE",YTIME) /
    SUM(TSTEAM2,i04DataHeatProd(runCy,TSTEAM2,YTIME))
  )$SUM(TSTEAM2,i04DataHeatProd(runCy,TSTEAM2,YTIME))
) * i04DataHeatProd(runCy,TSTEAM,YTIME);
*---
VmProdSte.LO(runCy,TSTEAM,YTIME) = 0;
VmProdSte.L(runCy,TSTEAM,YTIME) = i04DataHeatProd(runCy,TSTEAM,"%fBaseY%");
VmProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
(
  (
    i03DataGrossInlCons(runCy,"STE",YTIME) /
    SUM(TSTEAM2,i04DataHeatProd(runCy,TSTEAM2,YTIME))
  )$SUM(TSTEAM2,i04DataHeatProd(runCy,TSTEAM2,YTIME))
) * i04DataHeatProd(runCy,TSTEAM,YTIME);
*---
V09CaptRateSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = i09CaptRateSteProd(TSTEAM);
*---
V09CostCapProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostCapProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
(
  imDisc(runCy,"STEAMP",YTIME) * 
  exp(imDisc(runCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM)) /
  (exp(imDisc(runCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM))-1) * 
  (
    i09CostInvCostSteProd(TSTEAM,YTIME) * imCGI(runCy,YTIME) +
    i09CostFixOMSteProd(TSTEAM,YTIME)
  )
) / (i09PowToHeatRatio(TSTEAM,YTIME) + 1$TDHP(TSTEAM)) /
(
  i09AvailRateSteProd(TSTEAM,YTIME) * 
  smGwToTwhPerYear(YTIME) * 
  smTWhToMtoe * 1e3
);
*---
V09CostVarProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostVarProdSte.L(runCy,TSTEAM,YTIME) = 1;
V09CostVarProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
sum(EF$TSTEAMTOEF(TSTEAM,EF),
  (
    VmPriceFuelSubsecCarVal.L(runCy,"STEAMP",EF,YTIME) +
    V09CaptRateSte.L(runCy,TSTEAM,YTIME) * 
    (imCo2EmiFac(runCy,"STEAMP",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * 
    VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 +
    (1-V09CaptRateSte.L(runCy,TSTEAM,YTIME)) * 1e-3 * (imCo2EmiFac(runCy,"STEAMP",EF,YTIME)) *
    sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal.L(runCy,NAP,YTIME))
  )
) / SUM(STECH$sameas(STECH,TSTEAM),imPlantEffByType(runCy,STECH,"effHeat",YTIME)) +
i09CostVOMSteProd(TSTEAM,YTIME) * 1e-3 -!!/ smTWhToMtoe / SUM(TCHP$sameas(TCHP,TSTEAM),VmPriceElecInd.L(runCy,TCHP,YTIME)) -
(
  VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME) *
  smFracElecPriChp /
  SUM(TCHP$sameas(TCHP,TSTEAM),VmPriceElecInd.L(runCy,TCHP,YTIME))
)$TCHP(TSTEAM);
*---
V09CostProdSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CostProdSte.L(runCy,TSTEAM,YTIME) = 1;
V09CostProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
V09CostCapProdSte.L(runCy,TSTEAM,YTIME) + V09CostVarProdSte.L(runCy,TSTEAM,YTIME);
*---
VmCostAvgProdSte.LO(runCy,YTIME) = 0;
VmCostAvgProdSte.L(runCy,YTIME) = 1;
VmCostAvgProdSte.FX(runCy,YTIME)$DATAY(YTIME) = 
sum(TSTEAM, 
  (VmProdSte.L(runCy,TSTEAM,YTIME) + 1e-6) *
  V09CostProdSte.L(runCy,TSTEAM,YTIME)
) / 
sum(TSTEAM,VmProdSte.L(runCy,TSTEAM,YTIME) + 1e-6) ;
*---
VmConsFuelSteProd.LO(runCy,STEMODE,EFS,YTIME) = 0;
VmConsFuelSteProd.FX(runCy,STEMODE,EFS,YTIME)$(not STEAMEF(EFS)) = 0;
VmConsFuelSteProd.FX(runCy,"CHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpTotTransfProcess(runCy,"CHP",STEAMEF,YTIME);
VmConsFuelSteProd.FX(runCy,"DHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpTotTransfProcess(runCy,"STEAMP",STEAMEF,YTIME);
*---
V09DemGapSte.LO(runCy,YTIME) = 0;
*V09DemGapSte.L(runCy,YTIME) = 0.1;