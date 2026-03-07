"""
Industry (technology) module — equation definitions.

Mirrors 02_Industry/technology/equations.gms. Constraints apply to subsectors
excluding TRANSE (transport) and CDR; INDDOM is used for non-substitutable
electricity. Safe division and scaling are used for solver stability.
Equation descriptions below are transferred from GAMS *' comments.
"""
from pyomo.core import Constraint
from pyomo.environ import exp as pyo_exp

from core import sets as core_sets

# Scale for gap and demand constraints (residual magnitude)
DEMAND_SCALE = 1e6

TRANSE = set(core_sets.TRANSE)
CDR = set(core_sets.CDR)
INDDOM = set(core_sets.INDDOM)
NENSE = set(core_sets.NENSE)
CCSTECH = set(core_sets.CCSTECH)
TSTEAM = set(core_sets.TSTEAM)
RENEF = core_sets.RENEF
ELCEF = set(core_sets.ELCEF)


def _ord(ytime_list, y):
    """1-based position of year y in ytime."""
    try:
        return ytime_list.index(y) + 1
    except ValueError:
        return 0


def _year_at(ytime_list, index_0based):
    """Year at 0-based index; None if out of range."""
    if index_0based < 0 or index_0based >= len(ytime_list):
        return None
    return ytime_list[index_0based]


def add_industry_equations(m, core_sets_obj):
    """Add all Q02* Industry (technology) constraints."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    dsbs = list(core_sets.DSBS)
    itech = list(core_sets.ITECH)
    ef = list(core_sets.EF)
    inddom = list(core_sets.INDDOM)
    kpdl = list(core_sets.KPDL)
    sectech = core_sets.SECTTECH
    itechtoef = core_sets.ITECHtoEF
    sectoef = core_sets.SECtoEF
    nap = list(core_sets.NAP)

    # -------------------------------------------------------------------------
    # Q02RemEquipCapTechSubsec (GAMS): This equation computes the remaining equipment capacity of each technology in each subsector at the beginning of the year YTIME based on the available capacity of the previous year. V02RemEquipCapTechSubsec = V02EquipCapTechSubsec(YTIME-1) * V02RatioRem.
    # -------------------------------------------------------------------------
    def _q02_rem_equip_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        return (
            mod.V02RemEquipCapTechSubsec[cy, sb, tech, y]
            == mod.V02EquipCapTechSubsec[cy, sb, tech, y_1] * mod.V02RatioRem[cy, sb, tech, y]
        )

    m.Q02RemEquipCapTechSubsec = Constraint(
        run_cy, dsbs, itech, ytime, rule=_q02_rem_equip_rule
    )

    # -------------------------------------------------------------------------
    # Q02RatioRem (GAMS): V02RatioRem = (1 - 1/VmLft) * (1 - V02PremScrpIndu). Fraction of capacity remaining after normal and premature scrapping.
    # -------------------------------------------------------------------------
    def _q02_ratio_rem_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        lft = mod.VmLft[cy, sb, tech, y]
        return mod.V02RatioRem[cy, sb, tech, y] == (
            (1.0 - 1.0 / (lft + 1e-10)) * (1.0 - mod.V02PremScrpIndu[cy, sb, tech, y])
        )

    m.Q02RatioRem = Constraint(run_cy, dsbs, itech, ytime, rule=_q02_ratio_rem_rule)

    # -------------------------------------------------------------------------
    # Q02PremScrpIndu (GAMS): Premature scrapping index. The equation computes the share of capacity that is scrapped prematurely based on variable costs and scale parameter; logit-like formulation with (V02VarCostTech * i02util)**(-2) in numerator and denominator with sum of other technologies' costs.
    # -------------------------------------------------------------------------
    def _q02_prem_scrp_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        vc = mod.V02VarCostTech[cy, sb, tech, y_1]
        util = mod.i02util[cy, sb, tech, y_1]
        x = (vc * util + 1e-10) ** (-2)
        other = sum(
            mod.V02CostTech[cy, sb, t2, y_1] + mod.V02VarCostTech[cy, sb, t2, y_1]
            for t2 in itech
            if (sb, t2) in sectech and t2 != tech
        )
        scale = mod.i02ScaleEndogScrap[sb]
        den = (scale * (other + 1e-10)) ** (-2)
        return mod.V02PremScrpIndu[cy, sb, tech, y] == 1.0 - x / (x + den + 1e-12)

    m.Q02PremScrpIndu = Constraint(run_cy, dsbs, itech, ytime, rule=_q02_prem_scrp_rule)

    # -------------------------------------------------------------------------
    # Q02DemUsefulSubsecRemTech (GAMS): This equation computes the useful energy covered by the remaining equipment. V02DemUsefulSubsecRemTech = SUM(ITECH, V02RemEquipCapTechSubsec * imUsfEneConvSubTech * i02util).
    # -------------------------------------------------------------------------
    def _q02_dem_useful_rem_rule(mod, cy, sb, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        rhs = sum(
            mod.V02RemEquipCapTechSubsec[cy, sb, tech, y]
            * mod.imUsfEneConvSubTech[cy, sb, tech, y]
            * mod.i02util[cy, sb, tech, y]
            for tech in itech
            if (sb, tech) in sectech
        )
        return mod.V02DemUsefulSubsecRemTech[cy, sb, y] == rhs

    m.Q02DemUsefulSubsecRemTech = Constraint(
        run_cy, dsbs, ytime, rule=_q02_dem_useful_rem_rule
    )

    # -------------------------------------------------------------------------
    # Q02GapUsefulDemSubsec (GAMS): This equation calculates the gap in useful energy demand for industry, tertiary, non-energy uses, and bunkers. It is determined by subtracting the useful energy demand that can be satisfied by existing equipment from the total useful energy demand per subsector. The square root term is included to ensure a non-negative result. (demand - rem + sqrt((demand - rem)^2)) / 2 + 1e-6.
    # -------------------------------------------------------------------------
    def _q02_gap_rule(mod, cy, sb, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        from pyomo.environ import sqrt

        d = mod.V02DemSubUsefulSubsec[cy, sb, y]
        r = mod.V02DemUsefulSubsecRemTech[cy, sb, y]
        diff = d - r
        return mod.V02GapUsefulDemSubsec[cy, sb, y] == (
            (diff + sqrt(diff**2 + 1e-12)) / 2.0 + 1e-6
        )

    m.Q02GapUsefulDemSubsec = Constraint(run_cy, dsbs, ytime, rule=_q02_gap_rule)

    # -------------------------------------------------------------------------
    # Q02CapCostTech (GAMS): The equation computes the capital cost and fixed O&M cost of each technology in each subsector. Annuity factor from discount rate and VmLft; (imCapCostTech * imCGI + imFixOMCostTech / sUnitToKUnit) / imUsfEneConvSubTech.
    # -------------------------------------------------------------------------
    def _q02_cap_cost_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        disc = mod.imDisc[cy, sb, y] if tech not in TSTEAM else mod.imDisc[cy, "OI", y]
        lft = mod.VmLft[cy, sb, tech, y]
        num = disc * pyo_exp(disc * lft) / (pyo_exp(disc * lft) - 1.0 + 1e-12)
        cap = mod.imCapCostTech[cy, sb, tech, y] * mod.imCGI[cy, y]
        fom = mod.imFixOMCostTech[cy, sb, tech, y] / mod.sUnitToKUnit
        usc = mod.imUsfEneConvSubTech[cy, sb, tech, y]
        return mod.V02CapCostTech[cy, sb, tech, y] == (num * cap + fom) / (usc + 1e-10)

    m.Q02CapCostTech = Constraint(run_cy, dsbs, itech, ytime, rule=_q02_cap_cost_rule)

    # -------------------------------------------------------------------------
    # Q02VarCostTech (GAMS): The equation computes the variable cost (variable + fuel) of each technology in each subsector. Sum over EF of share * fuel price, CO2 capture cost, carbon cost, plus renewable value and imVarCostTech; divided by useful conversion.
    # -------------------------------------------------------------------------
    def _q02_var_cost_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        car_val = sum(mod.VmCarVal[cy, nap_, y] for nap_ in nap)
        part_per_ef = sum(
            (
                mod.i02ShareBlend[cy, sb, tech, e, y] * mod.VmPriceFuelSubsecCarVal[cy, sb, e, y]
                + mod.imCO2CaptRateIndustry[cy, tech, y] * mod.VmCstCO2SeqCsts[cy, y] * 1e-3 * mod.imCo2EmiFac[cy, sb, e, y]
                + (1.0 - mod.imCO2CaptRateIndustry[cy, tech, y]) * 1e-3 * mod.imCo2EmiFac[cy, sb, e, y] * car_val
            )
            for e in ef
            if (tech, e) in itechtoef
        )
        ren_part = (
            mod.VmRenValue[y] / 1000.0
            if (tech not in RENEF and sb not in NENSE)
            else 0.0
        )
        var_other = mod.imVarCostTech[cy, sb, tech, y] / mod.sUnitToKUnit
        usc = mod.imUsfEneConvSubTech[cy, sb, tech, y]
        return mod.V02VarCostTech[cy, sb, tech, y] == (
            part_per_ef + ren_part + var_other
        ) / (usc + 1e-10)

    m.Q02VarCostTech = Constraint(run_cy, dsbs, itech, ytime, rule=_q02_var_cost_rule)

    # -------------------------------------------------------------------------
    # Q02CostTech: total cost = cap + var - subsidy
    # -------------------------------------------------------------------------
    def _q02_cost_tech_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        return mod.V02CostTech[cy, sb, tech, y] == (
            mod.V02CapCostTech[cy, sb, tech, y]
            + mod.V02VarCostTech[cy, sb, tech, y]
            - mod.VmSubsiDemTech[cy, sb, tech, y]
        )

    m.Q02CostTech = Constraint(run_cy, dsbs, itech, ytime, rule=_q02_cost_tech_rule)

    # -------------------------------------------------------------------------
    # Q02ShareTechNewEquipUseful: share of tech in new equipment (logit-like)
    # -------------------------------------------------------------------------
    def _q02_share_tech_new_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        ela = mod.i02ElaSub[cy, sb]
        num = mod.imMatrFactor[cy, sb, tech, y] * (
            mod.V02CostTech[cy, sb, tech, y_1] + 1e-6
        ) ** (-ela)
        den = sum(
            mod.imMatrFactor[cy, sb, t2, y]
            * (mod.V02CostTech[cy, sb, t2, y_1] + 1e-6) ** (-ela)
            for t2 in itech
            if (sb, t2) in sectech
        )
        return mod.V02ShareTechNewEquipUseful[cy, sb, tech, y] == num / (den + 1e-12)

    m.Q02ShareTechNewEquipUseful = Constraint(
        run_cy, dsbs, itech, ytime, rule=_q02_share_tech_new_rule
    )

    # -------------------------------------------------------------------------
    # Q02EquipCapTechSubsec: equipment capacity = rem + (share * gap) / (usc * util)
    # -------------------------------------------------------------------------
    def _q02_equip_cap_rule(mod, cy, sb, tech, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        if (sb, tech) not in sectech:
            return Constraint.Skip
        usc = mod.imUsfEneConvSubTech[cy, sb, tech, y]
        util = mod.i02util[cy, sb, tech, y]
        new_part = (
            mod.V02ShareTechNewEquipUseful[cy, sb, tech, y]
            * mod.V02GapUsefulDemSubsec[cy, sb, y]
            / (usc * util + 1e-10)
        )
        return mod.V02EquipCapTechSubsec[cy, sb, tech, y] == (
            mod.V02RemEquipCapTechSubsec[cy, sb, tech, y] + new_part
        )

    m.Q02EquipCapTechSubsec = Constraint(
        run_cy, dsbs, itech, ytime, rule=_q02_equip_cap_rule
    )

    # -------------------------------------------------------------------------
    # Q02UsefulElecNonSubIndTert: non-substitutable useful electricity (INDDOM)
    # -------------------------------------------------------------------------
    def _q02_useful_elec_nonsub_rule(mod, cy, ind, y):
        if cy not in run_cy or y not in time_set or ind not in inddom:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 3:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        y_2 = ytime[i - 3]
        act = mod.imActv[y, cy, ind]
        act_1 = mod.imActv[y_1, cy, ind]
        p_elc = mod.VmPriceFuelSubsecCarVal[cy, ind, "ELC", y]
        p_elc_1 = mod.VmPriceFuelSubsecCarVal[cy, ind, "ELC", y_1]
        p_elc_2 = mod.VmPriceFuelSubsecCarVal[cy, ind, "ELC", y_2]
        el_a = mod.i02ElastNonSubElec[cy, ind, "a", y]
        el_b1 = mod.i02ElastNonSubElec[cy, ind, "b1", y]
        el_b2 = mod.i02ElastNonSubElec[cy, ind, "b2", y]
        rhs = (
            mod.V02UsefulElecNonSubIndTert[cy, ind, y_1]
            * (act / (act_1 + 1e-10)) ** el_a  # act_1 + 1e-10 avoids division by zero
            * (p_elc / (p_elc_1 + 1e-10)) ** el_b1
            * (p_elc_1 / (p_elc_2 + 1e-10)) ** el_b2
        )
        prod_c = 1.0
        for k_ord, k in enumerate(kpdl):
            if k_ord >= 6:
                break
            y_k = _year_at(ytime, i - 1 - k_ord)
            y_k1 = _year_at(ytime, i - 2 - k_ord)
            if y_k is None or y_k1 is None:
                continue
            pk = mod.VmPriceFuelSubsecCarVal[cy, ind, "ELC", y_k]
            pk1 = mod.VmPriceFuelSubsecCarVal[cy, ind, "ELC", y_k1]
            el_c = mod.i02ElastNonSubElec[cy, ind, "c", y]
            fpd = mod.imFPDL[ind, k]
            prod_c *= (pk / (pk1 + 1e-10)) ** (el_c * fpd)
        rhs = rhs * prod_c
        return mod.V02UsefulElecNonSubIndTert[cy, ind, y] == rhs

    m.Q02UsefulElecNonSubIndTert = Constraint(
        run_cy, inddom, ytime, rule=_q02_useful_elec_nonsub_rule
    )

    # -------------------------------------------------------------------------
    # Q02FinalElecNonSubIndTert: final = useful / conversion (TELC)
    # -------------------------------------------------------------------------
    def _q02_final_elec_nonsub_rule(mod, cy, ind, y):
        if cy not in run_cy or y not in time_set or ind not in inddom:
            return Constraint.Skip
        # TELC = technology for electricity in subsector
        usc = mod.imUsfEneConvSubTech[cy, ind, "TELC", y]
        return mod.V02FinalElecNonSubIndTert[cy, ind, y] == (
            mod.V02UsefulElecNonSubIndTert[cy, ind, y] / (usc + 1e-10)
        )

    m.Q02FinalElecNonSubIndTert = Constraint(
        run_cy, inddom, ytime, rule=_q02_final_elec_nonsub_rule
    )

    # -------------------------------------------------------------------------
    # Q02ConsFuel: fuel consumption by subsector and fuel
    # -------------------------------------------------------------------------
    def _q02_cons_fuel_rule(mod, cy, sb, e, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        rhs = sum(
            mod.i02ShareBlend[cy, sb, tech, e, y]
            * mod.V02EquipCapTechSubsec[cy, sb, tech, y]
            * mod.i02util[cy, sb, tech, y]
            for tech in itech
            if (sb, tech) in sectech and (tech, e) in itechtoef
        )
        if sb in INDDOM and e in ELCEF:
            rhs = rhs + mod.V02FinalElecNonSubIndTert[cy, sb, y]
        if e in ELCEF:
            rhs = rhs + mod.VmElecConsHeatPla[cy, sb, y]
        return mod.VmConsFuel[cy, sb, e, y] == rhs

    m.Q02ConsFuel = Constraint(run_cy, dsbs, ef, ytime, rule=_q02_cons_fuel_rule)

    # -------------------------------------------------------------------------
    # Q02IndAvrEffFinalUseful: average efficiency = useful / (final - non-sub - heat pump)
    # -------------------------------------------------------------------------
    def _q02_avr_eff_rule(mod, cy, sb, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        total_final = sum(
            mod.VmConsFuel[cy, sb, e, y]
            for e in ef
            if (sb, e) in sectoef
        )
        minus = 0.0
        if sb in INDDOM:
            minus = mod.V02FinalElecNonSubIndTert[cy, sb, y]
        minus = minus + mod.VmElecConsHeatPla[cy, sb, y]
        den = total_final - minus + 1e-6
        return mod.V02IndAvrEffFinalUseful[cy, sb, y] == (
            mod.V02DemSubUsefulSubsec[cy, sb, y] / den
        )

    m.Q02IndAvrEffFinalUseful = Constraint(
        run_cy, dsbs, ytime, rule=_q02_avr_eff_rule
    )

    # -------------------------------------------------------------------------
    # Q02IndxElecIndPrices: electricity price index for industry
    # -------------------------------------------------------------------------
    def _q02_indx_elec_rule(mod, cy, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        # VmPriceElecInd(y-1) * (p_elc/p_avg)^0.02 * (p_elc_2/p_avg_2)^0.01 * (p_elc_3/p_avg_3)^0.01
        p_1 = mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", y_1]
        a_1 = mod.VmPriceFuelAvgSub[cy, "OI", y_1]
        p_2 = mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", ytime[i - 3]] if i >= 3 else p_1
        a_2 = mod.VmPriceFuelAvgSub[cy, "OI", ytime[i - 3]] if i >= 3 else a_1
        p_3 = mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", ytime[i - 4]] if i >= 4 else p_1
        a_3 = mod.VmPriceFuelAvgSub[cy, "OI", ytime[i - 4]] if i >= 4 else a_1
        return mod.V02IndxElecIndPrices[cy, y] == mod.VmPriceElecInd[cy, y_1] * (
            (p_1 / (a_1 + 1e-10)) ** 0.02
            * (p_2 / (a_2 + 1e-10)) ** 0.01
            * (p_3 / (a_3 + 1e-10)) ** 0.01
        )

    m.Q02IndxElecIndPrices = Constraint(run_cy, ytime, rule=_q02_indx_elec_rule)

    # -------------------------------------------------------------------------
    # Q02DemSubUsefulSubsec (GAMS): This equation computes the useful energy demand in each demand subsector (excluding TRANSPORT). This demand is potentially "satisfied" by multiple energy forms/fuels (substitutable demand). The equation follows the "typical useful energy demand" format where the main explanatory variables are activity indicators (imActv) and average weighted technology costs (VmPriceFuelAvgSub). Demand = past demand * (activity ratio)^elast_a * (price ratios)^elast_b * prod(KPDL, price-lag term).
    # -------------------------------------------------------------------------
    def _q02_dem_sub_useful_rule(mod, cy, sb, y):
        if cy not in run_cy or y not in time_set or sb in TRANSE or sb in CDR:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 3:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        y_2 = ytime[i - 3]
        act_1 = mod.imActv[y_1, cy, sb]
        act = mod.imActv[y, cy, sb]
        price = mod.VmPriceFuelAvgSub[cy, sb, y]
        price_1 = mod.VmPriceFuelAvgSub[cy, sb, y_1]
        price_2 = mod.VmPriceFuelAvgSub[cy, sb, y_2]
        cgi = mod.imCGI[cy, y]
        el_a = mod.imElastA[cy, sb, "a", y]
        el_b1 = mod.imElastA[cy, sb, "b1", y]
        el_b2 = mod.imElastA[cy, sb, "b2", y]
        prod_pdl = 1.0
        for k_ord, k in enumerate(kpdl):
            if k_ord >= 6:
                break
            y_k = _year_at(ytime, i - 1 - k_ord)
            y_k1 = _year_at(ytime, i - 2 - k_ord)
            if y_k is None or y_k1 is None:
                continue
            p_k = mod.VmPriceFuelAvgSub[cy, sb, y_k]
            p_k1 = mod.VmPriceFuelAvgSub[cy, sb, y_k1]
            el_c = mod.imElastA[cy, sb, "c", y]
            fpd = mod.imFPDL[sb, k]
            prod_pdl *= (
                (p_k / (p_k1 + 1e-10)) / (cgi ** (1.0 / 6.0) + 1e-10)
            ) ** (el_c * fpd)
        rhs = (
            mod.V02DemSubUsefulSubsec[cy, sb, y_1]
            * (act / (act_1 + 1e-10)) ** el_a
            * (price / (price_1 + 1e-10)) ** el_b1
            * (price_1 / (price_2 + 1e-10)) ** el_b2
            * prod_pdl
        )
        return mod.V02DemSubUsefulSubsec[cy, sb, y] == rhs

    m.Q02DemSubUsefulSubsec = Constraint(
        run_cy, dsbs, ytime, rule=_q02_dem_sub_useful_rule
    )
