## First OPEN-PROM run with dummy data

**Objective**

This tutorial is for external users who want to verify that OPEN-PROM runs on their machine before they have access to real input data. It uses a public dummy dataset and runs only the `RWO` region.

This tutorial assumes that you have at least completed the basic software setup from Tutorial 03. In practice, you need a working `Rscript` command, a working `gams` command, and the R packages required by `loadMadratData.R`.

If you later experiment with `start.R` or the VS Code Task Runner instead of the direct GAMS command below, first open `start.R` and set:

```r
withSync <- FALSE
```

This dummy-data path does not use the normal internal sync workflow, and leaving `withSync <- TRUE` can make `syncRun()` stop the wrapper when `model_runs_path` is not configured.

## 1. Download the dummy data

Run the dummy-data loader once:

```bash
Rscript loadMadratData.R DevMode=2
```

This downloads `dummy_data.tgz` from Google Drive and extracts it into `./data`. It does **not** create `./targets`, so it cannot be used for calibration or any workflow that depends on targets.

## 2. Run the model

After `./data` exists, start OPEN-PROM directly with GAMS:

```bash
gams main.gms --DevMode=1 --GenerateInput=off --fCountries='RWO' -Idir=./data
```

This is the cleanest first run for external users:

* `--DevMode=1` selects the development-size region set
* `--GenerateInput=off` tells GAMS to use the already extracted dummy `data/`
* `--fCountries='RWO'` restricts the run to the single public dummy region

Do not treat this as the internal Task Runner workflow. `DevMode=2` is only for the public dummy-data path, and it is not the same as the internal task modes described in Tutorial 05.

## 3. What to expect

If the run is configured correctly, GAMS will solve the model for `RWO` and write the usual model outputs in the current working directory. Typical files to check are:

* `modelstat.txt`
* `outputData.gdx`
* the standard listing and log files produced by GAMS

If you later want to understand the internal workflow, data generation, or task modes, continue with Tutorial 05.
