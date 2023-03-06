Set

H2TECH Hydrogen production technologies
/
gsr gas steam reforming
gss gas steam reforming with CCS
bpy biomass pyrolysis
sht solar thermochemical cycle
nht nuclear termochemical cycle
weg water electrolysis from grid power
wen water electrolysis with nuclear
wew water electrolysis with wind
cgf coal gasification
cgs coal gasification with CCS
opo oil partial oxydation
ops oil partial oxydation with CCS
smr solar methane reforming
bgfs biomass gasification small scale
bgfl biomass gasification large scale
bgfls biomass gasification large scale with CCS
/


INFRTECH Hydrogen storage and distribution technologies
/
tpipa turnpike pipeline used also as a storage medium
hpipi high pressure for industry
hpipu high pressure for urban
mpipu medium pressure for urban
lpipu low pressure for urban
mpips medium pressure for service stations of length of 2km
ssgg service stations gaseous H2
/

PIPES(INFRTECH)  Pipelines
/
tpipa turnpike pipeline used also as a storage medium
hpipi high pressure for industry
hpipu high pressure for urban
mpipu medium pressure for urban
lpipu low pressure for urban
mpips medium pressure for service stations
/

H2STATIONS(INFRTECH) Service stations for hydrogen powered cars
/
ssgg service stations gas
/


INFRTECHtoEF(INFRTECH,EF) type of energy consumed onsite for the operation of the infrastructure technology
/
hpipu.h2f
ssgg.elc
/


H2NETWORK(INFRTECH,INFRTECH)
/
TPIPA.(HPIPI,HPIPU)
HPIPU.MPIPU
MPIPU.(MPIPS,LPIPU)
MPIPS.SSGG
/

H2EFFLOOP(INFRTECH)
/
HPIPI,HPIPU,MPIPU,MPIPS,LPIPU,SSGG
/


H2SBS(SBS) final demand sectors consuming hydrogen for energy purposes
/

PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI,SE,AG,HOU,PC,GU,PA,PT,GT
/


H2INFRSBS(INFRTECH,SBS) infrustructure required by demand sector)
/
TPIPA.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI,SE,AG,HOU,PC,GU,PA,PT,GT)
LPIPU.(SE,AG,HOU)
(SSGG,MPIPS).(PC,GU,PA,PT,GT)
(MPIPU,HPIPU).(SE,AG,HOU,PC,GU,PA,PT,GT)
HPIPI.(PG,IS,NF,BM,CH,PP,EN,TX,FD,OE,OI)
/


H2INFRDNODES(INFRTECH)
/ HPIPI,LPIPU,SSGG/


H2TECHEFtoEF(H2TECH,EF) mapping between production technologies and fuels
/
(gsr,gss,smr).ngs
(cgf,cgs).hcl
(bpy,bgfs,bgfl,bgfls).BMSWAS
sht.SOL
(nht,wen).NUC
weg.ELC
wew.WND
(opo,ops).RFO
/

H2PRODEF(EF) fuels used for hydrogen production
/
ngs,hcl,bmswas,sol,nuc,elc,wnd,rfo
/


H2TECHREN(H2TECH) Renewable hydrogen production technologies
/
sht
wew
/


H2CCS(H2TECH) Hydrogen production technologies equipped with CCS facility
/
gss gas steam reforming with CCS
cgs coal gasification with CCS
ops oil partial oxydation with CCS
bgfls biomass gasification large scale with CCS
/

H2NOCCS(H2TECH) Hydrogen production technologies without CCS but with corresponding option with CCS
/
gsr
cgf
opo
bgfl
/


H2CCS_NOCCS(H2TECH,H2TECH) mapping between hydrogen technologies with and without CCS facility
/
gss.gsr
cgs.cgf
ops.opo
bgfls.bgfl
/


H2TECHPM(H2TECH) technologies for which premature replacement is active
/
gsr,cgf,opo
/

ARELAST set containing the names of the elasticities used in area covered by H2 logistic fucntion
/
B        parameter controlling the speed to the transition to hydrogen economy
mid     mid point after which the hydrogen economy is taking off
/

Sets
alllabels labels used to read the data from excel
/IC_00,IC_25,IC_50,FC_00,FC_25,FC_50,VC_00,VC_25,VC_50,EFF_00,EFF_25,EFF_50,
 SELF_00,SELF_25,SELF_50,AVAIL_00,AVAIL_25,AVAIL_50,LFT,H2KMTOE,mpips,lpipu,
 mpipu,AREA,MAXAREA,B,mid,CR
/

INFRTECHLAB(INFRTECH,alllabels)
/
mpips.mpips
lpipu.lpipu
mpipu.mpipu
/

ALIAS (H2TECH2,H2TECH);
ALIAS (INFRTECH3,INFRTECH2, INFRTECH);
