*' @title Heat module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
VmDemTotSte.FX(runCy,YTIME)$DATAY(YTIME) = SUM(DSBS$(INDDOM(DSBS) or NENSE(DSBS)), VmConsFuel.L(runCy,DSBS,"STE",YTIME));
* FIXME: DISSAGREGATION - we are multiple counting
VmProdSte.L(runCy,TCHP,YTIME) = 1;
VmProdSte.FX(runCy,TCHP,YTIME)$DATAY(YTIME) = VmDemTotSte.L(runCy,YTIME);
*---
V09CaptRateSte.FX(runCy,TCHP,YTIME)$DATAY(YTIME) = i09CaptRateSteProd(TCHP);
*---
V09CostCapProdSte.FX(runCy,TCHP,YTIME)$DATAY(YTIME) =
(
  imDisc(runCy,"STEAMP",YTIME) * 
  exp(imDisc(runCy,"STEAMP",YTIME)* i09ProdLftSte(TCHP,YTIME)) /
  (exp(imDisc(runCy,"STEAMP",YTIME) * i09ProdLftSte(TCHP,YTIME))-1) * 
  (
    imCapCostTech(runCy,"OI",TCHP,YTIME) * imCGI(runCy,YTIME) +
    imFixOMCostTech(runCy,"OI",TCHP,YTIME) / sUnitToKUnit +
    i09CostVOMSteProd(runCy,TCHP,YTIME)
  )
) / imUsfEneConvSubTech(runCy,"OI",TCHP,YTIME);
*---
V09CostVarProdSte.L(runCy,TCHP,YTIME) = 1;
V09CostVarProdSte.FX(runCy,TCHP,YTIME)$DATAY(YTIME) =
sum(EF$TCHPTOEF(TCHP,EF),
  (
    VmPriceFuelSubsecCarVal.L(runCy,"STEAMP",EF,YTIME) +
    V09CaptRateSte.L(runCy,TCHP,YTIME) * 
    (imCo2EmiFac(runCy,"STEAMP",EF,YTIME) + 4.17$(sameas("BMSWAS", EF))) * 
    VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 +
    (1-V09CaptRateSte.L(runCy,TCHP,YTIME)) * 1e-3 * (imCo2EmiFac(runCy,"STEAMP",EF,YTIME)) *
    sum(NAP$NAPtoALLSBS(NAP,"STEAMP"),VmCarVal.L(runCy,NAP,YTIME))
  ) 
) / imUsfEneConvSubTech(runCy,"OI",TCHP,YTIME);
*---
V09CostProdSte.L(runCy,TCHP,YTIME) = 1;
V09CostProdSte.FX(runCy,TCHP,YTIME)$DATAY(YTIME) =
V09CostCapProdSte.L(runCy,TCHP,YTIME) +
!! FIXME: remove 1
V09CostVarProdSte.L(runCy,TCHP,YTIME) + 1;
*---
V09ScrapRate.UP(runCy,TCHP,YTIME) = 1;
V09ScrapRate.LO(runCy,TCHP,YTIME) = 0;