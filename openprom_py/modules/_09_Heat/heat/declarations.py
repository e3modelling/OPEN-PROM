"""
Module 09_Heat (heat): declarations (parameters and variables).

Mirrors modules/09_Heat/heat/declarations.gms. Steam demand (VmDemTotSte in 03), production by plant (VmProdSte in 03),
costs (V09CostVarProdSte, V09CostCapProdSte, V09CostProdSte), average cost (VmCostAvgProdSte), gap and shares (V09DemGapSte,
V09GapShareSte), scrapping (V09ScrapRate, V09ScrapRatePremature), capture rate (V09CaptRateSte), fuel consumption (VmConsFuelSteProd in 03).
Parameters from input: i09ProdLftSte, i09CaptRateSteProd, i09ScaleEndogScrap, i09AvailRateSteProd, i09CostVOMSteProd,
i09EffSteThrm, i09EffSteElc, i09PowToHeatRatio, i09CostInvCostSteProd, i09CostFixOMSteProd, i09ShareFuel.
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets

# Heat plants only (exclude TSTE placeholder for industry)
def _tsteam_heat():
    return list(core_sets.TCHP) + list(core_sets.TDHP)


def add_heat_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """Add 09_Heat (heat) parameters. Filled from input_loader or defaults."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    tsteam = _tsteam_heat()
    efs = list(core_sets.EFS)
    steam_ef = list(getattr(core_sets, "STEAMEF", ("LGN", "HCL", "GDO", "NGS", "BMSWAS", "H2F", "GEO", "NUC")))

    m.i09ProdLftSte = Param(tsteam, mutable=True, default=25.0, initialize={})
    m.i09CaptRateSteProd = Param(tsteam, mutable=True, default=0.0, initialize={})
    m.i09ScaleEndogScrap = Param(within=Reals, default=15.0 / max(len(tsteam), 1), mutable=False)
    m.i09AvailRateSteProd = Param(tsteam, ytime, mutable=True, default=0.9, initialize={})
    m.i09CostVOMSteProd = Param(tsteam, ytime, mutable=True, default=0.0, initialize={})
    m.i09EffSteThrm = Param(tsteam, ytime, mutable=True, default=0.35, initialize={})
    m.i09EffSteElc = Param(tsteam, ytime, mutable=True, default=0.0, initialize={})
    m.i09PowToHeatRatio = Param(tsteam, ytime, mutable=True, default=0.0, initialize={})
    m.i09CostInvCostSteProd = Param(tsteam, ytime, mutable=True, default=1.0, initialize={})
    m.i09CostFixOMSteProd = Param(tsteam, ytime, mutable=True, default=0.0, initialize={})
    m.i09ShareFuel = Param(run_cy, tsteam, steam_ef, ytime, mutable=True, default=0.0, initialize={})
    m.i09ParDHEffData = Param(steam_ef, mutable=True, default=0.78, initialize={})


def add_heat_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 09_Heat (heat) variables. VmDemTotSte, VmProdSte, VmConsFuelSteProd are in 03; only V09* and VmCostAvgProdSte here."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    tsteam = _tsteam_heat()
    stemode = list(getattr(core_sets, "STEMODE", ("CHP", "DHP")))
    steam_ef = list(getattr(core_sets, "STEAMEF", ("LGN", "HCL", "GDO", "NGS", "BMSWAS", "H2F", "GEO", "NUC")))

    m.V09ScrapRate = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, 1), initialize=0.5)
    m.V09DemGapSte = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.V09CostVarProdSte = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.V09CostCapProdSte = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.V09CostProdSte = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.V09GapShareSte = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, 1), initialize=0.1)
    m.V09CaptRateSte = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, 1), initialize=0.0)
    m.V09ScrapRatePremature = Var(run_cy, tsteam, ytime, domain=Reals, bounds=(0, 1), initialize=0.0)
    m.VmCostAvgProdSte = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
