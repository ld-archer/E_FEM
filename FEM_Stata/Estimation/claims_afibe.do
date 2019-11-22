/** \file

This file is for estimating transitions using variables derived from the Medicare-linked claims data.

DO NOT LINK WITH SSA or other restricted files.

inputs: hrs19_clms_trans, hrs19_transition
outputs: estimation models

Original Author: Jeffrey Sullivan, April 2013

$Id: claims_afibe.do 29 2013-12-23 16:17:01Z jeffreys $

*/

#delimit;
include ../../fem_env.do;
include hrs_covariate_definitions.do;

local ster "$local_path/Estimates/nvaf";

* Prep claims data first. Most of this is handling the switch from single year to two year steps.;
use $dua_rand_hrs/hrs19922008_clms_trans;
rename clm_year year;
destring hhidpn, replace;
xtset hhidpn year;
tsfill;

egen exclusion = anymatch(afib_exclu_*), values(1);

by hhidpn: gen firstyear = year[1];
replace any_afib = 0 if (year==firstyear & !missing(any_afib)) | exclusion;
gen lany_afib = l.any_afib;
replace any_afib = . if missing(lany_afib) & year > firstyear;
by hhidpn: gen afibe = sum(any_afib);
replace afibe = min(1, afibe);
tempfile afibe;
save `afibe';

takestring, oldlist($allvars_hlth) newname("allvars_afibe") extlist("lhearte fhearte liadl1 liadl2p ladl1 ladl2 ladl3p flogiearnx lage65l lage6574 lage75p lwidowed fwidowed fsingle lage lagesq");
takestring, oldlist($allvars_hlth) newname("allvars_stroke") extlist("lstroke fstroke lstroke llunge liadl1 liadl2p ladl1 ladl2 ladl3p lwidow fwidow fsingle");

global allvars_afibe $allvars_afibe llungoxy;
global allvars_stroke $allvars_stroke lafibe llungoxy;

use $outdata/hrs19_transition if age >= 65 & !missing(weight);

merge 1:1 hhidpn year using `afibe', keepusing(afibe exclusion) keep(master match);

gen age_capped = age_yrs;
replace age_capped = 99 if age_capped > 99;
preserve;
collapse (sum) male black hispan hsless college [iw=weight];
mkmat male black hispan hsless college, matrix(org_weights);
matrix org_weights = org_weights';
restore;

reweight male black hispan hsless college if _merge==3, sweight(weight) nweight(new_weight) total(org_weights) dfunction(chi2);

fsum male black hispan hsless college [aw=weight];
fsum male black hispan hsless college if _merge==3 [aw=weight];
fsum male black hispan hsless college if _merge==3 [aw=new_weight];
bys _merge: fsum age_capped [aw=weight], s(p1 p25 p50 p75 p99);
fsum age_capped [aw=new_weight], s(p1 p25 p50 p75 p99);

mean afibe if !ldied & _m==3;
mean afibe if !ldied & _m==3 [aw=new_weight];
mean afibe if !ldied & _m==3 [aw=new_weight], over(wave);

fsum lbpcontrol linsulin llungoxy ldiabkidney;
* Special handling to use this disease-specific risk factors in a model;
replace lbpcontrol = 0 if !lhibpe;
replace linsulin = 0 if !ldiabe;
replace llungoxy = 0 if !llunge;
replace ldiabkidney = 0 if !ldiabe;

xtset hhidpn wave;

foreach v of varlist afibe {
  ;
  gen l`v' = l.`v';
  local lbl : var label `v';
  label var l`v' "Lag of `v'";
  by hhidpn: gen f`v' = `v'[1];
  label var f`v' "Init of `v'";
  gen `v'_orig = `v';
  replace `v' = -2 if l`v'==1 & wave > firstwave;
  replace `v' = 9 if died;
};

replace afibe = -2 if (lhearte | fhearte) & wave > firstwave;
logout, save(afibe_consort.txt) replace: tab1 afibe* lafibe exclusion if !died & !missing(afibe) & lafibe==0;

fsum age if afibe==1 [aw=weight];
fsum age if afibe==0 [aw=weight];

foreach v of varlist afibe stroke {
  ;
  local x = "allvars_`v'";
  probit `v' $`x' if `v'!=-2 & `v'!=9 & !l.exclusion, vce(cluster hhidpn);
  gen e_`v' = e(sample);
  mfx2, stub(b_`v') nose;
  est save "`ster'/`v'.ster", replace;
};

est restore b_afibe_coef;
predict p_afibe;
gen afibe2 = afibe if inlist(afibe,0,1);
summ afibe2 p_afibe [aw=weight];

mean afibe2 p_afibe [aw=weight];

drop afibe;
rename afibe_orig afibe;
probit afibe $allvars_afibe if afibe!=9 & !exclusion, vce(cluster hhidpn);
mfx2, stub(b_prev_afibe) nose;
est save `ster'/afibe_prev.ster, replace;

predict prev_afibe;
fsum afibe prev_afibe if !ldied [aw=weight];

xml_tab b_*, save(`ster'/claims.xls) replace pvalue stars() stats(N r2_p);

