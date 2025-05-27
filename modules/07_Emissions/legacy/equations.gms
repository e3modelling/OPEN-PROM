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
QGrnnHsEmisCO2Equiv(NAP,YTIME)$(TIME(YTIME))..
         VGrnnHsEmisCO2Equiv(NAP,YTIME)
          =E=
        (
        sum(allCy,
                 sum((EFS,INDSE)$(SECTTECH(INDSE,EFS)  $NAPtoALLSBS(NAP,INDSE)),
                      VMVConsFue(allCy,INDSE,EFS,YTIME) * iCo2EmiFac(allCy,INDSE,EFS,YTIME)) !! final consumption
                +
                 sum(PGEF, VMVInpTransfTherm(allCy,PGEF,YTIME)*iCo2EmiFac(allCy,"PG",PGEF,YTIME)$(not h2f1(pgef))) !! input to power generation sector
                 +
                 sum(EFS, VMVTransfInputDHPlants(allCy,EFS,YTIME)*iCo2EmiFac(allCy,"PG",EFS,YTIME)) !! input to district heating plants
                 +
                 sum(EFS, VMVConsFiEneSec(allCy,EFS,YTIME)*iCo2EmiFac(allCy,"PG",EFS,YTIME)) !! consumption of energy branch

                 -
                 sum(PGEF,sum(CCS$PGALLtoEF(CCS,PGEF),
                         VMVProdElec(allCy,CCS,YTIME)*sTWhToMtoe/iPlantEffByType(allCy,CCS,YTIME)*
                         iCo2EmiFac(allCy,"PG",PGEF,YTIME)*iCO2CaptRate(allCy,CCS,YTIME)))));   !! CO2 captured by CCS plants in power generation
$offtext

*' The equation computes the total CO2 equivalent greenhouse gas emissions in all countries for a specific year.
*' The result represents the sum of total CO2eq emissions across all countries. The summation is performed over the NAP (National Allocation Plan) sectors,
*' considering the total CO2 GHG emissions per NAP sectorfor each country. This equation provides a concise and systematic approach to aggregating
*' greenhouse gas emissions at a global level, considering contributions from different sectors and countries. 
$ontext
qGrnnHsEmisCO2EquivAllCntr(YTIME)$(TIME(YTIME))..

         vGrnnHsEmisCO2EquivAllCntr(YTIME) 
         =E=
         sum(NAP, VGrnnHsEmisCO2Equiv(NAP,YTIME));
$offtext

*' Compute households expenditures on energy by utilizing the sum of consumption of remaining substitutable equipment multiplied by the fuel prices per subsector and fuel 
*' minus the efficiency values divided by CO2 emission factors per subsector and multiplied by the sum of carbon prices for all countries and adding the Electricity price
*' to Industrial and Residential Consumers multiplied by Consumption of non-substituable electricity in Industry and Tertiary divided by TWh to Mtoe conversion factor.
$ontext
qExpendHouseEne(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
                 vExpendHouseEne(allCy,YTIME)
                 =E= 
                 SUM(DSBS$HOU(DSBS),SUM(EF$SECTTECH(dSBS,EF),VMVConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)*(VMVPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)-iEffValueInDollars(allCy,DSBS,YTIME)/
                 1000-iCo2EmiFac(allCy,"PG",EF,YTIME)*sum(NAP$NAPtoALLSBS(NAP,"PG"),VCarVal(allCy,NAP,YTIME))/1000)))
                                          +VMVPriceElecIndResNoCliPol(allCy,"R",YTIME)*VMVConsElecNonSubIndTert(allCy,"HOU",YTIME)/sTWhToMtoe;
$offtext