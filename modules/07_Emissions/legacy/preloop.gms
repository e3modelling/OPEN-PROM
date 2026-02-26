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
      VmProdElec.L(runCy,CCS,YTIME) * smTWhToMtoe / 
      imPlantEffByType(runCy,CCS,YTIME) * 
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
V07GrossEmissCO2Demand.FX(runCy,DSBS,YTIME)$DATAY(YTIME) =   
SUM(EF,
  imFuelConsPerFueSub(runCy,DSBS,EF,YTIME) *
  imCo2EmiFac(runCy,DSBS,EF,YTIME)
);
*---
V07EmiActBySrcRegTim.FX(E07SrcMacAbate, allCy, YTIME)$DATAY(YTIME) = i07DataCh4N2OFEmis(allCy,E07SrcMacAbate,YTIME) ;