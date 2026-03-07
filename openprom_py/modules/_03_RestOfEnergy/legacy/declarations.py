"""
Module 03_RestOfEnergy (legacy): declarations (parameters and variables).

Mirrors modules/03_RestOfEnergy/legacy/declarations.gms and input.gms.
This module implements the "Rest of Energy" balance: final consumption by fuel,
non-energy use, distribution losses, transformation (refineries, solids, gases, CHP),
primary production, and fake imports/exports. It ties together demand (Industry,
Transport) with supply-side transformation and trade.

Parameters come from CSV (loaded in input_loader) or from formulas in input.gms.
Variables V03* are specific to this module; Vm* (VmConsFinEneCountry, VmLossesDistr,
etc.) are "interdependent" and used by other modules too.

STUBS: Several variables/params are normally provided by other modules (Power/CHP/H2).
We declare stub versions here and fix them to 0 (or 1 for price indices) so that
all Q03* equations can be written. When those modules are implemented, replace
stubs with the real components.
"""

from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


# Supply subsectors that produce steam (CHP, DHP). Used for VmConsFuelSteProd index.
_STEAM_SECTORS = ("CHP", "DHP")

# World fuel price index set (GAMS: WEF or similar). Used for oil primary production equation.
_WEF = ("WCRO",)


def add_rest_of_energy_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add all parameters required by the RestOfEnergy (legacy) module.

    Data tables (i03DataGrossInlCons, i03PrimProd, etc.) are filled by
    load_rest_of_energy_data_into_model(). Derived params (i03FeedTransfr,
    i03ResTransfOutputRefineries, etc.) are computed in the input loader or preloop.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    ssbs = list(core_sets.SSBS)
    efs = list(core_sets.EFS)
    ef = list(core_sets.EF)
    kpdl = list(core_sets.KPDL)[:5]  # a1..a5 for oil PDL

    # --- Raw data tables (from CSV) ---
    # Gross inland consumption by country and energy form (Mtoe). Base for balance.
    m.i03DataGrossInlCons = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Own consumption of energy branch by supply sector (Mtoe). Used to fix VmConsFiEneSec.
    m.i03DataOwnConsEne = Param(
        run_cy, ssbs, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Supplementary transfers (Mtoe). Becomes i03FeedTransfr after input formulas.
    m.i03SuppTransfers = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Primary production by energy form (Mtoe). Used to fix V03ProdPrimary in preloop.
    m.i03PrimProd = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Supplementary rate for primary production in total primary needs (1). Base-year source for i03RatePriProTotPriNeeds.
    m.i03SuppRatePrimProd = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Ratio of electricity net imports in final demand (1). Used for i03RatioImpFinElecDem.
    # Index (allCy, SUPOTH, YTIME); SUPOTH = single value "ELC_IMP" in legacy.
    _supoth = ["ELC_IMP"]
    m.i03ElcNetImpShare = Param(
        run_cy, _supoth, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Total transformation output by supply sector (Mtoe). Used to fix V03OutTotTransf, V03OutTransfRefSpec, etc.
    m.i03OutTotTransfProcess = Param(
        run_cy, ssbs, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Total transformation input by supply sector (Mtoe). Used to fix V03InpTotTransf.
    m.i03InpTotTransfProcess = Param(
        run_cy, ssbs, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Rate of energy branch own consumption over total transformation output (1). Used in Q03ConsFiEneSec.
    m.i03RateEneBranCons = Param(
        run_cy, ssbs, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Natural gas primary production elasticity (1). Scalar per country in GAMS.
    m.i03NatGasPriProElst = Param(
        run_cy,
        mutable=True,
        default=0.5,
        initialize={},
    )
    # Polynomial distribution lag coefficients for primary oil production (1). GAMS: a1..a5.
    m.i03PolDstrbtnLagCoeffPriOilPr = Param(
        kpdl,
        mutable=True,
        default=0.25,
        initialize={"a1": 1.666706504, "a2": 1.333269594, "a3": 1.000071707, "a4": 0.666634797, "a5": 0.33343691},
    )

    # --- Derived parameters (set in input_loader or from formulas) ---
    # Feedstocks in transfers (Mtoe). Equals i03SuppTransfers in input.
    m.i03FeedTransfr = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Residual in transformation output from refineries (1). From supplementary table.
    m.i03ResTransfOutputRefineries = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )
    # Rate of primary production in total primary needs (1). From base-year i03SuppRatePrimProd.
    m.i03RatePriProTotPriNeeds = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Residuals for hard coal, natural gas and oil primary production (1). From supplementary.
    m.i03ResHcNgOilPrProd = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )
    # Ratio of imports in final electricity demand (1). From i03ElcNetImpShare.
    m.i03RatioImpFinElecDem = Param(
        run_cy, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # Total energy branch consumption by EFS (sum over SSBS of i03DataOwnConsEne). Used in preloop.
    m.i03TotEneBranchCons = Param(
        run_cy, efs, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )

    # --- Supplementary parameters (GAMS: set to 1 or from CSV; used for i03ResHcNgOilPrProd) ---
    # i03SupResRefCapacity(allCy, SUPOTH, YTIME). GAMS: = 1; then i03ResHcNgOilPrProd(HCL/NGS/CRO) from it.
    _supoth_full = ["ELC_IMP", "REF_CAP_RES", "HCL_PPROD", "NGS_PPROD", "OIL_PPROD"]
    m.i03SupResRefCapacity = Param(
        run_cy, _supoth_full, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )
    # i03SupTrnasfOutputRefineries(allCy, EF, YTIME). GAMS: = 1; source for i03ResTransfOutputRefineries.
    m.i03SupTrnasfOutputRefineries = Param(
        run_cy, ef, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )

    # --- Commented out in GAMS (transferred for reference) ---
    # *i03RefCapacity(allCy,YTIME) "Refineries Capacity (Million Barrels/day)"
    # (Would be used in Q03CapRef equation and i03ResRefCapacity; both commented in GAMS.)

    # --- Stub parameters for equations that reference other modules ---
    # Oil price index (world crude). Used in Q03ProdPrimary for CRO. Stub = 1 so product is neutral.
    m.imPriceFuelsInt = Param(
        _WEF, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )
    m.imPriceFuelsIntBase = Param(
        _WEF, ytime,
        mutable=True,
        default=1.0,
        initialize={},
    )


def add_rest_of_energy_variables(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add all variables for the RestOfEnergy module plus stubs for Power/CHP/H2.

    V03* and Vm* (VmImpNetEneBrnch, VmConsFiEneSec, VmConsFinEneCountry, VmConsFinNonEne,
    VmLossesDistr) are the real variables. Stubs (V04ProdElecEstCHP, VmProdSte, etc.)
    are fixed to 0 in preloop so that Q03* constraints are well-defined.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    ssbs = list(core_sets.SSBS)
    efs = list(core_sets.EFS)
    sbs = list(core_sets.SBS)
    toctef = list(core_sets.TOCTEF)
    tsteam = list(core_sets.TSTEAM)
    pgall = list(core_sets.PGALL)

    # --- Transformation outputs ---
    # CHP output (ELC, STE) in Mtoe. Linked to VmProdSte and V04ProdElecEstCHP in equations.
    m.V03OutTransfCHP = Var(
        run_cy, toctef, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Refinery output by product (Mtoe). Per EFS in LQD sector.
    m.V03OutTransfRefSpec = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03OutTransfGasses = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03OutTransfSolids = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Transformation inputs to LQD, SLD, GAS (Mtoe).
    m.V03InputTransfRef = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03InputTransfSolids = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03InputTransfGasses = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Total transformation input/output by supply sector and EFS (Mtoe).
    m.V03InpTotTransf = Var(
        run_cy, ssbs, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03OutTotTransf = Var(
        run_cy, ssbs, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Transfers (Mtoe).
    m.V03Transfers = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Gross inland consumption excluding / including energy branch (Mtoe).
    m.V03ConsGrssInlNotEneBranch = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    m.V03ConsGrssInl = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Primary production (Mtoe).
    m.V03ProdPrimary = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Fake exports and imports (Mtoe). Q03Exp, Q03Imp.
    m.V03Exp = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    m.V03Imp = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )

    # --- Interdependent variables (used across modules) ---
    # Net imports (Mtoe). Q03ImpNetEneBrnch.
    m.VmImpNetEneBrnch = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(None, None),
        initialize=0.0,
    )
    # Final consumption in energy sector by supply sector (Mtoe). Q03ConsFiEneSec.
    m.VmConsFiEneSec = Var(
        run_cy, ssbs, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Total final energy consumption by country and EFS (Mtoe). Q03ConsFinEneCountry.
    m.VmConsFinEneCountry = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Final non-energy consumption (Mtoe). Q03ConsFinNonEne.
    m.VmConsFinNonEne = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Distribution losses (Mtoe). Q03LossesDistr.
    m.VmLossesDistr = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )

    # --- Stub variables (from Power/CHP/H2 modules; fixed to 0 in preloop) ---
    # When 04_PowerGeneration is loaded, it declares V04ProdElecEstCHP, VmProdElec,
    # VmConsFuelElecProd, VmCapElecTotEst, VmPeakLoad, VmCapElec; skip those here.
    # CHP electricity production (Mtoe). Used in Q03OutTransfCHP.
    if not hasattr(m, "V04ProdElecEstCHP"):
        m.V04ProdElecEstCHP = Var(
            run_cy, ytime,
            domain=Reals,
            bounds=(0, None),
            initialize=0.0,
        )
    # Steam production by technology (Mtoe). Used in Q03OutTransfCHP for STE.
    m.VmProdSte = Var(
        run_cy, tsteam, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Fuel consumption for electricity production (Mtoe). Used in Q03InpTotTransf for PG.
    if not hasattr(m, "VmConsFuelElecProd"):
        m.VmConsFuelElecProd = Var(
            run_cy, efs, ytime,
            domain=Reals,
            bounds=(0, None),
            initialize=0.0,
        )
    # Fuel consumption for steam production by CHP/DHP (Mtoe). Used in Q03InpTotTransf.
    m.VmConsFuelSteProd = Var(
        run_cy, _STEAM_SECTORS, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Fuel consumption for H2 production (Mtoe). Used in Q03ConsFiEneSec for H2P.
    m.VmConsFuelH2Prod = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # CDR production fuel consumption (Mtoe). Used in Q03ConsFinEneCountry.
    m.VmConsFuelCDRProd = Var(
        run_cy, efs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Total hydrogen demand (Mtoe). Used in Q03LossesDistr for H2.
    m.VmDemTotH2 = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Hydrogen demand by sector (Mtoe). Used in Q03LossesDistr.
    m.VmDemSecH2 = Var(
        run_cy, sbs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
    # Electricity production by plant type (GWh or Mtoe). Used in Q03OutTotTransf for PG.
    if not hasattr(m, "VmProdElec"):
        m.VmProdElec = Var(
            run_cy, pgall, ytime,
            domain=Reals,
            bounds=(0, None),
            initialize=0.0,
        )
    # Total steam demand (Mtoe). Used in Q03OutTotTransf for STEAMP.
    m.VmDemTotSte = Var(
        run_cy, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )

    # --- Commented out in GAMS (transferred for reference) ---
    # *q03ConsTotFinEne(YTIME) "Compute total final energy consumption in ALL countries"
    # *Q03CapRef(allCy,YTIME) "Compute refineries capacity"
    # *v03ConsTotFinEne(YTIME) "Total final energy Consumption in ALL COUNTRIES (Mtoe)"
    # *V03CapRef(allCy,YTIME) "Refineries capacity (Million barrels/day)"
