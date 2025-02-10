*QIndxElecIndPrices
VIndxElecIndPrices.L(runCy,YTIME)$(An(YTIME))
        =
VPriceElecInd.L(runCy,YTIME-1) *
((VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-1)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-1))/
(VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-2)))**(0.3) *
((VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-2)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-2))/
(VPriceFuelSubsecCarVal.L(runCy,"OI","ELC",YTIME-3)/VPriceFuelAvgSub.L(runCy,"OI",YTIME-3)))**(0.3);

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

*QCostTech
VCostTech.L(runCy,DSBS,rCon,EF,YTIME)$(An(YTIME)$(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF)) 
            =
            VCostTechIntrm.L(runCy,DSBS,rCon,EF,YTIME)**(-iElaSub(runCy,DSBS));

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

*QCostTechMatFac
VCostTechMatFac.L(runCy,DSBS,rCon,EF,YTIME)$(An(YTIME)) 
                                        =
iMatrFactor(runCy,DSBS,EF,YTIME) * VCostTech.L(runCy,DSBS,rCon,EF,YTIME) ;

*QSortTechVarCost
VSortTechVarCost.L(runCy,DSBS,rCon,YTIME)$(An(YTIME))
                =
sum((EF)$(SECTTECH(DSBS,EF) ),VCostTechMatFac.L(runCy,DSBS,rCon,EF,YTIME));

*QGapFinalDem
VGapFinalDem.L(runCy,DSBS,YTIME)$(An(YTIME))
        =
(VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME))
+ SQRT( SQR(VDemFinSubFuelSubsec.L(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquipSubSec.L(runCy,DSBS,EF,YTIME))))) /2;

*QShareTechNewEquip
VShareTechNewEquip.L(runCy,DSBS,EF,YTIME)$(An(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS))) =
iMatrFactor(runCy,DSBS,EF,YTIME) / iCumDistrFuncConsSize(runCy,DSBS) *
sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
        VCostTech.L(runCy,DSBS,rCon,EF,YTIME)
        * iDisFunConSize(runCy,DSBS,rCon)/VSortTechVarCost.L(runCy,DSBS,rCon,YTIME));

*QCostProdCHPDem
VCostProdCHPDem.L(runCy,DSBS,CHP,YTIME)$(An(YTIME))
        =
iVarCostChp(runCy,DSBS,CHP,YTIME)/1E3
        + sum(PGEF$CHPtoEF(CHP,PGEF), (VPriceFuelSubsecCarVal.L(runCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal.L(runCy,NAP,YTIME))))
                *sTWhToMtoe/(   iBoiEffChp(runCy,CHP,YTIME)*VPriceElecInd.L(runCy,YTIME)    ));
