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
Q03ConsFinEneCountry(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFinEneCountry(allCy,EFS,YTIME)
        =E=
    sum(INDDOM,
      sum(EF$(EFtoEFS(EF,EFS) $SECtoEF(INDDOM,EF) ), VmConsFuel(allCy,INDDOM,EF,YTIME))
    ) +
    sum(TRANSE,
      sum(EF$(EFtoEFS(EF,EFS) $SECtoEF(TRANSE,EF)),
        VmDemFinEneTranspPerFuel(allCy,TRANSE,EF,YTIME)
      )
    ) +
    sum(EF$(EFtoEFS(EF,EFS) $SECtoEF("DAC",EF)),VmConsFuelDACProd(allCy,EF,YTIME));

*' The equation computes the total final energy consumption in million tonnes of oil equivalent 
*' for all countries at a specific time period. This is achieved by summing the final energy consumption for each energy
*' form sector across all countries.
$ontext
q03ConsTotFinEne(YTIME)$(TIME(YTIME))..
         v03ConsTotFinEne(YTIME) =E= sum((allCy,EFS), VmConsFinEneCountry(allCy,EFS,YTIME) );     
$offtext

*' The equation computes the final non-energy consumption in million tonnes of oil equivalent
*' for a given energy form sector. The calculation involves summing the consumption of fuels in each non-energy and bunkers
*' demand subsector based on the corresponding fuel aggregation for the supply side. This process is performed 
*' for each time period.
Q03ConsFinNonEne(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFinNonEne(allCy,EFS,YTIME)
        =E=
    sum(NENSE$(not sameas("BU",NENSE)),
      sum(EF$(EFtoEFS(EF,EFS)$SECtoEF(NENSE,EF)), VmConsFuel(allCy,NENSE,EF,YTIME))
    );  

*' The equation computes the distribution losses in million tonnes of oil equivalent for a given energy form sector.
*' The losses are determined by the rate of losses over available for final consumption multiplied by the sum of total final energy
*' consumption and final non-energy consumption. This calculation is performed for each time period.
*' Please note that distribution losses are not considered for the hydrogen sector.
Q03LossesDistr(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmLossesDistr(allCy,EFS,YTIME)
        =E=
    (
      imRateLossesFinCons(allCy,EFS,YTIME) * 
      (
        VmConsFinEneCountry(allCy,EFS,YTIME) + 
        VmConsFinNonEne(allCy,EFS,YTIME) +
        V03ProdPrimary(allCy,EFS,YTIME)$sameas(EFS,"CRO")
      )
    )$(not H2EF(EFS)) +
    !! FIXME: Do we need to add LQD,GAS,SLD here too?
    (
      VmDemTotH2(allCy,YTIME) -
      sum(SBS$SECtoEF(SBS,"H2F"), VmDemSecH2(allCy,SBS,YTIME))
    )$H2EF(EFS);  

*' The equation calculates the transformation output from district heating plants .
*' This transformation output is determined by summing over different demand sectors and district heating systems 
*' that correspond to the specified energy form set. The equation then sums over these district heating 
*' systems and calculates the consumption of fuels in each of these sectors. The resulting value represents the 
*' transformation output from district heating plants in million tonnes of oil equivalent.
Q03OutTransfDhp(allCy,STEAM,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTransfDhp(allCy,STEAM,YTIME)
        =E=
    sum(TSTEAM$TDHP(TSTEAM),
      VmProdSte(allCy,TSTEAM,YTIME)
    );

*' The equation calculates the transformation input to district heating plants.
*' This transformation input is determined by summing over different district heating systems that correspond to the
*' specified energy form set . The equation then sums over different demand sectors within each 
*' district heating system and calculates the consumption of fuels in each of these sectors, taking into account
*' the efficiency of district heating plants. The resulting value represents the transformation input to district
*' heating plants in million tonnes of oil equivalent.
Q03TransfInputDHPlants(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmTransfInputDHPlants(allCy,EFS,YTIME)
        =E=
    VmConsFuelSteProd(allCy,"DHP",EFS,YTIME);

Q03OutTransfCHP(allCy,TOCTEF,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03OutTransfCHP(allCy,TOCTEF,YTIME)
        =E=
    sum(TSTEAM$TCHP(TSTEAM),
      VmProdSte(allCy,TSTEAM,YTIME)
    )$sameas("STE",TOCTEF) +
    (V04ProdElecEstCHP(allCy,YTIME) * smTWhToMtoe)$sameas("ELC",TOCTEF);

$ontext
*' The equation calculates the refineries' capacity for a given scenario and year.
*' The calculation is based on a residual factor, the previous year's capacity, and a production scaling
*' factor that takes into account the historical consumption trends for different energy forms. The scaling factor is
*' influenced by the base year and the production scaling parameter. The result represents the refineries'
*' capacity in million barrels per day (Million Barrels/day).
Q03CapRef(allCy,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03CapRef(allCy,YTIME)
        =E=
    [
      i03ResRefCapacity(allCy,YTIME) * V03CapRef(allCy,YTIME-1) *
      (1$(ord(YTIME) le 10) +
      (prod(rc,
      (sum(EFS$EFtoEFA(EFS,"LQD"),VmConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+1)))/sum(EFS$EFtoEFA(EFS,"LQD"),VmConsFinEneCountry(allCy,EFS,YTIME-(ord(rc)+2))))**(0.5/(ord(rc)+1)))
      )
      $(ord(YTIME) gt 10)
      )     
    ]$i03RefCapacity(allCy,"%fStartHorizon%")+0;
$offtext

*' The equation calculates the transformation output from refineries for a specific energy form 
*' in a given scenario and year. The output is computed based on a residual factor, the previous year's output, and the
*' change in refineries' capacity. The calculation includes considerations for the base year and adjusts the result accordingly.
*' The result represents the transformation output from refineries for the specified energy form in million tons of oil equivalent.
Q03OutTransfRefSpec(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEFPROD("LQD",EFS))..
    V03OutTransfRefSpec(allCy,EFS,YTIME)
        =E=
    i03ResTransfOutputRefineries(allCy,EFS,YTIME) * 
    V03OutTransfRefSpec(allCy,EFS,YTIME-1) *
    (
      SUM(EFS2$SECtoEFPROD("LQD",EFS2),VmConsFinEneCountry(allCy,EFS2,YTIME)) /
      (SUM(EFS2$SECtoEFPROD("LQD",EFS2),VmConsFinEneCountry(allCy,EFS2,YTIME-1)) + 1e-6)
    ) ** (0.98); 

Q03OutTransfSolids(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEFPROD("SLD",EFS))..
    V03OutTransfSolids(allCy,EFS,YTIME)
        =E=
    V03OutTransfSolids(allCy,EFS,YTIME-1) *
    (
      VmConsFinEneCountry(allCy,EFS,YTIME) /
      (VmConsFinEneCountry(allCy,EFS,YTIME-1) + 1e-6)
    ) ** (0.98);

Q03OutTransfGasses(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEFPROD("GAS",EFS))..
    V03OutTransfGasses(allCy,EFS,YTIME)
        =E=
    V03OutTransfGasses(allCy,EFS,YTIME-1) *
    (
      VmConsFinEneCountry(allCy,EFS,YTIME) /
      (VmConsFinEneCountry(allCy,EFS,YTIME-1) + 1e-6)
    ) ** (0.98);

*' The equation calculates the transformation input to refineries for the energy form Crude Oil
*' in a specific scenario and year. The input is computed based on the previous year's input to refineries, multiplied by the ratio of the transformation
*' output from refineries for the given energy form and year to the output in the previous year. This calculation is conditional on the refineries' capacity
*' being active in the specified starting horizon.The result represents the transformation input to refineries for crude oil in million tons of oil equivalent.
Q03InputTransfRef(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEF("LQD",EFS))..
    V03InputTransfRef(allCy,EFS,YTIME)
        =E=
    V03InputTransfRef(allCy,EFS,YTIME-1) *
    sum(EFS2$SECtoEFPROD("LQD",EFS2), V03OutTransfRefSpec(allCy,EFS2,YTIME)) /
    (sum(EFS2$SECtoEFPROD("LQD",EFS2), V03OutTransfRefSpec(allCy,EFS2,YTIME-1)) + 1e-6);                   

Q03InputTransfSolids(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEF("SLD",EFS))..
    V03InputTransfSolids(allCy,EFS,YTIME)
        =E=
    V03InputTransfSolids(allCy,EFS,YTIME-1) *
    sum(EFS2$SECtoEFPROD("SLD",EFS2), V03OutTransfSolids(allCy,EFS2,YTIME)) /
    (sum(EFS2$SECtoEFPROD("SLD",EFS2), V03OutTransfSolids(allCy,EFS2,YTIME-1)) + 1e-6); 

Q03InputTransfGasses(allCy,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEF("GAS",EFS))..
    V03InputTransfGasses(allCy,EFS,YTIME)
        =E=
    V03InputTransfGasses(allCy,EFS,YTIME-1) *
    sum(EFS2$SECtoEFPROD("GAS",EFS2), V03OutTransfGasses(allCy,EFS2,YTIME)) /
    (sum(EFS2$SECtoEFPROD("GAS",EFS2), V03OutTransfGasses(allCy,EFS2,YTIME-1)) + 1e-6); 
            
*' The equation calculates the total transformation input for a specific energy branch 
*' in a given scenario and year. The result is obtained by summing the transformation inputs from different sources, including
*' thermal power plants, District Heating Plants, nuclear plants, patent
*' fuel and briquetting plants, and refineries. In the case where the energy branch is "OGS"
*' (Other Gas), the total transformation input is calculated as the difference between the total transformation output and various consumption
*' and loss components. The outcome represents the total transformation input in million tons of oil equivalent.
Q03InpTotTransf(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECtoEF(SSBS,EFS))..
    V03InpTotTransf(allCy,SSBS,EFS,YTIME)
        =E=
    VmConsFuelElecProd(allCy,EFS,YTIME)$sameas("PG",SSBS) + 
    VmConsFuelSteProd(allCy,"CHP",EFS,YTIME)$sameas("CHP",SSBS) +
    VmConsFuelSteProd(allCy,"DHP",EFS,YTIME)$sameas("STEAMP",SSBS) +
    V03InputTransfRef(allCy,EFS,YTIME)$sameas("LQD",SSBS) + 
    V03InputTransfSolids(allCy,EFS,YTIME)$sameas("SLD",SSBS) +
    V03InputTransfGasses(allCy,EFS,YTIME)$sameas("GAS",SSBS) + 
    VmConsFuelH2Prod(allCy,EFS,YTIME)$sameas("H2P",SSBS);            

*' The equation calculates the total transformation output for a specific energy branch in a given scenario and year.
*' The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants,
*' nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
*' as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
Q03OutTotTransf(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$runCy(allCy)$SECtoEFPROD(SSBS,EFS))..
    V03OutTotTransf(allCy,SSBS,EFS,YTIME)
        =E=
    smTWhToMtoe * 
    (
      sum(PGALL,VmProdElec(allCy,PGALL,YTIME))$sameas("PG",SSBS) +
      V04ProdElecEstCHP(allCy,YTIME)$sameas("CHP",SSBS)
    )$ELCEF(EFS) +
    VmDemTotSte(allCy,YTIME)$(sameas("STEAMP",SSBS) and STEAM(EFS)) +
    !!FIXME: Add all liquids
    V03OutTransfRefSpec(allCy,EFS,YTIME)$sameas("LQD",SSBS) +  
    V03OutTransfSolids(allCy,EFS,YTIME)$sameas("SLD",SSBS) +
    V03OutTransfGasses(allCy,EFS,YTIME)$sameas("GAS",SSBS) +  
    VmDemTotH2(allCy,YTIME)$(sameas(EFS, "H2F") and sameas("H2P",SSBS));

*' The equation calculates the transfers of a specific energy branch in a given scenario and year.
*' The result is computed based on a complex formula that involves the previous year's transfers,
*' the residual for feedstocks in transfers, and various conditions.
*' In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers,
*' and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
Q03Transfers(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03Transfers(allCy,EFS,YTIME) 
        =E=
    ( 
      (
        V03Transfers(allCy,EFS,YTIME-1) *
        (
          VmConsFinEneCountry(allCy,EFS,YTIME) /
          (VmConsFinEneCountry(allCy,EFS,YTIME-1) + 1e-6)
        ) ** 0.3
      )$(not sameas(EFS,"CRO")) +
      (
        V03Transfers(allCy,"CRO",YTIME-1) *
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),V03Transfers(allCy,EFS2,YTIME)) /
        SUM(EFS2$EFTOEFA(EFS2,"LQD"),V03Transfers(allCy,EFS2,YTIME-1))
      )$sameas(EFS,"CRO")   
    )$i03FeedTransfr(allCy,EFS,"%fStartHorizon%");         

*' The equation calculates the gross inland consumption excluding the consumption of a specific energy branch
*' in a given scenario and year. The result is computed by summing various components, including
*' total final energy consumption, final non-energy consumption, total transformation input and output, distribution losses, and transfers.
*' The outcome represents the gross inland consumption excluding the consumption of the specified energy branch in million tons of oil equivalent.
Q03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME)
        =E=
    VmConsFinEneCountry(allCy,EFS,YTIME) + 
    VmConsFinNonEne(allCy,EFS,YTIME) + 
    SUM(SSBS,V03InpTotTransf(allCy,SSBS,EFS,YTIME)) - 
    SUM(SSBS,V03OutTotTransf(allCy,SSBS,EFS,YTIME)) + 
    VmLossesDistr(allCy,EFS,YTIME) - 
    V03Transfers(allCy,EFS,YTIME); 

*' The equation calculates the gross inland consumption. This quantity is equal to the total energy
*' supply for each country.
Q03ConsGrssInl(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ConsGrssInl(allCy,EFS,YTIME)
        =E=
    VmConsFinEneCountry(allCy,EFS,YTIME) + 
    VmConsFinNonEne(allCy,EFS,YTIME) + 
    SUM(SSBS,
      VmConsFiEneSec(allCy,SSBS,EFS,YTIME) +
      V03InpTotTransf(allCy,SSBS,EFS,YTIME) -
      V03OutTotTransf(allCy,SSBS,EFS,YTIME)
    ) + 
    VmLossesDistr(allCy,EFS,YTIME) - 
    V03Transfers(allCy,EFS,YTIME);  

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
Q03ProdPrimary(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ProdPrimary(allCy,EFS,YTIME)
        =E=  
    [
      (
        !!i03RatePriProTotPriNeeds(allCy,EFS,YTIME) *
        V03ProdPrimary(allCy,EFS,YTIME-1) *
        V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME) /
        (V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME-1) + 1e-6)
      )$(not (sameas(EFS,"CRO") or sameas(EFS,"NGS"))) +
      (
        i03ResHcNgOilPrProd(allCy,EFS,YTIME) * 
        V03ProdPrimary(allCy,EFS,YTIME-1) *
        (
          (V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME) + 1e-6) /
          (V03ConsGrssInlNotEneBranch(allCy,EFS,YTIME-1) + 1e-6)
        ) !!** i03NatGasPriProElst(allCy)
      )$(sameas(EFS,"NGS")) +
      (
        i03ResHcNgOilPrProd(allCy,EFS,YTIME) * 
        V03ProdPrimary(allCy,EFS,YTIME-1) *
        prod(kpdl$(ord(kpdl) lt 5),
          (
            imPriceFuelsInt("WCRO",YTIME-(ord(kpdl)+1)) /
            imPriceFuelsIntBase("WCRO",YTIME-(ord(kpdl)+1))
          ) ** (0.2 * i03PolDstrbtnLagCoeffPriOilPr(kpdl))
        )
      )$sameas(EFS,"CRO")   
    ];   

*' The equation calculates the fake exports for a specific energy branch
*' in a given scenario and year. The computation is based on the fuel exports for
*' the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
Q03Exp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..
    V03Exp(allCy,EFS,YTIME)
        =E=
    imFuelExprts(allCy,EFS,YTIME);

*' The equation computes the fake imports for a specific energy branch 
*' in a given scenario and year. The calculation is based on different conditions for various energy branches,
*' such as electricity, crude oil, and natural gas. The equation involves gross inland consumption,
*' fake exports, consumption of fuels in demand subsectors, electricity imports,
*' and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
Q03Imp(allCy,EFS,YTIME)$(TIME(YTIME) $IMPEF(EFS) $runCy(allCy))..
    V03Imp(allCy,EFS,YTIME)
        =E=
    (
      i03RatioImpFinElecDem(allCy,YTIME) * 
      (VmConsFinEneCountry(allCy,EFS,YTIME) + VmConsFinNonEne(allCy,EFS,YTIME)) +
      V03Exp(allCy,EFS,YTIME) !! + i03ElecImp(allCy,YTIME)
    )$ELCEF(EFS) +
    (
      V03ConsGrssInl(allCy,EFS,YTIME) + 
      V03Exp(allCy,EFS,YTIME) +
      VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS) -
      V03ProdPrimary(allCy,EFS,YTIME)
    )$(sameas(EFS,"CRO")) +
    (
      V03ConsGrssInl(allCy,EFS,YTIME) + 
      V03Exp(allCy,EFS,YTIME) + 
      VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS) -
      V03ProdPrimary(allCy,EFS,YTIME)
    )$(sameas(EFS,"NGS")) +
*         +imImpExp(allCy,"NGS",YTIME)$(sameas(EFS,"NGS"))
    (
      (1-i03RatePriProTotPriNeeds(allCy,EFS,YTIME)) *
      (
        V03ConsGrssInl(allCy,EFS,YTIME) +
        V03Exp(allCy,EFS,YTIME) +
        VmConsFuel(allCy,"BU",EFS,YTIME)$SECtoEF("BU",EFS)
      )
    )$(not (ELCEF(EFS) or sameas(EFS,"NGS") or sameas(EFS,"CRO")));

*' The equation computes the net imports for a specific energy branch 
*' in a given scenario and year. It subtracts the fake exports from the fake imports for
*' all fuels except natural gas . The result represents the net imports in million tons of oil equivalent.
Q03ImpNetEneBrnch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmImpNetEneBrnch(allCy,EFS,YTIME)
        =E=
    V03Imp(allCy,EFS,YTIME) - 
    V03Exp(allCy,EFS,YTIME);
                               
*' The equation calculates the final energy own consumption in the energy sector.
*' It considers the rate of energy branch consumption over the total transformation output.
*' The final consumption is determined based on the total transformation output and primary production for energy
*' branches, excluding Oil, Coal, and Gas. The result, VmConsFiEneSec, represents the final consumption in million tons of
*' oil equivalent for the specified scenario and year.
Q03ConsFiEneSec(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECtoEF(SSBS,EFS))..
    VmConsFiEneSec(allCy,SSBS,EFS,YTIME)
        =E=
    i03RateEneBranCons(allCy,SSBS,EFS,YTIME) *
    SUM(EFS2$SECtoEFPROD(SSBS,EFS2), 
      V03OutTotTransf(allCy,SSBS,EFS2,YTIME) +
      V03ProdPrimary(allCy,EFS2,YTIME)$(not PGRENEF(EFS2))
    );                               
