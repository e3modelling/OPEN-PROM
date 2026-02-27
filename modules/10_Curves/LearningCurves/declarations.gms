*' @title Learning Curves module Declarations
*' @code

Equations
Q10CostLC(LCTECH,YTIME)             "Learning curve cost multiplier calculation"
Q10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity calculation"
*' --- Regional learning-by-searching (R&D) block ---
*' Q10RDFundPrivate: creates private R&D flow (exo path, switchable on/off).
*' Q10RDFundState  : creates state R&D flow (linked to subsidy stream or exogenous fallback).
*' Q10RDStock      : accumulates region-tech knowledge stock with depreciation.
*' Q10CostRD       : transforms knowledge-stock growth into a period multiplier.
*' These equations are intentionally separate from Q10CostLC/Q10CumCapGlobal
*' to keep global learning-by-doing and regional learning-by-searching modular.
Q10RDFundPrivate(allCy,RDTECH,YTIME) "Private R&D funding definition"
Q10RDFundState(allCy,RDTECH,YTIME)   "State R&D funding definition"
Q10RDStock(allCy,RDTECH,YTIME)       "Regional R&D knowledge stock accumulation"
Q10CostRD(allCy,RDTECH,YTIME)        "Regional R&D cost multiplier calculation"
Q10CoreGrossCapDAC(DACTECH,YTIME)   "Core DAC CAPEX learning term"
Q10CoreFixOandMDAC(DACTECH,YTIME)   "Core DAC fixed O&M learning term"
Q10CoreVarCostDAC(DACTECH,YTIME)    "Core DAC variable cost learning term"

;

Variables
VmCostLC(LCTECH,YTIME)             "Learning curve cost multiplier (1)"
V10CumCapGlobal(LCTECH,YTIME)       "Global cumulative capacity (GW)"
*' --- Regional learning-by-searching state variables ---
*' V10RDStock      : dynamic knowledge stock K(c,i,t) used by the R&D learning equation.
*' V10RDFundState  : endogenous state R&D flow entering knowledge stock recursion.
*' V10RDFundPrivate: optional private R&D flow entering knowledge stock recursion.
*' V10CostRD       : regional R&D multiplier, combined multiplicatively with VmCostLC
*'                   in CAPEX/LCOC equations where applicable.
V10RDStock(allCy,RDTECH,YTIME)       "Regional R&D knowledge stock"
V10RDFundState(allCy,RDTECH,YTIME)   "State R&D funding"
V10RDFundPrivate(allCy,RDTECH,YTIME) "Private R&D funding"
V10CostRD(allCy,RDTECH,YTIME)        "Regional R&D learning cost multiplier (1)"
V10CoreGrossCapDAC(DACTECH,YTIME)   "Core DAC CAPEX learning term ($/tCO2)"
V10CoreFixOandMDAC(DACTECH,YTIME)   "Core DAC fixed O&M learning term ($/tCO2)"
V10CoreVarCostDAC(DACTECH,YTIME)    "Core DAC variable cost learning term ($/tCO2)"

;
