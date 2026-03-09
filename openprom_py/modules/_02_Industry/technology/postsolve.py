"""
Industry (technology) postsolve: fix solution values for the next time step.

Mirrors 02_Industry/technology/postsolve.gms. After each solve for a given year,
fix all Industry variables (V02*, VmConsFuel) at that year to their current
solution so that in a multi-year loop the next solve sees the previous year as fixed.
In calibration mode GAMS also fixes imMatrFactor to its .L; this is handled by
apply_imMatrFactor_postsolve() in core/equations.py (called from run_poc.py).
"""
from pyomo.core import ConcreteModel, value

from core import sets as core_sets


def apply_industry_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """
    Fix all Industry (V02*) and VmConsFuel variables at the given year to their
    current solution.

    Call after each successful solve for `year` so that when solving the next year,
    the solution at `year` is preserved as fixed. Mirrors GAMS:
    Var.FX(runCyL,...,YTIME)$TIME(YTIME) = Var.L(...).
    """
    run_cy = core_sets_obj.runCy
    dsbs = list(core_sets.DSBS)
    itech = list(core_sets.ITECH)
    inddom = list(core_sets.INDDOM)
    ef = list(core_sets.EF)

    def fix_var(var, idx):
        try:
            v = value(var[idx])
            if v is not None:
                var[idx].fix(v)
        except (TypeError, KeyError, ValueError):
            pass

    for cy in run_cy:
        if hasattr(m, "V02DemSubUsefulSubsec"):
            for ds in dsbs:
                fix_var(m.V02DemSubUsefulSubsec, (cy, ds, year))
        if hasattr(m, "V02RemEquipCapTechSubsec"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02RemEquipCapTechSubsec, (cy, ds, tech, year))
        if hasattr(m, "V02DemUsefulSubsecRemTech"):
            for ds in dsbs:
                fix_var(m.V02DemUsefulSubsecRemTech, (cy, ds, year))
        if hasattr(m, "V02GapUsefulDemSubsec"):
            for ds in dsbs:
                fix_var(m.V02GapUsefulDemSubsec, (cy, ds, year))
        if hasattr(m, "V02CapCostTech"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02CapCostTech, (cy, ds, tech, year))
        if hasattr(m, "V02VarCostTech"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02VarCostTech, (cy, ds, tech, year))
        if hasattr(m, "V02CostTech"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02CostTech, (cy, ds, tech, year))
        if hasattr(m, "V02ShareTechNewEquipUseful"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02ShareTechNewEquipUseful, (cy, ds, tech, year))
        if hasattr(m, "V02EquipCapTechSubsec"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02EquipCapTechSubsec, (cy, ds, tech, year))
        if hasattr(m, "V02UsefulElecNonSubIndTert"):
            for ds in inddom:
                fix_var(m.V02UsefulElecNonSubIndTert, (cy, ds, year))
        if hasattr(m, "V02FinalElecNonSubIndTert"):
            for ds in inddom:
                fix_var(m.V02FinalElecNonSubIndTert, (cy, ds, year))
        if hasattr(m, "VmConsFuel"):
            for ds in dsbs:
                for e in ef:
                    fix_var(m.VmConsFuel, (cy, ds, e, year))
        if hasattr(m, "V02IndxElecIndPrices"):
            fix_var(m.V02IndxElecIndPrices, (cy, year))
        if hasattr(m, "V02PremScrpIndu"):
            for ds in dsbs:
                for tech in itech:
                    fix_var(m.V02PremScrpIndu, (cy, ds, tech, year))

    # GAMS $ifthen.calib %Calibration% == MatCalibration: imMatrFactor.FX(...) = imMatrFactor.L(...)
    # Handled centrally by apply_imMatrFactor_postsolve() in core/equations.py.
