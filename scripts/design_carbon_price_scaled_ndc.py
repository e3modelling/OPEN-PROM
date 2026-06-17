"""
One-off: build a concave (alpha<1) price path per region where the 2030 (NDC)
anchor is scaled up by a fixed factor relative to each region's existing
2030 value, while keeping the 2050 (LTS) anchor unchanged -- to test whether
raising the early price *level* (not just the curve exponent) pushes the
resulting emissions trajectory toward emissions-alpha ~ 0.3 (strongly concave).

Usage
-----
python scripts/design_carbon_price_scaled_ndc.py --policy exogCV_NPi --regions ALL \
    --baseline-csv runs/COMTD_SSP2_NDC_a0.3_LTS_2026-06-16_12-20-19/data/iEnvPolicies.csv \
    --ndc-year 2030 --lts-year 2050 --scale 5 --alpha 0.3 --preview
"""

import argparse
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from design_carbon_price import (  # noqa: E402
    YEARS, DATA_FILE, REGION_GROUPS, find_year_col,
    read_existing_path, apply_path, _interp_trajectory, apply_growth_tail,
)


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--policy", required=True, choices=["exogCV_NPi", "exogCV_Calib", "exogCV_1_5C", "exogCV_2C"])
    p.add_argument("--regions", nargs="+", required=True)
    p.add_argument("--baseline-csv", required=True, help="CSV to read each region's existing NDC/LTS anchor values from")
    p.add_argument("--ndc-year", type=int, default=2030)
    p.add_argument("--lts-year", type=int, default=2050)
    p.add_argument("--scale", type=float, default=5.0, help="Multiply each region's existing NDC-year price by this factor")
    p.add_argument("--max-ndc-frac", type=float, default=0.9, help="Cap the scaled NDC anchor at this fraction of the LTS anchor, so the price never inverts (default: 0.9)")
    p.add_argument("--lts-scale", type=float, default=None, help="If set, override the LTS anchor as this multiple of the (post-scale) NDC anchor instead of using the baseline LTS value -- use to compress price growth between NDC and LTS")
    p.add_argument("--alpha", type=float, default=0.3)
    p.add_argument("--flat-after", type=int, default=None)
    p.add_argument("--grow-after", nargs=2, type=float, default=None, metavar=("YEAR", "RATE_PCT"), help="After YEAR, compound the price by RATE_PCT %% per year through 2100 instead of flattening")
    p.add_argument("--preview", action="store_true")
    p.add_argument("--csv", default=str(DATA_FILE))
    args = p.parse_args(argv)

    regions = []
    for token in args.regions:
        if token in REGION_GROUPS:
            regions.extend(REGION_GROUPS[token])
        else:
            regions.append(token)
    regions = list(dict.fromkeys(regions))

    baseline_path = Path(args.baseline_csv)
    with open(baseline_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        baseline_header = next(reader)
        baseline_rows = [row for row in reader]

    target_path = Path(args.csv)
    with open(target_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = [row for row in reader]

    print(f"Policy: {args.policy} | Scale factor on {args.ndc_year} anchor: {args.scale}x | alpha={args.alpha}")
    print(f"{'region':>8}{'ndc_old':>12}{'ndc_new':>12}{'lts':>12}")

    all_updated = []
    for region in regions:
        try:
            existing = read_existing_path(baseline_header, baseline_rows, args.policy, region)
        except ValueError as e:
            print(f"  WARNING: {e}", file=sys.stderr)
            continue
        ndc_old = existing[args.ndc_year]
        lts_old = existing[args.lts_year]
        ndc_new = min(ndc_old * args.scale, lts_old * args.max_ndc_frac)
        capped = " (capped)" if ndc_new < ndc_old * args.scale else ""
        lts_val = ndc_new * args.lts_scale if args.lts_scale is not None else lts_old
        print(f"{region:>8}{ndc_old:>12.2f}{ndc_new:>12.2f}{lts_val:>12.2f}{capped}")

        anchors = {args.ndc_year: ndc_new, args.lts_year: lts_val}
        path = _interp_trajectory(anchors, args.flat_after, args.alpha)
        if args.grow_after is not None:
            gy, rate = int(args.grow_after[0]), args.grow_after[1]
            path = apply_growth_tail(path, gy, rate)

        if args.preview:
            continue

        rows, updated = apply_path(header, rows, args.policy, [region], path, from_year=args.ndc_year)
        all_updated.extend(updated)

    if args.preview:
        print("\n[Preview only -- CSV not modified]")
        return

    with open(target_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"\nUpdated {len(all_updated)} region/policy rows in {target_path}")


if __name__ == "__main__":
    main()