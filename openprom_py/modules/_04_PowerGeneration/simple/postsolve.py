"""
04_PowerGeneration (simple) postsolve: fix solution values for the next time step.

Mirrors modules/04_PowerGeneration/simple/postsolve.gms. After each solve, fix
V04* and Vm* at the given year to their current solution for multi-year loop.
When calibration == MatCalibration, also fix i04MatFacPlaAvailCap (Var) to its .L.
"""
from pyomo.core import ConcreteModel, value

from core import sets as core_sets


def apply_power_generation_postsolve(
    m: ConcreteModel, core_sets_obj, year: int, config=None
) -> None:
    """Fix all 04 Power Generation variables at the given year to current solution.
    When config.calibration == 'MatCalibration', fix i04MatFacPlaAvailCap to solution."""
    run_cy = core_sets_obj.runCy
    pgall = list(core_sets.PGALL)
    calibration = getattr(config, "calibration", "off") if config else "off"

    def fix_var(var, idx):
        try:
            v = value(var[idx])
            if v is not None:
                var[idx].fix(v)
        except (TypeError, KeyError, ValueError):
            pass

    # GAMS calibration: i04MatFacPlaAvailCap.FX = .L after solve
    if calibration == "MatCalibration" and hasattr(m, "i04MatFacPlaAvailCap") and hasattr(m.i04MatFacPlaAvailCap, "fix"):
        for cy in run_cy:
            for pg in pgall:
                fix_var(m.i04MatFacPlaAvailCap, (cy, pg, year))

    for cy in run_cy:
        try:
            fix_var(m.VmCostPowGenAvgLng, (cy, year))
            fix_var(m.VmCapElecTotEst, (cy, year))
            fix_var(m.VmPeakLoad, (cy, year))
            fix_var(m.V04CapElecNonCHP, (cy, year))
            fix_var(m.V04ShareMixWndSol, (cy, year))
        except (AttributeError, TypeError):
            pass
        for pg in pgall:
            try:
                fix_var(m.V04CapOverall, (cy, pg, year))
                fix_var(m.V04IndxEndogScrap, (cy, pg, year))
                fix_var(m.VmCapElec, (cy, pg, year))
                fix_var(m.V04NewCapElec, (cy, pg, year))
                fix_var(m.V04NetNewCapElec, (cy, pg, year))
                fix_var(m.V04CFAvgRen, (cy, pg, year))
                fix_var(m.V04CapElecNominal, (cy, pg, year))
                fix_var(m.V04CapexFixCostPG, (cy, pg, year))
                fix_var(m.V04CapexRESRate, (cy, pg, year))
                fix_var(m.V04ShareTechPG, (cy, pg, year))
                fix_var(m.V04ShareSatPG, (cy, pg, year))
                fix_var(m.V04CostHourProdInvDec, (cy, pg, year))
            except (AttributeError, TypeError):
                pass
