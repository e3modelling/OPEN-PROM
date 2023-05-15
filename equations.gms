* Power Generation

* Compute total electricity demand
QElecDem(runCy,YTIME)$TIME(YTIME)..
         VElecDem(runCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VFeCons(runCy,"ELC",YTIME) + VFNonEnCons(runCy,"ELC",YTIME) + VLosses(runCy,"ELC",YTIME)
           + VEnCons(runCy,"ELC",YTIME) - VNetImp(runCy,"ELC",YTIME)
         );

* Compute estimated base load
QEstBaseLoad(runCy,YTIME)$TIME(YTIME)..
         VEstBaseLoad(runCy,YTIME)
             =E=
         (
             sum(DSBS, iBaseLoadShareDem(runCy,DSBS,YTIME)*VElecConsAll(runCy,DSBS,YTIME))*(1+iRateLossesFinCons(runCy,"ELC",YTIME))*
             (1 - VNetImports(runCy,"ELC",YTIME)/(sum(DSBS, VElecConsAll(runCy,DSBS,YTIME))+VLosses(runCy,"ELC",YTIME)))
             + 0.5*VEnCons(runCy,"ELC",YTIME)
         ) / sTWhToMtoe / sGwToTwhPerYear;

* Compute load factor of entire domestic system
QLoadFacDom(runCy,YTIME)$TIME(YTIME)..
         VCapChpPlants(runCy,YTIME)
             =E=
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemTr(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(runCy,INDDOM,YTIME)) + 
         sum(TRANSE, VDemTr(runCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(runCy,TRANSE,YTIME)));         

* Compute elerctricity peak load
QElecPeakLoad(runCy,YTIME)$TIME(YTIME)..
         VElecPeakLoad(runCy,YTIME)
             =E=
         VElecDem(runCy,YTIME)/(VCapChpPlants(runCy,YTIME)*sGwToTwhPerYear);
* Transport

* Compute passenger cars market extension (GDP dependent)
QMExtV(runCy,YTIME)$TIME(YTIME)..
         VMExtV(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTV",YTIME) * VMExtV(runCy,YTIME-1) *
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))] ** iElastA(runCy,"PC","a",YTIME);

* Compute passenger cars market extension (GDP independent)
QMExtF(runCy,YTIME)$TIME(YTIME)..
         VMExtF(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") * VLamda(runCy,YTIME))) *
         VNumVeh(runCy,YTIME-1) / (iPop(YTIME-1,runCy) * 1000);

* Compute stock of passenger cars (in million vehicles)
QNumVeh(runCy,YTIME)$TIME(YTIME)..
         VNumVeh(runCy,YTIME)
                 =E=
         (VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000) + VMExtF(runCy,YTIME) + VMExtV(runCy,YTIME)) *
         iPop(YTIME,runCy) * 1000;

* Compute new registrations of passenger cars
QNewReg(runCy,YTIME)$TIME(YTIME)..
         VNewReg(runCy,YTIME)
                 =E=
         (VMExtF(runCy,YTIME) + VMExtV(runCy,YTIME)) * (iPop(YTIME,runCy)*1000)  !! new cars due to GDP
         - VNumVeh(runCy,YTIME-1)*(1 - iPop(YTIME,runCy)/iPop(YTIME-1,runCy))    !! new cars due to population
         + VScrap(runCy,YTIME);                                                  !! new cars due to scrapping

* Compute passenger transport activity
QTrnspActiv(runCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE))..
         VTrnspActiv(runCy,TRANSE,YTIME)
                 =E=
         (  !! passenger cars
           iResActiv(runCy,TRANSE,YTIME) * VTrnspActiv(runCy,TRANSE,YTIME-1) *
           (VFuelPrice(runCy,TRANSE,YTIME)/VFuelPrice(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"b1",YTIME) *
           (VFuelPrice(runCy,TRANSE,YTIME-1)/VFuelPrice(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"b2",YTIME) *
           [(VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000))/(VNumVeh(runCy,YTIME)/(iPop(YTIME,runCy)*1000))]**iElastA(runCy,TRANSE,"b3",YTIME) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"b4",YTIME)
         )$sameas(TRANSE,"PC") +
         (  !! passenger aviation
           iResActiv(runCy,TRANSE,YTIME) * VTrnspActiv(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VFuelPrice(runCy,TRANSE,YTIME)/VFuelPrice(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VFuelPrice(runCy,TRANSE,YTIME-1)/VFuelPrice(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
         )$sameas(TRANSE,"PA") +
         (   !! other passenger transportation modes
          iResActiv(runCy,TRANSE,YTIME) * VTrnspActiv(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VFuelPrice(runCy,TRANSE,YTIME)/VFuelPrice(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VFuelPrice(runCy,TRANSE,YTIME-1)/VFuelPrice(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME) *
           [(VNumVeh(runCy,YTIME)*VTrnspActiv(runCy,"PC",YTIME))/(VNumVeh(runCy,YTIME-1)*VTrnspActiv(runCy,"PC",YTIME-1))]**iElastA(runCy,TRANSE,"c4",YTIME) *
           prod(kpdl,
                  [(VFuelPrice(runCy,TRANSE,YTIME-ord(kpdl))/
                    VFuelPrice(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

* Compute scrapped passenger cars
QScrap(runCy,YTIME)$TIME(YTIME)..
         VScrap(runCy,YTIME)
                 =E=
         VScrRate(runCy,YTIME) * VNumVeh(runCy,YTIME-1);

* Compute ratio of car ownership over saturation car ownership
QLevl(runCy,YTIME)$TIME(YTIME)..
         VLamda(runCy,YTIME) !! level of saturation of gompertz function
                 =E=
         ( (VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) / iSigma(runCy,"SAT") + 1 - SQRT( SQR((VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) /  iSigma(runCy,"SAT") - 1) + SQR(1E-4) ) )/2;

* Compute passenger cars scrapping rate
QScrRate(runCy,YTIME)$TIME(YTIME)..
         VScrRate(runCy,YTIME)
                  =E=
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**0.5
         * VScrRate(runCy,YTIME-1);

* Compute electricity consumption per final demand sector
QElecConsAll(runCy,DSBS,YTIME)$TIME(YTIME)..
         VElecConsAll(runCy,DSBS,YTIME)
             =E=
         sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemTr(runCy,TRANSE,"ELC",YTIME));


* INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES

* Compute total final demand per subsector
QDemSub(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VDemSub(runCy,DSBS,YTIME)
                 =E=
         [
         iResDemSub(runCy,DSBS,YTIME) * VDemSub(runCy,DSBS,YTIME-1)
         * ( iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS) )**iElastA(runCy,DSBS,"a",YTIME)
         * ( VFuelPrice(runCy,DSBS,YTIME)/VFuelPrice(runCy,DSBS,YTIME-1) )**iElastA(runCy,DSBS,"b1",YTIME)
         * ( VFuelPrice(runCy,DSBS,YTIME-1)/VFuelPrice(runCy,DSBS,YTIME-2) )**iElastA(runCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                  ( (VFuelPrice(runCy,DSBS,YTIME-ord(KPDL))/VFuelPrice(runCy,DSBS,YTIME-(ord(KPDL)+1)))/(iCGI(runCy,YTIME)**(1/6))
                  )**( iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
                )  ]$iActv(YTIME-1,runCy,DSBS)
;

* Compute Consumption of electricity in industrial sectors
QElecConsInd(runCy,YTIME)$TIME(YTIME)..
         VElecConsInd(runCy,YTIME)
         =E=
         SUM(INDSE,VElecNonSub(runCy,INDSE,YTIME));       

* Compute total final demand (of substitutable fuels) in industrial sectors (Mtoe)
QDemInd(runCy,YTIME)$TIME(YTIME)..
        VDemInd(runCy,YTIME)=E= SUM(INDSE,VDemSub(runCy,INDSE,YTIME));

* Compute electricity industry prices
QElecIndPrices(runCy,YTIME)$TIME(YTIME)..
         VElecIndPrices(runCy,YTIME) =E=
        ( VElecIndPricesEst(runCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VElecIndPricesEst(runCy,YTIME)-sElecToSteRatioChp) + SQR(1E-4) ) )/2;

* Compute electricity consumed in heatpump plants
QElecConsHeatPla(runCy,INDDOM,YTIME)$time(ytime) ..
         VElecConsHeatPla(runCy,INDDOM,YTIME)
         =E=   1E-7;

* Compute fuel consumption (Mtoe)
QFuelCons(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) )..
         VConsFuel(runCy,DSBS,EF,YTIME)
                 =E=
         VConsFuelSub(runCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
         (VConsFuelSub(runCy,DSBS,EF,YTIME) + VElecConsHeatPla(runCy,DSBS,YTIME))$ELCEF(EF);



* Compute Electricity Index of industry price
QElecIndPricesEst(runCy,YTIME)$TIME(YTIME)..
         VElecIndPricesEst(runCy,YTIME)
                 =E=
         VResElecIndex(runCy,YTIME) * VElecIndPrices(runCy,YTIME-1) *
        ((VFuelPriceSub(runCy,"OI","ELC",YTIME-1)/VFuelPrice(runCy,"OI",YTIME-1))/
        (VFuelPriceSub(runCy,"OI","ELC",YTIME-2)/VFuelPrice(runCy,"OI",YTIME-2)))**(0.3) *
        ((VFuelPriceSub(runCy,"OI","ELC",YTIME-2)/VFuelPrice(runCy,"OI",YTIME-2))/
        (VFuelPriceSub(runCy,"OI","ELC",YTIME-3)/VFuelPrice(runCy,"OI",YTIME-3)))**(0.3);

* Compute fuel prices per subsector and fuel especially for chp plants (take into account the profit of electricity sales)
QFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) )..
VFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)
                =E=   
             (((VFuelPriceSub(runCy,DSBS,EF,YTIME) + (VRenValue(YTIME)/1000)$(not RENEF(EF))+VTechCostVar(runCy,DSBS,EF,TEA,YTIME)/1000)/iUsfEnergyConvFact(runCy,DSBS,EF,TEA,YTIME)- 
               (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*VElecIndPrices(runCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VFuelPriceSub(runCy,DSBS,EF,YTIME)+VTechCostVar(runCy,DSBS,EF,TEA,YTIME)/1000)/VTechCostVar(runCy,DSBS,EF,TEA,YTIME)- 
              (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*VElecIndPrices(runCy,YTIME))$CHP(EF))))  ) )/2;


* Compute electricity production cost per CHP plant and demand sector 
QElecProdCosChp(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VElecProdCostChp(runCy,DSBS,CHP,YTIME)
                 =E=
                    ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(CHP))
                        / (exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(CHP)) -1))
                      * iCapCosChp(runCy,CHP,YTIME)* 1000 * iCGI(runCy,YTIME)  + iFixOandMCosChp(runCy,CHP,YTIME)
                    )/(iAvailRateChp(runCy,CHP)*(1000*sTWhToMtoe))/1000
                    + iCosPerChp(runCy,CHP,YTIME)/1000
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+0.001*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         * sTWhToMtoe /  (iBoiEffChp(runCy,CHP,YTIME) * VElecIndPrices(runCy,YTIME)) );        

* Compute technology cost
QTechCost(runCy,DSBS,rCon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) 
                 =E= 
                 VTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME)**(-iElaSub(runCy,DSBS)) ;   

* Compute technology cost 
QTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF))..
         VTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME) =E=
                  ( (( (iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF)) !! in case of chp plants we use the discount rate of power generation sector
                       * exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME))
                     )
                      / (exp((iDisc(runCy,DSBS,YTIME)$(not CHP(EF)) + iDisc(runCy,"PG",YTIME)$CHP(EF))*VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME))- 1)
                    ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
                    +
                    iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
                    +
                    VFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)
                    * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$INDDOM(DSBS)
                 +
                  ( (( iDisc(runCy,DSBS,YTIME)
                       * exp(iDisc(runCy,DSBS,YTIME)*VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME))
                     )
                      / (exp(iDisc(runCy,DSBS,YTIME)*VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME))- 1)
                    ) * iCapCostTech(runCy,DSBS,EF,YTIME) * iCGI(runCy,YTIME)
                    +
                    iFixOMCostTech(runCy,DSBS,EF,YTIME)/1000
                    +
                    (
                      (VFuelPriceSub(runCy,DSBS,EF,YTIME)+VTechCostVar(runCy,DSBS,EF,TEA,YTIME)/1000)/iUsfEnergyConvFact(runCy,DSBS,EF,TEA,YTIME)
                    )
                    * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$NENSE(DSBS);  

* Compute technology cost including Maturity factor per technology and subsector
QTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME) 
                                               =E=
VMatrFactor(runCy,DSBS,EF,TEA,YTIME) * VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) ;

* Compute Technology sorting based on variable cost
QTechSort(runCy,DSBS,rCon,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) )..
VTechSort(runCy,DSBS,rCon,YTIME)
                        =E=
sum((EF,TEA)$(SECTTECH(DSBS,EF) ),VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME));

* Compute the gap in final demand (industry, tertiary, non-energy uses and bunkers)
QGapFinalDem(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VGapFinalDem(runCy,DSBS,YTIME)
                 =E=
         ((VDemSub(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquip(runCy,DSBS,EF,YTIME))) 
         + SQRT( SQR((VDemSub(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquip(runCy,DSBS,EF,YTIME)))-0) ) )/2;

* Compute technology share in new equipment
QTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) )..
         VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME) =E=
         VMatrFactor(runCy,DSBS,EF,TEA,YTIME) / iCumDistrFuncConsSize(runCy,DSBS) *
         sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
                  VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME)
                  * iDisFunConSize(runCy,DSBS,rCon)/VTechSort(runCy,DSBS,rCon,YTIME));

*Compute fuel consumption including heat from heatpumps
QFuelConsInclHP(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) )..
         VFuelConsInclHP(runCy,DSBS,EF,YTIME)
                 =E=
         VConsRemSubEquip(runCy,DSBS,EF,YTIME)+
         sum(TEA,VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)*VGapFinalDem(runCy,DSBS,YTIME))
         + (VElecNonSub(runCy,DSBS,YTIME))$(INDDOM(DSBS) $(ELCEF(EF)));

* Compute variable including fuel electricity production cost per CHP plant and demand sector 
QVarProCostPerCHPDem(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VProCostCHPDem(runCy,DSBS,CHP,YTIME)
                 =E=
         iCosPerChp(runCy,CHP,YTIME)/1E3
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         *sTWhToMtoe/(   iBoiEffChp(runCy,CHP,YTIME)*VElecIndPrices(runCy,YTIME)    ));

* Compute Average Electricity production cost per CHP plant 
QAvgElcProCostCHP(runCy,CHP,YTIME)$TIME(YTIME)..
         VAvgElcProCHP(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))*VElecProdCostChp(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

* Compute Average variable including fuel electricity production cost per CHP plant 
QAvgVarElecProd(runCy,CHP,YTIME)$(TIME(YTIME) ) ..
         VAvgVarProdCostCHP(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))
         *VProCostCHPDem(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

* REST OF ENERGY BALANCE SECTORS
* Compute total final energy consumption
QTotFinEneCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VTotFinEneCons(runCy,EFS,YTIME)
             =E=
         sum(INDDOM,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel(runCy,INDDOM,EF,YTIME)))
         +
         sum(TRANSE,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemTr(runCy,TRANSE,EF,YTIME)));

* Compute total final energy consumption in ALL countries
QTotFinEneConsAll(YTIME)$TIME(YTIME)..
         VTotFinEneConsAll(YTIME) =E= sum((runCy,EFS), VTotFinEneCons(runCy,EFS,YTIME) );     

* Compute final non-energy consumption
QFinNonEneCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VFNonEnCons(runCy,EFS,YTIME)
             =E=
         sum(NENSE$(not sameas("BU",NENSE)),
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel(runCy,NENSE,EF,YTIME)));  

* Compute distribution losses
QDistrLosses(runCy,EFS,YTIME)$TIME(YTIME)..
         VDistrLosses(runCy,EFS,YTIME)
             =E=
         (iRateLossesFinCons(runCy,EFS,YTIME) * (VTotFinEneCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME)))$(not H2EF(EFS));  

* Compute the transformation output from district heating plants
QTranfOutputDHPlants(runCy,STEAM,YTIME)$TIME(YTIME)..
         VTransfOutputDHPlants(runCy,STEAM,YTIME)
             =E=
         sum(DOMSE,
             sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel(runCy,DOMSE,DH,YTIME)));

* Compute the transformation input to distrcit heating plants
QTransfInputDHPlants(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfInputDHPlants(runCy,EFS,YTIME)
             =E=
         sum(DH$DHtoEF(DH,EFS),
             sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel(runCy,DOMSE,DH,YTIME)) / iEffDHPlants(runCy,EFS,YTIME));   

* Compute the transfomration input to patent fuel and briquetting plants,coke-oven plants,blast furnace plants and gas works
QTransfInputPatFuel(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfInputPatFuel(runCy,EFS,YTIME)
             =E=
         sum(EF$(EFS(EF) $iAvgEffGas(runCy,EF,YTIME)) , VTransfOutputPatFuel(runCy,EFS,YTIME)/iAvgEffGas(runCy,EF,YTIME)) * iShareFueTransfInput(runCy,EFS); 

* Compute refineries capacity
QRefCapacity(runCy,YTIME)$TIME(YTIME)..
         VRefCapacity(runCy,YTIME)
             =E=
         [
         iResRefCapacity(runCy,YTIME) * VRefCapacity(runCy,YTIME-1)
         *
         (1$(ord(YTIME) le 16) +
         (prod(rc,
         (sum(EFS$EFtoEFA(EFS,"LQD"),VTotFinEneCons(runCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VTotFinEneCons(runCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
         )
         $(ord(YTIME) gt 16)
         )     ] $iRefCapacity(runCy,"%fStartHorizon%");

* Compute the transformation output from refineries
QTranfOutputRefineries(runCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD"))..
         VTransfOutputRefineries(runCy,EFS,YTIME)
             =E=
         [
         iResTransfOutputRefineries(runCy,EFS,YTIME) * VTransfOutputRefineries(runCy,EFS,YTIME-1)
         * (VRefCapacity(runCy,YTIME)/VRefCapacity(runCy,YTIME-1))**0.3
         * (
             1$(TFIRST(YTIME-1) or TFIRST(YTIME-2))
             +
             (
                sum(EF$EFtoEFA(EF,"LQD"),VTotFinEneCons(runCy,EF,YTIME-1))/sum(EF$EFtoEFA(EF,"LQD"),VTotFinEneCons(runCy,EF,YTIME-2))
             )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
           )**(0.7)  ]$iRefCapacity(runCy,"%fStartHorizon%"); 

* Compute the transformation input to refineries
QTransfInputRefineries(runCy,"CRO",YTIME)$(TIME(YTIME) )..
         VTransfInputRefineries(runCy,"CRO",YTIME)
             =E=
         [
         VTransfInputRefineries(runCy,"CRO",YTIME-1) *
         sum(EFS$EFtoEFA(EFS,"LQD"), VTransfOutputRefineries(runCy,EFS,YTIME)) /
         sum(EFS$EFtoEFA(EFS,"LQD"), VTransfOutputRefineries(runCy,EFS,YTIME-1))  ]$iRefCapacity(runCy,"%fStartHorizon%");                   

* Compute transformation output from nuclear plants
QTransfOutputNuclear(runCy,"ELC",YTIME)$TIME(YTIME) ..
         VTransfOutputNuclear(runCy,"ELC",YTIME) =E=SUM(PGNUCL,VElecProd(runCy,PGNUCL,YTIME))*sTWhToMtoe;

* Compute transformation input to nuclear plants
QTransfInNuclear(runCy,"NUC",YTIME)$TIME(YTIME)..
        VTransfInNuclear(runCy,"NUC",YTIME) =E=SUM(PGNUCL,VElecProd(runCy,PGNUCL,YTIME)/VPlantEffPlantType(runCy,PGNUCL,YTIME))*sTWhToMtoe;

* Compute transformation input to power plants
QTransfInPowerPls(runCy,PGEF,YTIME)$TIME(YTIME)..
         VTransfInThermPowPls(runCy,PGEF,YTIME)
             =E=
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$((not PGGEO(PGALL)) $(not PGNUCL(PGALL)))),
             VElecProd(runCy,PGALL,YTIME) * sTWhToMtoe /  VPlantEffPlantType(runCy,PGALL,YTIME))
        +
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$PGGEO(PGALL)),
             VElecProd(runCy,PGALL,YTIME) * sTWhToMtoe) 
        +
        sum(CHP$CHPtoEF(CHP,PGEF),  sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME))+sTWhToMtoe*VChpElecProd(runCy,CHP,YTIME))/(0.8+0.1*(ord(YTIME)-16)/32);

* Compute transformation output from thermal power plants
QTransfOutThermPP(runCy,TOCTEF,YTIME)$TIME(YTIME)..
         VTransfOutThermPowSta(runCy,TOCTEF,YTIME)
             =E=
        (
             sum(PGALL$(not PGNUCL(PGALL)),VElecProd(runCy,PGALL,YTIME)) * sTWhToMtoe
             +
             sum(CHP,VChpElecProd(runCy,CHP,YTIME)*sTWhToMtoe)
         )$ELCEF(TOCTEF)
        +
        (                                                                                                         
          sum(INDDOM,
          sum(CHP$SECTTECH(INDDOM,CHP), VConsFuel(runCy,INDDOM,CHP,YTIME)))+
          iRateEneBranCons(runCy,TOCTEF,YTIME)*(VFeCons(runCy,TOCTEF,YTIME) + VFNonEnCons(runCy,TOCTEF,YTIME) + VLosses(runCy,TOCTEF,YTIME)) + 
          VLosses(runCy,TOCTEF,YTIME)                                                                                    
         )$STEAM(TOCTEF); 
            
* Computer total transformation input
QTotTransfInput(runCy,EFS,YTIME)$TIME(YTIME)..
         VTotTransfInput(runCy,EFS,YTIME)
                 =E=
        (
            VTransfInThermPowPls(runCy,EFS,YTIME) + VTransfInputDHPlants(runCy,EFS,YTIME) + VTransfInNuclear(runCy,EFS,YTIME) +
             VTransfInputPatFuel(runCy,EFS,YTIME) + VTransfInputRefineries(runCy,EFS,YTIME)     !!$H2PRODEF(EFS)
        )$(not sameas(EFS,"OGS"))
        +
        (
          VTotTransfOutput(runCy,EFS,YTIME) - VFeCons(runCy,EFS,YTIME) - VFNonEnCons(runCy,EFS,YTIME) - iRateEneBranCons(runCy,EFS,YTIME)*
          VTotTransfOutput(runCy,EFS,YTIME) - VLosses(runCy,EFS,YTIME)
        )$sameas(EFS,"OGS");            

* Compute total transformation output
QTotTransfOutput(runCy,EFS,YTIME)$TIME(YTIME)..
         VTotTransfOutput(runCy,EFS,YTIME)
                 =E=
         VTransfOutThermPowSta(runCy,EFS,YTIME) + VTransfOutputDHPlants(runCy,EFS,YTIME) + VTransfOutputNuclear(runCy,EFS,YTIME) + VTransfOutputPatFuel(runCy,EFS,YTIME) +
         VTransfOutputRefineries(runCy,EFS,YTIME);        !!+ TONEW(CYrun,EFS,YTIME)

* Compute transfers
QTransfers(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfers(runCy,EFS,YTIME) =E=
         (( (VTransfers(runCy,EFS,YTIME-1)*iResFeedTransfr(runCy,YTIME)*VFeCons(runCy,EFS,YTIME)/VFeCons(runCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
          (
                 VTransfers(runCy,"CRO",YTIME-1)*iResFeedTransfr(runCy,YTIME)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME))/
                 SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(runCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);         
  
* Compute gross inland consumption not including consumption of energy branch
 QGrsInlConsNotEneBranch(runCy,EFS,YTIME)$TIME(YTIME)..
         VGrsInlConsNotEneBranch(runCy,EFS,YTIME)
                 =E=
         VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME) + VTotTransfInput(runCy,EFS,YTIME) - VTotTransfOutput(runCy,EFS,YTIME) + VLosses(runCy,EFS,YTIME) - 
         VTransfers(runCy,EFS,YTIME); 

* Compute gross inland consumption
QGrssInCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VGrssInCons(runCy,EFS,YTIME)
                 =E=
         VFeCons(runCy,EFS,YTIME) + VEnCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME) + VTotTransfInput(runCy,EFS,YTIME) - VTotTransfOutput(runCy,EFS,YTIME) +
          VLosses(runCy,EFS,YTIME) - VTransfers(runCy,EFS,YTIME);  

* Compute primary production
QPrimProd(runCy,PPRODEF,YTIME)$TIME(YTIME)..
         VPrimProd(runCy,PPRODEF,YTIME)
                 =E=  [
         (
             iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) * (VGrsInlConsNotEneBranch(runCy,PPRODEF,YTIME) +  VEnCons(runCy,PPRODEF,YTIME))
         )$(not (sameas(PPRODEF,"CRO")or sameas(PPRODEF,"NGS")))
         +
         (
             iResHcNgOilPrProd(runCy,PPRODEF,YTIME) * VPrimProd(runCy,PPRODEF,YTIME-1) *
             (VGrsInlConsNotEneBranch(runCy,PPRODEF,YTIME)/VGrsInlConsNotEneBranch(runCy,PPRODEF,YTIME-1))**iNatGasPriProElst(runCy)
         )$(sameas(PPRODEF,"NGS") )
        +
         (
           iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME) * VPrimProd(runCy,PPRODEF,YTIME-1) *
           ((VGrsInlConsNotEneBranch(runCy,PPRODEF,YTIME) + VExportsFake(runCy,PPRODEF,YTIME))/
            (VGrsInlConsNotEneBranch(runCy,PPRODEF,YTIME-1) + VExportsFake(runCy,PPRODEF,YTIME-1)))
         )$(sameas(PPRODEF,"NGS") )
         +(
           iResHcNgOilPrProd(runCy,PPRODEF,YTIME) *  iFuelPriPro(runCy,PPRODEF,YTIME) *
           prod(kpdl$(ord(kpdl) lt 5),
                         (iIntPricesMainFuels("WCRO",YTIME-(ord(kpdl)+1))/iIntPricesMainFuelsBsln("WCRO",YTIME-(ord(kpdl)+1)))
                         **(0.2*iPolDstrbtnLagCoeffPriOilPr(kpdl)))
         )$sameas(PPRODEF,"CRO")   ]$iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME);   

* Compute fake exports
QFakeExp(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..
         VExportsFake(runCy,EFS,YTIME)
                 =E=
         (
                 iFuelExprts(runCy,EFS,YTIME)
         )
+  iFuelExprts(runCy,EFS,YTIME);

* Compute fake imports
QFakeImprts(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..

         VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME)

                 =E=
         (
            iRatioImpFinElecDem(runCy,YTIME) * (VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME)) + VExportsFake(runCy,EFS,YTIME)
         )$ELCEF(EFS)
         +
         (
            VGrssInCons(runCy,EFS,YTIME)+ VExportsFake(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VPrimProd(runCy,EFS,YTIME)
         )$(sameas(EFS,"CRO"))

         +
         (
            VGrssInCons(runCy,EFS,YTIME)+ VExportsFake(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VPrimProd(runCy,EFS,YTIME)
         )$(sameas(EFS,"NGS"))
         +iImpExp(runCy,"NGS",YTIME)$(sameas(EFS,"NGS"))
         +
         (
            (1-iRatePriProTotPriNeeds(runCy,EFS,YTIME)) *
            (VGrssInCons(runCy,EFS,YTIME) + VExportsFake(runCy,EFS,YTIME) + VConsFuel(runCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS) )
         )$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));

* Compute net imports
QNetImports(runCy,EFS,YTIME)$TIME(YTIME)..
         VNetImports(runCy,EFS,YTIME)
                 =E=
         VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME) - VExportsFake(runCy,EFS,YTIME);
                               
* Compute energy branch final consumption
QEneBrnchEneCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VEnCons(runCy,EFS,YTIME)
                 =E=
         iRateEneBranCons(runCy,EFS,YTIME) *
         (
           (
              VTotTransfOutput(runCy,EFS,YTIME) +
              VPrimProd(runCy,EFS,YTIME)$(sameas(EFS,"CRO") or sameas(EFS,"NGS"))
            )$(not TOCTEF(EFS))
            +
            (
              VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME) + VLosses(runCy,EFS,YTIME)
            )$TOCTEF(EFS)
         );                              

* CO2 SEQUESTRATION COST CURVES

* Compute CO2 captured by electricity and hydrogen production plants 
QCO2ElcHrg(runCy,YTIME)$TIME(YTIME)..
         VCO2ElcHrgProd(runCy,YTIME)
         =E=
         sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                 VElecProd(runCy,CCS,YTIME)*sTWhToMtoe/VPlantEffPlantType(runCy,CCS,YTIME)*
                 iCo2EmiFac(runCy,"PG",PGEF,YTIME)));

* Compute cumulative CO2 captured 
QCumCO2Capt(runCy,YTIME)$TIME(YTIME)..
         VCumCO2Capt(runCy,YTIME) =E= VCumCO2Capt(runCy,YTIME-1)+VCO2ElcHrgProd(runCy,YTIME-1);   

* Compute Weight for transtition from linear CO2 sequestration cost curve to exponential
QWghtTrnstLinToExpo(runCy,YTIME)$TIME(YTIME)..
         VWghtTrnstLnrToExpo(runCy,YTIME)
         =E=
         1/(1+exp(-iElastCO2Seq(runCy,"mc_s")*( VCumCO2Capt(runCy,YTIME)/iElastCO2Seq(runCy,"pot")-iElastCO2Seq(runCy,"mc_m")))); 

* Compute cost curve for CO2 sequestration costs 
QCstCO2SeqCsts(runCy,YTIME)$TIME(YTIME)..
         VCO2CO2SeqCsts(runCy,YTIME) =E=
       (1-VWghtTrnstLnrToExpo(runCy,YTIME))*(iElastCO2Seq(runCy,"mc_a")*VCumCO2Capt(runCy,YTIME)+iElastCO2Seq(runCy,"mc_b"))+
       VWghtTrnstLnrToExpo(runCy,YTIME)*(iElastCO2Seq(runCy,"mc_c")*exp(iElastCO2Seq(runCy,"mc_d")*VCumCO2Capt(runCy,YTIME)));           

* Define dummy objective function
qDummyObj.. vDummyObj =e= 1;