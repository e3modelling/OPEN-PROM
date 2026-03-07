"""
Module 11_Economy (economy): declarations (parameters and variables).

Mirrors modules/11_Economy/economy/declarations.gms.
Equations: Q11SubsiTot, Q11SubsiDemTechAvail, Q11SubsiDemITech, Q11SubsiDemTech, Q11SubsiSupTech,
  Q11SubsiCapCostTech, !!Q11SubsiCapCostSupply (commented), Q11NetSubsiTax.
Variables: V11SubsiTot, VmSubsiDemTechAvail, VmSubsiDemITech, VmSubsiDemTech, VmSubsiSupTech,
  VmSubsiCapCostTech, VmSubsiCapCostSupply, VmNetSubsiTax.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_economy_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """Add 11_Economy (economy) parameters. i11SubsiPerDemTechAvail from CSV."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    tech = list(core_sets.TECH)
    itech = list(core_sets.ITECH)
    stech = list(getattr(core_sets, "STECH", core_sets.PGALL))

    m.i11SubsiPerDemTechAvail = Param(
        run_cy, dsbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # $$ontext in GAMS: i11SubsiPerSupTech(allCy,STECH,YTIME) from iSubsiPerSupTech.csv — commented
    # m.i11SubsiPerSupTech = Param(run_cy, stech, ytime, ...)


def add_economy_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 11_Economy (economy) variables. When 11 is loaded, VmSubsiDemTech is Var here (stub skips adding as Param)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    tech = list(core_sets.TECH)
    itech = list(core_sets.ITECH)
    stech = list(getattr(core_sets, "STECH", core_sets.PGALL))
    ssbs = list(core_sets.SSBS)

    m.V11SubsiTot = Var(run_cy, ytime, domain=Reals, bounds=(0.0001, None), initialize=0.0)
    m.VmSubsiDemTechAvail = Var(run_cy, dsbs, tech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmSubsiDemITech = Var(run_cy, dsbs, itech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmSubsiDemTech = Var(run_cy, dsbs, tech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmSubsiSupTech = Var(run_cy, stech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmSubsiCapCostTech = Var(run_cy, dsbs, tech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmSubsiCapCostSupply = Var(run_cy, ssbs, stech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.VmNetSubsiTax = Var(run_cy, ytime, domain=Reals, bounds=(None, None), initialize=0.0)
