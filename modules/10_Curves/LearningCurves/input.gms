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
i10AlphaLC(LCTECH)                    "Learning curve factor alpha for technology (1)"
i10LearningRate(LCTECH)               "Learning rate for technology (1)" 
i10InitCostRefLC(allCy,LCTECH,YTIME)  "Initial cost reference for learning curves from PowerGeneration (kUS$2015/KW)"
i10LearnableFraction(LCTECH)          "Fraction of cost subject to learning curve (1)"
i10MinCostFraction(LCTECH)            "Minimum cost as fraction of initial cost (1)"
i10KnowDep(RDTECH)                    "Regional R&D knowledge depreciation rate (1)"
i10RDLearningRate(RDTECH)             "R&D learning rate for technology (1)"
i10BetaRD(RDTECH)                     "R&D curve exponent from learning rate (1)"
i10RDFundPrivate_exo(allCy,RDTECH,YTIME) "Exogenous private R&D funding"
i10RDFundState_exo(allCy,RDTECH,YTIME)   "Exogenous state R&D funding when not linked to subsidies"
;
*---
i10LearningRate("PGSOL") = 0.20;    !! 20% cost reduction per doubling for Solar PV
i10LearningRate("PGCSP") = 0.20;    !! 20% cost reduction per doubling for CSP
i10LearningRate("PGAWND") = 0.10;   !! 10% cost reduction per doubling for Onshore Wind
i10LearningRate("PGAWNO") = 0.10;   !! 10% cost reduction per doubling for Offshore Wind
*---
*' Learnable fraction - what portion of total cost can be reduced by learning
*' Typically manufacturing/technology costs (~60-80%) vs. fixed costs (materials, labor, grid connection)
i10LearnableFraction("PGSOL") = 0.75;   !! 75% of solar PV costs subject to learning
i10LearnableFraction("PGCSP") = 0.75;   !! 75% of CSP costs subject to learning  
i10LearnableFraction("PGAWND") = 0.60;  !! 60% of onshore wind costs subject to learning
i10LearnableFraction("PGAWNO") = 0.60;  !! 60% of offshore wind costs subject to learning
*---
*' Minimum cost floor - prevents unrealistic cost reductions
*' Based on fundamental material and labor costs that cannot be reduced indefinitely
i10MinCostFraction("PGSOL") = 0.25;     !! Solar PV cannot go below 25% of initial cost
i10MinCostFraction("PGCSP") = 0.25;     !! CSP cannot go below 25% of initial cost
i10MinCostFraction("PGAWND") = 0.40;    !! Onshore wind cannot go below 40% of initial cost  
i10MinCostFraction("PGAWNO") = 0.40;    !! Offshore wind cannot go below 40% of initial cost
*---
*' R&D stock depreciation.
*' Interpretation: each period, a fraction of the accumulated knowledge stock becomes obsolete.
*' This avoids perpetual accumulation without attrition and keeps long-run dynamics realistic.
i10KnowDep(RDTECH) = 0.07;

*' Default R&D learning rates are set to zero.
*' Reason: preserve baseline behavior and avoid double counting against already-calibrated
*' deployment learning for mature technologies unless an explicit scenario turns this on.
i10RDLearningRate(RDTECH) = 0;

*' Default exogenous R&D inflows are zero.
*' If switches are enabled, these are the immediate scenario entry points:
*' - i10RDFundPrivate_exo is used when %EnablePrivateRD% == YES.
*' - i10RDFundState_exo is used when %RDLinkToSubsidies% != YES.
i10RDFundPrivate_exo(allCy,RDTECH,YTIME) = 0;
i10RDFundState_exo(allCy,RDTECH,YTIME) = 0;
*---
*' Use the base year costs as the reference point for learning curves
i10InitCostRefLC(allCy,LCTECH,YTIME)$TFIRST(YTIME) = i04GrossCapCosSubRen(allCy,LCTECH,YTIME);
*---
*' Calculate learning curve parameters from learning rates
*' With C(t) = (Cap(t)/Cap(t-1))^ε and LR = 1 - 2^(-ε)
*' Solving for ε: ε = -log(1-LR) / log(2) (negative for cost reduction)
i10AlphaLC(LCTECH) = -log(1 - i10LearningRate(LCTECH)) / log(2);

*' Convert R&D learning rates to exponent form used in ratio multiplier equations.
*' Same transformation style as i10AlphaLC to keep interpretation consistent across
*' learning-by-doing and learning-by-searching blocks.
i10BetaRD(RDTECH) = -log(1 - i10RDLearningRate(RDTECH)) / log(2);
*---