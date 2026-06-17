"""
Compare carbon-price-trajectory (alpha) emissions runs against a manual NDC/LTS target.
============================================================================

Auto-discovers run folders named like:
    runs/COMTD_SSP2_NDC_a<ALPHA>_LTS_<timestamp>/reporting.mif

extracts the World "Emissions|Kyoto Gases" row from each, and compares them
against a manual reference run (by default, the run folder
runs/COMTD_SSP2_NDC_LTS_<timestamp>/reporting.mif, which fulfills the NDC
and LTS targets by manual/direct calibration rather than a price-driven
trajectory).

NOTE: the scenario_name field inside reporting.mif / config.json can be
stale (copy-paste artifact between runs) -- this script always trusts the
*folder name* for identifying a run, not the in-file scenario label.

Usage
-----
# Compare all alpha runs found under runs/ against the manual run folder
python scripts/compare_emissions_trajectories.py

# Point at a different manual reference run folder
python scripts/compare_emissions_trajectories.py \
    --manual-run runs/COMTD_SSP2_NDC_LTS_2026-06-04_10-49-29

# Or fall back to a standalone CSV/mif snapshot instead of a run folder
python scripts/compare_emissions_trajectories.py \
    --manual-csv Kyoto_gases_results.csv \
    --manual-scenario COMTD_SSP2_NDC_LTS

# Restrict to specific alphas, custom milestone years
python scripts/compare_emissions_trajectories.py --alphas 0.3 1 1.3 --years 2030 2050 2100

# Check whether each alpha run fulfills the NDC/LTS scenario protocol
# (i.e. tracks the manual NDC/LTS-compliant path within tolerance at the
# NDC and LTS checkpoint years, and does not diverge to runaway negative
# emissions afterward)
python scripts/compare_emissions_trajectories.py --check-protocol

# Classify the *shape* of the resulting emissions trajectory between the
# NDC and LTS years (concave / linear / convex) for each alpha price run --
# answers "does a convex price imply convex emissions?" empirically.
python scripts/compare_emissions_trajectories.py --check-shape
"""

import argparse
import csv
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).parent.parent
RUNS_DIR = REPO_ROOT / "runs"
DEFAULT_MANUAL_RUN = RUNS_DIR / "COMTD_SSP2_NDC_LTS_2026-06-04_10-49-29"
DEFAULT_MANUAL_CSV = REPO_ROOT / "Kyoto_gases_results.csv"
DEFAULT_MANUAL_SCENARIO = "COMTD_SSP2_NDC_LTS"

VARIABLE = "Emissions|Kyoto Gases"
REGION = "World"

RUN_FOLDER_RE = re.compile(r"^COMTD_SSP2_NDC_a([0-9.]+)_LTS_(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})$")

DEFAULT_MILESTONES = [2020, 2025, 2030, 2035, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 2100]

# Scenario protocol checkpoints: the manual NDC/LTS run is the ground truth
# for "fulfills the protocol" -- these are the years where compliance matters most.
NDC_YEAR = 2030
LTS_YEAR = 2050
PROTOCOL_TOLERANCE_PCT = 10.0   # max allowed deviation from manual at NDC/LTS checkpoints
RUNAWAY_FACTOR = 2.0            # flag if emissions go more negative than RUNAWAY_FACTOR x manual's most negative milestone

# Per-region LTS year overrides: most regions target LTS=2050, but CHA/REF
# target 2060 and IND/SSA target 2070 under the scenario protocol.
REGION_LTS_YEAR = {
    "CHA": 2060,
    "REF": 2060,
    "IND": 2070,
    "SSA": 2070,
}

# EU27 member states -- excluded from the per-region table by default since
# they are already aggregated into the "EU" region row.
EU27_REGIONS = {
    "AUT", "BEL", "BGR", "CYP", "CZE", "DEU", "DNK", "ESP", "EST",
    "FIN", "FRA", "GRC", "HRV", "HUN", "IRL", "ITA", "LTU", "LUX",
    "LVA", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "SWE",
}


def parse_mif_row(path: Path, region: str, variable: str) -> dict[str, float] | None:
    """Return year->value for the first matching region/variable row in a .mif file."""
    with open(path, encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        header = next(reader)
        years = [h.strip() for h in header[5:] if h.strip()]
        for row in reader:
            if len(row) < 5:
                continue
            if row[2].strip() == region and row[3].strip() == variable:
                vals = row[5:5 + len(years)]
                return {y: float(v) for y, v in zip(years, vals) if v.strip() != ""}
    return None


def parse_mif_all_regions(path: Path, variable: str) -> dict[str, dict[str, float]]:
    """Return {region: {year: value}} for every region reporting `variable` in this mif."""
    result: dict[str, dict[str, float]] = {}
    with open(path, encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        header = next(reader)
        years = [h.strip() for h in header[5:] if h.strip()]
        for row in reader:
            if len(row) < 5:
                continue
            if row[3].strip() != variable:
                continue
            region = row[2].strip()
            vals = row[5:5 + len(years)]
            result[region] = {y: float(v) for y, v in zip(years, vals) if v.strip() != ""}
    return result


def discover_alpha_runs(runs_dir: Path) -> dict[float, Path]:
    """Find runs/COMTD_SSP2_NDC_a<ALPHA>_LTS_<timestamp>/reporting.mif, keep the latest per alpha."""
    found: dict[float, tuple[str, Path]] = {}
    if not runs_dir.exists():
        return {}
    for entry in runs_dir.iterdir():
        if not entry.is_dir():
            continue
        m = RUN_FOLDER_RE.match(entry.name)
        if not m:
            continue
        alpha = float(m.group(1))
        timestamp = m.group(2)
        mif = entry / "reporting.mif"
        if not mif.exists():
            continue
        if alpha not in found or timestamp > found[alpha][0]:
            found[alpha] = (timestamp, mif)
    return {a: p for a, (_, p) in found.items()}


def load_manual_series(csv_path: Path, scenario: str, region: str, variable: str) -> dict[str, float]:
    with open(csv_path, encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=";")
        header = next(reader)
        years = [h.strip() for h in header[5:] if h.strip()]
        for row in reader:
            if len(row) < 5:
                continue
            if row[1].strip() == scenario and row[2].strip() == region and row[3].strip() == variable:
                vals = row[5:5 + len(years)]
                return {y: float(v) for y, v in zip(years, vals) if v.strip() != ""}
    raise ValueError(f"Scenario '{scenario}' / region '{region}' / variable '{variable}' not found in {csv_path}")


def print_comparison(manual: dict[str, float], alpha_series: dict[float, dict[str, float]], milestones: list[int]) -> None:
    years = [str(y) for y in milestones if str(y) in manual]
    alphas = sorted(alpha_series)

    print(f"\n{'Year':>8}{'manual':>14}", end="")
    for a in alphas:
        print(f"{'alpha=' + str(a):>16}", end="")
    print()
    print("-" * (22 + 16 * len(alphas)))
    for y in years:
        print(f"{y:>8}{manual[y]:>14.1f}", end="")
        for a in alphas:
            v = alpha_series[a].get(y)
            print(f"{v:>16.1f}" if v is not None else f"{'n/a':>16}", end="")
        print()

    print("\n--- Deviation from manual (alpha run - manual), %% ---")
    print(f"{'Year':>8}", end="")
    for a in alphas:
        print(f"{'alpha=' + str(a):>16}", end="")
    print()
    for y in years:
        print(f"{y:>8}", end="")
        base = manual[y]
        for a in alphas:
            v = alpha_series[a].get(y)
            if v is None or base == 0:
                print(f"{'n/a':>16}", end="")
            else:
                pct = (v - base) / abs(base) * 100
                print(f"{pct:>+15.1f}%", end="")
        print()

    print("\n--- Implied avg. annual %% change (first milestone -> last milestone) ---")
    if len(years) >= 2:
        y0, y1 = years[0], years[-1]
        n = int(y1) - int(y0)
        if n > 0:
            def rate(v0, v1):
                if v0 == 0 or v1 / v0 <= 0:
                    return None
                return ((v1 / v0) ** (1 / n) - 1) * 100
            r = rate(manual[y0], manual[y1])
            print(f"  manual:    {r:+.2f}%/yr" if r is not None else "  manual:    n/a")
            for a in alphas:
                v0, v1 = alpha_series[a].get(y0), alpha_series[a].get(y1)
                if v0 is not None and v1 is not None:
                    r = rate(v0, v1)
                    print(f"  alpha={a}:  {r:+.2f}%/yr" if r is not None else f"  alpha={a}:  n/a")


def check_protocol(
    manual: dict[str, float],
    alpha_series: dict[float, dict[str, float]],
    milestones: list[int],
    ndc_year: int = NDC_YEAR,
    lts_year: int = LTS_YEAR,
    tolerance_pct: float = PROTOCOL_TOLERANCE_PCT,
    runaway_factor: float = RUNAWAY_FACTOR,
) -> None:
    """Report, per alpha, whether the run fulfills the NDC/LTS protocol.

    'Fulfills the protocol' is judged against the manual NDC/LTS-compliant
    run (the ground truth), not against any standalone target file:
      1. At the NDC year, emissions must be within tolerance_pct of manual.
      2. At the LTS year, emissions must be within tolerance_pct of manual.
      3. Beyond the LTS year, emissions must not run away to unrealistic
         negative values (more negative than runaway_factor x the most
         negative manual milestone value).
    """
    manual_min = min(manual.values())
    # Runaway threshold: emissions should never plunge past runaway_factor x
    # the manual path's most extreme (lowest) value -- whether that value is
    # positive or negative. If manual stays positive, anything substantially
    # negative is already a red flag.
    if manual_min < 0:
        runaway_threshold = manual_min * runaway_factor
    else:
        runaway_threshold = -abs(manual_min) * runaway_factor if manual_min != 0 else -1.0

    print("\n=== NDC/LTS Scenario Protocol Check (ground truth: manual run) ===")
    for a in sorted(alpha_series):
        series = alpha_series[a]
        verdicts = []

        ndc_val = series.get(str(ndc_year))
        ndc_manual = manual.get(str(ndc_year))
        if ndc_val is not None and ndc_manual:
            dev = (ndc_val - ndc_manual) / abs(ndc_manual) * 100
            ok = abs(dev) <= tolerance_pct
            verdicts.append((f"NDC ({ndc_year})", ok, f"{dev:+.1f}% vs manual"))
        else:
            verdicts.append((f"NDC ({ndc_year})", None, "data missing"))

        lts_val = series.get(str(lts_year))
        lts_manual = manual.get(str(lts_year))
        if lts_val is not None and lts_manual:
            dev = (lts_val - lts_manual) / abs(lts_manual) * 100
            ok = abs(dev) <= tolerance_pct
            verdicts.append((f"LTS ({lts_year})", ok, f"{dev:+.1f}% vs manual"))
        else:
            verdicts.append((f"LTS ({lts_year})", None, "data missing"))

        post_lts_years = [y for y in milestones if y > lts_year and str(y) in series]
        runaway = False
        if post_lts_years:
            post_lts_min = min(series[str(y)] for y in post_lts_years)
            if runaway_threshold is not None and post_lts_min < runaway_threshold:
                runaway = True
        verdicts.append((
            "Post-LTS stability",
            not runaway,
            f"min={post_lts_min:.0f}" if post_lts_years else "no data",
        ))

        overall = all(v[1] for v in verdicts if v[1] is not None)
        status = "PASS" if overall else "FAIL"
        print(f"\nalpha={a}: {status}")
        for label, ok, detail in verdicts:
            mark = "OK  " if ok else ("?   " if ok is None else "FAIL")
            print(f"    [{mark}] {label}: {detail}")


def fit_trajectory_alpha(series: dict[str, float], t_ndc: int, t_lts: int) -> float | None:
    """Best-fit alpha for E(t) = E_NDC - (E_NDC - E_LTS) * ((t-t_NDC)/(t_LTS-t_NDC))^alpha
    against the actual emissions series between t_ndc and t_lts (inclusive),
    via a 1D grid + golden-section-style refinement on log-sum-squared-error.
    Returns None if E_NDC <= E_LTS (no decline to fit) or data is missing.
    """
    import math

    e_ndc = series.get(str(t_ndc))
    e_lts = series.get(str(t_lts))
    if e_ndc is None or e_lts is None or e_ndc <= e_lts:
        return None

    span = t_lts - t_ndc
    points = []
    for y_str, val in series.items():
        y = int(y_str)
        if t_ndc < y < t_lts:
            t = (y - t_ndc) / span
            points.append((t, val))
    if not points:
        return None

    def sse(alpha: float) -> float:
        total = 0.0
        for t, val in points:
            pred = e_ndc - (e_ndc - e_lts) * (t ** alpha)
            total += (pred - val) ** 2
        return total

    # coarse grid search over a wide alpha range, then refine
    best_alpha, best_sse = None, math.inf
    grid = [round(0.05 * i, 2) for i in range(1, 121)]  # 0.05 .. 6.0
    for a in grid:
        s = sse(a)
        if s < best_sse:
            best_sse, best_alpha = s, a

    # local refinement around the best grid point
    lo, hi = max(0.01, best_alpha - 0.05), best_alpha + 0.05
    for _ in range(40):
        m1 = lo + (hi - lo) / 3
        m2 = hi - (hi - lo) / 3
        if sse(m1) < sse(m2):
            hi = m2
        else:
            lo = m1
    return (lo + hi) / 2


def classify_alpha(alpha: float, linear_band: float = 0.1) -> str:
    if alpha < 1 - linear_band:
        return "concave"
    if alpha > 1 + linear_band:
        return "convex"
    return "linear"


def check_shape(
    alpha_series: dict[float, dict[str, float]],
    ndc_year: int = NDC_YEAR,
    lts_year: int = LTS_YEAR,
) -> None:
    print(f"\n=== Emissions trajectory shape, {ndc_year}->{lts_year} (price-alpha vs. resulting-emissions-alpha) ===")
    print(f"{'price alpha':>14}{'emissions alpha':>18}{'shape':>12}")
    for a in sorted(alpha_series):
        fitted = fit_trajectory_alpha(alpha_series[a], ndc_year, lts_year)
        if fitted is None:
            print(f"{a:>14}{'n/a':>18}{'n/a':>12}")
            continue
        shape = classify_alpha(fitted)
        print(f"{a:>14}{fitted:>18.2f}{shape:>12}")

    print(
        "\nNote: price-alpha is the exponent used to *design* the carbon price path; "
        "emissions-alpha is the best-fit exponent of the *resulting* emissions path "
        "using the same E(t)=E_NDC-(E_NDC-E_LTS)*((t-t_NDC)/(t_LTS-t_NDC))^alpha form. "
        "They need not match -- emissions respond to price through the model's "
        "abatement-cost curves, not the price shape alone."
    )


def check_shape_by_region(
    discovered: dict[float, Path],
    variable: str = VARIABLE,
    ndc_year: int = NDC_YEAR,
    lts_year: int = LTS_YEAR,
    regions: list[str] | None = None,
) -> None:
    """Fit emissions-alpha per region per price-alpha run, to see whether the
    (lack of) shape transfer found at World level holds region-by-region, or
    whether some regions respond more convexly/concavely than others."""
    per_alpha_regions: dict[float, dict[str, dict[str, float]]] = {}
    all_regions: set[str] = set()
    for alpha, mif_path in sorted(discovered.items()):
        data = parse_mif_all_regions(mif_path, variable)
        per_alpha_regions[alpha] = data
        all_regions.update(data.keys())

    if regions:
        region_list = sorted(regions)
    else:
        region_list = sorted(all_regions - {"World"} - EU27_REGIONS)
    alphas = sorted(discovered)

    print(f"\n=== Per-region emissions-alpha fit, NDC={ndc_year}, LTS=per-region (default {lts_year}) ===")
    print("(EU27 member states excluded -- see the aggregated 'EU' row instead)")
    header = f"{'region':>8}{'lts_year':>10}"
    for a in alphas:
        header += f"{'price a=' + str(a):>14}"
    print(header)
    print("-" * len(header))
    for region in region_list:
        region_lts = REGION_LTS_YEAR.get(region, lts_year)
        row = f"{region:>8}{region_lts:>10}"
        for a in alphas:
            series = per_alpha_regions.get(a, {}).get(region)
            fitted = fit_trajectory_alpha(series, ndc_year, region_lts) if series else None
            row += f"{fitted:>14.2f}" if fitted is not None else f"{'n/a':>14}"
        print(row)

    print(
        "\nNote: blank/n/a means that region's emissions did not decline "
        "between its NDC and LTS years in that run (no curve to fit -- e.g. "
        "SSA emissions rise rather than decline in all runs), or the "
        "region/variable was missing from the .mif. LTS years follow the "
        "scenario protocol: 2050 by default, 2060 for CHA/REF, 2070 for IND/SSA."
    )


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--runs-dir", default=str(RUNS_DIR), help="Directory containing run folders (default: runs/)")
    p.add_argument("--manual-run", default=str(DEFAULT_MANUAL_RUN), help="Run folder holding the manual NDC/LTS reference (reads its reporting.mif by folder identity)")
    p.add_argument("--manual-csv", default=None, help="Fallback: a standalone CSV/mif file holding the manual reference scenario (overrides --manual-run if given)")
    p.add_argument("--manual-scenario", default=DEFAULT_MANUAL_SCENARIO, help="Scenario name to look up when using --manual-csv")
    p.add_argument("--region", default=REGION, help=f"Region to compare (default: {REGION})")
    p.add_argument("--variable", default=VARIABLE, help=f"Variable to compare (default: {VARIABLE})")
    p.add_argument("--alphas", nargs="+", type=float, default=None, help="Restrict comparison to these alpha values (default: all discovered)")
    p.add_argument("--years", nargs="+", type=int, default=None, help="Milestone years to show (default: a standard set)")
    p.add_argument("--check-protocol", action="store_true", help="Report PASS/FAIL on whether each alpha run fulfills the NDC/LTS protocol (vs. the manual run)")
    p.add_argument("--check-shape", action="store_true", help="Classify the curvature (concave/linear/convex) of each alpha run's resulting emissions trajectory between NDC and LTS years")
    p.add_argument("--check-shape-by-region", action="store_true", help="Same as --check-shape but fit a separate emissions-alpha per region instead of just World")
    p.add_argument("--shape-regions", nargs="+", default=None, help="Restrict --check-shape-by-region to these region codes (default: all regions found)")
    p.add_argument("--ndc-year", type=int, default=NDC_YEAR, help=f"NDC checkpoint year (default: {NDC_YEAR})")
    p.add_argument("--lts-year", type=int, default=LTS_YEAR, help=f"LTS checkpoint year (default: {LTS_YEAR})")
    p.add_argument("--tolerance-pct", type=float, default=PROTOCOL_TOLERANCE_PCT, help=f"Allowed deviation from manual at checkpoints (default: {PROTOCOL_TOLERANCE_PCT}%%)")
    args = p.parse_args(argv)

    runs_dir = Path(args.runs_dir)
    discovered = discover_alpha_runs(runs_dir)
    if args.alphas is not None:
        discovered = {a: pth for a, pth in discovered.items() if a in args.alphas}

    if not discovered:
        print(f"ERROR: no alpha run folders found under {runs_dir} matching 'COMTD_SSP2_NDC_a<ALPHA>_LTS_<timestamp>'.", file=sys.stderr)
        sys.exit(1)

    if args.manual_csv:
        manual_csv = Path(args.manual_csv)
        if not manual_csv.exists():
            print(f"ERROR: manual reference file not found: {manual_csv}", file=sys.stderr)
            sys.exit(1)
        manual = load_manual_series(manual_csv, args.manual_scenario, args.region, args.variable)
        manual_label = f"{manual_csv.name} (scenario={args.manual_scenario})"
    else:
        manual_run = Path(args.manual_run)
        manual_mif = manual_run / "reporting.mif"
        if not manual_mif.exists():
            print(f"ERROR: manual reference run not found: {manual_mif}", file=sys.stderr)
            sys.exit(1)
        manual = parse_mif_row(manual_mif, args.region, args.variable)
        if manual is None:
            print(f"ERROR: variable '{args.variable}' for region '{args.region}' not found in {manual_mif}", file=sys.stderr)
            sys.exit(1)
        manual_label = manual_run.name

    print(f"Manual reference (fulfills NDC/LTS targets): {manual_label}")

    alpha_series = {}
    print("Discovered alpha runs (folder name is the trusted source -- in-file scenario labels may be stale):")
    for alpha, mif_path in sorted(discovered.items()):
        series = parse_mif_row(mif_path, args.region, args.variable)
        if series is None:
            print(f"  alpha={alpha}: WARNING - variable not found in {mif_path}", file=sys.stderr)
            continue
        alpha_series[alpha] = series
        print(f"  alpha={alpha}: {mif_path.parent.name}")

    milestones = args.years if args.years else DEFAULT_MILESTONES
    print_comparison(manual, alpha_series, milestones)

    if args.check_protocol:
        check_protocol(
            manual, alpha_series, milestones,
            ndc_year=args.ndc_year, lts_year=args.lts_year,
            tolerance_pct=args.tolerance_pct,
        )

    if args.check_shape:
        check_shape(alpha_series, ndc_year=args.ndc_year, lts_year=args.lts_year)

    if args.check_shape_by_region:
        check_shape_by_region(
            discovered, variable=args.variable,
            ndc_year=args.ndc_year, lts_year=args.lts_year,
            regions=args.shape_regions,
        )


if __name__ == "__main__":
    main()