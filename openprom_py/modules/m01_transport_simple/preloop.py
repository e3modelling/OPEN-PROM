"""
Transport (simple) preloop: fix historical and initial values, set bounds.

From 01_Transport/simple/preloop.gms. For data years (datay), we fix stock,
ownership level, scrappage rates, new registrations, goods transport activity,
and gap; V01NumPcScrap fixed only at base year. V01ConsSpecificFuel, V01ConsTechTranspSectoral,
VmDemFinEneTranspPerFuel, V01CapCostAnnualized, V01CostFuel, V01CostTranspPerMeanConsSize
fixed for datay. V01PremScrp is determined by equation Q01PremScrp and is not fixed here.
"""
from math import exp

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
    Fix variables for data years; set bounds and initial values; match GAMS preloop.

    - Data years: fix V01StockPcYearly, V01PcOwnPcLevl, V01RateScrPc, V01RateScrPcTot,
      V01StockPcYearlyTech, V01NewRegPcYearly, V01ActivGoodsTransp, V01GapTranspActiv.
    - Base year only: V01NumPcScrap = sum_tech V01RateScrPcTot * V01StockPcYearlyTech.
    - V01ConsSpecificFuel: fix from i01InitSpecFuelConsData (non-PC) or i01SFCPC (PC).
    - V01ConsTechTranspSectoral: fix for datay from imFuelConsPerFueSub (non-PLUGIN); PLUGIN/CHYBV = 0.
    - VmDemFinEneTranspPerFuel: fix for not-an to imFuelConsPerFueSub; non-SECtoEF = 0.
    - V01CapCostAnnualized, V01CostFuel, V01CostTranspPerMeanConsSize: fix for datay from formulas.
    - LO: V01CostTranspPerMeanConsSize = epsilon6, V01ShareTechTr = 0.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = core_sets_obj.datay
    time_set = core_sets_obj.time  # an (solving horizon)
    base_y = core_sets_obj.base_year()
    ttech = list(core_sets.TTECH)
    trans = list(core_sets.TRANSE)
    ef = list(core_sets.EF)
    PLUGIN = core_sets.PLUGIN
    CHYBV = core_sets.CHYBV

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

    # --- V01NumPcScrap: fix only at base year = sum_tech V01RateScrPcTot * V01StockPcYearlyTech ---
    for cy in run_cy:
        total = 0.0
        for tech in ttech:
            try:
                total += value(m.V01RateScrPcTot[cy, tech, base_y]) * value(m.V01StockPcYearlyTech[cy, tech, base_y])
            except (TypeError, KeyError):
                pass
        m.V01NumPcScrap[cy, base_y].fix(total if total else 0.0)

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

    # --- V01ConsSpecificFuel: fix from i01InitSpecFuelConsData (non-PC) or i01SFCPC (PC) ---
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for e in ef:
                    if (tech, e) not in core_sets.TTECHtoEF:
                        continue
                    for y in ytime:
                        if tran == "PC":
                            v = _param_val(m.i01SFCPC, cy, tech, e, y)
                            m.V01ConsSpecificFuel[cy, tran, tech, e, y].fix(v if v is not None else 0.0)
                        else:
                            v = _param_val(m.i01InitSpecFuelConsData, tran, tech, e)
                            m.V01ConsSpecificFuel[cy, tran, tech, e, y].fix(v if v is not None else 0.0)

    # --- V01ConsTechTranspSectoral: fix for datay from imFuelConsPerFueSub (non-PLUGIN); PLUGIN and CHYBV = 0 ---
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for y in datay:
                    for e in ef:
                        if (tech, e) not in core_sets.TTECHtoEF:
                            continue
                        if tech in PLUGIN or tech in CHYBV:
                            m.V01ConsTechTranspSectoral[cy, tran, tech, e, y].fix(0.0)
                        else:
                            fc = _param_val(m.imFuelConsPerFueSub, cy, tran, e, y)
                            m.V01ConsTechTranspSectoral[cy, tran, tech, e, y].fix(fc if fc is not None else 0.0)

    # --- VmDemFinEneTranspPerFuel: fix for not-an to imFuelConsPerFueSub; non-SECtoEF = 0 ---
    for cy in run_cy:
        for tran in trans:
            for e in ef:
                for y in ytime:
                    if (tran, e) not in core_sets.SECtoEF:
                        m.VmDemFinEneTranspPerFuel[cy, tran, e, y].fix(0.0)
                    elif y not in time_set:
                        fc = _param_val(m.imFuelConsPerFueSub, cy, tran, e, y)
                        m.VmDemFinEneTranspPerFuel[cy, tran, e, y].fix(fc if fc is not None else 0.0)

    # --- V01CapCostAnnualized: LO=0; fix for datay from formula ---
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for y in ytime:
                    m.V01CapCostAnnualized[cy, tran, tech, y].setlb(0.0)
                for y in datay:
                    disc = _param_val(m.imDisc, cy, tran, y) or 0.1
                    lft = _param_val(m.i01TechLft, cy, tran, tech, y) or 20.0
                    num = disc * exp(disc * lft) / (exp(disc * lft) - 1.0 + 1e-12)
                    cap = _param_val(m.imCapCostTech, cy, tran, tech, y) or 0.0
                    cgi = _param_val(m.imCGI, cy, y) or 1.0
                    m.V01CapCostAnnualized[cy, tran, tech, y].fix(num * cap * cgi)

    # --- V01CostFuel: LO=0, L=1; fix for datay from formula (simplified: use current .value where needed) ---
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for y in ytime:
                    m.V01CostFuel[cy, tran, tech, y].setlb(0.0)
                for y in datay:
                    try:
                        if tran == "PC":
                            scale = 1e-3 * value(m.V01ActivPassTrnsp[cy, tran, y])
                        elif tran == "PT":
                            scale = 1e-1 * value(m.V01ActivPassTrnsp[cy, tran, y])
                        elif tran == "PB":
                            scale = 1e3 * value(m.V01ActivPassTrnsp[cy, tran, y])
                        elif tran in ("PN", "PA"):
                            scale = 1.0 * value(m.V01ActivPassTrnsp[cy, tran, y])
                        elif tran in ("GU", "GT", "GN"):
                            scale = 1e-5 * value(m.V01ActivGoodsTransp[cy, tran, y])
                        else:
                            scale = 1.0
                        cost = 0.0
                        for e in ef:
                            if (tech, e) not in core_sets.TTECHtoEF:
                                continue
                            if tech not in PLUGIN:
                                cost += value(m.V01ConsSpecificFuel[cy, tran, tech, e, y]) * value(m.i01ShareBlend[cy, tran, e, y]) * value(m.VmPriceFuelSubsecCarVal[cy, tran, e, y])
                            else:
                                if e != "ELC":
                                    cost += (1 - value(m.i01ShareAnnMilePlugInHybrid[cy, y])) * value(m.i01ShareBlend[cy, tran, e, y]) * value(m.V01ConsSpecificFuel[cy, tran, tech, e, y]) * value(m.VmPriceFuelSubsecCarVal[cy, tran, e, y])
                                else:
                                    cost += value(m.i01ShareAnnMilePlugInHybrid[cy, y]) * value(m.V01ConsSpecificFuel[cy, tran, tech, "ELC", y]) * value(m.VmPriceFuelSubsecCarVal[cy, tran, "ELC", y])
                        cost += _param_val(m.imVarCostTech, cy, tran, tech, y) or 0.0
                        if tech not in core_sets.RENEF:
                            cost += value(m.VmRenValue[y]) / 1000.0
                        m.V01CostFuel[cy, tran, tech, y].fix((cost or 0.0) * (scale if scale else 1.0))
                    except (TypeError, ZeroDivisionError):
                        m.V01CostFuel[cy, tran, tech, y].fix(1.0)

    # --- V01CostTranspPerMeanConsSize: LO=epsilon6, L=1; fix for datay = Cap + FixOM + CostFuel ---
    eps = value(m.epsilon6) if hasattr(m, "epsilon6") else 1e-6
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for y in ytime:
                    m.V01CostTranspPerMeanConsSize[cy, tran, tech, y].setlb(eps)
                for y in datay:
                    try:
                        tot = value(m.V01CapCostAnnualized[cy, tran, tech, y]) + _param_val(m.imFixOMCostTech, cy, tran, tech, y) + value(m.V01CostFuel[cy, tran, tech, y])
                        m.V01CostTranspPerMeanConsSize[cy, tran, tech, y].fix(tot if tot is not None else 1.0)
                    except (TypeError, ValueError):
                        m.V01CostTranspPerMeanConsSize[cy, tran, tech, y].fix(1.0)

    # --- V01ShareTechTr.LO = 0 ---
    for idx in m.V01ShareTechTr:
        m.V01ShareTechTr[idx].setlb(0.0)

    # V01PremScrp is defined by equation Q01PremScrp (uses i01PremScrpFac); do not fix here.
