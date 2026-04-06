*' @title Power Generation Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V04DemElecTot.LO(runCy,YTIME) = 0;
V04DemElecTot.L(runCy,YTIME) = (i03DataGrossInlCons(runCy,"ELC","%fBaseY%") - imFuelTrade(runCy,"IMPORTS","ELC","%fBaseY%") + imFuelTrade(runCy,"EXPORTS","ELC","%fBaseY%")) / smTWhToMtoe;
V04DemElecTot.FX(runCy,YTIME)$DATAY(YTIME) = (i03DataGrossInlCons(runCy,"ELC",YTIME) - imFuelTrade(runCy,"IMPORTS","ELC",YTIME) + imFuelTrade(runCy,"EXPORTS","ELC",YTIME)) / smTWhToMtoe;
*---
V04ProdElecEstCHP.LO(runCy,TCHP,YTIME) = 0;
V04ProdElecEstCHP.L(runCy,TCHP,YTIME) = i04DataElecProdCHP(runCy,TCHP,"%fBaseY%") / 1000;
V04ProdElecEstCHP.FX(runCy,TCHP,YTIME)$DATAY(YTIME) = i04DataElecProdCHP(runCy,TCHP,YTIME) / 1000;
*---
V04ScrpRate.UP(runCy,PGALL,YTIME) = 1;
V04ScrpRate.LO(runCy,PGALL,YTIME) = 0;
*---
V04CostVarTech.LO(runCy,PGALL,YTIME) = 0;
V04CostVarTech.L(runCy,PGALL,YTIME) = 1;
V04CostVarTech.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (VmRenValue.L(YTIME) * 8.6e-5)$(not (PGREN(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      i04ShareFuels(runCy,PGALL,PGEF) * (VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) +
      imCO2CaptRate(PGALL) * VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-imCO2CaptRate(PGALL)) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME))
      ) * smTWhToMtoe / imPlantEffByType(runCy,PGALL,"effELC",YTIME)
    )$(not PGREN(PGALL));
*---
V04CapexRESRate.L(runCy,PGALL,YTIME) = 1;
*---
V04NetNewCapElec.L(runCy,PGALL,YTIME) = 1;
V04NetNewCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) - imInstCapPastNonCHP(runCy,PGALL,YTIME-1);
*---
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = (imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL))
          / (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1))
          * i04GrossCapCosSubRen(runCY,PGALL,YTIME) * 1000
          * imCGI(runCy,YTIME)
          + i04FixOandMCost(runCy,PGALL,YTIME)
;
*---
V04CapexFixCostPG.LO(runCy,PGALL,YTIME) = 0;
V04CapexFixCostPG.L(runCy,PGALL,YTIME) = 
( 
  imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) /
  (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1)
) * i04GrossCapCosSubRen(runCy,PGALL,YTIME) * 1000 * imCGI(runCy,YTIME) +
i04FixOandMCost(runCy,PGALL,YTIME);
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
( 
  imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) /
  (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1)
) * i04GrossCapCosSubRen(runCy,PGALL,YTIME) * 1000 * imCGI(runCy,YTIME) +
i04FixOandMCost(runCy,PGALL,YTIME);
*---
V04CostCapTech.LO(runCy,PGALL,YTIME) = 0;
V04CostCapTech.L(runCy,PGALL,YTIME) = 1;
V04CostCapTech.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
V04CapexRESRate.L(runCy,PGALL,YTIME) * V04CapexFixCostPG.L(runCy,PGALL,YTIME) / 
    (i04AvailRate(runCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000); 
*---
V04CostHourProdInvDec.LO(runCy,PGALL,YTIME) = 0;
V04CostHourProdInvDec.L(runCy,PGALL,YTIME) = V04CostCapTech.L(runCy,PGALL,"%fBaseY%") + V04CostVarTech.L(runCy,PGALL,"%fBaseY%");     
V04CostHourProdInvDec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = V04CostCapTech.L(runCy,PGALL,YTIME) + V04CostVarTech.L(runCy,PGALL,YTIME);
*---
V04CapElecNonCHP.LO(runCy,YTIME) = 0;
V04CapElecNonCHP.L(runCy,YTIME) = SUM(PGALL, i04DataElecProdNonCHP(runCy,PGALL,"%fBaseY%")) / 1000 / smGwToTwhPerYear(YTIME);
V04CapElecNonCHP.FX(runCy,YTIME)$DATAY(YTIME) = 
(
  V04DemElecTot.L(runCy,YTIME) - 
  SUM(TCHP,V04ProdElecEstCHP.L(runCy,TCHP,YTIME)) 
) / smGwToTwhPerYear(YTIME);
*---
V04NewCapElec.LO(runCy,PGALL,YTIME) = 0;
*---
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) / i04AvailRate(runCy,PGALL,YTIME);
*---
V04ShareTechPG.LO(runCy,PGALL,YTIME) = 0;
V04ShareTechPG.UP(runCy,PGALL,YTIME) = 1; 
V04ShareTechPG.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) / sum(PGALL2, imInstCapPastNonCHP(runCy,PGALL2,YTIME));
*---
V04ShareSatPG.LO(runCy,PGALL,YTIME) = 0;
V04ShareSatPG.L(runCy,PGALL,YTIME)$(not PGREN(PGALL)) = 1;
V04ShareSatPG.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL) or DATAY(YTIME)) = 1;
*---
V04IndxEndogScrap.LO(runCy,PGALL,YTIME) = 0;
V04IndxEndogScrap.UP(runCy,PGALL,YTIME) = 1;
V04IndxEndogScrap.L(runCy,PGALL,YTIME) = 0.5;
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) or PGSCRN(PGALL)) = 1;
*---
VmCapElec.LO(runCy,PGALL,YTIME) = 0;
VmCapElec.L(runCy,PGALL,YTIME) = i04DataElecProdNonCHP(runCy,PGALL,"%fBaseY%") / 1000 / smGwToTwhPerYear(YTIME) + 1;
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = i04DataElecProdNonCHP(runCy,PGALL,YTIME) / 1000 / smGwToTwhPerYear(YTIME);
*---
VmProdElec.LO(runCy,PGALL,YTIME) = 0;
VmProdElec.L(runCy,pgall,YTIME) = i04DataElecProdNonCHP(runCy,pgall,"%fBaseY%") / 1000 + 1;
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME) = i04DataElecProdNonCHP(runCy,pgall,YTIME) / 1000;
*---
V04ShareMixWndSol.FX(runCy,YTIME)$DATAY(YTIME) = sum(PGALL$PGRENSW(PGALL), VmCapElec.L(runCy,PGALL,YTIME)) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
*---
V04CCSRetroFit.UP(runCy,PGALL,YTIME) = 1;
V04CCSRetroFit.LO(runCy,PGALL,YTIME) = 0;
V04CCSRetroFit.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) or not NOCCS(PGALL)) = 1;
*---
V04CO2CaptRate.UP(runCy,PGALL,YTIME) = 1;
V04CO2CaptRate.LO(runCy,PGALL,YTIME) = 0;
*---
VmConsFuelElecProd.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VmConsFuelElecProd.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = 
SUM(PGALL$PGALLTOEF(PGALL,PGEF),
  i04ShareFuels(runCy,PGALL,PGEF) *
  VmProdElec.L(runCy,PGALL,YTIME) * smTWhToMtoe / 
  imPlantEffByType(runCy,PGALL,"effELC",YTIME)
);
*---
VmConsFuelElecProd.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = -i03InpTotTransfProcess(runCy,"PG",PGEF,YTIME);
*---
V04GapGenCapPowerDiff.LO(runCy,YTIME) = 0;
V04GapGenCapPowerDiff.FX(runCy,YTIME)$DATAY(YTIME) = 0;
*---
VmCostPowGenAvgLng.LO(runCy,YTIME) = 0;
VmCostPowGenAvgLng.L(runCy,YTIME) = 
SUM(PGALL,VmProdElec.L(runCy,PGALL,"%fBaseY%") * V04CostHourProdInvDec.L(runCy,PGALL,"%fBaseY%")) / 
SUM(PGALL,VmProdElec.L(runCy,PGALL,"%fBaseY%"));
VmCostPowGenAvgLng.FX(runCy,YTIME)$DATAY(YTIME) = 
SUM(PGALL,(VmProdElec.L(runCy,PGALL,YTIME) + 1e-6) * V04CostHourProdInvDec.L(runCy,PGALL,YTIME)) / 
SUM(PGALL,VmProdElec.L(runCy,PGALL,YTIME) + 1e-6);
*---
V04SharePowPlaNewEq.LO(runCy,PGALL,YTIME) = 0;
V04SharePowPlaNewEq.UP(runCy,PGALL,YTIME) = 1;
V04SharePowPlaNewEq.L(runCy,PGALL,YTIME)$AN(YTIME) = t04SharePowPlaNewEq(runCy,PGALL,YTIME);