* "dollar" ($) commands section: define GAMS code control and compilation-time options

* turn on end-of-line comments (starting with !!, i.e. the GAMS default)
$onEolCom
* turn on alternative flow control syntax (more readable loop, for, if etc.)
$onEnd

* TODO: check if the contents of this block are actually used later
$setGlobal countries 'ALG MOR TUN EGY ISR JOR LEB'

$setGlobal singleCountryRun 'yes'

$setGlobal countryList %countries%

$setGlobal scenario 'DECARB_400'
$setGlobal baseline 'BASE'

$setGlobal periodOfYears '1'

$setGlobal includeNonCO2 no

$setGlobal readCommonDB 'yes'
$setGlobal readCountryDB 'yes'
$setGlobal readCountryCalib 'yes'

$setGlobal horizon '2010*2050'

* end of dollar commands section, from here on no new $commands are allowed (only $(bat)include & $on/offtext) 

file name / '' /; !! construct for printing diagnostic output into log file
put name;

$include sets.gms
*$include h2model_sets.gms

*$include params.gms

