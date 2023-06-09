* Calculation of polynomial distribution lags coefficients
iNPDL(DSBS) = 6;
loop DSBS do
   loop KPDL$(ord(KPDL) le iNPDL(DSBS)) do
         iFPDL(DSBS,KPDL) = 6 * (iNPDL(DSBS)+1-ord(KPDL)) * ord(KPDL)
                           /
                           (iNPDL(DSBS) * (iNPDL(DSBS)+1) * (iNPDL(DSBS)+2))
   endloop;
endloop;

model openprom /all/;


option iGDP:2:0:6;
display iCapGrossCosPlanType;
display iFixGrosCostPlaType;
display iCGI;
display iDisc;
display TF;
display TFIRST;
display iPlantAvailRate;
display iCo2EmiFac;
display TEA;
display iUsfEneConvSubTech;

*TIME(YTIME) = %fStartY%;
VFuelPrice.L(allCy,TRANSE,YTIME) = 0.1;
VNumVeh.L(allCy,YTIME)=0.1;
*VNumVeh.lags(allCy,YTIME) = 0.1;
VTrnspActiv.l(allCy,TRANSE,YTIME) = 0.1;
VFuelPrice.l(allCy,DSBS,YTIME) =1;
VFuelPriceSub.l(allCy,SBS,EF,YTIME) = 0.1;
VElecIndPrices.l(allCy,YTIME)= 0.1;
VTechCostVar.l(allCy,SBS,EF,TEA,YTIME) = 0.1;
VTechCostIntrm.l(allCy,DSBS,rcon,EF,TEA,YTIME) = 0.1;
VLifeTimeTech.l(allCy,DSBS,EF,TEA,YTIME)= 0.1;
VTechSort.l(allCy,DSBS,rCon,YTIME) = 0.1;
VMatrFactor.l(allCy,SBS,EF,TEA,YTIME) =0.1;
VConsFuel.l(allCy,DSBS,EF,YTIME)=0.1;
VRefCapacity.l(allCy,YTIME)=0.1;
VFeCons.l(allCy,EF,YTIME) = 0.1;
VTransfOutputRefineries.l(allCy,EFS,YTIME)=0.1;
VGrsInlConsNotEneBranch.l(allCy,EFS,YTIME)=0.1;
VElecConsAll.l(allCy,DSBS,YTIME)=0.1;
VCapChpPlants.l(allCy,YTIME)=0.1;
VElecPeakLoad.l(allCy,YTIME)=0.1;
VElecPeakLoad.up(allCy,YTIME)=1e6;
VElecProdPowGenPlants.l(allCy,PGALL,YTIME) = 1;
*VHourProdTech.up(allCy,PGALL,HOUR,YTIME)=1e6;
VSensCcs.l(allCy,YTIME)=1;
*VHourProdTech.VLamda(allCy,PGALL,HOUR,YTIME)=1;
VCarVal.fx(allCy,NAP,YTIME)=1;
VFuelPriceSub.l(allCy,"PG",PGEF,YTIME)=1;
VProdCostTechnology.l(allCy,PGALL2,YTIME)=0.1;
*VProdCostTechnology.up(allCy,PGALL2,YTIME)=1e6;
VVarCostTech.l(allCy,PGALL,YTIME)=0.1;
VProdCostTechPreReplacAvail.l(allCy,PGALL,PGALL2,YTIME)=0.1;
VTechSortVarCost.l(allCy,TRANSE,Rcon,YTIME)=0.1;
*VHourProdCostTech.up(allCy,PGALL,HOUR,YTIME)=8000;
*VHourProdCostTech.VLamda(allCy,PGALL,HOUR,YTIME)=10;
*VTemScalWeibull.up(allCy,PGALL,HOUR,YTIME)=1e6;
*VHourProdCostTech.lo(allCy,PGALL,HOUR,YTIME)=0.0001;
VRenPotSupplyCurve.l(allCy,PGRENEF,YTIME)=0.1;
VScrRate.l(allCy,YTIME)=0.1;
VTranspCostPermeanConsSize.l(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
VTranspCostPermeanConsSize.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.0001;
VElecNonSub.l(allCy,DSBS,YTIME)=0.1;
VElecNonSub.lo(allCy,DSBS,YTIME)=0.0001;
$ontext

VPowerPlantNewEq.VLamda(allCy,PGALL,TT)=0.1;
VHourProdCostOfTech.VLamda(allCy,PGALL,HOUR,TT)=0.1;
VPowerPlaShrNewEq.VLamda(allCy,PGALL,TT)=0.1;
VHourProdCostTech.VLamda(runCy,PGALL,HOUR,TT)$TIME(YTIME) = VPowerPlantNewEq.VLamda(runCy,PGALL,TT)*VHourProdCostOfTech.VLamda(runCy,PGALL,HOUR,TT)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq.VLamda(runCy,CCS,TT)*VHourProdCostOfTech.VLamda(runCy,CCS,HOUR,TT));
VHourProdCostTech.SCALE(runCy,PGALL,HOUR,TT)$TIME(YTIME) = max(abs(VHourProdCostTech.VLamda(runCy,PGALL,HOUR,TT)),1E-20);
$offtext
VNewInvDecis.l(allCy,YTIME)=0.1;
VVarCostTechnology.l(allCy,PGALL,YTIME)=0.1;
VElecPeakLoads.l(allCy,YTIME)=0.1;
VNewCapYearly.l(allCy,PGALL,YTIME)=0.1;
VAvgCapFacRes.l(allCy,PGALL,YTIME)=0.1;
*VOverallCap.scale(allCy,PGALL,YTIME)=1;
VPowPlantSorting.l(runCy,PGALL,YTIME)=0.01;
VReqElecProd.l(runCy,YTIME)=0.1;
*VPowPlantSorting.up(runCy,PGALL,YTIME)=0.001;
*VPowPlantSorting.scale(runCy,PGALL,YTIME)=1;
VElecDem.l(allCy,YTIME)=0.1;
*VHourProdTech.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VHourProdCostTech.lo(runCy,PGALL,HOUR,YTIME)=0.1;
VRenTechMatMult.l(allCy,PGALL,YTIME)=0.1;
VGoodsTranspActiv.l(allCy,TRANSE,YTIME)=0.1;
*VTranspCostPerVeh.lo(allCy,TRANSE,RCon,TTECH,TEA,YTIME)=0.1;
VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
loop an do
   s = s + 1;
   TIME(YTIME) = NO;
   TIME(AN)$(ord(an)=s) = YES;
   display TIME;
VRenValue.l(YTIME)=1;
VCO2CO2SeqCsts.l(allCy,YTIME)=1;
VScalWeibullSum.l(allCy,PGALL,YTIME)=2;
VScalWeibullSum.up(allCy,PGALL,YTIME)=1.0e+10;
VHourProdTech.l(runCy,PGALL,HOUR,TT) = 0.000000001;

********************************************************************************
*                        VARIABLE INITIALISATION                               *
********************************************************************************


VFuelPriceSub.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iConsPricesFuelSub(runCy,SBS,EF,YTIME);
VFuelPriceSub.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iConsPricesFuelSub(runCy,SBS,EF,YTIME));
VFuelPriceSub.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriceSub.FX(runCy,"H2P","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriceSub.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP") $(not An(YTIME))) = iConsPricesFuelSub(runCy,INDDOM,"ELC",YTIME);
VFuelPriceSub.fx(runCy,"H2P",EF,YTIME)$(SECTTECH("H2P",EF) $(not An(YTIME))) = VFuelPriceSub.l(runCy,"PG",EF,YTIME);
VFuelPriceSub.fx(runCy,"H2P","ELC",YTIME)$(not An(YTIME)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME);

VElecPriInduResConsu.FX(runCy,"i",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*0.086;
VElecPriInduResConsu.FX(runCy,"r",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"HOU","ELC",YTIME)*0.086;
VElecPriIndResNoCliPol.FX(runCy,"i",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*0.086;
VElecPriIndResNoCliPol.FX(runCy,"r",YTIME)$(not an(ytime)) = VFuelPriceSub.l(runCy,"HOU","ELC",YTIME)*0.086;
VFuelPriSubNoCarb.FX(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $(not HEATPUMP(EF))  $(not An(YTIME))) = iConsPricesFuelSub(runCy,SBS,EF,YTIME);
VFuelPriSubNoCarb.FX(runCy,SBS,ALTEF,YTIME)$(SECTTECH(SBS,ALTEF) $(not An(YTIME))) = sum(EF$ALTMAP(SBS,ALTEF,EF),iConsPricesFuelSub(runCy,SBS,EF,YTIME));
VFuelPriSubNoCarb.FX(runCy,"PG","NUC",YTIME) = 0.025; !! fixed price for nuclear fuel to 25Euro/toe
VFuelPriSubNoCarb.fx(runCy,INDDOM,"HEATPUMP",YTIME)$(SECTTECH(INDDOM,"HEATPUMP") $(not An(YTIME))) = iConsPricesFuelSub(runCy,INDDOM,"ELC",YTIME);

VFuelPrice.FX(runCy,DSBS,YTIME)$(not An(YTIME)) = sum(EF$SECTTECH(DSBS,EF), iWgtSecAvgPriFueCons(runCy,DSBS,EF) * iConsPricesFuelSub(runCy,DSBS,EF,YTIME));

VNumVeh.UP(runCy,YTIME) = 1000; !! upper bound of VNumVeh is 1000 million vehicles
VNumVeh.FX(runCy,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,"PC");
VLamda.UP(runCy,YTIME) = 1;
VLamda.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1) ) = (VNumVeh.l(runCy,YTIME-1) / (iPop(YTIME-1,runCy)*1000) /
           iPassCarsMarkSat(runCy))$(iPop(YTIME-1,runCy))+VLamda.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));
VMExtF.l(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") *
           EXP(iSigma(runCy,"S3") * VLamda.l(runCy,YTIME)))
               * VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy));

VMExtF.FX(runCy,YTIME)$((not An(YTIME)) $(ord(YTIME) gt 1)  ) = ( iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") *
                          VLamda.l(runCy,YTIME)))* 
                          VNumVeh.l(runCy,YTIME-1) /(iPop(YTIME-1,runCy) * 1000) )$(iPop(YTIME-1,runCy))+VMExtF.l(runCy,YTIME-1)$(not iPop(YTIME-1,runCy));

VMExtV.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","MEXTV");

VScrRate.UP(runCy,YTIME) = 1;
VScrRate.FX(runCy,YTIME)$(not An(YTIME)) = iDataPassCars(runCy,"PC","scr");
VGapTranspFillNewTech.FX(runCy,TRANSE,YTIME)$(not AN(YTIME))=0;
VTrnspActiv.FX(runCy,"PC",YTIME)$(not An(YTIME)) = iTransChar(runCy,"KM_VEH",YTIME);
VTrnspActiv.FX(runCy,TRANP,YTIME)$((not An(YTIME)) $(not sameas(TRANP,"PC"))) = iActv(YTIME,runCy,TRANP);
VTrnspActiv.FX(runCy,TRANSE,YTIME)$(not TRANP(TRANSE)) = 0;
VGoodsTranspActiv.FX(runCy,TRANG,YTIME)$(not An(YTIME)) = iActv(YTIME,runCy,TRANG);
VGoodsTranspActiv.FX(runCy,TRANSE,YTIME)$(not TRANG(TRANSE)) = 0;
VLifeTimeTech.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)  $(not  TRANSE(DSBS)) $(not sameas(DSBS,"PC"))) = iTechLft(runCy,DSBS,EF,TEA,YTIME);
VLifeTimeTech.FX(runCy,TRANSE,TTECH,TEA,YTIME)$(SECTTECH(TRANSE,TTECH) $(not sameas(TRANSE,"PC"))) = iTechLft(runCy,TRANSE,TTECH,TEA,YTIME);
VLifeTimeTech.FX(runCy,DSBS,EF,TEA,YTIME)$(not SECTTECH(DSBS,EF))=0;
VLifeTimeTech.FX(runCy,"PC",TTECH,TEA,YTIME)$( (not AN(YTIME)) $SECTTECH("PC",TTECH))=10;

VSpecificFuelCons.FX(runCy,TRANSE,TTECH,TEA,EF,"2017")$(SECTTECH(TRANSE,EF) ) = iSpeFuelConsCostBy(runCy,TRANSE,TTECH,TEA,EF);
VTechSortVarCostNewEquip.FX(runCy,TRANSE,TTECH,TEA,YTIME)$( SECTTECH(TRANSE,TTECH) $(not AN(YTIME))) = 0;
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $(not PLUGIN(TTECH)) $TTECHtoEF(TTECH,EF)  $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $PLUGIN(TTECH) $(not An(YTIME))) = 0;
VConsEachTechTransp.FX(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(SECTTECH(TRANSE,TTECH)  $CHYBV(TTECH) $(not An(YTIME))) =0;
VDemTr.FX(runCy,TRANSE,EF,YTIME) $(SECTTECH(TRANSE,EF) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,TRANSE,EF,YTIME);

VElecNonSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME) * iShrNonSubElecInTotElecDem(runCy,INDDOM);
VElecConsInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VElecNonSub.l(runCy,INDSE,YTIME));
$ontext
VFuePriSubChp.FX(runCy,DSBS,EF,TEA,YTIME)$((not An(YTIME)) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF)) =
(((VFuelPriceSub.l(runCy,DSBS,EF,YTIME)+iCosTech(runCy,DSBS,EF,TEA,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
(0$(not CHP(EF)) + (VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*iElecIndex(runCy,"2010"))$CHP(EF))) + (0.003) + 
SQRT( SQR(((VFuelPriceSub.l(runCy,DSBS,EF,YTIME)+iCosTech(runCy,DSBS,EF,TEA,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- (0$(not CHP(EF)) + 
(VFuelPriceSub.l(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*iElecIndex(runCy,"2010"))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;
$offtext

VDemSub.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,INDDOM,YTIME) - VElecNonSub.L(runCy,INDDOM,YTIME),1e-5);
VDemSub.FX(runCy,NENSE,YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,NENSE,YTIME),1e-5);
VDemSub.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(iTotFinEneDemSubBaseYr(runCy,"HOU",YTIME) - VElecNonSub.L(runCy,"HOU",YTIME)-iExogDemOfBiomass(runCy,"HOU",YTIME),1e-5);
VDemInd.FX(runCy,YTIME)$(not An(YTIME))= SUM(INDSE,VDemSub.L(runCy,INDSE,YTIME));

VElecIndPrices.FX(runCy,YTIME)$TFIRST(YTIME) = iElecIndex(runCy,YTIME);

VElecConsHeatPla.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = iFuelConsPerFueSub(runCy,INDDOM,"ELC",YTIME)*(1-iShrNonSubElecInTotElecDem(runCy,INDDOM))*iShrHeatPumpElecCons(runCy,INDDOM);

VConsFuel.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) $(not TRANSE(DSBS)) $(not An(YTIME))) = iFuelConsPerFueSub(runCy,DSBS,EF,YTIME);

VConsFuelSub.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) $(not An(YTIME))) =
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME))$((not ELCEF(EF)) $(not HEATPUMP(EF)))
+(VElecConsHeatPla.l(runCy,DSBS,YTIME)*iUsfEneConvSubTech(runCy,DSBS,"HEATPUMP",YTIME))$HEATPUMP(EF)+
(iFuelConsPerFueSub(runCy,DSBS,EF,YTIME)-VElecConsHeatPla.l(runCy,DSBS,YTIME))$ELCEF(EF)
+1e-7$(H2EF(EF) or sameas("STE1AH2F",EF))
;

VTechShareNewEquip.FX(runCy,DSBS,EF,TEA,YTIME)$(SECTTECH(DSBS,EF)$(not An(YTIME))) = 0;
VConsRemSubEquip.FX(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $(not An(ytime))) =
(VConsFuelSub.l(runCy ,DSBS,EF,YTIME) - (VElecNonSub.l(runCy,DSBS,YTIME)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
;



VFeCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
iFinEneConsPrevYear(runCy,EFS,YTIME)$(not An(YTIME)) = iFinEneCons(runCy,EFS,YTIME);
VLosses.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iDistrLosses(runCy,EFS,YTIME);

VTransfOutputPatFuel.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTranfOutGasworks(runCy,EFS,YTIME);
VTransfOutThermPowSta.FX(runCy,EFS,YTIME)$(not TOCTEF(EFS)) = 0;
VRefCapacity.FX(runCy,YTIME)$(not An(YTIME)) = iRefCapacity(runCy,YTIME);
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(EFtoEFA(EFS,"LQD") $(not An(YTIME))) = iTransfOutputRef(runCy,EFS,YTIME);
VTransfInputRefineries.FX(runCy,"CRO",YTIME)$(not An(YTIME)) = iTransfInputRef(runCy,"CRO",YTIME);
VGrsInlConsNotEneBranch.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrossInConsNoEneBra(runCy,EFS,YTIME);
VGrssInCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iGrosInlCons(runCy,EFS,YTIME);
VTransfers.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFeedTransfr(runCy,EFS,YTIME);
VPrimProd.FX(runCy,PPRODEF,YTIME)$(not An(YTIME)) = iFuelPriPro(runCy,PPRODEF,YTIME);
VEnCons.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iTotEneBranchCons(runCy,EFS,YTIME);

VExportsFake.FX(runCy,EFS,YTIME)$(not An(YTIME)) = iFuelExprts(runCy,EFS,YTIME);
VFkImpAllFuelsNotNatGas.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelImports(runCy,"NGS",YTIME);
VExportsFake.FX(runCy,"NGS",YTIME)$(not An(YTIME)) = iFuelExprts(runCy,"NGS",YTIME);

VElecDem.FX(runCy,YTIME)$(not An(YTIME)) =  1/0.086 * ( iFinEneCons(runCy,"ELC",YTIME) + sum(NENSE, iFuelConsPerFueSub(runCy,NENSE,"ELC",YTIME)) + iDistrLosses(runCy,"ELC",YTIME)
                                             + iTotEneBranchCons(runCy,"ELC",YTIME) - (iFuelImports(runCy,"ELC",YTIME)-iFuelExprts(runCy,"ELC",YTIME)));


VCorrBaseLoad.FX(runCy,YTIME)$(not An(YTIME)) = iPeakBsLoadBy(runCy,"BASELOAD");

VCapChpPlants.FX(runCy,YTIME)$(datay(YTIME)) =
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemTr.l(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel.l(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(runCy,INDDOM,"2015")) + sum(TRANSE, VDemTr.l(runCy,TRANSE,"ELC",YTIME)/
         iLoadFacElecDem(runCy,TRANSE,"2015")));

VElecPeakLoad.FX(runCy,YTIME)$(datay(YTIME)) = VElecDem.l(runCy,YTIME)/(VCapChpPlants.l(runCy,YTIME)*8.76);

VTotElecGenCap.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VElecGenNoChp.FX(runCy,YTIME)$(not An(YTIME)) = iTotAvailCapBsYr(runCy);
VElecCapChpPla.FX(runCy,CHP,YTIME)$(not An(YTIME)) = iHisChpGrCapData(runCy,CHP,YTIME);
VPowPlaShaNewEquip.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;

VHourProdTech.FX(runCy,PGALL,HOUR,YTIME)$((NOT AN(YTIME)))=0;

VPowerPlaShrNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VPowerPlantNewEq.FX(runCy,PGALL,YTIME)$((NOT AN(YTIME)) )=0;
VPowerPlaShrNewEq.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT CCS(PGALL)))=0;
VPowerPlantNewEq.FX(runCy,PGALL,YTIME)$(AN(YTIME) $(NOT NOCCS(PGALL)) )=0;

VNewInvDecis.FX(runCy,YTIME)$(NOT AN(YTIME))=1;
$ontext
VElecGenPlanCap.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iAvailInstCapPastYrs(runCy,PGALL,YTIME);
VElecGenPlantsCapac.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =  iAvailInstCapPastYrs(runCy,PGALL,YTIME);
VOverallCap.FX(runCy,PGALL,"2017") =  iAvailInstCapPastYrs(runCy,PGALL,"2017");

$ontext
VNewCapYearly.FX(runCy,PGALL,"2001")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2001")- iAvailInstCapPastYrs(runCy,PGALL,"2000") ;
VNewCapYearly.FX(runCy,PGALL,"2002")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2002")- iAvailInstCapPastYrs(runCy,PGALL,"2001") ;
VNewCapYearly.FX(runCy,PGALL,"2003")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2003")- iAvailInstCapPastYrs(runCy,PGALL,"2002") ;
VNewCapYearly.FX(runCy,PGALL,"2004")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2004")- iAvailInstCapPastYrs(runCy,PGALL,"2003") ;
VNewCapYearly.FX(runCy,PGALL,"2005")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2005")- iAvailInstCapPastYrs(runCy,PGALL,"2004") ;
VNewCapYearly.FX(runCy,PGALL,"2006")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2006")- iAvailInstCapPastYrs(runCy,PGALL,"2005") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2007")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2007")- iAvailInstCapPastYrs(runCy,PGALL,"2006") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2008")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2008")- iAvailInstCapPastYrs(runCy,PGALL,"2007") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2009")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2009")- iAvailInstCapPastYrs(runCy,PGALL,"2008") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2010")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2010")- iAvailInstCapPastYrs(runCy,PGALL,"2009") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2011")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2011")- iAvailInstCapPastYrs(runCy,PGALL,"2010") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2012")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2012")- iAvailInstCapPastYrs(runCy,PGALL,"2011") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2013")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2013")- iAvailInstCapPastYrs(runCy,PGALL,"2012") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2014")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2014")- iAvailInstCapPastYrs(runCy,PGALL,"2013") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2015")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2015")- iAvailInstCapPastYrs(runCy,PGALL,"2014") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2016")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2016")- iAvailInstCapPastYrs(runCy,PGALL,"2015") +1E-10;
VNewCapYearly.FX(runCy,PGALL,"2017")$PGREN(PGALL) = iAvailInstCapPastYrs(runCy,PGALL,"2017")- iAvailInstCapPastYrs(runCy,PGALL,"2016") +1E-10;
VNewCapYearly.FX(runCy,"PGLHYD","2017") = +1E-10;
$offtext
VAvgCapFacRes.FX(runCy,PGALL,YTIME)$DATAY(YTIME) =iPlantAvailRate(runCy,PGALL,YTIME);
$ontext
VElecProdPowGenPlants.FX(runCy,pgall,"2009")=iEleGenPastData(runCy,pgall,"prod_09")/1000;
VElecProdPowGenPlants.FX(runCy,pgall,"2010")=iEleGenPastData(runCy,pgall,"prod_10")/1000;
VElecProdPowGenPlants.FX(runCy,pgall,"2015")=iEleGenPastData(runCy,pgall,"prod_15")/1000;
VElecProdPowGenPlants.FX(runCy,pgall,"2017")=iEleGenPastData(runCy,pgall,"prod_17")/1000;
$offtext

VEndogScrapIndex.FX(runCy,PGALL,YTIME)$(not an(YTIME) ) = 1;
VEndogScrapIndex.FX(runCy,PGSCRN,YTIME) = 1;            !! premature replacement it is not allowed for all new plants


VCO2ElcHrgProd.FX(runCy,YTIME)$(not An(YTIME)) = 0;

VRenShareElecProdSub.FX(runCy,YTIME)$(NOT AN(YTIME))=0;
VRenPotSupplyCurve.FX(runCy,PGRENEF, YTIME) $(NOT AN(YTIME)) = iMinRenPotential(runCy,PGRENEF,YTIME);
$ontext
VAvgPowerGenLongTrm.VLamda(runCy,ESET,"2009") = 0;
VLonPowGenCostNoClimPol.VLamda(runCy,ESET,"2009") = 0;
VAvgPowerGenCostShoTrm.VLamda(runCy,ESET,"2009") = 0;
VLongPowGenCost.VLamda(runCy,PGALL,ESET,"2009") = 0;
VLonAvgPowGenCostNoClimPol.VLamda(runCy,PGALL,ESET,"2009") = 0;
VAvgPowerGenLongTrm.VLamda(runCy,ESET,"2017") = 0;
VLonPowGenCostNoClimPol.VLamda(runCy,ESET,"2017") = 0;
VAvgPowerGenCostShoTrm.VLamda(runCy,ESET,"2017") = 0;
VLongPowGenCost.VLamda(runCy,PGALL,ESET,"2017") = 0;
VLonAvgPowGenCostNoClimPol.VLamda(runCy,PGALL,ESET,"2017") = 0;
$offtext
VCarVal.fx(runCy,NAP,YTIME)$(not An(YTIME))=0;
VCarVal.FX(runCy,"TRADE",YTIME)$an(YTIME) = sExogCarbValue*iCarbValYrExog(YTIME);
VCarVal.FX(runCy,"NOTRADE",YTIME)$an(YTIME) =sExogCarbValue*iCarbValYrExog(YTIME);

VCumCO2Capt.FX(runCy,YTIME)$(not an(YTIME)) = 0 ;

VCO2CO2SeqCsts.FX(runCy,YTIME)$(not an(YTIME)) =
       (iElastCO2Seq(runCy,"mc_a") *iElastCO2Seq(runCy,"mc_b"));

VDemTr.FX(runCy,TRANSE,EF,YTIME)$(not SECTTECH(TRANSE,EF)) = 0;
VTransfOutputDHPlants.FX(runCy,EFS,YTIME)$(not STEAM(EFS)) = 0;
VTransfOutputRefineries.FX(runCy,EFS,YTIME)$(not EFtoEFA(EFS,"LQD")) = 0;
VTransfInputRefineries.FX(runCy,EFS,YTIME)$(not sameas("CRO",EFS)) = 0;
VTransfOutputNuclear.FX(runCy,EFS,YTIME)$(not sameas("ELC",EFS)) = 0;
VTransfInNuclear.FX(runCy,EFS,YTIME)$(not sameas("NUC",EFS)) = 0;
VTransfInThermPowPls.FX(runCy,EFS,YTIME)$(not PGEF(EFS)) = 0;


VExportsFake.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
VFkImpAllFuelsNotNatGas.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;

VScalFacPlaDisp.LO(runCy, HOUR, YTIME)=-1;
VLoadCurveConstr.LO(runCy,YTIME)=0;
VLoadCurveConstr.L(runCy,YTIME)=0.01;

VRenValue.FX(YTIME) = 0 ;
*EFFVAL.FX(YTIME) = 0;
*VEndogScrapIndex.fx(runCy,"athrfo","2017")=0.3;
*VEndogScrapIndex.fx(runCy,"athNGS","2017")=0.9;
VTotReqElecProd.fx(runCy,"2017")=sum(pgall,VElecProdPowGenPlants.L(runCy,pgall,"2017"));
*CONSEF.fx(runCy,INDDOM,CHP,YTIME)  =1-6;