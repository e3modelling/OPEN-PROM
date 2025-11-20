*' @title Heat module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

V09DemGapSte.LO(runCy,YTIME) = 0;
*---
V09ScrapRatePremature.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRatePremature.UP(runCy,TSTEAM,YTIME) = 1;
*---
V09GapShareSte.LO(runCy,TSTEAM,YTIME) = 0;
V09GapShareSte.UP(runCy,TSTEAM,YTIME) = 1;
*---
V09ScrapRate.LO(runCy,TSTEAM,YTIME) = 0;
V09ScrapRate.UP(runCy,TSTEAM,YTIME) = 1;
*---
VmDemTotSte.LO(runCy,YTIME) = 0;
VmDemTotSte.FX(runCy,YTIME)$DATAY(YTIME) = 
SUM(DSBS, imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
i03TotEneBranchCons(runCy,"STE",YTIME) +
imDistrLosses(runCy,"STE",YTIME) +
i03FeedTransfr(runCy,"STE",YTIME);
*---
* We account the steam production per chp plant based on a ratio of input transformation
VmProdSte.LO(runCy,TSTEAM,YTIME) = 0;
VmProdSte.L(runCy,TSTEAM,YTIME) = 1;
VmProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) /
  SUM(EFS$STEAMEF(EFS),i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) * 
  (
    SUM(DSBS$(not DOMSE(DSBS)), imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
    i03TotEneBranchCons(runCy,"STE",YTIME) +
    imDistrLosses(runCy,"STE",YTIME) / 2 +
    i03FeedTransfr(runCy,"STE",YTIME) / 2
  )
)$(TCHP(TSTEAM) and SUM(EFS,i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME))) +
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) /
  SUM(EFS$STEAMEF(EFS),i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)) * 
  (
    SUM(DSBS$DOMSE(DSBS), imFuelConsPerFueSub(runCy,DSBS,"STE",YTIME)) +
    imDistrLosses(runCy,"STE",YTIME) / 2 +
    i03FeedTransfr(runCy,"STE",YTIME) / 2
  )
)$(TDHP(TSTEAM) and SUM(EFS,i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteThrm(TSTEAM,YTIME)));
*---
V09CaptRateSte.LO(runCy,TSTEAM,YTIME) = 0;
V09CaptRateSte.UP(runCy,TSTEAM,YTIME) = 1;
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
V09CostVarProdSte.LO(runCy,TSTEAM,YTIME) = epsilon6;
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
) / i09EffSteThrm(TSTEAM,YTIME) +
i09CostVOMSteProd(TSTEAM,YTIME) * 1e-3 / smTWhToMtoe * VmPriceElecInd.L(runCy,YTIME) -
(
  VmPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME) *
  smFracElecPriChp *
  VmPriceElecInd.L(runCy,YTIME)
)$TCHP(TSTEAM);
*---
V09CostProdSte.LO(runCy,TSTEAM,YTIME) = epsilon6;
V09CostProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = V09CostCapProdSte.L(runCy,TSTEAM,YTIME) +
V09CostVarProdSte.L(runCy,TSTEAM,YTIME);
*---
VmCostAvgProdSte.LO(runCy,YTIME) = epsilon6;
VmCostAvgProdSte.FX(runCy,YTIME)$DATAY(YTIME) = 0;
*---
VmConsFuelSteProd.LO(runCy,STEMODE,EFS,YTIME) = 0;
VmConsFuelSteProd.FX(runCy,STEMODE,EFS,YTIME)$(not STEAMEF(EFS)) = 0;
VmConsFuelSteProd.FX(runCy,"CHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpCHPTransfProcess(runCy,STEAMEF,YTIME);
VmConsFuelSteProd.FX(runCy,"DHP",STEAMEF,YTIME)$DATAY(YTIME) = -i03InpDHPTransfProcess(runCy,STEAMEF,YTIME);