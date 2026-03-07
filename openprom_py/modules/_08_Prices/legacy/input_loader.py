"""
Module 08_Prices (legacy): load input data and derive parameters.

Mirrors modules/08_Prices/legacy/input.gms. Parameters: i08DiffFuelsInSec(SBS), i08WgtSecAvgPriFueCons(allCy,SBS,EF),
i08VAT(allCy,YTIME). Optional: iPricesMagpie when link2MAgPIE == on. GAMS also rescales imFuelPrice to k$/toe (done in core load).
Commented-out / $IFTHEN blocks transferred as comments.
"""
from pathlib import Path
from typing import Any, Dict

from pyomo.core import ConcreteModel, value as pyo_value

from core import sets as core_sets

# --- GAMS input.gms (transferred as comments) ---
# $IFTHEN %link2MAgPIE% == on
# table iPricesMagpie(allCy,SBS,YTIME) "Prices of biomass per subsector (k$2015/toe)"
# $ondelim
# $include "./iPrices_magpie.csv"
# $offdelim
# $ENDIF
# ---
# Parameters: i08DiffFuelsInSec(SBS), i08WgtSecAvgPriFueCons(allCy,SBS,EF), i08VAT(allCy,YTIME)
# loop SBS do i08DiffFuelsInSec(SBS)=0; loop EF$SECtoEF(SBS,EF) do i08DiffFuelsInSec(SBS)=i08DiffFuelsInSec(SBS)+1; endloop; endloop;
# i08WgtSecAvgPriFueCons for TRANSE, NENSE, INDDOM (base year consumption shares); then rescaling so weights sum to 1.
# i08VAT(runCy,YTIME)=0;
# imFuelPrice(...)=imFuelPrice(...)/1000;  [done in core load_core_data_into_model]
# imFuelPrice(runCy,"BU","KRS",YTIME)=imFuelPrice(runCy,"PA","KRS",YTIME);


def load_prices_data(config: Any) -> Dict[str, Any]:
    """Load 08_Prices input data. Optional iPricesMagpie when link2magpie == 'on'. Returns dict for load_prices_data_into_model."""
    data: Dict[str, Any] = {}
    data_dir = getattr(config, "data_dir", None) or getattr(config, "project_root", Path(__file__).resolve().parent.parent.parent.parent) / "data"
    if getattr(config, "link2magpie", "off") == "on":
        p = Path(data_dir) / "iPrices_magpie.csv"
        if p.exists():
            try:
                import pandas as pd
                df = pd.read_csv(p)
                cols = [c for c in df.columns if str(c).isdigit()]
                idx_cols = [c for c in df.columns if c not in cols]
                out = {}
                for _, row in df.iterrows():
                    if len(idx_cols) >= 3:
                        cy, sbs, y = row[idx_cols[0]], row[idx_cols[1]], row[idx_cols[2]]
                    else:
                        cy, sbs, y = row[0], row[1], row[2]
                    for ycol in cols:
                        try:
                            out[(cy, sbs, int(ycol))] = float(row[ycol])
                        except (TypeError, ValueError):
                            pass
                data["iPricesMagpie"] = out
            except Exception:
                data["iPricesMagpie"] = {}
    return data


def load_prices_data_into_model(
    m: ConcreteModel,
    data: Dict[str, Any],
    core_sets_obj: Any,
) -> None:
    """
    Fill i08DiffFuelsInSec, i08WgtSecAvgPriFueCons, i08VAT.
    i08DiffFuelsInSec(SBS) = count of EF with SECtoEF(SBS,EF). i08VAT = 0.
    i08WgtSecAvgPriFueCons from base-year consumption shares when imFuelConsPerFueSub/imTotFinEneDemSubBaseYr available.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    ef = list(core_sets.EF)
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]
    sec_to_ef = core_sets.SECtoEF
    base_y = getattr(core_sets_obj, "tFirst", None)
    if base_y is not None and hasattr(base_y, "__iter__") and not isinstance(base_y, (str, int)):
        base_y = next(iter(base_y), ytime[0] if ytime else None)
    else:
        base_y = ytime[0] if ytime else None

    if not hasattr(m, "i08DiffFuelsInSec"):
        return

    # i08DiffFuelsInSec(SBS) = number of EF with SECtoEF(SBS,EF)
    for sb in sbs_and_supply:
        count = sum(1 for e in ef if (sb, e) in sec_to_ef)
        m.i08DiffFuelsInSec[sb] = max(count, 1)

    # i08VAT = 0 (GAMS)
    for cy in run_cy:
        for y in ytime:
            m.i08VAT[cy, y] = 0.0

    # i08WgtSecAvgPriFueCons: from base year consumption shares. Simplified: 1/i08DiffFuelsInSec if no data.
    if base_y is None:
        return
    for cy in run_cy:
        for sb in sbs_and_supply:
            n = max(pyo_value(m.i08DiffFuelsInSec[sb]), 1)
            for e in ef:
                if (sb, e) not in sec_to_ef:
                    continue
                # Default weight: equal share
                w = 1.0 / n
                if hasattr(m, "imFuelConsPerFueSub") and hasattr(m, "imTotFinEneDemSubBaseYr"):
                    try:
                        tot = sum(
                            pyo_value(m.imFuelConsPerFueSub[cy, sb, e2, base_y])
                            for e2 in ef if (sb, e2) in sec_to_ef
                        )
                        if tot and tot > 0:
                            w = pyo_value(m.imFuelConsPerFueSub[cy, sb, e, base_y]) / tot
                    except Exception:
                        pass
                m.i08WgtSecAvgPriFueCons[cy, sb, e] = w
        # Rescale weights to sum to 1 per (cy, sb)
        for sb in sbs_and_supply:
            s = sum(pyo_value(m.i08WgtSecAvgPriFueCons[cy, sb, e]) for e in ef if (sb, e) in sec_to_ef)
            if s and s > 0:
                for e in ef:
                    if (sb, e) in sec_to_ef:
                        m.i08WgtSecAvgPriFueCons[cy, sb, e] = pyo_value(m.i08WgtSecAvgPriFueCons[cy, sb, e]) / s
