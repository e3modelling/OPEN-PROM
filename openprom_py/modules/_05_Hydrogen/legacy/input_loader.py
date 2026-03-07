"""
Load 05_Hydrogen (legacy) input data from CSV.

Mirrors modules/05_Hydrogen/legacy/input.gms. Loads i05H2Production (IC, FC, VC, EFF, LFT, CR, etc.),
i05H2Parameters, i05H2InfrCapCosts, iTechShareH2Prod. Fills i05ProdLftH2, i05CaptRateH2Prod,
i05CostCapH2Prod, i05CostFOMH2Prod, i05CostVOMH2Prod, i05AvailH2Prod, i05EffH2Prod,
iWBLShareH2Prod, iWBLPremRepH2Prod (0.1), i05WBLGammaH2Prod (1), etc.
"""
from pathlib import Path
from typing import Any, Dict

import pandas as pd
from pyomo.core import value as pyo_value

from core import sets as core_sets


def _read_table(
    data_dir: Path,
    filename: str,
    dims: int,
    year_cols: bool = True,
) -> Dict[tuple, float]:
    """Read CSV; return dict keyed by tuple (index cols + year if year_cols)."""
    p = data_dir / filename
    if not p.exists():
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols_list = [c for c in cols if str(c).strip().isdigit()]
    idx_cols = [c for c in cols if c not in year_cols_list]
    out = {}
    for _, row in df.iterrows():
        if year_cols and year_cols_list:
            for ycol in year_cols_list:
                try:
                    y = int(ycol)
                    key = tuple(row[c] for c in idx_cols) + (y,)
                    if len(key) == dims:
                        out[key] = float(row[ycol])
                except (TypeError, ValueError):
                    continue
        else:
            try:
                key = tuple(row[c] for c in idx_cols[:dims])
                val = float(row[idx_cols[dims]]) if len(idx_cols) > dims else float(row.iloc[-1])
                out[key] = val
            except (TypeError, ValueError, IndexError):
                continue
    return out


def load_hydrogen_data(config: Any) -> Dict[str, Dict[tuple, float]]:
    """Load 05 CSV data. Keys: i05H2Production, i05H2Parameters, i05H2InfrCapCosts, iTechShareH2Prod."""
    data_dir = Path(config.data_dir)
    base = data_dir / "05_Hydrogen" / "legacy"
    if not base.exists():
        base = data_dir
    out: Dict[str, Dict[tuple, float]] = {}
    for name, fname, dims, has_years in [
        ("i05H2Production", "iH2Production.csv", 3, True),
        ("i05H2Parameters", "iH2Parameters.csv", 2, False),
        ("i05H2InfrCapCosts", "iH2InfrCapCosts.csv", 3, True),
        ("iTechShareH2Prod", "iWBLShareH2Prod.csv", 2, True),
    ]:
        out[name] = _read_table(base, fname, dims, year_cols=has_years)
    return out


def load_hydrogen_data_into_model(
    m: Any,
    data: Dict[str, Dict[tuple, float]],
    core_sets_obj: Any,
) -> None:
    """Push loaded 05 data into model params. Apply GAMS formulas (wes/wew = weg, etc.)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    h2tech = list(core_sets.H2TECH)
    infrtech = ["tpipa", "hpipi", "hpipu", "mpipu", "lpipu", "mpips", "ssgg"]
    econcharhy = ("IC", "FC", "VC", "EFF", "SELF", "AVAIL", "LFT", "H2KMTOE", "CR", "B", "mid", "MAXAREA", "AREA")
    base_y = getattr(core_sets_obj, "tFirst", None)
    if hasattr(base_y, "__iter__") and not isinstance(base_y, str):
        base_y = next(iter(base_y), None)

    # iWBLShareH2Prod = iTechShareH2Prod
    if data.get("iTechShareH2Prod"):
        for k, v in data["iTechShareH2Prod"].items():
            if len(k) >= 2 and k[1] in h2tech and (len(k) == 2 or k[2] in ytime):
                for cy in run_cy:
                    key = (cy, k[0], k[1]) if len(k) == 2 else (cy, k[0], k[1], k[2])
                    if len(key) == 4:
                        m.iWBLShareH2Prod[key] = v
                    elif len(key) == 3:
                        for y in ytime:
                            m.iWBLShareH2Prod[cy, k[0], k[1], y] = v

    # i05WBLGammaH2Prod = 1
    for cy in run_cy:
        for y in ytime:
            m.i05WBLGammaH2Prod[cy, y] = 1.0

    # i05ProdLftH2 from i05H2Production LFT; wes/wew = weg
    if data.get("i05H2Production"):
        for k, v in data["i05H2Production"].items():
            if len(k) >= 3 and k[0] == "LFT" and k[1] in h2tech and k[2] in ytime:
                m.i05ProdLftH2[k[1], k[2]] = v
        for y in ytime:
            if ("LFT", "weg", y) in data.get("i05H2Production", {}):
                m.i05ProdLftH2["wes", y] = data["i05H2Production"][("LFT", "weg", y)]
                m.i05ProdLftH2["wew", y] = data["i05H2Production"][("LFT", "weg", y)]

    # i05CaptRateH2Prod from CR; zero for non-CCS; wes/wew = weg
    if data.get("i05H2Production") and base_y is not None:
        for ht in h2tech:
            key = ("CR", ht, base_y)
            if key in data["i05H2Production"]:
                m.i05CaptRateH2Prod[ht] = data["i05H2Production"][key]
        for ht in ("wes", "wew"):
            if "weg" in h2tech:
                m.i05CaptRateH2Prod[ht] = pyo_value(m.i05CaptRateH2Prod["weg"])
        for ht in h2tech:
            if ht in set(core_sets.H2CCS):
                continue
            m.i05CaptRateH2Prod[ht] = 0.0

    # i05CostCapH2Prod, i05CostFOMH2Prod, i05CostVOMH2Prod from i05H2Production (IC, FC, VC); wes/wew = weg
    for char, param in [("IC", "i05CostCapH2Prod"), ("FC", "i05CostFOMH2Prod"), ("VC", "i05CostVOMH2Prod")]:
        if not data.get("i05H2Production"):
            continue
        for k, v in data["i05H2Production"].items():
            if len(k) >= 3 and k[0] == char and k[1] in h2tech and k[2] in ytime:
                for cy in run_cy:
                    getattr(m, param)[cy, k[1], k[2]] = v
        for cy in run_cy:
            for y in ytime:
                v_weg = data["i05H2Production"].get((char, "weg", y))
                if v_weg is not None:
                    getattr(m, param)[cy, "wes", y] = v_weg
                    getattr(m, param)[cy, "wew", y] = v_weg

    # i05AvailH2Prod, i05EffH2Prod from i05H2Production (AVAIL, EFF)
    for char, param in [("AVAIL", "i05AvailH2Prod"), ("EFF", "i05EffH2Prod")]:
        if not data.get("i05H2Production"):
            continue
        for k, v in data["i05H2Production"].items():
            if len(k) >= 3 and k[0] == char and k[1] in h2tech and k[2] in ytime:
                for cy in run_cy:
                    getattr(m, param)[cy, k[1], k[2]] = v
        for cy in run_cy:
            for y in ytime:
                if "weg" in h2tech:
                    getattr(m, param)[cy, "wes", y] = data["i05H2Production"].get((char, "weg", y), 0.7)
                    getattr(m, param)[cy, "wew", y] = data["i05H2Production"].get((char, "weg", y), 0.7)
                if param == "i05AvailH2Prod" and hasattr(m, "i04AvailRate"):
                    m.i05AvailH2Prod[cy, "wes", y] = min(pyo_value(m.i05AvailH2Prod[cy, "weg", y]), pyo_value(m.i04AvailRate[cy, "PGSOL", y]))
                    m.i05AvailH2Prod[cy, "wew", y] = min(pyo_value(m.i05AvailH2Prod[cy, "weg", y]), pyo_value(m.i04AvailRate[cy, "PGAWNO", y]))

    # i05H2Adopt (B, mid), i05PolH2AreaMax, i05HabAreaCountry from i05H2Parameters
    if data.get("i05H2Parameters"):
        for k, v in data["i05H2Parameters"].items():
            if len(k) >= 2 and k[0] in run_cy and k[1] in econcharhy:
                if k[1].lower() == "b":
                    for y in ytime:
                        m.i05H2Adopt[k[0], "B", y] = v
                elif k[1].lower() == "mid":
                    for y in ytime:
                        m.i05H2Adopt[k[0], "mid", y] = v
                elif k[1] == "MAXAREA":
                    m.i05PolH2AreaMax[k[0]] = v
                elif k[1] == "AREA":
                    m.i05HabAreaCountry[k[0]] = v

    # i05TranspLftH2, i05CostInvH2Transp, i05EffH2Transp, i05ConsSelfH2Transp, i05AvailRateH2Transp, FC, VC, H2KMTOE from i05H2InfrCapCosts
    if data.get("i05H2InfrCapCosts"):
        for k, v in data["i05H2InfrCapCosts"].items():
            if len(k) >= 3 and k[1] in infrtech and k[2] in ytime:
                ch = k[0]
                if ch == "LFT":
                    m.i05TranspLftH2[k[1], k[2]] = v
                elif ch == "IC":
                    for cy in run_cy:
                        m.i05CostInvH2Transp[cy, k[1], k[2]] = v
                elif ch == "EFF":
                    for cy in run_cy:
                        m.i05EffH2Transp[cy, k[1], k[2]] = v
                elif ch == "SELF":
                    for cy in run_cy:
                        m.i05ConsSelfH2Transp[cy, k[1], k[2]] = v
                elif ch == "AVAIL":
                    m.i05AvailRateH2Transp[k[1], k[2]] = v
                elif ch == "FC":
                    m.i05CostInvFOMH2[k[1], k[2]] = v
                elif ch == "VC":
                    m.i05CostInvVOMH2[k[1], k[2]] = v
                elif ch == "H2KMTOE":
                    m.i05PipeH2Transp[k[1], k[2]] = v

    # iWBLPremRepH2Prod = 0.1
    for cy in run_cy:
        for ht in h2tech:
            for y in ytime:
                m.iWBLPremRepH2Prod[cy, ht, y] = 0.1

    # i05CostAvgWeight = 1 (or GAMS loop; we default 1)
    for cy in run_cy:
        for y in ytime:
            m.i05CostAvgWeight[cy, y] = 1.0
