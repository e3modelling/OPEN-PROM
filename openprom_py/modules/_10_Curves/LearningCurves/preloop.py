"""
Module 10_Curves (LearningCurves): preloop — bounds and fix historical values.

Mirrors modules/10_Curves/LearningCurves/preloop.gms:
  VmCostLC.LO=0.1, .UP=2, .FX(LCTECH, baseY)=1.
  V10CumCapGlobal.FX(LCTECH, 2010..baseY) from imInstCapPastNonCHP cumulative sum.
"""
from pyomo.core import ConcreteModel, value as pyo_value
from core import sets as core_sets


def apply_curves_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """Set bounds on VmCostLC; fix VmCostLC at base year = 1; fix V10CumCapGlobal for historical years from imInstCapPastNonCHP."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))
    t_first = getattr(core_sets_obj, "tFirst", None)
    if t_first and hasattr(t_first, "__iter__") and not isinstance(t_first, (str, int)):
        base_y = next(iter(t_first), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None

    for lc in lctech:
        for y in ytime:
            if hasattr(m, "VmCostLC"):
                m.VmCostLC[lc, y].setlb(0.1)
                m.VmCostLC[lc, y].setub(2.0)
                if y == base_y:
                    m.VmCostLC[lc, y].fix(1.0)

    # V10CumCapGlobal.FX from 2010 to baseY: cumulative sum of imInstCapPastNonCHP over runCy
    if not hasattr(m, "V10CumCapGlobal") or not hasattr(m, "imInstCapPastNonCHP"):
        return
    hist_years = [y for y in ytime if isinstance(y, int) and 2010 <= y <= (base_y if base_y else 2023)]
    cum = {lc: 0.0 for lc in lctech}
    for y in sorted(hist_years):
        for lc in lctech:
            add = 0.0
            for cy in run_cy:
                try:
                    add += pyo_value(m.imInstCapPastNonCHP[cy, lc, y])
                except Exception:
                    pass
            cum[lc] = cum[lc] + add
            try:
                m.V10CumCapGlobal[lc, y].fix(cum[lc])
            except Exception:
                pass
