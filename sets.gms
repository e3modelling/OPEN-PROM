sets
*        Geographic Coverage      *
allCy    Countries for which the model is applied
/
ALG       ALGERIA
MOR       MOROCCO
TUN       TUNISIA
EGY       EGYPT
LIB       LIBYA
ISR       ISRAEL
LEB       LEBANON
SYR       SYRIA
JOR       JORDAN
TUR       TURKEY
/

runCy(allCy) Countries for which the model is running
/
ALG       ALGERIA
MOR       MOROCCO
TUN       TUNISIA
EGY       EGYPT
ISR       ISRAEL
LEB       LEBANON
JOR       JORDAN
/

*        Model Time Horizon       *

ytime           Model time horizon                                /1990*2050/
ytime30(ytime)  Model time horizon up to 2030                     /1990*2030/
an(ytime)       Years for which the model is running              /%starty%*%endy%/
twenties(ytime) THE DECADE FROM 2020-2030                         /2021*2030/
thirties(ytime) THE DECADE FROM 2030-2040                         /2031*2040/
after2020(ytime) The period 2021 to 2050                          /2021*2050/
after2030(ytime) The period 2031 to 2050                          /2031*2050/
after2035(ytime) The period 2036 to 2050                          /2036*2050/
an1(ytime) /2010*2015/
an2(ytime) /2016*2030/
an3(ytime) /2016*2020/
an4(ytime) /2021*2025/
an5(ytime) /2026*2030/
dataY(ytime)    Historical year before the base year of the model /1990*2017/
carbon(ytime)   Years for which cabon tax is applied
period(ytime)   Model can also run for periods of years
tFirst(ytime)   Base year                                         /2017/
tFirstAn(ytime) First year for which the model is running         /2018/
time(ytime)     Model time horizon used in equation definitions
timeRep(ytime)  Model time horizon used in report
hour            "Segments of hours in a year (250,1250,...,8250)" /h0*h8/

*          Consumer Sizes         *

conSet       Consumer size groups related to space heating
/
smallest
modal
largest
/

conSizeSet /size/
eSet         Electricity consumers used for average electricity price calculations /i,r/
iSet(eSet)   Industrial consumer /i/
rSet(eSet)   Residential consumer /r/


*       Auxiliary Counters        *

rCon         counter for the number of consumers              /0,1*19/
nSet         auxiliary counter for the definition of Vr       /b1*b20/
kpdl         counter for Polynomial Distribution Lag          /a1*a6/
rc                                                            /1*3/
rres                                                          /r1*r4/


*       Sectoral Structure        *

sct          Model Sectors
/
INDU   Industry
TRAN   Transport
TERT   Tertiary
PSG    Power and Steam Generation
BUN    Bunkers
PCH    Petrochemical Industry
OTHNEN Other non energy uses
/

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
*PB    "Passenger Transport - Busses"
PT    "Passenger Transport - Rail"
*PN    "Passenger Transport - Inland Navigation"
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

pg(sbs)
/pg/

SCTtoSBS(SCT, SBS)  Sectors to Subsectors
/
INDU.(IS,NF,CH,BM,PP,FD,EN,TX,OE,OI)
TRAN.(PC,PT,PA,GU,GT,GN)
TERT.(SE,AG,HOU)
PSG.PG
BUN.BU
PCH.PCH
OTHNEN.NEN
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
exogCV
/

RegulaPolicies(POLICIES_set) Set of policies entering in the regula falsi loops
/ OPT           Carbon Value for Optimal CO2 permits allocation
  TRADE         Carbon Value for Trade sectors
  REN           Renewable value for renewable target in final demand
  EFF           Efficiency value for energy savings in final demand
  NONE          No policy
/

APolicies(RegulaPolicies) Regula falsi policies that are active
PolicyYears(RegulaPolicies, ytime) Years for which a policy is effective

NAP(Policies_set) National Allocation plan sector categories
/
Trade    Carbon Value for trading sectors
NoTrade  Carbon Value for non-trading sectors
/

NAPtoALLSBS(NAP,ALLSBS) Energy sectors corresponding to NAP sectors
/
Trade.(FD,EN,TX,OE,OI,NF,CH,IS,BM,PP,PG,BM_CO2,H2P)
NoTrade.(SE,AG,HOU,PC,PB,PT,PN,PA,GU,GT,GN,BU,PCH,NEN,LGN_PRD_CH4,HCL_PRD_CH4,GAS_PRD_CH4,TERT_CH4,TRAN_CH4,AG_CH4,SE_CH4,TRAN_N2O,TX_N2O,AG_N2O,OI_HFC,OI_PFC,NF_PFC,PG_SF6,OI_SF6)
/

DSBS(SBS)         All Demand Subsectors         /PC,PT,PA,GU,GT,GN, IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU,PCH,NEN,BU/
TRANSE(DSBS)      All Transport Subsectors      /PC,PT,PA,GU,GT,GN/
TRANS1(SBS)       All Transport Subsectors      /PC,PT,PA,GU,GT,GN/
TRANP(TRANSE)     Passenger Transport           /PC,PT,PA/
TRANP1(SBS)       Passenger Transport           /PC,PT,PA/
TRANG(TRANSE)     Goods Transport               /GU,GT,GN/
TRANG1(SBS)       Goods Transport               /GU,GT,GN/
TRANR(TRANSE)     Road Transport                /PC,GU/
TRANR1(SBS)       Road Transport                /PC,GU/
TRANT(TRANSE)     Train Transport               /PT,GT/
TRANA(TRANSE)     Aviation                      /PA/
*TRANI(TRANSE)     Inland Navigation             /PN,GN/

INDSE(DSBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE(DSBS)       Tertiary SubSectors           /SE,AG,HOU/
INDSE1(SBS)       Industrial SubSectors         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI/
DOMSE1(SBS)       Tertiary SubSectors           /SE,AG,HOU/
HOU(DSBS)         Households                     /HOU/
TERSE(DSBS)       Services and Agriculture      /SE,AG/
NENSE(DSBS)       Non Energy and Bunkers        /PCH,NEN,BU/
NENSE1(SBS)       Non Energy and Bunkers        /PCH,NEN,BU/
BUN(DSBS)         Bunkers                       /BU/

INDDOM(DSBS)      Industry and Tertiary         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU/
INDDOM1(SBS)      Industry and Tertiary         /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI,SE,AG,HOU/
* the following sets are used in price equation for electricity
INDTRANS(SBS)     Industry and Transport        /IS,NF,CH,BM,PP,FD,EN,TX,OE,OI ,PC,PT,PA,GU,GT, GN /
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

* heatpump energy (reduces the final energy demand of non electric consumption
HEATPUMP "Low enthalpy heat produced by heatpumps reducing the total final consumption of the sector"
/

HEATPUMP(EF) Heatpumps are reducing the heat requirements of the sector but increasing electricity consumption
/HEATPUMP/

h2f(ef)
/h2f/

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
OLQ(EF)
/OLQ/
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
(PC,GU,PT,GT,GN).MET.GDO
(PC,GU,PT,GT,GN).ETH.GDO
(PC,GU,GN).BGDO.GDO
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

EFIS(EF)        Fuels in Iron and Steel sector in which useful energy conversion factor is expressed in tn per toe
/HCL, ELC/

*         Technologies            *

TEAALL              Technology progress (Demand Side)
/
ORD   Ordinary
IMP   Improved
/

TEA(TEAALL)         Technologies currently used inside the model
/ORD/



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


ITECH(EF)        Industrial Technologies
/
LGN,HCL,GDO,RFO,OLQ,NGS,OGS,STE1AL,
STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE1AH2F, HEATPUMP, BMSWAS,ELC
/

DTECH(EF)        Tertiary Technologies
/
LGN,HCL,GSL,GDO,RFO,OLQ,NGS,OGS,STE1AL,
STE1AH,STE1AD,STE1AR,STE1AG,STE1AB,STE1AH2F, HEATPUMP,STE2LGN,STE2OSL,STE2GDO,STE2RFO,STE2OLQ,STE2NGS,
STE2OGS,STE2BMS,SOL,BMSWAS,ELC
/

BTECH(EF)        Bunkers Technologies                    /GDO,RFO,OLQ/

PNTECH(EF)       Petrochemical Technologies               /LGN,HCL,GDO,RFO,OLQ,NGS,OGS/

SECTTECH(SBS,EF) Link between Model Subsectors and Fuels
/
PC.(GSL,LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGSL,PHEVGDO,CHEVGSL,CHEVGDO)
*PB.(GSL,LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGSL,PHEVGDO)
GU.(GSL,LPG,GDO,NGS,ELC,ETH,MET,BGDO,PHEVGSL,PHEVGDO,CHEVGDO)
(PT,GT).(GDO,ELC,MET)
PA.(KRS)
*(PN,GN).(GSL,GDO)
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

NETTECH(SBS,EF) Link between model subsectors and technologies participating in network effect
/
(PC,GU).(ELC,H2F,PHEVGSL,PHEVGDO)
(PT,GT).(H2F)
PA.(H2F)
*(PN,GN).(H2F)
(IS,NF,CH,BM,PP,FD,EN,TX,OE,OI).(STE1AH2F,HEATPUMP,ELC)
(SE,HOU,AG).                    (STE1AH2F,HEATPUMP,ELC)
/


NETTECHTRA(SBS,EF) Link between transport subsectors and technologies participating in network effect
/
(PC).(ELC,H2F,PHEVGSL,PHEVGDO)
PT.H2F
PA.H2F
*PN.H2F
GU.(ELC,H2F,PHEVGSL,PHEVGDO)
GT.H2F
GN.H2F
/


NETEF(EF)
/
ELC,H2F,PHEVGSL,PHEVGDO,STE1AH2F,HEATPUMP
/

NETEF2(EF)
/
ELC,H2F,HEATPUMP
/

NETEF3(EF)
/
ELC,H2F,PHEVGSL,PHEVGDO
/
NETEF4
/
OTH,TRA
/

TRANSFINAL(TRANSE)
/PC,PA,PT,GU,GT,GN/

TRANSPFINAL(TRANSFINAL)/PC,PA,PT/
TRANSGFINAL(TRANSFINAL)/GU,GT,GN/

TRANSNONPC(TRANSE)
/PA,PT/

TRANSGOOD(TRANSE)
/GU,GT,GN/

TRANSPC(TRANSE)
/PC/

TRANSPASS(TRANSE)
/PA,PC,PT/


NETEFtoNETEF2(EF,EF)

/
ELC.(ELC,PHEVGSL,PHEVGDO)
HEATPUMP.HEATPUMP
H2F.(H2F,STE1AH2F)
/

NETEFtoNETEF3(EF,EF)

/
ELC.(ELC,PHEVGSL,PHEVGDO)
H2F.H2F
/


TRANSETTECH(TRANSE,TTECH) Technologies used in transport sectors
/
PC.(GSL,LPG,GDO,NGS,ELC,ETH,MET,H2F,BGDO,PHEVGSL,PHEVGDO,CHEVGSL,CHEVGDO)
*PB.(GSL,LPG,GDO,NGS,ELC,ETH,MET,H2F,BGDO,PHEVGSL,PHEVGDO)
GU.(GSL,LPG,GDO,NGS,ELC,ETH,MET,H2F,BGDO,PHEVGSL,PHEVGDO,CHEVGDO)
(PT,GT).(GDO,ELC,MET,H2F)
PA.(KRS,H2F)
*(PN,GN).(GSL,GDO,H2F)
GN.(GSL,GDO,H2F)
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
CONVPGALL(PGALL)            Conventional power generation plant types
/
*CTHLGN Conventional thermal monovalent lignite
*CTHHCL Conventional thermal monovalent hard coal
*CTHRFO Conventional thermal monovalent fuel oil
*CTHNGS Conventional thermal monovalent natural gas
CTHBMSWAS Conventional thermal monovalent biomass and waste
CCCGT  Conventional combined cycle gas turbine
*CGTGDO Conventional gas turbines (peak devices) diesel oil
*CGTNGS Conventional gas turbines (peak devices) natural gas
*PGNUC Nuclear Plants
PGLHYD Large Hydro Plants
PGSHYD Small Hydro Plants
PGWND Wind Plants
PGSOL Solar Photovoltaic Plants
*PGOTHREN Other renewables mainly geothermal
/




BMSPGALL(PGALL)
/
ATHBMSWAS
IGCCBMS
/

CCS(PGALL) Plants which can be equipped with CCS
/
PGAPSS
PGAPSSL
PGACGSL
PGACGS
PGAGGS
/


NOCCS(PGALL) Plants which can be equipped with CCS but they are not
/
SUPCRL
SUPCR
IGCCHCL
IGCCLGN
ACCGT
/

CCS_NOCCS(PGALL,PGALL) mapping
/
PGAPSSL.SUPCRL
PGAPSS.SUPCR
PGACGSL.IGCCLGN
PGACGS.IGCCHCL
PGAGGS.ACCGT
/




CHP(EF)       CHP Plants
/
STE1AL,STE1AH,STE1AD,STE1AR,STE1AG,STE1AB
/

*CONVCHP(EF)  Conventional CHP Plants
*/
*STE1CL,STE1CH,STE1CD,STE1CR,STE1CG,STE1CB
*/


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
*PGEXO(PGALL)     Plant types that are forecast exogenously /PGNUC, PGLHYD/
PGEXO(allCy,PGALL,Ytime)     Plant types for exogenous investment
PGREN(PGALL)     Renewable Plants                          /PGLHYD,PGSHYD,PGWND,PGSOL,PGASHYD,PGAWND,PGASOL,PGAOTHREN, PGAWNO, PGADPV/
PGNREN(PGALL)    Advanced Renewable Plants potential      /PGASHYD,PGAWND,PGASOL,PGAOTHREN,PGAWNO,PGADPV,ATHBMSWAS,IGCCBMS/
PGGEO(PGALL)     Geothermal Plants                        /PGAOTHREN/
PGRENEF          Renewable energy forms in power generation  /LHYD,SHYD,WND,WNO,SOL,DPV,BMSWAS,OTHREN/
PGHYDRO(PGALL) Hydro power technologies  /PGLHYD,PGSHYD,PGASHYD/
PGRENSUBS(PGALL) RES technologies to be subsidized in a scenario /PGAWND,PGASOL,PGAWNO,PGADPV,ATHBMSWAS,IGCCBMS,PGASHYD/

PGALLtoPGRENEF(PGALL,PGRENEF)     Correspondence between renewable plants and renewable energy forms
/
PGLHYD.LHYD
(PGSHYD,PGASHYD).SHYD
(PGWND,PGAWND).WND
PGAWNO.WNO
(PGSOL,PGASOL).SOL
PGADPV.DPV
(PGAOTHREN).OTHREN
(CTHBMSWAS,ATHBMSWAS,IGCCBMS).BMSWAS
/



PGALLtoEF(PGALL,PGEF)     Correspondence between plants and energy forms
/
(ATHLGN,FBCLGN,IGCCLGN,SUPCRL,PGAPSSL,PGACGSL).LGN
(ATHHCL,SUPCR,FBCHCL,IGCCHCL, PGAPSS, PGACGS).HCL
(ATHRFO).RFO
(AGTGDO).GDO
(ATHNGS,CCCGT,ACCGT,AGTNGS,PGAGGS).NGS
(CTHBMSWAS,ATHBMSWAS,IGCCBMS).BMSWAS
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

PGALLAG        Aggregations of power plants used in the aggregated report
/
NUC      "Nuclear Power Plants"
REN      "Renewables"
HYD      "Hydro Plants"
WND      "Wind Plants"
BMS      "Biomass and waste"
SOL      "Other renewables (mainly solar)"
THE      "Thermal plants"
HCL      "Solids"
ICG      "Clean coal"
SUP      "Supercritical"
OIL      "oil"
GAS      "Gas plants"
GGC      "Combined cycles"
OTH      "Hydrogen"
/

PGALLtoPGALLAG(PGALL,PGALLAG)
/

*CTHLGN.(HCL,THE)
*CTHHCL.(HCL,THE)
*CTHRFO.(OIL,THE)
*CTHNGS.(GAS,THE)
CTHBMSWAS.(BMS,REN)
ATHLGN.(HCL,THE)
ATHHCL.(HCL,THE)
ATHRFO.(OIL,THE)
ATHNGS.(GAS,THE)
ATHBMSWAS.(BMS,REN)
SUPCRL.(HCL,SUP,THE)
SUPCR.(HCL,SUP,THE)
FBCLGN.(HCL,SUP,THE)
FBCHCL.(HCL,SUP,THE)
IGCCLGN.(HCL,ICG,THE)
IGCCHCL.(HCL,ICG,THE)
IGCCBMS.(BMS,REN)
CCCGT.(GAS,GGC,THE)
ACCGT.(GAS,GGC,THE)
*(ACCHT,ICEH2).OTH
*CGTGDO.(OIL,THE)
*CGTNGS.(GAS,THE)
AGTGDO.(OIL,THE)
AGTNGS.(GAS,THE)
*FC1.OTH
*FC2.OTH
*PGNUC.NUC
PGLHYD.(HYD,REN)
PGSHYD.(HYD,REN)
PGWND.(WND,REN)
PGSOL.(SOL,REN)
*PGOTHREN.(SOL,REN)
PGASHYD.(HYD,REN)
PGAWND.(WND,REN)
PGASOL.(SOL,REN)
PGADPV.(SOL,REN)
PGAOTHREN.(SOL,REN)
PGANUC.NUC
PGAPSS.(HCL,SUP,THE)
PGAPSSL.(HCL,SUP,THE)
PGACGSL.(HCL,ICG,THE)
PGACGS.(HCL,ICG,THE)
PGAGGS.(GAS,GGC,THE)
PGAWNO.(WND,REN)
/
geme3tech
/
coalconv
gasconv
oilconv
gasadv
nuc
hyd
bms
wind
spv
csp
coalccs
gasccs
/

pgmap(geme3tech,pgall)
/
coalconv.(ATHLGN,ATHHCL,SUPCRL,SUPCR,FBCLGN,FBCHCL,IGCCLGN,IGCCHCL)
gasconv.(ATHNGS,AGTNGS)
oilconv.(ATHRFO,AGTGDO)
gasadv.(CCCGT,ACCGT)
nuc.(PGANUC)
hyd.(PGLHYD,PGSHYD,PGASHYD)
bms.(CTHBMSWAS,ATHBMSWAS,IGCCBMS)
wind.(PGWND,PGAWND,PGAWNO)
spv.(PGSOL,PGADPV)
csp.(PGASOL)
coalccs.(PGAPSS,PGAPSSL,PGACGSL,PGACGS)
gasccs.(PGAGGS )
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
/

NEWTECHS(PGALL) new technologies
/
ATHLGN  Advanced thermal monovalent lignite
ATHHCL Advanced thermal monovalent hard coal
ATHRFO Advanced thermal monovalent fuel oil
ATHNGS Advanced thermal monovalent natural gas
ATHBMSWAS Advanced thermal monovalent biomass and waste
SUPCRL  Supercritical lignite
SUPCR  Supercritical coal
FBCLGN Fluidised bed lignite
FBCHCL Fluidised bed hard coal
IGCCLGN Integrated gasification combine cycle lignite
IGCCHCL Integrtaed gasification combine cycle hard coal
IGCCBMS Integrated gasification combine cycle biomass
ACCGT  Advanced combined cycle gas turbine
AGTGDO Advanced gas turbines (peak devices) diesel oil
AGTNGS Advanced gas turbines (peak devices) natural gas
*ACCHT Advanced combined cycle hydrogen combustion turbines
*ICEH2  Internal combustion engine powered by H2
*FC1  Fuel cells
*FC2  Advanced Fuel cells
PGASHYD Advanced Small Hydro Plants
PGAWND Advanced Wind Plants
PGASOL Advanced Solar Thermal Plants
PGADPV Advanced Building Integrated PV Plants
PGAOTHREN Advanced geothermal Plants
PGANUC New Nuclear Designs
PGAPSSL Supercritical lignite with CCS
PGAPSS Supercritical coal with CCS
PGACGSL Integrated lignite gasification with CCS
PGACGS Integrated coal gasification with CCS
PGAGGS Gas turbine combined cycle with CCS
PGAWNO Wind offshore
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

NO_SCT_GHGtoallCy(SCT_GHG,allCy,ytime) Mapping between Sectors that do not emit in some countries
/
HCL_PRD_CH4.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)
LGN_PRD_CH4.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)
NF_PFC.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)
OI_SF6.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)
OI_PFC.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)

BM_CO2.(ALG,MOR,TUN,EGY,LIB,ISR,LEB,JOR,SYR,TUR).(2001*2030)
/

NO_DEMANDtoallCy(DSBS,allCy,ytime) Mapping between Sectors that do not EXIST IN CERTAIN COUNTRIES
/
(PCH,NF).TUN.(2001*2030)
/

NO_FUEL_TO_SCT (DSBS,EF,allCy,ytime)
/NF.OLQ.TUN.(2001*2030)/

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

Macro            "Elements used for reading Pop,GDP, Consumption Expenditure and Value Added"
/GDP,CONS_EXP,IS,NF,CH,BM,PP,FD,TX,EN,OE,OI,SE,AG,PCH,NEN,BU,HOU,POP,HOU_SIZE,HOUSEHOLDS/

HOUCHAR(Macro)   "Elements used for reading ingabidants per Households and number of Households"
/CONS_EXP,HOU_SIZE,HOUSEHOLDS/

ETYPES           "Elasticities types"
/a,b1,b2,b3,b4,b5,c,c1,c2,c3,c4,c5,aend,b3end,b4end/

ELCPCHAR         "Factors controlling electricity price"
/
INDU     "Elecprice-eleccost in Industry"
TERT     "Elecprice-eleccost in Tertiary"
W_INDU   "Weight for production cost in industry"
W_TERT   "Weight for production cost in tertiary"
IND_RES  "Additive residual to electricity price for industry"
TERT_RES  "Additive residual to electricity price for tertiary"
VAT      "VAT"
/

ECONCHAR         "Technical - Economic characteristics for demand technologies"
/
IC_00    "Capital Cost in 2000"
IC_05    "Capital Cost in 2005"
IC_10    "Capital Cost in 2010"
IC_15    "Capital Cost in 2015"
IC_20    "Capital Cost in 2020"
IC_25    "Capital Cost in 2025"
IC_30    "Capital Cost in 2030"
IC_50    "Capital cost in 2050"

FC_00    "Fixed O&M Cost in 2000"
FC_05    "Fixed O&M Cost in 2005"
FC_10    "Fixed O&M Cost in 2010"
FC_15    "Fixed O&M Cost in 2015"
FC_20    "Fixed O&M Cost in 2020"
FC_25    "Fixed O&M Cost in 2025"
FC_30    "Fixed O&M Cost in 2030"
FC_50    "Fixed O&M Cost in 2050"


VC_00    "Variable Cost in 2000"
VC_05    "Variable Cost in 2005"
VC_10    "Variable Cost in 2010"
VC_15    "Variable Cost in 2015"
VC_20    "Variable Cost in 2020"
VC_25    "Variable Cost in 2025"
VC_30    "Variable Cost in 2030"
VC_50    "Variable Cost in 2050"

LFT      "Technical Lifetime"

USC_00   "Useful Energy Conversion Factor in 2000"
USC_05   "Useful Energy Conversion Factor in 2005"
USC_10   "Useful Energy Conversion Factor in 2010"
USC_15   "Useful Energy Conversion Factor in 2015"
USC_20   "Useful Energy Conversion Factor in 2020"
USC_25   "Useful Energy Conversion Factor in 2025"
USC_30   "Useful Energy Conversion Factor in 2030"
USC_50   "Useful Energy Conversion Factor in 2050"
/


PGECONCHAR       "Technical - economic characteristics for power generation plants"
/
IC_05
IC_20
IC_50
FC_05
FC_20
FC_50
VC_05
VC_20
VC_50
EFF_05
EFF_20
EFF_50
AVAIL_05
AVAIL_20
AVAIL_50
LFT
CR
/



SG               "S parameters in Gompertz function for passenger cars vehicle km"
/S1,S2,S3/

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

PGTECH          "Indicators about Power Generation Plants"
/
CAPP_95          "1995 Installed Capacity in GW"
CAPP_00          "2000 Installed Capacity in GW"
CAPP_05          "2005 Installed Capacity in GW"
CAPP_09          "2009 Installed Capacity in GW"
CAPP_10          "2010 Installed Capacity in GW"
CAPP_15          "2015 Installed Capacity in GW"
CAPP_17          "2017 Installed Capacity in GW"

CAPI_00          "2000 Installed AVAILABLE Capacity in GW"
LFT              "Technical Lifetime in years"
AVAIL_00         "Plant availability in 2000"
AVAIL_10         "Plant availability in 2010"
AVAIL_30         "Plant availability in 2030"
EFF_00           "Plant Efficiency in 2000"
EFF_10           "Plant Efficiency in 2010"
EFF_30           "Plant Efficiency in 2030"
PROD_95          "Electricity Production in 1995"
PROD_00          "Electricity Production in 2000"
PROD_09          "Electricity Production in 2005"
PROD_10          "Electricity Production in 2009"
PROD_05          "Electricity Production in 2010"
PROD_15          "Electricity Production in 2015"
PROD_17          "Electricity Production in 2017"

H                "Scale parameter for endogenous scrapping (applied to the sum of full costs)"
S                "Weight parameter for endogenous scrapping"
/

PGCAPAST(PGTECH)         /CAPP_00,CAPP_05,CAPP_09,CAPP_10,CAPP_15,CAPP_17/
PGPRODPAST(PGTECH)       /PROD_00,PROD_05,PROD_09, PROD_10,PROD_15, PROD_17/

PGCAP            "Capacity decommisioning and expansion decided schedule"
/
DEC_05           "GW decommisioned until 2005"
DEC_10           "GW decommisioned until 2010"
DEC_15           "GW decommisioned until 2015"
DEC_18           "GW decommisioned until 2018"
DEC_20           "GW decommisioned until 2020"
DEC_25           "GW decommisioned until 2025"
DEC_30           "GW decommisioned until 2030"
INV_05           "GW decided to be installed until 2005"
INV_10           "GW decided to be installed until 2010"
INV_15           "GW decided to be installed until 2015"
INV_18           "GW decided to be installed until 2018"
INV_19           "GW decided to be installed until 2019"
INV_20           "GW decided to be installed until 2020"
INV_25           "GW decided to be installed until 2025"
INV_30           "GW decided to be installed until 2030"
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

cgiset /Baseline, Scenario/

chpparset /CHPPAR, ELCINDEX/

Gompset1 /PC/
Gompset2 /s1,s2,s3,sat,mextv,scr /
Indu_SCon_Set /Base, SHR_NSE, SH_HPELC/


PG1_set / 2000,2005,2009,2010,DEC_05,DEC_10,DEC_15, DEC_18,DEC_20,DEC_25,DEC_30,INV_05,INV_10,INV_15,INV_18, INV_19, INV_20,INV_25,INV_30,INV_11,INV_12,INV_13,INV_14,PROD_00,PROD_05,PROD_09,PROD_10, 2015,2017, PROD_15, PROD_17/


CHPPGSET /IC,FC,VOM,LFT,AVAIL,BOILEFF,MAXCHPSHARE/

ELSH_SET /elsh/

PMR_SET/H,S/

falsi_iter Maximum iterations for requla-falsi /rf1*rf7/

TAXSET
/
MaxTax
Mid
Speed
/

NETWSET
/
MULT
Mid
Speed
/
;

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
          loop TEA do
              TECHS(DSBS) = TECHS(DSBS)+1;
          endloop
     endloop;
endloop;

alias(NAP2,NAP);

ALIAS (EFS2,EFS);
ALIAS (CHP2,CHP);
ALIAS (INDDOM2,INDDOM);
ALIAS (YYTIME2,ytime);


scalar ordfirst /0/;
ordfirst=sum((ytime,YYTIME2)$((ord(ytime)<=ord(YYTIME2)) $TFIRST(YYTIME2)),1);
sets
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

REPORT_LINES Aggregate Report lines
/
r_dem
r_pop
r_hou
r_hsize
r_blank1
r_econ
r_gdp
r_cons
r_va
r_va_i
r_va_s
r_va_a
r_blank2
r_prd
r_prd_s
r_prd_o
r_prd_g
r_prd_n
r_prd_r
r_prd_h
r_prd_b
r_prd_w
r_prd_e
r_blank3
r_imp
r_imp_s
r_imp_o
r_imp_g
r_imp_e
r_imp_h
r_blank4
r_gic
r_gic_s
r_gic_o
r_gic_g
r_gic_n
r_gic_e
r_gic_r
r_gic_h
r_blank5
r_fcon
r_fcon_f
r_fcon_c
r_fcon_o
r_fcon_g
r_fcon_h
r_fcon_b
r_fcon_w
r_fcon_e
r_fcon_m
r_fcon_sf
r_fcon_i
r_fcon_i_s
r_fcon_i_o
r_fcon_i_g
r_fcon_i_h
r_fcon_i_b
r_fcon_i_e
r_fcon_r
r_fcon_r_s
r_fcon_r_o
r_fcon_r_g
r_fcon_r_h
r_fcon_r_b
r_fcon_r_r
r_fcon_r_e
r_fcon_r_m
r_fcon_s
r_fcon_s_s
r_fcon_s_o
r_fcon_s_g
r_fcon_s_h
r_fcon_s_b
r_fcon_s_r
r_fcon_s_e
r_fcon_s_m
r_fcon_a
r_fcon_a_s
r_fcon_a_o
r_fcon_a_g
r_fcon_a_h
r_fcon_a_b
r_fcon_a_r
r_fcon_a_e
r_fcon_a_m
r_fcon_t
r_fcon_t_s
r_fcon_t_o
r_fcon_t_g
r_fcon_t_e
r_fcon_t_m
r_blank6
r_eprod
r_eprod_n
r_eprod_r
r_eprod_h
r_eprod_w
r_eprod_t_g_b
r_eprod_o
r_eprod_t
r_eprod_t_s
r_eprod_t_cl
r_eprod_t_sp
r_eprod_t_o
r_eprod_t_g
r_eprod_t_g_cc
r_eprod_t_g_h
r_blank7
r_cap
r_cap_n
r_cap_r
r_cap_h
r_cap_w
r_cap_t_g_b
*r_cap_o
r_cap_csp
r_cap_dpv
r_cap_t
r_cap_t_s
r_cap_t_cl
r_cap_t_sp
r_cap_t_o
r_cap_t_g
r_cap_t_g_cc
r_cap_t_g_h
r_blank8
r_pginp
r_pginp_s
r_pginp_o
r_pginp_g
r_pginp_b
r_pginp_h
r_blank9
TIMEREP
r_prind
r_prres
r_blank11
r_co2
r_co2_p
r_co2_e
r_co2_i
r_co2_r
r_co2_s
r_co2_t
r_co2_90
r_blank12
r_blank13
r_gic_gdp
r_gic_cap
r_elc_cap
r_co2_gic
r_co2_cap
r_co2_gdp
r_imp_dep
r_blank14
r_blank15
r_int_i
r_int_r
r_int_s
r_int_t
r_blank16
r_blank17
r_blank18
r_blank19
r_blank20
r_actv_p
r_actv_pb
r_actv_pc
r_actv_pt
r_actv_pa
r_actv_pn
r_actv_cap
r_actv_cars
r_actv_km
r_actv_f
r_actv_gu
r_actv_gt
r_actv_gi
r_actv_ga
r_ccs
r_h2inp
r_h2inp_s
r_h2inp_o
r_h2inp_g
r_h2inp_b
r_co2_h
/


;
Set stringcy(allCy)
Set smallpg(pgall) /AGTGDO,AGTNGS/
Alias (smallpg,smallpgg),(geme3tech,geme3tech1),(EF1,EF),(allCy2,allCy)
;
