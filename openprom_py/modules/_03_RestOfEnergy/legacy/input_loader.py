"""
Module 03_RestOfEnergy (legacy): load input data from CSV and compute derived parameters.

Mirrors modules/03_RestOfEnergy/legacy/input.gms. All table files are optional;
if a file is missing, the corresponding parameter is left at default (0 or 1).
This allows the model to build even with minimal data; fill CSVs for real runs.

Derived parameters (i03FeedTransfr, i03ResTransfOutputRefineries, i03RatePriProTotPriNeeds,
i03ResHcNgOilPrProd, i03RatioImpFinElecDem, i03TotEneBranchCons) are computed from
the raw tables and from core data (imFuelConsPerFueSub, imDistrLosses). The core
parameter imRateLossesFinCons is also set here from imDistrLosses and consumption.
"""

from pathlib import Path
from typing import Any, Dict

import pandas as pd
from pyomo.core import value as pyo_value

from core import sets as core_sets

# SUPOTH elements (GAMS); used for i03SupResRefCapacity default and i03ResHcNgOilPrProd
_SUPOTH_FULL = ["ELC_IMP", "REF_CAP_RES", "HCL_PPROD", "NGS_PPROD", "OIL_PPROD"]


def _log(msg: str, detail: str = "") -> None:
    try:
        from run_report import get_report_logger
        log = get_report_logger()
        if log:
            if detail:
                log.info("  [03_RestOfEnergy] {}  {}".format(msg, detail))
            else:
                log.info("  [03_RestOfEnergy] {}".format(msg))
    except Exception:
        pass


def _path(data_dir: Path, filename: str) -> Path:
    p = data_dir / filename
    return p


def _read_csv_optional(data_dir: Path, filename: str) -> pd.DataFrame:
    """Read CSV if it exists; return empty DataFrame otherwise."""
    p = _path(data_dir, filename)
    if not p.exists():
        _log(filename, "not found, using defaults")
        return pd.DataFrame()
    try:
        return pd.read_csv(p)
    except Exception as e:
        _log(filename, "read error: {}".format(e))
        return pd.DataFrame()


def load_i03_data_gross_inl_cons(data_dir: Path) -> Dict[tuple, float]:
    """i03DataGrossInlCons(allCy, EFS, YTIME). Rows: country, EFS; columns: years."""
    df = _read_csv_optional(data_dir, "iDataGrossInlCons.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:2]]
        if len(keys) < 2:
            continue
        cy, efs = keys[0], keys[1]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_data_own_cons_ene(data_dir: Path) -> Dict[tuple, float]:
    """i03DataOwnConsEne(allCy, SSBS, EFS, YTIME)."""
    df = _read_csv_optional(data_dir, "iDataOwnConsEne.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:3]]
        if len(keys) < 3:
            continue
        cy, ssbs, efs = keys[0], keys[1], keys[2]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, ssbs, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_supp_transfers(data_dir: Path) -> Dict[tuple, float]:
    """i03SuppTransfers(allCy, EFS, YTIME)."""
    df = _read_csv_optional(data_dir, "iSuppTransfers.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:2]]
        if len(keys) < 2:
            continue
        cy, efs = keys[0], keys[1]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_prim_prod(data_dir: Path) -> Dict[tuple, float]:
    """i03PrimProd(allCy, EFS, YTIME)."""
    df = _read_csv_optional(data_dir, "iPrimProd.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:2]]
        if len(keys) < 2:
            continue
        cy, efs = keys[0], keys[1]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_supp_rate_prim_prod(data_dir: Path) -> Dict[tuple, float]:
    """i03SuppRatePrimProd(allCy, EF, YTIME)."""
    df = _read_csv_optional(data_dir, "iSuppRatePrimProd.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:2]]
        if len(keys) < 2:
            continue
        cy, ef = keys[0], keys[1]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, ef, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_elc_net_imp_share(data_dir: Path) -> Dict[tuple, float]:
    """i03ElcNetImpShare(allCy, SUPOTH, YTIME). SUPOTH = ELC_IMP."""
    df = _read_csv_optional(data_dir, "iElcNetImpShare.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:2]]
        if len(keys) < 2:
            continue
        cy, supoth = keys[0], keys[1]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, supoth, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_out_transf_process(data_dir: Path) -> Dict[tuple, float]:
    """i03OutTotTransfProcess(allCy, SSBS, EFS, YTIME)."""
    df = _read_csv_optional(data_dir, "iOutTransfProcess.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:3]]
        if len(keys) < 3:
            continue
        cy, ssbs, efs = keys[0], keys[1], keys[2]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, ssbs, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_inp_transf_process(data_dir: Path) -> Dict[tuple, float]:
    """i03InpTotTransfProcess(allCy, SSBS, EFS, YTIME)."""
    df = _read_csv_optional(data_dir, "iInpTransfProcess.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:3]]
        if len(keys) < 3:
            continue
        cy, ssbs, efs = keys[0], keys[1], keys[2]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, ssbs, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_ratio_branch_own_cons(data_dir: Path) -> Dict[tuple, float]:
    """i03RateEneBranCons(allCy, SSBS, EFS, YTIME). From iRatioBranchOwnCons.csv."""
    df = _read_csv_optional(data_dir, "iRatioBranchOwnCons.csv")
    if df.empty:
        return {}
    out = {}
    year_cols = [c for c in df.columns if str(c).strip().isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    for _, row in df.iterrows():
        keys = [row[c] for c in idx_cols[:3]]
        if len(keys) < 3:
            continue
        cy, ssbs, efs = keys[0], keys[1], keys[2]
        for ycol in year_cols:
            try:
                y = int(ycol)
                v = float(row[ycol])
                out[(cy, ssbs, efs, y)] = v
            except (TypeError, ValueError):
                continue
    return out


def load_i03_nat_gas_pri_pro_elst(data_dir: Path) -> Dict[tuple, float]:
    """i03NatGasPriProElst(allCy). One value per country."""
    df = _read_csv_optional(data_dir, "iNatGasPriProElst.csv")
    if df.empty:
        return {}
    out = {}
    cols = df.columns.tolist()
    for _, row in df.iterrows():
        cy = row[cols[0]]
        try:
            v = float(row[cols[1]]) if len(cols) > 1 else 0.5
            out[(cy,)] = v
        except (TypeError, ValueError):
            continue
    return out


def load_rest_of_energy_data(config: Any) -> Dict[str, Dict[tuple, float]]:
    """
    Load all RestOfEnergy CSV tables into a dict of parameter name -> data.
    Missing files result in empty dicts; no exception is raised.
    """
    data_dir = getattr(config, "data_dir", Path("data"))
    if not isinstance(data_dir, Path):
        data_dir = Path(data_dir)
    return {
        "i03DataGrossInlCons": load_i03_data_gross_inl_cons(data_dir),
        "i03DataOwnConsEne": load_i03_data_own_cons_ene(data_dir),
        "i03SuppTransfers": load_i03_supp_transfers(data_dir),
        "i03PrimProd": load_i03_prim_prod(data_dir),
        "i03SuppRatePrimProd": load_i03_supp_rate_prim_prod(data_dir),
        "i03ElcNetImpShare": load_i03_elc_net_imp_share(data_dir),
        "i03OutTotTransfProcess": load_i03_out_transf_process(data_dir),
        "i03InpTotTransfProcess": load_i03_inp_transf_process(data_dir),
        "i03RateEneBranCons": load_i03_ratio_branch_own_cons(data_dir),
        "i03NatGasPriProElst": load_i03_nat_gas_pri_pro_elst(data_dir),
    }


def _base_year_scalar(core_sets_obj, ytime):
    """Return base year as scalar (tFirst may be a set)."""
    t_first = getattr(core_sets_obj, "tFirst", None)
    if t_first is not None:
        try:
            return next(iter(t_first))
        except (StopIteration, TypeError):
            pass
    return ytime[0] if ytime else None


def load_rest_of_energy_data_into_model(m, data: Dict[str, Dict[tuple, float]], core_sets_obj) -> None:
    """
    Push loaded data into model parameters and compute derived parameters.

    Replicates GAMS input.gms: i03FeedTransfr, i03ResTransfOutputRefineries (from
    i03SupTrnasfOutputRefineries), i03RatePriProTotPriNeeds, i03ResHcNgOilPrProd (from
    i03SupResRefCapacity for HCL/NGS/CRO), i03TotEneBranchCons, i03DataOwnConsEne < 1e-4 = 0,
    imRateLossesFinCons formula and base-year copy.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    base_y = _base_year_scalar(core_sets_obj, ytime)
    an = set(getattr(core_sets_obj, "an", ytime))
    ssbs = list(core_sets.SSBS)
    efs = list(core_sets.EFS)
    ef = list(core_sets.EF)
    dsbs = list(core_sets.DSBS)

    # Raw tables
    for param_name, values in data.items():
        if not values:
            continue
        param = getattr(m, param_name, None)
        if param is None:
            continue
        for idx, val in values.items():
            try:
                if isinstance(idx, tuple) and len(idx) == 1:
                    param[idx[0]] = val
                else:
                    param[idx] = val
            except Exception:
                continue

    # GAMS: i03DataOwnConsEne(runCy,SSBS,EFS,YTIME)$(i03DataOwnConsEne(...) < 1e-4) = 0
    if hasattr(m, "i03DataOwnConsEne"):
        for cy in run_cy:
            for ss in ssbs:
                for efs_ in efs:
                    for y in ytime:
                        try:
                            v = m.i03DataOwnConsEne[cy, ss, efs_, y].value
                            if v is not None and v < 1e-4:
                                m.i03DataOwnConsEne[cy, ss, efs_, y] = 0.0
                        except Exception:
                            pass

    # i03FeedTransfr = i03SuppTransfers
    for (cy, efs_, y), val in data.get("i03SuppTransfers", {}).items():
        if hasattr(m, "i03FeedTransfr"):
            try:
                m.i03FeedTransfr[cy, efs_, y] = val
            except Exception:
                pass

    # GAMS: i03SupResRefCapacity(runCy,SUPOTH,YTIME) = 1; i03SupTrnasfOutputRefineries(runCy,EF,YTIME) = 1
    if hasattr(m, "i03SupResRefCapacity"):
        for cy in run_cy:
            for sup in _SUPOTH_FULL:
                for y in ytime:
                    try:
                        m.i03SupResRefCapacity[cy, sup, y] = 1.0
                    except Exception:
                        pass
    if hasattr(m, "i03SupTrnasfOutputRefineries"):
        for cy in run_cy:
            for e in ef:
                for y in ytime:
                    try:
                        m.i03SupTrnasfOutputRefineries[cy, e, y] = 1.0
                    except Exception:
                        pass

    # GAMS: i03ResTransfOutputRefineries(runCy,EFS,YTIME) = i03SupTrnasfOutputRefineries(runCy,EFS,YTIME)
    if hasattr(m, "i03ResTransfOutputRefineries") and hasattr(m, "i03SupTrnasfOutputRefineries"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    try:
                        if efs_ in ef:
                            m.i03ResTransfOutputRefineries[cy, efs_, y] = pyo_value(
                                m.i03SupTrnasfOutputRefineries[cy, efs_, y]
                            )
                        else:
                            m.i03ResTransfOutputRefineries[cy, efs_, y] = 1.0
                    except Exception:
                        try:
                            m.i03ResTransfOutputRefineries[cy, efs_, y] = 1.0
                        except Exception:
                            pass

    # GAMS: i03ResHcNgOilPrProd(runCy,"HCL",YTIME)$an(YTIME) = i03SupResRefCapacity(runCy,"HCL_PPROD",YTIME); same NGS,CRO
    if hasattr(m, "i03ResHcNgOilPrProd") and hasattr(m, "i03SupResRefCapacity"):
        for cy in run_cy:
            for y in an:
                try:
                    m.i03ResHcNgOilPrProd[cy, "HCL", y] = pyo_value(m.i03SupResRefCapacity[cy, "HCL_PPROD", y])
                    m.i03ResHcNgOilPrProd[cy, "NGS", y] = pyo_value(m.i03SupResRefCapacity[cy, "NGS_PPROD", y])
                    m.i03ResHcNgOilPrProd[cy, "CRO", y] = pyo_value(m.i03SupResRefCapacity[cy, "OIL_PPROD", y])
                except Exception:
                    pass

    # Commented out in GAMS (input.gms): *i03RefCapacity(allCy,YTIME) "Refineries Capacity (Million Barrels/day)"
    # *i03ResRefCapacity(runCy,YTIME) = i03SupResRefCapacity(runCy,"REF_CAP_RES",YTIME);

    # i03RatePriProTotPriNeeds = base-year i03SuppRatePrimProd
    supp_rate = data.get("i03SuppRatePrimProd", {})
    for cy in run_cy:
        for efs_ in efs:
            for y in ytime:
                key_base = (cy, efs_, base_y) if base_y else (cy, efs_, ytime[0])
                val = supp_rate.get(key_base, 0.0)
                if hasattr(m, "i03RatePriProTotPriNeeds"):
                    try:
                        m.i03RatePriProTotPriNeeds[cy, efs_, y] = val
                    except Exception:
                        pass

    # i03ResHcNgOilPrProd = 1 (default). GAMS sets from i03SupResRefCapacity per HCL/NGS/CRO
    for cy in run_cy:
        for efs_ in efs:
            for y in ytime:
                if hasattr(m, "i03ResHcNgOilPrProd"):
                    try:
                        m.i03ResHcNgOilPrProd[cy, efs_, y] = 1.0
                    except Exception:
                        pass

    # i03RatioImpFinElecDem = i03ElcNetImpShare(cy, "ELC_IMP", y)
    elc_share = data.get("i03ElcNetImpShare", {})
    for cy in run_cy:
        for y in ytime:
            val = elc_share.get((cy, "ELC_IMP", y), 0.0)
            if hasattr(m, "i03RatioImpFinElecDem"):
                try:
                    m.i03RatioImpFinElecDem[cy, y] = val
                except Exception:
                    pass

    # i03TotEneBranchCons = sum over SSBS of i03DataOwnConsEne
    own_cons = data.get("i03DataOwnConsEne", {})
    for cy in run_cy:
        for efs_ in efs:
            for y in ytime:
                tot = sum(own_cons.get((cy, ss, efs_, y), 0.0) for ss in ssbs)
                if hasattr(m, "i03TotEneBranchCons"):
                    try:
                        m.i03TotEneBranchCons[cy, efs_, y] = tot
                    except Exception:
                        pass

    # i03RateEneBranCons: for future years use base-year value (GAMS: $AN(YTIME) = base)
    rate_cons = data.get("i03RateEneBranCons", {})
    an = set(getattr(core_sets_obj, "an", ytime))
    for cy in run_cy:
        for ss in ssbs:
            for efs_ in efs:
                base_val = rate_cons.get((cy, ss, efs_, base_y), 0.0) if base_y else 0.0
                for y in ytime:
                    if y in an and (cy, ss, efs_, y) in rate_cons:
                        continue
                    if hasattr(m, "i03RateEneBranCons"):
                        try:
                            m.i03RateEneBranCons[cy, ss, efs_, y] = base_val
                        except Exception:
                            pass

    # imRateLossesFinCons: GAMS formula imDistrLosses / (sum DSBS imFuelConsPerFueSub + i03PrimProd for CRO); then $AN = base.
    if hasattr(m, "imRateLossesFinCons") and hasattr(m, "imDistrLosses") and hasattr(m, "imFuelConsPerFueSub") and hasattr(m, "i03PrimProd"):
        for cy in run_cy:
            for efs_ in efs:
                for y in ytime:
                    try:
                        denom = sum(
                            pyo_value(m.imFuelConsPerFueSub[cy, ds, efs_, y]) for ds in dsbs
                        ) + (pyo_value(m.i03PrimProd[cy, "CRO", y]) if efs_ == "CRO" else 0.0)
                        if denom <= 0:
                            continue
                        num = pyo_value(m.imDistrLosses[cy, efs_, y])
                        m.imRateLossesFinCons[cy, efs_, y] = num / denom
                    except Exception:
                        pass
        if base_y is not None:
            for cy in run_cy:
                for efs_ in efs:
                    try:
                        base_val = pyo_value(m.imRateLossesFinCons[cy, efs_, base_y])
                    except Exception:
                        base_val = 0.0
                    for y in an:
                        try:
                            m.imRateLossesFinCons[cy, efs_, y] = base_val
                        except Exception:
                            pass
