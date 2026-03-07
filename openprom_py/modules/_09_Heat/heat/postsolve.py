"""
Module 09_Heat (heat): postsolve — fix solved values for the next time step.

Mirrors modules/09_Heat/heat/postsolve.gms:
  VmProdSte.FX(runCyL,TSTEAM,YTIME)$TIME = VmProdSte.L(...)
  V09CostProdSte.FX(...) = V09CostProdSte.L(...)
  VmConsFuelSteProd.FX(...) = VmConsFuelSteProd.L(...)
* V09CostElecProdCHP, VmCostElcAvgProdCHP, VmCostAvgProdSte [commented in GAMS]
"""
from pyomo.core import ConcreteModel, value as pyo_value


def apply_heat_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix current year solution for heat variables so next iteration uses them."""
    run_cy = core_sets_obj.runCyL if hasattr(core_sets_obj, "runCyL") else core_sets_obj.runCy
    for cy in run_cy:
        if hasattr(m, "VmProdSte"):
            for key in m.VmProdSte:
                if key[2] == year:
                    m.VmProdSte[key].fix(pyo_value(m.VmProdSte[key]))
        if hasattr(m, "V09CostProdSte"):
            for key in m.V09CostProdSte:
                if key[2] == year:
                    m.V09CostProdSte[key].fix(pyo_value(m.V09CostProdSte[key]))
        if hasattr(m, "VmConsFuelSteProd"):
            for key in m.VmConsFuelSteProd:
                if key[3] == year:
                    m.VmConsFuelSteProd[key].fix(pyo_value(m.VmConsFuelSteProd[key]))
