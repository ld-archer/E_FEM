
capture program drop age_recode
program define age_recode

	* generate age variables

 qui{
	foreach v in age60e age61e age62e age63e age64e age5659 age6064 age6569 age7074 age7579 age8084 age85  ///
	age6574 age7584 age70p age5164 age75p /* wkrec00 wkrec01 wkrec11 wkrec10 */ {
		cap drop `v'
	}
	
	gen  age60e = age == 60 
	gen  age61e = age == 61 
	gen  age62e = age == 62 
	gen  age63e = age == 63 
	gen  age64e = age == 64 
	
       * More age variables
	gen age5659 =  inrange(age, 56, 59)
	gen age6064 =  inrange(age, 60, 64)       
	gen age6569 =  inrange(age, 65, 69)
	gen age7074 =  inrange(age, 70, 74)
	gen age7579 =  inrange(age, 75, 79)
	gen age8084 =  inrange(age, 80, 84)
	gen age85   =  age >= 85
	gen age6574 =  inrange(age,65,74)
	gen age7584 =  inrange(age,75,84)
	gen age70p  =  age >= 70 
	gen age5164 =  inrange(age, 51, 64)
	gen age75p =   age >=75 
	
	* Recode working status
	/*
	gen wkrec00 = wkrec_stat == 0 if wkrec_stat < .
	gen wkrec01 = wkrec_stat == 1 if wkrec_stat < .
	gen wkrec10 = wkrec_stat == 2 if wkrec_stat < .
	gen wkrec11 = wkrec_stat == 3 if wkrec_stat < .
	*/
	
}
	
end
