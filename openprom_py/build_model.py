"""
Build the OPEN-PROM Pyomo model: core + price stub + 01_Transport + 02_Industry + 04_PowerGeneration + 03_RestOfEnergy.

Assembly order mirrors main.gms:
  1. Sets (via CoreSets.from_config)
  2. Declarations: core params/vars, price stub, transport, industry, 04 power-gen, rest-of-energy params/vars
  3. Equations: core objective and qDummyObj, transport, industry, rest-of-energy, power-gen constraints
  4. Preloop: core (PDL, fixes), transport, industry, rest-of-energy, power-gen (historical fixes, stubs)
  5. Optional: load CSV data into mutable Params (core, transport, rest-of-energy, power-gen)

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
from modules._01_Transport.simple.input_loader import load_transport_data, load_transport_data_into_model
from modules._01_Transport.simple.declarations import add_transport_parameters, add_transport_variables
from modules._01_Transport.simple.equations import add_transport_equations
from modules._01_Transport.simple.preloop import apply_transport_preloop
from modules._02_Industry.technology.declarations import add_industry_parameters, add_industry_variables
from modules._02_Industry.technology.equations import add_industry_equations
from modules._02_Industry.technology.preloop import apply_industry_preloop
from modules._04_PowerGeneration.simple.declarations import add_power_generation_parameters, add_power_generation_variables
from modules._04_PowerGeneration.simple.equations import add_power_generation_equations
from modules._04_PowerGeneration.simple.input_loader import load_power_generation_data, load_power_generation_data_into_model
from modules._04_PowerGeneration.simple.preloop import apply_power_generation_preloop
from modules._03_RestOfEnergy.legacy.declarations import add_rest_of_energy_parameters, add_rest_of_energy_variables
from modules._03_RestOfEnergy.legacy.equations import add_rest_of_energy_equations
from modules._03_RestOfEnergy.legacy.preloop import apply_rest_of_energy_preloop
from modules._03_RestOfEnergy.legacy.input_loader import load_rest_of_energy_data, load_rest_of_energy_data_into_model
from modules._05_Hydrogen.legacy.declarations import add_hydrogen_parameters, add_hydrogen_variables
from modules._05_Hydrogen.legacy.equations import add_hydrogen_equations
from modules._05_Hydrogen.legacy.input_loader import load_hydrogen_data, load_hydrogen_data_into_model
from modules._05_Hydrogen.legacy.preloop import apply_hydrogen_preloop


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
    Build the Pyomo model with core + price stub + 01_Transport + 02_Industry (technology).

    If load_data is True, load CSVs from config.data_dir and fill mutable Params
    (requires data files in openprom_py/data/). If load_data is False, only
    the structure is built; defaults are used for Params (e.g. imElastA=0.5).
    """
    m = ConcreteModel(name="openprom")
    _log("Core sets from config.")
    core_sets_obj = CoreSets.from_config(config)

    # 1) Declarations: core params/vars, price stub, transport, industry params/vars
    _log("Adding core parameters and variables.")
    add_core_parameters(m, core_sets_obj)
    add_core_variables(m, core_sets_obj)
    _log("Adding price stub parameters.")
    add_price_stub_parameters(m, core_sets_obj)
    _log("Adding transport parameters and variables.")
    add_transport_parameters(m, core_sets_obj)
    add_transport_variables(m, core_sets_obj)
    _log("Adding industry (technology) parameters and variables.")
    add_industry_parameters(m, core_sets_obj)
    add_industry_variables(m, core_sets_obj)
    _log("Adding PowerGeneration (simple) parameters and variables.")
    add_power_generation_parameters(m, core_sets_obj, config)
    add_power_generation_variables(m, core_sets_obj)
    _log("Adding RestOfEnergy (legacy) parameters and variables.")
    add_rest_of_energy_parameters(m, core_sets_obj)
    add_rest_of_energy_variables(m, core_sets_obj)
    _log("Adding Hydrogen (legacy) parameters and variables.")
    add_hydrogen_parameters(m, core_sets_obj)
    add_hydrogen_variables(m, core_sets_obj)

    # 2) Equations: objective, qDummyObj, transport, industry, rest-of-energy, power-gen constraints
    _log("Adding core objective and qDummyObj constraint.")
    add_core_objective(m, calibration=config.calibration)
    add_q_dummy_obj_constraint(m, core_sets_obj)
    _log("Adding transport equations.")
    add_transport_equations(m, core_sets_obj)
    _log("Adding industry equations.")
    add_industry_equations(m, core_sets_obj)
    _log("Adding RestOfEnergy equations.")
    add_rest_of_energy_equations(m, core_sets_obj)
    _log("Adding PowerGeneration equations.")
    add_power_generation_equations(m, core_sets_obj, config)
    _log("Adding Hydrogen equations.")
    add_hydrogen_equations(m, core_sets_obj)

    # 3) Load CSV data *before* preloop so historical fixes use loaded params (e.g. imFuelConsPerFueSub)
    if load_data:
        try:
            _log("Loading data from CSV files.")
            data = load_core_data(config)
            data_transport = load_transport_data(config)
            data_rest_energy = load_rest_of_energy_data(config)
            data_power_gen = load_power_generation_data(config)
            data_hydrogen = load_hydrogen_data(config)
            _log("Loading core data into model.")
            load_core_data_into_model(m, data, core_sets_obj)
            _log("Loading transport data into model.")
            load_transport_data_into_model(m, data_transport, core_sets_obj, data_core=data)
            _log("Loading RestOfEnergy data into model.")
            load_rest_of_energy_data_into_model(m, data_rest_energy, core_sets_obj)
            _log("Loading PowerGeneration data into model.")
            load_power_generation_data_into_model(m, data_power_gen, core_sets_obj, config)
            _log("Loading Hydrogen data into model.")
            load_hydrogen_data_into_model(m, data_hydrogen, core_sets_obj)
        except Exception as e:
            _log("Data load failed: {}".format(e))
            raise

    # 4) Preloop: PDL, core var fixes, transport, industry, rest-of-energy, power-gen historical fixes and stubs
    _log("Applying core preloop.")
    apply_core_preloop(m, core_sets_obj)
    _log("Applying transport preloop.")
    apply_transport_preloop(m, core_sets_obj)
    _log("Applying industry preloop.")
    apply_industry_preloop(m, core_sets_obj)
    _log("Applying RestOfEnergy preloop.")
    apply_rest_of_energy_preloop(m, core_sets_obj)
    _log("Applying PowerGeneration preloop.")
    apply_power_generation_preloop(m, core_sets_obj, config)
    _log("Applying Hydrogen preloop.")
    apply_hydrogen_preloop(m, core_sets_obj)

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
