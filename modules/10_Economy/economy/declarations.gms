*' @title Economy module Declarations
*' @code

Equations
Q10SubsiTot(allCy,YTIME)                                 "Computes the total annual state revenues from carbon taxes per region (Millions US$2015)"
Q10SubDemsiTech(allCy,TECH,YTIME)                           "Computes the state grants purposed to the support of each technology (Millions US$2015)"
Q10NetSubsiTax(allCy,YTIME)                              "Computes the net difference between the cabon taxes and the green state grants and subsidies (Millions US$2015)"
Q10SubsiCapCostTech(allCy,DSBS,TECH,YTIME)                        ""
Q10SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
;

Variables
V10SubsiTot(allCy,YTIME)                                 "Total annual state revenues from carbon taxes per region (Millions US$2015)"
VmSubsiTech(allCy,TECH,YTIME)                            "State grants purposed to the support of each technology (Millions US$2015)"
VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)                       ""
VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
VmNetSubsiTax(allCy,YTIME)                                 "The net difference between the cabon taxes and the green state grants and subsidies"
;