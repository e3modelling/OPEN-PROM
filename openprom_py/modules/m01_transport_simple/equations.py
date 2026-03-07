"""
Transport (simple) module — equation definitions.

GENERAL INFORMATION (from GAMS):
  Equation format: "typical useful energy demand equation".
  The main explanatory variables (drivers) are activity indicators (economic activity)
  and corresponding energy costs. The type of "demand" is computed based on its past value,
  the ratio of the current and past activity indicators (with the corresponding elasticity),
  and the ratio of lagged energy costs (with the corresponding elasticities). This captures
  both short term and long term reactions to energy costs.

All equation names and comments mirror 01_Transport/simple/equations.gms.

Convergence: Activity constraints (Q01ActivGoodsTransp, Q01ActivPassTrnsp) are scaled by
ACTIVITY_SCALE so the residual seen by the solver is O(1) when activity is in Mtoe (1e6).
This reduces constraint violation magnitude and helps Ipopt converge.
"""
from pyomo.core import Constraint
from pyomo.environ import exp as pyo_exp, sqrt

from core import sets as core_sets

# Scale for activity equilibrium constraints (residual = (lhs - rhs) / scale)
# Use 1e6 so when activity is in millions the scaled residual is O(1); improves convergence.
ACTIVITY_SCALE = 1e6


def _ord(ytime_list, y):
    """1-based position of year y in ytime (GAMS ord(ytime))."""
    try:
        return ytime_list.index(y) + 1
    except ValueError:
        return 0


def _year_at_ord(ytime_list, ord_val):
    """Year at 1-based position ord_val (GAMS ytime-ord)."""
    if ord_val < 1 or ord_val > len(ytime_list):
        return None
    return ytime_list[ord_val - 1]


def add_transport_equations(m, core_sets_obj):
    """Add all 01_Transport (simple) constraints to the model."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    ttech = list(core_sets.TTECH)
    trans = list(core_sets.TRANSE)
    tranp = list(core_sets.TRANP)
    trang = list(core_sets.TRANG)
    ef = list(core_sets.EF)
    kpdl = list(core_sets.KPDL)
    tech = list(core_sets.TECH)
    TECHS = core_sets.TECHS
    PLUGIN = core_sets.PLUGIN
    RENEF = core_sets.RENEF

    # -------------------------------------------------------------------------
    # Q01Lft: Lifetime of passenger cars = inverse of scrapping rate.
    # This equation calculates the lifetime of passenger cars as the inverse
    # of their scrapping rate.
    # -------------------------------------------------------------------------
    def _q01_lft_rule(mod, cy, tech, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        if ("PC", tech) not in core_sets.SECTTECH:
            return Constraint.Skip
        return mod.VmLft[cy, "PC", tech, y] == 1.0 / mod.V01RateScrPc[cy, tech, y]

    m.Q01Lft = Constraint(run_cy, ttech, ytime, rule=_q01_lft_rule)

    # -------------------------------------------------------------------------
    # Q01ActivGoodsTransp: Activity for goods transport (trucks GU, other freight GT/GN).
    # The activity is influenced by GDP, population, fuel prices, and elasticities.
    # Trucks (GU): one form; other freight: includes cross-term with GU activity.
    # -------------------------------------------------------------------------
    def _q01_activ_goods_rule(mod, cy, tran, y):
        if cy not in run_cy or y not in time_set or tran not in trang:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        y_2 = ytime[i - 3] if i >= 3 else y_1
        gdp_cap = mod.i01GDPperCapita[y, cy]
        gdp_cap_1 = mod.i01GDPperCapita[y_1, cy]
        gdp_cap_2 = mod.i01GDPperCapita[y_2, cy]
        price = mod.VmPriceFuelAvgSub[cy, tran, y]
        price_1 = mod.VmPriceFuelAvgSub[cy, tran, y_1]
        price_2 = mod.VmPriceFuelAvgSub[cy, tran, y_2]
        cgi = mod.imCGI[cy, y]
        act_1 = mod.V01ActivGoodsTransp[cy, tran, y_1]
        pop = mod.i01Pop[y, cy]
        pop_1 = mod.i01Pop[y_1, cy]
        # PDL product over kpdl
        prod_pdl = 1.0
        for k_ord, k in enumerate(kpdl, start=1):
            if k_ord > 6:
                break
            y_k = _year_at_ord(ytime, i - k_ord)
            y_k1 = _year_at_ord(ytime, i - k_ord - 1)
            if y_k is None or y_k1 is None:
                continue
            p_k = mod.VmPriceFuelAvgSub[cy, tran, y_k]
            p_k1 = mod.VmPriceFuelAvgSub[cy, tran, y_k1]
            fpd = mod.imFPDL[tran, k]
            ela = mod.imElastA[cy, tran, "c3", y]
            prod_pdl *= ((p_k / p_k1) / (cgi ** (1.0 / 6.0))) ** (ela * fpd)
        if tran == "GU":
            rhs = (
                act_1
                * (gdp_cap / gdp_cap_1) ** 0.4
                * (pop / pop_1) ** 0.8
                * (price / price_1) ** mod.imElastA[cy, tran, "c1", y]
                * (price_1 / price_2) ** mod.imElastA[cy, tran, "c2", y]
                * prod_pdl
            )
            lhs = mod.V01ActivGoodsTransp[cy, tran, y]
            return (lhs - rhs) / ACTIVITY_SCALE == 0
        else:
            act_gu = mod.V01ActivGoodsTransp[cy, "GU", y]
            act_gu_1 = mod.V01ActivGoodsTransp[cy, "GU", y_1]
            rhs = (
                act_1
                * (gdp_cap / gdp_cap_1) ** mod.imElastA[cy, tran, "a", y]
                * (price / price_1) ** mod.imElastA[cy, tran, "c1", y]
                * (price_1 / price_2) ** mod.imElastA[cy, tran, "c2", y]
                * prod_pdl
                * ((act_gu + 1e-6) / (act_gu_1 + 1e-6)) ** mod.imElastA[cy, tran, "c4", y]
            )
        lhs = mod.V01ActivGoodsTransp[cy, tran, y]
        return (lhs - rhs) / ACTIVITY_SCALE == 0

    m.Q01ActivGoodsTransp = Constraint(run_cy, trang, ytime, rule=_q01_activ_goods_rule)

    # -------------------------------------------------------------------------
    # Q01GapTranspActiv: Gap in transport activity to be filled by new technologies.
    # Calculated separately for passenger cars, other passenger modes, and goods transport.
    # -------------------------------------------------------------------------
    def _q01_gap_rule(mod, cy, tran, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        i = _ord(ytime, y)
        y_1 = ytime[i - 2] if i >= 2 else y
        # PC: gap = new registrations
        if tran == "PC":
            return mod.V01GapTranspActiv[cy, tran, y] == mod.V01NewRegPcYearly[cy, y]
        # Other passenger (PT, PB, PN): smooth formula with lifetime
        if tran in tranp and tran != "PC":
            n_tech = TECHS.get(tran, 1)
            sum_lft = sum(
                mod.VmLft[cy, tran, t, y_1]
                for t in ttech
                if (tran, t) in core_sets.SECTTECH
            )
            avg_lft = sum_lft / n_tech if n_tech else 1.0
            act = mod.V01ActivPassTrnsp[cy, tran, y]
            act_1 = mod.V01ActivPassTrnsp[cy, tran, y_1]
            inner = act - act_1 + act_1 / avg_lft
            rhs = (inner + sqrt(inner**2 + 1e-4)) / 2.0
            return mod.V01GapTranspActiv[cy, tran, y] == rhs
        # Goods (GU, GT, GN)
        if tran in trang:
            n_tech = TECHS.get(tran, 1)
            sum_lft = sum(
                mod.VmLft[cy, tran, t, y_1]
                for t in ttech
                if (tran, t) in core_sets.SECTTECH
            )
            avg_lft = sum_lft / n_tech if n_tech else 1.0
            act = mod.V01ActivGoodsTransp[cy, tran, y]
            act_1 = mod.V01ActivGoodsTransp[cy, tran, y_1]
            inner = act - act_1 + act_1 / avg_lft
            rhs = (inner + sqrt(inner**2 + 1e-4)) / 2.0
            return mod.V01GapTranspActiv[cy, tran, y] == rhs
        return Constraint.Skip

    m.Q01GapTranspActiv = Constraint(run_cy, trans, ytime, rule=_q01_gap_rule)

    # -------------------------------------------------------------------------
    # Q01CapCostAnnualized: Annualized capital cost of new transport technologies.
    # Converts upfront investment into equivalent annual payments (annuity factor).
    # Includes state subsidy (VmSubsiDemTech).
    # -------------------------------------------------------------------------
    def _q01_cap_cost_rule(mod, cy, tran, tech, y):
        if cy not in run_cy or y not in time_set or (tran, tech) not in core_sets.SECTTECH:
            return Constraint.Skip
        d = mod.imDisc[cy, tran, y]
        lft = mod.VmLft[cy, tran, tech, y]
        num = d * pyo_exp(d * lft)
        den = pyo_exp(d * lft) - 1.0
        cap = mod.imCapCostTech[cy, tran, tech, y]
        sub = mod.VmSubsiDemTech[cy, tran, tech, y]
        cgi = mod.imCGI[cy, y]
        # Avoid using den in a Python boolean context; instead express the annuity
        # factor by multiplying both sides:
        #   annuity = num / den
        #   V01CapCostAnnualized = annuity * (cap - sub) * cgi
        # -> den * V01CapCostAnnualized = num * (cap - sub) * cgi
        return den * mod.V01CapCostAnnualized[cy, tran, tech, y] == num * (cap - sub) * cgi

    m.Q01CapCostAnnualized = Constraint(run_cy, trans, ttech, ytime, rule=_q01_cap_cost_rule)

    # -------------------------------------------------------------------------
    # Q01CostFuel: Total fuel cost for transport technologies.
    # Includes: SFC * fuel prices; plug-in hybrid electric/non-electric split;
    # variable cost; renewable value for non-renewable techs. Scaled by activity.
    # -------------------------------------------------------------------------
    def _q01_cost_fuel_rule(mod, cy, tran, tech, y):
        if cy not in run_cy or y not in time_set or (tran, tech) not in core_sets.SECTTECH:
            return Constraint.Skip
        fuel_part = 0.0
        if tech not in PLUGIN:
            for e in ef:
                if (tech, e) not in core_sets.TTECHtoEF:
                    continue
                fuel_part += (
                    mod.V01ConsSpecificFuel[cy, tran, tech, e, y]
                    * mod.i01ShareBlend[cy, tran, e, y]
                    * mod.VmPriceFuelSubsecCarVal[cy, tran, e, y]
                )
        else:
            share_elec = mod.i01ShareAnnMilePlugInHybrid[cy, y]
            for e in ef:
                if (tech, e) not in core_sets.TTECHtoEF or e == "ELC":
                    continue
                fuel_part += (
                    (1.0 - share_elec)
                    * mod.i01ShareBlend[cy, tran, e, y]
                    * mod.V01ConsSpecificFuel[cy, tran, tech, e, y]
                    * mod.VmPriceFuelSubsecCarVal[cy, tran, e, y]
                )
            fuel_part += (
                share_elec
                * mod.V01ConsSpecificFuel[cy, tran, tech, "ELC", y]
                * mod.VmPriceFuelSubsecCarVal[cy, tran, "ELC", y]
            )
        var_cost = mod.imVarCostTech[cy, tran, tech, y]
        ren_val = mod.VmRenValue[y] / 1000.0 if tech not in RENEF else 0.0
        cost = fuel_part + var_cost + ren_val
        # Activity scaling
        if tran == "PC":
            scale = 1e-3 * mod.V01ActivPassTrnsp[cy, tran, y]
        elif tran == "PT":
            scale = 1e-1 * mod.V01ActivPassTrnsp[cy, tran, y]
        elif tran == "PB":
            scale = 1e3 * mod.V01ActivPassTrnsp[cy, tran, y]
        elif tran == "PN":
            scale = 1.0 * mod.V01ActivPassTrnsp[cy, tran, y]
        elif tran == "PA":
            scale = 1.0 * mod.V01ActivPassTrnsp[cy, tran, y]
        elif tran in trang:
            scale = 1e-5 * mod.V01ActivGoodsTransp[cy, tran, y]
        else:
            scale = 1.0
        return mod.V01CostFuel[cy, tran, tech, y] == cost * scale

    m.Q01CostFuel = Constraint(run_cy, trans, ttech, ytime, rule=_q01_cost_fuel_rule)

    # -------------------------------------------------------------------------
    # Q01CostTranspPerMeanConsSize: Total cost per transport unit.
    # Sum of annualized capital cost, fixed O&M, and fuel cost.
    # -------------------------------------------------------------------------
    def _q01_cost_transp_rule(mod, cy, tran, tech, y):
        if cy not in run_cy or y not in time_set or (tran, tech) not in core_sets.SECTTECH:
            return Constraint.Skip
        return (
            mod.V01CostTranspPerMeanConsSize[cy, tran, tech, y]
            == mod.V01CapCostAnnualized[cy, tran, tech, y]
            + mod.imFixOMCostTech[cy, tran, tech, y]
            + mod.V01CostFuel[cy, tran, tech, y]
        )

    m.Q01CostTranspPerMeanConsSize = Constraint(
        run_cy, trans, ttech, ytime, rule=_q01_cost_transp_rule
    )

    # -------------------------------------------------------------------------
    # Q01ShareTechTr: Share of each transport technology in total sectoral use.
    # imMatrFactor = maturity factor; share ∝ imMatrFactor * cost^(-3).
    # -------------------------------------------------------------------------
    def _q01_share_tech_rule(mod, cy, tran, tech, y):
        if cy not in run_cy or y not in time_set or (tran, tech) not in core_sets.SECTTECH:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        num = mod.imMatrFactor[cy, tran, tech, y] * (
            mod.V01CostTranspPerMeanConsSize[cy, tran, tech, y_1] + 1e-6
        ) ** (-3)
        den = sum(
            mod.imMatrFactor[cy, tran, t2, y]
            * (mod.V01CostTranspPerMeanConsSize[cy, tran, t2, y_1] + 1e-6) ** (-3)
            for t2 in ttech
            if (tran, t2) in core_sets.SECTTECH
        )
        # Avoid "if den == 0" (den is a Pyomo expression). Use: den * V01ShareTechTr == num
        return den * mod.V01ShareTechTr[cy, tran, tech, y] == num

    m.Q01ShareTechTr = Constraint(run_cy, trans, tech, ytime, rule=_q01_share_tech_rule)

    # -------------------------------------------------------------------------
    # Q01ConsTechTranspSectoral: Consumption of each technology in transport sectors (Mtoe).
    # Considers lifetime, capacity, load factor, scrapping rate, SFC, gap activity.
    # -------------------------------------------------------------------------
    def _q01_cons_tech_rule(mod, cy, tran, tech, e, y):
        if (
            cy not in run_cy
            or y not in time_set
            or (tran, tech) not in core_sets.SECTTECH
            or (tech, e) not in core_sets.TTECHtoEF
        ):
            return Constraint.Skip
        i = _ord(ytime, y)
        y_1 = ytime[i - 2] if i >= 2 else y
        # Surviving stock term
        if tran == "PC":
            surv = 1.0 - mod.V01RateScrPcTot[cy, tech, y]
        else:
            lft_1 = mod.VmLft[cy, tran, tech, y_1]
            cap_1 = mod.i01AvgVehCapLoadFac[cy, tran, "CAP", y_1]
            lf_1 = mod.i01AvgVehCapLoadFac[cy, tran, "LF", y_1]
            cap = mod.i01AvgVehCapLoadFac[cy, tran, "CAP", y]
            lf = mod.i01AvgVehCapLoadFac[cy, tran, "LF", y]
            # Avoid (cap * lf) != 0 in Python; use epsilon so denominator is never zero
            surv = (lft_1 - 1) / lft_1 * cap_1 * lf_1 / (cap * lf + 1e-10)
        part1 = mod.V01ConsTechTranspSectoral[cy, tran, tech, e, y_1] * surv
        # New equipment term: share * blend * SFC * gap * activity factor / 1000
        if tech in PLUGIN:
            share_elec = mod.i01ShareAnnMilePlugInHybrid[cy, y]
            if e == "ELC":
                blend_sfc = share_elec * mod.V01ConsSpecificFuel[cy, tran, tech, "ELC", y]
            else:
                blend_sfc = (
                    (1.0 - share_elec)
                    * mod.i01ShareBlend[cy, tran, e, y]
                    * mod.V01ConsSpecificFuel[cy, tran, tech, e, y]
                )
        else:
            blend_sfc = (
                mod.i01ShareBlend[cy, tran, e, y]
                * mod.V01ConsSpecificFuel[cy, tran, tech, e, y]
            )
        if tran == "PC":
            act_fac = mod.V01ActivPassTrnsp[cy, tran, y]
        else:
            cap_1 = mod.i01AvgVehCapLoadFac[cy, tran, "CAP", y_1]
            lf_1 = mod.i01AvgVehCapLoadFac[cy, tran, "LF", y_1]
            cap = mod.i01AvgVehCapLoadFac[cy, tran, "CAP", y]
            lf = mod.i01AvgVehCapLoadFac[cy, tran, "LF", y]
            # Avoid (cap * lf) != 0 in Python; use epsilon so denominator is never zero
            act_fac = cap_1 * lf_1 / (cap * lf + 1e-10)
        part2 = (
            mod.V01ShareTechTr[cy, tran, tech, y]
            * blend_sfc
            / 1000.0
            * mod.V01GapTranspActiv[cy, tran, y]
            * act_fac
        )
        return mod.V01ConsTechTranspSectoral[cy, tran, tech, e, y] == part1 + part2

    m.Q01ConsTechTranspSectoral = Constraint(
        run_cy, trans, ttech, ef, ytime, rule=_q01_cons_tech_rule
    )

    # -------------------------------------------------------------------------
    # Q01DemFinEneTranspPerFuel: Final energy demand in transport per fuel (Mtoe).
    # Sum of consumption over technologies for that fuel.
    # -------------------------------------------------------------------------
    def _q01_dem_fin_rule(mod, cy, tran, e, y):
        if (
            cy not in run_cy
            or y not in time_set
            or (tran, e) not in core_sets.SECtoEF
        ):
            return Constraint.Skip
        rhs = sum(
            mod.V01ConsTechTranspSectoral[cy, tran, t, e, y]
            for t in ttech
            if (tran, t) in core_sets.SECTTECH and (t, e) in core_sets.TTECHtoEF
        )
        return mod.VmDemFinEneTranspPerFuel[cy, tran, e, y] == rhs

    m.Q01DemFinEneTranspPerFuel = Constraint(
        run_cy, trans, ef, ytime, rule=_q01_dem_fin_rule
    )

    # --- Commented out in GAMS (01_Transport/legacy/equations.gms $ontext) ---
    # q01DemFinEneSubTransp(allCy,TRANSE,YTIME)$(TIME(YTIME) $runCy(allCy))..
    #     v01DemFinEneSubTransp(allCy,TRANSE,YTIME) =E= sum(EF, VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME));

    # -------------------------------------------------------------------------
    # Q01StockPcYearly: Total stock of passenger cars (million vehicles).
    # Stock = ownership ratio * (population * 1000).
    # -------------------------------------------------------------------------
    def _q01_stock_pc_rule(mod, cy, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        return mod.V01StockPcYearly[cy, y] == mod.V01PcOwnPcLevl[cy, y] * (
            mod.i01Pop[y, cy] * 1000.0
        )

    m.Q01StockPcYearly = Constraint(run_cy, ytime, rule=_q01_stock_pc_rule)

    # -------------------------------------------------------------------------
    # Q01StockPcYearlyTech: Stock of passenger cars per technology.
    # Stock_tech(t) = Stock_tech(t-1)*(1 - RateScrPcTot) + NewRegTech.
    # -------------------------------------------------------------------------
    def _q01_stock_tech_rule(mod, cy, tech, y):
        if (
            cy not in run_cy
            or y not in time_set
            or ("PC", tech) not in core_sets.SECTTECH
        ):
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        return (
            mod.V01StockPcYearlyTech[cy, tech, y]
            == mod.V01StockPcYearlyTech[cy, tech, y_1]
            * (1.0 - mod.V01RateScrPcTot[cy, tech, y])
            + mod.V01NewRegPcTechYearly[cy, tech, y]
        )

    m.Q01StockPcYearlyTech = Constraint(run_cy, ttech, ytime, rule=_q01_stock_tech_rule)

    # -------------------------------------------------------------------------
    # Q01NewRegPcTechYearly: New registrations per technology = share * gap(PC).
    # -------------------------------------------------------------------------
    def _q01_new_reg_tech_rule(mod, cy, tech, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        return mod.V01NewRegPcTechYearly[cy, tech, y] == mod.V01ShareTechTr[
            cy, "PC", tech, y
        ] * mod.V01GapTranspActiv[cy, "PC", y]

    m.Q01NewRegPcTechYearly = Constraint(run_cy, ttech, ytime, rule=_q01_new_reg_tech_rule)

    # -------------------------------------------------------------------------
    # Q01NewRegPcYearly: New registrations of passenger cars (million).
    # Stock - Stock_1 + NumScrap + sqrt(sqr(Stock - Stock_1 + NumScrap)).
    # -------------------------------------------------------------------------
    def _q01_new_reg_rule(mod, cy, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        i = _ord(ytime, y)
        y_1 = ytime[i - 2] if i >= 2 else y
        stock = mod.V01StockPcYearly[cy, y]
        stock_1 = mod.V01StockPcYearly[cy, y_1]
        num_scrap = mod.V01NumPcScrap[cy, y]
        inner = stock - stock_1 + num_scrap
        rhs = inner + sqrt(inner**2 + 1e-10)
        return mod.V01NewRegPcYearly[cy, y] == rhs

    m.Q01NewRegPcYearly = Constraint(run_cy, ytime, rule=_q01_new_reg_rule)

    # -------------------------------------------------------------------------
    # Q01ActivPassTrnsp: Passenger transport activity (PC: km/veh, PA: Mpax, else Gpkm).
    # Passenger cars: price elasticities, ownership ratio, GDP per capita.
    # Aviation (PA): GDP per capita and price elasticities.
    # Other passenger (PT, PB, PN): GDP per capita, prices, PDL, and car-stock cross term.
    # -------------------------------------------------------------------------
    def _q01_activ_pass_rule(mod, cy, tran, y):
        if cy not in run_cy or y not in time_set or tran not in tranp:
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 3:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        y_2 = ytime[i - 3]
        act_1 = mod.V01ActivPassTrnsp[cy, tran, y_1]
        price = mod.VmPriceFuelAvgSub[cy, tran, y]
        price_1 = mod.VmPriceFuelAvgSub[cy, tran, y_1]
        price_2 = mod.VmPriceFuelAvgSub[cy, tran, y_2]
        gdp_cap = mod.i01GDPperCapita[y, cy]
        gdp_cap_1 = mod.i01GDPperCapita[y_1, cy]
        gdp_cap_2 = mod.i01GDPperCapita[y_2, cy]
        pop = mod.i01Pop[y, cy]
        pop_1 = mod.i01Pop[y_1, cy]
        if tran == "PC":
            stock = mod.V01StockPcYearly[cy, y]
            own_1 = mod.V01PcOwnPcLevl[cy, y_1]
            # Avoid "if own_1 and (pop*1000)" (own_1 is a Var). Use epsilon in denominator.
            ratio_own = (stock / (pop * 1000.0 + 1e-10)) / (own_1 + 1e-10)
            rhs = (
                act_1
                * (price / price_1) ** mod.imElastA[cy, tran, "b1", y]
                * (price_1 / price_2) ** mod.imElastA[cy, tran, "b2", y]
                * ratio_own ** mod.imElastA[cy, tran, "b3", y]
                * (gdp_cap / gdp_cap_1) ** 0.2
            )
        elif tran == "PA":
            rhs = (
                act_1
                * (gdp_cap / gdp_cap_1) ** mod.imElastA[cy, tran, "a", y]
                * (price / price_1) ** mod.imElastA[cy, tran, "c1", y]
                * (price_1 / price_2) ** mod.imElastA[cy, tran, "c2", y]
            )
        else:
            # Avoid "if pop" (pop can be Param/Var). Use epsilon in denominator.
            gdp_pop = mod.i01GDP[y, cy] / (pop + 1e-10)
            gdp_pop_1 = mod.i01GDP[y_1, cy] / (pop_1 + 1e-10)
            stock = mod.V01StockPcYearly[cy, y]
            stock_1 = mod.V01StockPcYearly[cy, y_1]
            act_pc = mod.V01ActivPassTrnsp[cy, "PC", y]
            act_pc_1 = mod.V01ActivPassTrnsp[cy, "PC", y_1]
            # Avoid "if (stock_1 * act_pc_1)" (Vars). Use epsilon in denominator.
            cross = (stock * act_pc) / (stock_1 * act_pc_1 + 1e-10)
            prod_pdl = 1.0
            for k_ord, k in enumerate(kpdl, start=1):
                if k_ord > 6:
                    break
                y_k = _year_at_ord(ytime, i - k_ord)
                y_k1 = _year_at_ord(ytime, i - k_ord - 1)
                if y_k is None or y_k1 is None:
                    continue
                p_k = mod.VmPriceFuelAvgSub[cy, tran, y_k]
                p_k1 = mod.VmPriceFuelAvgSub[cy, tran, y_k1]
                cgi = mod.imCGI[cy, y]
                fpd = mod.imFPDL[tran, k]
                ela = mod.imElastA[cy, tran, "c3", y]
                prod_pdl *= ((p_k / p_k1) / (cgi ** (1.0 / 6.0))) ** (ela * fpd)
            rhs = (
                act_1
                * (gdp_pop / gdp_pop_1) ** mod.imElastA[cy, tran, "a", y]
                * (price / price_1) ** mod.imElastA[cy, tran, "c1", y]
                * (price_1 / price_2) ** mod.imElastA[cy, tran, "c2", y]
                * cross ** mod.imElastA[cy, tran, "c4", y]
                * prod_pdl
            )
        lhs = mod.V01ActivPassTrnsp[cy, tran, y]
        return (lhs - rhs) / ACTIVITY_SCALE == 0

    m.Q01ActivPassTrnsp = Constraint(run_cy, tranp, ytime, rule=_q01_activ_pass_rule)

    # -------------------------------------------------------------------------
    # Q01NumPcScrap: Number of scrapped passenger cars = sum over tech of rate * stock_tech_1.
    # -------------------------------------------------------------------------
    def _q01_num_scrap_rule(mod, cy, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        i = _ord(ytime, y)
        y_1 = ytime[i - 2] if i >= 2 else y
        rhs = sum(
            mod.V01RateScrPcTot[cy, t, y] * mod.V01StockPcYearlyTech[cy, t, y_1]
            for t in ttech
        )
        return mod.V01NumPcScrap[cy, y] == rhs

    m.Q01NumPcScrap = Constraint(run_cy, ytime, rule=_q01_num_scrap_rule)

    # -------------------------------------------------------------------------
    # Q01PcOwnPcLevl: Vehicle ownership per capita (Gompertz function).
    # Saturation effect with GDP per capita; asymptote = i01PassCarsMarkSat.
    # -------------------------------------------------------------------------
    def _q01_pc_own_rule(mod, cy, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        s1 = mod.i01Sigma[cy, "S1"]
        s2 = mod.i01Sigma[cy, "S2"]
        gdp_cap = mod.i01GDPperCapita[y, cy]
        sat = mod.i01PassCarsMarkSat[cy]
        return mod.V01PcOwnPcLevl[cy, y] == sat * pyo_exp(
            -s1 * pyo_exp(-s2 * gdp_cap / 10000.0)
        )

    m.Q01PcOwnPcLevl = Constraint(run_cy, ytime, rule=_q01_pc_own_rule)

    # -------------------------------------------------------------------------
    # Q01RateScrPc: Scrapping rate of passenger cars.
    # Influenced by GDP per capita ratio (y vs y-1); dynamic over time.
    # -------------------------------------------------------------------------
    def _q01_rate_scr_rule(mod, cy, tech, y):
        if (
            cy not in run_cy
            or y not in time_set
            or ("PC", tech) not in core_sets.SECTTECH
        ):
            return Constraint.Skip
        i = _ord(ytime, y)
        if i < 2:
            return Constraint.Skip
        y_1 = ytime[i - 2]
        return mod.V01RateScrPc[cy, tech, y] == mod.V01RateScrPc[cy, tech, y_1] * (
            mod.i01GDPperCapita[y, cy] / mod.i01GDPperCapita[y_1, cy]
        ) ** 0.1

    m.Q01RateScrPc = Constraint(run_cy, ttech, ytime, rule=_q01_rate_scr_rule)

    # -------------------------------------------------------------------------
    # Q01RateScrPcTot: Total scrapping rate = 1 - (1 - RateScrPc)*(1 - PremScrp).
    # -------------------------------------------------------------------------
    def _q01_rate_scr_tot_rule(mod, cy, tech, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        return mod.V01RateScrPcTot[cy, tech, y] == 1.0 - (
            1.0 - mod.V01RateScrPc[cy, tech, y]
        ) * (1.0 - mod.V01PremScrp[cy, "PC", tech, y])

    m.Q01RateScrPcTot = Constraint(run_cy, ttech, ytime, rule=_q01_rate_scr_tot_rule)

    # -------------------------------------------------------------------------
    # Q01PremScrp: Premature scrapping probability.
    # Depends on cost of this tech vs others (i01PremScrpFac and cost terms).
    # -------------------------------------------------------------------------
    def _q01_prem_scrp_rule(mod, cy, tran, tech, y):
        if (
            cy not in run_cy
            or y not in time_set
            or (tran, tech) not in core_sets.SECTTECH
        ):
            return Constraint.Skip
        cost_this = (mod.V01CostFuel[cy, tran, tech, y] + 1e-4) ** (-2)
        other_sum = sum(
            (mod.V01CostTranspPerMeanConsSize[cy, tran, t2, y] + 1e-4) ** (-2)
            for t2 in ttech
            if t2 != tech and (tran, t2) in core_sets.SECTTECH
        )
        den = cost_this + mod.i01PremScrpFac[cy, tran, tech, y] * other_sum
        # Avoid "if den == 0" (den is a Pyomo expression). Use: den * V01PremScrp == den - cost_this
        return den * mod.V01PremScrp[cy, tran, tech, y] == den - cost_this

    m.Q01PremScrp = Constraint(run_cy, trans, ttech, ytime, rule=_q01_prem_scrp_rule)
