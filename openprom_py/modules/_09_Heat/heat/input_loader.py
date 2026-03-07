# 09_Heat heat: load iChpPowGen and fill i09* params
from pathlib import Path
from typing import Any, Dict
from pyomo.core import ConcreteModel, value as pyo_value
from core import sets as core_sets

def _tsteam_heat():
    return list(core_sets.TCHP) + list(core_sets.TDHP)

def load_heat_data(config: Any) -> Dict[str, Any]:
    data = {}
    data_dir = getattr(config, "data_dir", None) or (getattr(config, "project_root", Path(__file__).resolve().parent.parent.parent.parent) / "data")
    p = Path(data_dir) / "iChpPowGen.csv"
    if p.exists():
        try:
            import pandas as pd
            df = pd.read_csv(p)
            cols = [c for c in df.columns if str(c).isdigit()]
            idx_cols = [c for c in df.columns if c not in cols]
            out = {}
            for _, row in df.iterrows():
                t, ch = (row[idx_cols[0]], row[idx_cols[1]]) if len(idx_cols) >= 2 else (row[0], row[1])
                for ycol in cols:
                    try:
                        out[(t, ch, int(ycol))] = float(row[ycol])
                    except (TypeError, ValueError):
                        pass
            data["imDataChpPowGen"] = out
        except Exception:
            data["imDataChpPowGen"] = {}
    return data

def load_heat_data_into_model(m: ConcreteModel, data: Dict[str, Any], core_sets_obj: Any) -> None:
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    tsteam = _tsteam_heat()
    base_y = getattr(core_sets_obj, "tFirst", None)
    if base_y and hasattr(base_y, "__iter__") and not isinstance(base_y, (str, int)):
        base_y = next(iter(base_y), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None
    for t in tsteam:
        if hasattr(m, "i09CaptRateSteProd"):
            m.i09CaptRateSteProd[t] = 0.0
    tbl = data.get("imDataChpPowGen") or {}
    for t in tsteam:
        for y in ytime:
            if (t, "LFT", base_y) in tbl:
                m.i09ProdLftSte[t] = tbl[(t, "LFT", base_y)]
            if (t, "IC", y) in tbl:
                m.i09CostInvCostSteProd[t, y] = tbl[(t, "IC", y)]
            if (t, "FC", y) in tbl:
                m.i09CostFixOMSteProd[t, y] = tbl[(t, "FC", y)]
            if (t, "VOM", y) in tbl:
                m.i09CostVOMSteProd[t, y] = tbl[(t, "VOM", y)]
            if (t, "effThrm", y) in tbl:
                m.i09EffSteThrm[t, y] = tbl[(t, "effThrm", y)] / 4.0
            elif (t, "effThrm", base_y) in tbl:
                m.i09EffSteThrm[t, y] = tbl[(t, "effThrm", base_y)] / 4.0
            if (t, "effElc", y) in tbl:
                m.i09EffSteElc[t, y] = tbl[(t, "effElc", y)]
            if (t, "AVAIL", y) in tbl:
                m.i09AvailRateSteProd[t, y] = tbl[(t, "AVAIL", y)]
        for y in ytime:
            if hasattr(m, "i09EffSteElc") and hasattr(m, "i09EffSteThrm"):
                m.i09PowToHeatRatio[t, y] = pyo_value(m.i09EffSteElc[t, y]) / (pyo_value(m.i09EffSteThrm[t, y]) + 1e-10)
    if "TSTE2GEO" in tsteam and hasattr(m, "i09EffSteThrm"):
        for y in ytime:
            m.i09EffSteThrm["TSTE2GEO", y] = 1.0
