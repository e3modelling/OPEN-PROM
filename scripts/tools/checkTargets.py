"""
Script Description
------------------
Checks the results of the latest OPEN-PROM run against a list of targets.

It finds the newest run folder in Runs/ that has a reporting.mif, reads the World
region (or the region set in the targets file), adds up the variables listed for
each target, and reports whether each target passes.

Targets are defined in a JSON file (default: checkTargets.json next to this script):

{
  "region": "World",
  "targets": [
    {
      "name": "Light industry CO2 in 2030",
      "variables": ["Emissions|CO2|Energy|Demand|Industry|Food Drink and Tobacco",
                    "Emissions|CO2|Energy|Demand|Industry|Engineering"],
      "op": "<=",
      "value": 921,
      "year": 2030
    }
  ]
}

Fields of a target:
- name         label shown in the output
- variables    reporting variables to add up; prefix a name with "-" to subtract it
- numerator,   use these two lists instead of "variables" for a share target:
  denominator  sum(numerator) / sum(denominator), compared as a fraction (0.05 = 5%)
- op           one of <=, <, >=, >, ==  (emission limits: <=, penetration shares: >=)
- value        threshold, in the unit of the variables (a fraction for shares)
- year         (optional) the target must hold in this year
- by           (optional) the target must hold in at least one year up to and including this one
- tolerance    (optional) allowed absolute difference for op "==" (default 0)
A target needs "year", "by" or both. The output also shows the first model year in which
the condition holds and the values every 5 years from 2025 to 2050.

Targets can be grouped. A group reports how many of its targets pass, and passes if all
of them pass ("require": "all", the default) or if at least one passes ("require": "any"):

    {"group": "Industry and supply in 2030", "require": "all", "targets": [ {...}, {...} ]}

Usage:
    python scripts/tools/checkTargets.py                       # latest run, default targets file
    python scripts/tools/checkTargets.py --run Runs/<folder>   # a specific run folder or .mif file
    python scripts/tools/checkTargets.py --targets my.json     # another targets file
    python scripts/tools/checkTargets.py --list "Industry"     # find variable names containing a text
    python scripts/tools/checkTargets.py --compare             # numbered list of runs, then choose
    python scripts/tools/checkTargets.py --compare 1 3 5-8     # check these runs side by side
    python scripts/tools/checkTargets.py --compare all         # every run folder with a reporting.mif

--compare numbers the run folders in Runs/ that have a reporting.mif, oldest first (by the
timestamp in the folder name), so the runs of a batch keep their CSV order. It prints one
table with a row per run and a column per target (value in the target year, or the first
year met for 'by' targets, with ✓/✗), and how many checks each run passes. Use --run on a
single folder to see the full detail of one run.

The exit code is 0 if all targets pass and 1 otherwise (always 0 with --compare).
Only the Python standard library is used.
"""

import argparse
import csv
import difflib
import json
import operator
import contextlib
import io
import re
import sys
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_DIR = SCRIPT_DIR.parent.parent
DEFAULT_RUNS_DIR = REPO_DIR / "Runs"
DEFAULT_TARGETS = SCRIPT_DIR / "checkTargets.json"
SERIES_YEARS = [2025, 2030, 2035, 2040, 2045, 2050]
DEFAULT_START_YEAR = 2024  # used if the run's main.gms does not give fStartY

OPS = {"<=": operator.le, "<": operator.lt, ">=": operator.ge, ">": operator.gt}


# ---------------------------------------------------------------- run selection
def find_latest_run(runs_dir):
    """Newest run folder (by modification time) that contains a reporting.mif."""
    folders = sorted((p for p in runs_dir.iterdir() if p.is_dir()),
                     key=lambda p: p.stat().st_mtime, reverse=True)
    if not folders:
        sys.exit(f"No run folders found in {runs_dir}")
    with_mif = [p for p in folders if (p / "reporting.mif").is_file()]
    if not with_mif:
        sys.exit(f"No run folder in {runs_dir} has a reporting.mif")
    latest = with_mif[0]
    newer_without = [p.name for p in folders if p.stat().st_mtime > latest.stat().st_mtime]
    if newer_without:
        print(f"WARNING: {len(newer_without)} newer run folder(s) have no reporting.mif "
              f"(failed, still running or not reported): {', '.join(newer_without)}\n")
    return latest / "reporting.mif"


def resolve_mif(run_arg, runs_dir):
    if run_arg is None:
        return find_latest_run(runs_dir)
    path = Path(run_arg)
    if path.is_dir():
        path = path / "reporting.mif"
    if not path.is_file():
        sys.exit(f"reporting.mif not found: {path}")
    return path


def run_order(folder):
    """Sort key: the timestamp at the end of the folder name (creation order), else modification time."""
    match = re.search(r"(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})$", folder.name)
    return match.group(1) if match else time.strftime("%Y-%m-%d_%H-%M-%S", time.localtime(folder.stat().st_mtime))


def list_runs(runs_dir):
    """Run folders in runs_dir that have a reporting.mif, oldest first (so a batch keeps its CSV order)."""
    folders = sorted((p for p in runs_dir.iterdir() if p.is_dir()), key=run_order)
    without = [p.name for p in folders if not (p / "reporting.mif").is_file()]
    if without:
        print(f"Skipped {len(without)} run folder(s) without a reporting.mif "
              f"(failed, still running or not reported): {', '.join(without)}\n")
    runs = [p for p in folders if (p / "reporting.mif").is_file()]
    if not runs:
        sys.exit(f"No run folder in {runs_dir} has a reporting.mif")
    return runs


def parse_selection(text, n):
    """'1 3 5-8' or '1,3,5-8' or 'all' -> sorted list of 1-based numbers."""
    if text.strip().lower() == "all":
        return list(range(1, n + 1))
    chosen = set()
    for token in re.split(r"[\s,]+", text.strip()):
        if not token:
            continue
        match = re.fullmatch(r"(\d+)(?:-(\d+))?", token)
        if not match:
            sys.exit(f"Cannot read '{token}': use numbers, ranges like 3-7, or 'all'")
        lo, hi = int(match.group(1)), int(match.group(2) or match.group(1))
        if not 1 <= lo <= hi <= n:
            sys.exit(f"'{token}' is outside 1-{n}")
        chosen.update(range(lo, hi + 1))
    if not chosen:
        sys.exit("No runs chosen")
    return sorted(chosen)


def short_name(folder):
    """Folder name without the trailing _YYYY-MM-DD_HH-MM-SS timestamp."""
    return re.sub(r"_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}$", "", folder.name)


def model_start_year(mif_path):
    """fStartY from the run's main.gms, so 'first year met' ignores historical years."""
    main = mif_path.parent / "main.gms"
    if main.is_file():
        match = re.search(r"^\$evalGlobal\s+fStartY\s+(\d{4})", main.read_text(errors="ignore"), re.M)
        if match:
            return int(match.group(1))
    return DEFAULT_START_YEAR


# ---------------------------------------------------------------- reading the mif
def first_line(path):
    with open(path, encoding="utf-8", errors="ignore") as f:
        return f.readline()


def to_float(text):
    text = text.strip()
    if text in ("", "N/A", "NA", "NaN", "nan"):
        return None
    try:
        return float(text)
    except ValueError:
        return None


def read_mif(path, region):
    """Return {variable: (unit, {year: value})} for one region."""
    with open(path, newline="", encoding="utf-8", errors="ignore") as f:
        first = f.readline()
        f.seek(0)
        sep = ";" if first.count(";") >= first.count(",") else ","
        reader = csv.reader(f, delimiter=sep)
        header = next(reader)
        years = {i: int(h) for i, h in enumerate(header) if h.strip().isdigit()}
        data = {}
        for row in reader:
            if len(row) < 5 or row[2] != region:
                continue
            data[row[3]] = (row[4], {y: to_float(row[i]) for i, y in years.items() if i < len(row)})
    if not data:
        sys.exit(f"Region '{region}' not found in {path}")
    return data


# ---------------------------------------------------------------- checking targets
def sum_variables(data, names, year):
    """Signed sum over the variables in one year; None if any value is missing."""
    total = 0.0
    for name in names:
        sign, var = (-1.0, name[1:]) if name.startswith("-") else (1.0, name)
        value = data[var][1].get(year)
        if value is None:
            return None
        total += sign * value
    return total


def check_condition(op, value, threshold, tolerance):
    if value is None:
        return False
    if op == "==":
        return abs(value - threshold) <= tolerance
    return OPS[op](value, threshold)


def fmt(x):
    return "n/a" if x is None else f"{x:,.1f}"


def check_target(target, data, start_year, indent="   ", record=None):
    name = target.get("name", "unnamed target")
    is_share = "numerator" in target or "denominator" in target
    num = target.get("numerator" if is_share else "variables", [])
    den = target.get("denominator", []) if is_share else []
    op = target.get("op", ">=" if is_share else "<=")
    threshold = target.get("value")
    year = target.get("year")
    by = target.get("by")
    tolerance = target.get("tolerance", 0)
    head = indent[:-3]

    problems = []
    if not num or (is_share and not den):
        problems.append("give 'variables', or both 'numerator' and 'denominator'")
    if op not in OPS and op != "==":
        problems.append(f"unknown op '{op}' (use <=, <, >=, >, ==)")
    if threshold is None:
        problems.append("no value given")
    if year is None and by is None:
        problems.append("give 'year', 'by' or both")
    for m in [n.lstrip("-") for n in num + den if n.lstrip("-") not in data]:
        close = difflib.get_close_matches(m, data.keys(), n=3, cutoff=0.6)
        problems.append(f"variable not found: '{m}'" + (f" (did you mean: {'; '.join(close)})" if close else ""))
    print(f"{head}== {name}")
    if problems:
        for p in problems:
            print(f"{indent}ERROR: {p}")
        print()
        if record is not None:
            when = " ".join(([f"in {year}"] if year is not None else []) + ([f"by {by}"] if by is not None else []))
            record.append({"name": name, "cell": "error", "passed": False,
                           "rule": f"{op} {threshold} {when}   (error: see --run on that folder)"})
        return False

    def value_in(y):
        top = sum_variables(data, num, y)
        if not is_share:
            return top
        bottom = sum_variables(data, den, y)
        return None if top is None or not bottom else top / bottom

    def show(x):
        return ("n/a" if x is None else f"{100 * x:.1f}%") if is_share else fmt(x)

    if is_share:
        unit = "share"
        for part, names in (("numerator", num), ("denominator", den)):
            units = sorted({data[n.lstrip('-')][0] for n in names})
            if len(units) > 1:
                print(f"{indent}WARNING: the {part} variables have different units: {', '.join(units)}")
    else:
        units = sorted({data[n.lstrip('-')][0] for n in num})
        unit = units[0] if len(units) == 1 else " + ".join(units)
        if len(units) > 1:
            print(f"{indent}WARNING: the variables have different units: {', '.join(units)}")

    all_years = sorted(data[num[0].lstrip("-")][1])
    first_met = next((y for y in all_years if y >= start_year
                      and check_condition(op, value_in(y), threshold, tolerance)), None)

    passed = True
    threshold_text = f"{op} {show(threshold)}" + (f" ± {show(tolerance)}" if op == "==" else "")
    if record is not None:
        cells = []
        if year is not None:
            v = value_in(year)
            cells.append(("n/a" if v is None else f"{100 * v:.1f}%") if is_share else
                         ("n/a" if v is None else f"{v:,.0f}"))
        if by is not None:
            cells.append(str(first_met) if first_met else "never")
        when = " ".join(([f"in {year}"] if year is not None else []) + ([f"by {by}"] if by is not None else []))
        record.append({"name": name, "cell": " / ".join(cells), "rule": f"{threshold_text} {when}"})
    if year is not None:
        value = value_in(year)
        ok = check_condition(op, value, threshold, tolerance)
        passed &= ok
        gap = None if value is None else value - threshold
        gap_text = "n/a" if gap is None else (f"{100 * gap:+.1f} pp" if is_share else f"{gap:+,.1f}")
        print(f"{indent}{year}: {show(value)}{'' if is_share else ' ' + unit}   target {threshold_text}   "
              f"gap {gap_text}   {'PASS' if ok else 'FAIL'}")
    if by is not None:
        ok = first_met is not None and first_met <= by
        passed &= ok
        print(f"{indent}by {by}: first met in {first_met if first_met else 'never'}   {'PASS' if ok else 'FAIL'}")
    else:
        print(f"{indent}first model year meeting {threshold_text}: {first_met if first_met else 'never'}")

    series = "  ".join(f"{y}: {show(value_in(y))}" for y in SERIES_YEARS if y in all_years)
    print(f"{indent}values   {series}")
    ref = year if year is not None else by
    for label, names in ((("numerator", num), ("denominator", den)) if is_share else (("", num),)):
        if len(names) > 1 or is_share:
            if label:
                print(f"{indent}  {label} ({ref}): {fmt(sum_variables(data, names, ref))}")
            for n in names:
                var = n.lstrip("-")
                print(f"{indent}    {'-' if n.startswith('-') else '+'} {var}: {fmt(data[var][1].get(ref))}")
    print()
    if record is not None:
        record[-1]["passed"] = passed
    return passed


def check_group(group, data, start_year, record=None):
    name = group.get("group", "unnamed group")
    require = group.get("require", "all")
    if require not in ("all", "any"):
        print(f"== GROUP {name}\n   ERROR: 'require' must be 'all' or 'any'\n")
        return False
    print(f"== GROUP {name} (require {require})\n")
    results = [check_target(t, data, start_year, indent="      ", record=record) for t in group.get("targets", [])]
    n_pass = sum(results)
    ok = all(results) if require == "all" else any(results)
    met = [t.get("name", "?") for t, r in zip(group.get("targets", []), results) if r]
    print(f"   GROUP RESULT: {n_pass} of {len(results)} met"
          + (f" ({'; '.join(met)})" if 0 < n_pass < len(results) else "")
          + f"   {'PASS' if ok else 'FAIL'}\n")
    return ok


# ---------------------------------------------------------------- comparing runs
def check_run(mif, config, region):
    """Check one run quietly. Returns [(check passed, [records of its targets])], one per check."""
    data = read_mif(mif, region)
    start_year = model_start_year(mif)
    checks = []
    with contextlib.redirect_stdout(io.StringIO()):
        for t in config.get("targets", []):
            record = []
            ok = check_group(t, data, start_year, record) if "group" in t else \
                check_target(t, data, start_year, record=record)
            checks.append((ok, record))
    return checks


def compare_runs(folders, config, region):
    """One table: a row per run, a column per target, then the number of checks passed."""
    rows, legend = [], None
    for folder in folders:
        checks = check_run(folder / "reporting.mif", config, region)
        cells = []
        for i, (_, record) in enumerate(checks, start=1):
            for j, r in enumerate(record):
                code = f"{i}{'abcdefghijklmnopqrstuvwxyz'[j]}" if len(record) > 1 else str(i)
                cells.append((code, r))
        if legend is None:
            legend = [(code, r) for code, r in cells]
        rows.append((short_name(folder), cells, sum(ok for ok, _ in checks), len(checks)))

    print("Targets (letters are the targets of one group; a group passes only if all of them pass):")
    for code, r in legend:
        print(f"  {code:>4}  {r['name']}   [{r['rule']}]")
    print("\nCells show the value in the target year (or, for 'by' targets, the first year met). "
          "✓ = pass, ✗ = fail, error = a variable is missing from that run's reporting.mif.\n")

    codes = [code for code, _ in legend]
    text = {(name, code): f"{r['cell']} {'✓' if r['passed'] else '✗'}"
            for name, cells, _, _ in rows for code, r in cells}
    name_w = max(len("run"), *(len(name) for name, *_ in rows))
    width = {c: max(len(c), *(len(text.get((name, c), "")) for name, *_ in rows)) for c in codes}
    print(f"{'run':<{name_w}}  " + "  ".join(f"{c:>{width[c]}}" for c in codes) + "  checks passed")
    print("-" * (name_w + 2 + sum(width[c] + 2 for c in codes) + 13))
    for name, _, n_pass, n_checks in rows:
        print(f"{name:<{name_w}}  " + "  ".join(f"{text.get((name, c), ''):>{width[c]}}" for c in codes)
              + f"  {n_pass}/{n_checks}")
    return 0


# ---------------------------------------------------------------- main
def main():
    parser = argparse.ArgumentParser(description="Check OPEN-PROM reporting results against targets.")
    parser.add_argument("--run", help="run folder or reporting.mif (default: newest run with a reporting.mif)")
    parser.add_argument("--runs-dir", default=str(DEFAULT_RUNS_DIR), help="folder holding the run folders")
    parser.add_argument("--targets", default=str(DEFAULT_TARGETS), help="targets JSON file")
    parser.add_argument("--list", metavar="TEXT", help="list variables whose name contains TEXT, then exit")
    parser.add_argument("--compare", nargs="*", metavar="N",
                        help="check several runs side by side: give numbers (1 3 5-8, or all), "
                             "or nothing to see the numbered list and choose")
    args = parser.parse_args()

    targets_file = Path(args.targets)
    config = {}
    if args.list is None:
        if not targets_file.is_file():
            sys.exit(f"Targets file not found: {targets_file}")
        config = json.loads(targets_file.read_text())
    region = config.get("region", "World")

    if args.compare is not None:
        runs = list_runs(Path(args.runs_dir))
        print("Runs with a reporting.mif (oldest first):")
        for i, folder in enumerate(runs, start=1):
            print(f"  {i:>3}  {folder.name}")
        print()
        choice = " ".join(args.compare) or input("Runs to check (e.g. 1 2 5-8, or all): ")
        chosen = [runs[i - 1] for i in parse_selection(choice, len(runs))]
        print(f"\nTargets file: {targets_file}\nRegion:       {region}\n")
        return compare_runs(chosen, config, region)

    mif = resolve_mif(args.run, Path(args.runs_dir))
    data = read_mif(mif, region)
    scenario = ""
    with open(mif, encoding="utf-8", errors="ignore") as f:
        f.readline()
        row = f.readline().split(";" if ";" in first_line(mif) else ",")
        scenario = row[1] if len(row) > 1 else ""
    print(f"File:     {mif}")
    print(f"Scenario: {scenario}")
    print(f"Region:   {region}\n")

    if args.list is not None:
        text = args.list.lower()
        for var, (unit, _) in sorted(data.items()):
            if text in var.lower():
                print(f"{var} [{unit}]")
        return 0

    start_year = model_start_year(mif)
    results = [check_group(t, data, start_year) if "group" in t else check_target(t, data, start_year)
               for t in config.get("targets", [])]
    n_pass = sum(results)
    print(f"{n_pass}/{len(results)} checks passed (a group counts as one check).")
    return 0 if results and all(results) else 1


if __name__ == "__main__":
    sys.exit(main())
