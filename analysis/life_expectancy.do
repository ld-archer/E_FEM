clear all
set mem 500M
set maxvar 10000
set more off

include ../fem_env.do

** Variables to keep
global keeplist hhidpn mcrep year died age ldied qaly yr_step adl* iadl* nhmliv diclaim diabe cancre hearte lunge stroke hibpe qaly weight
global cohorts "2004 2006 2008 2010 2012 2014 2016 2018 2020 2022 2024"
global workdir "$local_root/analysis"
global qthresh 90 80 70 60

file open resultsFile using le.csv, write replace text
file write resultsFile "year,meanStartAge,meanDeathAge,meanLE,meanTotalQALY,meanMeanQALY"
foreach q in $qthresh {
  file write resultsFile ",totalAboveQ`q',totalBelowQ`q',percentAboveQ`q',percentBelowQ`q'"
}
file write resultsFile ",fig4_nodisability,fig4_anydisability,fig4_iadl1,fig4_iadl2p,fig4_adlnhm,fig4_adl1,fig4_adl2,fig4_adl3p,nodisease,anydisease,oneD,twoD,threeD,fourD,fiveD,sixD,hearte,lunge,diabe,cancre,hibpe,stroke"
file write resultsFile _n

foreach v in $cohorts {
  
** A script to calculate the life expectancy of a cohort simulation
global cohort_dir "$local_root/output/qalycohort`v'/detailed_output"

** Read in all the data files, dropping records dead for more than one timestep
cd $cohort_dir
shell ls *.dta > filelist.txt

file open myfile using filelist.txt, read

file read myfile line
use `line', clear
keep $keeplist

file read myfile line
while r(eof)==0 {
  append using `line', keep("$keeplist")
  drop if ldied==1
  file read myfile line
}

file close myfile

sort hhidpn mcrep year

** Life expectancy is just the average age at which people died
** Remove one year to assume person died in mid-timestep
by hhidpn mcrep: gen deathage = age[_N] - 1 if died[_N] == 1
by hhidpn mcrep: gen startage = age[1]
by hhidpn mcrep: gen startyear = year[1]
by hhidpn mcrep: gen deathyear = year[_N] - 1 if died[_N] == 1
by hhidpn mcrep: gen stillalive = died[_N] == 0
replace yr_step=1 if died==1
replace yr_step=0 if year==`v'

gen remainingLE = deathyear - startyear

** Mean total QALY is a bit more complicated
by hhidpn mcrep: egen qTot = total(qaly * yr_step)

** Mean Mean qaly just uses the two above
gen qLE = qTot/remainingLE if remainingLE > 0

** Mean percentage of life above QALY threshold
foreach q in $qthresh {
  gen aboveQ`q' = qaly > `q'/100
  gen belowQ`q' = qaly <= `q'/100
  by hhidpn mcrep: egen totalAboveQ`q' = total(aboveQ`q' * yr_step)
  by hhidpn mcrep: egen totalBelowQ`q' = total(belowQ`q' * yr_step)
  gen percentAboveQ`q' = totalAboveQ`q'/remainingLE
  gen percentBelowQ`q' = totalBelowQ`q'/remainingLE
}

cd $workdir
summ startage if year==`v' [aw=weight]
local meanStart = r(mean)
summ deathage if year==`v' [aw=weight]
local meanDeath = r(mean)
summ remainingLE if year==`v' [aw=weight]
local meanLE = r(mean)
summ qTot if year==`v' [aw=weight]
local meanTotQALY = r(mean)
summ qLE if year==`v' [aw=weight]
local meanMeanQALY = r(mean)

file write resultsFile "`v', `meanStart',`meanDeath',`meanLE',`meanTotQALY',`meanMeanQALY'"
foreach q in $qthresh {
  summ totalAboveQ`q' if year==`v' [aw=weight]
  local res = r(mean)
  file write resultsFile ",`res'"
  summ totalBelowQ`q' if year==`v' [aw=weight]
  local res = r(mean)
  file write resultsFile ",`res'"
  summ percentAboveQ`q' if year==`v' [aw=weight]
  local res = r(mean)
  file write resultsFile ",`res'"
  summ percentBelowQ`q' if year==`v' [aw=weight]
  local res = r(mean)
  file write resultsFile ",`res'"
}

** Life years in various disability categories
gen fig4_nodisability = !iadl1 & !iadl2p & !adl1 & !adl2 & !adl3p & !diclaim & !nhmliv
gen fig4_anydisability = !fig4_nodisability
gen fig4_iadl1 = iadl1 & !adl1 & !adl2 & !adl3p & !nhmliv
gen fig4_iadl2p = iadl2p & !adl1 & !adl2 & !adl3p & !nhmliv
gen fig4_adlnhm = adl1 | adl2 | adl3p | nhmliv
gen fig4_adl1 = adl1
gen fig4_adl2 = adl2
gen fig4_adl3p = adl3p
gen fig4_nodisease = !(hearte | lunge | diabe | cancre | hibpe | stroke)
gen fig4_anydisease = !fig4_nodisease
gen numdisease = hearte + lunge + diabe + cancre + hibpe + stroke
gen fig4_onedisease = numdisease == 1
gen fig4_twodiseases = numdisease == 2
gen fig4_threediseases = numdisease == 3
gen fig4_fourdiseases = numdisease == 4
gen fig4_fivediseases = numdisease == 5
gen fig4_sixdiseases = numdisease == 6
gen fig4_hearte = hearte
gen fig4_lunge = lunge
gen fig4_diabe = diabe
gen fig4_cancre = cancre
gen fig4_hibpe = hibpe
gen fig4_stroke = stroke

foreach d of varlist fig4_* {
  by hhidpn mcrep: egen total_`d' = total(`d' * yr_step)
  summ total_`d' if year==`v' [aw=weight]
  local res = r(mean)
  file write resultsFile ",`res'"
}


file write resultsFile _n
save "cohort`v'.dta", replace
}
file close resultsFile
insheet using le.csv, clear
save le.dta, replace

foreach v in 2004 2024 {
  use "cohort`v'.dta", clear
  gen qLT9 = qaly < 0.9 & died==0
  gen qLT8 = qaly < 0.8 & died==0
  gen qLT7 = qaly < 0.7 & died==0
  gen qLT6 = qaly < 0.6 & died==0
  gen nodisab = !(iadl1 | iadl2p | adl1 | adl2 | adl3p | nhmliv) & died==0
  gen nodisease = !(hearte | stroke | diabe | hibpe | lunge | cancre) & died==0
  
  collapse (sum) qLT9 qLT8 qLT7 qLT6 nodisab nodisease [pw=weight], by(year mcrep)
  collapse qLT9 qLT8 qLT7 qLT6 nodisab nodisease, by(year)
  
  outsheet using "survival`v'.csv", comma replace
}

exit, clear STATA
