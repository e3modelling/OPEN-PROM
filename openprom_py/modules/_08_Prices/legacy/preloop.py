"""
Module 08_Prices (legacy): preloop — fix historical (non-solving) values for price variables.

Mirrors modules/08_Prices/legacy/preloop.gms:
  VmPriceElecIndResConsu.FX(not An) = VmPriceFuelSubsecCarVal.L(OI/HOU/PC/SE, ELC, YTIME)*smTWhToMtoe
  V08PriceFuelSepCarbonWght.FX(not AN) = i08WgtSecAvgPriFueCons
  V08FuelPriSubNoCarb.FX(...) = imFuelPrice (or 0.025 for PG/NUC, ELC for HEATPUMP)
Commented-out GAMS $ontext (VmPriceFuelSubsecCHP.FX) transferred as comments.
"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets


def _pval(p, *idx):
    """Safe value of Param or Var at index."""
    try:
        v = p[idx] if len(idx) > 0 else p
        return pyo_value(v) if v is not None else 0.0
    except Exception:
        return 0.0


def apply_prices_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """
    Fix price variables for historical (non-An) years so the solver does not change them.
    Uses VmPriceFuelSubsecCarVal (or imFuelPrice) and i08WgtSecAvgPriFueCons where available.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    an = set(getattr(core_sets_obj, "an", [])) if hasattr(core_sets_obj, "an") else set()
    time_set = set(ytime)
    sbs = list(core_sets.SBS)
    ef = list(core_sets.EF)
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]
    sec_to_ef = core_sets.SECtoEF
    inddom = set(core_sets.INDDOM)

    for cy in run_cy:
        for y in ytime:
            if y in an:
                continue
            # VmPriceElecIndResConsu.FX(not An) = VmPriceFuelSubsecCarVal.L(OI/HOU/PC/SE, ELC, y)*smTWhToMtoe
            if hasattr(m, "VmPriceElecIndResConsu"):
                twh = pyo_value(m.smTWhToMtoe)
                m.VmPriceElecIndResConsu[cy, "i", y].fix(_pval(m.VmPriceFuelSubsecCarVal, cy, "OI", "ELC", y) * twh)
                m.VmPriceElecIndResConsu[cy, "r", y].fix(_pval(m.VmPriceFuelSubsecCarVal, cy, "HOU", "ELC", y) * twh)
                m.VmPriceElecIndResConsu[cy, "t", y].fix(_pval(m.VmPriceFuelSubsecCarVal, cy, "PC", "ELC", y) * twh)
                m.VmPriceElecIndResConsu[cy, "c", y].fix(_pval(m.VmPriceFuelSubsecCarVal, cy, "SE", "ELC", y) * twh)
            # V08PriceFuelSepCarbonWght.FX(not AN) = i08WgtSecAvgPriFueCons
            if hasattr(m, "V08PriceFuelSepCarbonWght") and hasattr(m, "i08WgtSecAvgPriFueCons"):
                for sb in sbs_and_supply:
                    for e in ef:
                        if (sb, e) not in sec_to_ef:
                            continue
                        m.V08PriceFuelSepCarbonWght[cy, sb, e, y].fix(pyo_value(m.i08WgtSecAvgPriFueCons[cy, sb, e]))
            # V08FuelPriSubNoCarb.FX = imFuelPrice (or 0.025 for PG/NUC, ELC for HEATPUMP in INDDOM)
            if hasattr(m, "V08FuelPriSubNoCarb"):
                for sb in sbs_and_supply:
                    for e in ef:
                        if (sb, e) not in sec_to_ef:
                            continue
                        if e == "HEATPUMP" and sb in inddom:
                            val = _pval(m.imFuelPrice, cy, sb, "ELC", y)
                        elif sb == "PG" and e == "NUC":
                            val = 0.025  # fixed price for nuclear fuel (25 Euro/toe in GAMS)
                        else:
                            val = _pval(m.imFuelPrice, cy, sb, e, y)
                        m.V08FuelPriSubNoCarb[cy, sb, e, y].fix(val)

    # --- GAMS $ontext: VmPriceFuelSubsecCHP.FX(...) = ... [commented] ---
