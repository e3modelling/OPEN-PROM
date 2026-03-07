"""
Load 01_Transport (simple) input data from CSV/CSVR.

Mirrors 01_Transport/simple/input.gms. All loaders return dicts keyed by index tuple.
Optional files: if missing, load_transport_data returns empty/partial dict and
load_transport_data_into_model uses defaults.

Commented out in GAMS (input.gms): *imMatrFactor.FX(runCy,"PC",TTECH,YTIME)$((t01StockPC(...) < 0) and (t01NewShareStockPC(...) <= 0)) = 100;
"""
from pathlib import Path
from typing import Any, Dict, Optional

import pandas as pd

from core import sets as core_sets
from modules._01_Transport.simple import sets as t_sets


def _path(data_dir: Path, filename: str) -> Optional[Path]:
    p = data_dir / filename
    return p if p.exists() else None


def _log(filename: str, status: str, detail: str = "") -> None:
    try:
        from run_report import get_report_logger
        log = get_report_logger()
        if log:
            if detail:
                log.info("  {}  {}  {}".format(filename, status, detail))
            else:
                log.info("  {}  {}".format(filename, status))
    except Exception:
        pass


# --- Inline data (GAMS parameter / table in code) ---

def i01_plug_hybr_fract_data() -> Dict[int, float]:
    """Plug-in hybrid fraction of mileage by year (GAMS i01PlugHybrFractData)."""
    base = 0.5
    step = 0.004444
    return {y: min(0.692593, base + (y - 2010) * step) for y in range(2010, 2101)}


def i01_cap_data_load_fac_each_transp() -> Dict[tuple, float]:
    """Capacity and load factor per transport mode (GAMS i01CapDataLoadFacEachTransp)."""
    # (TRANSE, TRANSUSE) -> value
    table = [
        ("PC", "CAP", 4), ("PC", "LF", 0.5),
        ("PB", "CAP", 40), ("PB", "LF", 0.4),
        ("PT", "CAP", 300), ("PT", "LF", 0.4),
        ("PN", "CAP", 300), ("PN", "LF", 0.5),
        ("PA", "CAP", 180), ("PA", "LF", 0.65),
        ("GU", "CAP", 5), ("GU", "LF", 0.7),
        ("GT", "CAP", 600), ("GT", "LF", 0.8),
        ("GN", "CAP", 1500), ("GN", "LF", 0.9),
    ]
    return {(t, u): v for t, u, v in table}


def i01_init_spec_fuel_cons_data() -> Dict[tuple, float]:
    """Initial SFC (TRANSE, TTECH, EF) — GAMS i01InitSpecFuelConsData."""
    table = [
        ("PT", "TGDO", "GDO", 11), ("PT", "TGDO", "BGDO", 11), ("PT", "TH2F", "H2F", 8.9), ("PT", "TELC", "ELC", 7),
        ("PA", "TKRS", "KRS", 20),
        ("PN", "TGDO", "GDO", 30), ("PN", "TGDO", "BGDO", 30), ("PN", "TH2F", "H2F", 43),
        ("PB", "TGSL", "GSL", 8), ("PB", "TGSL", "BGSL", 8), ("PB", "TGDO", "GDO", 7.8), ("PB", "TGDO", "BGDO", 7.8),
        ("PB", "TNGS", "NGS", 5.6), ("PB", "TNGS", "OGS", 5.6), ("PB", "TLPG", "LPG", 6.6), ("PB", "TELC", "ELC", 2.5), ("PB", "TH2F", "H2F", 4.3),
        ("GU", "TGSL", "GSL", 6), ("GU", "TGSL", "BGSL", 6), ("GU", "TLPG", "LPG", 5), ("GU", "TGDO", "GDO", 4), ("GU", "TGDO", "BGDO", 4),
        ("GU", "TNGS", "NGS", 2.8), ("GU", "TNGS", "OGS", 2.8), ("GU", "TH2F", "H2F", 1.3), ("GU", "TELC", "ELC", 1), ("GU", "TCHEVGDO", "GDO", 2.7),
        ("GT", "TGDO", "GDO", 1.9), ("GT", "TGDO", "BGDO", 1.9), ("GT", "TH2F", "H2F", 1.5), ("GT", "TELC", "ELC", 1.9),
        ("GN", "TGSL", "GSL", 2), ("GN", "TGSL", "BGSL", 2), ("GN", "TGDO", "GDO", 2.5), ("GN", "TGDO", "BGDO", 2.5), ("GN", "TH2F", "H2F", 1.5),
    ]
    return {(t, tech, e): v for t, tech, e, v in table}


# --- CSV/CSVR loaders ---

def load_i01_gdp(data_dir: Path) -> Dict[tuple, float]:
    """i01GDP(YTIME, allCy). CSV/CSVR: rows (year, country) or years as columns."""
    p = _path(data_dir, "iGDP.csvr") or _path(data_dir, "iGDP.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_col = next((c for c in cols if str(c).lower() in ("ytime", "year", "y")), cols[0])
    cy_col = next((c for c in cols if str(c).lower() in ("allcy", "cy", "country")), cols[1] if len(cols) > 1 else None)
    val_col = next((c for c in cols if c not in (year_col, cy_col) and str(c).replace(".", "").replace("-", "").isdigit() is False), cols[-1])
    out = {}
    for _, row in df.iterrows():
        try:
            y = int(float(row[year_col]))
            cy = str(row[cy_col]) if cy_col else str(row[cols[1]])
            v = float(row[val_col]) if val_col else float(row[cols[2]])
            out[(y, cy)] = v
        except (ValueError, TypeError, IndexError):
            continue
    return out


def load_i01_pop(data_dir: Path) -> Dict[tuple, float]:
    """i01Pop(YTIME, allCy)."""
    p = _path(data_dir, "iPop.csvr") or _path(data_dir, "iPop.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_col = next((c for c in cols if str(c).lower() in ("ytime", "year", "y")), cols[0])
    cy_col = next((c for c in cols if str(c).lower() in ("allcy", "cy", "country")), cols[1] if len(cols) > 1 else None)
    val_col = next((c for c in cols if c not in (year_col, cy_col)), cols[-1])
    out = {}
    for _, row in df.iterrows():
        try:
            y = int(float(row[year_col]))
            cy = str(row[cy_col]) if cy_col else str(row[cols[1]])
            v = float(row[val_col])
            out[(y, cy)] = v
        except (ValueError, TypeError, IndexError):
            continue
    return out


def load_i01_new_reg(data_dir: Path) -> Dict[tuple, float]:
    """i01NewReg(allCy, YTIME)."""
    p = _path(data_dir, "iNewReg.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    cy_col = next((c for c in cols if str(c).lower() in ("allcy", "cy", "country")), cols[0])
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    out = {}
    for _, row in df.iterrows():
        cy = str(row[cy_col]) if cy_col else str(row[idx_cols[0]])
        for ycol in year_cols:
            try:
                out[(cy, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_i01_stock_pc(data_dir: Path) -> Dict[tuple, float]:
    """i01StockPC(allCy, TTECH, YTIME)."""
    p = _path(data_dir, "iStockPC.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    if len(idx_cols) < 2:
        return {}
    out = {}
    for _, row in df.iterrows():
        cy = str(row[idx_cols[0]])
        tech = str(row[idx_cols[1]])
        for ycol in year_cols:
            try:
                out[(cy, tech, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_i01_data_share_blend(data_dir: Path) -> Dict[tuple, float]:
    """i01DataShareBlend(allCy, TRANSE, EF, YTIME)."""
    p = _path(data_dir, "iDataShareBlend.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    if len(idx_cols) < 3:
        return {}
    out = {}
    for _, row in df.iterrows():
        cy = str(row[idx_cols[0]])
        tran = str(row[idx_cols[1]])
        ef = str(row[idx_cols[2]])
        for ycol in year_cols:
            try:
                out[(cy, tran, ef, int(ycol))] = float(row[ycol])
            except (TypeError, ValueError):
                continue
    return out


def load_i01_sfc_pc(data_dir: Path) -> Dict[tuple, float]:
    """i01SFCPC(allCy, TTECH, EF, YTIME). Copy BGSL=GSL, BGDO=GDO, OGS=NGS."""
    p = _path(data_dir, "iSFC.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    if len(idx_cols) < 3:
        return {}
    out = {}
    for _, row in df.iterrows():
        cy = str(row[idx_cols[0]])
        tech = str(row[idx_cols[1]])
        ef = str(row[idx_cols[2]])
        for ycol in year_cols:
            try:
                v = float(row[ycol])
                out[(cy, tech, ef, int(ycol))] = v
                if ef == "GSL":
                    out[(cy, tech, "BGSL", int(ycol))] = v
                elif ef == "GDO":
                    out[(cy, tech, "BGDO", int(ycol))] = v
                elif ef == "NGS":
                    out[(cy, tech, "OGS", int(ycol))] = v
            except (TypeError, ValueError):
                continue
    return out


def load_im_data_trans_tech(data_dir: Path) -> Dict[tuple, float]:
    """imDataTransTech(TRANSE, TECH, ECONCHAR, YTIME). We need LFT for i01TechLft."""
    p = _path(data_dir, "iDataTransTech.csv")
    if not p:
        return {}
    df = pd.read_csv(p)
    cols = df.columns.tolist()
    year_cols = [c for c in cols if str(c).isdigit()]
    idx_cols = [c for c in cols if c not in year_cols]
    if len(idx_cols) < 3:
        return {}
    out = {}
    for _, row in df.iterrows():
        tran = str(row[idx_cols[0]])
        tech = str(row[idx_cols[1]])
        char = str(row[idx_cols[2]]) if len(idx_cols) > 2 else "LFT"
        for ycol in year_cols:
            try:
                v = float(row[ycol])
                out[(tran, tech, char, int(ycol))] = v
            except (TypeError, ValueError):
                continue
    return out


def load_transport_data(config: Any) -> Dict[str, Any]:
    """Load all transport input; return dict keyed by name. Missing files -> empty dict for that key."""
    data_dir = Path(config.data_dir)
    result = {}
    for name, filename, loader in [
        ("i01GDP", "iGDP.csvr", lambda: load_i01_gdp(data_dir)),
        ("i01Pop", "iPop.csvr", lambda: load_i01_pop(data_dir)),
        ("i01NewReg", "iNewReg.csv", lambda: load_i01_new_reg(data_dir)),
        ("i01StockPC", "iStockPC.csv", lambda: load_i01_stock_pc(data_dir)),
        ("i01DataShareBlend", "iDataShareBlend.csv", lambda: load_i01_data_share_blend(data_dir)),
        ("i01SFCPC", "iSFC.csv", lambda: load_i01_sfc_pc(data_dir)),
        ("imDataTransTech", "iDataTransTech.csv", lambda: load_im_data_trans_tech(data_dir)),
    ]:
        try:
            result[name] = loader()
            _log(filename, "OK" if result[name] else "EMPTY")
        except Exception as e:
            result[name] = {}
            _log(filename, "PARSE ERROR", str(e))
    result["i01PlugHybrFractData"] = i01_plug_hybr_fract_data()
    result["i01CapDataLoadFacEachTransp"] = i01_cap_data_load_fac_each_transp()
    result["i01InitSpecFuelConsData"] = i01_init_spec_fuel_cons_data()
    return result


def load_transport_data_into_model(
    m: Any,
    data: Dict[str, Any],
    core_sets_obj: Any,
    data_core: Optional[Dict[str, Any]] = None,
) -> None:
    """
    Push transport data into model Params. Compute i01GDPperCapita, i01ShareAnnMilePlugInHybrid,
    i01AvgVehCapLoadFac, i01TechLft, i01ShareBlend (from BLENDMAP + imFuelConsPerFueSub when available).
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    base_y = core_sets_obj.base_year()
    trans = list(core_sets.TRANSE)
    ttech = list(core_sets.TTECH)
    ef = list(core_sets.EF)
    datay = core_sets_obj.datay
    BLENDMAP = t_sets.BLENDMAP  # (EF_primary, EF_blended) e.g. (GSL, GSL), (GSL, BGSL)
    ROAD = t_sets.ROAD

    # i01GDP, i01Pop
    if data.get("i01GDP"):
        for (y, cy), v in data["i01GDP"].items():
            if cy in run_cy and y in ytime:
                m.i01GDP[y, cy] = v
    if data.get("i01Pop"):
        for (y, cy), v in data["i01Pop"].items():
            if cy in run_cy and y in ytime:
                m.i01Pop[y, cy] = v

    # i01GDPperCapita = i01GDP / i01Pop
    for y in ytime:
        for cy in run_cy:
            try:
                gdp = m.i01GDP[y, cy].value
                pop = m.i01Pop[y, cy].value
                if pop and pop > 0:
                    m.i01GDPperCapita[y, cy] = gdp / pop
            except (TypeError, ZeroDivisionError):
                pass

    # i01ShareAnnMilePlugInHybrid from i01PlugHybrFractData
    plug = data.get("i01PlugHybrFractData") or i01_plug_hybr_fract_data()
    for y in ytime:
        for cy in run_cy:
            if y in plug:
                m.i01ShareAnnMilePlugInHybrid[cy, y] = plug[y]

    # i01AvgVehCapLoadFac from i01CapDataLoadFacEachTransp
    cap_lf = data.get("i01CapDataLoadFacEachTransp") or i01_cap_data_load_fac_each_transp()
    for (tran, use), v in cap_lf.items():
        if tran in trans and use in core_sets.TRANSUSE:
            for cy in run_cy:
                for y in ytime:
                    m.i01AvgVehCapLoadFac[cy, tran, use, y] = v

    # i01TechLft from imDataTransTech (transport) or default 20
    trans_tech = data.get("imDataTransTech") or {}
    for (tran, tech, char, y), v in trans_tech.items():
        if char != "LFT":
            continue
        if tran in trans and tech in ttech and y in ytime:
            for cy in run_cy:
                m.i01TechLft[cy, tran, tech, y] = v
    for cy in run_cy:
        for tran in trans:
            for tech in ttech:
                if (tran, tech) not in core_sets.SECTTECH:
                    continue
                for y in ytime:
                    try:
                        if (tran, tech, "LFT", y) not in [(k[0], k[1], k[2], k[3]) for k in trans_tech if len(k) >= 4]:
                            pass  # keep default 20
                    except Exception:
                        pass

    # i01NewReg, i01StockPC
    if data.get("i01NewReg"):
        for (cy, y), v in data["i01NewReg"].items():
            if cy in run_cy and y in ytime:
                m.i01NewReg[cy, y] = v
    if data.get("i01StockPC"):
        for (cy, tech, y), v in data["i01StockPC"].items():
            if cy in run_cy and tech in ttech and y in ytime:
                m.i01StockPC[cy, tech, y] = v

    # i01SFCPC (and copy to base year for AN)
    if data.get("i01SFCPC"):
        for (cy, tech, e, y), v in data["i01SFCPC"].items():
            if cy in run_cy and tech in ttech and e in ef and y in ytime:
                m.i01SFCPC[cy, tech, e, y] = v
        for cy in run_cy:
            for tech in ttech:
                for e in ef:
                    for y in ytime:
                        if y not in datay and (cy, tech, e, base_y) in data.get("i01SFCPC", {}):
                            m.i01SFCPC[cy, tech, e, y] = data["i01SFCPC"][(cy, tech, e, base_y)]

    # i01InitSpecFuelConsData -> used in preloop for V01ConsSpecificFuel
    init_sfc = data.get("i01InitSpecFuelConsData") or i01_init_spec_fuel_cons_data()
    for (tran, tech, e), v in init_sfc.items():
        if tran in trans and tech in ttech and e in ef:
            try:
                m.i01InitSpecFuelConsData[tran, tech, e] = v
            except Exception:
                pass

    # i01ShareBlend: from imFuelConsPerFueSub + BLENDMAP when data_core has imFuelCons; else from i01DataShareBlend; then AN = base year; LAM/ROAD profile
    im_fuel_cons = (data_core or {}).get("imFuelCons") or {}
    if im_fuel_cons and hasattr(m, "imFuelConsPerFueSub"):
        # For each (cy, tran, y): for each EF2 in BLENDMAP primary, total = sum(imFuelCons(EFS) for EFS with BLENDMAP(EF2, EFS)); for each EF in group, share = imFuelCons(EF)/total
        for cy in run_cy:
            for tran in trans:
                for y in datay:
                    efs_in_sec = [e for e in ef if (tran, e) in core_sets.SECtoEF]
                    for e_prim, e_blend in BLENDMAP:
                        if e_blend not in efs_in_sec:
                            continue
                        group = [eb for (ep, eb) in BLENDMAP if ep == e_prim]
                        denom = sum(im_fuel_cons.get((cy, tran, eb, y), 0) for eb in group)
                        if denom and denom > 0:
                            for eb in group:
                                num = im_fuel_cons.get((cy, tran, eb, y), 0)
                                m.i01ShareBlend[cy, tran, eb, y] = num / denom
                    for e in efs_in_sec:
                        if not any((ep, e) in BLENDMAP for ep in ef):
                            m.i01ShareBlend[cy, tran, e, y] = 1.0
                for y in ytime:
                    if y not in datay:
                        for e in ef:
                            try:
                                m.i01ShareBlend[cy, tran, e, y] = m.i01ShareBlend[cy, tran, e, base_y].value or 0.0
                            except Exception:
                                pass
        for y in ytime:
            ord_y = core_sets_obj.year_to_ord.get(y, 14) if hasattr(core_sets_obj, "year_to_ord") else (ytime.index(y) + 1 if y in ytime else 14)
            for cy in run_cy:
                for tran in ROAD:
                    try:
                        base_bgdo = m.i01ShareBlend[cy, tran, "BGDO", base_y].value if base_y in ytime else 0
                        base_gdo = m.i01ShareBlend[cy, tran, "GDO", base_y].value if base_y in ytime else 0
                        base_bgsl = m.i01ShareBlend[cy, tran, "BGSL", base_y].value if base_y in ytime else 0
                        base_gsl = m.i01ShareBlend[cy, tran, "GSL", base_y].value if base_y in ytime else 0
                        if cy == "LAM":
                            m.i01ShareBlend[cy, tran, "BGDO", y] = (base_bgdo or 0) + 0.002 * (ord_y - 14)
                            m.i01ShareBlend[cy, tran, "GDO", y] = (base_gdo or 0) - 0.002 * (ord_y - 14)
                            m.i01ShareBlend[cy, tran, "BGSL", y] = (base_bgsl or 0) + 0.001 * (ord_y - 14)
                            m.i01ShareBlend[cy, tran, "GSL", y] = (base_gsl or 0) - 0.001 * (ord_y - 14)
                    except Exception:
                        pass
    elif data.get("i01DataShareBlend"):
        for (cy, tran, e, y), v in data["i01DataShareBlend"].items():
            if cy in run_cy and tran in trans and e in ef and y in ytime:
                m.i01ShareBlend[cy, tran, e, y] = v
        for cy in run_cy:
            for tran in trans:
                for y in ytime:
                    if y not in datay:
                        for e in ef:
                            try:
                                m.i01ShareBlend[cy, tran, e, y] = m.i01ShareBlend[cy, tran, e, base_y].value or 0.0
                            except Exception:
                                pass
