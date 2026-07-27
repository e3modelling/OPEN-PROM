# Input data

:::{note}
**In brief** — This page is the operational how-to for getting OPEN-PROM's input data in place: installing the
software needed by the `mrprom` pipeline, creating your local `config.json`, choosing between the dummy-data and
full-data routes, and refreshing the dataset used by the continuous-integration tests. The *theory* of the data
pipeline (MADRaT, `mrprom` stages, regional aggregation) lives in the model documentation.
:::

OPEN-PROM is fed by input data produced by the complementary [`mrprom`](https://github.com/e3modelling/mrprom)
R package, an independent repository also developed by E3Modelling. The common setup below is shared by external
users and E3Modelling internal users alike. If you only want to test the model with dummy data you do not need the
full real-data setup, but you still need the basic software environment, because the dummy-data first run depends on
R, GAMS, and the `loadMadratData.R` helper script.

:::{seealso}
For the pipeline theory — how `mrprom` reads, harmonises and assembles datasets, and how outputs are validated — see
{ref}`input-data`. For turning a run's GDX into a reporting MIF, see {ref}`postprocessing`.
:::

## Installing the software and libraries

Before using `mrprom` you need a working installation of [R](https://www.r-project.org/) and of GAMS. On Windows you
may also need [Rtools](https://cran.r-project.org/bin/windows/Rtools/) for packages that compile from source. Install
R, GAMS and, where relevant, Rtools in folders that do **not** require admin privileges and that are reachable from
your command line; if you need help adding software to your `PATH`, see example instructions for
[Windows](https://www.bbminfo.com/r/r-programming-environment-setup.php) and
[Linux](https://www.digitalocean.com/community/tutorials/how-to-view-and-update-the-linux-path-environment-variable).
Make sure the `reticulate` library is installed in R. You may need to restart your computer so the updated `PATH` is
visible in a new terminal session.

Once R is set up, launch the R console and run:

```r
options(repos = c(
  pik = "https://pik-piam.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))

install.packages(c(
  "magclass",
  "madrat",
  "gdx",
  "gdxrrw",
  "quitte",
  "mip",
  "piamValidation",
  "mrdrivers",
  "gms"
))

install.packages("remotes")
remotes::install_github("e3modelling/mrprom")
remotes::install_github("e3modelling/postprom")
```

These commands install `mrprom`, `postprom` and the main supporting packages used by the OPEN-PROM workflow;
`remotes` is only a helper so R can install packages directly from GitHub.

If your goal is only the external **dummy-data first run**, the real essentials are smaller:

- a working R installation,
- a working GAMS installation,
- the ability to run `Rscript scripts/tasks/loadMadratData.R DevMode=2`,
- and the R packages that script needs, most notably `dplyr`.

If `gdxrrw` cannot find your GAMS installation automatically — common on macOS and Linux — configure it explicitly in
R:

```r
library(gdxrrw)
gdxrrw::igdx("/path/to/gams/")
```

## Creating the local configuration file

Create a local `config.json` in the root folder of OPEN-PROM. The simplest way is to copy `config.template.json` and
edit the relevant fields. `config.json` has three top-level blocks:

- `paths.*` — machine-specific paths:
  - `paths.gams_path` — the GAMS installation directory, if `gams` is not already on your system `PATH`;
  - `paths.model_runs_path` — the destination used by the optional run-folder sync step;
  - `paths.magpie_path` — only needed for the OPEN-PROM ↔ MAgPIE soft-link (task 7).
- `behavior.*` — four switches controlling the wrapper workflow (see below).
- `scenario.*` — the scenario to run (`scenario_name`, `description`, `gams_flags`, `magpie`). `task_id` is *not*
  stored here — it comes from the CLI (`task_id=N`, passed by every VS Code task button) or, in batch mode, from each
  row of `scenarios.csv`.

:::{tip}
For batch sweeps over multiple scenarios, create a `scenarios.csv` at the repo root (see `scenarios.template.csv`
for the column format) and use `Rscript start.R scenarios.csv` or the **RUN BATCH** VS Code button. Each CSV row
overlays `config.json:scenario` for that one run. The CSV is opt-in: without it, only the single-scenario workflow
(`Rscript start.R task_id=N`) is available.
:::

If you are not working in the internal E3Modelling environment, `model_runs_path` is often not needed immediately. In
that case set the following in `config.json`, which avoids errors at the archive and sync stage when no valid
internal destination has been configured:

```json
{
  "behavior": { "withSync": false }
}
```

**The `config.json:behavior` switches.** OPEN-PROM defines four behaviour switches that modify the workflow
**around** the model run:

- `withRunFolder`
- `withSync`
- `withReport`
- `uploadGDX`

These switches do not change the mathematical model itself. They control the wrapper workflow — whether a run folder
is created, whether outputs are archived, and whether the reporting script runs automatically. The various task
modes available through VS Code and `start.R` are explained in the running and development guides.

## Adding the data sources

The model also needs access to the right data sources, and this is where external and internal workflows diverge.

- **E3Modelling internal users** point `madrat` (see the
  [madrat vignette](https://cran.r-project.org/web/packages/madrat/vignettes/madrat.html)) to a locally synced
  internal data directory, together with the SharePoint and `mainfolder` setup. Because those datasets are
  proprietary they cannot be shared publicly; acquire them yourself or contact us for guidance.
- **External users** do not need the full internal data sources to try the model for the first time. The dummy-data
  route downloads a public archive from Google Drive and extracts it locally. That path does not use the full
  internal `mrprom` data pipeline, but it still uses R and the local helper script.

:::{note}
The `mrprom` calc functions generate a large number of datasets from many different sources. For transparency and
reproducibility, the `InputDataOverview.csv` spreadsheet in the tutorials folder lists every generated OPEN-PROM
input parameter together with its original source and a short description.
:::

## Updating the CI dataset

If your branch introduces new data, you must make sure the GitHub automated tests (GitHub Actions) test the model
with that data. The continuous-integration workflow downloads a prebuilt dataset archive whose location is held in a
repository secret. To refresh it:

1. From **inside** the folder that contains all the data files (not the parent folder), in a *bash* shell, build the
   archive:

   ```bash
   tar -cvzf data.tgz *
   ```

2. Upload `data.tgz` to Google Drive and share it as "anyone with the link can view". Copy the link **ID** — the
   string between the slashes, after `d`.

3. Update the OPEN-PROM GitHub Actions secret `DATASET` with the new link ID by replacing **only** the ID in the
   URL, not the full URL. If you do not have access, ask a repository owner to do this for you.

4. Open a pull request for the change in step 3, or commit directly to `main` if you have access.

5. Merge the updated `main` into the branch to be merged.

6. Open the pull request: the automated tests, triggered when a pull request is opened, will now run with the new
   dataset.

## Running the model

Once setup is complete, the actual execution paths depend on the run mode, the available data, and whether fresh
input generation is needed:

- External users should continue with the dummy-data first run.
- E3Modelling internal users should continue with the full-data workflow.

OPEN-PROM can be started either from the VS Code Task Runner panel or from the command line, but the correct button
or command depends on the run mode and your data, which is why the execution paths are covered in the running guide
rather than here.
