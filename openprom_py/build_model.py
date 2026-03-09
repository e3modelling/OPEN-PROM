"""
Build the OPEN-PROM Pyomo model: core + all 11 modules.

Assembly order mirrors main.gms:
  1. Sets (via CoreSets.from_config)
  2. Declarations: core params/vars, price stub fallback, 01-11 module params/vars
  3. Equations: core objective and qDummyObj (or MatCalibration), module constraints
  4. Preloop: core (PDL, fixes), module-specific historical fixes and stubs
  5. Optional: load CSV data into mutable Params (core + all modules)

The resulting ConcreteModel has all components needed to solve one or more
(time step, country) subproblems with an NLP solver (e.g. Ipopt).
"""
from pyomo.core import ConcreteModel

from config.poc_config import PoCConfig
from core.sets import CoreSets
from core.declarations import add_core_parameters, add_core_variables
from core.equations import (
    add_core_objective,
    add_q_dummy_obj_constraint,
    add_q_dummy_obj_calibration,
    fix_imMatrFactor_for_mode,
)
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
from modules._06_CO2.legacy.declarations import add_co2_parameters, add_co2_variables
from modules._06_CO2.legacy.equations import add_co2_equations
from modules._06_CO2.legacy.input_loader import load_co2_data, load_co2_data_into_model
from modules._06_CO2.legacy.preloop import apply_co2_preloop
from modules._07_Emissions.legacy.declarations import add_emissions_parameters, add_emissions_variables
from modules._07_Emissions.legacy.equations import add_emissions_equations
from modules._07_Emissions.legacy.input_loader import load_emissions_data, load_emissions_data_into_model
from modules._07_Emissions.legacy.preloop import apply_emissions_preloop
from modules._08_Prices.legacy.declarations import add_prices_parameters, add_prices_variables
from modules._08_Prices.legacy.equations import add_prices_equations
from modules._08_Prices.legacy.input_loader import load_prices_data, load_prices_data_into_model
from modules._08_Prices.legacy.preloop import apply_prices_preloop
from modules._08_Prices.legacy.postsolve import apply_prices_postsolve
from modules._09_Heat.heat.declarations import add_heat_parameters, add_heat_variables
from modules._09_Heat.heat.equations import add_heat_equations
from modules._09_Heat.heat.input_loader import load_heat_data, load_heat_data_into_model
from modules._09_Heat.heat.preloop import apply_heat_preloop
from modules._09_Heat.heat.postsolve import apply_heat_postsolve
from modules._10_Curves.LearningCurves.declarations import add_curves_parameters, add_curves_variables
from modules._10_Curves.LearningCurves.equations import add_curves_equations
from modules._10_Curves.LearningCurves.input_loader import load_curves_data, load_curves_data_into_model
from modules._10_Curves.LearningCurves.preloop import apply_curves_preloop
from modules._10_Curves.LearningCurves.postsolve import apply_curves_postsolve
from modules._11_Economy.economy.declarations import add_economy_parameters, add_economy_variables
from modules._11_Economy.economy.equations import add_economy_equations
from modules._11_Economy.economy.input_loader import load_economy_data, load_economy_data_into_model
from modules._11_Economy.economy.preloop import apply_economy_preloop
from modules._11_Economy.economy.postsolve import apply_economy_postsolve
import logging

logger = logging.getLogger(__name__)


def _log(msg: str) -> None:
    """Log to run report if active."""
    try:
        from run_report import get_report_logger
        log = get_report_logger()
        if log:
            log.info(msg)
    except Exception as _exc:
        logger.debug("Skipped: %s", _exc)


def build_openprom_model(config: PoCConfig, load_data: bool = True) -> ConcreteModel:
    """
    Build the Pyomo model with core + all 11 modules.

    Modules: 01_Transport (simple), 02_Industry (technology),
    03_RestOfEnergy (legacy), 04_PowerGeneration (simple),
    05_Hydrogen (legacy), 06_CO2 (legacy), 07_Emissions (legacy),
    08_Prices (legacy), 09_Heat (heat), 10_Curves (LearningCurves),
    11_Economy (economy).  A price stub provides fallback Params when
    08_Prices/11_Economy Vars are not declared.

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
    _log("Adding 08_Prices (legacy) parameters and variables.")
    add_prices_parameters(m, core_sets_obj)
    add_prices_variables(m, core_sets_obj)
    _log("Adding 11_Economy (economy) parameters and variables.")
    add_economy_parameters(m, core_sets_obj)
    add_economy_variables(m, core_sets_obj)
    _log("Adding price stub parameters (VmSubsiDemTech only when 11_Economy not loaded).")
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
    _log("Adding CO2 (legacy) parameters and variables.")
    add_co2_parameters(m, core_sets_obj)
    add_co2_variables(m, core_sets_obj)
    _log("Adding Emissions (legacy) parameters and variables.")
    add_emissions_parameters(m, core_sets_obj)
    add_emissions_variables(m, core_sets_obj)
    _log("Adding 09_Heat (heat) parameters and variables.")
    add_heat_parameters(m, core_sets_obj)
    add_heat_variables(m, core_sets_obj)
    _log("Adding 10_Curves (LearningCurves) parameters and variables.")
    add_curves_parameters(m, core_sets_obj)
    add_curves_variables(m, core_sets_obj)

    # 2) Equations: objective, qDummyObj, transport, industry, rest-of-energy, power-gen constraints
    _log("Adding core objective and qDummyObj constraint.")
    add_core_objective(m, calibration=config.calibration)
    if config.calibration == "MatCalibration":
        _log("Using MatCalibration: sum-of-squares qDummyObj + qRestrain.")
        add_q_dummy_obj_calibration(m, core_sets_obj)
    else:
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
    _log("Adding CO2 equations.")
    add_co2_equations(m, core_sets_obj)
    _log("Adding Emissions equations.")
    add_emissions_equations(m, core_sets_obj)
    _log("Adding 09_Heat equations.")
    add_heat_equations(m, core_sets_obj)
    _log("Adding 08_Prices equations.")
    add_prices_equations(m, core_sets_obj)
    _log("Adding 10_Curves equations.")
    add_curves_equations(m, core_sets_obj)
    _log("Adding 11_Economy equations.")
    add_economy_equations(m, core_sets_obj)

    # 3) Load CSV data *before* preloop so historical fixes use loaded params (e.g. imFuelConsPerFueSub)
    if load_data:
        try:
            _log("Loading data from CSV files.")
            data = load_core_data(config)
            data_transport = load_transport_data(config)
            data_rest_energy = load_rest_of_energy_data(config)
            data_power_gen = load_power_generation_data(config)
            data_hydrogen = load_hydrogen_data(config)
            data_co2 = load_co2_data(config)
            data_emissions = load_emissions_data(config)
            data_prices = load_prices_data(config)
            data_heat = load_heat_data(config)
            data_curves = load_curves_data(config)
            data_economy = load_economy_data(config)
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
            _log("Loading CO2 data into model.")
            load_co2_data_into_model(m, data_co2, core_sets_obj)
            _log("Loading Emissions data into model.")
            load_emissions_data_into_model(m, data_emissions, core_sets_obj)
            _log("Loading 08_Prices data into model.")
            load_prices_data_into_model(m, data_prices, core_sets_obj)
            _log("Loading 09_Heat data into model.")
            load_heat_data_into_model(m, data_heat, core_sets_obj)
            _log("Loading 10_Curves data into model.")
            load_curves_data_into_model(m, data_curves, core_sets_obj)
            _log("Loading 11_Economy data into model.")
            load_economy_data_into_model(m, data_economy, core_sets_obj)
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
    _log("Applying CO2 preloop.")
    apply_co2_preloop(m, core_sets_obj)
    _log("Applying Emissions preloop.")
    apply_emissions_preloop(m, core_sets_obj)
    _log("Applying 09_Heat preloop.")
    apply_heat_preloop(m, core_sets_obj)
    _log("Applying 08_Prices preloop.")
    apply_prices_preloop(m, core_sets_obj)
    _log("Applying 10_Curves preloop.")
    apply_curves_preloop(m, core_sets_obj)
    _log("Applying 11_Economy preloop.")
    apply_economy_preloop(m, core_sets_obj)

    # 5) Fix/unfix imMatrFactor based on calibration mode (after data loading + preloops)
    _log("Fixing imMatrFactor for calibration mode: {}".format(config.calibration))
    fix_imMatrFactor_for_mode(m, core_sets_obj, calibration=config.calibration)

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
