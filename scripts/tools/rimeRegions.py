"""OPEN-PROM regions for RIME maps: region fractions per grid cell, weights, regional means.

Shared by climDegreeDays.py (feedback loop input) and rimeImpacts.py (impact reporting).

  * Countries (Natural Earth 1:50m, ISO3) are grouped into OPEN-PROM regions with the
    mrprom region mapping. Each grid cell is split into SUBCELLS x SUBCELLS points, so
    small countries (MLT, LUX) keep their share of a cell.
  * Weights: SSP2 gridded population of each year (ISIMIP ssp2soc), or cell area.
  * A regional value is the weighted mean over the region's cells, cells without data
    excluded; "World" = all mapped cells.
"""

import os
import re
import sys
import urllib.request

import numpy as np
import pandas as pd
import xarray as xr

SUBCELLS = 10               # sub-sampling per cell side for the region fractions
NE_URL = "https://naciscdn.org/naturalearth/50m/cultural/ne_50m_admin_0_countries.zip"


def read_mapping(path):
    """Country (ISO3) -> OPEN-PROM region, from an mrprom region mapping (either column convention)."""
    m = pd.read_csv(path, sep=None, engine="python")
    iso = next((c for c in ("CountryCode", "ISO3.Code") if c in m.columns), None)
    reg = next((c for c in ("RegionCode", "Region.Code") if c in m.columns), None)
    if not (iso and reg):
        sys.exit(f"[error] {path}: need CountryCode/RegionCode or ISO3.Code/Region.Code columns")
    return dict(zip(m[iso], m[reg]))


def natural_earth(path_or_cache_dir):
    """Path of the Natural Earth 1:50m countries zip; downloaded once into the cache folder if needed."""
    if os.path.isfile(path_or_cache_dir):
        return path_or_cache_dir
    os.makedirs(path_or_cache_dir, exist_ok=True)
    path = os.path.join(path_or_cache_dir, os.path.basename(NE_URL))
    if not os.path.exists(path):
        print("[info] downloading Natural Earth countries")
        urllib.request.urlretrieve(NE_URL, path + ".part")
        os.replace(path + ".part", path)
    return path


def region_fractions(lon, lat, iso2reg, ne_file, subcells=SUBCELLS):
    """Fraction of each grid cell in each OPEN-PROM region: DataArray (region, lat, lon).

    overlap=False: country polygons do not overlap, and it avoids regionmask's 3D bit
    mask, which fails for more than 32 regions.
    """
    import geopandas as gpd
    import regionmask
    ne = gpd.read_file(ne_file)
    ne["reg"] = ne["ADM0_A3"].map(iso2reg)              # ISO_A3 is -99 for e.g. FRA, NOR
    regs = ne.dropna(subset=["reg"]).dissolve(by="reg").reset_index()
    rm = regionmask.from_geopandas(regs, names="reg", abbrevs="reg", name="OPEN-PROM", overlap=False)
    lo, la, k = np.asarray(lon), np.asarray(lat), subcells
    off = (np.arange(k) + 0.5) / k - 0.5
    fine = rm.mask((lo[:, None] + off * (lo[1] - lo[0])).ravel(),
                   (la[:, None] + off * (la[1] - la[0])).ravel()).values.reshape(len(la), k, len(lo), k)
    frac = np.stack([(fine == n).mean(axis=(1, 3), dtype=np.float32) for n in rm.numbers])
    return xr.DataArray(frac, dims=("region", "lat", "lon"),
                        coords={"region": list(rm.abbrevs), "lat": la, "lon": lo})


class PopWeights:
    """SSP2 gridded population on a map grid for a given year (nearest available); else cos(lat) area."""

    def __init__(self, path, var=None):
        self.pop = None
        if not path:
            self.label = "area-weighted"
            return
        ds = xr.open_dataset(path, decode_times=False)
        dvars = [v for v in ds.data_vars if {"lat", "lon"} <= set(ds[v].dims)]
        var = var or (dvars[0] if len(dvars) == 1 else next(iter([v for v in dvars if "pop" in v.lower()]), None))
        if var is None:
            sys.exit(f"[error] cannot pick the population variable in {path}: {dvars}")
        tname = next(d for d in ds[var].dims if d not in ("lat", "lon"))
        units = ds[tname].attrs.get("units", "")
        start = int(re.search(r"(\d{4})", units).group(1))
        vals = ds[tname].values
        self.years = (start + vals if units.startswith("years") else start + np.floor(vals / 365.25)).astype(int)
        self.pop, self.tname = ds[var], tname
        self.label = "SSP2 population-weighted (population of each year)"

    def __call__(self, year, like):
        if self.pop is None:
            return area_weights(like)
        k = int(np.argmin(np.abs(self.years - year)))
        return self.pop.isel({self.tname: k}).interp_like(like, method="nearest").fillna(0)


def area_weights(like):
    """Cell area, proportional to cos(latitude)."""
    return np.cos(np.deg2rad(like.lat)) * xr.ones_like(like.lon)


class Regions:
    """OPEN-PROM regions for any map grid (fractions computed once per grid and cached)."""

    def __init__(self, mapping_file, ne_file):
        self.iso2reg = read_mapping(mapping_file)
        self.names = sorted(set(self.iso2reg.values()))
        self.ne_file = ne_file
        self._frac = {}

    def fractions(self, like):
        key = (like.sizes["lat"], like.sizes["lon"], float(like.lat[0]), float(like.lon[0]))
        if key not in self._frac:
            self._frac[key] = region_fractions(like.lon, like.lat, self.iso2reg, self.ne_file)
        return self._frac[key]


def regional_means(da, frac, weights, world=False):
    """Weighted mean of da (lat, lon) per region (+ "World" over all mapped cells); NaN cells excluded."""
    if world:
        frac = xr.concat([frac, frac.sum("region").clip(max=1).expand_dims(region=["World"])], dim="region")
    w = (frac * weights).where(da.notnull(), 0)
    num = (w * da.fillna(0)).sum(["lat", "lon"])
    den = w.sum(["lat", "lon"])
    return (num / den.where(den > 0)).to_series()


def regional_by_year(maps_file, ind, regions, weight, world=False):
    """Weighted regional values (rows) per RIME year with data (columns), and the maps' attributes.

    weight = callable(year, like) -> weights on the map grid (e.g. PopWeights or area_weights).
    """
    ds = xr.open_dataset(maps_file)
    da = ds[ind]
    frac = regions.fractions(da.isel(year=0))
    cols = {int(y): regional_means(da.sel(year=y), frac, weight(int(y), da.isel(year=0)), world)
            for y in da.year.values if bool(da.sel(year=y).notnull().any())}
    if not cols:
        sys.exit(f"[error] {maps_file}: no year with data")
    return pd.DataFrame(cols), {**da.attrs, **ds.attrs}   # scenario, model, ... are stored on the file
