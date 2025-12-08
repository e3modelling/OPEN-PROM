*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
*' Set bounds for cost multiplier with conservative values to avoid max() function
*' Lower bound set to prevent excessive cost reductions while ensuring solver compatibility
*' Using simple conservative bound instead of complex max() calculation
*' Cost = (LearnableFraction * CostMultiplier + (1-LearnableFraction)) * InitialCost
VmCostLC.LO(LCTECH,YTIME) = 0.35;   !! Conservative 35% minimum cost multiplier (65% max reduction)
VmCostLC.UP(LCTECH,YTIME) = 2.0;   !! Allow some cost increase for numerical stability
*---
*' Initialize cumulative capacity with historical data from base year  
*' Sum installed capacity across all countries for learning curve technologies
*' Convert from MW to GW by dividing by 1000
V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = sum(allCy, imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%")) / 1000;
*---
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
VmCostLC.FX(LCTECH,"%fBaseY%") = 1.0;
*---
