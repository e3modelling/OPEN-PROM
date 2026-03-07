"""
Module 10_Curves (LearningCurves): declarations (parameters and variables).

Mirrors modules/10_Curves/LearningCurves/declarations.gms.
Equations: Q10CostLC(LCTECH,YTIME), Q10CumCapGlobal(LCTECH,YTIME).
Variables: VmCostLC(LCTECH,YTIME), V10CumCapGlobal(LCTECH,YTIME).
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_curves_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """Add 10_Curves (LearningCurves) parameters. Filled from input_loader."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))

    m.i10AlphaLC = Param(lctech, mutable=True, default=-0.32, initialize={})
    m.i10LearningRate = Param(lctech, mutable=True, default=0.2, initialize={})
    m.i10InitCostRefLC = Param(run_cy, lctech, ytime, mutable=True, default=1.0, initialize={})
    m.i10LearnableFraction = Param(lctech, mutable=True, default=0.7, initialize={})
    m.i10MinCostFraction = Param(lctech, mutable=True, default=0.3, initialize={})


def add_curves_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 10_Curves (LearningCurves) variables. GAMS: VmCostLC(LCTECH,YTIME), V10CumCapGlobal(LCTECH,YTIME) — global, no country index."""
    ytime = core_sets_obj.ytime
    lctech = list(getattr(core_sets, "LCTECH", core_sets.PGRENSW))

    m.VmCostLC = Var(lctech, ytime, domain=Reals, bounds=(0.1, 2.0), initialize=1.0)
    m.V10CumCapGlobal = Var(lctech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
