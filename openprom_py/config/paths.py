"""
Resolve project and data paths using relative paths from this package.

Test runs use the isolated data folder at the repository root (OPEN-PROM/data/).
All CSV/CSVR input paths are relative to DATA_DIR.
"""
from pathlib import Path

# Directory where this file lives (openprom_py/config/)
_CONFIG_DIR = Path(__file__).resolve().parent
# Project root: one level up from config (openprom_py/)
PROJECT_ROOT = _CONFIG_DIR.parent
# Repository root: one level up from openprom_py (OPEN-PROM/)
REPO_ROOT = PROJECT_ROOT.parent
# Data directory: repo-level isolated data folder for test runs (OPEN-PROM/data/)
DATA_DIR = REPO_ROOT / "data"


def data_path(*parts: str) -> Path:
    """
    Build path to a file under the data folder (OPEN-PROM/data/).
    Example: data_path("iElastA.csv") -> REPO_ROOT / "data" / "iElastA.csv"
    """
    return DATA_DIR.joinpath(*parts)
