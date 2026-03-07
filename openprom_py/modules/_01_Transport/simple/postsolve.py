"""
Transport (simple) postsolve: fix solution values for the next time step.

From 01_Transport/simple/postsolve.gms. After each solve, fix all Transport
(and shared VmLft) variables at the given year to their current solution (.value)
so that in a multi-year loop the next solve sees the previous year as fixed.
"""
from pyomo.core import ConcreteModel, value

from core import sets as core_sets


def apply_transport_postsolve(m: ConcreteModel, core_sets_obj, year: int) -> None:
    """
    Fix all Transport and VmLft variables at the given year to their current solution.

    Call this after each successful solve for `year` so that when solving the next
    year (or when re-solving), the solution at `year` is preserved as fixed.
    Mirrors GAMS: Var.FX(runCyL, ..., YTIME)$TIME(YTIME) = Var.L(...).
    """
    run_cy = core_sets_obj.runCy
    ttech = list(core_sets.TTECH)
    trans = list(core_sets.TRANSE)
    ef = list(core_sets.EF)
    dsbs = list(core_sets.DSBS)
    tech_all = list(core_sets.TECH)

    for cy in run_cy:
        try:
            m.V01StockPcYearly[cy, year].fix(value(m.V01StockPcYearly[cy, year]))
        except (TypeError, KeyError):
            pass
        try:
            m.V01PcOwnPcLevl[cy, year].fix(value(m.V01PcOwnPcLevl[cy, year]))
        except (TypeError, KeyError):
            pass
        try:
            m.V01NewRegPcYearly[cy, year].fix(value(m.V01NewRegPcYearly[cy, year]))
        except (TypeError, KeyError):
            pass
        try:
            m.V01NumPcScrap[cy, year].fix(value(m.V01NumPcScrap[cy, year]))
        except (TypeError, KeyError):
            pass

        for tech in ttech:
            try:
                m.V01RateScrPc[cy, tech, year].fix(value(m.V01RateScrPc[cy, tech, year]))
                m.V01RateScrPcTot[cy, tech, year].fix(value(m.V01RateScrPcTot[cy, tech, year]))
                m.V01StockPcYearlyTech[cy, tech, year].fix(value(m.V01StockPcYearlyTech[cy, tech, year]))
            except (TypeError, KeyError):
                pass

        for tran in trans:
            try:
                m.V01ActivGoodsTransp[cy, tran, year].fix(value(m.V01ActivGoodsTransp[cy, tran, year]))
                m.V01ActivPassTrnsp[cy, tran, year].fix(value(m.V01ActivPassTrnsp[cy, tran, year]))
                m.V01GapTranspActiv[cy, tran, year].fix(value(m.V01GapTranspActiv[cy, tran, year]))
            except (TypeError, KeyError):
                pass
            for tech in ttech:
                try:
                    m.V01CostTranspPerMeanConsSize[cy, tran, tech, year].fix(value(m.V01CostTranspPerMeanConsSize[cy, tran, tech, year]))
                    m.V01CostFuel[cy, tran, tech, year].fix(value(m.V01CostFuel[cy, tran, tech, year]))
                    m.V01PremScrp[cy, tran, tech, year].fix(value(m.V01PremScrp[cy, tran, tech, year]))
                except (TypeError, KeyError):
                    pass
                for e in ef:
                    try:
                        m.V01ConsSpecificFuel[cy, tran, tech, e, year].fix(value(m.V01ConsSpecificFuel[cy, tran, tech, e, year]))
                        m.V01ConsTechTranspSectoral[cy, tran, tech, e, year].fix(value(m.V01ConsTechTranspSectoral[cy, tran, tech, e, year]))
                    except (TypeError, KeyError):
                        pass
            for e in ef:
                try:
                    m.VmDemFinEneTranspPerFuel[cy, tran, e, year].fix(value(m.VmDemFinEneTranspPerFuel[cy, tran, e, year]))
                except (TypeError, KeyError):
                    pass

        for sb in dsbs:
            for tech in tech_all:
                try:
                    m.VmLft[cy, sb, tech, year].fix(value(m.VmLft[cy, sb, tech, year]))
                except (TypeError, KeyError):
                    pass
