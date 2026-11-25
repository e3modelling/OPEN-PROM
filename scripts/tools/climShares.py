"""Climate-sensitive end-use shares for OPEN-PROM (iClimShares.csv, climate feedback loop 1).

Writes, for every OPEN-PROM region and the buildings subsectors HOU and SE:
  HDD column (i02ShHeat): space heating / (space heating + water heating + cooking),
                          all fuels: the climate-sensitive part of substitutable demand;
  CDD column (i02ShCool): space-cooling electricity / (electricity - electricity for space
                          heating, water heating and cooking): the cooling part of
                          non-substitutable electricity.
Shares are in final energy.

Sources:
  * EU-27, HOU: Eurostat nrg_d_hhq (households by end use and fuel), API, --eu-year.
  * EU-27, SE:  JRC-IDEES 2021 (services by end use, latest year 2021), CC BY 4.0; only the
                tertiary workbook is read from each country zip (HTTP range requests).
  * Other regions: scripts/tools/climShares_manual.csv (value, year, source, confidence per row);
                a row there also overrides the EU data for that region.
Regions without data get 0 (no climate effect) and are listed in the output.

Run:  python scripts/tools/climShares.py --regionmapping <regionmappingOPDEV5.csv> --out data/iClimShares.csv
Needs: pandas, openpyxl (e.g. the RIME environment).
"""

import argparse
import io
import json
import os
import sys
import time
import urllib.request
import zipfile

import pandas as pd

EUROSTAT = ("https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/nrg_d_hhq"
            "?format=JSON&lang=EN&unit=TJ&time={year}&siec=TOTAL&siec=E7000")
JRC = "https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/JRC-IDEES/JRC-IDEES-2021_v1/JRC-IDEES-2021_{cc}.zip"
JRC_YEAR = 2021
EU27 = {"AT": "AUT", "BE": "BEL", "BG": "BGR", "CY": "CYP", "CZ": "CZE", "DE": "DEU", "DK": "DNK",
        "EE": "EST", "EL": "GRC", "ES": "ESP", "FI": "FIN", "FR": "FRA", "HR": "HRV", "HU": "HUN",
        "IE": "IRL", "IT": "ITA", "LT": "LTU", "LU": "LUX", "LV": "LVA", "MT": "MLT", "NL": "NLD",
        "PL": "POL", "PT": "PRT", "RO": "ROU", "SE": "SWE", "SI": "SVN", "SK": "SVK"}
MANUAL = os.path.join(os.path.dirname(os.path.abspath(__file__)), "climShares_manual.csv")


def share(num, den):
    return round(num / den, 3) if den > 0 else None


def fetch(req, tries=4):
    """urlopen().read() with retries (the JRC server is occasionally slow)."""
    for k in range(tries):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return r.read(), r.headers
        except (OSError, TimeoutError) as err:
            if k == tries - 1:
                raise
            print(f"[warn] {getattr(req, 'full_url', req)}: {err}; retry {k + 1}")
            time.sleep(10 * (k + 1))


# =============================================================== Eurostat (households)
def eurostat_households(year):
    """{region: (heat_share, cool_share)} for EU-27 households from nrg_d_hhq."""
    d = json.loads(fetch(EUROSTAT.format(year=year))[0])
    if "error" in d:
        sys.exit(f"[error] Eurostat: {d['error']}")
    dims, size = d["id"], d["size"]
    lab = {k: {v: c for c, v in d["dimension"][k]["category"]["index"].items()} for k in dims}
    stride = [1] * len(dims)
    for i in range(len(dims) - 2, -1, -1):
        stride[i] = stride[i + 1] * size[i + 1]
    val = {}
    for idx, v in d["value"].items():
        key = {k: lab[k][(int(idx) // stride[i]) % size[i]] for i, k in enumerate(dims)}
        val[(key["geo"], key["siec"], key["nrg_bal"])] = v
    g = lambda geo, siec, bal: val.get((geo, siec, f"FC_OTH_HH_E{bal}"), 0.0)
    out = {}
    for geo, reg in EU27.items():
        sh, wh, ck = (g(geo, "TOTAL", b) for b in ("_SH", "_WH", "_CK"))
        e_tot, e_sc = g(geo, "E7000", ""), g(geo, "E7000", "_SC")
        e_heat = sum(g(geo, "E7000", b) for b in ("_SH", "_WH", "_CK"))
        out[reg] = (share(sh, sh + wh + ck), share(e_sc, e_tot - e_heat))
    return out


# =============================================================== JRC-IDEES (services)
class HttpRangeFile(io.RawIOBase):
    """Read-only, seekable view of a remote file via HTTP range requests (reads only what is needed)."""

    def __init__(self, url):
        self.url, self.pos = url, 0
        self.size = int(fetch(urllib.request.Request(url, method="HEAD"))[1]["Content-Length"])

    def seekable(self):
        return True

    def readable(self):
        return True

    def seek(self, off, whence=0):
        self.pos = {0: off, 1: self.pos + off, 2: self.size + off}[whence]
        return self.pos

    def tell(self):
        return self.pos

    def readinto(self, b):
        if self.pos >= self.size:
            return 0
        end = min(self.pos + len(b), self.size) - 1
        data = fetch(urllib.request.Request(self.url, headers={"Range": f"bytes={self.pos}-{end}"}))[0]
        b[:len(data)] = data
        self.pos += len(data)
        return len(data)


def jrc_tertiary(cc, cache_dir):
    """Path of the JRC-IDEES tertiary workbook of country cc (cached)."""
    path = os.path.join(cache_dir, f"JRC-IDEES-2021_Tertiary_{cc}.xlsx")
    if not os.path.exists(path):
        os.makedirs(cache_dir, exist_ok=True)
        z = zipfile.ZipFile(io.BufferedReader(HttpRangeFile(JRC.format(cc=cc)), buffer_size=1 << 20))
        with z.open(os.path.basename(path)) as src, open(path + ".part", "wb") as dst:
            dst.write(src.read())
        os.replace(path + ".part", path)
    return path


def jrc_services(cache_dir):
    """{region: (heat_share, cool_share)} for EU-27 services from JRC-IDEES (year JRC_YEAR)."""
    out = {}
    for cc, reg in EU27.items():
        print(f"[info] JRC-IDEES services {cc}")
        x = pd.ExcelFile(jrc_tertiary(cc, cache_dir))
        rows = {}
        for sheet in ("SER_hh_fec", "SER_summary"):
            d = pd.read_excel(x, sheet, header=None)
            ycol = list(d.iloc[0]).index(float(JRC_YEAR))
            for code, v in zip(d.iloc[:, -1], d.iloc[:, ycol]):
                if isinstance(code, str):
                    # country code -> CC (first occurrence only: Spain's "ES" also appears as ".ES." structure)
                    rows[code.replace(f".{cc}.", ".CC.", 1)] = float(v) if pd.notna(v) else 0.0
        f = lambda c: rows.get(f"FEC.ktoe.CC.{c}", 0.0)
        sh, wh, ca = f("Ser.Bld.Thermal.SH"), f("Ser.Bld.Thermal.HW"), f("Ser.Bld.Thermal.CA")
        e_heat = sum(v for c, v in rows.items() if c.endswith(".Elec") and
                     any(c.startswith(f"FEC.ktoe.CC.Ser.Bld.Thermal.{u}.") for u in ("SH", "HW", "CA")))
        out[reg] = (share(sh, sh + wh + ca), share(f("Ser.Bld.Thermal.SC.AC.Elec"), f("ES.Ser.Elec") - e_heat))
    return out


# =============================================================== main
def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--regionmapping", required=True, help="mrprom regionmappingOPDEV5.csv (OPEN-PROM regions)")
    p.add_argument("--out", required=True, help="output iClimShares.csv")
    p.add_argument("--manual", default=MANUAL, help="non-EU shares with sources")
    p.add_argument("--eu-year", type=int, default=2023, help="Eurostat year for EU households")
    p.add_argument("--cache-dir", default=os.path.join("..", "rime-data", "jrc-idees"))
    a = p.parse_args(argv)

    m = pd.read_csv(a.regionmapping, sep=None, engine="python")
    regions = sorted(m[next(c for c in ("RegionCode", "Region.Code") if c in m.columns)].unique())

    rows, src = {}, []
    for reg, (h, c) in eurostat_households(a.eu_year).items():
        rows[(reg, "HOU")] = (h, c)
        src.append((reg, "HOU", h, c, a.eu_year, "Eurostat nrg_d_hhq", "high"))
    for reg, (h, c) in jrc_services(a.cache_dir).items():
        rows[(reg, "SE")] = (h, c)
        src.append((reg, "SE", h, c, JRC_YEAR, "JRC-IDEES 2021 tertiary", "high"))
    man = pd.read_csv(a.manual)
    for r in man.itertuples():
        h = None if pd.isna(r.heat_share) else float(r.heat_share)
        c = None if pd.isna(r.cool_share) else float(r.cool_share)
        if h is None and c is None:
            continue
        if (r.region, r.sector) in rows:
            print(f"[info] {r.region}.{r.sector}: manual value overrides {rows[(r.region, r.sector)]}")
        rows[(r.region, r.sector)] = (h, c)
        src.append((r.region, r.sector, h, c, r.year, r.source, r.confidence))

    out, missing = [], []
    for reg in regions:
        for sec in ("HOU", "SE"):
            h, c = rows.get((reg, sec), (None, None))
            for lab, v in (("heat", h), ("cool", c)):
                if v is None:
                    missing.append(f"{reg}.{sec}:{lab}")
                elif not 0 <= v <= 1:
                    sys.exit(f"[error] {reg}.{sec} {lab} share {v} outside [0,1]")
            out.append((f"{reg},{sec}", h or 0.0, c or 0.0))

    with open(a.out, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("* iClimShares.csv - climate feedback loop 1, read into i02ShHeat (HDD) and i02ShCool (CDD)\n")
        fh.write("* HDD: space heating / (space heating + water heating + cooking), all fuels, final energy\n")
        fh.write("* CDD: space-cooling electricity / electricity without space/water heating and cooking, final energy\n")
        fh.write(f"* EU-27: Eurostat nrg_d_hhq {a.eu_year} (HOU), JRC-IDEES 2021 (SE); others: climShares_manual.csv\n")
        fh.write(f"* Sources per value: {os.path.basename(os.path.splitext(a.out)[0])}_sources.csv. Missing -> 0\n")
        fh.write("dummy,dummy,HDD,CDD\n")   # OPEN-PROM/mrprom layout: one label column per row dimension
        fh.writelines(f"{k},{h:g},{c:g}\n" for k, h, c in out)
    srcs = pd.DataFrame(src, columns=["region", "sector", "heat_share", "cool_share", "year", "source", "confidence"])
    srcs["year"] = pd.to_numeric(srcs["year"], errors="coerce").astype("Int64")
    srcs.sort_values(["region", "sector"]).to_csv(os.path.splitext(a.out)[0] + "_sources.csv", index=False)

    if missing:
        print(f"[WARNING] no data (written as 0, no climate effect) for {len(missing)} values: {', '.join(missing)}")
    print(f"[ok] {a.out}: {len(out)} rows ({len(regions)} regions x HOU, SE)")


if __name__ == "__main__":
    main()
