Parameter


*        Macroeconomic indicators

         pGDP(allCy,YTIME)                        "GDP in Billions of Euro05"
         pPop(allCy,YTIME)                        "POP in Billions of Inhabitants"
         pActv(allCy,SBS,YTIME)                   "Sector activity in Billion Euro05 (except bunkers and households in which it is an index. Also in transport it is expressed in Gpkm, or Gvehkm or Gtkm)"
         pHouses(allCy,HOUCHAR,YTIME)             "Number of Households in thousands, inhabitants per household and consumption expenditure in MEuro/capita"
         pDiscount(allCy,SBS,YTIME)               "Discount rates per subsector"
         pElastA(allCy,SBS,ETYPES,YTIME)          "Activity Elasticities per subsector"
         pElastNSE(allCy,SBS,ETYPES,YTIME)        "Elasticities of Non Substitutable Electricity"
         pConSize(allCy,CONSET)                   "Consumer sizes for district heating"
         pCGI(allCy,YTIME)                        "Capital Goods Index (defined as CGI(Scenario)/CGI(Baseline))"
         pEnPrdIndx(allCy,SBS,YTIME)              "Energy productivity index used in R&D scenarios"
         pCCRES(PGALL,YTIME)                      "Capital cost R&D adjustment for power generation plants"
         pFOMRES(PGALL,YTIME)                     "Fixed O&M cost R&D adjustment for power generation plants"
         pVOMRES(PGALL,YTIME)                     "Variable O&M cost R&D adjustment for power generation plants"
         pEffRES(PGALL,YTIME)                     "Efficiencies R&D adjustment"
         pNucRES(YTIME)                           "Nuclear capital cost reduction for High nuclear cases"
         pNPDL(SBS)                               "Number of Polynomial Distribution Lags (PDL)"
         pFPDL(SBS,KPDL)                          "Polynomial Distribution Lags Coefficients per subsector"
         pNCon(SBS)                               "Number of consumers"
         pX0(allCy,SBS)                           "Annual consumption of the smallest consumer (average for all countries)"
                                                 !! - For passenger cars X0 is measured in Million km per vehicle
                                                 !! - For other passenger transportation modes X0 is measured in Mpkm per vehicle
                                                 !! - For goods transport, X0 is measured in Mtkm per vehicle
         pXn(allCy,SBS)                           "Annual consumption of the largest consumer (average for all countries)"
                                                 !! - For passenger cars Xn is measured in Million km per vehicle
                                                 !! - For other passenger transportation modes Xn is measured in Mpkm per vehicle
                                                 !! - For goods transport, Xn is measured in Mtkm per vehicle

         pXm(allCy,SBS)                           "Annual consumption of the modal consumer (average for all countries)"
                                                 !! - For passenger cars Xn is measured in Million km per vehicle
                                                 !! - For other passenger transportation modes Xn is measured in Mpkm per vehicle
                                                 !! - For goods transport, Xn is measured in Mtkm per vehicle
         pVr(allCy,DSBS,Rcon)                     "Distribution function of consumer size groups"
         pSTT(allCy,DSBS)                         "Cumulative distribution function of consumer size groups"

*        Prices

         pIntPrice(WEF,YTIME)                     "International Prices of main fuels in kEuro05/toe"
         pEFPrice(allCy,SBS,EF,YTIME)             "Consumer Prices of fuels per subsector in kEuro05/toe"
         pAPrice(allCy,SBS,EF,YTIME)              "'Alpha' Parameter, linking International Prices with Consumer Prices"
         pResPrice(allCy,SBS,EF,YTIME)            "'Residual' in Price Equations"
         pTaxElast(allCy,TAXSET,YTIME)            "Elasticities controlling tha taxation of alternative fuels"
         pCHPPrice(allCy,YTIME)                   "Fraction of Electricity Price at which a CHP sells electricity to network"
         pDElCIndex(allCy,YTIME)                  "Electricity Index"
         pRElCindex(allCy,YTIME)                  "Residual for electricity Index"
         pIntPriceBase(WEF,YTIME)                 "International Prices of main fuels (kEuro05/toe) in Baseline scenario"
         pElcPriceChar(allCy,ELCPCHAR,YTIME)      "Factors affecting electricity prices to consumers"
         pWPrice(allCy,SBS,EF)                    "Weights (based on fuel consumption) for sector's average price"


*        Common parameters for all Demand Subsectors

         pCapCost(allCy,SBS,EF,TEA,YTIME)        "Capital Cost of technology"
                                                 !! - For transport expressed in kEuro05 per vehicle
                                                 !! - For Industrial sectors (except Iron and Steel) expressed in kEuro05/toe-year
                                                 !! - For Iron and Steel expressed in kEuro05/tn-of-steel
                                                 !! - For Domestic Sectors expressed in kEuro05/toe-year
         pFixCost(allCy,SBS,EF,TEA,YTIME)        "Fixed O&M cost of technology"
                                                 !! - For transport is expressed in kEuro05 per vehicle
                                                 !! - For Industrial sectors (except Iron and Steel) is expressed in Euro05/toe-year
                                                 !! - For Iron and Steel is expressed in Euro05/tn-of-steel
                                                 !! - For Domestic sectors is expressed in Euro05/toe-year
         pVarCost(allCy,SBS,EF,TEA,YTIME)        "Variable Cost of technology"
                                                 !! - For transport is expressed in kEuro05 per vehicle
                                                 !! - For Industrial sectors (except Iron and Steel) is expressed in Euro05/toe-year
                                                 !! - For Iron and Steel is expressed in Euro05/tn-of-steel
                                                 !! - For Domestic sectors is expressed in Euro05/toe-year
         pDLFT(allCy,SBS,EF,TEA,YTIME)            "Technical Lifetime. For passenger cars it is a variable"
         pDLFTT(allCy,SBS,TTECH,TEA,YTIME)        "Technical Lifetime. For passenger cars it is a variable"

         pMF(allCy,SBS,EF,TEA,YTIME)              "Maturity factor per technology and subsector (for non transport sectors??)"

         pDDemSE(allCy,SBS,YTIME)                 "Total Final Energy Demand per subsector in Mtoe in Base year"
         pShrNSE(allCy,SBS)                       "Share of non substitutable electricity in total electricity demand per subsector"
         pShrHPELC(allCy,SBS)                     "Share of heat pump electricity consumption in total substitutable electricity"

         pDConsEF(allCy,SBS,EF,YTIME)             "Fuel consumption per fuel and subsector in Mtoe"
         pNetworkParam(NETWSET,SBS,EF)            "Parameters for controlling network effect curve"
         pDCF(allCy,EF,YTIME)                     "Final energy consumption in Mtoe"
         pVCF(allCy,EF,YTIME)                     "Final energy consumption in Mtoe (used for holding previous year results)"
         pResDemSE(allCy,SBS,YTIME)               "Residuals in total energy demand per subsector (energy intensity)"
         pResConsEF(allCy,SBS,EF,YTIME)           "Residuals in fuel consumption per subsector and fuel"
         pResNSE(allCy,SBS,YTIME)                 "Residuals in Non Substitutable Electricity Demand"
         pUF(allCy,SBS,EF,TEA,YTIME)              "Useful Energy Conversion Factor per subsector and technology"
         pTradBms(allCy,SBS,YTIME)                "Demand of traditional Biomass - Exogenously defined"

*        Transport Sector specific Parameters

         pS(allCy,SG)                             "S parameters of Gompertz function for passenger cars vehicle km"
         pSAT(allCy)                              "Passenger cars market saturation [1]"
         pDMExtV(allCy)                           "GDP-dependent passenger cars market extension per capita"
         pDScr(allCy)                             "Passenger cars scrapping rate"
         pResActv(allCy,SBS,YTIME)                "Residuals on transport activity"
         pDSFC(allCy,SBS,TTECH,TEA,EF)            "Specific fuel consumption cost in ktoe/Gpkm or ktoe/Gtkm or ktoe/Gvkm (Base year)"
         pResSFC(allCy,TRANSE,TTECH,EF,YTIME)     "Residuals on specific fuel consumption cost"
         pTransCHAR(allCy,TRANSPCHAR,YTIME)       "km per car, passengers per car and residuals for passenger cars market extension"
         pUseTr(allCy,TRANSE,TRANSUSE,YTIME)      "Average capacity/vehicle (in tn/veh or passengers/veh) and load factor"
         pELSh(allCy,YTIME)                       "Share of annual mileage of a plug-in hybrid which is covered by electricity"

*        Supply Side Specific Parameters

         pDPProd(allCy,EF,YTIME)                  "Fuel Primary Production in Mtoe"
         pAPProd(allCy,EF,YTIME)                  "Rate of Primary Production in Total Primary Needs"
         pDImpo(allCy,EF,YTIME)                   "Fuel Imports in Mtoe"
         pDExpo(allCy,EF,YTIME)                   "Fuel Exports in Mtoe"
         pDGIC(allCy,EF,YTIME)                    "Gross Inland Consumption in Mtoe"
         pDGICP(allCy,EF,YTIME)                   "Gross Inland Consumption (not including energy branch) in Mtoe"
         pDTICT(allCy,EF,YTIME)                   "Transformation Input for Electricity and Steam Generation in Mtoe"
         pDTIDH(allCy,EF,YTIME)                   "Transformation Input in District Heating Plants for Steam Generation in Mtoe"
         pDTIRF(allCy,EF,YTIME)                   "Transformation Input in Refineries in Mtoe"
         pDTIOTH(allCy,EF,YTIME)                  "Transformation Input in Gasworks, Blast Furnaces, Briquetting plants in Mtoe"
         pTIOTHEff(allCy,EF,YTIME)                "Average Efficiency of Gasworks, Blast Furnaces, Briquetting plants"
         pDTOCT(allCy,EF,YTIME)                   "Electricity and Steam Output from Power Generation and CHP Plants in Mtoe"
         pDTODH(allCy,EF,YTIME)                   "Steam output from District Heating Plants in Mtoe"
         pDTONUC(allCy,EF,YTIME)                  "Electricity production from nuclear plants in Mtoe"
         pDTORF(allCy,EF,YTIME)                   "Transformation Output from Refineries in Mtoe"
         pRTORF(allCy,EF,YTIME)                   "Residual in Transformation Output from Refineries"
         pDTOOTH(allCy,EF,YTIME)                  "Transformation Output from Gasworks, Blast Furnaces and Briquetting plants in Mtoe"
         pDCEN(allCy,EF,YTIME)                    "Total Energy Branch Consumption in Mtoe"
         pACEN(allCy,EF,YTIME)                    "Rate of Energy Branch Consumption over total transformation output"
         pDLOS(allCy,EF,YTIME)                    "Distribution Losses in Mtoe"
         pALOS(allCy,EF,YTIME)                    "Rate of losses over Available for Final Consumption"
         pDAVFCO(allCy,EF,YTIME)              "Available for Final Consumption in Mtoe"
         pDREFCAP(allCy,YTIME)                    "Refineries Capacity in Million Barrels per day"
         pREFCAPRES(allCy,YTIME)                  "Residual in Refineries Capacity"
         pPPRODRES(allCy,EF,YTIME)                "Residuals for Hard Coal, Natural Gas and Oil Primary Production"
         pNGSEXPRES(allCy,YTIME)                  "Natural Gas Exports Residual"
         pTIOTHRES(allCy,YTIME)                   "Transformation Input to Gasworks, Blast Furnaces, Briquetting plants Residual"
         pTOOTHRES(allCy,YTIME)                   "Transformation Output from Gasworks, Blast Furnaces, Briquetting plants Residual"
         pSHIOTH(allCy,EF)                        "Share of fuels in transformation input to Gasworks, Blast Furnances, Briquetting plants (base year)"
         pAELCIMP(allCy,YTIME)                    "Ratio of imports in final electricity demand"
         pDNETIMP(allCy,EFS,YTIME)                "Net Imports in Mtoe"
         pFEEDTRANS(allCy,EFS,YTIME)              "Feedstocks in Transfers in Mtoe"
         pFEEDRES(allCy,YTIME)                    "Residual for Feedstocks in Transfers"
         pSTDIF(allCy,EFS,YTIME)                  "Energy balance statistical difference"
         pCS(allCy,EFS,YTIME)                     "Energy balance change in stocks in mtoe"


*        Power Generation Parameters

         pPGCAPCOST(allCy,PGALL,YTIME)            "Capital Cost per Plant Type in kEuro05/KW (gross)"
         pPGCAPCOST_BAR(allCy,PGALL,YTIME)        "Capital Cost per Plant Type in kEuro05/KW (gross) with subsidy for renewables"
         pCHPCAPCOST(allCy,DSBS,CHP,YTIME)    "Capital Cost per CHP plant type kEuro05/KW"
         pPGFIXCOST(allCy,PGALL,YTIME)            "Fixed O&M Cost per Plant Type in Euro05/KW (gross)"
         pCHPFIXCOST(allCy,DSBS,CHP,YTIME)        "Fixed O&M cost per CHP plant type in Euro05/KW"
         pPGVARCOST(allCy,PGALL,YTIME)            "Variable (other than fuel) cost per Plant Type in Euro05/KW (gross)"
         pCHPVARCOST(allCy,DSBS,CHP,YTIME)        "Variable (other than fuel) cost per CHP Type in Euro05/KW (gross)"
         pCHPLFT(allCy,DSBS,CHP)                  "Technical Lifetime for CHP plants in years"
         pCHPAVAIL(allCy,DSBS,CHP)                "Availability rate of CHP Plants"
         pBOILEFF(allCy,CHP,YTIME)                "Boiler efficiency (typical) used in adjusting CHP efficiency"
         pPGCAPPAST(allCy,PGALL,PGCAPAST)         "Installed Capacity (gross) in GW (for 1995 and 2000)"
         pPGELCPROD(allCy,PGALL,PGPRODPAST)       "Electricity generation in GWh (past data for 1995 and 2000)"
         pPGCHPELPROD(allCy,YTIME)                "Electricity production from CHP (past data for 1995 and 2000)"
         pPGCAPBASE(allCy,PGALL,YTIME)            "Available installed capacity in GW for PAST YEARS"
         pPGLFT(allCy,PGALL)                      "Technical Lifetime per plant type"
         pPGAVAIL(allCy,PGALL,YTIME)              "Plant availability rate"
         pPGEFF(allCy,PGALL,YTIME)                "Plant efficiency per plant type"
         pPGCR(allCy,PGALL,YTIME)                 "Plant CO2 capture rate"
         pPGDCAP(allCy,PGALL,YTIME)               "Decided plant decomissioning schedule in GW"
         pPGICAP(allCy,PGALL,YTIME)               "Decided plant investment schedule in GW"
         pPGTOTCAP(allCy)                         "Total installed available capacity in base year in GW"
         pPGLOAD(allCy,PGLOADTYPE)                "Peak and Base load in GW for base year"
         pPGCHP(allCy,CHPSET,YTIME)               "Percentage of CHP Capacity over total gross capacity and utilisation rate of CHP Plants"
         pPGUTIL(allCy,CHP,YTIME)                 "Utilisation rate of CHP Plants"
         pPGDHEFF(allCy,EF,YTIME)                 "Efficiency of District Heating Plants"
         pPGRESMAR(allCy,PGRES,YTIME)             "Reserve margins on total available capacity and peak load"
         pPGMFC(allCy,PGALL,YTIME)                "Maturity factor related to plant available capacity"
         pPGMFL(allCy,PGALL,YTIME)                "Maturity factor related to plant dispatching"
*         PGNHYDCAP(allCy,PGALL,YTIME)            "Capacity of nuclear and large hydro plants (exogenously defined) in Gw"
         pPOTRENMIN(allCy,PGRENEF,YTIME)          "Renewable potential in GW (minimum)"
         pPOTRENMAX(allCy,PGRENEF,YTIME)          "Renewable potential in GW (maximum)"
         pH(allCy,PGALL,YTIME)                    "Scale parameter for endogenous scrapping (applied to the sum of full costs)"
         pSPG(allCy,PGALL)                        "Scale parameter for endogenous scrapping"
         pDISCOUNTED(allCy,PGALL,YTIME)           "discount factor for each technology"
         pLOADF(allCy,DSBS,YTIME)                 "Load factor of electricity demand per sector"
         pMAXLOADSH(allCy,YTIME)                  "Maximum load factor of electricity demand"
         pAMAXBASE(allCy,YTIME)                   "Parameter of baseload correction"
         pBASESHARE(allCy,DSBS,YTIME)             "Baseload share of demand per sector"
         pDCHPCAPAC(allCy,CHP,YTIME)              "Historical CHP Capacity data (gross in GW)"
         pMAXCHPSHARE(allCy,YTIME)                "Maximum share of CHP electricity in a country"
         pH2_PRICE(allCy,SBS,YTIME)               "HYDROGEN PRICE"
         pTOTH2DEMAND(allCy,YTIME)
         H2TECH_DEMAND(allCy,SBS,YTIME)
         TINEW(allCy,EF,YTIME)
         TONEW(allCy,EF,YTIME)
*         MFRENMULT(allCy,PGALL,YTIME)

*       PARAMEETERS RELATED TO THE NEW IMPORT MECHANISM (USED FOR NATURAL GAS IMPORTS+EXPORTS)
        IMP_OF_EXP_COUNTRIES(allCy,EFS,YTIME)  "IMPORTS OF EXPORTING COUNTRIES-USUALLY ZERO"
        IMP_ISR(allCy,EFS,YTIME)               "IMPORTS OF ISRAEL-FROM EGYPT UNTIL 2025"
        SHAREIMP(allCy,allCy2,EFS,YTIME)       "SHARE OF IMPORTS OF IMPORTERS FROM EXPORTERS OF NATURAL GAS"
        DEXPO_EU(allCy,EFS,YTIME)              "EXOGENOUSLY DEFINED EXPORTS TO EUROPE FROM GAS EXPORTERS"


*        Emission Related Parameters

         CO2SEQPARAM(allCy,CO2SEQELAST)          "Elasticities for CO2 sequestration cost curve"
         EMMCONSTR(NAP,YTIME)                    "Total emissions allowed per year in Mtn of CO2 in trading and non trading sectors constraint per sector"
         EMMCONSTRT(YTIME)                       "Total emissions allowed per year in Mtn of CO2 in trading and non trading sectors"
         RESCONSTR(YTIME)                        "Renewables in final demand constraint"
         EFFCONSTR(YTIME)                        "Energy efficiency constraint"
         DGHGEMISS(allCy,SCT_GHG,EMISS,YTIME)    "GHG Emissions in Mtn of CO2 Equivalent for past years"
         GHGELASTA(allCy,SCT_GHG,EMISS,YTIME)    "Elasticity on sector's emission driver"
         GHGELASTC(allCy,SCT_GHG,EMISS,ETYPES,YTIME) "Elasticity on MAC"
         GHGRES(allCy,SCT_GHG,EMISS,YTIME)       "Residual for emissions adjustment"
         CO2EMFAC(allCy,SBS,EF,YTIME)            "CO2 emission factors in kg CO2 per kgoe fuel burned"
         CO2EMIS(allCy,YTIME)                    "Total CO2 energy related emissions in Mtn of CO2 per country"
         CO2_Fug(allCy,ytime)                    "Fugitive CO2 emissions"
*        System Costs

         SYSCOSTTRANS(allCy,TRANSE,EF,YTIME)     "Transport cost per transportation sector and technology in kEuro05 per vehicle"
         SYSCOSTDEMSE(allCy,DSBS,EF,YTIME)       "System cost per demand subsector and technology"
         ELECCOST(allCy,PGALL,HOUR,YTIME)        "Electricity generation cost per plant type and hour class in Euro05 per KWh"
         TELECCOST(allCy,PGALL,YTIME)            "Total electricity generation cost per plant tyoe in Euro05 per KWh"
         TTELCCOST(allCy,YTIME)                  "Total electricity generation cost in BEuro05"

         TTELCCOSTNEW(allCy,YTIME)               "Total electricity generation cost in BEuro05"
         TTELCCOST_INT_PRICE(allCy,YTIME)        "Total electricity generation cost in BEuro05-CALCULATED WITH INTERNATIONAL PRICES"
         TTOPEX_INT_PRICE(allCy,YTIME)           "Total OPEX cost in BEuro05-CALCULATED WITH INTERNATIONAL PRICES"
         TTCAPEX_INT_PRICE(allCy,YTIME)          "Total CAPEX cost in BEuro05-CALCULATED WITH INTERNATIONAL PRICES"
         INVCOST(allCy,SBS,YTIME)                "Total investment cost per sector in MEuro05"
         INVCOST_TECH(allCy,PGALL,YTIME)         "Total investment cost per power generation technnology in MEuro05" 
         FUELCOST(allCy,DSBS,YTIME)              "Fuel cost per demand sector in MEuro05"
         OPEXPG(allCy,PGALL,HOUR,YTIME)
         CAPEXPG(allCy,PGALL,HOUR,YTIME)
         TOPEXPG(allCy,PGALL,YTIME)
         TCAPEXPG(allCy,PGALL,YTIME)
         TTOPEXPG(allCy,YTIME)
         TTCAPEXPG(allCy,YTIME)
         CV(YTIME)                             "Carbon value used for initialisation of variables"
         AVGCV(YTIME)

         REPELCP(allCy,PGALL,YTIME)              "Electricity production for 1995 and 2000"

         TESTPGMFC(allCy,PGNREN,YTIME)

         Policy(YTIME)                           "Environmental policies"
!!                                               0. No policy
!!                                               1. trade sectors only CO2 constraint
!!                                               2. optimal allocation of CO2 permits
!!                                               3. renewable constraint
!!                                               4. energy efficiency constraint
!!                                               5. exogenous cabron value for ETS
!!                                               6. exogenous carbon value for optimal allocation
!!                                               7. exogenous renewable value
!!                                               8. exogenous efficiency value

         CarbonPolicy(Ytime)                     "1 Carbon policy active, 0 no carbon policy"
         ResPolicy(Ytime)                        "1 Renewables policy active, 0 no renewable policy"
         EffPolicy(Ytime)                        "1 Efficiency policy active, 0 no efficiency policy"
         optalloc(ytime)                         "optimal allocation for CO2 permits (1=active, 0=inactive)"
         EFFVAL(allCy,SBS,YTIME)                 "Efficiency value in Euro05/toe"

*        Reguala Falsi Parameters

         x(falsi_iter)                           "Root calculated from secant method"
         f_x(falsi_iter)                         "Secant method main equation"
         cond(falsi_iter)                        "Loop condition to stop the regula falsi iterations"
         cvcond(ytime)                           "loop condition for carbon value"
         rescond(ytime)                          "loop condition for renewable value"
         effcond(ytime)                          "efficiency condition for efficiency value"
         exogCVp(ytime)                          "carbon value for each year when it is exogenous"
         NemesisModelStat(allCy,YTIME)           "ModelStat for the model"
        CAPACITY_ELEC_EXP(allCy,PGALL,YTIME) "CAPACITY USED FOR EXPORTS TO EU IN GW,ONLY FOR CSP"
        PROD_ELEC_EXP(allCy,PGALL,YTIME)   "ELECTRICITY EXPORTS TO EU IN TWH"
      ELC_IMPORTS(allCy,YTIME)
      EXTRACOST(allCy,YTIME)
      DURATION(allCy,YTIME)

kappa1(allCy,AGSECT,EF,YTIME)
targetprice1(allCy,AGSECT,EF,YTIME)
targetprice(allCy,SBS,EF,YTIME)
kappa(allCy,SBS,EF,YTIME)


;
EXTRACOST(runCy,YTIME) =0;
DURATION(runCy,YTIME) =0;
ELC_IMPORTS(allCy,YTIME)=0;
CAPACITY_ELEC_EXP(allCy,PGALL,YTIME)=0  ;
PROD_ELEC_EXP(allCy,PGALL,YTIME)=0  ;
EFFVAL(allCy,SBS,YTIME)=0;
H2TECH_DEMAND(allCy,SBS,YTIME)=1E-7;
TINEW(allCy,EF,YTIME)=1E-7;
TONEW(allCy,EF,YTIME) =1E-7;
*SHAREIMP(allCy,CYALL2,EFS,YTIME)=1;
*MFRENMULT(runCy,PGALL,YTIME)=1;
;

scalars networkON Switch allowing for network effects or not (1=ON 0=OFF)
         includeGHG boolean to include the GHG in emission constraints
         NONE special scalar used in regula falsi method
         MAXELCINDEX Technical maximum of electricity to steam ratio in CHP plants /1.15/
         tol Regula Falsi tolerance /1e-4/
         initfalsi  Initialise reqgula falsi to default values or not/1/
         cvv /0/
         effv /0/
         resv /0/
         exogCV  switch for exogenous carbon value (0=exogenous 1=endogenous) /1/
;


TABLE ELSB(allCy,DSBS)
           IS          NF          CH         BM          PP          FD          TX          EN           OE          OI          SE         HOU           AG        BU        PCH        NEN
ALG        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
MOR        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
TUN        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
LIB        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
EGY        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
ISR        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
SYR        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
LEB        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.
JOR        2.57        1.99        2.23        3.43        2.27        2.54        3.02        2.61        1.49        1.61        1.47        2.41        1.82        2.0        2.        2.


;


PARAMETER ELASTGAS(allCy) Natural Gas primary production elasticity related to gross inland consumption
/
ALG 1
TUN 0.35
LIB 1
MOR 0.02
LEB 0.01
JOR 0.08
SYR 0.5
ISR 1
TUR 0.01
EGY 0.65
/;





PARAMETER OILPDL(kpdl) Polynomial Distribution Lag Coefficients for primary oil production
/
a1       1.666706504
a2       1.333269594
a3       1.000071707
a4       0.666634797
a5       0.33343691
/
;



* H2 params
*PARAMETERS

*H2TECH_DATA(H2TECH,alllabels),
*H2INFRA_DATA(INFRTECH,alllabels)
*H2INFR_OTHER(allCy,alllabels)
*;

* common data parameters



parameters
         ConsizePRN(CONSET,conSizeSet)
         DiscountPRN(SBS,YTIME)
         IntpricePRN(WEF,YTIME)
         IntpriceBPRN(WEF,YTIME)
         Trans_Tech(TRANSE,EF,ECONCHAR)
         Trans_Use(TRANSE,TRANSUSE)
         Indu_Tech(INDSE,EF,ECONCHAR)
         Dom_Tech(DOMSE,EF,ECONCHAR)
         NetEffect(NETWSET,NETEF,NETEF4)
         Nen_Tech(NENSE,EF,ECONCHAR)
         PG_Cost(PGALL,PGECONCHAR)
         CHPPG_Cost(EF,CHPPGSET,YTIME)
         DH_Eff(PGEFS,YTIME)
         POLICIES(POLICIES_SET,YTIME)

         GIC_GAS(allCy,YTIME)
         NO_NGS_PPROD(allCy,YTIME)
         EN_PRD_INDX_PRN(allCy,SBS,YTIME)
         CCRES_PRN(PGALL,YTIME)
         FOMRES_PRN(PGALL,YTIME)
         VOMRES_PRN(PGALL,YTIME)
         EFFRES_PRN(PGALL,YTIME)
         NUCRES_PRN(nucres_set,YTIME)
;



parameters
         bal_pprod(balef,YTIME)
         bal_imp(balef,YTIME)
         bal_nimp(balef,YTIME)
         bal_exp(balef,YTIME)
         bal_bun(balef,YTIME)
         bal_gic(balef,YTIME)
         bal_titot(balef,YTIME)
         bal_tict(balef,YTIME)
         bal_tinuc(balef,YTIME)
         bal_tidh(balef,YTIME)
         bal_tirf(balef,YTIME)
         bal_tinew(balef,YTIME)
         bal_tioth(balef,YTIME)
         bal_tooth(balef,YTIME)
         bal_totot(balef,YTIME)
         bal_toct(balef,YTIME)
         bal_todh(balef,YTIME)
         bal_tonuc(balef,YTIME)
         bal_tonew(balef,YTIME)
         bal_torf(balef,YTIME)
         bal_cen(balef,YTIME)
         bal_los(balef,YTIME)
         bal_cfnen(balef,YTIME)
         bal_cpch(balef,YTIME)
         bal_cone(balef,YTIME)
         bal_cf(balef,YTIME)
         bal_avfco(balef,YTIME)
         bal_cin(balef,YTIME)
         bal_cis(balef,YTIME)
         bal_cnf(balef,YTIME)
         bal_cch(balef,YTIME)
         bal_cbm(balef,YTIME)
         bal_cpp(balef,YTIME)
         bal_cfdt(balef,YTIME)
         bal_ctex(balef,YTIME)
         bal_ceng(balef,YTIME)
         bal_core(balef,YTIME)
         bal_coth(balef,YTIME)
         bal_ctr(balef,YTIME)
         bal_ctt(balef,YTIME)
         bal_crt(balef,YTIME)
         bal_cat(balef,YTIME)
         bal_cni(balef,YTIME)
         bal_cdm(balef,YTIME)
         bal_cter(balef,YTIME)
         bal_cser(balef,YTIME)
         bal_cagr(balef,YTIME)
         bal_chou(balef,YTIME)
         bal_stdif(balef,YTIME)
         bal_cs(balef,YTIME)
         bal_trans(balef,YTIME)
         BALANCE(allCy,*,EFS,YTIME)              only for exporting in NEMESIS Macro model
         Report_agr(report_lines,YTIME)       aggeragate report
;

