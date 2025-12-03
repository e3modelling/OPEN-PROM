*' @title Learning Curves Inputs
*' @code
*' This file contains minimal input data required for the Learning Curves module.
*' Initial costs are dynamically set from PowerGeneration module (i04GrossCapCosSubRen).
*' Initial capacities use historical data from imInstCapPastNonCHP.

Parameters
i10AlphaLC(LCTECH)                  "Learning curve factor alpha for technology (1)"
i10LearningRate(LCTECH)             "Learning rate for technology (1)" 
i10InitCostRefLC(allCy,LCTECH,YTIME) "Initial cost reference for learning curves from PowerGeneration (kUS$2015/KW)"
;
*---
*' Calculate learning curve parameters from learning rates
*' With C(t) = (Cap(t)/Cap(t-1))^ε and LR = 1 - 2^(-ε)
*' Solving for ε: ε = -log(1-LR) / log(2) (negative for cost reduction)
i10AlphaLC(LCTECH) = -log(1 - i10LearningRate(LCTECH)) / log(2);
*---
i10LearningRate("PGSOL") = 0.20;    !! 20% cost reduction per doubling for Solar PV
i10LearningRate("PGCSP") = 0.20;    !! 20% cost reduction per doubling for CSP
i10LearningRate("PGAWND") = 0.10;   !! 10% cost reduction per doubling for Onshore Wind
i10LearningRate("PGAWNO") = 0.10;   !! 10% cost reduction per doubling for Offshore Wind
*---
*' Dynamically capture initial cost reference from PowerGeneration data
*' Use the base year costs as the reference point for learning curves
i10InitCostRefLC(allCy,LCTECH,YTIME)$TFIRST(YTIME) = i04GrossCapCosSubRen(allCy,LCTECH,YTIME);
*---