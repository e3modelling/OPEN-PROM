"""RIME degree-day maps -> OPEN-PROM input iClimDegDays.csv (climate feedback loop 1).

Reads the maps written by rimeMaps.py for one MAGICC run and produces the
degree-day ratios read by OPEN-PROM (i02ClimDD, switch --climFeedback=on):

  1. population-weighted degree days per OPEN-PROM region and RIME year: country
     polygons (Natural Earth) grouped with the OPEN-PROM region mapping (mrprom),
     fractional overlap with the map grid (small countries such as MLT or LUX are
     not lost), weighted by SSP2 gridded population of that year (area weights if
     no population file is given);
  2. annual values base-year..end-year: linear between RIME years, the first value
     held before it, the last valid value held after it (overshoot runs are
     emulated only until RIME's drawdown limit, see rimeMaps.py);
  3. ratio to the base year with a floored base and a cap (see degree_day_ratio);
  4. iClimDegDays.csv (header dummy,dummy,<years>; rows CDD,<REG> / HDD,<REG>), plus
     iClimDegDays_absolute.csv and iClimDegDays_diagnostics.png for reporting.

No HDD maps exist yet (the Climate Solutions Explorer data have cooling degree
days only): without --hdd-ind, HDD = 1 for all regions and years.
"""

import argparse
import os
import sys
import warnings

warnings.filterwarnings("ignore", category=FutureWarning)

import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402
import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rimeRegions import PopWeights, Regions, natural_earth, regional_by_year  # noqa: E402

CDD_IND = "sdd_c_24p0"      # RIME cooling degree days, 24 °C base
FLOOR = {"CDD": 50.0, "HDD": 100.0}  # °C·days: smallest base used in the ratio
CAP = 3.0                   # upper bound of the ratio
BASE_YEAR = 2023            # ratio = 1 (last historical year of OPEN-PROM)
END_YEAR = 2100


# =============================================================== time and ratio
def to_annual(df, base_year, end_year):
    """RIME years -> annual: linear in between, first value held before, last valid value held after."""
    years = np.arange(base_year, end_year + 1)
    rows = {}
    for reg, row in df.iterrows():
        s = row.dropna()
        rows[reg] = np.interp(years, s.index.astype(float), s.values) if len(s) else np.full(len(years), np.nan)
    return pd.DataFrame(rows, index=years).T


def degree_day_ratio(dd, base_year, floor, cap, label):
    """ratio(t) = min(cap, 1 + (DD(t) - DD(base)) / max(DD(base), floor)).

    Equals DD(t)/DD(base) wherever DD(base) >= floor, and is exactly 1 in the base
    year everywhere (no jump in OPEN-PROM's first projection year). Where the base
    is tiny, the absolute change is scaled by the floor. Prints where floor/cap act.
    """
    base = dd[base_year]
    ratio = 1 + dd.sub(base, axis=0).div(base.clip(lower=floor), axis=0)
    floored = base.index[base < floor]
    capped = ratio.index[(ratio > cap).any(axis=1)]
    if len(floored):
        print(f"[info] {label}: base floored at {floor:g} °C·days in "
              + ", ".join(f"{r} ({base[r]:.1f})" for r in floored))
    if len(capped):
        print(f"[info] {label}: ratio capped at {cap:g} in "
              + ", ".join(f"{r} (max {ratio.loc[r].max():.2f})" for r in capped))
    return ratio.clip(upper=cap)


# =============================================================== outputs
def write_gams_csv(path, ratios, regions, provenance):
    """GAMS $ondelim table: '*' comments, header 'dummy,dummy,<years>', rows 'HDD,REG,...' / 'CDD,REG,...'."""
    years = ratios["CDD"].columns
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.writelines(f"* {line}\n" for line in provenance)
        # OPEN-PROM/mrprom table layout: one "dummy" header field and one label column per row dimension
        fh.write("dummy,dummy," + ",".join(str(y) for y in years) + "\n")
        for label in ("HDD", "CDD"):
            for reg in regions:
                fh.write(f"{label},{reg}," + ",".join(f"{v:.5g}" for v in ratios[label].loc[reg, years]) + "\n")


def diagnostic_plot(path, ratios, title, cap, n_label=6):
    """Ratio over time per region (CDD, HDD); the regions with the largest change are labelled."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6), sharex=True)
    for ax, label in zip(axes, ("CDD", "HDD")):
        r = ratios[label]
        top = list((r.iloc[:, -1] - 1).abs().sort_values(ascending=False).index[:n_label])
        top = [t for t in top if abs(r.loc[t].iloc[-1] - 1) > 0]
        for reg in r.index:
            hi = reg in top
            ax.plot(r.columns, r.loc[reg], lw=2 if hi else 0.8, color=None if hi else "#B8BFCC",
                    label=reg if hi else None, zorder=3 if hi else 2)
        ax.axhline(1, color="#14213D", lw=0.8)
        if (r >= cap).any().any():
            ax.axhline(cap, color="#C1121F", lw=0.8, ls="--", label=f"cap {cap:g}")
        ax.set_title(f"{label} ratio to {r.columns[0]}" + ("" if top else " (neutral = 1)"), loc="left")
        ax.set_xlabel("Year")
        if ax.get_legend_handles_labels()[0]:
            ax.legend(frameon=False, fontsize=10)
    axes[0].set_ylabel("Degree-day ratio (–)")
    fig.suptitle(title, x=0.01, ha="left", fontweight="bold")
    fig.tight_layout()
    fig.savefig(path, dpi=200)
    plt.close(fig)


# =============================================================== MAIN
def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--maps-dir", required=True, help="folder with rime_maps_<indicator>.nc (from rimeMaps.py)")
    p.add_argument("--regionmapping", required=True, help="mrprom regionmappingOPDEV5.csv")
    p.add_argument("--natural-earth", required=True, help="Natural Earth countries zip, or a cache folder to download it to")
    p.add_argument("--pop-grid", default=None, help="SSP2 gridded population (ISIMIP, 0.5°); none -> area weights")
    p.add_argument("--out", required=True, help="output iClimDegDays.csv")
    p.add_argument("--cdd-ind", default=CDD_IND)
    p.add_argument("--hdd-ind", default=None, help="RIME HDD indicator (none -> HDD = 1)")
    p.add_argument("--floor-cdd", type=float, default=FLOOR["CDD"])
    p.add_argument("--floor-hdd", type=float, default=FLOOR["HDD"])
    p.add_argument("--cap", type=float, default=CAP)
    p.add_argument("--base-year", type=int, default=BASE_YEAR)
    p.add_argument("--end-year", type=int, default=END_YEAR)
    a = p.parse_args(argv)

    regions = Regions(a.regionmapping, natural_earth(a.natural_earth))
    maps = {lab: os.path.join(a.maps_dir, f"rime_maps_{ind}.nc") for lab, ind in (("CDD", a.cdd_ind), ("HDD", a.hdd_ind)) if ind}
    if not os.path.exists(maps["CDD"]):
        sys.exit(f"[error] no CDD maps: {maps['CDD']} (run rimeMaps.py first)")
    popw = PopWeights(a.pop_grid)
    if a.pop_grid is None:
        print("[warn] no population grid given -> area weights")
    print(f"[info] {len(regions.names)} OPEN-PROM regions, {popw.label}")
    regions_list = regions.names

    years = list(range(a.base_year, a.end_year + 1))
    ratios, absolute, notes, scen = {}, {}, [], ""
    for label, floor in (("CDD", a.floor_cdd), ("HDD", a.floor_hdd)):
        if label not in maps or not os.path.exists(maps[label]):
            print("[WARNING] " + "=" * 68)
            print(f"[WARNING] No HDD maps{' (' + maps[label] + ')' if label in maps else ''}: "
                  "HDD = 1 for all regions and years (no heating feedback).")
            print("[WARNING] " + "=" * 68)
            ratios[label] = pd.DataFrame(1.0, index=regions_list, columns=years)
            notes.append("HDD: no maps -> 1 (neutral)")
            continue
        by_year, attrs = regional_by_year(maps[label], a.cdd_ind if label == "CDD" else a.hdd_ind, regions, popw)
        scen = attrs.get("scenario", scen)
        last = int(by_year.columns[by_year.notna().any()].max())
        print(f"[info] {label}: RIME years {by_year.columns.min()}-{last}"
              + (f", held constant after {last}" if last < a.end_year else ""))
        absolute[label] = to_annual(by_year, a.base_year, a.end_year)
        ratios[label] = degree_day_ratio(absolute[label], a.base_year, floor, a.cap, label)
        notes.append(f"{label}: {os.path.basename(maps[label])}, RIME years to {last}, base floor {floor:g} °C·days")

    for label, r in ratios.items():
        missing = sorted(set(regions_list) - set(r.dropna().index))
        if missing:
            sys.exit(f"[error] {label}: no values for {len(missing)} of {len(regions_list)} OPEN-PROM regions: "
                     f"{', '.join(missing)} (check the region mapping / Natural Earth codes)")

    write_gams_csv(a.out, ratios, regions_list, [
        f"iClimDegDays.csv for OPEN-PROM (i02ClimDD, climFeedback){' - ' + scen if scen else ''}",
        f"Ratio to {a.base_year}: min(cap, 1 + (DD(t) - DD({a.base_year})) / max(DD({a.base_year}), floor)), cap {a.cap:g}",
        f"RIME maps per OPEN-PROM region, {popw.label}; " + "; ".join(notes),
    ])
    stem = os.path.splitext(a.out)[0]
    if absolute:
        ab = pd.concat(absolute, names=["ddtype", "region"])
        ab.round(2).to_csv(f"{stem}_absolute.csv")
    diagnostic_plot(f"{stem}_diagnostics.png", ratios, f"iClimDegDays{' – ' + scen if scen else ''}", a.cap)
    print(f"[ok] {a.out} (+ _absolute.csv, _diagnostics.png)")


if __name__ == "__main__":
    main()
