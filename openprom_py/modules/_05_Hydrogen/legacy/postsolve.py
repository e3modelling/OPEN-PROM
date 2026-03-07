"""
05_Hydrogen (legacy) postsolve: fix solution values for the next time step.

Mirrors modules/05_Hydrogen/legacy/postsolve.gms. Fix VmConsFuelTechH2Prod, V05GapShareH2Tech1,
VmProdH2, V05DemGapH2, VmCostAvgProdH2, V05CaptRateH2 at the given year.
"""
from pyomo.core import ConcreteModel, value

from core import sets as core_sets

# --- GAMS postsolve.gms commented-out, transferred as comment ---
# *V05DelivH2InfrTech.FX(runCyL,INFRTECH,YTIME)$TIME(YTIME) = V05DelivH2InfrTech.L(runCyL,INFRTECH,YTIME)$TIME(YTIME);


def apply_hydrogen_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix 05 Hydrogen variables at the given year to current solution."""
    run_cy = core_sets_obj.runCy
    h2tech = list(core_sets.H2TECH)
    ef_list = list(core_sets.EF)

    def fix_var(var, idx):
        try:
            v = value(var[idx])
            if v is not None:
                var[idx].fix(v)
        except (TypeError, KeyError, ValueError):
            pass

    for cy in run_cy:
        try:
            fix_var(m.V05DemGapH2, (cy, year))
            fix_var(m.VmCostAvgProdH2, (cy, year))
        except (AttributeError, TypeError):
            pass
        for ht in h2tech:
            try:
                fix_var(m.V05GapShareH2Tech1, (cy, ht, year))
                fix_var(m.VmProdH2, (cy, ht, year))
                fix_var(m.V05CaptRateH2, (cy, ht, year))
            except (AttributeError, TypeError):
                pass
        for ht in h2tech:
            for ef_ in ef_list:
                try:
                    fix_var(m.VmConsFuelTechH2Prod, (cy, ht, ef_, year))
                except (AttributeError, TypeError):
                    pass
