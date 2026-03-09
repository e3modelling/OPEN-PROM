"""
Core parameter and variable declarations for OPEN-PROM.

Adds to a Pyomo ConcreteModel all core parameters and variables defined in
core/declarations.gms that are shared across modules. Index sets come from
core/sets and from core_sets_obj (runCy, ytime).

VmPriceFuelSubsecCarVal, VmPriceFuelAvgSub, VmSubsiDemTech are provided by
08_Prices and 11_Economy modules; a fallback price stub (prices_stub.py)
adds them as Params when those modules' Vars are not yet declared.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_core_parameters(m: ConcreteModel, core_sets_obj: core_sets.CoreSets) -> None:
    """
    Add core parameters to the model.

    All are mutable so that load_core_data_into_model() can fill them from CSV.
    Defaults are set for sparse access; unused indices return the default.
    Parameters used by RestOfEnergy (03): imRateLossesFinCons, imDistrLosses,
    imFuelImports, imFuelExprts.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    dsbs = list(core_sets.DSBS)
    trans = list(core_sets.TRANSE)
    tech = list(core_sets.TECH)
    ef = list(core_sets.EF)
    efs = list(core_sets.EFS)  # Supply-side energy form aggregate (used by 03_RestOfEnergy)
    kpdl = list(core_sets.KPDL)

    # --- Scalars: conversion factors and small constants ---
    # smTWhToMtoe: TWh to Mtoe (e.g. for electricity output in balance equations)
    m.smTWhToMtoe = Param(within=Reals, default=0.086, mutable=False)
    # epsilon6: small number to avoid division by zero in ratio constraints
    m.epsilon6 = Param(within=Reals, default=1e-6, mutable=False)
    # sUnitToKUnit: units to thousands (e.g. vehicles to k-vehicles)
    m.sUnitToKUnit = Param(within=Reals, default=1000.0, mutable=False)
    # 07_Emissions: tCO2 <-> tC conversion (1 tC = 3.66 tCO2); used in p07UnitConvFactor and p07CostCorrection
    m.smCtoCO2 = Param(within=Reals, default=3.66, mutable=False)
    # 07_Emissions: deflators 2015->2010 (CH4/N2O MAC in 2010$) and 2015->2005 (F-gases in 2005$)
    m.smDefl_15_to_10 = Param(within=Reals, default=1.0, mutable=False)
    m.smDefl_15_to_05 = Param(within=Reals, default=1.0, mutable=False)
    # 08_Prices / 09_Heat: fraction of electricity price at which CHP sells to grid; max electricity-to-steam ratio in CHP
    m.smFracElecPriChp = Param(within=Reals, default=0.5, mutable=False)
    m.smElecToSteRatioChp = Param(within=Reals, default=1.0, mutable=False)

    # imCo2EmiFac(allCy, SBS/SSBS, EF, YTIME) — CO2 emission factor (kgCO2/kgoe).
    # GAMS indexes by both demand SBS and supply SSBS; 07_Emissions uses imCo2EmiFac(allCy,SSBS,EFS,YTIME) for supply.
    # So we include all of SSBS (PG, H2P, STEAMP, LQD, SLD, GAS, CHP) in addition to SBS (DSBS).
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]
    m.imCo2EmiFac = Param(
        run_cy, sbs_and_supply, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

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

    # imDisc(allCy, SBS, YTIME). SBS includes supply sectors PG, H2P, STEAMP for 04_PowerGeneration.
    m.imDisc = Param(
        run_cy, sbs_and_supply, ytime,
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

    # 11_Economy: imCapCostTechMin(allCy, DSBS, TECH, YTIME) — minimum cap cost fraction (1 = no subsidy below this)
    m.imCapCostTechMin = Param(
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

    # 08_Prices: imEffValueInDollars(allCy, SBS, YTIME) — efficiency value in dollars for electricity/heat pump price component
    m.imEffValueInDollars = Param(
        run_cy, sbs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imFuelPrice(allCy, SBS, EF, YTIME) — base fuel price ($/toe); 08_Prices preloop uses it for V08FuelPriSubNoCarb; GAMS rescales to k$/toe
    m.imFuelPrice = Param(
        run_cy, sbs_and_supply, ef, ytime,
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

    # -------------------------------------------------------------------------
    # Parameters used by module 03_RestOfEnergy (energy balance, losses, trade)
    # -------------------------------------------------------------------------

    # imRateLossesFinCons(allCy, EFS, YTIME): Rate of distribution losses over
    # "available for final consumption". Used in Q03LossesDistr. Formula in GAMS:
    # imDistrLosses / (sum over DSBS of imFuelConsPerFueSub + i03PrimProd for CRO);
    # for future years set to base-year value. Unit: (1).
    m.imRateLossesFinCons = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imDistrLosses(allCy, EF, YTIME): Distribution losses by fuel (Mtoe).
    # Used to compute imRateLossesFinCons in 03 input and to fix VmLossesDistr in preloop.
    m.imDistrLosses = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imFuelImports(allCy, EF, YTIME): Fuel imports (Mtoe). Used in 03 preloop
    # to fix V03Imp for natural gas in historical years.
    m.imFuelImports = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # imFuelExprts(allCy, EF, YTIME): Fuel exports (Mtoe). Used in Q03Exp and
    # 03 preloop to fix V03Exp in historical years.
    m.imFuelExprts = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # -------------------------------------------------------------------------
    # Parameters used by module 04_PowerGeneration (plant efficiency, capacity, GW->TWh)
    # -------------------------------------------------------------------------

    # imPlantEffByType(allCy, PGALL, YTIME): Plant efficiency per plant type (1). From iDataPlantEffByType.
    pgall = list(core_sets.PGALL)
    m.imPlantEffByType = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.35,
        initialize={},
    )
    # imCO2CaptRate(PGALL): CO2 capture rate for CCS plants (1). GAMS: 0.90 for CCS(PGALL).
    m.imCO2CaptRate = Param(
        pgall,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # imInstCapPastNonCHP(allCy, PGALL, YTIME): Installed non-CHP capacity past (GW). From core input.
    m.imInstCapPastNonCHP = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # imInstCapPastCHP(allCy, EF, YTIME): Installed CHP capacity by fuel (GW). From core input.
    # iCarbValYrExog(allCy, YTIME): exogenous carbon value (e.g. $/tCO2) for 07_Emissions non-CO2 MAC
    m.iCarbValYrExog = Param(
        run_cy, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    m.imInstCapPastCHP = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # smGwToTwhPerYear(YTIME): Convert GW mean power to TWh/year (8.76 or 8.784 for leap years).
    m.smGwToTwhPerYear = Param(
        ytime,
        mutable=True,
        default=8.76,
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
    # CO2 sequestration cost (allCy, YTIME) — used by Industry
    m.VmCstCO2SeqCsts = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    # Electricity price index for industry (allCy, YTIME)
    m.VmPriceElecInd = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
