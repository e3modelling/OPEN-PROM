#!/usr/bin/env python
import re
import sys
from pathlib import Path
from collections import defaultdict

# ================= CONFIG =================

# Base directory = folder where this script lives (e.g. .../OPEN-PROM/scripts)
BASE_DIR = Path(__file__).resolve().parent

# Default root = parent of scripts folder, i.e. the OPEN-PROM repo root
DEFAULT_ROOT = BASE_DIR.parent

# If a path is passed as an argument, use that as root; otherwise use DEFAULT_ROOT
ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else DEFAULT_ROOT

# Toggle this to True if you also want to check against declarations
CHECK_DECLARED = False

# Folders/paths to ignore (relative to root or absolute)
IGNORE_PATHS = {
    # User-specified paths to ignore
    "modules/01_Transport/legacy",
    "modules/02_Industry/legacy", 
    "modules/04_PowerGeneration/legacy",
    "modules/07_Emissions",
    # System folders to ignore
    "runs",                    # Ignore all run output folders
    "225a", "225b", "225c",   # Ignore solver folders
    # Add more folder names or relative paths here as needed
    # Examples:
    # "deprecated",
    # "modules/99_Legacy", 
    # "old_versions",
    # "backup"
}

# Additional ignore patterns (can use wildcards)
IGNORE_PATTERNS = {
    # Examples:
    # "**/backup/**",
    # "**/deprecated/**",
    # "**/*_old.gms"
}

# Regex for lagged uses in equations/preloop:
# Variables starting with V or Vm that use YTIME - n (where n >= 1)
LAGGED_INDEX_RE = re.compile(
    r'\b(V[mM]?[A-Za-z0-9_]*)\s*(?:\.[Ll])?\s*\([^)]*\bYTIME\s*-\s*([1-9][0-9]*)[^)]*\)',
    re.IGNORECASE,
)

# Regex for variables in postsolve:
# V or Vm variables with .(FX|L|LO|UP|M)
POSTSOLVE_VAR_RE = re.compile(
    r'\b(V[mM]?[A-Za-z0-9_]*)\s*\.(?:FX|L|LO|UP|M)\s*\(',
    re.IGNORECASE,
)

# Declarations (optional, only used if CHECK_DECLARED = True)
VAR_DECL_START_RE = re.compile(
    r'^\s*(positive\s+|negative\s+)?variable(s)?\b', re.IGNORECASE
)

COMMENT_LINE_RE = re.compile(r'^\s*\*')  # GAMS full-line comment


# ================= HELPERS =================

def should_ignore_path(path: Path, root: Path) -> bool:
    """
    Check if a path should be ignored based on IGNORE_PATHS and IGNORE_PATTERNS.
    """
    rel_path = path.relative_to(root)
    
    # Check against direct path matches
    for ignore_path in IGNORE_PATHS:
        ignore_path_obj = Path(ignore_path)
        if ignore_path_obj in rel_path.parents or rel_path == ignore_path_obj:
            return True
        # Also check if any part of the path matches
        if ignore_path in str(rel_path):
            return True
    
    # Check against pattern matches
    for pattern in IGNORE_PATTERNS:
        if rel_path.match(pattern):
            return True
    
    return False


def iter_gms_files(root: Path):
    """
    Yield all .gms files under 'core' or 'modules' (and their subfolders),
    relative to the given root, excluding ignored paths.
    Anything outside these two top-level folders is ignored.
    """
    for p in root.rglob("*.gms"):
        # Skip if path should be ignored
        if should_ignore_path(p, root):
            continue
            
        rel = p.relative_to(root)
        parts_lower = [part.lower() for part in rel.parts]
        if "core" in parts_lower or "modules" in parts_lower:
            yield p


def read_without_ontext(path: Path) -> str:
    """
    Read a .gms file and strip out:
    - $ontext ... $offtext blocks
    - full-line comments starting with '*'
    - inline '//' comments
    """
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    out = []
    in_ontext = False
    for line in lines:
        stripped = line.strip()
        up = stripped.upper()
        if up.startswith("$ONTEXT"):
            in_ontext = True
            continue
        if up.startswith("$OFFTEXT"):
            in_ontext = False
            continue
        if in_ontext:
            continue
        if COMMENT_LINE_RE.match(stripped):
            continue
        if "//" in line:
            line = line.split("//", 1)[0]
        out.append(line)
    return "\n".join(out)


def is_logic_file(path: Path) -> bool:
    """
    Return True if this .gms file is considered a 'logic' file:
    - filename contains 'equations' or 'preloop', OR
    - any directory component is exactly 'equations' or 'preloop'.
    """
    lower_name = path.name.lower()
    if "equations" in lower_name or "preloop" in lower_name:
        return True
    for part in path.parts:
        part_lower = part.lower()
        if part_lower in ("equations", "preloop"):
            return True
    return False


def is_postsolve_file(path: Path) -> bool:
    """
    Return True if this .gms file is a postsolve file.
    Adjust this if your naming convention differs.
    """
    return "postsolve" in path.name.lower()


def is_model_variable(name: str) -> bool:
    """
    For OPEN-PROM we treat only names starting with 'V' or 'Vm' as model variables.
    This includes V01, V02, VmConsFuel, etc.
    """
    return name.upper().startswith("V")


# ================= CORE COLLECTORS =================

def collect_lagged_vars(root: Path):
    """
    Collect all model variables (V* and Vm*) that are used with YTIME - n (n >= 1)
    from equations/preloop files only, organized by module.
    """
    lagged = defaultdict(set)  # var -> set of lags
    per_module_lagged = defaultdict(lambda: defaultdict(set))  # module -> var -> set of lags
    
    for path in iter_gms_files(root):
        if not is_logic_file(path):
            continue
        if is_postsolve_file(path):
            continue
            
        # Determine module from path
        module = "core"
        for part in path.parts:
            if part.startswith(("01_", "02_", "03_", "04_", "05_", "06_", "07_", "08_", "09_", "10_")):
                module = part
                break
                
        text = read_without_ontext(path)
        for m in LAGGED_INDEX_RE.finditer(text):
            var, lag = m.group(1), int(m.group(2))
            if not is_model_variable(var):
                continue
            lagged[var].add(lag)
            per_module_lagged[module][var].add(lag)
            
    return lagged, per_module_lagged


def collect_postsolve_vars(root: Path):
    """
    Collect all model variables (V* and Vm*) that appear in postsolve files
    organized by module. Returns both a global set and per-module breakdown.
    """
    postsolve_vars = set()
    per_module_vars = defaultdict(set)  # module -> set of vars
    per_file_counts = defaultdict(lambda: defaultdict(int))  # file -> var -> count
    
    for path in iter_gms_files(root):
        if not is_postsolve_file(path):
            continue
            
        # Determine module from path
        module = "core"
        for part in path.parts:
            if part.startswith(("01_", "02_", "03_", "04_", "05_", "06_", "07_", "08_")):
                module = part
                break
                
        text = read_without_ontext(path)
        for m in POSTSOLVE_VAR_RE.finditer(text):
            var = m.group(1)
            if not is_model_variable(var):
                continue
            postsolve_vars.add(var)
            per_module_vars[module].add(var)
            per_file_counts[path][var] += 1
            
    return postsolve_vars, per_module_vars, per_file_counts


# ===== Optional: declarations check (only if CHECK_DECLARED) =====

def parse_declared_from_block(block: str):
    """
    Given the text after 'variables' up to ';', extract variable names
    without dimensions or descriptions.
    """
    block = VAR_DECL_START_RE.sub("", block, count=1)
    names = set()
    for part in block.split(","):
        name = part.strip()
        if not name:
            continue
        if "'" in name:
            name = name.split("'", 1)[0].strip()
        if "(" in name:
            name = name.split("(", 1)[0].strip()
        if name:
            names.add(name)
    return names


def collect_declared_vars(root: Path):
    """
    Collect declared variables from 'variable(s)' blocks
    across all .gms files in core/modules.
    Only used if CHECK_DECLARED is True.
    """
    declared = set()
    for path in iter_gms_files(root):
        text = read_without_ontext(path)
        lines = text.splitlines()
        in_decl = False
        buffer = ""
        for line in lines:
            stripped = line.strip()
            if not in_decl:
                if VAR_DECL_START_RE.match(stripped):
                    in_decl = True
                    buffer = stripped
                    if ";" in stripped:
                        before_semicolon = buffer.split(";", 1)[0]
                        declared |= parse_declared_from_block(before_semicolon)
                        in_decl = False
                        buffer = ""
            else:
                buffer += " " + stripped
                if ";" in stripped:
                    before_semicolon = buffer.split(";", 1)[0]
                    declared |= parse_declared_from_block(before_semicolon)
                    in_decl = False
                    buffer = ""
    return declared


# ================= MAIN =================

def main(root: Path):
    print(f"=== OPEN-PROM POSTSOLVE CONSISTENCY CHECK ===")
    print(f"Scanning sources under: {root}")
    
    if IGNORE_PATHS or IGNORE_PATTERNS:
        print(f"Ignoring paths: {', '.join(IGNORE_PATHS) if IGNORE_PATHS else 'None'}")
        print(f"Ignoring patterns: {', '.join(IGNORE_PATTERNS) if IGNORE_PATTERNS else 'None'}")
    print()

    lagged, per_module_lagged = collect_lagged_vars(root)
    postsolve_vars, per_module_postsolve, per_file_counts = collect_postsolve_vars(root)

    lagged_vars = set(lagged.keys())
    
    # Global cross-module analysis - this is the main output
    print("=== GLOBAL CROSS-MODULE ANALYSIS ===")
    truly_missing = lagged_vars - postsolve_vars
    if truly_missing:
        print("🚨 CRITICAL - Variables with YTIME-n that are missing from ALL postsolve files:")
        for var in sorted(truly_missing):
            # Find which modules use this variable
            using_modules = [mod for mod, vars_dict in per_module_lagged.items() if var in vars_dict]
            modules_str = ", ".join(using_modules)
            print(f"   {var} (used in: {modules_str})")
    else:
        print("✅ All lagged variables are handled in some postsolve file")
    
    # Show variables that are handled in postsolve but not used with lags anywhere
    truly_redundant = postsolve_vars - lagged_vars
    if truly_redundant:
        print(f"\n🟡 Variables in postsolve files that don't use YTIME-n anywhere:")
        for var in sorted(truly_redundant):
            # Find which modules have this in postsolve
            handling_modules = [mod for mod, vars_set in per_module_postsolve.items() if var in vars_set]
            modules_str = ", ".join(handling_modules)
            print(f"   {var} (in postsolve: {modules_str})")
    
    if not truly_missing and not truly_redundant:
        print("🎉 ALL VARIABLES ARE CORRECTLY CONFIGURED!")
    
    print()
    print("=== LEGEND ===")
    print("� Critical: Variables that must be added to some postsolve file")
    print("🟡 Redundant: Variables in postsolve but don't use YTIME-n anywhere (can be removed)")
    print("✅ All good: No issues found")
    print()
    print("NOTE: Variables starting with V or Vm only. Parameters (i*, im*) are ignored.")


if __name__ == "__main__":
    main(ROOT)
