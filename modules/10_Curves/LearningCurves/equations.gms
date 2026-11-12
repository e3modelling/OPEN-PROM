*' @title Equations of OPEN-PROM's Learning Curves module
*' @code

*' GENERAL INFORMATION
*'
*' * Learning Curves module
*'
*' This module models experience-driven cost changes for technologies in LCTECH.
*' The learning exponent i10AlphaLC is typically derived from a learning rate as
*' log(1 - learning rate) / log(2). A negative exponent implies decreasing costs
*' when cumulative installed capacity grows.
*' The equations below calculate a period-to-period learning multiplier and
*' accumulate new electricity capacity globally. They do not themselves implement
*' a fixed-cost fraction, a minimum-cost floor, or a zero-denominator safeguard.

*' Calculate the learning-cost multiplier from the ratio of global cumulative
*' installed capacity in the previous two periods, raised to i10AlphaLC.
*' The multiplier for YTIME uses YTIME-1 relative to YTIME-2, so capacity
*' additions affect costs with a lag. Both capacity values must be nonzero
*' for the ratio to be well-defined; no epsilon is added in this equation.
Q10CostLC(LCTECH,YTIME)$(TIME(YTIME))..
    VmCostLC(LCTECH,YTIME)
        =E=
    (V10CumCapGlobal(LCTECH,YTIME-1) / (V10CumCapGlobal(LCTECH,YTIME-2))) ** i10AlphaLC(LCTECH);

*' Update global cumulative installed capacity for each learning technology.
*' Add current-period new electricity capacity across countries in runCy to
*' the previous period's cumulative capacity. The equation contains no explicit
*' MW-to-GW conversion; units follow those of V04NewCapElec and V10CumCapGlobal.
Q10CumCapGlobal(LCTECH,YTIME)$(TIME(YTIME))..
    V10CumCapGlobal(LCTECH,YTIME)
        =E=
    V10CumCapGlobal(LCTECH,YTIME-1) + 
    sum(allCy$(runCy(allCy)), V04NewCapElec(allCy,LCTECH,YTIME));
