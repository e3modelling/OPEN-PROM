*' @title Economy module Declarations
*' @code

Equations
Q11SubsiTot(allCy,YTIME)                                 "Computes the total annual state revenues from carbon taxes per region (Millions US$2015)"
Q11SubsiDemTech(allCy,DSBS,TECH,YTIME)                        "Computes the state grants purposed to the support of each demand technology (Millions US$2015)"
Q11SubsiSupTech(allCy,STECH,YTIME)                       "Computes the state grants purposed to the support of each supply technology (Millions US$2015)"
Q11NetSubsiTax(allCy,YTIME)                              "Computes the net difference between the cabon taxes and the green state grants and subsidies (Millions US$2015)"
Q11SubsiCapCostTech(allCy,DSBS,TECH,YTIME)                        ""
Q11SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
;

Variables
V11SubsiTot(allCy,YTIME)                                 "Total annual state revenues from carbon taxes per region (Millions US$2015)"
VmSubsiDemTech(allCy,DSBS,TECH,YTIME)                            "State grants purposed to the support of each demand technology (Millions US$2015)"
VmSubsiSupTech(allCy,STECH,YTIME)                            "State grants purposed to the support of each supply technology (Millions US$2015)"
VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)                       ""
VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
VmNetSubsiTax(allCy,YTIME)                                 "The net difference between the cabon taxes and the green state grants and subsidies"
;