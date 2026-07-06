*' @title Economy module Declarations
*' @code

Equations
Q11SubsiTot(allCy,YTIME)                                 "Computes the total annual state revenues from carbon taxes per region (Millions US$2015)"
Q11SubsiDemTechAvail(allCy,DSBS,TECH,YTIME)              "Computes the state grants purposed to the support of each demand technology (Millions US$2015)"
Q11SubsiFuelAvail(allCy,SBS,EFS,YTIME)                    "Computes the state grants purposed to the support of each fuel (Millions US$2015)"
Q11SubsiFuel(allCy,SBS,EFS,YTIME)                        "Computes the state support for each fuel"
Q11SubsiDemITech(allCy,DSBS,ITECH,YTIME)                 "Computes the state support per unit of new capacity in the industrial subsectors and technologies (kUS$2015/toe-year)"
Q11SubsiDemTech(allCy,DSBS,TECH,YTIME)                   "Computes the state grants used for the support of each demand technology (Millions US$2015)"
Q11SubsiSupTech(allCy,STECH,YTIME)                       "Computes the state grants purposed to the support of each supply technology (Millions US$2015)"
Q11SubsiCapCostTech(allCy,DSBS,TECH,YTIME)                        ""
Q11SubsiFuelTot(allCy,SBS,EFS,YTIME)                        "Computes the total state support for each fuel (Millions US$2015)"
!!Q11SubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
Q11NetSubsiTax(allCy,YTIME)                              "Computes the net difference between the cabon taxes and the green state grants and subsidies (Millions US$2015)"
;

Variables
V11SubsiTot(allCy,YTIME)                                 "Total annual state revenues from carbon taxes per region (Millions US$2015)"
VmSubsiDemTechAvail(allCy,DSBS,TECH,YTIME)               "State grants purposed to the support of each demand technology (Millions US$2015)"
VmSubsiFuelAvail(allCy,SBS,EFS,YTIME)                     "State grants purposed to the support of each fuel (Millions US$2015)"
VmSubsiFuel(allCy,SBS,EFS,YTIME)                          "State support for each fuel (kUS$2015/toe)"
VmSubsiDemITech(allCy,DSBS,ITECH,YTIME)                  "The state support per unit of new capacity in the industrial subsectors and technologies (kUS$2015/toe-year)"
VmSubsiDemTech(allCy,DSBS,TECH,YTIME)                    "The state support per unit of new capacity in the demand subsectors and technologies for the following units:"
                                                            !!Transport (kUS$2015 per vehicle)
                                                            !!Industry (kUS$2015/toe-year)
                                                            !!CDR ()
                                                            !!Residential electricity ()
VmSubsiSupTech(allCy,STECH,YTIME)                        "State grants purposed to the support of each supply technology (Millions US$2015)"
VmSubsiCapCostTech(allCy,DSBS,TECH,YTIME)                ""
VmSubsiFuelTot(allCy,SBS,EFS,YTIME)                     "Total state support for each fuel (Millions US$2015)"
VmSubsiCapCostSupply(allCy,SSBS,STECH,YTIME)
VmNetSubsiTax(allCy,YTIME)                               "The net difference between the cabon taxes and the green state grants and subsidies"
;