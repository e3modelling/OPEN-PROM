*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
*' Set bounds for cost multiplier with conservative values to avoid max() function
*' Lower bound set to prevent excessive cost reductions while ensuring solver compatibility
*' Using simple conservative bound instead of complex max() calculation
*' Cost = (LearnableFraction * CostMultiplier + (1-LearnableFraction)) * InitialCost
VmCostLC.LO(LCTECH,YTIME) = 0.1;   !! Conservative 10% minimum cost multiplier (90% max reduction)
VmCostLC.UP(LCTECH,YTIME) = 2.0;   !! Allow some cost increase for numerical stability
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
VmCostLC.FX(LCTECH,"%fBaseY%") = 1.0;
*---
*' Initialize cumulative capacity with historical data from base year only
*' Sum installed capacity across all countries for learning curve technologies
*' Keep units consistent: imInstCapPastNonCHP is in MW, V10CumCapGlobal should be in MW to match V04NewCapElec
V10CumCapGlobal.FX(LCTECH,"2019") = sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"2019"))/1000;
V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = V10CumCapGlobal.L(LCTECH,"2019") + sum(allCy$(runCy(allCy)), imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%"))/1000;
*---