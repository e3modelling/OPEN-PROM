"""
Load core input data from CSV/CSVR files in the data folder.

All paths are relative to the data directory (config.data_dir), i.e. openprom_py/data/.
File names and expected dimensions mirror core/input.gms (table/parameter declarations).
CSV format: GAMS uses $ondelim $include "file" $offdelim, so comma-delimited with
one or more index columns plus value columns (often years as columns).

Loaders return dicts keyed by (index tuple) -> float for use in Param initialize or
direct assignment. load_core_data(config) returns a dict of parameter name -> data dict.
load_core_data_into_model(m, data, core_sets_obj) writes the loaded data into the
model's mutable Params and calls the price stub filler when imFuelPrice is present.
"""
from pathlib import Path
from typing import Any, Dict

import pandas as pd


def _data_load_log(filename: str, status: str, detail: str = "") -> None:
    """Log one data-load line to the run report (main.lst) if active."""
    try:
        from run_report import get_report_logger
        log = get_report_logger()
        if log:
            if detail:
                log.info("  {}  {}  {}".format(filename, status, detail))
            else:
                log.info("  {}  {}".format(filename, status))
    except Exception:
        pass


def _path(data_dir: Path, filename: str) -> Path:
    """Return path to a file under the data folder; raise FileNotFoundError if missing."""
    p = data_dir / filename
    if not p.exists():
        raise FileNotFoundError(f"Data file not found: {p} (relative to data dir: {data_dir})")
    return p


def load_im_elast_a(data_dir: Path) -> Dict[tuple, float]:
    """
    imElastA(allCy, SBS, ETYPES, YTIME).
    CSV format: rows (allCy, SBS, ETYPES), columns = year (2010..2100).
    """
    p = _path(data_dir, "iElastA.csv")
    df = pd.read_csv(p)
    # First 3 columns are allCy, SBS, ETYPES; rest are years
    year_cols = [c for c in df.columns if str(c).isdigit()]
    idx_cols = [c for c in df.columns if c not in year_cols]
    if len(idx_cols) < 3:
        idx_cols = list(df.columns[:3])
        year_cols = list(df.columns[3:])
    out = {}
    for _, row in df.iterrows():
        cy, sbs, etype = row[idx_cols[0]], row[idx_cols[1]], row[idx_cols[2]]
        for ycol in year_cols:
            y = int(ycol)
            try:
                v = float(row[ycol])
            except (TypeError, ValueError):
                continue
            out[(cy, sbs, etype, y)] = v
    return out


def load_im_actv(data_dir: Path) -> Dict[tuple, float]:
    """
    imActv(YTIME, allCy, DSBS). Sector activity.
    CSVR: rows = (YTIME, allCy?, DSBS?), columns or rows.
    """
    p = _path(data_dir, "iActv.csvr")
    df = pd.read_csv(p)
    # Infer layout: typically rows are index, columns might be years or sectors
    # GAMS table imActv(YTIME,allCy,DSBS) - so 3-dim. Common is rows = (y, cy, sbs), one value column
    if df.shape[1] >= 3:
        # Assume first 3 cols are YTIME, allCy, DSBS
        cols = df.columns.tolist()
        out = {}
        for _, row in df.iterrows():
            try:
                y, cy, sbs = int(row[cols[0]]), str(row[cols[1]]), str(row[cols[2]])
                v = float(row[cols[3]]) if len(cols) > 3 else 1.0
                out[(y, cy, sbs)] = v
            except (ValueError, TypeError, IndexError):
                continue
        return out
    return {}


def load_im_trans_char(data_dir: Path) -> Dict[tuple, float]:
    """
    imTransChar(allCy, TRANSPCHAR, YTIME).
    """
    p = _path(data_dir, "iTransChar.csv")
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        if len(idx_cols) >= 2:
            cy, char = row[idx_cols[0]], row[idx_cols[1]]
        else:
            cy, char = row[0], row[1]
        for ycol in year_cols:
            try:
                out[(cy, char, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_im_fuel_price(data_dir: Path) -> Dict[tuple, float]:
    """
    imFuelPrice(allCy, SBS, EF, YTIME).
    """
    p = _path(data_dir, "iFuelPrice.csv")
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        if len(idx_cols) >= 3:
            cy, sbs, ef = row[idx_cols[0]], row[idx_cols[1]], row[idx_cols[2]]
        else:
            cy, sbs, ef = row[0], row[1], row[2]
        for ycol in year_cols:
            try:
                out[(cy, sbs, ef, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_im_fuel_cons(data_dir: Path) -> Dict[tuple, float]:
    """
    imFuelConsPerFueSub / imFuelCons(allCy, SBS, EF, YTIME). Fuel consumption per fuel and subsector.
    """
    p = _path(data_dir, "iFuelCons.csv")
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        if len(idx_cols) >= 3:
            cy, sbs, ef = row[idx_cols[0]], row[idx_cols[1]], row[idx_cols[2]]
        else:
            cy, sbs, ef = row[0], row[1], row[2]
        for ycol in year_cols:
            try:
                out[(cy, sbs, ef, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_core_data(config: Any) -> Dict[str, Any]:
    """
    Load all core input data used by the PoC.
    Returns a dict keyed by parameter name (e.g. 'imElastA', 'imActv', ...).
    Logs each file to the run report (main.lst): OK, NOT FOUND, or PARSE ERROR.
    """
    data_dir = Path(config.data_dir)
    result: Dict[str, Any] = {}

    # (param_name, filename, loader) for report logging
    loaders = [
        ("imElastA", "iElastA.csv", load_im_elast_a),
        ("imActv", "iActv.csvr", load_im_actv),
        ("imTransChar", "iTransChar.csv", load_im_trans_char),
        ("imFuelPrice", "iFuelPrice.csv", load_im_fuel_price),
        ("imFuelCons", "iFuelCons.csv", load_im_fuel_cons),
    ]

    for name, filename, loader in loaders:
        path = data_dir / filename
        try:
            result[name] = loader(data_dir)
            _data_load_log(filename, "OK")
        except FileNotFoundError as e:
            result[name] = None
            _data_load_log(filename, "NOT FOUND", str(path))
            if "iElastA" in str(e) or "iFuelPrice" in str(e) or "iFuelCons" in str(e):
                raise  # Required for transport
        except Exception as e:
            _data_load_log(filename, "PARSE ERROR", str(e))
            raise
    return result


def get_im_elast_a_for_country(
    data: Dict[tuple, float],
    country: str,
    sbs: str,
    etype: str,
    year: int,
    default: float = 0.5,
) -> float:
    """Get imElastA(cy, sbs, etype, y); fallback to ELL if country missing."""
    if data is None:
        return default
    v = data.get((country, sbs, etype, year))
    if v is not None:
        return float(v)
    v = data.get(("ELL", sbs, etype, year))
    return float(v) if v is not None else default


def load_core_data_into_model(
    m: Any,
    data: Dict[str, Any],
    core_sets_obj: Any,
) -> None:
    """
    Push loaded core data (from load_core_data()) into the model's mutable Params.
    Only sets indices that exist in the model and in data.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime

    if data.get("imElastA"):
        for key, val in data["imElastA"].items():
            if len(key) == 4 and key[0] in run_cy and key[3] in ytime:
                m.imElastA[key] = val

    if data.get("imActv"):
        for key, val in data["imActv"].items():
            if len(key) == 3 and key[1] in run_cy and key[0] in ytime:
                m.imActv[key] = val

    if data.get("imTransChar"):
        for key, val in data["imTransChar"].items():
            if len(key) == 3 and key[0] in run_cy and key[2] in ytime:
                m.imTransChar[key] = val

    # Fill price stub (VmPriceFuelSubsecCarVal, VmPriceFuelAvgSub) from imFuelPrice when available
    if data.get("imFuelPrice") and hasattr(m, "VmPriceFuelSubsecCarVal"):
        from prices_stub import load_price_stub_from_fuel_price
        load_price_stub_from_fuel_price(m, data["imFuelPrice"], core_sets_obj)

    # imFuelConsPerFueSub(allCy, SBS, EF, YTIME) — fuel consumption per subsector and fuel
    if data.get("imFuelCons"):
        for key, val in data["imFuelCons"].items():
            if len(key) == 4 and key[0] in run_cy and key[3] in ytime:
                m.imFuelConsPerFueSub[key] = val
