"""
Module 06_CO2 (legacy): postsolve – fix current year solution for next time step.

Mirrors modules/06_CO2/legacy/postsolve.gms. Fix V06CapCO2ElecHydr, V06CaptCummCO2,
V06CapCDR, V06LvlCostDAC, V06CapFacNewDAC to their solution values for the given year.

"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets

# --- GAMS postsolve.gms $ontext ... $offtext (commented out in GAMS), transferred as comments ---
# $ontext
# V06GrossCapDAC.FX(DACTECH,YTIME)$TIME(YTIME) = V06GrossCapDAC.L(DACTECH,YTIME)$TIME(YTIME);
# V06FixOandMDAC.FX(DACTECH,YTIME)$TIME(YTIME) = V06FixOandMDAC.L(DACTECH,YTIME)$TIME(YTIME);
# V06VarCostDAC.FX(DACTECH,YTIME)$TIME(YTIME) = V06VarCostDAC.L(DACTECH,YTIME)$TIME(YTIME);
# $offtext


def _fix_var(var, idx):
    """Fix variable at index to its current value."""
    try:
        v = pyo_value(var[idx])
        if v is not None:
            var[idx].fix(v)
    except (KeyError, TypeError):
        pass


def apply_co2_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix 06_CO2 variables for the given year to their solution values."""
    run_cy = core_sets_obj.runCy
    sbs = list(core_sets.SBS)
    cdrtech = list(core_sets.CDRTECH)

    for cy in run_cy:
        for sb in sbs:
            if hasattr(m, "V06CapCO2ElecHydr"):
                _fix_var(m.V06CapCO2ElecHydr, (cy, sb, year))
        if hasattr(m, "V06CaptCummCO2"):
            _fix_var(m.V06CaptCummCO2, (cy, year))
        for tech in cdrtech:
            if hasattr(m, "V06CapCDR"):
                _fix_var(m.V06CapCDR, (cy, tech, year))
            if hasattr(m, "V06LvlCostDAC"):
                _fix_var(m.V06LvlCostDAC, (cy, tech, year))
            if hasattr(m, "V06CapFacNewDAC"):
                _fix_var(m.V06CapFacNewDAC, (cy, tech, year))
