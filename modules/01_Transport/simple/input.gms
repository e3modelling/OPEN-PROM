*' @title Transport Inputs
*' @code

*---
table i01GDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
*---
table i01Pop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
*---
table i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
     Cap  LF
PC   4    0.5
PB  40   0.4
PT   300  0.4
PN  300  0.5
PA   180  0.65
GU   5    0.7
GT   600  0.8
GN   1500 0.9 
;
*---
table i01NewReg(allCy,YTIME)                            "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;
*---
table i01StockPC(allCy,TTECH,YTIME)                     "Car stock per technology (million vehicles)"
$ondelim
$include"./iStockPC.csv"
$offdelim
;
*---
table i01DataShareBlend(allCy,TRANSE,EF,YTIME)                     "Blend share of fuel per transport mode (1)"
$ondelim
$include"./iDataShareBlend.csv"
$offdelim
;
*---
parameter i01PlugHybrFractData(YTIME)                   "Plug in hybrid fraction of mileage" /
2010    0.5
2011    0.504444
2012    0.508889
2013    0.513333
2014    0.517778
2015    0.522222
2016    0.526667
2017    0.531111
2018    0.535556
2019    0.54
2020    0.544444
2021    0.548889
2022    0.553333
2023    0.557778
2024    0.562222
2025    0.566667
2026    0.571111
2027    0.575556
2028    0.58
2029    0.584444
2030    0.588889
2031    0.593333
2032    0.597778
2033    0.602222
2034    0.606667
2035    0.611111
2036    0.615556
2037    0.62
2038    0.624444
2039    0.628889
2040    0.633333
2041    0.637778
2042    0.642222
2043    0.646667
2044    0.651111
2045    0.655556
2046    0.66
2047    0.664444
2048    0.668889
2049    0.673333
2050    0.677778
2051    0.682222
2052    0.686667
2053    0.691111
2054    0.695556
2055    0.7
2056    0.688889
2057    0.690741
2058    0.69216
2059    0.693076
2060    0.693404
2061    0.693045
2062    0.691886
2063    0.692385
2064    0.692659
2065    0.692743
2066    0.692687
2067    0.692567
2068    0.692488
2069    0.692588
2070    0.692622
2071    0.692616
2072    0.692595
2073    0.692579
2074    0.692581
2075    0.692597
2076    0.692598
2077    0.692594
2078    0.692591
2079    0.69259
2080    0.692592
2081    0.692594
2082    0.692593
2083    0.692592
2084    0.692592
2085    0.692592
2086    0.692593
2087    0.692593
2088    0.692593
2089    0.692593
2090    0.692593
2091    0.692593
2092    0.692593
2093    0.692593
2094    0.692593
2095    0.692593
2096    0.692593
2097    0.692593
2098    0.692593
2099    0.692593
2100    0.692593
/
;
*---
table i01SFCPC(allCy,TTECH,EF,YTIME)                     "Initial Specific fuel consumption (toe/vkm)"
$ondelim
$include"./iSFC.csv"
$offdelim
;
i01SFCPC(allCy,TTECH,"BGSL",YTIME) = i01SFCPC(allCy,TTECH,"GSL",YTIME);
i01SFCPC(allCy,TTECH,"BGDO",YTIME) = i01SFCPC(allCy,TTECH,"GDO",YTIME);
i01SFCPC(allCy,TTECH,"OGS",YTIME) = i01SFCPC(allCy,TTECH,"NGS",YTIME);
i01SFCPC(allCy,TTECH,EF,YTIME)$AN(YTIME) = i01SFCPC(allCy,TTECH,EF,"%fBaseY%");
*---
parameter i01InitSpecFuelConsData(TRANSE,TTECH,EF)      "Initial Specific fuel consumption: (ktoe/Gvkm)" /
PT.TGDO.GDO	11.
PT.TGDO.BGDO	11.
*PT.TMET.MET	12.6
PT.TH2F.H2F	8.9
PT.TELC.ELC	7
*PA.H2F.H2F	21.7
PA.TKRS.KRS	20
PN.TGDO.GDO  30
PN.TGDO.BGDO  30
PN.TH2F.H2F  43
PB.TGSL.GSL  8
PB.TGSL.BGSL  8
PB.TGDO.GDO  7.8
PB.TGDO.BGDO  7.8
PB.TNGS.NGS  5.6
PB.TNGS.OGS  5.6
PB.TLPG.LPG  6.6
PB.TELC.ELC  2.5
PB.TH2F.H2F  4.3
GU.TGSL.GSL	6.0
GU.TGSL.BGSL	6.0
GU.TLPG.LPG	5.0
GU.TGDO.GDO	4.0
GU.TGDO.BGDO	4.0
GU.TNGS.NGS	2.8
GU.TNGS.OGS	2.8
GU.TH2F.H2F	1.3
GU.TELC.ELC	1.0
GU.TCHEVGDO.GDO	2.7
GT.TGDO.GDO	1.9
GT.TGDO.BGDO	1.9
GT.TH2F.H2F	1.5
GT.TELC.ELC	1.9
GN.TGSL.GSL	2.0
GN.TGSL.BGSL	2.0
GN.TGDO.GDO	2.5
GN.TGDO.BGDO	2.5
GN.TH2F.H2F	1.5
/
;
*---
i01PassCarsMarkSat(runCy) = 0.7;
*---
i01ShareAnnMilePlugInHybrid(runCy,YTIME) = i01PlugHybrFractData(YTIME);
*---
i01AvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE);
*---
**  Transport Sector
i01TechLft(runCy,TRANSE,TTECH,YTIME) = imDataTransTech(TRANSE,TTECH,"LFT",YTIME);
i01TechLft(runCy,TRANSE,TTECH,YTIME) = 20;
*---
**  Industrial Sector
i01TechLft(runCy,INDSE,ITECH,YTIME) = imDataIndTechnology(INDSE,ITECH,"LFT");
*---
**  Domestic Sector
i01TechLft(runCy,DOMSE,ITECH,YTIME) = imDataDomTech(DOMSE,ITECH,"LFT");
*---
**  Non Energy Sector and Bunkers
i01TechLft(runCy,NENSE,ITECH,YTIME) = imDataNonEneSec(NENSE,ITECH,"LFT");
i01TechLft(runCy,"BU","TH2F",YTIME) = 25;
*---
**  DAC Sector
i01TechLft(runCy,"DAC",DACTECH,YTIME) = 25;
*---
i01GDPperCapita(YTIME,runCy) = i01GDP(YTIME,runCy) / i01Pop(YTIME,runCy);
*---or not sameas("BGSL", EF) or not sameas("BGDO", EF) "%fBaseY%"
i01ShareBlend(runCy,TRANSE,EF,YTIME)$DATAY(YTIME) =
SUM(EF2$BLENDMAP(EF2,EF),
  (
    imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME) / 
    sum(EFS$BLENDMAP(EF2,EFS),
      imFuelConsPerFueSub(runCy,TRANSE,EFS,YTIME)
    )
  )$(sum(EFS$BLENDMAP(EF2,EFS),imFuelConsPerFueSub(runCy,TRANSE,EFS,YTIME)) > 0)
);
i01ShareBlend(runCy,TRANSE,EFS,YTIME)$(SECtoEF(TRANSE,EFS) and not SUM(EF2,BLENDMAP(EF2,EFS))) = 1;
i01ShareBlend(runCy,TRANSE,EF,YTIME)$AN(YTIME) = i01ShareBlend(runCy,TRANSE,EF,"%fBaseY%");
i01ShareBlend("LAM",ROAD,"BGDO",YTIME) = i01ShareBlend("LAM",ROAD,"BGDO","%fBaseY%") + 0.002 * (ord(YTIME)-11);
i01ShareBlend("LAM",ROAD,"GDO",YTIME) = i01ShareBlend("LAM",ROAD,"GDO","%fBaseY%") - 0.002 * (ord(YTIME)-11);
i01ShareBlend("LAM",ROAD,"BGSL",YTIME) = i01ShareBlend("LAM",ROAD,"BGSL","%fBaseY%") + 0.001 * (ord(YTIME)-11);
i01ShareBlend("LAM",ROAD,"GSL",YTIME) = i01ShareBlend("LAM",ROAD,"GSL","%fBaseY%") - 0.001 * (ord(YTIME)-11);
*---
$IFTHEN.calib %Calibration% == MatCalibration
table t01NewShareStockPC(allCy,TRANSE,TTECH,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tNewShareStockPC.csv"
$offdelim
;
*imMatrFactor.FX(runCy,"PC",TTECH,YTIME)$((t01StockPC(runCy,TTECH,YTIME) < 0) and (t01NewShareStockPC(runCy,TTECH,YTIME) <= 0)) = 100;         
$ENDIF.calib
*---
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF), imFuelConsPerFueSub(runCy,TRANSE,EF,YTIME));