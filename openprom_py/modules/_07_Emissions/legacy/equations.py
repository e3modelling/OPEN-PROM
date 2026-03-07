"""
Module 07_Emissions (legacy): equation definitions.

Mirrors modules/07_Emissions/legacy/equations.gms. Implements Q07GrossEmissCO2Demand,
Q07GrossEmissCO2Supply, Q07RedAbsBySrcRegTim, Q07CostAbateBySrcRegTim, Q07EmiActBySrcRegTim.
All equation descriptions below are transferred verbatim from GAMS *' comments.
"""
from pyomo.core import ConcreteModel, Constraint, value as pyo_value

from core import sets as core_sets

# --- GAMS equations.gms commented-out (transferred as comments) ---
# *' *** Emissions Constraints Equations
# * Q07GrnnHsEmisCO2Equiv(NAP,YTIME)   "Compute total CO2eq GHG emissions in all countries per NAP sector"
# * q07GrnnHsEmisCO2EquivAllCntr(YTIME) "Compute total CO2eq GHG emissions in all countries"
# * q07ExpendHouseEne(allCy,YTIME)     "Compute households expenditures on energy"
# $ontext
# Q07GrnnHsEmisCO2Equiv(NAP,YTIME)$(TIME(YTIME))..
#   V07GrnnHsEmisCO2Equiv(NAP,YTIME) =E= ( sum(allCy, sum((EFS,INDSE)$(SECTTECH(INDSE,EFS)$NAPtoALLSBS(NAP,INDSE)), VmConsFuel*imCo2EmiFac)
#     + sum(PGEF, VmInpTransfTherm*imCo2EmiFac$(not h2f1(pgef))) + sum(EFS, VmTransfInputDHPlants*imCo2EmiFac)
#     + sum(EFS, VmConsFiEneSec*imCo2EmiFac) - sum(PGEF, sum(CCS$PGALLtoEF, VmProdElec*smTWhToMtoe/imPlantEffByType*imCo2EmiFac*imCO2CaptRate)) ));
# $offtext
# q07GrnnHsEmisCO2EquivAllCntr(YTIME)$(TIME(YTIME)).. v07GrnnHsEmisCO2EquivAllCntr(YTIME) =E= sum(NAP, V07GrnnHsEmisCO2Equiv(NAP,YTIME));
# $ontext
# q07ExpendHouseEne(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy))).. v07ExpendHouseEne =E= SUM(DSBS$HOU(DSBS), SUM(EF$SECTTECH, VmConsRemSubEquipSubSec*(VmPriceFuelSubsecCarVal-...) ) + VmPriceElecIndResNoCliPol*VmConsElecNonSubIndTert/smTWhToMtoe;  VmConsElecNonSubIndTert --> NO LONGER
# $offtext

# Small epsilon to avoid division-by-zero when comparing carbon price to MAC step cost
_EPS = 1e-10


def add_emissions_equations(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add all Q07* constraints for 07_Emissions (legacy).
    Index sets and domain checks follow GAMS TIME(YTIME), runCy(allCy).
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    time_set = core_sets_obj.time
    ssbs = list(core_sets.SSBS)
    dsbs = list(core_sets.DSBS)
    e07src = list(core_sets.E07SrcMacAbate)
    e07mac = list(core_sets.E07MAC)
    ssbsemit = set(core_sets.SSBSEMIT)
    efs = list(core_sets.EFS) if hasattr(core_sets, "EFS") else list(core_sets.EF)
    trans = set(core_sets.TRANSE)

    # -------------------------------------------------------------------------
    # Q07GrossEmissCO2Demand (GAMS: "Calculate gross emissions of demand subsectors")
    # Gross emissions of demand subsectors = SUM(EFS, (VmConsFuel + VmDemFinEneTranspPerFuel for transport + VmConsFuelCDRProd) * imCo2EmiFac).
    # Covers final consumption, transport demand per fuel, and CDR production fuel use, each times the subsector/fuel CO2 emission factor.
    # -------------------------------------------------------------------------
    def _q07_gross_demand(mod, cy, dsbs_, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        lhs = 0.0
        for efs_ in efs:
            cons = mod.VmConsFuel[cy, dsbs_, efs_, y]
            if dsbs_ in trans and hasattr(mod, "VmDemFinEneTranspPerFuel"):
                cons = cons + mod.VmDemFinEneTranspPerFuel[cy, dsbs_, efs_, y]
            if hasattr(mod, "VmConsFuelCDRProd"):
                cons = cons + mod.VmConsFuelCDRProd[cy, efs_, y]
            lhs += cons * mod.imCo2EmiFac[cy, dsbs_, efs_, y]
        return mod.V07GrossEmissCO2Demand[cy, dsbs_, y] == lhs

    m.Q07GrossEmissCO2Demand = Constraint(run_cy, dsbs, ytime, rule=_q07_gross_demand)

    # -------------------------------------------------------------------------
    # Q07GrossEmissCO2Supply (GAMS: "Compute total CO2eq GHG emissions per supply sector")
    # SUM(EFS, (V03InpTotTransf(allCy,SSBS,EFS,YTIME)$SSBSEMIT(SSBS) + VmConsFiEneSec) * imCo2EmiFac(allCy,SSBS,EFS,YTIME))
    # -------------------------------------------------------------------------
    def _q07_gross_supply(mod, cy, ss, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        lhs = 0.0
        for efs_ in efs:
            term = 0.0
            # Only supply subsectors in SSBSEMIT (PG, H2P, CHP, STEAMP) have transformation input term
            if ss in ssbsemit and hasattr(mod, "V03InpTotTransf"):
                term += mod.V03InpTotTransf[cy, ss, efs_, y]
            if hasattr(mod, "VmConsFiEneSec"):
                term += mod.VmConsFiEneSec[cy, ss, efs_, y]
            lhs += term * mod.imCo2EmiFac[cy, ss, efs_, y]
        return mod.V07GrossEmissCO2Supply[cy, ss, y] == lhs

    m.Q07GrossEmissCO2Supply = Constraint(run_cy, ssbs, ytime, rule=_q07_gross_supply)

    # -------------------------------------------------------------------------
    # Q07RedAbsBySrcRegTim (GAMS description):
    # This equation calculates the total absolute abatement of non-CO2 emissions for a specific source, country, and time period.
    # The determination is based on the Marginal Abatement Cost (MAC) curves, the exogenous carbon price, and specific unit conversion factors.
    # The equation identifies the maximum abatement potential by scanning the MAC curve steps and selecting the highest reduction level
    # where the implementation cost is less than or equal to the adjusted carbon price.
    # GAMS: V07RedAbsBySrcRegTim =E= smax(E07MAC$(p07MacCost <= iCarbValYrExog * p07UnitConvFactor), i07DataCh4N2OFMAC(...))
    # -------------------------------------------------------------------------
    def _q07_red_abs(mod, cy, src, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        carb = pyo_value(mod.iCarbValYrExog[cy, y]) or 0.0
        ucf = pyo_value(mod.p07UnitConvFactor[src]) or 1.0
        threshold = carb * ucf + _EPS
        admissible = [mac for mac in e07mac if (pyo_value(mod.p07MacCost[mac]) or 0.0) <= threshold]
        if not admissible:
            return mod.V07RedAbsBySrcRegTim[cy, src, y] == 0.0
        # smax in GAMS: max over admissible steps (numeric at rule build; Params may be mutable)
        best = max(
            (pyo_value(mod.i07DataCh4N2OFMAC[cy, src, mac, y]) or 0.0 for mac in admissible),
            default=0.0,
        )
        return mod.V07RedAbsBySrcRegTim[cy, src, y] == best

    m.Q07RedAbsBySrcRegTim = Constraint(run_cy, e07src, ytime, rule=_q07_red_abs)

    # -------------------------------------------------------------------------
    # Q07CostAbateBySrcRegTim (GAMS description):
    # This equation calculates the Total Cumulative Cost of all abatement actions combined for non-CO2 sources in a specific country and time period.
    # The calculation is based on the marginal reduction steps derived from the MAC curves and their corresponding implementation costs.
    # The equation computes the total investment required by summing the cost of each individual abatement step
    # (marginal reduction * step cost * cost correction) for all steps that fall strictly below or equal to the adjusted carbon price.
    # This represents the area under the MAC curve up to the implementation point.
    # The 'p07CostCorrection' handles the GWP conversion for F-gases to ensure we are paying for 'C-equivalents', not 'tons of gas'. Output units: [Mil $2015]
    # GAMS: sum(E07MAC$(p07MacCost <= iCarbValYrExog * p07UnitConvFactor), p07MarginalRed * p07MacCost * p07CostCorrection)
    # -------------------------------------------------------------------------
    def _q07_cost_abate(mod, cy, src, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        carb = pyo_value(mod.iCarbValYrExog[cy, y]) or 0.0
        ucf = pyo_value(mod.p07UnitConvFactor[src]) or 1.0
        threshold = carb * ucf + _EPS
        lhs = 0.0
        for mac in e07mac:
            if (pyo_value(mod.p07MacCost[mac]) or 0.0) <= threshold:
                lhs += mod.p07MarginalRed[cy, src, mac, y] * mod.p07MacCost[mac] * mod.p07CostCorrection[src]
        return mod.V07CostAbateBySrcRegTim[cy, src, y] == lhs

    m.Q07CostAbateBySrcRegTim = Constraint(run_cy, e07src, ytime, rule=_q07_cost_abate)

    # -------------------------------------------------------------------------
    # Q07EmiActBySrcRegTim (GAMS description):
    # This equation calculates the actual remaining non-CO2 emissions for a specific source, country, and time period after mitigation.
    # The calculation is based on the exogenous baseline emissions projection (what emissions would be without action) and the total absolute abatement
    # calculated in the previous step. The equation essentially subtracts the economically feasible abatement quantity from the baseline emissions
    # to derive the final volume of emissions released into the atmosphere.
    # Output units: CH4 and N2O: Mt C-eq, F-gases: kt-gas
    # GAMS: V07EmiActBySrcRegTim =E= i07DataCh4N2OFEmis - V07RedAbsBySrcRegTim
    # -------------------------------------------------------------------------
    def _q07_emi_act(mod, cy, src, y):
        if y not in time_set or cy not in run_cy:
            return Constraint.Skip
        return mod.V07EmiActBySrcRegTim[cy, src, y] == (
            mod.i07DataCh4N2OFEmis[cy, src, y] - mod.V07RedAbsBySrcRegTim[cy, src, y]
        )

    m.Q07EmiActBySrcRegTim = Constraint(run_cy, e07src, ytime, rule=_q07_emi_act)
