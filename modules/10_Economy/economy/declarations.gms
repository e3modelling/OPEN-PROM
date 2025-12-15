*' @title Heat module Declarations
*' @code

Equations
Q10CarbTaxTot(allCy,YTIME)                                 "Compute the total annual state revenues from carbon taxes per region (Millions US$2015)"
Q10NetSubsiTax(allCy,YTIME)                                "Computes the net difference between the cabon taxes and the green state grants and subsidies"
Q10SubsiCapCostTech(allCy,DSBS,TECH,YTIME)                        ""
Q10SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
;

Variables
V10CarbTaxTot(allCy,YTIME)                                 "Total annual state revenues from carbon taxes per region (Millions US$2015)"
VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)                       ""
VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
VmNetSubsiTax(allCy,YTIME)                                 "The net difference between the cabon taxes and the green state grants and subsidies"
;