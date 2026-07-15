# OPEN-PROM Docker Guide

This guide describes how to build and run OPEN-PROM with Docker.

The Docker setup includes:

- `Dockerfile`
- `docker-compose.yml`
- `config.container.json`
- `.env.example`
- `docker/install-r-packages.R`

The container runs OPEN-PROM through:

```sh
Rscript start.R
```

The default Docker Compose command runs:

```sh
Rscript start.R task_id=2
```

## Requirements

The host system must provide:

- Docker Desktop or Docker Engine with Docker Compose.
- A Linux installation of GAMS.
- A valid GAMS license for that Linux installation.
- The OPEN-PROM input folders `data/` and `targets/` at the repository root.

The Windows GAMS installation path, for example `C:\GAMS\47`, cannot be used directly inside the Linux container. The container requires a Linux GAMS executable.

## GAMS Configuration

The Docker Compose setup mounts GAMS inside the container at:

```text
/opt/gams
```

The GAMS executable must therefore be available inside the container as:

```text
/opt/gams/gams
```

The host path to the Linux GAMS installation is configured with `GAMS_HOME` in a `.env` file.

Create `.env` from the template:

```sh
cp .env.example .env
```

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Then edit `.env` and replace:

```text
GAMS_HOME=/path/to/linux/gams
```

with the actual Linux GAMS installation path.

Examples:

```text
GAMS_HOME=/home/user/gams/47
```

or, when using Docker Desktop with WSL:

```text
GAMS_HOME=/home/plessias/GAMS/47
```

The configured directory must contain the Linux `gams` executable.

## GAMS License

The Docker image does not install, copy, or configure a GAMS license.

The mounted GAMS installation is expected to be already licensed and functional. If the license file is stored outside the GAMS installation directory, add an additional read-only volume to `docker-compose.yml`.

Example:

```yaml
      - /path/to/gams/license:/opt/gams/license:ro
```

The exact license mount depends on the local GAMS installation and license configuration.

## Container Configuration

The container uses:

```text
config.container.json
```

instead of the local `config.json`.

This is configured in `docker-compose.yml`:

```yaml
environment:
  OPENPROM_CONFIG: config.container.json
```

The main container paths are defined in `config.container.json`:

```json
{
  "paths": {
    "model_runs_path": "/outputs",
    "magpie_path": "/magpie/",
    "gams_path": "/opt/gams/"
  }
}
```

Path meanings:

- `/opt/gams/`: mounted Linux GAMS installation.
- `/outputs`: destination for synchronized run archives when `withSync=true`.
- `/magpie/`: placeholder path for MAgPIE, required only for task 7 soft-linking.

For a standard OPEN-PROM research run with `task_id=2`, `/magpie/` is not required.

## Mounted Folders

`docker-compose.yml` defines the following volume mounts:

```yaml
      - ./config.container.json:/open-prom/config.container.json:ro
      - ./data:/open-prom/data:ro
      - ./targets:/open-prom/targets:ro
      - ./runs:/open-prom/runs
      - ./outputs:/outputs
      - ${GAMS_HOME:-/path/to/linux/gams}:/opt/gams:ro
```

These mounts mean:

- `data/` is mounted read-only at `/open-prom/data`.
- `targets/` is mounted read-only at `/open-prom/targets`.
- `runs/` receives run folders produced by OPEN-PROM.
- `outputs/` receives synchronized archives when sync is enabled.
- `GAMS_HOME` is mounted read-only as `/opt/gams`.

## R Packages

The image installs R packages from CRAN and R-universe.

Default R-universe repositories:

```text
https://pik-piam.r-universe.dev
https://e3modelling.r-universe.dev
```

The packages `mrprom` and `postprom` are installed from GitHub:

```text
https://github.com/e3modelling/mrprom.git
https://github.com/e3modelling/postprom.git
```

Package installation is handled by:

```text
docker/install-r-packages.R
```

Package sources can be overridden at build time:

```sh
docker compose build \
  --build-arg R_UNIVERSE_REPOS="https://pik-piam.r-universe.dev,https://e3modelling.r-universe.dev" \
  --build-arg GITHUB_R_PACKAGES="https://github.com/e3modelling/mrprom.git,https://github.com/e3modelling/postprom.git"
```

## IAMC Common Definitions

The image clones:

```text
https://github.com/IAMconsortium/common-definitions.git
```

into:

```text
/opt/iamc/common-definitions
```

The path is exposed as:

```text
IAMC_COMMON_DEFINITIONS=/opt/iamc/common-definitions
```

For reproducible builds, the default Docker build pins this repository to:

```text
d877b5f56386317b66214bdb8cc694befda5596c
```

The image also installs the pinned Python package:

```text
nomenclature-iamc==0.31.0
```

This repository and package support IAMC codelists, mappings, validation, and exports.

Both pins can be overridden at build time:

```sh
docker compose build \
  --build-arg COMMON_DEFINITIONS_REF="main" \
  --build-arg NOMENCLATURE_IAMC_VERSION="0.31.0"
```

These pins make the IAMC common-definitions layer reproducible by default. Full image reproducibility would also require pinning the R package dependency graph, for example with an `renv.lock` file or equivalent version lock.

## Build

Build the image from the repository root:

```sh
docker compose build
```

Rebuild without cache after changing package sources, Docker dependencies, or the common-definitions reference:

```sh
docker compose build --no-cache
```

## Single Scenario Execution

Configure the scenario in:

```text
config.container.json
```

Run the default command:

```sh
docker compose run --rm open-prom
```

This uses the default command from `docker-compose.yml`:

```yaml
command: ["task_id=2"]
```

The equivalent explicit command is:

```sh
docker compose run --rm open-prom task_id=2
```

Other tasks can be selected by changing the `task_id` argument:

```sh
docker compose run --rm open-prom task_id=0
```

```sh
docker compose run --rm open-prom task_id=5
```

## Batch Execution

Batch mode is executed by passing a CSV file:

```sh
docker compose run --rm open-prom scenarios.template.csv
```

For a custom batch file:

```sh
docker compose run --rm open-prom scenarios.csv
```

The CSV must be available inside the project tree used by the container. `start.R` supports batch execution only for tasks that are batch-compatible.

## Outputs

When `withRunFolder=true`, run folders are written under:

```text
runs/
```

When `withSync=true`, synchronized archives are copied to:

```text
outputs/
```

The default container configuration sets:

```json
"withSync": true,
"uploadGDX": false
```

With this configuration, synchronized archives exclude `.gdx` files to reduce archive size.

To include `.gdx` files in synchronized archives, set:

```json
"uploadGDX": true
```

## MAgPIE and Task 7

`config.container.json` defines:

```json
"magpie_path": "/magpie/"
```

This is a placeholder for task 7 soft-linking. To run task 7, mount a MAgPIE installation at `/magpie`.

Example `docker-compose.yml` volume:

```yaml
      - /path/to/magpie:/magpie
```

The mounted MAgPIE directory must contain the setup expected by `scripts/tasks/task7SoftLinkMagpie.R`, including `e3m_start.R`.

For non-task-7 runs, the `/magpie/` path can be ignored.

## Useful Commands

Build the image:

```sh
docker compose build
```

Run default task 2:

```sh
docker compose run --rm open-prom
```

Run explicit task 2:

```sh
docker compose run --rm open-prom task_id=2
```

Run batch mode:

```sh
docker compose run --rm open-prom scenarios.template.csv
```

Open a shell inside the container:

```sh
docker compose run --rm --entrypoint bash open-prom
```

Check whether GAMS is visible inside the container:

```sh
docker compose run --rm --entrypoint bash open-prom -lc "which gams && gams"
```

Check selected R packages:

```sh
docker compose run --rm --entrypoint Rscript open-prom -e "library(mrprom); library(postprom); library(gdx); library(quitte)"
```

## Troubleshooting

If Docker reports that `/path/to/linux/gams` does not exist, `.env` has not been configured. Set `GAMS_HOME` to the real Linux GAMS installation path:

```text
GAMS_HOME=/real/linux/path/to/gams
```

If `gams` is not found inside the container, verify that:

- `GAMS_HOME` points to the directory containing the Linux `gams` executable.
- The compose volume maps `GAMS_HOME` to `/opt/gams`.
- `config.container.json` sets `"gams_path": "/opt/gams/"`.

If GAMS starts but reports a license error, the mounted GAMS installation or license configuration is incomplete.

If an R package fails to install, verify that:

- The package exists in the configured R-universe repositories.
- GitHub is reachable during `docker compose build`.
- `GITHUB_R_PACKAGES` contains the correct repository URLs.

If task 7 fails because MAgPIE is missing, add a `/magpie` volume and verify `magpie_path`.

If outputs are missing, verify:

- `withRunFolder`
- `withSync`
- `model_runs_path`
- write access to `./runs` and `./outputs`

## Optional Windows Container

The default Docker setup uses a Linux container. This is the recommended path, including on Windows hosts through Docker Desktop with WSL2.

An optional Windows-container setup is also provided:

- `Dockerfile.windows`
- `docker-compose.windows.yml`
- `config.windows-container.json`
- `.env.windows.example`

This setup is intended for environments that must use a Windows GAMS installation inside a Windows container.

Windows-container requirements:

- Docker Desktop switched to Windows containers.
- A Windows base image compatible with the host, defaulting to `mcr.microsoft.com/windows/servercore:ltsc2022`.
- A Windows GAMS installation, for example `C:\GAMS\47`.
- A valid GAMS license for that Windows installation.

Create the Windows environment file:

```powershell
Copy-Item .env.windows.example .env.windows
```

Edit `.env.windows` if GAMS is not installed at the default path:

```text
GAMS_WINDOWS_HOME=C:\GAMS\47
```

Build the Windows image:

```powershell
docker compose --env-file .env.windows -f docker-compose.windows.yml build
```

Run task 2:

```powershell
docker compose --env-file .env.windows -f docker-compose.windows.yml run --rm open-prom-windows
```

Run another task:

```powershell
docker compose --env-file .env.windows -f docker-compose.windows.yml run --rm open-prom-windows task_id=5
```

The Windows container maps paths as follows:

```yaml
      - .\config.windows-container.json:C:\open-prom\config.windows-container.json:ro
      - .\data:C:\open-prom\data:ro
      - .\targets:C:\open-prom\targets:ro
      - .\runs:C:\open-prom\runs
      - .\outputs:C:\outputs
      - ${GAMS_WINDOWS_HOME:-C:\GAMS\47}:C:\GAMS:ro
```

Inside the Windows container, OPEN-PROM uses:

```json
{
  "paths": {
    "model_runs_path": "C:/outputs",
    "magpie_path": "C:/magpie/",
    "gams_path": "C:/GAMS/"
  }
}
```

The Windows image installs R and Rtools from pinned installer URLs and installs the same R package set as the Linux image. It downloads the pinned IAMC common-definitions archive into `C:\iamc\common-definitions`.

The Windows image is expected to be larger and less portable than the Linux image. Prefer the Linux container unless Windows GAMS execution is required.
