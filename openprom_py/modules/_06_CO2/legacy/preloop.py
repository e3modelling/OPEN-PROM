"""
Module 06_CO2 (legacy): preloop – initialise/fix variables for historical years.

Mirrors modules/06_CO2/legacy/preloop.gms. Fix V06CapCO2ElecHydr in datay to 0;
V06CaptCummCO2 LO=0, L=1, FX in datay=0; V06LvlCostDAC bounds and fix in datay=100;
V06CapCDR fix in datay=1; V06ProfRateDAC bounds; V06CapFacNewDAC fix in datay=S06CapFacMinNewDAC.
"""
from pyomo.core import ConcreteModel

from core import sets as core_sets


def apply_co2_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """Apply 06_CO2 legacy preloop: fix/bound variables for historical data years."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = getattr(core_sets_obj, "datay", ())
    if hasattr(datay, "__iter__") and not isinstance(datay, (str, dict)):
        datay = set(datay) if datay else set()
    else:
        datay = set()
    sbs = list(core_sets.SBS)
    cdrtech = list(core_sets.CDRTECH)
    cap_fac_min = float(m.S06CapFacMinNewDAC)

    # V06CapCO2ElecHydr.FX(runCy,SBS,YTIME)$DATAY(YTIME) = 0
    if hasattr(m, "V06CapCO2ElecHydr"):
        for cy in run_cy:
            for sb in sbs:
                for y in ytime:
                    if y in datay:
                        m.V06CapCO2ElecHydr[cy, sb, y].fix(0.0)

    # V06CaptCummCO2.LO = 0, .L = 1, .FX in datay = 0
    if hasattr(m, "V06CaptCummCO2"):
        for cy in run_cy:
            for y in ytime:
                m.V06CaptCummCO2[cy, y].setlb(0.0)
                m.V06CaptCummCO2[cy, y].set_value(1.0)
                if y in datay:
                    m.V06CaptCummCO2[cy, y].fix(0.0)

    # V06LvlCostDAC.LO = epsilon, .L = 100, .FX in datay = 100
    if hasattr(m, "V06LvlCostDAC"):
        for cy in run_cy:
            for tech in cdrtech:
                for y in ytime:
                    m.V06LvlCostDAC[cy, tech, y].setlb(1e-6)
                    m.V06LvlCostDAC[cy, tech, y].set_value(100.0)
                    if y in datay:
                        m.V06LvlCostDAC[cy, tech, y].fix(100.0)

    # V06CapCDR.FX in datay = 1
    if hasattr(m, "V06CapCDR"):
        for cy in run_cy:
            for tech in cdrtech:
                for y in ytime:
                    if y in datay:
                        m.V06CapCDR[cy, tech, y].fix(1.0)

    # V06ProfRateDAC.LO = 0, .L = 1
    if hasattr(m, "V06ProfRateDAC"):
        for cy in run_cy:
            for tech in cdrtech:
                for y in ytime:
                    m.V06ProfRateDAC[cy, tech, y].setlb(0.0)
                    m.V06ProfRateDAC[cy, tech, y].set_value(1.0)

    # V06CapFacNewDAC.FX in datay = S06CapFacMinNewDAC
    if hasattr(m, "V06CapFacNewDAC"):
        for cy in run_cy:
            for tech in cdrtech:
                for y in ytime:
                    if y in datay:
                        m.V06CapFacNewDAC[cy, tech, y].fix(cap_fac_min)
