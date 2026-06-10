#!/usr/bin/env python3
"""
Extract the Current-Trends (HD_D2) capacity trajectory to be used as the
supply-side upper bound for the Derailment (D1) scenarios (IAM-COMPACT H&D,
protocol column D).

What it does
------------
1. Runs `gdxdump` on the HD_D2 run's `blabla.gdx` to pull the model variable
   `V04NewCapElec(allCy, PGALL, YTIME)` (yearly capacity additions, GW/yr) in long
   CSV form. (V04NewCapElec is in the full blabla.gdx, not the curated outputData.gdx.)
2. Keeps only the disruption-hit technologies (hydro + thermo), i.e. exactly the
   set `CFTECHMAP12` already defined in modules/12_ClimateImpact/iam_compact/sets.gms:
       PGLHYD, PGSHYD,
       ATHCOAL, ATHLGN, ATHGAS, ATHOIL, ATHBMSWAS,
       ATHCOALCCS, ATHLGNCCS, ATHGASCCS, ATHBMSCCS,
       PGANUC
3. Pivots to the wide layout GAMS `table` expects (same format as the existing
   parameters/iExtraCoolingElectricityDemand_*.csv): label columns first
   ("allCy","PGALL") then one column per year, header quoted.
4. Writes parameters/i12CapBoundD2.csv.

Per-tech V04NewCapElec.L (additions) is exported. module 12 imposes a BY-TYPE
(by-fuel) cap: in preloop.gms it sets V04NewCapElec.UP for EACH shocked tech to its
own HD_D2 additions path (protocol's "Capacity Additions ... by fuel"). No
reallocation within the shocked set -- each fuel held to its own Current-Trends
path.

WHY PAIRED WITH A RENEWABLE BOOST: any D2-level cap (by-type or aggregate, stock or
additions) on its own makes HD_D1 ~fully infeasible -- D1 needs more shocked-tech
capacity than D2 (extra cooling demand + reduced CF), and OPEN-PROM has a hard
demand balance. The cap is therefore paired with the Part 5 renewable maturity
boost (module 12 input.gms), which opens enough renewable headroom inside the
CF-cut window to close the energy balance.

Usage
-----
    python3 scripts/tools/extract_i12CapBoundD2.py \
        --run runs/HD_D2_2026-06-09_13-16-48 \
        [--gams /Library/Frameworks/GAMS.framework/Resources] \
        [--out parameters/i12CapBoundD2.csv]
"""

import argparse
import csv
import os
import subprocess
import sys

# Disruption-hit technologies = CFTECHMAP12 (hydro + thermo). Bound only these.
SHOCKED_TECHS = [
    "PGLHYD", "PGSHYD",
    "ATHCOAL", "ATHLGN", "ATHGAS", "ATHOIL", "ATHBMSWAS",
    "ATHCOALCCS", "ATHLGNCCS", "ATHGASCCS", "ATHBMSCCS",
    "PGANUC",
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", required=True,
                    help="HD_D2 run folder containing blabla.gdx")
    ap.add_argument("--gams", default="/Library/Frameworks/GAMS.framework/Resources",
                    help="GAMS Resources dir (where gdxdump lives)")
    ap.add_argument("--out", default="parameters/i12CapBoundD2.csv",
                    help="Output table CSV path")
    args = ap.parse_args()

    gdx = os.path.join(args.run, "blabla.gdx")
    gdxdump = os.path.join(args.gams, "gdxdump")
    if not os.path.isfile(gdx):
        sys.exit(f"ERROR: gdx not found: {gdx}")
    if not os.path.isfile(gdxdump):
        sys.exit(f"ERROR: gdxdump not found: {gdxdump}")

    # 1. dump VmCapElec long form: allCy, PGALL, ytime, Val
    raw = subprocess.run(
        [gdxdump, gdx, "symb=V04NewCapElec", "format=csv"],
        capture_output=True, text=True, check=True,
    ).stdout.splitlines()

    rdr = csv.reader(raw)
    header = next(rdr)  # "allCy","PGALL","ytime","Val"
    shocked = set(SHOCKED_TECHS)
    # data[(region, tech)][year] = value
    data, regions, years = {}, set(), set()
    for row in rdr:
        if len(row) < 4:
            continue
        cy, tech, yr, val = row[0], row[1], row[2], row[3]
        if tech not in shocked:
            continue
        data.setdefault((cy, tech), {})[yr] = float(val)
        regions.add(cy)
        years.add(int(yr))

    years = [str(y) for y in sorted(years)]
    regions = sorted(regions)

    # 2. write wide table, full (region x shocked-tech) grid, 0.0 where absent.
    #    A full grid keeps the GAMS table rectangular; absent combos = 0 bound,
    #    which correctly forbids D1 from building a tech D2 never built.
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    n = 0
    with open(args.out, "w", newline="") as f:
        w = csv.writer(f, quoting=csv.QUOTE_NONNUMERIC)
        w.writerow(["allCy", "PGALL"] + years)
        for cy in regions:
            for tech in SHOCKED_TECHS:
                cells = data.get((cy, tech), {})
                w.writerow([cy, tech] + [cells.get(y, 0.0) for y in years])
                n += 1

    print(f"wrote {args.out}: {n} rows ({len(regions)} regions x "
          f"{len(SHOCKED_TECHS)} techs), years {years[0]}-{years[-1]}")


if __name__ == "__main__":
    main()
