*' @title Economy module Preloop
*' @code

*'                *VARIABLE INITIALISATION*
V11SubsiTot.LO(runCy,YTIME) = 0;
*V11SubsiTot.L(runCy,YTIME) = 1;
V11SubsiTot.FX(runCy,YTIME)$(DATAY(YTIME)) = (
    sum(EF,
        VmConsFinEneCountry.L(runCy, EF, YTIME) * imCo2EmiFac(runCy,"PG", EF, YTIME)) +
    sum(SSBS,
        V07EmissCO2Supply.L(runCy,SSBS,YTIME))
    )
    * sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal.L(runCy,NAP,YTIME));
*---
VmSubsiDemITech.LO(runCy,DSBS,ITECH,YTIME) = 0;
VmSubsiDemITech.L(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH)) = 1;
VmSubsiDemITech.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or TFIRST(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
*---
VmSubsiCapCostTech.FX(runCy,DSBS,TECH,YTIME)$(not SECTTECH(DSBS,TECH)) = 0;
*---
VmNetSubsiTax.FX(runCy,YTIME)$(DATAY(YTIME)) = 0;