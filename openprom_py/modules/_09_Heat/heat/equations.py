"""
Module 09_Heat (heat): equation definitions.

Mirrors modules/09_Heat/heat/equations.gms. Q09DemTotSte, Q09ScrapRate, Q09ProdSte, Q09DemGapSte,
Q09CostVarProdSte, Q09CostCapProdSte, Q09CostProdSte, Q09CostAvgProdSte, Q09GapShareSte, Q09CaptRateSte,
Q09ScrapRatePremature, Q09ConsFuelSteProd. All use TCHP + TDHP (heat plants only).
"""
from pyomo.core import ConcreteModel, Constraint
from pyomo.environ import exp, sqrt, value as pyo_value

from core import sets as core_sets

_EPS = 1e-10


def _tsteam_heat():
    return list(core_sets.TCHP) + list(core_sets.TDHP)


def _year_prev(ytime_list, y):
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def add_heat_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add all Q09* constraints for 09_Heat (heat)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    tsteam = _tsteam_heat()
    tchp = set(core_sets.TCHP)
    tdhp = set(core_sets.TDHP)
    dsbs = list(core_sets.DSBS)
    ssbs = list(core_sets.SSBS)
    stemode = list(getattr(core_sets, "STEMODE", ("CHP", "DHP")))
    steam_ef = list(getattr(core_sets, "STEAMEF", ("LGN", "HCL", "GDO", "NGS", "BMSWAS", "H2F", "GEO", "NUC")))
    tsteamtoef = getattr(core_sets, "TSTEAMTOEF", set())
    nap_to_steamp = [(n, s) for (n, s) in getattr(core_sets, "NAPtoALLSBS", []) if s == "STEAMP"]
    base_y = getattr(core_sets_obj, "tFirst", None)
    if base_y and hasattr(base_y, "__iter__") and not isinstance(base_y, (str, int)):
        base_y = next(iter(base_y), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None

    # -------------------------------------------------------------------------
    # Q09DemTotSte (GAMS): This equation calculates the total heat demand in the system. It takes into
    # account the overall need for steam across sectors like transportation, industry, and power generation,
    # adjusted for any transportation losses or distribution inefficiencies.
    # VmDemTotSte = sum(DSBS, VmConsFuel(STE)) + sum(SSBS, VmConsFiEneSec(STE)) + VmLossesDistr(STE) + V03Transfers(STE).
    # -------------------------------------------------------------------------
    def _q09_dem_tot_ste(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        rhs = (
            sum(mod.VmConsFuel[cy, ds, "STE", y] for ds in dsbs)
            + sum(mod.VmConsFiEneSec[cy, ss, "STE", y] for ss in ssbs)
            + mod.VmLossesDistr[cy, "STE", y]
            + mod.V03Transfers[cy, "STE", y]
        )
        return mod.VmDemTotSte[cy, y] == rhs

    m.Q09DemTotSte = Constraint(run_cy, ytime, rule=_q09_dem_tot_ste)

    # -------------------------------------------------------------------------
    # Q09ScrapRate (GAMS): Scrap rate of steam capacity; 1 - (1 - 1/i09ProdLftSte) * V09ScrapRatePremature.
    # -------------------------------------------------------------------------
    def _q09_scrap_rate(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        lft = pyo_value(mod.i09ProdLftSte[t]) or 25.0
        rhs = 1.0 - (1.0 - 1.0 / (lft + _EPS)) * mod.V09ScrapRatePremature[cy, t, y]
        return mod.V09ScrapRate[cy, t, y] == rhs

    m.Q09ScrapRate = Constraint(run_cy, tsteam, ytime, rule=_q09_scrap_rate)

    # -------------------------------------------------------------------------
    # Q09ProdSte (GAMS): Steam production by plant type; surviving capacity production plus new gap share.
    # VmProdSte = (1-V09ScrapRate)*VmProdSte(t-1) + V09GapShareSte*V09DemGapSte.
    # -------------------------------------------------------------------------
    def _q09_prod_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        rhs = (1.0 - mod.V09ScrapRate[cy, t, y]) * mod.VmProdSte[cy, t, y_1] + mod.V09GapShareSte[cy, t, y] * mod.V09DemGapSte[cy, y]
        return mod.VmProdSte[cy, t, y] == rhs

    m.Q09ProdSte = Constraint(run_cy, tsteam, ytime, rule=_q09_prod_ste)

    # -------------------------------------------------------------------------
    # Q09DemGapSte (GAMS): Demand gap for steam; positive part of (demand - remaining capacity production) + 1e-6.
    # V09DemGapSte = (VmDemTotSte - sum((1-V09ScrapRate)*VmProdSte(t-1)) + sqrt(sqr(...)))/2 + 1e-6.
    # -------------------------------------------------------------------------
    def _q09_dem_gap_ste(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        rem = sum((1.0 - mod.V09ScrapRate[cy, t, y]) * mod.VmProdSte[cy, t, y_1] for t in tsteam)
        diff = mod.VmDemTotSte[cy, y] - rem
        rhs = (diff + sqrt(diff**2 + _EPS)) / 2.0 + 1e-6
        return mod.V09DemGapSte[cy, y] == rhs

    m.Q09DemGapSte = Constraint(run_cy, ytime, rule=_q09_dem_gap_ste)

    # -------------------------------------------------------------------------
    # Q09CostVarProdSte (GAMS): Variable cost of steam production: fuel, CO2, VOM, minus CHP electricity credit.
    # Sum over TSTEAMTOEF of (share*price + capture*CO2 + (1-capture)*carbon*carVal)/efficiency + VOM - CHP credit for TCHP.
    # -------------------------------------------------------------------------
    def _q09_cost_var_prod_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        efs_steam = [e for e in steam_ef if (t, e) in tsteamtoef]
        if not efs_steam:
            efs_steam = [e for (tt, e) in tsteamtoef if tt == t]
        fuel_term = 0.0
        for efs_ in efs_steam:
            co2_bms = 4.17 if efs_ == "BMSWAS" else 0.0
            car_sum = sum(mod.VmCarVal[cy, n, y] for (n, s) in nap_to_steamp)
            fuel_term += (
                mod.i09ShareFuel[cy, t, efs_, base_y] * mod.VmPriceFuelSubsecCarVal[cy, "STEAMP", efs_, y]
                + mod.V09CaptRateSte[cy, t, y] * (mod.imCo2EmiFac[cy, "STEAMP", efs_, y] + co2_bms) * mod.VmCstCO2SeqCsts[cy, y] * 1e-3
                + (1.0 - mod.V09CaptRateSte[cy, t, y]) * 1e-3 * mod.imCo2EmiFac[cy, "STEAMP", efs_, y] * car_sum
            )
        eff = pyo_value(mod.i09EffSteThrm[t, y]) or 0.35
        rhs = fuel_term / (eff + _EPS) + pyo_value(mod.i09CostVOMSteProd[t, y]) * 1e-3 / pyo_value(mod.smTWhToMtoe) * mod.VmPriceElecInd[cy, y]
        if t in tchp:
            rhs -= mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", y] * pyo_value(mod.smFracElecPriChp) * mod.VmPriceElecInd[cy, y]
        return mod.V09CostVarProdSte[cy, t, y] == rhs

    m.Q09CostVarProdSte = Constraint(run_cy, tsteam, ytime, rule=_q09_cost_var_prod_ste)

    # -------------------------------------------------------------------------
    # Q09CostCapProdSte (GAMS): Capital cost of steam production (annuity). imDisc*exp(...)/(exp(...)-1) * (IC*imCGI + FC)
    # / (i09PowToHeatRatio + 1 for DHP) / (i09AvailRateSteProd * smGwToTwhPerYear * smTWhToMtoe * 1e3).
    # -------------------------------------------------------------------------
    def _q09_cost_cap_prod_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        disc = mod.imDisc[cy, "STEAMP", y]
        lft = pyo_value(mod.i09ProdLftSte[t]) or 25.0
        ex = exp(disc * lft)
        ann = disc * ex / (ex - 1.0 + _EPS)
        num = ann * (mod.i09CostInvCostSteProd[t, y] * mod.imCGI[cy, y] + mod.i09CostFixOMSteProd[t, y])
        pow_heat = pyo_value(mod.i09PowToHeatRatio[t, y]) or 0.0
        den1 = (pow_heat + (1.0 if t in tdhp else 0.0)) + _EPS
        den2 = pyo_value(mod.i09AvailRateSteProd[t, y]) * mod.smGwToTwhPerYear[y] * mod.smTWhToMtoe * 1e3 + _EPS
        return mod.V09CostCapProdSte[cy, t, y] == num / den1 / den2

    m.Q09CostCapProdSte = Constraint(run_cy, tsteam, ytime, rule=_q09_cost_cap_prod_ste)

    # -------------------------------------------------------------------------
    # Q09CostProdSte (GAMS): Total cost of steam production; V09CostProdSte = V09CostCapProdSte + V09CostVarProdSte.
    # -------------------------------------------------------------------------
    def _q09_cost_prod_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        return mod.V09CostProdSte[cy, t, y] == mod.V09CostCapProdSte[cy, t, y] + mod.V09CostVarProdSte[cy, t, y]

    m.Q09CostProdSte = Constraint(run_cy, tsteam, ytime, rule=_q09_cost_prod_ste)

    # -------------------------------------------------------------------------
    # Q09CostAvgProdSte (GAMS): Average cost of steam production (production-weighted). Used by 08_Prices.
    # VmCostAvgProdSte = sum(TSTEAM, (VmProdSte+1e-6)*V09CostProdSte) / sum(TSTEAM, VmProdSte+1e-6).
    # -------------------------------------------------------------------------
    def _q09_cost_avg_prod_ste(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = sum((mod.VmProdSte[cy, t, y] + 1e-6) * mod.V09CostProdSte[cy, t, y] for t in tsteam)
        den = sum(mod.VmProdSte[cy, t, y] + 1e-6 for t in tsteam)
        return mod.VmCostAvgProdSte[cy, y] == num / (den + _EPS)

    m.Q09CostAvgProdSte = Constraint(run_cy, ytime, rule=_q09_cost_avg_prod_ste)

    # -------------------------------------------------------------------------
    # Q09GapShareSte (GAMS): Share of new steam demand gap allocated to each plant type (inverse cost squared).
    # V09GapShareSte = V09CostProdSte(t-1)**(-2) / sum(TSTEAM2, V09CostProdSte(t-1)**(-2)). !! i04MatFacPlaAvailCap commented.
    # -------------------------------------------------------------------------
    def _q09_gap_share_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        num = (mod.V09CostProdSte[cy, t, y_1] + _EPS) ** (-2)
        den = sum((mod.V09CostProdSte[cy, t2, y_1] + _EPS) ** (-2) for t2 in tsteam) + _EPS
        return mod.V09GapShareSte[cy, t, y] == num / den

    m.Q09GapShareSte = Constraint(run_cy, tsteam, ytime, rule=_q09_gap_share_ste)

    # -------------------------------------------------------------------------
    # Q09CaptRateSte (GAMS): CO2 capture rate for steam plants; sigmoid in VmCstCO2SeqCsts/(sum VmCarVal(STEAMP)+1).
    # i09CaptRateSteProd / (1 + EXP(20*(...))).
    # -------------------------------------------------------------------------
    def _q09_capt_rate_ste(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        car_sum = sum(mod.VmCarVal[cy, n, y] for (n, s) in nap_to_steamp) + 1.0
        x = mod.VmCstCO2SeqCsts[cy, y] / (car_sum + _EPS)
        inner = (x + 2.0 - sqrt((x - 2.0) ** 2 + _EPS)) / 2.0 - 1.0
        cap0 = pyo_value(mod.i09CaptRateSteProd[t])
        rhs = cap0 / (1.0 + exp(20.0 * inner))
        return mod.V09CaptRateSte[cy, t, y] == rhs

    m.Q09CaptRateSte = Constraint(run_cy, tsteam, ytime, rule=_q09_capt_rate_ste)

    # -------------------------------------------------------------------------
    # Q09ScrapRatePremature (GAMS): Endogenous premature scrap rate; logit-like in V09CostVarProdSte vs other techs.
    # V09CostVarProdSte**(-2) / (V09CostVarProdSte**(-2) + (i09ScaleEndogScrap * sum(other TCHP/TDHP cost))**(-2)).
    # -------------------------------------------------------------------------
    def _q09_scrap_rate_premature(mod, cy, t, y):
        if y not in time_set or cy not in run_cy or t not in tsteam:
            return Constraint.Skip
        vc = (mod.V09CostVarProdSte[cy, t, y] + _EPS) ** (-2)
        other = 0.0
        scale = pyo_value(mod.i09ScaleEndogScrap)
        if t in tchp:
            other = sum(mod.V09CostProdSte[cy, t2, y] for t2 in tsteam if t2 in tchp and t2 != t)
        if t in tdhp:
            other = sum(mod.V09CostProdSte[cy, t2, y] for t2 in tsteam if t2 in tdhp and t2 != t)
        den = vc + (scale * (other + _EPS)) ** (-2) + _EPS
        return mod.V09ScrapRatePremature[cy, t, y] == vc / den

    m.Q09ScrapRatePremature = Constraint(run_cy, tsteam, ytime, rule=_q09_scrap_rate_premature)

    # -------------------------------------------------------------------------
    # Q09ConsFuelSteProd (GAMS): Fuel consumption for steam production by mode (DHP/CHP) and fuel.
    # VmConsFuelSteProd = sum(TDHP/TCHP with TSTEAMTOEF, VmProdSte * i09ShareFuel / i09EffSteThrm).
    # -------------------------------------------------------------------------
    def _q09_cons_fuel_ste_prod(mod, cy, mode, efs_, y):
        if y not in time_set or cy not in run_cy or efs_ not in steam_ef:
            return Constraint.Skip
        rhs = 0.0
        if mode == "DHP":
            for t in tdhp:
                if (t, efs_) not in tsteamtoef:
                    continue
                rhs += mod.VmProdSte[cy, t, y] * mod.i09ShareFuel[cy, t, efs_, base_y] / (mod.i09EffSteThrm[t, y] + _EPS)
        if mode == "CHP":
            for t in tchp:
                if (t, efs_) not in tsteamtoef:
                    continue
                rhs += mod.VmProdSte[cy, t, y] * mod.i09ShareFuel[cy, t, efs_, base_y] / (mod.i09EffSteThrm[t, y] + _EPS)
        return mod.VmConsFuelSteProd[cy, mode, efs_, y] == rhs

    m.Q09ConsFuelSteProd = Constraint(run_cy, stemode, steam_ef, ytime, rule=_q09_cons_fuel_ste_prod)
