*' @title Emissions Constraints Preloop
*' @code

*'                *VARIABLE INITIALISATION*
*---
V07GrossEmissCO2Supply.LO(runCy,SSBS,YTIME) = 0;
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
V07GrossEmissCO2Demand.LO(runCy,DSBS,YTIME) = 0;
V07GrossEmissCO2Demand.FX(runCy,DSBS,YTIME)$DATAY(YTIME) =   
SUM(EF,
  imFuelCons(runCy,DSBS,EF,YTIME) *
  imCo2EmiFac(runCy,DSBS,EF,YTIME)
);
*---
V07EmiActBySrcRegTim.FX(E07SrcMacAbate, allCy, YTIME)$DATAY(YTIME) = i07DataCh4N2OFEmis(allCy,E07SrcMacAbate,YTIME) ;
*---
V07EmissionsNet.FX(runCy,YTIME)$DATAY(YTIME) = sum(SSBS, V07GrossEmissCO2Supply.L(runCy,SSBS,YTIME))
    + sum(DSBS, V07GrossEmissCO2Demand.L(runCy,DSBS,YTIME))
    - sum((SBS,EFS)$SECtoEF(SBS,EFS), V06CO2CaptureCCS.L(runCy,SBS,EFS,YTIME))
    - sum(CDRTECH, V06CapCDR.L(runCy,CDRTECH,YTIME));
*---
V07EmissionsNetPart.L(runCy,YTIME) = 0.1;
V07EmissionsNetPart.FX(runCy,YTIME)$DATAY(YTIME) = V07EmissionsNet.L(runCy,YTIME) /
    (sum(runCy2, V07EmissionsNet.L(runCy2,YTIME)) + epsilon6);
*---

*'                *PARAMETER INITIALISATION FOR RECURSIVE LAGS*

V07RedAbsBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME) = 0;
V07CostAbateBySrcRegTim.L(E07SrcMacAbate,runCy,YTIME) = 0;

*' Seed parameters from historical data
p07GrossEmissCO2Supply(runCy,SSBS,YTIME)$(DATAY(YTIME)) = V07GrossEmissCO2Supply.L(runCy,SSBS,YTIME);
p07RedAbsBySrcRegTim(E07SrcMacAbate,runCy,YTIME)$(DATAY(YTIME)) = 0;
p07EmiActBySrcRegTim(E07SrcMacAbate,runCy,YTIME)$(DATAY(YTIME)) = i07DataCh4N2OFEmis(runCy,E07SrcMacAbate,YTIME);
p07CostAbateBySrcRegTim(E07SrcMacAbate,runCy,YTIME)$(DATAY(YTIME)) = 0;
p07GrossEmissCO2Demand(runCy,DSBS,YTIME)$(DATAY(YTIME)) = V07GrossEmissCO2Demand.L(runCy,DSBS,YTIME);
p07EmissionsNet(runCy,YTIME)$(DATAY(YTIME)) = V07EmissionsNet.L(runCy,YTIME);
p07EmissionsNetPart(runCy,YTIME)$(DATAY(YTIME)) = V07EmissionsNetPart.L(runCy,YTIME);
