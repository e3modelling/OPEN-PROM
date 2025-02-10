*QOutTransfDhp
VOutTransfDhp.L(runCy,STEAM,YTIME)$(An(YTIME))
    =
sum(DOMSE,
    sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel.L(runCy,DOMSE,DH,YTIME)));

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

*QOutTransfNuclear
VOutTransfNuclear.L(runCy,"ELC",YTIME)$(An(YTIME)) = SUM(PGNUCL,VProdElec.L(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*QInpTransfNuclear
VInpTransfNuclear.L(runCy,"NUC",YTIME)$(An(YTIME)) = SUM(PGNUCL,VProdElec.L(runCy,PGNUCL,YTIME)/iPlantEffByType(runCy,PGNUCL,YTIME))*sTWhToMtoe;

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

*QOutTotTransf
VOutTotTransf.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VOutTransfTherm.L(runCy,EFS,YTIME) + VOutTransfDhp.L(runCy,EFS,YTIME) + VOutTransfNuclear.L(runCy,EFS,YTIME) +
VOutTransfRefSpec.L(runCy,EFS,YTIME);

*QTransfers
VTransfers.L(runCy,EFS,YTIME)$(An(YTIME)) =
(( (VTransfers.L(runCy,EFS,YTIME-1)*VConsFinEneCountry.L(runCy,EFS,YTIME)/VConsFinEneCountry.L(runCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
(
        VTransfers.L(runCy,"CRO",YTIME-1)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers.L(runCy,EFS2,YTIME))/
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers.L(runCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(runCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);

*QConsGrssInlNotEneBranch
VConsGrssInlNotEneBranch.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME) + VInpTotTransf.L(runCy,EFS,YTIME) - VOutTotTransf.L(runCy,EFS,YTIME) + VLossesDistr.L(runCy,EFS,YTIME) - 
VTransfers.L(runCy,EFS,YTIME);

*QConsGrssInl
VConsGrssInl.L(runCy,EFS,YTIME)$(An(YTIME))
        =
VConsFinEneCountry.L(runCy,EFS,YTIME) + VConsFiEneSec.L(runCy,EFS,YTIME) + VConsFinNonEne.L(runCy,EFS,YTIME) + VInpTotTransf.L(runCy,EFS,YTIME) - VOutTotTransf.L(runCy,EFS,YTIME) +
VLossesDistr.L(runCy,EFS,YTIME) - VTransfers.L(runCy,EFS,YTIME); 

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

*QExp
VExp.L(runCy,EFS,YTIME)$(An(YTIME))
        =
(iFuelExprts(runCy,EFS,YTIME));

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
