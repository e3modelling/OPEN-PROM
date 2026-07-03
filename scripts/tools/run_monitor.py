#!/usr/bin/env python3
"""Monitor OPEN-PROM run resources and compare monitor outputs.

Examples:
  python scripts/tools/run_monitor.py monitor --out runs/monitor_current.csv --wait --stop-when-gone
  python scripts/tools/run_monitor.py monitor --pid 12345 --out runs/monitor_pid12345.csv
  python scripts/tools/run_monitor.py compare run_a.csv run_b.csv --labels before after --outdir runs/monitor_compare
"""

from __future__ import annotations

import argparse
import csv
import math
import os
import statistics
import sys
import time
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable


MONITOR_FIELDS = [
    "timestamp",
    "elapsed_s",
    "sample",
    "scope",
    "pid",
    "ppid",
    "process_name",
    "cpu_percent",
    "rss_mb",
    "rss_gb",
    "ram_total_mb",
    "rss_percent_total",
    "cmdline",
]


@dataclass
class SampleRow:
    timestamp: str
    elapsed_s: float
    sample: int
    scope: str
    pid: str
    ppid: str
    process_name: str
    cpu_percent: float
    rss_mb: float
    rss_gb: float
    ram_total_mb: float
    rss_percent_total: float
    cmdline: str

    def as_dict(self) -> dict[str, str]:
        return {
            "timestamp": self.timestamp,
            "elapsed_s": f"{self.elapsed_s:.3f}",
            "sample": str(self.sample),
            "scope": self.scope,
            "pid": self.pid,
            "ppid": self.ppid,
            "process_name": self.process_name,
            "cpu_percent": f"{self.cpu_percent:.3f}",
            "rss_mb": f"{self.rss_mb:.3f}",
            "rss_gb": f"{self.rss_gb:.6f}",
            "ram_total_mb": f"{self.ram_total_mb:.3f}",
            "rss_percent_total": f"{self.rss_percent_total:.4f}",
            "cmdline": self.cmdline,
        }


def require_psutil():
    try:
        import psutil  # type: ignore

        return psutil
    except ImportError:
        print(
            "Missing dependency: psutil\n"
            "Install it with: python -m pip install psutil",
            file=sys.stderr,
        )
        raise SystemExit(2)


def split_match_terms(value: str) -> list[str]:
    return [part.strip().lower() for part in value.split(",") if part.strip()]


def newest_run_dir(runs_root: Path) -> Path | None:
    if not runs_root.exists():
        return None
    candidates = [path for path in runs_root.iterdir() if path.is_dir()]
    if not candidates:
        return None
    return max(candidates, key=lambda path: path.stat().st_mtime)


def path_tokens(path: Path | None) -> list[str]:
    if path is None:
        return []
    resolved = str(path.resolve()).lower()
    return [resolved, resolved.replace("\\", "/"), path.name.lower()]


def command_line(proc) -> str:
    try:
        return " ".join(proc.cmdline())
    except Exception:
        return ""


def process_matches(proc, terms: list[str]) -> bool:
    try:
        haystack = " ".join([proc.name(), command_line(proc)]).lower()
    except Exception:
        return False
    return any(term in haystack for term in terms)


def process_matches_current_run(proc, current_run: Path | None) -> bool:
    tokens = path_tokens(current_run)
    if not tokens:
        return True
    try:
        haystack = command_line(proc).lower().replace("\\", "/")
    except Exception:
        return False
    return any(token.replace("\\", "/") in haystack for token in tokens)


def process_tree(psutil, root_pid: int):
    try:
        root = psutil.Process(root_pid)
    except psutil.Error:
        return []
    procs = [root]
    try:
        procs.extend(root.children(recursive=True))
    except psutil.Error:
        pass
    return procs


def discover_processes(psutil, pid: int | None, terms: list[str], current_run: Path | None):
    if pid is not None:
        return process_tree(psutil, pid)

    procs = []
    for proc in psutil.process_iter(["pid", "name", "ppid"]):
        if process_matches(proc, terms) and process_matches_current_run(proc, current_run):
            procs.append(proc)
    return procs


def unique_live_processes(psutil, procs):
    seen = set()
    live = []
    for proc in procs:
        try:
            if not proc.is_running() or proc.status() == psutil.STATUS_ZOMBIE:
                continue
            if proc.pid in seen:
                continue
            seen.add(proc.pid)
            live.append(proc)
        except psutil.Error:
            continue
    return live


def prime_cpu_counters(procs) -> None:
    for proc in procs:
        try:
            proc.cpu_percent(interval=None)
        except Exception:
            pass


def sample_processes(psutil, procs, started_at: float, sample_index: int) -> list[SampleRow]:
    total_ram_mb = psutil.virtual_memory().total / 1024 / 1024
    timestamp = datetime.now().isoformat(timespec="seconds")
    elapsed_s = time.time() - started_at
    rows: list[SampleRow] = []

    agg_cpu = 0.0
    agg_rss_mb = 0.0

    for proc in unique_live_processes(psutil, procs):
        try:
            mem = proc.memory_info()
            rss_mb = mem.rss / 1024 / 1024
            cpu = proc.cpu_percent(interval=None)
            ppid = proc.ppid()
            name = proc.name()
            cmd = command_line(proc)
        except psutil.Error:
            continue

        agg_cpu += cpu
        agg_rss_mb += rss_mb
        rows.append(
            SampleRow(
                timestamp=timestamp,
                elapsed_s=elapsed_s,
                sample=sample_index,
                scope="process",
                pid=str(proc.pid),
                ppid=str(ppid),
                process_name=name,
                cpu_percent=cpu,
                rss_mb=rss_mb,
                rss_gb=rss_mb / 1024,
                ram_total_mb=total_ram_mb,
                rss_percent_total=(rss_mb / total_ram_mb * 100) if total_ram_mb else 0.0,
                cmdline=cmd,
            )
        )

    rows.append(
        SampleRow(
            timestamp=timestamp,
            elapsed_s=elapsed_s,
            sample=sample_index,
            scope="aggregate",
            pid="ALL",
            ppid="",
            process_name="ALL",
            cpu_percent=agg_cpu,
            rss_mb=agg_rss_mb,
            rss_gb=agg_rss_mb / 1024,
            ram_total_mb=total_ram_mb,
            rss_percent_total=(agg_rss_mb / total_ram_mb * 100) if total_ram_mb else 0.0,
            cmdline="",
        )
    )
    return rows


def monitor(args: argparse.Namespace) -> None:
    psutil = require_psutil()
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    terms = split_match_terms(args.match)

    started_at = time.time()
    sample_index = 0
    no_process_samples = 0
    selected_run_dir: Path | None = None

    print(f"Writing monitor samples to {out_path}")
    print(f"Match terms: {', '.join(terms)}")
    if args.current_run and args.pid is None:
        print(f"Current-run detection: newest directory under {Path(args.runs_root)}")

    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=MONITOR_FIELDS)
        writer.writeheader()

        while True:
            if args.current_run and args.pid is None:
                latest = newest_run_dir(Path(args.runs_root))
                if latest and latest != selected_run_dir:
                    selected_run_dir = latest
                    print(f"Selected current run: {selected_run_dir}")

            procs = discover_processes(psutil, args.pid, terms, selected_run_dir if args.current_run else None)
            live = unique_live_processes(psutil, procs)

            if not live and args.wait and sample_index == 0:
                print("No matching process yet; waiting...")
                time.sleep(args.interval)
                continue

            prime_cpu_counters(live)
            time.sleep(args.interval)
            rows = sample_processes(psutil, live, started_at, sample_index)
            for row in rows:
                writer.writerow(row.as_dict())
            handle.flush()

            aggregate = rows[-1]
            print(
                f"[{aggregate.timestamp}] "
                f"cpu={aggregate.cpu_percent:.1f}% "
                f"ram={aggregate.rss_mb:.1f} MB ({aggregate.rss_gb:.3f} GB, "
                f"{aggregate.rss_percent_total:.2f}% total) "
                f"processes={max(len(rows) - 1, 0)}"
            )

            sample_index += 1
            if not live:
                no_process_samples += 1
            else:
                no_process_samples = 0

            if args.duration and (time.time() - started_at) >= args.duration:
                break
            if args.stop_when_gone and sample_index > 0 and no_process_samples >= args.gone_samples:
                break


def read_monitor_csv(path: Path) -> list[dict[str, str]]:
    with path.open("r", newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def as_float(row: dict[str, str], key: str) -> float:
    try:
        return float(row.get(key, "") or 0)
    except ValueError:
        return 0.0


def percentile(values: list[float], pct: float) -> float:
    if not values:
        return 0.0
    ordered = sorted(values)
    if len(ordered) == 1:
        return ordered[0]
    position = (len(ordered) - 1) * pct / 100
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return ordered[int(position)]
    weight = position - lower
    return ordered[lower] * (1 - weight) + ordered[upper] * weight


def aggregate_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    agg = [row for row in rows if row.get("scope") == "aggregate"]
    return agg if agg else rows


def summarize(label: str, path: Path, rows: list[dict[str, str]]) -> dict[str, float | str]:
    agg = aggregate_rows(rows)
    elapsed = [as_float(row, "elapsed_s") for row in agg]
    cpu = [as_float(row, "cpu_percent") for row in agg]
    rss_mb = [as_float(row, "rss_mb") for row in agg]
    rss_pct = [as_float(row, "rss_percent_total") for row in agg]

    return {
        "label": label,
        "file": str(path),
        "samples": len(agg),
        "duration_s": max(elapsed) - min(elapsed) if elapsed else 0.0,
        "avg_cpu_percent": statistics.fmean(cpu) if cpu else 0.0,
        "max_cpu_percent": max(cpu) if cpu else 0.0,
        "avg_ram_mb": statistics.fmean(rss_mb) if rss_mb else 0.0,
        "max_ram_mb": max(rss_mb) if rss_mb else 0.0,
        "p95_ram_mb": percentile(rss_mb, 95),
        "avg_ram_gb": (statistics.fmean(rss_mb) / 1024) if rss_mb else 0.0,
        "max_ram_gb": (max(rss_mb) / 1024) if rss_mb else 0.0,
        "max_ram_percent_total": max(rss_pct) if rss_pct else 0.0,
    }


def write_summary_csv(path: Path, summaries: list[dict[str, float | str]]) -> None:
    fields = [
        "label",
        "file",
        "samples",
        "duration_s",
        "avg_cpu_percent",
        "max_cpu_percent",
        "avg_ram_mb",
        "max_ram_mb",
        "p95_ram_mb",
        "avg_ram_gb",
        "max_ram_gb",
        "max_ram_percent_total",
    ]
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for summary in summaries:
            writer.writerow(
                {
                    key: f"{summary[key]:.3f}" if isinstance(summary[key], float) else summary[key]
                    for key in fields
                }
            )


def markdown_table(summaries: list[dict[str, float | str]]) -> str:
    headers = [
        "run",
        "samples",
        "duration_s",
        "avg_cpu_%",
        "max_cpu_%",
        "avg_ram_mb",
        "max_ram_mb",
        "p95_ram_mb",
        "max_ram_%",
    ]
    lines = [
        "| " + " | ".join(headers) + " |",
        "| " + " | ".join(["---"] * len(headers)) + " |",
    ]
    for item in summaries:
        values = [
            str(item["label"]),
            str(item["samples"]),
            f"{float(item['duration_s']):.1f}",
            f"{float(item['avg_cpu_percent']):.1f}",
            f"{float(item['max_cpu_percent']):.1f}",
            f"{float(item['avg_ram_mb']):.1f}",
            f"{float(item['max_ram_mb']):.1f}",
            f"{float(item['p95_ram_mb']):.1f}",
            f"{float(item['max_ram_percent_total']):.2f}",
        ]
        lines.append("| " + " | ".join(values) + " |")
    return "\n".join(lines)


def write_markdown_report(path: Path, summaries: list[dict[str, float | str]]) -> None:
    path.write_text(
        "# Run Resource Comparison\n\n"
        + markdown_table(summaries)
        + "\n\nGenerated by `scripts/tools/run_monitor.py`.\n",
        encoding="utf-8",
    )


def plot_series(outdir: Path, datasets: list[tuple[str, list[dict[str, str]]]]) -> None:
    try:
        import matplotlib  # type: ignore

        matplotlib.use("Agg")
        import matplotlib.pyplot as plt  # type: ignore
    except ImportError:
        print("matplotlib not installed; skipping plots.")
        return

    specs = [
        ("rss_mb", "RAM (MB)", "ram_mb.png"),
        ("rss_gb", "RAM (GB)", "ram_gb.png"),
        ("rss_percent_total", "RAM (% of total)", "ram_percent_total.png"),
        ("cpu_percent", "CPU (%)", "cpu_percent.png"),
    ]

    for column, ylabel, filename in specs:
        plt.figure(figsize=(10, 5))
        for label, rows in datasets:
            agg = aggregate_rows(rows)
            x = [as_float(row, "elapsed_s") for row in agg]
            y = [as_float(row, column) for row in agg]
            plt.plot(x, y, label=label, linewidth=1.8)
        plt.xlabel("Elapsed seconds")
        plt.ylabel(ylabel)
        plt.title(ylabel)
        plt.grid(True, alpha=0.3)
        plt.legend()
        plt.tight_layout()
        plt.savefig(outdir / filename, dpi=140)
        plt.close()


def compare(args: argparse.Namespace) -> None:
    paths = [Path(args.run_a), Path(args.run_b)]
    labels = args.labels or [paths[0].stem, paths[1].stem]
    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    datasets = [(label, read_monitor_csv(path)) for label, path in zip(labels, paths)]
    summaries = [summarize(label, path, rows) for (label, rows), path in zip(datasets, paths)]

    summary_csv = outdir / "summary.csv"
    report_md = outdir / "summary.md"
    write_summary_csv(summary_csv, summaries)
    write_markdown_report(report_md, summaries)
    plot_series(outdir, datasets)

    print(markdown_table(summaries))
    print(f"\nWrote {summary_csv}")
    print(f"Wrote {report_md}")
    print(f"Wrote plots to {outdir}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Monitor and compare OPEN-PROM run resources.")
    sub = parser.add_subparsers(dest="command", required=True)

    monitor_parser = sub.add_parser("monitor", help="Monitor CPU and RAM for a live run.")
    monitor_parser.add_argument("--out", default="runs/run_monitor.csv", help="Output CSV path.")
    monitor_parser.add_argument(
        "--match",
        default="Rscript,gams,conopt",
        help="Comma-separated process-name/cmdline terms to monitor when --pid is not used.",
    )
    monitor_parser.add_argument("--pid", type=int, help="Root PID to monitor, including children.")
    monitor_parser.add_argument(
        "--current-run",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Restrict process matching to the newest directory under --runs-root. Enabled by default.",
    )
    monitor_parser.add_argument("--runs-root", default="runs", help="Runs directory used by --current-run.")
    monitor_parser.add_argument("--interval", type=float, default=2.0, help="Seconds between samples.")
    monitor_parser.add_argument("--duration", type=float, default=0.0, help="Stop after N seconds; 0 means unlimited.")
    monitor_parser.add_argument("--wait", action="store_true", help="Wait until a matching process appears.")
    monitor_parser.add_argument(
        "--stop-when-gone",
        action="store_true",
        help="Stop after matching processes disappear.",
    )
    monitor_parser.add_argument(
        "--gone-samples",
        type=int,
        default=3,
        help="Consecutive empty samples before stopping with --stop-when-gone.",
    )
    monitor_parser.set_defaults(func=monitor)

    compare_parser = sub.add_parser("compare", help="Compare two monitor CSV files.")
    compare_parser.add_argument("run_a", help="First monitor CSV.")
    compare_parser.add_argument("run_b", help="Second monitor CSV.")
    compare_parser.add_argument("--labels", nargs=2, help="Labels for the two runs.")
    compare_parser.add_argument("--outdir", default="runs/monitor_compare", help="Output directory.")
    compare_parser.set_defaults(func=compare)

    return parser


def main(argv: Iterable[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
