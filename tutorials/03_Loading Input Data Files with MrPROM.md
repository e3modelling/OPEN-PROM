## Loading Input Data Files with MrPROM application

**Objective:**

In this guide, you will find the common setup that is needed before loading input data files to the OPEN-PROM model. This setup is shared by both external users and E3-Modelling internal users. The input data workflow relies on the complementary [`mrprom`](https://github.com/e3modelling/mrprom) R package, which is also developed by E3-Modelling.

If you only want to test the model with dummy data, you do not need the full real-data setup described later in this tutorial. However, you still need the basic software environment described here, because the dummy-data first run still depends on R, GAMS, and the `loadMadratData.R` script used in Tutorial 04.

## Installing Necessary Software and Libraries

Before using `mrprom`, you need a working installation of R (download [here](https://www.r-project.org/)), as well as GAMS. If you use Windows, you may also need Rtools (download [here](https://cran.r-project.org/bin/windows/Rtools/)) for packages that compile from source. Make sure that R, GAMS, and, where relevant, Rtools are installed in folders that do not require admin priviledges, and can be found from your command line. If you need help adding software to your `PATH`, you can check example instructions for [Windows](https://www.bbminfo.com/r/r-programming-environment-setup.php) and [Linux](https://www.digitalocean.com/community/tutorials/how-to-view-and-update-the-linux-path-environment-variable). Please be sure that the library reticulate is installed in R. You may need to restart your computer to ensure that the updated `PATH` is visible in a new terminal session.

After making sure that R is correctly set up on your system, launch the R console and execute the following commands:

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

Those commands install `mrprom`, `postprom`, and the main supporting packages used by the OPEN-PROM workflow. `remotes` is only needed as a helper package so that R can install packages directly from GitHub.

If your goal is only the external dummy-data first run, this is more than the absolute minimum. In that case, the real essentials are:

* a working R installation,
* a working GAMS installation,
* the ability to run `Rscript loadMadratData.R DevMode=2`,
* and the R packages needed by that script, most notably `dplyr`.

If `gdxrrw` cannot find your GAMS installation automatically, you may need to configure it explicitly in R. This is especially common on macOS and Linux. A typical example is:

```r
library(gdxrrw)
gdxrrw::igdx("/path/to/gams/")
```

## Creating the Local Configuration File

Apart from installing the software, you should also create a local `config.json` file in the root folder of `OPEN-PROM`. The simplest way is to copy `config.template.json` and edit the relevant fields.

The most important settings are:

* `gams_path`: the directory of the GAMS installation, if `gams` is not already available in your system `PATH`
* `scenario_name`: the scenario label used in run folders and output naming
* `model_runs_path`: the destination used by the optional run-folder sync step

If you are not working in the internal E3-Modelling environment, `model_runs_path` is often not needed immediately. In that case, the common first change in `start.R` is:

```r
withSync <- FALSE
```

This avoids errors at the archive and sync stage when no valid internal destination has been configured.

## Understanding the Main `start.R` Switches

At the top of `start.R`, OPEN-PROM defines four switches that modify the workflow around the model run:

* `withRunFolder`
* `withSync`
* `withReport`
* `uploadGDX`

These switches do not change the mathematical model itself. They control the wrapper workflow around it, such as whether a run folder is created, whether outputs are archived, and whether the reporting script is executed automatically. There are also several task modes available through VS Code and `start.R`, but their exact meaning is explained later in Tutorial 05.

## Adding the Data Sources

Apart from software setup, the model also needs access to the right data sources. This is where external users and internal users begin to diverge.

If you are an E3-Modelling internal user, the normal workflow is to point `madrat` (see instructions [here](https://cran.r-project.org/web/packages/madrat/vignettes/madrat.html)) to a locally synced internal data directory. That step, together with the SharePoint and `mainfolder` setup, is described in Tutorial 05. Due to the proprietary nature of those datasets, we can't share them publicly, so you'll have to acquire them yourself, or contact us for further guidance.

If you are an external user, you do not need to configure the full internal data sources in order to try the model for the first time. The dummy-data route described in Tutorial 04 downloads a public archive from Google Drive and extracts it locally. That path does not use the full internal `mrprom` data pipeline, but it still uses R and the local helper script.

## Input Data Overview

The `mrprom` package calc functions generate a large number of datasets, originating from many different sources. To support transparency and reproducibility, a spreadsheet with the OPEN-PROM input datasets is available in `InputDataOverview.csv` in this tutorials folder. It provides the generated OPEN-PROM input parameters together with the original source and a short description.

## Executing the OPEN-PROM Model

To run the model after the setup is complete:

* External users should continue with Tutorial 04.
* E3-Modelling internal users should continue with Tutorial 05.

As mentioned in the VS Code Task Runner tutorial, OPEN-PROM can be started either from the Task Runner panel or from the command line. However, the correct button or command depends on the run mode, the available data, and whether fresh input generation is needed. That is why the actual execution paths are explained in the next tutorials rather than here.
