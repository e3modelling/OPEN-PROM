"""
05_Hydrogen (legacy) preloop: bounds and historical fixes.

Mirrors modules/05_Hydrogen/legacy/preloop.gms. Sets bounds on V05GapShareH2Tech1/2,
V05DemGapH2, VmDemTotH2, VmProdH2, V05ScrapLftH2Prod, V05CostProdH2Tech, V05ShareCCSH2Prod,
V05ShareNoCCSH2Prod, VmConsFuelH2Prod, V05CostProdCCSNoCCSH2Prod, VmCostAvgProdH2,
V05PremRepH2Prod, V05CaptRateH2; fixes for datay where applicable.
Also: VmConsFuelTechH2Prod.FX at base year = VmProdH2.L/i05EffH2Prod (GAMS parity).
"""
from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets
import logging

logger = logging.getLogger(__name__)

# --- GAMS preloop.gms commented-out lines, transferred as comments ---
# *V05CostTotH2.L(runCy,SBS,YTIME) = 2;
# *V05CostTotH2.FX(runCy,TRANSE,YTIME)$(not An(YTIME)) = imFuelPrice(runCy,TRANSE,"H2F",YTIME)$(not An(YTIME));
# *V05CostTotH2.FX(runCy,"PG",YTIME)$(not An(YTIME))   = imFuelPrice(runCy,"PG","H2F",YTIME)$(not An(YTIME));
# *V05CostTotH2.FX(runCy,INDDOM,YTIME)$(not An(YTIME)) = imFuelPrice(runCy,INDDOM,"STE1AH2F",YTIME)$(not An(YTIME));
# *display V05CostTotH2.L;
# *VmConsFuelTechH2Prod.L(runCy,H2TECH,EF,YTIME)$(not An(YTIME)$H2TECHEFtoEF(H2TECH,EF)) = 0;
# (VmConsFuelTechH2Prod.FX at base year is implemented in code below)
# *V05DelivH2InfrTech.L(runCy,INFRTECH,YTIME) = 2;
# *V05DelivH2InfrTech.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
# *V05DelivH2InfrTech.FX(runCy,INFRTECH,"%fBaseY%") = 0;
# *V05CostVarProdH2Tech.LO(runCy,H2TECH,YTIME) = epsilon6;
# *V05InvNewReqH2Infra.L(runCy,INFRTECH,YTIME) = 2;
# *V05InvNewReqH2Infra.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
# *V05CostInvTechH2Infr.L(runCy, INFRTECH,YTIME) = 2;
# *V05CostInvTechH2Infr.FX(runCy, INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
# *V05CostInvCummH2Transp.L(runCy,INFRTECH,YTIME) = 2;
# *V05CostInvCummH2Transp.FX(runCy,INFRTECH,YTIME)$(not An(YTIME)) = 1e-5;
# *V05TariffH2Infr.L(runCy,INFRTECH,YTIME) = 2;
# *V05TariffH2Infr.FX(runCy,INFRTECH,YTIME) $(not An(YTIME)) = 1e-5;
# *V05PriceH2Infr.L(runCy,SBS,YTIME) = 2;
# *V05PriceH2Infr.FX(runCy,SBS,YTIME)  $(not An(YTIME)) = 1e-5;
# *V05H2InfrArea.L(runCy,YTIME) = 0.001;


def _pval(m, param, *idx):
    try:
        return pyo_value(param[idx])
    except Exception:
        return None


def apply_hydrogen_preloop(m: ConcreteModel, core_sets_obj) -> None:
    """Apply 05_Hydrogen (legacy) preloop: bounds and historical fixes."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    datay = getattr(core_sets_obj, "datay", set())
    if hasattr(datay, "__iter__") and not isinstance(datay, set):
        datay = set(datay)
    an = getattr(core_sets_obj, "an", set())
    if hasattr(an, "__iter__") and not isinstance(an, set):
        an = set(an)
    h2tech = list(core_sets.H2TECH)
    h2techpm = set(core_sets.H2TECHPM)
    h2techeftoef = core_sets.H2TECHEFtoEF
    h2prodef = set(core_sets.H2PRODEF)
    ef_list = list(core_sets.EF)
    sbs = list(core_sets.SBS)
    ssbs = list(core_sets.SSBS)

    for cy in run_cy:
        for y in ytime:
            # V05GapShareH2Tech1 bounds
            for ht in h2tech:
                try:
                    m.V05GapShareH2Tech1[cy, ht, y].setub(1.0)
                    m.V05GapShareH2Tech1[cy, ht, y].setlb(0.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05DemGapH2
            try:
                m.V05DemGapH2[cy, y].setlb(0.0)
                m.V05DemGapH2[cy, y].set_value(10.0)
                if y not in an:
                    m.V05DemGapH2[cy, y].fix(0.0)
            except Exception as _exc:
                logger.debug("Skipped: %s", _exc)

            # VmDemTotH2: init and fix in datay from supply + demand data
            try:
                s = 1.0
                if hasattr(m, "i03DataOwnConsEne"):
                    for sb in ssbs:
                        if (sb, "H2F") in core_sets.SECtoEFPROD or (sb, "H2F") in core_sets.SECtoEF:
                            s += _pval(m, m.i03DataOwnConsEne, cy, sb, "H2F", y) or 0.0
                if hasattr(m, "imFuelConsPerFueSub"):
                    for d in core_sets.DSBS:
                        s += _pval(m, m.imFuelConsPerFueSub, cy, d, "H2F", y) or 0.0
                m.VmDemTotH2[cy, y].setlb(0.0)
                m.VmDemTotH2[cy, y].set_value(s)
                if y in datay:
                    m.VmDemTotH2[cy, y].fix(s)
            except Exception as _exc:
                logger.debug("Skipped: %s", _exc)

            # VmProdH2: fix in datay to 0
            for ht in h2tech:
                try:
                    m.VmProdH2[cy, ht, y].setlb(0.0)
                    m.VmProdH2[cy, ht, y].set_value(0.5)
                    if y in datay:
                        m.VmProdH2[cy, ht, y].fix(0.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05ScrapLftH2Prod: fix in datay to 1/lifetime
            for ht in h2tech:
                try:
                    m.V05ScrapLftH2Prod[cy, ht, y].setub(1.0)
                    m.V05ScrapLftH2Prod[cy, ht, y].setlb(0.0)
                    if y in datay:
                        lft = _pval(m, m.i05ProdLftH2, ht, y) or 20.0
                        m.V05ScrapLftH2Prod[cy, ht, y].fix(1.0 / (lft + 1e-10))
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05CostProdH2Tech: fix in datay to 900 (GAMS)
            for ht in h2tech:
                try:
                    m.V05CostProdH2Tech[cy, ht, y].setlb(0.0)
                    m.V05CostProdH2Tech[cy, ht, y].set_value(2.0)
                    if y in datay:
                        m.V05CostProdH2Tech[cy, ht, y].fix(900.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05ShareCCSH2Prod, V05ShareNoCCSH2Prod bounds
            for ht in h2tech:
                try:
                    m.V05ShareCCSH2Prod[cy, ht, y].setlb(0.0)
                    m.V05ShareCCSH2Prod[cy, ht, y].setub(1.0)
                    m.V05ShareNoCCSH2Prod[cy, ht, y].setlb(0.0)
                    m.V05ShareNoCCSH2Prod[cy, ht, y].setub(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmConsFuelH2Prod: fix in datay to sum of tech; fix to 0 for non-H2PRODEF
            for ef_ in ef_list:
                try:
                    if ef_ not in h2prodef:
                        m.VmConsFuelH2Prod[cy, ef_, y].fix(0.0)
                    elif y in datay:
                        s = sum(
                            pyo_value(m.VmConsFuelTechH2Prod[cy, ht, ef_, y]) or 0.0
                            for (ht, e) in h2techeftoef
                            if e == ef_
                        )
                        m.VmConsFuelH2Prod[cy, ef_, y].fix(s)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05CostProdCCSNoCCSH2Prod bounds
            for ht in h2tech:
                try:
                    m.V05CostProdCCSNoCCSH2Prod[cy, ht, y].setlb(1e-6)
                    m.V05CostProdCCSNoCCSH2Prod[cy, ht, y].set_value(2.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # VmCostAvgProdH2: fix in datay to weighted average
            try:
                m.VmCostAvgProdH2[cy, y].setlb(0.0)
                m.VmCostAvgProdH2[cy, y].set_value(1.0)
                if y in datay:
                    num = sum(
                        ((pyo_value(m.VmProdH2[cy, ht, y]) or 0.0) + 1e-6)
                        * (pyo_value(m.V05CostProdH2Tech[cy, ht, y]) or 0.0)
                        for ht in h2tech
                    )
                    denom = sum((pyo_value(m.VmProdH2[cy, ht, y]) or 0.0) + 1e-6 for ht in h2tech)
                    m.VmCostAvgProdH2[cy, y].fix(num / (denom + 1e-10))
            except Exception as _exc:
                logger.debug("Skipped: %s", _exc)

            # V05PremRepH2Prod: fix to 1 for non-H2TECHPM
            for ht in h2tech:
                try:
                    m.V05PremRepH2Prod[cy, ht, y].setlb(0.0)
                    m.V05PremRepH2Prod[cy, ht, y].setub(1.0)
                    if ht not in h2techpm:
                        m.V05PremRepH2Prod[cy, ht, y].fix(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

            # V05CaptRateH2: fix in datay to i05CaptRateH2Prod
            for ht in h2tech:
                try:
                    m.V05CaptRateH2[cy, ht, y].setlb(0.0)
                    if y in datay:
                        m.V05CaptRateH2[cy, ht, y].fix(_pval(m, m.i05CaptRateH2Prod, ht) or 0.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

    # VmConsFuelTechH2Prod.FX at base year = VmProdH2.L / i05EffH2Prod (GAMS: runCy,H2TECH,EF,"%fBaseY%")
    base_y = getattr(core_sets_obj, "tFirst", None)
    if base_y is not None and hasattr(base_y, "__iter__") and not isinstance(base_y, str):
        base_y = next(iter(base_y), None)
    if base_y is not None:
        for cy in run_cy:
            for (ht, ef_) in h2techeftoef:
                try:
                    prod = pyo_value(m.VmProdH2[cy, ht, base_y]) or 0.0
                    eff = _pval(m, m.i05EffH2Prod, cy, ht, base_y) or 1.0
                    m.VmConsFuelTechH2Prod[cy, ht, ef_, base_y].fix(prod / (eff + 1e-10))
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)

    # V05CapScrapH2ProdTech, V05GapShareH2Tech2 bounds
    for cy in run_cy:
        for ht in h2tech:
            for y in ytime:
                try:
                    m.V05CapScrapH2ProdTech[cy, ht, y].setlb(0.0)
                    m.V05CapScrapH2ProdTech[cy, ht, y].setub(1.0)
                    m.V05GapShareH2Tech2[cy, ht, y].setlb(0.0)
                    m.V05GapShareH2Tech2[cy, ht, y].setub(1.0)
                except Exception as _exc:
                    logger.debug("Skipped: %s", _exc)
