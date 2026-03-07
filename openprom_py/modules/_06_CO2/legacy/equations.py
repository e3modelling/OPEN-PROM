"""
Module 06_CO2 (legacy): equation definitions.

Mirrors modules/06_CO2/legacy/equations.gms. Q06CapCO2ElecHydr, Q06CaptCummCO2,
Q06CstCO2SeqCsts, Q06GrossCapDAC, Q06FixOandMDAC, Q06VarCostDAC, Q06LvlCostDAC,
Q06ProfRateDAC, Q06CapFacNewDAC, Q06CapCDR, Q06ConsFuelTechCDRProd, Q06ConsFuelCDRProd.
"""
import math
from pyomo.core import ConcreteModel, Constraint
from pyomo.environ import exp, sqrt

from core import sets as core_sets

_EPS = 1e-6
# Learning curve exponent (GAMS: log(0.97)/log(2))
_LOG097_LOG2 = math.log(0.97) / math.log(2.0)


def _year_prev(ytime_list, y):
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def add_co2_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add all Q06* constraints for 06_CO2 (legacy)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    sbs = list(core_sets.SBS)
    cdrtech = list(core_sets.CDRTECH)
    dactech = set(core_sets.DACTECH)
    ef_list = list(core_sets.EFS) if hasattr(core_sets, "EFS") else list(core_sets.EF)
    ccs_pg = set(core_sets.CCS_PG)
    pgalltoef = getattr(core_sets, "PGALLtoEF", set())
    indse1 = list(core_sets.INDSE1)
    ccstech = set(core_sets.CCSTECH)
    secttech = core_sets.SECTTECH
    itechtoef = core_sets.ITECHtoEF
    cdrtechtoef = core_sets.CDRTECHtoEF
    nap_dac = [n for (n, sb) in core_sets.NAPtoALLSBS if sb == "DAC"]
    if not nap_dac:
        nap_dac = list(core_sets.NAP)
    h2tech = list(core_sets.H2TECH) if hasattr(core_sets, "H2TECH") else []
    h2techeftoef = getattr(core_sets, "H2TECHEFtoEF", set())

    # Q06CapCO2ElecHydr: CO2 captured by sector (PG CCS, H2P CCS, DAC, EW, IND)
    def _q06_cap_co2(mod, cy, sb, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        rhs = 0.0
        if sb == "PG" and hasattr(mod, "VmProdElec") and hasattr(mod, "V04CO2CaptRate"):
            for (ccs, efs) in pgalltoef:
                if ccs not in ccs_pg:
                    continue
                rhs += (
                    mod.VmProdElec[cy, ccs, y] * mod.smTWhToMtoe
                    / (mod.imPlantEffByType[cy, ccs, y] + _EPS)
                    * (mod.imCo2EmiFac[cy, sb, efs, y] + (4.17 if efs == "BMSWAS" else 0.0))
                    * mod.V04CO2CaptRate[cy, ccs, y]
                )
        if sb == "H2P" and hasattr(mod, "VmConsFuelTechH2Prod") and hasattr(mod, "V05CaptRateH2"):
            for (ht, efs) in h2techeftoef:
                rhs += (
                    mod.VmConsFuelTechH2Prod[cy, ht, efs, y]
                    * (mod.imCo2EmiFac[cy, sb, efs, y] + (4.17 if efs == "BMSWAS" else 0.0))
                    * mod.V05CaptRateH2[cy, ht, y]
                )
        if sb == "DAC":
            rhs += sum(mod.V06CapCDR[cy, tech, y] * 1e-6 for tech in dactech)
        if sb == "EW":
            rhs += mod.V06CapCDR[cy, "TEW", y] * 1e-6
        if sb in indse1 and hasattr(mod, "i02ShareBlend") and hasattr(mod, "V02EquipCapTechSubsec") and hasattr(mod, "imCO2CaptRateIndustry"):
            for (dsbs, tech) in secttech:
                if dsbs != sb or tech not in ccstech:
                    continue
                for (t, efs) in itechtoef:
                    if t != tech:
                        continue
                    rhs += (
                        mod.i02ShareBlend[cy, sb, tech, efs, y]
                        * mod.V02EquipCapTechSubsec[cy, sb, tech, y]
                        * mod.i02util[cy, sb, tech, y]
                        * mod.imCO2CaptRateIndustry[cy, tech, y]
                        * (mod.imCo2EmiFac[cy, sb, efs, y] + (4.17 if efs == "BMSWAS" else 0.0))
                    )
                    break  # one fuel per tech in ITECHtoEF for this tech
        return mod.V06CapCO2ElecHydr[cy, sb, y] == rhs

    m.Q06CapCO2ElecHydr = Constraint(run_cy, sbs, ytime, rule=_q06_cap_co2)

    # Q06CaptCummCO2: cumulative = previous + sum over SBS (excl EW) of V06CapCO2ElecHydr
    def _q06_cumm(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        prev = mod.V06CaptCummCO2[cy, yp]
        add = sum(mod.V06CapCO2ElecHydr[cy, sb, y] for sb in sbs if sb != "EW")
        return mod.V06CaptCummCO2[cy, y] == prev + add

    m.Q06CaptCummCO2 = Constraint(run_cy, ytime, rule=_q06_cumm)

    # Q06CstCO2SeqCsts: sequestration cost curve (core Var)
    def _q06_cst_seq(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        mc_b = mod.i06ElastCO2Seq[cy, "mc_b"]
        mc_d = mod.i06ElastCO2Seq[cy, "mc_d"]
        return mod.VmCstCO2SeqCsts[cy, y] == (
            0.6 * mc_b
            + (1.0 - 0.6) * mc_b * exp(mod.V06CaptCummCO2[cy, y] / (mc_d + _EPS))
        )

    m.Q06CstCO2SeqCsts = Constraint(run_cy, ytime, rule=_q06_cst_seq)

    # Q06GrossCapDAC: learning curve (sum over run_cy of V06CapCDR lagged)
    def _q06_gross(mod, tech, y):
        if y not in time_set:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        cap_prev = sum(mod.V06CapCDR[cy, tech, yp] for cy in run_cy)
        base = mod.i06GrossCapDAC[tech] * (cap_prev + _EPS) ** _LOG097_LOG2
        mn = mod.i06GrossCapDACMin[tech]
        return mod.V06GrossCapDAC[tech, y] == 0.5 * (
            base + mn + sqrt((base - mn) ** 2 + _EPS)
        )

    m.Q06GrossCapDAC = Constraint(cdrtech, ytime, rule=_q06_gross)

    # Q06FixOandMDAC
    def _q06_fix(mod, tech, y):
        if y not in time_set:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        cap_prev = sum(mod.V06CapCDR[cy, tech, yp] for cy in run_cy)
        base = mod.i06FixOandMDAC[tech] * (cap_prev + _EPS) ** _LOG097_LOG2
        mn = mod.i06FixOandMDACMin[tech]
        return mod.V06FixOandMDAC[tech, y] == 0.5 * (base + mn + sqrt((base - mn) ** 2 + _EPS))

    m.Q06FixOandMDAC = Constraint(cdrtech, ytime, rule=_q06_fix)

    # Q06VarCostDAC
    def _q06_var(mod, tech, y):
        if y not in time_set:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        cap_prev = sum(mod.V06CapCDR[cy, tech, yp] for cy in run_cy)
        base = mod.i06VarCostDAC[tech] * (cap_prev + _EPS) ** _LOG097_LOG2
        mn = mod.i06VarCostDACMin[tech]
        return mod.V06VarCostDAC[tech, y] == 0.5 * (base + mn + sqrt((base - mn) ** 2 + _EPS))

    m.Q06VarCostDAC = Constraint(cdrtech, ytime, rule=_q06_var)

    # Q06LvlCostDAC: levelized cost incl subsidies and fuel
    def _q06_lvl(mod, cy, tech, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        sub_dac = mod.VmSubsiDemTech[cy, "DAC", tech, y] if tech in dactech else 0.0
        sub_ew = mod.VmSubsiDemTech[cy, "EW", tech, y] if tech == "TEW" else 0.0
        rhs = (
            mod.V06GrossCapDAC[tech, y]
            - sub_dac - sub_ew
            + mod.V06FixOandMDAC[tech, y]
            + mod.V06VarCostDAC[tech, y]
            - 20.0
            + mod.i06SpecElecDAC[cy, tech, y] * mod.VmPriceFuelSubsecCarVal[cy, "OI", "ELC", y]
            + mod.i06SpecHeatDAC[cy, tech, y] * mod.VmPriceFuelSubsecCarVal[cy, "OI", "NGS", y] / 0.85
            + mod.VmCstCO2SeqCsts[cy, y]
        )
        return mod.V06LvlCostDAC[cy, tech, y] == rhs

    m.Q06LvlCostDAC = Constraint(run_cy, cdrtech, ytime, rule=_q06_lvl)

    # Q06ProfRateDAC: carbon value / levelized cost (lagged)
    def _q06_prof(mod, cy, tech, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        car = sum(mod.VmCarVal[cy, n, y] for n in nap_dac)
        return mod.V06ProfRateDAC[cy, tech, y] == car / (mod.V06LvlCostDAC[cy, tech, yp] + _EPS)

    m.Q06ProfRateDAC = Constraint(run_cy, cdrtech, ytime, rule=_q06_prof)

    # Q06CapFacNewDAC
    def _q06_capfac(mod, cy, tech, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = exp(mod.i06MatFacDAC[tech] * mod.V06ProfRateDAC[cy, tech, y] - 1.0)
        denom = exp(mod.i06MatFacDAC[tech] * mod.S06ProfRateMaxDAC - 1.0)
        return mod.V06CapFacNewDAC[cy, tech, y] == (
            num / (denom + _EPS) * (mod.S06CapFacMaxNewDAC - mod.S06CapFacMinNewDAC)
            + mod.S06CapFacMinNewDAC
        )

    m.Q06CapFacNewDAC = Constraint(run_cy, cdrtech, ytime, rule=_q06_capfac)

    # Q06CapCDR: capacity growth + scheduled
    def _q06_cap_cdr(mod, cy, tech, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        return mod.V06CapCDR[cy, tech, y] == (
            mod.V06CapCDR[cy, tech, yp] * (1.0 + mod.V06CapFacNewDAC[cy, tech, y])
            + mod.i06SchedNewCapDAC[cy, tech, y]
        )

    m.Q06CapCDR = Constraint(run_cy, cdrtech, ytime, rule=_q06_cap_cdr)

    # Q06ConsFuelTechCDRProd: fuel use per tech (ngs, H2F, elc from spec heat/elec)
    def _q06_cons_tech(mod, cy, tech, ef_, y):
        if y not in time_set or cy not in run_cy or (tech, ef_) not in cdrtechtoef:
            return Constraint.Skip
        cap = mod.V06CapCDR[cy, tech, y]
        if ef_ == "NGS" or ef_ == "ngs":
            return mod.VmConsFuelTechCDRProd[cy, tech, ef_, y] == (
                cap * mod.i06SpecHeatDAC[cy, tech, y] / 0.85
            ) / 1e6
        if ef_ == "H2F":
            return mod.VmConsFuelTechCDRProd[cy, tech, ef_, y] == (
                cap * mod.i06SpecHeatDAC[cy, tech, y] / 0.85
            ) / 1e6
        if ef_ == "ELC" or ef_ == "elc":
            return mod.VmConsFuelTechCDRProd[cy, tech, ef_, y] == (
                cap * mod.i06SpecElecDAC[cy, tech, y]
            ) / 1e6
        return Constraint.Skip

    m.Q06ConsFuelTechCDRProd = Constraint(run_cy, cdrtech, ef_list, ytime, rule=_q06_cons_tech)

    # Q06ConsFuelCDRProd: sum over CDRTECH
    def _q06_cons(mod, cy, ef_, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.VmConsFuelCDRProd[cy, ef_, y] == sum(
            mod.VmConsFuelTechCDRProd[cy, tech, ef_, y]
            for (tech, e) in cdrtechtoef
            if e == ef_
        )

    m.Q06ConsFuelCDRProd = Constraint(run_cy, ef_list, ytime, rule=_q06_cons)
