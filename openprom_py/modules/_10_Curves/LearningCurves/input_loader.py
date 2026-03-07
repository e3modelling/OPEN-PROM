"""
Module 10_Curves (LearningCurves): load input and derive parameters.

Mirrors modules/10_Curves/LearningCurves/input.gms.
i10LearningRate, i10LearnableFraction, i10MinCostFraction defaults; i10AlphaLC = -log(1-LR)/log(2);
i10InitCostRefLC from i04GrossCapCosSubRen for TFIRST (base year).
"""
from pathlib import Path
from typing import Any, Dict
import math
from pyomo.core import ConcreteModel, value as pyo_value
from core import sets as core_sets


def load_curves_data(config: Any) -> Dict[str, Any]:
    """No CSV in GAMS for 10_Curves; params set in code. Return empty dict or any optional data."""
    return {}


def load_curves_data_into_model(m: ConcreteModel, data: Dict[str, Any], core_sets_obj: Any) -> None:
    """Set i10LearningRate, i10LearnableFraction, i10MinCostFraction defaults; compute i10AlphaLC; i10InitCostRefLC from i04GrossCapCosSubRen for base year."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))
    t_first = getattr(core_sets_obj, "tFirst", None)
    if t_first and hasattr(t_first, "__iter__") and not isinstance(t_first, (str, int)):
        base_y = next(iter(t_first), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None

    # i10LearningRate defaults (GAMS)
    if hasattr(m, "i10LearningRate"):
        m.i10LearningRate["PGSOL"].set_value(0.20)
        m.i10LearningRate["PGCSP"].set_value(0.20)
        m.i10LearningRate["PGAWND"].set_value(0.10)
        m.i10LearningRate["PGAWNO"].set_value(0.10)
    # i10LearnableFraction
    if hasattr(m, "i10LearnableFraction"):
        m.i10LearnableFraction["PGSOL"].set_value(0.75)
        m.i10LearnableFraction["PGCSP"].set_value(0.75)
        m.i10LearnableFraction["PGAWND"].set_value(0.60)
        m.i10LearnableFraction["PGAWNO"].set_value(0.60)
    # i10MinCostFraction
    if hasattr(m, "i10MinCostFraction"):
        m.i10MinCostFraction["PGSOL"].set_value(0.25)
        m.i10MinCostFraction["PGCSP"].set_value(0.25)
        m.i10MinCostFraction["PGAWND"].set_value(0.40)
        m.i10MinCostFraction["PGAWNO"].set_value(0.40)
    # i10AlphaLC = -log(1 - i10LearningRate) / log(2)
    if hasattr(m, "i10AlphaLC"):
        for lc in lctech:
            lr = pyo_value(m.i10LearningRate[lc]) if hasattr(m, "i10LearningRate") else 0.2
            m.i10AlphaLC[lc].set_value(-math.log(1.0 - lr + 1e-12) / math.log(2.0))
    # i10InitCostRefLC(allCy, LCTECH, YTIME)$TFIRST(YTIME) = i04GrossCapCosSubRen(allCy, LCTECH, YTIME)
    if base_y and hasattr(m, "i10InitCostRefLC") and hasattr(m, "i04GrossCapCosSubRen"):
        for cy in run_cy:
            for lc in lctech:
                try:
                    m.i10InitCostRefLC[cy, lc, base_y] = pyo_value(m.i04GrossCapCosSubRen[cy, lc, base_y])
                except Exception:
                    pass
