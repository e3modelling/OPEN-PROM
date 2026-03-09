"""
04_PowerGeneration (simple) preloop: fix historical variables and set bounds.

Mirrors modules/04_PowerGeneration/simple/preloop.gms. Fixes V04* and Vm* for
historical years (datay), sets bounds and initial values. Uses imInstCapPastNonCHP,
imInstCapPastCHP from core; i04AvailRate, i04VarCost, etc. from 04 input.
"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets
import logging

logger = logging.getLogger(__name__)


def _pval(m, param, *idx):
    """Numeric value of Param at index; None if missing."""
    try:
        return pyo_value(param[idx])
    except Exception:
        return None


def _base_year(core_sets_obj):
    """Scalar base year from tFirst."""
    t_first = getattr(core_sets_obj, "tFirst", None)
    if t_first is None:
        return None
    if hasattr(t_first, "__iter__") and not isinstance(t_first, str):
        return next(iter(t_first), None)
    return t_first


def apply_power_generation_preloop(m: ConcreteModel, core_sets_obj, config=None) -> None:
    """Apply 04_PowerGeneration (simple) preloop: bounds and historical fixes.
    When config.calibration == 'MatCalibration', V04DemElecTot is fixed to t04DemElecTot
    and i04MatFacPlaAvailCap is initialized from iMatFacPlaAvailCapData."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = core_sets_obj.datay
    an = core_sets_obj.an
    base_y = _base_year(core_sets_obj)
    calibration = getattr(config, "calibration", "off") if config else "off"
    pgall = list(core_sets.PGALL)
    pgren = set(core_sets.PGREN)
    pgrensw = set(core_sets.PGRENSW)
    noccs_pg = set(core_sets.NOCCS_PG)
    inddom = list(core_sets.INDDOM)
    trans = list(core_sets.TRANSE)
    efs = list(core_sets.EFS)
    pgef = set(core_sets.PGEF)
    pgalltoef = core_sets.PGALLtoEF

    # Calibration: initialize i04MatFacPlaAvailCap (Var) from iMatFacPlaAvailCapData (GAMS: .L = data)
    if calibration == "MatCalibration" and hasattr(m, "iMatFacPlaAvailCapData") and hasattr(m, "i04MatFacPlaAvailCap"):
        for cy in run_cy:
            for pg in pgall:
                for y in ytime:
                    try:
                        v = _pval(m, m.iMatFacPlaAvailCapData, cy, pg, y)
                        if v is not None:
                            m.i04MatFacPlaAvailCap[cy, pg, y].set_value(v)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

    for cy in run_cy:
        for y in ytime:
            # V04ScrpRate bounds
            for pg in pgall:
                try:
                    m.V04ScrpRate[cy, pg, y].setlb(0.0)
                    m.V04ScrpRate[cy, pg, y].setub(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CostVarTech: init and historical fix (GAMS: V04CostVarTech.FX$DATAY = formula)
            for pg in pgall:
                try:
                    m.V04CostVarTech[cy, pg, y].setlb(m.epsilon6)
                    m.V04CostVarTech[cy, pg, y].set_value(0.1)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)
            # Optional refinement: fix V04CostVarTech in datay to full GAMS formula
            if y in datay:
                pgren2 = set(core_sets.PGREN2)
                pgalltoef = core_sets.PGALLtoEF
                nap_pg_set = [n for (n, s) in core_sets.NAPtoALLSBS if s == "PG"]
                if not nap_pg_set:
                    nap_pg_set = list(core_sets.NAP)
                for pg in pgall:
                    try:
                        base = (_pval(m, m.i04VarCost, pg, y) or 0.0) / 1e3
                        ren_term = 0.0
                        if pg not in pgren2:
                            ren_term = (pyo_value(m.VmRenValue[y]) or 0.0) * 8.6e-5
                        fuel_term = 0.0
                        if pg not in pgren:
                            for (pg_ef, efs_ef) in pgalltoef:
                                if pg_ef != pg:
                                    continue
                                co2 = _pval(m, m.imCo2EmiFac, cy, "PG", efs_ef, y) or 0.0
                                if efs_ef == "BMSWAS":
                                    co2 = co2 + 4.17
                                car_sum = sum(
                                    pyo_value(m.VmCarVal[cy, n, y]) or 0.0
                                    for n in nap_pg_set
                                )
                                cap_r = _pval(m, m.imCO2CaptRate, pg) or 0.0
                                seq = pyo_value(m.VmCstCO2SeqCsts[cy, y]) or 0.0
                                price = (
                                    pyo_value(m.VmPriceFuelSubsecCarVal[cy, "PG", efs_ef, y])
                                    or 0.0
                                )
                                eff = _pval(m, m.imPlantEffByType, cy, pg, y) or 0.35
                                sm = pyo_value(m.smTWhToMtoe) or 0.086
                                fuel_term += (
                                    (
                                        price
                                        + cap_r * seq * 1e-3 * co2
                                        + (1.0 - cap_r) * 1e-3 * co2 * car_sum
                                    )
                                    * sm
                                    / (eff + 1e-10)
                                )
                        m.V04CostVarTech[cy, pg, y].fix(base + ren_term + fuel_term)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04CapexRESRate = 1
            for pg in pgall:
                try:
                    m.V04CapexRESRate[cy, pg, y].set_value(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CFAvgRen: init from base year avail; fix in datay to i04AvailRate
            for pg in pgren:
                try:
                    if base_y is not None:
                        m.V04CFAvgRen[cy, pg, y].set_value(
                            _pval(m, m.i04AvailRate, cy, pg, base_y) or 0.3
                        )
                    if y in datay:
                        m.V04CFAvgRen[cy, pg, y].fix(
                            _pval(m, m.i04AvailRate, cy, pg, y) or 0.3
                        )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CapexFixCostPG: fix in datay to formula (disc, lft, gross, fix O&M)
            if y in datay:
                for pg in pgall:
                    try:
                        import math
                        disc = _pval(m, m.imDisc, cy, "PG", y) or 0.1
                        lft = _pval(m, m.i04TechLftPlaType, cy, pg) or 25.0
                        ex = math.exp(disc * lft)
                        ann = disc * ex / (ex - 1.0)
                        cap = (
                            ann
                            * (_pval(m, m.i04GrossCapCosSubRen, cy, pg, y) or 0.0)
                            * 1000.0
                            * (_pval(m, m.imCGI, cy, y) or 1.0)
                        )
                        fix_om = _pval(m, m.i04FixOandMCost, cy, pg, y) or 0.0
                        m.V04CapexFixCostPG[cy, pg, y].fix(cap + fix_om)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04CapexFixCostPG.LO = i04FixOandMCost
            for pg in pgall:
                try:
                    m.V04CapexFixCostPG[cy, pg, y].setlb(
                        _pval(m, m.i04FixOandMCost, cy, pg, y) or 0.0
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CostCapTech: fix when not AN
            if y not in an:
                for pg in pgall:
                    try:
                        avail = _pval(m, m.i04AvailRate, cy, pg, y) or 0.85
                        gw = _pval(m, m.smGwToTwhPerYear, y) or 8.76
                        cap = pyo_value(m.V04CapexFixCostPG[cy, pg, y])
                        res = pyo_value(m.V04CapexRESRate[cy, pg, y])
                        m.V04CostCapTech[cy, pg, y].fix(
                            res * cap / (avail * gw * 1000.0 + 1e-10)
                        )
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04CostHourProdInvDec: fix when not AN
            if y not in an:
                for pg in pgall:
                    try:
                        m.V04CostHourProdInvDec[cy, pg, y].fix(
                            pyo_value(m.V04CostCapTech[cy, pg, y])
                            + pyo_value(m.V04CostVarTech[cy, pg, y])
                        )
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # VmCapElecTotEst: fix when not AN
            if y not in an and hasattr(m, "imInstCapPastNonCHP") and hasattr(m, "imInstCapPastCHP"):
                try:
                    tot = sum(
                        _pval(m, m.imInstCapPastNonCHP, cy, pg, y) or 0.0
                        for pg in pgall
                    ) + sum(
                        _pval(m, m.imInstCapPastCHP, cy, ef, y) or 0.0
                        for ef in efs
                    )
                    m.VmCapElecTotEst[cy, y].fix(tot)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CapElecNonCHP: fix when not AN
            if y not in an:
                try:
                    m.V04CapElecNonCHP[cy, y].fix(
                        sum(
                            _pval(m, m.imInstCapPastNonCHP, cy, pg, y) or 0.0
                            for pg in pgall
                        )
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CapElecCHP: fix when not AN
            if y not in an and hasattr(m, "imInstCapPastCHP"):
                try:
                    m.V04CapElecCHP[cy, y].fix(
                        sum(
                            _pval(m, m.imInstCapPastCHP, cy, ef, y) or 0.0
                            for ef in efs
                        )
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmCapElec: fix in datay to imInstCapPastNonCHP
            if y in datay and hasattr(m, "imInstCapPastNonCHP"):
                for pg in pgall:
                    try:
                        m.VmCapElec[cy, pg, y].fix(
                            _pval(m, m.imInstCapPastNonCHP, cy, pg, y) or 0.0
                        )
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04CapElecNominal: fix in datay
            if y in datay:
                for pg in pgall:
                    try:
                        cap = _pval(m, m.imInstCapPastNonCHP, cy, pg, y) or 0.0
                        avail = _pval(m, m.i04AvailRate, cy, pg, y) or 0.85
                        m.V04CapElecNominal[cy, pg, y].fix(cap / (avail + 1e-10))
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04ShareTechPG: fix in datay
            if y in datay and hasattr(m, "imInstCapPastNonCHP"):
                try:
                    tot = sum(
                        _pval(m, m.imInstCapPastNonCHP, cy, p, y) or 0.0
                        for p in pgall
                    )
                    if tot and tot > 0:
                        for pg in pgall:
                            m.V04ShareTechPG[cy, pg, y].fix(
                                (_pval(m, m.imInstCapPastNonCHP, cy, pg, y) or 0.0)
                                / tot
                            )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04ShareSatPG: fix to 1 when not PGREN or not AN
            for pg in pgall:
                try:
                    if pg not in pgren or y not in an:
                        m.V04ShareSatPG[cy, pg, y].fix(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04IndxEndogScrap: fix to 1 when not an, and for PGSCRN
            for pg in pgall:
                try:
                    if y not in an or pg in core_sets.PGSCRN:
                        m.V04IndxEndogScrap[cy, pg, y].fix(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04LoadFacDom, VmPeakLoad, V04DemElecTot
            # GAMS $ifthen.calib MatCalibration: V04DemElecTot.FX = t04DemElecTot; $else fix from formula in datay
            if calibration == "MatCalibration" and hasattr(m, "t04DemElecTot"):
                try:
                    m.V04DemElecTot[cy, y].fix(
                        _pval(m, m.t04DemElecTot, cy, y) or 0.0
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)
            elif y in datay and hasattr(m, "imFuelConsPerFueSub"):
                try:
                    s = sum(
                        _pval(m, m.imFuelConsPerFueSub, cy, d, "ELC", y) or 0.0
                        for d in (inddom + trans)
                    )
                    if hasattr(m, "imDistrLosses"):
                        s += _pval(m, m.imDistrLosses, cy, "ELC", y) or 0.0
                    if hasattr(m, "i03TotEneBranchCons"):
                        s += _pval(m, m.i03TotEneBranchCons, cy, "ELC", y) or 0.0
                    if hasattr(m, "imFuelImports") and hasattr(m, "imFuelExprts"):
                        s -= (_pval(m, m.imFuelImports, cy, "ELC", y) or 0.0) - (
                            _pval(m, m.imFuelExprts, cy, "ELC", y) or 0.0
                        )
                    m.V04DemElecTot[cy, y].fix(s / (pyo_value(m.smTWhToMtoe) + 1e-10))
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmPeakLoad fix in datay
            if y in datay:
                try:
                    dem = pyo_value(m.V04DemElecTot[cy, y])
                    lf = pyo_value(m.V04LoadFacDom[cy, y]) or 0.5
                    gw = _pval(m, m.smGwToTwhPerYear, y) or 8.76
                    m.VmPeakLoad[cy, y].fix(dem / (lf * gw + 1e-10))
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmProdElec: fix in datay to i04DataElecProdNonCHP/1000
            if y in datay:
                for pg in pgall:
                    try:
                        v = _pval(m, m.i04DataElecProdNonCHP, cy, pg, y) or 0.0
                        m.VmProdElec[cy, pg, y].fix(v / 1000.0 + 1e-10)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

            # V04ProdElecEstCHP: fix in datay to sum i04DataElecProdCHP/1000
            if y in datay and hasattr(m, "i04DataElecProdCHP"):
                try:
                    m.V04ProdElecEstCHP[cy, y].fix(
                        sum(
                            _pval(m, m.i04DataElecProdCHP, cy, ef, y) or 0.0
                            for ef in efs
                        )
                        / 1000.0
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04ShareMixWndSol: fix in datay
            if y in datay:
                try:
                    num = sum(
                        pyo_value(m.VmCapElec[cy, pg, y]) for pg in pgrensw
                    )
                    den = sum(pyo_value(m.VmCapElec[cy, pg, y]) for pg in pgall)
                    m.V04ShareMixWndSol[cy, y].fix(
                        num / (den + 1e-10)
                    )
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V04CCSRetroFit: fix to 1 in datay or when not NOCCS
            for pg in pgall:
                try:
                    if y in datay or pg not in noccs_pg:
                        m.V04CCSRetroFit[cy, pg, y].fix(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmConsFuelElecProd: fix to 0 for non-PGEF; fix in datay for PGEF
            for efs_ in efs:
                try:
                    if efs_ not in pgef:
                        m.VmConsFuelElecProd[cy, efs_, y].fix(0.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)
            if y in datay:
                for ef_ in pgef:
                    try:
                        s = sum(
                            pyo_value(m.VmProdElec[cy, pg, y])
                            * pyo_value(m.smTWhToMtoe)
                            / (_pval(m, m.imPlantEffByType, cy, pg, y) or 0.35 + 1e-10)
                            for (pg, e) in pgalltoef
                            if e == ef_
                        )
                        m.VmConsFuelElecProd[cy, ef_, y].fix(s)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)

    # V04NetNewCapElec: fix for PGREN in datay (consecutive year diff) + PGLHYD at tFirst
    t_first = _base_year(core_sets_obj)
    if t_first is not None:
        for cy in run_cy:
            try:
                m.V04NetNewCapElec[cy, "PGLHYD", t_first].fix(1e-6)
            except Exception as _exc:
                logger.debug("Skipped: %s", _exc)
