"""
GAMS-style run report: single file (main.lst) with configuration, data load,
model build, solver output, and errors so failures are easy to locate.

Report is written from the start of run_poc; for import errors before that,
check the console/traceback.

Each run can be archived under runs/<timestamp>/ with main.lst and a snapshot
of the openprom_py code (see create_run_archive).
"""
import logging
import shutil
import sys
import traceback
from datetime import datetime
from pathlib import Path
from typing import Any, Optional, Tuple

# Module-level state for the current run's report
_report_file = None
_report_logger = None
_report_path: Optional[Path] = None
_report_handler: Optional[logging.FileHandler] = None

REPORT_LOGGER_NAME = "openprom.run_report"
DEFAULT_REPORT_FILENAME = "main.lst"


def _get_project_root() -> Path:
    """Project root for default report path; fallback to cwd if config not available."""
    try:
        from config.paths import PROJECT_ROOT
        return PROJECT_ROOT
    except Exception:
        return Path.cwd()


def _ignore_run_archive(dirname: str, names: list) -> list:
    """Names to exclude when copying openprom_py into a run archive (code snapshot)."""
    ignore = {
        ".venv", "venv", "__pycache__", ".git", "runs", "main.lst",
        ".gitignore",
    }
    return [
        n for n in names
        if n in ignore or n.endswith(".pyc") or n.endswith(".lst")
    ]


def create_run_archive() -> Tuple[Path, Path]:
    """
    Create runs/<timestamp>/ and a snapshot of openprom_py there.
    Returns (run_dir, report_path) where report_path = run_dir / "main.lst".
    The snapshot is run_dir / "openprom_py" (code at run start).
    """
    root = _get_project_root()
    runs_dir = root / "runs"
    timestamp = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    run_dir = runs_dir / timestamp
    run_dir.mkdir(parents=True, exist_ok=True)

    # Snapshot of code (exclude .venv, __pycache__, runs, etc.)
    snapshot_dst = run_dir / "openprom_py"
    if not snapshot_dst.exists():
        shutil.copytree(root, snapshot_dst, ignore=_ignore_run_archive)

    report_path = run_dir / "main.lst"
    return run_dir, report_path


def _write_line(fp, text: str = "") -> None:
    if fp is None:
        return
    fp.write(text + "\n")
    fp.flush()


def start_run_report(
    config: Any,
    report_path: Optional[Path] = None,
    load_data: Optional[bool] = None,
) -> Path:
    """
    Open the report file, write header and configuration, set up file logger.
    Returns the path to the report file. Call end_run_report() when done.
    """
    global _report_file, _report_logger, _report_path, _report_handler

    if report_path is None:
        root = _get_project_root()
        report_path = root / DEFAULT_REPORT_FILENAME

    _report_path = report_path.resolve()
    _report_file = open(_report_path, "w", encoding="utf-8")

    # GAMS-style header (mirrors main.lst first lines)
    _write_line(_report_file, "OPEN-PROM PoC  Python/Pyomo  {}".format(
        datetime.now().strftime("%m/%d/%y %H:%M:%S")))
    _write_line(_report_file, "O p e n   P r o m   P o C   R u n")
    _write_line(_report_file, "E x e c u t i o n")
    _write_line(_report_file, "")
    _write_line(_report_file, "Command: run_poc (load_data={})".format(
        load_data if load_data is not None else "?"))
    if "runs" in _report_path.parts:
        run_archive_dir = _report_path.parent
        _write_line(_report_file, "Run archive: {} (main.lst + openprom_py snapshot)".format(
            run_archive_dir))
    _write_line(_report_file, "")

    # Configuration section (GAMS $setGlobal / $evalGlobal style)
    _write_line(_report_file, "*** Configuration (GAMS-equivalent flags) ***")
    if config is not None:
        countries = getattr(config, "countries", ())
        fcountries = ",".join(countries) if countries else "?"
        _write_line(_report_file, "  Calibration       {}".format(
            getattr(config, "calibration", "off")))
        _write_line(_report_file, "  link2MAgPIE       {}".format(
            getattr(config, "link2magpie", "off")))
        _write_line(_report_file, "  SolverTryMax      {}".format(
            getattr(config, "solver_try_max", "?")))
        _write_line(_report_file, "  fCountries        '{}'".format(fcountries))
        _write_line(_report_file, "  fPeriodOfYears     {}".format(
            getattr(config, "period_of_years", 1)))
        _write_line(_report_file, "  fStartHorizon     {}".format(
            getattr(config, "start_horizon", "?")))
        _write_line(_report_file, "  fEndHorizon       {}".format(
            getattr(config, "end_horizon", "?")))
        _write_line(_report_file, "  fStartY           {}".format(
            getattr(config, "start_y", "?")))
        _write_line(_report_file, "  fEndY             {}".format(
            getattr(config, "end_y", "?")))
        _write_line(_report_file, "  fBaseY            {}".format(
            getattr(config, "base_y", "?")))
        _write_line(_report_file, "  fScenario         {}".format(
            getattr(config, "scenario", "?")))
        _write_line(_report_file, "")
        _write_line(_report_file, "**MODULE REALIZATION SWITCHES**")
        _write_line(_report_file, "  Transport         simple")
        _write_line(_report_file, "  (other modules   legacy/off in PoC)")
        _write_line(_report_file, "")
        _write_line(_report_file, "  load_data         {}".format(
            load_data if load_data is not None else "?"))
        try:
            data_dir = getattr(config, "data_dir", None)
            if data_dir is not None:
                _write_line(_report_file, "  data_dir          {}".format(Path(data_dir).resolve()))
        except Exception:
            pass
    _write_line(_report_file, "")

    # Create logger that writes to this file only
    _report_logger = logging.getLogger(REPORT_LOGGER_NAME)
    _report_logger.setLevel(logging.DEBUG)
    _report_logger.handlers.clear()
    _report_handler = logging.StreamHandler(_report_file)
    _report_handler.setLevel(logging.DEBUG)
    _report_handler.setFormatter(logging.Formatter("%(message)s"))
    _report_logger.addHandler(_report_handler)
    _report_logger.propagate = False

    return _report_path


def get_report_logger() -> Optional[logging.Logger]:
    """Return the logger for this run; None if no report started."""
    return _report_logger


def log_section(title: str) -> None:
    """Write a section header to the report file."""
    if _report_file is None:
        return
    _write_line(_report_file, "")
    _write_line(_report_file, f"=== {title} ===")


def log_solver_output(text: str) -> None:
    """Append raw solver output (tee) to the report file."""
    if _report_file is None:
        return
    _report_file.write(text)
    if text and not text.endswith("\n"):
        _report_file.write("\n")
    _report_file.flush()


def log_model_statistics_line(model_name: str = "openprom", solver: str = "NLP") -> None:
    """Write GAMS-style 'Model Statistics SOLVE ... Using NLP' line before solver output."""
    if _report_file is None:
        return
    _write_line(_report_file, "Model Statistics    SOLVE {} Using {} From line 0".format(
        model_name, solver))
    _write_line(_report_file, "")
    _write_line(_report_file, "")


def log_solve_summary(
    model_name: str = "openprom",
    objective: str = "vDummyObj",
    solver_type: str = "NLP",
    status: Optional[str] = None,
    termination: Optional[str] = None,
    objective_value: Optional[float] = None,
) -> None:
    """
    Write GAMS-style S O L V E   S U M M A R Y block after solver output.
    Mirrors the block in GAMS main.lst (MODEL, OBJECTIVE, status, etc.).
    """
    if _report_file is None:
        return
    _write_line(_report_file, "")
    _write_line(_report_file, "               S O L V E      S U M M A R Y")
    _write_line(_report_file, "")
    _write_line(_report_file, "     MODEL   {:<16} OBJECTIVE  {}".format(
        model_name, objective))
    _write_line(_report_file, "     TYPE    {}".format(solver_type))
    if status is not None:
        _write_line(_report_file, "     SOLVER STATUS  {}".format(status))
    if termination is not None:
        _write_line(_report_file, "     TERMINATION    {}".format(termination))
    if objective_value is not None:
        _write_line(_report_file, "     OBJECTIVE VAL  {}".format(objective_value))
    _write_line(_report_file, "")


def _format_elapsed(seconds: float) -> str:
    """Format elapsed time as HH:MM:SS and seconds (e.g. '0:01:23 (83.45 s)')."""
    if seconds < 0:
        return "?"
    s = int(seconds)
    h, s = divmod(s, 3600)
    m, s = divmod(s, 60)
    return "{:d}:{:02d}:{:02d} ({:.2f} s)".format(h, m, s, seconds)


def end_run_report(
    success: bool,
    summary: Optional[str] = None,
    elapsed_seconds: Optional[float] = None,
) -> None:
    """
    Write run time (if provided), final status (RUN SUCCESSFUL / RUN FAILED), and close the report file.
    """
    global _report_file, _report_logger, _report_path, _report_handler

    if _report_file is None:
        return

    _write_line(_report_file, "")
    if elapsed_seconds is not None:
        _write_line(_report_file, "=== Run time ===")
        _write_line(_report_file, "Total PoC run time: {}".format(_format_elapsed(elapsed_seconds)))
        _write_line(_report_file, "")
    _write_line(_report_file, "=== End of run ===")
    if success:
        _write_line(_report_file, "*** RUN SUCCESSFUL ***")
        if summary:
            _write_line(_report_file, summary)
    else:
        _write_line(_report_file, "*** RUN FAILED ***")
        if summary:
            _write_line(_report_file, f"Reason: {summary}")

    if _report_handler and _report_logger:
        _report_logger.removeHandler(_report_handler)
        _report_handler.close()
    _report_file.close()
    _report_file = None
    _report_logger = None
    _report_handler = None


def log_traceback() -> None:
    """Log the current exception's traceback to the report (Errors section)."""
    logger = get_report_logger()
    if logger is None:
        return
    log_section("Errors")
    exc_type, exc_value, exc_tb = sys.exc_info()
    if exc_tb is not None:
        for line in traceback.format_exception(exc_type, exc_value, exc_tb):
            logger.info(line.rstrip())
    else:
        logger.info(f"{exc_type}: {exc_value}")


def get_report_path() -> Optional[Path]:
    """Return the path to the current report file, or None."""
    return _report_path
