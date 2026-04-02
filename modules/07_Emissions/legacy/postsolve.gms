*' @title Emissions Constraints postsolve
* Fix values of variables for the next time step

* Emissions Module

V07GrossEmissCO2Supply.FX(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(runCyL,SSBS,YTIME)$TIME(YTIME);

P07GrossEmissCO2Demand(allCy,DSBS,YTIME)$(TIME(YTIME)$runCy(allCy)) =   
    SUM(EFS,
      (
        VmConsFuel.L(allCy,DSBS,EFS,YTIME) + 
        SUM(TRANSE$sameas(TRANSE,DSBS), VmDemFinEneTranspPerFuel.L(allCy,TRANSE,EFS,YTIME)) +
        sum(DACTECH$TECHtoEF(DACTECH,EFS),VmConsFuelTechCDRProd.L(allCy,DACTECH,EFS,YTIME))$(sameas(DSBS,"DAC")) +
        VmConsFuelTechCDRProd.L(allCy,"TEW",EFS,YTIME)$(sameas(DSBS,"EW"))
      ) *
      imCo2EmiFac(allCy,DSBS,EFS,YTIME)
    );
