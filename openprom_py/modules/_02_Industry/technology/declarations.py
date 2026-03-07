"""
Industry (technology) module: parameters and variables.

Mirrors 02_Industry/technology/declarations.gms. All parameters are mutable
for data loading. Variables are used in Q02* equations and VmConsFuel
is the fuel consumption by subsector/fuel (interdependent with other modules).
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_industry_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 02_Industry technology parameters.

    Index sets: runCy, DSBS, ITECH, EF, YTIME, ETYPES. Excludes TRANSE and CDR
    in equation definitions; parameters are declared over full index sets with defaults.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    itech = list(core_sets.ITECH)
    ef = list(core_sets.EF)

    # i02ExogDemOfBiomass(allCy, DSBS, YTIME) — exogenous traditional biomass demand
    m.i02ExogDemOfBiomass = Param(
        run_cy, dsbs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i02ElastNonSubElec(allCy, DSBS, ETYPES, YTIME) — elasticities non-substitutable electricity
    m.i02ElastNonSubElec = Param(
        run_cy, dsbs, core_sets.ETYPES, ytime,
        mutable=True,
        default=0.5,
        initialize={},
    )
    # i02util(allCy, DSBS, ITECH, YTIME) — utilization rate of technology
    m.i02util = Param(
        run_cy, dsbs, itech, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )
    # imCO2CaptRateIndustry(allCy, ITECH, YTIME) — industry CO2 capture rate (0–1)
    m.imCO2CaptRateIndustry = Param(
        run_cy, itech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i02ScaleEndogScrap(DSBS) — scale for endogenous scrapping
    m.i02ScaleEndogScrap = Param(
        dsbs,
        mutable=True,
        default=1.0,
        initialize={},
    )
    # i02ShareBlend(allCy, DSBS, ITECH, EF, YTIME) — share of each energy form in a technology
    m.i02ShareBlend = Param(
        run_cy, dsbs, itech, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i02ElaSub(allCy, DSBS) — elasticity by subsector (technology choice)
    m.i02ElaSub = Param(
        run_cy, dsbs,
        mutable=True,
        default=2.0,
        initialize={},
    )

    # --- Commented out in GAMS (02_Industry/technology/declarations.gms) ---
    # !!Q02CapCostTech1(allCy,DSBS,ITECH,YTIME)
    # !!V02CapCostTech1(allCy,DSBS,ITECH,YTIME)
    # (Industry legacy: *Q02CostProdCHPDem, *q02ConsTotElecInd, *q02DemFinSubFuelInd, *Q02CostVarAvgElecProd,
    #  *vmConsTotElecInd, *vmDemFinSubFuelInd)


def add_industry_variables(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 02_Industry technology variables and VmConsFuel.

    Variables follow GAMS names (V02*, VmConsFuel). Bounds and initialisation
    are set in preloop where needed.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    itech = list(core_sets.ITECH)
    ef = list(core_sets.EF)
    inddom = list(core_sets.INDDOM)

    # Demand for useful substitutable energy per subsector
    m.V02DemSubUsefulSubsec = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(1e-10, None),
        initialize=1.0,
    )
    # Remaining equipment capacity per technology per subsector
    m.V02RemEquipCapTechSubsec = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Useful energy covered by remaining equipment
    m.V02DemUsefulSubsecRemTech = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Gap in useful energy demand per subsector (Mtoe)
    m.V02GapUsefulDemSubsec = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(1e-6, None),
        initialize=0.1,
    )
    # Capital cost of each technology per subsector
    m.V02CapCostTech = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    # Variable cost of each technology per subsector
    m.V02VarCostTech = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    # Total cost (capital + variable - subsidy) per technology
    m.V02CostTech = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    # Share of each technology in new equipment (gap)
    m.V02ShareTechNewEquipUseful = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Equipment capacity per technology per subsector
    m.V02EquipCapTechSubsec = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Non-substitutable useful electricity (INDDOM)
    m.V02UsefulElecNonSubIndTert = Var(
        run_cy, inddom, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Final energy of non-substitutable electricity
    m.V02FinalElecNonSubIndTert = Var(
        run_cy, inddom, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Electricity price index for industry
    m.V02IndxElecIndPrices = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    # Average efficiency (useful / final)
    m.V02IndAvrEffFinalUseful = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(1e-6, None),
        initialize=0.5,
    )
    # Premature scrapping (0–1)
    m.V02PremScrpIndu = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=0.0,
    )
    # Ratio remaining (1 - 1/lifetime)*(1 - prem scrap)
    m.V02RatioRem = Var(
        run_cy, dsbs, itech, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=0.95,
    )
    # Fuel consumption by subsector and energy form (interdependent)
    m.VmConsFuel = Var(
        run_cy, dsbs, ef, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )

    # --- Commented out in GAMS (02_Industry/technology/declarations.gms) ---
    # !!V02CapCostTech1(allCy,DSBS,ITECH,YTIME)
