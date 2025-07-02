*' @title Equations of OPEN-PROMs INDUSTRY  IRON and STEEL - need to be implemented in the industry equations.gms
*' @code



* HISTORICAL TECHNOLOGIES, Calibration of the historical years/base year in terms of production and fuel consumption of the existing routes BF-BOF, DR-EAF. scrap-EAF
*probably we can add an equation to check if the production of the 3 existing routes is equal to the total production included in the iProdDemandIs
* This equation calculates the initial installed capacity for each existing historical technology in the base year.
* It calculate the actual installed capacity (in Mt/year) as the total steel production demanded in the base year (this has to be changed with all the historical years) for the sector and dividing it by the historical capacity factor specific to each technology for that year.
* This establishes the starting point for tracking the capacity of historical assets/vintage.
QInitialCapISHist(allCy,ISTECH_HIST,YTIME)$(runCy(allCy) and YTIME eq '2019')..
    VInitialCapISHist(allCy,ISTECH_HIST,YTIME) =E=
    iProdHistIS(allCy, ISTECH_HIST, YTIME) * (1 / iCapFacBaseYrIS(allCy,ISTECH_HIST,YTIME));



* ENDOGENOUS SCRAPPING AND COSTING LOGIC (Including CO2/Carbon Tax) too be revised

* This equation calculates the annualized capital cost for Iron and Steel technologies.
* It converts the upfront capital investment (iCapCosIS, adjusted by capital goods index imCGI) into an equivalent annual cost over the technical lifetime (iTechLftIS) of the technology, using a discount rate (imDisc).
* This provides a standardized cost component for economic comparison across technologies.
QISAnnCapCost(allCy,ISTECH_ALL,YTIME)$(runCy(allCy))..
    VISAnnCapCost(allCy,ISTECH_ALL,YTIME) =E=
    (imDisc(allCy,YTIME) * exp(imDisc(allCy,YTIME) * iTechLftIS(allCy,ISTECH_ALL)) /
    (exp(imDisc(allCy,YTIME) * iTechLftIS(allCy,ISTECH_ALL)) - 1))
    * iCapCosIS(allCy,ISTECH_ALL,YTIME) * imCGI(allCy,YTIME);

* This equation calculates the total production cost per unit of steel (e.g., kEuro/Mton of steel) for each technology. PLEASE CONSIDER THAT RAW MATERIAL COST ARE NOT INCLUDED
* It COnsiders:
* Annualized capital costs (VISAnnCapCost) and fixed operation & maintenance (O&M) costs (iFixOMCostIS), divided by the plant's availability rate (iAvailRateIS) PLEASE CONSIDER THAT HERE WE DO NOT HAVE THE SHARE OF THE FIXED COST AS GEM E3 NEEDS
* Variable O&M costs (iVarOMCostIS) per unit of production.
* Fuel costs: Specific fuel consumption (iSpecFuelConsIS or iSpecFuelConsIS_New depending on the fact that the technology is already existing or it is new) multiplied by fuel price (VmPriceFuelSubsecCarVal).
* CO2 costs: The amount of CO2 emitted per unit of fuel (iCo2EmFacIS) is multiplied by the CO2 price (VmCarVal) if not captured (1 - imCO2CaptRate), or by the CO2 sequestration cost (VmCstCO2SeqCsts) if captured (imCO2CaptRate). This directly incorporates carbon pricing policies into technology economics.
QISTotProdCost(allCy,ISTECH_ALL,YTIME)$(runCy(allCy))..
    VISTotProdCost(allCy,ISTECH_ALL,YTIME) =E=
    (VISAnnCapCost(allCy,ISTECH_ALL,YTIME) + iFixOMCostIS(allCy,ISTECH_ALL,YTIME)) / (iAvailRateIS(ISTECH_ALL,YTIME))
    + iVarOMCostIS(allCy,ISTECH_ALL,YTIME)
    + sum(EF,
        ( (iSpecFuelConsIS_Hist(allCy,ISTECH_ALL,EF)$ISTECH_HIST(ISTECH_ALL)
         + iSpecFuelConsIS_New(allCy,ISTECH_ALL,EF,YTIME)$ISTECH_NEW(ISTECH_ALL) )
        * VmPriceFuelSubsecCarVal(allCy,"IS",EF,YTIME)
        )
      + ( (iSpecFuelConsIS_Hist(allCy,ISTECH_ALL,EF)$ISTECH_HIST(ISTECH_ALL)
         + iSpecFuelConsIS_New(allCy,ISTECH_ALL,EF,YTIME)$ISTECH_NEW(ISTECH_ALL) )
        * iCo2EmFacIS(allCy,EF,YTIME) * (imCO2CaptRate(allCy,ISTECH_ALL,YTIME) * VmCstCO2SeqCsts(allCy,YTIME) + (1 - imCO2CaptRate(allCy,ISTECH_ALL,YTIME)) * sum(NAP, VmCarVal(allCy,NAP,YTIME)))
        )
    );

* This equation computes the endogenous scrapping index for historical Iron and Steel plants. NEED TO BE DOUBLECHECKED
* This index determines the likelihood or fraction of historical capacity being prematurely decommissioned (i.e. scrapped) due to its non-competitiveness compared to other available technologies (both historical and new).
* It is calculated as the inverse of the historical technology's total production cost (raised to the power of -5 to amplify differences but this need to be checked and calibrate - divided by the sum of this value and a scaled sum of total production costs for all technologies. A lower cost (higher inverse) leads to a higher index, meaning less scrapping.
QIndxEndogScrapIS(allCy,ISTECH_HIST,YTIME)$(runCy(allCy))..
    VIndxEndogScrapIS(allCy,ISTECH_HIST,YTIME) =E=
    (VISTotProdCost(allCy,ISTECH_HIST,YTIME)**(-5)) /
    (VISTotProdCost(allCy,ISTECH_HIST,YTIME)**(-5) + iScaleEndogScrapIS(ISTECH_HIST) * (sum(ISTECH_ALL2,VISTotProdCost(allCy,ISTECH_ALL2,YTIME)))**(-5));


* This equation recursively calculates the available capacity of historical technologies.
* The capacity in the current year is defined as the capacity from the previous year,
* reduced by two factors:
* 1. Scheduled, age-based decommissioning (from the exogenous iDecomScheduleIS input).
* 2. Economically driven scrapping (based on the VIndxEndogScrapIS index).

QAvailCapISHist(allCy,ISTECH_HIST,YTIME)$(runCy(allCy) and YTIME.val > %fBaseY%)..

    VAvailCapISHist(allCy,ISTECH_HIST,YTIME) =E=

    (VAvailCapISHist(allCy,ISTECH_HIST,YTIME-1) * (1 - VIndxEndogScrapIS(allCy,ISTECH_HIST,YTIME))) - iDecomScheduleIS(allCy,ISTECH_HIST,YTIME);

* ---
* ACTIVITY (PRODUCTION) FOR HISTORICAL TECHNOLOGIES
* ---
* This equation limits the actual activity level (production of steel in Mt) for historical technologies to their available installed capacity.
* The model will determine the exact activity level up to this limit based on the overall demand balance.
QActivityISHist(allCy,ISTECH_HIST,YTIME)$(runCy(allCy))..
    VActivityISHist(allCy,ISTECH_HIST,YTIME) =L= VAvailCapISHist(allCy,ISTECH_HIST,YTIME);

* ---
* NEW TECHNOLOGIES AND ENDOGENOUS INVESTMENT LOGIC (Includes User Preference / Inertia)
* ---
* This equation defines the a sort of 'attractiveness' for each Iron and Steel technology. THIS MECHANISM CAN BE REVIEW
* It's derived from the total production cost. A negative sign is used so that lower costs result in a higher utility value (more attractive).
* Note: The maturity factor (iMatFacTechProd) is applied directly to the cost for new technologies to reflect cost reductions (assuming iMatFacTechProd is a cost-reducing factor, e.g., <1).
QISInvCostTech(allCy,ISTECH_ALL,YTIME)$(runCy(allCy))..
    QISInvCostTech(allCy,ISTECH_ALL,YTIME) =E=
    - (VISTotProdCost(allCy,ISTECH_ALL,YTIME) * iMatFacTechProd(allCy,ISTECH_ALL,YTIME))$ISTECH_NEW(ISTECH_ALL)
    - VISTotProdCost(allCy,ISTECH_ALL,YTIME)$ISTECH_HIST(ISTECH_ALL);

* This equation calculates the capacity gap in the Iron and Steel sector for each country and year.
* This gap represents the amount of new installed capacity (in Mt/year) that needs to be added to meet the exogenous steel production demand (iProdDemandIS).
* It is determined by subtracting the available capacity from historical technologies (VAvailCapISHist) and the new technologies already installed in the previous year (VAvailCapISNew from YTIME-1) from the total steel production demand.
QGapISCapacity(allCy,YTIME)$(runCy(allCy))..
    VGapISCapacity(allCy,YTIME) =E=
    (iProdDemandIS(allCy,YTIME)
    - sum(ISTECH_HIST, VAvailCapISHist(allCy,ISTECH_HIST,YTIME))
    - sum(ISTECH_NEW, VAvailCapISNew(allCy,ISTECH_NEW,YTIME-1)));

* This equation calculates the newly installed Iron and Steel production capacity (in Mt/year) for each technology.
* This represents the endogenous investment decision. The calculated capacity gap (VGapISCapacity) is distributed among all available technologies (ISTECH_ALL) using a multinomial logit-like function. THIS HAS TO BE CHECKED
* This function incorporates a sensitivity parameter (iEIS_ChoiceSensitivity) that controls how strongly utility (derived from cost and maturity) influences market share.
QNewInstalledCapacityIS(allCy,ISTECH_ALL,YTIME)$(runCy(allCy))..
    VNewInstalledCapacityIS(allCy,ISTECH_ALL,YTIME) =E=
    VGapISCapacity(allCy,YTIME)
    * (exp(iEIS_ChoiceSensitivity(allCy) * VISInvCostTech(allCy,ISTECH_ALL,YTIME))
    / sum(ISTECH_ALL2, exp(iEIS_ChoiceSensitivity(allCy) * QISInvCostTech(allCy,ISTECH_ALL2,YTIME))));


* This equation calculates the total available capacity for new technologies,
* including the retirement of plants at the end of their technical lifetime.
QAvailCapISNew(allCy,ISTECH_NEW,YTIME)$(runCy(allCy))..
    VAvailCapISNew(allCy,ISTECH_NEW,YTIME) =E=
     sum(YYTIME$( (YYTIME.val <= YTIME.val) and (YTIME.val < YYTIME.val + iTechLftIS(allCy,ISTECH_NEW)) ), 
     VNewInstalledCapacityIS(allCy,ISTECH_NEW,YYTIME));

* This equation limits the actual activity level (production of steel in Mt) for new technologies to their available installed capacity.
* Similar to historical technologies, the model will determine the exact activity level up to this capacity limit based on the overall demand balance.
QActivityISNew(allCy,ISTECH_NEW,YTIME)$(runCy(allCy))..
    VActivityISNew(allCy,ISTECH_NEW,YTIME) =L= VAvailCapISNew(allCy,ISTECH_NEW,YTIME);

* ---
* OVERALL SECTOR ACTIVITY (PRODUCTION) AND CAPACITY FACTOR CALCULATION
* ---

* This equation calculates the total steel activity (production in Mt) for the entire Iron and Steel sector.
* It sums up the actual production from all historical technologies (VActivityISHist) and all new technologies (VActivityISNew) within a given country and year.
QTotActivityIS(allCy,YTIME)$(runCy(allCy))..
    VTotActivityIS(allCy,YTIME) =E=
    sum(ISTECH_HIST, VActivityISHist(allCy,ISTECH_HIST,YTIME)) + sum(ISTECH_NEW, VActivityISNew(allCy,ISTECH_NEW,YTIME));

* Balancing equation: the total steel activity (production) for the sector has to exactly meet the exogenously defined steel production demand (iProdDemandIS).
* It ensures that the generated production of steel calculated by the model matches the external demand projection for steel.
QBalanceActDemandIS(allCy,YTIME)$(runCy(allCy))..
    VTotActivityIS(allCy,YTIME) =E= iProdDemandIS(allCy,YTIME);

* This equation calculates the capacity factor for each Iron and Steel technology in each country and year.
* It is calculated by dividing the actual activity level (production) of a technology by its available installed capacity for that year.
* This provides insight into how efficiently each plant type is being utilized.
QCapFacIS(allCy,ISTECH_ALL,YTIME)$(runCy(allCy))..
    VCapFacIS(allCy,ISTECH_ALL,YTIME) =E=
    (VActivityISHist(allCy,ISTECH_ALL,YTIME)$ISTECH_HIST(ISTECH_ALL) + VActivityISNew(allCy,ISTECH_ALL,YTIME)$ISTECH_NEW(ISTECH_ALL))
    / (VAvailCapISHist(allCy,ISTECH_ALL,YTIME)$ISTECH_HIST(ISTECH_ALL) + VAvailCapISNew(allCy,ISTECH_ALL,YTIME)$ISTECH_NEW(ISTECH_ALL));


* ---
* FUEL CONSUMPTION AND EMISSIONS
* ---

* This equation calculates the fuel consumption for historical Iron and Steel technologies.ACTUALLY THIS IS DONE ALREADY OUTSIDE THE MODEL BUT IT IS TO HAVE A SyMMETRIC STRUCTURE BETWEEN HISTORICAL TECH AND NEW TECH:
* It multiplies the actual activity level (production of steel, VActivityISHist) of each historical technology by its specific fuel consumption rate (iSpecFuelConsIS) for each fuel type.
QFuelConsISHist(allCy,ISTECH_HIST,EF,YTIME)$(runCy(allCy))..
    VFuelConsISHist(allCy,ISTECH_HIST,EF,YTIME) =E=
    VActivityISHist(allCy,ISTECH_HIST,YTIME)
    * iSpecFuelConsIS_Hist(allCy,ISTECH_HIST,EF);

* This equation calculates the fuel consumption for new Iron and Steel technologies.
* It multiplies the actual activity level (production of steel, VActivityISNew) of each new technology by its specific fuel consumption rate (iFuelSpecISNew) for each fuel type.
QFuelConsISNew(allCy,ISTECH_NEW,EF,YTIME)$(runCy(allCy))..
    VFuelConsISNew(allCy,ISTECH_NEW,EF,YTIME) =E=
    VActivityISNew(allCy,ISTECH_NEW,YTIME) * iSpecFuelConsIS_New(allCy,ISTECH_NEW,EF,YTIME);

* This equation computes the total Iron and Steel fuel demand for each fuel type.
* It sums the fuel consumption from all historical technologies (VFuelConsISHist) and all new technologies (VFuelConsISNew) to provide the aggregate fuel consumption for the entire sector.
* FUTURE INTEGRATION in OPEN PROM LINK TO MAIN ENERGY BALANCE e.g. eliminate IS
QTotFuelConsIS(allCy,EF,YTIME)$(runCy(allCy))..
    VTotFuelConsIS(allCy,EF,YTIME) =E=
    sum(ISTECH_HIST, VFuelConsISHist(allCy,ISTECH_HIST,EF,YTIME))
    + sum(ISTECH_NEW, VFuelConsISNew(allCy,ISTECH_NEW,EF,YTIME));

* This equation calculates the CO₂ emissions associated with the Iron and Steel sector.
* It multiplies the total fuel consumption (VTotFuelConsIS) for each fuel type by its corresponding CO2 emission factor (iCo2EmFacIS). This equation provides a measure of the sector's carbon footprint.
QEmissionsIS(allCy,EF,YTIME)$(runCy(allCy))..
    VEmissionsIS(allCy,EF,YTIME) =E=
    VTotFuelConsIS(allCy,EF,YTIME) * iCo2EmFacIS(allCy,EF,YTIME);

* ---
* INVESTEMENT (For investment calculation based on endogenous new capacity)
* ---
* This equation calculates the  investment required for new Iron and Steel technologies.
* It converts the endogenously determined new installed capacity (VNewInstalledCapacityIS) into  investment ( kEuro: to be checked) by multiplying it with the capital cost per unit of capacity (iCapCosIS).
QInvestISNew(allCy,ISTECH_NEW,YTIME)$(runCy(allCy))..
    VInvestISNew(allCy,ISTECH_NEW,YTIME) =E=
    VNewInstalledCapacityIS(allCy,ISTECH_NEW,YTIME) * iCapCosIS(allCy,ISTECH_NEW,YTIME);