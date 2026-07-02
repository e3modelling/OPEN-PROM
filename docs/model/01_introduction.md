# Introduction

:::{note}
**In brief** — OPEN-PROM is a modular, open-source, simulation-based integrated assessment model of the global energy system. This chapter introduces what the model is, how it has been used, its recursive-dynamic logic, its demand and supply coverage, the gap-and-substitution mechanism, its 39-region global scope, and the purpose of this documentation.
:::

OPEN-PROM ("open PROMETHEUS"), i.e. the open version of the PROMETHEUS model, is a modular open-source simulation-based integrated assessment model (IAM) that projects energy-system developments — and land-use developments when coupled with a land-use model — under varying macroeconomic, technological, and policy scenarios.

The model has been extensively used for energy and climate policy impact assessments in the EU and globally (Gidden, Portugal-Pereira, & Apeaning, 2026; Fragkos, 2020; Fragkos, Kouvaritakis, & Capros, 2015; Fragkos, Van De Ven, Horowitz, & Zisarou, 2024; Marucci, Panos, Kypreos, & Fragkos, 2019; Mikropoulos et al., 2025), and provided scenarios to the IPCC AR6 database and the European Commission.

The development of OPEN-PROM within DIAMOND follows the project's broader objective of upgrading and opening established integrated assessment models by improving their transparency, sectoral and technological detail, spatial resolution, and capacity to support Paris-compatible mitigation analysis. In this context, OPEN-PROM has been further developed to provide a consistent system-wide representation of energy balances, emissions, prices, technology choices, and policy signals, while remaining sufficiently modular to support targeted model improvements and interlinkages with specialised models.

OPEN-PROM operates as a recursive dynamic model. In each simulation year, the model updates activity levels, useful energy demand, technology stocks, investment needs, fuel use, costs, prices, emissions, and policy conditions based on previous-year outcomes and scenario assumptions. This modelling approach reflects the gradual and path-dependent nature of energy-system change: existing infrastructure and technology lifetimes constrain near-term developments, while new investments, retirements, retrofits, fuel switching, and policy incentives determine longer-term transformation pathways.

The model covers the main energy demand sectors, including industry, domestic demand, transport, non-energy uses, and bunkers. Useful energy demand is linked to macroeconomic and sectoral drivers such as GDP, industrial activity, household income, population, transport activity, and energy-service costs. Final energy demand is then derived through technology-specific efficiencies and substitution mechanisms. On the supply side, OPEN-PROM represents electricity, heat, hydrogen, and other fuels, ensuring that fuel flows, transformation inputs, energy balances, prices, and emissions remain internally consistent across sectors and regions.

A key feature of the updated model is the explicit treatment of technology turnover and competition. The gap-and-substitution mechanism determines how new or replacement demand is satisfied by competing technologies, using cost-based formulations that also account for technology maturity, existing capital stock, premature scrapping, retrofitting, and policy-induced changes in relative competitiveness. This allows OPEN-PROM to represent both short-term inertia and the gradual diffusion of low-carbon technologies across end-use and supply sectors.

:::{important}
OPEN-PROM is recursive dynamic, runs annually from 2024 to 2100, and draws on historical data from 2010 onwards for calibration and validation. Its global coverage is represented through 39 countries and regions, including detailed representation of EU Member States and major global economies.
:::

The model's global coverage is represented through 39 countries and regions, including detailed representation of EU Member States and major global economies. This regional structure supports national, European, and global scenario analysis while enabling compatibility with other models used in DIAMOND. The model runs annually from 2024 to 2100, using historical data from 2010 onwards for calibration and validation.

This documentation describes the current structure and modelling logic of OPEN-PROM. It presents the model overview, sectoral representation, technology substitution mechanisms, price formation, energy supply modules, data preparation and calibration workflows, output post-processing tools, and inter-model linkages. The purpose is to provide a clear reference for users, developers, and analysts working with OPEN-PROM in energy-system, climate-policy, and integrated assessment applications.

:::{seealso}
Continue with the {doc}`/model/02_model_overview` for the model's time and regional resolution, sectoral granularity, the gap-and-substitution mechanism, price formation, and energy supply. Full citation details are listed on the {doc}`/reference/bibliography` page.
:::
