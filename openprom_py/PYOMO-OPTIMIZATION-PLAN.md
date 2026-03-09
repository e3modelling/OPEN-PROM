# OPEN-PROM Pyomo Performance Optimization Plan

> **Date**: March 2026  
> **Scope**: Four optimizations to reduce model build time, data loading time, and per-solve overhead  
> **Decisions**: GAMSPy rejected (license dependency). Linopy rejected (LP-only, see below). We stay with Pyomo and optimize it.

---

## Why Linopy Cannot Replace Pyomo for OPEN-PROM

[Linopy](https://github.com/pypsa/linopy) is a high-performance optimization
framework built on `xarray` and `pandas`. It constructs LP/MIP problems as
dense vectorized arrays, writes flat `.lp`/`.mps` files, and interfaces with
HiGHS, Gurobi, CPLEX, and GLPK. For **linear** models like PyPSA-Eur (power
system dispatch), it is an excellent choice — model construction is orders of
magnitude faster than Pyomo.

**However, OPEN-PROM is a nonlinear programming (NLP) model.** Linopy
fundamentally cannot express OPEN-PROM's economics. The incompatibility is
structural, not a matter of missing features that might be added later.

### Nonlinear constructs used throughout OPEN-PROM

| GAMS construct | Python/Pyomo equivalent | Used in | Linopy support |
|---|---|---|---|
| `SQR(x)` | `x ** 2` | Calibration objective (`qDummyObj`) | ❌ No |
| `LOG(x)` | `log(x)` | CES demand functions, utility | ❌ No |
| `variable × variable` | bilinear terms | Technology share × demand, cost × capacity | ❌ No |
| `x ** iElaSub` (var to param power) | nonlinear CES elasticity | Demand subsector equations | ❌ No |
| `EXP(...)` | exponential | Logit technology shares, learning curves | ❌ No |
| `1 / variable` | inverse | Lifetime = 1/scrapping rate | ❌ No |
| `variable ** 0.5` (sqrt) | fractional power | Some cost functions | ❌ No |

Linopy's own documentation states:

> *"Linopy is designed for **linear** and **mixed-integer linear** optimization
> problems."*

### What would be lost

To use Linopy, one would need to either:

1. **Piecewise-linearize every nonlinear term** — This introduces enormous
   approximation error. Each nonlinearity requires auxiliary binary variables
   and SOS2 constraints. A single `LOG(x)` with 20 breakpoints adds 20 binary
   variables; across ~150 constraints with nonlinear terms, this would produce
   thousands of binaries. The resulting MIP would likely be **slower** to solve
   than the original NLP, and the solutions would lose economic fidelity.

2. **Strip out all nonlinear economics** — The CES demand functions, logit
   technology choice, learning curves, and maturity factors are the core of
   OPEN-PROM's economic behavior. Removing them would produce a different model
   that no longer represents the energy system dynamics OPEN-PROM is designed
   to capture.

3. **Use Linopy for linear submodules only** (e.g., emissions accounting,
   capacity balance) while keeping Pyomo for the nonlinear core — This creates
   a dual-framework maintenance burden, two model objects that must be
   synchronized, and no clear interface boundary.

None of these options are practical.

### What Linopy does well (and why it still doesn't apply)

| Aspect | Pyomo | Linopy |
|---|---|---|
| Construction speed | Slower (Python objects per component) | Much faster (vectorized xarray) |
| Memory for large models | Higher (~600 bytes/Var) | Lower (dense arrays) |
| Solver interface | Broad (NLP, MINLP, LP, MIP) | LP/MIP only |
| Data integration | Manual dict/loop | Native xarray/pandas |
| HiGHS (free, fast LP solver) | Supported but verbose | First-class citizen |
| Model build for 1M constraints | Minutes | Seconds |

These advantages are real and significant — for linear models. For OPEN-PROM,
they are irrelevant because the model **cannot be expressed** in Linopy's
framework at all.

### Conclusion

**Linopy is rejected.** The correct path is to keep Pyomo (which fully supports
NLP via Ipopt) and optimize its performance through the four phases described
below: NL writer v2, vectorized data loading, persistent solver interface, and
(optionally) the kernel API.

---

## Table of Contents

1. [Current Performance Baseline](#1-current-performance-baseline)
2. [Phase 1 — AMPL NL Writer v2](#2-phase-1--ampl-nl-writer-v2)
3. [Phase 2 — Vectorized Param Construction](#3-phase-2--vectorized-param-construction)
4. [Phase 3 — Persistent Solver Interface](#4-phase-3--persistent-solver-interface)
5. [Phase 4 — Pyomo Kernel API Migration](#5-phase-4--pyomo-kernel-api-migration)
6. [Implementation Order & Dependencies](#6-implementation-order--dependencies)
7. [Risk Assessment](#7-risk-assessment)
8. [Appendix: Code Patterns to Change](#appendix-code-patterns-to-change)

---

## 1. Current Performance Baseline

### Model Size (production config: DEU, 2024–2100, yearly timestep)

| Component          | Declarations | Approx. instantiated objects |
|--------------------|-------------|-------------------------------|
| Params (`m.i*`)    | 177         | ~500K mutable Param entries    |
| Vars (`m.V*`)      | 158         | ~400K Var entries              |
| Constraints (`m.Q*`)| 150        | ~200K active + millions skipped|
| Objective          | 1           | 1                             |
| Solve years        | **77**      | **77 NL file generations**     |

> **Note**: OPEN-PROM solves one NLP per year with a yearly timestep from the
> base year (typically 2024) through 2100. All estimates below use **77 solves**
> as the baseline, not the PoC default of 7.

### Where Time Is Spent 

| Phase                        | Est. share | Bottleneck                                       |
|------------------------------|-----------|--------------------------------------------------|
| Data loading (CSV → Param)   | ~10%      | 33× `df.iterrows()` + per-element `m.param[k]=v` |
| Model construction (Pyomo)   | ~10%      | Python-object-per-component overhead (one-time)   |
| NL file generation (×77)     | **~40%**  | Full model serialization each `opt.solve()` call  |
| Ipopt solve (×77)            | ~35%      | Actual NLP solving (cannot be reduced in Python)  |
| Postsolve (`.fix()` loops ×77)| ~5%      | Python loops over index sets                      |

> With 77 solves, the per-solve overhead (NL write + Ipopt) dominates.
> Phases 1 and 3 are therefore the highest-impact optimizations.

### Current Anti-Patterns Found

| Pattern | Location | Count | Impact |
|---------|----------|-------|--------|
| `df.iterrows()` for CSV parsing | All `input_loader.py` files | 33 calls | ~100× slower than vectorized |
| `Param(initialize={})` then per-element set | All `declarations.py` | 177 Params | Double construction cost |
| `Constraint(full_cross_product, rule=skip)` | All `equations.py` | 150 constraints | Millions of wasted `Constraint.Skip` evaluations |
| `SolverFactory("ipopt")` (non-persistent) | `run_poc.py` L126 | 1 | NL file rebuilt from scratch every solve |
| No warm-start between years | `run_poc.py` L157 | per solve | Ipopt starts from scratch each year |
| Redundant index checks in rules | All `equations.py` | ~150 rules | `y not in time_set` checked despite indexing over `ytime` |

---

## 2. Phase 1 — AMPL NL Writer v2

### What It Is

Pyomo 6.7+ ships a rewritten NL file writer (`pyomo.repn.plugins.nl_writer`) that replaces the legacy ASL writer. It is **5–10× faster** at serializing the Pyomo model into the `.nl` format that Ipopt reads. This is a **zero-code-change** optimization — you just tell Pyomo to use the new writer.

### Why It Matters

NL file generation happens **every** `opt.solve()` call. With 77 solve years (and up to 4 retry attempts each), that's **77–308 serializations** per run. The current writer traverses every Pyomo component through Python. The v2 writer uses compiled expression walkers and batched I/O.

### Implementation

#### Step 1: Verify Pyomo version

```python
import pyomo
print(pyomo.__version__)  # Must be ≥ 6.7.0
```

#### Step 2: Enable v2 writer in `run_poc.py`

```python
# Current (line ~126):
opt = SolverFactory("ipopt")

# New:
opt = SolverFactory("ipopt")
opt.options["writer"] = "nl_v2"  # Use AMPL NL writer v2
```

Alternatively, set the writer globally before any solve:

```python
from pyomo.repn.plugins.nl_writer import NLWriter
# The v2 writer auto-registers in Pyomo ≥ 6.7; SolverFactory will pick it up
# if you pass: opt.solve(m, io_options={"nlp_v2": True})
```

The cleanest approach with modern Pyomo (6.8+):

```python
res = opt.solve(m, tee=True, options=IPOPT_OPTIONS, io_options={"writer": "nl_v2"})
```

#### Step 3: Validate output

Compare `.nl` file sizes and solve results between old and new writers — they should be byte-equivalent for well-formed models.

### Estimated Impact

| Metric | Before | After |
|--------|--------|-------|
| NL write time per solve | ~15–30s | ~2–5s |
| Total NL write (77 years) | ~20–40 min | ~2.5–6.5 min |

### Effort: **2 hours** (change + validation)

### Risk: **Very low** — drop-in replacement, no model changes.

---

## 3. Phase 2 — Vectorized Param Construction

### What It Is

Replace the current two-step pattern (declare empty Param → loop to assign) with a single-step construction using `initialize=data_dict` from vectorized pandas operations.

### Current Pattern (all 177 Params)

```python
# declarations.py — Step 1: empty Param
m.imElastA = Param(
    run_cy, sbs, core_sets.ETYPES, ytime,
    mutable=True, default=0.5, initialize={},
)

# input_loader.py — Step 2a: row-by-row CSV parsing
for _, row in df.iterrows():
    cy = row["allCy"]
    sbs = row["SBS"]
    for ycol in year_cols:
        out[(cy, sbs, etype, int(ycol))] = float(row[ycol])

# input_loader.py — Step 2b: per-element assignment
for key, val in data["imElastA"].items():
    if len(key) == 4 and key[0] in run_cy and key[3] in ytime:
        m.imElastA[key] = val
```

### Target Pattern

```python
# input_loader.py — Step 1: vectorized CSV → dict (replaces iterrows)
def csv_to_param_dict(filepath, index_cols, year_cols):
    """Convert wide-format CSV to {(idx..., year): value} dict, vectorized."""
    df = pd.read_csv(filepath)
    df_long = df.melt(
        id_vars=index_cols,
        value_vars=year_cols,
        var_name="YTIME",
        value_name="value",
    )
    df_long["YTIME"] = df_long["YTIME"].astype(int)
    # Build tuple index → float dict in one pass (no iterrows)
    idx = [df_long[c] for c in index_cols] + [df_long["YTIME"]]
    return dict(zip(zip(*idx), df_long["value"].values))

# declarations.py — Step 2: construct with data (replaces empty init + loop assign)
data_dict = csv_to_param_dict("iElastA.csv", ["allCy", "SBS", "ETYPE"], year_cols)
m.imElastA = Param(
    run_cy, sbs, core_sets.ETYPES, ytime,
    mutable=True, default=0.5,
    initialize=data_dict,  # ← one-shot construction
)
```

### Detailed Changes

#### A. Create `core/data_utils.py` — shared vectorized CSV reader

```python
"""Vectorized CSV-to-dict utilities for Param initialization."""
import pandas as pd
from typing import Dict, List, Tuple, Any

def wide_csv_to_dict(
    filepath: str,
    index_cols: List[str],
    year_range: Tuple[int, int] = None,
) -> Dict[tuple, float]:
    """
    Read a wide-format CSV (index columns + year columns) and return
    a {(idx1, idx2, ..., year): value} dict.

    Uses pd.melt (vectorized) instead of iterrows.
    ~100× faster for typical OPEN-PROM data files.
    """
    df = pd.read_csv(filepath)
    # Identify year columns (all-digit column names)
    year_cols = [c for c in df.columns if c not in index_cols and str(c).isdigit()]
    if year_range:
        year_cols = [c for c in year_cols if year_range[0] <= int(c) <= year_range[1]]

    df_long = df.melt(id_vars=index_cols, value_vars=year_cols,
                      var_name="_year", value_name="_val")
    df_long["_year"] = df_long["_year"].astype(int)
    df_long = df_long.dropna(subset=["_val"])

    cols = index_cols + ["_year"]
    keys = list(zip(*(df_long[c] for c in cols)))
    vals = df_long["_val"].values
    return dict(zip(keys, vals))


def long_csv_to_dict(
    filepath: str,
    index_cols: List[str],
    value_col: str = "value",
) -> Dict[tuple, float]:
    """Read a long-format CSV and return a {(idx1, idx2, ...): value} dict."""
    df = pd.read_csv(filepath)
    df = df.dropna(subset=[value_col])
    keys = list(zip(*(df[c] for c in index_cols)))
    vals = df[value_col].values
    return dict(zip(keys, vals))
```

#### B. Refactor each `input_loader.py`

For each of the 11 module input loaders + core input loader:

1. Replace `df.iterrows()` with `wide_csv_to_dict()` or `long_csv_to_dict()`
2. Return pre-built dicts in the `load_*_data()` functions

#### C. Refactor each `declarations.py` / `load_*_data_into_model()`

Two possible approaches:

**Option A — Keep current architecture** (declarations separate from data):
- Keep `Param(initialize={})` in declarations
- Replace per-element `m.param[key] = val` loops with bulk `m.param._data.update(data_dict)` (Pyomo internal, version-dependent)
- Simpler but less clean

**Option B — Merge data into construction** (recommended):
- Pass data dicts to `add_*_parameters()` functions
- Use `Param(initialize=data_dict)` directly
- Requires adjusting `build_model.py` to load data before declarations
- Cleaner but bigger refactor

Recommended: **Option A first**, then migrate to Option B incrementally.

#### D. Refactor `build_model.py` assembly order (for Option B)

```python
# Current order:
# 1. Declarations (empty Params)
# 2. Equations
# 3. Load data → assign to Params
# 4. Preloop

# New order (Option B):
# 1. Load data (CSV → dicts)
# 2. Declarations (Params with initialize=data_dict)
# 3. Equations
# 4. Preloop
```

### Files to Modify

| File | Changes |
|------|---------|
| `core/data_utils.py` | **NEW** — shared vectorized CSV reader |
| `core/input_loader.py` | Replace iterrows (8 Params) |
| `modules/_01_Transport/simple/input_loader.py` | Replace iterrows |
| `modules/_02_Industry/technology/input_loader.py` | Replace iterrows |
| `modules/_03_RestOfEnergy/legacy/input_loader.py` | Replace iterrows |
| `modules/_04_PowerGeneration/simple/input_loader.py` | Replace iterrows |
| `modules/_05_Hydrogen/legacy/input_loader.py` | Replace iterrows |
| `modules/_06_CO2/legacy/input_loader.py` | Replace iterrows |
| `modules/_07_Emissions/legacy/input_loader.py` | Replace iterrows |
| `modules/_08_Prices/legacy/input_loader.py` | Replace iterrows |
| `modules/_09_Heat/heat/input_loader.py` | Replace iterrows |
| `modules/_10_Curves/LearningCurves/input_loader.py` | Replace iterrows |
| `modules/_11_Economy/economy/input_loader.py` | Replace iterrows |

### Estimated Impact

| Metric | Before | After |
|--------|--------|-------|
| CSV parsing (all files) | ~30–60s | ~1–3s |
| Param population | ~20–40s | ~5–10s (or near-zero with Option B) |
| Total data loading | ~60–90s | ~5–15s |

### Effort: **2–3 days** (12 loader files + `data_utils.py` + testing)

### Risk: **Low** — data values unchanged, just faster construction paths. Test by comparing Param values before/after.

---

## 4. Phase 3 — Persistent Solver Interface

### What It Is

Pyomo's `PersistentSolver` interface keeps the solver's internal representation of the model alive between solves. Instead of regenerating the full `.nl` file each time, you:

1. Build the solver's internal model once (`opt.set_instance(m)`)
2. Between solves, only communicate **changes** (`.fix()`, `.unfix()`, updated Param values)
3. The solver sees an incremental update, not a full model rebuild

For Ipopt this uses the `CyIpopt` or the AMPL Solver Library (ASL) persistent interface.

### Why It Matters

In the multi-year solve loop, between year `t` and year `t+1`, only a few things change:
- Some variables get `.fix()`-ed to their solved values (postsolve)
- Time-dependent parameters may be updated
- The structural model (constraints, variables, index sets) stays **identical**

Currently, every `opt.solve(m)` call regenerates the entire NL file (~200K+ constraints). With persistent, only the delta is communicated.

### Implementation

#### Step 1: Check availability

```python
from pyomo.environ import SolverFactory
opt = SolverFactory("ipopt_persistent")
print(opt.available())  # True if cyipopt is installed
```

If `ipopt_persistent` is not available, install `cyipopt`:

```bash
conda install -c conda-forge cyipopt
# or
pip install cyipopt
```

#### Step 2: Modify `run_poc.py` — solver setup

```python
# Current:
opt = SolverFactory("ipopt")

# New:
opt = SolverFactory("ipopt_persistent")
opt.set_instance(m)  # One-time: build the solver's internal representation
```

#### Step 3: Modify `run_poc.py` — solve loop

```python
# Current solve loop:
for year in core_sets.an:
    res = opt.solve(m, tee=True, options=IPOPT_OPTIONS)
    # ... postsolve (.fix) ...

# New solve loop:
for year in core_sets.an:
    # Communicate variable fixes from postsolve to the solver
    # (This is automatic for .fix()/.unfix() with persistent solver)
    res = opt.solve(tee=True, options=IPOPT_OPTIONS)  # No 'm' argument
    # ... postsolve (.fix) ...
    # After .fix() calls, update the solver:
    for var_data in changed_vars:
        opt.update_var(var_data)  # Incremental update
```

#### Step 4: Handle postsolve `.fix()` → solver update

The key challenge: when postsolve calls `m.V01StockPcYearly[cy, y].fix(val)`, the persistent solver must be told about it. Two approaches:

**Approach A — Batch update after postsolve** (simpler):

```python
# After all postsolve functions run:
opt.set_instance(m)  # Rebuild — but persistent makes this faster than NL regen
```

This is simpler but loses some benefit. Still faster than non-persistent because the solver's internal data structures are reused.

**Approach B — Granular updates** (faster, more complex):

```python
# Modify postsolve functions to return changed var indices
# Then:
for var_data in changed_indices:
    opt.update_var(var_data)
```

Recommended: **Start with Approach A**, profile, then migrate to Approach B if needed.

#### Step 5: Add warm-starting (complementary optimization)

```python
IPOPT_OPTIONS = {
    "max_iter": 10000,
    "nlp_scaling_method": "gradient-based",
    "tol": 1e-6,
    "acceptable_tol": 1e-4,
    "acceptable_iter": 5,
    "warm_start_init_point": "yes",          # NEW
    "warm_start_bound_push": 1e-6,           # NEW
    "warm_start_bound_frac": 1e-6,           # NEW
    "warm_start_slack_bound_push": 1e-6,     # NEW
    "warm_start_slack_bound_frac": 1e-6,     # NEW
    "warm_start_mult_bound_push": 1e-6,      # NEW
}
```

Warm-starting tells Ipopt to use the previous solution as the starting point for the next year's solve. Since consecutive years have similar solutions, Ipopt converges in fewer iterations.

### Estimated Impact

| Metric | Before | After |
|--------|--------|-------|
| Per-solve Python overhead | ~15–30s (NL write) | ~1–5s (incremental) |
| Ipopt iterations (warm-start) | ~200–500 | ~50–150 |
| Total 77-year solve time | ~50–100 min | ~10–25 min |

### Effort: **1–2 days** (solver swap + postsolve integration + warm-start)

### Risk: **Medium**

- `cyipopt` may have installation issues on Windows (conda recommended)
- Persistent solver API is Pyomo-version-sensitive (test with specific version)
- Warm-start can cause convergence issues if the step between years is too large — add fallback to cold-start on retry

### Fallback

If persistent solver proves unstable, keep standard `SolverFactory("ipopt")` with only warm-start + NL writer v2 — still a significant speedup.

---

## 5. Phase 4 — Pyomo Kernel API Migration

### What It Is

The Pyomo kernel API (`pyomo.core.kernel`) is a lightweight alternative to the standard `ConcreteModel` / `AbstractModel` APIs. It uses simpler Python objects with less overhead:

| Standard API | Kernel API |
|---|---|
| `ConcreteModel()` | `block()` |
| `Var(index, domain, bounds)` | `variable_dict` / `variable_list` |
| `Param(index, mutable, default)` | `parameter_dict` / plain Python dict |
| `Constraint(index, rule=fn)` | `constraint_dict` with explicit expressions |
| `Objective(expr=...)` | `objective(expr=...)` |

The kernel objects have **~3× less memory overhead** and **~3× faster construction** because they skip:
- Hierarchical component registration
- Automatic name management
- Abstract/concrete distinction plumbing
- Slack variable machinery for constraints

### Why It Matters

With 177 Params (~500K entries), 158 Vars (~400K entries), and 150 Constraints (~200K+ active), the standard Pyomo component overhead is significant. Each `Var` entry is a full `_VarData` Python object (~600 bytes). Kernel `variable` objects are ~200 bytes.

### Why This is Phase 4 (Last)

This is the **highest-effort, highest-risk** optimization. It requires touching virtually every file in the codebase. It should only be done after Phases 1–3 have been delivered and profiled. If Phases 1–3 provide sufficient speedup, Phase 4 may not be needed.

### Migration Strategy

#### A. New base: `pyomo.core.kernel.block`

```python
# Current:
from pyomo.core import ConcreteModel
m = ConcreteModel(name="openprom")

# Kernel:
from pyomo.core.kernel.block import block
m = block()
m.name = "openprom"
```

#### B. Variables: `variable_dict` instead of `Var`

```python
# Current:
from pyomo.core import Var
from pyomo.environ import Reals
m.V01StockPcYearly = Var(run_cy, ytime, domain=Reals, bounds=(0, None), initialize=0.0)

# Kernel:
from pyomo.core.kernel.variable import variable, variable_dict
m.V01StockPcYearly = variable_dict()
for cy in run_cy:
    for y in ytime:
        m.V01StockPcYearly[cy, y] = variable(lb=0, value=0.0)
```

Note: Kernel variables don't support `domain=Reals` — use `lb`/`ub` instead. `Reals` with `bounds=(0, None)` becomes `lb=0`.

However, for performance, batch-create from a generator:

```python
m.V01StockPcYearly = variable_dict(
    ((cy, y), variable(lb=0, value=0.0))
    for cy in run_cy for y in ytime
)
```

#### C. Parameters: plain Python dicts

The kernel API does not have a `Param` equivalent. Use plain `dict` objects:

```python
# Current:
m.imElastA = Param(run_cy, sbs, etypes, ytime, mutable=True, default=0.5, initialize={})

# Kernel: just a dict attached to the block
m.imElastA = {}  # or defaultdict(lambda: 0.5)
m.imElastA_default = 0.5

# Access in constraints:
def get_param(d, key, default=0.0):
    return d.get(key, default)
```

This is the **most disruptive change** — every constraint rule that accesses `mod.imElastA[cy, sbs, etype, y]` must be updated to use dict `.get()` instead of Pyomo Param indexing.

#### D. Constraints: `constraint_dict` with explicit expressions

```python
# Current:
def _q01_lft_rule(mod, cy, tech, y):
    if cy not in run_cy or y not in time_set:
        return Constraint.Skip
    return mod.VmLft[cy, "PC", tech, y] == 1.0 / mod.V01RateScrPc[cy, tech, y]
m.Q01Lft = Constraint(run_cy, ttech, ytime, rule=_q01_lft_rule)

# Kernel:
from pyomo.core.kernel.constraint import constraint, constraint_dict
m.Q01Lft = constraint_dict()
for cy in run_cy:
    for tech in ttech:
        for y in time_set:  # Only valid years — no Skip needed
            if ("PC", tech) not in core_sets.SECTTECH:
                continue
            m.Q01Lft[cy, tech, y] = constraint(
                m.VmLft[cy, "PC", tech, y] == 1.0 / m.V01RateScrPc[cy, tech, y]
            )
```

Benefits:
- No `Constraint.Skip` overhead (only valid indices are created)
- No rule-function-call overhead per index
- Explicit control over what gets built

#### E. Objective

```python
# Current:
from pyomo.core import Objective, minimize
m.obj = Objective(expr=m.vDummyObj, sense=minimize)

# Kernel:
from pyomo.core.kernel.objective import objective, minimize
m.obj = objective(m.vDummyObj, sense=minimize)
```

### Migration Path (Incremental)

Do NOT do a big-bang migration. Instead:

| Step | Scope | Effort |
|------|-------|--------|
| 4a | Replace `ConcreteModel` with `block` | 1 day |
| 4b | Convert core Vars to `variable_dict` | 2 days |
| 4c | Convert core Params to plain dicts | 2 days |
| 4d | Convert core Constraints to `constraint_dict` | 2 days |
| 4e | Module 01_Transport: full kernel migration | 2 days |
| 4f | Remaining 10 modules (batch) | 5–8 days |
| 4g | Integration testing + solver validation | 2 days |

### Estimated Impact

| Metric | Before (standard) | After (kernel) |
|--------|-------------------|----------------|
| Model build time | ~30–60s | ~10–20s |
| Memory usage | ~2–4 GB | ~0.7–1.5 GB |
| Constraint construction | ~15–30s | ~5–10s |

### Effort: **3–4 weeks** (full migration)

### Risk: **High**

- **Solver compatibility**: Not all solver interfaces support kernel blocks. Ipopt via ASL does. Persistent solver interface does **not** support kernel (as of Pyomo 6.8). This means Phase 3 and Phase 4 may be **mutually exclusive** with current Pyomo versions.
- **API stability**: Kernel API is less documented than standard API. Some edge cases may not be covered.
- **Testing burden**: Every constraint, every Param access, every Var reference must be validated.
- **Team familiarity**: Requires all contributors to learn a different API.

### Decision Point

**After completing Phases 1–3, profile the model.**

| If... | Then... |
|-------|---------|
| Phases 1–3 bring total run under target | Skip Phase 4 |
| Model build is still >50% of runtime | Do Phase 4a–4d (core only) |
| Memory is the bottleneck (large multi-country runs) | Do full Phase 4 |
| Persistent solver (Phase 3) is needed | **Do NOT do Phase 4** (incompatible) |

---

## 6. Implementation Order & Dependencies

```
Phase 1 (NL Writer v2)          ← Start here: zero risk, immediate payoff
   │
   ├─ No dependencies
   │
Phase 2 (Vectorized Params)     ← Independent of Phase 1, can parallelize
   │
   ├─ Creates core/data_utils.py (shared utility)
   │  
Phase 3 (Persistent Solver)     ← Depends on Phase 1 (NL writer must work)
   │                              Requires cyipopt installation
   │
   ├─ Warm-start (sub-task of Phase 3, independent benefit)
   │
Phase 4 (Kernel API)            ← ONLY if Phases 1–3 insufficient
                                  ⚠️ MUTUALLY EXCLUSIVE with Phase 3
                                     (persistent solver)
```

### Recommended Timeline

| Phase | Duration | Prerequisites | Can Parallelize With |
|-------|----------|---------------|---------------------|
| 1 | 2 hours | Pyomo ≥ 6.7 | — |
| 2 | 2–3 days | pandas | Phase 1 |
| 3 | 1–2 days | cyipopt, Phase 1 done | Phase 2 |
| 4 | 3–4 weeks | Decision point after 1–3 | Nothing |

### Go/No-Go Checkpoints

- **After Phase 1**: Measure NL write time reduction across a 77-year run. Expected: 5–10× per write → **~15–35 min saved**.
- **After Phase 2**: Measure data loading time. Expected: 10–100× → **~1–2 min saved** (one-time).
- **After Phase 3**: Measure total 77-year solve-loop time. Expected: 2–5× on top of Phase 1 → **~30–75 min saved**.
- **Decision on Phase 4**: Only proceed if cumulative Phases 1–3 leave model build as the bottleneck.

---

## 7. Risk Assessment

| Risk | Phase | Likelihood | Impact | Mitigation |
|------|-------|-----------|--------|------------|
| NL v2 writer produces different results | 1 | Very Low | Low | Compare .nl files, compare solutions |
| Vectorized loader misparses edge-case CSV | 2 | Low | Medium | Unit-test each loader, compare param dicts |
| cyipopt install fails on Windows | 3 | Medium | Medium | Use conda-forge; fallback to standard solver + warm-start |
| Persistent solver API changes between Pyomo versions | 3 | Medium | Medium | Pin Pyomo version; add version check |
| Warm-start causes Ipopt divergence | 3 | Low | Low | Fallback to cold-start on retry (already have retry loop) |
| Kernel API incompatible with persistent solver | 4 | **Certain** | **High** | Do NOT combine Phase 3 and Phase 4 |
| Kernel migration introduces subtle constraint bugs | 4 | Medium | High | Incremental migration with regression tests per module |

---

## Appendix: Code Patterns to Change

### A. Files with `df.iterrows()` (Phase 2)

```
openprom_py/core/input_loader.py                         — 8 occurrences
openprom_py/modules/_01_Transport/simple/input_loader.py — 3 occurrences
openprom_py/modules/_02_Industry/technology/input_loader.py
openprom_py/modules/_03_RestOfEnergy/legacy/input_loader.py
openprom_py/modules/_04_PowerGeneration/simple/input_loader.py — 5 occurrences
openprom_py/modules/_05_Hydrogen/legacy/input_loader.py
openprom_py/modules/_06_CO2/legacy/input_loader.py
openprom_py/modules/_07_Emissions/legacy/input_loader.py
openprom_py/modules/_08_Prices/legacy/input_loader.py
openprom_py/modules/_09_Heat/heat/input_loader.py
openprom_py/modules/_10_Curves/LearningCurves/input_loader.py
openprom_py/modules/_11_Economy/economy/input_loader.py
Total: 33 iterrows() calls to replace
```

### B. Solver setup (Phase 3)

```
openprom_py/run_poc.py — Lines 59–65 (IPOPT_OPTIONS), 126 (SolverFactory), 157 (opt.solve)
```

### C. Constraint rules with redundant index checks (Phase 2 bonus)

```
All equations.py files — 150 constraint rules with `if cy not in run_cy` checks
that can be eliminated by constructing over valid index subsets only.
```

### D. Core declarations to migrate (Phase 4)

```
openprom_py/core/declarations.py       — 177 Params, 158 Vars  (lines 1–360)
openprom_py/core/equations.py          — core objective + calibration constraints
openprom_py/build_model.py             — ConcreteModel construction
openprom_py/run_poc.py                 — solver interface
+ 11 module declarations.py files
+ 11 module equations.py files
```
