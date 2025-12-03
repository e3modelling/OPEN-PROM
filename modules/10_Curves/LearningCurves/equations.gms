*' @title Equations of OPEN-PROMs Learning Curves module
*' @code

*' GENERAL INFORMATION

*' * Learning Curves module 

*' This equation implements the learning curve for wind and solar technologies.
*' The learning curve follows the equation: multiplier = (Cap_current / Cap_initial)^ε
*' where ε is calculated from learning rate: ε = log(1-LR)/log(2)
*' 
*' The cost multiplier depends on global cumulative capacity deployment
*' and is applied to existing PowerGeneration cost tables.

*' Learning curve cost multiplier equation
*' Timing: Cost multiplier for YTIME based on capacity growth in previous period (YTIME-1 vs YTIME-2)
*' This reflects that learning happens from past experience and affects current period costs
Q10CostLC(LCTECH,YTIME)$(TIME(YTIME) and not TFIRST(YTIME) and not TFIRST(YTIME-1))..
    V10CostLC(LCTECH,YTIME)
        =E=
    (V10CumCapGlobal(LCTECH,YTIME-1) / V10CumCapGlobal(LCTECH,YTIME-2)) ** i10AlphaLC(LCTECH);

*' Global cumulative capacity tracking equation
*' Tracks total cumulative capacity installations since base year
*' Cumulative = Previous cumulative + New installations this period (converted MW to GW)
Q10CumCapGlobal(LCTECH,YTIME)$(TIME(YTIME) and not TFIRST(YTIME))..
    V10CumCapGlobal(LCTECH,YTIME)
        =E=
    V10CumCapGlobal(LCTECH,YTIME-1) + 
    sum(allCy$(runCy(allCy)), V04NewCapElec(allCy,LCTECH,YTIME) / 1000);
