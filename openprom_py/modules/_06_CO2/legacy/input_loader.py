"""
Load 06_CO2 (legacy) input data.

Mirrors modules/06_CO2/legacy/input.gms. Loads i06CO2SeqData (CO2SEQELAST), i06MatFacDAC,
i06CapexDAC, i06CapexDACMin, i06FixCostDAC, i06FixCostDACMin, i06VarDAC, i06VarDACMin,
i06SubsiDAC, i06LftExpDAC, i06ElNeedsDAC, i06HeatNeedsDAC, i06SchedNewCapDAC.
Derived: i06ElastCO2Seq, i06GrossCapDAC/Min, i06FixOandMDAC/Min, i06VarCostDAC/Min,
i06SubsiFacDAC, i06LftDAC, i06SpecElecDAC, i06SpecHeatDAC.

We load from optional CSV i06SchedNewCapDAC.csv when present (no scenario switch).
"""
from pathlib import Path
from typing import Any, Dict

from core import sets as core_sets

# --- GAMS input.gms $ifthen.DACproj ... $endIf (commented-out branch), transferred as comments ---
# $ifthen.DACproj %fScenario% == 2
#   CHA.LTDAC.2026 1e6, CHA.H2DAC.2030 1e5, CHA.TEW.2030 1e6, OAS.LTDAC.2030 1e6, OAS.TEW.2035 1e5,
#   DEU.LTDAC.2035 4e5, DEU.TEW.2035 2e5, FRA.LTDAC.2035 2e5, GBR.H2DAC.2035 5e4, IND.LTDAC.2026 7e5,
#   IND.TEW.2030 7e5, JPN.H2DAC.2030 1e5, REF.LTDAC.2029 5e5, REF.TEW.2033 1e5, MEA.LTDAC.2031 1e5,
#   MEA.TEW.2037 5e5, SSA.LTDAC.2032 1e6, SSA.TEW.2037 1e5, LAM.TEW.2024 5e5;
# $else.DACproj
#   /;
# $endIf.DACproj

# Default table (GAMS parameter inline in input.gms)
_I06_CO2_SEQ_DATA = {
    "POT": 9175.0,
    "mc_a": 0.0,
    "mc_b": 20.0,
    "mc_c": 0.02,
    "mc_d": 5e3,
    "mc_s": 120.0,
    "mc_m": 1.013,
}
_I06_MAT_FAC_DAC = {"HTDAC": 0.80, "H2DAC": 0.27, "LTDAC": 0.13, "TEW": 0.35}
_I06_CAPEX_DAC = {"HTDAC": 250.0, "H2DAC": 1300.0, "LTDAC": 1300.0, "TEW": 400.0}
_I06_CAPEX_DAC_MIN = {"HTDAC": 120.0, "H2DAC": 68.0, "LTDAC": 68.0, "TEW": 68.0}
_I06_FIX_COST_DAC = {"HTDAC": 72.0, "H2DAC": 80.0, "LTDAC": 180.0, "TEW": 600.0}
_I06_FIX_COST_DAC_MIN = {"HTDAC": 40.0, "H2DAC": 40.0, "LTDAC": 30.0, "TEW": 30.0}
_I06_VAR_DAC = {"HTDAC": 90.0, "H2DAC": 115.0, "LTDAC": 306.0, "TEW": 200.0}
_I06_VAR_DAC_MIN = {"HTDAC": 75.0, "H2DAC": 94.0, "LTDAC": 250.0, "TEW": 130.0}
_I06_SUBSI_DAC = {"HTDAC": 1.0, "H2DAC": 1.8, "LTDAC": 1.8, "TEW": 1.8}
_I06_LFT_EXP_DAC = {"HTDAC": 25.0, "H2DAC": 25.0, "LTDAC": 20.0, "TEW": 15.0}
_I06_EL_NEEDS_DAC = {"HTDAC": 0.12658832, "H2DAC": 0.12658832, "LTDAC": 0.0236457, "TEW": 3.0}
_I06_HEAT_NEEDS_DAC = {"HTDAC": 1.265883, "H2DAC": 1.265883, "LTDAC": 0.0, "TEW": 0.0}


def _read_csv_table(data_dir: Path, filename: str, dims: int, year_cols: bool = True) -> Dict[tuple, float]:
    """Read CSV; return dict keyed by tuple (index cols + year if year_cols)."""
    import pandas as pd
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


def load_co2_data(config: Any) -> Dict[str, Dict[tuple, float]]:
    """Load 06 CO2 data. Returns dict of param name -> index -> value."""
    data_dir = Path(config.data_dir)
    base = data_dir / "06_CO2" / "legacy"
    if not base.exists():
        base = data_dir
    out: Dict[str, Dict[tuple, float]] = {}

    # Inline defaults from GAMS
    out["i06CO2SeqData"] = {(k,): v for k, v in _I06_CO2_SEQ_DATA.items()}
    out["i06MatFacDAC"] = {(k,): v for k, v in _I06_MAT_FAC_DAC.items()}
    out["i06CapexDAC"] = {(k,): v for k, v in _I06_CAPEX_DAC.items()}
    out["i06CapexDACMin"] = {(k,): v for k, v in _I06_CAPEX_DAC_MIN.items()}
    out["i06FixCostDAC"] = {(k,): v for k, v in _I06_FIX_COST_DAC.items()}
    out["i06FixCostDACMin"] = {(k,): v for k, v in _I06_FIX_COST_DAC_MIN.items()}
    out["i06VarDAC"] = {(k,): v for k, v in _I06_VAR_DAC.items()}
    out["i06VarDACMin"] = {(k,): v for k, v in _I06_VAR_DAC_MIN.items()}
    out["i06SubsiDAC"] = {(k,): v for k, v in _I06_SUBSI_DAC.items()}
    out["i06LftExpDAC"] = {(k,): v for k, v in _I06_LFT_EXP_DAC.items()}
    out["i06ElNeedsDAC"] = {(k,): v for k, v in _I06_EL_NEEDS_DAC.items()}
    out["i06HeatNeedsDAC"] = {(k,): v for k, v in _I06_HEAT_NEEDS_DAC.items()}

    # Optional CSV overrides
    sched = _read_csv_table(base, "i06SchedNewCapDAC.csv", 3, year_cols=True)
    if sched:
        out["i06SchedNewCapDAC"] = sched

    return out


def load_co2_data_into_model(
    m: Any,
    data: Dict[str, Dict[tuple, float]],
    core_sets_obj: Any,
) -> None:
    """Fill model parameters from loaded data. Replicate GAMS assignments."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    cdrtech = list(core_sets.CDRTECH)
    co2seqelast = list(core_sets.CO2SEQELAST)

    # i06ElastCO2Seq(runCy, CO2SEQELAST) = i06CO2SeqData(CO2SEQELAST)
    seq = data.get("i06CO2SeqData", {})
    for cy in run_cy:
        for el in co2seqelast:
            k = (el,)
            if k in seq:
                m.i06ElastCO2Seq[cy, el] = seq[k]

    # i06GrossCapDACMin(CDRTECH) = i06CapexDACMin
    for t in cdrtech:
        v = data.get("i06CapexDACMin", {}).get((t,), _I06_CAPEX_DAC_MIN.get(t, 68.0))
        m.i06GrossCapDACMin[t] = v
    # i06GrossCapDAC(CDRTECH) = i06CapexDAC
    for t in cdrtech:
        v = data.get("i06CapexDAC", {}).get((t,), _I06_CAPEX_DAC.get(t, 500.0))
        m.i06GrossCapDAC[t] = v
    # i06VarCostDAC = i06VarDAC, i06VarCostDACMin = i06VarDACMin
    for t in cdrtech:
        m.i06VarCostDAC[t] = data.get("i06VarDAC", {}).get((t,), _I06_VAR_DAC.get(t, 150.0))
        m.i06VarCostDACMin[t] = data.get("i06VarDACMin", {}).get((t,), _I06_VAR_DAC_MIN.get(t, 94.0))
    # i06FixOandMDACMin = i06FixCostDACMin, i06FixOandMDAC = i06FixCostDAC
    for t in cdrtech:
        m.i06FixOandMDACMin[t] = data.get("i06FixCostDACMin", {}).get((t,), _I06_FIX_COST_DAC_MIN.get(t, 30.0))
        m.i06FixOandMDAC[t] = data.get("i06FixCostDAC", {}).get((t,), _I06_FIX_COST_DAC.get(t, 100.0))
    # i06SubsiFacDAC = i06SubsiDAC
    for t in cdrtech:
        m.i06SubsiFacDAC[t] = data.get("i06SubsiDAC", {}).get((t,), _I06_SUBSI_DAC.get(t, 1.0))
    # i06LftDAC(runCy, CDRTECH, YTIME) = i06LftExpDAC(CDRTECH)
    for cy in run_cy:
        for t in cdrtech:
            for y in ytime:
                m.i06LftDAC[cy, t, y] = data.get("i06LftExpDAC", {}).get((t,), _I06_LFT_EXP_DAC.get(t, 25.0))
    # i06SpecElecDAC = i06ElNeedsDAC, i06SpecHeatDAC = i06HeatNeedsDAC
    for cy in run_cy:
        for t in cdrtech:
            for y in ytime:
                m.i06SpecElecDAC[cy, t, y] = data.get("i06ElNeedsDAC", {}).get((t,), _I06_EL_NEEDS_DAC.get(t, 0.1))
                m.i06SpecHeatDAC[cy, t, y] = data.get("i06HeatNeedsDAC", {}).get((t,), _I06_HEAT_NEEDS_DAC.get(t, 0.5))
    # i06MatFacDAC
    for t in cdrtech:
        m.i06MatFacDAC[t] = data.get("i06MatFacDAC", {}).get((t,), _I06_MAT_FAC_DAC.get(t, 0.3))
    # i06SchedNewCapDAC
    sched = data.get("i06SchedNewCapDAC", {})
    for k, v in sched.items():
        if len(k) == 3 and k[0] in run_cy and k[1] in cdrtech and k[2] in ytime:
            m.i06SchedNewCapDAC[k] = v
