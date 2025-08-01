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
PC   2    
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
parameter i01InitSpecFuelConsData(TRANSE,TTECH,EF)      "Initial Specific fuel consumption ()" /
PC.LPG.LPG	65.88
PC.GSL.GSL	73.2
PC.GDO.GDO	54.9
PC.NGS.NGS	84.3391
PC.MET.MET	71.84
PC.ETH.ETH	102.1
PC.BGDO.BGDO	54.9
PC.H2F.H2F	24.15
PC.ELC.ELC	20.496
PC.PHEVGSL.GSL	43.92
PC.PHEVGSL.ELC	20.496
PC.PHEVGDO.GDO	32.94
PC.PHEVGDO.ELC	20.496
PC.CHEVGSL.GSL	45.384
PC.CHEVGDO.GDO	40.8456
PT.GDO.GDO	18.6313
PT.MET.MET	12.6
PT.H2F.H2F	8.9
PT.ELC.ELC	2.73638
PA.H2F.H2F	21.7
GU.LPG.LPG	54.1073
GU.GSL.GSL	60.1192
GU.GDO.GDO	45.0894
GU.NGS.NGS	66
GU.MET.MET	56.2
GU.ETH.ETH	80
GU.BGDO.BGDO	45.0894
GU.H2F.H2F	13.5268
GU.ELC.ELC	27.0536
GU.PHEVGSL.GSL	34.4
GU.PHEVGSL.ELC	21.8
GU.PHEVGDO.GDO	27.0536
GU.PHEVGDO.ELC	21.8
GU.CHEVGDO.GDO	21.8
GT.GDO.GDO	33.629
GT.MET.MET	78
GT.H2F.H2F	92
GT.ELC.ELC	11.5245
GN.GSL.GSL	22.8
GN.GDO.GDO	15.2
GN.H2F.H2F	8.14286
/
;
*---

Parameters
i01PlugHybrFractOfMileage(ELSH_SET,YTIME)	           "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)"
i01SpeFuelConsCostBy(allCy,SBS,TTECH,EF)	           "Specific fuel consumption cost in Base year (ktoe/Gpkm or ktoe/Gtkm or ktoe/Gvkm)"
i01GdpPassCarsMarkExt(allCy)	                          "GDP-dependent passenger cars market extension (GDP/capita)"
i01PassCarsScrapRate(allCy)	                          "Passenger cars scrapping rate (1)"
i01ShareAnnMilePlugInHybrid(allCy,YTIME)	           "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
i01AvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	      "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)"
i01TechLft(allCy,SBS,EF,YTIME)	                     "Technical Lifetime. For passenger cars it is a variable (1)"
i01PassCarsMarkSat(allCy)	                          "Passenger cars ownership saturation threshold (1)"
i01PCGDPSatThresh(allCy)	                           "Passenger cars GDP per capita saturation threshold (US$2015)"
i01GDPperCapita(YTIME,allCy)
;
*---
i01SpeFuelConsCostBy(runCy,TRANSE,TTECH,EF) = i01InitSpecFuelConsData(TRANSE,TTECH,EF);
*---
i01PCGDPSatThresh(runCy) = 50000;
i01PassCarsMarkSat(runCy) = 0.7;
*---
imFuelConsTRANSE(runCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(imFuelConsTRANSE(runCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
*---
i01PlugHybrFractOfMileage(ELSH_SET,YTIME) = i01PlugHybrFractData(YTIME);
*---
i01ShareAnnMilePlugInHybrid(runCy,YTIME)$an(YTIME) = i01PlugHybrFractOfMileage("ELSH",YTIME);
*---
i01AvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = i01CapDataLoadFacEachTransp(TRANSE,TRANSUSE);
*---
**  Transport Sector
i01TechLft(runCy,TRANSE,EF,YTIME) = imDataTransTech(TRANSE,EF,"LFT",YTIME);
*---
**  Industrial Sector
i01TechLft(runCy,INDSE,EF,YTIME) = imDataIndTechnology(INDSE,EF,"LFT");
*---
**  Domestic Sector
i01TechLft(runCy,DOMSE,EF,YTIME) = imDataDomTech(DOMSE,EF,"LFT");
*---
**  Non Energy Sector and Bunkers
i01TechLft(runCy,NENSE,EF,YTIME) = imDataNonEneSec(NENSE,EF,"LFT");
*---
i01GDPperCapita(YTIME,runCy) = i01GDP(YTIME,runCy) / i01Pop(YTIME,runCy);