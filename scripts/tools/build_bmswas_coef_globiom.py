#!/usr/bin/env python3
"""
Build supply- and emissions-curve coefficient tables for BMSWAS from
GLOBIOM's biomass supply lookup table, mapped onto OPEN-PROM's `allCy`
region set.

PURPOSE
-------
OPEN-PROM consumes biomass supply via a single non-linear equation per
(region, year): P = a + b * Q^c (power-law, monotone-convex by
construction). The post-solve step recovers land-use emissions at the
solved demand Q* via a parallel but *different* family:
    Em = ea + eb * Q + ec * Q^2  (unconstrained quadratic, one fit per
    emission type).

The two families differ on purpose. Supply prices are bounded below by
zero and are monotone-increasing in Q for economic reasons, which the
power-law family expresses cleanly. Land-use emissions, by contrast,
are computed inside MAgPIE / GLOBIOM as linear combinations of activity
drivers (carbon-stock change, livestock, rice area, fertiliser N,
manure), so the *direct* relationship Em = f(activity) is linear. The
non-linearity in Em(Q) arises only indirectly, through land scarcity;
and depending on the emission type, the net effect can be increasing,
decreasing (when bioenergy displaces livestock or fertilised food
crops), or non-monotone. A quadratic with all three coefficients free
in sign tracks this faithfully via cheap OLS, without the boundary-
hitting pathology we saw when forcing emissions into the same
non-negative power-law family as price.

This script produces both coefficient tables from the IIASA / E3-
Modelling GLOBIOM lookup.

INPUT
-----
scripts/tools/GLOBIOM_LookupTable.xlsx with three sheets we use:

    GLOBIOM_BioenSupCurve
        One row per (Region, Variable, BioScen, GHGScen) at decadal
        resolution (2000, 2010, ..., 2070). Relevant variables:
            P     = "Price|Primary Energy|Biomass"        [US$2000/GJ]
            Q     = sum of "Primary Energy|Biomass|*"     [EJ/yr]
                    feedstock variables (6 of them)
            Em_v  = "Emissions|v|Land Use" for v in
                    {CO2 [Mt CO2/yr],
                     CH4 [Mt CH4/yr],
                     N2O [kt N2O/yr]}
        DATA-COVERAGE CAVEAT: in this lookup table, emission rows are
        present only for the 32 non-EU GLOBIOM regions. The 28 EU
        member-state rows ship the supply variables (Q, P) but no
        Emissions|*|Land Use rows. As a result, the emissions CSV
        contains (0, 0, 0) coefficients for every EU OPEN-PROM region;
        the post-solve emissions readback for those regions will return
        zero, which reflects missing data rather than zero physical
        emissions. A separate EU-side emission source would be needed
        to fill that gap.

    globiom_to_openprom
        Two columns: globiom_region -> openprom_region. Many-to-one for
        non-EU; one-to-one for EU member states. Edit this sheet directly
        in Excel if the mapping needs to change.

PROCESSING
----------
1. Aggregate GLOBIOM regions to OPEN-PROM regions, per anchor:
       Q_R        = sum over feedstock vars and over GLOBIOM regions
                    mapping to R
       P_R        = sum_g(P_g * Q_g) / Q_R          (production-weighted)
       Em_R(v)    = sum over GLOBIOM regions
   Drop degenerate anchors (Q_R <= 1e-9 or non-finite P_R).

2. For each (GHGScen, OPEN-PROM region, decadal year):
       Supply:    fit P     = a  + b  * Q^c            on (Q_R, P_R)
                  via bounded NLLS: a, b >= 0,  0.1 <= c <= 5.0
                  3+ anchors -> 3-parameter fit
                  2 anchors  -> linear (force c = 1, a, b >= 0)
       Emissions: fit Em_v  = ea + eb * Q + ec * Q^2   on (Q_R, Em_R(v))
                  via unconstrained OLS (linear in parameters); all of
                  ea, eb, ec are free in sign, so the fit naturally
                  expresses monotone-increasing, monotone-decreasing,
                  or non-monotone responses.
                  3+ anchors -> 3-parameter quadratic
                  2 anchors  -> 2-parameter linear (ec = 0)
                  -- one fit per type v in {CO2LandUse, CH4LandUse, N2OLandUse}
   < 2 anchors -> coefficients omitted (gap, filled by step 3).

3. Decadal coefficients -> annual values 2010..2100:
       linear interpolation between fitted years;
       gaps before the earliest fit are back-filled with the earliest value;
       2071..2100 (and gaps after the latest fit) forward-fill from the
       latest fitted value (= 2070 when 2070 was fittable).

OUTPUT
------
Two GAMS-loadable wide-format CSVs in parameters/ (following the
existing convention of `dummy,dummy,...,2010,...,2100`):

    iBmswasSupplyCoefGLOBIOM.csv
        3 key columns -> GHGScen, OPEN-PROM region, coef in {a, b, c}.
        Loaded as: imBmswasSupplyCoefGLOBIOM(GHGSCEN, allCy, COEF, YTIME)

    iBmswasEmisCoefGLOBIOM.csv
        4 key columns -> GHGScen, OPEN-PROM region, emission type in
        {CO2LandUse, CH4LandUse, N2OLandUse}, coef in {ea, eb, ec}.
        Loaded as: imBmswasEmisCoefGLOBIOM(GHGSCEN, allCy, EMTYPE, ECOEF, YTIME)
        ec here is the *quadratic* coefficient (Q^2 term), NOT the
        power-law exponent. See PURPOSE / PROCESSING above.

Supply uses coef set {a, b, c} (power-law); emissions uses {ea, eb, ec}
(quadratic). The distinct coef sets make the two GAMS parameters easy
to tell apart and avoid any chance of mis-applying the formula. The
GAMS post-solve formulas are correspondingly different:

    P  = a  + b  * power(Q, c)             -- supply
    Em = ea + eb * Q + ec * Q * Q          -- emissions

DEPENDENCIES
------------
pandas, numpy, scipy, openpyxl
    pip install pandas numpy scipy openpyxl

USAGE
-----
    python3 scripts/tools/build_bmswas_coef_globiom.py
"""

from __future__ import annotations

import logging
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.optimize import least_squares


# --------------------------- configuration ---------------------------
REPO_ROOT          = Path(__file__).resolve().parents[2]
INPUT_XLSX         = REPO_ROOT / "scripts" / "tools" / "GLOBIOM_LookupTable.xlsx"
OUTPUT_SUPPLY_CSV  = REPO_ROOT / "parameters" / "iBmswasSupplyCoefGLOBIOM.csv"
OUTPUT_EMIS_CSV    = REPO_ROOT / "parameters" / "iBmswasEmisCoefGLOBIOM.csv"

DATA_SHEET    = "GLOBIOM_BioenSupCurve"
MAPPING_SHEET = "globiom_to_openprom"

FEEDSTOCK_VARS = [
    "Primary Energy|Biomass|Energy Crops",
    "Primary Energy|Biomass|Forest industry residues",
    "Primary Energy|Biomass|Fuelwood",
    "Primary Energy|Biomass|Logging residues",
    "Primary Energy|Biomass|Other Solid",
    "Primary Energy|Biomass|Roundwood harvest",
]
PRICE_VAR = "Price|Primary Energy|Biomass"

# Short EmType label -> source variable name in the lookup table.
EM_VARS = {
    "CO2LandUse": "Emissions|CO2|Land Use",
    "CH4LandUse": "Emissions|CH4|Land Use",
    "N2OLandUse": "Emissions|N2O|Land Use",
}

OUT_YEARS         = list(range(2010, 2101))               # 91 annual years
SRC_YEARS_DECADAL = [2010, 2020, 2030, 2040, 2050, 2060, 2070]

# (a, b, c) fit bounds shared by supply and emissions fits.
COEF_INIT  = (0.0, 1.0, 1.0)
COEF_LOWER = (0.0, 0.0, 0.1)
COEF_UPPER = (np.inf, np.inf, 5.0)

Q_FLOOR              = 1e-9
MIN_ANCHORS_3PARAM   = 3
MIN_ANCHORS_2PARAM   = 2
OUTPUT_FLOAT_FORMAT  = "%.6g"

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger("build_bmswas_coef_globiom")


# --------------------------- I/O ---------------------------
def load_long(xlsx_path: Path) -> pd.DataFrame:
    """Read GLOBIOM_BioenSupCurve and melt to one row per
    (region, variable, bioscen, ghgscen, year). Values coerced to float;
    GAMS sentinel "Eps" and other non-numeric tokens become NaN."""
    df = pd.read_excel(xlsx_path, sheet_name=DATA_SHEET)
    year_cols = [c for c in df.columns if str(c).isdigit()]
    long = df.melt(
        id_vars=["Region", "Variable", "Unit", "BioScen", "GHGScen"],
        value_vars=year_cols,
        var_name="Year",
        value_name="Value",
    )
    long["Year"]  = long["Year"].astype(int)
    long["Value"] = pd.to_numeric(long["Value"], errors="coerce")
    return long


def load_mapping(xlsx_path: Path) -> dict:
    """Read the globiom_to_openprom sheet into a dict."""
    df = pd.read_excel(xlsx_path, sheet_name=MAPPING_SHEET)
    return dict(zip(df["globiom_region"].astype(str),
                    df["openprom_region"].astype(str)))


# --------------------------- anchor construction ---------------------------
def build_anchors(long: pd.DataFrame, mapping: dict) -> pd.DataFrame:
    """One row per (op_region, GHGScen, Year, BioScen) anchor after
    cross-region aggregation, with columns:
        op_region, GHGScen, Year, BioScen, Q, P, CO2LandUse, CH4LandUse, N2OLandUse
    Degenerate anchors (Q <= Q_FLOOR or non-finite P) are dropped.
    """
    # Q at GLOBIOM resolution: sum feedstocks per (region, BioScen, GHGScen, Year).
    q = (long[long["Variable"].isin(FEEDSTOCK_VARS)]
         .groupby(["Region", "GHGScen", "Year", "BioScen"], as_index=False)["Value"]
         .sum()
         .rename(columns={"Value": "Q"}))

    # P at GLOBIOM resolution.
    p = (long[long["Variable"] == PRICE_VAR]
         [["Region", "GHGScen", "Year", "BioScen", "Value"]]
         .rename(columns={"Value": "P"}))

    # Emissions at GLOBIOM resolution, pivoted to one column per EmType.
    em_long = long[long["Variable"].isin(EM_VARS.values())].copy()
    em_rev  = {v: k for k, v in EM_VARS.items()}
    em_long["EmType"] = em_long["Variable"].map(em_rev)
    em = em_long.pivot_table(
        index=["Region", "GHGScen", "Year", "BioScen"],
        columns="EmType",
        values="Value",
        aggfunc="sum",
    ).reset_index()
    em.columns.name = None

    df = pd.merge(q, p, on=["Region", "GHGScen", "Year", "BioScen"], how="inner")
    df = pd.merge(df, em, on=["Region", "GHGScen", "Year", "BioScen"], how="left")

    # Apply mapping; drop GLOBIOM regions absent from the sheet (with a warning).
    df["op_region"] = df["Region"].map(mapping)
    unmapped = sorted(df.loc[df["op_region"].isna(), "Region"].unique().tolist())
    if unmapped:
        log.warning("GLOBIOM regions absent from mapping sheet (dropped): %s", unmapped)
    df = df.dropna(subset=["op_region"])

    # Aggregate to OP region: sum Q, sum P*Q (for weighted price), sum each EmType.
    df["PxQ"] = df["P"] * df["Q"]
    em_cols = list(EM_VARS.keys())
    agg = (df.groupby(["op_region", "GHGScen", "Year", "BioScen"], as_index=False)
             .agg({"Q": "sum", "PxQ": "sum",
                   **{c: "sum" for c in em_cols}}))

    # Production-weighted price (NaN where total Q is too small to be meaningful).
    agg["P"] = np.where(agg["Q"] > Q_FLOOR, agg["PxQ"] / agg["Q"], np.nan)
    agg = agg.drop(columns=["PxQ"])

    # Filter degenerate.
    agg = agg[(agg["Q"] > Q_FLOOR) & agg["P"].notna() & (agg["P"] >= 0)]
    return agg


# --------------------------- fitting ---------------------------
def fit_powerlaw(Q: np.ndarray, Y: np.ndarray) -> tuple:
    """Fit Y = a + b * Q^c with a, b >= 0 and 0.1 <= c <= 5.0.
    Returns (a, b, c). Used for the supply curve.

    >= 3 anchors : 3-parameter NLLS with bounds.
    2 anchors    : force c = 1, fit (a, b) by non-negative linear least squares.
    < 2 anchors  : caller should not invoke; defensive (0, 0, 1) fallback.
    """
    Q = np.asarray(Q, dtype=float)
    Y = np.asarray(Y, dtype=float)
    if len(Q) >= MIN_ANCHORS_3PARAM:
        def residuals(params):
            a, b, c = params
            return a + b * np.power(Q, c) - Y
        res = least_squares(
            residuals, x0=COEF_INIT,
            bounds=(COEF_LOWER, COEF_UPPER),
            method="trf",
        )
        return tuple(float(v) for v in res.x)
    if len(Q) >= MIN_ANCHORS_2PARAM:
        A = np.vstack([np.ones_like(Q), Q]).T
        coefs, *_ = np.linalg.lstsq(A, Y, rcond=None)
        a = max(0.0, float(coefs[0]))
        b = max(0.0, float(coefs[1]))
        return (a, b, 1.0)
    return (0.0, 0.0, 1.0)


def fit_quadratic(Q: np.ndarray, Y: np.ndarray) -> tuple:
    """Fit Y = a + b * Q + c * Q^2 via unconstrained OLS. Returns (a, b, c).
    Used for emission curves -- all coefficients free in sign so the fit
    can track monotone-increasing, monotone-decreasing, or non-monotone
    Em(Q) responses faithfully.

    >= 3 anchors : full 3-parameter quadratic.
    2 anchors    : linear fit (force c = 0).
    < 2 anchors  : caller should not invoke; defensive (0, 0, 0) fallback.
    """
    Q = np.asarray(Q, dtype=float)
    Y = np.asarray(Y, dtype=float)
    if len(Q) >= MIN_ANCHORS_3PARAM:
        A = np.vstack([np.ones_like(Q), Q, Q * Q]).T
        coefs, *_ = np.linalg.lstsq(A, Y, rcond=None)
        return tuple(float(v) for v in coefs)
    if len(Q) >= MIN_ANCHORS_2PARAM:
        A = np.vstack([np.ones_like(Q), Q]).T
        coefs, *_ = np.linalg.lstsq(A, Y, rcond=None)
        return (float(coefs[0]), float(coefs[1]), 0.0)
    return (0.0, 0.0, 0.0)


def fit_decadal(anchors: pd.DataFrame, op_region: str, ghg: str,
                target_col: str, fit_func=fit_powerlaw) -> dict:
    """For one (op_region, ghg), return {coef -> {year -> value}} for every
    decadal year that had >= 2 usable anchors. target_col is the dependent
    variable (e.g. 'P' for supply, 'CO2LandUse' for emissions). NaN target
    values are dropped per year. fit_func selects the functional form
    (fit_powerlaw for supply, fit_quadratic for emissions)."""
    decadal = {"a": {}, "b": {}, "c": {}}
    sub = anchors[(anchors["op_region"] == op_region)
                  & (anchors["GHGScen"] == ghg)]
    for y in SRC_YEARS_DECADAL:
        ysub = sub[sub["Year"] == y].dropna(subset=[target_col])
        if len(ysub) < MIN_ANCHORS_2PARAM:
            continue
        a, b, c = fit_func(ysub["Q"].values, ysub[target_col].values)
        decadal["a"][y] = a
        decadal["b"][y] = b
        decadal["c"][y] = c
    return decadal


def interpolate_annual(year_to_value: dict, out_years: list) -> list:
    """Linearly interpolate {year -> value} onto out_years.

    Years <= earliest source year: earliest value (back-fill).
    Years >= latest source year:    latest value (forward-fill);
                                    this is how 2071..2100 inherit 2070.
    Empty input: all zeros (caller logs a warning separately).
    """
    if not year_to_value:
        return [0.0] * len(out_years)
    src_years = sorted(year_to_value.keys())
    src_vals  = [year_to_value[y] for y in src_years]
    out = []
    for y in out_years:
        if y <= src_years[0]:
            out.append(year_to_value[src_years[0]])
        elif y >= src_years[-1]:
            out.append(year_to_value[src_years[-1]])
        else:
            out.append(float(np.interp(y, src_years, src_vals)))
    return out


# --------------------------- CSV writers ---------------------------
def write_supply_csv(anchors: pd.DataFrame, op_regions: list,
                     ghgscens: list, out_path: Path) -> None:
    rows = []
    empty = 0
    for ghg in ghgscens:
        for r in op_regions:
            decadal = fit_decadal(anchors, r, ghg, "P", fit_func=fit_powerlaw)
            if not decadal["a"]:
                empty += 1
                log.warning("Supply: no fittable anchors for (%s, %s)", ghg, r)
            for coef in ("a", "b", "c"):
                annual = interpolate_annual(decadal[coef], OUT_YEARS)
                rows.append([ghg, r, coef] + annual)
    header = ["dummy", "dummy", "dummy"] + [str(y) for y in OUT_YEARS]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(rows, columns=header).to_csv(
        out_path, index=False, float_format=OUTPUT_FLOAT_FORMAT)
    log.info("Wrote %s (%d rows; %d (GHGScen, region) cells without anchors)",
             out_path, len(rows), empty)


def write_emis_csv(anchors: pd.DataFrame, op_regions: list,
                   ghgscens: list, out_path: Path) -> None:
    # fit_decadal returns the coefficients keyed as a / b / c internally;
    # emit them under the ea / eb / ec labels expected on the GAMS side.
    EMIS_COEF_LABELS = (("a", "ea"), ("b", "eb"), ("c", "ec"))
    rows = []
    empty_per_type = {t: 0 for t in EM_VARS}
    for ghg in ghgscens:
        for r in op_regions:
            for em_type in EM_VARS:
                decadal = fit_decadal(anchors, r, ghg, em_type,
                                      fit_func=fit_quadratic)
                if not decadal["a"]:
                    empty_per_type[em_type] += 1
                for src_key, out_label in EMIS_COEF_LABELS:
                    annual = interpolate_annual(decadal[src_key], OUT_YEARS)
                    rows.append([ghg, r, em_type, out_label] + annual)
    header = ["dummy", "dummy", "dummy", "dummy"] + [str(y) for y in OUT_YEARS]
    out_path.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(rows, columns=header).to_csv(
        out_path, index=False, float_format=OUTPUT_FLOAT_FORMAT)
    log.info("Wrote %s (%d rows; empty cells per EmType: %s)",
             out_path, len(rows), empty_per_type)


# --------------------------- main ---------------------------
def main() -> None:
    if not INPUT_XLSX.exists():
        raise FileNotFoundError(f"GLOBIOM lookup table not found: {INPUT_XLSX}")

    log.info("Reading %s", INPUT_XLSX)
    long    = load_long(INPUT_XLSX)
    mapping = load_mapping(INPUT_XLSX)
    log.info("Mapping: %d GLOBIOM regions -> %d distinct OPEN-PROM regions",
             len(mapping), len(set(mapping.values())))

    log.info("Aggregating anchors")
    anchors = build_anchors(long, mapping)

    op_regions = sorted(anchors["op_region"].unique().tolist())
    ghgscens   = sorted(anchors["GHGScen"].unique().tolist())
    log.info("OP regions with anchors: %d, GHGScens: %d, output years: %d..%d",
             len(op_regions), len(ghgscens), OUT_YEARS[0], OUT_YEARS[-1])

    write_supply_csv(anchors, op_regions, ghgscens, OUTPUT_SUPPLY_CSV)
    write_emis_csv  (anchors, op_regions, ghgscens, OUTPUT_EMIS_CSV)


if __name__ == "__main__":
    main()
