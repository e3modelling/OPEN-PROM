"""
Module 07_Emissions (legacy): preloop — fix historical (datay) emissions variables.

Mirrors modules/07_Emissions/legacy/preloop.gms. Fixes V07GrossEmissCO2Supply (H2INFR=0 when index exists;
for datay: from transformation/own cons minus CCS terms), V07GrossEmissCO2Demand (from imFuelConsPerFueSub*imCo2EmiFac),
V07EmiActBySrcRegTim (to i07DataCh4N2OFEmis).
"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets
import logging

logger = logging.getLogger(__name__)

_EPS = 1e-10


def _pval(p, *idx):
    """Return numeric value of a Param at the given index; 0.0 if missing or not numeric."""
    try:
        v = p[idx]
        return float(pyo_value(v)) if hasattr(v, "value") else float(v)
    except Exception:
        return 0.0


def apply_emissions_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """
    Apply 07_Emissions preloop: fix historical (datay) values so the solver does not change them.

    Order (GAMS preloop.gms):
    1. V07GrossEmissCO2Supply.FX(runCy,"H2INFR",YTIME) = 0 (if index exists).
    2. V07GrossEmissCO2Supply.FX(runCy,SSBS,YTIME)$DATAY = RHS from transformation input, own consumption, minus PG/H2P CCS terms, times imCo2EmiFac.
    3. V07GrossEmissCO2Demand.FX(...)$DATAY = sum over EF of imFuelConsPerFueSub * imCo2EmiFac.
    4. V07EmiActBySrcRegTim.FX(...)$DATAY = i07DataCh4N2OFEmis (baseline; no abatement in historical years).
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = set(getattr(core_sets_obj, "datay", []))
    ssbs = list(core_sets.SSBS)
    dsbs = list(core_sets.DSBS)
    efs = list(core_sets.EFS) if hasattr(core_sets, "EFS") else list(core_sets.EF)
    ssbsemit = set(core_sets.SSBSEMIT)

    # V07GrossEmissCO2Supply.FX(runCy,"H2INFR",YTIME) = 0 (GAMS); only if index exists
    if hasattr(m, "V07GrossEmissCO2Supply"):
        for cy in run_cy:
            for y in ytime:
                try:
                    m.V07GrossEmissCO2Supply[cy, "H2INFR", y].fix(0.0)
                except (KeyError, TypeError):
                    pass

    # V07GrossEmissCO2Supply.FX(runCy,SSBS,YTIME)$DATAY = SUM(EFS, (...)* imCo2EmiFac)
    if hasattr(m, "V07GrossEmissCO2Supply") and datay:
        for cy in run_cy:
            for ss in ssbs:
                for y in ytime:
                    if y not in datay:
                        continue
                    rhs = 0.0
                    for efs_ in efs:
                        term = 0.0
                        if ss in ssbsemit and hasattr(m, "i03InpTotTransfProcess"):
                            term += -_pval(m.i03InpTotTransfProcess, cy, ss, efs_, y)
                        if hasattr(m, "i03DataOwnConsEne"):
                            term += _pval(m.i03DataOwnConsEne, cy, ss, efs_, y)
                        # PG: subtract CO2 captured by CCS plants (VmProdElec * smTWhToMtoe / eff * imCo2EmiFac * capture rate)
                        if ss == "PG" and hasattr(m, "VmProdElec") and hasattr(m, "imPlantEffByType") and hasattr(m, "imCO2CaptRate"):
                            try:
                                from core import sets as cs
                                pgalltoef = getattr(cs, "PGALLtoEF", set())
                                for (ccs, pgef) in (pgalltoef or []):
                                    if pgef == efs_:
                                        prod = pyo_value(m.VmProdElec[cy, ccs, y]) or 0.0
                                        eff = _pval(m.imPlantEffByType, cy, ccs, y) or 1.0
                                        capt = pyo_value(getattr(m, "V04CO2CaptRate", m.imCO2CaptRate)[cy, ccs, y]) if hasattr(m, "V04CO2CaptRate") else _pval(m.imCO2CaptRate, cy, ccs, y)
                                        term -= prod * (getattr(m, "smTWhToMtoe", 0.086) or 0.086) / (eff + _EPS) * _pval(m.imCo2EmiFac, cy, "PG", efs_, y) * capt
                            except Exception as _exc:
                                logger.debug("Skipped: %s", _exc)
                        # H2P: subtract H2 production with CCS (VmProdH2 / eff * V05CaptRateH2)
                        if ss == "H2P" and hasattr(m, "VmProdH2") and hasattr(m, "i05EffH2Prod"):
                            try:
                                from core import sets as cs
                                h2techeftoef = getattr(cs, "H2TECHEFtoEF", set())
                                for (h2ccs, efs_h2) in (h2techeftoef or []):
                                    if efs_h2 == efs_:
                                        prod = pyo_value(m.VmProdH2[cy, h2ccs, y]) or 0.0
                                        eff = _pval(m.i05EffH2Prod, cy, h2ccs, y) or 1.0
                                        capt = pyo_value(getattr(m, "V05CaptRateH2", m.i05EffH2Prod)[cy, h2ccs, y]) if hasattr(m, "V05CaptRateH2") else 0.0
                                        term -= prod / (eff + _EPS) * capt
                            except Exception as _exc:
                                logger.debug("Skipped: %s", _exc)
                        fac = _pval(m.imCo2EmiFac, cy, "PG", efs_, y)
                        rhs += term * fac
                    try:
                        m.V07GrossEmissCO2Supply[cy, ss, y].fix(rhs)
                    except (KeyError, TypeError):
                        pass

    # V07GrossEmissCO2Demand.FX(runCy,DSBS,YTIME)$DATAY = SUM(EF, imFuelConsPerFueSub*imCo2EmiFac)
    if hasattr(m, "V07GrossEmissCO2Demand") and hasattr(m, "imFuelConsPerFueSub") and datay:
        for cy in run_cy:
            for ds in dsbs:
                for y in ytime:
                    if y not in datay:
                        continue
                    rhs = sum(
                        _pval(m.imFuelConsPerFueSub, cy, ds, ef, y) * _pval(m.imCo2EmiFac, cy, ds, ef, y)
                        for ef in efs
                    )
                    try:
                        m.V07GrossEmissCO2Demand[cy, ds, y].fix(rhs)
                    except (KeyError, TypeError):
                        pass

    # V07EmiActBySrcRegTim.FX(...)$DATAY = i07DataCh4N2OFEmis
    if hasattr(m, "V07EmiActBySrcRegTim") and hasattr(m, "i07DataCh4N2OFEmis") and datay:
        e07src = list(core_sets.E07SrcMacAbate)
        for cy in run_cy:
            for src in e07src:
                for y in ytime:
                    if y not in datay:
                        continue
                    try:
                        v = _pval(m.i07DataCh4N2OFEmis, cy, src, y)
                        m.V07EmiActBySrcRegTim[cy, src, y].fix(v)
                    except (KeyError, TypeError):
                        pass
