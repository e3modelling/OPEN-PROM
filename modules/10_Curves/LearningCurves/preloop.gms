*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
*' Set bounds for cost multiplier with stopping mechanism (relaxed for stability)
*' Lower bound ensures minimum cost floor is respected but not too restrictive
*' Cost = (LearnableFraction * CostMultiplier + (1-LearnableFraction)) * InitialCost
*' At minimum: CostMultiplier_min = (MinCostFraction - (1-LearnableFraction)) / LearnableFraction
VmCostLC.LO(LCTECH,YTIME) = max(0.01, 
    0.5 * (i10MinCostFraction(LCTECH) - (1 - i10LearnableFraction(LCTECH))) / i10LearnableFraction(LCTECH));
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
