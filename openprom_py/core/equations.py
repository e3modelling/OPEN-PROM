"""
Core equations: dummy objective function with calibration support.

GAMS (core/equations.gms):
  - When Calibration is off: qDummyObj.. vDummyObj =e= 1.
  - When Calibration == MatCalibration: qDummyObj is a sum of squares of
    (V04SharePowPlaNewEq - t04SharePowPlaNewEq) and (V01ShareTechTr - t01NewShareStockPC),
    and qRestrain ties imMatrFactor to common() for negative targets.

Both branches are implemented below, selected by the ``calibration`` argument.
"""
import logging

from pyomo.core import ConcreteModel, Constraint, Objective, minimize
from pyomo.environ import value as pyo_value

from core import sets as core_sets

logger = logging.getLogger(__name__)

# Transport subsectors included in the calibration objective (GAMS condition:
# ``sameas("PC",TRANSE) or sameas("PB",TRANSE) or sameas("GU",TRANSE)``).
_CALIB_TRANSE = {"PC", "PB", "GU"}


def add_core_objective(m: ConcreteModel, calibration: str = "off") -> None:
    """
    Add objective: minimize vDummyObj.

    For ``calibration="MatCalibration"`` the objective drives vDummyObj toward
    the sum-of-squares residual defined by ``qDummyObj``.  For calibration off
    it is simply min vDummyObj (constrained to 1 by qDummyObj).
    """
    m.obj = Objective(expr=m.vDummyObj, sense=minimize)


def add_q_dummy_obj_constraint(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add constraint qDummyObj (non-calibration): vDummyObj == 1.

    In GAMS with calibration off, the equation is qDummyObj.. vDummyObj =e= 1.
    Without this constraint, minimizing vDummyObj would drive it to -inf;
    with it, the model has a well-defined target and other constraints
    (from transport, etc.) determine the rest of the solution.
    """
    m.qDummyObj = Constraint(expr=m.vDummyObj == 1)


def add_q_dummy_obj_calibration(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add calibration-mode qDummyObj and qRestrain constraints.

    GAMS (core/equations.gms, ``$IFTHEN.calib %Calibration% == MatCalibration``):

    qDummyObj(allCy, YTIME)$(TIME(YTIME) and runCy(allCy))..
      vDummyObj =e=
        SUM(PGALL, SQR(V04SharePowPlaNewEq - t04SharePowPlaNewEq))
      + SUM((TRANSE,TTECH)$(SECTTECH and (PC or PB or GU)),
            SQR(
              (V01ShareTechTr - t01NewShareStockPC)$(target >= 0)
              + 0.01*(imMatrFactor(t) - imMatrFactor(t-1))
            ));

    qRestrain(allCy,TRANSE,TTECH,YTIME)$(target < 0)..
      imMatrFactor =e= common;
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    pgall = list(core_sets.PGALL)
    secttech = core_sets.SECTTECH  # set of (DSBS, TECH) pairs

    # Helper: previous-year lookup
    def _prev_year(y, offset=1):
        try:
            i = ytime.index(y)
            return ytime[i - offset] if i >= offset else ytime[0]
        except (ValueError, IndexError):
            return ytime[0]

    # ---- qDummyObj (calibration) ----
    def _q_dummy_obj_calib(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip

        # Power-generation share residuals
        pg_sum = 0.0
        for pg in pgall:
            if hasattr(mod, "V04SharePowPlaNewEq") and hasattr(mod, "t04SharePowPlaNewEq"):
                try:
                    v = mod.V04SharePowPlaNewEq[cy, pg, y]
                    t = mod.t04SharePowPlaNewEq[cy, pg, y]
                    pg_sum += (v - t) ** 2
                except (KeyError, TypeError):
                    pass

        # Transport share residuals (PC, PB, GU only)
        tr_sum = 0.0
        for transe in _CALIB_TRANSE:
            for tech in core_sets.TTECH:
                if (transe, tech) not in secttech:
                    continue
                try:
                    target = pyo_value(mod.t01NewShareStockPC[cy, transe, tech, y])
                except (KeyError, TypeError):
                    target = -1.0
                if target >= 0:
                    v = mod.V01ShareTechTr[cy, transe, tech, y]
                    tr_sum += (v - target) ** 2
                # Add maturity-factor smoothing term (0.01 * delta)
                y_1 = _prev_year(y)
                try:
                    mf_now = mod.imMatrFactor[cy, transe, tech, y]
                    mf_prev = mod.imMatrFactor[cy, transe, tech, y_1]
                    tr_sum += 0.01 * (mf_now - mf_prev)
                except (KeyError, TypeError):
                    pass

        return mod.vDummyObj == pg_sum + tr_sum

    m.qDummyObj = Constraint(run_cy, ytime, rule=_q_dummy_obj_calib)

    # ---- qRestrain: tie imMatrFactor to common when target < 0 ----
    def _q_restrain(mod, cy, transe, tech, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        if (transe, tech) not in secttech:
            return Constraint.Skip
        try:
            target = pyo_value(mod.t01NewShareStockPC[cy, transe, tech, y])
        except (KeyError, TypeError):
            target = -1.0
        if target >= 0:
            return Constraint.Skip  # not restrained for non-negative targets
        # imMatrFactor == common
        return mod.imMatrFactor[cy, transe, tech, y] == mod.common[cy, transe, y]

    m.qRestrain = Constraint(
        run_cy, list(_CALIB_TRANSE), list(core_sets.TTECH), ytime,
        rule=_q_restrain,
    )
    logger.info("Calibration equations added: qDummyObj (sum-of-squares) + qRestrain")
