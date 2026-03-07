"""
Module 03_RestOfEnergy (legacy): equation definitions.

Mirrors modules/03_RestOfEnergy/legacy/equations.gms. Each constraint is documented
with the corresponding GAMS equation name and the GAMS *' description text so that
non-specialists can follow what each equation does. Descriptions transferred from GAMS.
"""

from pyomo.core import Constraint

from core import sets as core_sets

# Small epsilon to avoid division by zero in ratio terms (GAMS uses 1e-6).
_EPS = 1e-6

# Sets used in multiple rules
TRANSE = set(core_sets.TRANSE)
INDDOM = set(core_sets.INDDOM)
NENSE = set(core_sets.NENSE)
SECtoEFPROD = core_sets.SECtoEFPROD
SECtoEF = core_sets.SECtoEF
EFtoEFS = core_sets.EFtoEFS
ELCEF = set(core_sets.ELCEF)
H2EF = set(core_sets.H2EF)
IMPEF = set(core_sets.IMPEF)
STEAM_EFS = set(core_sets.STEAM_EFS)

# EFS that belong to LQD aggregate (for transfers and refinery equations)
_EFS_LQD = [efs for (ss, efs) in SECtoEFPROD if ss == "LQD"]


def _year_prev(ytime_list, y):
    """Return previous year in ytime list, or None if first year."""
    try:
        i = ytime_list.index(y)
        if i <= 0:
            return None
        return ytime_list[i - 1]
    except ValueError:
        return None


def _year_at(ytime_list, y, offset):
    """Return year at index(current) + offset; None if out of range."""
    try:
        i = ytime_list.index(y)
        j = i + offset
        if j < 0 or j >= len(ytime_list):
            return None
        return ytime_list[j]
    except ValueError:
        return None


def add_rest_of_energy_equations(m, core_sets_obj):
    """
    Add all Q03* constraints for the RestOfEnergy (legacy) module.

    Order matches GAMS. Constraints that depend on lagged variables use
    _year_prev() to get the previous year; we skip the constraint if
    the previous year is not in the time set.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    ssbs = list(core_sets.SSBS)
    efs = list(core_sets.EFS)
    toctef = list(core_sets.TOCTEF)
    tsteam = list(core_sets.TSTEAM)
    kpdl_list = [k for k in core_sets.KPDL][:5]  # a1..a5
    base_y = core_sets_obj.tFirst if hasattr(core_sets_obj, "tFirst") else (ytime[0] if ytime else None)

    # -------------------------------------------------------------------------
    # Q03ConsFinEneCountry (GAMS): The equation computes the total final energy consumption in million tonnes of oil equivalent for each country, energy form sector, and time period. The total final energy consumption is calculated as the sum of final energy consumption in the Industry and Tertiary sectors and the sum of final energy demand in all transport subsectors. The consumption is determined by the relevant link between model subsectors and fuels. Plus VmConsFuelCDRProd(EFS).
    # -------------------------------------------------------------------------
    def _q03_cons_fin_ene_country_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        lhs = 0.0
        # Sum over industry/domestic subsectors and fuels that map to this EFS
        for (sbs, ef) in SECtoEF:
            if sbs not in INDDOM:
                continue
            if (ef, efs_) not in EFtoEFS:
                continue
            lhs += mod.VmConsFuel[cy, sbs, ef, y]
        # Sum over transport subsectors and fuels
        for (sbs, ef) in SECtoEF:
            if sbs not in TRANSE:
                continue
            if (ef, efs_) not in EFtoEFS:
                continue
            lhs += mod.VmDemFinEneTranspPerFuel[cy, sbs, ef, y]
        # CDR production fuel use (stub if not present)
        lhs += mod.VmConsFuelCDRProd[cy, efs_, y]
        return mod.VmConsFinEneCountry[cy, efs_, y] == lhs

    m.Q03ConsFinEneCountry = Constraint(
        run_cy, efs, ytime,
        rule=_q03_cons_fin_ene_country_rule,
    )

    # --- Commented out in GAMS ($ontext ... $offtext) ---
    # q03ConsTotFinEne(YTIME)$(TIME(YTIME))..
    #     v03ConsTotFinEne(YTIME) =E= sum((allCy,EFS), VmConsFinEneCountry(allCy,EFS,YTIME));

    # -------------------------------------------------------------------------
    # Q03ConsFinNonEne (GAMS): The equation computes the final non-energy consumption in million tonnes of oil equivalent for a given energy form sector. The calculation involves summing the consumption of fuels in each non-energy and bunkers demand subsector based on the corresponding fuel aggregation for the supply side. This process is performed for each time period. (Excluding BU.)
    # -------------------------------------------------------------------------
    def _q03_cons_fin_non_ene_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        lhs = 0.0
        for nense in NENSE:
            if nense == "BU":
                continue
            if (nense, efs_) not in SECtoEF:
                continue
            lhs += mod.VmConsFuel[cy, nense, efs_, y]
        return mod.VmConsFinNonEne[cy, efs_, y] == lhs

    m.Q03ConsFinNonEne = Constraint(
        run_cy, efs, ytime,
        rule=_q03_cons_fin_non_ene_rule,
    )

    # -------------------------------------------------------------------------
    # Q03LossesDistr (GAMS): The equation computes the distribution losses in million tonnes of oil equivalent for a given energy form sector. The losses are determined by the rate of losses over available for final consumption multiplied by the sum of total final energy consumption and final non-energy consumption. This calculation is performed for each time period. Please note that distribution losses are not considered for the hydrogen sector (H2 uses a different term: VmDemTotH2 - sum VmDemSecH2).
    # -------------------------------------------------------------------------
    def _q03_losses_distr_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        if efs_ in H2EF:
            # Hydrogen: losses = total H2 demand minus sectoral H2 demand (stub vars fixed to 0)
            sbs_list = list(core_sets.SBS)
            return mod.VmLossesDistr[cy, efs_, y] == (
                mod.VmDemTotH2[cy, y] - sum(mod.VmDemSecH2[cy, sb, y] for sb in sbs_list)
            )
        denom = (
            mod.VmConsFinEneCountry[cy, efs_, y]
            + mod.VmConsFinNonEne[cy, efs_, y]
            + (mod.V03ProdPrimary[cy, "CRO", y] if efs_ == "CRO" else 0.0)
        )
        # Guard: if denominator would be 0, set losses to 0
        rate = mod.imRateLossesFinCons[cy, efs_, y]
        return mod.VmLossesDistr[cy, efs_, y] == rate * denom

    m.Q03LossesDistr = Constraint(
        run_cy, efs, ytime,
        rule=_q03_losses_distr_rule,
    )

    # -------------------------------------------------------------------------
    # Q03OutTransfCHP (GAMS): CHP transformation output. STE = sum(TSTEAM, VmProdSte); ELC = V04ProdElecEstCHP * smTWhToMtoe.
    # -------------------------------------------------------------------------
    def _q03_out_transf_chp_rule(mod, cy, tocef, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        if tocef == "STE":
            lhs = sum(mod.VmProdSte[cy, t, y] for t in tsteam)
        else:
            lhs = mod.V04ProdElecEstCHP[cy, y] * mod.smTWhToMtoe
        return mod.V03OutTransfCHP[cy, tocef, y] == lhs

    m.Q03OutTransfCHP = Constraint(
        run_cy, toctef, ytime,
        rule=_q03_out_transf_chp_rule,
    )

    # --- Commented out in GAMS ($ontext ... $offtext) ---
    # Q03CapRef(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    #     V03CapRef(allCy,YTIME) =E=
    #     [
    #       i03ResRefCapacity(allCy,YTIME) * V03CapRef(allCy,YTIME-1) *
    #       (1$(ord(YTIME) le 10) +
    #       (prod(rc,
    #       (sum(EFS$EFtoEFA(EFS,"LQD"),VmConsFinEneCountry(...))/sum(...))**(0.5/(ord(rc)+1)))
    #       ) $(ord(YTIME) gt 10)
    #     ]$i03RefCapacity(allCy,"%fStartHorizon%")+0;

    # -------------------------------------------------------------------------
    # Q03OutTransfRefSpec (GAMS): The equation calculates the transformation output from refineries for a specific energy form in a given scenario and year. The output is computed based on a residual factor, the previous year's output, and the change in refineries' capacity. The calculation includes considerations for the base year and adjusts the result accordingly. The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
    # -------------------------------------------------------------------------
    def _q03_out_transf_ref_spec_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        if ("LQD", efs_) not in SECtoEFPROD:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        sum_cons_now = sum(mod.VmConsFinEneCountry[cy, e2, y] for e2 in _EFS_LQD)
        sum_cons_prev = sum(mod.VmConsFinEneCountry[cy, e2, y1] for e2 in _EFS_LQD) + _EPS
        growth = (sum_cons_now / sum_cons_prev) ** 0.98
        return mod.V03OutTransfRefSpec[cy, efs_, y] == (
            mod.i03ResTransfOutputRefineries[cy, efs_, y]
            * mod.V03OutTransfRefSpec[cy, efs_, y1]
            * growth
        )

    m.Q03OutTransfRefSpec = Constraint(
        run_cy, efs, ytime,
        rule=_q03_out_transf_ref_spec_rule,
    )

    # -------------------------------------------------------------------------
    # Q03OutTransfSolids / Q03OutTransfGasses (GAMS): Same structure as refineries—lagged output times growth in final consumption (exponent 0.98), per EFS for SLD and GAS.
    # -------------------------------------------------------------------------
    def _q03_out_transf_solids_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or ("SLD", efs_) not in SECtoEFPROD:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        cons_prev = mod.VmConsFinEneCountry[cy, efs_, y1] + _EPS
        growth = (mod.VmConsFinEneCountry[cy, efs_, y] / cons_prev) ** 0.98
        return mod.V03OutTransfSolids[cy, efs_, y] == mod.V03OutTransfSolids[cy, efs_, y1] * growth

    m.Q03OutTransfSolids = Constraint(run_cy, efs, ytime, rule=_q03_out_transf_solids_rule)

    def _q03_out_transf_gasses_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or ("GAS", efs_) not in SECtoEFPROD:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        cons_prev = mod.VmConsFinEneCountry[cy, efs_, y1] + _EPS
        growth = (mod.VmConsFinEneCountry[cy, efs_, y] / cons_prev) ** 0.98
        return mod.V03OutTransfGasses[cy, efs_, y] == mod.V03OutTransfGasses[cy, efs_, y1] * growth

    m.Q03OutTransfGasses = Constraint(run_cy, efs, ytime, rule=_q03_out_transf_gasses_rule)

    # -------------------------------------------------------------------------
    # Q03InputTransfRef (GAMS): The equation calculates the transformation input to refineries for the energy form Crude Oil in a specific scenario and year. The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation output from refineries for the given energy form and year to the output in the previous year.
    # -------------------------------------------------------------------------
    def _q03_input_transf_ref_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or ("LQD", efs_) not in SECtoEF:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        sum_out_now = sum(mod.V03OutTransfRefSpec[cy, e2, y] for e2 in _EFS_LQD)
        sum_out_prev = sum(mod.V03OutTransfRefSpec[cy, e2, y1] for e2 in _EFS_LQD) + _EPS
        return mod.V03InputTransfRef[cy, efs_, y] == (
            mod.V03InputTransfRef[cy, efs_, y1] * sum_out_now / sum_out_prev
        )

    m.Q03InputTransfRef = Constraint(run_cy, efs, ytime, rule=_q03_input_transf_ref_rule)

    def _q03_input_transf_solids_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or ("SLD", efs_) not in SECtoEF:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        efs_sld = [e2 for (ss, e2) in SECtoEFPROD if ss == "SLD"]
        sum_out_now = sum(mod.V03OutTransfSolids[cy, e2, y] for e2 in efs_sld)
        sum_out_prev = sum(mod.V03OutTransfSolids[cy, e2, y1] for e2 in efs_sld) + _EPS
        return mod.V03InputTransfSolids[cy, efs_, y] == (
            mod.V03InputTransfSolids[cy, efs_, y1] * sum_out_now / sum_out_prev
        )

    m.Q03InputTransfSolids = Constraint(run_cy, efs, ytime, rule=_q03_input_transf_solids_rule)

    def _q03_input_transf_gasses_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or ("GAS", efs_) not in SECtoEF:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        efs_gas = [e2 for (ss, e2) in SECtoEFPROD if ss == "GAS"]
        sum_out_now = sum(mod.V03OutTransfGasses[cy, e2, y] for e2 in efs_gas)
        sum_out_prev = sum(mod.V03OutTransfGasses[cy, e2, y1] for e2 in efs_gas) + _EPS
        return mod.V03InputTransfGasses[cy, efs_, y] == (
            mod.V03InputTransfGasses[cy, efs_, y1] * sum_out_now / sum_out_prev
        )

    m.Q03InputTransfGasses = Constraint(run_cy, efs, ytime, rule=_q03_input_transf_gasses_rule)

    # -------------------------------------------------------------------------
    # Q03InpTotTransf (GAMS): The equation calculates the total transformation input for a specific energy branch in a given scenario and year. The result is obtained by summing the transformation inputs from different sources, including thermal power plants, District Heating Plants, nuclear plants, patent fuel and briquetting plants, and refineries (VmConsFuelElecProd for PG, VmConsFuelSteProd for CHP/STEAMP, V03InputTransfRef/Solids/Gasses for LQD/SLD/GAS).
    # -------------------------------------------------------------------------
    def _q03_inp_tot_transf_rule(mod, cy, ssbs_, efs_, y):
        if cy not in run_cy or y not in time_set or (ssbs_, efs_) not in SECtoEF:
            return Constraint.Skip
        lhs = 0.0
        if ssbs_ == "PG":
            lhs = mod.VmConsFuelElecProd[cy, efs_, y]
        elif ssbs_ == "CHP":
            lhs = mod.VmConsFuelSteProd[cy, "CHP", efs_, y]
        elif ssbs_ == "STEAMP":
            lhs = mod.VmConsFuelSteProd[cy, "DHP", efs_, y]
        elif ssbs_ == "LQD":
            lhs = mod.V03InputTransfRef[cy, efs_, y]
        elif ssbs_ == "SLD":
            lhs = mod.V03InputTransfSolids[cy, efs_, y]
        elif ssbs_ == "GAS":
            lhs = mod.V03InputTransfGasses[cy, efs_, y]
        return mod.V03InpTotTransf[cy, ssbs_, efs_, y] == lhs

    m.Q03InpTotTransf = Constraint(
        run_cy, ssbs, efs, ytime,
        rule=_q03_inp_tot_transf_rule,
    )

    # -------------------------------------------------------------------------
    # Q03OutTotTransf (GAMS): The equation calculates the total transformation output for a specific energy branch in a given scenario and year. The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants, nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
    # -------------------------------------------------------------------------
    def _q03_out_tot_transf_rule(mod, cy, ssbs_, efs_, y):
        if cy not in run_cy or y not in time_set or (ssbs_, efs_) not in SECtoEFPROD:
            return Constraint.Skip
        lhs = 0.0
        if ssbs_ == "PG" and efs_ in ELCEF:
            lhs = mod.smTWhToMtoe * sum(mod.VmProdElec[cy, p, y] for p in core_sets.PGALL)
        elif ssbs_ == "CHP" and efs_ in ELCEF:
            lhs = mod.V04ProdElecEstCHP[cy, y] * mod.smTWhToMtoe
        elif ssbs_ == "STEAMP" and efs_ in STEAM_EFS:
            lhs = mod.VmDemTotSte[cy, y]
        elif ssbs_ == "LQD":
            lhs = mod.V03OutTransfRefSpec[cy, efs_, y]
        elif ssbs_ == "SLD":
            lhs = mod.V03OutTransfSolids[cy, efs_, y]
        elif ssbs_ == "GAS":
            lhs = mod.V03OutTransfGasses[cy, efs_, y]
        elif ssbs_ == "H2P" and efs_ == "H2F":
            lhs = mod.VmDemTotH2[cy, y]
        return mod.V03OutTotTransf[cy, ssbs_, efs_, y] == lhs

    m.Q03OutTotTransf = Constraint(
        run_cy, ssbs, efs, ytime,
        rule=_q03_out_tot_transf_rule,
    )

    # -------------------------------------------------------------------------
    # Q03Transfers (GAMS): The equation calculates the transfers of a specific energy branch in a given scenario and year. The result is computed based on a complex formula that involves the previous year's transfers, the residual for feedstocks in transfers, and various conditions. In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers, and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent. Active when i03FeedTransfr > 0.
    # -------------------------------------------------------------------------
    def _q03_transfers_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        # Stub: enable transfers if any feed is non-zero (GAMS uses fStartHorizon)
        feed = mod.i03FeedTransfr[cy, efs_, y]
        try:
            feed_val = feed.value if hasattr(feed, "value") else float(feed)
        except Exception:
            feed_val = 0.0
        if feed_val <= 0:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        if efs_ == "CRO":
            sum_tr_now = sum(mod.V03Transfers[cy, e2, y] for e2 in _EFS_LQD)
            sum_tr_prev = sum(mod.V03Transfers[cy, e2, y1] for e2 in _EFS_LQD) + _EPS
            rhs = mod.V03Transfers[cy, "CRO", y1] * sum_tr_now / sum_tr_prev
        else:
            cons_prev = mod.VmConsFinEneCountry[cy, efs_, y1] + _EPS
            rhs = mod.V03Transfers[cy, efs_, y1] * (mod.VmConsFinEneCountry[cy, efs_, y] / cons_prev) ** 0.3
        return mod.V03Transfers[cy, efs_, y] == rhs

    m.Q03Transfers = Constraint(run_cy, efs, ytime, rule=_q03_transfers_rule)

    # -------------------------------------------------------------------------
    # Q03ConsGrssInlNotEneBranch (GAMS): Gross inland consumption excluding energy branch = VmConsFinEneCountry + VmConsFinNonEne + sum(V03InpTotTransf) - sum(V03OutTotTransf) + VmLossesDistr - V03Transfers.
    # -------------------------------------------------------------------------
    def _q03_cons_grss_inl_not_ene_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        rhs = (
            mod.VmConsFinEneCountry[cy, efs_, y]
            + mod.VmConsFinNonEne[cy, efs_, y]
            + sum(mod.V03InpTotTransf[cy, ss, efs_, y] for ss in ssbs)
            - sum(mod.V03OutTotTransf[cy, ss, efs_, y] for ss in ssbs)
            + mod.VmLossesDistr[cy, efs_, y]
            - mod.V03Transfers[cy, efs_, y]
        )
        return mod.V03ConsGrssInlNotEneBranch[cy, efs_, y] == rhs

    m.Q03ConsGrssInlNotEneBranch = Constraint(
        run_cy, efs, ytime,
        rule=_q03_cons_grss_inl_not_ene_rule,
    )

    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    # Q03ConsGrssInl (GAMS): Gross inland consumption including energy branch = same as ConsGrssInlNotEneBranch but with sum(VmConsFiEneSec + V03InpTotTransf - V03OutTotTransf) over SSBS.
    # -------------------------------------------------------------------------
    def _q03_cons_grss_inl_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        rhs = (
            mod.VmConsFinEneCountry[cy, efs_, y]
            + mod.VmConsFinNonEne[cy, efs_, y]
            + sum(
                mod.VmConsFiEneSec[cy, ss, efs_, y]
                + mod.V03InpTotTransf[cy, ss, efs_, y]
                - mod.V03OutTotTransf[cy, ss, efs_, y]
                for ss in ssbs
            )
            + mod.VmLossesDistr[cy, efs_, y]
            - mod.V03Transfers[cy, efs_, y]
        )
        return mod.V03ConsGrssInl[cy, efs_, y] == rhs

    m.Q03ConsGrssInl = Constraint(run_cy, efs, ytime, rule=_q03_cons_grss_inl_rule)

    # -------------------------------------------------------------------------
    # Q03ProdPrimary (GAMS): Primary production. For most fuels: lagged value times growth in gross inland (excluding energy branch). For NGS: with residual i03ResHcNgOilPrProd. For CRO: with polynomial distributed lag on oil price (KPDL).
    # -------------------------------------------------------------------------
    def _q03_prod_primary_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        y1 = _year_prev(ytime, y)
        if y1 is None:
            return Constraint.Skip
        g1 = mod.V03ConsGrssInlNotEneBranch[cy, efs_, y] + _EPS
        g0 = mod.V03ConsGrssInlNotEneBranch[cy, efs_, y1] + _EPS
        if efs_ not in ("CRO", "NGS"):
            return mod.V03ProdPrimary[cy, efs_, y] == (
                mod.V03ProdPrimary[cy, efs_, y1] * (g1 / g0)
            )
        if efs_ == "NGS":
            return mod.V03ProdPrimary[cy, efs_, y] == (
                mod.i03ResHcNgOilPrProd[cy, efs_, y]
                * mod.V03ProdPrimary[cy, efs_, y1]
                * (g1 / g0)
            )
        # CRO: with PDL on oil price
        prod_term = 1.0
        for k in kpdl_list:
            ord_k = kpdl_list.index(k) + 1
            if ord_k >= 5:
                break
            y_lag = _year_at(ytime, y, -(ord_k + 1))
            if y_lag is None:
                continue
            price_ratio = (
                mod.imPriceFuelsInt["WCRO", y_lag] / (mod.imPriceFuelsIntBase["WCRO", y_lag] + _EPS)
            )
            coef = mod.i03PolDstrbtnLagCoeffPriOilPr[k]
            prod_term *= price_ratio ** (0.2 * coef)
        return mod.V03ProdPrimary[cy, efs_, y] == (
            mod.i03ResHcNgOilPrProd[cy, efs_, y] * mod.V03ProdPrimary[cy, efs_, y1] * prod_term
        )

    m.Q03ProdPrimary = Constraint(run_cy, efs, ytime, rule=_q03_prod_primary_rule)

    # -------------------------------------------------------------------------
    # Q03Exp: Fake exports = imFuelExprts.
    # -------------------------------------------------------------------------
    def _q03_exp_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or efs_ not in IMPEF:
            return Constraint.Skip
        return mod.V03Exp[cy, efs_, y] == mod.imFuelExprts[cy, efs_, y]

    m.Q03Exp = Constraint(run_cy, efs, ytime, rule=_q03_exp_rule)

    # -------------------------------------------------------------------------
    # Q03Imp: Fake imports. Different formula for ELC, CRO, NGS, and other fuels.
    # -------------------------------------------------------------------------
    def _q03_imp_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set or efs_ not in IMPEF:
            return Constraint.Skip
        if efs_ in ELCEF:
            rhs = (
                mod.i03RatioImpFinElecDem[cy, y]
                * (mod.VmConsFinEneCountry[cy, efs_, y] + mod.VmConsFinNonEne[cy, efs_, y])
                + mod.V03Exp[cy, efs_, y]
            )
        elif efs_ == "CRO" or efs_ == "NGS":
            bu_term = mod.VmConsFuel[cy, "BU", efs_, y] if ("BU", efs_) in SECtoEF else 0.0
            rhs = (
                mod.V03ConsGrssInl[cy, efs_, y]
                + mod.V03Exp[cy, efs_, y]
                + bu_term
                - mod.V03ProdPrimary[cy, efs_, y]
            )
        else:
            bu_term = mod.VmConsFuel[cy, "BU", efs_, y] if ("BU", efs_) in SECtoEF else 0.0
            rhs = (1 - mod.i03RatePriProTotPriNeeds[cy, efs_, y]) * (
                mod.V03ConsGrssInl[cy, efs_, y] + mod.V03Exp[cy, efs_, y] + bu_term
            )
        return mod.V03Imp[cy, efs_, y] == rhs

    m.Q03Imp = Constraint(run_cy, efs, ytime, rule=_q03_imp_rule)

    # -------------------------------------------------------------------------
    # Q03ImpNetEneBrnch: Net imports = V03Imp - V03Exp.
    # -------------------------------------------------------------------------
    def _q03_imp_net_rule(mod, cy, efs_, y):
        if cy not in run_cy or y not in time_set:
            return Constraint.Skip
        return mod.VmImpNetEneBrnch[cy, efs_, y] == mod.V03Imp[cy, efs_, y] - mod.V03Exp[cy, efs_, y]

    m.Q03ImpNetEneBrnch = Constraint(run_cy, efs, ytime, rule=_q03_imp_net_rule)

    # Renewable energy forms in power generation (GAMS PGRENEF). Primary production not added for these.
    PGRENEF = {"HYD", "WND", "SOL", "BMSWAS", "GEO"}

    # -------------------------------------------------------------------------
    # Q03ConsFiEneSec (GAMS): The equation computes the final consumption in the energy sector (VmConsFiEneSec) per supply subsector and energy form. Rate applied to transformation output and primary production; special handling for H2 (H2 production term).
    # -------------------------------------------------------------------------
    def _q03_cons_fi_ene_sec_rule(mod, cy, ssbs_, efs_, y):
        if cy not in run_cy or y not in time_set or (ssbs_, efs_) not in SECtoEF:
            return Constraint.Skip
        # Sum over EFS2 produced by this sector: V03OutTotTransf + V03ProdPrimary (if not renewable)
        out_plus_prim = 0.0
        for e2 in efs:
            if (ssbs_, e2) not in SECtoEFPROD:
                continue
            out_plus_prim += mod.V03OutTotTransf[cy, ssbs_, e2, y]
            if e2 not in PGRENEF:
                out_plus_prim += mod.V03ProdPrimary[cy, e2, y]
        rate = mod.i03RateEneBranCons[cy, ssbs_, efs_, y]
        lhs = rate * out_plus_prim
        if ssbs_ == "H2P":
            lhs += mod.VmConsFuelH2Prod[cy, efs_, y]
        return mod.VmConsFiEneSec[cy, ssbs_, efs_, y] == lhs

    m.Q03ConsFiEneSec = Constraint(
        run_cy, ssbs, efs, ytime,
        rule=_q03_cons_fi_ene_sec_rule,
    )
