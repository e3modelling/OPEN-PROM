"""
Module 11_Economy (economy): preloop — bounds and fix historical values.

Mirrors modules/11_Economy/economy/preloop.gms:
  V11SubsiTot.LO = 0.0001
  VmSubsiDemITech.LO=0, .L=0, .FX for datay or TFIRST or not SECTTECH = 0
  VmSubsiCapCostTech.FX = 0 when not SECTTECH(DSBS,TECH)
  VmNetSubsiTax.FX = 0 for datay
  VmSubsiDemTech.LO = 0
"""
from pyomo.core import ConcreteModel, value as pyo_value
from core import sets as core_sets


def apply_economy_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """Set bounds and fix 11_Economy variables for historical/datay."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = set(getattr(core_sets_obj, "datay", [])) if hasattr(core_sets_obj, "datay") else set()
    t_first = getattr(core_sets_obj, "tFirst", set())
    if t_first and hasattr(t_first, "__iter__") and not isinstance(t_first, (str, int)):
        t_first = set(t_first)
    else:
        t_first = set()
    sectech = core_sets.SECTTECH
    dsbs = list(core_sets.DSBS)
    tech = list(core_sets.TECH)
    itech = list(core_sets.ITECH)

    for cy in run_cy:
        for y in ytime:
            if hasattr(m, "V11SubsiTot"):
                m.V11SubsiTot[cy, y].setlb(0.0001)
            if hasattr(m, "VmNetSubsiTax") and y in datay:
                m.VmNetSubsiTax[cy, y].fix(0.0)

    for cy in run_cy:
        for dsb in dsbs:
            for t in tech:
                for y in ytime:
                    if hasattr(m, "VmSubsiDemTech"):
                        m.VmSubsiDemTech[cy, dsb, t, y].setlb(0.0)
                    if (dsb, t) not in sectech and hasattr(m, "VmSubsiCapCostTech"):
                        m.VmSubsiCapCostTech[cy, dsb, t, y].fix(0.0)
        for dsb in dsbs:
            for it in itech:
                if not hasattr(m, "VmSubsiDemITech"):
                    continue
                for y in ytime:
                    m.VmSubsiDemITech[cy, dsb, it, y].setlb(0.0)
                    m.VmSubsiDemITech[cy, dsb, it, y].set_value(0.0)
                    if y in datay or y in t_first or (dsb, it) not in sectech:
                        m.VmSubsiDemITech[cy, dsb, it, y].fix(0.0)
