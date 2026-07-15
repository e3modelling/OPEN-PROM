# OPEN-PROM

This is OPEN-PROM ("open PROMETHEUS"). The model is currently under development, the present version 
is based on MENA-EDS ENERGY MODEL v4.0 (c) E3Modelling 2020

Some preliminary documentation of OPEN-PROM can be found in the Tutorials folder, extensive documentation of the PROMETHEUS model (on which both MENA-EDS and OPEN-PROM are based) can be found here: https://e3modelling.com/modelling-tools/prometheus/

OPEN-PROM is written in GAMS (General Algebraic Modelling System) and its main file is `main.gms`.

## Docker setup

Containerization files are included for running OPEN-PROM with Docker:

- `Dockerfile`
- `docker-compose.yml`
- `config.container.json`
- `.env.example`
- `docker/install-r-packages.R`

For setup, GAMS path configuration, build commands, single-scenario execution,
batch execution, outputs, MAgPIE/task 7 notes, and troubleshooting, see
[`docker/README.md`](docker/README.md).

An optional Windows-container setup is also included for environments that need
to run against a Windows GAMS installation:

- `Dockerfile.windows`
- `docker-compose.windows.yml`
- `config.windows-container.json`
- `.env.windows.example`
 
## Acknowledgements
OPEN-PROM was originally developed within the context of the European Union’s Horizon programme under Grant Agreement No. 101081179 ([DIAMOND](https://climate-diamond.eu/)) project and has been further advanced in the European Union’s Horizon programme under Grant Agreement No. 101137606 ([TRANSIENCE](https://www.transience.eu/)) to enhance its industrial representation and account for circular economy policies and impacts.
The responsibility for the content lies solely with the contributors.
