# Supply sectors

:::{note}
**In brief** — This chapter describes how OPEN-PROM supplies the energy carriers that meet sectoral demand: a technology-rich power sector, a district-heat sector, a production-centred hydrogen sector, and the aggregated supply of all other fuels (solids, liquids, gases and biofuels) that keep the energy balance closed.
:::

The supply sectors translate the demand transmitted by the end-use modules into the production, conversion and pricing of energy carriers. They were developed in the context of the DIAMOND project and share the same accounting and decision logic that underpins the rest of the model.

:::{tip}
The power, heat and hydrogen modules all reuse the same gap, scrapping and substitution logic described in {ref}`gap-substitution`: surviving capacity is carried forward, the gap to demand is computed, and new production is allocated across competing technologies through a market-share mechanism.
:::

(power-supply)=
## Power supply

The Power Supply module, developed in the context of DIAMOND, represents the electricity generation sector, determining how electricity demand is met through a detailed portfolio of generation technologies and fuels. It features a technology-rich menu of power generation technologies[^powertech], encompassing biomass and fossil-fuel plants (with and without Carbon Capture and Storage), nuclear, and renewable energy technologies. For example, the module includes coal-fired power, natural gas combined cycles and turbines, oil-fired units, nuclear reactors, hydroelectric power, wind turbines (onshore and offshore), solar power (photovoltaic and concentrated solar power, CSP), biomass-fired plants, and others. In addition to electricity-only power plants, cogeneration or combined heat and power (CHP) plants are also included. These technologies differ in that they produce heat (or steam) that can be distributed to consumers. All technologies compete to supply electricity based on their costs, availability, and policy constraints. The Power Supply module simulates capacity expansion and operation on an annual basis, ensuring that sufficient capacity is built and dispatched to satisfy electricity demand in every region and year.

In terms of equations and functionality, the Power Supply module usually includes equations for capacity accumulation. Capacity expansion equations determine how much new capacity of each technology is added each year, based on investment decisions which depend on expected profitability or exogenously specified build trajectories. Operating cost minimisation or simulation ensures that, for a given set of available plants, the least-cost generation options are used to meet demand, subject to constraints like maximum capacity and renewable availability. In addition, a set of parameter weights, referred to as *maturity factors*, guide the energy mix trajectory by influencing investment decision shares based on various factors. These factors account for non-economic considerations, including policy preferences and challenges in scaling up technologies. Renewable energy sources are typically modelled with constraints reflecting resource potential and variability — for example, limits on annual generation from wind or solar corresponding to capacity factor assumptions and installed capacity. The power module also accounts for fuel consumption and associated CO₂ emissions of thermal power plants.

The power module incorporates three mechanisms for technology scrapping: lifetime, premature, and retrofitting. Lifetime scrapping occurs when a technology surpasses its operational lifetime. An important output of the Power Supply module is the electricity price, which is determined by the average cost of electricity generation. In the integrated model, this electricity price feeds back to the demand modules, influencing electricity consumption in industry, buildings, and transport. Conversely, the module takes as input the total electricity demand from the Industry/Domestic and Transport modules and ensures this demand is met. The module can also incorporate policy measures such as renewable portfolio standards or emission caps: for instance, a constraint could force a minimum share of generation from renewables or limit emissions from the power sector, affecting the investment decisions. When run in standalone mode, the Power Supply module would use exogenous electricity demand projections and fuel prices to simulate the power system expansion. In the full model run, however, it dynamically interacts with other modules, making it a central component for analysing decarbonisation pathways (since the power sector is often a major focus of climate policies). Overall, the Power Supply module provides a detailed picture of the evolving electricity generation mix, capacity investment needs, and the cost of electricity under various scenarios.

(heat-supply)=
## Heat supply

The Heat Supply module, developed in the context of the DIAMOND project, simulates the production and availability of steam and heat to meet the model's heat demand for district heating purposes, providing a detailed representation of all production technologies and supply-chain elements. It includes only heat that is produced and sold to third parties (e.g. residential, commercial, or industrial consumers) under contractual arrangements through the public grid. Heat produced and consumed within an autoproducer's establishment is excluded here and is accounted for in the final fuel consumption of the relevant consuming sector.

The functionality of the Heat Supply module focuses on ensuring that heat supply meets demand and on determining the market price of heat. On the supply side, the module includes equations for capacity investment in heat production plants and their output, while also accounting for heat produced as a by-product from CHP plants in the power generation module. It then allocates heat production across technologies based on cost competitiveness and operational constraints. For example, if renewable electricity is abundant and inexpensive in a given scenario, solar thermal technology may expand significantly; otherwise, fossil fuel plants may dominate unless restricted by carbon policies. The module also considers resource and policy constraints, such as the availability of geothermal resources for district heating plants, limits on CO₂ emissions for fossil-based heat, and targets for "green" hydrogen production. Non-economic factors, including transmission obstacles or policy-driven decisions, are implemented through corresponding maturity factors.

As in the power generation module, the Heat Supply module also includes scrapping mechanisms (lifetime and premature scrapping) to account for cases where a heat plant becomes economically unfeasible compared to other technologies.

(hydrogen-supply)=
## Hydrogen supply

The Hydrogen Supply module, also developed during the DIAMOND project, represents the upstream production of hydrogen and its interaction with the wider energy system. In the current main-branch implementation, hydrogen is treated as a produced secondary energy carrier whose demand is linked to the model's hydrogen energy balance, and whose production is allocated across competing technologies according to cost, existing production, scrapping and new demand requirements. The module is therefore focused on hydrogen production, production costs, fuel inputs and carbon-capture behaviour, while the more detailed hydrogen infrastructure representation is present in the model structure but not currently active in the solved equations.

:::{warning}
The current implementation is **production-centred**. Input data and equation blocks for hydrogen delivery and infrastructure — pipelines, service stations, network efficiencies, self-consumption, infrastructure investment, tariffs and delivered hydrogen costs — exist in the model structure but are **not active** in the solved equations on the current main branch. Sectoral hydrogen demand is handled through the energy-balance link rather than built up from a distribution network.
:::

The active production technology portfolio includes natural-gas steam reforming with and without CCS, coal gasification with and without CCS, grid-based electrolysis, solar- and wind-based electrolysis, and large-scale biomass gasification with and without CCS. These routes cover the main fossil, renewable electricity and biomass-based hydrogen pathways currently represented in OPEN-PROM. Several additional concepts, such as nuclear thermochemical routes, oil partial oxidation, solar thermochemical hydrogen and smaller biomass gasification routes, appear as dormant or commented options rather than active technologies in the present realization.

Hydrogen demand is determined at country and year level from the model's gross inland consumption of hydrogen, adjusted for net imports. This is an important distinction from a fully sector-explicit delivered-demand formulation. Although the model contains structures for assigning hydrogen demand to end-use sectors and for accounting for infrastructure losses, the currently active demand equation does not build total hydrogen demand by summing sectoral hydrogen uses through a distribution network. Sectoral hydrogen-demand variables are effectively inactive in the current implementation, while total hydrogen requirements are handled through the energy-balance link.

Once total hydrogen requirements are known, the module calculates the gap between demand and surviving production from the previous period. Existing hydrogen production is carried forward subject to normal lifetime scrapping and premature replacement. New production required to close the gap is distributed across available technologies through a Weibull-type market-share mechanism, where lower-cost and more mature technologies receive higher shares. The CCS and non-CCS variants of fossil and biomass routes are also treated as competing options, with the attractiveness of CCS influenced by sequestration costs, carbon prices and technology-specific capture rates.

Technology costs combine annualised capital costs, fixed and variable operation and maintenance costs, availability factors, conversion efficiencies and fuel costs. For fossil and biomass routes, variable production costs depend on the price of the input fuel, the emissions intensity of that fuel, the prevailing carbon price and the share of emissions captured. For electrolysis, the model distinguishes grid electrolysis from solar- and wind-linked electrolysis, with the latter two drawing on the cost and availability assumptions of the corresponding renewable power technologies. This creates a direct interaction between hydrogen production and the wider power, fuel-price, CCS and carbon-pricing systems.

The module reports hydrogen production by technology, fuel consumption for hydrogen production, technology-specific production costs, average hydrogen production cost and captured-emission behaviour for CCS-equipped routes. The aggregate fuel requirements of hydrogen production are passed to the transformation side of the energy balance, so that upstream fuel use for hydrogen is accounted for consistently and is not confused with final energy demand. The average hydrogen production cost is also used by the wider price system to transmit hydrogen-cost dynamics to other parts of OPEN-PROM.

The current implementation should therefore be described as a production-centred hydrogen supply module, not yet as a fully active hydrogen delivery-network module. Input data and inactive equation blocks exist for pipelines, service stations, network efficiencies, self-consumption, infrastructure investment, tariffs and delivered hydrogen costs, but these infrastructure equations are not part of the active solved module on the current main branch. Future development can reactivate or extend this infrastructure layer, but the present operational version mainly captures how different hydrogen production routes compete and how their fuel, electricity and carbon-price dependencies feed back into the broader energy-system solution.

:::{seealso}
The CCS and BECCS routes referenced here connect to the carbon-capture and removal technologies described in {ref}`cdr`.
:::

### Supply–demand alignment and sector coupling

Hydrogen demand arrives from other modules (industry, transport). The model calculates total hydrogen demand by combining end-use requirements with the additional hydrogen needed to cover transport losses and final-sector demand by the magnitude of system losses.

Production is allocated across hydrogen technologies based on their cost competitiveness and technical constraints, ensuring that hydrogen supply meets this total demand. Hydrogen production based on electrolysis becomes more attractive when electricity prices decline or when higher carbon prices reduce the competitiveness of fossil-based production routes. Conventional fossil-based hydrogen production becomes less economically attractive under stringent climate policy, unless combined with carbon capture and storage. Biomass routes are controlled by feedstock availability and carbon accounting rules.

The fuel required for hydrogen production is accounted for as an upstream transformation input rather than as final energy consumption. In practice, the model aggregates the fuel and electricity inputs needed by all hydrogen production technologies and passes them to the transformation side of the energy balance. This ensures that hydrogen production is represented consistently within the overall energy accounting framework. It also avoids double-counting, since fuels used to produce hydrogen are treated as inputs to an energy conversion process, while hydrogen consumed by industry, transport, or other end-use sectors is recorded separately as final demand.

Hydrogen production also interacts with the emissions module through direct emissions (from non-CCS routes) and captured emissions (from CCS-equipped technologies), using the same emission factors and carbon prices used across the model. Thus, the hydrogen module is directly tied to the power system, fossil supply system, CCS system, emissions block, and the carbon pricing mechanism.

### Output and role in the full energy system

The module provides hydrogen production by technology, overall hydrogen production cost, delivered hydrogen price, upstream fuel use, and CO₂ captured and emitted. Through these outputs, OPEN-PROM can assess how hydrogen scales in long-term decarbonisation scenarios: how fast electrolysis grows under cheap renewables, how CCS hydrogen competes when carbon prices tighten, how biomass-based hydrogen behaves under supply constraints, and how hydrogen production shifts electricity load and fossil fuel use. By explicitly modelling technologies, efficiencies, CO₂ pathways, price feedback loops, and sectoral interactions, the Hydrogen Supply Module provides a complete, system-integrated picture of hydrogen's role within the broader energy transition.

(other-fuels)=
## Supply of other fuels

The supply component for the rest of the fuels covers energy carriers that are not represented in dedicated electricity, hydrogen or heat supply modules, but remain essential for the overall energy balance. These include fossil solids (e.g. hard coal and lignite), liquid fuels (e.g. crude oil, gasoline, diesel, kerosene, LPG and residual fuel oil), gaseous fuels (e.g. natural gas and other gases), and non-fossil alternatives (e.g. biomass and waste, biodiesel, bio-gasoline, biokerosene, biogas, methanol and ethanol). These carriers appear throughout the model as final energy inputs, transformation fuels, primary production streams, and trade flows, as determined during DIAMOND.

OPEN-PROM ensures that all energy balances are fully closed across regions, fuels and time periods. This is achieved through aggregated SOLIDS, LIQUIDS and GASES supply sectors, which track the full chain from primary resources to final use (see {numref}`fig-energy-flow`). These sectors act as the accounting backbone for fossil liquids, gases, solid fuels and biofuels.

For each region and year, the supply sectors calculate the gross inland consumption of each fuel, which includes:

- final energy demand from industry, buildings, transport and other sectors;
- transformation inputs into conversion processes;
- own consumption within energy supply sectors;
- distribution losses and inter-fuel transfers.

Based on these requirements, the model determines the transformation inputs needed to supply demand. Examples include crude oil inputs to refineries, coal inputs to liquefaction plants, and gas inputs to processing facilities. The associated energy needs of these processes, such as heat and electricity consumption, are explicitly accounted for, ensuring consistency across all energy carriers and sectors.

The estimation of required resources relies on input–output relationships, derived as ratios based on the total transformation output of each supply sector. This allows OPEN-PROM to link upstream resource use with downstream fuel production in a transparent and internally consistent manner, without representing each individual facility in engineering detail.

A specific and more detailed treatment is applied to biomass, reflecting its role as both an energy carrier and a land-constrained resource. Biomass supply is represented using supply curves derived from the linkage with the MAgPIE land-use model (or its emulator), which incorporate biomass potential, land availability and competing land uses. As a result, biomass becomes an explicitly constrained resource that competes across alternative uses, including fuel production and carbon removal pathways such as bioenergy with carbon capture and storage (BECCS).

:::{seealso}
The biomass supply curves come from the land-use coupling described in {ref}`magpie-link`.
:::

Through this structure, the supply sectors are capable of consistently tracking both primary and secondary energy production for each region, ensuring that domestic production, transformation processes, imports and exports jointly satisfy demand. Overall, these supply sectors provide a coherent and flexible representation of the rest of the fuels. It enables OPEN-PROM to capture the evolution of fossil fuels, bioenergy and alternative fuels, while maintaining consistency in energy balances and allowing interactions with demand sectors, fuel prices, technology choices and emissions across a wide range of scenarios.

[^powertech]: The exact set of power generation technologies can be found in OPEN-PROM's online documentation.
