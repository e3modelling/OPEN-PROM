"""
Module 07_Emissions (legacy): declarations (parameters and variables).

Mirrors modules/07_Emissions/legacy/declarations.gms. Gross CO2 emissions by supply/demand sector,
non-CO2 (CH4, N2O, F-gas) marginal abatement cost curves, reduction fraction, actual emissions,
and abatement cost. Core provides imCo2EmiFac, smCtoCO2, smDefl_15_to_10, smDefl_15_to_05, iCarbValYrExog.
03 provides V03InpTotTransf, VmConsFuel; VmConsFuelCDRProd from 06.

--- GAMS declarations.gms commented-out (transferred as comments) ---
*' *** Emissions Constraints Variables
* V07GrnnHsEmisCO2Equiv(NAP,YTIME)   "Total CO2eq GHG emissions in all countries per NAP sector (1)"
* v07GrnnHsEmisCO2EquivAllCntr(YTIME) "Total CO2eq GHG emissions in all countries (1)"
* v07ExpendHouseEne(allCy,YTIME)      "Households expenditures on energy (billions)"
*;
"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets


def add_emissions_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 07_Emissions (legacy) parameters.
    All are mutable; filled from input_loader (CSV + derived logic) or left at default.
    GAMS: p07MarginalRed, p07MacCost, p07UnitConvFactor, p07GWP, p07CostCorrection.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    e07mac = list(core_sets.E07MAC)
    e07src = list(core_sets.E07SrcMacAbate)

    # Marginal abatement cost curve (MACC) data: cumulative reduction at each cost step (allCy, source, E07MAC step, year)
    m.i07DataCh4N2OFMAC = Param(run_cy, e07src, e07mac, ytime, mutable=True, default=0.0, initialize={})
    # Baseline non-CO2 emissions by source (Mt CO2e CH4/N2O, kt F-gases); used in Q07EmiActBySrcRegTim
    m.i07DataCh4N2OFEmis = Param(run_cy, e07src, ytime, mutable=True, default=0.0, initialize={})
    # Incremental reduction at each MAC step (filled in input_loader: difference from previous step; first step = total)
    m.p07MarginalRed = Param(run_cy, e07src, e07mac, ytime, mutable=True, default=0.0, initialize={})
    # Numeric value of each MAC cost step (0, 20, 40, ... 4000) for comparison with carbon price
    m.p07MacCost = Param(e07mac, mutable=True, default=0.0, initialize={})
    # Converts carbon price to same units as MAC (CH4/N2O: 2010$/tC; F-gases: 2005$/tC)
    m.p07UnitConvFactor = Param(e07src, mutable=True, default=3.66, initialize={})
    # Global warming potential (AR4 100yr); used in cost correction for F-gases
    m.p07GWP = Param(e07src, mutable=True, default=1.0, initialize={})
    # Converts (qty * cost) to Million 2015$; differs for CH4/N2O vs F-gases
    m.p07CostCorrection = Param(e07src, mutable=True, default=1.0, initialize={})


def add_emissions_variables(m: ConcreteModel, core_sets_obj) -> None:
    """
    Add 07_Emissions (legacy) variables.
    All are free (or lower-bounded at 0) and initialized to 0; preloop fixes historical (datay) values.
    """
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    ssbs = list(core_sets.SSBS)
    dsbs = list(core_sets.DSBS)
    e07src = list(core_sets.E07SrcMacAbate)

    # Total CO2eq GHG emissions per supply sector (Mt CO2/yr); defined by Q07GrossEmissCO2Supply
    m.V07GrossEmissCO2Supply = Var(run_cy, ssbs, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Selected cumulative abatement fraction from MAC curve (Q07RedAbsBySrcRegTim)
    m.V07RedAbsBySrcRegTim = Var(run_cy, e07src, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Actual remaining emissions after abatement (Q07EmiActBySrcRegTim)
    m.V07EmiActBySrcRegTim = Var(run_cy, e07src, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Total abatement cost (Mil $2015) from MAC curve (Q07CostAbateBySrcRegTim)
    m.V07CostAbateBySrcRegTim = Var(run_cy, e07src, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    # Gross emissions of demand subsectors (Q07GrossEmissCO2Demand)
    m.V07GrossEmissCO2Demand = Var(run_cy, dsbs, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
