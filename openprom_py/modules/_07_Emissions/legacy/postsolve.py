"""
Module 07_Emissions (legacy): postsolve — fix solved values for next time step.

Mirrors modules/07_Emissions/legacy/postsolve.gms:
  V07GrossEmissCO2Supply.FX(runCyL,SSBS,YTIME)$TIME(YTIME) = V07GrossEmissCO2Supply.L(...);
So the current year's solution is fixed for use in the following year's solve.
"""
from pyomo.core import ConcreteModel

from core import sets as core_sets


def apply_emissions_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """
    Fix V07GrossEmissCO2Supply at the given year to its current solution value.
    Called after each year solve so that the next iteration uses this fixed value.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = getattr(core_sets_obj, "time", set(ytime))
    if year not in time_set:
        return
    if not hasattr(m, "V07GrossEmissCO2Supply"):
        return
    ssbs = list(core_sets.SSBS)
    for cy in run_cy:
        for ss in ssbs:
            try:
                var = m.V07GrossEmissCO2Supply[cy, ss, year]
                val = var.value
                if val is not None:
                    var.fix(float(val))
            except (KeyError, TypeError, AttributeError):
                pass
