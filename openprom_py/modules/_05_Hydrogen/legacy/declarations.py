"""
Module 05_Hydrogen (legacy): declarations (parameters and variables).

Mirrors modules/05_Hydrogen/legacy/declarations.gms. Hydrogen production technologies,
costs, CCS/no-CCS shares, demand gap, and fuel consumption. Core provides imDisc,
imCo2EmiFac (with H2P), NAPtoALLSBS; 04 provides V04CapexFixCostPG, i04VarCost, i04AvailRate.
03_RestOfEnergy already declares VmDemTotH2, VmDemSecH2, VmConsFuelH2Prod; this module
declares V05*, VmProdH2, VmCostAvgProdH2, VmConsFuelTechH2Prod.

--- GAMS $ontext ... $offtext (commented out in GAMS; transferred as comments) ---
$ontext
*'                **Infrastructure Variables**
V05H2InfrArea(allCy, YTIME)                       "Number of stylised areas covered by H2 infrastructure"
V05DelivH2InfrTech(allCy, INFRTECH, YTIME)        "Hydrogen delivered by infrastructure technology in Mtoe"
V05InvNewReqH2Infra(allCy, INFRTECH, YTIME)       "New infrastructure requirements in Mtoe of delivered hydrogen"
V05H2Pipe(allCy, INFRTECH, YTIME)                 "Required capacity to meet the new infrastructure requirements"
                                                    !! - km of pipelines, !! - number of service stations
V05CostInvTechH2Infr(allCy, INFRTECH, YTIME)      "Investment cost of infrastructure by technology in Million Euros (MEuro)"
V05CostInvCummH2Transp(allCy, INFRTECH, YTIME)    "Average cost of infrastructure Euro per toe"
V05CostTechH2Infr(allCy, INFRTECH, YTIME)         "Marginal cost by infrastructure technology in Euro"
V05TariffH2Infr(allCy, INFRTECH, YTIME)           "Tarrif paid by the final consumer ... Euro per toe annual"
V05PriceH2Infr(allCy, SBS, YTIME)                 "Hydrogen distribution and storage price paid by final consumer in Euro per toe annual"
V05CostTotH2(allCy, SBS, YTIME)                   "Total Hydrogen Cost Per Sector in Euro per toe"
*' *** Miscellaneous
*V05ProdCapH2Tech(allCy, H2TECH, YTIME)           "Production capacity by H2 production technology"
$offtext
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_hydrogen_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """Add 05_Hydrogen (legacy) parameters. Filled from input_loader."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    h2tech = list(core_sets.H2TECH)
    ef = list(core_sets.EF)
    # ECONCHARHY and ARELAST from GAMS (used in input tables)
    econcharhy = ("IC", "FC", "VC", "EFF", "SELF", "AVAIL", "LFT", "H2KMTOE", "CR", "B", "mid", "MAXAREA", "AREA")
    arelast = ("B", "mid")
    # INFRTECH from sets.gms (for infra params; infrastructure equations are commented out)
    infrtech = ("tpipa", "hpipi", "hpipu", "mpipu", "lpipu", "mpips", "ssgg")

    # Scalars (GAMS: s05AreaStyle, s05SalesH2Station, s05LenH2StationConn, s05DelivH2Turnpike)
    m.s05AreaStyle = Param(within=Reals, default=3025.0, mutable=False)
    m.s05SalesH2Station = Param(within=Reals, default=2.26, mutable=False)
    m.s05LenH2StationConn = Param(within=Reals, default=2.0, mutable=False)
    m.s05DelivH2Turnpike = Param(within=Reals, default=275.0, mutable=False)

    # Parameters (filled in input_loader from CSV or formulas)
    m.i05WBLGammaH2Prod = Param(run_cy, ytime, mutable=True, default=1.0, initialize={})
    m.i05ProdLftH2 = Param(h2tech, ytime, mutable=True, default=20.0, initialize={})
    m.i05CaptRateH2Prod = Param(h2tech, mutable=True, default=0.0, initialize={})
    m.i05CostCapH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.0, initialize={})
    m.i05CostFOMH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.0, initialize={})
    m.i05CostVOMH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.0, initialize={})
    m.i05AvailH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.85, initialize={})
    m.i05EffH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.7, initialize={})
    m.iWBLShareH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.1, initialize={})
    m.iWBLPremRepH2Prod = Param(run_cy, h2tech, ytime, mutable=True, default=0.1, initialize={})
    # Infrastructure (for possible future use; equations commented out in GAMS)
    m.i05TranspLftH2 = Param(infrtech, ytime, mutable=True, default=40.0, initialize={})
    m.i05CostInvH2Transp = Param(run_cy, infrtech, ytime, mutable=True, default=0.0, initialize={})
    m.i05EffH2Transp = Param(run_cy, infrtech, ytime, mutable=True, default=0.99, initialize={})
    m.i05ConsSelfH2Transp = Param(run_cy, infrtech, ytime, mutable=True, default=0.0, initialize={})
    m.i05AvailRateH2Transp = Param(infrtech, ytime, mutable=True, default=0.95, initialize={})
    m.i05CostInvVOMH2 = Param(infrtech, ytime, mutable=True, default=0.0, initialize={})
    m.i05CostInvFOMH2 = Param(infrtech, ytime, mutable=True, default=0.0, initialize={})
    m.i05PipeH2Transp = Param(infrtech, ytime, mutable=True, default=0.0, initialize={})
    m.i05KmFactH2Transp = Param(run_cy, infrtech, mutable=True, default=1.0, initialize={})
    m.i05PolH2AreaMax = Param(run_cy, mutable=True, default=0.0, initialize={})
    m.i05HabAreaCountry = Param(run_cy, mutable=True, default=1e6, initialize={})
    m.i05EffNetH2Transp = Param(run_cy, infrtech, ytime, mutable=True, default=0.99, initialize={})
    m.i05CostAvgWeight = Param(run_cy, ytime, mutable=True, default=1.0, initialize={})
    m.i05H2Adopt = Param(run_cy, arelast, ytime, mutable=True, default=0.5, initialize={})


def add_hydrogen_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 05_Hydrogen (legacy) variables. VmDemTotH2, VmDemSecH2, VmConsFuelH2Prod are in 03."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    h2tech = list(core_sets.H2TECH)
    ef = list(core_sets.EF)
    sbs = list(core_sets.SBS)

    # V05* variables
    m.V05GapShareH2Tech1 = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.1)
    m.V05GapShareH2Tech2 = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.1)
    m.V05CapScrapH2ProdTech = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.0)
    m.V05PremRepH2Prod = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=1.0)
    m.V05ScrapLftH2Prod = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.05)
    m.V05DemGapH2 = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=10.0)
    m.V05CostProdH2Tech = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, None), initialize=2.0)
    m.V05CostVarProdH2Tech = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, None), initialize=2.0)
    m.V05ShareCCSH2Prod = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.5)
    m.V05ShareNoCCSH2Prod = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.5)
    m.V05AcceptCCSH2Tech = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=2.0)
    m.V05CostProdCCSNoCCSH2Prod = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(1e-6, None), initialize=2.0)
    m.V05CaptRateH2 = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, 1), initialize=0.0)

    # Interdependent: VmProdH2, VmCostAvgProdH2, VmConsFuelTechH2Prod (03 has VmDemTotH2, VmDemSecH2, VmConsFuelH2Prod)
    m.VmProdH2 = Var(run_cy, h2tech, ytime, domain=Reals, bounds=(0, None), initialize=0.5)
    m.VmCostAvgProdH2 = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.VmConsFuelTechH2Prod = Var(run_cy, h2tech, ef, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
