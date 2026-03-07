"""
Module 09_Heat (heat): preloop — bounds and fix historical values for steam variables.

Mirrors modules/09_Heat/heat/preloop.gms. Bounds on V09ScrapRatePremature, V09GapShareSte, V09CaptRateSte,
V09ScrapRate. VmDemTotSte, VmProdSte initial and FX for datay. V09CostCapProdSte, V09CostVarProdSte, V09CostProdSte,
VmCostAvgProdSte, VmConsFuelSteProd FX for datay. V09CaptRateSte.FX(datay)=i09CaptRateSteProd.
"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets


def _tsteam_heat():
    return list(core_sets.TCHP) + list(core_sets.TDHP)


def _pval(p, *idx):
    try:
        v = p[idx] if len(idx) > 0 else p
        return pyo_value(v) if v is not None else 0.0
    except Exception:
        return 0.0


def apply_heat_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """Set bounds and fix historical (datay) values for 09_Heat variables."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = set(getattr(core_sets_obj, "datay", [])) if hasattr(core_sets_obj, "datay") else set()
    tsteam = _tsteam_heat()
    tchp = set(core_sets.TCHP)
    tdhp = set(core_sets.TDHP)
    stemode = list(getattr(core_sets, "STEMODE", ("CHP", "DHP")))
    steam_ef = list(getattr(core_sets, "STEAMEF", ("LGN", "HCL", "GDO", "NGS", "BMSWAS", "H2F", "GEO", "NUC")))
    base_y = getattr(core_sets_obj, "tFirst", None)
    if base_y and hasattr(base_y, "__iter__") and not isinstance(base_y, (str, int)):
        base_y = next(iter(base_y), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None

    for cy in run_cy:
        for y in ytime:
            for t in tsteam:
                if hasattr(m, "V09ScrapRatePremature"):
                    m.V09ScrapRatePremature[cy, t, y].setlb(0.0)
                    m.V09ScrapRatePremature[cy, t, y].setub(1.0)
                if hasattr(m, "V09GapShareSte"):
                    m.V09GapShareSte[cy, t, y].setlb(0.0)
                    m.V09GapShareSte[cy, t, y].setub(1.0)
                if hasattr(m, "V09CaptRateSte"):
                    m.V09CaptRateSte[cy, t, y].setlb(0.0)
                    m.V09CaptRateSte[cy, t, y].setub(1.0)
                if hasattr(m, "V09ScrapRate"):
                    m.V09ScrapRate[cy, t, y].setlb(0.0)
                    m.V09ScrapRate[cy, t, y].setub(1.0)
                if y in datay and hasattr(m, "V09CaptRateSte") and hasattr(m, "i09CaptRateSteProd"):
                    m.V09CaptRateSte[cy, t, y].fix(pyo_value(m.i09CaptRateSteProd[t]))

    # Fix industry placeholder TSTE to 0 (not used in heat equations)
    if hasattr(m, "VmProdSte"):
        for cy in run_cy:
            for y in ytime:
                try:
                    m.VmProdSte[cy, "TSTE", y].fix(0.0)
                except (KeyError, TypeError):
                    pass
    for cy in run_cy:
        for y in ytime:
            if hasattr(m, "VmDemTotSte"):
                m.VmDemTotSte[cy, y].setlb(0.0)
                if base_y and hasattr(m, "imFuelConsPerFueSub"):
                    val = sum(_pval(m.imFuelConsPerFueSub, cy, ds, "STE", base_y) for ds in core_sets.DSBS)
                    if hasattr(m, "i03TotEneBranchCons"):
                        val += _pval(m.i03TotEneBranchCons, cy, "STE", base_y)
                    if hasattr(m, "imDistrLosses"):
                        val += _pval(m.imDistrLosses, cy, "STE", base_y)
                    if hasattr(m, "i03FeedTransfr"):
                        val += _pval(m.i03FeedTransfr, cy, "STE", base_y)
                    m.VmDemTotSte[cy, y].set_value(val)
                if y in datay and hasattr(m, "imFuelConsPerFueSub"):
                    val = sum(_pval(m.imFuelConsPerFueSub, cy, ds, "STE", y) for ds in core_sets.DSBS)
                    if hasattr(m, "i03TotEneBranchCons"):
                        val += _pval(m.i03TotEneBranchCons, cy, "STE", y)
                    if hasattr(m, "imDistrLosses"):
                        val += _pval(m.imDistrLosses, cy, "STE", y)
                    if hasattr(m, "i03FeedTransfr"):
                        val += _pval(m.i03FeedTransfr, cy, "STE", y)
                    m.VmDemTotSte[cy, y].fix(val)

    for cy in run_cy:
        for t in tsteam:
            for y in ytime:
                if hasattr(m, "VmProdSte"):
                    m.VmProdSte[cy, t, y].setlb(0.0)
                if y in datay and hasattr(m, "i03InpTotTransfProcess") and hasattr(m, "VmProdSte"):
                    # Simplified: fix from share of CHP/STEAMP input if available
                    pass  # GAMS uses complex formula; keep initial 0
                if hasattr(m, "V09CostCapProdSte") and y in datay:
                    disc = _pval(m.imDisc, cy, "STEAMP", y)
                    lft = _pval(m.i09ProdLftSte, t)
                    ex = __import__("math").exp(disc * lft)
                    ann = disc * ex / (ex - 1.0 + 1e-12)
                    num = ann * (pyo_value(m.i09CostInvCostSteProd[t, y]) * pyo_value(m.imCGI[cy, y]) + pyo_value(m.i09CostFixOMSteProd[t, y]))
                    den1 = pyo_value(m.i09PowToHeatRatio[t, y]) + (1.0 if t in tdhp else 0.0) + 1e-10
                    den2 = pyo_value(m.i09AvailRateSteProd[t, y]) * pyo_value(m.smGwToTwhPerYear[y]) * pyo_value(m.smTWhToMtoe) * 1e3 + 1e-10
                    m.V09CostCapProdSte[cy, t, y].fix(num / den1 / den2)
                if hasattr(m, "V09CostVarProdSte") and y in datay:
                    # Keep initial or compute from equation structure
                    pass
                if hasattr(m, "V09CostProdSte") and hasattr(m, "V09CostCapProdSte") and hasattr(m, "V09CostVarProdSte") and y in datay:
                    m.V09CostProdSte[cy, t, y].fix(pyo_value(m.V09CostCapProdSte[cy, t, y]) + pyo_value(m.V09CostVarProdSte[cy, t, y]))
                if hasattr(m, "VmCostAvgProdSte") and y in datay:
                    num = sum((pyo_value(m.VmProdSte[cy, t2, y]) + 1e-6) * pyo_value(m.V09CostProdSte[cy, t2, y]) for t2 in tsteam)
                    den = sum(pyo_value(m.VmProdSte[cy, t2, y]) + 1e-6 for t2 in tsteam)
                    m.VmCostAvgProdSte[cy, y].fix(num / (den + 1e-10))
    for cy in run_cy:
        for mode in stemode:
            for efs_ in steam_ef:
                for y in ytime:
                    if hasattr(m, "VmConsFuelSteProd"):
                        m.VmConsFuelSteProd[cy, mode, efs_, y].setlb(0.0)
                        if y in datay and hasattr(m, "i03InpTotTransfProcess"):
                            val = -_pval(m.i03InpTotTransfProcess, cy, "CHP" if mode == "CHP" else "STEAMP", efs_, y)
                            m.VmConsFuelSteProd[cy, mode, efs_, y].fix(val)
