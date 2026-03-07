"""
Module 06_CO2 (legacy): declarations (parameters and variables).

Mirrors modules/06_CO2/legacy/declarations.gms. CO2 capture by sector, cumulative capture,
sequestration cost curve (VmCstCO2SeqCsts in core), DAC learning-curve costs and capacity,
and CDR fuel consumption. Core has VmCstCO2SeqCsts; 03 has VmConsFuelCDRProd. This module
declares V06* and VmConsFuelTechCDRProd, V06CapCDR.

"""
from pyomo.core import ConcreteModel, Param, Var
from pyomo.environ import Reals

from core import sets as core_sets

# --- GAMS sets.gms $ontext ... $offtext (commented out in GAMS), transferred as comments ---
# $ontext
# DACTECHEF(EF)               "Fuels used in DAC technologies"
# / ngs, elc /
# DACTECHEFtoEF(DACTECH,EF)   "Mapping between DAC technologies and fuels"
# / (HTDAC).ngs, (HTDAC,LTDAC,EWDAC).elc /
# $offtext
# We use CO2CAPTECH, CDR(DSBS), CDRTECH, DACTECH, CO2SEQELAST, CDRTECHtoEF in core.


def add_co2_parameters(m: ConcreteModel, core_sets_obj) -> None:
    """Add 06_CO2 (legacy) parameters. Filled from input_loader."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    cdrtech = list(core_sets.CDRTECH)
    co2seqelast = list(core_sets.CO2SEQELAST)

    # Scalars (GAMS: S06ProfRateMaxDAC, S06CapFacMaxNewDAC, S06CapFacMinNewDAC)
    m.S06ProfRateMaxDAC = Param(within=Reals, default=7.5, mutable=False)
    m.S06CapFacMaxNewDAC = Param(within=Reals, default=0.115, mutable=False)
    m.S06CapFacMinNewDAC = Param(within=Reals, default=0.055, mutable=False)

    # Parameters (from input or derived)
    m.i06ElastCO2Seq = Param(run_cy, co2seqelast, mutable=True, default=0.0, initialize={})
    m.i06GrossCapDAC = Param(cdrtech, mutable=True, default=500.0, initialize={})
    m.i06GrossCapDACMin = Param(cdrtech, mutable=True, default=68.0, initialize={})
    m.i06FixOandMDAC = Param(cdrtech, mutable=True, default=100.0, initialize={})
    m.i06FixOandMDACMin = Param(cdrtech, mutable=True, default=30.0, initialize={})
    m.i06VarCostDAC = Param(cdrtech, mutable=True, default=150.0, initialize={})
    m.i06VarCostDACMin = Param(cdrtech, mutable=True, default=94.0, initialize={})
    m.i06LftDAC = Param(run_cy, cdrtech, ytime, mutable=True, default=25.0, initialize={})
    m.i06SubsiFacDAC = Param(cdrtech, mutable=True, default=1.0, initialize={})
    m.i06SpecElecDAC = Param(run_cy, cdrtech, ytime, mutable=True, default=0.1, initialize={})
    m.i06SpecHeatDAC = Param(run_cy, cdrtech, ytime, mutable=True, default=0.5, initialize={})
    m.i06MatFacDAC = Param(cdrtech, mutable=True, default=0.3, initialize={})
    m.i06SchedNewCapDAC = Param(run_cy, cdrtech, ytime, mutable=True, default=0.0, initialize={})


def add_co2_variables(m: ConcreteModel, core_sets_obj) -> None:
    """Add 06_CO2 (legacy) variables. VmCstCO2SeqCsts in core; VmConsFuelCDRProd in 03."""
    run_cy = core_sets_obj.runCy
    ytime = core_sets_obj.ytime
    sbs = list(core_sets.SBS)
    cdrtech = list(core_sets.CDRTECH)
    ef_list = list(core_sets.EF)

    m.V06CapCO2ElecHydr = Var(run_cy, sbs, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
    m.V06CaptCummCO2 = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.V06GrossCapDAC = Var(cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=300.0)
    m.V06FixOandMDAC = Var(cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=80.0)
    m.V06VarCostDAC = Var(cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=100.0)
    m.V06LvlCostDAC = Var(run_cy, cdrtech, ytime, domain=Reals, bounds=(1e-6, None), initialize=100.0)
    m.V06ProfRateDAC = Var(run_cy, cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.V06CapFacNewDAC = Var(run_cy, cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=0.055)
    m.V06CapCDR = Var(run_cy, cdrtech, ytime, domain=Reals, bounds=(0, None), initialize=1.0)
    m.VmConsFuelTechCDRProd = Var(run_cy, cdrtech, ef_list, ytime, domain=Reals, bounds=(0, None), initialize=0.0)
