*' @title Transport Inputs
*' @code

*---
table iGDP(YTIME,allCy) "GDP (billion US$2015)"
$ondelim
$include "./iGDP.csvr"
$offdelim
;
*---
table iPop(YTIME,allCy) "Population (billion)"
$ondelim
$include "./iPop.csvr"
$offdelim
;
*---
table iCapDataLoadFacEachTransp(TRANSE,TRANSUSE)	 "Capacity data and Load factor for each transportation mode (passenger or tonnes/vehicle)"
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
table iDataPassCars(allCy,GompSet1,Gompset2)        "Initial Data for Passenger Cars ()"
          scr
CHA.PC    0.0201531648401507
IND.PC    0.0201531648401507
USA.PC    0.0418811968705786
;
*---
table iNewReg(allCy,YTIME) "new car registrations per year"
$ondelim
$include"./iNewReg.csv"
$offdelim
;
*---
table iInitSpecFuelCons(allCy,TRANSE,TTECH,EF,YTIME)                 "Initial Specific fuel consumption for all countries ()";
*---
** CHP economic and technical data initialisation for electricity production
table iDataChpPowGen(EF,YTIME,CHPPGSET)   "Data for power generation costs (various)"
               IC      FC      LFT VOM     AVAIL BOILEFF
STE1AL.2010    2.75    58.4621 35  5.19746 0.85  0.699301
STE1AL.2020    2.75    52.9702     5.01869       0.699301
STE1AL.2050    2.75    48.5081     3.3689        0.699301
STE1AH.2010    2.2814  50.609  35  4.4306  0.85  0.746269
STE1AH.2020    2.2814  43.5126     4.2842        0.746269
STE1AH.2050    2.2814  37.7468     4.08204       0.746269
STE1AD.2010    1.276   20.01   15  2.67042 0.29  0.813008
STE1AD.2020    1.276   20.01       2.67042       0.813008
STE1AD.2050    1.276   20.01       2.67042       0.813008
STE1AR.2010    1.782   27.945  30  3.72938 0.8   0.78125
STE1AR.2020    1.782   27.945      3.72938       0.78125
STE1AR.2050    1.782   27.945      3.72938       0.78125
STE1AG.2010    1.16358 19.35   25  2.56461 0.8   0.819672
STE1AG.2020    1.09263 19.35       2.44861       0.819672
STE1AG.2050    1.06425 19.35       2.23212       0.819672
STE1AB.2010    3.2208  57.096  30  6.29638 0.85  0.746269
STE1AB.2020    3.0866  54.717      6.05137       0.746269
STE1AB.2050    2.8853  51.1485     5.61708       0.746269
STE1AH2F.2010  1.16358 19.35   15  2.56461 0.8   0.829672
STE1AH2F.2020  1.09263 19.35       2.44861       0.829672
STE1AH2F.2050  1.06425 19.35       2.23212       0.829672
;
*---
parameter iPlugHybrFractData(YTIME)  "Plug in hybrid fraction of mileage" /
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
parameter iInitSpecFuelConsData(TRANSE,TTECH,EF)        "Initial Specific fuel consumption ()" /
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
iPlugHybrFractOfMileage(ELSH_SET,YTIME)	                   "Plug in hybrid fraction of mileage covered by electricity, residualls on GDP-Depnd car market ext (1)"
iSpeFuelConsCostBy(allCy,SBS,TTECH,EF)	                   "Specific fuel consumption cost in Base year (ktoe/Gpkm or ktoe/Gtkm or ktoe/Gvkm)"
iSigma(allCy,SG)                                           "S parameters of Gompertz function for passenger cars vehicle km (1)"
iGdpPassCarsMarkExt(allCy)	                             "GDP-dependent passenger cars market extension (GDP/capita)"
iPassCarsScrapRate(allCy)	                             "Passenger cars scrapping rate (1)"
iShareAnnMilePlugInHybrid(allCy,YTIME)	                   "Share of annual mileage of a plug-in hybrid which is covered by electricity (1)"
iAvgVehCapLoadFac(allCy,TRANSE,TRANSUSE,YTIME)	         "Average capacity/vehicle and load factor (tn/veh or passenegers/veh)"
iTechLft(allCy,SBS,EF,YTIME)	                             "Technical Lifetime. For passenger cars it is a variable (1)"
iPassCarsMarkSat(allCy)	                                  "Passenger cars market saturation (1)"
;
*---
iInitSpecFuelCons(runCy,TRANSE,TTECH,EF,YTIME) = iInitSpecFuelConsData(TRANSE,TTECH,EF) ; 
*---
iSpeFuelConsCostBy(runCy,TRANSE,TTECH,EF) = iInitSpecFuelCons(runCy,TRANSE,TTECH,EF,"2017");
*---
iDataPassCars(runCy,"PC","S1") = 1.0;
iDataPassCars(runCy,"PC","S2") = -0.01;
iDataPassCars(runCy,"PC","S3") = 6.5;
*---
iSigma(runCy,"S1") = iDataPassCars(runCy,"PC","S1");
iSigma(runCy,"S2") = iDataPassCars(runCy,"PC","S2");
iSigma(runCy,"S3") = iDataPassCars(runCy,"PC","S3");
*---
* Converting EUR2005 to US2015
iDataChpPowGen(EF,YTIME,"IC") = iDataChpPowGen(EF,YTIME,"IC") * 1.3;
iDataChpPowGen(EF,YTIME,"FC") = iDataChpPowGen(EF,YTIME,"FC") * 1.3;
iDataChpPowGen(EF,YTIME,"VOM") = iDataChpPowGen(EF,YTIME,"VOM") * 1.3;
iPassCarsMarkSat(runCy) = iDataPassCars(runCy,"PC","SAT");
*---
*iGdpPassCarsMarkExt(runCy) = iDataPassCars(runCy,"PC","MEXTV");
*---
*iPassCarsScrapRate(runCy)  = iDataPassCars(runCy,"PC", "SCR");
*---
iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)$(SECTTECH(TRANSE,EF) $(iFuelConsTRANSE(runCy,TRANSE,EF,YTIME)<=0)) = 1e-6;
*---
iPlugHybrFractOfMileage(ELSH_SET,YTIME) = iPlugHybrFractData(YTIME);
*---
iShareAnnMilePlugInHybrid(runCy,YTIME)$an(YTIME) = iPlugHybrFractOfMileage("ELSH",YTIME);
*---
iAvgVehCapLoadFac(runCy,TRANSE,TRANSUSE,YTIME) = iCapDataLoadFacEachTransp(TRANSE,TRANSUSE);
*---
**  Transport Sector
iTechLft(runCy,TRANSE,EF,YTIME) = iDataTransTech(TRANSE,EF,"LFT",YTIME);
*---
**  Industrial Sector
iTechLft(runCy,INDSE,EF,YTIME) = iDataIndTechnology(INDSE,EF,"LFT");
*---
**  Domestic Sector
iTechLft(runCy,DOMSE,EF,YTIME) = iDataDomTech(DOMSE,EF,"LFT");
*---
**  Non Energy Sector and Bunkers
iTechLft(runCy,NENSE,EF,YTIME) = iDataNonEneSec(NENSE,EF,"LFT");
*---