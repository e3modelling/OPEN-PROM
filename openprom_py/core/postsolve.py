"""
Core postsolve: export solution to CSV (or GDX when gdxpds available).

Mirrors core/postsolve.gms: after each solve (or at end of run), export
selected variables for comparison with GAMS or for downstream use. The full
GAMS model writes outputData.gdx / outputCalib.gdx; here we provide a simple
CSV export of the objective and a few transport variables.
"""
from pathlib import Path
from typing import Any

from pyomo.core import value


def export_solution_csv(m: Any, filepath: Path, core_sets_obj: Any) -> None:
    """
    Write key variables to a CSV file for the current solution.

    Rows: variable name, country (if indexed), year (if indexed), value.
    Includes vDummyObj, V01StockPcYearly, V01PcOwnPcLevl. Extend as needed
    for calibration or reporting.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    lines = ["variable,country,year,value"]
    try:
        lines.append(f"vDummyObj,,,{value(m.vDummyObj)}")
    except (TypeError, ValueError):
        pass
    for cy in run_cy:
        for y in ytime:
            try:
                v = value(m.V01StockPcYearly[cy, y])
                lines.append(f"V01StockPcYearly,{cy},{y},{v}")
            except (TypeError, ValueError, KeyError):
                pass
            try:
                v = value(m.V01PcOwnPcLevl[cy, y])
                lines.append(f"V01PcOwnPcLevl,{cy},{y},{v}")
            except (TypeError, ValueError, KeyError):
                pass
    filepath = Path(filepath)
    filepath.parent.mkdir(parents=True, exist_ok=True)
    filepath.write_text("\n".join(lines), encoding="utf-8")
