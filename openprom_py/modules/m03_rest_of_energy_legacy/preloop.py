"""
Module 03_RestOfEnergy (legacy): preloop — fix historical variables and set bounds.

Mirrors modules/03_RestOfEnergy/legacy/preloop.gms. For historical (datay) years we fix
variables to data so the solver does not change them. For stub variables from
Power/CHP/H2 we fix them to 0 (or 1 for price indices) so all Q03* equations are
well-defined. Lower bounds (LO) are set where needed (e.g. VmConsFinEneCountry.LO = 0).
"""

from pyomo.core import value

from core import sets as core_sets


def _pval(p, *idx):
    """Safely get numeric value of a Param at index; return 0 if missing or non-numeric."""
    try:
        v = p[idx]
        return float(value(v)) if hasattr(v, "value") else float(v)
    except Exception:
        return 0.0


def _base_year(core_sets_obj, ytime):
    """Return base year as a scalar (tFirst may be a set in CoreSets)."""
    t_first = getattr(core_sets_obj, "tFirst", None)
    if t_first is not None:
        try:
            return next(iter(t_first))
        except StopIteration:
            pass
    return ytime[0] if ytime else None


def apply_rest_of_energy_preloop(m, core_sets_obj) -> None:
    """
    Apply RestOfEnergy preloop: fix historical values from data and fix stubs to 0.

    Order follows GAMS:
    1. V03OutTransfRefSpec, V03OutTransfSolids, V03OutTransfGasses: FX from i03OutTotTransfProcess for datay; 0 if not produced.
    2. V03ConsGrssInlNotEneBranch, V03ConsGrssInl: L and FX from i03DataGrossInlCons (minus tot branch cons for first).
    3. V03InputTransfRef/Solids/Gasses: FX from -i03InpTotTransfProcess for datay; 0 if not input.
    4. V03Transfers: FX = i03FeedTransfr for non-solving (historical) years.
    5. V03ProdPrimary: L and FX from i03PrimProd for datay.
    6. V03Imp (NGS), V03Exp: FX from imFuelImports/imFuelExprts for historical.
    7. VmConsFiEneSec: L and FX from i03DataOwnConsEne for datay; 0 if not SECtoEF.
    8. VmLossesDistr: FX from imDistrLosses for datay.
    9. V03OutTotTransf, V03InpTotTransf: L and FX from process tables.
    10. V03OutTransfCHP: FX for datay.
    11. VmConsFinEneCountry: LO=0, FX for datay from sum of imFuelConsPerFueSub (excluding NENSE).
    12. VmConsFinNonEne: FX for datay from sum NENSE (excl BU) imFuelConsPerFueSub.
    13. Stub vars: V04ProdElecEstCHP, VmProdSte, VmConsFuelElecProd, VmConsFuelSteProd, VmConsFuelH2Prod, VmConsFuelCDRProd, VmDemTotH2, VmDemSecH2, VmProdElec, VmDemTotSte: fix to 0.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = set(getattr(core_sets_obj, "datay", []))
    an = set(getattr(core_sets_obj, "an", []))
    ssbs = list(core_sets.SSBS)
    efs = list(core_sets.EFS)
    toctef = list(core_sets.TOCTEF)
    sec_to_ef_prod = core_sets.SECtoEFPROD
    sec_to_ef = core_sets.SECtoEF
    nense = set(core_sets.NENSE)

    # Commented out in GAMS (legacy/preloop.gms): *V03OutTransfRefSpec.L(runCy,EFS,YTIME) = 0.1;
    # Commented out in GAMS: *V03ProdPrimary.LO(runCy,EFS,YTIME) = 0;

    # 1) V03OutTransfRefSpec: fix to data for datay and LQD products; 0 otherwise
    if hasattr(m, "V03OutTransfRefSpec") and hasattr(m, "i03OutTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("LQD", efs_) in sec_to_ef_prod and y in datay:
                        v = _pval(m.i03OutTotTransfProcess, cy, "LQD", efs_, y)
                        m.V03OutTransfRefSpec[cy, efs_, y].fix(v)
                    elif ("LQD", efs_) not in sec_to_ef_prod:
                        m.V03OutTransfRefSpec[cy, efs_, y].fix(0.0)

    # 2) V03OutTransfSolids
    if hasattr(m, "V03OutTransfSolids") and hasattr(m, "i03OutTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("SLD", efs_) in sec_to_ef_prod and y in datay:
                        v = _pval(m.i03OutTotTransfProcess, cy, "SLD", efs_, y)
                        m.V03OutTransfSolids[cy, efs_, y].fix(v)
                    elif ("SLD", efs_) not in sec_to_ef_prod:
                        m.V03OutTransfSolids[cy, efs_, y].fix(0.0)

    # 3) V03OutTransfGasses
    if hasattr(m, "V03OutTransfGasses") and hasattr(m, "i03OutTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("GAS", efs_) in sec_to_ef_prod and y in datay:
                        v = _pval(m.i03OutTotTransfProcess, cy, "GAS", efs_, y)
                        m.V03OutTransfGasses[cy, efs_, y].fix(v)
                    elif ("GAS", efs_) not in sec_to_ef_prod:
                        m.V03OutTransfGasses[cy, efs_, y].fix(0.0)

    # 4) V03ConsGrssInlNotEneBranch: L = base-year data - tot branch; FX = same for datay
    base_y = _base_year(core_sets_obj, ytime)
    if hasattr(m, "V03ConsGrssInlNotEneBranch") and hasattr(m, "i03DataGrossInlCons") and hasattr(m, "i03TotEneBranchCons"):
        for cy in run_cy:
            for efs_ in efs:
                gic_base = _pval(m.i03DataGrossInlCons, cy, efs_, base_y) if base_y else 0.0
                tot_base = _pval(m.i03TotEneBranchCons, cy, efs_, base_y) if base_y else 0.0
                m.V03ConsGrssInlNotEneBranch[cy, efs_, base_y].set_value(gic_base - tot_base)
                for y in datay:
                    gic = _pval(m.i03DataGrossInlCons, cy, efs_, y)
                    tot = _pval(m.i03TotEneBranchCons, cy, efs_, y)
                    m.V03ConsGrssInlNotEneBranch[cy, efs_, y].fix(gic - tot)

    # 5) V03InputTransfRef/Solids/Gasses: FX = -i03InpTotTransfProcess for datay; 0 if not input
    if hasattr(m, "V03InputTransfRef") and hasattr(m, "i03InpTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("LQD", efs_) in sec_to_ef and y in datay:
                        v = -_pval(m.i03InpTotTransfProcess, cy, "LQD", efs_, y)
                        m.V03InputTransfRef[cy, efs_, y].fix(v)
                    elif ("LQD", efs_) not in sec_to_ef:
                        m.V03InputTransfRef[cy, efs_, y].fix(0.0)
    if hasattr(m, "V03InputTransfSolids") and hasattr(m, "i03InpTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("SLD", efs_) in sec_to_ef and y in datay:
                        v = -_pval(m.i03InpTotTransfProcess, cy, "SLD", efs_, y)
                        m.V03InputTransfSolids[cy, efs_, y].fix(v)
                    elif ("SLD", efs_) not in sec_to_ef:
                        m.V03InputTransfSolids[cy, efs_, y].fix(0.0)
    if hasattr(m, "V03InputTransfGasses") and hasattr(m, "i03InpTotTransfProcess"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if ("GAS", efs_) in sec_to_ef and y in datay:
                        v = -_pval(m.i03InpTotTransfProcess, cy, "GAS", efs_, y)
                        m.V03InputTransfGasses[cy, efs_, y].fix(v)
                    elif ("GAS", efs_) not in sec_to_ef:
                        m.V03InputTransfGasses[cy, efs_, y].fix(0.0)

    # 6) V03ConsGrssInl: L and FX from i03DataGrossInlCons
    if hasattr(m, "V03ConsGrssInl") and hasattr(m, "i03DataGrossInlCons"):
        for cy in run_cy:
            for efs_ in efs:
                v_base = _pval(m.i03DataGrossInlCons, cy, efs_, base_y) if base_y else 0.0
                m.V03ConsGrssInl[cy, efs_, base_y].set_value(v_base)
                for y in datay:
                    m.V03ConsGrssInl[cy, efs_, y].fix(_pval(m.i03DataGrossInlCons, cy, efs_, y))

    # 7) V03Transfers: FX = i03FeedTransfr for non-AN (historical) years
    if hasattr(m, "V03Transfers") and hasattr(m, "i03FeedTransfr"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if y not in an:
                        m.V03Transfers[cy, efs_, y].fix(_pval(m.i03FeedTransfr, cy, efs_, y))

    # 8) V03ProdPrimary: L from base year + 1, FX for datay from i03PrimProd
    if hasattr(m, "V03ProdPrimary") and hasattr(m, "i03PrimProd"):
        for cy in run_cy:
            for efs_ in efs:
                v_base = _pval(m.i03PrimProd, cy, efs_, base_y) + 1.0 if base_y else 1.0
                m.V03ProdPrimary[cy, efs_, base_y].set_value(v_base)
                for y in datay:
                    m.V03ProdPrimary[cy, efs_, y].fix(_pval(m.i03PrimProd, cy, efs_, y))

    # 9) V03Imp (NGS) and V03Exp: FX from imFuelImports / imFuelExprts for historical
    if hasattr(m, "V03Imp") and hasattr(m, "imFuelImports"):
        for cy in run_cy:
            for y in ytime:
                if y not in an:
                    m.V03Imp[cy, "NGS", y].fix(_pval(m.imFuelImports, cy, "NGS", y))
    if hasattr(m, "V03Exp") and hasattr(m, "imFuelExprts"):
        impef = set(core_sets.IMPEF)
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    if y not in an:
                        m.V03Exp[cy, efs_, y].fix(_pval(m.imFuelExprts, cy, efs_, y))
                if efs_ not in impef:
                    for y in ytime:
                        m.V03Exp[cy, efs_, y].fix(0.0)

    # 10) VmConsFiEneSec: L from base, FX for datay from i03DataOwnConsEne; 0 if not SECtoEF
    if hasattr(m, "VmConsFiEneSec") and hasattr(m, "i03DataOwnConsEne"):
        for cy in run_cy:
            for ss in ssbs:
                for efs_ in efs:
                    if (ss, efs_) not in sec_to_ef:
                        m.VmConsFiEneSec[cy, ss, efs_, base_y].set_value(0.0)
                        for y in ytime:
                            m.VmConsFiEneSec[cy, ss, efs_, y].fix(0.0)
                        continue
                    v_base = _pval(m.i03DataOwnConsEne, cy, ss, efs_, base_y) if base_y else 0.0
                    m.VmConsFiEneSec[cy, ss, efs_, base_y].set_value(v_base)
                    for y in datay:
                        m.VmConsFiEneSec[cy, ss, efs_, y].fix(_pval(m.i03DataOwnConsEne, cy, ss, efs_, y))

    # 11) VmLossesDistr: FX for datay from imDistrLosses
    if hasattr(m, "VmLossesDistr") and hasattr(m, "imDistrLosses"):
        for cy in run_cy:
            for efs_ in efs:
                for y in datay:
                    m.VmLossesDistr[cy, efs_, y].fix(_pval(m.imDistrLosses, cy, efs_, y))

    # 12) V03OutTotTransf, V03InpTotTransf: L and FX from process tables
    if hasattr(m, "V03OutTotTransf") and hasattr(m, "i03OutTotTransfProcess"):
        for cy in run_cy:
            for ss in ssbs:
                for efs_ in efs:
                    v_base = _pval(m.i03OutTotTransfProcess, cy, ss, efs_, base_y) if base_y else 0.0
                    m.V03OutTotTransf[cy, ss, efs_, base_y].set_value(v_base)
                    for y in datay:
                        if (ss, efs_) in sec_to_ef_prod:
                            m.V03OutTotTransf[cy, ss, efs_, y].fix(_pval(m.i03OutTotTransfProcess, cy, ss, efs_, y))
                    if (ss, efs_) not in sec_to_ef_prod:
                        for y in ytime:
                            m.V03OutTotTransf[cy, ss, efs_, y].fix(0.0)
    if hasattr(m, "V03InpTotTransf") and hasattr(m, "i03InpTotTransfProcess"):
        for cy in run_cy:
            for ss in ssbs:
                for efs_ in efs:
                    for y in ytime:
                        if (ss, efs_) in sec_to_ef and y in datay:
                            m.V03InpTotTransf[cy, ss, efs_, y].fix(-_pval(m.i03InpTotTransfProcess, cy, ss, efs_, y))
                        elif (ss, efs_) not in sec_to_ef:
                            m.V03InpTotTransf[cy, ss, efs_, y].fix(0.0)

    # 13) V03OutTransfCHP: FX for datay from i03OutTotTransfProcess(CHP, TOCTEF)
    if hasattr(m, "V03OutTransfCHP") and hasattr(m, "i03OutTotTransfProcess"):
        for cy in run_cy:
            for tocef in toctef:
                for y in datay:
                    m.V03OutTransfCHP[cy, tocef, y].fix(_pval(m.i03OutTotTransfProcess, cy, "CHP", tocef, y))

    # 14) VmConsFinEneCountry: LO = 0, FX for datay = sum over DSBS (not NENSE) of imFuelConsPerFueSub
    if hasattr(m, "VmConsFinEneCountry"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    m.VmConsFinEneCountry[cy, efs_, y].setlb(0.0)
                for y in datay:
                    if hasattr(m, "imFuelConsPerFueSub"):
                        tot = 0.0
                        for ds in core_sets.DSBS:
                            if ds in nense:
                                continue
                            tot += _pval(m.imFuelConsPerFueSub, cy, ds, efs_, y)
                        m.VmConsFinEneCountry[cy, efs_, y].fix(tot)

    # 15) VmConsFinNonEne: FX for datay = sum NENSE (excl BU) imFuelConsPerFueSub
    if hasattr(m, "VmConsFinNonEne") and hasattr(m, "imFuelConsPerFueSub"):
        for cy in run_cy:
            for efs_ in efs:
                for y in datay:
                    tot = 0.0
                    for nn in nense:
                        if nn == "BU":
                            continue
                        if (nn, efs_) in sec_to_ef:
                            tot += _pval(m.imFuelConsPerFueSub, cy, nn, efs_, y)
                    m.VmConsFinNonEne[cy, efs_, y].fix(tot)

    # 16) Stub variables: fix to 0 so equations are well-defined
    for stub_name in (
        "V04ProdElecEstCHP", "VmProdSte", "VmConsFuelElecProd", "VmConsFuelSteProd",
        "VmConsFuelH2Prod", "VmConsFuelCDRProd", "VmDemTotH2", "VmProdElec", "VmDemTotSte",
    ):
        var = getattr(m, stub_name, None)
        if var is None:
            continue
        for idx in var:
            var[idx].fix(0.0)
    if hasattr(m, "VmDemSecH2"):
        for idx in m.VmDemSecH2:
            m.VmDemSecH2[idx].fix(0.0)
