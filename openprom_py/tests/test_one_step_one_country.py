"""
Minimal test: build model for one country and one time step, check components exist.
Compare with GAMS by running GAMS for the same config and comparing vDummyObj and key vars.
"""
import sys
from pathlib import Path

# Ensure package root on path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from config.poc_config import PoCConfig
from build_model import build_openprom_model


def test_build_one_country_one_period():
    config = PoCConfig.default_poc()
    assert len(config.countries) == 1
    assert config.countries[0] == "DEU"
    m = build_openprom_model(config, load_data=False)
    assert m.vDummyObj is not None
    assert hasattr(m, "V01StockPcYearly")
    assert hasattr(m, "Q01Lft")
    assert hasattr(m, "qDummyObj")
    assert m.obj.sense.name == "minimize"
    assert len(m._core_sets.an) >= 1
    print("test_build_one_country_one_period passed")


if __name__ == "__main__":
    test_build_one_country_one_period()
