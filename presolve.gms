
*QExp
VExp.L(runCy,EFS,YTIME)$(An(YTIME))
        =
(iFuelExprts(runCy,EFS,YTIME));

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

VPriceFuelSubsecCarVal.L(runCy,SBS,EF,YTIME)$(An(YTIME) $ALTEF(EF)) = iFuelPrice(runCy,SBS,EF,"%fBaseY%")  ;

*QPriceFuelSepCarbonWght
VPriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
    =
iWgtSecAvgPriFueCons(runCy,DSBS,EF) * VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME);

*QPriceFuelAvgSub
VPriceFuelAvgSub.L(runCy,DSBS,YTIME)$(An(YTIME))
            =
    sum(EF$SECTTECH(DSBS,EF), VPriceFuelSepCarbonWght.L(runCy,DSBS,EF,YTIME));

*QPcOwnPcLevl
VPcOwnPcLevl.L(runCy,YTIME)$(An(YTIME)) !! level of saturation of gompertz function
        =
( (VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) / iPassCarsMarkSat(runCy) + 1 - SQRT( SQR((VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) /  iPassCarsMarkSat(runCy) - 1) ) )/2;

*QMEPcNonGdp
VMEPcNonGdp.L(runCy,YTIME)$(An(YTIME))
        =
iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.L(runCy,YTIME))) *
VStockPcYearly.L(runCy,YTIME-1) / (iPop(YTIME-1,runCy) * 1000);

*QMEPcGdp
VMEPcGdp.L(runCy,YTIME)$(An(YTIME))
        =
iTransChar(runCy,"RES_MEXTV",YTIME) * VMEPcGdp.L(runCy,YTIME-1) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))] ** iElastA(runCy,"PC","a",YTIME);

*QStockPcYearly
VStockPcYearly.L(runCy,YTIME)$(An(YTIME))
        =
(VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000) + VMEPcNonGdp.L(runCy,YTIME) + VMEPcGdp.L(runCy,YTIME))
 *iPop(YTIME,runCy) * 1000;

*QRateScrPc
VRateScrPc.L(runCy,YTIME)$(An(YTIME))
        =
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**0.5* VRateScrPc.L(runCy,YTIME-1);

*QNumPcScrap
VNumPcScrap.L(runCy,YTIME)$(An(YTIME))
        =
VRateScrPc.L(runCy,YTIME) * VStockPcYearly.L(runCy,YTIME-1);
display VRateScrPc.L,an;
*QLft
VLft.L(runCy,"PC",TTECH,YTIME)$(An(YTIME)$SECTTECH("pc",TTECH))
        =
1/VRateScrPc.L(runCy,YTIME);

*QNewRegPcYearly
VNewRegPcYearly.L(runCy,YTIME)$(An(YTIME))
        =
(VMEPcNonGdp.L(runCy,YTIME) + VMEPcGdp.L(runCy,YTIME)) * (iPop(YTIME,runCy)*1000)  !! new cars due to GDP
- VStockPcYearly.L(runCy,YTIME-1)*(1 - iPop(YTIME,runCy)/iPop(YTIME-1,runCy))    !! new cars due to population
+ VNumPcScrap.L(runCy,YTIME);

display VPriceFuelAvgSub.l,VStockPcYearly.l,iGDP,ipop;
*QActivPassTrnsp
VActivPassTrnsp.L(runCy,TRANSE,YTIME)$(An(YTIME)$sameas(TRANSE,"PC"))
        =
(  !! passenger cars
VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"b1",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"b2",YTIME) *
[(VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000))/(VStockPcYearly.L(runCy,YTIME)/(iPop(YTIME,runCy)*1000))]**iElastA(runCy,TRANSE,"b3",YTIME) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"b4",YTIME)
)$sameas(TRANSE,"PC");
VActivPassTrnsp.L(runCy,TRANSE,YTIME)$(An(YTIME)$sameas(TRANSE,"PA"))
        =
(  !! passenger aviation
VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
)$sameas(TRANSE,"PA");
VActivPassTrnsp.L(runCy,TRANSE,YTIME)$(An(YTIME)$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA"))))
        =
(   !! other passenger transportation modes
VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME) *
[(VStockPcYearly.L(runCy,YTIME)*VActivPassTrnsp.L(runCy,"PC",YTIME))/(VStockPcYearly.L(runCy,YTIME-1)*VActivPassTrnsp.L(runCy,"PC",YTIME-1))]**iElastA(runCy,TRANSE,"c4",YTIME) *
prod(kpdl,
        [(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-ord(kpdl))/
        VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
        (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
        )
)$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));         

*QActivGoodsTransp
VActivGoodsTransp.L(runCy,TRANG,YTIME)$(An(YTIME)$(sameas(TRANG,"GU")))
        =
    (
    VActivGoodsTransp.L(runCy,TRANG,YTIME-1)
    * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANG,"a",YTIME)
    * (iPop(YTIME,runCy)/iPop(YTIME-1,runCy))
    * (VPriceFuelAvgSub.L(runCy,TRANG,YTIME)/VPriceFuelAvgSub.L(runCy,TRANG,YTIME-1))**iElastA(runCy,TRANG,"c1",YTIME)
    * (VPriceFuelAvgSub.L(runCy,TRANG,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANG,YTIME-2))**iElastA(runCy,TRANG,"c2",YTIME)
    * prod(kpdl,
            [(VPriceFuelAvgSub.L(runCy,TRANG,YTIME-ord(kpdl))/
            VPriceFuelAvgSub.L(runCy,TRANG,YTIME-(ord(kpdl)+1)))/
            (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANG,"c3",YTIME)*iFPDL(TRANG,KPDL))
        )
    );        !!trucks

display VActivGoodsTransp.L;

VActivGoodsTransp.L(runCy,TRANG,YTIME)$(An(YTIME)$(not sameas(TRANG,"GU")))
        =
    (
    VActivGoodsTransp.L(runCy,TRANG,YTIME-1)
    * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANG,"a",YTIME)
    * (VPriceFuelAvgSub.L(runCy,TRANG,YTIME)/VPriceFuelAvgSub.L(runCy,TRANG,YTIME-1))**iElastA(runCy,TRANG,"c1",YTIME)
    * (VPriceFuelAvgSub.L(runCy,TRANG,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANG,YTIME-2))**iElastA(runCy,TRANG,"c2",YTIME)
    * prod(kpdl,
            [(VPriceFuelAvgSub.L(runCy,TRANG,YTIME-ord(kpdl))/
            VPriceFuelAvgSub.L(runCy,TRANG,YTIME-(ord(kpdl)+1)))/
            (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANG,"c3",YTIME)*iFPDL(TRANG,KPDL))
        )  
    * (VActivGoodsTransp.L(runCy,"GU",YTIME)/VActivGoodsTransp.L(runCy,"GU",YTIME-1))**iElastA(runCy,TRANG,"c4",YTIME)

    );                      !!other freight transport 


*QGapTranspActiv
VGapTranspActiv.L(runCy,TRANSE,YTIME)$(An(YTIME))
        =
VNewRegPcYearly.L(runCy,YTIME)$sameas(TRANSE,"PC")
+
(
( [VActivPassTrnsp.L(runCy,TRANSE,YTIME) - VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) + VActivPassTrnsp.L(runCy,TRANSE,YTIME-1)/
(sum((TTECH)$SECTTECH(TRANSE,TTECH),VLft.L(runCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))] +
SQRT( SQR([VActivPassTrnsp.L(runCy,TRANSE,YTIME) - VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) + VActivPassTrnsp.L(runCy,TRANSE,YTIME-1)/
(sum((TTECH)$SECTTECH(TRANSE,TTECH),VLft.L(runCy,TRANSE,TTECH,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
)$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
+
(
( [VActivGoodsTransp.L(runCy,TRANSE,YTIME) - VActivGoodsTransp.L(runCy,TRANSE,YTIME-1) + VActivGoodsTransp.L(runCy,TRANSE,YTIME-1)/
(sum((EF)$SECTTECH(TRANSE,EF),VLft.L(runCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([VActivGoodsTransp.L(runCy,TRANSE,YTIME) - VActivGoodsTransp.L(runCy,TRANSE,YTIME-1) + VActivGoodsTransp.L(runCy,TRANSE,YTIME-1)/
(sum((EF)$SECTTECH(TRANSE,EF),VLft.L(runCy,TRANSE,EF,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
)$TRANG(TRANSE);

display VConsSpecificFuel.L;
display VPriceFuelSubsecCarVal.L;
display iElastA;
display iFPDL;

*QConsSpecificFuel
VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME)$(An(YTIME)$SECTTECH(TRANSE,EF) $TTECHtoEF(TTECH,EF) )
        =
VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME-1) * prod(KPDL,
            (
            VPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME-ord(KPDL))/VPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
            )**(iElastA(runCy,TRANSE,"c5",YTIME)*iFPDL(TRANSE,KPDL))
);


*QCostTranspPerMeanConsSize
VCostTranspPerMeanConsSize.L(runCy,TRANSE,RCon,TTECH,YTIME)$(An(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le iNcon(TRANSE)+1))
=
            (
                (
                (iDisc(runCy,TRANSE,YTIME)*exp(iDisc(runCy,TRANSE,YTIME)*VLft.L(runCy,TRANSE,TTECH,YTIME)))
                /
                (exp(iDisc(runCy,TRANSE,YTIME)*VLft.L(runCy,TRANSE,TTECH,YTIME)) - 1)
                ) * iCapCostTech(runCy,TRANSE,TTECH,YTIME)  * iCGI(runCy,YTIME)
                + iFixOMCostTech(runCy,TRANSE,TTECH,YTIME)  +
                (
                (sum(EF$TTECHtoEF(TTECH,EF),VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
                +
                (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),

                    (1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME)*VPriceFuelSubsecCarVal.L(runCy,TRANSE,EF,YTIME))
                    + iShareAnnMilePlugInHybrid(runCy,YTIME)*VConsSpecificFuel.L(runCy,TRANSE,TTECH,"ELC",YTIME)*VPriceFuelSubsecCarVal.L(runCy,TRANSE,"ELC",YTIME)
                )$PLUGIN(TTECH)

                + iVarCostTech(runCy,TRANSE,TTECH,YTIME)
                + (VRenValue.L(YTIME)/1000)$( not RENEF(TTECH))
                )
                *  iAnnCons(runCy,TRANSE,"smallest") * (iAnnCons(runCy,TRANSE,"largest")/iAnnCons(runCy,TRANSE,"smallest"))**((ord(Rcon)-1)/iNcon(TRANSE))
            );

*QCostTranspPerVeh
VCostTranspPerVeh.L(runCy,TRANSE,rCon,TTECH,YTIME)$(An(YTIME)$SECTTECH(TRANSE,TTECH) $(ord(Rcon) le iNcon(TRANSE)+1))
=
VCostTranspPerMeanConsSize.L(runCy,TRANSE,rCon,TTECH,YTIME)**(-4);

*QCostTranspMatFac
VCostTranspMatFac.L(runCy,TRANSE,RCon,TTECH,YTIME)$(An(YTIME)) 
=
iMatrFactor(runCy,TRANSE,TTECH,YTIME) * VCostTranspPerVeh.L(runCy,TRANSE,rCon,TTECH,YTIME);


*QTechSortVarCost
VTechSortVarCost.L(runCy,TRANSE,rCon,YTIME)$(An(YTIME))
        =
sum((TTECH)$SECTTECH(TRANSE,TTECH), VCostTranspMatFac.L(runCy,TRANSE,rCon,TTECH,YTIME));

*QShareTechTr
    VShareTechTr.L(runCy,TRANSE,TTECH,YTIME)$(An(YTIME))
    =
    iMatrFactor(runCy,TRANSE,TTECH,YTIME) / iCumDistrFuncConsSize(runCy,TRANSE)
    * sum( Rcon$(ord(Rcon) le iNcon(TRANSE)+1),
        VCostTranspPerVeh.L(runCy,TRANSE,RCon,TTECH,YTIME)
        * iDisFunConSize(runCy,TRANSE,RCon) / VTechSortVarCost.L(runCy,TRANSE,RCon,YTIME)
        );

*QConsTechTranspSectoral
    VConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME)$(An(YTIME)$SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF))
            =
    VConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME-1) *
    (
            (
                ((VLft.L(runCy,TRANSE,TTECH,YTIME-1)-1)/VLft.L(runCy,TRANSE,TTECH,YTIME-1))
                *(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
                /(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
            )$(not sameas(TRANSE,"PC"))
            +
            (1 - VRateScrPc.L(runCy,YTIME))$sameas(TRANSE,"PC")
    )
    +
    VShareTechTr.L(runCy,TRANSE,TTECH,YTIME) *
    (
            VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME)$(not PLUGIN(TTECH))
            +
            ( ((1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VConsSpecificFuel.L(runCy,TRANSE,TTECH,EF,YTIME))$(not sameas("ELC",EF))
            + iShareAnnMilePlugInHybrid(runCy,YTIME)*VConsSpecificFuel.L(runCy,TRANSE,TTECH,"ELC",YTIME))$PLUGIN(TTECH)
    )/1000
    * VGapTranspActiv.L(runCy,TRANSE,YTIME) *
    (
            (
            (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
            / (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
            )$(not sameas(TRANSE,"PC"))
            +
            (VActivPassTrnsp.L(runCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
    );

*QDemFinEneTranspPerFuel
VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME)$(An(YTIME))
        =
sum((TTECH)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), VConsTechTranspSectoral.L(runCy,TRANSE,TTECH,EF,YTIME)); 

*qDemFinEneSubTransp
vDemFinEneSubTransp.L(runCy,TRANSE,YTIME)$(An(YTIME))
                 =
         sum(EF,VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME));

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

*QIndxElecIndPrices
VIndxElecIndPrices.L(runCy,YTIME)$(An(YTIME))
        =
VPriceElecInd.L(runCy,YTIME-1) *
((VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-1)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-1))/
(VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-2)))**(0.3) *
((VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-2))/
(VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-3)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-3)))**(0.3);


*QPriceElecInd
    VPriceElecInd.L(runCy,YTIME)$(An(YTIME)) =
( VIndxElecIndPrices.L(runCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VIndxElecIndPrices.L(runCy,YTIME)-sElecToSteRatioChp) + SQR(1E-4) ) )/2;

*QPriceFuelSubsecCHP
VPriceFuelSubsecCHP.L(runCy,DSBS,EF,YTIME)$(An(YTIME)$(not TRANSE(DSBS))  $SECTTECH(DSBS,EF))
    =
    (((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME) + (VRenValue.L(YTIME)/1000)$(not RENEF(EF))+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
    (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd.L(runCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
    (0$(not CHP(EF)) + (VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VPriceElecInd.L(runCy,YTIME))$CHP(EF))))  ) )/2;

*QCostTechIntrm
VCostTechIntrm.L(runCy,DSBS,rCon,EF,YTIME)$(An(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF)) =
        ( (( (iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF)) !! in case of chp plants we use the discount rate of power generation sector
            * exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLft.L(runCy,DSBS,EF,YTIME))
            )
            / (exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLft.L(runCy,DSBS,EF,YTIME))- 1)
        ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
        +
        iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
        +
        VPriceFuelSubsecCHP.L(runCy,DSBS,EF,YTIME)
        * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
        )$INDDOM(DSBS)
        +
        ( (( iDisc(runCy,DSBS,YTIME)
            * exp(iDisc(runCy,DSBS,YTIME)*VLft.L(runCy,DSBS,EF,YTIME))
            )
            / (exp(iDisc(runCy,DSBS,YTIME)*VLft.L(runCy,DSBS,EF,YTIME))- 1)
        ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
        +
        iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
        +
        (
            (VPriceFuelSubsecCarVal.L(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)
        )
        * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
        )$NENSE(DSBS);

*QCostTech
VCostTech.L(runCy,DSBS,rCon,EF,YTIME)$(An(YTIME)$(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF)) 
            =
            VCostTechIntrm.L(runCy,DSBS,rCon,EF,YTIME)**(-iElaSub(runCy,DSBS));

*QCostTechMatFac
VCostTechMatFac.L(runCy,DSBS,rCon,EF,YTIME)$(An(YTIME)) 
                                        =
iMatrFactor(runCy,DSBS,EF,YTIME) * VCostTech.L(runCy,DSBS,rCon,EF,YTIME) ;


*QSortTechVarCost
VSortTechVarCost.L(runCy,DSBS,rCon,YTIME)$(An(YTIME))
                =
sum((EF)$(SECTTECH(DSBS,EF) ),VCostTechMatFac.L(runCy,DSBS,rCon,EF,YTIME));

*QShareTechNewEquip
VShareTechNewEquip.L(runCy,DSBS,EF,YTIME)$(An(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS))) =
iMatrFactor(runCy,DSBS,EF,YTIME) / iCumDistrFuncConsSize(runCy,DSBS) *
sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
        VCostTech.L(runCy,DSBS,rCon,EF,YTIME)
        * iDisFunConSize(runCy,DSBS,rCon)/VSortTechVarCost.L(runCy,DSBS,rCon,YTIME));

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

*QGapFinalDem
VGapFinalDem.L(runCy,DSBS,YTIME)$(An(YTIME))
        =
(VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME))
+ SQRT( SQR(VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME))))) /2;

*QConsFuelInclHP
VConsFuelInclHP.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
        =
VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME)+
(VShareTechNewEquip.L(runCy,DSBS,EF,YTIME)*VGapFinalDem.L(runCy,DSBS,YTIME))
*'        $(VGapFinalDem.L(runCy,DSBS,YTIME)>0)
+ (VConsElecNonSubIndTert.L(runCy,DSBS,YTIME))$(INDDOM(DSBS) and ELCEF(EF));

*QConsFuel
VConsFuel.L(runCy,DSBS,EF,YTIME)$(An(YTIME))
        =
VConsFuelInclHP.L(runCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
(VConsFuelInclHP.L(runCy,DSBS,EF,YTIME) + VElecConsHeatPla.L(runCy,DSBS,YTIME))$ELCEF(EF);

*QCostElecProdCHP
VCostElecProdCHP.L(runCy,DSBS,CHP,YTIME)$(An(YTIME))
        =
        ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP))
            / (exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP)) -1))
            * iInvCostChp(runCy,DSBS,CHP,YTIME)* 1000 * iCGI(runCy,YTIME)  + iFixOMCostPerChp(runCy,DSBS,CHP,YTIME)
        )/(iAvailRateChp(runCy,DSBS,CHP)*(sGwToTwhPerYear))/1000
        + iVarCostChp(runCy,DSBS,CHP,YTIME)/1000
        + sum(PGEF$CHPtoEF(CHP,PGEF), (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)+0.001*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
                * sTWhToMtoe /  (iBoiEffChp(runCy,CHP,YTIME) * VPriceElecInd.L(runCy,YTIME)) );

*QCostProdCHPDem
VCostProdCHPDem.L(runCy,DSBS,CHP,YTIME)$(An(YTIME))
        =
iVarCostChp(runCy,DSBS,CHP,YTIME)/1E3
        + sum(PGEF$CHPtoEF(CHP,PGEF), (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
                *sTWhToMtoe/(   iBoiEffChp(runCy,CHP,YTIME)*VPriceElecInd.L(runCy,YTIME)    ));

*QCostElcAvgProdCHP (second part already has .L values)
VCostElcAvgProdCHP.L(runCy,CHP,YTIME)$(An(YTIME))
=
(sum(INDDOM, VConsFuel.L(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))*VCostElecProdCHP.L(runCy,INDDOM,CHP,YTIME)))$SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

*QCostVarAvgElecProd (second part already has .L values)
    VCostVarAvgElecProd.L(runCy,CHP,YTIME)$(An(YTIME))
    =

    (sum(INDDOM, VConsFuel.L(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))
    *VCostProdCHPDem.L(runCy,INDDOM,CHP,YTIME)))
    $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));


*QConsFinEneCountry
VConsFinEneCountry.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(INDDOM,
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel.L(runCy,INDDOM,EF,YTIME)))
+
sum(TRANSE,
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME)));

*QConsFinNonEne
VConsFinNonEne.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(NENSE$(not sameas("BU",NENSE)),
    sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel.L(runCy,NENSE,EF,YTIME)));

*QLossesDistr
VLossesDistr.L(runCy,EFS,YTIME)$(An(YTIME))
    =
(iRateLossesFinCons(runCy,EFS,YTIME) * (VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME)))$(not H2EF(EFS));

*QOutTransfDhp
VOutTransfDhp.L(runCy,STEAM,YTIME)$(An(YTIME))
    =
sum(DOMSE,
    sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel.L(runCy,DOMSE,DH,YTIME)));

*QTransfInputDHPlants
VTransfInputDHPlants.L(runCy,EFS,YTIME)$(An(YTIME))
    =
sum(DH$DHtoEF(DH,EFS),
    sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel.L(runCy,DOMSE,DH,YTIME)) / iEffDHPlants(runCy,EFS,YTIME));

*QCapRef
    VCapRef.L(runCy,YTIME)$(An(YTIME))
        =
    [
    iResRefCapacity(runCy,YTIME) * VCapRef.L(runCy,YTIME-1)
    *
    (1$(ord(YTIME) le 10) +
    (prod(rc,
    (sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry.L(runCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry.L(runCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
    )
    $(ord(YTIME) gt 10)
    )     ] $iRefCapacity(runCy,"%fStartHorizon%")+0;

*QOutTransfRefSpec
    VOutTransfRefSpec.L(runCy,EFS,YTIME)$(An(YTIME))
        =
    [
    iResTransfOutputRefineries(runCy,EFS,YTIME) * VOutTransfRefSpec.L(runCy,EFS,YTIME-1)
    * (VCapRef.L(runCy,YTIME)/VCapRef.L(runCy,YTIME-1))**0.3
    * (
        1$(TFIRST(YTIME-1) or TFIRST(YTIME-2))
        +
        (
        sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry.L(runCy,EF,YTIME-1))/sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry.L(runCy,EF,YTIME-2))
        )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
    )**(0.7)  ]$iRefCapacity(runCy,"%fStartHorizon%")+0;

*QInputTransfRef
VInputTransfRef.L(runCy,"CRO",YTIME)$(An(YTIME))
    =
[
VInputTransfRef.L(runCy,"CRO",YTIME-1) *
sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec.L(runCy,EFS,YTIME)) /
sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec.L(runCy,EFS,YTIME-1))  ]$iRefCapacity(runCy,"%fStartHorizon%")+0;

*QTransfers
VTransfers.L(runCy,EFS,YTIME)$(An(YTIME)) =
(( (VTransfers.L(runCy,EFS,YTIME-1)*VConsFinEneCountry.L(runCy,EFS,YTIME)/VConsFinEneCountry.L(runCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
(
        VTransfers.L(runCy,"CRO",YTIME-1)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers.L(runCy,EFS2,YTIME))/
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers.L(runCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(runCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);

*QImp
VImp.L(runCy,EFS,YTIME)$(An(YTIME))

        =
(
iRatioImpFinElecDem(runCy,YTIME) * (VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME)) + VExp.L(runCy,EFS,YTIME)
+ iElecImp(runCy,YTIME)
)$ELCEF(EFS)
+
(
VConsGrssInl.L(runCy,EFS,YTIME)+ VExp.L(runCy,EFS,YTIME) + VConsFuel.L(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
- VProdPrimary.L(runCy,EFS,YTIME)
)$(sameas(EFS,"CRO"))

+
(
VConsGrssInl.L(runCy,EFS,YTIME)+ VExp.L(runCy,EFS,YTIME) + VConsFuel.L(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
- VProdPrimary.L(runCy,EFS,YTIME)
)$(sameas(EFS,"NGS"))
*         +iImpExp(runCy,"NGS",YTIME)$(sameas(EFS,"NGS"))
+
(
(1-iRatePriProTotPriNeeds(runCy,EFS,YTIME)) *
(VConsGrssInl.L(runCy,EFS,YTIME) + VExp.L(runCy,EFS,YTIME) + VConsFuel.L(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS) )
)$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));

*QImpNetEneBrnch
VImpNetEneBrnch.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VImp.L(runCy,EFS,YTIME) - VExp.L(runCy,EFS,YTIME);

*QDemElecTot
VDemElecTot.L(runCy,YTIME)$(An(YTIME))
    =
1/sTWhToMtoe *
( VConsFinEneCountry.L(runCy,"ELC",YTIME) + VConsFinNonEne.L(runCy,"ELC",YTIME) + VLossesDistr.L(runCy,"ELC",YTIME)
+ VConsFiEneSec.L(runCy,"ELC",YTIME) - VImpNetEneBrnch.L(runCy,"ELC",YTIME)
);

*QConsElec
VConsElec.l(runCy,DSBS,YTIME)$(An(YTIME))
    =
sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel.l(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemFinEneTranspPerFuel.l(runCy,TRANSE,"ELC",YTIME));

*QBsldEst
VBsldEst.l(runCy,YTIME)$(An(YTIME))
    = 
(
    sum(DSBS, iBaseLoadShareDem(runCy,DSBS,YTIME)*VConsElec.L(runCy,DSBS,YTIME))*(1+iRateLossesFinCons(runCy,"ELC",YTIME))*
    (1 - VImpNetEneBrnch.L(runCy,"ELC",YTIME)/(sum(DSBS, VConsElec.L(runCy,DSBS,YTIME))+VLossesDistr.L(runCy,"ELC",YTIME)))
    + 0.5*VConsFiEneSec.L(runCy,"ELC",YTIME)
) / sTWhToMtoe / sGwToTwhPerYear;

*QLoadFacDom
VLoadFacDom.L(runCy,YTIME)$(An(YTIME))
    =
(sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)))/
(sum(INDDOM,VConsFuel.L(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + 
sum(TRANSE, VDemFinEneTranspPerFuel.L(runCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(TRANSE)));

*QPeakLoad
VPeakLoad.L(runCy,YTIME)$(An(YTIME))
    =
VDemElecTot.L(runCy,YTIME)/(VLoadFacDom.L(runCy,YTIME)*sGwToTwhPerYear);

*QBaseLoadMax ??
 VBaseLoadMax.L(runCy,YTIME)$(An(YTIME)) =

         ((iMxmLoadFacElecDem(runCy,YTIME)*8.76*VPeakLoad.L(runCy,YTIME)-VDemElecTot.L(runCy,YTIME)))/(8.76*(-1+iMxmLoadFacElecDem(runCy,YTIME)));

*QBaseLoad
VBaseLoad.l(runCy,YTIME)$(An(YTIME))
    = (1/(1+exp(iBslCorrection(runCy,YTIME)*(VBsldEst.L(runCy,YTIME)-VBaseLoadMax.L(runCy,YTIME)))))*VBsldEst.L(runCy,YTIME)
+(1-1/(1+exp(iBslCorrection(runCy,YTIME)*(VBsldEst.L(runCy,YTIME)-VBaseLoadMax.L(runCy,YTIME)))))*VBaseLoadMax.L(runCy,YTIME);

VLambda.L(runCy,YTIME)=0.21;
*VLambda.L(runCy,YTIME)$($(An(YTIME)) $(NOT TFIRSTAN(TT)))= VLambda.L(runCy,YTIME-1);

*QProdElecReqTot
VProdElecReqTot.L(runCy,YTIME)$(An(YTIME))
    =
sum(HOUR, (VPeakLoad.L(runCy,YTIME)-VBaseLoad.L(runCy,YTIME))
        * exp(-VLambda.L(runCy,YTIME)*(0.25+(ord(HOUR)-1)))
    ) + 9*VBaseLoad.L(runCy,YTIME);

*QCapElecCHP
VCapElecCHP.L(runCy,CHP,YTIME)$(An(YTIME))
=
1/sTWhToMtoe * sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME)) * VPriceElecInd.L(runCy,YTIME)/
sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
iUtilRateChpPlants(runCy,CHP,YTIME) /sGwToTwhPerYear;

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

*QCostHourProdInvDecNoCCS
VCostHourProdInvDecNoCCS.L(runCy,PGALL,HOUR,YTIME)$(An(YTIME)) =
VShareNewTechNoCCS.L(runCy,PGALL,YTIME)*VCostHourProdInvDec.L(runCy,PGALL,HOUR,YTIME)+
sum(CCS$CCS_NOCCS(CCS,PGALL), VShareNewTechCCS.L(runCy,CCS,YTIME)*VCostHourProdInvDec.L(runCy,CCS,HOUR,YTIME));

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

*QPotRenCurr
VPotRenCurr.L(runCy,PGRENEF,YTIME)$(An(YTIME)) 
=
( VPotRenMaxAllow.L(runCy,PGRENEF,YTIME) + iMinRenPotential(runCy,PGRENEF,YTIME))/2;

*QRenTechMatMultExpr
VRenTechMatMultExpr.L(runCy,PGALL,YTIME)$(An(YTIME))
=
sum(PGRENEF$PGALLtoPGRENEF(PGALL,PGRENEF),
sum(PGALL2$(PGALLtoPGRENEF(PGALL2,PGRENEF) $PGREN(PGALL2)),
VCapElec2.L(runCy,PGALL2,YTIME-1))/VPotRenCurr.L(runCy,PGRENEF,YTIME))-0.6;

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

**QCapElec2
VCapElec2.L(runCy,PGALL,YTIME)$(An(YTIME))
    =
( VCapElec.L(runCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VCapElec.L(runCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*QNewCapElec
VNewCapElec.L(runCy,PGALL,YTIME)$(An(YTIME)) =
VCapElec2.L(runCy,PGALL,YTIME)- VCapElec2.L(runCy,PGALL,YTIME-1);

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

*QScalFacPlantDispatch ??
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

*QProdElec
    VProdElec.L(runCy,PGALL,YTIME)$(An(YTIME))
            =
    VProdElecNonCHP.L(runCy,YTIME) /
    (VProdElecReqTot.L(runCy,YTIME)- VProdElecReqCHP.L(runCy,YTIME))
    * VCapElec2.L(runCy,PGALL,YTIME)* sum(HOUR, exp(-VScalFacPlaDisp.L(runCy,HOUR,YTIME)/VSortPlantDispatch.L(runCy,PGALL,YTIME)));

*QProdElecCHP
    VProdElecCHP.L(runCy,CHP,YTIME)$(An(YTIME))
            =
sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VConsFuel.L(runCy,INDDOM,CHP2,YTIME)))*
(VDemElecTot.L(runCy,YTIME) - SUM(PGALL,VProdElec.L(runCy,PGALL,YTIME)));

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

*QCostPowGenAvgLng
VCostPowGenAvgLng.L(runCy,ESET,YTIME)$(An(YTIME))
        =
(
SUM(PGALL, VProdElec.L(runCy,PGALL,YTIME)*VCostPowGenLngTechNoCp.L(runCy,PGALL,ESET,YTIME))

+
sum(CHP, VCostElcAvgProdCHP.L(runCy,CHP,YTIME)*VProdElecCHP.L(runCy,CHP,YTIME))
)
/VDemElecTot.L(runCy,YTIME);

*QOutTransfNuclear
VOutTransfNuclear.L(runCy,"ELC",YTIME)$(An(YTIME)) = SUM(PGNUCL,VProdElec.L(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*QInpTransfNuclear
VInpTransfNuclear.L(runCy,"NUC",YTIME)$(An(YTIME)) = SUM(PGNUCL,VProdElec.L(runCy,PGNUCL,YTIME)/iPlantEffByType(runCy,PGNUCL,YTIME))*sTWhToMtoe;

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

*QOutTransfTherm
    VOutTransfTherm.L(runCy,TOCTEF,YTIME)$(An(YTIME))
        =
(
        sum(PGALL$(not PGNUCL(PGALL)),VProdElec.L(runCy,PGALL,YTIME)) * sTWhToMtoe
        +
        sum(CHP,VProdElecCHP.L(runCy,CHP,YTIME)*sTWhToMtoe)
    )$ELCEF(TOCTEF)
+
(                                                                                                         
    sum(INDDOM,
    sum(CHP$SECTTECH(INDDOM,CHP), VConsFuel.L(runCy,INDDOM,CHP,YTIME)))+
    iRateEneBranCons(runCy,TOCTEF,YTIME)*(VConsFinEneCountry.L(runCy,TOCTEF,YTIME) + VConsFinNonEne.L(runCy,TOCTEF,YTIME) + VLossesDistr.L(runCy,TOCTEF,YTIME)) + 
    VLossesDistr.L(runCy,TOCTEF,YTIME)                                                                                    
    )$STEAM(TOCTEF);

*QOutTotTransf
VOutTotTransf.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VOutTransfTherm.L(runCy,EFS,YTIME) + VOutTransfDhp.L(runCy,EFS,YTIME) + VOutTransfNuclear.L(runCy,EFS,YTIME) +
VOutTransfRefSpec.L(runCy,EFS,YTIME);

*QInpTotTransf
    VInpTotTransf.L(runCy,EFS,YTIME)$(An(YTIME))
            =
(
    VInpTransfTherm.L(runCy,EFS,YTIME) + VTransfInputDHPlants.L(runCy,EFS,YTIME) + VInpTransfNuclear.L(runCy,EFS,YTIME) +
        VInputTransfRef.L(runCy,EFS,YTIME)     !!$H2PRODEF(EFS)
)$(not sameas(EFS,"OGS"))
+
(
    VOutTotTransf.L(runCy,EFS,YTIME) - VConsFinEneCountry.L(runCy,EFS,YTIME) - VConsFinNonEne.L(runCy,EFS,YTIME) - iRateEneBranCons(runCy,EFS,YTIME)*
    VOutTotTransf.L(runCy,EFS,YTIME) - VLossesDistr.L(runCy,EFS,YTIME)
)$sameas(EFS,"OGS");

*QConsGrssInlNotEneBranch
VConsGrssInlNotEneBranch.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME) + VInpTotTransf.L(runCy,EFS,YTIME) - VOutTotTransf.L(runCy,EFS,YTIME) + VLossesDistr.L(runCy,EFS,YTIME) - 
VTransfers.L(runCy,EFS,YTIME);

*QProdPrimary
VProdPrimary.L(runCy,PPRODEF,YTIME)$(An(YTIME))
        =  [
(
    iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) * (VConsGrssInlNotEneBranch.L(runCy,PPRODEF,YTIME) +  VConsFiEneSec.L(runCy,PPRODEF,YTIME))
)$(not (sameas(PPRODEF,"CRO")or sameas(PPRODEF,"NGS")))
+
(
    iResHcNgOilPrProd(runCy,PPRODEF,YTIME) * VProdPrimary.L(runCy,PPRODEF,YTIME-1) *
    (VConsGrssInlNotEneBranch.L(runCy,PPRODEF,YTIME)/VConsGrssInlNotEneBranch.L(runCy,PPRODEF,YTIME-1))**iNatGasPriProElst(runCy)
)$(sameas(PPRODEF,"NGS") )

+(
iResHcNgOilPrProd(runCy,PPRODEF,YTIME) *  iFuelPriPro(runCy,PPRODEF,YTIME) *
prod(kpdl$(ord(kpdl) lt 5),
                (iPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1))/iPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1)))
                **(0.2*iPolDstrbtnLagCoeffPriOilPr(kpdl)))
)$sameas(PPRODEF,"CRO")   ]$iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME);

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
*QConsGrssInl
VConsGrssInl.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFiEneSec.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME) + VInpTotTransf.L(runCy,EFS,YTIME) - VOutTotTransf.L(runCy,EFS,YTIME) +
VLossesDistr.L(runCy,EFS,YTIME) - VTransfers.L(runCy,EFS,YTIME); 

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

*QImpNetEneBrnch
VImpNetEneBrnch.L(runCy,EFS,YTIME)$(An(YTIME))
                 =
VImp.L(runCy,EFS,YTIME) - VExp.L(runCy,EFS,YTIME);

*QCapCO2ElecHydr
VCapCO2ElecHydr.L(runCy,YTIME)$(An(YTIME))
=
sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
        VProdElec.L(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
        iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)));

*QCaptCummCO2
VCaptCummCO2.L(runCy,YTIME)$(An(YTIME)) = VCaptCummCO2.L(runCy,YTIME-1)+VCapCO2ElecHydr.L(runCy,YTIME-1);

*QTrnsWghtLinToExp
VTrnsWghtLinToExp.L(runCy,YTIME)$(An(YTIME))
=
1/(1+exp(-iElastCO2Seq(runCy,"mc_s")*( VCaptCummCO2.L(runCy,YTIME)/iElastCO2Seq(runCy,"pot")-iElastCO2Seq(runCy,"mc_m")))); 

*QCstCO2SeqCsts
VCstCO2SeqCsts.L(runCy,YTIME)$(An(YTIME)) =
(1-VTrnsWghtLinToExp.L(runCy,YTIME))*(iElastCO2Seq(runCy,"mc_a")*VCaptCummCO2.L(runCy,YTIME)+iElastCO2Seq(runCy,"mc_b"))+
VTrnsWghtLinToExp.L(runCy,YTIME)*(iElastCO2Seq(runCy,"mc_c")*exp(iElastCO2Seq(runCy,"mc_d")*VCaptCummCO2.L(runCy,YTIME))); 

openprom.optfile=1;

openprom.scaleopt=1;

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
