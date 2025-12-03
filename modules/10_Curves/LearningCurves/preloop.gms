*' @title Learning Curves module Preloop
*' @code

*'                *VARIABLE INITIALISATION*

*---
V10CostLC.LO(LCTECH,YTIME) = 0.01;  !! Minimum cost multiplier (99% reduction max)
V10CostLC.UP(LCTECH,YTIME) = 1.0;   !! Maximum cost multiplier (no increase)
*---
*' Calculate learning curve parameters from learning rates
*' With C(t) = (Cap(t)/Cap(t-1))^ε and LR = 1 - 2^(-ε)
*' Solving for ε: ε = -log(1-LR) / log(2) (negative for cost reduction)
i10AlphaLC(LCTECH) = -log(1 - i10LearningRate(LCTECH)) / log(2);
*---
*' Initialize cumulative capacity with initial values for base year
V10CumCapGlobal.FX(LCTECH,"2020") = i10InitCapGlobal(LCTECH);
*---
*' Initialize cost multiplier to 1.0 for base year (no cost reduction initially)
V10CostLC.FX(LCTECH,"2020") = 1.0;
*---
