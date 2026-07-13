from __future__ import annotations

import os
import shutil
import subprocess
import sys
import time
import uuid
from dataclasses import dataclass
from pathlib import Path

import pandas as pd
from filelock import FileLock, Timeout


REQUIRED_COLUMNS = {"Model", "Scenario", "Region", "Variable", "Unit"}
YEAR_MIN = 2010
YEAR_MAX = 2300


class ClimateRunError(RuntimeError):
    """Raised when an assessment cannot be configured or completed."""


@dataclass(frozen=True)
class RunResult:
    job_id: str
    job_dir: Path
    workbook: Path
    log: Path
    elapsed_seconds: float


@dataclass(frozen=True)
class Settings:
    climate_assessment_dir: Path
    jobs_dir: Path
    infilling_database: Path
    cicero_probabilistic_file: Path
    magicc_probabilistic_file: Path | None
    max_upload_mb: int
    run_timeout_seconds: int
    retention_hours: int

    @classmethod
    def from_environment(cls) -> "Settings":
        climate_dir = Path(
            os.getenv("CLIMATE_ASSESSMENT_DIR", "/opt/climate-assessment")
        )
        magicc_file = os.getenv("MAGICC_PROBABILISTIC_FILE")
        return cls(
            climate_assessment_dir=climate_dir,
            jobs_dir=Path(os.getenv("CLIMATE_JOBS_DIR", "/data/jobs")),
            infilling_database=Path(
                os.getenv("INFILLING_DATABASE", "/opt/climate-assets/infilling.csv")
            ),
            cicero_probabilistic_file=Path(
                os.getenv(
                    "CICERO_PROBABILISTIC_FILE",
                    str(climate_dir / "data/cicero/subset_cscm_configfile.json"),
                )
            ),
            magicc_probabilistic_file=Path(magicc_file) if magicc_file else None,
            max_upload_mb=int(os.getenv("MAX_UPLOAD_MB", "50")),
            run_timeout_seconds=int(os.getenv("RUN_TIMEOUT_SECONDS", "14400")),
            retention_hours=int(os.getenv("JOB_RETENTION_HOURS", "24")),
        )


def validate_emissions_csv(contents: bytes, max_upload_mb: int) -> pd.DataFrame:
    if not contents:
        raise ClimateRunError("The uploaded emissions file is empty.")
    if len(contents) > max_upload_mb * 1024 * 1024:
        raise ClimateRunError(f"The upload exceeds the {max_upload_mb} MB limit.")

    try:
        from io import BytesIO

        frame = pd.read_csv(BytesIO(contents), nrows=20)
    except Exception as exc:
        raise ClimateRunError(f"The upload is not a readable CSV: {exc}") from exc

    missing = sorted(REQUIRED_COLUMNS.difference(frame.columns))
    if missing:
        raise ClimateRunError("Missing IAMC columns: " + ", ".join(missing))

    year_columns = []
    for column in frame.columns:
        try:
            year = int(str(column))
        except ValueError:
            continue
        if YEAR_MIN <= year <= YEAR_MAX:
            year_columns.append(column)
    if not year_columns:
        raise ClimateRunError("No year columns were found in the emissions CSV.")
    return frame


def _require_file(path: Path, label: str) -> None:
    if not path.is_file():
        raise ClimateRunError(f"{label} was not found at {path}")


def _build_command(
    settings: Settings,
    model: str,
    emissions_file: Path,
    output_dir: Path,
    num_cfgs: int,
    scenario_batch_size: int,
) -> list[str]:
    workflow = settings.climate_assessment_dir / "scripts/run_workflow.py"
    _require_file(workflow, "climate-assessment workflow")
    _require_file(settings.infilling_database, "Infilling database")

    versions = {"ciceroscm": "v2019vCH4", "magicc": "v7.5.3"}
    if model not in versions:
        raise ClimateRunError(f"Unsupported climate model: {model}")

    if model == "ciceroscm":
        probabilistic_file = settings.cicero_probabilistic_file
        _require_file(probabilistic_file, "CICERO probabilistic configuration")
    else:
        probabilistic_file = settings.magicc_probabilistic_file
        if probabilistic_file is None:
            raise ClimateRunError("MAGICC_PROBABILISTIC_FILE is not configured.")
        _require_file(probabilistic_file, "MAGICC probabilistic configuration")
        magicc_executable = os.getenv("MAGICC_EXECUTABLE_7")
        if not magicc_executable:
            raise ClimateRunError("MAGICC_EXECUTABLE_7 is not configured.")
        _require_file(Path(magicc_executable), "MAGICC executable")

    command = [
        sys.executable,
        str(workflow),
        str(emissions_file),
        str(output_dir),
        "--model",
        model,
        "--model-version",
        versions[model],
        "--num-cfgs",
        str(num_cfgs),
        "--probabilistic-file",
        str(probabilistic_file),
        "--infilling-database",
        str(settings.infilling_database),
        "--scenario-batch-size",
        str(scenario_batch_size),
    ]
    if model == "magicc":
        command.append("--co2-and-non-co2-warming")
    return command


def run_assessment(
    settings: Settings,
    contents: bytes,
    model: str,
    num_cfgs: int,
    scenario_batch_size: int,
) -> RunResult:
    validate_emissions_csv(contents, settings.max_upload_mb)
    settings.jobs_dir.mkdir(parents=True, exist_ok=True)

    lock = FileLock(str(settings.jobs_dir / "climate-assessment.lock"))
    try:
        lock.acquire(timeout=1)
    except Timeout as exc:
        raise ClimateRunError(
            "Another climate assessment is already running. Try again after it finishes."
        ) from exc

    job_id = uuid.uuid4().hex
    job_dir = settings.jobs_dir / job_id
    output_dir = job_dir / "output"
    emissions_file = job_dir / "emissions.csv"
    log_file = job_dir / "assessment.log"
    output_dir.mkdir(parents=True)
    emissions_file.write_bytes(contents)

    started = time.monotonic()
    try:
        command = _build_command(
            settings,
            model,
            emissions_file,
            output_dir,
            num_cfgs,
            scenario_batch_size,
        )
        try:
            completed = subprocess.run(
                command,
                cwd=settings.climate_assessment_dir,
                capture_output=True,
                text=True,
                timeout=settings.run_timeout_seconds,
                check=False,
            )
        except subprocess.TimeoutExpired as exc:
            stdout = (
                exc.stdout.decode(errors="replace")
                if isinstance(exc.stdout, bytes)
                else (exc.stdout or "")
            )
            stderr = (
                exc.stderr.decode(errors="replace")
                if isinstance(exc.stderr, bytes)
                else (exc.stderr or "")
            )
            log_file.write_text(
                stdout + "\n" + stderr, encoding="utf-8"
            )
            raise ClimateRunError(
                f"Assessment exceeded the {settings.run_timeout_seconds}-second timeout."
            ) from exc

        log_text = completed.stdout + "\n" + completed.stderr
        log_file.write_text(log_text, encoding="utf-8")
        if completed.returncode != 0:
            tail = "\n".join(log_text.splitlines()[-20:])
            raise ClimateRunError(
                f"Assessment exited with code {completed.returncode}.\n\n{tail}"
            )

        workbooks = sorted(output_dir.glob("*_alloutput.xlsx"))
        if not workbooks:
            workbooks = sorted(output_dir.rglob("*_alloutput.xlsx"))
        if len(workbooks) != 1:
            raise ClimateRunError(
                f"Expected one *_alloutput.xlsx file, found {len(workbooks)}."
            )
        return RunResult(
            job_id=job_id,
            job_dir=job_dir,
            workbook=workbooks[0],
            log=log_file,
            elapsed_seconds=time.monotonic() - started,
        )
    except Exception:
        if not log_file.exists():
            log_file.write_text("Assessment failed before execution.\n", encoding="utf-8")
        raise
    finally:
        lock.release()


def cleanup_expired_jobs(settings: Settings) -> None:
    if not settings.jobs_dir.exists():
        return
    cutoff = time.time() - settings.retention_hours * 3600
    for path in settings.jobs_dir.iterdir():
        if not path.is_dir():
            continue
        try:
            if path.stat().st_mtime < cutoff:
                shutil.rmtree(path)
        except OSError:
            # A running job or another process may currently own the directory.
            continue


def read_temperature_data(workbook: Path) -> pd.DataFrame:
    frame = pd.read_excel(workbook)
    columns = {str(column).lower(): column for column in frame.columns}
    required = {"model", "scenario", "region", "variable"}
    if not required.issubset(columns):
        raise ClimateRunError("The output workbook is not in IAMC format.")

    filtered = frame[
        frame[columns["region"]].astype(str).eq("World")
        & frame[columns["variable"]]
        .astype(str)
        .str.contains(r"Surface Temperature \(GSAT\).*50", regex=True, na=False)
    ].copy()
    if filtered.empty:
        raise ClimateRunError("No median World GSAT series was found in the output.")

    if "year" in columns and "value" in columns:
        long_frame = filtered.rename(
            columns={columns["year"]: "Year", columns["value"]: "Temperature"}
        )
    else:
        year_columns = [
            column
            for column in filtered.columns
            if str(column).isdigit() and YEAR_MIN <= int(str(column)) <= YEAR_MAX
        ]
        long_frame = filtered.melt(
            id_vars=[columns["model"], columns["scenario"], columns["variable"]],
            value_vars=year_columns,
            var_name="Year",
            value_name="Temperature",
        )

    long_frame["Year"] = pd.to_numeric(long_frame["Year"], errors="coerce")
    long_frame["Temperature"] = pd.to_numeric(
        long_frame["Temperature"], errors="coerce"
    )
    long_frame["Series"] = (
        long_frame[columns["scenario"]].astype(str)
        + " — "
        + long_frame[columns["variable"]].astype(str)
    )
    return long_frame.dropna(subset=["Year", "Temperature"])[
        ["Year", "Temperature", "Series"]
    ]
