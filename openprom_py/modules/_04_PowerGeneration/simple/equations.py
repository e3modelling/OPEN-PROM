"""
Module 04_PowerGeneration (simple): equation definitions.

Mirrors modules/04_PowerGeneration/simple/equations.gms. All Q04* constraints.
Uses core sets PGREN, PGREN2, PGRENSW, PGSCRN, NOCCS_PG, CCS_NOCCS, PGALLtoEF, NAPtoALLSBS.
Calibration off: Q04DemElecTot is active. Learning curves off: factor 1 in Q04CapexFixCostPG.
Equation descriptions below are transferred from GAMS *' comments.
"""
from pyomo.core import ConcreteModel, Constraint, value as pyo_value
from pyomo.environ import exp, sqrt

from core import sets as core_sets

_EPS = 1e-6


def _year_prev(ytime_list, y):
    """Previous year in ytime; if first, return y."""
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def _year_at(ytime_list, y, offset):
    """Year at position (y + offset) in ytime; clamp to first/last."""
    try:
        i = ytime_list.index(y)
        j = i + offset
        if j < 0:
            return ytime_list[0]
        if j >= len(ytime_list):
            return ytime_list[-1]
        return ytime_list[j]
    except (ValueError, AttributeError):
        return y


def add_power_generation_equations(m: ConcreteModel, core_sets_obj, config=None) -> None:
    """Add all Q04* constraints for 04_PowerGeneration (simple).
    When config.calibration == 'MatCalibration', Q04DemElecTot is not added (demand fixed from targets)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    pgall = list(core_sets.PGALL)
    efs = list(core_sets.EFS)
    pgef = list(core_sets.PGEF)
    ssbs = list(core_sets.SSBS)
    inddom = list(core_sets.INDDOM)
    trans = list(core_sets.TRANSE)
    nap = list(core_sets.NAP)
    pgren = set(core_sets.PGREN)
    pgren2 = set(core_sets.PGREN2)
    pgrensw = set(core_sets.PGRENSW)
    pgscrn = set(core_sets.PGSCRN)
    noccs_pg = set(core_sets.NOCCS_PG)
    ccs_noccs = core_sets.CCS_NOCCS  # (ccs_plant, noccs_plant)
    pgalltoef = core_sets.PGALLtoEF

    # NAP that map to PG / H2P for carbon value sums
    calibration = getattr(config, "calibration", "off") if config else "off"
    nap_pg_set = set()
    for (n, s) in core_sets.NAPtoALLSBS:
        if s == "PG":
            nap_pg_set.add(n)
    nap_h2p_set = set()
    for (n, s) in core_sets.NAPtoALLSBS:
        if s == "H2P":
            nap_h2p_set.add(n)
    if not nap_pg_set:
        nap_pg_set = set(nap)
    if not nap_h2p_set:
        nap_h2p_set = set(nap)

    # --- Commented out in GAMS (04_PowerGeneration/simple/equations.gms) ---
    # *q04PotRenMinAllow(allCy,PGRENEF,YTIME): minimum allowed renewable potential
    # *q04SecContrTotCHPProd(allCy,SBS,CHP,YTIME): sector contribution to total CHP production
    # *q04CostPowGenLonMin(allCy,PGALL,YTIME): long-term minimum power generation cost
    # *q04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME): long-term cost with international fuel prices
    # *q04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME): short-term cost with international fuel prices
    # *q04CostPowGenAvgShrt(allCy,ESET,YTIME): short-term average power generation cost

    # -------------------------------------------------------------------------
    # Q04ProdElecEstCHP (GAMS): This equation calculates the estimated electricity generation of Combined Heat and Power plants in a specific country and time period. The estimation is based on the fuel consumption of CHP plants, their electricity prices, the maximum share of CHP electricity in total demand, and the overall electricity demand. The square root expression ensures that the estimated electricity generation remains non-negative.
    # -------------------------------------------------------------------------
    def _q04_prod_elec_est_chp(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        ste = pyo_value(mod.V03OutTransfCHP[cy, "STE", y])
        pind = mod.VmPriceElecInd[cy, y]
        mx = mod.i04MxmShareChpElec[cy, y]
        dem = mod.V04DemElecTot[cy, y]
        diff = ste * pind - mx * dem
        # sqrt(max(0, diff^2)) = abs(diff); GAMS SQR = square
        rhs = (1.0 / mod.smTWhToMtoe) * (
            (ste * pind + mx * dem - sqrt(diff**2 + _EPS)) / 2.0 + _EPS
        )
        return mod.V04ProdElecEstCHP[cy, y] == rhs

    m.Q04ProdElecEstCHP = Constraint(run_cy, ytime, rule=_q04_prod_elec_est_chp)

    # -------------------------------------------------------------------------
    # Q04CapElecCHP (GAMS): This equation computes the electric capacity of Combined Heat and Power (CHP) plants. The capacity is calculated in gigawatts (GW) and is based on several factors, including the consumption of fuel in the industrial sector, the electricity prices in the industrial sector, the availability rate of power generation plants, and the utilization rate of CHP plants.
    # -------------------------------------------------------------------------
    def _q04_cap_elec_chp(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V04CapElecCHP[cy, y] == mod.V04ProdElecEstCHP[cy, y] / (
            1e3 * mod.smGwToTwhPerYear[y] + _EPS
        )

    m.Q04CapElecCHP = Constraint(run_cy, ytime, rule=_q04_cap_elec_chp)

    # -------------------------------------------------------------------------
    # Q04DemElecTot (GAMS): The equation calculates the total electricity demand by summing the components of final energy consumption in electricity, final non-energy consumption in electricity, distribution losses, and final consumption in the energy sector for electricity, and then subtracting net imports. The result is normalized using a conversion factor which converts TWh to Mtoe. Active only when Calibration == off ($ifthen.calib).
    # -------------------------------------------------------------------------
    if calibration != "MatCalibration":
        def _q04_dem_elec_tot(mod, cy, y):
            if y not in time_set or cy not in run_cy:
                return Constraint.Skip
            s = (
                mod.VmConsFinEneCountry[cy, "ELC", y]
                + mod.VmConsFinNonEne[cy, "ELC", y]
                + mod.VmLossesDistr[cy, "ELC", y]
                + sum(mod.VmConsFiEneSec[cy, ss, "ELC", y] for ss in ssbs)
                - mod.VmImpNetEneBrnch[cy, "ELC", y]
            )
            return mod.V04DemElecTot[cy, y] == (1.0 / mod.smTWhToMtoe) * s

        m.Q04DemElecTot = Constraint(run_cy, ytime, rule=_q04_dem_elec_tot)

    # -------------------------------------------------------------------------
    # Q04LoadFacDom (GAMS): This equation calculates the load factor of the entire domestic system as a sum of consumption in each demand subsector and the sum of energy demand in transport subsectors (electricity only). Those sums are also divided by the load factor of electricity demand per sector.
    # -------------------------------------------------------------------------
    def _q04_load_fac_dom(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = sum(mod.VmConsFuel[cy, d, "ELC", y] for d in inddom) + sum(
            mod.VmDemFinEneTranspPerFuel[cy, t, "ELC", y] for t in trans
        )
        den = sum(
            mod.VmConsFuel[cy, d, "ELC", y] / (mod.i04LoadFacElecDem[d] + _EPS)
            for d in inddom
        ) + sum(
            mod.VmDemFinEneTranspPerFuel[cy, t, "ELC", y]
            / (mod.i04LoadFacElecDem[t] + _EPS)
            for t in trans
        )
        return mod.V04LoadFacDom[cy, y] == num / (den + _EPS)

    m.Q04LoadFacDom = Constraint(run_cy, ytime, rule=_q04_load_fac_dom)

    # -------------------------------------------------------------------------
    # Q04PeakLoad (GAMS): The equation calculates the electricity peak load by dividing the total electricity demand by the load factor for the domestic sector and converting the result to gigawatts (GW) using the conversion factor. This provides an estimate of the maximum power demand during a specific time period.
    # -------------------------------------------------------------------------
    def _q04_peak_load(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.VmPeakLoad[cy, y] == mod.V04DemElecTot[cy, y] / (
            mod.V04LoadFacDom[cy, y] * mod.smGwToTwhPerYear[y] + _EPS
        )

    m.Q04PeakLoad = Constraint(run_cy, ytime, rule=_q04_peak_load)

    # -------------------------------------------------------------------------
    # Q04CapElecTotEst (GAMS): The equation calculates the estimated total electricity generation capacity by multiplying the previous year's total electricity generation capacity with the ratio of the current year's estimated electricity peak load to the previous year's electricity peak load. This provides an estimate of the required generation capacity based on the changes in peak load.
    # -------------------------------------------------------------------------
    def _q04_cap_elec_tot_est(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        return mod.VmCapElecTotEst[cy, y] == mod.VmCapElecTotEst[cy, y_1] * (
            mod.VmPeakLoad[cy, y] / (mod.VmPeakLoad[cy, y_1] + _EPS)
        )

    m.Q04CapElecTotEst = Constraint(run_cy, ytime, rule=_q04_cap_elec_tot_est)

    # -------------------------------------------------------------------------
    # Q04CapexFixCostPG (GAMS): This equation calculates the CAPEX and the Fixed Costs of each power generation unit, taking into account its discount rate and life expectancy, for each region (country) and year. Learning curves applied only to CAPEX costs with cost breakdown. Formula: Cost = [LearnableFraction × CostMultiplier + (1-LearnableFraction)] × InitialCost. (We use factor 1 when LearningCurves not active.)
    # -------------------------------------------------------------------------
    def _q04_capex_fix_cost_pg(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        disc = mod.imDisc[cy, "PG", y]
        lft = mod.i04TechLftPlaType[cy, pg]
        ex = exp(disc * lft)
        ann = disc * ex / (ex - 1.0 + _EPS)
        cap_part = (
            ann
            * mod.i04GrossCapCosSubRen[cy, pg, y]
            * 1000.0
            * mod.imCGI[cy, y]
            * 1.0
        )  # learning = 1
        return mod.V04CapexFixCostPG[cy, pg, y] == cap_part + mod.i04FixOandMCost[
            cy, pg, y
        ]

    m.Q04CapexFixCostPG = Constraint(
        run_cy, pgall, ytime, rule=_q04_capex_fix_cost_pg
    )

    # Q04CostCapTech: V04CostCapTech = V04CapexRESRate * V04CapexFixCostPG / (i04AvailRate * smGwToTwhPerYear * 1000)
    def _q04_cost_cap_tech(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        denom = (
            mod.i04AvailRate[cy, pg, y]
            * mod.smGwToTwhPerYear[y]
            * 1000.0
            + _EPS
        )
        return mod.V04CostCapTech[cy, pg, y] == mod.V04CapexRESRate[
            cy, pg, y
        ] * mod.V04CapexFixCostPG[cy, pg, y] / denom

    m.Q04CostCapTech = Constraint(run_cy, pgall, ytime, rule=_q04_cost_cap_tech)

    # -------------------------------------------------------------------------
    # Q04CostVarTech (GAMS): Compute the variable cost of each power plant technology for every region, by utilizing the gross cost, fuel prices, CO2 emission factors & capture, and plant efficiency.
    # -------------------------------------------------------------------------
    def _q04_cost_var_tech(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        base = mod.i04VarCost[pg, y] / 1e3
        # VmRenValue * 8.6e-5 when NOT in PGREN2 (excl. PGASHYD, PGSHYD, PGLHYD)
        if pg in pgren2:
            ren_term = 0.0
        else:
            ren_term = mod.VmRenValue[y] * 8.6e-5
        fuel_term = 0.0
        if pg not in pgren:
            for (pg_ef, efs_ef) in pgalltoef:
                if pg_ef != pg:
                    continue
                co2 = mod.imCo2EmiFac[cy, "PG", efs_ef, y]
                if efs_ef == "BMSWAS":
                    co2 = co2 + 4.17
                car_sum = sum(mod.VmCarVal[cy, n, y] for n in nap_pg_set)
                cap_r = mod.V04CO2CaptRate[cy, pg, y]
                seq = mod.VmCstCO2SeqCsts[cy, y]
                fuel_term += (
                    (
                        mod.VmPriceFuelSubsecCarVal[cy, "PG", efs_ef, y]
                        + cap_r * seq * 1e-3 * co2
                        + (1.0 - cap_r) * 1e-3 * co2 * car_sum
                    )
                    * mod.smTWhToMtoe
                    / (mod.imPlantEffByType[cy, pg, y] + _EPS)
                )
        return mod.V04CostVarTech[cy, pg, y] == base + ren_term + fuel_term

    m.Q04CostVarTech = Constraint(run_cy, pgall, ytime, rule=_q04_cost_var_tech)

    # -------------------------------------------------------------------------
    # Q04CostHourProdInvDec (GAMS): The equation calculates the hourly production cost of a power generation plant used in investment decisions. The cost is determined based on various factors, including the discount rate, gross capital cost, fixed O&M cost, availability rate, variable cost, renewable value, and fuel prices. The production cost is normalized per unit of electricity generated (kEuro2005/kWh).
    # -------------------------------------------------------------------------
    def _q04_cost_hour_prod_inv_dec(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V04CostHourProdInvDec[cy, pg, y] == mod.V04CostCapTech[
            cy, pg, y
        ] + mod.V04CostVarTech[cy, pg, y]

    m.Q04CostHourProdInvDec = Constraint(
        run_cy, pgall, ytime, rule=_q04_cost_hour_prod_inv_dec
    )

    # -------------------------------------------------------------------------
    # Q04IndxEndogScrap (GAMS): The equation computes the endogenous scrapping index for power generation plants during the specified year. The index is calculated as the variable cost of technology divided by the sum of this variable cost and a scaled value based on the scale parameter for endogenous scrapping. Only for plants not in PGSCRN.
    # -------------------------------------------------------------------------
    def _q04_indx_endog_scrap(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy or pg in pgscrn:
            return Constraint.Skip
        v = mod.V04CostVarTech[cy, pg, y]
        other = sum(
            mod.V04CostHourProdInvDec[cy, pg2, y]
            for pg2 in pgall
            if pg2 != pg
        )
        scale = mod.i04ScaleEndogScrap
        return mod.V04IndxEndogScrap[cy, pg, y] == (v ** (-2)) / (
            (v ** (-2)) + (scale * other + _EPS) ** (-2) + _EPS
        )

    m.Q04IndxEndogScrap = Constraint(
        run_cy, pgall, ytime, rule=_q04_indx_endog_scrap
    )

    # -------------------------------------------------------------------------
    # Q04CapElecNonCHP (GAMS): The equation calculates the total electricity generation capacity excluding Combined Heat and Power plants for a specified year. It is derived by subtracting the sum of the capacities of CHP plants multiplied by a factor of 0.85 from the total electricity generation capacity.
    # -------------------------------------------------------------------------
    def _q04_cap_elec_non_chp(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V04CapElecNonCHP[cy, y] == mod.VmCapElecTotEst[
            cy, y
        ] - mod.V04CapElecCHP[cy, y]

    m.Q04CapElecNonCHP = Constraint(run_cy, ytime, rule=_q04_cap_elec_non_chp)

    # -------------------------------------------------------------------------
    # Q04GapGenCapPowerDiff (GAMS): In essence, the equation evaluates the difference between the current and expected power generation capacity, accounting for various factors such as planned capacity, decommissioning schedules, and endogenous scrapping. The square root term introduces a degree of tolerance in the calculation.
    # -------------------------------------------------------------------------
    def _q04_gap_gen_cap_power_diff(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        delta_cap = mod.V04CapElecNonCHP[cy, y] - mod.V04CapElecNonCHP[cy, y_1]
        sum_pg = sum(
            mod.VmCapElec[cy, pg, y_1] * mod.V04ScrpRate[cy, pg, y]
            - mod.VmCapElec[cy, pg, y_1] * (1.0 - mod.V04CCSRetroFit[cy, pg, y])
            + (
                mod.i04PlantDecomSched[cy, pg, y]
                - mod.i04DecInvPlantSched[cy, pg, y]
            )
            * mod.i04AvailRate[cy, pg, y]
            for pg in pgall
        )
        inner = delta_cap + sum_pg
        return mod.V04GapGenCapPowerDiff[cy, y] == (
            inner + sqrt(inner**2 + _EPS)
        ) / 2.0

    m.Q04GapGenCapPowerDiff = Constraint(
        run_cy, ytime, rule=_q04_gap_gen_cap_power_diff
    )

    # -------------------------------------------------------------------------
    # Q04ShareMixWndSol (GAMS): Calculates the share of all the unflexible RES penetration into the mixture (sum over PGRENSW of VmCapElec / sum over all PGALL of VmCapElec).
    # -------------------------------------------------------------------------
    def _q04_share_mix_wnd_sol(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = sum(mod.VmCapElec[cy, pg, y] for pg in pgrensw)
        den = sum(mod.VmCapElec[cy, pg, y] for pg in pgall) + _EPS
        return mod.V04ShareMixWndSol[cy, y] == num / den

    m.Q04ShareMixWndSol = Constraint(run_cy, ytime, rule=_q04_share_mix_wnd_sol)

    # -------------------------------------------------------------------------
    # Q04SharePowPlaNewEq (GAMS): The equation calculates the power plant share in new equipment for a specific power plant in a given country and time period. The calculation depends on maturity factor, saturation share (t-1), and hourly production cost (t-1)**(-2); ratio to sum over all plants. For plants with CCS the share is determined by summing shares of corresponding non-CCS plants.
    # -------------------------------------------------------------------------
    def _q04_share_pow_pla_new_eq(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        num = (
            mod.i04MatFacPlaAvailCap[cy, pg, y]
            * mod.V04ShareSatPG[cy, pg, y_1]
            * (mod.V04CostHourProdInvDec[cy, pg, y_1] + _EPS) ** (-2)
        )
        den = sum(
            mod.i04MatFacPlaAvailCap[cy, pg2, y]
            * mod.V04ShareSatPG[cy, pg2, y_1]
            * (mod.V04CostHourProdInvDec[cy, pg2, y_1] + _EPS) ** (-2)
            for pg2 in pgall
        ) + _EPS
        return mod.V04SharePowPlaNewEq[cy, pg, y] == num / den

    m.Q04SharePowPlaNewEq = Constraint(
        run_cy, pgall, ytime, rule=_q04_share_pow_pla_new_eq
    )

    # -------------------------------------------------------------------------
    # Q04CapElec (GAMS): This equation calculates the electricity generation capacity for a specific power plant in a given country and time period. VmCapElec = VmCapElec(t-1)*(1 - V04ScrpRate) + V04NewCapElec - i04PlantDecomSched * i04AvailRate.
    # -------------------------------------------------------------------------
    def _q04_cap_elec(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        return mod.VmCapElec[cy, pg, y] == mod.VmCapElec[
            cy, pg, y_1
        ] * (1.0 - mod.V04ScrpRate[cy, pg, y]) + mod.V04NewCapElec[
            cy, pg, y
        ] - mod.i04PlantDecomSched[cy, pg, y] * mod.i04AvailRate[cy, pg, y]

    m.Q04CapElec = Constraint(run_cy, pgall, ytime, rule=_q04_cap_elec)

    # Q04CapElecNominal: V04CapElecNominal = VmCapElec / i04AvailRate
    def _q04_cap_elec_nominal(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V04CapElecNominal[cy, pg, y] == mod.VmCapElec[
            cy, pg, y
        ] / (mod.i04AvailRate[cy, pg, y] + _EPS)

    m.Q04CapElecNominal = Constraint(
        run_cy, pgall, ytime, rule=_q04_cap_elec_nominal
    )

    # Q04NewCapElec: New capacity = share * gap + scheduled + CCS retrofit from non-CCS plants
    def _q04_new_cap_elec(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        ccs_retro = sum(
            (1.0 - mod.V04CCSRetroFit[cy, pg2, y])
            * mod.VmCapElec[cy, pg2, y_1]
            for (pg_ccs, pg2) in ccs_noccs
            if pg_ccs == pg
        )
        return mod.V04NewCapElec[cy, pg, y] == mod.V04SharePowPlaNewEq[
            cy, pg, y
        ] * mod.V04GapGenCapPowerDiff[cy, y] + mod.i04DecInvPlantSched[
            cy, pg, y
        ] * mod.i04AvailRate[cy, pg, y] + ccs_retro

    m.Q04NewCapElec = Constraint(run_cy, pgall, ytime, rule=_q04_new_cap_elec)

    # -------------------------------------------------------------------------
    # Q04NetNewCapElec (GAMS): This equation calculates the newly added electricity generation capacity for a specific renewable power plant in a given country and time period. V04NetNewCapElec = VmCapElec - VmCapElec(t-1). (Only PGREN.)
    # -------------------------------------------------------------------------
    def _q04_net_new_cap_elec(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy or pg not in pgren:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        return mod.V04NetNewCapElec[cy, pg, y] == mod.VmCapElec[
            cy, pg, y
        ] - mod.VmCapElec[cy, pg, y_1]

    m.Q04NetNewCapElec = Constraint(
        run_cy, pgall, ytime, rule=_q04_net_new_cap_elec
    )

    # -------------------------------------------------------------------------
    # Q04CFAvgRen (GAMS): This equation calculates the average capacity factor of renewable energy sources for a specific renewable power plant. The calculation involves the availability rates and newly added capacity in the current and seven previous time periods; weighted average over eight periods. (Only PGREN.)
    # -------------------------------------------------------------------------
    def _q04_cf_avg_ren(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy or pg not in pgren:
            return Constraint.Skip
        num = sum(
            mod.i04AvailRate[cy, pg, _year_at(ytime, y, k)]
            * mod.V04NetNewCapElec[cy, pg, _year_at(ytime, y, k)]
            for k in range(8)
        )
        den = sum(
            mod.V04NetNewCapElec[cy, pg, _year_at(ytime, y, k)]
            for k in range(8)
        ) + _EPS
        return mod.V04CFAvgRen[cy, pg, y] == num / den

    m.Q04CFAvgRen = Constraint(run_cy, pgall, ytime, rule=_q04_cf_avg_ren)

    # -------------------------------------------------------------------------
    # Q04CapOverall (GAMS): This equation calculates the overall capacity for a specific power plant. For non-renewable: V04CapOverall = VmCapElec. For renewable: V04CapOverall = V04CFAvgRen(t-1) * (V04NetNewCapElec/i04AvailRate + V04CapOverall(t-1)/(V04CFAvgRen(t-1)+eps)).
    # -------------------------------------------------------------------------
    def _q04_cap_overall(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        if pg not in pgren:
            return mod.V04CapOverall[cy, pg, y] == mod.VmCapElec[cy, pg, y]
        cf_1 = mod.V04CFAvgRen[cy, pg, y_1] + _EPS
        return mod.V04CapOverall[cy, pg, y] == mod.V04CFAvgRen[
            cy, pg, y_1
        ] * (
            mod.V04NetNewCapElec[cy, pg, y]
            / (mod.i04AvailRate[cy, pg, y] + _EPS)
            + mod.V04CapOverall[cy, pg, y_1] / cf_1
        )

    m.Q04CapOverall = Constraint(run_cy, pgall, ytime, rule=_q04_cap_overall)

    # -------------------------------------------------------------------------
    # Q04ProdElec (GAMS): This equation calculates the electricity production from power generation plants for a specific country, power plant type, and time period. VmProdElec = (V04DemElecTot - V04ProdElecEstCHP) / sum(VmCapElec) * VmCapElec (proportional dispatch by capacity).
    # -------------------------------------------------------------------------
    def _q04_prod_elec(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        tot_cap = sum(mod.VmCapElec[cy, pg2, y] for pg2 in pgall) + _EPS
        return mod.VmProdElec[cy, pg, y] == (
            mod.V04DemElecTot[cy, y] - mod.V04ProdElecEstCHP[cy, y]
        ) / tot_cap * mod.VmCapElec[cy, pg, y]

    m.Q04ProdElec = Constraint(run_cy, pgall, ytime, rule=_q04_prod_elec)

    # Q04ShareTechPG (GAMS): Share of all technologies in the electricity mixture. V04ShareTechPG = VmCapElec / sum(VmCapElec).
    def _q04_share_tech_pg(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        tot = sum(mod.VmCapElec[cy, pg2, y] for pg2 in pgall) + _EPS
        return mod.V04ShareTechPG[cy, pg, y] == mod.VmCapElec[cy, pg, y] / tot

    m.Q04ShareTechPG = Constraint(
        run_cy, pgall, ytime, rule=_q04_share_tech_pg
    )

    # Q04ShareSatPG (GAMS): Sigmoid function used as a saturation mechanism for electricity mixture penetration of RES technologies. V04ShareSatPG = 2 / (1 + exp(9*V04ShareTechPG)). (Only PGREN.)
    def _q04_share_sat_pg(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy or pg not in pgren:
            return Constraint.Skip
        return mod.V04ShareSatPG[cy, pg, y] == 2.0 / (
            1.0 + exp(9.0 * mod.V04ShareTechPG[cy, pg, y])
        )

    m.Q04ShareSatPG = Constraint(
        run_cy, pgall, ytime, rule=_q04_share_sat_pg
    )

    # -------------------------------------------------------------------------
    # Q04CostPowGenAvgLng (GAMS): This equation computes the long-term average power generation cost. Sum over PGALL of (VmProdElec * V04CostHourProdInvDec) / sum(VmProdElec).
    # -------------------------------------------------------------------------
    def _q04_cost_pow_gen_avg_lng(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = sum(
            mod.VmProdElec[cy, pg, y] * mod.V04CostHourProdInvDec[cy, pg, y]
            for pg in pgall
        )
        den = sum(mod.VmProdElec[cy, pg, y] for pg in pgall) + _EPS
        return mod.VmCostPowGenAvgLng[cy, y] == num / den

    m.Q04CostPowGenAvgLng = Constraint(
        run_cy, ytime, rule=_q04_cost_pow_gen_avg_lng
    )

    # Q04CapexRESRate (GAMS): This equation estimates the factor increasing the CAPEX of new RES (unflexible) capacity installation due to grid upgrade and storage. V04CapexRESRate = 1 + (V04ShareMixWndSol(t-1))**S04CapexBessRate for PGRENSW.
    def _q04_capex_res_rate(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        if pg in pgrensw:
            return mod.V04CapexRESRate[cy, pg, y] == 1.0 + (
                mod.V04ShareMixWndSol[cy, y_1] + _EPS
            ) ** mod.S04CapexBessRate
        return mod.V04CapexRESRate[cy, pg, y] == 1.0

    m.Q04CapexRESRate = Constraint(
        run_cy, pgall, ytime, rule=_q04_capex_res_rate
    )

    # Q04CO2CaptRate: CO2 capture rate as function of sequestration cost vs carbon value (smooth step).
    def _q04_co2_capt_rate(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        im = mod.imCO2CaptRate[pg]
        seq = mod.VmCstCO2SeqCsts[cy, y]
        car = sum(mod.VmCarVal[cy, n, y] for n in nap_h2p_set) + 1.0
        x = seq / car
        inner = (x + 2.0 - sqrt((x - 2.0) ** 2 + _EPS)) / 2.0 - 1.0
        return mod.V04CO2CaptRate[cy, pg, y] == im / (
            1.0 + exp(20.0 * inner) + _EPS
        )

    m.Q04CO2CaptRate = Constraint(
        run_cy, pgall, ytime, rule=_q04_co2_capt_rate
    )

    # Q04CCSRetroFit (GAMS): Retrofit share for non-CCS plants; logit-like in variable cost vs CCS alternative. (Only NOCCS_PG.)
    def _q04_ccs_retro_fit(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy or pg not in noccs_pg:
            return Constraint.Skip
        v = mod.V04CostVarTech[cy, pg, y]
        s = 0.01 * sum(
            (
                mod.V04CostCapTech[cy, pg2, y]
                - mod.i04AvailRate[cy, pg, y]
                / (mod.i04AvailRate[cy, pg2, y] + _EPS)
                * mod.V04CostCapTech[cy, pg, y]
                + mod.V04CostVarTech[cy, pg2, y]
            )
            ** (-2)
            for (pg2, noccs_p) in ccs_noccs
            if noccs_p == pg
        )
        return mod.V04CCSRetroFit[cy, pg, y] == (v ** (-2)) / (
            (v ** (-2)) + s + _EPS
        )

    m.Q04CCSRetroFit = Constraint(
        run_cy, pgall, ytime, rule=_q04_ccs_retro_fit
    )

    # Q04ScrpRate: Endogenous scrapping rate from V04IndxEndogScrap; 0 for PGSCRN.
    def _q04_scrp_rate(mod, cy, pg, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        lft = mod.i04TechLftPlaType[cy, pg]
        return mod.V04ScrpRate[cy, pg, y] == 1.0 - (
            1.0 - 1.0 / (lft + _EPS)
        ) * mod.V04IndxEndogScrap[cy, pg, y] * mod.V04CCSRetroFit[cy, pg, y]

    m.Q04ScrpRate = Constraint(
        run_cy, pgall, ytime, rule=_q04_scrp_rate
    )

    # Q04ConsFuelElecProd: Fuel consumption for electricity production = sum over PGALL of VmProdElec * smTWhToMtoe / eff * fuel share (PGALLtoEF).
    def _q04_cons_fuel_elec_prod(mod, cy, pgef_ef, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        s = sum(
            mod.VmProdElec[cy, pg, y]
            * mod.smTWhToMtoe
            / (mod.imPlantEffByType[cy, pg, y] + _EPS)
            for (pg, ef) in pgalltoef
            if ef == pgef_ef
        )
        return mod.VmConsFuelElecProd[cy, pgef_ef, y] == s

    m.Q04ConsFuelElecProd = Constraint(
        run_cy, pgef, ytime, rule=_q04_cons_fuel_elec_prod
    )
