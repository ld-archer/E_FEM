/** \dir Makedata/HRS This directory holds all the code used in processing the RAND HRS and the HRS Fat Files into simulation inputs. */

/** \file common.do This file is called by all the other files to grab the necessary common parameters

\todo validation test: make sure oprobit dummies add to 100% exactly

*/
clear
clear mata
set more off
set mem 800m
set seed 5243212
set maxvar 15000

* Assume that this script is being executed in the FEM_Stata/Makedata/HRS directory

* Load environment variables from the root FEM directory, three levels up
* these define important paths, specific to the user
include "../../../fem_env.do"

#delimit;
* Record identifiers;
global identifiers 
hhid
hhidpn
wave
;

* Demographics that never change over time;
global demog 
hacohort
rbyr
rbmonth
weight
wthh
black
white
hispan
educ
educ_fam
hsless
college
male
fkids 
catholic
jewish
reloth
relnone
rel_notimp
rel_someimp
suburb
exurb
bornus
fdiabe50
fsmoken50
fcanc50
fheart50
fstrok50
fhibp50
flung50
flogbmi50
weightnh
raedyrs
rameduc
rafeduc
;

* Variables required for the initial conditions covariance matrix;
global vcmatrix 
single
shlt
smokev
anydb
anydc
db_tenure
logdcwlthx
dcwlth
dcwlthx
era
nra
rssclyr
rdb_na_c
rdb_ea_c
wtstate
;	

* Variables still present in their first-interview formulation;
global flist
smokev
rbyr
logiearnx
logiearnuc
anydb
;

* Variables that change over time;
global timevariant
widowed
married
died
iwstat
hearte
stroke
cancre
hibpe
diabe
lunge
memrye
anyhi
diclaim
ssiclaim
ssclaim
dbclaim 
nhmliv
wlth_nonzero
logbmi
smoken
work
loghatotax
logiearnx
logiearnuc
hatotax
iearnx
hatota
iearnuc
logdcwlthx
dcwlthx
smkstat
adlstat
iadlstat
age_iwe
age_yrs
age
hicap
hicap_nonzero
igxfr
igxfr_nonzero
htcamt
helphoursyr
helphoursyr_sp
helphoursyr_nonsp
gkcarehrs
volhours
kid_byravg
kid_mnage
nkid_liv10mi
parhelphours 
deprsymp
chfe
alzhe
hspnit
doctim
jyears
binge
satisfaction
proxy
hitot
hearta
heartae
time_lhearta
lipidrx
cenreg
rxchol
;

* Variables that are outcomes-only, meaning we don't care if they have lagged or missing values;
global outcomeonly
bpcontrol
insulin
lungoxy
diabkidney
painstat
;
#delimit cr
