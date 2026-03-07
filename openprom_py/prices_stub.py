"""
Stub for fuel prices and subsidy variables.

In the full GAMS model, VmPriceFuelSubsecCarVal and VmPriceFuelAvgSub are
computed by module 08_Prices, and VmSubsiDemTech by 11_Economy. For the PoC
we do not implement those modules; instead we provide these as mutable Pyomo
Params (fixed values) so that the Transport module can run. Values can be
filled from precomputed CSV or from core preloop logic (imFuelPrice,
i08WgtSecAvgPriFueCons) via load_price_stub_from_fuel_price().
"""
from typing import Dict

from pyomo.core import ConcreteModel, Param
from pyomo.environ import Reals

from core import sets as core_sets


def add_price_stub_parameters(
    m: ConcreteModel,
    core_sets_obj: core_sets.CoreSets,
) -> None:
    """
    Add VmPriceFuelSubsecCarVal, VmPriceFuelAvgSub, VmSubsiDemTech as mutable Params.

    - VmPriceFuelSubsecCarVal(cy, SBS, EF, y): fuel price per subsector and fuel (k$2015/toe).
    - VmPriceFuelAvgSub(cy, DSBS, y): average fuel price per subsector.
    - VmSubsiDemTech(cy, DSBS, TECH, y): subsidy per unit of new capacity (11_Economy).

    Defaults: 1.5 (prices), 0.001 (avg), 0 (subsidy) so the model is feasible.
    Fill from data using load_price_stub_from_fuel_price() when imFuelPrice is loaded.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    sbs_and_supply = sbs + ["PG", "H2P", "STEAMP"]  # 04_PowerGeneration uses PG
    dsbs = list(core_sets.DSBS)
    ef = list(core_sets.EF)
    tech = list(core_sets.TECH)

    # Fuel price per subsector and fuel (k$2015/toe). Default 1.5 for feasibility.
    m.VmPriceFuelSubsecCarVal = Param(
        run_cy, sbs_and_supply, ef, ytime,
        mutable=True,
        default=1.5,
        initialize={},
    )

    # Average fuel price per subsector (k$2015/toe).
    m.VmPriceFuelAvgSub = Param(
        run_cy, dsbs, ytime,
        mutable=True,
        default=0.001,
        initialize={},
    )

    # Subsidy per unit of new capacity (11_Economy). Default 0 for PoC.
    m.VmSubsiDemTech = Param(
        run_cy, dsbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )


def load_price_stub_from_fuel_price(
    m: ConcreteModel,
    im_fuel_price: Dict[tuple, float],
    core_sets_obj: core_sets.CoreSets,
) -> None:
    """
    Fill VmPriceFuelSubsecCarVal from imFuelPrice (allCy, SBS, EF, YTIME).
    Fill VmPriceFuelAvgSub as simple average over EF for each (cy, dsbs, y) where (dsbs, ef) in SECtoEF.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    ef = list(core_sets.EF)

    # Copy imFuelPrice into VmPriceFuelSubsecCarVal only for (SBS, EF) in SECtoEF
    for key, val in im_fuel_price.items():
        if len(key) != 4:
            continue
        cy, sb, e, y = key
        if (sb, e) not in core_sets.SECtoEF:
            continue
        if cy in run_cy and y in ytime:
            m.VmPriceFuelSubsecCarVal[cy, sb, e, y] = val

    # VmPriceFuelAvgSub = simple average over fuels in SECtoEF for each (cy, dsbs, y)
    for cy in run_cy:
        for sb in dsbs:
            for y in ytime:
                vals = [
                    m.VmPriceFuelSubsecCarVal[cy, sb, e, y]
                    for e in ef
                    if (sb, e) in core_sets.SECtoEF
                ]
                if vals:
                    m.VmPriceFuelAvgSub[cy, sb, y] = sum(vals) / len(vals)
