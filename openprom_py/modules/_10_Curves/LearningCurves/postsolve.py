"""
Module 10_Curves (LearningCurves): postsolve.

Mirrors core/postsolve.gms (outside the countries loop, inside the year loop):
  V10CumCapGlobal.FX(LCTECH,YTIME)$TIME(YTIME) = V10CumCapGlobal.L(LCTECH,YTIME)$TIME(YTIME);

This fixes the solved cumulative global capacity at the current year so that
the next time step's Q10CumCapGlobal and Q10CostLC equations use the correct
lagged value.
"""
import logging

from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets

logger = logging.getLogger(__name__)


def apply_curves_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix V10CumCapGlobal at solved value for the current year.

    After all countries are solved for ``year``, lock V10CumCapGlobal(LCTECH, year)
    to its .L so the next year's equations see the correct cumulative capacity.
    """
    if not hasattr(m, "V10CumCapGlobal"):
        return
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))
    fixed_count = 0
    for lc in lctech:
        try:
            v = m.V10CumCapGlobal[lc, year]
            solved_val = pyo_value(v)
            if solved_val is not None:
                v.fix(solved_val)
                fixed_count += 1
        except (KeyError, TypeError) as exc:
            logger.debug("V10CumCapGlobal[%s, %s] skip: %s", lc, year, exc)
    if fixed_count:
        logger.debug("Curves postsolve: fixed V10CumCapGlobal for %d techs at year %s", fixed_count, year)
