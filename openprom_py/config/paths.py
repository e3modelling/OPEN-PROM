"""
Resolve project and data paths using relative paths from this package.

The data folder is assumed to be named 'data' and to live in the same
directory as the project root (the directory containing config/, core/, modules/, data/).
All CSV/CSVR input paths are relative to DATA_DIR so that the same code works
regardless of where the project is located.
"""
from pathlib import Path

# Directory where this file lives (openprom_py/config/)
_CONFIG_DIR = Path(__file__).resolve().parent
# Project root: one level up from config (openprom_py/)
PROJECT_ROOT = _CONFIG_DIR.parent
# Data directory: openprom_py/data/ — place all CSV/CSVR files here
DATA_DIR = PROJECT_ROOT / "data"


def data_path(*parts: str) -> Path:
    """
    Build path to a file under the data folder.
    Example: data_path("iElastA.csv") -> PROJECT_ROOT / "data" / "iElastA.csv"
    """
    return DATA_DIR.joinpath(*parts)
