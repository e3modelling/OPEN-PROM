"""
One-off: copy the exogCV_1_5C price values (from a reference run's iEnvPolicies.csv)
into the exogCV_NPi row for every region in the working data/iEnvPolicies.csv.

This isolates whether the *exact* price path used in DAILYAG_1p5C_2026-06-15_19-21-14
(which produced concave World emissions, alpha~0.70) reproduces that concavity when
run under fScenario=1 (exogCV_NPi) instead of fScenario=2 (exogCV_1_5C) -- ruling out
any policy-row-specific model branching as the actual cause of the concavity.

Usage
-----
python scripts/copy_1_5c_into_npi.py \
    --source-csv "runs/DAILYAG_1p5C_2026-06-15_19-21-14/data/iEnvPolicies.csv" \
    --preview
"""

import argparse
import csv
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
DATA_FILE = REPO_ROOT / "data" / "iEnvPolicies.csv"


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--source-csv", required=True, help="iEnvPolicies.csv to read exogCV_1_5C rows from")
    p.add_argument("--csv", default=str(DATA_FILE), help="Target iEnvPolicies.csv to update exogCV_NPi rows in")
    p.add_argument("--preview", action="store_true")
    args = p.parse_args(argv)

    with open(args.source_csv, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        src_header = next(reader)
        src_rows = list(reader)

    source_values = {}
    for row in src_rows:
        if row[1] == "exogCV_1_5C":
            source_values[row[0]] = row[2:]

    target_path = Path(args.csv)
    with open(target_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        rows = list(reader)

    updated = []
    for row in rows:
        if row[1] == "exogCV_NPi" and row[0] in source_values:
            old_2030 = row[22] if len(row) > 22 else None
            row[2:] = source_values[row[0]]
            new_2030 = row[22]
            updated.append((row[0], old_2030, new_2030))

    print(f"{'region':>8}{'old_2030':>12}{'new_2030':>12}")
    for region, old, new in updated:
        print(f"{region:>8}{old:>12}{new:>12}")

    if args.preview:
        print("\n[Preview only -- CSV not modified]")
        return

    with open(target_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"\nUpdated {len(updated)} exogCV_NPi rows in {target_path}")


if __name__ == "__main__":
    main()