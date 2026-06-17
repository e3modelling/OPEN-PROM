"""
Carbon Price Path Designer for iEnvPolicies.csv
================================================
Design carbon price paths and write them back to data/iEnvPolicies.csv.

Usage examples
--------------
# Linear ramp from 25 in 2025 to 165 in 2040, flat thereafter, for all EU regions
python scripts/design_carbon_price.py \
    --policy exogCV_NPi \
    --regions AUT BEL BGR CZE DEU DNK ESP EST FIN FRA GBR GRC HRV HUN IRL ITA LTU LUX LVA MLT NLD POL PRT ROU SVK SVN SWE \
    --shape linear \
    --anchor 2025 25 --anchor 2040 165 \
    --flat-after 2040

# Exponential growth for a custom scenario
python scripts/design_carbon_price.py \
    --policy exogCV_2C \
    --regions DEU FRA \
    --shape exponential \
    --anchor 2025 30 --anchor 2050 200

# Reach 165 by 2050, then grow 2.5% per year through 2100
python scripts/design_carbon_price.py \
    --policy exogCV_NPi \
    --regions EU27 \
    --shape linear \
    --anchor 2025 84 --anchor 2050 165 \
    --grow-after 2050 2.5

# Preview without writing
python scripts/design_carbon_price.py \
    --policy exogCV_NPi \
    --regions AUT \
    --shape linear \
    --anchor 2025 25 --anchor 2050 150 \
    --preview
"""

import argparse
import csv
import sys
from pathlib import Path


YEARS = list(range(2010, 2101))
DATA_FILE = Path(__file__).parent.parent / "data" / "iEnvPolicies.csv"


# ---------------------------------------------------------------------------
# Path shapes
# ---------------------------------------------------------------------------

def _interp_linear(anchors: dict[int, float], flat_after: int | None) -> dict[int, float]:
    """Piecewise-linear interpolation between anchor points."""
    sorted_years = sorted(anchors)
    result = {}
    for y in YEARS:
        if flat_after and y > flat_after:
            result[y] = anchors.get(flat_after, anchors[sorted_years[-1]])
            continue
        if y <= sorted_years[0]:
            result[y] = anchors[sorted_years[0]]
        elif y >= sorted_years[-1]:
            result[y] = anchors[sorted_years[-1]]
        else:
            for i in range(len(sorted_years) - 1):
                y0, y1 = sorted_years[i], sorted_years[i + 1]
                if y0 <= y <= y1:
                    t = (y - y0) / (y1 - y0)
                    result[y] = anchors[y0] + t * (anchors[y1] - anchors[y0])
                    break
    return result


def _interp_exponential(anchors: dict[int, float], flat_after: int | None) -> dict[int, float]:
    """Piecewise-exponential growth between anchor points."""
    import math
    sorted_years = sorted(anchors)
    result = {}
    for y in YEARS:
        if flat_after and y > flat_after:
            result[y] = anchors.get(flat_after, anchors[sorted_years[-1]])
            continue
        if y <= sorted_years[0]:
            result[y] = anchors[sorted_years[0]]
        elif y >= sorted_years[-1]:
            result[y] = anchors[sorted_years[-1]]
        else:
            for i in range(len(sorted_years) - 1):
                y0, y1 = sorted_years[i], sorted_years[i + 1]
                if y0 <= y <= y1:
                    v0, v1 = anchors[y0], anchors[y1]
                    if v0 <= 0 or v1 <= 0:
                        # Fall back to linear for zero/negative anchors
                        t = (y - y0) / (y1 - y0)
                        result[y] = v0 + t * (v1 - v0)
                    else:
                        t = (y - y0) / (y1 - y0)
                        result[y] = v0 * math.exp(t * math.log(v1 / v0))
                    break
    return result


def _interp_ssplike(anchors: dict[int, float], flat_after: int | None) -> dict[int, float]:
    """S-curve (logistic) between anchor points — slow start, fast middle, plateau."""
    import math
    sorted_years = sorted(anchors)
    result = {}
    for y in YEARS:
        if flat_after and y > flat_after:
            result[y] = anchors.get(flat_after, anchors[sorted_years[-1]])
            continue
        if y <= sorted_years[0]:
            result[y] = anchors[sorted_years[0]]
        elif y >= sorted_years[-1]:
            result[y] = anchors[sorted_years[-1]]
        else:
            for i in range(len(sorted_years) - 1):
                y0, y1 = sorted_years[i], sorted_years[i + 1]
                if y0 <= y <= y1:
                    t = (y - y0) / (y1 - y0)
                    # Smooth step (cubic S-curve)
                    s = t * t * (3 - 2 * t)
                    result[y] = anchors[y0] + s * (anchors[y1] - anchors[y0])
                    break
    return result


def _interp_trajectory(anchors: dict[int, float], flat_after: int | None, alpha: float = 1.0) -> dict[int, float]:
    """NDC→LTS trajectory: E(t) = E_NDC - (E_NDC - E_LTS) * ((t - t_NDC) / (t_LTS - t_NDC))^alpha.

    Requires exactly two anchors: the NDC point and the LTS point.
    alpha < 1 : concave  (fast early reduction, slows down)
    alpha = 1 : linear
    alpha > 1 : convex   (slow start, accelerates toward LTS)
    """
    if len(anchors) != 2:
        raise ValueError("Shape 'trajectory' requires exactly two --anchor points: the NDC year/price and the LTS year/price.")
    t_ndc, t_lts = sorted(anchors)
    e_ndc, e_lts = anchors[t_ndc], anchors[t_lts]
    span = t_lts - t_ndc
    result = {}
    for y in YEARS:
        if y <= t_ndc:
            result[y] = e_ndc
        elif y >= t_lts:
            result[y] = e_lts if not (flat_after and y > flat_after) else e_lts
        else:
            if flat_after and y > flat_after:
                result[y] = anchors.get(flat_after, e_lts)
            else:
                t = (y - t_ndc) / span
                result[y] = e_ndc - (e_ndc - e_lts) * (t ** alpha)
    return result


SHAPES = {
    "linear": _interp_linear,
    "exponential": _interp_exponential,
    "scurve": _interp_ssplike,
    "trajectory": _interp_trajectory,
}


# ---------------------------------------------------------------------------
# CSV read / write
# ---------------------------------------------------------------------------

def read_csv(path: Path) -> tuple[list[str], list[list[str]]]:
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = list(reader)
    return header, rows


def write_csv(path: Path, header: list[str], rows: list[list[str]]) -> None:
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)


def find_year_col(header: list[str], year: int) -> int:
    try:
        return header.index(str(year))
    except ValueError:
        raise ValueError(f"Year {year} not found in CSV header.")


# ---------------------------------------------------------------------------
# Main logic
# ---------------------------------------------------------------------------

def apply_growth_tail(path: dict[int, float], from_year: int, annual_rate_pct: float) -> dict[int, float]:
    """Compound the price by annual_rate_pct % every year starting from from_year+1."""
    rate = annual_rate_pct / 100.0
    if from_year not in path:
        raise ValueError(f"--grow-after year {from_year} is not in the computed path.")
    base = path[from_year]
    for y in YEARS:
        if y > from_year:
            base = base * (1 + rate)
            path[y] = base
    return path


def build_path(shape: str, anchors: dict[int, float], flat_after: int | None, alpha: float = 1.0) -> dict[int, float]:
    if shape not in SHAPES:
        raise ValueError(f"Unknown shape '{shape}'. Choose from: {', '.join(SHAPES)}")
    if shape == "trajectory":
        return _interp_trajectory(anchors, flat_after, alpha)
    return SHAPES[shape](anchors, flat_after)


def read_existing_path(
    header: list[str],
    rows: list[list[str]],
    policy: str,
    region: str,
) -> dict[int, float]:
    """Read current year→price values for a single region/policy row from the CSV."""
    for row in rows:
        if row[0] == region and row[1] == policy:
            result = {}
            for y in YEARS:
                col = find_year_col(header, y)
                val = row[col]
                result[y] = float(val) if val not in ("NA", "", "na") else 0.0
            return result
    raise ValueError(f"No row found for region={region}, policy={policy} in CSV.")


def apply_path(
    header: list[str],
    rows: list[list[str]],
    policy: str,
    regions: list[str],
    path: dict[int, float],
    from_year: int | None = None,
) -> tuple[list[list[str]], list[str]]:
    updated = []
    for region in regions:
        matched = False
        for row in rows:
            if row[0] == region and row[1] == policy:
                matched = True
                for year, value in path.items():
                    if from_year is not None and year < from_year:
                        continue
                    col = find_year_col(header, year)
                    row[col] = str(round(value, 6))
                updated.append(f"{region},{policy}")
                break
        if not matched:
            print(f"  WARNING: no row found for region={region}, policy={policy} — skipping.", file=sys.stderr)
    return rows, updated


def preview_path(regions: list[str], policy: str, path: dict[int, float], milestone_years: list[int] | None = None) -> None:
    if milestone_years is None:
        milestone_years = [2025, 2030, 2035, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 2100]
    milestone_years = sorted(set(y for y in milestone_years if y in path))
    print(f"\nPolicy: {policy}  |  Regions: {', '.join(regions)}")
    print("-" * (14 * len(milestone_years) + 4))
    print("  Year  |  " + "  ".join(f"{y:>8}" for y in milestone_years))
    print("  Price |  " + "  ".join(f"{path[y]:>8.2f}" for y in milestone_years))
    print("-" * (14 * len(milestone_years) + 4))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Design carbon price paths and update iEnvPolicies.csv",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument(
        "--policy", required=True,
        choices=["exogCV_NPi", "exogCV_Calib", "exogCV_1_5C", "exogCV_2C"],
        help="Policy row to update (e.g. exogCV_NPi)",
    )
    p.add_argument(
        "--regions", nargs="+", required=True,
        help="Space-separated region codes (e.g. AUT BEL DEU), 'ALL' for every region, or 'EU27' for all 27 EU member states",
    )
    p.add_argument(
        "--shape", default="linear", choices=list(SHAPES),
        help="Interpolation shape between anchor points (default: linear)",
    )
    p.add_argument(
        "--anchor", nargs=2, action="append", metavar=("YEAR", "PRICE"),
        default=None,
        help="year/price anchor pair; repeat for multiple anchors (e.g. --anchor 2025 25 --anchor 2050 150). "
             "Optional when --grow-after is used alone — the script reads existing CSV values as the base.",
    )
    p.add_argument(
        "--flat-after", type=int, default=None, metavar="YEAR",
        help="Hold the price flat at the last anchor value after this year",
    )
    p.add_argument(
        "--alpha", type=float, default=1.0,
        help="Shape exponent for --shape trajectory. "
             "α<1 concave (fast early, slows later), α=1 linear, α>1 convex (slow start, accelerates). "
             "Suggested values: {0.1, 0.3, 0.5, 0.7, 1, 1.3, 1.5, 2, 3}. Ignored for other shapes.",
    )
    p.add_argument(
        "--grow-after", nargs=2, default=None, metavar=("YEAR", "RATE_PCT"),
        help="After YEAR, compound the price by RATE_PCT %% per year through 2100 "
             "(e.g. --grow-after 2050 2.5 raises price 2.5%% annually from 2051 onward). "
             "Cannot be combined with --flat-after.",
    )
    p.add_argument(
        "--preview", action="store_true",
        help="Print a preview table but do NOT modify the CSV",
    )
    p.add_argument(
        "--csv", default=str(DATA_FILE),
        help=f"Path to iEnvPolicies.csv (default: {DATA_FILE})",
    )
    return p.parse_args(argv)


ALL_REGIONS = [
    "LAM", "OAS", "SSA", "NEU", "MEA", "REF", "CAZ",
    "AUT", "BEL", "BGR", "CHA", "CYP", "CZE", "DEU", "DNK", "ESP", "EST",
    "FIN", "FRA", "GBR", "GRC", "HRV", "HUN", "IND", "IRL", "ITA", "JPN",
    "LTU", "LUX", "LVA", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN",
    "SWE", "USA",
]

EU27_REGIONS = [
    "AUT", "BEL", "BGR", "CYP", "CZE", "DEU", "DNK", "ESP", "EST",
    "FIN", "FRA", "GRC", "HRV", "HUN", "IRL", "ITA", "LTU", "LUX",
    "LVA", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "SWE",
]

REGION_GROUPS = {
    "ALL": ALL_REGIONS,
    "EU27": EU27_REGIONS,
}


def main(argv=None):
    args = parse_args(argv)

    regions = []
    for token in args.regions:
        if token in REGION_GROUPS:
            regions.extend(REGION_GROUPS[token])
        else:
            regions.append(token)
    regions = list(dict.fromkeys(regions))  # deduplicate, preserve order

    # Validate --grow-after
    grow_after = None
    if args.grow_after is not None:
        if args.flat_after is not None:
            print("ERROR: --grow-after and --flat-after are mutually exclusive.", file=sys.stderr)
            sys.exit(1)
        try:
            grow_after = (int(args.grow_after[0]), float(args.grow_after[1]))
        except ValueError:
            print("ERROR: --grow-after expects an integer year and a numeric rate (e.g. --grow-after 2035 2).", file=sys.stderr)
            sys.exit(1)

    # Require --anchor unless grow-after-only mode
    grow_only = (args.anchor is None and grow_after is not None)
    if not grow_only and args.anchor is None:
        print("ERROR: --anchor is required unless --grow-after is used alone.", file=sys.stderr)
        sys.exit(1)

    csv_path = Path(args.csv)
    if not csv_path.exists():
        print(f"ERROR: CSV file not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    header, rows = read_csv(csv_path)

    if grow_only:
        # Apply compound growth independently per region, starting from existing CSV values
        gy, rate = grow_after
        milestone_years = [gy, 2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100]
        all_updated = []
        for region in regions:
            try:
                path = read_existing_path(header, rows, args.policy, region)
            except ValueError as e:
                print(f"  WARNING: {e} — skipping.", file=sys.stderr)
                continue
            path = apply_growth_tail(path, gy, rate)
            if args.preview:
                preview_path([region], args.policy, path, milestone_years=milestone_years)
            else:
                rows, updated = apply_path(header, rows, args.policy, [region], path, from_year=gy)
                all_updated.extend(updated)
        if args.preview:
            print("\n[Preview only — CSV not modified]")
        else:
            write_csv(csv_path, header, rows)
            print(f"\nUpdated {len(all_updated)} row(s) in {csv_path}:")
            for r in all_updated:
                print(f"  {r}")
            print("Done.")
    else:
        # Normal mode: build path from anchors, apply to all regions uniformly
        anchors = {}
        for year_str, price_str in args.anchor:
            try:
                y, v = int(year_str), float(price_str)
            except ValueError:
                print(f"ERROR: invalid anchor '{year_str} {price_str}' — expected integer year and numeric price.", file=sys.stderr)
                sys.exit(1)
            if y not in YEARS:
                print(f"ERROR: year {y} out of range {YEARS[0]}–{YEARS[-1]}.", file=sys.stderr)
                sys.exit(1)
            anchors[y] = v

        if len(anchors) < 2:
            print("ERROR: at least two --anchor points are required.", file=sys.stderr)
            sys.exit(1)

        if args.alpha != 1.0 and args.shape != "trajectory":
            print(f"  WARNING: --alpha is only used with --shape trajectory; ignored for '{args.shape}'.", file=sys.stderr)

        path = build_path(args.shape, anchors, args.flat_after, alpha=args.alpha)

        if grow_after is not None:
            path = apply_growth_tail(path, grow_after[0], grow_after[1])

        milestone_years = sorted(anchors) + [2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100]
        if grow_after:
            milestone_years.append(grow_after[0])
        preview_path(regions, args.policy, path, milestone_years=milestone_years)

        if args.preview:
            print("\n[Preview only — CSV not modified]")
            return

        rows, updated = apply_path(header, rows, args.policy, regions, path, from_year=min(anchors))
        write_csv(csv_path, header, rows)
        print(f"\nUpdated {len(updated)} row(s) in {csv_path}:")
        for r in updated:
            print(f"  {r}")
        print("Done.")


if __name__ == "__main__":
    main()
