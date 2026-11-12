*' @title Equations of OPEN-PROMs Emissions Constraints
*' @code

*' GENERAL INFORMATION
*' These equations calculate gross and net CO2 emissions from demand and supply,
*' process emissions from hydrogen production, and non-CO2 mitigation outcomes.
*' Non-CO2 abatement is determined using marginal abatement cost (MAC) curves.

*' EMISSIONS CONSTRAINTS

*' Inactive equation for aggregating CO2-equivalent emissions over NAP sectors.
*' Retained for reference; this equation is inside a GAMS text block.
$ontext
q07GrnnHsEmisCO2EquivAllCntr(YTIME)$(TIME(YTIME))..

         v07GrnnHsEmisCO2EquivAllCntr(YTIME) 
         =E=
         sum(NAP, V07GrnnHsEmisCO2Equiv(NAP,YTIME));
$offtext

*' Inactive equation estimating household energy expenditure from fuel use and prices.
*' The expression includes adjustments for efficiency values and carbon costs,
*' plus electricity expenditure for non-substitutable household electricity.
*' Retained unchanged for reference, including its legacy variable names.
$ontext
q07ExpendHouseEne(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
                 v07ExpendHouseEne(allCy,YTIME)
                 =E= 
                 SUM(DSBS$HOU(DSBS),SUM(EF$SECTTECH(dSBS,EF),VmConsRemSubEquipSubSec(allCy,DSBS,EF,YTIME)*(VmPriceFuelSubsecCarVal(allCy,DSBS,EF,YTIME)-imEffValueInDollars(allCy,DSBS,YTIME)/
                 1000-imCo2EmiFac(allCy,"PG",EF,YTIME)*sum(NAP$NAPtoALLSBS(NAP,"PG"),VmCarVal(allCy,NAP,YTIME))/1000)))
                                          +VmPriceElecIndResNoCliPol(allCy,"R",YTIME)*VmConsElecNonSubIndTert(allCy,"HOU",YTIME)/smTWhToMtoe;
VmConsElecNonSubIndTert --> NO LONGER                                          
$offtext

*' Calculates gross demand-side CO2 emissions by country, demand subsector, and year.
*' Final energy consumption is multiplied by the corresponding fuel emission factor
*' and summed across energy forms.
Q07GrossEmissCO2Demand(allCy,DSBS,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V07GrossEmissCO2Demand(allCy,DSBS,YTIME)
        =E=   
    SUM(EFS,
      VmFinalEnergy(allCy,DSBS,EFS,YTIME) *
      imCo2EmiFac(allCy,DSBS,EFS,YTIME)
    );

*' Calculates gross supply-side CO2 emissions by country, supply subsector, and year.
*' Emissions arise from transformation inputs in SSBSENERGY sectors and from final
*' energy consumption within supply sectors, weighted by fuel emission factors.
Q07GrossEmissCO2Supply(allCy,SSBS,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V07GrossEmissCO2Supply(allCy,SSBS,YTIME)
        =E=   
    SUM(EFS,
      (
        V03InpTotTransf(allCy,SSBS,EFS,YTIME)$SSBSENERGY(SSBS) +
        VmConsFiEneSec(allCy,SSBS,EFS,YTIME) 
      ) * imCo2EmiFac(allCy,SSBS,EFS,YTIME)
    );

*' Calculates gross CO2 process emissions from hydrogen production (H2P) only.
*' Transformation inputs are multiplied by their sector-specific emission factors
*' and summed across energy forms; other supply sectors contribute zero.
Q07GrossEmissCO2Processes(allCy,SSBS,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V07GrossEmissCO2Processes(allCy,SSBS,YTIME)
        =E=   
    SUM(EFS,
      V03InpTotTransf(allCy,SSBS,EFS,YTIME) * 
      imCo2EmiFac(allCy,SSBS,EFS,YTIME)
    )$sameas(SSBS,"H2P");

*' Determines economically available absolute non-CO2 abatement by source and year.
*' Selects the maximum reduction from MAC steps whose cost does not exceed the
*' exogenous carbon value adjusted by the source-specific unit conversion factor.
*' The equation is active only for periods with ord(YTIME) greater than 17.
Q07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy))$(ord(YTIME) > 17))..
    V07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    smax(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME) * p07UnitConvFactor(E07SrcMacAbate)), 
         i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC, YTIME));

*' Calculates total non-CO2 abatement costs by source, country, and year.
*' Sums marginal reductions multiplied by MAC step costs and source-specific cost
*' correction factors for steps below the adjusted exogenous carbon price.
*' The correction factor accounts for differences in source-specific units.
Q07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07CostAbateBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    sum(E07MAC$(p07MacCost(E07MAC) <= iCarbValYrExog(allCy, YTIME) * p07UnitConvFactor(E07SrcMacAbate)), 
        p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME) * p07MacCost(E07MAC) * p07CostCorrection(E07SrcMacAbate));

*' Calculates remaining non-CO2 emissions by source, country, and year.
*' Subtracts absolute MAC-based abatement from exogenous baseline emissions.
*' Source-specific output units are retained: CH4 and N2O in Mt C-eq and
*' F-gases in kt of gas, as specified in the input data.
Q07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07EmiActBySrcRegTim(E07SrcMacAbate, allCy, YTIME)
    =E=
    i07DataCh4N2OFEmis(allCy, E07SrcMacAbate, YTIME)  - V07RedAbsBySrcRegTim(E07SrcMacAbate, allCy, YTIME);

*' Calculates an adjusted net CO2 emissions measure by country and year.
*' Gross supply- and demand-side emissions are reduced by CCS capture and CDR.
*' The square-root term adds the absolute value of the negative of this balance,
*' making the result twice the positive balance, or zero when it is negative,
*' before adding a small positive constant (1e-6).
*' The expression is not a simple signed net-emissions balance.
Q07EmissionsNet(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V07EmissionsNet(allCy,YTIME)
    =E=
    (sum(SSBS, V07GrossEmissCO2Supply(allCy,SSBS,YTIME))
    + sum(DSBS, V07GrossEmissCO2Demand(allCy,DSBS,YTIME))
    - sum((SBS,EFS)$SECtoEF(SBS,EFS), V06CO2CaptureCCS(allCy,SBS,EFS,YTIME))
    - sum(CDRTECH, V06CapCDR(allCy,CDRTECH,YTIME)) * 1e-6)
    +
    sqrt(
        sqr(-(sum(SSBS, V07GrossEmissCO2Supply(allCy,SSBS,YTIME))
        + sum(DSBS, V07GrossEmissCO2Demand(allCy,DSBS,YTIME))
        - sum((SBS,EFS)$SECtoEF(SBS,EFS), V06CO2CaptureCCS(allCy,SBS,EFS,YTIME))
        - sum(CDRTECH, V06CapCDR(allCy,CDRTECH,YTIME)) * 1e-6))
    ) + 1e-6
    ;
