"""OPEN-PROM -> MAGICC -> RIME: gridded climate-impact maps for one MAGICC run.

Uses the RIME package (https://github.com/iiasa/rime, installed by
scripts/tools/installRimeWSL.sh) on the median GSAT of a climate-assessment output:

  rime.core.GMTPathway   MAGICC median GSAT (SSP assigned by RIME's ssp_helper)
  rime.core.RasterArray  gridded impacts by warming level (Climate Solutions Explorer)
  rime.rime_functions.map_transform_gwl_wrapper  -> maps (lat, lon, year)

Impact data: cse_<indicator>_<ssp>_<gwl>_abs.nc4 from energy.zip of Werning et al.
(2024), Climate Solutions Explorer v1.1, doi:10.5281/zenodo.14524342 (CC BY 4.0).
Missing files are downloaded once into --impact-dir.

Overshoot: RIME is not valid after a temperature drawdown larger than
--drawdown-max below the peak. Maps are therefore produced only up to the last
year that passes RIME's own check; later years are left out (held constant
downstream, in climDegreeDays.py).

Output: <out-dir>/rime_maps_<indicator>.nc, variable <indicator> (lat, lon, year).
"""

import argparse
import glob
import os
import re
import sys
import urllib.request
import warnings
import zipfile

warnings.filterwarnings("ignore", category=FutureWarning)

import numpy as np  # noqa: E402
import pandas as pd  # noqa: E402
import pyam  # noqa: E402
from rime.core import GMTPathway, RasterArray  # noqa: E402
from rime.rime_functions import map_transform_gwl_wrapper  # noqa: E402

YEARS = list(range(2020, 2101, 5))                 # RIME years
DRAWDOWN_MAX, TEMP_MIN, TEMP_MAX = 0.15, 1.2, 3.5  # RIME defaults (map_transform_gwl)
GSAT_PATTERN = r"Surface Temperature \(GSAT\).*50\.0th Percentile"
ZENODO_ZIP = "https://zenodo.org/records/14524342/files/{name}?download=1"
# Indicator -> Zenodo archive of the gridded maps (first matching prefix wins)
ARCHIVE_OF = {"sdd_c": "energy.zip", "hwd_": "temperature.zip", "hw_": "temperature.zip", "tr20": "temperature.zip",
              "cdd": "precipitation.zip", "pr_": "precipitation.zip", "sdii": "precipitation.zip",
              "dri": "hydrology.zip", "iavar": "hydrology.zip", "seas": "hydrology.zip", "wsi": "hydrology.zip",
              "lc": "land.zip", "pm2p5": "air_pollution.zip"}


def read_gsat(xlsx):
    """Median World GSAT of the single scenario in a climate-assessment output, as pyam.IamDataFrame."""
    sheets = pd.ExcelFile(xlsx).sheet_names
    df = pd.read_excel(xlsx, sheet_name="data" if "data" in sheets else 0)
    df.columns = [c.lower() if isinstance(c, str) and not c.strip().isdigit() else int(c) for c in df.columns]
    var = [v for v in df["variable"].unique() if re.search(GSAT_PATTERN, v)]
    if not var:
        sys.exit(f"[error] no median GSAT variable in {xlsx}")
    df = df[(df["variable"] == var[0]) & (df["region"] == "World")]
    if df["scenario"].nunique() != 1:
        sys.exit(f"[error] {xlsx}: expected one scenario, found {df['scenario'].nunique()}")
    return pyam.IamDataFrame(df), var[0]


def emulation_end(gsat, years, drawdown_max):
    """Last RIME year whose drawdown (peak so far minus current GSAT) is within RIME's limit."""
    ok = [y for y in years if max(gsat[z] for z in years if z <= y) - gsat[y] <= drawdown_max]
    return ok[-1]


def impact_files(ind, ssp, impact_dir):
    """Gridded impact files of one indicator and SSP; downloaded from Zenodo when missing."""
    pattern = os.path.join(impact_dir, f"cse_{ind}_{ssp.lower()}_*_abs.nc4")
    files = sorted(glob.glob(pattern))
    if files:
        return files
    archive = next((a for p, a in ARCHIVE_OF.items() if ind.startswith(p)), None)
    if archive is None:
        sys.exit(f"[error] no files {pattern} and no known Zenodo archive for {ind}")
    os.makedirs(impact_dir, exist_ok=True)
    zpath = os.path.join(impact_dir, archive)
    if not os.path.exists(zpath):
        print(f"[info] downloading {archive} from Zenodo (doi:10.5281/zenodo.14524342)")
        urllib.request.urlretrieve(ZENODO_ZIP.format(name=archive), zpath + ".part")
        os.replace(zpath + ".part", zpath)
    with zipfile.ZipFile(zpath) as z:
        names = [n for n in z.namelist() if re.fullmatch(rf"cse_{re.escape(ind)}_{ssp.lower()}_\d+p\d+_abs\.nc4", os.path.basename(n))]
        if not names:
            sys.exit(f"[error] {archive} has no maps for {ind} / {ssp}")
        for n in names:
            with z.open(n) as src, open(os.path.join(impact_dir, os.path.basename(n)), "wb") as dst:
                dst.write(src.read())
    return sorted(glob.glob(pattern))


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--gsat", required=True, help="climate-assessment *_alloutput.xlsx (one scenario)")
    p.add_argument("--indicators", nargs="+", required=True, help="RIME indicators, e.g. sdd_c_24p0")
    p.add_argument("--ssp", default="SSP2")
    p.add_argument("--impact-dir", required=True, help="folder with cse_<ind>_<ssp>_<gwl>_abs.nc4 (download cache)")
    p.add_argument("--out-dir", required=True)
    p.add_argument("--drawdown-max", type=float, default=DRAWDOWN_MAX)
    p.add_argument("--temp-min", type=float, default=TEMP_MIN)
    p.add_argument("--temp-max", type=float, default=TEMP_MAX)
    a = p.parse_args(argv)

    df, var = read_gsat(a.gsat)
    gmt = GMTPathway(df, temperature_variable=var, default_ssp=a.ssp)
    gsat = df.filter(year=YEARS).timeseries().iloc[0]
    missing = [y for y in YEARS if y not in gsat.index]
    if missing:
        sys.exit(f"[error] GSAT lacks RIME years {missing}")
    end = emulation_end(gsat, YEARS, a.drawdown_max)
    years = [y for y in YEARS if y <= end]
    print(f"[info] GSAT {YEARS[0]}: {gsat[YEARS[0]]:.2f} °C, peak {gsat.max():.2f} °C ({gsat.idxmax()}), "
          f"{YEARS[-1]}: {gsat[YEARS[-1]]:.2f} °C")
    if end < YEARS[-1]:
        print(f"[info] overshoot: drawdown > {a.drawdown_max} °C after {end}; RIME maps up to {end} only")
    os.makedirs(a.out_dir, exist_ok=True)

    for ind in a.indicators:
        files = impact_files(ind, a.ssp, a.impact_dir)
        print(f"[info] {ind}: {len(files)} warming levels, {a.ssp}, years {years[0]}-{years[-1]}")
        maps = map_transform_gwl_wrapper(gmt.df, RasterArray(files), years, use_dask=False,
                                         drawdown_max=a.drawdown_max, temp_min=a.temp_min, temp_max=a.temp_max)
        maps = maps[[ind]].transpose("year", "lat", "lon")
        maps.attrs.update(scenario=df.scenario[0], model=df.model[0], ssp=a.ssp, gsat_variable=var,
                          emulated_until=end, source="RIME map_transform_gwl_wrapper; Werning et al. (2024) doi:10.5281/zenodo.14524342")
        out = os.path.join(a.out_dir, f"rime_maps_{ind}.nc")
        maps.to_netcdf(out, encoding={ind: dict(zlib=True, complevel=5)})
        valid = [int(y) for y in maps.year.values if bool(np.isfinite(maps[ind].sel(year=y)).any())]
        print(f"[ok] {out} (years with data: {valid[0]}-{valid[-1]})" if valid else f"[warn] {out}: no valid data")


if __name__ == "__main__":
    main()
