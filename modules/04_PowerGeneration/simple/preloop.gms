*' @title Power Generation Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V04ShareTechPG.LO(runCy,PGALL,YTIME)$DATAY(YTIME) = 0;
V04ShareTechPG.UP(runCy,PGALL,YTIME)$DATAY(YTIME) = 1;
*---
V04ScrpRate.UP(runCy,PGALL,YTIME) = 1;
V04ScrpRate.LO(runCy,PGALL,YTIME) = 0;
*---
V04CostVarTech.LO(runCy,PGALL,YTIME) = epsilon6;
V04CostVarTech.L(runCy,PGALL,YTIME) = 0.1;
V04CostVarTech.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (VmRenValue.L(YTIME) * 8.6e-5)$(not PGREN(PGALL)) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      (VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) +
      imCO2CaptRate(PGALL) * VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-imCO2CaptRate(PGALL)) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME)))
      ) * smTWhToMtoe / imPlantEffByType(runCy,PGALL,YTIME)
    )$(not PGREN(PGALL));
*---
V04CapexRESRate.LO(runCy,PGALL,YTIME) = 1;
V04CapexRESRate.L(runCy,PGALL,YTIME) = 1;
*---
V04NetNewCapElec.L(runCy,PGALL,YTIME) = 1;
V04NetNewCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) - imInstCapPastNonCHP(runCy,PGALL,YTIME);
*---
V04NetNewCapElec.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) and ord(YTIME) > 0) = imInstCapPastNonCHP(runCy,PGALL,YTIME) - imInstCapPastNonCHP(runCy,PGALL,YTIME-1);
*---
V04CFAvgRen.LO(runCy,PGALL,YTIME) = 0;
V04CFAvgRen.UP(runCy,PGALL,YTIME) = 1;
V04CFAvgRen.L(runCy,PGALL,YTIME) = 0.5;
V04CFAvgRen.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) or not PGREN(PGALL)) = i04AvailRate(runCy,PGALL,YTIME);
*---
V04CapexFixCostPG.LO(runCy,PGALL,YTIME) = 0;
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$(DATAY(YTIME)) = (imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL))
          / (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1))
          * i04GrossCapCosSubRen(runCy,PGALL,YTIME) * 1000 * imCGI(runCy,YTIME)
          + i04FixOandMCost(runCy,PGALL,YTIME);
*---
V04CostCapTech.LO(runCy,PGALL,YTIME) = 0;
V04CostCapTech.L(runCy,PGALL,YTIME) = 0.1;
V04CostCapTech.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
V04CapexRESRate.L(runCy,PGALL,YTIME) * V04CapexFixCostPG.L(runCy,PGALL,YTIME) / 
    (i04AvailRate(runCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000); 
*---
V04CostHourProdInvDec.LO(runCy,PGALL,YTIME) = epsilon6;
*V04CostHourProdInvDec.L(runCy,PGALL,YTIME) = 0.1;     
V04CostHourProdInvDec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = V04CostCapTech.L(runCy,PGALL,YTIME) + V04CostVarTech.L(runCy,PGALL,YTIME);
*---
VmCapElecTotEst.LO(runCy,YTIME) = 0;
VmCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME)) + SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
*---
V04CapElecNonCHP.LO(runCy,YTIME) = 0;
V04CapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME));
*---
V04CapElecCHP.LO(runCy,YTIME) = 0;
V04CapElecCHP.FX(runCy,YTIME)$(not An(YTIME)) = SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
*---
VmCapElec.LO(runCy,PGALL,YTIME) = 0;
VmCapElec.L(runCy,PGALL,YTIME) = 1;
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  imInstCapPastNonCHP(runCy,PGALL,YTIME);
*---
V04CapElecNominal.LO(runCy,PGALL,YTIME) = 0;
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) / i04AvailRate(runCy,PGALL,YTIME);
*---
V04ShareTechPG.LO(runCy,PGALL,YTIME)$DATAY(YTIME) = 0;
V04ShareTechPG.UP(runCy,PGALL,YTIME)$DATAY(YTIME) = 1;
V04ShareTechPG.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  VmCapElec.L(runCy,PGALL,YTIME) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
*---
V04ShareSatPG.LO(runCy,PGALL,YTIME) = 0;
V04ShareSatPG.UP(runCy,PGALL,YTIME) = 1;
V04ShareSatPG.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL) or not AN(YTIME)) = 1;
*---
V04IndxEndogScrap.LO(runCy,PGALL,YTIME) = 0;
V04IndxEndogScrap.UP(runCy,PGALL,YTIME) = 1;
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 1;
V04IndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1; !! premature replacement it is not allowed for all new plants
*---
V04GapGenCapPowerDiff.LO(runCy,YTIME) = 0;
V04GapGenCapPowerDiff.L(runCy,YTIME) = 1;
*---
V04LoadFacDom.LO(runCy,YTIME) = 0;
V04LoadFacDom.L(runCy,YTIME) = 0.5;
V04LoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         i04LoadFacElecDem(TRANSE)));
*---
V04DemElecTot.LO(runCy,YTIME) = 0;
V04DemElecTot.L(runCy,YTIME) = 10;
$ifthen.calib %Calibration% == MatCalibration
V04DemElecTot.FX(runCy,YTIME) = t04DemElecTot(runCy,YTIME);
$else.calib
V04DemElecTot.FX(runCy,YTIME)$DATAY(YTIME) = 
1/smTWhToMtoe * 
(
  sum(DSBS, imFuelConsPerFueSub(runCy,DSBS,"ELC",YTIME)) +
  imDistrLosses(runCy,"ELC",YTIME) +
  i03TotEneBranchCons(runCy,"ELC",YTIME) -
  (imFuelImports(runCy,"ELC",YTIME)- imFuelExprts(runCy,"ELC",YTIME))
);
$endif.calib
*---
VmPeakLoad.LO(runCy,YTIME) = 0;
VmPeakLoad.L(runCy,YTIME) = 1;
VmPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = V04DemElecTot.L(runCy,YTIME)/(V04LoadFacDom.L(runCy,YTIME)*8.76);
*---
VmProdElec.LO(runCy,pgall,YTIME) = 0;
VmProdElec.L(runCy,pgall,YTIME) = i04DataElecProdNonCHP(runCy,pgall,YTIME) / 1000;
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME) = i04DataElecProdNonCHP(runCy,pgall,YTIME) / 1000;
*---
V04ProdElecEstCHP.LO(runCy,YTIME) = 0;
V04ProdElecEstCHP.L(runCy,YTIME) = SUM(EF,i04DataElecProdCHP(runCy,EF,YTIME)) / 1000;
V04ProdElecEstCHP.FX(runCy,YTIME)$DATAY(YTIME) = SUM(EF,i04DataElecProdCHP(runCy,EF,YTIME)) / 1000;
*---
V04ShareMixWndSol.LO(runCy,YTIME) = 0;
V04ShareMixWndSol.UP(runCy,YTIME) = 1;
V04ShareMixWndSol.FX(runCy,YTIME)$DATAY(YTIME) = sum(PGALL$PGRENSW(PGALL), VmCapElec.L(runCy,PGALL,YTIME)) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
*---
VmCostPowGenAvgLng.LO(runCy,YTIME) = 0;
VmCostPowGenAvgLng.L(runCy,YTIME) = 1;
*---
V04SharePowPlaNewEq.LO(runCy,PGALL,YTIME) = 0;
V04SharePowPlaNewEq.UP(runCy,PGALL,YTIME) = 1;
*---
V04CCSRetroFit.UP(runCy,PGALL,YTIME) = 1;
V04CCSRetroFit.LO(runCy,PGALL,YTIME) = 0;
V04CCSRetroFit.FX(runCy,PGALL,YTIME)$(DATAY(YTIME) or not NOCCS(PGALL)) = 1;
*---
V04CO2CaptRate.UP(runCy,PGALL,YTIME) = 1;
V04CO2CaptRate.LO(runCy,PGALL,YTIME) = 0;
*---
VmConsFuelElecProd.LO(runCy,EFS,YTIME) = 0;
VmConsFuelElecProd.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;
VmConsFuelElecProd.FX(runCy,PGEF,YTIME)$DATAY(YTIME) = -i03InpPGTransfProcess(runCy,PGEF,YTIME);
*---
V04NewCapElec.LO(runCy,PGALL,YTIME) = 0;
V04NewCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = 
V04SharePowPlaNewEq.L(runCy,PGALL,YTIME) * V04GapGenCapPowerDiff.L(runCy,YTIME) +
i04DecInvPlantSched(runCy,PGALL,YTIME) * i04AvailRate(runCy,PGALL,YTIME) +
SUM(PGALL2$CCS_NOCCS(PGALL,PGALL2),
  (1 - V04CCSRetroFit.L(runCy,PGALL2,YTIME)) * imInstCapPastNonCHP(runCy,PGALL2,YTIME-1)
);
