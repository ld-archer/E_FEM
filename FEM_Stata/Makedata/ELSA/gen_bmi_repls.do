* This file will generate a couple of new stock populations, with various changes made to reduce the levels of obesity and morbid obesity.

* 3 new populations will be produced:
* Morbid obesity removed - All simulants with BMI over 40 will have their BMI reduced to the mean of people with BMI 35-40
* Obesity 2 removed - BMI 35+ reduced to average of 30-35
* Obesity removed - BMI 30+ reduced to average of whole population

gen obeseGroup = 3 if logbmi >= log(35) & logbmi < log(40)
replace obeseGroup = 2 if logbmi >= log(30) & logbmi < log(35)
*replace obeseGroup = 1 if logbmi < log(30)

count
sum bmi logbmi 
count if missing(bmi)
count if !missing(bmi)
count if missing(logbmi)
count if !missing(logbmi)

preserve

sum logbmi if obeseGroup == 3

replace logbmi = r(mean) if !missing(logbmi) & logbmi > log(40)
*replace logbmi = log(bmi) if !missing(bmi)

drop obeseGroup

saveold $outdata/ELSA_repl_nomorbid.dta, replace v(12)

restore
preserve

sum logbmi if obeseGroup == 2

replace logbmi = r(mean) if !missing(logbmi) & logbmi > log(35)
*replace logbmi = log(bmi) if !missing(bmi)

drop obeseGroup

saveold $outdata/ELSA_repl_noobese2.dta, replace v(12)

restore
preserve

sum logbmi

di r(mean)

replace logbmi = r(mean) if !missing(logbmi) & logbmi > log(30)
*replace logbmi = log(bmi) if !missing(bmi)

drop obeseGroup

saveold $outdata/ELSA_repl_noobese1.dta, replace v(12)
