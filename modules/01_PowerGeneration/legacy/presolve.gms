**QCapElec2
VCapElec2.L(runCy,PGALL,YTIME)$(An(YTIME))
    =
( VCapElec.L(runCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VCapElec.L(runCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*QRenTechMatMultExpr
VRenTechMatMultExpr.L(runCy,PGALL,YTIME)$(An(YTIME))
=
sum(PGRENEF$PGALLtoPGRENEF(PGALL,PGRENEF),
sum(PGALL2$(PGALLtoPGRENEF(PGALL2,PGRENEF) $PGREN(PGALL2)),
VCapElec2.L(runCy,PGALL2,YTIME-1))/VPotRenCurr.L(runCy,PGRENEF,YTIME))-0.6;

*QPotRenCurr
VPotRenCurr.L(runCy,PGRENEF,YTIME)$(An(YTIME)) 
=
( VPotRenMaxAllow.L(runCy,PGRENEF,YTIME) + iMinRenPotential(runCy,PGRENEF,YTIME))/2;

*QCapElecCHP
VCapElecCHP.L(runCy,CHP,YTIME)$(An(YTIME))
=
1/sTWhToMtoe * sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME)) * VPriceElecInd.L(runCy,YTIME)/
sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
iUtilRateChpPlants(runCy,CHP,YTIME) /sGwToTwhPerYear;

*QBsldEst
VBsldEst.l(runCy,YTIME)$(An(YTIME))
    = 
(
    sum(DSBS, iBaseLoadShareDem(runCy,DSBS,YTIME)*VConsElec.L(runCy,DSBS,YTIME))*(1+iRateLossesFinCons(runCy,"ELC",YTIME))*
    (1 - VImpNetEneBrnch.L(runCy,"ELC",YTIME)/(sum(DSBS, VConsElec.L(runCy,DSBS,YTIME))+VLossesDistr.L(runCy,"ELC",YTIME)))
    + 0.5*VConsFiEneSec.L(runCy,"ELC",YTIME)
) / sTWhToMtoe / sGwToTwhPerYear;

*QBaseLoadMax
 VBaseLoadMax.L(runCy,YTIME)$(An(YTIME)) =

         ((iMxmLoadFacElecDem(runCy,YTIME)*8.76*VPeakLoad.L(runCy,YTIME)-VDemElecTot.L(runCy,YTIME)))/(8.76*(-1+iMxmLoadFacElecDem(runCy,YTIME)));

*QBaseLoad
VBaseLoad.l(runCy,YTIME)$(An(YTIME))
    = (1/(1+exp(iBslCorrection(runCy,YTIME)*(VBsldEst.L(runCy,YTIME)-VBaseLoadMax.L(runCy,YTIME)))))*VBsldEst.L(runCy,YTIME)
+(1-1/(1+exp(iBslCorrection(runCy,YTIME)*(VBsldEst.L(runCy,YTIME)-VBaseLoadMax.L(runCy,YTIME)))))*VBaseLoadMax.L(runCy,YTIME);

VLambda.L(runCy,YTIME)=0.21;
*VLambda.L(runCy,YTIME)$($(An(YTIME)) $(NOT TFIRSTAN(TT)))= VLambda.L(runCy,YTIME-1);

*QCapElecTotEst
VCapElecTotEst.L(runCy,YTIME)$(An(YTIME))
        =
VCapElecTotEst.L(runCy,YTIME-1) * VPeakLoad.L(runCy,YTIME)/VPeakLoad.L(runCy,YTIME-1); 

*QCostHourProdInvDec
VCostHourProdInvDec.L(runCy,PGALL,HOUR,YTIME)$(An(YTIME))
        =
        
        ( ( iDisc(runCy,"PG",YTIME-1) * exp(iDisc(runCy,"PG",YTIME-1)*iTechLftPlaType(runCy,PGALL))
            / (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
            * iGrossCapCosSubRen(PGALL,YTIME-1)* 1E3 * iCGI(runCy,YTIME-1)  + iFixOandMCost(PGALL,YTIME-1)
        )/iAvailRate(PGALL,YTIME-1) / (1000*(ord(HOUR)-1+0.25))
        + iVarCost(PGALL,YTIME-1)/1E3 + (VRenValue.L(YTIME-1)*8.6e-5)$( not ( PGREN(PGALL) 
        $(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) ))
        + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME-1)+
            iCO2CaptRate(runCy,PGALL,YTIME-1)*VCstCO2SeqCsts.L(runCy,YTIME-1)*1e-3*
        iCo2EmiFac(runCy,"PG",PGEF,YTIME-1)
                +(1-iCO2CaptRate(runCy,PGALL,YTIME-1))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME-1)*
                (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME-1))))
                *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME-1))$(not PGREN(PGALL));

*QCostHourProdInvDecNoCCS
VCostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,YTIME)$(An(YTIME)) =
VShareNewTechNoCCS.L(runCy,PGALL,YTIME)*VCostHourProdInvDec.L(runCy,PGALL,HOUR,YTIME)+
sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS.L(runCy,CCS,YTIME)*VCostHourProdInvDec.L(runCy,CCS,HOUR,YTIME));

*QSensCCS(runCy,YTIME)
VSensCCS.L(runCy,YTIME)$(An(YTIME)) = 10+EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME-1)))));

*QCostProdSpecTech
VCostProdSpecTech.L(runCy,PGALL,YTIME)$(An(YTIME)) 
=
sum(HOUR,VCostHourProdInvDec.L(runCy,PGALL,HOUR,YTIME)**(-VSensCCS.L(runCy,YTIME)));

*QShareNewTechCCS
VShareNewTechCCS.L(runCy,PGALL,YTIME)$(An(YTIME)) =
1.1 *VCostProdSpecTech.L(runCy,PGALL,YTIME)
/(1.1*VCostProdSpecTech.L(runCy,PGALL,YTIME)
+ sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),VCostProdSpecTech.L(runCy,PGALL2,YTIME))
);

*QShareNewTechNoCCS (wrong place!!!!!!)
VShareNewTechNoCCS.L(runCy,PGALL,YTIME)$(An(YTIME)) 
=
1 - sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS.L(runCy,CCS,YTIME));

*QCostVarTech
VCostVarTech.L(runCy,PGALL,YTIME)$(An(YTIME))  =
    (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)/1.2441+
    iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts.L(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
    + (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
    *(sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
    *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)));

*QCostVarTechNotPGSCRN
VCostVarTechNotPGSCRN.L(runCy,PGALL,YTIME)$(An(YTIME)) 
    =
VCostVarTech.L(runCy,PGALL,YTIME)**(-5);

*QCostProdTeCHPreReplac
VCostProdTeCHPreReplac.L(runCy,PGALL,YTIME)$(An(YTIME)) =
            (
                ((iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))/
                (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
                * iGrossCapCosSubRen(PGALL,YTIME)* 1E3 * iCGI(runCy,YTIME)  + 
                iFixOandMCost(PGALL,YTIME))/(8760*iAvailRate(PGALL,YTIME))
                + (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), 
                (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)+
                iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts.L(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
                    (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
                        *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)))
                );
*QCostProdTeCHPreReplacAvail
VCostProdTeCHPreReplacAvail.L(runCy,PGALL,PGALL2,YTIME)$(An(YTIME)) =
iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME)*VCostProdTeCHPreReplac.L(runCy,PGALL,YTIME)+
VCostVarTech.L(runCy,PGALL,YTIME)*(1-iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME));

*QIndxEndogScrap
VIndxEndogScrap.L(runCy,PGALL,YTIME)$(An(YTIME))
        =
VCostVarTechNotPGSCRN.L(runCy,PGALL,YTIME)/
(VCostVarTechNotPGSCRN.L(runCy,PGALL,YTIME)+(iScaleEndogScrap(PGALL)*
sum(PGALL2,VCostProdTeCHPreReplacAvail.L(runCy,PGALL,PGALL2,YTIME)))**(-5));

*QCapElecNonCHP
VCapElecNonCHP.L(runCy,YTIME)$(An(YTIME))
=
VCapElecTotEst.L(runCy,YTIME) - SUM(CHP,VCapElecCHP.L(runCy,CHP,YTIME)*0.85);

*QGapGenCapPowerDiff
VGapGenCapPowerDiff.L(runCy,YTIME)$(An(YTIME))
    =
(        (  VCapElecNonCHP.L(runCy,YTIME) - VCapElecNonCHP.L(runCy,YTIME-1) + sum(PGALL,VCapElec2.L(runCy,PGALL,YTIME-1) * 
(1 - VIndxEndogScrap.L(runCy,PGALL,YTIME))) +
sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
+ Sum(PGALL$PGSCRN(PGALL), (VCapElec.L(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
iTechLftPlaType(runCy,PGALL))
)
+ 0 + SQRT( SQR(       (  VCapElecNonCHP.L(runCy,YTIME) - VCapElecNonCHP.L(runCy,YTIME-1) +
sum(PGALL,VCapElec2.L(runCy,PGALL,YTIME-1) * (1 - VIndxEndogScrap.L(runCy,PGALL,YTIME))) +
sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
+ Sum(PGALL$PGSCRN(PGALL), (VCapElec.L(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
iTechLftPlaType(runCy,PGALL))
) -0) + SQR(1e-10) ) )/2;
*QPotRenSuppCurve (wrong place!!!!!!)
VPotRenSuppCurve.L(runCy,PGRENEF,YTIME)$(An(YTIME)) =
iMinRenPotential(runCy,PGRENEF,YTIME) +(VCarVal.L(runCy,"Trade",YTIME))/(70)*
(iMaxRenPotential(runCy,PGRENEF,YTIME)-iMinRenPotential(runCy,PGRENEF,YTIME));

*QPotRenMaxAllow
VPotRenMaxAllow.L(runCy,PGRENEF,YTIME)$(An(YTIME)) =
( VPotRenSuppCurve.L(runCy,PGRENEF,YTIME)+ iMaxRenPotential(runCy,PGRENEF,YTIME))/2;

*QRenTechMatMult
VRenTechMatMult.L(runCy,PGALL,YTIME)$(An(YTIME))
=
1
+
(
1/(1+exp(10*VRenTechMatMultExpr.L(runCy,PGALL,YTIME)))
)$PGREN(PGALL);

*QScalWeibullSum
VScalWeibullSum.L(runCy,PGALL,YTIME)$(An(YTIME)$(not CCS(PGALL)))
=
    iMatFacPlaAvailCap(runCy,PGALL,YTIME) * VRenTechMatMult.L(runCy,PGALL,YTIME)*
    sum(HOUR,
        (VCostHourProdInvDec.L(runCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
        +
        VCostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,YTIME)$NOCCS(PGALL)
        )**(-6)
    );

*QNewInvElec
VNewInvElec.L(runCy,YTIME)$(An(YTIME))
    =
sum(PGALL$(not CCS(PGALL)),VScalWeibullSum.L(runCy,PGALL,YTIME));

*QSharePowPlaNewEq
VSharePowPlaNewEq.L(runCy,PGALL,YTIME)$(An(YTIME))
        =
    ( VScalWeibullSum.L(runCy,PGALL,YTIME)/ VNewInvElec.L(runCy,YTIME))$(not CCS(PGALL))
    +
    sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),VSharePowPlaNewEq.L(runCy,NOCCS,YTIME))$CCS(PGALL);

*QCapElec
VCapElec.L(runCy,PGALL,YTIME)$(An(YTIME))
    =
(VCapElec2.L(runCy,PGALL,YTIME-1)*VIndxEndogScrap.L(runCy,PGALL,YTIME-1)
+(VSharePowPlaNewEq.L(runCy,PGALL,YTIME) * VGapGenCapPowerDiff.L(runCy,YTIME))$( (not CCS(PGALL)) AND (not NOCCS(PGALL)))
+(VSharePowPlaNewEq.L(runCy,PGALL,YTIME) * VShareNewTechNoCCS.L(runCy,PGALL,YTIME) * VGapGenCapPowerDiff.L(runCy,YTIME))$NOCCS(PGALL)
+(VSharePowPlaNewEq.L(runCy,PGALL,YTIME) * VShareNewTechNoCCS.L(runCy,PGALL,YTIME) * VGapGenCapPowerDiff.L(runCy,YTIME))$CCS(PGALL)
+ iDecInvPlantSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
- iPlantDecomSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
)
- ((VCapElec.L(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME-1))* 
iAvailRate(PGALL,YTIME)*(1/iTechLftPlaType(runCy,PGALL)))$PGSCRN(PGALL);

*QCostVarTechElec
VCostVarTechElec.L(runCy,PGALL,YTIME)$(An(YTIME))
=
iMatureFacPlaDisp(runCy,PGALL,YTIME)*VCostVarTech.L(runCy,PGALL,YTIME)**(-2);

*QCostVarTechElecTot
VCostVarTechElecTot.L(runCy,YTIME)$(An(YTIME)) 
=
sum(PGALL, VCostVarTechElec.L(runCy,PGALL,YTIME));

*QSortPlantDispatch
VSortPlantDispatch.L(runCy,PGALL,YTIME)$(An(YTIME))
        =
VCostVarTechElec.L(runCy,PGALL,YTIME)
/
VCostVarTechElecTot.L(runCy,YTIME);

*QNewCapElec
VNewCapElec.L(runCy,PGALL,YTIME)$(An(YTIME)) =
VCapElec2.L(runCy,PGALL,YTIME)- VCapElec2.L(runCy,PGALL,YTIME-1);

*QCFAvgRen
VCFAvgRen.L(runCy,PGALL,YTIME)$(An(YTIME))
=
(iAvailRate(PGALL,YTIME)*VNewCapElec.L(runCy,PGALL,YTIME)+
iAvailRate(PGALL,YTIME-1)*VNewCapElec.L(runCy,PGALL,YTIME-1)+
iAvailRate(PGALL,YTIME-2)*VNewCapElec.L(runCy,PGALL,YTIME-2)+
iAvailRate(PGALL,YTIME-3)*VNewCapElec.L(runCy,PGALL,YTIME-3)+
iAvailRate(PGALL,YTIME-4)*VNewCapElec.L(runCy,PGALL,YTIME-4)+
iAvailRate(PGALL,YTIME-5)*VNewCapElec.L(runCy,PGALL,YTIME-5)+
iAvailRate(PGALL,YTIME-6)*VNewCapElec.L(runCy,PGALL,YTIME-6)+
iAvailRate(PGALL,YTIME-7)*VNewCapElec.L(runCy,PGALL,YTIME-7))/
(VNewCapElec.L(runCy,PGALL,YTIME)+VNewCapElec.L(runCy,PGALL,YTIME-1)+VNewCapElec.L(runCy,PGALL,YTIME-2)+
VNewCapElec.L(runCy,PGALL,YTIME-3)+VNewCapElec.L(runCy,PGALL,YTIME-4)+VNewCapElec.L(runCy,PGALL,YTIME-5)+
VNewCapElec.L(runCy,PGALL,YTIME-6)+VNewCapElec.L(runCy,PGALL,YTIME-7));

*QCapOverall
VCapOverall.L(runCy,PGALL,YTIME)$(An(YTIME))
=
VCapElec2.L(runCy,pgall,ytime)$ (not PGREN(PGALL))
+VCFAvgRen.L(runCy,PGALL,YTIME-1)*(VNewCapElec.L(runCy,PGALL,YTIME)/iAvailRate(PGALL,YTIME)+
VCapOverall.L(runCy,PGALL,YTIME-1)
/VCFAvgRen.L(runCy,PGALL,YTIME-1))$PGREN(PGALL);

*QScalFacPlantDispatch
VScalFacPlaDisp.L(runCy,HOUR,YTIME)$(An(YTIME))= 1e-10;

*QProdElecEstCHP
VProdElecEstCHP.L(runCy,YTIME)$(An(YTIME)) 
=
( (1/0.086 * sum((INDDOM,CHP),VConsFuel.L(runCy,INDDOM,CHP,YTIME)) * VPriceElecInd.L(runCy,YTIME)) + 
iMxmShareChpElec(runCy,YTIME)*VDemElecTot.L(runCy,YTIME) - SQRT( SQR((1/0.086 * sum((INDDOM,CHP),VConsFuel.L(runCy,INDDOM,CHP,YTIME)) * 
VPriceElecInd.L(runCy,YTIME)) - 
iMxmShareChpElec(runCy,YTIME)*VDemElecTot.L(runCy,YTIME)) + SQR(1E-4) ) )/2;

*QProdElecNonCHP
VProdElecNonCHP.L(runCy,YTIME)$(An(YTIME)) 
=
(VDemElecTot.L(runCy,YTIME) - VProdElecEstCHP.L(runCy,YTIME));

*QProdElecReqCHP
VProdElecReqCHP.L(runCy,YTIME)$(An(YTIME)) 
=
sum(hour, sum(CHP,VCapElecCHP.L(runCy,CHP,YTIME)*exp(-VScalFacPlaDisp.L(runCy,HOUR,YTIME)/ 
sum(pgall$chptoeon(chp,pgall),VSortPlantDispatch.L(runCy,PGALL,YTIME)))));

*QCostPowGenLngTechNoCp
VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,YTIME)$(An(YTIME))
        =

    (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
    (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
    iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
    / (1000*(6$ISET(ESET)+4$RSET(ESET))) +
    sum(PGEF$PGALLTOEF(PGALL,PGEF),
        (iVarCost(PGALL,YTIME)/1000+(VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)/1.2441+
        iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts.L(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
        (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
        (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
        *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*QCostAvgPowGenLonNoClimPol
VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,YTIME)$(An(YTIME))
        =

    (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
    (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
    iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
    / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
    sum(PGEF$PGALLTOEF(PGALL,PGEF),
        (iVarCost(PGALL,YTIME)/1000+((VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)-iEffValueInDollars(runCy,"PG",ytime)/1000-iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
        sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))/1000 )/1.2441+

        iCO2CaptRate(runCy,PGALL,YTIME)*VCstCO2SeqCsts.L(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

        (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

        (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))

        *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*QCostPowGenLonNoClimPol
VCostPowGenLonNoClimPol.L(runCy,ESET,YTIME)$(An(YTIME))
        =
(
SUM(PGALL, (VProdElec.L(runCy,PGALL,YTIME))*VCostAvgPowGenLonNoClimPol.L(runCy,PGALL,ESET,YTIME))

+
sum(CHP, VCostElcAvgProdCHP.L(runCy,CHP,YTIME)*VProdElecCHP.L(runCy,CHP,YTIME))
)
/(VDemElecTot.L(runCy,YTIME));
