*' @title Emissions Constraints Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V07GrossEmissCO2Supply.FX(runCy,"H2INFR",YTIME) = 0;
V07GrossEmissCO2Supply.FX(runCy,SSBS,YTIME)$DATAY(YTIME) = 
SUM(EFS,
  (
    (-i03InpTotTransfProcess(runCy,SSBS,EFS,YTIME))$SSBSEMIT(SSBS) +
    i03DataOwnConsEne(runCy,SSBS,EFS,YTIME) -
    SUM(CCS$PGALLtoEF(CCS,EFS),
      SUM(PGEF$sameas(PGEF,EFS),
      i04ShareFuels(runCy,CCS,PGEF)) *
      VmProdElec.L(runCy,CCS,YTIME) * smTWhToMtoe / 
      imPlantEffByType(runCy,CCS,"effELC",YTIME) * 
      V04CO2CaptRate.L(runCy,CCS,YTIME)
    )$sameas("PG",SSBS) -
    SUM(H2CCS$H2TECHEFtoEF(H2CCS,EFS),
      VmProdH2.L(runCy,H2CCS,YTIME) /
      i05EffH2Prod(runCy,H2CCS,YTIME) *
      V05CaptRateH2.L(runCy,H2CCS,YTIME)
    )$sameas("H2P",SSBS)
  ) *
  imCo2EmiFac(runCy,"PG",EFS,YTIME)
);
*---
P07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy))) =
    smax(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME) * p07UnitConvFactor(E07SrcMacAbate)),
         i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC, YTIME));

P07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy))) =
    sum(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME) * p07UnitConvFactor(E07SrcMacAbate)),
        p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME) * p07MacCost(E07MAC) * p07CostCorrection(E07SrcMacAbate));

P07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy))) =
    i07DataCh4N2OFEmis(allCy, E07SrcMacAbate, YTIME)  - P07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME);
    
P07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$DATAY(YTIME) = i07DataCh4N2OFEmis(allCy,E07SrcMacAbate,YTIME) ;