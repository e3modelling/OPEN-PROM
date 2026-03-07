# 11_Economy economy: load iSubsiPerDemTech.csv -> i11SubsiPerDemTechAvail
from pathlib import Path
from typing import Any, Dict
from pyomo.core import ConcreteModel

def load_economy_data(config: Any) -> Dict[str, Any]:
    data = {}
    data_dir = getattr(config, "data_dir", None) or (getattr(config, "project_root", Path(__file__).resolve().parent.parent.parent.parent) / "data")
    p = Path(data_dir) / "iSubsiPerDemTech.csv"
    if p.exists():
        try:
            import pandas as pd
            df = pd.read_csv(p)
            cols = [c for c in df.columns if str(c).isdigit()]
            idx_cols = [c for c in df.columns if c not in cols]
            out = {}
            for _, row in df.iterrows():
                n = len(idx_cols)
                cy = row[idx_cols[0]] if n >= 1 else row[0]
                dsb = row[idx_cols[1]] if n >= 2 else row[1]
                t = row[idx_cols[2]] if n >= 3 else row[2]
                for ycol in cols:
                    try:
                        out[(cy, dsb, t, int(ycol))] = float(row[ycol])
                    except (TypeError, ValueError):
                        pass
            data["i11SubsiPerDemTechAvail"] = out
        except Exception:
            data["i11SubsiPerDemTechAvail"] = {}
    return data

def load_economy_data_into_model(m: ConcreteModel, data: Dict[str, Any], core_sets_obj: Any) -> None:
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    if not data.get("i11SubsiPerDemTechAvail") or not hasattr(m, "i11SubsiPerDemTechAvail"):
        return
    for key, val in data["i11SubsiPerDemTechAvail"].items():
        if len(key) == 4 and key[0] in run_cy and key[3] in ytime:
            try:
                m.i11SubsiPerDemTechAvail[key] = float(val)
            except Exception:
                pass
