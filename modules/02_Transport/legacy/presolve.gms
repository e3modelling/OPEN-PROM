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

*QActivGoodsTransp
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

*qDemFinEneSubTransp IT'S COMMENTED OUT!!
vDemFinEneSubTransp.L(runCy,TRANSE,YTIME)$(An(YTIME))
                 =
         sum(EF,VDemFinEneTranspPerFuel.L(runCy,TRANSE,EF,YTIME));

*QMEPcGdp
VMEPcGdp.L(runCy,YTIME)$(An(YTIME))
        =
iTransChar(runCy,"RES_MEXTV",YTIME) * VMEPcGdp.L(runCy,YTIME-1) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))] ** iElastA(runCy,"PC","a",YTIME);

*QMEPcNonGdp
VMEPcNonGdp.L(runCy,YTIME)$(An(YTIME))
        =
iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") * VPcOwnPcLevl.L(runCy,YTIME))) *
VStockPcYearly.L(runCy,YTIME-1) / (iPop(YTIME-1,runCy) * 1000);

*QStockPcYearly
VStockPcYearly.L(runCy,YTIME)$(An(YTIME))
        =
(VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000) + VMEPcNonGdp.L(runCy,YTIME) + VMEPcGdp.L(runCy,YTIME))
 *iPop(YTIME,runCy) * 1000;

*QNewRegPcYearly
VNewRegPcYearly.L(runCy,YTIME)$(An(YTIME))
        =
(VMEPcNonGdp.L(runCy,YTIME) + VMEPcGdp.L(runCy,YTIME)) * (iPop(YTIME,runCy)*1000)  !! new cars due to GDP
- VStockPcYearly.L(runCy,YTIME-1)*(1 - iPop(YTIME,runCy)/iPop(YTIME-1,runCy))    !! new cars due to population
+ VNumPcScrap.L(runCy,YTIME);

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

*QActivPassTrnsp
VActivPassTrnsp.L(runCy,TRANSE,YTIME)$(An(YTIME)$sameas(TRANSE,"PA"))
        =
(  !! passenger aviation
VActivPassTrnsp.L(runCy,TRANSE,YTIME-1) *
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
(VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-1)/VPriceFuelAvgSub.L(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
)$sameas(TRANSE,"PA");

*QActivPassTrnsp
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

display VConsSpecificFuel.L;
display VPriceFuelSubsecCarVal.L;
display iElastA;
display iFPDL;

*QNumPcScrap
VNumPcScrap.L(runCy,YTIME)$(An(YTIME))
        =
VRateScrPc.L(runCy,YTIME) * VStockPcYearly.L(runCy,YTIME-1);
display VRateScrPc.L,an;

*QPcOwnPcLevl
VPcOwnPcLevl.L(runCy,YTIME)$(An(YTIME)) !! level of saturation of gompertz function
        =
( (VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) / iPassCarsMarkSat(runCy) + 1 - SQRT( SQR((VStockPcYearly.L(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) /  iPassCarsMarkSat(runCy) - 1) ) )/2;

*QRateScrPc
VRateScrPc.L(runCy,YTIME)$(An(YTIME))
        =
[(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**0.5* VRateScrPc.L(runCy,YTIME-1);
