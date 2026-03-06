"""
Core parameter and variable declarations.

Adds to a Pyomo ConcreteModel all core parameters and variables defined in
core/declarations.gms that are needed for the dummy objective and for the
Transport module (and for preloop fixes). Index sets are taken from core/sets
and from core_sets_obj (runCy, ytime).

Does not add VmPriceFuelSubsecCarVal, VmPriceFuelAvgSub, VmSubsiDemTech — those
are provided by the price stub (prices_stub.py) so that 08_Prices and 11_Economy
modules are not required for the PoC.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_core_parameters(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add core parameters to the model.

    All are mutable so that load_core_data_into_model() can fill them from CSV.
    Defaults are set for sparse access; unused indices return the default.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    dsbs = list(core_sets.DSBS)
    trans = list(core_sets.TRANSE)
    tech = list(core_sets.TECH)
    ef = list(core_sets.EF)
    kpdl = list(core_sets.KPDL)

    # Scalars (GAMS: smTWhToMtoe, epsilon6)
    m.smTWhToMtoe = Param(within=Reals, default=0.086, mutable=False)
    m.epsilon6 = Param(within=Reals, default=1e-6, mutable=False)

    # PDL coefficients: set in preloop, not from CSV
    m.imFPDL = Param(
        dsbs, kpdl,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imElastA(allCy, SBS, ETYPES, YTIME) — from CSV
    m.imElastA = Param(
        run_cy, sbs, core_sets.ETYPES, ytime,
        mutable=True,
        default=0.5,
        initialize={},
    )

    # imCGI(allCy, YTIME) — scenario capital goods index
    m.imCGI = Param(
        run_cy, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )

    # imDisc(allCy, SBS, YTIME)
    m.imDisc = Param(
        run_cy, sbs, ytime,
        mutable=True,
        default=0.1,
        initialize={},
    )

    # imCapCostTech(allCy, SBS, TECH, YTIME)
    m.imCapCostTech = Param(
        run_cy, sbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imVarCostTech(allCy, SBS, TECH, YTIME)
    m.imVarCostTech = Param(
        run_cy, sbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imFuelConsPerFueSub(allCy, SBS, EF, YTIME)
    m.imFuelConsPerFueSub = Param(
        run_cy, sbs, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imActv(YTIME, allCy, DSBS)
    m.imActv = Param(
        ytime, run_cy, dsbs,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imTransChar(allCy, TRANSPCHAR, YTIME)
    m.imTransChar = Param(
        run_cy, core_sets.TRANSPCHAR, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imShrNonSubElecInTotElecDem(allCy, SBS)
    m.imShrNonSubElecInTotElecDem = Param(
        run_cy, sbs,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # iShrHeatPumpElecCons(allCy, SBS)
    m.iShrHeatPumpElecCons = Param(
        run_cy, sbs,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imFixOMCostTech(allCy, SBS, TECH, YTIME)
    m.imFixOMCostTech = Param(
        run_cy, sbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imUsfEneConvSubTech(allCy, SBS, TECH, YTIME)
    m.imUsfEneConvSubTech = Param(
        run_cy, sbs, tech, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )

    # imMatrFactor(allCy, DSBS, TECH, YTIME) — Maturity factor per technology and subsector (1).
    # Used in Transport Q01ShareTechTr. Loaded from iMatrFactorData in core input.
    m.imMatrFactor = Param(
        run_cy, dsbs, tech, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )

    # i01PremScrpFac(allCy, DSBS, TECH, YTIME) — Parameter that controls premature scrapping.
    # Used in Transport Q01PremScrp. Loaded from iPremScrpFac.csv in core input.
    m.i01PremScrpFac = Param(
        run_cy, dsbs, tech, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )


def add_core_variables(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add core variables to the model.

    Bounds and initial values for calibration-related vars (VmRenValue, VmCarVal,
    VmElecConsHeatPla) are set in core preloop. vDummyObj is the PoC objective;
    common(cy, trans, y) is used by Transport and other modules.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    dsbs = list(core_sets.DSBS)
    trans = list(core_sets.TRANSE)
    nap = list(core_sets.NAP)

    # Objective variable for PoC (minimize vDummyObj; constraint qDummyObj fixes it to 1)
    m.vDummyObj = Var(domain=Reals, initialize=1.0)
    # Electricity consumption of heat plants (allCy, DSBS, YTIME)
    m.VmElecConsHeatPla = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Car value (allCy, NAP, YTIME) — used in calibration
    m.VmCarVal = Var(
        run_cy, nap, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Renewable value (YTIME) — used in calibration
    m.VmRenValue = Var(
        ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Common transport activity (allCy, TRANSE, YTIME); linked to Transport module
    m.common = Var(
        run_cy, trans, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
