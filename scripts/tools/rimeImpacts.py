"""Climate impacts of an OPEN-PROM run with RIME: OPEN-PROM -> MAGICC -> RIME -> impact tables.

Two outputs, both in IAMC format (.mif for the OPEN-PROM reporting tools, .csv):

  1. OPEN-PROM regions (always): the RIME maps written by rimeMaps.py, averaged over
     the 39 OPEN-PROM regions and the World (rimeRegions.py), for every RIME year:
       Climate impacts|RIME|<indicator>|Population weighted   (or |Area weighted)
     Weighting "auto": population for energy, heat, precipitation and air quality;
     area for water and land.
  2. Countries (option --tables): the Climate Solutions Explorer country tables run
     through RIME's table route (rime.rime_functions.loop_interpolate_gwl ->
     rime.core.RegionArray -> rime.rime_functions.table_impacts_gwl), with RIME's own
     selection of variables: hazard (absolute, population or land-area weighted, risk
     score) and exposure (population, land area). One table per indicator (~55 MB) is
     read from the Zenodo archive once and cached.

Validity as in rimeMaps.py: years after RIME's overshoot limit and warming levels outside
the impact data are left empty. Units and names come from RIME's indicator_params.yml.
Impact data: Werning et al. (2024), Climate Solutions Explorer v1.1, doi:10.5281/zenodo.14524342.
"""

import argparse
import csv
import gzip
import io
import os
import sys
import warnings
import zipfile

warnings.filterwarnings("ignore", category=FutureWarning)

import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402
import xarray as xr  # noqa: E402
import yaml  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from rimeRegions import PopWeights, Regions, area_weights, natural_earth, regional_by_year  # noqa: E402
from rimeMaps import YEARS, DRAWDOWN_MAX, emulation_end, read_gsat  # noqa: E402

PREFIX = "Climate impacts|RIME|"
AREA_WEIGHTED = ("dri", "iavar", "seas", "wsi", "lc")    # water and land: area weights under "auto"
TABLES_ZIP = "https://zenodo.org/records/14524342/files/table_output_climate_exposure_COUNTRIES.zip"
# RIME's own selection of country-table variables (rime/generate_aggregated_inputs.py)
TABLE_VARS = ["|Exposure|Land area", "|Exposure|Population", "|Exposure|Population|%",
              "|Hazard|Absolute|Land area weighted", "|Hazard|Absolute|Population weighted",
              "|Hazard|Risk score|Population weighted"]
MEDIAN = "|50.0th Percentile"


def indicator_info():
    """short_name -> (long name, unit) from RIME's indicator_params.yml."""
    import rime
    with open(os.path.join(os.path.dirname(rime.__file__), "indicator_params.yml"), encoding="utf-8") as fh:
        params = yaml.safe_load(fh)
    info = {}
    for group in params.get("indicators", {}).values():
        for entry in group.values():
            info[entry["short_name"]] = (entry.get("long_name", ""), entry.get("unit", ""))
    return info


def weighting_of(ind, choice):
    if choice != "auto":
        return choice
    return "area" if ind.startswith(AREA_WEIGHTED) else "population"


# =============================================================== 1. OPEN-PROM regions from the maps
def regional_impacts(a, info):
    regions = Regions(a.regionmapping, natural_earth(a.natural_earth))
    popw = PopWeights(a.pop_grid)
    rows, scen, model = [], "", "OPEN-PROM"
    for ind in a.indicators:
        path = os.path.join(a.maps_dir, f"rime_maps_{ind}.nc")
        if not os.path.exists(path):
            sys.exit(f"[error] no maps for {ind}: {path} (run rimeMaps.py with this indicator first)")
        w = weighting_of(ind, a.weighting)
        if w == "population" and popw.pop is None:
            print(f"[warn] {ind}: no population grid given -> area weights")
            w = "area"
        weight = popw if w == "population" else (lambda y, like: area_weights(like))
        by_year, attrs = regional_by_year(path, ind, regions, weight, world=True)
        scen = attrs.get("scenario", scen)
        long_name, unit = info.get(ind, ("", xr.open_dataset(path)[ind].attrs.get("unit", "")))
        var = f"{PREFIX}{ind}|{'Population' if w == 'population' else 'Area'} weighted"
        for reg, vals in by_year.iterrows():
            rows.append({"model": model, "scenario": scen, "region": reg, "variable": var, "unit": unit, **vals.to_dict()})
        print(f"[info] {ind} ({long_name or 'n/a'}, {unit}): {w} weighted, years {by_year.columns.min()}-{by_year.columns.max()}")
    return pd.DataFrame(rows)


# =============================================================== 2. countries with RIME's table route
def country_table(ind, ssp, cache_dir):
    """Rows of RIME's variable selection (median, one SSP) for one indicator, cached as .csv.gz."""
    path = os.path.join(cache_dir, f"{ind}_{ssp.lower()}_COUNTRIES_rime.csv.gz")
    if os.path.exists(path):
        return pd.read_csv(path)
    from climShares import HttpRangeFile              # remote zip member, read via HTTP ranges
    os.makedirs(cache_dir, exist_ok=True)
    keep = {f"{ind}{v}{MEDIAN}" for v in TABLE_VARS}
    print(f"[info] reading table_output_{ind}_COUNTRIES.csv from Zenodo (once, ~55 MB)")
    z = zipfile.ZipFile(io.BufferedReader(HttpRangeFile(TABLES_ZIP), buffer_size=8 << 20))
    member = f"table_output_{ind}_COUNTRIES.csv"
    if member not in z.namelist():
        sys.exit(f"[error] no country table for {ind} (tables exist for all indicators except lc and pm2p5)")
    with z.open(member) as f, gzip.open(path + ".part", "wt", encoding="utf-8", newline="") as out:
        rd, wr = csv.reader(io.TextIOWrapper(f, encoding="utf-8")), csv.writer(out, lineterminator="\n")
        wr.writerow(next(rd))
        for r in rd:
            if r[0] == "Climate Solutions" and r[3] in keep and r[1].startswith(f"{ssp.lower()}_"):
                wr.writerow(r)
    os.replace(path + ".part", path)
    return pd.read_csv(path)


def region_array(table):
    """Country table -> rime.core.RegionArray, as RIME's generate_aggregated_inputs.py does."""
    import pyam
    from rime.core import RegionArray
    from rime.rime_functions import loop_interpolate_gwl
    years = list(range(YEARS[0], YEARS[-1] + 1))
    df = pyam.IamDataFrame(table).interpolate(time=years).timeseries().reset_index()
    df.dropna(how="all", inplace=True)
    df[["SSP", "GWL"]] = df.scenario.str.split("_", expand=True)
    df["GWL"] = df["GWL"].str.replace("p", ".").astype("float")
    df["variable"] = df["variable"].str.replace(MEDIAN, "", regex=False)
    ds = xr.Dataset()
    for var in df.variable.unique():
        d = loop_interpolate_gwl(df[df.variable == var], YEARS[0], YEARS[-1])
        d = d.melt(id_vars=["model", "scenario", "variable", "region", "unit", "SSP", "GWL"], value_vars=years, var_name="year")
        d.columns = [c.lower() for c in d.columns]
        d["year"] = d["year"].astype(int)
        dx = d.set_index(["gwl", "year", "ssp", "region"]).to_xarray()
        ds[var] = dx["value"]
        ds[var].attrs["unit"] = str(d["unit"].iloc[0])
    ds["ssp"] = [s.upper() for s in ds["ssp"].values]
    return RegionArray(ds)


def country_impacts(a):
    """RIME table_impacts_gwl on the median GSAT, per indicator with a country table."""
    from rime.core import GMTPathway
    from rime.rime_functions import table_impacts_gwl
    from rime.utils import fix_duplicate_temps
    df, var = read_gsat(a.gsat)
    gmt = GMTPathway(df, temperature_variable=var, default_ssp=a.ssp)
    gsat = df.filter(year=YEARS).timeseries().iloc[0]
    years = [y for y in YEARS if y <= emulation_end(gsat, YEARS, a.drawdown_max)]
    dft = gmt.df.filter(year=years).timeseries().reset_index()
    dft.columns = [int(c) if isinstance(c, (int, np.integer)) else c for c in dft.columns]
    dft = dft.merge(gmt.df.meta[["Ssp_family"]].reset_index(), on=["model", "scenario"])
    np.random.seed(0)                                  # fix_duplicate_temps jitters repeated temperatures
    row = dft.apply(fix_duplicate_temps, years=years, axis=1).iloc[0]
    out = []
    for ind in a.indicators:
        if ind.startswith(("lc", "pm2p5")):
            print(f"[info] {ind}: no country table in the Climate Solutions Explorer data, skipped")
            continue
        ra = region_array(country_table(ind, a.ssp, a.table_dir))
        res = table_impacts_gwl(row, ra, prefix_indicator=PREFIX)
        res.columns = [int(c) if str(c).isdigit() else c for c in res.columns]
        lo, hi = float(ra.dataset.gwl.min()), float(ra.dataset.gwl.max())
        outside = [y for y in years if not lo <= float(row[y]) <= hi]
        res.loc[:, outside] = np.nan                   # warming levels outside the impact data: no value
        res["model"] = "OPEN-PROM"
        out.append(res)
        print(f"[info] {ind}: {res['region'].nunique()} countries, {res['variable'].nunique()} variables")
    return pd.concat(out) if out else pd.DataFrame()


# =============================================================== output
def write_iamc(df, stem):
    """IAMC wide table as .mif (semicolons, N/A) and .csv; columns = years with any value."""
    if df.empty:
        return
    idx = ["model", "scenario", "region", "variable", "unit"]
    years = sorted(c for c in df.columns if isinstance(c, (int, np.integer)) and df[c].notna().any())
    df = df[idx + years].sort_values(idx)
    df.to_csv(f"{stem}.csv", index=False)
    with open(f"{stem}.mif", "w", encoding="utf-8", newline="\n") as fh:
        fh.write(";".join(["Model", "Scenario", "Region", "Variable", "Unit"] + [str(y) for y in years]) + ";\n")
        for _, r in df.iterrows():
            vals = ["N/A" if pd.isna(r[y]) else f"{r[y]:.6g}" for y in years]
            fh.write(";".join([str(r[c]) for c in idx] + vals) + ";\n")
    print(f"[ok] {stem}.mif / .csv: {df['variable'].nunique()} variables, {df['region'].nunique()} regions")


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--maps-dir", required=True, help="folder with rime_maps_<indicator>.nc (from rimeMaps.py)")
    p.add_argument("--indicators", nargs="+", required=True)
    p.add_argument("--regionmapping", required=True, help="mrprom regionmappingOPDEV5.csv")
    p.add_argument("--natural-earth", required=True, help="Natural Earth countries zip, or a cache folder")
    p.add_argument("--pop-grid", default=None, help="SSP2 gridded population (ISIMIP ssp2soc); none -> area weights")
    p.add_argument("--weighting", choices=["auto", "population", "area"], default="auto")
    p.add_argument("--out-dir", required=True)
    p.add_argument("--tables", action="store_true", help="also country tables via RIME's table route")
    p.add_argument("--gsat", help="climate-assessment *_alloutput.xlsx (needed with --tables)")
    p.add_argument("--table-dir", help="cache folder for the country tables (needed with --tables)")
    p.add_argument("--ssp", default="SSP2")
    p.add_argument("--drawdown-max", type=float, default=DRAWDOWN_MAX)
    a = p.parse_args(argv)
    if a.tables and not (a.gsat and a.table_dir):
        sys.exit("[error] --tables needs --gsat and --table-dir")

    os.makedirs(a.out_dir, exist_ok=True)
    write_iamc(regional_impacts(a, indicator_info()), os.path.join(a.out_dir, "rime_impacts"))
    if a.tables:
        write_iamc(country_impacts(a), os.path.join(a.out_dir, "rime_impacts_countries"))


if __name__ == "__main__":
    main()
