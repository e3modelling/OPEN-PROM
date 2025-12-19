*' @title Equations of OPEN-PROMs Emissions Constraints
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * EMISSIONS CONSTRAINTS 

*' The equation computes the total CO2 equivalent greenhouse gas emissions in all countries
*' per National Allocation Plan (NAP) sector for a specific year. The result represents the 
*' sum of CO2 emissions for each NAP sector across all countries.The equation involves several components:
*' The consumption of fuels in each demand subsector, excluding heat from heat pumps, is considered.
*' The emissions are calculated based on the fuel consumption and the CO2 emission factor for each subsector.
*' Transformation Input to Thermal Power Plants is considered,
*' and the emissions are calculated based on the input and the CO2 emission factor.
*' Transformation Input to District Heating Plants : The transformation input to district heating plants is considered,
*' and emissions are calculated based on the input and the CO2 emission factor.
*' Final Consumption in Energy Sector : The final consumption in the energy sector is considered, and emissions are calculated based
*' on the consumption and the CO2 emission factor.
*' Electricity Production: The emissions from electricity production are considered, including adjustments for plant efficiency,
*' CO2 emission factors, and the CO2 capture rate for plants with carbon capture and storage.
*' The equation provides a comprehensive approach to calculating CO2eq emissions for each NAP sector, considering various aspects of fuel consumption
*' and transformation across different subsectors. The result represents the overall CO2 emissions for each NAP sector across
*' all countries for the specified year.
$ontext
Q07GrnnHsEmisCO2Equiv(NAP,YTIME)$(TIME(YTIME))..
         V07GrnnHsEmisCO2Equiv(NAP,YTIME)
          =E=
        (
        sum(allCy,
                 sum((EFS,INDSE)$(SECTTECH(INDSE,EFS)  $NAPtoALLSBS(NAP,INDSE)),
                      VmConsFuel(allCy,INDSE,EFS,YTIME) * imCo2EmiFac(allCy,INDSE,EFS,YTIME)) !! final consumption
                +
                 sum(PGEF, VmInpTransfTherm(allCy,PGEF,YTIME)*imCo2EmiFac(allCy,"PG",PGEF,YTIME)$(not h2f1(pgef))) !! input to power generation sector
                 +
                 sum(EFS, VmTransfInputDHPlants(allCy,EFS,YTIME)*imCo2EmiFac(allCy,"PG",EFS,YTIME)) !! input to district heating plants
                 +
                 sum(EFS, VmConsFiEneSec(allCy,EFS,YTIME)*imCo2EmiFac(allCy,"PG",EFS,YTIME)) !! consumption of energy branch

                 -
                 sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                         VmProdElec(allCy,CCS,YTIME)*smTWhToMtoe/imPlantEffByType(allCy,CCS,YTIME)*
                         imCo2EmiFac(allCy,"PG",PGEF,YTIME)*imCO2CaptRate(allCy,CCS,YTIME)))));   !! CO2 captured by CCS plants in power generation
$offtext

*' The equation computes the total CO2 equivalent greenhouse gas emissions in all countries for a specific year.
*' The result represents the sum of total CO2eq emissions across all countries. The summation is performed over the NAP (National Allocation Plan) sectors,
*' considering the total CO2 GHG emissions per NAP sectorfor each country. This equation provides a concise and systematic approach to aggregating
*' greenhouse gas emissions at a global level, considering contributions from different sectors and countries. 
$ontext
q07GrnnHsEmisCO2EquivAllCntr(YTIME)$(TIME(YTIME))..

         v07GrnnHsEmisCO2EquivAllCntr(YTIME) 
         =E=
         sum(NAP, V07GrnnHsEmisCO2Equiv(NAP,YTIME));
$offtext

*' Compute households expenditures on energy by utilizing the sum of consumption of remaining substitutable equipment multiplied by the fuel prices per subsector and fuel 
*' minus the efficiency values divided by CO2 emission factors per subsector and multiplied by the sum of carbon prices for all countries and adding the Electricity price
*' to Industrial and Residential Consumers multiplied by Consumption of non-substituable electricity in Industry and Tertiary divided by TWh to Mtoe conversion factor.
$ontext
q07ExpendHouseEne(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
                 v07ExpendHouseEne(allCy,YTIME)
                 =E= 
                 SUM(DSBS$HOU(DSBS),SUM(EF$SECTTECH(dSBS,EF),VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)*(VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)-imEffValueInDollars(allCy,DSBS,YTIME)/
                 1000-imCo2EmiFac(allCy,"PG",EF,YTIME)*sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))/1000)))
                                          +VmPriceElecIndResNoCliPol(allCy,"R",YTIME)*VmConsElecNonSubIndTert(allCy,"HOU",YTIME)/smTWhToMtoe;
VmConsElecNonSubIndTert --> NO LONGER                                          
$offtext

* -----------------------------------------------------------------------------
* 1. REDUCTION FRACTION
* Find the maximum abatement potential available where the MAC Cost is 
* less than or equal to the current Carbon Price.
* -----------------------------------------------------------------------------
Q07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    smax(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME) * p07UnitConvFactor(E07SrcMacAbate)), 
         i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC, YTIME));

* -----------------------------------------------------------------------------
* 2. TOTAL ABATEMENT COST
* Calculate the area under the curve (Sum of: Step Size * Step Cost)
* Only for steps strictly below or equal to the Carbon Price.
* Multiplied by Baseline Emissions to get total monetary cost.
* -----------------------------------------------------------------------------
Q07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    sum(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME)), 
        p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME) * p07MacCost(E07MAC));

* -----------------------------------------------------------------------------
* EQUATION 3: ACTUAL EMISSIONS
* Emissions = Baseline * (1 - ReductionFraction)
* -----------------------------------------------------------------------------
Q07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    i07DataCh4N2OFEmis(allCy, E07SrcMacAbate, YTIME)  - V07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME);