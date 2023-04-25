* Power Generation

* Compute total electricity demand
QElecDem(runCy,YTIME)$TIME(YTIME)..
         VElecDem(runCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VFeCons(runCy,"ELC",YTIME) + VFNonEnCons(runCy,"ELC",YTIME) + VLosses(runCy,"ELC",YTIME)
           + VEnCons(runCy,"ELC",YTIME) - VNetImp(runCy,"ELC",YTIME)
         );


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
             (((VFuelPriceSub(runCy,DSBS,EF,YTIME) + (VRenValue(YTIME)/1000)$(not RENEF(EF))+VCosTech(runCy,DSBS,EF,TEA,YTIME)/1000)/iUsfEnergy(runCy,DSBS,EF,TEA,YTIME)- 
               (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*VElecIndPrices(runCy,YTIME))$CHP(EF))) + 
              (0.003) + SQRT( SQR(((VFuelPriceSub(runCy,DSBS,EF,YTIME)+VCosTech(runCy,DSBS,EF,TEA,YTIME)/1000)/VCosTech(runCy,DSBS,EF,TEA,YTIME)- 
              (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp(runCy,YTIME)*VElecIndPrices(runCy,YTIME))$CHP(EF)))-(0.003)) + SQR(1e-7) ) )/2;


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
QTechCost(runCy,DSBS,Rcon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(Rcon) le Ncon(DSBS)+1) $SECTTECH(DSBS,EF) )..
VTechCost(CYrun,DSBS,Rcon,EF,TEA,YTIME) 
                 =E= 
                 DEMCOST(runCy,DSBS,Rcon,EF,TEA,YTIME)**(-ELSB(runCy,DSBS)) ;        

* Define dummy objective function
qDummyObj.. vDummyObj =e= 1;