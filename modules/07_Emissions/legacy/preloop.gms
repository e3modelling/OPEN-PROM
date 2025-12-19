*' @title Emissions Constraints Preloop
*' @code

* This turns the text label "20" into the number 20.
Parameter p07MacCost(E07MAC) /
    0 0,     20 20,   40 40,   60 60,   80 80
    100 100, 120 120, 140 140, 160 160, 180 180
    200 200, 220 220, 240 240, 260 260, 280 280
    300 300, 320 320, 340 340, 360 360, 380 380
    400 400, 420 420, 460 460, 480 480, 500 500
    520 520, 540 540, 560 560, 580 580, 600 600
    660 660, 680 680, 720 720, 740 740, 760 760
    780 780, 820 820, 840 840, 1000 1000
    1080 1080, 1100 1100, 1120 1120, 1520 1520
    1660 1660, 1700 1700, 1740 1740, 2580 2580
    2600 2600, 3440 3440, 3460 3460, 3500 3500
    3540 3540, 3600 3600, 3840 3840, 4000 4000
/;

* Calculate difference between current step and previous step (E07MAC-1)
* The condition $(ord(E07MAC)>1) ensures we don't crash on the first element.
p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME) = 
    i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC, YTIME) 
  - i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC-1, YTIME);

* Fix the first step (Cost 0): It has no predecessor, so marginal = total
p07MarginalRed(allCy, E07SrcMacAbate, E07MAC, YTIME)$(ord(E07MAC)=1) = 
    i07DataCh4N2OFMAC(allCy, E07SrcMacAbate, E07MAC, YTIME);

* Default: Initialize everything to handle the Mass Conversion (tCO2 -> tC)
p07UnitConvFactor(E07SrcMacAbate) = smCtoCO2;

* GROUP 1: CH4 and N2O (Target: 2010$) - Manually select the first 14 items that are CH4/N2O
* We apply the 2015->2010 deflator to these sources.
p07UnitConvFactor(E07SrcMacAbate)$(
    ord(E07SrcMacAbate) <= 14  
) = smCtoCO2 * smDefl_15_to_10; 

* GROUP 2: F-Gases (Target: 2005$)
* We apply the 2015->2005 deflator to the rest (HFCs, PFCs, SF6).
p07UnitConvFactor(E07SrcMacAbate)$(
    ord(E07SrcMacAbate) > 14
) = smCtoCO2 * smDefl_15_to_05;