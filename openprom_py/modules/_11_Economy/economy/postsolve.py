"""
Module 11_Economy (economy): postsolve — fix solved values for next time step.

Mirrors modules/11_Economy/economy/postsolve.gms:
  V11SubsiTot.FX(runCyL,YTIME)$TIME = V11SubsiTot.L(...)
  VmNetSubsiTax.FX(...) = VmNetSubsiTax.L(...)
"""
from pyomo.core import ConcreteModel, value as pyo_value


def apply_economy_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix current year solution for economy variables."""
    run_cy = core_sets_obj.runCyL if hasattr(core_sets_obj, "runCyL") else core_sets_obj.runCy
    for cy in run_cy:
        if hasattr(m, "V11SubsiTot") and (cy, year) in m.V11SubsiTot:
            m.V11SubsiTot[cy, year].fix(pyo_value(m.V11SubsiTot[cy, year]))
        if hasattr(m, "VmNetSubsiTax") and (cy, year) in m.VmNetSubsiTax:
            m.VmNetSubsiTax[cy, year].fix(pyo_value(m.VmNetSubsiTax[cy, year]))
