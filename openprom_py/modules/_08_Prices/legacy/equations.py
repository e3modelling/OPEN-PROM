"""
Module 08_Prices (legacy): equation definitions.

Mirrors modules/08_Prices/legacy/equations.gms. Q08PriceFuelSubsecCarVal, Q08PriceFuelSepCarbonWght,
Q08PriceFuelAvgSub, Q08PriceElecIndResConsu, Q08PriceElecInd. VmPriceElecInd is in core (Q08PriceElecInd defines it).
Commented-out GAMS equation Q08PriceFuelSubsecCHP and $ontext blocks transferred as comments.
"""
from pyomo.core import ConcreteModel, Constraint
from pyomo.environ import value as pyo_value, sqrt

from core import sets as core_sets

_EPS = 1e-10


def _year_prev(ytime_list, y):
    """Previous year in ytime; if first, return y."""
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def add_prices_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add all Q08* constraints for 08_Prices (legacy)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    sbs = list(core_sets.SBS)
    dsbs = list(core_sets.DSBS)
    ef = list(core_sets.EF)
    eset = list(getattr(core_sets, "ESET", ("i", "r", "t", "c")))
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]
    sec_to_ef = core_sets.SECtoEF
    indse1 = set(getattr(core_sets, "INDSE1", core_sets.INDSE))
    hou1 = set(getattr(core_sets, "HOU1", ("HOU",)))
    trans1 = set(getattr(core_sets, "TRANS1", core_sets.TRANSE))
    serv = set(getattr(core_sets, "SERV", ("SE",)))
    elcef = set(core_sets.ELCEF)
    h2ef = set(core_sets.H2EF)
    altef = set(getattr(core_sets, "ALTEF", ()))
    inddom = set(core_sets.INDDOM)
    nense = set(core_sets.NENSE)
    transe = set(core_sets.TRANSE)
    nap_to_sbs = list(getattr(core_sets, "NAPtoALLSBS", []))
    t_first = getattr(core_sets_obj, "tFirst", set())
    if t_first and hasattr(t_first, "__iter__") and not isinstance(t_first, (str, int)):
        t_first = set(t_first)
    else:
        t_first = {ytime[0]} if ytime else set()
    start_y = getattr(core_sets_obj, "an", ytime)
    if start_y and hasattr(start_y, "__getitem__"):
        start_y = start_y[0] if start_y else (ytime[0] if ytime else None)
    else:
        start_y = ytime[0] if ytime else None

    # -------------------------------------------------------------------------
    # Q08PriceFuelSubsecCarVal (GAMS): The equation computes fuel prices per subsector and fuel with separate
    # carbon values in each sector. Branches: (1) DSBS and not ELC/HEATPUMP/ALTEF/H2EF/STE: lagged + sum_NAP carbon delta/1000.
    # (2) PG: same. (3) DSBS and ALTEF: lagged. (4) ELC or HEATPUMP: VmPriceElecIndResConsu(eset)/smTWhToMtoe + imEffValueInDollars/1000.
    # (5) H2P or STEAMP: OI or AG fuel price. (6) H2EF and DSBS: VmCostAvgProdH2(t-1)/1000. (7) STE and DSBS: VmCostAvgProdSte.
    # -------------------------------------------------------------------------
    def _q08_price_fuel_subsec_car_val(mod, cy, sb, e, y):
        if y not in time_set or cy not in run_cy or (sb, e) not in sec_to_ef:
            return Constraint.Skip
        if e == "NUC":
            return Constraint.Skip
        # GAMS $IFTHEN %link2MAgPIE% == on $(not sameas("BMSWAS",EF))
        if getattr(getattr(mod, "_config", None), "link2magpie", "off") == "on" and e == "BMSWAS":
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        # Branch: DSBS and not (ELCEF or HEATPUMP or ALTEF or H2EF or STE)
        if sb in dsbs and e not in elcef and e != "HEATPUMP" and e not in altef and e not in h2ef and e != "STE":
            car_sum = 0.0
            for (nap, s) in nap_to_sbs:
                if s != sb:
                    continue
                car_sum += (
                    pyo_value(mod.VmCarVal[cy, nap, y]) * pyo_value(mod.imCo2EmiFac[cy, sb, e, y])
                    - pyo_value(mod.VmCarVal[cy, nap, y_1]) * pyo_value(mod.imCo2EmiFac[cy, sb, e, y_1])
                )
            rhs = mod.VmPriceFuelSubsecCarVal[cy, sb, e, y_1] + car_sum / 1000.0
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        # Branch: PG (same carbon delta)
        if sb == "PG":
            car_sum = 0.0
            for (nap, s) in nap_to_sbs:
                if s != "PG":
                    continue
                car_sum += (
                    mod.VmCarVal[cy, nap, y] * mod.imCo2EmiFac[cy, "PG", e, y]
                    - mod.VmCarVal[cy, nap, y_1] * mod.imCo2EmiFac[cy, "PG", e, y_1]
                )
            rhs = mod.VmPriceFuelSubsecCarVal[cy, "PG", e, y_1] + car_sum / 1000.0
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        # Branch: DSBS and ALTEF — lagged
        if sb in dsbs and e in altef:
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == mod.VmPriceFuelSubsecCarVal[cy, sb, e, y_1]
        # Branch: ELC or HEATPUMP
        if e in elcef or e == "HEATPUMP":
            if sb in indse1 or sb == "DAC" or sb == "EW":
                p_elc = mod.VmPriceElecIndResConsu[cy, "i", y]
            elif sb in hou1:
                p_elc = mod.VmPriceElecIndResConsu[cy, "r", y]
            elif sb in trans1:
                p_elc = mod.VmPriceElecIndResConsu[cy, "t", y]
            elif sb in serv:
                p_elc = mod.VmPriceElecIndResConsu[cy, "c", y]
            else:
                p_elc = 0.0
            eff_val = pyo_value(mod.imEffValueInDollars[cy, sb, y]) / 1000.0 if sb in dsbs else 0.0
            rhs = p_elc / mod.smTWhToMtoe + eff_val
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        # Branch: H2P or STEAMP — OI or AG price
        if sb in ("H2P", "STEAMP"):
            if e == "BMSWAS":
                rhs = mod.VmPriceFuelSubsecCarVal[cy, "AG", e, y]
            else:
                rhs = mod.VmPriceFuelSubsecCarVal[cy, "OI", e, y]
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        # Branch: H2EF and DSBS
        if e in h2ef and sb in dsbs:
            rhs = mod.VmCostAvgProdH2[cy, y_1] / 1000.0
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        # Branch: STE and DSBS
        if e == "STE" and sb in dsbs:
            rhs = mod.VmCostAvgProdSte[cy, y]
            return mod.VmPriceFuelSubsecCarVal[cy, sb, e, y] == rhs
        return Constraint.Skip

    m.Q08PriceFuelSubsecCarVal = Constraint(
        run_cy, sbs_and_supply, ef, ytime,
        rule=_q08_price_fuel_subsec_car_val,
    )

    # --- Commented out in GAMS ($ontext): Q08PriceFuelSepCarbonWght alternative formula with i08WgtSecAvgPriFueCons * (...) ---
    # *' The equation calculates the fuel prices per subsector and fuel multiplied by weights ...
    # Q08PriceFuelSepCarbonWght ... = i08WgtSecAvgPriFueCons * ( (VmConsFuel - V02FinalElecNonSubIndTert$ELCEF) / SUM(...) )$INDSE * VmPriceFuelSubsecCarVal + ...

    # -------------------------------------------------------------------------
    # Q08PriceFuelSepCarbonWght (GAMS): V08PriceFuelSepCarbonWght = 1e-6 + one of (INDDOM/NENSE share, TRANSE share, DAC share, EW share).
    # -------------------------------------------------------------------------
    def _q08_price_fuel_sep_carbon_wght(mod, cy, dsb, e, y):
        if y not in time_set or cy not in run_cy or (dsb, e) not in sec_to_ef:
            return Constraint.Skip
        term = 0.0
        if dsb in inddom or dsb in nense:
            cons = mod.VmConsFuel[cy, dsb, e, y]
            if e in elcef and hasattr(mod, "V02FinalElecNonSubIndTert"):
                cons = cons - mod.V02FinalElecNonSubIndTert[cy, dsb, y]
            denom = _EPS
            for e2 in ef:
                if (dsb, e2) not in sec_to_ef:
                    continue
                c2 = mod.VmConsFuel[cy, dsb, e2, y]
                if e2 in elcef and hasattr(mod, "V02FinalElecNonSubIndTert"):
                    c2 = c2 - mod.V02FinalElecNonSubIndTert[cy, dsb, y]
                denom += c2
            term = cons / denom
        elif dsb in transe:
            denom = _EPS
            for e2 in ef:
                if (dsb, e2) not in sec_to_ef:
                    continue
                denom += mod.VmDemFinEneTranspPerFuel[cy, dsb, e2, y]
            term = mod.VmDemFinEneTranspPerFuel[cy, dsb, e, y] / denom
        elif dsb == "DAC" and hasattr(mod, "VmConsFuelTechCDRProd"):
            dactech = getattr(core_sets, "DACTECH", ("HTDAC", "H2DAC", "LTDAC"))
            num_dac = sum(mod.VmConsFuelTechCDRProd[cy, dact, e, y] for dact in dactech)
            denom = 1e-12 + sum(
                mod.VmConsFuelTechCDRProd[cy, dact, e2, y]
                for dact in dactech for e2 in ef if (dsb, e2) in sec_to_ef
            )
            term = num_dac / denom
        elif dsb == "EW" and hasattr(mod, "VmConsFuelTechCDRProd"):
            denom = 1e-12 + sum(
                mod.VmConsFuelTechCDRProd[cy, "TEW", e2, y]
                for e2 in ef if (dsb, e2) in sec_to_ef
            )
            term = mod.VmConsFuelTechCDRProd[cy, "TEW", e, y] / denom
        return mod.V08PriceFuelSepCarbonWght[cy, dsb, e, y] == term + 1e-6

    m.Q08PriceFuelSepCarbonWght = Constraint(
        run_cy, sbs_and_supply, ef, ytime,
        rule=_q08_price_fuel_sep_carbon_wght,
    )

    # -------------------------------------------------------------------------
    # Q08PriceFuelAvgSub (GAMS): The equation calculates the average fuel price per subsector.
    # VmPriceFuelAvgSub = sum(EF, V08PriceFuelSepCarbonWght(t-1) * VmPriceFuelSubsecCarVal(t-1)).
    # -------------------------------------------------------------------------
    def _q08_price_fuel_avg_sub(mod, cy, dsb, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        rhs = sum(
            mod.V08PriceFuelSepCarbonWght[cy, dsb, e, y_1] * mod.VmPriceFuelSubsecCarVal[cy, dsb, e, y_1]
            for e in ef
            if (dsb, e) in sec_to_ef
        )
        return mod.VmPriceFuelAvgSub[cy, dsb, y] == rhs

    m.Q08PriceFuelAvgSub = Constraint(run_cy, dsbs, ytime, rule=_q08_price_fuel_avg_sub)

    # -------------------------------------------------------------------------
    # Q08PriceElecIndResConsu (GAMS): Calculates electricity price for industrial and residential consumers using
    # previous year's fuel prices. For first year (TFIRST) use fuel price * smTWhToMtoe; for later years scale by
    # VmPriceElecIndResConsu(eset, fStartY) / VmCostPowGenAvgLng(fStartY) * VmCostPowGenAvgLng(YTIME-1).
    # -------------------------------------------------------------------------
    def _q08_price_elec_ind_res_consu(mod, cy, es, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        vat = 1.0 + pyo_value(mod.i08VAT[cy, y])
        # TFIRST(YTIME-1): base year(s) — use fuel price * smTWhToMtoe
        if y_1 in t_first:
            if es == "i":
                base = mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", y_1] * mod.smTWhToMtoe
            elif es == "r":
                base = mod.VmPriceFuelSubsecCarVal[cy, "HOU", "ELC", y_1] * mod.smTWhToMtoe
            elif es == "t":
                base = mod.VmPriceFuelSubsecCarVal[cy, "PC", "ELC", y_1] * mod.smTWhToMtoe
            elif es == "c":
                base = mod.VmPriceFuelSubsecCarVal[cy, "SE", "ELC", y_1] * mod.smTWhToMtoe
            else:
                base = 0.0
            return mod.VmPriceElecIndResConsu[cy, es, y] == vat * base
        # Not first: scale by start_y ratio
        if not hasattr(mod, "VmCostPowGenAvgLng") or start_y is None:
            return Constraint.Skip
        ratio = mod.VmPriceElecIndResConsu[cy, es, start_y] / (mod.VmCostPowGenAvgLng[cy, start_y] + _EPS) * mod.VmCostPowGenAvgLng[cy, y_1]
        return mod.VmPriceElecIndResConsu[cy, es, y] == vat * ratio

    m.Q08PriceElecIndResConsu = Constraint(run_cy, eset, ytime, rule=_q08_price_elec_ind_res_consu)

    # --- Commented out in GAMS ($ontext): Q08PriceFuelSubsecCHP ---
    # *' This equation calculates the fuel prices per subsector and fuel, specifically for CHP plants ...
    # Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)$... VmPriceFuelSubsecCHP =E= (((VmPriceFuelSubsecCarVal + ...)/imUsfEneConvSubTech - ...

    # -------------------------------------------------------------------------
    # Q08PriceElecInd (GAMS): This equation determines the electricity industry prices based on an estimated
    # electricity index and a technical maximum of the electricity to steam ratio in CHP plants.
    # VmPriceElecInd = (V02IndxElecIndPrices + smElecToSteRatioChp - sqrt((V02IndxElecIndPrices - smElecToSteRatioChp)^2)) / 2.
    # -------------------------------------------------------------------------
    def _q08_price_elec_ind(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        idx = mod.V02IndxElecIndPrices[cy, y]
        ratio = pyo_value(mod.smElecToSteRatioChp)
        diff = idx - ratio
        rhs = (idx + ratio - sqrt(diff**2 + _EPS)) / 2.0
        return mod.VmPriceElecInd[cy, y] == rhs

    m.Q08PriceElecInd = Constraint(run_cy, ytime, rule=_q08_price_elec_ind)
