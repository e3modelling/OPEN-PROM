"""
Module 08_Prices (legacy): postsolve — fix solved values for the next time step.

Mirrors modules/08_Prices/legacy/postsolve.gms:
  VmPriceFuelAvgSub.FX(runCyL,DSBS,YTIME)$TIME = VmPriceFuelAvgSub.L(...)
  VmPriceFuelSubsecCarVal.FX(...) = .L(...)
  VmPriceElecInd.FX(...) = .L(...)
  VmPriceElecIndResConsu.FX(...) = .L(...)
  V08PriceFuelSepCarbonWght.FX(...) = .L(...)
"""
from pyomo.core import ConcreteModel, value as pyo_value


def apply_prices_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """Fix current year solution for price variables so next iteration uses them."""
    run_cy = core_sets_obj.runCyL if hasattr(core_sets_obj, "runCyL") else core_sets_obj.runCy
    for cy in run_cy:
        if hasattr(m, "VmPriceFuelAvgSub"):
            for key in m.VmPriceFuelAvgSub:
                if key[2] == year:
                    m.VmPriceFuelAvgSub[key].fix(pyo_value(m.VmPriceFuelAvgSub[key]))
        if hasattr(m, "VmPriceFuelSubsecCarVal"):
            for key in m.VmPriceFuelSubsecCarVal:
                if key[3] == year:
                    m.VmPriceFuelSubsecCarVal[key].fix(pyo_value(m.VmPriceFuelSubsecCarVal[key]))
        if hasattr(m, "VmPriceElecInd") and (cy, year) in m.VmPriceElecInd:
            m.VmPriceElecInd[cy, year].fix(pyo_value(m.VmPriceElecInd[cy, year]))
        if hasattr(m, "VmPriceElecIndResConsu"):
            for key in m.VmPriceElecIndResConsu:
                if key[2] == year:
                    m.VmPriceElecIndResConsu[key].fix(pyo_value(m.VmPriceElecIndResConsu[key]))
        if hasattr(m, "V08PriceFuelSepCarbonWght"):
            for key in m.V08PriceFuelSepCarbonWght:
                if key[3] == year:
                    m.V08PriceFuelSepCarbonWght[key].fix(pyo_value(m.V08PriceFuelSepCarbonWght[key]))
