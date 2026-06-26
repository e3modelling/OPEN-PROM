# Demand sectors

:::{note}
**In brief** — OPEN-PROM resolves final energy demand in three end-use domains: industry and domestic
(households, services, agriculture), transport and bunkers, and a dedicated Carbon Dioxide Removal sub-model.
Each domain estimates activity from socio-economic drivers, then allocates energy across competing fuels and
technologies in response to relative prices, before passing electricity and hydrogen demands to the supply
modules.
:::

(industry-demand)=
## Industry and domestic demand

The Industry and Domestic Demand module covers final energy consumption in the industrial sector and in the
domestic sector (households and commercial/services, often grouped with residential demand). This module
projects how energy demand evolves in these sectors across the model horizon, disaggregating key subsectors and
end-uses to capture structural and technological differences.

Industry in OPEN-PROM is split into ten subsectors, reflecting a broad range of industrial activities with
distinct energy profiles. These include energy-intensive industries such as:

- Iron and Steel
- Chemicals
- Non-ferrous Metals (e.g. aluminium)
- Non-Metallic Minerals
- Pulp and Paper
- Food, Drink and Tobacco
- Engineering
- Textiles
- an Other Industrial Sectors category to cover remaining manufacturing sectors

By modelling these subsectors separately, the module can account for differences in production growth,
technological options, and energy intensity. Each subsector's output or activity is usually driven by exogenous
assumptions linked to GDP or sectoral value-added growth (for example, Iron and Steel demand may follow
construction and manufacturing trends).

The domestic part of the module includes three main subsectors — Services and Trade; Households; and
Agriculture, Fishing, Forestry, etc. These domestic demands are driven by indicators like population, number of
households, floor area of buildings, income levels, and urbanisation. Both industry and domestic sub-modules use
these drivers to estimate baseline activity growth, then determine energy consumption based on the technology and
fuel choices available.

The core of this module's functionality is the calculation of final energy demand by fuel for each subsector. It
does so by using energy intensities or energy-service demand approaches. For example, in industry the model might
have an energy intensity (energy per unit of output) that improves over time due to technological advances and
efficiency policies. These improvements can be exogenous or endogenous (e.g. in response to energy prices).
According to future activity projections, the module computes the total energy required to satisfy the demand of
the specific sector. A fuel allocation routine then determines how that energy requirement is met by different
fuels or technologies. The fuels considered usually include coal, oil, natural gas, biomass, hydrogen,
electricity, and others. The module uses econometric formulations (like logit or substitution elasticities) to
split demand among fuels based on their relative prices and availabilities.

For instance, if electricity becomes cheaper or cleaner, the model will shift some heating demand from fossil
fuels to electric boilers or heat pumps in the residential sector (fuel switching). Similarly, industries might
adopt electric arc furnaces (using electricity) over blast furnaces (using coke for steelmaking) if conditions
favour that, or switch from oil-fired furnaces to gas, etc.

:::{tip}
The inclusion of hydrogen as a final demand option is a distinctive feature, allowing exploration of sector
coupling and new fuel adoption. Price signals from the Prices module (energy prices by fuel) therefore feed this
module's equations, influencing the chosen fuel mix in each subsector via behavioural parameters or cost
comparisons.
:::

On the domestic side, a similar logic applies to household energy uses: the module simulates how heating is
supplied by gas boilers vs. electric heat pumps vs. possibly hydrogen boilers, how cooking shifts from LPG to
electricity, or how insulation and efficiency improvements reduce overall energy needs. Many of these changes
over time can be driven by exogenous policies (like building codes mandating efficiency, or incentives for heat
pumps) or by the model responding to price changes (e.g. high carbon prices making fossil heating more expensive,
thus accelerating electrification).

The outcome of the Industry and Domestic Demand module is a detailed breakdown of energy demand by sector,
subsector, end-use, and fuel in each region and year. These demands are then passed to other modules: electricity
demand and hydrogen demand computed here become inputs for the Power and Hydrogen Supply modules, respectively,
while demand for fossil fuels (gas, oil, coal) interacts with the Prices module to determine if supply is adequate
or if price adjustments are needed. In turn, the module receives information on final energy prices (which
incorporate primary energy prices and any taxes or subsidies) from the Prices module each iteration, to
recalculate consumption with price-responsive elements. When run standalone, the Industry/Domestic module would
use exogenous price trajectories to simulate energy demand; within the integrated model, it provides a crucial
link from economic activity to energy usage, and ultimately to emissions.

:::{seealso}
Electricity and hydrogen demands computed here feed the supply modules — see {ref}`power-supply` and
{ref}`hydrogen-supply`.
:::

## Residential and commercial

:::{note}
Despite the heading, this sub-section documents the ICT / data-centre sub-sector, which was split off from the
services sector during the PRISMA project.
:::

The ICT (Data Centres and related Infrastructure) sector is separated from the services sector, during the PRISMA
project, to create a new sector that keeps track of the final consumption of the newly merged data-centres sector,
which is expected to have significant growth over the coming years. For the projection of the data-centre
electricity demand, an econometric curve is fitted based on the IEA short-term projections and further analysis,
ending in the creation of different scenarios (Lower, Medium and Higher Usage).

(transport-demand)=
## Transport and bunkers demand

The Transport Demand module models energy demand in the transportation sector by distinguishing between passenger
and freight transport modes. In OPEN-PROM, transport is disaggregated into seven categories (modes) to reflect
differences in technologies and usage patterns. Passenger transport includes passenger cars, buses, aviation, and
passenger rail, while freight transport comprises freight trucks, freight rail, and maritime shipping.
International maritime and aviation activities are treated separately under the bunkers category, outside the main
transport module. This level of disaggregation, produced in the context of DIAMOND, allows the model to capture
the distinct characteristics of each transport mode. For instance, passenger cars and aviation differ
significantly in their energy consumption patterns, operational behaviour, and available fuel options.

The module projects transport activity growth based on key socio-economic drivers. Activity indicators are
expressed as:

- Kilometres per year for passenger cars
- Passenger-kilometres for other passenger modes
- Tonne-kilometres for freight transport

In addition, the total passenger car stock in each region is estimated using socio-economic indicators such as GDP
per capita and population. Rising incomes and urbanisation generally lead to increased demand for passenger
mobility, reflected in higher car ownership rates and greater air travel. Similarly, growth in economic output and
trade stimulates demand for freight transport services.

A core component of the Transport Demand module is the representation of vehicle technologies and fuel choices,
particularly in road transport. The passenger car segment is modelled in detail, distinguishing across multiple
vehicle types:

- conventional internal combustion engine vehicles (ICEVs, gasoline and diesel)
- hybrid electric vehicles (HEVs)
- plug-in hybrids (PHEVs)
- compressed natural gas (CNG) vehicles
- liquefied petroleum gas (LPG) vehicles
- battery electric vehicles (BEVs)
- hydrogen fuel cell vehicles (FCEVs)

The model simulates the evolution of new vehicle sales using a multinomial logit framework, combined with
cost-based comparisons to reflect consumer preferences. This allows technology adoption to respond endogenously to
economic signals. For example, declining battery costs or increasing fossil fuel prices can lead to a higher share
of electric vehicles in new registrations. Over time, the interaction between new sales and vehicle retirements
determines the total fleet composition, from which the average efficiency and fuel mix are derived. A similar
modelling approach is applied to other transport modes, including buses, freight vehicles, and rail (e.g. diesel
versus electrified systems). Each mode is characterised by an evolving energy intensity, reflecting both
technological improvements and shifts in the underlying technology mix.

Using projected transport activity and mode-specific energy intensities, the module calculates total energy demand
by fuel type and transport mode. Outputs include the consumption of major fuels such as gasoline, diesel,
electricity, hydrogen, and other energy carriers used across the transport sector. These outputs are passed to
other components of the modelling framework. Electricity and hydrogen demands are integrated into the Power Supply
and Hydrogen modules, respectively, while liquid fuel demand (e.g. gasoline, diesel, kerosene, and marine fuels)
is transferred to the corresponding supply sector. In return, the Transport module receives updated fuel prices,
such as electricity price, hydrogen costs, and retail fuel prices, which influence subsequent iterations of
technology choice and transport demand.

The module also incorporates a calibration mechanism. Regulatory measures such as CO₂ emission standards or
electric vehicle mandates can be represented through parameters affecting technology uptake (e.g. maturity or
adoption constraints), thereby influencing the composition of new vehicle sales. Finally, the Transport module
includes vehicle stock dynamics, accounting for both standard lifetimes and premature scrapping. This enables the
model to capture accelerated turnover in response to economic or policy drivers, particularly when certain
technologies become less competitive.

Within the integrated modelling framework, the Transport Demand module provides essential insights into the
interaction between mobility trends, technological change, and energy demand. Its level of technological and modal
detail enables the assessment of transition pathways, such as the impact of large-scale vehicle electrification on
electricity demand and oil consumption, or the role of alternative fuels in reducing emissions from aviation and
maritime transport.

:::{seealso}
As in the industry/domestic sector, the transport module's electricity and hydrogen demands feed the supply side
— see {ref}`power-supply` and {ref}`hydrogen-supply`.
:::

(cdr)=
## Carbon Dioxide Removal (CDR) technologies

The CO₂ module includes the calculation of carbon captured by the CCS and DAC technologies, as well as the curve
of the sequestration costs according to the cumulative carbon captured as a result of the limitation in carbon
storage. The rest of the module analyses the capacity expansion in CDR technologies.

The following CDR technologies are added in OPEN-PROM:

1. Liquid solvent (high temperature) Direct-Air-Capture
2. Liquid solvent (high temperature) Direct-Air-Capture (hydrogen fuelled)
3. Solid sorbent (low temperature) Direct-Air-Capture
4. Enhanced Weathering

Input data of the technology, like capital, fixed and variable costs, were taken mainly from the UPTAKE[^uptake]
project. These costs are affected by a learning curve (learning-by-doing) that decreases them by 3% for every
doubling of the installed capacity. There is a top (beginning) and bottom (ending) level for each of these costs,
which is parameterised according to the literature.

The expansion of these technologies is performed according to two basic criteria:

- **Financial sustainability** is checked by calculating the rate between the carbon taxes and the levelised
  carbon capture cost for each technology. On the one hand, the carbon taxes are supposed to increase as time
  passes, while at the same time the levelised cost decreases because of the learning curve. Moreover, this
  levelised cost is affected by the subsidy mechanism. This rate affects the annual increase in the installed
  capacity, increasing the motivation for new investments in high profitability.
- **Regional emissions** create an extra motivation for CDR technology expansion. This adds regionality to the CDR
  technology expansion, ensuring that the high-emitting regions have an extra reason to invest in CDR. This will
  perhaps be linked with the subsidy mechanism, so as to express this extra motivation as a policy.

:::{note}
These drivers influence both the regional distribution of technology deployment and the definition of scenarios.
On the one hand, regional differentiation is reflected in the expansion of technologies, as subsidies, costs, and
residual emissions vary across regions. On the other hand, scenario design is shaped by the parameterisation of
the subsidy mechanism, which represents policy choices specific to each scenario.
:::

[^uptake]: Cost data for the CDR technologies are drawn mainly from the UPTAKE project.
