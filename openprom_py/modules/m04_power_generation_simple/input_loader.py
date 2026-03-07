"""
Load 04_PowerGeneration (simple) input data from CSV.

Mirrors modules/04_PowerGeneration/simple/input.gms. Loads i04AvailRate,
i04DataElecSteamGen, i04DataElecProdNonCHP, i04DataElecProdCHP,
i04DataTechLftPlaType, i04GrossCapCosSubRen, i04FixOandMCost, i04VarCost,
i04InvPlants, i04PlantDecomSched, iMatFacPlaAvailCap. Derived: i04TechLftPlaType,
iTotAvailNomCapBsYr, i04DecInvPlantSched, i04MxmShareChpElec, i04ScaleEndogScrap.
i04GrossCapCosSubRen is divided by 1000 in GAMS; i04VarCost + 1e-3; i04InvPlants/i04PlantDecomSched = 0.
"""
from pathlib import Path
from typing import Any, Dict

import pandas as pd
from pyomo.core import value as pyo_value

from core import sets as core_sets


def _read_table(
    data_dir: Path,
    filename: str,
    dims: int,
    year_cols_expected: bool = True,
) -> Dict[tuple, float]:
    """Read CSV with index columns + optional year columns. Return dict (tuple) -> float."""
    p = data_dir / filename
    if not p.exists():
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).strip().isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        if year_cols_expected and year_cols:
            for ycol in year_cols:
                try:
                    y = int(ycol)
                    key = tuple(row[c] for c in idx_cols) + (y,)
                    if len(key) == dims:
                        out[key] = float(row[ycol])
                except (TypeError, ValueError):
                    continue
        else:
            try:
                key = tuple(row[c] for c in idx_cols[:dims])
                val = float(row[idx_cols[dims]]) if len(idx_cols) > dims else float(row.iloc[-1])
                out[key] = val
            except (TypeError, ValueError, IndexError):
                continue
    return out


def load_power_generation_data(config: Any) -> Dict[str, Dict[tuple, float]]:
    """Load 04 CSV data. Keys: i04AvailRate, i04DataElecSteamGen, etc.
    When config.calibration == 'MatCalibration', also loads t04DemElecTot and t04SharePowPlaNewEq
    from targets/ (GAMS: ../targets/tDemand.csv, tShares_ProdElec.csv)."""
    data_dir = Path(config.data_dir)
    out: Dict[str, Dict[tuple, float]] = {}
    calibration = getattr(config, "calibration", "off")

    # Optional subdir for 04 data (e.g. data/04_PowerGeneration/simple/)
    base = data_dir
    for name, fname, dims, has_years in [
        ("i04AvailRate", "iAvailRate.csv", 3, True),
        ("i04DataElecSteamGen", "iDataElecSteamGen.csv", 3, True),
        ("i04DataElecProdNonCHP", "iDataElecProdNonCHP.csv", 3, True),
        ("i04DataElecProdCHP", "iDataElecProdCHP.csv", 3, True),
        ("i04GrossCapCosSubRen", "iGrossCapCosSubRen.csv", 3, True),
        ("i04FixOandMCost", "iFixOandMCost.csv", 3, True),
        ("i04VarCost", "iVarCost.csv", 2, True),
        ("i04InvPlants", "iInvPlants.csv", 3, True),
        ("i04PlantDecomSched", "iDecomPlants.csv", 3, True),
        ("i04MatFacPlaAvailCap", "iMatFacPlaAvailCap.csv", 3, True),
    ]:
        out[name] = _read_table(base, fname, dims, year_cols_expected=has_years)

    # i04DataTechLftPlaType(PGALL, PGECONCHAR) - 2 dims
    out["i04DataTechLftPlaType"] = {}
    p = base / "iDataTechLftPlaType.csv"
    if p.exists():
        df = pd.read_csv(p)
        cols = df.columns.tolist()
        for _, row in df.iterrows():
            try:
                if len(cols) >= 2:
                    out["i04DataTechLftPlaType"][
                        (str(row[cols[0]]), str(row[cols[1]]))
                    ] = float(row[cols[2]] if len(cols) > 2 else row.iloc[-1])
            except (TypeError, ValueError):
                continue

    # Calibration targets (GAMS $ifthen.calib %Calibration% == MatCalibration)
    if calibration == "MatCalibration":
        targets_dir = data_dir / "targets"
        if targets_dir.exists():
            out["t04DemElecTot"] = _read_table(
                targets_dir, "tDemand.csv", 2, year_cols_expected=True
            )
            out["t04SharePowPlaNewEq"] = _read_table(
                targets_dir, "tShares_ProdElec.csv", 3, year_cols_expected=True
            )
        else:
            out["t04DemElecTot"] = {}
            out["t04SharePowPlaNewEq"] = {}

    return out


def load_power_generation_data_into_model(
    m: Any,
    data: Dict[str, Dict[tuple, float]],
    core_sets_obj: Any,
    config: Any = None,
) -> None:
    """Push loaded 04 data into model params. When calibration == MatCalibration,
    fill iMatFacPlaAvailCapData, t04DemElecTot, t04SharePowPlaNewEq; else fill i04MatFacPlaAvailCap."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = core_sets_obj.datay
    pgall = list(core_sets.PGALL)
    pgoth = list(core_sets.PGOTH)
    ef = list(core_sets.EF)
    pgeconchar = list(core_sets.PGECONCHAR)

    if data.get("i04AvailRate"):
        for k, v in data["i04AvailRate"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04AvailRate[k] = v
    for cy in run_cy:
        for y in ytime:
            m.i04AvailRate[cy, "PGH2F", y] = 0.9  # GAMS

    if data.get("i04DataElecSteamGen"):
        for k, v in data["i04DataElecSteamGen"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime and k[1] in pgoth:
                m.i04DataElecSteamGen[k] = v

    if data.get("i04DataElecProdNonCHP"):
        for k, v in data["i04DataElecProdNonCHP"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04DataElecProdNonCHP[k] = v

    if data.get("i04DataElecProdCHP"):
        for k, v in data["i04DataElecProdCHP"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04DataElecProdCHP[k] = v

    # i04TechLftPlaType(runCy, PGALL) = i04DataTechLftPlaType(PGALL, "LFT"); PGH2F = 20
    if data.get("i04DataTechLftPlaType"):
        for (pg, char), v in data["i04DataTechLftPlaType"].items():
            if char == "LFT" and pg in pgall:
                for cy in run_cy:
                    m.i04TechLftPlaType[cy, pg] = v
    for cy in run_cy:
        m.i04TechLftPlaType[cy, "PGH2F"] = 20.0

    if data.get("i04GrossCapCosSubRen"):
        for k, v in data["i04GrossCapCosSubRen"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04GrossCapCosSubRen[k] = v / 1000.0  # GAMS /1000

    if data.get("i04FixOandMCost"):
        for k, v in data["i04FixOandMCost"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04FixOandMCost[k] = v

    if data.get("i04VarCost"):
        for k, v in data["i04VarCost"].items():
            if len(k) == 2 and k[1] in ytime:
                m.i04VarCost[k] = v + 1e-3  # GAMS
            elif len(k) >= 2:
                m.i04VarCost[k[0], k[1]] = v + 1e-3

    # i04InvPlants = 0, i04PlantDecomSched = 0 (GAMS)
    for cy in run_cy:
        for pg in pgall:
            for y in ytime:
                m.i04DecInvPlantSched[cy, pg, y] = pyo_value(m.i04InvPlants[cy, pg, y])

    calibration = getattr(config, "calibration", "off") if config else "off"
    if calibration == "MatCalibration" and hasattr(m, "iMatFacPlaAvailCapData"):
        if data.get("i04MatFacPlaAvailCap"):
            for k, v in data["i04MatFacPlaAvailCap"].items():
                if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                    m.iMatFacPlaAvailCapData[k] = v
        if data.get("t04DemElecTot"):
            for k, v in data["t04DemElecTot"].items():
                if len(k) == 2 and k[0] in run_cy and k[1] in ytime:
                    m.t04DemElecTot[k] = v
        if data.get("t04SharePowPlaNewEq"):
            for k, v in data["t04SharePowPlaNewEq"].items():
                if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                    m.t04SharePowPlaNewEq[k] = v
    if calibration != "MatCalibration" and data.get("i04MatFacPlaAvailCap") and hasattr(m, "i04MatFacPlaAvailCap"):
        for k, v in data["i04MatFacPlaAvailCap"].items():
            if len(k) == 3 and k[0] in run_cy and k[2] in ytime:
                m.i04MatFacPlaAvailCap[k] = v

    # iTotAvailNomCapBsYr(runCy, YTIME)$datay = i04DataElecSteamGen(runCy, "TOTNOMCAP", YTIME)
    if hasattr(m, "iTotAvailNomCapBsYr"):
        for cy in run_cy:
            for y in datay:
                try:
                    m.iTotAvailNomCapBsYr[cy, y] = pyo_value(
                        m.i04DataElecSteamGen[cy, "TOTNOMCAP", y]
                    )
                except Exception:
                    pass

    # i04MxmShareChpElec = 0.5
    for cy in run_cy:
        for y in ytime:
            m.i04MxmShareChpElec[cy, y] = 0.5

    # i04LoadFacElecDem(DSBS) from GAMS parameter block
    load_fac = {
        "IS": 0.92, "NF": 0.94, "CH": 0.83, "BM": 0.82, "PP": 0.74, "FD": 0.65,
        "EN": 0.7, "TX": 0.61, "OE": 0.92, "OI": 0.67, "SE": 0.64, "AG": 0.52,
        "HOU": 0.72, "PC": 0.7, "PB": 0.7, "PT": 0.62, "PN": 0.7, "PA": 0.7,
        "GU": 0.7, "GT": 0.62, "GN": 0.7, "BU": 0.7, "PCH": 0.83, "NEN": 0.83,
    }
    dsbs = list(core_sets.DSBS)
    for d in dsbs:
        if d in load_fac and hasattr(m, "i04LoadFacElecDem"):
            m.i04LoadFacElecDem[d] = load_fac[d]
