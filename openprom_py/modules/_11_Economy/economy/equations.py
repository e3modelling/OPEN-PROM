"""
Module 11_Economy (economy): equation definitions.

Mirrors modules/11_Economy/economy/equations.gms.
Q11SubsiTot, Q11SubsiDemTechAvail, Q11SubsiDemITech, Q11SubsiDemTech (=0 with $ontext full formula),
Q11SubsiSupTech, Q11SubsiCapCostTech, Q11NetSubsiTax. $ontext Q11SubsiCapCostSupply transferred as comments.
"""
from pyomo.core import ConcreteModel, Constraint
from pyomo.environ import sqrt, value as pyo_value

from core import sets as core_sets

_EPS = 1e-10


def _year_prev(ytime_list, y):
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def add_economy_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add all Q11* constraints."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = set(core_sets_obj.time) if hasattr(core_sets_obj, "time") else set(ytime)
    dsbs = list(core_sets.DSBS)
    sbs = list(core_sets.SBS)
    tech = list(core_sets.TECH)
    itech = list(core_sets.ITECH)
    stech = list(getattr(core_sets, "STECH", core_sets.PGALL))
    ssbs = list(core_sets.SSBS)
    sectech = core_sets.SECTTECH
    indse = set(core_sets.INDSE)
    transe = set(core_sets.TRANSE)
    cdr = set(getattr(core_sets, "CDR", ("DAC", "EW")))
    ef = list(core_sets.EF)
    ef_to_efs = getattr(core_sets, "EFtoEFS", set())
    nap_to_pg = [(n, s) for (n, s) in getattr(core_sets, "NAPtoALLSBS", []) if s == "PG"]
    ttech = list(core_sets.TTECH)

    # -------------------------------------------------------------------------
    # Q11SubsiTot (GAMS): The equation computes the total state revenues from carbon taxes, as the product
    # of all fuel consumption in all subsectors of the supply side, along with the relevant fuel emission
    # factor, and the carbon tax posed regionally that year. This is added to the 0.5% of the GDP, which
    # is assumed to be used by each state for green subsidies. Plus VmNetSubsiTax(t-1).
    # -------------------------------------------------------------------------
    def _q11_subsi_tot(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        # sum((EF,EFS)$EFtoEFS: VmConsFinEneCountry(cy,EF,y-1)*imCo2EmiFac(cy,"PG",EF,y-1). Use EFS index for VmConsFinEneCountry.
        term_cons = 0.0
        for (ef_, efs_) in ef_to_efs:
            if not hasattr(mod, "VmConsFinEneCountry"):
                break
            try:
                term_cons += mod.VmConsFinEneCountry[cy, efs_, y_1] * pyo_value(mod.imCo2EmiFac[cy, "PG", ef_, y_1])
            except Exception:
                pass
        term_supply = sum(mod.V07GrossEmissCO2Supply[cy, ss, y_1] for ss in ssbs) if hasattr(mod, "V07GrossEmissCO2Supply") else 0.0
        term_cap = sum(mod.V06CapCO2ElecHydr[cy, sb, y_1] for sb in sbs) if hasattr(mod, "V06CapCO2ElecHydr") else 0.0
        bracket = (term_cons + term_supply - term_cap + sqrt((term_cons + term_supply - term_cap) ** 2 + _EPS)) / 2.0
        car_sum = sum(mod.VmCarVal[cy, n, y_1] for (n, s) in nap_to_pg)
        gdp_term = 0.005 * pyo_value(mod.i01GDP[y_1, cy]) * 1000.0 if hasattr(mod, "i01GDP") else 0.0
        rhs = bracket * car_sum + gdp_term + mod.VmNetSubsiTax[cy, y_1]
        return mod.V11SubsiTot[cy, y] == rhs

    m.Q11SubsiTot = Constraint(run_cy, ytime, rule=_q11_subsi_tot)

    # -------------------------------------------------------------------------
    # Q11SubsiDemTechAvail (GAMS): The equation splits the available state grants to the various demand
    # technologies through a policy parameter expressing this proportional division. The resulting amount
    # (in Millions US$2015) is going to be implemented to the cost calculation of each subsidized demand technology.
    # -------------------------------------------------------------------------
    def _q11_subsi_dem_tech_avail(mod, cy, dsb, t, y):
        if y not in time_set or cy not in run_cy or (dsb, t) not in sectech:
            return Constraint.Skip
        return mod.VmSubsiDemTechAvail[cy, dsb, t, y] == mod.V11SubsiTot[cy, y] * mod.i11SubsiPerDemTechAvail[cy, dsb, t, y]

    m.Q11SubsiDemTechAvail = Constraint(run_cy, dsbs, tech, ytime, rule=_q11_subsi_dem_tech_avail)

    # -------------------------------------------------------------------------
    # Q11SubsiDemITech (GAMS): The equation calculates the state support per unit of new capacity in the
    # industrial subsectors and technologies (kUS$2015/toe-year). Applied when ord(YTIME) > 15.
    # -------------------------------------------------------------------------
    def _q11_subsi_dem_itech(mod, cy, dsb, it, y):
        if y not in time_set or cy not in run_cy or dsb not in indse or dsb in cdr or (dsb, it) not in sectech:
            return Constraint.Skip
        try:
            ord_y = ytime.index(y) + 1
            if ord_y <= 15:
                return Constraint.Skip
        except ValueError:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        den = (
            mod.V02ShareTechNewEquipUseful[cy, dsb, it, y_1] * mod.V02GapUsefulDemSubsec[cy, dsb, y_1] * 1e6
            * mod.VmLft[cy, dsb, it, y] + 1e-6
        )
        a = mod.VmSubsiDemTechAvail[cy, dsb, it, y] * 1e3 / den
        b = (1.0 - pyo_value(mod.imCapCostTechMin[cy, dsb, it, y])) * mod.V02CostTech[cy, dsb, it, y_1]
        rhs = (a + b - sqrt((a - b) ** 2 + _EPS)) / 2.0
        return mod.VmSubsiDemITech[cy, dsb, it, y] == rhs

    m.Q11SubsiDemITech = Constraint(run_cy, dsbs, itech, ytime, rule=_q11_subsi_dem_itech)

    # -------------------------------------------------------------------------
    # Q11SubsiDemTech (GAMS): The equation calculates the state support per unit of new capacity in the
    # demand subsectors and technologies: Transport (kUS$2015 per vehicle), Industry (kUS$2015/toe-year),
    # CDR, Residential electricity. Active in GAMS: = 0. $ontext full formula (Transport EV, Industry VmSubsiDemITech, CDR):
    #   sum(TTECH$(sameas(TECH,TTECH)), (VmSubsiDemTechAvail*1e3/(V01NewRegPcTechYearly*1e6) + (1-imCapCostTechMin)*imCapCostTech - sqrt(sqr(...)))/2 )$(ord(YTIME)>15 and TRANSE and PC and TELC)
    #   + sum(ITECH$(sameas(TECH,ITECH)), VmSubsiDemITech)$INDSE + sum(DACTECH, ...)$DAC
    # $offtext
    # -------------------------------------------------------------------------
    def _q11_subsi_dem_tech(mod, cy, dsb, t, y):
        if y not in time_set or cy not in run_cy or (dsb, t) not in sectech:
            return Constraint.Skip
        return mod.VmSubsiDemTech[cy, dsb, t, y] == 0.0

    m.Q11SubsiDemTech = Constraint(run_cy, dsbs, tech, ytime, rule=_q11_subsi_dem_tech)

    # -------------------------------------------------------------------------
    # Q11SubsiSupTech (GAMS): The equation splits the available state grants to the various supply
    # technologies through a policy parameter. Resulting amount (Millions US$2015) to cost of each
    # subsidized supply technology. Active: VmSubsiSupTech = V11SubsiTot (!! * i11SubsiPerSupTech commented).
    # -------------------------------------------------------------------------
    def _q11_subsi_sup_tech(mod, cy, st, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.VmSubsiSupTech[cy, st, y] == mod.V11SubsiTot[cy, y]

    m.Q11SubsiSupTech = Constraint(run_cy, stech, ytime, rule=_q11_subsi_sup_tech)

    # -------------------------------------------------------------------------
    # Q11SubsiCapCostTech (GAMS): Subsidies in demand (Millions US$2015). GIVING DUPLICATES AND NEED TO DEAL WITH SUM.
    # Transport subsidies (TTECH, PC): VmSubsiDemTechAvail + imCapCostTechMin*imCapCostTech*1e-3*(V01NewRegPcTechYearly*1e6) - sqrt(sqr(...)); Industry (ITECH): similar with V02CostTech, V02EquipCapTechSubsec, V02RemEquipCapTechSubsec, VmLft. CDR/residential !! commented in GAMS.
    # -------------------------------------------------------------------------
    def _q11_subsi_cap_cost_tech(mod, cy, dsb, t, y):
        if y not in time_set or cy not in run_cy or (dsb, t) not in sectech:
            return Constraint.Skip
        y_1 = _year_prev(ytime, y)
        rhs = 0.0
        if dsb in transe and dsb == "PC" and t in ttech:
            avail = mod.VmSubsiDemTechAvail[cy, dsb, t, y]
            capmin = pyo_value(mod.imCapCostTechMin[cy, dsb, t, y]) * pyo_value(mod.imCapCostTech[cy, dsb, t, y]) * 1e-3
            new_reg = mod.V01NewRegPcTechYearly[cy, t, y_1] * 1e6
            rhs = (avail + capmin * new_reg - sqrt((avail - capmin * new_reg) ** 2 + _EPS)) / 2.0
        elif dsb in indse and t in itech:
            avail = mod.VmSubsiDemTechAvail[cy, dsb, t, y]
            capmin = pyo_value(mod.imCapCostTechMin[cy, dsb, t, y]) * mod.V02CostTech[cy, dsb, t, y] * 1e3
            diff = (mod.V02EquipCapTechSubsec[cy, dsb, t, y] - mod.V02RemEquipCapTechSubsec[cy, dsb, t, y]) * mod.VmLft[cy, dsb, t, y]
            rhs = (avail + capmin * diff - sqrt((avail - capmin * diff) ** 2 + _EPS)) / 2.0
        return mod.VmSubsiCapCostTech[cy, dsb, t, y] == rhs

    m.Q11SubsiCapCostTech = Constraint(run_cy, dsbs, tech, ytime, rule=_q11_subsi_cap_cost_tech)

    # $ontext Q11SubsiCapCostSupply(allCy,SSBS,STECH,YTIME): VmSubsiCapCostSupply = sum(PGALL, i04GrossCapCosSubRen*imFacSubsiCapCostSupply*V04NewCapElec*1e3/i04AvailRate + imGrantCapCostSupply*...) $PG
    #   + sum(H2TECH, V05CostProdH2Tech*VmDemTotH2*(1-V05ShareCCSH2Prod)*(1-V05ShareNoCCSH2Prod)*imFacSubsiCapCostSupply + ...) $H2P
    # $offtext (commented in GAMS — not added as constraint)

    # -------------------------------------------------------------------------
    # Q11NetSubsiTax (GAMS): This equation calculates the difference between the state revenues from
    # collected carbon taxes, and the green grants and subsidies given in both the supply and demand sectors.
    # VmNetSubsiTax = V11SubsiTot - sum((DSBS,TECH)$SECTTECH, VmSubsiCapCostTech). !! supply sum commented.
    # -------------------------------------------------------------------------
    def _q11_net_subsi_tax(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        tot = sum(mod.VmSubsiCapCostTech[cy, dsb, t, y] for dsb in dsbs for t in tech if (dsb, t) in sectech)
        return mod.VmNetSubsiTax[cy, y] == mod.V11SubsiTot[cy, y] - tot

    m.Q11NetSubsiTax = Constraint(run_cy, ytime, rule=_q11_net_subsi_tax)
