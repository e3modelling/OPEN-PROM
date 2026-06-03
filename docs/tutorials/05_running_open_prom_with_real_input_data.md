# 05 Running OPEN-PROM with real input data

## Running OPEN-PROM with real input data

**Objective**

This tutorial is for E3-Modelling internal users who can access the real input data pipeline. It explains how the internal data path works, how `data/` and `targets/` are produced, and how the standard task modes differ.

If you only want to test the model with dummy data, go to Tutorial 04 instead.

## 1. External users vs E3-Modelling users

The repository supports two different onboarding paths:

* External users can run the public dummy-data path only. That path creates `data/`, but not `targets/`, and it is described in Tutorial 04.
* E3-Modelling internal users can prepare real `data/` and `targets/` from the internal `madrat` archive and then use the full task-based workflow described here.

So this tutorial is mainly about the second path.

## 2. Point R to the local `madrat` archive

Before generating real data, make sure your local `madrat` directory is synced from SharePoint or another internal source. Then point R to that local archive:

```r
library(madrat)
setConfig(mainfolder = "/path/to/local/madrat")
```

In the usual setup, `mainfolder` is the only path you need to set explicitly. `madrat` then derives the relevant `sources/`, `output/`, and `cache/` locations from it automatically.
In other words, you normally do not need to point OPEN-PROM to every subfolder separately. You point `madrat` to its main local root, and the rest follows from that.

## 3. How `data/` and `targets/` are created

OPEN-PROM uses `loadMadratData.R` as the bridge between the `mrprom` data pipeline and the model input folders in the repository root.

* `DevMode=0` generates the full research input and the calibration targets.
* `DevMode=1` generates development-size input data for quick runs.
* `DevMode=2` is the public dummy-data path and is not part of the normal internal real-data workflow.

The practical result is:

* development-style real-data generation creates `./data`
* research-style real-data generation creates both `./data` and `./targets`

The underlying script is triggered automatically in the normal workflow when the appropriate task uses `GenerateInput=on`, but you can also run it directly if you want to inspect the generated files yourself.

## 4. Task modes in `start.R`

The standard single-scenario entry point is:

```bash
Rscript start.R task_id=N
```

`start.R` always runs **one** scenario: the one defined in `config.json:scenario`. Edit that block to change what gets run.

For batch sweeps over multiple scenarios, see §5 below.

The main task modes are:

| task_id | Button name | What it does | Main input requirement | Main outputs | Batchable? |
|---------|-------------|--------------|------------------------|--------------|:-:|
| 0 | `OPEN-PROM DEV` | Runs the development model with existing input data | existing `data/` | model run output; `reportOutput.R` runs automatically if `behavior.withRunFolder` and `behavior.withReport` are both `true` in `config.json` | no |
| 1 | `OPEN-PROM DEV NEW DATA` | Rebuilds development input data and then runs the model | internal data access | fresh development `data/` and a model run | no |
| 2 | `OPEN-PROM RESEARCH` | Runs the research model with existing research input data | existing research `data/` | model run output; `reportOutput.R` runs automatically if `behavior.withRunFolder` and `behavior.withReport` are both `true` in `config.json` | **yes** |
| 3 | `OPEN-PROM RESEARCH NEW DATA` | Rebuilds research input data, calibrates maturity factors, then runs the model | internal data access | fresh research `data/`, `targets/`, calibration results, and a model run | no |
| 5 | `CALIBRATE` | Runs calibration only | existing `data/` and `targets/` | calibrated maturity-factor files | no |
| 6 | `CALIBRATE CARBON PRICES` | Runs carbon-price calibration | internal calibration setup | updated carbon-price inputs and, if enabled, a report | no |
| 7 | `OPEN-PROM SOFT-LINK MAgPIE` | Runs the MAgPIE soft-link pipeline (see Tutorial 12) | internal data access + MAgPIE checkout | scenario run with coupled MAgPIE outputs | **yes** |

Task 4 is a debugging path and is not part of the normal run flow.

The easiest way to read this table is:

* `NEW DATA` means the workflow first regenerates model inputs
* `DEV` means the lighter development setup
* `RESEARCH` means the full research setup
* `CALIBRATE` modes are specialized runs and not the usual first step

## 5. Batch mode

When you want to run several scenarios in one go, put a `scenarios.csv` file at the repo root and run:

```bash
Rscript start.R scenarios.csv
```

or click the **RUN BATCH** button in the VS Code Task Runner. The script fails with `Batch CSV not found: scenarios.csv` if the file is missing — batch is always opt-in via that file. Each row produces its own `runs/<scenario_name>_<timestamp>/` folder; rows are processed sequentially inside one R process (no subprocess overhead). Batch supports only `task_id` 2 and 7; other values are rejected per row.

A starter template lives at `scenarios.template.csv`. The minimal required columns are `scenario_name` and `task_id`; everything else is optional.

### 5.1 How each row builds its scenario (merge semantics)

For each row, `start.R` builds a complete scenario object by **deep-merging the CSV row onto `config.json:scenario`**. Two conventions make this work:

1. **Dot-notation column names** map to nested config keys.
   * `gams_flags.fScenario` → `scenario.gams_flags.fScenario`
   * `magpie.existing_prom_run` → `scenario.magpie.existing_prom_run`
2. **Empty cells inherit, filled cells override.** A non-empty cell replaces the value from `config.json:scenario` at the same nested path; an empty cell leaves that path alone, so the row keeps whatever `config.json:scenario` provides as default. The merge is **recursive** — overriding `magpie.existing_prom_run` does not wipe `magpie.project`; only the leaf you wrote in the CSV changes.

Worked example — given `config.json:scenario`:

```json
{
  "scenario_name": "Default",
  "description":   "Default UPTAKE run",
  "gams_flags":    { "fScenario": 200 },
  "magpie":        { "project": "uptake", "existing_prom_run": null }
}
```

and one CSV row:

```csv
scenario_name,task_id,description,gams_flags.fScenario,magpie.existing_prom_run
C600_landHigh,7,UPTAKE C600 landHigh,600,
```

the merged scenario `start.R` runs for this row is:

```jsonc
{
  "scenario_name": "C600_landHigh",        // from CSV
  "task_id":       7,                       // from CSV (also overrides anything else)
  "description":   "UPTAKE C600 landHigh", // from CSV
  "gams_flags":    { "fScenario": 600 },   // CSV overrides 200 -> 600
  "magpie": {
    "project":           "uptake",          // inherited from config (no CSV override)
    "existing_prom_run": null               // CSV cell was empty, inherited
  }
}
```

**Practical implication for "default" values.** Whatever sits in `config.json:scenario` is the **default for every batch row** unless that row overrides it. So put **only project-wide invariants** there (e.g. `magpie.project: "uptake"`, `gams_flags.fScenario: 200` as the most common case). **Do not** put per-run "incidentals" like `magpie.existing_prom_run` in `config.json:scenario` — if you forget to override the column on every row, all of them will silently inherit the same `existing_prom_run` path, every batch row will skip Step 1 and reuse the same OPEN-PROM round-1 result, and they'll all overwrite each other in that one folder. Keep `magpie.existing_prom_run` in `config.json` as `null` and set it on individual CSV rows only when you actually want to resume from a specific path.

**Extensibility — any flag works, no R-code changes needed.** The dot-notation rule above is *generic*: `start.R` does not hard-code any particular column name. Some practical consequences:

* **Any `gams_flags.X` works**, where `X` is any `$setGlobal` / `$evalGlobal` symbol declared in `main.gms` — e.g. `gams_flags.fEndY`, `gams_flags.CountrySolveMode`, `gams_flags.Transport`, `gams_flags.Industry`, `gams_flags.Curves`, etc. Each becomes a `--X=value` CLI flag passed to GAMS.
* **The column does not need to pre-exist in `config.json`.** A CSV column for a key that isn't in `config.json:scenario` simply injects that key for rows where the cell is non-empty. (Putting it in `config.json` only gives it a default for the rows that leave the cell blank.)
* **Column order is irrelevant.** `start.R` reads columns by name, not by position. `gams_flags.fEndY,gams_flags.Transport,…` and `gams_flags.Transport,gams_flags.fEndY,…` behave identically.
* **Adding a flag is a data-only change.** You never edit `start.R` to expose a new flag — add the column, fill the cells you want overridden, leave the rest blank.

Concrete example — sweep across end-year horizon and Transport realization without touching any R code:

```csv
scenario_name,task_id,gams_flags.fScenario,gams_flags.fEndY,gams_flags.Transport
short_simple,2,200,2050,simple
long_simple,2,200,2100,simple
long_legacy,2,200,2100,legacy
```

### 5.2 Gating rows with a `start` column

To skip rows without deleting them from the CSV, add an optional `start` column:

* `1` — run this row
* `0` — skip this row
* anything else (typo, blank cell, `yes`/`no`, etc.) — `start.R` aborts before any scenario runs, listing every offending row

If the `start` column is **absent**, every row runs (backwards-compatible with older CSVs). Validation happens upfront, so a typo on row 8 won't only surface after rows 1–7 have already run.

Example:

```csv
scenario_name,start,task_id,description,gams_flags.fScenario
C200_biolim100,1,2,UPTAKE C200 biolim100,200
C200_landHigh,1,2,UPTAKE C200 landHigh,200
C600_biolim100,0,7,UPTAKE C600 biolim100 -- temporarily off,600
C600_landHigh,1,7,UPTAKE C600 landHigh,600
```

Console output:

```
Skipping row 3 (scenario_name=C600_biolim100): start=0
Loaded 4 row(s) from scenarios.csv, 3 active, 1 skipped
```

The `start` column is stripped before each row's overlay is merged onto `config.json:scenario`, so it does not leak into the scenario object passed to the task body.

## 6. What the outputs mean

When `behavior.withReport: true` in `config.json`, the task body automatically calls `scripts/tasks/reportOutput.R` after task 0, 2, 3, 6 or 7, provided the run-folder workflow is active. That script converts the model output into a MIF report, typically `reporting.mif`. It may also try to create plot files, but PDF generation depends on the local LaTeX/TinyTeX setup.

`outputForProject.mif` is not part of the default workflow. It is only created when project reporting is explicitly enabled.

For a quick success check:

* `modelstat.txt` should show successful model status lines for the solved years and regions
* `outputData.gdx` should exist after a normal model run
* `reporting.mif` only appears when the reporting step actually runs
* if `behavior.withReport: false`, the model can still run successfully even though no MIF or reporting plots are created

So when checking a run, do not confuse “the model solved” with “the full reporting workflow also ran”.
