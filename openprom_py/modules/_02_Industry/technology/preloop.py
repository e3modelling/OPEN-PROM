"""
Industry (technology) module — preloop: fix historical variable values.

Mirrors 02_Industry/technology/preloop.gms. For years not in the solution
horizon (not in `an`), we fix Industry variables from base data so that
only the forward horizon is solved. Also sets bounds and initial values
for VmConsFuel, V02VarCostTech, V02CapCostTech, V02CostTech.
"""
from pyomo.core import ConcreteModel

from core import sets as core_sets
import logging

logger = logging.getLogger(__name__)


def _in_an(core_sets_obj, y):
    """True if y is in the solution horizon (an)."""
    return y in core_sets_obj.time


def apply_industry_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """
    Apply Industry (technology) preloop: fix historical values and set bounds.

    - V02FinalElecNonSubIndTert, V02UsefulElecNonSubIndTert: fixed from
      imFuelConsPerFueSub and imShrNonSubElecInTotElecDem for non-an years.
    - V02EquipCapTechSubsec: fixed from imFuelConsPerFueSub / utilization for non-an.
    - V02DemSubUsefulSubsec: fixed from sum of equipment * conversion * util for non-an.
    - VmConsFuel: bounds and fix to imFuelConsPerFueSub for datay; zero for TRANSE/CDR/HEATPUMP.
    - V02VarCostTech, V02CapCostTech, V02CostTech: fixed for datay from formulas/levels.
    """
    # --- Commented out in GAMS (02_Industry/technology/preloop.gms) ---
    # $ontext: V02RemEquipCapTechSubsec, V02DemUsefulSubsecRemTech, V02GapUsefulDemSubsec (levels)
    # $ontext: V02ShareTechNewEquipUseful, V02EquipCapTechSubsec (levels)
    # *V02EquipCapTechSubsec.FX(...) = imFuelConsPerFueSub(...) * (1-imShrNonSubElecInTotElecDem(...));  (TELC only, alternate)
    # *V02DemSubUsefulSubsec.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = max(imTotFinEneDemSubBaseYr(...) - V02UsefulElecNonSubIndTert.L(...), 1e-5) * 0.5;
    # *V02DemSubUsefulSubsec.FX(runCy,"HOU",YTIME)$(not An(YTIME)) = max(...) * 0.8;
    # *i02Share(...) = (imFuelConsPerFueSub/...) / V02EquipCapTechSubsec(...);
    # *vmConsTotElecInd.FX(...) = SUM(INDSE, VmConsElecNonSubIndTert.l(...));
    # *vmDemFinSubFuelInd.FX(...) = SUM(INDSE, VmDemFinSubFuelSubsec.L(...));

    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = core_sets_obj.datay
    dsbs = list(core_sets.DSBS)
    itech = list(core_sets.ITECH)
    ef = list(core_sets.EF)
    inddom = list(core_sets.INDDOM)
    sectech = core_sets.SECTTECH
    itechtoef = core_sets.ITECHtoEF
    TRANSE = set(core_sets.TRANSE)
    CDR = set(core_sets.CDR)
    CCSTECH = set(core_sets.CCSTECH)
    TSTEAM = set(core_sets.TSTEAM)

    def _pval(p, *idx):
        """Numeric value of a Param at index, or 0.0."""
        try:
            v = p[idx].value
            return float(v) if v is not None else 0.0
        except (KeyError, TypeError):
            return 0.0

    # V02FinalElecNonSubIndTert, V02UsefulElecNonSubIndTert: fix for non-an
    for cy in run_cy:
        for ind in inddom:
            for y in ytime:
                if _in_an(core_sets_obj, y):
                    continue
                try:
                    fin_elc = _pval(m.imFuelConsPerFueSub, cy, ind, "ELC", y)
                    shr_nonsub = _pval(m.imShrNonSubElecInTotElecDem, cy, ind)
                    val_fin = fin_elc * shr_nonsub or 0.1
                    m.V02FinalElecNonSubIndTert[cy, ind, y].fix(val_fin)
                except (KeyError, TypeError):
                    m.V02FinalElecNonSubIndTert[cy, ind, y].fix(0.1)
                try:
                    usc = _pval(m.imUsfEneConvSubTech, cy, ind, "TELC", y) or 1.0
                    val_usc = m.V02FinalElecNonSubIndTert[cy, ind, y].value * usc
                    m.V02UsefulElecNonSubIndTert[cy, ind, y].fix(val_usc if val_usc else 0.1)
                except (KeyError, TypeError):
                    m.V02UsefulElecNonSubIndTert[cy, ind, y].fix(0.1)

    # V02EquipCapTechSubsec: fix for non-an (from imFuelConsPerFueSub / util)
    for cy in run_cy:
        for sb in dsbs:
            if sb in TRANSE or sb in CDR:
                continue
            for tech in itech:
                if (sb, tech) not in sectech:
                    continue
                for y in ytime:
                    if _in_an(core_sets_obj, y):
                        continue
                    if tech in CCSTECH:
                        m.V02EquipCapTechSubsec[cy, sb, tech, y].fix(0.0)
                        continue
                    try:
                        util = _pval(m.i02util, cy, sb, tech, y) or 1.0
                        if tech == "TELC":
                            fin_elc = _pval(m.imFuelConsPerFueSub, cy, sb, "ELC", y)
                            shr_nonsub = _pval(m.imShrNonSubElecInTotElecDem, cy, sb)
                            num = fin_elc * (1.0 - shr_nonsub)
                            n_tech_elc = sum(
                                1 for t in itech if (sb, t) in sectech and (t, "ELC") in itechtoef
                            )
                            num = num / max(n_tech_elc, 1)
                        else:
                            num = 0.0
                            for e in ef:
                                if (tech, e) not in itechtoef:
                                    continue
                                fc = _pval(m.imFuelConsPerFueSub, cy, sb, e, y)
                                n_tech_ef = sum(
                                    1 for t in itech
                                    if (sb, t) in sectech and (t, e) in itechtoef and t not in CCSTECH
                                )
                                num += fc / max(n_tech_ef, 1)
                        m.V02EquipCapTechSubsec[cy, sb, tech, y].fix(
                            (num / util) if (num and util) else 0.1
                        )
                    except (KeyError, TypeError):
                        m.V02EquipCapTechSubsec[cy, sb, tech, y].fix(0.1)

    # V02DemSubUsefulSubsec: fix for non-an from sum(equip * usc * util)
    for cy in run_cy:
        for sb in inddom:
            for y in ytime:
                if _in_an(core_sets_obj, y):
                    continue
                try:
                    val = sum(
                        (m.V02EquipCapTechSubsec[cy, sb, tech, y].value or 0.0)
                        * _pval(m.imUsfEneConvSubTech, cy, sb, tech, y)
                        * _pval(m.i02util, cy, sb, tech, y)
                        for tech in itech
                        if (sb, tech) in sectech
                    )
                    m.V02DemSubUsefulSubsec[cy, sb, y].fix(val if val else 1.0)
                except (KeyError, TypeError):
                    m.V02DemSubUsefulSubsec[cy, sb, y].fix(1.0)
        for sbn in core_sets.NENSE:
            for y in ytime:
                if _in_an(core_sets_obj, y):
                    continue
                try:
                    val = sum(
                        _pval(m.imFuelConsPerFueSub, cy, sbn, e, y)
                        for e in ef if (sbn, e) in core_sets.SECtoEF
                    )
                    m.V02DemSubUsefulSubsec[cy, sbn, y].fix(max(val, 1e-5) if val else 1e-5)
                except (KeyError, TypeError):
                    m.V02DemSubUsefulSubsec[cy, sbn, y].fix(1e-5)

    # VmConsFuel: bounds and fix for datay (non-transport, non-CDR)
    for cy in run_cy:
        for sb in dsbs:
            for e in ef:
                for y in ytime:
                    if sb in TRANSE or sb in CDR:
                        m.VmConsFuel[cy, sb, e, y].fix(0.0)
                    elif y in datay:
                        try:
                            m.VmConsFuel[cy, sb, e, y].fix(
                                _pval(m.imFuelConsPerFueSub, cy, sb, e, y)
                            )
                        except (KeyError, TypeError):
                            m.VmConsFuel[cy, sb, e, y].fix(0.0)

    # V02VarCostTech, V02CapCostTech, V02CostTech: fix for datay (simplified)
    for cy in run_cy:
        for sb in dsbs:
            if sb in TRANSE or sb in CDR:
                continue
            for tech in itech:
                if (sb, tech) not in sectech:
                    continue
                for y in ytime:
                    if y not in datay:
                        continue
                    try:
                        disc = _pval(m.imDisc, cy, sb, y) if tech not in TSTEAM else _pval(m.imDisc, cy, "OI", y)
                        lft = m.VmLft[cy, sb, tech, y].value or 20.0
                        from math import exp

                        num = disc * exp(disc * lft) / (exp(disc * lft) - 1.0 + 1e-12)
                        cap = _pval(m.imCapCostTech, cy, sb, tech, y) * _pval(m.imCGI, cy, y)
                        fom = _pval(m.imFixOMCostTech, cy, sb, tech, y) / m.sUnitToKUnit.value
                        usc = _pval(m.imUsfEneConvSubTech, cy, sb, tech, y)
                        m.V02CapCostTech[cy, sb, tech, y].fix((num * cap + fom) / (usc + 1e-10))
                    except Exception:
                        m.V02CapCostTech[cy, sb, tech, y].fix(1.0)
                    try:
                        m.V02VarCostTech[cy, sb, tech, y].fix(2.0)
                    except Exception as _exc:
                        logger.debug("Skipped: %s", _exc)
                    try:
                        m.V02CostTech[cy, sb, tech, y].fix(
                            m.V02CapCostTech[cy, sb, tech, y].value + m.V02VarCostTech[cy, sb, tech, y].value
                        )
                    except Exception:
                        m.V02CostTech[cy, sb, tech, y].fix(1.0)
