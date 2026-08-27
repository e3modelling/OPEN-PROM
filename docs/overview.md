# Overview

OPEN-PROM ("open PROMETHEUS") is a modular, open-source, simulation-based **integrated assessment model** of the
global energy system. It projects energy demand, energy supply, technology deployment, fuel use, prices, and
emissions under alternative macroeconomic, technological, resource, and climate-policy assumptions.

Key characteristics:

- **Global, country-resolved** — 39 countries and regions, with EU Member States and major economies modelled
  individually.
- **Recursive-dynamic** — annual steps from 2024 to 2100, calibrated on historical data from 2010.
- **Technology-rich** — explicit demand sectors (industry, domestic, transport, non-energy, bunkers) and supply
  sectors (electricity, heat, hydrogen, other fuels), with technology turnover handled by the gap-and-substitution
  mechanism.
- **An integrated toolchain** — the model is fed by **mrprom** (input-data pipeline) and analysed with **postprom**
  (post-processing and reporting).

The documentation is organised as follows:

- **Getting started** (this section) — this overview and the first steps for {doc}`setting up </guide/01_setup>`
  and {doc}`running </guide/02_running_the_model>` the model.
- **How-to guides** — task-oriented guides for {doc}`input data </guide/03_input_data>`,
  {doc}`development </guide/04_development>`, and {doc}`model coupling </guide/05_soft_linking>`.
- **Model documentation** — the scientific reference: model structure, sectors, mechanisms, equations, the data
  pipeline, calibration, model interlinkages, and baseline results.
- **Reference** — GAMS error codes, abbreviations, and bibliography.
- **Project** — acknowledgements, funding, and how to cite OPEN-PROM.

:::{tip}
New to OPEN-PROM? Skim this overview, then read the model {doc}`Introduction </model/01_introduction>` for the full
picture, or start with {doc}`Setup and environment </guide/01_setup>` to run it.
:::
