*' @title Learning Curves Inputs
*' @code
*' This file contains input data for the Learning Curves module.
*' 
*' COST BREAKDOWN METHODOLOGY:
*' Total cost is split into two components:
*' 1. Learnable fraction: Subject to learning curve cost reductions (technology/manufacturing costs)
*' 2. Fixed fraction: Not affected by learning (materials, labor, grid connection, etc.)
*' 
*' Formula: FinalCost = LearnableFraction × CostMultiplier × InitialCost + (1-LearnableFraction) × InitialCost
*'          Simplified: FinalCost = [LearnableFraction × CostMultiplier + (1-LearnableFraction)] × InitialCost
*'
*' This prevents unrealistic cost reductions while maintaining learning benefits.

Parameters
i10AlphaLC(LCTECH)                  "Learning curve factor alpha for technology (1)"
i10LearningRate(LCTECH)             "Learning rate for technology (1)" 
i10InitCostRefLC(allCy,LCTECH,YTIME) "Initial cost reference for learning curves from PowerGeneration (kUS$2015/KW)"
i10LearnableFraction(LCTECH)        "Fraction of cost subject to learning curve (1)"
i10MinCostFraction(LCTECH)          "Minimum cost as fraction of initial cost (1)"
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
*' Learnable fraction - what portion of total cost can be reduced by learning
*' Typically manufacturing/technology costs (~60-80%) vs. fixed costs (materials, labor, grid connection)
i10LearnableFraction("PGSOL") = 0.70;   !! 70% of solar PV costs subject to learning
i10LearnableFraction("PGCSP") = 0.65;   !! 65% of CSP costs subject to learning  
i10LearnableFraction("PGAWND") = 0.60;  !! 60% of onshore wind costs subject to learning
i10LearnableFraction("PGAWNO") = 0.60;  !! 60% of offshore wind costs subject to learning
*---
*' Minimum cost floor - prevents unrealistic cost reductions
*' Based on fundamental material and labor costs that cannot be reduced indefinitely
i10MinCostFraction("PGSOL") = 0.30;     !! Solar PV cannot go below 30% of initial cost
i10MinCostFraction("PGCSP") = 0.35;     !! CSP cannot go below 35% of initial cost
i10MinCostFraction("PGAWND") = 0.40;    !! Onshore wind cannot go below 40% of initial cost  
i10MinCostFraction("PGAWNO") = 0.40;    !! Offshore wind cannot go below 40% of initial cost
*---
*' Dynamically capture initial cost reference from PowerGeneration data
*' Use the base year costs as the reference point for learning curves
i10InitCostRefLC(allCy,LCTECH,YTIME)$TFIRST(YTIME) = i04GrossCapCosSubRen(allCy,LCTECH,YTIME);
*---