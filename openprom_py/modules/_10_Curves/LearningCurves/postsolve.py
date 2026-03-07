"""
Module 10_Curves (LearningCurves): postsolve.

Mirrors modules/10_Curves/LearningCurves/postsolve.gms — file has only header comment, no fix statements.
* Learning Curves Module (no variable fixes for next time step in GAMS).
"""
from pyomo.core import ConcreteModel


def apply_curves_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """No fixes in GAMS postsolve for 10_Curves; leave as no-op."""
    pass
