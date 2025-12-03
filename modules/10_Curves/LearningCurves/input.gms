*' @title Learning Curves Inputs
*' @code
*' This file contains minimal input data required for the Learning Curves module.
*' Most cost data comes from existing PowerGeneration module inputs.

Parameters
i10AlphaLC(LCTECH)                  "Learning curve factor alpha for technology (1)"
i10LearningRate(LCTECH)             "Learning rate for technology (1)" 
i10InitCapGlobal(LCTECH)            "Initial global cumulative capacity for technology (GW)"
;
*---
i10LearningRate("PGSOL") = 0.20;    !! 20% cost reduction per doubling for Solar PV
i10LearningRate("PGCSP") = 0.20;    !! 20% cost reduction per doubling for CSP
i10LearningRate("PGAWND") = 0.10;   !! 10% cost reduction per doubling for Onshore Wind
i10LearningRate("PGAWNO") = 0.10;   !! 10% cost reduction per doubling for Offshore Wind
*---
*' Approximate 2020 global capacities (GW)
i10InitCapGlobal("PGSOL") = 500;    !! Global Solar PV capacity ~500 GW
i10InitCapGlobal("PGCSP") = 50;     !! Global CSP capacity ~50 GW
i10InitCapGlobal("PGAWND") = 400;   !! Global Onshore Wind capacity ~400 GW
i10InitCapGlobal("PGAWNO") = 30;    !! Global Offshore Wind capacity ~30 GW
*---