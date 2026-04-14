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

The standard internal entry point is:

```bash
Rscript start.R task=N
```

The main task modes are:

| task | Button name | What it does | Main input requirement | Main outputs |
|------|-------------|--------------|------------------------|--------------|
| 0 | `OPEN-PROM DEV` | Runs the development model with existing input data | existing `data/` | model run output; `reportOutput.R` runs automatically if `withRunFolder` and `withReport` are enabled |
| 1 | `OPEN-PROM DEV NEW DATA` | Rebuilds development input data and then runs the model | internal data access | fresh development `data/` and a model run |
| 2 | `OPEN-PROM RESEARCH` | Runs the research model with existing research input data | existing research `data/` | model run output; `reportOutput.R` runs automatically if `withRunFolder` and `withReport` are enabled |
| 3 | `OPEN-PROM RESEARCH NEW DATA` | Rebuilds research input data, calibrates maturity factors, then runs the model | internal data access | fresh research `data/`, `targets/`, calibration results, and a model run |
| 5 | `CALIBRATE` | Runs calibration only | existing `data/` and `targets/` | calibrated maturity-factor files |
| 6 | `CALIBRATE CARBON PRICES` | Runs carbon-price calibration | internal calibration setup | updated carbon-price inputs and, if enabled, a report |

Task 4 is a debugging path and is not part of the normal run flow.

The easiest way to read this table is:

* `NEW DATA` means the workflow first regenerates model inputs
* `DEV` means the lighter development setup
* `RESEARCH` means the full research setup
* `CALIBRATE` modes are specialized runs and not the usual first step

## 5. What the outputs mean

When `withReport <- TRUE`, `start.R` automatically calls `reportOutput.R` after task 0, 2, 3, or 6, provided the run-folder workflow is active. That script converts the model output into a MIF report, typically `reporting.mif`. It may also try to create plot files, but PDF generation depends on the local LaTeX/TinyTeX setup.

`outputForProject.mif` is not part of the default workflow. It is only created when project reporting is explicitly enabled.

For a quick success check:

* `modelstat.txt` should show successful model status lines for the solved years and regions
* `outputData.gdx` should exist after a normal model run
* `reporting.mif` only appears when the reporting step actually runs
* if `withReport <- FALSE`, the model can still run successfully even though no MIF or reporting plots are created

So when checking a run, do not confuse “the model solved” with “the full reporting workflow also ran”.
