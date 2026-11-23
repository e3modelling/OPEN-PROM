"""Degree-day ratios for OPEN-PROM climate feedback loop 1 (iClimDegDays.csv).

Reads the median GSAT pathway produced by climate-assessment (MAGICC/CICERO
*_alloutput.xlsx) and RIME region datasets of degree days by global warming
level, and writes the ratio DD(t)/DD(2023) per OPEN-PROM region in the GAMS
table layout of iClimDegDays.csv (rows DDTYPE.region, year columns).

Lookup method = rime.rime_functions.table_impacts_gwl: for every year, take the
nearest (year, gwl) point of the RIME dataset for the chosen SSP. RIME itself is
not imported (it needs Python 3.10 and heavy mapping libraries); only pandas and
xarray (+ netCDF4) are used, so this runs in the climate-assessment .venv.

RIME region datasets are the output of rime/generate_aggregated_inputs.py, e.g.
sdd_c_18p3_COUNTRIES.nc with dims (gwl, year, ssp, region) and variable
"sdd_c_18p3|Hazard|Absolute|Population weighted" (Werning et al. 2024,
doi:10.5281/zenodo.14524342). That dataset has cooling degree days only, so HDD
rows are written only when --hdd-file is given; missing rows stay 1 in OPEN-PROM.
"""

import argparse
import re
import sys

import numpy as np
import pandas as pd
import xarray as xr

BASE_YEAR = 2023
GSAT_PATTERN = r"Surface Temperature \(GSAT\).*50\.0th Percentile"
ISO3_OF = {"CHA": "CHN"}  # OPEN-PROM codes that differ from ISO3


def read_gsat(xlsx, years):
    """Median GSAT (World) of the single scenario in a climate-assessment output file."""
    df = pd.read_excel(xlsx)
    df.columns = [c.lower() if isinstance(c, str) and not c.isdigit() else c for c in df.columns]
    sel = df[df["variable"].str.contains(GSAT_PATTERN, regex=True) & (df["region"] == "World")]
    if sel.empty:
        sys.exit(f"No median GSAT variable for World in {xlsx}")
    if sel["scenario"].nunique() > 1:
        sys.exit(f"{xlsx} holds several scenarios ({', '.join(sel['scenario'].unique())}); expected one.")
    row = sel.iloc[0]
    ts = {int(c): row[c] for c in sel.columns if str(c).isdigit() and pd.notna(row[c])}
    ts = pd.Series(ts).sort_index()
    ts = ts.reindex(sorted(set(ts.index) | set(years))).interpolate(method="index", limit_area="inside")
    missing = [y for y in years if pd.isna(ts.get(y))]
    if missing:
        sys.exit(f"GSAT does not cover years {missing[0]}-{missing[-1]}")
    print(f"GSAT: {row['variable']} ({BASE_YEAR}: {ts[BASE_YEAR]:.2f} C, {years[-1]}: {ts[years[-1]]:.2f} C)")
    return ts.loc[years]


def degree_days(nc_file, variable, ssp, gsat):
    """RIME lookup: DD(region, year) at the GSAT of that year (nearest year and gwl)."""
    try:
        ds = xr.open_dataset(nc_file)
    except ValueError as err:
        sys.exit(f"Cannot open {nc_file} ({err}). Install a netCDF backend: pip install netCDF4")
    ds = ds.rename({d: d.lower() for d in ds.dims})
    if "gmt" in ds.dims:
        ds = ds.rename({"gmt": "gwl"})
    if variable not in ds:
        sys.exit(f"{variable} not in {nc_file}. Available: {', '.join(ds.data_vars)}")
    da = ds[variable].sel(ssp=ssp)
    lo, hi = float(da.gwl.min()), float(da.gwl.max())
    if gsat.min() < lo or gsat.max() > hi:
        print(f"Warning: GSAT {gsat.min():.2f}-{gsat.max():.2f} C outside dataset range {lo}-{hi} C; nearest level used.")
    pts = dict(year=xr.DataArray(gsat.index.values, dims="t"), gwl=xr.DataArray(gsat.values, dims="t"))
    out = da.sel(**pts, method="nearest").transpose("region", "t").to_pandas()
    out.columns = gsat.index
    out.index = out.index.astype(str)
    return out


def model_regions(sets_file):
    """Members of the allCy set in core/sets.gms."""
    text = open(sets_file, encoding="utf-8").read()
    block = re.search(r"^allCy\b[^\n]*\n/\n(.*?)\n/", text, re.S | re.M)
    if not block:
        sys.exit(f"allCy set not found in {sets_file}")
    return [ln.split()[0] for ln in block.group(1).splitlines() if ln.strip() and not ln.startswith("*")]


def read_mapping(path):
    """Country -> region mapping (madrat format: CountryCode and RegionCode columns)."""
    df = pd.read_csv(path, sep=None, engine="python")
    if not {"CountryCode", "RegionCode"} <= set(df.columns):
        sys.exit(f"{path} needs CountryCode and RegionCode columns")
    return df.groupby("RegionCode")["CountryCode"].apply(list).to_dict()


def to_model_regions(dd, regions, mapping):
    """Country DD -> OPEN-PROM regions. Aggregates use the unweighted mean of member countries."""
    rows, skipped = {}, []
    for r in regions:
        iso = ISO3_OF.get(r, r)
        if iso in dd.index:
            rows[r] = dd.loc[iso]
        elif mapping and r in mapping:
            members = [c for c in mapping[r] if c in dd.index]
            if members:
                rows[r] = dd.loc[members].mean()
            else:
                skipped.append(r)
        else:
            skipped.append(r)
    if skipped:
        print(f"No degree days for {', '.join(skipped)} (stay neutral = 1)"
              + ("" if mapping else "; pass --regionmapping for aggregate regions"))
    return pd.DataFrame(rows).T


def ratios(dd):
    base = dd[BASE_YEAR].replace(0, np.nan)
    return dd.div(base, axis=0).dropna(how="any")


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--gsat", required=True, help="climate-assessment *_alloutput.xlsx")
    p.add_argument("--cdd-file", required=True, help="RIME region netCDF with cooling degree days")
    p.add_argument("--cdd-var", default="sdd_c_18p3|Hazard|Absolute|Population weighted")
    p.add_argument("--hdd-file", default=None, help="RIME-format region netCDF with heating degree days (optional)")
    p.add_argument("--hdd-var", default=None)
    p.add_argument("--ssp", default="SSP2")
    p.add_argument("--sets", required=True, help="OPEN-PROM core/sets.gms (allCy members)")
    p.add_argument("--regionmapping", default=None, help="CountryCode/RegionCode mapping for aggregate regions")
    p.add_argument("--out", required=True, help="Output iClimDegDays.csv")
    p.add_argument("--end-year", type=int, default=2100)
    a = p.parse_args()

    years = list(range(BASE_YEAR, a.end_year + 1))
    gsat = read_gsat(a.gsat, years)
    regions = model_regions(a.sets)
    mapping = read_mapping(a.regionmapping) if a.regionmapping else None

    blocks = {"CDD": (a.cdd_file, a.cdd_var)}
    if a.hdd_file:
        if not a.hdd_var:
            sys.exit("--hdd-var is required with --hdd-file")
        blocks["HDD"] = (a.hdd_file, a.hdd_var)
    else:
        print("No HDD dataset given (RIME/Werning et al. provide CDD only): HDD stays neutral = 1.")

    tables = []
    for ddtype, (f, var) in blocks.items():
        r = ratios(to_model_regions(degree_days(f, var, a.ssp, gsat), regions, mapping))
        r.index = [f"{ddtype}.{c}" for c in r.index]
        tables.append(r)
        print(f"{ddtype}: {len(r)} regions, ratio {years[-1]} range {r[years[-1]].min():.3f}-{r[years[-1]].max():.3f}")
    table = pd.concat(tables).round(5)

    header = [
        "* iClimDegDays.csv - climate feedback loop 1 (switch climFeedback), read into i02ClimDD(DDTYPE,allCy,YTIME)",
        f"* Degree-day ratio DD(t)/DD({BASE_YEAR}), dimensionless. Generated by scripts/tools/rimeDegreeDays.py",
        f"* GSAT: {a.gsat}",
        f"* CDD: {a.cdd_file} [{a.cdd_var}]" + (f"; HDD: {a.hdd_file} [{a.hdd_var}]" if a.hdd_file else "; HDD: none (neutral)"),
        f"* RIME nearest (year, GWL) lookup, {a.ssp}, population-weighted country values"
        + ("; aggregates = unweighted mean of member countries" if mapping else ""),
    ]
    with open(a.out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(header) + "\n")
        fh.write("," + ",".join(str(y) for y in years) + "\n")
        for idx, row in table.iterrows():
            fh.write(idx + "," + ",".join(f"{v:g}" for v in row.values) + "\n")
    print(f"Written {a.out}")


if __name__ == "__main__":
    main()
