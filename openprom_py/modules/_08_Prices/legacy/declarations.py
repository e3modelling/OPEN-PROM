"""
Module 08_Prices (legacy): declarations (parameters and variables).

Mirrors modules/08_Prices/legacy/declarations.gms. Fuel prices per subsector and fuel (with carbon value),
weighted price quantity V08PriceFuelSepCarbonWght, average fuel price per subsector, electricity prices
for industry/residential/transport/services (VmPriceElecIndResConsu), electricity index (VmPriceElecInd in core),
and fuel price without carbon (V08FuelPriSubNoCarb). Core provides VmPriceElecInd, imCo2EmiFac, imEffValueInDollars,
smTWhToMtoe, smElecToSteRatioChp; 02 provides V02IndxElecIndPrices; 04 provides VmCostPowGenAvgLng; 05 provides VmCostAvgProdH2;
09 provides VmCostAvgProdSte.

--- GAMS declarations.gms (transferred as comments) ---
Equations
*' *** Prices
Q08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME) "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
*'                **Interdependent Equations**
Q08PriceElecIndResConsu(allCy,ESET,YTIME)     "Compute electricity price in Industrial and Residential Consumers"
Q08PriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)  "Compute fuel prices per subsector and fuel, separate carbon value in each sector"
Q08PriceFuelAvgSub(allCy,DSBS,YTIME)          "Compute average fuel price per subsector"
* Q08PriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)   "Compute fuel prices per subsector and fuel especially for chp plants"  [commented in GAMS]
Q08PriceElecInd(allCy,YTIME)                  "Compute electricity industry prices"
Variables
*' *** Prices Variables
V08PriceFuelSepCarbonWght(allCy,SBS,EF,YTIME) "Fuel prices per subsector and fuel multiplied by weights (kUS$2015/toe)"
VmPriceFuelSubsecCarVal(allCy,SBS,EF,YTIME)   "Fuel prices per subsector and fuel (k$2015/toe)"
VmPriceFuelAvgSub(allCy,DSBS,YTIME)           "Average fuel prices per subsector (k$2015/toe)"
* VmPriceFuelSubsecCHP(allCy,DSBS,EF,YTIME)    "Fuel prices per subsector and fuel for CHP plants (kUS$2015/toe)" [commented in GAMS]
VmPriceElecInd(allCy,YTIME)                   "Electricity index - a function of industry price (1)" [in core]
*' *** Miscellaneous
V08FuelPriSubNoCarb(allCy,SBS,EF,YTIME)       "Fuel prices per subsector and fuel without carbon value (kUS$2015/toe)"
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_prices_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 08_Prices (legacy) parameters.
    i08DiffFuelsInSec(SBS), i08WgtSecAvgPriFueCons(allCy,SBS,EF), i08VAT(allCy,YTIME).
    Filled from input_loader or derived in input_loader.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    dsbs = list(core_sets.DSBS)
    ef = list(core_sets.EF)
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]

    # Number of different fuels in each sector (used for weight fallback)
    m.i08DiffFuelsInSec = Param(
        sbs_and_supply,
        mutable=True,
        default=1,
        initialize={},
    )
    # Weights for sector average price based on fuel consumption (1)
    m.i08WgtSecAvgPriFueCons = Param(
        run_cy, sbs_and_supply, ef,
        mutable=True,
        default=0.0,
        initialize={},
    )
    # VAT (value added tax) rates (1); GAMS sets to 0
    m.i08VAT = Param(
        run_cy, ytime,
        mutable=True,
        default=0.0,
        initialize={},
    )


def add_prices_variables(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 08_Prices (legacy) variables.
    VmPriceFuelSubsecCarVal, VmPriceFuelAvgSub (elsewhere provided as stub Params when 08 not loaded),
    V08PriceFuelSepCarbonWght, VmPriceElecIndResConsu, V08FuelPriSubNoCarb. VmPriceElecInd is in core.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    dsbs = list(core_sets.DSBS)
    ef = list(core_sets.EF)
    eset = list(getattr(core_sets, "ESET", ("i", "r", "t", "c")))
    ssbs = list(getattr(core_sets, "SSBS", ()))
    sbs_and_supply = list(sbs) + [x for x in ssbs if x not in sbs]

    # Fuel price per subsector and fuel including carbon value (k$2015/toe); defined by Q08PriceFuelSubsecCarVal
    m.VmPriceFuelSubsecCarVal = Var(
        run_cy, sbs_and_supply, ef, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1.5,
    )
    # Average fuel price per subsector (k$2015/toe); defined by Q08PriceFuelAvgSub
    m.VmPriceFuelAvgSub = Var(
        run_cy, dsbs, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.001,
    )
    # Weighted fuel price (consumption share * price); defined by Q08PriceFuelSepCarbonWght
    m.V08PriceFuelSepCarbonWght = Var(
        run_cy, sbs_and_supply, ef, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=1e-6,
    )
    # Electricity price to industrial/residential/transport/services (US$2015/KWh); defined by Q08PriceElecIndResConsu
    m.VmPriceElecIndResConsu = Var(
        run_cy, eset, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.1,
    )
    # Fuel price without carbon (kUS$2015/toe); preloop fixes from imFuelPrice
    m.V08FuelPriSubNoCarb = Var(
        run_cy, sbs_and_supply, ef, ytime,
        domain=Reals,
        bounds=(0, None),
        initialize=0.0,
    )
