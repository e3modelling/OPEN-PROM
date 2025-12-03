*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
V10CostLC.LO(LCTECH,YTIME) = 0.01;  !! Minimum cost multiplier (99% reduction max)
V10CostLC.UP(LCTECH,YTIME) = 1.0;   !! Maximum cost multiplier (no increase)
*---
*' Initialize cumulative capacity with historical data from base year  
*' Sum installed capacity across all countries for learning curve technologies
V10CumCapGlobal.FX(LCTECH,"%fBaseY%") = sum(allCy, imInstCapPastNonCHP(allCy,LCTECH,"%fBaseY%"));
*---
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
V10CostLC.FX(LCTECH,"%fBaseY%") = 1.0;
*---
