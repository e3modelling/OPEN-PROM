*' @title Hydrogen sets
*' @code

sets
*---
H2TECH "Hydrogen production technologies"
/
gsr         "gas steam reforming"
gss         "gas steam reforming with CCS"
*bpy        "biomass pyrolysis"
*sht        "solar thermochemical cycle"
*nht        "nuclear termochemical cycle"
weg         "water electrolysis from grid power"
*wen        "water electrolysis with nuclear"
wew         "water electrolysis with wind"
wes         "water electrolysis with solar"
cgf         "coal gasification"
cgs         "coal gasification with CCS"
*opo        "oil partial oxydation"
*ops        "oil partial oxydation with CCS"
*smr        "solar methane reforming"
*bgfs       "biomass gasification small scale"
bgfl        "biomass gasification large scale"
bgfls       "biomass gasification large scale with CCS"
amm_hb      "Ammonia synthesis via Haber-Bosch"
amm_hb_ccs  "Ammonia synthesis via Haber-Bosch with CCS"
amm_elec    "Electrochemical ammonia synthesis"
amm_crk     "Ammonia cracking"
*amm_comb   "Ammonia combustion"
*amm_fc     "Ammonia fuel cell"
/
*---
INFRTECH                  "Hydrogen storage and distribution technologies"
/
tpipa "turnpike pipeline used also as a storage medium"
hpipi "high pressure for industry"
hpipu "high pressure for urban"
mpipu "medium pressure for urban"
lpipu "low pressure for urban"
mpips "medium pressure for service stations of length of 2km"
ssgg  "service stations gaseous H2"
/
*---
PIPES(INFRTECH)            "Pipelines"
/
tpipa "turnpike pipeline used also as a storage medium"
hpipi "high pressure for industry"
hpipu "high pressure for urban"
mpipu "medium pressure for urban"
lpipu "low pressure for urban"
mpips "medium pressure for service stations"
/
*---
H2STATIONS(INFRTECH)       "Service stations for hydrogen powered cars"
/
ssgg "service stations gas"
/
*---
INFRTECHtoEF(INFRTECH,EF)  "Type of energy consumed onsite for the operation of the infrastructure technology"
/
hpipu.h2f
ssgg.elc
/
*---
H2NETWORK(INFRTECH,INFRTECH)
/
TPIPA.(HPIPI,HPIPU)
HPIPU.MPIPU
MPIPU.(MPIPS,LPIPU)
MPIPS.SSGG
/
*---
H2EFFLOOP(INFRTECH)
/
HPIPI
HPIPU
MPIPU
MPIPS
LPIPU
SSGG
/
*---
H2INFRSBS(INFRTECH,SBS)  "Infrustructure required by demand sector"
/
TPIPA.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI,SE,AG,HOU,PC,GU,PA,PT,GT)
LPIPU.(SE,AG,HOU)
(SSGG,MPIPS).(PC,GU,PA,PT,GT)
(MPIPU,HPIPU).(SE,AG,HOU,PC,GU,PA,PT,GT)
HPIPI.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI)
/
*---
H2INFRDNODES(INFRTECH)
/
HPIPI
LPIPU
SSGG
/
*---
H2TECHEFtoEF(H2TECH,EF)   "Mapping between production technologies and fuels"
/
(gsr,gss).ngs       !!,smr
(cgf,cgs).hcl
(bgfls,bgfl).BMSWAS !!,bpy,bgfs,
weg.ELC
wes.ELC
wew.ELC
amm_hb.h2f
amm_bb_ccs.h2f
amm_elec.ELC
amm_crk.amm
amm_crk.h2f
*amm_comb.amm
*amm_fc.amm
*sht.SOL
*(nht,wen).NUC
*(opo,ops).RFO
/
*---
$ontext
H2TECHtoPGALL(H2TECH,PGALL)  "Mapping between hydrogen production technologies and power generation technologies used for water electrolysis"
/
wes.PGSOL
wew.PGAWNO
/
$offtext
*---
H2PRODEF(EF)               "Fuels used for hydrogen production"
/
ngs
hcl
bmswas
sol
nuc
elc
wnd
rfo
h2f
amm
/
*---

H2TECHREN(H2TECH)          "Renewable hydrogen production technologies"
/
wew
wes
amm_elec
*sht
/

*---
H2CCS(H2TECH)              "Hydrogen production technologies equipped with CCS facility"
/
gss         "gas steam reforming with CCS"
cgs         "coal gasification with CCS"
bgfls       "biomass gasification large scale with CCS"
amm_hb_ccs  "Ammonia synthesis via Haber-Bosch with CCS"
*ops        "oil partial oxydation with CCS"
/
*---
H2NOCCS(H2TECH)            "Hydrogen production technologies without CCS but with corresponding option with CCS"
/
gsr
cgf
bgfl
amm_hb
*opo
/
*---
H2CCS_NOCCS(H2TECH,H2TECH) "Mapping between hydrogen technologies with and without CCS facility"
/
gss.gsr
cgs.cgf
bgfls.bgfl
amm_hb_ccs.amm_hb
*ops.opo
/
*---
H2TECHPM(H2TECH)           "Technologies for which premature replacement is active"
/
gsr
cgf
bgfl
weg
amm_hb
amm_elec
amm_crk
*opo
/
*---
ARELAST                    "Set containing the names of the elasticities used in area covered by H2 logistic fucntion"
/
B        "parameter controlling the speed to the transition to hydrogen economy"
mid      "mid point after which the hydrogen economy is taking off"
/
*---
ECONCHARHY                 "Technical - Economic characteristics for demand technologies Hydrogen"
/
IC
FC
VC
EFF
SELF
AVAIL
LFT
H2KMTOE
mpips
lpipu
mpipu
AREA
MAXAREA
B
mid
CR
/
*---
INFRTECHLAB(INFRTECH,ECONCHARHY)
/
mpips.mpips
lpipu.lpipu
mpipu.mpipu
/
*---
ALIAS (H2TECH2,H2TECH);
ALIAS (INFRTECH3,INFRTECH2, INFRTECH);
*---