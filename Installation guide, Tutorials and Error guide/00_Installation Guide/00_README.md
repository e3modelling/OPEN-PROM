Welcome to the OPEN-PROM tutorial!

The contents of the tutorial are listed on the left (in "Tutorials" folder).

Necessary software: GAMS (required); R (required), Git (optional), GAMS Studio/VS Code (optional)

Model users: Install GAMS and R (if you haven't done so already), add them to your PATH variable. Please be sure that the library reticulate is installed in R. Note that to run the model you need input data, which are not distributed with the model code. If you don't have the data please get in touch with us: info@e3modelling.com

Model developers: Install GAMS and R (if you haven't done so already), add them to your PATH variable, and then proceed with Tutorial 00

Regionalization of OPEN-PROM
Here is the proposed classification of world countries to OPEN-PROM native regions:

(Custom native region codes are highlighted - for the rest of the countries their official 3-digit ISO Code will be used).
Machine-readable mapping is found [here](https://github.com/e3modelling/mrprom/blob/main/inst/extdata/regional/regionmappingOP5.csv)

1.	Austria
2.	Belgium
3.	Bulgaria
4.	Cyprus
5.	Croatia
6.	Czech Republic
7.	Germany
8.	Denmark
9.	Spain
10.	Finland
11.	France
12.	United Kingdom
13.	Greece
14.	Hungary
15.	Ireland
16.	Italy
17.	Malta
18.	Netherlands
19.	Poland
20.	Portugal
21.	Slovakia
22.	Slovenia
23.	Sweden
24.	Romania
25.	USA
26.	Japan
27.	Canada
28.	Brazil
29.	China /CHINA, MACAO, HONG KONG, TAIWAN/ `**CHA**`
30.	India
31.	South Korea
32.	Indonesia
33.	Mexico
34.	Argentina
35.	Turkey
36.	Saudi Arabia
37.	Oceania `**OCE**`
38.	Russian federation
39.	Iran
40.	Nigeria
41.	Rest of energy producing countries /ALGERIA, AZERBAIJAN, IRAQ, JORDAN, KUWAIT, LEBANON, LIBYAN ARAB JAMAHIRIYA, QATAR, SYRIAN ARAB REPUBLIC, UNITED ARAB EMIRATES, VENEZUELA, WESTERN SAHARA, YEMEN/ `**REP**`                       
42.	South Africa
43.	Rest of Europe 1 /NORWAY, SWITZERLAND, ICELAND, LIECHTENSTEIN/ `**NSI**`
44.	Rest of Europe 2 /ALBANIA, ANDORRA, GREENLAND, VATICAN, SAN MARINO, SVALBARD AND JAN MAYEN, BELARUS, BOSNIA AND HERZEGOVINA, NORTH MACEDONIA, MOLDOVA, REPUBLIC OF MONACO, MONTENEGRO, SERBIA, UKRAINE/ `**REU**`        
45.	Egypt
46.	Morocco
47.	Tunisia
48.	Israel
49.	Rest of Latin America `**RLA**`
50.	Rest of Africa `**RAF**`
51.	Rest of Asia `**RAS**`
52.	Rest of world `**RWO**`
53.	Rest of EU27 /ESTONIA, LUXEMBOURG, LITHUANIA, LATVIA/ `**ELL**`

A quick overview of the Tutorials contents:

 - ***01_Git and VS Code Settings:***

    A step by step guide to set up Git & VS Code (useful tools for developing and running the the model), as well as adding all the nessessary extensions to VS code.

- ***02_Task Runner settings in VS code:***

    Dedicated guide for installing the task runner extension in VS code. The Task Runner is g a custom button, whose function is to run the GAMS code of OPEN-PROM in different modalities that are described in this guide (it corresponds to the Run (F9) button in GAMS studio).
 - ***03_Loading Input Data Files with MrPROM:***

    A brief guide about loading real input data files to the OPEN-PROM model using the dedicated tool mrprom developed in R (Mr PROM).

- ***04_First OPEN‐PROM running:***

    This guide described how to execute OPEN-PROM for the first time with dummy data as inputs to the model generated by a dedicated script.

- ***05_Running OPEN‐PROM with real input data:***

    Brief description on how to execute OPEN-PROM, as well as the order of script execution.
    

- ***06_Setting OPEN-PROM regionalization:***

    Explanatory document about the countries and regions mapping used in the model and guide for change the regionalization (Work in progress)

- ***07_GAMS error codes:***

    Contains examples or GAMS errors, as well as a URL redirecting you to the official GAMS error codes documentation.

- ***08_Troubleshooting Guide Setting Up Git and Visual Studio Code for GitHub:***
    Simple steps to troubleshoot and resolve common problems during the setup process of Git and Visual Studio Code for GitHub.

- ***09_Creating FIXME Issues from Code Comments:***

    A brief guide about automatically creating new Github issues, by adding a specifically formatted type of comment in your code.

- ***10_Set up Github Actions for GAMS code using GAMS Engine:***

    Basic steps to properly set up Github Actions running GAMS code.





OPEN-PROM ("open PROMETHEUS") is an energy-economy model currently under development; the present version is based on MENA-EDS ENERGY MODEL v4.0 (c) E3Modelling 2020.

Extensive documentation of the PROMETHEUS model (on which both MENA-EDS and OPEN-PROM are based) can be found here: https://e3modelling.com/modelling-tools/prometheus/

OPEN-PROM is written in GAMS (*G*eneral *A*lgebraic *M*odelling *S*ystem https://gams.com/) and its main file is `main.gms`.
