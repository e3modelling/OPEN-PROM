"""
Run report: two separate outputs (like GAMS).

- main.lst: listing file with configuration, data load, model build, solver output,
  and errors (detailed report for debugging).
- main.log: screen log — what you would see in the terminal when running
  (Job Start/Stop, Parameters, Starting execution, Generating NLP model,
  solver tee, Status). Same idea as GAMS main.log.

Both are written from the start of run_poc. Each run can be archived under
runs/<timestamp>/ with main.lst, main.log, and an openprom_py snapshot.
"""
import logging
import shutil
import sys
import traceback
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Optional, Tuple

# Module-level state
_report_file = None   # main.lst (listing)
_log_file = None     # main.log (screen-style output)
_report_logger = None
_report_path: Optional[Path] = None
_report_handler: Optional[logging.FileHandler] = None
_job_start_time: Optional[float] = None

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
    Open main.lst (listing) and main.log (screen log). Write headers and config.
    Returns the path to main.lst. Call end_run_report() when done.
    """
    global _report_file, _log_file, _report_logger, _report_path, _report_handler, _job_start_time

    if report_path is None:
        root = _get_project_root()
        report_path = root / DEFAULT_REPORT_FILENAME

    _job_start_time = time.perf_counter()
    _report_path = report_path.resolve()
    _report_file = open(_report_path, "w", encoding="utf-8")

    # main.log: screen-style output (same idea as GAMS .log = what you see in terminal)
    _log_path = _report_path.parent / "main.log"
    _log_file = open(_log_path, "w", encoding="utf-8")
    now = datetime.now()
    _write_line(_log_file, "--- Job run_poc Start {} {} Python/Pyomo".format(
        now.strftime("%m/%d/%y %H:%M:%S"), "PoC"))
    _write_line(_log_file, "--- Parameters:")
    _write_line(_log_file, "    Report  {}".format(_report_path))
    _write_line(_log_file, "    Log     {}".format(_log_path))
    _write_line(_log_file, "    RunDir  {}".format(_report_path.parent))
    _write_line(_log_file, "")

    # main.lst: listing only (no --- lines; those go to main.log)
    _write_line(_report_file, "OPEN-PROM PoC  Python/Pyomo  {}".format(
        now.strftime("%m/%d/%y %H:%M:%S")))
    _write_line(_report_file, "O p e n   P r o m   P o C   R u n")
    _write_line(_report_file, "E x e c u t i o n")
    _write_line(_report_file, "")
    _write_line(_report_file, "Command: run_poc (load_data={})".format(
        load_data if load_data is not None else "?"))
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
    """Append raw solver output (tee) to main.lst and main.log (screen)."""
    if _report_file is not None:
        _report_file.write(text)
        if text and not text.endswith("\n"):
            _report_file.write("\n")
        _report_file.flush()
    if _log_file is not None:
        _log_file.write(text)
        if text and not text.endswith("\n"):
            _log_file.write("\n")
        _log_file.flush()


def log_model_statistics_line(model_name: str = "openprom", solver: str = "NLP") -> None:
    """Write 'Model Statistics SOLVE ...' to main.lst and main.log (screen)."""
    line = "Model Statistics    SOLVE {} Using {} From line 0".format(model_name, solver)
    if _report_file is not None:
        _write_line(_report_file, line)
        _write_line(_report_file, "")
        _write_line(_report_file, "")
    if _log_file is not None:
        _write_line(_log_file, line)
        _write_line(_log_file, "")
        _write_line(_log_file, "")


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


def _format_elapsed_gams(seconds: float) -> str:
    """Format elapsed time as 0:HH:MM:SS.fff (GAMS main.log style)."""
    if seconds < 0:
        return "?"
    s = int(seconds)
    h, s = divmod(s, 3600)
    m, s = divmod(s, 60)
    frac = seconds - int(seconds)
    return "0:{:d}:{:02d}:{:02d}.{:03.0f}".format(h, m, s, frac * 1000)


def _write_log_line(msg: str) -> None:
    """Write a line to main.log only (screen output)."""
    if _log_file is None:
        return
    _write_line(_log_file, msg)


def log_starting_model_build() -> None:
    """Write '--- Starting model build' to main.log (screen)."""
    _write_log_line("--- Starting model build")


def log_starting_execution() -> None:
    """Write '--- Starting execution: elapsed 0:00:XX.XXX' to main.log (screen)."""
    if _log_file is None or _job_start_time is None:
        return
    elapsed = time.perf_counter() - _job_start_time
    _write_log_line("--- Starting execution: elapsed {}".format(
        _format_elapsed_gams(elapsed)))


def log_generating_nlp_model(model_name: str = "openprom") -> None:
    """Write '--- Generating NLP model openprom' to main.log (screen, before each solve)."""
    _write_log_line("--- Generating NLP model {}".format(model_name))


def log_rcc_attempt(attempt: int) -> None:
    """Write '--- rcc = rccN' to main.log (GAMS-style solver attempt counter)."""
    _write_log_line("--- rcc = rcc{}".format(attempt))


def end_run_report(
    success: bool,
    summary: Optional[str] = None,
    elapsed_seconds: Optional[float] = None,
) -> None:
    """
    Write run time to main.lst; write Status and Job Stop to main.log (screen).
    Then close both files.
    """
    global _report_file, _log_file, _report_logger, _report_path, _report_handler, _job_start_time

    if _report_file is None:
        return

    # main.lst: run time and end-of-run only (listing)
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

    # main.log: screen-style finish (like GAMS .log)
    if _log_file is not None:
        if success:
            _write_line(_log_file, "*** Status: Normal completion")
        else:
            _write_line(_log_file, "*** Status: Run failed")
            if summary:
                _write_line(_log_file, "*** Reason: {}".format(summary))
        total_elapsed = (time.perf_counter() - _job_start_time) if _job_start_time is not None else elapsed_seconds
        if total_elapsed is not None:
            _write_line(_log_file, "--- Job run_poc Stop {} elapsed {}".format(
                datetime.now().strftime("%m/%d/%y %H:%M:%S"),
                _format_elapsed_gams(total_elapsed)))
        _log_file.close()
        _log_file = None

    if _report_handler and _report_logger:
        _report_logger.removeHandler(_report_handler)
        _report_handler.close()
    _report_file.close()
    _report_file = None
    _report_logger = None
    _report_handler = None
    _job_start_time = None


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


def write_modelstat_line(country: str, modelstat: int, year: int) -> None:
    """
    Append a line to modelstat.txt (GAMS-compatible: Country, Model Status, Year).
    File is written next to main.lst (e.g. runs/<timestamp>/modelstat.txt).
    """
    if _report_path is None:
        return
    path = _report_path.parent / "modelstat.txt"
    with open(path, "a", encoding="utf-8") as f:
        f.write("Country: {}  Model Status: {}  Year: {}\n".format(country, modelstat, year))
        f.flush()
