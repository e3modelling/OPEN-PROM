*QPriceElecIndResConsu
VPriceElecIndResConsu.L(runCy,ESET,YTIME)$(An(YTIME))
            =
(1 + iVAT(runCy,YTIME)) *
((
        (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
        (
        VCostPowGenAvgLng.L(runCy,"i",YTIME-1)
        )$(not TFIRST(YTIME-1))
    )$ISET(ESET) + (
        (VPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
        (
        VCostPowGenAvgLng.L(runCy,"r",YTIME-1) 
        )$(not TFIRST(YTIME-1))
    )$RSET(ESET));  
*---
*QPriceFuelSubsecCarVal
VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$(An(YTIME))
        =
(VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME-1) +
iCo2EmiFac(runCy,SBS,EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SBS),(VCarVal.L(runCy,NAP,YTIME)))/1000
)$( not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF)))
+
(
VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF)
)
+
(
( VPriceElecIndResConsu.L(runCy,"i",YTIME)$INDTRANS(SBS)+VPriceElecIndResConsu.L(runCy,"r",YTIME)$RESIDENT(SBS))/sTWhToMtoe
+
((iEffValueInDollars(runCy,SBS,YTIME))/1000)$DSBS(SBS)
)$(ELCEF(EF) or HEATPUMP(EF))
+
(
        iHydrogenPri(runCy,SBS,YTIME-1)$DSBS(SBS)
)$(H2EF(EF) or sameas("STE1AH2F",EF));
*---
*QPriceFuelSubsecCarVal
VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$(An(YTIME) $ALTEF(EF)) = iFuelPrice(runCy,SBS,EF,"%fBaseY%")  ;
*---
*QPriceFuelAvgSub
VPriceFuelAvgSub.L(runCy,DSBS,YTIME)$(An(YTIME))
            =
    sum(EF$SECTTECH(DSBS,EF), VPriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME));
*---
*QLft
VLft.L(runCy,"PC",TTECH,YTIME)$(An(YTIME)$SECTTECH("pc",TTECH))
        =
1/VRateScrPc.L(runCy,YTIME);
*---
display VPriceFuelAvgSub.l,VStockPcYearly.l,iGDP,ipop;
*---
*QDemFinEneTranspPerFuel
VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME)$(An(YTIME))
        =
sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), VConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME)); 
*---
*QConsElecNonSubIndTert
    VConsElecNonSubIndTert.L(runCy,INDDOM,YTIME)$(An(YTIME))
            =
    [
    VConsElecNonSubIndTert.L(runCy,INDDOM,YTIME-1) * ( iActv(YTIME,runCy,INDDOM)/iActv(YTIME-1,runCy,INDDOM) )**
    iElastNonSubElec(runCy,INDDOM,"a",YTIME)
    * ( VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME)/VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME-1) )**iElastNonSubElec(runCy,INDDOM,"b1",YTIME)
    * ( VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME-1)/VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME-2) )**iElastNonSubElec(runCy,INDDOM,"b2",YTIME)
    * prod(KPDL,
            ( VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME-ord(KPDL))/VPriceFuelSubsecCarVal.L(runCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))
            )**( iElastNonSubElec(runCy,INDDOM,"c",YTIME)*iFPDL(INDDOM,KPDL))
        )      ]$iActv(YTIME-1,runCy,INDDOM)+0;
*---
*QDemFinSubFuelSubsec
    VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME)$(An(YTIME))
            =
    [
    VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME-1)
    * ( iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS) )**iElastA(runCy,DSBS,"a",YTIME)
    * ( VPriceFuelAvgSub.L(runCy,DSBS,YTIME)/VPriceFuelAvgSub.L(runCy,DSBS,YTIME-1) )**iElastA(runCy,DSBS,"b1",YTIME)
    * ( VPriceFuelAvgSub.L(runCy,DSBS,YTIME-1)/VPriceFuelAvgSub.L(runCy,DSBS,YTIME-2) )**iElastA(runCy,DSBS,"b2",YTIME)
    * prod(KPDL,
            ( (VPriceFuelAvgSub.L(runCy,DSBS,YTIME-ord(KPDL))/VPriceFuelAvgSub.L(runCy,DSBS,YTIME-(ord(KPDL)+1)))/(iCGI(runCy,YTIME)**(1/6))
            )**( iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
        )  ]$iActv(YTIME-1,runCy,DSBS)+0
;
*---
*QPriceElecInd
    VPriceElecInd.L(runCy,YTIME)$(An(YTIME)) =
( VIndxElecIndPrices.L(runCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VIndxElecIndPrices.L(runCy,YTIME)-sElecToSteRatioChp) + SQR(1E-4) ) )/2;
*---
*QPriceFuelSubsecCHP
VPriceFuelSubsecCHP.L(runCy,DSBS,EF,YTIME)$(An(YTIME)$(not TRANSE(DSBS))  $SECTTECH(DSBS,EF))
    =
    (((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME) + (VRenValue.L(YTIME)/1000)$(not RENEF(EF))+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
    (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd.L(runCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
    (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd.L(runCy,YTIME))$CHP(EF))))  ) )/2;
*---
*QConsRemSubEquipSubSec
    VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME)$(An(YTIME)$(not TRANSE(DSBS)) $SECTTECH(DSBS,EF))
            =
    [
    (VLft.L(runCy,DSBS,EF,YTIME)-1)/VLft.L(runCy,DSBS,EF,YTIME)
    * (VConsFuelInclHP.L(runCy,DSBS,EF,YTIME-1) - (VConsElecNonSubIndTert.L(runCy,DSBS,YTIME-1)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)))))
    * (iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS))**iElastA(runCy,DSBS,"a",YTIME)
    * (VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)/VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME-1))**iElastA(runCy,DSBS,"b1",YTIME)
    * (VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME-1)/VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME-2))**iElastA(runCy,DSBS,"b2",YTIME)
    * prod(KPDL,
            (VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME-ord(KPDL))/VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME-(ord(KPDL)+1)))**(iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
        )  ]$(iActv(YTIME-1,runCy,DSBS));
*---
*QConsFuelInclHP
VConsFuelInclHP.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
        =
VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME)+
(VShareTechNewEquip.L(runCy,DSBS,EF,YTIME)*VGapFinalDem.L(runCy,DSBS,YTIME))
*'        $(VGapFinalDem.L(runCy,DSBS,YTIME)>0)
+ (VConsElecNonSubIndTert.L(runCy,DSBS,YTIME))$(INDDOM(DSBS) and ELCEF(EF));
*---
*QConsFuel
VConsFuel.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
        =
VConsFuelInclHP.L(runCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
(VConsFuelInclHP.L(runCy,DSBS,EF,YTIME) + VElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF);
*---
*QCostElcAvgProdCHP (second part already has .L values)
VCostElcAvgProdCHP.L(runCy,CHP,YTIME)$(An(YTIME))
=
(sum(INDDOM, VConsFuel.L(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))*VCostElecProdCHP.L(runCy,INDDOM,CHP,YTIME)))$SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));
*---
*QCostVarAvgElecProd (second part already has .L values)
    VCostVarAvgElecProd.L(runCy,CHP,YTIME)$(An(YTIME))
    =

    (sum(INDDOM, VConsFuel.L(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))
    *VCostProdCHPDem.L(runCy,INDDOM,CHP,YTIME)))
    $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));
*---
*QConsFinEneCountry
VConsFinEneCountry.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(INDDOM,
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel.L(runCy,INDDOM,EF,YTIME)))
+
sum(TRANSE,
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME)));
*---
*QConsFinNonEne
VConsFinNonEne.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(NENSE$(not sameas("BU",NENSE)),
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel.L(runCy,NENSE,EF,YTIME)));
*---
*QLossesDistr
VLossesDistr.L(runCy,EFS,YTIME)$(An(YTIME))
    =
(iRateLossesFinCons(runCy,EFS,YTIME) * (VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME)))$(not H2EF(EFS));
*---
*QTransfInputDHPlants
VTransfInputDHPlants.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(DH$DHtoEF(DH,EFS),
    sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel.L(runCy,DOMSE,DH,YTIME)) / iEffDHPlants(runCy,EFS,YTIME));
*---
*QImpNetEneBrnch
VImpNetEneBrnch.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VImp.L(runCy,EFS,YTIME) - VExp.L(runCy,EFS,YTIME);
*---
*QDemElecTot
VDemElecTot.L(runCy,YTIME)$(An(YTIME))
    =
1/sTWhToMtoe *
( VConsFinEneCountry.L(runCy,"ELC",YTIME) + VConsFinNonEne.L(runCy,"ELC",YTIME) + VLossesDistr.L(runCy,"ELC",YTIME)
+ VConsFiEneSec.L(runCy,"ELC",YTIME) - VImpNetEneBrnch.L(runCy,"ELC",YTIME)
);
*---
*QConsElec
VConsElec.l(runCy,DSBS,YTIME)$(An(YTIME))
    =
sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME));
*---
*QLoadFacDom
VLoadFacDom.L(runCy,YTIME)$(An(YTIME))
    =
(sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
(sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + 
sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(TRANSE)));
*---
*QPeakLoad
VPeakLoad.L(runCy,YTIME)$(An(YTIME))
    =
VDemElecTot.L(runCy,YTIME)/(VLoadFacDom.L(runCy,YTIME)*sGwToTwhPerYear);
*---
*QProdElecReqTot
VProdElecReqTot.L(runCy,YTIME)$(An(YTIME))
    =
sum(HOUR, (VPeakLoad.L(runCy,YTIME)-VBaseLoad.L(runCy,YTIME))
        * exp(-VLambda.L(runCy,YTIME)*(0.25+(ord(HOUR)-1)))
    ) + 9*VBaseLoad.L(runCy,YTIME);
*---
*QProdElec
    VProdElec.L(runCy,PGALL,YTIME)$(An(YTIME))
            =
    VProdElecNonCHP.L(runCy,YTIME) /
    (VProdElecReqTot.L(runCy,YTIME)- VProdElecReqCHP.L(runCy,YTIME))
    * VCapElec2.L(runCy,PGALL,YTIME)* sum(HOUR, exp(-VScalFacPlaDisp.L(runCy,HOUR,YTIME)/VSortPlantDispatch.L(runCy,PGALL,YTIME)));
*---
*QProdElecCHP
    VProdElecCHP.L(runCy,CHP,YTIME)$(An(YTIME))
            =
sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP2,YTIME)))*
(VDemElecTot.L(runCy,YTIME) - SUM(PGALL,VProdElec.L(runCy,PGALL,YTIME)));
*---
*QCostPowGenAvgLng
VCostPowGenAvgLng.L(runCy,ESET,YTIME)$(An(YTIME))
        =
(
SUM(PGALL, VProdElec.L(runCy,PGALL,YTIME)*VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,YTIME))
+
sum(CHP, VCostElcAvgProdCHP.L(runCy,CHP,YTIME)*VProdElecCHP.L(runCy,CHP,YTIME))
)
/VDemElecTot.L(runCy,YTIME);
*---
*QInpTransfTherm
    VInpTransfTherm.L(runCy,PGEF,YTIME)$(An(YTIME))
        =
sum(PGALL$(PGALLtoEF(PGALL,PGEF)$((not PGGEO(PGALL)) $(not PGNUCL(PGALL)))),
        VProdElec.L(runCy,PGALL,YTIME) * sTWhToMtoe /  iPlantEffByType(runCy,PGALL,YTIME))
+
sum(PGALL$(PGALLtoEF(PGALL,PGEF)$PGGEO(PGALL)),
        VProdElec.L(runCy,PGALL,YTIME) * sTWhToMtoe / 0.15) 
+
sum(CHP$CHPtoEF(CHP,PGEF),  sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME))+sTWhToMtoe*VProdElecCHP.L(runCy,CHP,YTIME))/(0.8+0.1*(ord(YTIME)-10)/32);
*---
*QConsFiEneSec
$ontext
VConsFiEneSec.L(runCy,EFS,YTIME)$(An(YTIME))
        =
iRateEneBranCons(runCy,EFS,YTIME) *
(
(
    VOutTotTransf.L(runCy,EFS,YTIME) +
    VProdPrimary.L(runCy,EFS,YTIME)$(sameas(EFS,"CRO") or sameas(EFS,"NGS"))
)$(not TOCTEF(EFS))
+
(
    VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME) + VLossesDistr.L(runCy,EFS,YTIME)
)$TOCTEF(EFS)
);
$offtext
*---
*QPriceElecIndResNoCliPol
VPriceElecIndResNoCliPol.L(runCy,ESET,YTIME)$(An(YTIME))
            =
(1 + iVAT(runCy, YTIME)) *
(
    (
        (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
        (
        VCostPowGenLonNoClimPol.L(runCy,"i",YTIME-1) 
        )$(not TFIRST(YTIME-1))
    )$ISET(ESET)
+
    (
        (VPriceFuelSubsecCarVal.L(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
        (
        VCostPowGenLonNoClimPol.L(runCy,"r",YTIME-1) 
        )$(not TFIRST(YTIME-1))
    )$RSET(ESET)
);
*---
*QImpNetEneBrnch
VImpNetEneBrnch.L(runCy,EFS,YTIME)$(An(YTIME))
                 =
VImp.L(runCy,EFS,YTIME) - VExp.L(runCy,EFS,YTIME);
*---
*QCstCO2SeqCsts
VCstCO2SeqCsts.L(runCy,YTIME)$(An(YTIME)) =
(1-VTrnsWghtLinToExp.L(runCy,YTIME))*(iElastCO2Seq(runCy,"mc_a")*VCaptCummCO2.L(runCy,YTIME)+iElastCO2Seq(runCy,"mc_b"))+
VTrnsWghtLinToExp.L(runCy,YTIME)*(iElastCO2Seq(runCy,"mc_c")*exp(iElastCO2Seq(runCy,"mc_d")*VCaptCummCO2.L(runCy,YTIME))); 
*---
$ontext
VCostProdSpecTech.scale(runCy,PGALL,YTIME)=max(abs(VCostProdSpecTech.l(runCy,PGALL,YTIME)),1E-20);
QCostProdSpecTech.scale(runCy,PGALL,YTIME)=max(abs(VCostProdSpecTech.l(runCy,PGALL,YTIME)),1E-20);
VCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=VCostVarTechNotPGSCRN.l(runCy,PGALL,YTIME);
QCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME)=VCostVarTechNotPGSCRN.scale(runCy,PGALL,YTIME);
VScalFacPlaDisp.scale(runCy,HOUR,YTIME)=VScalFacPlaDisp.l(runCy,HOUR,YTIME);
QScalFacPlantDispatch.scale(runCy,HOUR,YTIME)=VScalFacPlaDisp.scale(runCy,HOUR,YTIME);
*VSortPlantDispatch.scale(runCy,PGALL,YTIME)=VSortPlantDispatch.l(runCy,PGALL,YTIME);
*QSortPlantDispatch.scale(runCy,PGALL,YTIME)=VSortPlantDispatch.scale(runCy,PGALL,YTIME);
VCostVarTechElec.scale(runCy,PGALL,YTIME)=VCostVarTechElec.l(runCy,PGALL,YTIME);
QCostVarTechElec.scale(runCy,PGALL,YTIME)=VCostVarTechElec.scale(runCy,PGALL,YTIME);
VNewInvElec.scale(runCy,YTIME)=VNewInvElec.l(runCy,YTIME);
QNewInvElec.scale(runCy,YTIME)=VNewInvElec.scale(runCy,YTIME);
*VActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(VActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
*QActivPassTrnsp.scale(runCy,TRANP,YTIME)$(AN(YTIME) and not sameas(TRANP,"PC")) = max(VActivPassTrnsp.l(runCy,TRANP,YTIME),1e-20);
VCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=1e-7;
QCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME)=VCostTranspMatFac.scale(runCy,TRANSE,RCon,TTECH,YTIME);
VTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=1e-8;
QTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME)=VTechSortVarCost.scale(runCy,TRANSE,Rcon,YTIME);
VShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=1e-6;
QShareTechTr.scale(runCy,TRANSE,EF2,YTIME)=VShareTechTr.scale(runCy,TRANSE,EF2,YTIME);
VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=1e-6;
QPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME)=VPriceFuelSepCarbonWght.scale(runCy,DSBS,EF,YTIME);
*VTrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
*QTrnsWghtLinToExp.scale(runCy,YTIME)=1.e-20;
VCostVarTech.scale(runCy,PGALL,YTIME)=1e-5;
QCostVarTech.scale(runCy,PGALL,YTIME)=VCostVarTech.scale(runCy,PGALL,YTIME);
VScalWeibullSum.scale(runCy,PGALL,YTIME)=1e6;
QScalWeibullSum.scale(runCy,PGALL,YTIME)=VScalWeibullSum.scale(runCy,PGALL,YTIME);
$offtext