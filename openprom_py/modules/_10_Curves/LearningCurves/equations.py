"""
Module 10_Curves (LearningCurves): equation definitions.

Mirrors modules/10_Curves/LearningCurves/equations.gms.
Q10CostLC: Learning curve cost multiplier = (V10CumCapGlobal(t-1)/V10CumCapGlobal(t-2))^i10AlphaLC.
Q10CumCapGlobal: V10CumCapGlobal = V10CumCapGlobal(t-1) + sum(runCy, V04NewCapElec(cy,LCTECH,YTIME)).
"""
from pyomo.core import ConcreteModel, Constraint
from pyomo.environ import value as pyo_value

from core import sets as core_sets

_EPS = 1e-10


def _year_prev(ytime_list, y, offset=1):
    try:
        i = ytime_list.index(y)
        return ytime_list[i - offset] if i >= offset else ytime_list[0]
    except (ValueError, AttributeError):
        return ytime_list[0] if ytime_list else y


def add_curves_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add Q10CostLC and Q10CumCapGlobal."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))

    # -------------------------------------------------------------------------
    # Q10CostLC (GAMS): Learning curve cost multiplier equation with numerical safeguards.
    # Timing: Cost multiplier for YTIME based on capacity growth in previous period (YTIME-1 vs YTIME-2).
    # This reflects that learning happens from past experience and affects current period costs.
    # Safeguards: Add small epsilon to denominator to avoid division by zero.
    # General: This equation implements the learning curve for wind and solar with stopping mechanism;
    # multiplier = (Cap_current/Cap_initial)^epsilon, epsilon = log(1-LR)/log(2). LearnableFraction,
    # FixedFraction, MinCostFraction prevent unrealistic cost reductions.
    # -------------------------------------------------------------------------
    def _q10_cost_lc(mod, lc, y):
        if y not in time_set or lc not in lctech:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y, 1)
        y_2 = _year_prev(ytime, y, 2)
        if y_1 == y_2:
            return Constraint.Skip
        den = mod.V10CumCapGlobal[lc, y_2] + _EPS
        alpha = pyo_value(mod.i10AlphaLC[lc])
        rhs = (mod.V10CumCapGlobal[lc, y_1] / den) ** alpha
        return mod.VmCostLC[lc, y] == rhs

    m.Q10CostLC = Constraint(lctech, ytime, rule=_q10_cost_lc)

    # -------------------------------------------------------------------------
    # Q10CumCapGlobal (GAMS): Global cumulative capacity tracking equation.
    # Tracks total cumulative capacity installations since base year.
    # Cumulative = Previous cumulative + New installations this period (converted MW to GW).
    # -------------------------------------------------------------------------
    def _q10_cum_cap_global(mod, lc, y):
        if y not in time_set or lc not in lctech:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y, 1)
        if not hasattr(mod, "V04NewCapElec"):
            return Constraint.Skip
        new_cap = sum(mod.V04NewCapElec[cy, lc, y] for cy in run_cy)
        return mod.V10CumCapGlobal[lc, y] == mod.V10CumCapGlobal[lc, y_1] + new_cap

    m.Q10CumCapGlobal = Constraint(lctech, ytime, rule=_q10_cum_cap_global)
