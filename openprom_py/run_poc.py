"""
Run OPEN-PROM PoC: build model, run time x country loop, solve with Ipopt.

The GAMS model (core/solve.gms) loops over time (an) and then over countries
(runCyL); for each (year, country) it updates the active time/country, applies
preloop fixes, solves the NLP (minimize vDummyObj), and in postsolve fixes
solution values for the next period. This script builds the full model once and
solves one year (PoC); extend the loop and add postsolve fixes for a full run.

Run report (main.lst) is written from the start of run_poc; for import errors
before that, check the console/traceback.
"""
import sys
import time
from typing import Optional

from pyomo.opt import SolverFactory
from pyomo.core import value

from config.poc_config import PoCConfig
from build_model import build_openprom_model
from run_report import (
    create_run_archive,
    start_run_report,
    end_run_report,
    get_report_logger,
    log_section,
    log_solver_output,
    log_starting_model_build,
    log_starting_execution,
    log_generating_nlp_model,
    log_rcc_attempt,
    log_model_statistics_line,
    log_solve_summary,
    log_traceback,
    get_report_path,
    write_modelstat_line,
)

# Ipopt maximum iterations (default 3000). Increase if the solver hits maxIterations.
IPOPT_MAX_ITER = 10000

# GAMS modelstat: 1 = Optimal, 2 = Locally optimal (success); >2 = retry or fail
MODELSTAT_OPTIMAL = 1
MODELSTAT_LOCALLY_OPTIMAL = 2


def _termination_to_modelstat(termination_condition: str) -> int:
    """Map Pyomo solver termination to GAMS-like modelstat (1=optimal, 2=locally optimal, 4=infeasible, etc.)."""
    t = str(termination_condition).lower()
    if t in ("optimal", "globally_optimal"):
        return MODELSTAT_OPTIMAL
    if t in ("locally_optimal", "ok"):
        return MODELSTAT_LOCALLY_OPTIMAL
    if "infeasible" in t:
        return 4
    if "unbounded" in t:
        return 3
    return 13  # other/error


class _TeeStream:
    """Writes to both stdout and the run report (for solver tee)."""

    def __init__(self):
        self._stdout = sys.stdout

    def write(self, text: str) -> None:
        self._stdout.write(text)
        self._stdout.flush()
        log_solver_output(text)

    def flush(self) -> None:
        self._stdout.flush()


def run_poc(config: Optional[PoCConfig] = None, load_data: bool = True):
    """
    Build model, run solve loop (one year in PoC), return model and results.

    If Ipopt is not available, returns (m, None) and reports to main.lst.
    Otherwise returns (m, list of {year, status, termination, vDummyObj}).
    """
    config = config or PoCConfig.default_poc()
    t0 = time.perf_counter()
    run_dir, report_path = create_run_archive()
    start_run_report(config, report_path=report_path, load_data=load_data)
    log = get_report_logger()

    def log_info(msg: str) -> None:
        if log:
            log.info(msg)

    try:
        log_section("Data loading")
        log_info("(see Model build phase for load_data result)")

        log_starting_model_build()
        log_section("Model build")
        log_info("Building model (core + price stub + transport)...")
        m = build_openprom_model(config, load_data=load_data)
        log_info("Model build complete.")

        core_sets = m._core_sets
        opt = SolverFactory("ipopt")
        available = opt is not None and opt.available()

        log_starting_execution()
        log_section("Solve")
        log_info(f"Solver: ipopt  available: {available}")
        log_info(f"Ipopt options: max_iter={IPOPT_MAX_ITER}")

        if not available:
            elapsed = time.perf_counter() - t0
            end_run_report(False, "Ipopt not available. Install with conda install -c conda-forge ipopt (see README).", elapsed_seconds=elapsed)
            print("Ipopt not available. Report written to", report_path)
            print("Run archive:", run_dir)
            return m, None

        results = []
        run_cy = core_sets.runCy
        solver_try_max = getattr(config, "solver_try_max", 4)

        for s_iter, year in enumerate(core_sets.an, start=1):
            countries_str = ", ".join(run_cy)
            log_section("Solve cycle: year {} | countries: {}".format(year, countries_str))
            log_info(">>> Start iterations for year {}, country/ies: {} <<<".format(year, countries_str))

            # rcc loop (GAMS): try solver up to solver_try_max times; stop when modelstat <= 2 (optimal/locally optimal)
            modelstat = 100  # "not yet solved"
            res = None
            for rcc_attempt in range(1, solver_try_max + 1):
                if modelstat <= MODELSTAT_LOCALLY_OPTIMAL:
                    break
                log_info("--- rcc attempt {}/{} (solver try) ---".format(rcc_attempt, solver_try_max))
                log_rcc_attempt(rcc_attempt)
                log_generating_nlp_model(model_name="openprom")
                log_model_statistics_line(model_name="openprom", solver="NLP")
                tee_stream = _TeeStream()
                old_stdout = sys.stdout
                try:
                    sys.stdout = tee_stream
                    res = opt.solve(
                        m,
                        tee=True,
                        options={"max_iter": IPOPT_MAX_ITER},
                    )
                finally:
                    sys.stdout = old_stdout

                term = res.solver.termination_condition
                modelstat = _termination_to_modelstat(str(term))
                status = res.solver.status
                obj = value(m.vDummyObj) if m.vDummyObj.value is not None else None

                log_solve_summary(
                    model_name="openprom",
                    objective="vDummyObj",
                    solver_type="NLP",
                    status=str(status),
                    termination=str(term),
                    objective_value=obj,
                )
                log_info("rcc {}: termination={}  modelstat={}  vDummyObj={}".format(
                    rcc_attempt, term, modelstat, obj))
                if modelstat <= MODELSTAT_LOCALLY_OPTIMAL:
                    log_info("--- rcc: success (modelstat {}), stopping solver tries ---".format(modelstat))
                    break

            if res is None:
                elapsed = time.perf_counter() - t0
                end_run_report(False, "Solver did not run (no result).", elapsed_seconds=elapsed)
                return m, results

            status = res.solver.status
            term = res.solver.termination_condition
            obj = value(m.vDummyObj) if m.vDummyObj.value is not None else None
            results.append({
                "year": year,
                "status": str(status),
                "termination": str(term),
                "modelstat": modelstat,
                "vDummyObj": obj,
            })

            # GAMS-compatible modelstat.txt: one line per country for this year
            for country in run_cy:
                write_modelstat_line(country, modelstat, year)

            log_info(">>> End of iterations for year {}, country/ies: {} <<<".format(year, countries_str))
            log_info(f"Termination: {term}  Status: {status}  modelstat: {modelstat}  vDummyObj: {obj}")
            if modelstat > MODELSTAT_LOCALLY_OPTIMAL:
                elapsed = time.perf_counter() - t0
                end_run_report(
                    False,
                    "Solver failed after {} attempts: termination={}, modelstat={}".format(
                        solver_try_max, term, modelstat),
                    elapsed_seconds=elapsed,
                )
                print("Solver did not report optimal. Report written to", report_path)
                print("Run archive:", run_dir)
                return m, results

            print(f"Year {year} status={status} termination={term} modelstat={modelstat} vDummyObj={obj}")
            break  # PoC: run one year only

        elapsed = time.perf_counter() - t0
        end_run_report(True, "Solved 1 year.", elapsed_seconds=elapsed)
        print("Report written to", report_path)
        print("Run archive:", run_dir)
        return m, results

    except Exception as e:
        elapsed = time.perf_counter() - t0
        log_traceback()
        end_run_report(False, str(e), elapsed_seconds=elapsed)
        print("Run failed. Report written to", report_path)
        print("Run archive:", run_dir)
        raise


if __name__ == "__main__":
    try:
        m, results = run_poc(load_data=False)
        if results:
            print("Results:", results)
        else:
            print("Model built; solver not run (Ipopt missing or no data).")
    except Exception:
        report_path = get_report_path()
        if report_path:
            print("Report written to", report_path)
        raise
