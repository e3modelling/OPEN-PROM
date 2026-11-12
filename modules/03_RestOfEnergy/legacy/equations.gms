*' @title Equations of OPEN-PROMs REST OF ENERGY BALANCE SECTORS
*' @code

*' GENERAL INFORMATION
*' This module defines energy-balance accounting and transformation equations.
*' It covers distribution losses, transformation inputs and outputs, transfers,
*' gross inland consumption, primary production, energy trade, energy-sector own
*' consumption, and final energy consumption by sector and energy carrier.
*'
*' * REST OF ENERGY BALANCE SECTORS
*'
*' Calculates distribution losses for each energy carrier by applying its
*' final-consumption loss rate to total final energy use. For crude oil (CRO), primary
*' production is also included in the loss base. The formula does not explicitly exclude
*' hydrogen.
Q03LossesDistr(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmLossesDistr(allCy,EFS,YTIME)
        =E=
    imRateLossesFinCons(allCy,EFS,YTIME) * 
    (
      SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME)) +
      V03ProdPrimary(allCy,EFS,YTIME)$sameas(EFS,"CRO")
    )
    !! FIXME: Do we need to add LQD,GAS,SLD here too?
;  

$ontext
*' Inactive equation (inside $ontext): estimates refinery capacity from the
*' previous-year capacity and a residual capacity factor. After the initial ten periods,
*' a product of lagged liquid-fuel final-consumption growth ratios adjusts capacity. The
*' equation is conditional on nonzero refinery capacity in the start year.
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

*' Calculates transformation input by transformation sector and energy carrier. Power
*' generation input is derived from technology-specific electricity output, fuel shares,
*' and electrical efficiency. CHP and district-heating input use steam output, base-year
*' fuel shares, and heat efficiency. Gas, solid, and liquid transformation inputs use
*' base-year input-to-output coefficients. Hydrogen production input is determined by
*' feedstock requirements.
Q03InpTotTransf(allCy,SSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$SECtoEF(SSBS,EFS))..
    V03InpTotTransf(allCy,SSBS,EFS,YTIME)
        =E=
    SUM(PGALL$PGALLTOEF(PGALL,EFS),
      i04ShareFuels(allCy,PGALL,EFS) *
      VmProdElec(allCy,PGALL,YTIME) * smTWhToMtoe / 
      imPlantEffByType(allCy,PGALL,"effELC",YTIME)
    )$sameas("PG",SSBS) + 
    SUM(TCHP$(TSTEAMTOEF(TCHP,EFS)),
      VmProdSte(allCy,TCHP,YTIME) * i09ShareFuel(allCy,TCHP,EFS,"%fBaseY%") / 
      SUM(STECH$sameas(STECH,TCHP), imPlantEffByType(allCy,STECH,"effHeat","%fBaseY%"))
    )$sameas("CHP",SSBS) +
    SUM(TDHP$(TSTEAMTOEF(TDHP,EFS)),
      VmProdSte(allCy,TDHP,YTIME) *
      i09ShareFuel(allCy,TDHP,EFS,"%fBaseY%") / SUM(STECH$sameas(STECH,TDHP),imPlantEffByType(allCy,STECH,"effHeat","%fBaseY%"))
    )$sameas("STEAMP",SSBS) +
    (
      i03InputEffSupply(allCy,SSBS,EFS,"%fBaseY%") * 
      SUM(EFS2, V03OutTotTransf(allCy,SSBS,EFS2,YTIME))
    )$(sameas(SSBS,"GAS") or sameas(SSBS,"SLD") or sameas(SSBS,"LQD")) +
    (SUM(H2TECH$H2TECHtoFEEDSTOCK(H2TECH,EFS),VmProdH2(allCy,H2TECH,YTIME) * i05InputOverOutH2ProdFeed(allCy,H2TECH,EFS,YTIME)))$sameas("H2P",SSBS);    

*' Calculates transformation output by sector and energy carrier. Electricity output
*' includes power plants and estimated CHP electricity generation, converted from TWh to
*' Mtoe. Steam output includes district heating and CHP production. Liquid, solid, and
*' gaseous fuel outputs are estimated using gross inland consumption net of imports and
*' the base-year primary-fuel ratio. Hydrogen output equals total hydrogen demand for
*' the hydrogen-production sector.
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

*' Projects transfers for each energy carrier by scaling previous-year transfers with
*' the ratio of current to previous final energy consumption across demand subsectors. A
*' small additive constant in each summand prevents a zero denominator.
Q03Transfers(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03Transfers(allCy,EFS,YTIME) 
        =E=
    V03Transfers(allCy,EFS,YTIME-1) *
    SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME) + 1e-6) / 
    SUM(DSBS,VmFinalEnergy(allCy,DSBS,EFS,YTIME-1) + 1e-6);         

*' Calculates gross inland energy consumption for each carrier as final energy
*' consumption plus energy-sector own consumption and transformation inputs, plus
*' distribution losses, minus transfers.
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

*' Calculates primary production as gross inland consumption minus net energy imports
*' and the sum of transformation outputs for the corresponding energy carrier. This is
*' an energy-balance residual, not a separate production-growth or elasticity equation.
Q03ProdPrimary(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    V03ProdPrimary(allCy,EFS,YTIME)
        =E=  
    V03ConsGrssInl(allCy,EFS,YTIME) - 
    VmImpNetEneBrnch(allCy,EFS,YTIME) -
    SUM(SSBS,V03OutTotTransf(allCy,SSBS,EFS,YTIME));   

*' Estimates exports of each energy carrier as a fixed base-year export-to-import
*' coefficient multiplied by the sum of previous-year imports across modeled countries.
Q03Exp(allCy,EFS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V03Exp(allCy,EFS,YTIME)
      =E=
    i03RateExpTotImp(allCy,EFS,"%fBaseY%") *
    SUM(runCy2, V03Imp(runCy2,EFS,YTIME-1));

*' Estimates imports for each energy carrier by multiplying current gross inland
*' consumption by the carrier-specific base-year import-to-gross-inland-consumption
*' ratio.
Q03Imp(allCy,EFS,YTIME)$(TIME(YTIME) $runCy(allCy))..
    V03Imp(allCy,EFS,YTIME)
        =E=
    i03RateImpGrossInlCons(allCy,EFS,"%fBaseY%") *
    V03ConsGrssInl(allCy,EFS,YTIME);

*' Defines net imports of each energy carrier as estimated imports minus estimated
*' exports.
Q03ImpNetEneBrnch(allCy,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy)))..
    VmImpNetEneBrnch(allCy,EFS,YTIME)
        =E=
    V03Imp(allCy,EFS,YTIME) -
    V03Exp(allCy,EFS,YTIME);
                               
*' Calculates energy-sector own consumption by sector and carrier. For sectors other
*' than hydrogen production, applies an energy-branch consumption rate to eligible
*' transformation outputs and non-renewable primary production. For hydrogen production,
*' sums technology-specific energy inputs required for hydrogen output.
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
    (SUM(H2TECH$H2TECHtoENERGY(H2TECH,EFS),VmProdH2(allCy,H2TECH,YTIME) * i05InputOverOutH2ProdEnergy(allCy,H2TECH,EFS,YTIME)))$sameas("H2P",SSBS);                               

*' Aggregates final energy consumption by demand subsector and carrier. Includes
*' transport fuel consumption, other subsector fuel consumption, agricultural fuel use
*' for AG, direct-air-capture technology fuel use for DAC, and TEW fuel use for EW. The
*' equation is restricted to mapped sector-carrier combinations and excludes ICT.
Q03FinalEnergy(allCy,DSBS,EFS,YTIME)$(TIME(YTIME)$(runCy(allCy))$(SECtoEF(DSBS,EFS))$(not sameas("ICT",DSBS)))..
    VmFinalEnergy(allCy,DSBS,EFS,YTIME)
        =E= 
    SUM(TRANSE$sameas(TRANSE,DSBS),V01ConsFuelTransport(allCy,TRANSE,EFS,YTIME)) +
    VmConsFuel(allCy,DSBS,EFS,YTIME) + 
    SUM(AGRI_MODES,V12ConsFuel(allCy,AGRI_MODES,EFS,YTIME))$sameas("AG",DSBS) +
    sum(DACTECH$TECHtoEF(DACTECH,EFS),VmConsFuelTechCDRProd(allCy,DACTECH,EFS,YTIME))$sameas(DSBS,"DAC") +
    VmConsFuelTechCDRProd(allCy,"TEW",EFS,YTIME)$sameas(DSBS,"EW");   
