"""
Core preloop: PDL coefficients and variable initialisation/fixes.

WHAT "PRELOOP" MEANS (plain language):
  Before the solver runs, we set some variables to fixed numbers (e.g. historical
  demand in past years) so the model doesn't try to "solve" them. We also set
  bounds (e.g. "this variable must be >= 0"). This file does that for *core*
  variables; each module (Transport, Industry, RestOfEnergy) has its own preloop
  for its variables.

Mirrors core/preloop.gms. This module:
  1. Computes Polynomial Distribution Lag (PDL) coefficients imFPDL(DSBS, KPDL)
     used in demand equations for lagged price effects.
  2. Fixes core variables: VmRenValue (by year bands), VmElecConsHeatPla (0 for PoC),
     VmCarVal (exogenous carbon value or 0).

Does not set VmPriceFuelSubsecCarVal / VmPriceFuelAvgSub (handled by price stub)
or VmLft (handled in transport preloop).

Commented out in GAMS (core/preloop.gms): *VmRenValue.FX(YTIME)$(not AN(YTIME)) = 0;
*VmRenValue.FX(YTIME)$(AN(YTIME)) = 0;
"""
from typing import Any

from pyomo.core import ConcreteModel

from core import sets as core_sets

# Number of PDL terms per subsector (GAMS: iNPDL(DSBS) = 6)
I_NPDL = 6


def compute_pdl_coefficients() -> dict:
    """
    Compute Polynomial Distribution Lag coefficients imFPDL(DSBS, KPDL).

    Formula from GAMS preloop:
      imFPDL(DSBS,KPDL) = 6 * (iNPDL+1 - ord(KPDL)) * ord(KPDL)
                          / (iNPDL * (iNPDL+1) * (iNPDL+2))
    with iNPDL = 6 and KPDL = a1..a6 (ord = 1..6). These weights are used in
    demand equations to distribute lagged price elasticities over past years.
    """
    denom = I_NPDL * (I_NPDL + 1) * (I_NPDL + 2)
    out = {}
    for dsbs in core_sets.DSBS:
        for i, k in enumerate(core_sets.KPDL, start=1):
            if i <= I_NPDL:
                num = 6 * (I_NPDL + 1 - i) * i
                out[dsbs, k] = num / denom
    return out


def apply_core_preloop(
    m: ConcreteModel,
    core_sets_obj: core_sets.CoreSets,
    *,
    i_carb_val_yr_exog: Any = None,
) -> None:
    """
    Apply core preloop: set imFPDL, fix VmRenValue, VmElecConsHeatPla, VmCarVal.

    - imFPDL: filled from compute_pdl_coefficients().
    - VmRenValue: fixed by year index (ord < 20 -> 0; 20..49 -> ramp; >= 50 -> 2000).
    - VmElecConsHeatPla: fixed to 0 for PoC (full version would use heat pump share).
    - VmCarVal: fixed to i_carb_val_yr_exog(cy, y) if provided, else 0.

    i_carb_val_yr_exog: optional dict (cy, y) -> value for exogenous carbon price (US$2015/tCO2).
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    inddom = list(core_sets.INDDOM)
    nap = list(core_sets.NAP)

    # 1) PDL coefficients
    pdl = compute_pdl_coefficients()
    for (dsb, k), v in pdl.items():
        m.imFPDL[dsb, k] = v

    # 2) VmRenValue: fix by position in ytime (ord)
    for i, y in enumerate(ytime, start=1):
        if i < 20:
            m.VmRenValue[y].fix(0.0)
        elif i < 50:
            m.VmRenValue[y].fix((i - 20) * 100)
        else:
            m.VmRenValue[y].fix(2000.0)

    # 3) VmElecConsHeatPla: set to 0 for PoC (or from imFuelConsPerFueSub*(1-imShr...)*iShr... for INDDOM)
    for cy in run_cy:
        for sb in dsbs:
            for y in ytime:
                m.VmElecConsHeatPla[cy, sb, y].fix(0.0)

    # 4) VmCarVal: fix to exogenous carbon value or 0
    for cy in run_cy:
        for nap_ in nap:
            for y in ytime:
                if i_carb_val_yr_exog is not None and (cy, y) in i_carb_val_yr_exog:
                    m.VmCarVal[cy, nap_, y].fix(i_carb_val_yr_exog[cy, y])
                else:
                    m.VmCarVal[cy, nap_, y].fix(0.0)

    # 5) VmCstCO2SeqCsts, VmPriceElecInd: fix for historical years (Industry module)
    if hasattr(m, "VmCstCO2SeqCsts"):
        for cy in run_cy:
            for y in ytime:
                if y in core_sets_obj.datay:
                    m.VmCstCO2SeqCsts[cy, y].fix(1.0)
    if hasattr(m, "VmPriceElecInd"):
        for cy in run_cy:
            for y in ytime:
                if y in core_sets_obj.datay:
                    m.VmPriceElecInd[cy, y].fix(1.0)
