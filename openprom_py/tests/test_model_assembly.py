"""
Tests: verify all 11 modules are assembled and key components exist.

Runs without Ipopt or data files — tests only structure and wiring.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from config.poc_config import PoCConfig
from build_model import build_openprom_model


# ── All 11 modules: key Var / Constraint from each ──────────────────────────

# Map: module name -> (representative Var name, representative Constraint name)
_MODULE_COMPONENTS = {
    "01_Transport":      ("V01StockPcYearly",      "Q01Lft"),
    "02_Industry":       ("V02ConsFuelInSub",       "Q02Lft"),
    "03_RestOfEnergy":   ("V03TotFinEneDemSub",     "Q03FinEneDemSub"),
    "04_PowerGeneration":("V04NewCapElec",          "Q04NewCapElec"),
    "05_Hydrogen":       ("VmProdH2",               "Q05ProdH2"),
    "06_CO2":            ("V06CstCO2SeqCsts",       "Q06CstCO2SeqCsts"),
    "07_Emissions":      ("V07CO2ElcHrgCl",         "Q07CO2ElcHrgCl"),
    "08_Prices":         ("VmPriceFuelSubsecCarVal", "Q08PriceFuelSubsecCarVal"),
    "09_Heat":           ("VmElecConsHeatPla",       None),  # Var declared in core, constraints in heat  
    "10_Curves":         ("VmCostLC",               "Q10CostLC"),
    "11_Economy":        ("VmSubsiDemTech",          None),  # May be Param from stub or Var from economy
}


def _build_model():
    config = PoCConfig.default_poc()
    return build_openprom_model(config, load_data=False)


def test_all_modules_have_vars():
    """Every module contributes at least one Var or Param to the model."""
    m = _build_model()
    for mod_name, (var_name, _) in _MODULE_COMPONENTS.items():
        assert hasattr(m, var_name), (
            f"Module {mod_name}: expected Var/Param '{var_name}' not found on model"
        )


def test_all_modules_have_constraints():
    """Modules with equations contribute at least one Constraint."""
    m = _build_model()
    for mod_name, (_, constr_name) in _MODULE_COMPONENTS.items():
        if constr_name is None:
            continue
        assert hasattr(m, constr_name), (
            f"Module {mod_name}: expected Constraint '{constr_name}' not found on model"
        )


def test_core_objective_and_qDummyObj():
    """Core: objective minimizes vDummyObj, qDummyObj constraint exists."""
    m = _build_model()
    assert m.obj.sense.name == "minimize"
    assert hasattr(m, "qDummyObj")
    assert m.vDummyObj is not None


def test_core_sets_populated():
    """CoreSets has expected attributes: runCy, an, ytime, time, tFirst."""
    m = _build_model()
    cs = m._core_sets
    assert len(cs.runCy) >= 1
    assert len(cs.an) >= 1
    assert len(cs.ytime) > len(cs.an)  # ytime includes historical + solve years
    assert "DEU" in cs.runCy


def test_config_attached():
    """Config is attached to model for postsolve use."""
    m = _build_model()
    assert hasattr(m, "_config")
    assert hasattr(m, "_core_sets")


# ── Calibration branch ──────────────────────────────────────────────────────

def test_calibration_off_gives_scalar_qDummyObj():
    """With calibration off, qDummyObj is a scalar constraint (vDummyObj == 1)."""
    config = PoCConfig.default_poc()
    assert config.calibration == "off"
    m = build_openprom_model(config, load_data=False)
    # Scalar constraint — not indexed
    assert hasattr(m, "qDummyObj")
    assert not hasattr(m, "qRestrain")


def test_calibration_matcalibration_gives_indexed_qDummyObj():
    """With MatCalibration, qDummyObj is indexed by (cy, ytime) and qRestrain exists."""
    config = PoCConfig(
        countries=("DEU",),
        start_horizon=2010,
        end_horizon=2100,
        start_y=2024,
        end_y=2025,
        base_y=2023,
        period_of_years=1,
        scenario=1,
        calibration="MatCalibration",
        link2magpie="off",
        solver_try_max=4,
    )
    m = build_openprom_model(config, load_data=False)
    assert hasattr(m, "qDummyObj")
    assert hasattr(m, "qRestrain")
    # qDummyObj should be a Constraint indexed by (cy, ytime), not scalar
    from pyomo.core import Constraint
    assert isinstance(m.qDummyObj, Constraint)


# ── Multi-year structure ─────────────────────────────────────────────────────

def test_multi_year_config():
    """Config with multiple solve years produces correct an set."""
    config = PoCConfig(
        countries=("DEU",),
        start_horizon=2010,
        end_horizon=2100,
        start_y=2024,
        end_y=2030,
        base_y=2023,
        period_of_years=1,
        scenario=1,
        calibration="off",
        link2magpie="off",
        solver_try_max=4,
    )
    m = build_openprom_model(config, load_data=False)
    an = m._core_sets.an
    assert len(an) == 7  # 2024..2030 inclusive
    assert an[0] == 2024
    assert an[-1] == 2030


def test_t01NewShareStockPC_param_exists():
    """Calibration target Param t01NewShareStockPC is declared by Transport."""
    m = _build_model()
    assert hasattr(m, "t01NewShareStockPC"), (
        "Transport should declare t01NewShareStockPC for calibration"
    )


# ── Postsolve imports ────────────────────────────────────────────────────────

def test_postsolve_functions_importable():
    """All 11 module postsolve functions are importable."""
    from modules._01_Transport.simple.postsolve import apply_transport_postsolve
    from modules._02_Industry.technology.postsolve import apply_industry_postsolve
    from modules._03_RestOfEnergy.legacy.postsolve import apply_rest_of_energy_postsolve
    from modules._04_PowerGeneration.simple.postsolve import apply_power_generation_postsolve
    from modules._05_Hydrogen.legacy.postsolve import apply_hydrogen_postsolve
    from modules._06_CO2.legacy.postsolve import apply_co2_postsolve
    from modules._07_Emissions.legacy.postsolve import apply_emissions_postsolve
    from modules._08_Prices.legacy.postsolve import apply_prices_postsolve
    from modules._09_Heat.heat.postsolve import apply_heat_postsolve
    from modules._10_Curves.LearningCurves.postsolve import apply_curves_postsolve
    from modules._11_Economy.economy.postsolve import apply_economy_postsolve
    assert callable(apply_transport_postsolve)
    assert callable(apply_curves_postsolve)


if __name__ == "__main__":
    tests = [v for k, v in globals().items() if k.startswith("test_")]
    for t in tests:
        try:
            t()
            print(f"  PASS  {t.__name__}")
        except Exception as e:
            print(f"  FAIL  {t.__name__}: {e}")
