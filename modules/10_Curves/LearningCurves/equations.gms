*' @title Equations of OPEN-PROMs Learning Curves module
*' @code

*' GENERAL INFORMATION

*' * Learning Curves module 

*' This equation implements the learning curve for wind and solar technologies with stopping mechanism.
*' The learning curve follows the equation: multiplier = (Cap_current / Cap_initial)^ε
*' where ε is calculated from learning rate: ε = log(1-LR)/log(2)
*' 
*' STOPPING MECHANISM: Only a fraction of costs are subject to learning curves.
*' - LearnableFraction: Technology-specific manufacturing costs that improve with experience
*' - FixedFraction: Basic materials, labor, installation costs that remain constant
*' - MinCostFraction: Absolute floor preventing unrealistic cost reductions
*'
*' The cost multiplier applies only to the learnable portion of total costs.
*' Final cost = [LearnableFraction × CostMultiplier + (1-LearnableFraction)] × InitialCost

*' Learning curve cost multiplier equation with numerical safeguards
*' Timing: Cost multiplier for YTIME based on capacity growth in previous period (YTIME-1 vs YTIME-2)
*' This reflects that learning happens from past experience and affects current period costs
*' Safeguards: Add small epsilon to denominator to avoid division by zero
Q10CostLC(LCTECH,YTIME)$(TIME(YTIME))..
    VmCostLC(LCTECH,YTIME)
        =E=
    (V10CumCapGlobal(LCTECH,YTIME-1) / (V10CumCapGlobal(LCTECH,YTIME-2))) ** i10AlphaLC(LCTECH);

*' Global cumulative capacity tracking equation
*' Tracks total cumulative capacity installations since base year
*' Cumulative = Previous cumulative + New installations this period (converted MW to GW)
Q10CumCapGlobal(LCTECH,YTIME)$(TIME(YTIME))..
    V10CumCapGlobal(LCTECH,YTIME)
        =E=
    V10CumCapGlobal(LCTECH,YTIME-1) + 
    sum(allCy$(runCy(allCy)), V04NewCapElec(allCy,LCTECH,YTIME));