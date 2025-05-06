sets

***        Geographic Coverage      *
allCy    "All Countries Used in the Model"
/
LAM
OAS
SSA
NEU
MEA
REF
CAZ
AUT
BEL
BGR
CHA
CYP
CZE
DEU
DNK
ESP
ELL
FIN
FRA
GBR
GRC
HRV
HUN
IND
IRL
ITA
JPN
MLT
NLD
POL
PRT
ROU
SVK
SVN
SWE
USA
MAR
EGY
RWO
/

resCy "Countries for Research Mode"
/
LAM
OAS
SSA
NEU
MEA
REF
CAZ
AUT
BEL
BGR
CHA
CYP
CZE
DEU
DNK
ESP
ELL
FIN
FRA
GBR
GRC
HRV
HUN
IND
IRL
ITA
JPN
MLT
NLD
POL
PRT
ROU
SVK
SVN
SWE
USA
/

fscenario   "Model scenario used: 0 is NPi_Default, 1 is 1.5C and 2 is 2C"
/
%fScenario%
/

runCy(allCy) Countries for which the model is running
/
%fCountries%
/
runCyL(allCy) Countries for which the model is running (used in countries loop)
/
%fCountries%
/;

* runCy is equal to resCy on research mode
runCy(allCy)$(%DevMode% = 0) = resCy(allCy) ;
runCyL(allCy)$(%DevMode% = 0) = resCy(allCy) ;

sets
***        Model Time Horizon       *
ytime           Model time horizon                                /%fStartHorizon%*%fEndHorizon%/
an(ytime)       Years for which the model is running              /%fStartY%*%fEndY%/
period(ytime)   Model can also run for periods of years
tFirst(ytime)   Base year                                         /%fBaseY%/
time(ytime)     Model time horizon used in equation definitions   /%fStartY%*%fEndY%/
datay(ytime)    Historical year before the base year of the model /%fStartHorizon%*%fBaseY%/
hour            "Segments of hours in a year (250,1250,...,8250)" /h0*h8/


posElast / a /
negElast / b1, b2, c, b3, b4, c1, c2, c3, c4, c5 /

***          Consumer Sizes         *

conSet       Consumer size groups related to space heating
/
smallest
modal
largest
/

eSet         Electricity consumers used for average electricity price calculations /i,r/
iSet(eSet)   Industrial consumer /i/
rSet(eSet)   Residential consumer /r/


***       Auxiliary Counters        *

rCon         counter for the number of consumers              /0,1*19/
nSet         auxiliary counter for the definition of Vr       /b1*b20/
kpdl         counter for Polynomial Distribution Lag          /a1*a6/
rc                                                            /1*3/
rcc                                                           /1*10/


***       Sectoral Structure        *



ALLSBS   All sectors
/
IS    "Iron and Steel"
NF    "Non Ferrous Metals"
CH    "Chemicals"
BM    "Non Metallic Minerals"
PP    "Paper and Pulp"
FD    "Food Drink and Tobacco"
EN    "Engineering"
TX    "Textiles"
OE    "Ore Extraction"
OI    "Other Industrial sectors"
SE    "Services and Trade"
AG    "Agriculture, Fishing, Forestry etc."
HOU   "Households"
PC    "Passenger Transport - Cars"
PB    "Passenger Transport - Busses"
PT    "Passenger Transport - Rail"
PN    "Passenger Transport - Inland Navigation"
PA    "Passenger Transport - Aviation"
GU    "Goods Transport - Trucks"
GT    "Goods Transport - Rail"
GN    "Goods Transport - Inland Navigation"
BU    "Bunkers"
PCH   "Petrochemicals Industry"
NEN   "Other Non Energy Uses"
PG    "Power and Steam Generation"
H2P   "Hydrogen Production"
H2INFR "Hydrogen storage and delivery"
LGN_PRD_CH4    "Lignite Primary Production, related with CH4"
HCL_PRD_CH4    "Hard coal primary production, related with CH4"
GAS_PRD_CH4    "Natural gas primary production, related with CH4"
TERT_CH4       "Natural gas distribution in tertiary, related with CH4"
TRAN_CH4       "Gasoline in transport, related with CH4"
AG_CH4         "Agriculture activities, related with CH4"
SE_CH4         "Waste used in housing and water charges in services, related with CH4"
TRAN_N2O       "Oil activities in transport, related with N2O"
TX_N2O         "Textile activities, related with N2O"
AG_N2O         "Agriculture activities, related with N2O"
OI_HFC         "Other Industry activities, related with HFC"
OI_PFC         "Semiconductor manufacturing, related with PFC"
NF_PFC         "Aluminium production, related with PFC"
BM_CO2         "Non metallic minerals production, related with CO2"
PG_SF6         "Electricity production, related with SF6"
OI_SF6         "Other Industries activities, related with SF6"
/

SBS(ALLSBS)          Model Subsectors
/
IS    "Iron and Steel"
NF    "Non Ferrous Metals"
CH    "Chemicals"
BM    "Non Metallic Minerals"
PP    "Paper and Pulp"
FD    "Food Drink and Tobacco"
EN    "Engineering"
TX    "Textiles"
OE    "Ore Extraction"
OI    "Other Industrial sectors"
SE    "Services and Trade"
AG    "Agriculture, Fishing, Forestry etc."
HOU   "Households"
PC    "Passenger Transport - Cars"
PB    "Passenger Transport - Busses"
PT    "Passenger Transport - Rail"
PN    "Passenger Transport - Inland Navigation"
PA    "Passenger Transport - Aviation"
GU    "Goods Transport - Trucks"
GT    "Goods Transport - Rail"
GN    "Goods Transport - Inland Navigation"
BU    "Bunkers"
PCH   "Petrochemicals Industry"
NEN   "Other Non Energy Uses"
PG    "Power and Steam Generation"
H2P   "Hydrogen production"
H2INFR "Hydrogen storage and delivery"
/


SCT_GHG(ALLSBS)      Aggregate Sectors used in non-energy related GHG emissions
/
LGN_PRD_CH4    "Lignite Primary Production, related with CH4"
HCL_PRD_CH4    "Hard coal primary production, related with CH4"
GAS_PRD_CH4    "Natural gas primary production, related with CH4"
TERT_CH4       "Natural gas distribution in tertiary, related with CH4"
TRAN_CH4       "Gasoline in transport, related with CH4"
AG_CH4         "Agriculture activities, related with CH4"
SE_CH4         "Waste used in housing and water charges in services, related with CH4"
TRAN_N2O       "Oil activities in transport, related with N2O"
TX_N2O         "Textile activities, related with N2O"
AG_N2O         "Agriculture activities, related with N2O"
OI_HFC         "Other Industry activities, related with HFC"
OI_PFC         "Semiconductor manufacturing, related with PFC"
NF_PFC         "Aluminium production, related with PFC"
BM_CO2         "Non metallic minerals production, related with CO2"
PG_SF6         "Electricity production, related with SF6"
OI_SF6         "Other Industries activities, related with SF6"
/



POLICIES_set
/
TRADE
NoTrade
OPT
REN
EFF
NONE
RENE_SUBS
BIO_SUBS
BIOM_SUBS
SOLRES_SUBS
exogCV_NPi
exogCV_1_5C
exogCV_2C
/

RegulaPolicies(POLICIES_set) Set of policies entering in the regula falsi loops
/ OPT           Carbon Value for Optimal CO2 permits allocation
  TRADE         Carbon Value for Trade sectors
  REN           Renewable value for renewable target in final demand
  EFF           Efficiency value for energy savings in final demand
  NONE          No policy
/

NAP(Policies_set) National Allocation Plan sector categories
/
Trade    Carbon Value for trading sectors
NoTrade  Carbon Value for non-trading sectors
/

NAPtoALLSBS(NAP,ALLSBS) Energy sectors corresponding to NAP sectors
/
Trade.(FD,EN,TX,OE,OI,NF,CH,IS,BM,PP,PG,BM_CO2,H2P)
NoTrade.(SE,AG,HOU,PC,PB,PT,PN,PA,GU,GT,GN,BU,PCH,NEN,LGN_PRD_CH4,HCL_PRD_CH4,GAS_PRD_CH4,TERT_CH4,TRAN_CH4,AG_CH4,SE_CH4,TRAN_N2O,TX_N2O,AG_N2O,OI_HFC,OI_PFC,NF_PFC,PG_SF6,OI_SF6)
/

DSBS(SBS)         All Demand Subsectors         /PC,PT,PA,PB,PN,GU,GT,GN,IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU,PCH,NEN,BU/
TRANSE(DSBS)      All Transport Subsectors      /PC,PT,PA,PB,PN,GU,GT,GN/
TRANS1(SBS)       All Transport Subsectors      /PC,PT,PA,PB,PN,GU,GT,GN/
TRANP(TRANSE)     Passenger Transport           /PC,PT,PA,PB,PN/
TRANG(TRANSE)     Goods Transport               /GU,GT,GN/

INDSE(DSBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE(DSBS)       Tertiary SubSectors           /SE,AG,HOU/
INDSE1(SBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE1(SBS)       Tertiary SubSectors           /SE,AG,HOU/
HOU(DSBS)         Households                     /HOU/
NENSE(DSBS)       Non Energy and Bunkers        /PCH,NEN,BU/
NENSE1(SBS)       Non Energy and Bunkers        /PCH,NEN,BU/
BUN(DSBS)         Bunkers                       /BU/

INDDOM(DSBS)      Industry and Tertiary         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU/
* the following sets are used in price equation for electricity
INDTRANS(SBS)     Industry and Transport        /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI ,PC,PT,PA,PB,PN,GU,GT, GN /
RESIDENT(SBS)     Residential                   /SE,AG,HOU/
AGSECT            aggregate sectors             /INDSE1,DOMSE1,NENSE1,TRANS1,PG/

*         Energy Forms            *

EF           Energy Forms
/
HCL     "Hard Coal, Coke and Other Solids"
LGN     "Lignite"
CRO     "Crude Oil and Feedstocks"
LPG     "Liquefied Petroleum Gas"
GSL     "Gasoline"
KRS     "Kerosene"
GDO     "Diesel Oil"
RFO     "Residual Fuel Oil"
OLQ     "Other Liquids"
NGS     "Natural Gas"
OGS     "Other Gases"
NUC     "Nuclear"
STE     "Steam"
HYD     "Hydro"
WND     "Wind"
SOL     "Solar"
BMSWAS  "Biomass and Waste"
GEO     "Geothermal and other renewable sources eg. Tidal, etc."
MET     "Methanol"
ETH     "Ethanol"
BGDO    "Biodiesel"
H2F     "Hydrogen"
ELC     "Electricity"
*STE1CL  "Steam coming from CHP plants conventional lgn"
*STE1CH  "Steam produced from CHP conventional hcl"
*STE1CD  "CHP conventional gdo"
*STE1CR  "Steam produced from CHP conventional rfo"
*STE1CG  "Steam produced from CHP conventional ngs"
*STE1CB  "Steam produced from CHP conventional bmswas"
STE1AL  "Steam produced from CHP advanced lgn"
STE1AH  "Steam produced from CHP advanced hcl"
STE1AD  "Steam produced from CHP advanced gdo"
STE1AR  "Steam produced from CHP advanced rfo"
STE1AG  "Steam produced from CHP advanced ngs"
STE1AB  "Steam produced from CHP advanced bmswas"
STE1AH2F "Steam produced from Hydrogen powered CHP fuel cells"
STE2LGN "Steam coming from district heating plants burning lgn"
STE2OSL "Steam produced from district heating plants burning hcl"
STE2GDO "Steam produced from district heating plants burning gdo"
STE2RFO "Steam produced from district heating plants burning rfo"
STE2OLQ "Steam produced from district heating plants burning olq"
STE2NGS "Steam produced from district heating plants burning ngs"
STE2OGS "Steam produced from district heating plants burning ogs"
STE2BMS "Steam produced from district heating plants burning bmswas"
PHEVGSL  "Plug in Hybrid engine - gasoline"
PHEVGDO  "Plug in Hybrid engine - diesel"
*hybrid cars with gasoline and diesel
CHEVGSL  "conventional Hybrid engine - gasoline"
CHEVGDO  "conventional Hybrid engine - diesel"

* Aggregate Fuels
SLD     "Solid Fuels"
GAS     "Gases"
LQD     "All Liquids"
OLQT    "All liquids but GDO, RFO, GSL"
REN     "Renewables except Hydro"
NFF     "Non Fossil Fuels"
NEF     "New energy forms"

* heatpump energy (reduces the final energy demand of non electric consumption)
HEATPUMP "Low enthalpy heat produced by heatpumps reducing the total final consumption of the sector"
/
HEATPUMP(EF) Heatpumps are reducing the heat requirements of the sector but increasing electricity consumption
/HEATPUMP/

EFA(EF)          Aggregate Energy Forms
/
SLD   "Solid Fuels"
LQD   "Liquids"
OLQT  "All liquids but GDO, RFO, GSL"
GAS   "Gases"
REN   "Renewables except Hydro"
STE   "Steam"
NFF   "Non Fossil Fuels"
NEF   "New energy forms"
/

REFORM(EF) FUELS CONSIDERED IN PRICE REFORM
/
CRO     "Crude Oil and Feedstocks"
LPG     "Liquefied Petroleum Gas"
GSL     "Gasoline"
KRS     "Kerosene"
GDO     "Diesel Oil"
RFO     "Residual Fuel Oil"
OLQ     "Other Liquids"
NGS     "Natural Gas"
OGS     "Other Gases"
/

REFORM1(EF) FUELS CONSIDERED IN PRICE REFORM
/HCL
LGN/

RENEF(EF)        Renewable technologies in demand side
/
HYD     "Hydro"
WND     "Wind"
SOL     "Solar"
BMSWAS  "Biomass and Waste"
GEO     "Geothermal and other renewable sources eg. Tidal, etc."
BGDO    "Biodiesel"
*STE1CB  "Steam produced from CHP conventional bmswas"
STE1AB  "Steam produced from CHP advanced bmswas"
STE2BMS "Steam produced from district heating plants burning bmswas"
/

OIL(EF) Liquid fuels in private road transport
/
GSL     "Gasoline"
GDO     "Diesel Oil"
/

EFtoEFA(EF,EFA)  Energy Forms Aggregations (for summary balance report)
/
(HCL,LGN).SLD
(GSL,GDO,RFO,LPG,KRS,OLQ).LQD
(LPG,KRS,OLQ).OLQT
(NGS,OGS).GAS
(STE1AL,STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE1AH2F,STE2LGN,STE2OSL,STE2GDO,STE2RFO,STE2OLQ,
 STE2NGS,STE2OGS,STE2BMS).STE
(WND,SOL,GEO).REN
(HYD,WND,SOL,GEO,NUC,BMSWAS).NFF
(H2F,MET,ETH).NEF
/

WEF              Imported Energy Forms (affecting fuel prices)
/
WHCL    Imported Hard Coal
WCOKE   Imported Coke
WCRO    Imported Crude Oil
WNGS    Imported Natural Gas
WLGN    Lignite for Industry
WGSL    Spot price of gasoline Rotterdam
WGDO    Spot price of diesel Rotterdam
WRFO    Spot price of heavy fuel oil Rotterdam
/

WEFMAP(EF,WEF)          Link between Imported Energy Forms and Energy Forms used in Model Subsectors
/(LGN,STE1AL,STE2LGN).WLGN
(HCL,STE1AH,STE2OSL).WHCL
*(GSL,GDO,RFO,OLQ,KRS,LPG,STE1AD,STE1AR,STE2GDO,STE2RFO,STE2OLQ).WCRO
(NGS,OGS,STE1AG,STE2NGS,STE2OGS).WNGS
HCL.WCOKE
(GSL,KRS).WGSL
(GDO,STE1AD,STE2GDO).WGDO
(RFO,STE1AR,STE2RFO).WRFO
(OLQ,LPG,STE2OLQ).WCRO

/

EFtoWEF(SBS,EF,WEF) Link between Imported Energy Forms and Energy Forms used in Model Subsectors


EFS(EF)          Energy Forms used in Supply Side
/
LGN
HCL
CRO
GSL
GDO
RFO
LPG
KRS
OLQ
NGS
OGS
NUC
STE
HYD
BMSWAS
SOL
WND
GEO
ELC
H2F
MET
ETH
/

EFtoEFS(EF,EFS)    Fuel Aggregation for Supply Side
/
LGN.LGN
HCL.HCL
CRO.CRO
GSL.GSL
GDO.GDO
RFO.RFO
LPG.LPG
KRS.KRS
OLQ.OLQ
NGS.NGS
OGS.OGS
NUC.NUC
(STE1AL,STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE1AH2F,STE2LGN,STE2OSL,STE2GDO,STE2RFO,STE2OLQ,STE2NGS,STE2OGS,STE2BMS).STE
HYD.HYD
(BGDO,ETH,BMSWAS).BMSWAS
SOL.SOL
GEO.GEO
WND.WND
ELC.ELC
MET.MET
H2F.H2F
/


ELCEF(EF)        Electricity                                         /ELC/
H2EF(EF)         Hydrogen                                            /H2F/
STEAM(EFS)       Steam                                               /STE/
TOCTEF(EFS)      Energy forms produced by power plants and boilers   /ELC,STE/
ALTEF(EF)        Alternative Fuels used in transport                 /BGDO,MET,ETH/

ALTMAP(SBS,EF,EF)    Fuels whose prices affect the prices of alternative fuels
/
(PC,GU,PT,PB,GT,GN).MET.GDO
(PC,GU,PT,PB,GT,GN).ETH.GDO
(PC,GU,GN,PN).BGDO.GDO
/


PGEF(EFS)        Energy forms used for power generation
/
LGN
HCL
GDO
RFO
OLQ
NGS
NUC
HYD
BMSWAS
SOL
GEO
WND
H2F
/

h2f1(pgef)
/h2f/

PPRODEF(EFS)     Fuels considered in primary production
/
LGN
HCL
CRO
HYD
BMSWAS
NUC
SOL
GEO
WND
NGS
/


IMPEF(EFS)       Fuels considered in Imports and Exports
/
LGN
HCL
CRO
GSL
GDO
RFO
LPG
KRS
OLQ
NGS
OGS
ELC
*BMSWAS
/

*         Technologies            *

TEAALL              Technology progress (Demand Side)
/
ORD   Ordinary
IMP   Improved
/

TTECH(EF)        Transport Technologies
/
GSL      "Internal Combustion Engine fueled by Gasoline"
LPG      "Internal Combustion Engine fueled by Liquified Petroleum Gas"
GDO      "Internal Combustion Engine fueled by Diesel Oil"
NGS      "Internal Combustion Engine fueled by Natural Gas"
ELC      "Pure Electirc Engine"
KRS      "Gas Turbine fueled by Kerosene"
ETH      "Internal Combustion Engine fueled by Ethanol"
MET      "Methanol (85% gasoline 15% methanol) coming either from ngs or bms"
BGDO     "Biodiesel internal combustion engine"
PHEVGSL  "Plug in Hybrid engine - gasoline"
PHEVGDO  "Plug in Hybrid engine - diesel"
H2F      "Fuel Cells: Hydrogen"
CHEVGSL  "conventional Hybrid engine - gasoline"
CHEVGDO  "conventional Hybrid engine - diesel"
/

TTECHtoEF(TTECH,EF) Fuels consumed by transport technologies
/
GSL.GSL
LPG.LPG
GDO.GDO
NGS.NGS
ELC.ELC
KRS.KRS
ETH.ETH
MET.MET
BGDO.BGDO
PHEVGSL.(GSL,ELC)
PHEVGDO.(GDO,ELC)
H2F.H2F
CHEVGSL.GSL
CHEVGDO.GDO
/


PLUGIN(EF) Plug-in hybrids
/
PHEVGSL
PHEVGDO
/

CHYBV(EF) CONVENTIONAL hybrids
/
CHEVGSL
CHEVGDO
/

SECTTECH(SBS,EF) Link between Model Subsectors and Fuels
/
PC.(GSL,LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGSL,PHEVGDO,CHEVGSL,CHEVGDO)
PB.(GSL,LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGSL,PHEVGDO)
GU.(LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGDO,CHEVGDO) !! Removed GSL and PHEVGSL
(PT,GT).(GDO,ELC,MET)
PA.(KRS)
PN.(GSL,GDO)
GN.(GSL,GDO)
(IS,NF,CH,BM,PP,FD,EN,TX,OE,OI).(LGN,HCL,GDO,RFO,LPG,KRS,OLQ,NGS,OGS,ELC,STE1AL,
                                 STE1AH,STE1AD,STE1AR,STE1AG,STE1AB)
(SE,HOU,AG).                    (LGN,HCL,GSL,GDO,RFO,LPG,KRS,OLQ,NGS,OGS,ELC,STE1AL,
                                 STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE2LGN,STE2OSL,STE2GDO,STE2RFO,STE2OLQ,STE2NGS,
                                 STE2OGS,STE2BMS, BMSWAS)

*BU.(GDO,RFO,OLQ)
BU.(GDO,RFO)
(PCH,NEN).(LGN,HCL,GDO,RFO,LPG,OLQ,NGS,OGS)
PG.(LGN,HCL,GDO,RFO,NGS,NUC,HYD,BMSWAS,SOL,GEO,WND)
H2P.(HCL,RFO,NGS,NUC,BMSWAS,SOL,WND,ELC)
/


PGALL            Power Generation Plant Types
/
*CTHLGN Conventional thermal monovalent lignite
*CTHHCL Conventional thermal monovalent hard coal
*CTHRFO Conventional thermal monovalent fuel oil
*CTHNGS Conventional thermal monovalent natural gas
CTHBMSWAS Conventional thermal monovalent biomass and waste
ATHLGN  Advanced thermal monovalent lignite
ATHHCL Advanced thermal monovalent hard coal
ATHRFO Advanced thermal monovalent fuel oil
ATHNGS Advanced thermal monovalent natural gas
ATHBMSWAS Advanced thermal monovalent biomass and waste
ATHBMCCS
SUPCRL  Supercritical lignite
SUPCR  Supercritical coal
FBCLGN Fluidised bed lignite
FBCHCL Fluidised bed hard coal
IGCCLGN Integrated gasification combine cycle lignite
IGCCHCL Integrtaed gasification combine cycle hard coal
IGCCBMS Integrated gasification combine cycle biomass
CCCGT  Conventional combined cycle gas turbine
ACCGT  Advanced combined cycle gas turbine
*ACCHT  Advanced combined cycle hydrogen combustion turbine
*ICEH2  Internal combustion engine powered by H2
*CGTGDO Conventional gas turbines (peak devices) diesel oil
*CGTNGS Conventional gas turbines (peak devices) natural gas
AGTGDO Advanced gas turbines (peak devices) diesel oil
AGTNGS Advanced gas turbines (peak devices) natural gas
*FC1  Fuel cells
*FC2  Advanced Fuel cells
*PGNUC Nuclear Plants
PGLHYD Large Hydro Plants
PGSHYD Small Hydro Plants
PGWND Wind Plants
PGSOL Solar Photovoltaic Plants
*PGOTHREN Other renewables mainly geothermal
PGASHYD Advanced Small Hydro Plants
PGAWND Advanced Wind Plants
PGASOL Advanced Solar Thermal Plants
PGADPV Advanced Building Integrated PV Plants
PGAOTHREN Advanced geothermal Plants
PGANUC New Nuclear Designs
PGAPSS Supercritical coal with CCS
PGAPSSL Supercritical lignite with CCS
PGACGSL Integrated lignite gasification with CCS
PGACGS Integrated coal gasification with CCS
PGAGGS Gas turbine combined cycle with CCS
PGAWNO Wind offshore
/

PGASOL(PGALL)
/PGASOL/

CCS(PGALL) Plants which can be equipped with CCS
/
PGAPSS
PGAPSSL
PGACGSL
PGACGS
PGAGGS
ATHBMCCS
/


NOCCS(PGALL) Plants which can be equipped with CCS but they are not
/
SUPCRL
SUPCR
IGCCHCL
IGCCLGN
ACCGT
ATHBMSWAS
/

CCS_NOCCS(PGALL,PGALL) mapping
/
PGAPSSL.SUPCRL
PGAPSS.SUPCR
PGACGSL.IGCCLGN
PGACGS.IGCCHCL
PGAGGS.ACCGT
ATHBMCCS.ATHBMSWAS
/

CHP(EF)       CHP Plants
/
STE1AL,STE1AH,STE1AD,STE1AR,STE1AG,STE1AB
/

DH(EF)       District Heating
/
STE2LGN
STE2OSL
STE2GDO
STE2RFO
STE2OLQ
STE2NGS
STE2OGS
STE2BMS
/

PGNUCL(PGALL)    Nuclear plants                            / PGANUC/
PGREN(PGALL)     Renewable Plants                          /PGLHYD,PGSHYD,PGWND,PGSOL,PGASHYD,PGAWND,PGASOL,PGAOTHREN, PGAWNO, PGADPV/
PGNREN(PGALL)    Advanced Renewable Plants potential      /PGASHYD,PGAWND,PGASOL,PGAOTHREN,PGAWNO,PGADPV,ATHBMSWAS,IGCCBMS/
PGGEO(PGALL)     Geothermal Plants                        /PGAOTHREN/
PGRENEF          Renewable energy forms in power generation  /LHYD,SHYD,WND,WNO,SOL,DPV,BMSWAS,OTHREN/

PGALLtoPGRENEF(PGALL,PGRENEF)     Correspondence between renewable plants and renewable energy forms
/
PGLHYD.LHYD
(PGSHYD,PGASHYD).SHYD
(PGWND,PGAWND).WND
PGAWNO.WNO
(PGSOL,PGASOL).SOL
PGADPV.DPV
(PGAOTHREN).OTHREN
(CTHBMSWAS,ATHBMSWAS,IGCCBMS,ATHBMCCS).BMSWAS
/

PGALLtoEF(PGALL,PGEF)     Correspondence between plants and energy forms
/
(ATHLGN,FBCLGN,IGCCLGN,SUPCRL,PGAPSSL,PGACGSL).LGN
(ATHHCL,SUPCR,FBCHCL,IGCCHCL, PGAPSS, PGACGS).HCL
(ATHRFO).RFO
(AGTGDO).GDO
(ATHNGS,CCCGT,ACCGT,AGTNGS,PGAGGS).NGS
(CTHBMSWAS,ATHBMSWAS,IGCCBMS,ATHBMCCS).BMSWAS
(PGANUC).NUC
(PGLHYD,PGSHYD,PGASHYD).HYD
(PGWND,PGAWND,PGAWNO).WND
(PGSOL,PGASOL,PGADPV).SOL
(PGAOTHREN).GEO
*(ACCHT,ICEH2,FC2).H2F
/

CHPtoEF(EF,EF)           correspondence of CHP plant types to fuels
/
(STE1AL).LGN
(STE1AH).HCL
(STE1AD).GDO
(STE1AR).RFO
(STE1AG).NGS
(STE1AB).BMSWAS
STE1AH2F.H2F
/

DHtoEF(EF,EF)          correspondence of district heating plant types to fuels
/
STE2LGN.LGN,
STE2OSL.HCL,
STE2GDO.GDO,
STE2RFO.RFO,
STE2OLQ.OLQ,
STE2NGS.NGS,
STE2OGS.OGS,
STE2BMS.BMSWAS
/

CHPtoEON(EF,PGALL)       Mapping of chp technologies to elec-only technologies
/
*STE1CL.CTHLGN,
*STE1CH.CTHHCL,
*STE1CD.CGTGDO,
*STE1CR.CTHRFO,
*STE1CG.CTHNGS,
*STE1CB.CTHBMSWAS,
STE1AL.SUPCRL,
STE1AH.SUPCR,
STE1AD.AGTGDO,
STE1AR.ATHRFO,
STE1AG.ACCGT,
STE1AB.ATHBMSWAS
*STE1AH2F.FC2
/

PGSCRN(PGALL)     New plants involved in endogenous scrapping (these plants are not scrapped)
/
ATHBMSWAS
SUPCRL
SUPCR
FBCLGN
FBCHCL
IGCCLGN
IGCCHCL
IGCCBMS
*ACCHT,ICEH2
*FC1,FC2
*PGNUC
PGLHYD
PGSHYD
PGWND
PGSOL
*PGOTHREN
PGASHYD
PGAWND
PGASOL
PGANUC
PGAPSS
PGAPSSL
PGACGSL
PGACGS
PGAGGS
PGAWNO
PGADPV
PGAOTHREN
ATHBMCCS
/

*           Emissions             *

EMISS            "Pollutant Emissions"
/
CO2      "Carbon dioxide"
CH4      "Methanio"
N2O      "Nitrogen dioxide"
HFC      "Hydrofluorocarbons"
PFC      "Perfluorinated Compounds "
SF6      "Sulfur Hexafluoride"
/



SCT_GHGtoEMISS(SCT_GHG,EMISS)  Mapping between sectors and emissions
/
(LGN_PRD_CH4,HCL_PRD_CH4,GAS_PRD_CH4,TERT_CH4,TRAN_CH4,AG_CH4,SE_CH4).CH4
(TRAN_N2O,TX_N2O,AG_N2O).N2O
(OI_PFC,NF_PFC).PFC
OI_HFC.HFC
BM_CO2.CO2
(PG_SF6,OI_SF6).SF6
/

CO2SEQELAST Elasticities for CO2 sequestration cost curve
/
POT      MAXIMUM POTENTIAL
mc_a     linear slope
mc_b     initial cost at x=0
mc_c
mc_d
mc_s     speed to transition to exponential
mc_m     value for the ratio of x to potential after which exponential is taking over

/


*   DUMMY SETS USED FOR DATA INPUT  *

ETYPES           "Elasticities types"
/a,b1,b2,b3,b4,b5,c,c1,c2,c3,c4,c5,aend,b3end,b4end/

ECONCHAR         "Technical - Economic characteristics for demand technologies"
/
IC       "Capital Cost"
FC       "Fixed O&M Cost"
VC       "Variable Cost"
LFT      "Technical Lifetime"
USC   "Useful Energy Conversion Factor"
/


PGECONCHAR       "Technical - economic characteristics for power generation plants"
/
LFT
/

SG               "S parameters in Gompertz function for passenger cars vehicle km"
/S1,S2,S3,SAT/

TRANSPCHAR       "Various transport data used in equations and post-solution calculations"
/
KM_VEH           "Thousands km per passenger car vehicle"
KM_VEH_TRUCK     "Thousands km per truck vehicle"
OCCUP_CAR        "Passengers per car (car occupancy rate)"
RES_MEXTV        "Residual for controlling the GDP-Dependent market extension of passenger cars"
RES_MEXTF        "Residual for controlling the GDP-Independent market extension of passenger cars"
/

TRANSUSE         "Usage (average) data concerning capacity and load factor"
/
CAP              "Capacity in tn/vehicle or passengers/vehicle"
LF               "Load factor"
/

TOCTSET          "Total Transformation Output and Total District Heating Output"
/
TOCT_ELC         "Electricity Total Transformation Output in Mtoe"
TOCT_STE         "Steam Total Transformation Output in Mtoe"
TONUC_ELC        "Electricity production from nuclear plants in Mtoe"
TODH_STE         "Steam produced from District Heating Plants in Mtoe"
/


SUPOTH           "Indicators related to supply side"
/
REF_CAP          "Refineries Capacity in Mbl/day"
REF_CAP_RES      "Residuals of Refineries Capacity"
HCL_PPROD        "Residual of Hard Coal Primary Production"
NGS_PPROD        "Residual of Natural Gas Primary Production"
OIL_PPROD        "Residual of Crude Oil Primary Production"
NGS_EXPORT       "Residual of Natural Gas Exports"
ELC_IMP          "Ratio of electricity imports to total final demand"
TIOTH_RES        "Residual of Total Transformation Input in Gasworks, Blast Furnances, etc."
TOOTH_RES        "Residual of Total Transformation Output from Gasworks, etc."
FEED_RES         "Residual for Feedstocks in Transfers"
/

PGOTH            "Various data related to power generation plants"
/
TOTCAP           "Total Available capacity in Base Year (GW)"
PEAKLOAD         "Peak Load in Base Year (GW)"
BASELOAD         "Base Load in Base Year (GW)"
NON_CHP_PER      "Non-CHP capacity (percentage of total (gross) capacity)"
CHP_CAP          "CHP Capacity (gross) in GW"
CHP_ELC          "CHP electricity"
*STE1CL           "Utilisation rate of Lignite powered conventional CHP"
*STE1CH           "Utilisation rate of Hard Coal powered conventional CHP"
*STE1CD           "Utilisation rate of Diesel Oil powered conventional CHP"
*STE1CR           "Utilisation rate of Fuel Oil powered conventional CHP"
*STE1CG           "Utilisation rate of Natural Gas powered conventional CHP"
*STE1CB           "Utilisation rate of Biomass-Waste powered conventional CHP"
STE1AL           "Utilisation rate of Lignite powered advanced CHP"
STE1AH           "Utilisation rate of Hard Coal powered advanced CHP"
STE1AD           "Utilisation rate of Diesel Oil powered advanced CHP"
STE1AR           "Utilisation rate of Fuel Oil powered advanced CHP"
STE1AG           "Utilisation rate of Natural Gas powered advanced CHP"
STE1AB           "Utilisation rate of Biomass-Waste powered advanced CHP"
STE1AH2F         "Utilisation rate of HYDROGEN powered FUEL CELL CHP"
* The following fuels are related with district heating efficiency
LGN
HCL
GDO
RFO
OLQ
NGS
OGS
BMSWAS
/

PGLOADTYPE(PGOTH)   "Peak and Base load of total electricity demand in GW"
/PEAKLOAD, BASELOAD/

CHPSET(PGOTH)       "Indicators related to CHP Production"                       /NON_CHP_PER,CHP_CAP/

PGEFS(PGOTH)        "Fuels used as Input to District Heating"                    /LGN,HCL,GDO,RFO,OLQ,NGS,OGS,BMSWAS/

PG_CHP(PGOTH)/
*STE1CL,STE1CH,STE1CD,STE1CR,STE1CG,STE1CB,
STE1AL,STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE1AH2F/

VARIOUS_LABELS /AMAXBASE, MAXLOADSH/


PGRES
/
TOT_CAP_RES         "Residual on Total Capacity (Reserve margin on capacity)"
BASE_LOAD_RES       "Residual on Base Load "
MAX_LOAD_RES        "Residual on Peak Load (Peak Load margin)"
/


CHPRES_SET
/
CHP_CC           Capital cost RD residual adjustment
CHP_FOM          FOM cost RD residual adjustment
CHP_VOM          VOM cost RD residual adjustment
/

nucres_set
/res/

Gompset1 /PC/
Gompset2 /s1,s2,s3,sat,mextv,scr /
Indu_SCon_Set /Base, SHR_NSE, SH_HPELC/

CHPPGSET /IC,FC,VOM,LFT,AVAIL,BOILEFF,MAXCHPSHARE/

ELSH_SET /elsh/

BALEF fuels in balance report
/
"Total"
"Solids"
"Hard coal"
"Lignite"
"Crude oil and Feedstocks"
"Liquids"
"Liquified petroleum gas"
"Gasoline"
"Kerosene"
"Diesel oil"
"Fuel oil"
"Other liquids"
"Gas fuels"
"Natural gas"
"Derived gases"
"Nuclear heat"
"Steam"
"Hydro"
"Wind"
"Solar energy"
"Biomass"
"Geothermal heat"
"Methanol"
"Hydrogen"
"Electricity"
/

biomass(balef)
/"biomass"/

TOTAL(BALEF)
/"TOTAL"/
BALEF2EFS(BALEF, EFS) Mapping from balance fuels to model fuels
/
"Total".(HCL,LGN,CRO,LPG,GSL,KRS,GDO,RFO,OLQ,NGS,OGS,NUC,STE,HYD,WND,SOL,BMSWAS,GEO,MET,ETH,H2F,ELC)
"Solids".(HCL,LGN)
"Hard coal".HCL
"Lignite".LGN
"Crude oil and Feedstocks".CRO
"Liquids".(LPG,GSL,KRS,GDO,RFO,OLQ)
"Liquified petroleum gas".LPG
"Gasoline".GSL
"Kerosene".KRS
"Diesel oil".GDO
"Fuel oil".RFO
"Other liquids".OLQ
"Gas fuels".(NGS,OGS)
"Natural gas".NGS
"Derived gases".OGS
"Nuclear heat".NUC
"Steam".STE
"Hydro".HYD
"Wind".WND
"Solar energy".SOL
"Biomass".BMSWAS
"Geothermal heat".GEO
"Methanol".MET
"Hydrogen".H2F
"Electricity".ELC
/

*         SET ASSIGNMENTS           *

alias(TT, ytime);
* TT set is used as an index to main time loop
alias (YYTIME,ytime);
alias(EF, EF2);
* this alias is used in alternative transport fuels price calculations
alias(PGALL2,PGALL);
*this alias is used in plant dispatching equation


scalar TF order of base year in set ytime;
TF=sum((TFIRST,ytime), ord(ytime)$TFIRST(ytime));

* Allocate imported fuels to fuels used in demand subsectors
EFtoWEF(SBS,EF,WEF)=NO;
loop WEF do
  loop EF$WEFMAP(EF,WEF) do
    loop SBS$SECTTECH(SBS,EF) do
         if not sameas(WEF,"WCOKE") then
             EFtoWEF(SBS,EF,WEF)=yes;
         endif;
    endloop;
  endloop;
endloop;
EFtoWEF("IS","HCL","WCOKE")=yes; !! special case for Iron and Steel -> hard coal is in fact coke
EFtoWEF("IS","HCL","WHCL")=no; !! special case for Iron and Steel -> hard coal is in fact coke


Parameter TECHS(DSBS) Number of technologies in transport subsectors;

loop DSBS$TRANSE(DSBS) do
     TECHS(DSBS)=0;
     loop EF$SECTTECH(DSBS,EF) do
       TECHS(DSBS) = TECHS(DSBS)+1;
     endloop;
endloop;

alias(NAP2,NAP);

ALIAS (EFS2,EFS);
ALIAS (CHP2,CHP);
ALIAS (INDDOM2,INDDOM);
ALIAS (YYTIME2,ytime);


scalar ordfirst /0/;
ordfirst=sum((ytime,YYTIME2)$((ord(ytime)<=ord(YYTIME2)) $TFIRST(YYTIME2)),1);

