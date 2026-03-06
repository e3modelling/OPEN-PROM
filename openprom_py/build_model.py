"""
Build the OPEN-PROM Pyomo model: core + price stub + 01_Transport (simple).

Assembly order mirrors main.gms:
  1. Sets (via CoreSets.from_config)
  2. Declarations: core params/vars, price stub params, transport params/vars
  3. Equations: core objective and qDummyObj, transport constraints
  4. Preloop: core (PDL, fixes), transport (historical fixes, bounds)
  5. Optional: load CSV data into mutable Params

The resulting ConcreteModel has all components needed to solve one or more
(time step, country) subproblems with an NLP solver (e.g. Ipopt).
"""
from pyomo.core import ConcreteModel

from config.poc_config import PoCConfig
from core.sets import CoreSets
from core.declarations import add_core_parameters, add_core_variables
from core.equations import add_core_objective, add_q_dummy_obj_constraint
from core.preloop import apply_core_preloop
from core.input_loader import load_core_data, load_core_data_into_model
from prices_stub import add_price_stub_parameters
from modules.transport_simple.declarations import add_transport_parameters, add_transport_variables
from modules.transport_simple.equations import add_transport_equations
from modules.transport_simple.preloop import apply_transport_preloop


def _log(msg: str) -> None:
    """Log to run report if active."""
    try:
        from run_report import get_report_logger
        log = get_report_logger()
        if log:
            log.info(msg)
    except Exception:
        pass


def build_openprom_model(config: PoCConfig, load_data: bool = True) -> ConcreteModel:
    """
    Build the Pyomo model with core + price stub + 01_Transport (simple).

    If load_data is True, load CSVs from config.data_dir and fill mutable Params
    (requires data files in openprom_py/data/). If load_data is False, only
    the structure is built; defaults are used for Params (e.g. imElastA=0.5).
    """
    m = ConcreteModel(name="openprom")
    _log("Core sets from config.")
    core_sets_obj = CoreSets.from_config(config)

    # 1) Declarations: core params/vars, price stub, transport params/vars
    _log("Adding core parameters and variables.")
    add_core_parameters(m, core_sets_obj)
    add_core_variables(m, core_sets_obj)
    _log("Adding price stub parameters.")
    add_price_stub_parameters(m, core_sets_obj)
    _log("Adding transport parameters and variables.")
    add_transport_parameters(m, core_sets_obj)
    add_transport_variables(m, core_sets_obj)

    # 2) Equations: objective (min vDummyObj), qDummyObj, and all Q01* transport constraints
    _log("Adding core objective and qDummyObj constraint.")
    add_core_objective(m, calibration=config.calibration)
    add_q_dummy_obj_constraint(m, core_sets_obj)
    _log("Adding transport equations.")
    add_transport_equations(m, core_sets_obj)

    # 3) Preloop: PDL, core var fixes, transport historical fixes and bounds
    _log("Applying core preloop.")
    apply_core_preloop(m, core_sets_obj)
    _log("Applying transport preloop.")
    apply_transport_preloop(m, core_sets_obj)

    # 4) Optional: load CSV data into mutable Params (imElastA, imActv, imTransChar, etc.)
    if load_data:
        try:
            _log("Loading data from CSV files.")
            data = load_core_data(config)
            _log("Loading data into model.")
            load_core_data_into_model(m, data, core_sets_obj)
        except Exception as e:
            _log("Data load failed: {}".format(e))
            raise

    # Attach for run_poc / postsolve
    m._core_sets = core_sets_obj
    m._config = config
    return m


if __name__ == "__main__":
    config = PoCConfig.default_poc()
    m = build_openprom_model(config, load_data=False)
    print("Model built. Components:", [c.getname() for c in m.component_objects()])
    print("runCy:", m._core_sets.runCy)
    print("an:", m._core_sets.an[:5], "...")
