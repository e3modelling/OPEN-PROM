*' @title Heat module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
VmDemTotSte.FX(runCy,YTIME)$DATAY(YTIME) = SUM(DSBS$(INDDOM(DSBS) or NENSE(DSBS)), VmConsFuel.L(runCy,DSBS,"STE",YTIME));
* We account the steam production per chp plant based on a ratio of input transformation
VmProdSte.L(runCy,TSTEAM,YTIME) = 1;
VmProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = 
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM)) /
  SUM(EFS,i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM)) * 
  SUM(DSBS$(INDSE(DSBS) or NENSE(DSBS)), VmConsFuel.L(runCy,DSBS,"STE",YTIME))
)$(TCHP(TSTEAM) and SUM(EFS,i03InpCHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM))) +
(
  SUM(EFS$TSTEAMTOEF(TSTEAM,EFS),i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM)) /
  SUM(EFS,i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM)) * 
  SUM(DSBS$DOMSE(DSBS), VmConsFuel.L(runCy,DSBS,"STE",YTIME))
)$(TDHP(TSTEAM) and SUM(EFS,i03InpDHPTransfProcess(runCy,EFS,YTIME) * i09EffSteProd(TSTEAM)));
*---
V09CaptRateSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) = i09CaptRateSteProd(TSTEAM);
*---
V09CostCapProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
(
  imDisc(runCy,"STEAMP",YTIME) * 
  exp(imDisc(runCy,"STEAMP",YTIME)* i09ProdLftSte(TSTEAM,YTIME)) /
  (exp(imDisc(runCy,"STEAMP",YTIME) * i09ProdLftSte(TSTEAM,YTIME))-1) * 
  (
    imDataIndTechnologyCHP("OI",TSTEAM,"IC") * imCGI(runCy,YTIME) +
    imDataIndTechnologyCHP("OI",TSTEAM,"FC") / sUnitToKUnit +
    i09CostVOMSteProd(runCy,TSTEAM,YTIME)
  )
) / 0.8;
*---
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
) / 0.8; !! FIXME: imUsfEneConvSubTech(runCy,"OI",TSTEAM,YTIME);
*---
V09CostProdSte.L(runCy,TSTEAM,YTIME) = 1;
V09CostProdSte.FX(runCy,TSTEAM,YTIME)$DATAY(YTIME) =
V09CostCapProdSte.L(runCy,TSTEAM,YTIME) +
V09CostVarProdSte.L(runCy,TSTEAM,YTIME);
*---
V09ScrapRate.UP(runCy,TSTEAM,YTIME) = 1;
V09ScrapRate.LO(runCy,TSTEAM,YTIME) = 0;