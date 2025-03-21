*' @title Equations of OPEN-PROMs REST OF ENERGY BALANCE SECTORS
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * REST OF ENERGY BALANCE SECTORS

*' The equation computes the total final energy consumption in million tonnes of oil equivalent for each country ,
*' energy form sector, and time period. The total final energy consumption is calculated as the sum of final energy consumption in the
*' Industry and Tertiary sectors and the sum of final energy demand in all transport subsectors. The consumption is determined by the 
*' relevant link between model subsectors and fuels.
QConsFinEneCountry(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsFinEneCountry(allCy,EFS,YTIME)
             =E=
         sum(INDDOM,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(INDDOM,EF) ), VConsFuel(allCy,INDDOM,EF,YTIME)))
         +
         sum(TRANSE,
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(TRANSE,EF)), VDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)));

*' The equation computes the total final energy consumption in million tonnes of oil equivalent 
*' for all countries at a specific time period. This is achieved by summing the final energy consumption for each energy
*' form sector across all countries.
$ontext
qConsTotFinEne(YTIME)$(TIME(YTIME))..
         vConsTotFinEne(YTIME) =E= sum((allCy,EFS), VConsFinEneCountry(allCy,EFS,YTIME) );     
$offtext

*' The equation computes the final non-energy consumption in million tonnes of oil equivalent
*' for a given energy form sector. The calculation involves summing the consumption of fuels in each non-energy and bunkers
*' demand subsector based on the corresponding fuel aggregation for the supply side. This process is performed 
*' for each time period.
QConsFinNonEne(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsFinNonEne(allCy,EFS,YTIME)
             =E=
         sum(NENSE$(not sameas("BU",NENSE)),
             sum(EF$(EFtoEFS(EF,EFS) $SECTTECH(NENSE,EF) ), VConsFuel(allCy,NENSE,EF,YTIME)));  

*' The equation computes the distribution losses in million tonnes of oil equivalent for a given energy form sector.
*' The losses are determined by the rate of losses over available for final consumption multiplied by the sum of total final energy
*' consumption and final non-energy consumption. This calculation is performed for each time period.
*' Please note that distribution losses are not considered for the hydrogen sector.
QLossesDistr(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VLossesDistr(allCy,EFS,YTIME)
             =E=
         (iRateLossesFinCons(allCy,EFS,YTIME) * (VConsFinEneCountry(allCy,EFS,YTIME) + VConsFinNonEne(allCy,EFS,YTIME)))$(not H2EF(EFS))
         +
         (  VDemTotH2(allCy,YTIME) - sum(SBS$H2SBS(SBS), VDemSecH2(allCy,SBS,YTIME)))$H2EF(EFS);  

*' The equation calculates the transformation output from district heating plants .
*' This transformation output is determined by summing over different demand sectors and district heating systems 
*' that correspond to the specified energy form set. The equation then sums over these district heating 
*' systems and calculates the consumption of fuels in each of these sectors. The resulting value represents the 
*' transformation output from district heating plants in million tonnes of oil equivalent.
QOutTransfDhp(allCy,STEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VOutTransfDhp(allCy,STEAM,YTIME)
             =E=
         sum(DOMSE,
             sum(DH$(EFtoEFS(DH,STEAM) $SECTTECH(DOMSE,DH)), VConsFuel(allCy,DOMSE,DH,YTIME)));

*' The equation calculates the transformation input to district heating plants.
*' This transformation input is determined by summing over different district heating systems that correspond to the
*' specified energy form set . The equation then sums over different demand sectors within each 
*' district heating system and calculates the consumption of fuels in each of these sectors, taking into account
*' the efficiency of district heating plants. The resulting value represents the transformation input to district
*' heating plants in million tonnes of oil equivalent.
QTransfInputDHPlants(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VTransfInputDHPlants(allCy,EFS,YTIME)
             =E=
         sum(DH$DHtoEF(DH,EFS),
             sum(DOMSE$SECTTECH(DOMSE,DH),VConsFuel(allCy,DOMSE,DH,YTIME)) / iEffDHPlants(allCy,EFS,YTIME));

*' The equation calculates the refineries' capacity for a given scenario and year.
*' The calculation is based on a residual factor, the previous year's capacity, and a production scaling
*' factor that takes into account the historical consumption trends for different energy forms. The scaling factor is
*' influenced by the base year and the production scaling parameter. The result represents the refineries'
*' capacity in million barrels per day (Million Barrels/day).
QCapRef(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VCapRef(allCy,YTIME)
             =E=
         [
         iResRefCapacity(allCy,YTIME) * VCapRef(allCy,YTIME-1)
         *
         (1$(ord(YTIME) le 10) +
         (prod(rc,
         (sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
         )
         $(ord(YTIME) gt 10)
         )     ] $iRefCapacity(allCy,"%fStartHorizon%")+0;

*' The equation calculates the transformation output from refineries for a specific energy form 
*' in a given scenario and year. The output is computed based on a residual factor, the previous year's output, and the
*' change in refineries' capacity. The calculation includes considerations for the base year and adjusts the result accordingly.
*' The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
QOutTransfRefSpec(allCy,EFS,YTIME)$(TIME(YTIME) $EFtoEFA(EFS,"LQD") $runCy(allCy))..
         VOutTransfRefSpec(allCy,EFS,YTIME)
             =E=
         [
         iResTransfOutputRefineries(allCy,EFS,YTIME) * VOutTransfRefSpec(allCy,EFS,YTIME-1)
         * (VCapRef(allCy,YTIME)/VCapRef(allCy,YTIME-1))**0.3
         * (
             1$(TFIRST(YTIME-1) or TFIRST(YTIME-2))
             +
             (
                sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry(allCy,EF,YTIME-1))/sum(EF$EFtoEFA(EF,"LQD"),VConsFinEneCountry(allCy,EF,YTIME-2))
             )$(not (TFIRST(YTIME-1) or TFIRST(YTIME-2)))
           )**(0.7)  ]$iRefCapacity(allCy,"%fStartHorizon%")+0; 

*' The equation calculates the transformation input to refineries for the energy form Crude Oil
*' in a specific scenario and year. The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation
*' output from refineries for the given energy form and year to the output in the previous year. This calculation is conditional on the refineries' capacity
*' being active in the specified starting horizon.The result represents the transformation input to refineries for crude oil in million tons of oil equivalent.
QInputTransfRef(allCy,"CRO",YTIME)$(TIME(YTIME) $runCy(allCy))..
         VInputTransfRef(allCy,"CRO",YTIME)
             =E=
         [
         VInputTransfRef(allCy,"CRO",YTIME-1) *
         sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec(allCy,EFS,YTIME)) /
         sum(EFS$EFtoEFA(EFS,"LQD"), VOutTransfRefSpec(allCy,EFS,YTIME-1))  ]$iRefCapacity(allCy,"%fStartHorizon%")+0;                   

*' The equation calculates the transformation output from nuclear plants for electricity production 
*' in a specific scenario and year. The output is computed as the sum of electricity production from all nuclear power plants in the given
*' scenario and year, multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent.
*' The result represents the transformation output from nuclear plants for electricity production in million tons of oil equivalent.
QOutTransfNuclear(allCy,"ELC",YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VOutTransfNuclear(allCy,"ELC",YTIME) =E=SUM(PGNUCL,VProdElec(allCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation computes the transformation input to nuclear plants for a specific scenario and year.
*' The input is calculated based on the sum of electricity production from all nuclear power plants in the given scenario and year, divided
*' by the plant efficiency and multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe).
*' The result represents the transformation input to nuclear plants in million tons of oil equivalent.
QInpTransfNuclear(allCy,"NUC",YTIME)$(TIME(YTIME)$(runCy(allCy)))..
        VInpTransfNuclear(allCy,"NUC",YTIME) =E=SUM(PGNUCL,VProdElec(allCy,PGNUCL,YTIME)/iPlantEffByType(allCy,PGNUCL,YTIME))*sTWhToMtoe;

*' The equation computes the transformation input to thermal power plants for a specific power generation form 
*' in a given scenario and year. The input is calculated based on the following conditions:
*' For conventional power plants that are not geothermal or nuclear, the transformation input is determined by the electricity production
*' from the respective power plant multiplied by the conversion factor from terawatt-hours to million tons of oil equivalent (sTWhToMtoe), divided by the
*' plant efficiency.For geothermal power plants, the transformation input is based on the electricity production from the geothermal plant multiplied by the conversion
*' factor.For combined heat and power plants , the input is calculated as the sum of the consumption of fuels in various demand subsectors and the electricity
*' production from the CHP plant . This sum is then divided by a factor based on the year to account for variations over time.The result represents
*' the transformation input to thermal power plants in million tons of oil equivalent.
QInpTransfTherm(allCy,PGEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VInpTransfTherm(allCy,PGEF,YTIME)
             =E=
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$((not PGGEO(PGALL)) $(not PGNUCL(PGALL)))),
             VProdElec(allCy,PGALL,YTIME) * sTWhToMtoe /  iPlantEffByType(allCy,PGALL,YTIME))
        +
        sum(PGALL$(PGALLtoEF(PGALL,PGEF)$PGGEO(PGALL)),
             VProdElec(allCy,PGALL,YTIME) * sTWhToMtoe / 0.15) 
        +
        sum(CHP$CHPtoEF(CHP,PGEF),  sum(INDDOM,VConsFuel(allCy,INDDOM,CHP,YTIME))+sTWhToMtoe*VProdElecCHP(allCy,CHP,YTIME))/(0.8+0.1*(ord(YTIME)-10)/32);

*' The equation calculates the transformation output from thermal power stations for a specific energy branch
*' in a given scenario and year. The result is computed based on the following conditions: 
*' If the energy branch is related to electricity, the transformation output from thermal power stations is the sum of electricity production from
*' conventional power plants and combined heat and power plants. The production values are converted from terawatt-hours (TWh) to
*' million tons of oil equivalent.
*' If the energy branch is associated with steam, the transformation output is determined by the sum of the consumption of fuels in various demand
*' subsectors, the rate of energy branch consumption over total transformation output, and losses.
*' The result represents the transformation output from thermal power stations in million tons of oil equivalent.
QOutTransfTherm(allCy,TOCTEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VOutTransfTherm(allCy,TOCTEF,YTIME)
             =E=
        (
             sum(PGALL$(not PGNUCL(PGALL)),VProdElec(allCy,PGALL,YTIME)) * sTWhToMtoe
             +
             sum(CHP,VProdElecCHP(allCy,CHP,YTIME)*sTWhToMtoe)
         )$ELCEF(TOCTEF)
        +
        (                                                                                                         
          sum(INDDOM,
          sum(CHP$SECTTECH(INDDOM,CHP), VConsFuel(allCy,INDDOM,CHP,YTIME)))+
          iRateEneBranCons(allCy,TOCTEF,YTIME)*(VConsFinEneCountry(allCy,TOCTEF,YTIME) + VConsFinNonEne(allCy,TOCTEF,YTIME) + VLossesDistr(allCy,TOCTEF,YTIME)) + 
          VLossesDistr(allCy,TOCTEF,YTIME)                                                                                    
         )$STEAM(TOCTEF); 
            
*' The equation calculates the total transformation input for a specific energy branch 
*' in a given scenario and year. The result is obtained by summing the transformation inputs from different sources, including
*' thermal power plants, District Heating Plants, nuclear plants, patent
*' fuel and briquetting plants, and refineries. In the case where the energy branch is "OGS"
*' (Other Gas), the total transformation input is calculated as the difference between the total transformation output and various consumption
*' and loss components. The outcome represents the total transformation input in million tons of oil equivalent.
QInpTotTransf(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VInpTotTransf(allCy,EFS,YTIME)
                 =E=
        (
            VInpTransfTherm(allCy,EFS,YTIME) + VTransfInputDHPlants(allCy,EFS,YTIME) + VInpTransfNuclear(allCy,EFS,YTIME) +
             VInputTransfRef(allCy,EFS,YTIME)     !!$H2PRODEF(EFS)
        )$(not sameas(EFS,"OGS"))
        +
        (
          VOutTotTransf(allCy,EFS,YTIME) - VConsFinEneCountry(allCy,EFS,YTIME) - VConsFinNonEne(allCy,EFS,YTIME) - iRateEneBranCons(allCy,EFS,YTIME)*
          VOutTotTransf(allCy,EFS,YTIME) - VLossesDistr(allCy,EFS,YTIME)
        )$sameas(EFS,"OGS");            

*' The equation calculates the total transformation output for a specific energy branch in a given scenario and year.
*' The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants,
*' nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
*' as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
QOutTotTransf(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VOutTotTransf(allCy,EFS,YTIME)
                 =E=
         VOutTransfTherm(allCy,EFS,YTIME) + VOutTransfDhp(allCy,EFS,YTIME) + VOutTransfNuclear(allCy,EFS,YTIME) +
         VOutTransfRefSpec(allCy,EFS,YTIME);        !!+ TONEW(allCy,EFS,YTIME)

*' The equation calculates the transfers of a specific energy branch in a given scenario and year.
*' The result is computed based on a complex formula that involves the previous year's transfers,
*' the residual for feedstocks in transfers, and various conditions.
*' In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers,
*' and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
QTransfers(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VTransfers(allCy,EFS,YTIME) =E=
         (( (VTransfers(allCy,EFS,YTIME-1)*VConsFinEneCountry(allCy,EFS,YTIME)/VConsFinEneCountry(allCy,EFS,YTIME-1))$EFTOEFA(EFS,"LQD")+
          (
                 VTransfers(allCy,"CRO",YTIME-1)*SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(allCy,EFS2,YTIME))/
                 SUM(EFS2$EFTOEFA(EFS2,"LQD"),VTransfers(allCy,EFS2,YTIME-1)))$sameas(EFS,"CRO")   )$(iFeedTransfr(allCy,EFS,"%fStartHorizon%"))$(NOT sameas("OLQ",EFS)) 
);         

*' The equation calculates the gross inland consumption excluding the consumption of a specific energy branch
*' in a given scenario and year. The result is computed by summing various components, including
*' total final energy consumption, final non-energy consumption, total transformation input and output, distribution losses, and transfers.
*' The outcome represents the gross inland consumption excluding the consumption of the specified energy branch in million tons of oil equivalent.
 QConsGrssInlNotEneBranch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsGrssInlNotEneBranch(allCy,EFS,YTIME)
                 =E=
         VConsFinEneCountry(allCy,EFS,YTIME) + VConsFinNonEne(allCy,EFS,YTIME) + VInpTotTransf(allCy,EFS,YTIME) - VOutTotTransf(allCy,EFS,YTIME) + VLossesDistr(allCy,EFS,YTIME) - 
         VTransfers(allCy,EFS,YTIME); 

*' The equation calculates the gross inland consumptionfor a specific energy branch in a given scenario and year.
*' This is computed by summing various components, including total final energy consumption, final consumption in the energy sector, final non-energy consumption,
*' total transformation input and output, distribution losses, and transfers. The result represents the gross inland consumption in million tons of oil equivalent.
QConsGrssInl(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsGrssInl(allCy,EFS,YTIME)
                 =E=
         VConsFinEneCountry(allCy,EFS,YTIME) + VConsFiEneSec(allCy,EFS,YTIME) + VConsFinNonEne(allCy,EFS,YTIME) + VInpTotTransf(allCy,EFS,YTIME) - VOutTotTransf(allCy,EFS,YTIME) +
          VLossesDistr(allCy,EFS,YTIME) - VTransfers(allCy,EFS,YTIME);  

*' The equation calculates the primary production for a specific primary production definition in a given scenario and year.
*' The computation involves different scenarios based on the type of primary production definition:
*' For primary production definitions the primary production is directly proportional to the rate of primary production in total primary needs,
*' and it depends on gross inland consumption not including the consumption of the energy branch.
*' For Natural Gas primary production, the calculation considers a specific formula involving the rate of primary production in total primary needs, residuals for
*' hard coal, natural gas, and oil primary production, the elasticity related to gross inland consumption for natural gas, and other factors. Additionally, there is a lag
*' effect with coefficients for primary oil production.
*' For Crude Oil primary production, the computation includes the rate of primary production in total primary needs, residuals for hard coal, natural gas, and oil
*' primary production, the fuel primary production, and a product term involving the polynomial distribution lag coefficients for primary oil production.
*' The result represents the primary production in million tons of oil equivalent.
QProdPrimary(allCy,PPRODEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VProdPrimary(allCy,PPRODEF,YTIME)
                 =E=  [
         (
             iRatePriProTotPriNeeds(allCy,PPRODEF,YTIME) * (VConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME) +  VConsFiEneSec(allCy,PPRODEF,YTIME))
         )$(not (sameas(PPRODEF,"CRO")or sameas(PPRODEF,"NGS")))
         +
         (
             iResHcNgOilPrProd(allCy,PPRODEF,YTIME) * VProdPrimary(allCy,PPRODEF,YTIME-1) *
             (VConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME)/VConsGrssInlNotEneBranch(allCy,PPRODEF,YTIME-1))**iNatGasPriProElst(allCy)
         )$(sameas(PPRODEF,"NGS") )

         +(
           iResHcNgOilPrProd(allCy,PPRODEF,YTIME) *  iFuelPriPro(allCy,PPRODEF,YTIME) *
           prod(kpdl$(ord(kpdl) lt 5),
                         (iPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1))/iPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1)))
                         **(0.2*iPolDstrbtnLagCoeffPriOilPr(kpdl)))
         )$sameas(PPRODEF,"CRO")   ]$iRatePriProTotPriNeeds(allCy,PPRODEF,YTIME);   

*' The equation calculates the fake exports for a specific energy branch
*' in a given scenario and year. The computation is based on the fuel exports for
*' the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
QExp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..
         VExp(allCy,EFS,YTIME)
                 =E=
         (
                 iFuelExprts(allCy,EFS,YTIME)
         );

*' The equation computes the fake imports for a specific energy branch 
*' in a given scenario and year. The calculation is based on different conditions for various energy branches,
*' such as electricity, crude oil, and natural gas. The equation involves gross inland consumption,
*' fake exports, consumption of fuels in demand subsectors, electricity imports,
*' and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
QImp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..

         VImp(allCy,EFS,YTIME)

                 =E=
         (
            iRatioImpFinElecDem(allCy,YTIME) * (VConsFinEneCountry(allCy,EFS,YTIME) + VConsFinNonEne(allCy,EFS,YTIME)) + VExp(allCy,EFS,YTIME)
         + iElecImp(allCy,YTIME)
         )$ELCEF(EFS)
         +
         (
            VConsGrssInl(allCy,EFS,YTIME)+ VExp(allCy,EFS,YTIME) + VConsFuel(allCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VProdPrimary(allCy,EFS,YTIME)
         )$(sameas(EFS,"CRO"))

         +
         (
            VConsGrssInl(allCy,EFS,YTIME)+ VExp(allCy,EFS,YTIME) + VConsFuel(allCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS)
            - VProdPrimary(allCy,EFS,YTIME)
         )$(sameas(EFS,"NGS"))
*         +iImpExp(allCy,"NGS",YTIME)$(sameas(EFS,"NGS"))
         +
         (
            (1-iRatePriProTotPriNeeds(allCy,EFS,YTIME)) *
            (VConsGrssInl(allCy,EFS,YTIME) + VExp(allCy,EFS,YTIME) + VConsFuel(allCy,"BU",EFS,YTIME)$SECTTECH("BU",EFS) )
         )$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));

*' The equation computes the net imports for a specific energy branch 
*' in a given scenario and year. It subtracts the fake exports from the fake imports for
*' all fuels except natural gas . The result represents the net imports in million tons of oil equivalent.
QImpNetEneBrnch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VImpNetEneBrnch(allCy,EFS,YTIME)
                 =E=
         VImp(allCy,EFS,YTIME) - VExp(allCy,EFS,YTIME);
                               
*' The equation calculates the final energy consumption in the energy sector.
*' It considers the rate of energy branch consumption over the total transformation output.
*' The final consumption is determined based on the total transformation output and primary production for energy
*' branches, excluding Oil, Coal, and Gas. The result, VConsFiEneSec, represents the final consumption in million tons of
*' oil equivalent for the specified scenario and year.
QConsFiEneSec(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
         VConsFiEneSec(allCy,EFS,YTIME)
                 =E=
         iRateEneBranCons(allCy,EFS,YTIME) *
         (
           (
              VOutTotTransf(allCy,EFS,YTIME) +
              VProdPrimary(allCy,EFS,YTIME)$(sameas(EFS,"CRO") or sameas(EFS,"NGS"))
            )$(not TOCTEF(EFS))
            +
            (
              VConsFinEneCountry(allCy,EFS,YTIME) + VConsFinNonEne(allCy,EFS,YTIME) + VLossesDistr(allCy,EFS,YTIME)
            )$TOCTEF(EFS)
         );                              
