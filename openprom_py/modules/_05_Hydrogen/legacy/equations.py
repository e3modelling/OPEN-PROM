"""
Module 05_Hydrogen (legacy): equation definitions.

Mirrors modules/05_Hydrogen/legacy/equations.gms. Implements Q05DemTotH2, Q05DemSecH2,
Q05ScrapLftH2Prod, Q05PremRepH2Prod, Q05CapScrapH2ProdTech, Q05DemGapH2, Q05CostProdH2Tech,
Q05CostVarProdH2Tech, Q05AcceptCCSH2Tech, Q05ShareCCSH2Prod, Q05ShareNoCCSH2Prod,
Q05CostProdCCSNoCCSH2Prod, Q05GapShareH2Tech2, Q05GapShareH2Tech1, Q05ProdH2,
Q05CostAvgProdH2, Q05ConsFuelTechH2Prod, Q05ConsFuelH2Prod, Q05CaptRateH2.

Simplifications vs GAMS (intentional):
- Q05DemTotH2: GAMS divides sector demand by prod(INFRTECH, i05EffH2Transp*(1-i05ConsSelfH2Transp));
  we use sum(VmDemSecH2) without that transport-efficiency product (infrastructure block is $ontext).
- Q05ScrapLftH2Prod: GAMS uses (1/lifetime)$(ord(YTIME)>14+i05ProdLftH2) and $ontext gap-share term;
  we use 1/lifetime for all years.

---
GAMS $ontext ... $offtext (commented out in GAMS; transferred here as comments):
$ontext
!!                               B. Hydrogen Infrustructure
!!
*' Q05H2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
*'   V05H2InfrArea(allCy,YTIME) =E= i05PolH2AreaMax(allCy)/(1 + exp( -i05H2Adopt(allCy,"B",YTIME)*( VmDemTotH2(allCy,YTIME)/(i05HabAreaCountry(allCy)/s05AreaStyle*0.275)- i05H2Adopt(allCy,"MID",YTIME))));
*' Q05DelivH2InfrTech(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
*'   V05DelivH2InfrTech = ( sum(SBS$(H2INFRSBS$SECTtoEF(SBS,"H2F")), VmDemSecH2/(i05EffH2Transp*(1-i05ConsSelfH2Transp)) )$H2INFRDNODES + sum(INFRTECH2$H2NETWORK, V05DelivH2InfrTech(INFRTECH2)/(i05EffH2Transp*(1-i05ConsSelfH2Transp)) )$(not H2INFRDNODES) )$i05PolH2AreaMax +1e-7;
*' Q05InvNewReqH2Infra: V05InvNewReqH2Infra = ( V05DelivH2InfrTech-V05DelivH2InfrTech(YTIME-1) + 0 + SQRT(SQR(...)+SQR(1e-4)) )/2;
*' Q05H2Pipe: V05H2Pipe = (55*V05InvNewReqH2Infra/(1e-3*s05DelivH2Turnpike))$TPIPA + (i05PipeH2Transp*1e6*V05InvNewReqH2Infra)$(LPIPU or HPIPI) + (s05LenH2StationConn*V05CostInvTechH2Infr(SSGG))$MPIPS + (sum(H2NETWORK,V05CostInvTechH2Infr*i05KmFactH2Transp))$(MPIPU or HPIPU) + (V05InvNewReqH2Infra/s05SalesH2Station*1E3)$SSGG;
*' Q05CostInvTechH2Infr: 1e-6*(i05CostInvH2Transp/V05H2InfrArea*V05CostInvTechH2Infr)$TPIPA + ... + (i05CostInvH2Transp*V05InvNewReqH2Infra)$SSGG;
*' Q05CostTechH2Infr: ((imDisc("H2INFR")*exp(...)/i05TranspLftH2)/(exp(...)-1))*V05CostInvCummH2Transp*(1+i05CostInvFOMH2)/i05AvailRateH2Transp + i05CostInvVOMH2 * ... + (i05ConsSelfH2Transp*V05InvNewReqH2Infra*(VmCostAvgProdH2(YTIME-1)$HPIPU + VmPriceFuelSubsecCarVal*1e3)$SSGG)$(SSGG or HPIPU) /V05InvNewReqH2Infra;
*' Q05CostInvCummH2Transp: V05CostInvCummH2Transp = sum(YYTIME$(an$(ord<=ord(YTIME)), V05CostTechH2Infr*V05InvNewReqH2Infra*exp(0.04*(ord(YTIME)-ord(YYTIME)))) / sum(YYTIME$, V05InvNewReqH2Infra);
*' Q05TariffH2Infr: V05TariffH2Infr = i05CostAvgWeight*V05H2Pipe + (1-i05CostAvgWeight)*V05CostTechH2Infr;
*' Q05PriceH2Infr(allCy,SBS,YTIME)$(TIME $SECTTECH(SBS,"H2F") $runCy): V05PriceH2Infr = sum(INFRTECH$H2INFRSBS(INFRTECH,SBS), V05TariffH2Infr);
*' Q05CostTotH2(allCy,SBS,YTIME)$(TIME $SECTTECH(SBS,"H2F") $runCy): V05CostTotH2 = V05PriceH2Infr+VmCostAvgProdH2;
*' *Q05ProdCapH2Tech(allCy,H2TECH,YTIME)
$offtext
---
"""
from pyomo.core import ConcreteModel, Constraint, value as pyo_value
from pyomo.environ import exp, sqrt

from core import sets as core_sets

_EPS = 1e-6


def _year_prev(ytime_list, y):
    """Previous year in ytime; if first, return y."""
    try:
        i = ytime_list.index(y)
        return ytime_list[i - 1] if i > 0 else y
    except (ValueError, AttributeError):
        return y


def add_hydrogen_equations(m: ConcreteModel, core_sets_obj) -> None:
    """Add all Q05* constraints for 05_Hydrogen (legacy)."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    h2tech = list(core_sets.H2TECH)
    h2ccs = set(core_sets.H2CCS)
    h2noccs = set(core_sets.H2NOCCS)
    h2ccs_noccs = core_sets.H2CCS_NOCCS
    h2techpm = set(core_sets.H2TECHPM)
    h2techeftoef = core_sets.H2TECHEFtoEF
    h2techren = set(core_sets.H2TECHREN)
    h2prodef = set(core_sets.H2PRODEF)
    inddom = list(core_sets.INDDOM)
    trans = list(core_sets.TRANSE)
    sbs = list(core_sets.SBS)
    ef_list = list(core_sets.EF)
    # SBS that consume H2F and are in VmDemSecH2 index set (DSBS)
    sbs_h2f = [s for (s, ef) in core_sets.SECtoEF if ef == "H2F" and s in sbs]
    if not sbs_h2f:
        sbs_h2f = list(sbs)
    nap_h2p = [n for (n, sb) in core_sets.NAPtoALLSBS if sb == "H2P"]
    if not nap_h2p:
        nap_h2p = list(core_sets.NAP)

    # Q05DemTotH2: total H2 demand (simplified: sum of sector demands; GAMS divides by transport efficiency product)
    def _q05_dem_tot_h2(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.VmDemTotH2[cy, y] == sum(
            mod.VmDemSecH2[cy, s, y] for s in sbs_h2f
        )

    m.Q05DemTotH2 = Constraint(run_cy, ytime, rule=_q05_dem_tot_h2)

    # Q05DemSecH2: sectoral H2 demand from industry, transport, DAC, EW, PG
    def _q05_dem_sec_h2(mod, cy, sb, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        lhs = 0.0
        if sb in inddom:
            lhs = lhs + mod.VmConsFuel[cy, sb, "H2F", y]
        if sb in trans:
            lhs = lhs + mod.VmDemFinEneTranspPerFuel[cy, sb, "H2F", y]
        if sb == "DAC" and hasattr(mod, "VmConsFuelCDRProd"):
            lhs = lhs + mod.VmConsFuelCDRProd[cy, "H2F", y]
        if sb == "EW" and hasattr(mod, "VmConsFuelCDRProd"):
            lhs = lhs + mod.VmConsFuelCDRProd[cy, "H2F", y]
        if sb == "PG" and hasattr(mod, "VmConsFuelElecProd"):
            lhs = lhs + mod.VmConsFuelElecProd[cy, "H2F", y]
        return mod.VmDemSecH2[cy, sb, y] == lhs

    m.Q05DemSecH2 = Constraint(run_cy, sbs, ytime, rule=_q05_dem_sec_h2)

    # Q05ScrapLftH2Prod: normal scrapping = 1/lifetime (simplified; GAMS has ord condition)
    def _q05_scrap_lft(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V05ScrapLftH2Prod[cy, ht, y] == 1.0 / (mod.i05ProdLftH2[ht, y] + _EPS)

    m.Q05ScrapLftH2Prod = Constraint(run_cy, h2tech, ytime, rule=_q05_scrap_lft)

    # Q05PremRepH2Prod: only for H2TECHPM
    def _q05_prem_rep(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy or ht not in h2techpm:
            return Constraint.Skip
        gamma = mod.i05WBLGammaH2Prod[cy, y]
        vcost = mod.V05CostVarProdH2Tech[cy, ht, y]
        other = sum(
            mod.V05CostProdH2Tech[cy, ht2, y]
            for ht2 in h2tech
            if ht2 != ht
        )
        iwbl = mod.iWBLPremRepH2Prod[cy, ht, y]
        denom = (iwbl * (other + _EPS)) ** (-gamma) + (vcost + _EPS) ** (-gamma)
        return mod.V05PremRepH2Prod[cy, ht, y] == (vcost + _EPS) ** (-gamma) / (denom + _EPS)

    m.Q05PremRepH2Prod = Constraint(run_cy, h2tech, ytime, rule=_q05_prem_rep)

    # Q05CapScrapH2ProdTech
    def _q05_cap_scrap(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V05CapScrapH2ProdTech[cy, ht, y] == 1.0 - (
            (1.0 - mod.V05ScrapLftH2Prod[cy, ht, y]) * mod.V05PremRepH2Prod[cy, ht, y]
        )

    m.Q05CapScrapH2ProdTech = Constraint(run_cy, h2tech, ytime, rule=_q05_cap_scrap)

    # Q05DemGapH2: demand minus (1-scrap)*production last year; non-negative via (x + sqrt(x^2))/2
    def _q05_dem_gap(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        dem = mod.VmDemTotH2[cy, y]
        cap = sum(
            (1.0 - mod.V05CapScrapH2ProdTech[cy, ht, y]) * mod.VmProdH2[cy, ht, yp]
            for ht in h2tech
        )
        diff = dem - cap
        return mod.V05DemGapH2[cy, y] == (diff + sqrt(diff**2 + _EPS)) / 2.0

    m.Q05DemGapH2 = Constraint(run_cy, ytime, rule=_q05_dem_gap)

    # Q05CostProdH2Tech: levelized cost + variable cost; wes/wew use V04CapexFixCostPG from 04
    def _q05_cost_prod(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        disc = mod.imDisc[cy, "H2P", y]
        lft = mod.i05ProdLftH2[ht, y]
        ex = exp(disc * lft)
        ann = disc * ex / (ex - 1.0 + _EPS)
        cap_cost = (
            mod.i05CostCapH2Prod[cy, ht, y]
            + mod.i05CostFOMH2Prod[cy, ht, y]
            + mod.i05CostVOMH2Prod[cy, ht, y]
        )
        if ht == "wes" and hasattr(mod, "V04CapexFixCostPG"):
            cap_cost = cap_cost + mod.V04CapexFixCostPG[cy, "PGSOL", y]
        if ht == "wew" and hasattr(mod, "V04CapexFixCostPG"):
            cap_cost = cap_cost + mod.V04CapexFixCostPG[cy, "PGAWNO", y]
        avail = mod.i05AvailH2Prod[cy, ht, y]
        gw = mod.smGwToTwhPerYear[y]
        sm = mod.smTWhToMtoe
        cap_term = ann * cap_cost / (avail * gw * sm + _EPS)
        return mod.V05CostProdH2Tech[cy, ht, y] == cap_term + mod.V05CostVarProdH2Tech[cy, ht, y]

    m.Q05CostProdH2Tech = Constraint(run_cy, h2tech, ytime, rule=_q05_cost_prod)

    # Q05CostVarProdH2Tech: fuel + CO2 cost for non-REN; wes/wew use i04VarCost
    def _q05_cost_var(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        if ht in h2techren:
            if ht == "wes" and hasattr(mod, "i04VarCost"):
                return mod.V05CostVarProdH2Tech[cy, ht, y] == mod.i04VarCost["PGSOL", y] / (mod.smTWhToMtoe + _EPS)
            if ht == "wew" and hasattr(mod, "i04VarCost"):
                return mod.V05CostVarProdH2Tech[cy, ht, y] == mod.i04VarCost["PGAWNO", y] / (mod.smTWhToMtoe + _EPS)
            return Constraint.Skip
        # Non-REN: sum over H2TECHEFtoEF(ht, ef) of (price + CO2 terms) / efficiency
        terms = []
        for (ht_ef, ef_) in h2techeftoef:
            if ht_ef != ht:
                continue
            co2_extra = 4.17 if ef_ == "BMSWAS" else 0.0
            price = mod.VmPriceFuelSubsecCarVal[cy, "H2P", ef_, y] * 1e3
            co2 = mod.imCo2EmiFac[cy, "H2P", ef_, y] + co2_extra
            car_sum = sum(mod.VmCarVal[cy, n, y] for n in nap_h2p)
            capt = mod.V05CaptRateH2[cy, ht, y]
            seq = mod.VmCstCO2SeqCsts[cy, y]
            terms.append(
                (price + capt * co2 * seq + (1.0 - capt) * co2 * car_sum)
                / (mod.i05EffH2Prod[cy, ht, y] + _EPS)
            )
        if not terms:
            return Constraint.Skip
        return mod.V05CostVarProdH2Tech[cy, ht, y] == sum(terms)

    m.Q05CostVarProdH2Tech = Constraint(run_cy, h2tech, ytime, rule=_q05_cost_var)

    # Q05AcceptCCSH2Tech
    def _q05_accept_ccs(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        car = sum(mod.VmCarVal[cy, n, yp] for n in nap_h2p)
        return mod.V05AcceptCCSH2Tech[cy, y] == mod.i05WBLGammaH2Prod[cy, y] * 2.0 + exp(-0.06 * (car + _EPS))

    m.Q05AcceptCCSH2Tech = Constraint(run_cy, ytime, rule=_q05_accept_ccs)

    # Q05ShareCCSH2Prod: only for H2CCS
    def _q05_share_ccs(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy or ht not in h2ccs:
            return Constraint.Skip
        num = 1.5 * mod.iWBLShareH2Prod[cy, ht, y] * (mod.V05CostProdH2Tech[cy, ht, y] + 1e-3) ** (-mod.V05AcceptCCSH2Tech[cy, y])
        denom = num
        for (ccs_ht, noccs_ht) in h2ccs_noccs:
            if ccs_ht == ht:
                denom = denom + 1.0 * mod.iWBLShareH2Prod[cy, noccs_ht, y] * (mod.V05CostProdH2Tech[cy, noccs_ht, y] + 1e-3) ** (-mod.V05AcceptCCSH2Tech[cy, y])
        return mod.V05ShareCCSH2Prod[cy, ht, y] == num / (denom + _EPS)

    m.Q05ShareCCSH2Prod = Constraint(run_cy, h2tech, ytime, rule=_q05_share_ccs)

    # Q05ShareNoCCSH2Prod: only for H2NOCCS
    def _q05_share_noccs(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy or ht not in h2noccs:
            return Constraint.Skip
        s = sum(
            mod.V05ShareCCSH2Prod[cy, ccs_ht, y]
            for (ccs_ht, noccs_ht) in h2ccs_noccs
            if noccs_ht == ht
        )
        return mod.V05ShareNoCCSH2Prod[cy, ht, y] == 1.0 - s

    m.Q05ShareNoCCSH2Prod = Constraint(run_cy, h2tech, ytime, rule=_q05_share_noccs)

    # Q05CostProdCCSNoCCSH2Prod: only for H2NOCCS
    def _q05_cost_ccs_noccs(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy or ht not in h2noccs:
            return Constraint.Skip
        rhs = mod.V05ShareNoCCSH2Prod[cy, ht, y] * mod.V05CostProdH2Tech[cy, ht, y]
        for (ccs_ht, noccs_ht) in h2ccs_noccs:
            if noccs_ht == ht:
                rhs = rhs + mod.V05ShareCCSH2Prod[cy, ccs_ht, y] * mod.V05CostProdH2Tech[cy, ccs_ht, y]
        return mod.V05CostProdCCSNoCCSH2Prod[cy, ht, y] == rhs

    m.Q05CostProdCCSNoCCSH2Prod = Constraint(run_cy, h2tech, ytime, rule=_q05_cost_ccs_noccs)

    # Q05GapShareH2Tech2
    def _q05_gap_share2(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        gamma = mod.i05WBLGammaH2Prod[cy, y]
        if ht in h2ccs:
            return mod.V05GapShareH2Tech2[cy, ht, y] == sum(
                mod.V05GapShareH2Tech2[cy, noccs_ht, y]
                for (ccs_ht, noccs_ht) in h2ccs_noccs
                if ccs_ht == ht
            )
        # Not CCS: share = iWBL * cost^(-gamma) / sum over non-CCS
        cost_ht = mod.V05CostProdCCSNoCCSH2Prod[cy, ht, y] if ht in h2noccs else mod.V05CostProdH2Tech[cy, ht, y]
        num = mod.iWBLShareH2Prod[cy, ht, y] * (cost_ht + _EPS) ** (-gamma)
        denom = 0.0
        for ht2 in h2tech:
            if ht2 in h2ccs:
                continue
            c2 = mod.V05CostProdCCSNoCCSH2Prod[cy, ht2, y] if ht2 in h2noccs else mod.V05CostProdH2Tech[cy, ht2, y]
            denom += mod.iWBLShareH2Prod[cy, ht2, y] * (c2 + _EPS) ** (-gamma)
        return mod.V05GapShareH2Tech2[cy, ht, y] == num / (denom + _EPS)

    m.Q05GapShareH2Tech2 = Constraint(run_cy, h2tech, ytime, rule=_q05_gap_share2)

    # Q05GapShareH2Tech1
    def _q05_gap_share1(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        g2 = mod.V05GapShareH2Tech2[cy, ht, y]
        if ht not in h2ccs and ht not in h2noccs:
            return mod.V05GapShareH2Tech1[cy, ht, y] == g2
        if ht in h2ccs:
            return mod.V05GapShareH2Tech1[cy, ht, y] == g2 * mod.V05ShareCCSH2Prod[cy, ht, y]
        return mod.V05GapShareH2Tech1[cy, ht, y] == g2 * mod.V05ShareNoCCSH2Prod[cy, ht, y]

    m.Q05GapShareH2Tech1 = Constraint(run_cy, h2tech, ytime, rule=_q05_gap_share1)

    # Q05ProdH2
    def _q05_prod_h2(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        yp = _year_prev(ytime, y)
        return mod.VmProdH2[cy, ht, y] == (
            (1.0 - mod.V05CapScrapH2ProdTech[cy, ht, y]) * mod.VmProdH2[cy, ht, yp]
            + mod.V05GapShareH2Tech1[cy, ht, y] * mod.V05DemGapH2[cy, y]
        )

    m.Q05ProdH2 = Constraint(run_cy, h2tech, ytime, rule=_q05_prod_h2)

    # Q05CostAvgProdH2
    def _q05_cost_avg(mod, cy, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        num = sum(
            (mod.VmProdH2[cy, ht, y] + _EPS) * mod.V05CostProdH2Tech[cy, ht, y]
            for ht in h2tech
        )
        denom = sum(mod.VmProdH2[cy, ht, y] + _EPS for ht in h2tech)
        return mod.VmCostAvgProdH2[cy, y] == num / denom

    m.Q05CostAvgProdH2 = Constraint(run_cy, ytime, rule=_q05_cost_avg)

    # Q05ConsFuelTechH2Prod: only for (ht, ef) in H2TECHEFtoEF
    def _q05_cons_fuel_tech(mod, cy, ht, ef_, y):
        if y not in time_set or cy not in run_cy or (ht, ef_) not in h2techeftoef:
            return Constraint.Skip
        return mod.VmConsFuelTechH2Prod[cy, ht, ef_, y] == mod.VmProdH2[cy, ht, y] / (mod.i05EffH2Prod[cy, ht, y] + _EPS)

    m.Q05ConsFuelTechH2Prod = Constraint(run_cy, h2tech, ef_list, ytime, rule=_q05_cons_fuel_tech)

    # Q05ConsFuelH2Prod: only for ef in H2PRODEF
    def _q05_cons_fuel(mod, cy, ef_, y):
        if y not in time_set or cy not in run_cy or ef_ not in h2prodef:
            return Constraint.Skip
        return mod.VmConsFuelH2Prod[cy, ef_, y] == sum(
            mod.VmConsFuelTechH2Prod[cy, ht, ef_, y]
            for (ht, e) in h2techeftoef
            if e == ef_
        )

    m.Q05ConsFuelH2Prod = Constraint(run_cy, ef_list, ytime, rule=_q05_cons_fuel)

    # Q05CaptRateH2: smooth step from i05CaptRateH2Prod based on CO2 price vs carbon value
    def _q05_capt_rate(mod, cy, ht, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        base = mod.i05CaptRateH2Prod[ht]
        car = sum(mod.VmCarVal[cy, n, y] for n in nap_h2p) + 1.0
        ratio = mod.VmCstCO2SeqCsts[cy, y] / car
        # GAMS: 1 + EXP(20*(...)) in denominator
        inner = (ratio + 2.0 - sqrt((ratio - 2.0) ** 2 + _EPS)) / 2.0 - 1.0
        denom = 1.0 + exp(20.0 * inner)
        return mod.V05CaptRateH2[cy, ht, y] == base / (denom + _EPS)

    m.Q05CaptRateH2 = Constraint(run_cy, h2tech, ytime, rule=_q05_capt_rate)

# --- GAMS equations.gms $ontext ... $offtext (full block, commented out in GAMS), transferred as comments ---
# $ontext
# !!                               B. Hydrogen Infrustructure
# !! Q05H2InfrArea(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
# !!   V05H2InfrArea(allCy,YTIME) =E= i05PolH2AreaMax(allCy)/(1 + exp( -i05H2Adopt(allCy,"B",YTIME)*( VmDemTotH2(allCy,YTIME)/(i05HabAreaCountry(allCy)/s05AreaStyle*0.275)- i05H2Adopt(allCy,"MID",YTIME))));
# !! Q05DelivH2InfrTech(allCy,INFRTECH,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
# !!   V05DelivH2InfrTech = ( (sum(SBS$(H2INFRSBS(INFRTECH,SBS) $SECTtoEF(SBS,"H2F")), VmDemSecH2/(i05EffH2Transp*(1-i05ConsSelfH2Transp))) )$H2INFRDNODES(INFRTECH) + sum(INFRTECH2$H2NETWORK(INFRTECH,INFRTECH2), V05DelivH2InfrTech(INFRTECH2)/(i05EffH2Transp*(1-i05ConsSelfH2Transp))))$(not H2INFRDNODES(INFRTECH)) )$i05PolH2AreaMax(allCy) +1e-7;
# !! Q05InvNewReqH2Infra: V05InvNewReqH2Infra = ( V05DelivH2InfrTech-V05DelivH2InfrTech(YTIME-1) + 0 + SQRT(SQR(...)+SQR(1e-4)) )/2;
# !! Q05H2Pipe: V05H2Pipe = (55*V05InvNewReqH2Infra/(1e-3*s05DelivH2Turnpike))$sameas("TPIPA",INFRTECH) + (i05PipeH2Transp*1e6*V05InvNewReqH2Infra)$(LPIPU or HPIPI) + ... + (V05InvNewReqH2Infra/s05SalesH2Station*1E3)$sameas("SSGG",INFRTECH);
# !! Q05CostInvTechH2Infr: 1e-6*(i05CostInvH2Transp/V05H2InfrArea*V05CostInvTechH2Infr)$TPIPA + ... + (i05CostInvH2Transp*V05InvNewReqH2Infra)$SSGG;
# !! Q05CostTechH2Infr: ((imDisc("H2INFR")*exp(...)/(exp(...)-1))*V05CostInvCummH2Transp*(1+i05CostInvFOMH2)/i05AvailRateH2Transp + i05CostInvVOMH2)*... + (i05ConsSelfH2Transp*V05InvNewReqH2Infra*(VmCostAvgProdH2(YTIME-1)$HPIPU + VmPriceFuelSubsecCarVal*1e3)$SSGG)$(SSGG or HPIPU) /V05InvNewReqH2Infra;
# !! Q05CostInvCummH2Transp: V05CostInvCummH2Transp = sum(YYTIME$(an(YYTIME)$(ord(YYTIME)<=ord(YTIME))), V05CostTechH2Infr*V05InvNewReqH2Infra*exp(0.04*(ord(YTIME)-ord(YYTIME)))) / sum(YYTIME$(an(YYTIME)$(ord(YYTIME)<=ord(YTIME))), V05InvNewReqH2Infra);
# !! Q05TariffH2Infr: V05TariffH2Infr = i05CostAvgWeight*V05H2Pipe + (1-i05CostAvgWeight)*V05CostTechH2Infr;
# !! Q05PriceH2Infr(allCy,SBS,YTIME)$(TIME $SECTTECH(SBS,"H2F") $runCy): V05PriceH2Infr = sum(INFRTECH$H2INFRSBS(INFRTECH,SBS), V05TariffH2Infr);
# !! Q05CostTotH2(allCy,SBS,YTIME)$(TIME $SECTTECH(SBS,"H2F") $runCy): V05CostTotH2 = V05PriceH2Infr+VmCostAvgProdH2;
# !! *Q05ProdCapH2Tech(allCy,H2TECH,YTIME)
# $offtext
