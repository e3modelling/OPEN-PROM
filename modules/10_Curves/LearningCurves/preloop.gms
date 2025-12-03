*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
*' Calculate learning curve parameters from learning rates
*' With C(t) = (Cap(t)/Cap(t-1))^ε and LR = 1 - 2^(-ε)
*' Solving for ε: ε = -log(1-LR) / log(2) (negative for cost reduction)
i10AlphaLC(LCTECH) = -log(1 - i10LearningRate(LCTECH)) / log(2);
*---
*' Set bounds for cost multiplier with stopping mechanism
*' Lower bound ensures minimum cost floor is respected
*' Cost = (LearnableFraction * CostMultiplier + (1-LearnableFraction)) * InitialCost
*' At minimum: CostMultiplier_min = (MinCostFraction - (1-LearnableFraction)) / LearnableFraction
V10CostLC.LO(LCTECH,YTIME) = max(0.01, 
    (i10MinCostFraction(LCTECH) - (1 - i10LearnableFraction(LCTECH))) / i10LearnableFraction(LCTECH));
V10CostLC.UP(LCTECH,YTIME) = 1.0;   !! Maximum cost multiplier (no increase)
*---
*' Initialize cumulative capacity with historical data from base year  
*' Sum installed capacity across all countries for learning curve technologies
V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = sum(allCy, imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%"));
*---
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
V10CostLC.FX(LCTECH,"%fBaseY%") = 1.0;
*---
