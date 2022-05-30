use input_data/ELSA_long.dta, clear


*** Check how much is missing and by wave
* Total in ELSA_long
count
* Total not missing
count if !missing(alcbase)
* Tab of wave
tab wave
* By wave: Total missing alcbase
bysort wave: count if missing(alcbase)


*** Check consumption stats by groups

** Gender
bys male: egen miss_gender = mean(missing(alcbase))
bys male: sum alcbase miss_gender

************************************

** Age Group
egen age_group = cut(age), at(50, 60, 70, 80, 90, 100)

bys age_group: egen miss_age = mean(missing(alcbase))
bys age_group: sum alcbase miss_age

************************************

** Education level
bys educ: egen miss_educ = mean(missing(alcbase))
bys educ: sum alcbase miss_educ

************************************

** Marriage status
*bys mstat: egen miss_mstat = mean(missing(alcbase))
*bys mstat: sum alcbase miss_mstat

************************************

** Obesity
*generate obese = (logbmi > log(30))
bys obese: egen miss_obese = mean(missing(alcbase))
bys obese: sum alcbase miss_obese

************************************

hist alcbase, by(male, missing)

hist alcbase, by(educ, missing)

*hist alcbase, by(age_group, missing)


*** Look at Abstainers
sum male age educ if alcbase == 0
