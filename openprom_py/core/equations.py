"""
Core equations: dummy objective function.

GAMS (core/equations.gms):
  - When Calibration is off: qDummyObj.. vDummyObj =e= 1.
  - When Calibration == MatCalibration: qDummyObj is a sum of squares of
    (V04SharePowPlaNewEq - t04SharePowPlaNewEq) and (V01ShareTechTr - t01NewShareStockPC),
    and qRestrain ties imMatrFactor to common() for negative targets.

We implement only the non-calibration case: constraint vDummyObj == 1 and
objective minimize vDummyObj, so the single feasible value is 1.
"""
from pyomo.core import ConcreteModel, Constraint, Objective, minimize

from core import sets as core_sets


def add_core_objective(m: ConcreteModel, calibration: str = "off") -> None:
    """
    Add objective: minimize vDummyObj.
    For calibration mode (MatCalibration) we would add a sum-of-squares objective
    over power and transport shares; for PoC we use simple min vDummyObj.
    """
    m.obj = Objective(expr=m.vDummyObj, sense=minimize)


def add_q_dummy_obj_constraint(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add constraint qDummyObj: vDummyObj == 1.

    In GAMS with calibration off, the equation is qDummyObj.. vDummyObj =e= 1.
    Without this constraint, minimizing vDummyObj would drive it to -inf;
    with it, the model has a well-defined target and other constraints
    (from transport, etc.) determine the rest of the solution.
    """
    m.qDummyObj = Constraint(expr=m.vDummyObj == 1)
