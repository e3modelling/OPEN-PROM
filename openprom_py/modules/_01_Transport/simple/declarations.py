"""
Transport (simple) module: add parameters and variables to the model.

Mirrors 01_Transport/simple/declarations.gms. All parameters are mutable so they
can be filled from CSV or from core input. Variables are used in transport
equations (Q01*) and in core/common; VmLft and VmDemFinEneTranspPerFuel are
shared with other modules.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets
from modules._01_Transport.simple import sets as t_sets


def add_transport_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 01_Transport parameters to the model.

    Index sets: runCy (countries), ytime (years), TRANSE (subsectors), DSBS, TECH,
    TTECH (transport techs), EF (fuels). All mutable for data loading.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    trans = list(core_sets.TRANSE)
    dsbs = list(core_sets.DSBS)
    tech = list(core_sets.TECH)
    ttech = list(core_sets.TTECH)
    ef = list(core_sets.EF)

    # GDP per capita (YTIME, allCy) — used in Gompertz and activity
    m.i01GDPperCapita = Param(ytime, run_cy, mutable=True, default=1.0, initialize={})
    # Share of annual mileage for plug-in hybrid (allCy, YTIME)
    m.i01ShareAnnMilePlugInHybrid = Param(run_cy, ytime, mutable=True, default=0.5, initialize={})
    # Passenger cars market saturation (allCy)
    m.i01PassCarsMarkSat = Param(run_cy, mutable=True, default=0.7, initialize={})
    # Technical lifetime by subsector and technology (allCy, DSBS, TECH, YTIME)
    m.i01TechLft = Param(run_cy, dsbs, tech, ytime, mutable=True, default=20.0, initialize={})
    # Average vehicle capacity/load factor (allCy, TRANSE, TRANSUSE, YTIME)
    m.i01AvgVehCapLoadFac = Param(run_cy, trans, core_sets.TRANSUSE, ytime, mutable=True, default=1.0, initialize={})
    # Gompertz parameters S1, S2 (allCy, SG)
    m.i01Sigma = Param(run_cy, t_sets.SG, mutable=True, default=0.0, initialize={})
    # Share of blended fuel (allCy, TRANSE, EF, YTIME); BLENDMAP used in equations
    m.i01ShareBlend = Param(run_cy, trans, ef, ytime, mutable=True, default=0.0, initialize={})
    # New car registrations total (allCy, YTIME)
    m.i01NewReg = Param(run_cy, ytime, mutable=True, default=0.0, initialize={})
    # Stock of passenger cars by tech (allCy, TTECH, YTIME) — historical
    m.i01StockPC = Param(run_cy, ttech, ytime, mutable=True, default=0.0, initialize={})
    # Initial specific fuel consumption (TRANSE, TTECH, EF)
    m.i01InitSpecFuelConsData = Param(trans, ttech, ef, mutable=True, default=0.0, initialize={})
    # Specific fuel consumption PC (allCy, TTECH, EF, YTIME)
    m.i01SFCPC = Param(run_cy, ttech, ef, ytime, mutable=True, default=0.0, initialize={})
    # Population (YTIME, allCy) — for ownership level
    m.i01Pop = Param(ytime, run_cy, mutable=True, default=0.001, initialize={})
    # GDP (YTIME, allCy) — billion US$2015
    m.i01GDP = Param(ytime, run_cy, mutable=True, default=1.0, initialize={})
    # GDP-dependent passenger cars market extension (allCy)
    m.i01GdpPassCarsMarkExt = Param(run_cy, mutable=True, default=1.0, initialize={})
    # Passenger cars scrapping rate (allCy) — used in calibration
    m.i01PassCarsScrapRate = Param(run_cy, mutable=True, default=0.05, initialize={})

    # t01NewShareStockPC(allCy, TRANSE, TTECH, YTIME) — calibration target for new
    # passenger car shares. Values >= 0 are targets used in the MatCalibration
    # objective (sum-of-squares); values < 0 trigger qRestrain (imMatrFactor == common).
    m.t01NewShareStockPC = Param(
        run_cy, trans, ttech, ytime,
        mutable=True,
        default=-1.0,  # negative = no target (triggers qRestrain in calibration)
        initialize={},
    )

    # --- Commented out in GAMS (01_Transport/simple/declarations.gms) ---
    # *Q01ConsSpecificFuel(allCy,TRANSE,TTECH,EF,YTIME) "Compute Specific Fuel Consumption"
    # *q01DemFinEneSubTransp(allCy,TRANSE,YTIME) "Compute final energy demand in transport"
    # *v01DemFinEneSubTransp(allCy,TRANSE,YTIME) "Final energy demand in transport subsectors (Mtoe)"


def add_transport_variables(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 01_Transport variables and shared VmLft, VmDemFinEneTranspPerFuel.

    VmLft (lifetime) and VmDemFinEneTranspPerFuel (final energy per fuel) are
    used by other modules; the V01* variables are transport-specific.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    trans = list(core_sets.TRANSE)
    dsbs = list(core_sets.DSBS)
    tech = list(core_sets.TECH)
    ttech = list(core_sets.TTECH)
    ef = list(core_sets.EF)

    # Goods transport activity (GU, GT, GN) — GAMS: V01ActivGoodsTransp
    m.V01ActivGoodsTransp = Var(run_cy, trans, ytime, domain=Reals, bounds=(0, None), initialize=0.1)
    # Gap between activity and calibration — Q01GapTranspActiv
    m.V01GapTranspActiv = Var(run_cy, trans, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Specific fuel consumption (by trans, ttech, ef) — Q01ConsTechTranspSectoral
    m.V01ConsSpecificFuel = Var(run_cy, trans, ttech, ef, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Cost per mean consumption size — Q01CostTranspPerMeanConsSize
    m.V01CostTranspPerMeanConsSize = Var(run_cy, trans, ttech, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    # Share of technology in transport — Q01ShareTechTr (uses imMatrFactor)
    m.V01ShareTechTr = Var(run_cy, trans, tech, ytime, domain=Reals, bounds=(0, None), initialize=0.1)
    # Consumption by tech and fuel — Q01ConsTechTranspSectoral
    m.V01ConsTechTranspSectoral = Var(run_cy, trans, ttech, ef, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Total passenger car stock — Q01StockPcYearly
    m.V01StockPcYearly = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.1)
    # Stock by technology — Q01StockPcYearlyTech
    m.V01StockPcYearlyTech = Var(run_cy, ttech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # New car registrations total — Q01NewRegPcYearly
    m.V01NewRegPcYearly = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # New registrations by tech — Q01NewRegPcTechYearly
    m.V01NewRegPcTechYearly = Var(run_cy, ttech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Passenger transport activity (PC, PA, etc.) — Q01ActivPassTrnsp
    m.V01ActivPassTrnsp = Var(run_cy, trans, ytime, domain=Reals, bounds=(0, None), initialize=0.1)
    # Number of cars scrapped — Q01NumPcScrap
    m.V01NumPcScrap = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Car ownership level (Gompertz) — Q01PcOwnPcLevl
    m.V01PcOwnPcLevl = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.1)
    # Scrappage rate by tech — Q01RateScrPc
    m.V01RateScrPc = Var(run_cy, ttech, ytime, domain=Reals, bounds=(0, None), initialize=0.05)
    # Annualized capital cost — Q01CapCostAnnualized
    m.V01CapCostAnnualized = Var(run_cy, trans, ttech, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Fuel cost — Q01CostFuel
    m.V01CostFuel = Var(run_cy, trans, ttech, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    # Premature scrapping share — Q01PremScrp (uses i01PremScrpFac)
    m.V01PremScrp = Var(run_cy, trans, ttech, ytime, domain=Reals, bounds=(0, 1), initialize=0.0)
    # Total scrappage rate by tech — Q01RateScrPcTot
    m.V01RateScrPcTot = Var(run_cy, ttech, ytime, domain=Reals, bounds=(0, 1), initialize=0.05)

    # Final energy demand per fuel (shared with other modules)
    m.VmDemFinEneTranspPerFuel = Var(run_cy, trans, ef, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    # Technical lifetime (shared; fixed in preloop for non-PC and historical PC)
    m.VmLft = Var(run_cy, dsbs, tech, ytime, domain=Reals, bounds=(0, None), initialize=10.0)

    # --- Commented out in GAMS (01_Transport/simple/declarations.gms) ---
    # *v01DemFinEneSubTransp(allCy,TRANSE,YTIME) "Final energy demand in transport subsectors (Mtoe)"
