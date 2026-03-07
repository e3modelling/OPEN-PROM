"""
Module 04_PowerGeneration (simple): declarations (parameters and variables).

Mirrors modules/04_PowerGeneration/simple/declarations.gms. Power generation capacity,
dispatch, costs, CHP estimate, and fuel consumption for electricity production.
Core provides: imPlantEffByType, imCO2CaptRate, imInstCapPastNonCHP, imInstCapPastCHP,
smGwToTwhPerYear. This module adds i04* parameters and V04* / Vm* variables.
Commented-out GAMS declarations are noted in comments.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_power_generation_parameters(m: ConcreteModel, core_sets_obj, config=None) -> None:
    """Add 04_PowerGeneration (simple) parameters. When config.calibration == 'MatCalibration',
    i04MatFacPlaAvailCap is declared as a variable (with bounds) and calibration targets are added."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    pgall = list(core_sets.PGALL)
    efs = list(core_sets.EFS)
    dsbs = list(core_sets.DSBS)
    calibration = getattr(config, "calibration", "off") if config else "off"

    # i04AvailRate(allCy, PGALL, YTIME): plant availability rate (1)
    m.i04AvailRate = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.85,
        initialize={},
    )
    # i04DataElecSteamGen(allCy, PGOTH, YTIME): various data (e.g. TOTNOMCAP)
    pgoth = list(core_sets.PGOTH)
    m.i04DataElecSteamGen = Param(
        run_cy, pgoth, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04DataElecProdNonCHP(allCy, PGALL, YTIME): electricity non-CHP production past (GWh)
    m.i04DataElecProdNonCHP = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04DataElecProdCHP(allCy, EF, YTIME): electricity CHP production past (GWh)
    ef = list(core_sets.EF)
    m.i04DataElecProdCHP = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04DataTechLftPlaType(PGALL, PGECONCHAR): e.g. LFT (lifetime)
    pgeconchar = list(core_sets.PGECONCHAR)
    m.i04DataTechLftPlaType = Param(
        pgall, pgeconchar,
        mutable=True,
        default=25.0,
        initialize={},
    )
    # i04TechLftPlaType(allCy, PGALL): technical lifetime per plant type (years)
    m.i04TechLftPlaType = Param(
        run_cy, pgall,
        mutable=True,
        default=25.0,
        initialize={},
    )
    # i04GrossCapCosSubRen(allCy, PGALL, YTIME): gross capital cost with subsidy (kUS$2015/kW) -> then /1000 in input
    m.i04GrossCapCosSubRen = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04FixOandMCost(allCy, PGALL, YTIME): fixed O&M (US$2015/kW)
    m.i04FixOandMCost = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04VarCost(PGALL, YTIME): variable cost other than fuel (US$2015/MWh); GAMS adds 1e-3
    m.i04VarCost = Param(
        pgall, ytime,
        mutable=True,
        default=0.001,
        initialize={},
    )
    # i04InvPlants(allCy, PGALL, YTIME): investment plants (MW); GAMS sets to 0
    m.i04InvPlants = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04PlantDecomSched(allCy, PGALL, YTIME): decommissioning schedule (GW); GAMS sets to 0
    m.i04PlantDecomSched = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04DecInvPlantSched(allCy, PGALL, YTIME): decided investment schedule (GW)
    m.i04DecInvPlantSched = Param(
        run_cy, pgall, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # iMatFacPlaAvailCapData / i04MatFacPlaAvailCap(allCy, PGALL, YTIME): maturity factor (1)
    # GAMS $IFTHEN.calib %Calibration% == MatCalibration: variable i04MatFacPlaAvailCap (LO=1e-6, UP=50);
    # $ELSE.calib: parameter i04MatFacPlaAvailCap = iMatFacPlaAvailCapData; $ENDIF.calib
    if calibration == "MatCalibration":
        m.iMatFacPlaAvailCapData = Param(
            run_cy, pgall, ytime,
            mutable=True,
            default=1.0,
            initialize={},
        )
        m.i04MatFacPlaAvailCap = Var(
            run_cy, pgall, ytime,
            domain=Reals,
            bounds=(1e-6, 50.0),
            initialize=1.0,
        )
        # Calibration targets: fix V04DemElecTot and (optionally) share targets
        m.t04DemElecTot = Param(
            run_cy, ytime,
            mutable=True,
            default=0.0,
            initialize={},
        )
        m.t04SharePowPlaNewEq = Param(
            run_cy, pgall, ytime,
            mutable=True,
            default=0.0,
            initialize={},
        )
    else:
        m.i04MatFacPlaAvailCap = Param(
            run_cy, pgall, ytime,
            mutable=True,
            default=1.0,
            initialize={},
        )
    # i04LoadFacElecDem(DSBS): load factor of electricity demand per sector (1)
    m.i04LoadFacElecDem = Param(
        dsbs,
        mutable=True,
        default=0.7,
        initialize={},
    )
    # iTotAvailNomCapBsYr(allCy, YTIME): total nominal available capacity in base year (GW)
    m.iTotAvailNomCapBsYr = Param(
        run_cy, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # i04ScaleEndogScrap: scale parameter for endogenous scrapping (1). GAMS: 2/card(PGALL)
    m.i04ScaleEndogScrap = Param(within=Reals, default=2.0 / max(len(pgall), 1), mutable=False)
    # i04MxmShareChpElec(allCy, YTIME): maximum share of CHP electricity (1). GAMS: 0.5
    m.i04MxmShareChpElec = Param(
        run_cy, ytime,
        mutable=True,
        default=0.5,
        initialize={},
    )
    # S04CapexBessRate: scalar for RES capex rate (1.3)
    m.S04CapexBessRate = Param(within=Reals, default=1.3, mutable=False)

    # --- Commented out in GAMS (04_PowerGeneration/simple/declarations.gms) ---
    # Equations:
    # *q04PotRenMinAllow(allCy,PGRENEF,YTIME) "Compute minimum allowed renewable potential"
    # *q04SecContrTotCHPProd(allCy,SBS,CHP,YTIME) "Compute sector contribution to total CHP production"
    # *q04CostPowGenLonMin(allCy,PGALL,YTIME) "Long-term minimum power generation cost"
    # *q04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME) "Compute long term power generation cost of technologies including international Prices of main fuels"
    # *q04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME) "Compute short term power generation cost of technologies including international Prices of main fuels"
    # *q04CostPowGenAvgShrt(allCy,ESET,YTIME) "Compute short term power generation cost"
    # Variables:
    # *v04PotRenMinAllow(allCy,PGRENEF,YTIME) "Minimum allowed renewable potential (GW)"
    # *v04SecContrTotCHPProd(allCy,SBS,CHP,YTIME) "Contribution of each sector in total CHP production (1)"
    # *v04CostPowGenLonMin(allCy,PGALL,YTIME) "Long-term minimum power generation cost (US$2015/kWh)"
    # *v04CostPowGenLongIntPri(allCy,PGALL,ESET,YTIME) "Long term power generation cost ... (kUS$2015/toe)"
    # *v04CostPowGenShortIntPri(allCy,PGALL,ESET,YTIME) "Short term power generation cost ... (kUS$2015/toe)"
    # *v04CostPowGenAvgShrt(allCy,ESET,YTIME) "Short-term average power generation cost (US$2015/kWh)"


def add_power_generation_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 04_PowerGeneration (simple) variables. Also Vm* used by 03_RestOfEnergy."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    pgall = list(core_sets.PGALL)
    efs = list(core_sets.EFS)
    _eps = 1e-10

    # V04CapElecNominal(allCy, PGALL, YTIME) — nominal capacity (GW)
    m.V04CapElecNominal = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04ShareTechPG = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04CapElecCHP = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    m.V04CostHourProdInvDec = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(1e-6, None),
        initialize=0.1,
    )
    m.V04CostVarTech = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(1e-6, None),
        initialize=0.1,
    )
    m.V04IndxEndogScrap = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=1.0,
    )
    m.V04CapElecNonCHP = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04GapGenCapPowerDiff = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04ShareSatPG = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.5,
    )
    m.V04SharePowPlaNewEq = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04SortPlantDispatch = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04NewCapElec = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    m.V04NetNewCapElec = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    m.V04CFAvgRen = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(_eps, None),
        initialize=0.3,
    )
    m.V04CapOverall = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04LoadFacDom = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(_eps, 1.0),
        initialize=0.5,
    )
    m.V04DemElecTot = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.0,
    )
    m.V04ProdElecEstCHP = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    m.V04CapexFixCostPG = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=100.0,
    )
    m.V04ShareMixWndSol = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=0.2,
    )
    m.V04CapexRESRate = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(1.0, None),
        initialize=1.0,
    )
    m.V04CO2CaptRate = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=0.0,
    )
    m.V04CostCapTech = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V04CCSRetroFit = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=1.0,
    )
    m.V04ScrpRate = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, 1),
        initialize=0.05,
    )
    # Interdependent
    m.VmProdElec = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.VmCostPowGenAvgLng = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.VmCapElecTotEst = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.VmPeakLoad = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.VmCapElec = Var(
        run_cy, pgall, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.VmConsFuelElecProd = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
