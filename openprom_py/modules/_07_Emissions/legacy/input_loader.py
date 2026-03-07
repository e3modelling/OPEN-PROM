"""
Load 07_Emissions (legacy) input data.

Mirrors modules/07_Emissions/legacy/input.gms. Loads i07DataCh4N2OFMAC (from CSV if present),
i07DataCh4N2OFEmis (from CSV if present), sets p07MacCost (E07MAC value), p07MarginalRed (derived),
p07UnitConvFactor, p07GWP, p07CostCorrection (defaults + GWP/cost correction by source).

--- GAMS input.gms (transferred as comments) ---
* table i07DataCh4N2OFMAC(allCy,E07SrcMacAbate,E07MAC,YTIME) $include"./iDataCh4N2OFgasesMAC.csv"
* table i07DataCh4N2OFEmis(allCy,E07SrcMacAbate,YTIME) $include"./iDataCh4N2OFgasesEmissions.csv"
* Parameter p07MacCost(E07MAC) / 0 0, 20 20, 40 40, ... 4000 4000 /;
* p07MarginalRed = i07DataCh4N2OFMAC(...,E07MAC,...) - i07DataCh4N2OFMAC(...,E07MAC-1,...); ord(E07MAC)=1 => = i07DataCh4N2OFMAC
* p07UnitConvFactor, p07GWP, p07CostCorrection: defaults then GROUP 1 (CH4/N2O ord<=14), GROUP 2 (F-gases)
"""
from pathlib import Path
from typing import Any, Dict

from core import sets as core_sets


def _read_csv_4d(data_dir: Path, filename: str, idx_cols_count: int) -> Dict[tuple, float]:
    """
    Read CSV with year columns (e.g. 2010, 2020, ...).
    Returns dict keyed by (index_cols..., year). idx_cols_count = number of index columns (e.g. 3 for cy, src, mac).
    """
    try:
        import pandas as pd
    except ImportError:
        return {}
    p = data_dir / filename
    if not p.exists():
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).strip().isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        for ycol in year_cols:
            try:
                y = int(ycol)
                key = tuple(row[c] for c in idx_cols) + (y,)
                if len(key) == idx_cols_count + 1:
                    out[key] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_emissions_data(config: Any) -> Dict[str, Dict[tuple, float]]:
    """Load 07 Emissions data. Returns dict of param name -> (index tuple) -> value."""
    data_dir = Path(config.data_dir)
    base = data_dir / "07_Emissions" / "legacy"
    if not base.exists():
        base = data_dir
    out: Dict[str, Dict[tuple, float]] = {}

    # Optional CSVs (GAMS: iDataCh4N2OFgasesMAC.csv, iDataCh4N2OFgasesEmissions.csv)
    mac_data = _read_csv_4d(base, "iDataCh4N2OFgasesMAC.csv", 3)  # (cy, src, mac, y)
    emis_data = _read_csv_4d(base, "iDataCh4N2OFgasesEmissions.csv", 2)  # (cy, src, y)
    out["i07DataCh4N2OFMAC"] = mac_data
    out["i07DataCh4N2OFEmis"] = emis_data

    return out


def load_emissions_data_into_model(
    m,
    data: Dict[str, Dict[tuple, float]],
    core_sets_obj,
) -> None:
    """
    Fill model parameters from loaded data and apply GAMS-derived logic.

    - p07MacCost(mac) = mac (numeric value of E07MAC step).
    - p07MarginalRed = i07DataCh4N2OFMAC(cy,src,mac,y) - i07DataCh4N2OFMAC(cy,src,mac-1,y); first step = same.
    - p07UnitConvFactor, p07GWP, p07CostCorrection: defaults then overrides (CH4/N2O first 14, F-gases).
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    e07mac = list(core_sets.E07MAC)
    e07src = list(core_sets.E07SrcMacAbate)
    s_f_gases = set(core_sets.sFGases)
    sm_cto_co2 = getattr(m, "smCtoCO2", 3.66)
    if hasattr(sm_cto_co2, "value"):
        sm_cto_co2 = sm_cto_co2.value
    sm_d15_10 = getattr(m, "smDefl_15_to_10", 1.0)
    if hasattr(sm_d15_10, "value"):
        sm_d15_10 = sm_d15_10.value
    sm_d15_05 = getattr(m, "smDefl_15_to_05", 1.0)
    if hasattr(sm_d15_05, "value"):
        sm_d15_05 = sm_d15_05.value

    mac_csv = data.get("i07DataCh4N2OFMAC", {})
    emis_csv = data.get("i07DataCh4N2OFEmis", {})

    for (cy, src, mac, y), val in mac_csv.items():
        if hasattr(m, "i07DataCh4N2OFMAC"):
            try:
                m.i07DataCh4N2OFMAC[cy, src, mac, y] = val
            except (KeyError, TypeError):
                pass
    for (cy, src, y), val in emis_csv.items():
        if hasattr(m, "i07DataCh4N2OFEmis"):
            try:
                m.i07DataCh4N2OFEmis[cy, src, y] = val
            except (KeyError, TypeError):
                pass

    # GAMS: Parameter p07MacCost(E07MAC) / 0 0, 20 20, ... 4000 4000 /; (turns label into number)
    for mac in e07mac:
        if hasattr(m, "p07MacCost"):
            m.p07MacCost[mac] = float(mac)

    # p07MarginalRed = i07DataCh4N2OFMAC(...,E07MAC,...) - i07DataCh4N2OFMAC(...,E07MAC-1,...); ord(E07MAC)=1 => marginal = total
    mac_list = e07mac
    for cy in run_cy:
        for src in e07src:
            for i, mac in enumerate(mac_list):
                for y in ytime:
                    cur = mac_csv.get((cy, src, mac, y), 0.0)
                    if i == 0:
                        marg = cur
                    else:
                        prev_mac = mac_list[i - 1]
                        prev = mac_csv.get((cy, src, prev_mac, y), 0.0)
                        marg = cur - prev
                    if hasattr(m, "p07MarginalRed"):
                        try:
                            m.p07MarginalRed[cy, src, mac, y] = marg
                        except (KeyError, TypeError):
                            pass

    # Default: p07UnitConvFactor = smCtoCO2, p07GWP = 1, p07CostCorrection = 1; then overrides by group
    for i, src in enumerate(e07src):
        ord1 = i + 1
        if hasattr(m, "p07UnitConvFactor"):
            m.p07UnitConvFactor[src] = sm_cto_co2
        if hasattr(m, "p07GWP"):
            m.p07GWP[src] = 1.0
        if hasattr(m, "p07CostCorrection"):
            m.p07CostCorrection[src] = 1.0

    # GROUP 1: CH4/N2O (ord <= 14): UnitConvFactor = smCtoCO2 * smDefl_15_to_10; CostCorrection = 1/smDefl_15_to_10
    for i, src in enumerate(e07src):
        if i < 14:
            if hasattr(m, "p07UnitConvFactor"):
                m.p07UnitConvFactor[src] = sm_cto_co2 * sm_d15_10
            if hasattr(m, "p07CostCorrection") and src not in s_f_gases:
                m.p07CostCorrection[src] = 1.0 / (sm_d15_10 + 1e-10)

    # GROUP 2: F-gases (ord > 14): UnitConvFactor = smCtoCO2 * smDefl_15_to_05; CostCorrection = 1e3*GWP/smCtoCO2/smDefl_15_to_05*1e-6 (GAMS logic)
    for i, src in enumerate(e07src):
        if i >= 14 or src in s_f_gases:
            if hasattr(m, "p07UnitConvFactor"):
                m.p07UnitConvFactor[src] = sm_cto_co2 * sm_d15_05
            if hasattr(m, "p07CostCorrection") and src in s_f_gases:
                gwp = _gwp_default(src)
                m.p07CostCorrection[src] = 1e3 * gwp * (1.0 / sm_cto_co2) * (1.0 / (sm_d15_05 + 1e-10)) * 1e-6

    # p07GWP overrides: GAMS sets specific GWP for HFC/PFC/SF6 (AR4 100yr); CH4/N2O stay at 1
    for src in e07src:
        gwp = _gwp_default(src)
        if gwp != 1.0 and hasattr(m, "p07GWP"):
            m.p07GWP[src] = gwp


def _gwp_default(src: str) -> float:
    """Return GWP (Global Warming Potential, AR4 100yr) for F-gas source; 1 for CH4/N2O. From GAMS input.gms."""
    _gwp = {
        "HFC_23": 14800, "HFC_32": 675, "HFC_43_10": 1640, "HFC_125": 3500,
        "HFC_134a": 1430, "HFC_143a": 4470, "HFC_152a": 124, "HFC_227ea": 3220,
        "HFC_236fa": 9810, "HFC_245ca": 693,
        "CF4": 7390, "C2F6": 12200, "SF6": 22800, "C6F14": 9300,
    }
    return _gwp.get(src, 1.0)
