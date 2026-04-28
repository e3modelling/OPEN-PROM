#!/usr/bin/env python3
"""Compare key runtime metrics across two OPEN-PROM runs.

This script parses GAMS log/lst outputs and reports:
- Peak generation memory from log trace lines (--- ... <N> Mb)
- Compilation time and MB from lst summary lines when available
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

LOG_MB_RE = re.compile(r"^--- .*?\s(?P<mb>\d+)\s+Mb\s*$")
LST_COMP_RE = re.compile(
    r"COMPILATION TIME\s*=\s*(?P<seconds>[0-9.]+)\s+SECONDS\s+(?P<mb>\d+)\s+MB",
    re.IGNORECASE,
)
LST_EXEC_RE = re.compile(
    r"EXECUTION TIME\s*=\s*(?P<seconds>[0-9.]+)\s+SECONDS",
    re.IGNORECASE,
)


@dataclass
class RunMetrics:
    label: str
    peak_log_mb: Optional[int]
    compilation_seconds: Optional[float]
    compilation_mb: Optional[int]
    execution_seconds: Optional[float]


def _stream_lines(path: Path):
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            yield line.rstrip("\n")


def parse_log_peak_mb(path: Path) -> Optional[int]:
    peak = None
    for line in _stream_lines(path):
        m = LOG_MB_RE.match(line)
        if not m:
            continue
        val = int(m.group("mb"))
        peak = val if peak is None else max(peak, val)
    return peak


def parse_lst_metrics(path: Path) -> tuple[Optional[float], Optional[int], Optional[float]]:
    comp_seconds = None
    comp_mb = None
    exec_seconds = None

    for line in _stream_lines(path):
        if comp_seconds is None:
            m_comp = LST_COMP_RE.search(line)
            if m_comp:
                comp_seconds = float(m_comp.group("seconds"))
                comp_mb = int(m_comp.group("mb"))

        if exec_seconds is None:
            m_exec = LST_EXEC_RE.search(line)
            if m_exec:
                exec_seconds = float(m_exec.group("seconds"))

        if comp_seconds is not None and exec_seconds is not None:
            break

    return comp_seconds, comp_mb, exec_seconds


def collect_metrics(label: str, log_path: Path, lst_path: Optional[Path]) -> RunMetrics:
    peak_log_mb = parse_log_peak_mb(log_path) if log_path.exists() else None

    comp_seconds = None
    comp_mb = None
    exec_seconds = None
    if lst_path and lst_path.exists():
        comp_seconds, comp_mb, exec_seconds = parse_lst_metrics(lst_path)

    return RunMetrics(
        label=label,
        peak_log_mb=peak_log_mb,
        compilation_seconds=comp_seconds,
        compilation_mb=comp_mb,
        execution_seconds=exec_seconds,
    )


def pct_delta(base: Optional[float], cand: Optional[float]) -> Optional[float]:
    if base is None or cand is None or base == 0:
        return None
    return (cand - base) / base * 100.0


def fmt(v: Optional[float | int], precision: int = 3) -> str:
    if v is None:
        return "NA"
    if isinstance(v, int):
        return str(v)
    return f"{v:.{precision}f}"


def print_metric(name: str, base: Optional[float], cand: Optional[float], unit: str):
    delta = None if base is None or cand is None else (cand - base)
    pct = pct_delta(base, cand)

    delta_txt = "NA" if delta is None else f"{delta:+.3f} {unit}" if isinstance(delta, float) else f"{delta:+d} {unit}"
    pct_txt = "NA" if pct is None else f"{pct:+.2f}%"

    print(f"- {name}: base={fmt(base)} {unit}, candidate={fmt(cand)} {unit}, delta={delta_txt}, pct={pct_txt}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Compare OPEN-PROM run metrics between baseline and candidate runs.")
    parser.add_argument("--base-log", required=True, type=Path, help="Baseline log file (e.g., baseline/main.log)")
    parser.add_argument("--base-lst", type=Path, default=None, help="Baseline lst file (optional)")
    parser.add_argument("--cand-log", required=True, type=Path, help="Candidate log file (e.g., main.log)")
    parser.add_argument("--cand-lst", type=Path, default=None, help="Candidate lst file (optional)")

    args = parser.parse_args()

    base = collect_metrics("baseline", args.base_log, args.base_lst)
    cand = collect_metrics("candidate", args.cand_log, args.cand_lst)

    print("OPEN-PROM Run Comparison")
    print("=======================")
    print_metric("Peak log memory", base.peak_log_mb, cand.peak_log_mb, "MB")
    print_metric("Compilation time", base.compilation_seconds, cand.compilation_seconds, "s")
    print_metric("Compilation memory", base.compilation_mb, cand.compilation_mb, "MB")
    print_metric("Execution time", base.execution_seconds, cand.execution_seconds, "s")

    print("\nInterpretation")
    print("- Lower Peak log memory and Compilation memory are better.")
    print("- Lower Compilation/Execution time are better.")
    print("- Run both cases with identical config/data and compare medians over >=3 runs.")


if __name__ == "__main__":
    main()
