"""
Transport (simple) preloop: fix historical and initial values, set bounds.

From 01_Transport/simple/preloop.gms. For data years (datay), we fix stock,
ownership level, scrappage rates, new registrations, goods transport activity,
and gap; for the first solving year we fix V01RateScrPc from i01TechLft when
no lag is available. VmLft is fixed for non-PC subsectors and for PC in datay.
V01PremScrp is determined by equation Q01PremScrp and is not fixed here.
"""
from pyomo.core import ConcreteModel, value

from core import sets as core_sets


def _param_val(p, *idx):
    """Return Param value at index or None if missing/invalid (safe for sparse data)."""
    try:
        return value(p[idx])
    except (KeyError, TypeError):
        return None


def apply_transport_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """
    Fix variables for data years; set bounds and initial values for solving years.

    - Data years (y in datay): fix V01StockPcYearly, V01PcOwnPcLevl, V01RateScrPc,
      V01RateScrPcTot, V01StockPcYearlyTech, V01NewRegPcYearly, V01ActivGoodsTransp,
      V01GapTranspActiv from parameters (imActv, i01Pop, i01TechLft, i01StockPC,
      i01NewReg). For first solving year, fix V01RateScrPc from i01TechLft where not fixed.
    - Bounds: V01PcOwnPcLevl <= 2, V01RateScrPc and V01PremScrp in [0, 1].
    - Non-PC tech: fix V01RateScrPc and V01RateScrPcTot to 0. VmLft fixed for
      non-SECTTECH and for PC/datay and non-PC from i01TechLft.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = core_sets_obj.datay
    ttech = list(core_sets.TTECH)
    trans = list(core_sets.TRANSE)

    # --- Data years: fix all historical transport variables from parameters ---
    for cy in run_cy:
        for y in ytime:
            if y in datay:
                # PC stock from activity (imActv)
                actv_pc = _param_val(m.imActv, y, cy, "PC")
                m.V01StockPcYearly[cy, y].fix(actv_pc if actv_pc is not None else 0.1)
                # Ownership level = stock / (pop * 1000)
                pop = _param_val(m.i01Pop, y, cy)
                if pop is not None and pop > 0:
                    m.V01PcOwnPcLevl[cy, y].fix(m.V01StockPcYearly[cy, y].value / (pop * 1000))
                else:
                    m.V01PcOwnPcLevl[cy, y].fix(0.1)
                # Scrappage rate from lifetime (1/LFT) for PC techs
                for tech in ttech:
                    if ("PC", tech) in core_sets.SECTTECH:
                        lft = _param_val(m.i01TechLft, cy, "PC", tech, y)
                        m.V01RateScrPc[cy, tech, y].fix(1.0 / lft if lft and lft > 0 else 0.05)
                        m.V01RateScrPcTot[cy, tech, y].fix(m.V01RateScrPc[cy, tech, y].value)
                    st = _param_val(m.i01StockPC, cy, tech, y)
                    m.V01StockPcYearlyTech[cy, tech, y].fix(st if st is not None else 0.0)
                nr = _param_val(m.i01NewReg, cy, y)
                m.V01NewRegPcYearly[cy, y].fix(nr if nr is not None else 0.0)
                # Goods transport activity (GU, GT, GN) from imActv
                for tr in ("GU", "GT", "GN"):
                    av = _param_val(m.imActv, y, cy, tr)
                    m.V01ActivGoodsTransp[cy, tr, y].fix(av if av is not None else (0.1 if tr == "GU" else 0.0))
                for tr in trans:
                    m.V01GapTranspActiv[cy, tr, y].fix(0.0)

    # --- First solving year: fix V01RateScrPc from i01TechLft where no lag ---
    an = core_sets_obj.an
    if an:
        first_y = an[0]
        for cy in run_cy:
            for tech in ttech:
                if ("PC", tech) in core_sets.SECTTECH and not m.V01RateScrPc[cy, tech, first_y].fixed:
                    lft = _param_val(m.i01TechLft, cy, "PC", tech, first_y)
                    m.V01RateScrPc[cy, tech, first_y].fix(1.0 / lft if lft and lft > 0 else 0.05)

    # --- Bounds: ownership level and scrappage/premature scrapping rates ---
    for idx in m.V01PcOwnPcLevl:
        m.V01PcOwnPcLevl[idx].setub(2.0)
    for idx in m.V01RateScrPc:
        m.V01RateScrPc[idx].setlb(0.0)
        m.V01RateScrPc[idx].setub(1.0)
    for idx in m.V01PremScrp:
        m.V01PremScrp[idx].setlb(0.0)
        m.V01PremScrp[idx].setub(1.0)

    # --- Non-PC technologies: scrappage rates fixed to 0 ---
    for cy in run_cy:
        for tech in ttech:
            if ("PC", tech) not in core_sets.SECTTECH:
                for y in ytime:
                    m.V01RateScrPc[cy, tech, y].fix(0.0)
                    m.V01RateScrPcTot[cy, tech, y].fix(0.0)

    # --- VmLft: fix for non-PC subsectors and for PC in datay (from i01TechLft) ---
    dsbs = list(core_sets.DSBS)
    tech_all = list(core_sets.TECH)
    for cy in run_cy:
        for sb in dsbs:
            for tech in tech_all:
                for y in ytime:
                    if (sb, tech) not in core_sets.SECTTECH:
                        m.VmLft[cy, sb, tech, y].fix(0.0)
                    elif sb == "PC" and y in datay:
                        lft = _param_val(m.i01TechLft, cy, "PC", tech, y)
                        m.VmLft[cy, sb, tech, y].fix(lft if lft and lft > 0 else 10.0)
                    elif sb != "PC":
                        lft = _param_val(m.i01TechLft, cy, sb, tech, y)
                        m.VmLft[cy, sb, tech, y].fix(lft if lft and lft > 0 else 10.0)

    # V01PremScrp is defined by equation Q01PremScrp (uses i01PremScrpFac); do not fix here.
