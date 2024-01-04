*' @title Equations of OPEN-PROM
*' @code
*' Power Generation


*' * Compute current renewable potential 
qCurrRenPot(runCy,PGRENEF,YTIME)$TIME(YTIME)..

         vCurrRenPot(runCy,PGRENEF,YTIME) 
         =E=
         ( VMaxmAllowRenPotent(runCy,PGRENEF,YTIME) + iMinRenPotential(runCy,PGRENEF,YTIME))/2;

*' * Compute CHP electric capacity
QChpElecPlants(runCy,CHP,YTIME)$TIME(YTIME)..
         VElecCapChpPla(runCy,CHP,YTIME)
         =E=
         1/sTWhToMtoe * sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME)) * VElecIndPrices(runCy,YTIME)/
         sum(PGALL$CHPtoEON(CHP,PGALL),iAvailRate(PGALL,YTIME)) /
         iUtilRateChpPlants(runCy,CHP,YTIME) /sGwToTwhPerYear;  

*' * Compute Lambda parameter
QLambda(runCy,YTIME)$TIME(YTIME)..
         (1 - exp( -VLoadCurveConstr(runCy,YTIME)*sGwToTwhPerYear))  / VLoadCurveConstr(runCy,YTIME)
             =E=
         (VElecDem(runCy,YTIME) - sGwToTwhPerYear*VCorrBaseLoad(runCy,YTIME))
         / (VElecPeakLoad(runCy,YTIME) - VCorrBaseLoad(runCy,YTIME));

*' * Compute electricity final demand
QElecDem(runCy,YTIME)$TIME(YTIME)..
         VElecDem(runCy,YTIME)
             =E=
         1/sTWhToMtoe *
         ( VFeCons(runCy,"ELC",YTIME) + VFNonEnCons(runCy,"ELC",YTIME) + VLosses(runCy,"ELC",YTIME)
           + VEnCons(runCy,"ELC",YTIME) - iNetImp(runCy,"ELC",YTIME)
         );

*' This equation computes the estimated base load as a quantity dependent on the electricity demand per final sector,
*' as well as the baseload share of demand per sector, the rate of losses for final Consumption, the net imports,
*' distribution losses and final consumption in energy sector.
QEstBaseLoad(runCy,YTIME)$TIME(YTIME)..
         VEstBaseLoad(runCy,YTIME)
             =E=
         (
             sum(DSBS, iBaseLoadShareDem(runCy,DSBS,YTIME)*VElecConsAll(runCy,DSBS,YTIME))*(1+iRateLossesFinCons(runCy,"ELC",YTIME))*
             (1 - VNetImports(runCy,"ELC",YTIME)/(sum(DSBS, VElecConsAll(runCy,DSBS,YTIME))+VLosses(runCy,"ELC",YTIME)))
             + 0.5*VEnCons(runCy,"ELC",YTIME)
         ) / sTWhToMtoe / sGwToTwhPerYear;

*' This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector
*' and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor
*' of electricity demand per sector
QLoadFacDom(runCy,YTIME)$TIME(YTIME)..
         VLoadFacDom(runCy,YTIME)
             =E=
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE, VDemTr(runCy,TRANSE,"ELC",YTIME)))/
         (sum(INDDOM,VConsFuel(runCy,INDDOM,"ELC",YTIME)/iLoadFacElecDem(INDDOM)) + 
         sum(TRANSE, VDemTr(runCy,TRANSE,"ELC",YTIME)/iLoadFacElecDem(TRANSE)));         

*' * Compute elerctricity peak load
QElecPeakLoad(runCy,YTIME)$TIME(YTIME)..
         VElecPeakLoad(runCy,YTIME)
             =E=
         VElecDem(runCy,YTIME)/(VLoadFacDom(runCy,YTIME)*sGwToTwhPerYear);

*' This equation calculates the baseload corresponding to maximum load by multiplying the maximum load factor of electricity demand
*' to the electricity peak load, minus the baseload corresponding to maximum load factor.
QBslMaxmLoad(runCy,YTIME)$TIME(YTIME)..
         (VElecDem(runCy,YTIME)-VBslMaxmLoad(runCy,YTIME)*sGwToTwhPerYear)
             =E=
         iMxmLoadFacElecDem(runCy,YTIME)*(VElecPeakLoad(runCy,YTIME)-VBslMaxmLoad(runCy,YTIME))*sGwToTwhPerYear;  

*' This equation calculates the electricity base load utilizing exponential functions that include the estimated base load,
*' the baseload corresponding to maximum load factor, and the parameter of baseload correction.
QElecBaseLoad(runCy,YTIME)$TIME(YTIME)..
         VCorrBaseLoad(runCy,YTIME)
             =E=
         (1/(1+Exp(iBslCorrection(runCy,YTIME)*(VEstBaseLoad(runCy,YTIME)-VBslMaxmLoad(runCy,YTIME)))))*VEstBaseLoad(runCy,YTIME)
        +(1-1/(1+Exp(iBslCorrection(runCy,YTIME)*(VEstBaseLoad(runCy,YTIME)-VBslMaxmLoad(runCy,YTIME)))))*VBslMaxmLoad(runCy,YTIME);

*' This equation calculates the total required electricity production as a sum of the electricity peak load minus the corrected base load,
*' multiplied by the exponential function of the parameter for load curve construction.
QTotReqElecProd(runCy,YTIME)$TIME(YTIME)..
         VTotReqElecProd(runCy,YTIME)
             =E=
         sum(HOUR, (VElecPeakLoad(runCy,YTIME)-VCorrBaseLoad(runCy,YTIME))
                   * exp(-VLoadCurveConstr(runCy,YTIME)*(0.25+(ord(HOUR)-1)))
             ) + 9*VCorrBaseLoad(runCy,YTIME);   

*' * Compute Estimated total electricity generation capacity
QTotEstElecGenCap(runCy,YTIME)$TIME(YTIME)..
        VTotElecGenCapEst(runCy,YTIME)
             =E=
        VTotElecGenCap(runCy,YTIME-1) * VElecPeakLoad(runCy,YTIME)/VElecPeakLoad(runCy,YTIME-1);          

*' * Compute total electricity generation capacity
QTotElecGenCap(runCy,YTIME)$TIME(YTIME)..
        VTotElecGenCap(runCy,YTIME) 
        =E=
     VTotElecGenCapEst(runCy,YTIME);  

*' * Compute hourly production cost used in investment decisions
QHourProdCostInv(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME)) ..
         VHourProdCostTech(runCy,PGALL,HOUR,YTIME)
                  =E=
                  
                    ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))
                        / (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
                      * iGrossCapCosSubRen(PGALL,YTIME)* 1E3 * iCGI(runCy,YTIME)  + iFixOandMCost(PGALL,YTIME)
                    )/iAvailRate(PGALL,YTIME) / (1000*(ord(HOUR)-1+0.25))
                    + iVarCost(PGALL,YTIME)/1E3 + (VRenValue(YTIME)*8.6e-5)$( not ( PGREN(PGALL) 
                    $(not sameas("PGASHYD",PGALL)) $(not sameas("PGSHYD",PGALL)) $(not sameas("PGLHYD",PGALL)) ))
                    + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+
                        iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*
                    iCo2EmiFac(runCy,"PG",PGEF,YTIME)
                         +(1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL));



*' Compute hourly production cost used in investment decisions excluding CCS
*' The equation QHourProdCostInvDec calculates the hourly production cost for
*' a given technology without carbon capture and storage (CCS) investments. 
*' The result, VHourProdCostTechNoCCS, is expressed in Euro per kilowatt-hour (Euro/KWh).
*' The equation is based on the power plant's share in new equipment (VPowerPlantNewEq) and
*' the hourly production cost of technology without CCS (VHourProdCostTech). Additionally, 
*' it considers the contribution of other technologies with CCS (CCS_NOCCS) by summing their
*' shares in new equipment (VPowerPlaShrNewEq) multiplied by their respective hourly production
*' costs. The equation reflects the cost dynamics associated with technology investments and provides
*' insights into the hourly production cost for power generation without CCS.

QHourProdCostInvDec(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $NOCCS(PGALL)) ..
         VHourProdCostTechNoCCS(runCy,PGALL,HOUR,YTIME) =E=
         VPowerPlantNewEq(runCy,PGALL,YTIME)*VHourProdCostTech(runCy,PGALL,HOUR,YTIME)+
         sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq(runCy,CCS,YTIME)*VHourProdCostTech(runCy,CCS,HOUR,YTIME)); 


*' Compute gamma parameter used in CCS/No CCS decision tree
*' The equation reflects a dynamic relationship where the sensitivity
*' to CCS acceptance is influenced by the carbon prices of different countries.
*' The resulting VSensCcs provides a measure of the sensitivity of CCS acceptance
*' based on the carbon values in the previous year.
QGammaInCcsDecTree(runCy,YTIME)$TIME(YTIME)..
         VSensCcs(runCy,YTIME) =E= 20+25*EXP(-0.06*((sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME-1)))));

* Compute hourly production cost used in investment decisions taking into account CCS acceptance
qHourProdCostInvDecisionsAfterCCS(runCy,PGALL,HOUR,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL))) ..
         vHourProdCostTechAfterCCS(runCy,PGALL,HOUR,YTIME) 
         =E=
          VHourProdCostTech(runCy,PGALL,HOUR,YTIME)**(-VSensCcs(runCy,YTIME)/4);

*' Compute production cost used in investment decisions
*' The equation QProdCostInvDecis calculates the production cost of a technology (VProdCostTechnology)
*' for a specific power plant and year. The equation involves the hourly production cost of the technology
*' (VHourProdCostTech) and a sensitivity variable controlling carbon capture and storage (CCS) acceptance (VSensCcs).
*' The summation over hours (HOUR) is weighted by the inverse of the technology's hourly production cost raised to the 
*' power of minus one-fourth of the sensitivity variable. 
QProdCostInvDecis(runCy,PGALL,YTIME)$(TIME(YTIME) $(CCS(PGALL) or NOCCS(PGALL)) ) ..
         VProdCostTechnology(runCy,PGALL,YTIME) 
         =E=  
         sum(HOUR,VHourProdCostTech(runCy,PGALL,HOUR,YTIME)**(-VSensCcs(runCy,YTIME)/4)) ;

*' Compute SHRCAP
*' The equation QShrcap calculates the power plant's share in new equipment (VPowerPlaShrNewEq) 
*'for a specific power plant and year when carbon capture and storage (CCS) is implemented. The
*' share is determined based on a formulation that considers the production costs of the technology
*' (VProdCostTechnology). The numerator of the share calculation involves a factor of 1.1 multiplied
*' by the production cost of the technology for the specific power plant and year. The denominator
*' includes the sum of the numerator and the production costs of other power plant types without CCS (CCS_NOCCS).

QShrcap(runCy,PGALL,YTIME)$(TIME(YTIME) $CCS(PGALL))..
         VPowerPlaShrNewEq(runCy,PGALL,YTIME) =E=
         1.1 *VProdCostTechnology(runCy,PGALL,YTIME)
         /(1.1*VProdCostTechnology(runCy,PGALL,YTIME)
           + sum(PGALL2$CCS_NOCCS(PGALL,PGALL2),VProdCostTechnology(runCy,PGALL2,YTIME))
           );         

*' Compute SHRCAP excluding CCs
*' The equation QShrcapNoCcs calculates the power plant's share in new equipment (VPowerPlantNewEq)
*' for a specific power plant and year when carbon capture and storage (CCS) is not implemented (NOCCS).
*' The equation is based on the complementarity relationship, expressing that the power plant's share in
*' new equipment without CCS is equal to one minus the sum of the shares of power plants with CCS in the
*' new equipment. The sum is taken over all power plants with CCS for the given power plant type (PGALL) and year (YTIME).

QShrcapNoCcs(runCy,PGALL,YTIME)$(TIME(YTIME) $NOCCS(PGALL))..
         VPowerPlantNewEq(runCy,PGALL,YTIME) 
         =E= 
         1 - sum(CCS$CCS_NOCCS(CCS,PGALL), VPowerPlaShrNewEq(runCy,CCS,YTIME));

*' Compute the variable cost of each power plant technology for every region,
*' By utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency. 
QVarCostTech(runCy,PGALL,YTIME)$(time(YTIME))..
         VVarCostTech(runCy,PGALL,YTIME) 
             =E=
         (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
         + (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)
          *(sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
          *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)));


*' Compute variable cost of technology excluding PGSCRN
*' The equation QVarCostTechNotPGSCRN calculates the variable VVarCostTechNotPGSCRN for a specific
*' power plant and year when the power plant is not subject to PGSCRN. The calculation involves raising the variable
*' cost of the technology (VVarCostTech) for the specified power plant and year to the power of -5.

QVarCostTechNotPGSCRN(runCy,PGALL,YTIME)$(time(YTIME) $(not PGSCRN(PGALL)))..
         VVarCostTechNotPGSCRN(runCy,PGALL,YTIME) 
              =E=
          VVarCostTech(runCy,PGALL,YTIME)**(-5);


*' Compute production cost of technology  used in premature replacement
*' The equation QProdCostTechPreReplac calculates the production cost of a technology (VProdCostTechPreReplac)
*' for a specific power plant and year. The equation involves various factors, including discount rates, technical
*' lifetime of the plant type, gross capital cost with subsidies for renewables, capital goods index, fixed operation 
*' and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, CO2 capture rates, cost
*' curve for CO2 sequestration costs, CO2 emission factors, carbon values, plant efficiency, and specific conditions excluding
*' renewable power plants (not PGREN). The equation reflects the complex dynamics of calculating the production cost, considering both economic and technical parameters.

QProdCostTechPreReplac(runCy,PGALL,YTIME)$TIME(YTIME)..
         VProdCostTechPreReplac(runCy,PGALL,YTIME) =e=
                        (
                          ((iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))/
                          (exp(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) -1))
                            * iGrossCapCosSubRen(PGALL,YTIME)* 1E3 * iCGI(runCy,YTIME)  + 
                            iFixOandMCost(PGALL,YTIME))/(8760*iAvailRate(PGALL,YTIME))
                           + (iVarCost(PGALL,YTIME)/1E3 + sum(PGEF$PGALLtoEF(PGALL,PGEF), 
                           (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+
                            iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
                             (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))$(not PGREN(PGALL)))
                         );


*' Compute production cost of technology  used in premature replacement including plant availability rate
*'The equation QProdCostTechPreReplacAvail calculates the production cost of a technology used in premature replacement,
*' considering plant availability rates. The result, VProdCostTechPreReplacAvail, is expressed in Euro per kilowatt-hour (Euro/KWh). 
*'The equation involves the production cost of the technology used in premature replacement without considering availability rates 
*'(VProdCostTechPreReplac) and incorporates adjustments based on the availability rates of two power plants (PGALL and PGALL2).

QProdCostTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)$TIME(YTIME)..
         VProdCostTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME) =E=
         iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME)*VProdCostTechPreReplac(runCy,PGALL,YTIME)+
         VVarCostTech(runCy,PGALL,YTIME)*(1-iAvailRate(PGALL,YTIME)/iAvailRate(PGALL2,YTIME));  

*' * Compute endogenous scrapping index 
QEndogScrapIndex(runCy,PGALL,YTIME)$(TIME(YTIME) $(not PGSCRN(PGALL)))..
         VEndogScrapIndex(runCy,PGALL,YTIME)
                 =E=
         VVarCostTechNotPGSCRN(runCy,PGALL,YTIME)/
         (VVarCostTechNotPGSCRN(runCy,PGALL,YTIME)+(iScaleEndogScrap(runCy,PGALL,YTIME)*
         sum(PGALL2,VProdCostTechPreReplacAvail(runCy,PGALL,PGALL2,YTIME)))**(-5));

*' * Compute total electricity generation capacity excluding CHP plants
QElecGenNoChp(runCy,YTIME)$TIME(YTIME)..
         VElecGenNoChp(runCy,YTIME)
          =E=
VTotElecGenCap(runCy,YTIME) - SUM(CHP,VElecCapChpPla(runCy,CHP,YTIME)*0.85);      

*' * Compute the gap in power generation capacity
QGapPowerGenCap(runCy,YTIME)$TIME(YTIME)..
         VGapPowerGenCap(runCy,YTIME)
             =E=
 (        (  VElecGenNoChp(runCy,YTIME) - VElecGenNoChp(runCy,YTIME-1) + sum(PGALL,VElecGenPlanCap(runCy,PGALL,YTIME-1) * 
 (1 - VEndogScrapIndex(runCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VElecGenPlantsCapac(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
          iTechLftPlaType(runCy,PGALL))
       )
  + 0 + SQRT( SQR(       (  VElecGenNoChp(runCy,YTIME) - VElecGenNoChp(runCy,YTIME-1) +
        sum(PGALL,VElecGenPlanCap(runCy,PGALL,YTIME-1) * (1 - VEndogScrapIndex(runCy,PGALL,YTIME))) +
          sum(PGALL, (iPlantDecomSched(runCy,PGALL,YTIME)-iDecInvPlantSched(runCy,PGALL,YTIME))*iAvailRate(PGALL,YTIME))
          + Sum(PGALL$PGSCRN(PGALL), (VElecGenPlantsCapac(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME))/
          iTechLftPlaType(runCy,PGALL))
       ) -0) + SQR(1e-10) ) )/2;


*' Compute temporary variable facilitating the scaling in Weibull equation
*' The equation vScalWeibull calculates a temporary variable (vScalWeibull) 
*' that facilitates the scaling in the Weibull equation. The equation involves
*' the hourly production costs of technology (VHourProdCostTech) for power plants
*' with carbon capture and storage (CCS) and without CCS (NOCCS). The production 
*' costs are raised to the power of -6, and the result is used as a scaling factor
*' in the Weibull equation. The equation captures the cost-related considerations 
*' in determining the scaling factor for the Weibull equation based on the production costs of different technologies.

qScalWeibull(runCy,PGALL,HOUR,YTIME)$((not CCS(PGALL))$TIME(YTIME))..
          vScalWeibull(runCy,PGALL,HOUR,YTIME) 
         =E=
         (VHourProdCostTech(runCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
         +
          VHourProdCostTechNoCCS(runCy,PGALL,HOUR,YTIME)$NOCCS(PGALL))**(-6);     


*' * Compute renewable potential supply curve
QRenPotSupplyCurve(runCy,PGRENEF,YTIME)$TIME(YTIME)..
         VRenPotSupplyCurve(runCy,PGRENEF,YTIME) =E=
         iMinRenPotential(runCy,PGRENEF,YTIME) +(VCarVal(runCy,"Trade",YTIME))/(70)*
         (iMaxRenPotential(runCy,PGRENEF,YTIME)-iMinRenPotential(runCy,PGRENEF,YTIME));

*' * Compute maximum allowed renewable potential 
QMaxmAllowRenPotent(runCy,PGRENEF,YTIME)$TIME(YTIME)..      
         VMaxmAllowRenPotent(runCy,PGRENEF,YTIME) =E=
         ( VRenPotSupplyCurve(runCy,PGRENEF,YTIME)+ iMaxRenPotential(runCy,PGRENEF,YTIME))/2;

*' * Compute minimum allowed renewable potential 
QMnmAllowRenPot(runCy,PGRENEF,YTIME)$TIME(YTIME)..  
         VMnmAllowRenPot(runCy,PGRENEF,YTIME) =E=
         ( VRenPotSupplyCurve(runCy,PGRENEF,YTIME) + VMnmAllowRenPot(runCy,PGRENEF,YTIME))/2;

*' * Compute renewable technologies maturity multiplier
QRenTechMatMult(runCy,PGALL,YTIME)$TIME(YTIME)..
         VRenTechMatMult(runCy,PGALL,YTIME)
          =E=
         1$(NOT PGREN(PGALL))
         +
         (
           1/(1+EXP(9*(
                 sum(PGRENEF$PGALLtoPGRENEF(PGALL,PGRENEF),
                 sum(PGALL2$(PGALLtoPGRENEF(PGALL2,PGRENEF) $PGREN(PGALL2)),
                 VElecGenPlanCap(runCy,PGALL2,YTIME-1))/VRenPotSupplyCurve(runCy,PGRENEF,YTIME))-0.6)))
           )$PGREN(PGALL);  

*' * Compute temporary variable facilitating the scaling in Weibull equation
QScalWeibullSum(runCy,PGALL,YTIME)$((not CCS(PGALL)) $TIME(YTIME))..
         VScalWeibullSum(runCy,PGALL,YTIME) 
         =E=
              iMatFacPlaAvailCap(runCy,PGALL,YTIME) * VRenTechMatMult(runCy,PGALL,YTIME)*
              sum(HOUR,
                 (VHourProdCostTech(runCy,PGALL,HOUR,YTIME)$(not NOCCS(PGALL))
                 +
                 VHourProdCostTechNoCCS(runCy,PGALL,HOUR,YTIME)$NOCCS(PGALL)
                 )**(-6)
              ); 
  

*' * Compute for Power Plant new investment decision
QNewInvDecis(runCy,YTIME)$TIME(YTIME)..
         VNewInvDecis(runCy,YTIME)
             =E=
         sum(PGALL$(not CCS(PGALL)),VScalWeibullSum(runCy,PGALL,YTIME));

*' * Compute the power plant share in new equipment
QPowPlaShaNewEquip(runCy,PGALL,YTIME)$(TIME(YTIME)) ..
        VPowPlaShaNewEquip(runCy,PGALL,YTIME)
             =E=
         ( VScalWeibullSum(runCy,PGALL,YTIME)/ VNewInvDecis(runCy,YTIME))$(not CCS(PGALL))
          +
          sum(NOCCS$CCS_NOCCS(PGALL,NOCCS),VPowPlaShaNewEquip(runCy,NOCCS,YTIME))$CCS(PGALL);

*' * Compute electricity generation capacity
QElecGenCapacity(runCy,PGALL,YTIME)$TIME(YTIME)..
         VElecGenPlantsCapac(runCy,PGALL,YTIME)
             =E=
         (VElecGenPlanCap(runCy,PGALL,YTIME-1)*VEndogScrapIndex(runCy,PGALL,YTIME-1)
          +(VPowPlaShaNewEquip(runCy,PGALL,YTIME) * VGapPowerGenCap(runCy,YTIME))$( (not CCS(PGALL)) AND (not NOCCS(PGALL)))
          +(VPowPlaShaNewEquip(runCy,PGALL,YTIME) * VPowerPlantNewEq(runCy,PGALL,YTIME) * VGapPowerGenCap(runCy,YTIME))$NOCCS(PGALL)
          +(VPowPlaShaNewEquip(runCy,PGALL,YTIME) * VPowerPlantNewEq(runCy,PGALL,YTIME) * VGapPowerGenCap(runCy,YTIME))$CCS(PGALL)
          + iDecInvPlantSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
          - iPlantDecomSched(runCy,PGALL,YTIME) * iAvailRate(PGALL,YTIME)
         )
         - ((VElecGenPlantsCapac(runCy,PGALL,YTIME-1)-iPlantDecomSched(runCy,PGALL,YTIME-1))* 
         iAvailRate(PGALL,YTIME)*(1/iTechLftPlaType(runCy,PGALL)))$PGSCRN(PGALL);

*' * Compute electricity generation capacity
QElecGenCap(runCy,PGALL,YTIME)$TIME(YTIME)..
         VElecGenPlanCap(runCy,PGALL,YTIME)
             =E=
         ( VElecGenPlantsCapac(runCy,PGALL,YTIME) + 1e-6 + SQRT( SQR(VElecGenPlantsCapac(runCy,PGALL,YTIME)-1e-6) + SQR(1e-4) ) )/2;

*' Compute the variable cost of each power plant technology for every region,
*' by utilizing the maturity factor related to plant dispatching.
QVarCostTechnology(runCy,PGALL,YTIME)$TIME(YTIME)..
         VVarCostTechnology(runCy,PGALL,YTIME)
         =E=  
          iMatureFacPlaDisp(runCy,PGALL,YTIME)*VVarCostTech(runCy,PGALL,YTIME)**(-2);

*' Compute the electricity peak loads of each region,
*' as a sum of the variable costs of all power plant technologies.
QElecPeakLoads(runCy,YTIME)$TIME(YTIME)..
         VElecPeakLoads(runCy,YTIME) 
         =E= 
         sum(PGALL, VVarCostTechnology(runCy,PGALL,YTIME));     

*' Compute power plant sorting to decide the plant dispatching. 
*' This is accomplished by dividing the variable cost by the peak loads.
QElectrPeakLoad(runCy,PGALL,YTIME)$TIME(YTIME)..
         VPowPlantSorting(runCy,PGALL,YTIME)
                 =E=
         VVarCostTechnology(runCy,PGALL,YTIME)
         /
         VElecPeakLoads(runCy,YTIME);  

*' * Compute the new capacity added every year
QNewCapYearly(runCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME))..
         VNewCapYearly(runCy,PGALL,YTIME) =e=
VElecGenPlanCap(runCy,PGALL,YTIME)- VElecGenPlanCap(runCy,PGALL,YTIME-1);                       

*' * Compute the average capacity factor of RES
QAvgCapFacRes(runCy,PGALL,YTIME)$(PGREN(PGALL)$TIME(YTIME))..
   VAvgCapFacRes(runCy,PGALL,YTIME)
      =E=
    (iAvailRate(PGALL,YTIME)*VNewCapYearly(runCy,PGALL,YTIME)+
     iAvailRate(PGALL,YTIME-1)*VNewCapYearly(runCy,PGALL,YTIME-1)+
     iAvailRate(PGALL,YTIME-2)*VNewCapYearly(runCy,PGALL,YTIME-2)+
     iAvailRate(PGALL,YTIME-3)*VNewCapYearly(runCy,PGALL,YTIME-3)+
     iAvailRate(PGALL,YTIME-4)*VNewCapYearly(runCy,PGALL,YTIME-4)+
     iAvailRate(PGALL,YTIME-5)*VNewCapYearly(runCy,PGALL,YTIME-5)+
     iAvailRate(PGALL,YTIME-6)*VNewCapYearly(runCy,PGALL,YTIME-6)+
     iAvailRate(PGALL,YTIME-7)*VNewCapYearly(runCy,PGALL,YTIME-7))/
(VNewCapYearly(runCy,PGALL,YTIME)+VNewCapYearly(runCy,PGALL,YTIME-1)+VNewCapYearly(runCy,PGALL,YTIME-2)+
VNewCapYearly(runCy,PGALL,YTIME-3)+VNewCapYearly(runCy,PGALL,YTIME-4)+VNewCapYearly(runCy,PGALL,YTIME-5)+
VNewCapYearly(runCy,PGALL,YTIME-6)+VNewCapYearly(runCy,PGALL,YTIME-7));

*' * Compute overall capacity
QOverallCap(runCy,PGALL,YTIME)$TIME(YTIME)..
     VOverallCap(runCy,PGALL,YTIME)
     =E=
VElecGenPlanCap(runCy,pgall,ytime)$ (not PGREN(PGALL))
+VAvgCapFacRes(runCy,PGALL,YTIME-1)*(VNewCapYearly(runCy,PGALL,YTIME)/iAvailRate(PGALL,YTIME)+
VOverallCap(runCy,PGALL,YTIME-1)
/VAvgCapFacRes(runCy,PGALL,YTIME-1))$PGREN(PGALL);


*' * Compute the scaling factor for plant dispatching
QScalFacPlantDispatch(runCy,HOUR,YTIME)$TIME(YTIME)..
         sum(PGALL,
                 (VOverallCap(runCy,PGALL,YTIME)+
                 sum(CHP$CHPtoEON(CHP,PGALL),VElecCapChpPla(runCy,CHP,YTIME)))*
                 exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/VPowPlantSorting(runCy,PGALL,YTIME))
                 )
         =E=
         (VElecPeakLoad(runCy,YTIME) - VCorrBaseLoad(runCy,YTIME))
         * exp(-VLoadCurveConstr(runCy,YTIME)*(0.25 + ord(HOUR)-1))
         + VCorrBaseLoad(runCy,YTIME);


*' * Compute estimated electricity of CHP Plants
QElecChpPlants(runCy,YTIME)$TIME(YTIME)..
         VElecChpPlants(runCy,YTIME) 
         =E=
         ( (1/0.086 * sum((INDDOM,CHP),VConsFuel(runCy,INDDOM,CHP,YTIME)) * VElecIndPrices(runCy,YTIME)) + 
         iMxmShareChpElec(runCy,YTIME)*VElecDem(runCy,YTIME) - SQRT( SQR((1/0.086 * sum((INDDOM,CHP),VConsFuel(runCy,INDDOM,CHP,YTIME)) * 
         VElecIndPrices(runCy,YTIME)) - 
         iMxmShareChpElec(runCy,YTIME)*VElecDem(runCy,YTIME)) + SQR(1E-4) ) )/2;

*' * Compute non CHP electricity production 
QNonChpElecProd(runCy,YTIME)$TIME(YTIME)..
         VNonChpElecProd(runCy,YTIME) 
         =E=
  (VElecDem(runCy,YTIME) - VElecChpPlants(runCy,YTIME));  

*' * Compute total required electricity production 
QReqElecProd(runCy,YTIME)$TIME(YTIME)..
VReqElecProd(runCy,YTIME) 
                   =E=
         sum(hour, sum(CHP,VElecCapChpPla(runCy,CHP,YTIME)*exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/ 
         sum(pgall$chptoeon(chp,pgall),VPowPlantSorting(runCy,PGALL,YTIME)))));

*' * Compute electricity production from power generation plants
QElecProdPowGenPlants(runCy,PGALL,YTIME)$TIME(YTIME)..
         VElecProdPowGenPlants(runCy,PGALL,YTIME)
                 =E=
         VNonChpElecProd(runCy,YTIME) /
         (VTotReqElecProd(runCy,YTIME)- VReqElecProd(runCy,YTIME))
         * VElecGenPlanCap(runCy,PGALL,YTIME)* sum(HOUR, exp(-VScalFacPlaDisp(runCy,HOUR,YTIME)/VPowPlantSorting(runCy,PGALL,YTIME)));

*' * Compute sector contribution to total CHP production
qSecContrTotChpProd(runCy,INDDOM,CHP,YTIME)$(TIME(YTIME) $SECTTECH(INDDOM,CHP))..
         vSecContrTotChpProd(runCy,INDDOM,CHP,YTIME) 
          =E=
         VConsFuel(runCy,INDDOM,CHP,YTIME)/(1e-6+SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME)));

*' * Compute electricity production from CHP plants 
QElecProdChpPlants(runCy,CHP,YTIME)$TIME(YTIME)..
         VChpElecProd(runCy,CHP,YTIME)
                 =E=
        sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME)) / SUM(chp2,sum(INDDOM,VConsFuel(runCy,INDDOM,CHP2,YTIME)))*
        (VElecDem(runCy,YTIME) - SUM(PGALL,VElecProd(runCy,PGALL,YTIME)));


qShareRenGrossElecProd(runCy,YTIME)$TIME(YTIME)..

                 vResShareGrossElecProd(runCy,YTIME) 
                 =E=
                 (SUM(PGNREN$((not sameas("PGASHYD",PGNREN)) $(not sameas("PGSHYD",PGNREN)) $(not sameas("PGLHYD",PGNREN)) ),
                         VElecProdPowGenPlants(runCy,PGNREN,YTIME)))/
                 (SUM(PGALL,VElecProdPowGenPlants(runCy,PGALL,YTIME))+ 
                 1e-3*sum(DSBS,sum(CHP$SECTTECH(DSBS,CHP),VConsFuel(runCy,DSBS,CHP,YTIME)))/8.6e-5*VElecIndPrices(runCy,YTIME) + 
                 1/0.086 *VNetImports(runCy,"ELC",YTIME));         

*' * Compute long term power generation cost of technologies excluding climate policies
QLonPowGenCostTechNoCp(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..
         VLongPowGenCost(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
              / (1000*(6$ISET(ESET)+4$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VFuelPriceSub(runCy,"PG",PGEF,YTIME)/1.2441+
                 iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*' * Long-term minimum power generation cost
qLonMnmpowGenCost(runCy,PGALL,YTIME)$TIME(YTIME)..

         vLonMnmpowGenCost(runCy,PGALL,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*sGwToTwhPerYear) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+(VFuelPriceSub(runCy,"PG",PGEF,YTIME)/1.2441+

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));   


*' * Compute long term power generation cost of technologies including international Prices of main fuels 
qLongPowGenIntPri(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..

         vLongPowGenIntPri(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)/1.5*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME))); 


*' * Compute short term power generation cost of technologies including international Prices of main fuels 
qShoPowGenIntPri(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..

         vShoPowGenIntPri(runCy,PGALL,ESET,YTIME)
                 =E=
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((
  SUM(EF,sum(WEF$EFtoWEF("PG",EF,WEF), iPriceFuelsInt(WEF,YTIME))*sTWhToMtoe/1000*1.5))$(not PGREN(PGALL))    +

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));    

*' * Compute long term power generation cost
QLongPowGenCost(runCy,ESET,YTIME)$TIME(YTIME)..
         VLongAvgPowGenCost(runCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, VElecProdPowGenPlants(runCy,PGALL,YTIME)*VLongPowGenCost(runCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VAvgElcProCHP(runCy,CHP,YTIME)*VChpElecProd(runCy,CHP,YTIME))
         )
/VElecDem(runCy,YTIME); 

*' The equation QLonAvgPowGenCostNoClimPol represents the long-term average power generation cost excluding climate policies.
*' It calculates the cost in Euro2005 per kilowatt-hour (kWh) for a specific combination of parameters. The equation is composed 
*' of various factors, including discount rates, technical lifetime of the plant type, gross capital cost with subsidies for renewables,
*' fixed operation and maintenance costs, plant availability rate, variable costs other than fuel, fuel prices, efficiency values, CO2 emission factors,
*' CO2 capture rates, and carbon prices. The equation incorporates a summation over different plant fuel types and considers the cost curve for CO2 sequestration.
*' The final result is the average power generation cost per unit of electricity produced, taking into account various economic and technical parameters.
QLonAvgPowGenCostNoClimPol(runCy,PGALL,ESET,YTIME)$TIME(YTIME)..
         VLonAvgPowGenCostNoClimPol(runCy,PGALL,ESET,YTIME)
                 =E=

             (iDisc(runCy,"PG",YTIME)*EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL)) /
             (EXP(iDisc(runCy,"PG",YTIME)*iTechLftPlaType(runCy,PGALL))-1)*iGrossCapCosSubRen(PGALL,YTIME)*1000*iCGI(runCy,YTIME) +
             iFixOandMCost(PGALL,YTIME))/iAvailRate(PGALL,YTIME)
             / (1000*(7.25$ISET(ESET)+2.25$RSET(ESET))) +
             sum(PGEF$PGALLTOEF(PGALL,PGEF),
                 (iVarCost(PGALL,YTIME)/1000+((VFuelPriceSub(runCy,"PG",PGEF,YTIME)-iEffValueInEuro(runCy,"PG",ytime)/1000-iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                 sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))/1000 )/1.2441+

                 iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +

                 (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*

                 (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))

                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)));

*' Compute long term power generation cost excluding climate policies by summing the Electricity production multiplied by Long-term average power generation cost excluding 
*' climate policies added to the sum of Average Electricity production cost per CHP plant multiplied by the CHP electricity production and all of the above divided by 
*' the Total electricity demand.
QLonPowGenCostNoClimPol(runCy,ESET,YTIME)$TIME(YTIME)..
         VLonPowGenCostNoClimPol(runCy,ESET,YTIME)
                 =E=
         (
         SUM(PGALL, (VElecProdPowGenPlants(runCy,PGALL,YTIME))*VLonAvgPowGenCostNoClimPol(runCy,PGALL,ESET,YTIME))

        +
         sum(CHP, VAvgElcProCHP(runCy,CHP,YTIME)*VChpElecProd(runCy,CHP,YTIME))
         )
/(VElecDem(runCy,YTIME));  

*' Compute electricity price in Industrial and Residential Consumers excluding climate policies by multiplying the Factors affecting electricity prices to consumers by the sum of 
*' Fuel prices per subsector and fuel multiplied by the TWh to Mtoe conversion factor adding the Factors affecting electricity prices to consumers and the Long-term average power 
*' generation cost  excluding climate policies for Electricity of Other Industrial sectors and for Electricity for Households .
QElecPriIndResNoCliPol(runCy,ESET,YTIME)$TIME(YTIME)..   !! The electricity price is based on previous year's production costs
        VElecPriIndResNoCliPol(runCy,ESET,YTIME)
                 =E=
        (1 + iFacElecPriConsu(runCy,"VAT",YTIME)) *
        (
           (
             (VFuelPriceSub(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"IND_RES",YTIME-1)+
               VLonPowGenCostNoClimPol(runCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VFuelPriceSub(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"TERT_RES",YTIME-1)+
                VLonPowGenCostNoClimPol(runCy,"r",YTIME-1)
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );


*' * Compute short term power generation cost
qShortPowGenCost(runCy,ESET,YTIME)$TIME(YTIME)..

        vAvgPowerGenCostShoTrm(runCy,ESET,YTIME)
                 =E=
        (
        sum(PGALL,
        VElecProdPowGenPlants(runCy,PGALL,YTIME)*
        (
        sum(PGEF$PGALLtoEF(PGALL,PGEF),
        (iVarCost(PGALL,YTIME)/1000+(VFuelPriceSub(runCy,"PG",PGEF,YTIME)/1.2441+
         iCO2CaptRate(runCy,PGALL,YTIME)*VCO2SeqCsts(runCy,YTIME)*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME) +
         (1-iCO2CaptRate(runCy,PGALL,YTIME))*1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                 *sTWhToMtoe/iPlantEffByType(runCy,PGALL,YTIME)))
        ))
        +
         sum(CHP, VAvgVarProdCostCHP(runCy,CHP,YTIME)*VChpElecProd(runCy,CHP,YTIME))
         )
         /VElecDem(runCy,YTIME);

*' * Transport

*' * Compute the lifetime of passenger cars 
QPassCarsLft(runCy,DSBS,EF,TEA,YTIME)$(TIME(YTIME) $sameas(DSBS,"PC") $SECTTECH(DSBS,EF))..
         VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME)
                 =E=
         1/VScrRate(runCy,YTIME);

*' * Compute goods transport activity
QGoodsTranspActiv(runCy,TRANSE,YTIME)$(TIME(YTIME) $TRANG(TRANSE))..
         VGoodsTranspActiv(runCy,TRANSE,YTIME)
                 =E=
         (
          VGoodsTranspActiv(runCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME)
           * (iPop(YTIME,runCy)/iPop(YTIME-1,runCy))
           * (VFuelPriceAvg(runCy,TRANSE,YTIME)/VFuelPriceAvg(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME)
           * (VFuelPriceAvg(runCy,TRANSE,YTIME-1)/VFuelPriceAvg(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VFuelPriceAvg(runCy,TRANSE,YTIME-ord(kpdl))/
                    VFuelPriceAvg(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$sameas(TRANSE,"GU")        !!trucks
         +
         (
           VGoodsTranspActiv(runCy,TRANSE,YTIME-1)
           * [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME)
           * (VFuelPriceAvg(runCy,TRANSE,YTIME)/VFuelPriceAvg(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME)
           * (VFuelPriceAvg(runCy,TRANSE,YTIME-1)/VFuelPriceAvg(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
           * prod(kpdl,
                  [(VFuelPriceAvg(runCy,TRANSE,YTIME-ord(kpdl))/
                    VFuelPriceAvg(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
           * (VGoodsTranspActiv(runCy,"GU",YTIME)/VGoodsTranspActiv(runCy,"GU",YTIME-1))**iElastA(runCy,TRANSE,"c4",YTIME)
         )$(not sameas(TRANSE,"GU"));                      !!other freight transport

*' * Compute the gap in transport activity
QGapTranspActiv(runCy,TRANSE,YTIME)$TIME(YTIME)..
         VGapTranspFillNewTech(runCy,TRANSE,YTIME)
                 =E=
         VNewReg(runCy,YTIME)$sameas(TRANSE,"PC")
         +
         (
         ( [VTrnspActiv(runCy,TRANSE,YTIME)/
         (sum((TTECH,TEA)$SECTTECH(TRANSE,TTECH),VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME-1))/TECHS(TRANSE))] +
          SQRT( SQR([VTrnspActiv(runCy,TRANSE,YTIME)/
          (sum((TTECH,TEA)$SECTTECH(TRANSE,TTECH),VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$(TRANP(TRANSE) $(not sameas(TRANSE,"PC")))
         +
         (
         ( [VGoodsTranspActiv(runCy,TRANSE,YTIME)/
         (sum((EF,TEA)$SECTTECH(TRANSE,EF),VLifeTimeTech(runCy,TRANSE,EF,TEA,YTIME-1))/TECHS(TRANSE))] + SQRT( SQR([VGoodsTranspActiv(runCy,TRANSE,YTIME)/
          (sum((EF,TEA)$SECTTECH(TRANSE,EF),VLifeTimeTech(runCy,TRANSE,EF,TEA,YTIME-1))/TECHS(TRANSE))]) + SQR(1e-4) ) )/2
         )$TRANG(TRANSE);

*' * Compute Specific Fuel Consumption
QSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF) $TTECHtoEF(TTECH,EF) )..
         VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)
                 =E=
         VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME-1) * prod(KPDL,
                     (
                        VFuelPriceSub(runCy,TRANSE,EF,YTIME-ord(KPDL))/VFuelPriceSub(runCy,TRANSE,EF,YTIME-(ord(KPDL)+1))
                      )**(iElastA(runCy,TRANSE,"c5",YTIME)*iFPDL(TRANSE,KPDL))
          );

*' * Compute transportation cost per mean and consumer size in KEuro per vehicle
QTranspCostPerMeanConsSize(runCy,TRANSE,RCon,TTECH,TEA,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(Rcon) le iNcon(TRANSE)+1))..
         VTranspCostPermeanConsSize(runCy,TRANSE,RCon,TTECH,TEA,YTIME)
         =E=
                       (
                         (
                           (iDisc(runCy,TRANSE,YTIME)*exp(iDisc(runCy,TRANSE,YTIME)*VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME)))
                           /
                           (exp(iDisc(runCy,TRANSE,YTIME)*VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME)) - 1)
                         ) * iCapCostTech(runCy,TRANSE,TTECH,YTIME)  * iCGI(runCy,YTIME)
                         + iFixOMCostTech(runCy,TRANSE,TTECH,YTIME)  +
                         (
                           (sum(EF$TTECHtoEF(TTECH,EF),VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)*VFuelPriceSub(runCy,TRANSE,EF,YTIME)) )$(not PLUGIN(TTECH))
                           +
                           (sum(EF$(TTECHtoEF(TTECH,EF) $(not sameas("ELC",EF))),

                              (1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)*VFuelPriceSub(runCy,TRANSE,EF,YTIME))
                             + iShareAnnMilePlugInHybrid(runCy,YTIME)*VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,"ELC",YTIME)*VFuelPriceSub(runCy,TRANSE,"ELC",YTIME)
                           )$PLUGIN(TTECH)

                           + iVarCostTech(runCy,TRANSE,TTECH,YTIME)
                           + (VRenValue(YTIME)/1000)$( not RENEF(TTECH))
                         )
                         *  iAnnCons(runCy,TRANSE,"smallest") * (iAnnCons(runCy,TRANSE,"largest")/iAnnCons(runCy,TRANSE,"smallest"))**((ord(Rcon)-1)/iNcon(TRANSE))
                       );

*' * Compute transportation cost per mean and consumer size 
QTranspCostPerVeh(runCy,TRANSE,rCon,TTECH,TEA,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1))..
         VTranspCostPerVeh(runCy,TRANSE,rCon,TTECH,TEA,YTIME)
         =E=
         VTranspCostPermeanConsSize(runCy,TRANSE,rCon,TTECH,TEA,YTIME)**(-4);

*' * Compute transportation cost including maturity factor
QTranspCostMatFac(runCy,TRANSE,RCon,TTECH,TEA,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $(ord(rCon) le iNcon(TRANSE)+1))..
         VTranspCostMatFac(runCy,TRANSE,RCon,TTECH,TEA,YTIME) 
         =E=
         iMatrFactor(runCy,TRANSE,TTECH,YTIME) * VTranspCostPerVeh(runCy,TRANSE,rCon,TTECH,TEA,YTIME);


*' * Compute technology sorting based on variable cost
QTechSortVarCost(runCy,TRANSE,rCon,YTIME)$(TIME(YTIME) $(ord(rCon) le iNcon(TRANSE)+1))..
         VTechSortVarCost(runCy,TRANSE,rCon,YTIME)
                 =E=
         sum((TTECH,TEA)$SECTTECH(TRANSE,TTECH), VTranspCostMatFac(runCy,TRANSE,rCon,TTECH,TEA,YTIME));

*' * Compute the share of each technology in total sectoral use
QTechSortVarCostNewEquip(runCy,TRANSE,TTECH,TEA,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) )..
         VTechSortVarCostNewEquip(runCy,TRANSE,TTECH,TEA,YTIME)
         =E=
         iMatrFactor(runCy,TRANSE,TTECH,YTIME) / iCumDistrFuncConsSize(runCy,TRANSE)
         * sum( Rcon$(ord(Rcon) le iNcon(TRANSE)+1),
                VTranspCostPerVeh(runCy,TRANSE,RCon,TTECH,TEA,YTIME)
                * iDisFunConSize(runCy,TRANSE,RCon) / VTechSortVarCost(runCy,TRANSE,RCon,YTIME)
              );

*' * Compute consumption of each technology in transport sectors
QConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) )..
         VConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME)
                 =E=
         VConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME-1) *
         (
                 (
                     ((VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME-1)-1)/VLifeTimeTech(runCy,TRANSE,TTECH,TEA,YTIME-1))
                      *(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
                      /(iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (1 - VScrRate(runCy,YTIME))$sameas(TRANSE,"PC")
         )
         +
         VTechSortVarCostNewEquip(runCy,TRANSE,TTECH,TEA,YTIME) *
         (
                 VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME)$(not PLUGIN(TTECH))
                 +
                 ( ((1-iShareAnnMilePlugInHybrid(runCy,YTIME))*VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,EF,YTIME))$(not sameas("ELC",EF))
                   + iShareAnnMilePlugInHybrid(runCy,YTIME)*VSpecificFuelCons(runCy,TRANSE,TTECH,TEA,"ELC",YTIME))$PLUGIN(TTECH)
         )/1000
         * VGapTranspFillNewTech(runCy,TRANSE,YTIME) *
         (
                 (
                  (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME-1)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME-1))
                  / (iAvgVehCapLoadFac(runCy,TRANSE,"CAP",YTIME)*iAvgVehCapLoadFac(runCy,TRANSE,"LF",YTIME))
                 )$(not sameas(TRANSE,"PC"))
                 +
                 (VTrnspActiv(runCy,TRANSE,YTIME))$sameas(TRANSE,"PC")
         );

*' * Compute final energy demand in transport per fuel
QFinEneDemTranspPerFuel(runCy,TRANSE,EF,YTIME)$(TIME(YTIME) $SECTTECH(TRANSE,EF))..
         VDemTr(runCy,TRANSE,EF,YTIME)
                 =E=
         sum((TTECH,TEA)$(SECTTECH(TRANSE,TTECH) $TTECHtoEF(TTECH,EF) ), VConsEachTechTransp(runCy,TRANSE,TTECH,EF,TEA,YTIME));

*' * Compute final energy demand in transport 
qFinEneDemTransp(runCy,TRANSE,YTIME)$(TIME(YTIME)) ..
         vFinEneDemTranspSub(runCy,TRANSE,YTIME)
                 =E=
         sum(EF,VDemTr(runCy,TRANSE,EF,YTIME));

*' * Compute passenger cars market extension (GDP dependent)
QMExtV(runCy,YTIME)$TIME(YTIME)..
         VMExtV(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTV",YTIME) * VMExtV(runCy,YTIME-1) *
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))] ** iElastA(runCy,"PC","a",YTIME);

*' * Compute passenger cars market extension (GDP independent)
QMExtF(runCy,YTIME)$TIME(YTIME)..
         VMExtF(runCy,YTIME)
                 =E=
         iTransChar(runCy,"RES_MEXTF",YTIME) * iSigma(runCy,"S1") * EXP(iSigma(runCy,"S2") * EXP(iSigma(runCy,"S3") * VLamda(runCy,YTIME))) *
         VNumVeh(runCy,YTIME-1) / (iPop(YTIME-1,runCy) * 1000);

*' * Compute stock of passenger cars (in million vehicles)
QNumVeh(runCy,YTIME)$TIME(YTIME)..
         VNumVeh(runCy,YTIME)
                 =E=
         (VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000) + VMExtF(runCy,YTIME) + VMExtV(runCy,YTIME)) *
         iPop(YTIME,runCy) * 1000;

*' * Compute new registrations of passenger cars
QNewReg(runCy,YTIME)$TIME(YTIME)..
         VNewReg(runCy,YTIME)
                 =E=
         (VMExtF(runCy,YTIME) + VMExtV(runCy,YTIME)) * (iPop(YTIME,runCy)*1000)  !! new cars due to GDP
         - VNumVeh(runCy,YTIME-1)*(1 - iPop(YTIME,runCy)/iPop(YTIME-1,runCy))    !! new cars due to population
         + VScrap(runCy,YTIME);                                                  !! new cars due to scrapping

*' * Compute passenger transport activity
QTrnspActiv(runCy,TRANSE,YTIME)$(TIME(YTIME) $TRANP(TRANSE))..
         VTrnspActiv(runCy,TRANSE,YTIME)
                 =E=
         (  !! passenger cars
            VTrnspActiv(runCy,TRANSE,YTIME-1) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME)/VFuelPriceAvg(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"b1",YTIME) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME-1)/VFuelPriceAvg(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"b2",YTIME) *
           [(VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000))/(VNumVeh(runCy,YTIME)/(iPop(YTIME,runCy)*1000))]**iElastA(runCy,TRANSE,"b3",YTIME) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"b4",YTIME)
         )$sameas(TRANSE,"PC") +
         (  !! passenger aviation
            VTrnspActiv(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME)/VFuelPriceAvg(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME-1)/VFuelPriceAvg(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME)
         )$sameas(TRANSE,"PA") +
         (   !! other passenger transportation modes
           VTrnspActiv(runCy,TRANSE,YTIME-1) *
           [(iGDP(YTIME,runCy)/iPop(YTIME,runCy))/(iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**iElastA(runCy,TRANSE,"a",YTIME) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME)/VFuelPriceAvg(runCy,TRANSE,YTIME-1))**iElastA(runCy,TRANSE,"c1",YTIME) *
           (VFuelPriceAvg(runCy,TRANSE,YTIME-1)/VFuelPriceAvg(runCy,TRANSE,YTIME-2))**iElastA(runCy,TRANSE,"c2",YTIME) *
           [(VNumVeh(runCy,YTIME)*VTrnspActiv(runCy,"PC",YTIME))/(VNumVeh(runCy,YTIME-1)*VTrnspActiv(runCy,"PC",YTIME-1))]**iElastA(runCy,TRANSE,"c4",YTIME) *
           prod(kpdl,
                  [(VFuelPriceAvg(runCy,TRANSE,YTIME-ord(kpdl))/
                    VFuelPriceAvg(runCy,TRANSE,YTIME-(ord(kpdl)+1)))/
                    (iCGI(runCy,YTIME)**(1/6))]**(iElastA(runCy,TRANSE,"c3",YTIME)*iFPDL(TRANSE,KPDL))
                 )
         )$(NOT (sameas(TRANSE,"PC") or sameas(TRANSE,"PA")));

*' * Compute scrapped passenger cars
QScrap(runCy,YTIME)$TIME(YTIME)..
         VScrap(runCy,YTIME)
                 =E=
         VScrRate(runCy,YTIME) * VNumVeh(runCy,YTIME-1);

*' * Compute ratio of car ownership over saturation car ownership
QLevl(runCy,YTIME)$TIME(YTIME)..
         VLamda(runCy,YTIME) !! level of saturation of gompertz function
                 =E=
         ( (VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) / iPassCarsMarkSat(runCy) + 1 - SQRT( SQR((VNumVeh(runCy,YTIME-1)/(iPop(YTIME-1,runCy)*1000)) /  iPassCarsMarkSat(runCy) - 1)  ) )/2;

*' * Compute passenger cars scrapping rate
QScrRate(runCy,YTIME)$TIME(YTIME)..
         VScrRate(runCy,YTIME)
                  =E=
         [(iGDP(YTIME,runCy)/iPop(YTIME,runCy)) / (iGDP(YTIME-1,runCy)/iPop(YTIME-1,runCy))]**0.5
         * VScrRate(runCy,YTIME-1);

*' * Compute electricity consumption per final demand sector
QElecConsAll(runCy,DSBS,YTIME)$TIME(YTIME)..
         VElecConsAll(runCy,DSBS,YTIME)
             =E=
         sum(INDDOM $SAMEAS(INDDOM,DSBS), VConsFuel(runCy,INDDOM,"ELC",YTIME)) + sum(TRANSE $SAMEAS(TRANSE,DSBS), VDemTr(runCy,TRANSE,"ELC",YTIME));


*' * INDUSTRY  - DOMESTIC - NON ENERGY USES - BUNKERS VARIABLES

*' * Compute non-substituable electricity consumption in Industry and Tertiary
QElecConsNonSub(runCy,INDDOM,YTIME)$TIME(YTIME)..
         VElecNonSub(runCy,INDDOM,YTIME)
                 =E=
         [
         VElecNonSub(runCy,INDDOM,YTIME-1) * ( iActv(YTIME,runCy,INDDOM)/iActv(YTIME-1,runCy,INDDOM) )**
         iElastNonSubElec(runCy,INDDOM,"a",YTIME)
         * ( VFuelPriceSub(runCy,INDDOM,"ELC",YTIME)/VFuelPriceSub(runCy,INDDOM,"ELC",YTIME-1) )**iElastNonSubElec(runCy,INDDOM,"b1",YTIME)
         * ( VFuelPriceSub(runCy,INDDOM,"ELC",YTIME-1)/VFuelPriceSub(runCy,INDDOM,"ELC",YTIME-2) )**iElastNonSubElec(runCy,INDDOM,"b2",YTIME)
         * prod(KPDL,
                  ( VFuelPriceSub(runCy,INDDOM,"ELC",YTIME-ord(KPDL))/VFuelPriceSub(runCy,INDDOM,"ELC",YTIME-(ord(KPDL)+1))
                  )**( iElastNonSubElec(runCy,INDDOM,"c",YTIME)*iFPDL(INDDOM,KPDL))
                )      ]$iActv(YTIME-1,runCy,INDDOM)+0;

*' * Compute the consumption of the remaining substitutable equipment
QConsOfRemSubEquip(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF))..
         VConsRemSubEquip(runCy,DSBS,EF,YTIME)
                 =E=
         [
         (sum(TEA,VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME)-1)/sum(TEA,VLifeTimeTech(runCy,DSBS,EF,TEA,YTIME)))
         * (VFuelConsInclHP(runCy,DSBS,EF,YTIME-1) - (VElecNonSub(runCy,DSBS,YTIME-1)$(ELCEF(EF) $INDDOM(DSBS)) + 0$(not (ELCEF(EF) $INDDOM(DSBS)) )))
         * (iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS))**iElastA(runCy,DSBS,"a",YTIME)
         * (VFuelPriceSub(runCy,DSBS,EF,YTIME)/VFuelPriceSub(runCy,DSBS,EF,YTIME-1))**iElastA(runCy,DSBS,"b1",YTIME)
         * (VFuelPriceSub(runCy,DSBS,EF,YTIME-1)/VFuelPriceSub(runCy,DSBS,EF,YTIME-2))**iElastA(runCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                 (VFuelPriceSub(runCy,DSBS,EF,YTIME-ord(KPDL))/VFuelPriceSub(runCy,DSBS,EF,YTIME-(ord(KPDL)+1)))**(iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
               )  ]$iActv(YTIME-1,runCy,DSBS)+0;

*' * Compute total final demand (of substitutable fuels) per subsector
QDemSub(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VDemSub(runCy,DSBS,YTIME)
                 =E=
         [
         VDemSub(runCy,DSBS,YTIME-1)
         * ( iActv(YTIME,runCy,DSBS)/iActv(YTIME-1,runCy,DSBS) )**iElastA(runCy,DSBS,"a",YTIME)
         * ( VFuelPriceAvg(runCy,DSBS,YTIME)/VFuelPriceAvg(runCy,DSBS,YTIME-1) )**iElastA(runCy,DSBS,"b1",YTIME)
         * ( VFuelPriceAvg(runCy,DSBS,YTIME-1)/VFuelPriceAvg(runCy,DSBS,YTIME-2) )**iElastA(runCy,DSBS,"b2",YTIME)
         * prod(KPDL,
                  ( (VFuelPriceAvg(runCy,DSBS,YTIME-ord(KPDL))/VFuelPriceAvg(runCy,DSBS,YTIME-(ord(KPDL)+1)))/(iCGI(runCy,YTIME)**(1/6))
                  )**( iElastA(runCy,DSBS,"c",YTIME)*iFPDL(DSBS,KPDL))
                )  ]$iActv(YTIME-1,runCy,DSBS)
;

*' * Compute Consumption of electricity in industrial sectors
qElecConsInd(runCy,YTIME)$TIME(YTIME)..
         vElecConsInd(runCy,YTIME)
         =E=
         SUM(INDSE,VElecNonSub(runCy,INDSE,YTIME));       

*' * Compute total final demand (of substitutable fuels) in industrial sectors (Mtoe)
qDemInd(runCy,YTIME)$TIME(YTIME)..
        vDemInd(runCy,YTIME)=E= SUM(INDSE,VDemSub(runCy,INDSE,YTIME));

*' * Compute electricity industry prices
QElecIndPrices(runCy,YTIME)$TIME(YTIME)..
         VElecIndPrices(runCy,YTIME) =E=
        ( VElecIndPricesEst(runCy,YTIME) + sElecToSteRatioChp - SQRT( SQR(VElecIndPricesEst(runCy,YTIME)-sElecToSteRatioChp) + SQR(1E-4) ) )/2;

*' * Compute fuel consumption (Mtoe)
QFuelCons(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) $(not HEATPUMP(EF)) )..
         VConsFuel(runCy,DSBS,EF,YTIME)
                 =E=
         VFuelConsInclHP(runCy,DSBS,EF,YTIME)$(not ELCEF(EF)) + 
         (VFuelConsInclHP(runCy,DSBS,EF,YTIME) + VElecConsHeatPla(runCy,DSBS,YTIME))$ELCEF(EF);



*' * Compute the estimated electricity index of industry price
QElecIndPricesEst(runCy,YTIME)$TIME(YTIME)..
         VElecIndPricesEst(runCy,YTIME)
                 =E=
         VElecIndPrices(runCy,YTIME-1) *
        ((VFuelPriceSub(runCy,"OI","ELC",YTIME-1)/VFuelPriceAvg(runCy,"OI",YTIME-1))/
        (VFuelPriceSub(runCy,"OI","ELC",YTIME-2)/VFuelPriceAvg(runCy,"OI",YTIME-2)))**(0.3) *
        ((VFuelPriceSub(runCy,"OI","ELC",YTIME-2)/VFuelPriceAvg(runCy,"OI",YTIME-2))/
        (VFuelPriceSub(runCy,"OI","ELC",YTIME-3)/VFuelPriceAvg(runCy,"OI",YTIME-3)))**(0.3);

*' * Compute fuel prices per subsector and fuel especially for chp plants (take into account the profit of electricity sales)
QFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS))  $SECTTECH(DSBS,EF) )..
        VFuePriSubChp(runCy,DSBS,EF,TEA,YTIME)
                =E=   
             (((VFuelPriceSub(runCy,DSBS,EF,YTIME) + (VRenValue(YTIME)/1000)$(not RENEF(EF))+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
               (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VElecIndPrices(runCy,YTIME))$CHP(EF)))  + SQRT( SQR(((VFuelPriceSub(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)- 
              (0$(not CHP(EF)) + (VFuelPriceSub(runCy,"OI","ELC",YTIME)*iFracElecPriChp*VElecIndPrices(runCy,YTIME))$CHP(EF))))  ) )/2;


*' * Compute electricity production cost per CHP plant and demand sector 
QElecProdCosChp(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VElecProdCostChp(runCy,DSBS,CHP,YTIME)
                 =E=
                    ( ( iDisc(runCy,"PG",YTIME) * exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP))
                        / (exp(iDisc(runCy,"PG",YTIME)*iLifChpPla(runCy,DSBS,CHP)) -1))
                      * iInvCostChp(runCy,DSBS,CHP,YTIME)* 1000 * iCGI(runCy,YTIME)  + iFixOMCostPerChp(runCy,DSBS,CHP,YTIME)
                    )/(iAvailRateChp(runCy,DSBS,CHP)*(1000*sTWhToMtoe))/1000
                    + iVarCostChp(runCy,DSBS,CHP,YTIME)/1000
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+0.001*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         * sTWhToMtoe /  (iBoiEffChp(runCy,CHP,YTIME) * VElecIndPrices(runCy,YTIME)) );        

*' * Compute technology cost
QTechCost(runCy,DSBS,rCon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
        VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) 
                 =E= 
                 VTechCostIntrm(runCy,DSBS,rCon,EF,TEA,YTIME)**(-iElaSub(runCy,DSBS)) ;   

*' * Compute technology cost including lifetime 
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
                      (VFuelPriceSub(runCy,DSBS,EF,YTIME)+iVarCostTech(runCy,DSBS,EF,YTIME)/1000)/iUsfEneConvSubTech(runCy,DSBS,EF,YTIME)
                    )
                    * iAnnCons(runCy,DSBS,"smallest") * (iAnnCons(runCy,DSBS,"largest")/iAnnCons(runCy,DSBS,"smallest"))**((ord(rCon)-1)/iNcon(DSBS))
                  )$NENSE(DSBS);  

*' * Compute technology cost including Maturity factor per technology and subsector
QTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) $SECTTECH(DSBS,EF) )..
        VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME) 
                                               =E=
        iMatrFactor(runCy,DSBS,EF,YTIME) * VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME) ;

*' * Compute Technology sorting based on variable cost
QTechSort(runCy,DSBS,rCon,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $(ord(rCon) le iNcon(DSBS)+1) )..
        VTechSort(runCy,DSBS,rCon,YTIME)
                        =E=
        sum((EF,TEA)$(SECTTECH(DSBS,EF) ),VTechCostMatr(runCy,DSBS,rCon,EF,TEA,YTIME));

*' * Compute the gap in final demand on industry, tertiary, non-energy uses and bunkers
QGapFinalDem(runCy,DSBS,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)))..
         VGapFinalDem(runCy,DSBS,YTIME)
                 =E=
         VDemSub(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquip(runCy,DSBS,EF,YTIME))
         + SQRT( SQR(VDemSub(runCy,DSBS,YTIME) - sum(EF$SECTTECH(DSBS,EF), VConsRemSubEquip(runCy,DSBS,EF,YTIME)))) /2;

*' * Compute technology share in new equipment
QTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)$(TIME(YTIME) $SECTTECH(DSBS,EF) $(not TRANSE(DSBS)) )..
         VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME) =E=
         iMatrFactor(runCy,DSBS,EF,YTIME) / iCumDistrFuncConsSize(runCy,DSBS) *
         sum(rCon$(ord(rCon) le iNcon(DSBS)+1),
                  VTechCost(runCy,DSBS,rCon,EF,TEA,YTIME)
                  * iDisFunConSize(runCy,DSBS,rCon)/VTechSort(runCy,DSBS,rCon,YTIME));

*' *Compute fuel consumption including heat from heatpumps
QFuelConsInclHP(runCy,DSBS,EF,YTIME)$(TIME(YTIME) $(not TRANSE(DSBS)) $SECTTECH(DSBS,EF) )..
         VFuelConsInclHP(runCy,DSBS,EF,YTIME)
                 =E=
         VConsRemSubEquip(runCy,DSBS,EF,YTIME)+
         sum(TEA,VTechShareNewEquip(runCy,DSBS,EF,TEA,YTIME)*VGapFinalDem(runCy,DSBS,YTIME))
         + (VElecNonSub(runCy,DSBS,YTIME))$(INDDOM(DSBS) $(ELCEF(EF)));

*' * Compute variable including fuel electricity production cost per CHP plant and demand sector 
QVarProCostPerCHPDem(runCy,DSBS,CHP,YTIME)$(TIME(YTIME) $INDDOM(DSBS))..
         VProCostCHPDem(runCy,DSBS,CHP,YTIME)
                 =E=
         iVarCostChp(runCy,DSBS,CHP,YTIME)/1E3
                    + sum(PGEF$CHPtoEF(CHP,PGEF), (VFuelPriceSub(runCy,"PG",PGEF,YTIME)+1e-3*iCo2EmiFac(runCy,"PG",PGEF,YTIME)*
                         (sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))))
                         *sTWhToMtoe/(   iBoiEffChp(runCy,CHP,YTIME)*VElecIndPrices(runCy,YTIME)    ));

*' * Compute Average Electricity production cost per CHP plant 
QAvgElcProCostCHP(runCy,CHP,YTIME)$TIME(YTIME)..
         VAvgElcProCHP(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))*VElecProdCostChp(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

*' * Compute Average variable including fuel electricity production cost per CHP plant 
QAvgVarElecProd(runCy,CHP,YTIME)$(TIME(YTIME) ) ..
         VAvgVarProdCostCHP(runCy,CHP,YTIME)
         =E=

         (sum(INDDOM, VConsFuel(runCy,INDDOM,CHP,YTIME-1)/SUM(INDDOM2,VConsFuel(runCy,INDDOM2,CHP,YTIME-1))
         *VProCostCHPDem(runCy,INDDOM,CHP,YTIME)))
         $SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1))+0$(NOT SUM(INDDOM2,VConsFuel.L(runCy,INDDOM2,CHP,YTIME-1)));

*' * REST OF ENERGY BALANCE SECTORS

*' The equation QTransfOutputPatFuel calculates the transformation output from patent fuel and briquetting plants, coke-oven plants, blast furnace plants,
*' and gas works (VTransfOutputPatFuel). The equation involves the use of a residual (iTransfOutputGasw) and is governed by certain parameters such as sector
*' activity (iActv), activity elasticities (iElastA), and the ratio of current year activity to the previous year (iActv(YTIME,runCy,"IS")/iActv(YTIME-1,runCy,"IS")).
QTransfOutputPatFuel(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfOutputPatFuel(runCy,EFS,YTIME)
             =E=
         [
         iTransfOutputGasw(runCy,YTIME) * VTransfOutputPatFuel(runCy,EFS,YTIME-1) * (iActv(YTIME,runCy,"IS")/iActv(YTIME-1,runCy,"IS"))**iElastA(runCy,"IS","a",YTIME)
         ]$iActv(YTIME-1,runCy,"IS")+0;

*' The equation QTotFinEneCons computes the total final energy consumption (VFeCons) in million tonnes of oil equivalent (Mtoe) for each country (runCy),
*' energy form sector (EFS), and time period (YTIME). The total final energy consumption is calculated as the sum of final energy consumption in the
*' Industry and Tertiary sectors (INDDOM) and the sum of final energy demand in all transport subsectors (TRANSE). The consumption is determined by the 
*' relevant link between model subsectors and fuels (SECTTECH).
QTotFinEneCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VFeCons(runCy,EFS,YTIME)
             =E=
         sum(INDDOM,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel(runCy,INDDOM,EF,YTIME)))
         +
         sum(TRANSE,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemTr(runCy,TRANSE,EF,YTIME)));

*' The equation qTotFinEneConsAll computes the total final energy consumption (vTotFinEneConsAll) in million tonnes of oil equivalent (Mtoe)
*' for all countries at a specific time period (YTIME). This is achieved by summing the final energy consumption (VFeCons) for each energy
*' form sector (EFS) across all countries (runCy).
qTotFinEneConsAll(YTIME)$TIME(YTIME)..
         vTotFinEneConsAll(YTIME) =E= sum((runCy,EFS), VFeCons(runCy,EFS,YTIME) );     

*' The equation QFinNonEneCons computes the final non-energy consumption (VFNonEnCons) in million tonnes of oil equivalent (Mtoe)
*' for a given energy form sector (EFS). The calculation involves summing the consumption of fuels in each non-energy and bunkers
*' demand subsector (NENSE) based on the corresponding fuel aggregation for the supply side (EFtoEFS). This process is performed 
*' for each time period (YTIME).
QFinNonEneCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VFNonEnCons(runCy,EFS,YTIME)
             =E=
         sum(NENSE$(not sameas("BU",NENSE)),
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel(runCy,NENSE,EF,YTIME)));  

*' The equation QDistrLosses computes the distribution losses (VLosses) in million tonnes of oil equivalent (Mtoe) for a given energy form sector (EFS).
*' The losses are determined by the rate of losses over available for final consumption (iRateLossesFinCons) multiplied by the sum of total final energy
*' consumption (VFeCons) and final non-energy consumption (VFNonEnCons). This calculation is performed for each time period (YTIME).
*' Please note that distribution losses are not considered for the hydrogen sector (H2EF(EF)).
QDistrLosses(runCy,EFS,YTIME)$TIME(YTIME)..
         VLosses(runCy,EFS,YTIME)
             =E=
         (iRateLossesFinCons(runCy,EFS,YTIME) * (VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME)))$(not H2EF(EFS));  

*' The equation QTransfOutputDHPlants calculates the transformation output from district heating plants (VTransfOutputDHPlants).
*' This transformation output is determined by summing over different demand sectors (DOMSE) and district heating systems (DH)
*' that correspond to the specified energy form set (EFtoEFS(DH, STEAM)). The equation then sums over these district heating 
*' systems and calculates the consumption of fuels (VConsFuel) in each of these sectors. The resulting value represents the 
*' transformation output from district heating plants in million tonnes of oil equivalent (Mtoe).
QTranfOutputDHPlants(runCy,STEAM,YTIME)$TIME(YTIME)..
         VTransfOutputDHPlants(runCy,STEAM,YTIME)
             =E=
         sum(DOMSE,
             sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel(runCy,DOMSE,DH,YTIME)));

*' The equation QTransfInputDHPlants calculates the transformation input to district heating plants (VTransfInputDHPlants).
*' This transformation input is determined by summing over different district heating systems (DH) that correspond to the
*' specified energy form set (DHtoEF(DH, EFS)). The equation then sums over different demand sectors (DOMSE) within each 
*' district heating system and calculates the consumption of fuels (VConsFuel) in each of these sectors, taking into account
*' the efficiency of district heating plants (iEffDHPlants). The resulting value represents the transformation input to district
*' heating plants in million tonnes of oil equivalent (Mtoe).
QTransfInputDHPlants(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfInputDHPlants(runCy,EFS,YTIME)
             =E=
         sum(DH$DHtoEF(DH,EFS),
             sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel(runCy,DOMSE,DH,YTIME)) / iEffDHPlants(runCy,EFS,YTIME));   

*' The equation QTransfInputPatFuel calculates the transformation input to patent fuel and briquetting plants, coke-oven plants, blast furnace plants,
*' and gas works (VTransfInputPatFuel). This transformation input is computed by summing over different energy forms (EF) within the specified set (EFS)
*' and using the corresponding transformation output (VTransfOutputPatFuel). The efficiency of gasworks, blast furnaces, and briquetting plants (iAvgEffGas)
*' is taken into account, and the result is multiplied by the share of fuels in the transformation input to gasworks, blast furnaces, and briquetting plants
*' in the base year (iShareFueTransfInput). The output represents the transformation input in the base year (1).
QTransfInputPatFuel(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfInputPatFuel(runCy,EFS,YTIME)
             =E=
         sum(EF$(EFS(EF) $iAvgEffGas(runCy,EF,YTIME)) , VTransfOutputPatFuel(runCy,EFS,YTIME)/iAvgEffGas(runCy,EF,YTIME)) * iShareFueTransfInput(runCy,EFS); 

*' The equation QRefCapacity calculates the refineries' capacity (VRefCapacity) for a given scenario and year (YTIME).
*' The calculation is based on a residual factor (iResRefCapacity), the previous year's capacity, and a production scaling
*' factor that takes into account the historical consumption trends for different energy forms (EFS). The scaling factor is
*' influenced by the base year (tFirst) and the production scaling parameter (prod(rc,...)). The result represents the refineries'
*' capacity in million barrels per day (Million Barrels/day).
QRefCapacity(runCy,YTIME)$TIME(YTIME)..
         VRefCapacity(runCy,YTIME)
             =E=
         [
         iResRefCapacity(runCy,YTIME) * VRefCapacity(runCy,YTIME-1)
         *
         (1$(ord(YTIME) le 16) +
         (prod(rc,
         (sum(EFS$EFtoEFA(EFS,"LQD"),VFeCons(runCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VFeCons(runCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
         )
         $(ord(YTIME) gt 16)
         )     ] $iRefCapacity(runCy,"%fStartHorizon%");

*' The equation QTranfOutputRefineries calculates the transformation output from refineries (VTransfOutputRefineries) for a specific energy form (EFS)
*' in a given scenario and year (YTIME). The output is computed based on a residual factor (iResTransfOutputRefineries), the previous year's output, and the
*' change in refineries' capacity (VRefCapacity). The calculation includes considerations for the base year (tFirst) and adjusts the result accordingly.
*' The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
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
                sum(EF$EFtoEFA(EF,"LQD"),VFeCons(runCy,EF,YTIME-1))/sum(EF$EFtoEFA(EF,"LQD"),VFeCons(runCy,EF,YTIME-2))
             )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
           )**(0.7)  ]$iRefCapacity(runCy,"%fStartHorizon%"); 

*' The equation QTransfInputRefineries calculates the transformation input to refineries (VTransfInputRefineries) for the energy form "CRO" (Crude Oil)
*' in a specific scenario and year (YTIME). The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation
*' output from refineries for the given energy form and year to the output in the previous year. This calculation is conditional on the refineries' capacity
*' (iRefCapacity) being active in the specified starting horizon.The result represents the transformation input to refineries for crude oil in million tons of oil equivalent.
QTransfInputRefineries(runCy,"CRO",YTIME)$(TIME(YTIME) )..
         VTransfInputRefineries(runCy,"CRO",YTIME)
             =E=
         [
         VTransfInputRefineries(runCy,"CRO",YTIME-1) *
         sum(EFS$EFtoEFA(EFS,"LQD"), VTransfOutputRefineries(runCy,EFS,YTIME)) /
         sum(EFS$EFtoEFA(EFS,"LQD"), VTransfOutputRefineries(runCy,EFS,YTIME-1))  ]$iRefCapacity(runCy,"%fStartHorizon%");                   

*' The equation QTransfOutputNuclear calculates the transformation output from nuclear plants (VTransfOutputNuclear) for electricity production ("ELC")
*' in a specific scenario and year (YTIME). The output is computed as the sum of electricity production from all nuclear power plants (PGNUCL) in the given
*' scenario and year, multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe).
*' The result represents the transformation output from nuclear plants for electricity production in million tons of oil equivalent.
QTransfOutputNuclear(runCy,"ELC",YTIME)$TIME(YTIME) ..
         VTransfOutputNuclear(runCy,"ELC",YTIME) =E=SUM(PGNUCL,VElecProd(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation QTransfInNuclear computes the transformation input to nuclear plants (VTransfInNuclear) for a specific scenario and year (YTIME).
*' The input is calculated based on the sum of electricity production from all nuclear power plants (PGNUCL) in the given scenario and year, divided
*' by the plant efficiency (iPlantEffByType) and multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe).
*' The result represents the transformation input to nuclear plants in million tons of oil equivalent.
QTransfInNuclear(runCy,"NUC",YTIME)$TIME(YTIME)..
        VTransfInNuclear(runCy,"NUC",YTIME) =E=SUM(PGNUCL,VElecProd(runCy,PGNUCL,YTIME)/iPlantEffByType(runCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation QTransfInPowerPls computes the transformation input to thermal power plants (VTransfInThermPowPls) for a specific power generation form (PGEF)
*' in a given scenario and year (YTIME). The input is calculated based on the following conditions:
*' For conventional power plants (PGALL) that are not geothermal (PGGEO) or nuclear (PGNUCL), the transformation input is determined by the electricity production
*' from the respective power plant (VElecProd) multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), divided by the
*' plant efficiency (iPlantEffByType).
*' For geothermal power plants (PGGEO), the transformation input is based on the electricity production from the geothermal plant (VElecProd) multiplied by the conversion
*' factor.
*' For combined heat and power (CHP) plants (CHP), the input is calculated as the sum of the consumption of fuels in various demand subsectors (VConsFuel) and the electricity
*' production from the CHP plant (VChpElecProd). This sum is then divided by a factor based on the year (ord(YTIME)) to account for variations over time.The result represents
*' the transformation input to thermal power plants in million tons of oil equivalent.
QTransfInPowerPls(runCy,PGEF,YTIME)$TIME(YTIME)..
         VTransfInThermPowPls(runCy,PGEF,YTIME)
             =E=
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$((not PGGEO(PGALL)) $(not PGNUCL(PGALL)))),
             VElecProd(runCy,PGALL,YTIME) * sTWhToMtoe /  iPlantEffByType(runCy,PGALL,YTIME))
        +
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$PGGEO(PGALL)),
             VElecProd(runCy,PGALL,YTIME) * sTWhToMtoe) 
        +
        sum(CHP$CHPtoEF(CHP,PGEF),  sum(INDDOM,VConsFuel(runCy,INDDOM,CHP,YTIME))+sTWhToMtoe*VChpElecProd(runCy,CHP,YTIME))/(0.8+0.1*(ord(YTIME)-16)/32);

*' The equation QTransfOutThermPP calculates the transformation output from thermal power stations (VTransfOutThermPowSta) for a specific energy branch (TOCTEF)
*' in a given scenario and year (YTIME). The result is computed based on the following conditions: 
*' If the energy branch is related to electricity (ELCEF(TOCTEF)), the transformation output from thermal power stations is the sum of electricity production from
*' conventional power plants (VElecProd) and combined heat and power (CHP) plants (VChpElecProd). The production values are converted from terawatt-hours (TWh) to
*' million tons of oil equivalent (Mtoe).
*' If the energy branch is associated with steam (STEAM(TOCTEF)), the transformation output is determined by the sum of the consumption of fuels in various demand
*' subsectors (VConsFuel), the rate of energy branch consumption over total transformation output (iRateEneBranCons), and losses (VLosses).
*' The result represents the transformation output from thermal power stations in million tons of oil equivalent.
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
            
*' The equation QTotTransfInput calculates the total transformation input (VTotTransfInput) for a specific energy branch (EFS)
*' in a given scenario and year (YTIME). The result is obtained by summing the transformation inputs from different sources, including
*' thermal power plants (VTransfInThermPowPls), District Heating Plants (VTransfInputDHPlants), nuclear plants (VTransfInNuclear), patent
*' fuel and briquetting plants (VTransfInputPatFuel), and refineries (VTransfInputRefineries). In the case where the energy branch is "OGS"
*' (Other Gas), the total transformation input is calculated as the difference between the total transformation output and various consumption
*' and loss components. The outcome represents the total transformation input in million tons of oil equivalent.
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

*' The equation QTotTransfOutput calculates the total transformation output (VTotTransfOutput) for a specific energy branch (EFS) in a given scenario and year (YTIME).
*' The result is obtained by summing the transformation outputs from different sources, including thermal power stations (VTransfOutThermPowSta), District Heating Plants
*' (VTransfOutputDHPlants), nuclear plants (VTransfOutputNuclear), patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
*' (VTransfOutputPatFuel), as well as refineries (VTransfOutputRefineries). The outcome represents the total transformation output in million tons of oil equivalent.
QTotTransfOutput(runCy,EFS,YTIME)$TIME(YTIME)..
         VTotTransfOutput(runCy,EFS,YTIME)
                 =E=
         VTransfOutThermPowSta(runCy,EFS,YTIME) + VTransfOutputDHPlants(runCy,EFS,YTIME) + VTransfOutputNuclear(runCy,EFS,YTIME) + VTransfOutputPatFuel(runCy,EFS,YTIME) +
         VTransfOutputRefineries(runCy,EFS,YTIME);        !!+ TONEW(runCy,EFS,YTIME)

*' The equation QTransfers calculates the transfers of a specific energy branch (EFS) in a given scenario and year (YTIME).
*' The result, represented by VTransfers, is computed based on a complex formula that involves the previous year's transfers,
*' the residual for feedstocks in transfers (iResFeedTransfr), and various conditions.
*' In particular, the equation includes terms related to feedstock transfers (iFeedTransfr), residual feedstock transfers (iResFeedTransfr),
*' and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
QTransfers(runCy,EFS,YTIME)$TIME(YTIME)..
         VTransfers(runCy,EFS,YTIME) =E=
         (( (VTransfers(runCy,EFS,YTIME-1)*iResFeedTransfr(runCy,YTIME)*VFeCons(runCy,EFS,YTIME)/VFeCons(runCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
          (
                 VTransfers(runCy,"CRO",YTIME-1)*iResFeedTransfr(runCy,YTIME)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME))/
                 SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(runCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(runCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);         

*' The equation QGrsInlConsNotEneBranch calculates the gross inland consumption excluding the consumption of a specific energy branch (EFS)
*' in a given scenario and year (YTIME). The result, represented by VGrsInlConsNotEneBranch, is computed by summing various components, including
*' total final energy consumption, final non-energy consumption, total transformation input and output, distribution losses, and transfers.
*' The outcome represents the gross inland consumption excluding the consumption of the specified energy branch in million tons of oil equivalent.
 QGrsInlConsNotEneBranch(runCy,EFS,YTIME)$TIME(YTIME)..
         VGrsInlConsNotEneBranch(runCy,EFS,YTIME)
                 =E=
         VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME) + VTotTransfInput(runCy,EFS,YTIME) - VTotTransfOutput(runCy,EFS,YTIME) + VLosses(runCy,EFS,YTIME) - 
         VTransfers(runCy,EFS,YTIME); 

*' The equation QGrssInCons calculates the gross inland consumption (VGrssInCons) for a specific energy branch (EFS) in a given scenario and year (YTIME).
*' This is computed by summing various components, including total final energy consumption, final consumption in the energy sector, final non-energy consumption,
*' total transformation input and output, distribution losses, and transfers. The result represents the gross inland consumption in million tons of oil equivalent.
QGrssInCons(runCy,EFS,YTIME)$TIME(YTIME)..
         VGrssInCons(runCy,EFS,YTIME)
                 =E=
         VFeCons(runCy,EFS,YTIME) + VEnCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME) + VTotTransfInput(runCy,EFS,YTIME) - VTotTransfOutput(runCy,EFS,YTIME) +
          VLosses(runCy,EFS,YTIME) - VTransfers(runCy,EFS,YTIME);  

*' The equation QPrimProd calculates the primary production (VPrimProd) for a specific primary production definition (PPRODEF) in a given scenario and year (YTIME).
*' The computation involves different scenarios based on the type of primary production definition:
*' For primary production definitions other than "CRO" and "NGS," the primary production is directly proportional to the rate of primary production in total primary needs,
*' and it depends on gross inland consumption not including the consumption of the energy branch.
*' For "NGS" (Natural Gas) primary production, the calculation considers a specific formula involving the rate of primary production in total primary needs, residuals for
*' hard coal, natural gas, and oil primary production, the elasticity related to gross inland consumption for natural gas, and other factors. Additionally, there is a lag
*' effect with coefficients (iPolDstrbtnLagCoeffPriOilPr) for primary oil production.
*' For "CRO" (Crude Oil) primary production, the computation includes the rate of primary production in total primary needs, residuals for hard coal, natural gas, and oil
*' primary production, the fuel primary production, and a product term involving the polynomial distribution lag coefficients for primary oil production.
*' The result represents the primary production in million tons of oil equivalent.
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
                         (iPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1))/iPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1)))
                         **(0.2*iPolDstrbtnLagCoeffPriOilPr(kpdl)))
         )$sameas(PPRODEF,"CRO")   ]$iRatePriProTotPriNeeds(runCy,PPRODEF,YTIME);   

*' The equation QFakeExp calculates the fake exports (VExportsFake) for a specific energy branch (EFS)
*' in a given scenario and year (YTIME). The computation is based on the fuel exports (iFuelExprts) for
*' the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
QFakeExp(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..
         VExportsFake(runCy,EFS,YTIME)
                 =E=
         (
                 iFuelExprts(runCy,EFS,YTIME)
         )
+  iFuelExprts(runCy,EFS,YTIME);

*' The equation QFakeImprts computes the fake imports (VFkImpAllFuelsNotNatGas) for a specific energy branch (EFS)
*' in a given scenario and year (YTIME). The calculation is based on different conditions for various energy branches,
*' such as electricity (ELCEF), crude oil (CRO), and natural gas (NGS). The equation involves gross inland consumption
*' (VGrssInCons), fake exports (VExportsFake), consumption of fuels in demand subsectors (VConsFuel), electricity imports
*' (iElecImp), and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
QFakeImprts(runCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS))..

         VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME)

                 =E=
         (
            iRatioImpFinElecDem(runCy,YTIME) * (VFeCons(runCy,EFS,YTIME) + VFNonEnCons(runCy,EFS,YTIME)) + VExportsFake(runCy,EFS,YTIME)
         + iElecImp(runCy,YTIME)
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

*' The equation QNetImports computes the net imports (VNetImports) for a specific energy branch (EFS)
*' in a given scenario and year. It subtracts the fake exports (VExportsFake) from the fake imports for
*' all fuels except natural gas (VFkImpAllFuelsNotNatGas). The result represents the net imports in million tons of oil equivalent.
QNetImports(runCy,EFS,YTIME)$TIME(YTIME)..
         VNetImports(runCy,EFS,YTIME)
                 =E=
         VFkImpAllFuelsNotNatGas(runCy,EFS,YTIME) - VExportsFake(runCy,EFS,YTIME);
                               
*' The equation QEneBrnchEneCons calculates the final energy consumption in the energy sector (VEnCons).
*' It considers the rate of energy branch consumption over the total transformation output (iRateEneBranCons).
*' The final consumption is determined based on the total transformation output and primary production for energy
*' branches, excluding Oil, Coal, and Gas. The result, VEnCons, represents the final consumption in million tons of
*' oil equivalent for the specified scenario and year.
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

*' * CO2 SEQUESTRATION COST CURVES

*' The equation QCO2ElcHrg calculates the CO2 captured by electricity and hydrogen production plants (VCO2ElcHrgProd)
*' in million tons of CO2 for a specific scenario and year (runCy, YTIME). The CO2 capture is determined by summing 
*' the product of electricity production (VElecProd) from plants with carbon capture and storage (CCS), the conversion
*' factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), the plant efficiency (iPlantEffByType),
*' the CO2 emission factor (iCo2EmiFac), and the plant CO2 capture rate (iCO2CaptRate). 
QCO2ElcHrg(runCy,YTIME)$TIME(YTIME)..
         VCO2ElcHrgProd(runCy,YTIME)
         =E=
         sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                 VElecProd(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
                 iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)));

*' The equation QCumCO2Capt calculates the cumulative CO2 captured (VCumCO2Capt) in million tons of CO2 for a given scenario and year.
*' The cumulative CO2 captured at the current time period is determined by adding the CO2 captured by electricity and hydrogen production
*' plants (VCO2ElcHrgProd) to the cumulative CO2 captured in the previous time period. This equation captures the ongoing total CO2 capture
*' over time in the specified scenario.
QCumCO2Capt(runCy,YTIME)$TIME(YTIME)..
         VCumCO2Capt(runCy,YTIME) =E= VCumCO2Capt(runCy,YTIME-1)+VCO2ElcHrgProd(runCy,YTIME-1);   

*' The equation QWghtTrnstLinToExpo computes the transition weight (VWghtTrnstLnrToExpo) from a linear to exponential CO2 sequestration
*' cost curve for a specific scenario and year (runCy, YTIME). The transition weight is determined based on the cumulative CO2 captured
*' (VCumCO2Capt) and parameters defining the transition characteristics (iElastCO2Seq).The transition weight is calculated using a logistic function.
*' This equation provides a mechanism to smoothly transition from a linear to exponential cost curve based on the cumulative CO2 captured, allowing
*' for a realistic representation of the cost dynamics associated with CO2 sequestration. The resulting VWghtTrnstLnrToExpo represents the weight for
*' the transition in the specified scenario and year.
QWghtTrnstLinToExpo(runCy,YTIME)$TIME(YTIME)..
         VWghtTrnstLnrToExpo(runCy,YTIME)
         =E=
         1/(1+exp(-iElastCO2Seq(runCy,"mc_s")*( VCumCO2Capt(runCy,YTIME)/iElastCO2Seq(runCy,"pot")-iElastCO2Seq(runCy,"mc_m")))); 

*' The equation QCstCO2SeqCsts calculates the cost curve for CO2 sequestration costs (VCO2SeqCsts) in Euro per ton of CO2 sequestered
*' for a specific scenario and year (runCy, YTIME). The cost curve is determined based on cumulative CO2 captured (VCumCO2Capt) and
*' elasticities for the CO2 sequestration cost curve (iElastCO2Seq).The equation is formulated to represent a flexible cost curve that
*' can transition from linear to exponential. The transition is controlled by the weight for the transition from linear to exponential
*' (VWghtTrnstLnrToExpo). The cost curve is expressed as a combination of linear and exponential functions, allowing for a realistic
*' representation of the relationship between cumulative CO2 captured and sequestration costs. This equation provides a dynamic and
*' realistic approach to modeling CO2 sequestration costs, considering the cumulative CO2 captured and the associated elasticities
*' for the cost curve. The resulting VCO2SeqCsts represents the cost of sequestering one ton of CO2 in the specified scenario and year.
QCstCO2SeqCsts(runCy,YTIME)$TIME(YTIME)..
         VCO2SeqCsts(runCy,YTIME) =E=
       (1-VWghtTrnstLnrToExpo(runCy,YTIME))*(iElastCO2Seq(runCy,"mc_a")*VCumCO2Capt(runCy,YTIME)+iElastCO2Seq(runCy,"mc_b"))+
       VWghtTrnstLnrToExpo(runCy,YTIME)*(iElastCO2Seq(runCy,"mc_c")*exp(iElastCO2Seq(runCy,"mc_d")*VCumCO2Capt(runCy,YTIME)));           


*' * EMISSIONS CONSTRAINTS 

*' The equation QTotGhgEmisAllCountrNap computes the total CO2 equivalent (CO2eq) greenhouse gas emissions in all countries
*' per National Allocation Plan (NAP) sector for a specific year (YTIME). The result, VTotGhgEmisAllCountrNap, represents the 
*' sum of CO2eq emissions for each NAP sector across all countries.
*' The equation involves several components:
*' Consumption of Fuels (VConsFuel): The consumption of fuels in each demand subsector, excluding heat from heat pumps, is considered.
*' The emissions are calculated based on the fuel consumption and the CO2 emission factor for each subsector.
*' Transformation Input to Thermal Power Plants (VTransfInThermPowPls): The transformation input to thermal power plants is considered,
*' and the emissions are calculated based on the input and the CO2 emission factor.
*' Transformation Input to District Heating Plants (VTransfInputDHPlants): The transformation input to district heating plants is considered,
*' and emissions are calculated based on the input and the CO2 emission factor.
*' Final Consumption in Energy Sector (VEnCons): The final consumption in the energy sector is considered, and emissions are calculated based
*' on the consumption and the CO2 emission factor.
*' Electricity Production (VElecProd): The emissions from electricity production are considered, including adjustments for plant efficiency,
*' CO2 emission factors, and the CO2 capture rate for plants with carbon capture and storage (CCS).
*' The equation provides a comprehensive approach to calculating CO2eq emissions for each NAP sector, considering various aspects of fuel consumption
*' and transformation across different subsectors. The result VTotGhgEmisAllCountrNap represents the overall CO2eq emissions for each NAP sector across
*' all countries for the specified year.
QTotGhgEmisAllCountrNap(NAP,YTIME)$TIME(YTIME)..
         VTotGhgEmisAllCountrNap(NAP,YTIME)
          =E=
        (
        sum(runCy,
                 sum((EFS,INDSE)$(SECTTECH(INDSE,EFS)  $NAPtoALLSBS(NAP,INDSE)),
                      VConsFuel(runCy,INDSE,EFS,YTIME) * iCo2EmiFac(runCy,INDSE,EFS,YTIME)) !! final consumption
                +
                 sum(PGEF, VTransfInThermPowPls(runCy,PGEF,YTIME)*iCo2EmiFac(runCy,"PG",PGEF,YTIME)$(not h2f1(pgef))) !! input to power generation sector
                 +
                 sum(EFS, VTransfInputDHPlants(runCy,EFS,YTIME)*iCo2EmiFac(runCy,"PG",EFS,YTIME)) !! input to district heating plants
                 +
                 sum(EFS, VEnCons(runCy,EFS,YTIME)*iCo2EmiFac(runCy,"PCH",EFS,YTIME)) !! consumption of energy branch

                 -
                 sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                         VElecProd(runCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(runCy,CCS,YTIME)*
                         iCo2EmiFac(runCy,"PG",PGEF,YTIME)*iCO2CaptRate(runCy,CCS,YTIME)))));   !! CO2 captured by CCS plants in power generation

*' The equation qTotCo2AllCoun computes the total CO2 equivalent (CO2eq) greenhouse gas emissions in all countries for a specific year (YTIME).
*' The result, vTotCo2AllCoun, represents the sum of total CO2eq emissions across all countries. The summation is performed over the NAP (National Allocation Plan) sectors,
*' considering the total CO2eq GHG emissions per NAP sector (VTotGhgEmisAllCountrNap) for each country. This equation provides a concise and systematic approach to aggregating
*' greenhouse gas emissions at a global level, considering contributions from different sectors and countries. 
qTotCo2AllCoun(YTIME)$TIME(YTIME)..

         vTotCo2AllCoun(YTIME) 
         =E=
         sum(NAP, VTotGhgEmisAllCountrNap(NAP,YTIME));

*' Compute households expenditures on energy by utilizing the sum of consumption of remaining substitutable equipment multiplied by the fuel prices per subsector and fuel 
*' minus the efficiency values divided by CO2 emission factors per subsector and multiplied by the sum of carbon prices for all countries and adding the Electricity price
*' to Industrial and Residential Consumers multiplied by Consumption of non-substituable electricity in Industry and Tertiary divided by TWh to Mtoe conversion factor.
qHouseExpEne(runCy,YTIME)$TIME(YTIME)..
                 vHouseExpEne(runCy,YTIME)
                 =E= 
                 SUM(DSBS$HOU(DSBS),SUM(EF$SECTTECH(dSBS,EF),VConsRemSubEquip(runCy,DSBS,EF,YTIME)*(VFuelPriceSub(runCy,DSBS,EF,YTIME)-iEffValueInEuro(runCy,DSBS,YTIME)/
                 1000-iCo2EmiFac(runCy,"PG",EF,YTIME)*sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(runCy,NAP,YTIME))/1000)))
                                          +VElecPriIndResNoCliPol(runCy,"R",YTIME)*VElecNonSub(runCy,"HOU",YTIME)/sTWhToMtoe;         


*' * Prices

*' The equation QFuelPriSubSepCarbVal computes fuel prices per subsector and fuel (VFuelPriceSub) with separate carbon values in
*' each sector for a specific scenario, subsector (SBS), fuel (EF), and year (YTIME).The equation considers various scenarios based
*' on the type of fuel and whether it is subject to changes in carbon values. It incorporates factors such as carbon emission factors
*' (iCo2EmiFac), carbon values for all countries (VCarVal), electricity prices to industrial and residential consumers (VElecPriInduResConsu),
*' efficiency values (iEffValueInEuro), and the total hydrogen cost per sector (iHydrogenPri).The result of the equation is the fuel price per 
*'subsector and fuel, adjusted based on changes in carbon values, electricity prices, efficiency, and hydrogen costs.
QFuelPriSubSepCarbVal(runCy,SBS,EF,YTIME)$(SECTTECH(SBS,EF) $TIME(YTIME) $(not sameas("NUC",EF)))..
         VFuelPriceSub(runCy,SBS,EF,YTIME)
                 =E=
         (VFuelPriceSub(runCy,SBS,EF,YTIME-1) +
          iCo2EmiFac(runCy,SBS,EF,YTIME) * sum(NAP$NAPtoALLSBS(NAP,SBS),(VCarVal(runCy,NAP,YTIME)))/1000
         )$( not (ELCEF(EF) or HEATPUMP(EF) or ALTEF(EF)))
         +
         (
VFuelPriceSub(runCy,SBS,EF,YTIME-1)$(DSBS(SBS))$ALTEF(EF)
         )
         +
         (
           ( VElecPriInduResConsu(runCy,"i",YTIME)$INDTRANS(SBS)+VElecPriInduResConsu(runCy,"r",YTIME)$RESIDENT(SBS))/sTWhToMtoe
            +
            ((iEffValueInEuro(runCy,SBS,YTIME))/1000)$DSBS(SBS)
         )$(ELCEF(EF) or HEATPUMP(EF))
         +
         (
                 iHydrogenPri(runCy,SBS,YTIME-1)$DSBS(SBS)
         )$(H2EF(EF) or sameas("STE1AH2F",EF));

*' The equation QFuelPriSepCarbon calculates the fuel prices per subsector and fuel multiplied by weights (VFuelPriMultWgt)
*' considering separate carbon values in each sector. This equation is applied for a specific scenario, subsector (DSBS), fuel (EF), and year (YTIME).
*' The calculation involves multiplying the sector's average price weight based on fuel consumption (iWgtSecAvgPriFueCons) by the fuel price per subsector
*' and fuel (VFuelPriceSub). The weights are determined by the sector's average price, considering the specific fuel consumption for the given scenario, subsector, and fuel.
*' This equation allows for a more nuanced calculation of fuel prices, taking into account the carbon values in each sector. The resulting VFuelPriMultWgt represents the fuel
*' prices per subsector and fuel, multiplied by the corresponding weights, and adjusted based on the specific carbon values in each sector.
QFuelPriSepCarbon(runCy,DSBS,EF,YTIME)$(SECTTECH(DSBS,EF) $TIME(YTIME))..
        VFuelPriMultWgt(runCy,DSBS,EF,YTIME)
          =E= 
        iWgtSecAvgPriFueCons(runCy,DSBS,EF) * VFuelPriceSub(runCy,DSBS,EF,YTIME);

*' The equation QAvgFuelPriSub calculates the average fuel price per subsector (VFuelPriceAvg) for a specific scenario, subsector, and year.
*' The calculation involves summing the product of fuel prices per subsector and fuel (VFuelPriMultWgt) and their corresponding weights (SECTTECH)
*' for the specified scenario, subsector (DSBS), and year (YTIME).The equation is designed to compute the weighted average fuel price, considering
*' different fuels within the subsector and their respective weights.
QAvgFuelPriSub(runCy,DSBS,YTIME)$TIME(YTIME)..
        VFuelPriceAvg(runCy,DSBS,YTIME)
                 =E=
         sum(EF$SECTTECH(DSBS,EF), VFuelPriMultWgt(runCy,DSBS,EF,YTIME));         

*' The equation QElecPriIndResCons calculates the electricity price for industrial and residential consumers (VElecPriInduResConsu)
*' in a given scenario, energy set, and year. The electricity price is based on the previous year's production costs, incorporating
*' various factors such as fuel prices, factors affecting electricity prices to consumers (iFacElecPriConsu), and long-term average
*' power generation costs (VLongAvgPowGenCost).The equation is structured to handle different energy sets (ESET). It calculates the electricity
*' price for industrial consumers (ISET) and residential consumers (RSET) separately. The electricity price is influenced by fuel prices,
*' factors affecting electricity prices, and long-term average power generation costs. It provides a comprehensive representation of the
*' factors contributing to the electricity price for industrial and residential consumers in the specified scenario, energy set, and year.
QElecPriIndResCons(runCy,ESET,YTIME)$TIME(YTIME)..  !! The electricity price is based on previous year's production costs
        VElecPriInduResConsu(runCy,ESET,YTIME)
                 =E=
        (1 + iFacElecPriConsu(runCy,"VAT",YTIME)) *
        (
           (
             (VFuelPriceSub(runCy,"OI","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"IND_RES",YTIME-1)+
                VLongAvgPowGenCost(runCy,"i",YTIME-1)
              )$(not TFIRST(YTIME-1))
           )$ISET(ESET)
        +
           (
             (VFuelPriceSub(runCy,"HOU","ELC",YTIME-1)*sTWhToMtoe)$TFIRST(YTIME-1) +
             (  iFacElecPriConsu(runCy,"TERT_RES",YTIME-1)+
               VLongAvgPowGenCost(runCy,"r",YTIME-1)
             )$(not TFIRST(YTIME-1))
           )$RSET(ESET)
        );

*' * Define dummy objective function
qDummyObj.. vDummyObj =e= 1;
