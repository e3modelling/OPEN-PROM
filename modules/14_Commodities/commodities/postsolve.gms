*' @title Commodities module postsolve
* Fix values of variables for the next time step

* Commodities Module
V14Imp.FX(runCyL,MATERIALS,YTIME)$TIME(YTIME) = V14Imp.L(runCyL,MATERIALS,YTIME)$TIME(YTIME);
V14CostAvgCommodities.FX(runCyL,COMMODITIES,YTIME)$TIME(YTIME) = V14CostAvgCommodities.L(runCyL,COMMODITIES,YTIME)$TIME(YTIME);
