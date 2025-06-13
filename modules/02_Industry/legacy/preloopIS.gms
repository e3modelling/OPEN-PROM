* ---
* Iron and Steel Module: Preloop (Variable Initialization)
* This section sets initial values and fixes certain variables for the base year or across all years.

* ---

* Initialize historical production parameter (only for base year, values loaded from input file)
iProdHistIS(runCy,ISTECH_HIST,YTIME)$(YTIME eq '2019') = 0; !! Or a small positive number if direct input is zero

* Initialize newly introduced variables to default values.
VISAnnCapCost.L(runCy,ISTECH_ALL,YTIME) = 0;
VISTotProdCost.L(runCy,ISTECH_ALL,YTIME) = 100; ! Initialize with a plausible cost (e.g., 100 kEuro/Mt) to avoid division by zero or numerical issues.
VIndxEndogScrapIS.L(runCy,ISTECH_HIST,YTIME) = 1; ! Default: Assume no endogenous scrapping initially (index of 1 means 100% retained).
VISInvCostTech.L(runCy,ISTECH_ALL,YTIME) = -100; ! Initialize utility to a negative value. This should reflect a cost-based nature TO BE CHECKED

* Initialize capacity variables.
VAvailCapISHist.L(runCy,ISTECH_HIST,YTIME) = 0;
VAvailCapISNew.L(runCy,ISTECH_NEW,YTIME) = 0;
VNewInstalledCapacityIS.L(runCy,ISTECH_ALL,YTIME) = 0;

* Initialize activity/production variables.
VActivityISHist.L(runCy,ISTECH_HIST,YTIME) = 0;
VActivityISNew.L(runCy,ISTECH_NEW,YTIME) = 0;
VTotActivityIS.L(runCy,YTIME) = 0;

* Initialize capacity factor.
VCapFacIS.L(runCy,ISTECH_ALL,YTIME) = 0.8; ! Initialize with a plausible capacity factor (e.g., 80%).

* Initialize fuel consumption and emissions variables (these will be calculated by equations).
VFuelConsISHist.L(runCy,ISTECH_HIST,EF,YTIME) = 0;
VFuelConsISNew.L(runCy,ISTECH_NEW,EF,YTIME) = 0;
VTotFuelConsIS.L(runCy,EF,YTIME) = 0;
VEmissionsIS.L(runCy,EF,YTIME) = 0;

* Initialize investment variable.
VInvestISNew.L(runCy,ISTECH_NEW,YTIME) = 0;

* Initialize capacity gap variable.
VGapISCapacity.L(runCy,YTIME) = 0;

* Fix initial installed capacity for historical technologies in the base year.
* This ensures the model starts with the correct inferred historical capacity.
VInitialCapISHist.FX(allCy,ISTECH_HIST,YTIME)$(YTIME eq '2019') = iProdHistIS(allCy, ISTECH_HIST, YTIME) * (1 / iCapFacBaseYrIS(allCy,ISTECH_HIST,YTIME));

* Fix total activity (production) for the base year to match the exogenous demand.
* This ensures the model starts with a balanced demand-supply for the initial year.
VTotActivityIS.FX(runCy,YTIME)$(YTIME eq '2019') = iProdDemandIS(runCy,YTIME);

* For historical technologies, set their activity (production) in the base year if needed for consistency.
* This assumes historical production data is available and should match the overall demand.
* VActivityISHist.FX(runCy,ISTECH_HIST,YTIME)$(YTIME eq '2019') = iActivityISProdHist(runCy,ISTECH_HIST,YTIME); !! Use original historical activity if available.