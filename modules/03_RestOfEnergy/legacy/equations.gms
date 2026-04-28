*' @title Equations of OPEN-PROMs REST OF ENERGY BALANCE SECTORS
*' @code

*' GENERAL INFORMATION

*' Equation format: "typical useful energy demand equation"
*' The main explanatory variables (drivers) are activity indicators (economic activity) and corresponding energy costs.
*' The type of "demand" is computed based on its past value, the ratio of the current and past activity indicators (with the corresponding elasticity), 
*' and the ratio of lagged energy costs (with the corresponding elasticities). This type of equation captures both short term and long term reactions to energy costs. 

*' * REST OF ENERGY BALANCE SECTORS

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
        SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME)) +
        V03ProdPrimary(allCy,EFS,YTIME)$sameas(EFS,"CRO")
      )
    )$(not H2EF(EFS)) +
    !! FIXME: Do we need to add LQD,GAS,SLD here too?
    (
      0!!VmDemTotH2(allCy,YTIME) -
      !!sum(SBS$SECtoEF(SBS,"H2F"), VmDemSecH2(allCy,SBS,YTIME))
    )$H2EF(EFS);  

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
    (
      i03InputEffSupply(allCy,SSBS,EFS,"%fBaseY%") * 
      SUM(EFS2, V03OutTotTransf(allCy,SSBS,EFS2,YTIME))
    )$(sameas(SSBS,"GAS") or sameas(SSBS,"SLD") or sameas(SSBS,"LQD"));            

*' The equation calculates the total transformation output for a specific energy branch in a given scenario and year.
*' The result is obtained by summing the transformation outputs from different sources, including thermal power stations, District Heating Plants,
*' nuclear plants, patent fuel and briquetting plants, coke-oven plants, blast furnace plants, and gas works
*' as well as refineries. The outcome represents the total transformation output in million tons of oil equivalent.
Q03OutTotTransf(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$runCy(allCy))..
    V03OutTotTransf(allCy,SSBS,EFS,YTIME)
        =E=
    smTWhToMtoe * 
    (
      sum(PGALL,VmProdElec(allCy,PGALL,YTIME))$sameas("PG",SSBS) +
      SUM(TCHP,V04ProdElecEstCHP(allCy,TCHP,YTIME))$sameas("CHP",SSBS)
    )$ELCEF(EFS) +
    (
      SUM(TDHP,VmProdSte(allCy,TDHP,YTIME))$sameas("STEAMP",SSBS) +
      SUM(TCHP,VmProdSte(allCy,TCHP,YTIME))$sameas("CHP",SSBS)
    )$STEAM(EFS) +
    (
      (1-i03RatioPrimaryFuels(allCy,EFS,"%fBaseY%")) *
      (V03ConsGrssInl(allCy,EFS,YTIME) - VmImpNetEneBrnch(allCy,EFS,YTIME))
    )$(SECtoEFPROD(SSBS,EFS) and (sameas("LQD",SSBS) or sameas("SLD",SSBS) or sameas("GAS",SSBS))) +
    VmDemTotH2(allCy,YTIME)$(sameas(EFS, "H2F") and sameas("H2P",SSBS));

*' The equation calculates the transfers of a specific energy branch in a given scenario and year.
*' The result is computed based on a complex formula that involves the previous year's transfers,
*' the residual for feedstocks in transfers, and various conditions.
*' In particular, the equation includes terms related to feedstock transfers, residual feedstock transfers,
*' and specific conditions for the energy branch "CRO" (crop residues). The outcome represents the transfers in million tons of oil equivalent.
Q03Transfers(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03Transfers(allCy,EFS,YTIME) 
        =E=
    V03Transfers(allCy,EFS,YTIME-1) *
    SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME) + 1e-6) / 
    SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME-1) + 1e-6);         

*' The equation calculates the gross inland consumption. This quantity is equal to the total energy
*' supply for each country.
Q03ConsGrssInl(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ConsGrssInl(allCy,EFS,YTIME)
        =E=
    SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME)) +
    SUM(SSBS,
      VmConsFiEneSec(allCy,SSBS,EFS,YTIME) +
      V03InpTotTransf(allCy,SSBS,EFS,YTIME)
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
    V03ConsGrssInl(allCy,EFS,YTIME) - 
    VmImpNetEneBrnch(allCy,EFS,YTIME) -
    SUM(SSBS,V03OutTotTransf(allCy,SSBS,EFS,YTIME));   

*' The equation calculates the fake exports for a specific energy branch
*' in a given scenario and year. The computation is based on the fuel exports for
*' the corresponding energy branch. The result represents the fake exports in million tons of oil equivalent.
Q03Exp(allCy,EFS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V03Exp(allCy,EFS,YTIME)
      =E=
    i03RateExpTotImp(allCy,EFS,"%fBaseY%") *
    SUM(runCy2, V03Imp(runCy2,EFS,YTIME-1));

*' The equation computes the fake imports for a specific energy branch 
*' in a given scenario and year. The calculation is based on different conditions for various energy branches,
*' such as electricity, crude oil, and natural gas. The equation involves gross inland consumption,
*' fake exports, consumption of fuels in demand subsectors, electricity imports,
*' and other factors. The result represents the fake imports in million tons of oil equivalent for all fuels except natural gas.
Q03Imp(allCy,EFS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V03Imp(allCy,EFS,YTIME)
        =E=
    i03RateImpGrossInlCons(allCy,EFS,"%fBaseY%") *
    V03ConsGrssInl(allCy,EFS,YTIME);

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
Q03ConsFiEneSec(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmConsFiEneSec(allCy,SSBS,EFS,YTIME)
        =E=
    (
      i03RateEneBranCons(allCy,SSBS,EFS,YTIME) *
      SUM(EFS2$SECtoEFPROD(SSBS,EFS2), 
        V03OutTotTransf(allCy,SSBS,EFS2,YTIME) +
        V03ProdPrimary(allCy,EFS2,YTIME)$(not PGRENEF(EFS2))
      )
    )$(not sameas("H2P",SSBS)) +
    VmConsFuelH2Prod(allCy,EFS,YTIME)$sameas("H2P",SSBS);                               

Q03FinalEnergy(allCy,DSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$(SECtoEF(DSBS,EFS)))..
    VmFinalEnergy(allCy,DSBS,EFS,YTIME)
        =E=
    SUM((TRANSE,TTECH)$(sameas(DSBS,TRANSE) and SECTTECH(TRANSE,TTECH) and TTECHtoEF(TTECH,EFS)),
      V01ConsTechTranspSectoral(allCy,TRANSE,TTECH,EFS,YTIME)
    ) + 
    VmConsFuel(allCy,DSBS,EFS,YTIME) + 
    sum(CDRTECH$TECHtoEF(CDRTECH,EFS),VmConsFuelTechCDRProd(allCy,CDRTECH,EFS,YTIME))$sameas(DSBS,"DAC") +
    VmConsFuelTechCDRProd(allCy,"TEW",EFS,YTIME)$sameas(DSBS,"EW");   
