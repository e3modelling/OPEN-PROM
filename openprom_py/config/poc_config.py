"""
Run configuration: countries, time horizon, and flags.

Mirrors the GAMS $setGlobal / $evalGlobal definitions in main.gms so that
the Python run uses the same scenario and horizon as a typical GAMS run.
"""
from pathlib import Path

from dataclasses import dataclass
from typing import Sequence

from .paths import DATA_DIR, PROJECT_ROOT


@dataclass(frozen=True)
class PoCConfig:
    """
    Proof-of-concept configuration.

    All attributes correspond to GAMS compile-time symbols used in main.gms
    and in core/sets.gms for building time and country sets.
    """

    # Countries to run (GAMS: fCountries), e.g. ("DEU",) or ("CHA", "DEU", "IND", "USA", "RWO")
    countries: Sequence[str]
    # Time horizon: first and last year in the model (GAMS: fStartHorizon, fEndHorizon)
    start_horizon: int  # e.g. 2010
    end_horizon: int    # e.g. 2100
    # First and last solving year (GAMS: fStartY, fEndY). Model solves for years in [start_y, end_y].
    start_y: int        # e.g. 2024
    end_y: int          # e.g. 2100
    # Base year for historical data (GAMS: fBaseY = fStartY - period_of_years)
    base_y: int
    # Number of years per period (GAMS: fPeriodOfYears), typically 1
    period_of_years: int
    # Scenario index: 0 = No carbon price, 1 = NPi_Default, 2 = 1.5C, 3 = 2C (GAMS: fScenario)
    scenario: int
    # Calibration mode: "off", "Calibration", or "MatCalibration" (GAMS: %Calibration%)
    calibration: str
    # MAgPIE link: "on" or "off" (GAMS: %link2MAgPIE%)
    link2magpie: str
    # Maximum solver attempts per time step (GAMS: %SolverTryMax%)
    solver_try_max: int

    @property
    def data_dir(self) -> Path:
        """Path to the data directory (openprom_py/data/)."""
        return DATA_DIR

    @property
    def project_root(self) -> Path:
        """Path to the project root (openprom_py/)."""
        return PROJECT_ROOT

    @classmethod
    def default_poc(cls) -> "PoCConfig":
        """
        Default configuration: one country (DEU), full horizon to 2100, calibration off.
        Matches GAMS main.gms: fStartY=2024, fEndY=2100.
        """
        return cls(
            countries=("DEU",),
            start_horizon=2010,
            end_horizon=2100,
            start_y=2024,
            end_y=2100,
            base_y=2023,
            period_of_years=1,
            scenario=1,
            calibration="off",
            link2magpie="off",
            solver_try_max=4,
        )
