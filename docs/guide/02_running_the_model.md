# Running the model

:::{note}
**In brief** — This page is the operational how-to for running OPEN-PROM: a first run on public dummy data, the
internal real-data workflow driven by `start.R` task modes (including batch sweeps), and how to change which regions
a run covers. For the conceptual description of the region set itself, see {ref}`regions`.
:::

The entry point for a normal run is always `start.R`, never `gams main.gms` directly: the harness sets up the run
folder, metadata, flags and reporting. The only exception is the dummy-data smoke test below, which calls GAMS
directly so that external users can verify their toolchain before they have access to the internal data pipeline.

(running-first-run)=
## A first run (public dummy data)

This path is for external users who want to confirm that OPEN-PROM runs on their machine before they have real
input data. It uses a public dummy dataset and solves only the single dummy region `RWO`. It assumes a working
`Rscript` command, a working `gams` command, and the R packages required by `loadMadratData.R`.

:::{warning}
The dummy-data path does **not** use the normal internal sync workflow. Before experimenting with `start.R` or the
VS Code Task Runner on this path, set `behavior.withSync` to `false` in `config.json`; otherwise `syncRun()` can
stop the wrapper when `paths.model_runs_path` is not configured.

```json
{
  "behavior": { "withSync": false }
}
```
:::

**1. Download the dummy data.** Run the loader once:

```bash
Rscript scripts/tasks/loadMadratData.R DevMode=2
```

This downloads `dummy_data.tgz` and extracts it into `./data`. It does **not** create `./targets`, so it cannot be
used for calibration or any workflow that depends on targets.

**2. Run the model** directly with GAMS once `./data` exists:

```bash
gams main.gms --DevMode=1 --GenerateInput=off --fCountries='RWO' -Idir=./data
```

- `--DevMode=1` selects the development-size region set.
- `--GenerateInput=off` uses the already-extracted dummy `data/`.
- `--fCountries='RWO'` restricts the run to the single public dummy region.

**3. What to expect.** GAMS solves the model for `RWO` and writes the usual outputs in the current working
directory — typically `modelstat.txt`, `outputData.gdx`, and the standard GAMS listing and log files.

:::{important}
`DevMode=2` is only for the public dummy-data path. It is **not** one of the internal task modes; do not treat this
direct-GAMS call as the Task Runner workflow.
:::

## Running with real input data

This is the E3Modelling internal path, for users who can access the real input-data pipeline. The repository
supports two onboarding paths: external users run the dummy-data path above (creates `data/`, not `targets/`),
while internal users prepare real `data/` and `targets/` from the internal `madrat` archive and then use the full
task-based workflow described here.

### Point R to the local `madrat` archive

Make sure your local `madrat` directory is synced from SharePoint (or another internal source), then point R to
that local archive:

```r
library(madrat)
setConfig(mainfolder = "/path/to/local/madrat")
```

In the usual setup, `mainfolder` is the only path you need to set explicitly: `madrat` derives the relevant
`sources/`, `output/` and `cache/` locations from it automatically. You do not normally point OPEN-PROM at every
subfolder separately.

### How `data/` and `targets/` are created

`loadMadratData.R` is the bridge between the `mrprom` data pipeline and the model input folders at the repository
root. `DevMode` selects what it generates:

- `DevMode=0` — full research input **and** the calibration targets (creates both `./data` and `./targets`).
- `DevMode=1` — development-size input for quick runs (creates `./data` only).
- `DevMode=2` — the public dummy-data path (not part of the internal real-data workflow).

The script is triggered automatically when a task uses `GenerateInput=on`, but you can also run it directly to
inspect the generated files yourself.

:::{seealso}
The input-data pipeline (`mrprom`) and post-processing (`postprom`) are described in {doc}`/guide/03_input_data`,
with the conceptual treatment in {ref}`input-data` and {ref}`postprocessing`.
:::

### Task modes in `start.R`

The standard single-scenario entry point is:

```bash
Rscript start.R task_id=N
```

`start.R` always runs **one** scenario — the one defined in `config.json:scenario`. Edit that block to change what
gets run. The main task modes:

:::{list-table}
:header-rows: 1
:widths: 6 22 30 18 8

* - `task_id`
  - Button name
  - What it does
  - Main input requirement
  - Batchable?
* - 0
  - `OPEN-PROM DEV`
  - Runs the development model with existing input data
  - existing `data/`
  - no
* - 1
  - `OPEN-PROM DEV NEW DATA`
  - Rebuilds development input data, then runs the model
  - internal data access
  - no
* - 2
  - `OPEN-PROM RESEARCH`
  - Runs the research model with existing research input data
  - existing research `data/`
  - **yes**
* - 3
  - `OPEN-PROM RESEARCH NEW DATA`
  - Rebuilds research input data, calibrates maturity factors, then runs the model
  - internal data access
  - no
* - 5
  - `CALIBRATE`
  - Runs calibration only
  - existing `data/` and `targets/`
  - no
* - 6
  - `CALIBRATE CARBON PRICES`
  - Runs carbon-price calibration
  - internal calibration setup
  - no
* - 7
  - `OPEN-PROM SOFT-LINK MAgPIE`
  - Runs the MAgPIE soft-link pipeline
  - internal data access + MAgPIE checkout
  - **yes**
:::

Task 4 is a debugging path and is not part of the normal run flow. A quick way to read the table: `NEW DATA` means
the workflow first regenerates model inputs; `DEV` is the lighter development setup; `RESEARCH` is the full research
setup; `CALIBRATE` modes are specialised runs, not the usual first step.

For tasks 0, 2, 3, 6 and 7, `reportOutput.R` runs automatically when `behavior.withRunFolder` and
`behavior.withReport` are both `true` in `config.json` (see [What the outputs mean](#running-outputs)).

:::{seealso}
The MAgPIE soft-link (task 7) is covered in {doc}`/guide/05_soft_linking`; see also {ref}`magpie-link`.
:::

### Batch mode

To run several scenarios in one go, put a `scenarios.csv` file at the repo root and run:

```bash
Rscript start.R scenarios.csv
```

or click the **RUN BATCH** button in the VS Code Task Runner. The script fails with
`Batch CSV not found: scenarios.csv` if the file is missing — batch is always opt-in via that file. Each row
produces its own `runs/<scenario_name>_<timestamp>/` folder; rows are processed sequentially inside one R process.
Batch supports only `task_id` 2 and 7; other values are rejected per row. A starter template lives at
`scenarios.template.csv`; the minimal required columns are `scenario_name` and `task_id`.

#### How each row builds its scenario (merge semantics)

For each row, `start.R` builds a complete scenario object by **deep-merging the CSV row onto
`config.json:scenario`**. Two conventions make this work:

1. **Dot-notation column names** map to nested config keys — `gams_flags.fScenario` →
   `scenario.gams_flags.fScenario`, `soft_link_magpie.existing_prom_run` →
   `scenario.soft_link_magpie.existing_prom_run`.
2. **Empty cells inherit, filled cells override.** A non-empty cell replaces the value from `config.json:scenario`
   at the same nested path; an empty cell leaves that path alone. The merge is **recursive** — overriding
   `soft_link_magpie.existing_prom_run` does not wipe `soft_link_magpie.project`; only the leaf you wrote in the
   CSV changes.

Worked example — given `config.json:scenario`:

```json
{
  "scenario_name": "Default",
  "description":   "Default UPTAKE run",
  "gams_flags":    { "fScenario": 200 },
  "soft_link_magpie": { "project": "uptake", "existing_prom_run": null }
}
```

and one CSV row:

```text
scenario_name,task_id,description,gams_flags.fScenario,soft_link_magpie.existing_prom_run
C600_landHigh,7,UPTAKE C600 landHigh,600,
```

the merged scenario `start.R` runs is:

```text
{
  "scenario_name": "C600_landHigh",        // from CSV
  "task_id":       7,                       // from CSV
  "description":   "UPTAKE C600 landHigh",  // from CSV
  "gams_flags":    { "fScenario": 600 },    // CSV overrides 200 -> 600
  "soft_link_magpie": {
    "project":           "uptake",          // inherited from config
    "existing_prom_run": null               // CSV cell empty, inherited
  }
}
```

:::{tip}
Put **only project-wide invariants** in `config.json:scenario` (e.g. `soft_link_magpie.project`, the most common
`gams_flags.fScenario`). Keep per-run incidentals like `soft_link_magpie.existing_prom_run` as `null` and set them
on individual CSV rows only when you want to resume from a specific path — otherwise every row silently inherits the
same path, skips Step 1, reuses the same round-1 result, and overwrites each other in one folder.
:::

The dot-notation rule is **generic** — `start.R` hard-codes no column names, so adding a flag is a data-only change:

- **Any `gams_flags.X` works**, where `X` is any `$setGlobal` / `$evalGlobal` symbol in `main.gms` (e.g.
  `gams_flags.fEndY`, `gams_flags.CountrySolveMode`, `gams_flags.Transport`, `gams_flags.Curves`). Each becomes a
  `--X=value` CLI flag passed to GAMS.
- **The column need not pre-exist in `config.json`.** A column for a key not in `config.json:scenario` injects that
  key for rows where the cell is non-empty.
- **Column order is irrelevant** — columns are read by name, not position.

Beyond `gams_flags.X`, two scenario groups are read specially by `start.R` rather than passed through verbatim:

- **`land_use_emulator.*`** drives the pre-fitted land-use emulator. `start.R` translates
  `land_use_emulator.source` into the `--landUseEmulator=` flag and `land_use_emulator.carbon_price` into
  `--emulatorGHGScen=`. This is the path for **emulator-only runs** (no live MAgPIE coupling): e.g.
  `land_use_emulator.source = globiom` with `land_use_emulator.carbon_price = GHG100`.
- **`soft_link_magpie.*`** configures the task-7 MAgPIE soft-link. This group is **not** turned into GAMS flags by
  the generic dispatcher; task 7 reads it directly (`project`, `existing_prom_run`, `max_iter`, `price_tol`,
  `quant_tol`) and passes `--softLinkMAgPIE` itself. See {doc}`/guide/05_soft_linking`.

Concrete example — sweep end-year horizon and Transport realization with no R-code changes:

```text
scenario_name,task_id,gams_flags.fScenario,gams_flags.fEndY,gams_flags.Transport
short_simple,2,200,2050,simple
long_simple,2,200,2100,simple
long_legacy,2,200,2100,legacy
```

#### Gating rows with a `start` column

To skip rows without deleting them, add an optional `start` column: `1` runs the row, `0` skips it, and anything
else (typo, blank, `yes`/`no`) makes `start.R` abort **before any scenario runs**, listing every offending row.
If the `start` column is absent, every row runs (backwards-compatible). The column is stripped before each row's
overlay is merged, so it never leaks into the scenario object.

```text
scenario_name,start,task_id,description,gams_flags.fScenario
C200_biolim100,1,2,UPTAKE C200 biolim100,200
C200_landHigh,1,2,UPTAKE C200 landHigh,200
C600_biolim100,0,7,UPTAKE C600 biolim100 -- temporarily off,600
C600_landHigh,1,7,UPTAKE C600 landHigh,600
```

```
Skipping row 3 (scenario_name=C600_biolim100): start=0
Loaded 4 row(s) from scenarios.csv, 3 active, 1 skipped
```

(running-outputs)=
### What the outputs mean

When `behavior.withReport: true` (and the run-folder workflow is active), the task body automatically calls
`scripts/tasks/reportOutput.R` after tasks 0, 2, 3, 6 or 7. That script converts the model output into a MIF report,
typically `reporting.mif`. It may also try to create plots, but PDF generation depends on the local LaTeX/TinyTeX
setup. `outputForProject.mif` is not part of the default workflow; it is created only when project reporting is
explicitly enabled.

For a quick success check:

- `modelstat.txt` should show successful model-status lines for the solved years and regions.
- `outputData.gdx` should exist after a normal model run.
- `reporting.mif` only appears when the reporting step actually runs.
- with `behavior.withReport: false`, the model can still solve successfully even though no MIF or plots are created.

Do not confuse "the model solved" with "the full reporting workflow also ran".

## Changing the region set

A run's regions are governed by a **region-mapping CSV** that assigns every world country to one of the 39
OPEN-PROM regions, plus the `fCountries` flag that picks which of those regions to actually solve.

`DevMode` selects which mapping file is used:

- `DevMode=0` (research) → `regionmappingOPDEV5.csv`
- `DevMode=1` (development) → `regionmappingOPDEV4.csv`

The mapping files live in the `mrprom` package under `inst/extdata/regional/`. The research mapping is also
available machine-readably at
<https://raw.githubusercontent.com/e3modelling/mrprom/main/inst/extdata/regional/regionmappingOPDEV5.csv>. In each
file, custom multi-country regions use native region codes (e.g. `CHA` for China and neighbours, `LAM` for Latin
America and the Caribbean, `MEA` for the Middle East and North Africa, `SSA` for Sub-Saharan Africa, `REF` for the
reforming economies of the former Soviet Union, `RWO` as the residual rest-of-world dummy region), while all other
countries are identified by their official three-letter ISO codes.

To **restrict** a run to a subset of regions without editing the mapping, pass `fCountries`:

```bash
# solve only China, Germany, India, the USA and rest-of-world
... --fCountries='CHA,DEU,IND,USA,RWO'
```

`fCountries` defaults to `CHA,DEU,IND,USA,RWO`. To **redefine** which countries belong to a region, edit the
relevant region-mapping CSV (or point to a different mapping file) rather than changing model code.

:::{seealso}
For the full list of the 39 regions, their member countries, and the design rationale behind the regional
aggregation, see {ref}`regions` in the model overview.
:::
