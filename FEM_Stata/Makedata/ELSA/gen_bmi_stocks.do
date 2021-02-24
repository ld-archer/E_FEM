* This file will generate a couple of new stock populations, with various changes made to reduce the levels of obesity and morbid obesity.

* 3 new populations will be produced:
* Morbid obesity removed - All simulants with BMI over 40 will have their BMI reduced to the mean of people with BMI 35-40
* Obesity 2 removed - BMI 35+ reduced to average of 30-35
* Obesity removed - BMI 30+ reduced to average of whole population

gen obeseGroup = 3 if bmi >= 35 & bmi < 40
replace obeseGroup = 2 if bmi >= 30 & bmi < 35
replace obeseGroup = 1 if bmi >= 25 & bmi < 30

*bysort obeseGroup: egen bmi_mean = mean(bmi)

*local 3540_mean = bmi_mean if obeseGroup == 3
*local 3035_mean = bmi_mean if obeseGroup == 2
*local 2530_mean = bmi_mean if obeseGroup == 1

preserve

sum bmi if obeseGroup == 3

replace bmi = r(mean) if bmi > 40

drop obeseGroup

saveold $outdata/ELSA_stock_nomorbid.dta, replace v(12)

restore
preserve

sum bmi if obeseGroup == 2

replace bmi = r(mean) if bmi > 35

drop obeseGroup

saveold $outdata/ELSA_stock_noobese2.dta, replace v(12)

restore
preserve

sum bmi if obeseGroup == 1

replace bmi = r(mean) if bmi > 30

drop obeseGroup

saveold $outdata/ELSA_stock_noobese1.dta, replace v(12)
