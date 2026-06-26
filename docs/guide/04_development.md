# Development and code structure

:::{note}
**In brief** — A developer's map of the GAMS codebase: how the source is split between the shared `core/` and the
`modules/NN_Name/` folders, how `main.gms` assembles the model phase by phase and fans each phase out to every
module, how a module's behaviour is selected through realizations, and the object-naming convention you must follow.
It closes with the FIXME-comment workflow for turning code notes into tracked issues.
:::

OPEN-PROM is a recursive, modular energy-system model written in GAMS. This page is the practical view of how that
code is laid out and assembled; it is not a description of the model's economics or equations.

:::{seealso}
For the science — what the model represents, the gap-and-substitution mechanism, sectors, prices and supply — see
{doc}`/model/02_model_overview`.
:::

## Folder structure

The codebase is organised around two directories.

**`core/`** holds the shared backbone used by every run. Its files are named for the assembly **phases** they
contribute to:

| File | Role |
|---|---|
| `sets.gms` | sets for years, countries, technologies and other key dimensions |
| `declarations.gms` | declares variables, parameters and scalars |
| `input.gms` | reads and prepares input data for the equation system |
| `equations.gms` | core equations (including `qDummyObj`, see below) |
| `preloop.gms` | bounds, initial values and runtime settings before solving |
| `solve.gms` | the recursive solve loop (years, countries, solver attempts) |
| `postsolve.gms` | post-processing, output writing, and fixing solved values to carry into the next year |

**`modules/NN_Name/`** holds the sector and cross-sector modules, each in its own numbered subfolder:

:::{list-table}
:header-rows: 1

* - Module
  - Module
* - `01_Transport`
  - `07_Emissions`
* - `02_Industry`
  - `08_Prices`
* - `03_RestOfEnergy`
  - `09_Heat`
* - `04_PowerGeneration`
  - `10_Curves`
* - `05_Hydrogen`
  - `11_Economy`
* - `06_CO2`
  -
:::

The global dispatcher that assembles all modules is `modules/include.gms`, located in the top-level `modules/`
directory.

## The phase system

`main.gms` does **not** assemble one complete module at a time. It builds the model **phase by phase**, in this
order:

```
sets → declarations → input → equations → preloop → solve → postsolve
```

For each phase, `main.gms` first includes the `core/` file for that phase, then calls `modules/include.gms`, which
fans the same phase out to every module via `$batinclude`. Each module realization then includes only the file that
matches the current phase.

The key mental model: **the hierarchy is phase-based, not sector-based.** `main.gms` selects a phase,
`modules/include.gms` propagates it, and every active realization contributes its slice of that phase. A `phase` is
a code-assembly concept, not a model-year concept.

:::{tip}
Keep the two kinds of "loop" distinct. The phase order above is how the *code* is assembled at compile time. At run
time the model iterates an **outer loop over years**, a **middle loop over countries/regions**, and an **inner loop
over solver attempts** — that is where the recursive, year-by-year solve actually happens.
:::

The **solve** phase deserves a closer look. The solver call in `core/solve.gms` is:

```text
solve openprom using nlp minimizing vDummyObj;
```

In a normal run the equation `qDummyObj` simply fixes `vDummyObj = 1`: the NLP solver is used because the equation
system is nonlinear, not because the model minimises a planner objective — the solve is searching for a numerically
closed, feasible system for the active year and region. In calibration mode (`Calibration=MatCalibration`) the same
`qDummyObj` becomes a real fitting objective: selected maturity-related parameters become decision variables and the
solve minimises the mismatch between model outputs and calibration targets. The model structure is unchanged; only
the objective the solve is pointed at differs.

## Modules and realizations

Each module folder contains:

- `module.gms` — selects the active **realization** for that module via a global switch and conditional includes;
- one or more **realization subfolders** (e.g. `legacy`, `simple`, `technology`, `heat`, `economy`,
  `LearningCurves`);
- inside each realization, the per-phase files (`declarations.gms`, `equations.gms`, `input.gms`, `preloop.gms`,
  `postsolve.gms`) plus a `realization.gms` that dispatches on the active `phase`.

Not every module offers the same realization names. For example, Transport switches between `legacy` and `simple`,
Industry between `legacy` and `technology`, PowerGeneration between `legacy` and `simple`, while Heat uses `heat`,
Economy uses `economy`, and Curves uses `LearningCurves`.

The active realizations in the current default setup are:

| Module | Realization | Module | Realization |
|---|---|---|---|
| Transport | `simple` | Emissions | `legacy` |
| Industry | `technology` | Prices | `legacy` |
| RestOfEnergy | `legacy` | Heat | `heat` |
| PowerGeneration | `simple` | Curves | `off` |
| Hydrogen | `legacy` | Economy | `economy` |
| CO2 | `legacy` | | |

To change what a module does, the realization switches are set near the bottom of `main.gms`, under the
"MODULE REALIZATION SWITCHES" header (e.g. `$setGlobal Transport simple`):

- **switch realization** — point the module's global switch at a different existing realization; or
- **edit the active realization** — change the per-phase files inside the realization currently selected.

Edit `module.gms` itself only when adding a brand-new realization (a new subfolder plus a branch in the conditional
include). The same `module.gms` then routes the assembly to the matching phase file via `realization.gms`.

`main.gms` also defines the run-level configuration: solver attempts, research vs development mode, time horizon and
scenario, calibration mode, the active realizations, and country selection through `fCountries`.

## Naming convention

Object names encode their scope through a prefix; follow it for every new object. The type letters are:

- **`Q` / `q`** — equation (capital `Q` = participates in several equations; lowercase `q` = used in only one place);
- **`V` / `v`** — variable (same capitalisation rule);
- **`i`** — input data.

The scope is encoded around the type letter:

- **`Vm` / `im`** — model-wide variable/input, shared across more than one module (declared in `core/`);
- **`Vxx` / `ixx`** — module-specific, where `xx` is the module number (e.g. `V01ActivGoodsTransp`,
  `i04PlantLifetime`);
- **`V` / `i`** — core-only.

Equations must begin with the two-digit module code: `QxxEquationName`. Only promote an object to `Vm`/`im` when it
is genuinely shared by more than one module.

:::{tip}
Both the `core/` layer and the individual modules carry real model logic — modules are not empty wrappers. When
editing, keep model logic separate from the workflow/wrapper logic of the R harness, and document changes thoroughly.
:::

## Developer workflow

Bugs and follow-ups can be tracked directly from the source — **FIXME issues from code comments**: a specially formatted comment is parsed and turned into
a GitHub issue automatically, which keeps the team's workflow streamlined. The comment must start with `FIXME:`,
followed by a short, descriptive summary that becomes the issue title; a second line may assign your GitHub username
to `author` (optional, but strongly encouraged):

```text
* FIXME: This is a test issue that was generated automatically
* author=derevirn
VExportsFake.FX(runCy,EFS,YTIME)$(not IMPEF(EFS)) = 0;
```

A few practical points:

- `FIXME` comments are converted to issues only after a successful pull request is **merged to `main`**.
- The generated issue on the [Issues page](https://github.com/e3modelling/OPEN-PROM/issues) includes a snippet of
  the surrounding code and a link to the file, so the bug is easy to locate.
- Deleting the `FIXME` comment from `main` is meant to close the issue automatically — but this has proven somewhat
  unreliable, so confirm the closure manually.
