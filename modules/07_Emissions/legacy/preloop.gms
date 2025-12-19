*' @title Emissions Constraints Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V07EmissCO2Supply.FX(runCy,SSBS,YTIME)$DATAY(YTIME) = 
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