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
*' Correct formulation: C(t) = (Cap(t) / Cap(t-1))^ε
*' Where LR = 1 - 2^(-ε), so ε = -log(LR) / log(2)
Q10CostLC(LCTECH,YTIME)$(TIME(YTIME) and not TFIRST(YTIME))..
    V10CostLC(LCTECH,YTIME)
        =E=
    (V10CumCapGlobal(LCTECH,YTIME) / V10CumCapGlobal(LCTECH,YTIME-1)) ** i10AlphaLC(LCTECH);

*' Global cumulative capacity tracking equation
*' Tracks total cumulative capacity installations since base year
*' Cumulative = Previous cumulative + New installations this period (converted MW to GW)
Q10CumCapGlobal(LCTECH,YTIME)$(TIME(YTIME) and not TFIRST(YTIME))..
    V10CumCapGlobal(LCTECH,YTIME)
        =E=
    V10CumCapGlobal(LCTECH,YTIME-1) + 
    sum(allCy$(runCy(allCy)), V04NewCapElec(allCy,LCTECH,YTIME) / 1000);
