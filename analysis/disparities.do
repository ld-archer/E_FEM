clear all
set more off
set mem 5000M
set maxvar 15000

include "../fem_env.do"
global timestep 2

gen scenario = ""
label var scenario "Name of scenario"

global scen_list "status_quo cancer_aniogenesis cancer_mortality heart_icd heart_pacemaker hsless_ged prevent_diabe cancer_telomerase cancer_vaccine heart_lvad hsless_removed combination1 hibpe_adherence hearte_mortality"

foreach f in $scen_list {
  ** A script to calculate the life expectancy of a cohort simulation
  global cohort_dir "$local_root/output/`f'/detailed_output"

  ** Read in all the data files, dropping records dead for more than one timestep
  cd $cohort_dir
  shell ls *.dta > filelist.txt

  file open myfile using filelist.txt, read
  
  file read myfile line
  while r(eof)==0 {
    append using `line'
    drop if ldied | weight <= 0 | entry != 2006
    replace scenario = "`f'" if scenario==""
    file read myfile line
  }
  
  file close myfile
}

cd "$local_root/analysis"

log using disparityLE.txt, text replace

gen subgroup_all = 1
gen subgroup_black = black
gen subgroup_white = !black & !hispan
gen subgroup_hsless = hsless
gen subgroup_hsgrad = !hsless & !college
gen subgroup_college = college

sort scenario mcrep hhidpn year

foreach v of varlist subgroup_* {
  gen alive50_`v' = !died & age > 50 if `v'
  gen noadl50_`v' = !anyadl & !died & age > 50 if `v'
  gen nodisease50_`v' = !anydisease & !died & age > 50 if `v'
  gen totmd_`v' = totmd if `v'
  label var alive50_`v' "Alive and over age 50, `v'"
  label var noadl50_`v' "No ADLs and over age 50. `v'"
  label var nodisease50_`v' "No chronic disease and over age 50, `v'"
  label var totmd_`v' "Total Medical Expenditures, `v'"

  by scenario mcrep hhidpn: egen e50_`v' = total(alive50_`v' * $timestep) if `v'
  by scenario mcrep hhidpn: egen e50noadl_`v' = total(noadl50_`v' * $timestep) if `v'
  by scenario mcrep hhidpn: egen e50nodisease_`v' = total(nodisease50_`v' * $timestep) if `v'
  by scenario mcrep hhidpn: egen lifetime_totmd_`v' = total(totmd_`v' * $timestep) if `v'
  label var e50_`v' "Remaining life expectancy at age 50, `v'"
  label var e50noadl_`v' "Remaining adl-free years at age 50, `v'"
  label var e50nodisease_`v' "Remaining disease-free years at age 65, `v'"
  label var lifetime_totmd_`v' "Lifetime Total Medical Expenditures, `v'"
}

save bigdata.dta,replace

foreach v of varlist e50* lifetime_totmd_* {
  replace `v' = . if year > 2006
}

format %4.2f e50*
collapse e50* lifetime_totmd_* [aw=weight], by(scenario)
list
save disparity_le.dta, replace

  log close

exit, clear STATA
