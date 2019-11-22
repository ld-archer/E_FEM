/** 
Summarize marital status in data used for estimating PSID transition models
*/

use ../../input_data/psid_transition.dta

* incidence
gen new_married = mstat_new==3 if l2mstat_new != 3 & !missing(mstat_new) & !missing(l2mstat_new)
gen new_cohab = mstat_new==2 if l2mstat_new != 2 & !missing(mstat_new) & !missing(l2mstat_new)
gen new_singlenwid = mstat_new==1 & widowed==0 if l2mstat_new != 1 & !missing(mstat_new) & !missing(l2mstat_new) & !missing(partdied)
gen new_partdied = mstat_new==1 & partdied==1 if l2mstat_new != 1 & l2partdied==0 & !missing(mstat_new) & !missing(l2mstat_new) & !missing(partdied) & !missing(l2partdied)
gen new_widow = mstat_new==1 & widowed==1 if l2mstat_new != 1 & l2widowed==0 & !missing(mstat_new) & !missing(l2mstat_new) & !missing(widowed) & !missing(l2widowed)

* prevalence
gen cur_married = mstat_new==3 if !missing(mstat_new)
gen cur_cohab = mstat_new==2 if !missing(mstat_new)
gen cur_singlenwid = mstat_new==1 & widowed==0 if !missing(mstat_new) & !missing(widowed)
gen cur_partdied = mstat_new==1 & partdied==1 if !missing(mstat_new) & !missing(partdied)
gen cur_widow = mstat_new==1 & widowed==1 if !missing(mstat_new) & !missing(widowed)

* create age groups
gen agegrp = 1     if age >= 25 & age < 35
replace agegrp = 2 if age >= 35 & age < 45
replace agegrp = 3 if age >= 45 & age < 55
replace agegrp = 4 if age >= 55 & age < 65
replace agegrp = 5 if age >= 65 & !missing(age)

tempfile tfile1

* summarize population
preserve
#d ;
collapse 
(mean) imarried=new_married (mean) icohab=new_cohab (mean) isingle=new_singlenwid (mean) ipartdied=new_partdied (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_icohab=new_cohab (sum) t_isingle=new_singlenwid (sum) t_ipartdied=new_partdied (sum) t_iwidowed=new_widow
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) ppartdied=cur_partdied (mean) pwidowed=cur_widow
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_partdied=cur_partdied (sum) t_widowed=cur_widow
[fw=weight]
, by(year);
#d cr
save `tfile1'

* summarize by sex
restore
preserve
#d ;
collapse 
(mean) imarried=new_married (mean) icohab=new_cohab (mean) isingle=new_singlenwid (mean) ipartdied=new_partdied (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_icohab=new_cohab (sum) t_isingle=new_singlenwid (sum) t_ipartdied=new_partdied (sum) t_iwidowed=new_widow
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) ppartdied=cur_partdied (mean) pwidowed=cur_widow
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_partdied=cur_partdied (sum) t_widowed=cur_widow
[fw=weight]
, by(year male);
#d cr
append using `tfile1'
save `tfile1', replace

* summarize by sex and age group
restore
preserve
#d ;
collapse 
(mean) imarried=new_married (mean) icohab=new_cohab (mean) isingle=new_singlenwid (mean) ipartdied=new_partdied (mean) iwidowed=new_widow
(sum) t_imarried=new_married (sum) t_icohab=new_cohab (sum) t_isingle=new_singlenwid (sum) t_ipartdied=new_partdied (sum) t_iwidowed=new_widow
(mean) pmarried=cur_married (mean) pcohab=cur_cohab (mean) psingle=cur_singlenwid (mean) ppartdied=cur_partdied (mean) pwidowed=cur_widow
(sum) t_married=cur_married (sum) t_cohab=cur_cohab (sum) t_single=cur_singlenwid (sum) t_partdied=cur_partdied (sum) t_widowed=cur_widow
[fw=weight]
, by(year male agegrp);
#d cr

append using `tfile1'
save `tfile1', replace

sort male agegrp year

save estsamp_mstat_summaries.dta, replace 


