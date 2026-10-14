*' @title Industry Inputs
*' @code

*---
table i02ElastNonSubElecData(DSBS,ETYPES,YTIME)             "Elasticities of Non Substitutable Electricity (1)"
$ondelim
$include "iElastNonSubElecData.csv"
$offdelim
;
*---
table i02ElaSub(allCy,DSBS)                                "Elasticities by subsector for all countries (1)" ;
*---
imTotFinEneDemSubBaseYr(runCy,TRANSE,YTIME)  = sum(EF$SECtoEF(TRANSE,EF),imFuelCons(runCy,TRANSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,INDSE,YTIME)   = SUM(EF$SECtoEF(INDSE,EF),imFuelCons(runCy,INDSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,DOMSE,YTIME)   = SUM(EF$SECtoEF(DOMSE,EF),imFuelCons(runCy,DOMSE,EF,YTIME));
imTotFinEneDemSubBaseYr(runCy,NENSE,YTIME)   = SUM(EF$SECtoEF(NENSE,EF),imFuelCons(runCy,NENSE,EF,YTIME));
*---
i02util(runCy,DSBS,ITECH,YTIME)$SECTTECH(DSBS,ITECH) = 1;
i02CapFactor(allCy,DSBS,ITECH,YTIME) = 1;
*---
$IFTHEN.calib %Calibration% == off
table i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)       "Scale parameter for endogenous scrapping applied to the sum of full costs (1)"
$ondelim
$include"./iScaleEndogScrap.csv"
$offdelim
;
*---
table i02CalibUsefulEnergy(allCy,DSBS,YTIME)      "Calibration parameter for useful energy (1)"
$ondelim
$include"./iCalibUsefulEnergy.csv"
$offdelim
;
*---
$ELSE.calib
variable i02ScaleEndogScrap(allCy,DSBS,ITECH,YTIME)        "Scale parameter for endogenous scrapping applied to the sum of full costs (1)";
variable i02CalibUsefulEnergy(allCy,DSBS,YTIME);

i02ScaleEndogScrap.LO(runCy,DSBS,ITECH,YTIME) = 0.01;                                      
i02ScaleEndogScrap.UP(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.L(runCy,DSBS,ITECH,YTIME) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(DATAY(YTIME) or not SECTTECH(DSBS,ITECH)) = 0;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(SECTTECH(DSBS,ITECH) and not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 1;
i02ScaleEndogScrap.FX(runCy,DSBS,ITECH,YTIME)$(sameas("AG",DSBS) and not EU28(runCy)) = 1;

i02CalibUsefulEnergy.LO(runCy,DSBS,YTIME) = -0.5;  
i02CalibUsefulEnergy.UP(runCy,DSBS,YTIME) = 1;  
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$DATAY(YTIME) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(not (INDDOM(DSBS) or sameas("NEN",DSBS) or sameas("PCH",DSBS))) = 0;
i02CalibUsefulEnergy.FX(runCy,DSBS,YTIME)$(sameas("AG",DSBS) and not EU28(runCy)) = 0;
i02CalibUsefulEnergy.FX(runCy,"IS",YTIME) = 0;  !!this is for the initial IS runs only
$ENDIF.calib
i02ElastNonSubElec(runCy,DSBS,ETYPES,YTIME) = i02ElastNonSubElecData(DSBS,ETYPES,YTIME);
*---
i02ElaSub(runCy,DSBS) = imElaSubData(DSBS);
i02ElaSub(runCy,DSBS) = 2;
*---
imCO2CaptRateIndustry(runCy,CCSTECH,YTIME) = 0.9;
*---
alias(ITECH,ITECH2);
i02numtechnologiesUsingEF(DSBS,EF)=sum(ITECH2$(ITECHtoEF(ITECH2,EF)$SECTTECH(DSBS,ITECH2)),1);
*---
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$(DATAY(YTIME) and SECTTECH(DSBS,ITECH) and ITECHtoEF(ITECH,EF)) =
  (
    imFuelCons(runCy,DSBS,EF,YTIME) /
    SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME))
  )$SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME)) +
  1$(not SUM(EFS2$ITECHtoEF(ITECH,EFS2), imFuelCons(runCy,DSBS,EFS2,YTIME)) and not BIOFUELS(EF));
  
i02ShareBlend(runCy,DSBS,ITECH,EF,YTIME)$AN(YTIME) = i02ShareBlend(runCy,DSBS,ITECH,EF,"%fBaseY%");
i02ShareElcHP(runCy,"HOU",YTIME) = 0.1;
i02ShareElcHP(runCy,"SE",YTIME) = 0.1;


# i02ShareFeed(runCy,DSBS,ITECH,EF,YTIME) = 0;
# imCo2EmiFacFeed(runCy,DSBS,EF,YTIME) = imCo2EmiFac(runCy,DSBS,EF,YTIME);
*i02CapFactor(allCy,"IS",ITECH,YTIME) = 0.77; !!https://www2.gerdau.com/market-update/global-crude-steel-production-and-capacity-utilization-11
i02SpecificEnergyIntensity(runCy,DSBS,ITECH,YTIME)$(not sameas(DSBS,"IS")) = 1;
*i02SpecificEnergyIntensity(allCy,"IS",ITECH,YTIME) = 0.5;
i02FuelShare(runCy,DSBS,ITECH,EF,YTIME)$(not sameas(DSBS,"IS")) = 1;
*---
table i02FuelConsICT(allCy,ICTSCEN,SSPSCEN,YTIME)             "Electrity demand of Data centers and infrastructure (Mtoe)"
$ondelim
$include "./iFuelConsICT.csv"
$offdelim
;
*---
$IFTHEN.calib %Calibration% == MatCalibration
table t02SharesFuelBuildings(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesFuelBuildings.csv"
$offdelim;

table t02SharesFuelINDSE(allCy,DSBS,EFS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tSharesINDSE.csv"
$offdelim;

table t02FinalEnergyDOMSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsFuelBuildings.csv"
$offdelim;

table t02FinalEnergyINDSE(allCy,DSBS,YTIME)    "Targets for share of new passenger cars"
$ondelim
$include "../targets/tProjectionsINDSE.csv"
$offdelim;
$ENDIF.calib

* IRON and STEEL DATA (move to mrPROM) (Check units of the data)
table imDataISTechnology(INDSE,TECH,ECONCHAR)          "Technoeconomic characteristics of industry (various)"
              IC      FC      VC      LFT    USC 
IS.BFBOF      0.536   123.3   0       25     1
IS.BFBOFCCS   0.686   157.8   0       25     1
IS.DREAF      0.527   131.8   0       25     1
IS.DREAFCCS   0.677   155.7   0       25     1 
IS.H2DREAF    0.844   135.0   0       25     1
IS.SCREAF     0.247   50      0       25     1 

imCapCostTech(runCy,"IS",TECH,YTIME) = imDataISTechnology("IS",TECH,"IC");
imFixOMCostTech(runCy,"IS",TECH,YTIME) = imDataISTechnology("IS",TECH,"FC");
imVarCostTech(runCy,"IS",TECH,YTIME) = imDataISTechnology("IS",TECH,"VC");
imUsfEneConvSubTech(runCy,"IS",TECH,YTIME) = imDataISTechnology("IS",TECH,"USC");

i02SpecificEnergyIntensity("CHA","IS","BFBOF",YTIME) = 0.621;
i02SpecificEnergyIntensity("CHA","IS","BFBOFCCS",YTIME) = 0.627;
i02SpecificEnergyIntensity("CHA","IS","DREAF",YTIME) = 0.43;
i02SpecificEnergyIntensity("CHA","IS","DREAFCCS",YTIME) = 0.436;
i02SpecificEnergyIntensity("CHA","IS","H2EAF",YTIME) = 0.392;
i02SpecificEnergyIntensity("CHA","IS","SCREAF",YTIME) = 0.096;

i02SpecificEnergyIntensity("DEU","IS","BFBOF",YTIME) = 0.497;
i02SpecificEnergyIntensity("DEU","IS","BFBOFCCS",YTIME) = 0.502;
i02SpecificEnergyIntensity("DEU","IS","DREAF",YTIME) = 0.478;
i02SpecificEnergyIntensity("DEU","IS","DREAFCCS",YTIME) = 0.485;
i02SpecificEnergyIntensity("DEU","IS","H2EAF",YTIME) = 0.435;
i02SpecificEnergyIntensity("DEU","IS","SCREAF",YTIME) = 0.072;

*shares iron and steel doubts on the definitions, in principle I would read these share directly from the data source
i02FuelShare("CHA","IS","BFBOF","HCL",YTIME)= 0.9;
i02FuelShare("CHA","IS","BFBOF","NGS",YTIME) = 0.01;
i02FuelShare("CHA","IS","BFBOF","ELC",YTIME) = 0.09;

i02FuelShare("CHA","IS","BFBOFCCS","HCL",YTIME) = 0.89;
i02FuelShare("CHA","IS","BFBOFCCS","NGS",YTIME) = 0.01;
i02FuelShare("CHA","IS","BFBOFCCS","ELC",YTIME)= 0.1;

i02FuelShare("CHA","IS","DREAF","NGS",YTIME) = 0.6;
i02FuelShare("CHA","IS","DREAF","ELC",YTIME) = 0.37;
i02FuelShare("CHA","IS","DREAF","HCL",YTIME) = 0.03;

i02FuelShare("CHA","IS","DREAFCCS","NGS",YTIME)= 0.59;
i02FuelShare("CHA","IS","DREAFCCS","ELC",YTIME) = 0.38;
i02FuelShare("CHA","IS","DREAFCCS","HCL",YTIME)= 0.1;

i02FuelShare("CHA","IS","H2DREAF","H2F",YTIME) = 0.69;
i02FuelShare("CHA","IS","H2DREAF","ELC",YTIME) = 0.15;
i02FuelShare("CHA","IS","H2DREAF","BMSWAS",YTIME) = 0.16;

i02FuelShare("CHA","IS","SCREAF","HCL",YTIME) = 0.1;
i02FuelShare("CHA","IS","SCREAF","ELC",YTIME) = 0.8;
i02FuelShare("CHA","IS","SCREAF","NGS",YTIME)= 0.1;

# Germany data
i02FuelShare("DEU","IS","BFBOF","HCL",YTIME)= 0.8;
i02FuelShare("DEU","IS","BFBOF","NGS",YTIME) = 0.1;
i02FuelShare("DEU","IS","BFBOF","ELC",YTIME) = 0.1;

i02FuelShare("DEU","IS","BFBOFCCS","HCL",YTIME) = 0.79;
i02FuelShare("DEU","IS","BFBOFCCS","NGS",YTIME) = 0.1;
i02FuelShare("DEU","IS","BFBOFCCS","ELC",YTIME)= 0.11;

i02FuelShare("DEU","IS","DREAF","NGS",YTIME) = 0.532;
i02FuelShare("DEU","IS","DREAF","ELC",YTIME) = 0.364;
i02FuelShare("DEU","IS","DREAF","HCL",YTIME) = 0.104;

i02FuelShare("DEU","IS","DREAFCCS","NGS",YTIME)= 0.522;
i02FuelShare("DEU","IS","DREAFCCS","ELC",YTIME) = 0.374;
i02FuelShare("DEU","IS","DREAFCCS","HCL",YTIME)= 0.104;

i02FuelShare("DEU","IS","H2DREAF","H2F",YTIME) = 0.69;
i02FuelShare("DEU","IS","H2DREAF","ELC",YTIME) = 0.15;
i02FuelShare("DEU","IS","H2DREAF","BMSWAS",YTIME) = 0.16;

i02FuelShare("DEU","IS","SCREAF","HCL",YTIME) = 0.064;
i02FuelShare("DEU","IS","SCREAF","ELC",YTIME) = 0.7;
i02FuelShare("DEU","IS","SCREAF","NGS",YTIME)= 0.236;