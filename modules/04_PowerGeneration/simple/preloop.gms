*' @title Power Generation Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V04CostVarTech.L(runCy,PGALL,YTIME) = 0.1;
V04CostVarTech.FX(runCy,PGALL,YTIME)$(not AN(YTIME)) = 
    i04VarCost(PGALL,YTIME) / 1e3 + 
    (VmRenValue.L(YTIME) * 8.6e-5)$(not (PGREN(PGALL)$(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) )) +
    sum(PGEF$PGALLtoEF(PGALL,PGEF), 
      (VmPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME) +
      imCO2CaptRate(PGALL) * VmCstCO2SeqCsts.L(runCy,YTIME) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF))) +
      (1-imCO2CaptRate(PGALL)) * 1e-3 * (imCo2EmiFac(runCy,"PG",PGEF,YTIME) + 4.17$(sameas("BMSWAS", PGEF)))*
      (sum(NAP$NAPtoALLSBS(NAP,"PG"), VmCarVal.L(runCy,NAP,YTIME)))
      ) * smTWhToMtoe / imPlantEffByType(runCy,PGALL,YTIME)
    )$(not PGREN(PGALL));
*---
V04CapexRESRate.L(runCy,PGALL,YTIME)=1;
*---
alias(datay, dataylag)
loop (runCy,PGALL,datay,dataylag)$(ord(datay) = ord(dataylag) + 1 and PGREN(PGALL)) DO
  V04NetNewCapElec.FX(runCy,PGALL,datay) = imInstCapPastNonCHP(runCy,PGALL,datay) - imInstCapPastNonCHP(runCy,PGALL,dataylag) + 1E-10;
ENDLOOP;
V04NetNewCapElec.FX(runCy,"PGLHYD",YTIME)$TFIRST(YTIME) = +1E-10;
*---
V04CFAvgRen.L(runCy,PGALL,YTIME) = 0.1;
V04CFAvgRen.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = i04AvailRate(runCy,PGALL,YTIME);
*---
V04CapexFixCostPG.FX(runCy,PGALL,YTIME)$(DATAY(YTIME)) = (imDisc(runCy,"PG",YTIME) * exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL))
          / (exp(imDisc(runCy,"PG",YTIME) * i04TechLftPlaType(runCy,PGALL)) -1))
          * i04GrossCapCosSubRen(runCy,PGALL,YTIME) * 1000 * imCGI(runCy,YTIME)
          + i04FixOandMCost(runCy,PGALL,YTIME);
*---
V04CostCapTech.FX(runCy,PGALL,YTIME)$(not AN(YTIME)) = 
V04CapexRESRate.L(runCy,PGALL,YTIME) * V04CapexFixCostPG.L(runCy,PGALL,YTIME) / 
    (i04AvailRate(runCy,PGALL,YTIME) * smGwToTwhPerYear(YTIME) * 1000); 
*---
V04CostHourProdInvDec.L(runCy,PGALL,YTIME) = 0.1;     
V04CostHourProdInvDec.FX(runCy,PGALL,YTIME)$(NOT AN(YTIME)) = 
V04CostCapTech.L(runCy,PGALL,YTIME) + V04CostVarTech.L(runCy,PGALL,YTIME);
*---
VmCapElecTotEst.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME)) + SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
*---
V04CapElecNonCHP.FX(runCy,YTIME)$(not An(YTIME)) = sum(PGALL,imInstCapPastNonCHP(runCy,PGALL,YTIME));
*---
V04CapElecCHP.FX(runCy,YTIME)$(not An(YTIME)) = SUM(EF,imInstCapPastCHP(runCy,EF,YTIME));
*---
VmCapElec.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  imInstCapPastNonCHP(runCy,PGALL,YTIME);
VmCapElec.L(runCy,PGALL,YTIME)$AN(YTIME) = imInstCapPastNonCHP(runCy,PGALL,"%fStartY%");
V04CapOverall.FX(runCy,PGALL,"%fBaseY%") =  imInstCapPastNonCHP(runCy,PGALL,"%fBaseY%");
V04CapElecNominal.FX(runCy,PGALL,YTIME)$DATAY(YTIME) = imInstCapPastNonCHP(runCy,PGALL,YTIME) / i04AvailRate(runCy,PGALL,YTIME);
*---
V04ShareTechPG.FX(runCy,PGALL,YTIME)$(DATAY(YTIME)) =  VmCapElec.L(runCy,PGALL,YTIME) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
V04ShareSatPG.FX(runCy,PGALL,YTIME)$(not PGREN(PGALL) or not AN(YTIME)) = 1;
*---
V04IndxEndogScrap.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
V04IndxEndogScrap.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants
*---
V04CostVarTech.scale(runCy,PGALL,YTIME)=1e-5;
Q04CostVarTech.scale(runCy,PGALL,YTIME)=V04CostVarTech.scale(runCy,PGALL,YTIME);
*---
V04LoadFacDom.L(runCy,YTIME)=0.5;
V04LoadFacDom.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"ELC",YTIME)/i04LoadFacElecDem(INDDOM)) + sum(TRANSE, VmDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/
         i04LoadFacElecDem(TRANSE)));
*---
$ifthen.calib %Calibration% == MatCalibration
V04DemElecTot.FX(runCy,YTIME) = t04DemElecTot(runCy,YTIME);
$else.calib
V04DemElecTot.L(runCy,YTIME) = 10;
V04DemElecTot.FX(runCy,YTIME)$(not An(YTIME)) = 
1/smTWhToMtoe * 
(imFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, imFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + 
imDistrLosses(runCy,"ELC",YTIME) + i03TotEneBranchCons(runCy,"ELC",YTIME) -
(imFuelImports(runCy,"ELC",YTIME)- imFuelExprts(runCy,"ELC",YTIME)));
$endif.calib
*---
VmPeakLoad.L(runCy,YTIME) = 1;
VmPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = V04DemElecTot.L(runCy,YTIME)/(V04LoadFacDom.L(runCy,YTIME)*8.76);
*---
VmProdElec.L(runCy,pgall,YTIME) = 0.1;
VmProdElec.FX(runCy,pgall,YTIME)$DATAY(YTIME) = i04DataElecProdNonCHP(runCy,pgall,YTIME) / 1000;
*---
V04ProdElecEstCHP.FX(runCy,YTIME)$DATAY(YTIME) = SUM(EF,i04DataElecProdCHP(runCy,EF,YTIME)) / 1000;
*---
V04ShareMixWndSol.L(runCy,YTIME)$(DATAY(YTIME)) = sum(PGALL$(PGRENSW(PGALL)), VmCapElec.L(runCy,PGALL,YTIME)) / sum(PGALL2, VmCapElec.L(runCy,PGALL2,YTIME));
*---
V04CCSRetroFit.FX(runCy,PGALL,YTIME)$(not AN(YTIME) or not NOCCS(PGALL)) = 1;
*---
V04ScrpRate.UP(runCy,PGALL,YTIME) = 1;
*---
VmInpTransfTherm.FX(runCy,PGEF,YTIME)$(not AN(YTIME)) = 
sum(PGALL$(PGALLtoEF(PGALL,PGEF)),
  VmProdElec.L(runCy,PGALL,YTIME) * smTWhToMtoe /  imPlantEffByType(runCy,PGALL,YTIME)
) +
sum(INDDOM,VmConsFuel.L(runCy,INDDOM,"STE",YTIME)) +
smTWhToMtoe * V04ProdElecEstCHP.L(runCy,YTIME)
;