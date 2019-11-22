/* 
	Output an Excel file that has node and edge information:
	node sheet: defines group IDS, node IDS, and labels
	edge sheet: defines source and target nodes
*/


quietly include ../../fem_env.do 

local outdir : env simtype
local edges_nodes_file : env fileout 
local ster : env sterdir 

log using process_ster_`outdir'.log, replace

noi di "Loading estimates from [`ster']"

* Loads all estimates
local all_ests : dir "`ster'" files "*.ster"
	
* For development only 	
* local all_ests cancre.ster diabe.ster hearte.ster hibpe.ster lunge.ster stroke.ster 


* Initialize the file
qui file open outfile using `outdir'/files/all_edges.csv, write text replace
file write outfile "Source" "," "Target" _n	
	
foreach est in `all_ests' {
	noi di "Loading estimate: `est'"


	est use "`ster'/`est'"

	* Name of the file (if needed)
	local est_name = substr("`est'",1,length("`est'")-5)

	* Regressors to be processed
	matrix x = e(b)
	local ncols = colsof(x)
	local vars : colnames x
	
	* Predicted variable 
	local depvar = e(depvar)
	
	forvalues i = 1/`ncols' {
		local varout : word `i' of `vars'		
		file write outfile "`varout'" "," "`depvar'" _n	
	}
	
}

file close outfile		


clear

import delimited `outdir'/files/all_edges.csv, varnames(1)


* Clean up omitted variables and constants
drop if source == "_cons"
drop if substr(source,1,2) == "o."

* tab source
* tab target

gen str input_grp_lvl_1 = ""
gen str input_grp_lvl_2 = ""
gen str input_grp_lvl_3 = ""

gen str output_grp_lvl_1 = ""
gen str output_grp_lvl_2 = ""
gen str output_grp_lvl_3 = ""

* Define the source concepts 
gen str concept = ""

replace concept = "Age" if inlist(source,"l2age35l","l2age3544","l2age4554","l2age5564","l2age6574","l2age75p")
replace concept = "Race" if inlist(source,"black","hispan")
replace concept = "Education" if inlist(source,"educ1","educ3","educ4","hsless","college")
replace concept = "Race-Education" if inlist(source,"black_educ1","black_educ3","black_educ4","hispan_educ1","hispan_educ3","hispan_educ4")
replace concept = "Sex" if inlist(source,"male")
replace concept = "Sex-Race" if inlist(source,"male_black","male_hispan")
replace concept = "Childhood SES" if inlist(source,"fpoor","frich")
replace concept = "Childhood self-reported health" if inlist(source,"chldsrh2","chldsrh3","chldsrh4","chldsrh5")
replace concept = "Age-Sex" if inlist(source,"l2age35l_male","l2age3544_male","l2age4554_male","l2age5564_male","l2age6574_male","l2age75p_male","l2age65p_male")
replace concept = "Smoking status" if inlist(source,"l2smokev","l2smoken")
replace concept = "Exercise" if inlist(source,"l2anyexercise")
replace concept = "BMI" if inlist(source,"l2logbmi_l30","l2logbmi_30p")
replace concept = "Cancer" if inlist(source,"l2cancre","cancre","cancre_lcancre","cancre_nlcancre","icancre")
replace concept = "Diabetes" if inlist(source,"l2diabe","diabe","diabe_ldiabe","diabe_nldiabe","idiabe")
replace concept = "Heart disease" if inlist(source,"l2hearte","hearte","hearte_lhearte","hearte_nlhearte","ihearte")
replace concept = "Hypertension" if inlist(source,"l2hibpe","hibpe","hibpe_lhibpe","hibpe_nlhibpe","ihibpe")
replace concept = "Lung disease" if inlist(source,"l2lunge","lunge","lunge_llunge","lunge_nllunge","ilunge")
replace concept = "Stroke" if inlist(source,"l2stroke","stroke","stroke_lstroke","stroke_nlstroke","istroke")
replace concept = "ADL" if inlist(source,"adl1","adl1p","adl2","adl3p","l2adl1","l2adl2","l2adl3p")
replace concept = "Age" if inlist(source,"age","agesq","l2age")
replace concept = "Age" if inlist(source,"age2534","age3034","age3539","age3544","age4044","age4549","age4554","age5054","age5559")
replace concept = "Age" if inlist(source,"age5564","age6064","age6569","age7074","age7579","age8084","age85")
replace concept = "Age-Race" if inlist(source,"black_l2age3034d","black_l2age3539d","black_l2age4049d","black_l2age5059d","black_l2age50pd","black_l2age6064d","black_l2age65pd")
replace concept = "Cancer" if inlist(source,"cancre","cancre_lcancre","cancre_nlcancre")
replace concept = "Relationship status" if inlist(source,"cohab")
replace concept = "Comorbidities" if inlist(source,"diabe_hearte","diabe_hibpe","hibpe_hearte","hibpe_stroke")
replace concept = "Claiming disability" if inlist(source,"diclaim","diclaim_died","diclaim_nhmliv","l2diclaim")
replace concept = "Mortality" if inlist(source,"died")
replace concept = "Age-Mortality" if inlist(source,"died_age2534","died_age3544","died_age4554","died_age5564","died_age7074","died_age7579","died_age8084","died_age85")
replace concept = "Condition-Mortality" if inlist(source,"died_cancre","died_diabe","died_hearte","died_hibpe","died_lunge","died_nhmliv","died_stroke")
replace concept = "Capital income" if inlist(source,"hicap_real")
replace concept = "Age-Race" if inlist(source,"hispan_l2age3034d","hispan_l2age3539d","hispan_l2age4049d","hispan_l2age5059d","hispan_l2age50pd","hispan_l2age6064d","hispan_l2age60pd","hispan_l2age65pd")
replace concept = "IADL" if inlist(source,"iadl1","iadl2p","l2iadl1","l2iadl2p")
replace concept = "Earnings" if inlist(source,"iearn_real")
replace concept = "Kessler 6" if inlist(source,"k6severe")
replace concept = "Age" if inlist(source,"l2age3034d","l2age3539d","l2age4049d","l2age5059d","l2age50pd","l2age5561")
replace concept = "Age" if inlist(source,"l2age55p","l2age6064d","l2age6264")
replace concept = "Age-Education" if inlist(source,"l2age3544_educ1","l2age3544_educ3","l2age3544_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age3544_l2cohab","l2age3544_l2married")
replace concept = "Age-Education" if inlist(source,"l2age35l_educ1","l2age35l_educ3","l2age35l_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age35l_l2cohab","l2age35l_l2married")
replace concept = "Age-Education" if inlist(source,"l2age4554_educ1","l2age4554_educ3","l2age4554_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age4554_l2cohab","l2age4554_l2married")
replace concept = "Age-Education" if inlist(source,"l2age5564_educ1","l2age5564_educ3","l2age5564_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age5564_l2cohab","l2age5564_l2married")
replace concept = "Age-Race" if inlist(source,"l2age6574_black","l2age6574_hispan","l2age65l_black","l2age65l_hispan","l2age75p_black","l2age75p_hispan")
replace concept = "Age-Education" if inlist(source,"l2age6574_educ1","l2age6574_educ3","l2age6574_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age6574_l2cohab","l2age6574_l2married")
replace concept = "Age" if inlist(source,"l2age65l","l2age65p","l2age65pd")
replace concept = "Age-Education" if inlist(source,"l2age65p_educ1","l2age65p_educ3","l2age65p_educ4")
replace concept = "Age-Education" if inlist(source,"l2age75p_educ1","l2age75p_educ3","l2age75p_educ4")
replace concept = "Age-Relationship" if inlist(source,"l2age75p_l2cohab","l2age75p_l2married")
replace concept = "Age" if inlist(source,"l2agesq")
replace concept = "Relationship status" if inlist(source,"l2cohab","l2everm","l2eversep","l2married")
replace concept = "Earnings" if inlist(source,"l2ihsiearn","l2logiearnx","logiearnx")
replace concept = "Earnings-Work" if inlist(source,"l2ihsiearn_l2workcat1","l2ihsiearn_l2workcat3","l2ihsiearn_l2workcat4")
replace concept = "Insurance" if inlist(source,"l2inscat1","l2inscat2")
replace concept = "Kessler 6" if inlist(source,"l2k6score")
replace concept = "Wealth" if inlist(source,"l2loghatotax","loghatotax")
replace concept = "Children" if inlist(source,"l2numbiokids1","l2numbiokids2","l2numbiokids3p")
replace concept = "Social Security" if inlist(source,"l2ssclaim")
replace concept = "Supplemental Security" if inlist(source,"l2ssiclaim")
replace concept = "Work category" if inlist(source,"l2workcat2","l2workcat3","l2workcat4")
replace concept = "Sex-Education" if inlist(source,"male_college","male_educ1","male_educ3","male_educ4","male_hsless")
replace concept = "Age-Sex" if inlist(source,"male_l2age6574","male_l2age65l","male_l2age75p")
replace concept = "Age-Sex-Race" if inlist(source,"male_l2age6574_black","male_l2age65l_black","male_l2age65l_hispan","male_l2age75p_black")
replace concept = "Sex-Relationship" if inlist(source,"male_l2cohab","male_l2married","male_married","male_cohab")
replace concept = "Relationship status" if inlist(source,"married")
replace concept = "Mother's education" if inlist(source,"mthreduc2","mthreduc3","mthreduc4")
replace concept = "Nursing home" if inlist(source,"nhmliv")
replace concept = "Age" if inlist(source,"nramin0","nramin1","nramin10","nramin2","nramin3","nramin4","nramin5","nramin6")
replace concept = "Age" if inlist(source,"nramin7","nramin8","nramin9","nraplus0","nraplus1","nraplus2","nraplus4")
replace concept = "Children" if inlist(source,"numbiokids1","numbiokids2","numbiokids3p")
replace concept = "BMI" if inlist(source,"obese","overwt")
replace concept = "Relationship status" if inlist(source,"single","widowed")
replace concept = "Smoking status" if inlist(source,"smoken")
replace concept = "Age" if inlist(source,"age6575","age65l","age75l","age75p","age_yrs")  
replace concept = "IADL" if inlist(source,"anyiadl")  
replace concept = "Age" if inlist(source,"at_eea","at_nra")  
replace concept = "Race-Heart attack" if inlist(source,"black_l2heartae","hispan_l2heartae")  
replace concept = "Religion" if inlist(source,"catholic","jewish")  
replace concept = "Education-Heart attack" if inlist(source,"college_l2heartae","hsless_l2heartae")
replace concept = "Claiming disability-ADL" if inlist(source,"diclaim_adl3p") 
replace concept = "Age-Mortality" if inlist(source,"died_age6569")
replace concept = "Developed environment" if inlist(source,"exurb","suburb") 
replace concept = "Cancer by 50" if inlist(source,"fcanc50") 
replace concept = "Diabetes by 50" if inlist(source,"fdiabe50")
replace concept = "Heart disease by 50" if inlist(source,"fheart50") 
replace concept = "Hypertension by 50" if inlist(source,"fhibp50") 
replace concept = "Lung disease by 50" if inlist(source,"flung50")
replace concept = "Cancer by 50" if inlist(source,"fstrok50")  
replace concept = "Cancer by 50-Heart attack" if inlist(source,"fcanc50_l2heartae")
replace concept = "Diabetes by 50-Heart attack" if inlist(source,"fdiabe50_l2heartae")
replace concept = "Heart disease by 50-Heart attack" if inlist(source,"fheart50_l2heartae")
replace concept = "Hypertension by 50-Heart Attack" if inlist(source,"fhibp50_l2heartae")
replace concept = "Lung disease by 50-Heart attack" if inlist(source,"flung50_l2heartae")
replace concept = "Number of children" if inlist(source,"fkids")
replace concept = "BMI at 50" if inlist(source,"flogbmi50_30p","flogbmi50_l30")  
replace concept = "Earnings" if inlist(source,"flogiearnuc","flogiearnx","iearnx")  
replace concept = "Birth year" if inlist(source,"frbyr")
replace concept = "Smoking status at 50" if inlist(source,"fsmoken50","fsmokev")
replace concept = "Smoking status at 50-Heart attack" if inlist(source,"fsmoken50_l2heartae","fsmokev_l2heartae")  
replace concept = "Stroke by 50-Heart disease" if inlist(source,"fstrok50_l2heartae") 
replace concept = "Heart disease-Smoking status" if inlist(source,"hearte_smokev")  
replace concept = "Hypertension-BMI" if inlist(source,"hibpe_obese")
replace concept = "Age" if inlist(source,"l2a6","l2a7","l2a7p")  
replace concept = "ADL" if inlist(source,"l2adl1p")  
replace concept = "Age-Heart attack" if inlist(source,"l2age6574_l2heartae","l2age65l_l2heartae","l2age75p_l2heartae")
replace concept = "Age" if inlist(source,"l2age7074","l2age70l","l2age7579")  
replace concept = "Age" if inlist(source,"l2age80p")
replace concept = "Congestive heart failure" if inlist(source,"l2chfe")  
replace concept = "Cognitive status" if inlist(source,"l2cogstate1","l2cogstate2")  
replace concept = "Claiming DB pension" if inlist(source,"l2dbclaim")  
replace concept = "Diabetes-Heart Attack" if inlist(source,"l2diabe_l2heartae")  
replace concept = "Grandchild care hours" if inlist(source,"l2gkcarehrs")  
replace concept = "Heart attack" if inlist(source,"l2hearta")  
replace concept = "Helper hours" if inlist(source,"l2helphoursyr","l2helphoursyr_nonsp","l2helphoursyr_sp")  
replace concept = "Hypertension-Stroke" if inlist(source,"l2hibp_stroke")
replace concept = "Hypertension-Heart attack" if inlist(source,"l2hibpe_l2heartae")
replace concept = "Capital income" if inlist(source,"l2hicap","l2hicap_nonzero")  
replace concept = "IADL" if inlist(source,"l2iadl1p")  
replace concept = "Capital income" if inlist(source,"l2ihs_hicap_cpl")  
replace concept = "Wealth" if inlist(source,"l2ihs_hwealth_cpl")  
replace concept = "BMI-Heart attack" if inlist(source,"l2logbmi_30p_l2heartae","l2logbmi_l30_l2heartae")  
replace concept = "Earnings" if inlist(source,"l2logiearnuc")  
replace concept = "Nursing home" if inlist(source,"l2nhmliv")  
replace concept = "Number of diseases" if inlist(source,"l2numdisease")
replace concept = "Parent care hours" if inlist(source,"l2parhelphours")
replace concept = "Property tax" if inlist(source,"l2proptax","l2proptax_nonzero")  
replace concept = "Self-rated memory" if inlist(source,"l2selfmem1","l2selfmem2")  
replace concept = "Smoking status-Heart attack" if inlist(source,"l2smoken_l2heartae")  
replace concept = "Financial transfers" if inlist(source,"l2tcamt_cpl")
replace concept = "Volunteer hours" if inlist(source,"l2volhours")  
replace concept = "Relationship status" if inlist(source,"l2widowed")  
replace concept = "Relationship status-Heart attack" if inlist(source,"l2widowed_l2heartae")  
replace concept = "Wealth non-zero" if inlist(source,"l2wlth_nonzero")  
replace concept = "Interview spacing" if inlist(source,"logdeltaage") 
replace concept = "Interview spacing-Heart attack" if inlist(source,"logdeltaage_l2heartae")
replace concept = "Sex-Race-Heart attack" if inlist(source,"male_black_l2heartae","male_hispan_l2heartae")
replace concept = "Sex-Education-Heart attack" if inlist(source,"male_hsless_l2heartae")
replace concept = "Sex-Heart attack" if inlist(source,"male_l2heartae")  
replace concept = "Memory-related disease" if inlist(source,"memrye")  
replace concept = "Children nearby" if inlist(source,"nkid_liv10mi")  
replace concept = "Age" if inlist(source,"nraplus10","nraplus3","nraplus5","nraplus6","nraplus7","nraplus8","nraplus9") 
replace concept = "Religion importance" if inlist(source,"rel_notimp","rel_someimp","relnone","reloth")  
replace concept = "Smoking status" if inlist(source,"smokev")
replace concept = "Unemployment rate" if inlist(source,"unemployment")  
replace concept = "Year" if inlist(source,"w5","w6","w7","w8","w9")  
replace concept = "Working for pay" if inlist(source,"work","l2work")  
replace concept = "Age" if inlist(source,"yrs_after_nra","yrs_before_nra")  
replace concept = "Alzheimer's disease" if inlist(source,"alzhe_lalzhe")
replace concept = "Alzheimer's disease" if inlist(source,"alzhe_nlalzhe")
replace concept = "Condition-Mortality" if inlist(source,"died_alzhe")
replace concept = "Condition-Mortality" if inlist(source,"died_heartae")
replace concept = "Heart attack" if inlist(source,"hearta")
replace concept = "Subsequent heart attack" if inlist(source,"heartae_lheartae")
replace concept = "First heart attack" if inlist(source,"heartae_nlheartae")
replace concept = "Nursing home-Alzheimer's disease" if inlist(source,"nhmliv_alzhe")
replace concept = "Nursing home-Heart attack" if inlist(source,"nhmliv_heartae")
replace concept = "Age" if inlist(source,"l2age62pd")
replace concept = "Social Security" if inlist(source,"l2oasiclaim")
replace concept = "Age-Sex-Race" if inlist(source,"male_l2age6574_hispan","male_l2age75p_hispan")
replace concept = "Age" if inlist(source,"l2age6061","l2age6263","l2age6566","l2age6770")
replace concept = "Year" if inlist(source,"y2001","y2003","y2005","y2007","y2009","y2011","y2013")


tab concept
tab source if missing(concept)

levelsof source if missing(concept), local(concept_missing)
local concept_missing_cnt : word count `concept_missing'
if `concept_missing_cnt' > 0 {
	forvalues x = 1/`concept_missing_cnt' {
		local tgt : word `x' of `concept_missing'
		di as txt "Warning: `tgt' is not assigned a CONCEPT group"
	}
}

* Code the hierarchical groups of concepts

* Predictors
** Demographic
*** Time-invariant
* "Childhood SES","Childhood self-reported health","Education","Mother's Education","Race","Sex"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Childhood SES","Childhood self-reported health","Education","Mother's education","Race","Sex")
replace input_grp_lvl_2 = "T: Demographic" if inlist(concept,"Childhood SES","Childhood self-reported health","Education","Mother's education","Race","Sex")
replace input_grp_lvl_3 = "T: Time-invariant" if inlist(concept,"Childhood SES","Childhood self-reported health","Education","Mother's education","Race","Sex")

*** Time-varying
* "Children","Relationship status"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Children","Relationship status")
replace input_grp_lvl_2 = "T: Demographic" if inlist(concept,"Children","Relationship status")
replace input_grp_lvl_3 = "T: Time-varying" if inlist(concept,"Children","Relationship status")

* Predictors
** Health Status
*** Mortality
* "Mortality"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Mortality")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Mortality")
replace input_grp_lvl_3 = "T: Mortality" if inlist(concept,"Mortality")

*** Risk factors (age, bmi, smoking, exercise)
* "Age","BMI","Exercise","Smoking status"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Age","BMI","Exercise","Smoking status")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Age","BMI","Exercise","Smoking status")
replace input_grp_lvl_3 = "T: Risk factors" if inlist(concept,"Age","BMI","Exercise","Smoking status")

*** Risk factors (birth year, current year, interview spacing)
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Birth year","Year","Interview spacing")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Birth year","Year","Interview spacing")
replace input_grp_lvl_3 = "T: Risk factors" if inlist(concept,"Birth year","Year","Interview spacing")

*** Risk factors at age 50
* "BMI at 50","Cancer by 50","Diabetes by 50","Heart disease by 50","Hypertension by 50","Lung disease by 50","Smoking status at 50"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"BMI at 50","Cancer by 50","Diabetes by 50","Heart disease by 50","Hypertension by 50","Lung disease by 50","Smoking status at 50")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"BMI at 50","Cancer by 50","Diabetes by 50","Heart disease by 50","Hypertension by 50","Lung disease by 50","Smoking status at 50")
replace input_grp_lvl_3 = "T: Risk factors at age 50" if inlist(concept,"BMI at 50","Cancer by 50","Diabetes by 50","Heart disease by 50","Hypertension by 50","Lung disease by 50","Smoking status at 50")


*** Chronic conditions (cancer, diabetes, heart disease, hypertension, lung disease, stroke)
* "Cancer","Diabetes","Heart Disease","Hypertension","Lung Disease","Stroke"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Cancer","Diabetes","Heart disease","Hypertension","Lung disease","Stroke")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Cancer","Diabetes","Heart disease","Hypertension","Lung disease","Stroke")
replace input_grp_lvl_3 = "T: Chronic conditions" if inlist(concept,"Cancer","Diabetes","Heart disease","Hypertension","Lung disease","Stroke")
* "Alzheimer's disease","Congestive heart failure","First heart attack","Subsequent heart attack","Heart attack")
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Alzheimer's disease","Congestive heart failure","First heart attack","Subsequent heart attack","Heart attack")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Alzheimer's disease","Congestive heart failure","First heart attack","Subsequent heart attack","Heart attack")
replace input_grp_lvl_3 = "T: Chronic conditions" if inlist(concept,"Alzheimer's disease","Congestive heart failure","First heart attack","Subsequent heart attack","Heart attack")

*** Functional limitations (ADL, IADL)
* "ADL","IADL","Nursing Home"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"ADL","IADL","Nursing home")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"ADL","IADL","Nursing home")
replace input_grp_lvl_3 = "T: Functional limitations" if inlist(concept,"ADL","IADL","Nursing home")

*** Mental distress
* "Kessler 6"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Kessler 6")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Kessler 6")
replace input_grp_lvl_3 = "T: Mental distress" if inlist(concept,"Kessler 6")


* Predictors
** Econonmic Status
*** Employment status (laborforce, full/part time
* "Work category","Working for pay"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Work category","Working for pay")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Work category","Working for pay")
replace input_grp_lvl_3 = "T: Employment status" if inlist(concept,"Work category","Working for pay")

*** Income and assets (any earnings/amount, any wealth/amount, any capital/amount)
* "Capital income","Earnings","Wealth","Wealth non-zero"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Capital income","Earnings","Wealth","Wealth non-zero")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Capital income","Earnings","Wealth","Wealth non-zero")
replace input_grp_lvl_3 = "T: Income and assets" if inlist(concept,"Capital income","Earnings","Wealth","Wealth non-zero")

*** Public program participation (DI, SS, SSI, igxfr)
* "Claiming disability","Social Security","Supplemental Security"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Claiming disability","Social Security","Supplemental Security")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Claiming disability","Social Security","Supplemental Security")
replace input_grp_lvl_3 = "T: Public program participation" if inlist(concept,"Claiming disability","Social Security","Supplemental Security")

*** Private program participation (DB)
* "Claiming DB pension"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Claiming DB pension")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Claiming DB pension")
replace input_grp_lvl_3 = "T: Private program participation" if inlist(concept,"Claiming DB pension")

*** Health insurance
* "Insurance"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Insurance")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Insurance")
replace input_grp_lvl_3 = "T: Health insurance" if inlist(concept,"Insurance")

*** Interactions
* "Age-Education","Age-Mortality","Age-Race","Age-Relationship","Age-Sex","Age-Sex-Race"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Age-Education","Age-Mortality","Age-Race","Age-Relationship","Age-Sex","Age-Sex-Race")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Age-Education","Age-Mortality","Age-Race","Age-Relationship","Age-Sex","Age-Sex-Race")

*  "Comorbidities","Condition-Mortality","Earnings-Work","Race-Education","Sex-Education","Sex-Race","Sex-Relationship"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Comorbidities","Condition-Mortality","Earnings-Work","Race-Education","Sex-Education","Sex-Race","Sex-Relationship")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Comorbidities","Condition-Mortality","Earnings-Work","Race-Education","Sex-Education","Sex-Race","Sex-Relationship")

* Economic
* "Property tax"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Property tax")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Property tax")
replace input_grp_lvl_3 = "T: Taxes" if inlist(concept,"Property tax")

* Additional fixed demographic characteristics
* "Children nearby","Number of children","Developed environment","Religion","Religion importance"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Children nearby","Number of children","Developed environment","Religion","Religion importance")
replace input_grp_lvl_2 = "T: Demographic" if inlist(concept,"Children nearby","Number of children","Developed environment","Religion","Religion importance")
replace input_grp_lvl_3 = "T: Time-invariant" if inlist(concept,"Children nearby","Number of children","Developed environment","Religion","Religion importance")


* Cognition
* "Cognitive status","Memory-related disease","Self-rated memory"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Cognitive status","Memory-related disease","Self-rated memory")
replace input_grp_lvl_2 = "T: Health status" if inlist(concept,"Cognitive status","Memory-related disease","Self-rated memory")
replace input_grp_lvl_3 = "T: Cognition" if inlist(concept,"Cognitive status","Memory-related disease","Self-rated memory")

* Financial transfers
* "Financial transfers","Grandchild care hours","Parent care hours","Volunteer hours","Helper hours"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Financial transfers","Grandchild care hours","Parent care hours","Volunteer hours","Helper hours")
replace input_grp_lvl_2 = "T: Economic status" if inlist(concept,"Financial transfers","Grandchild care hours","Parent care hours","Volunteer hours","Helper hours")
replace input_grp_lvl_3 = "T: Informal transfers" if inlist(concept,"Financial transfers","Grandchild care hours","Parent care hours","Volunteer hours","Helper hours")


*** FEM Interactions
* "Age-Heart attack","BMI-Heart attack","Cancer by 50-Heart attack","Claiming disability-ADL","Diabetes by 50-Heart attack","Diabetes-Heart Attack","Education-Heart attack"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Age-Heart attack","BMI-Heart attack","Cancer by 50-Heart attack","Claiming disability-ADL","Diabetes by 50-Heart attack","Diabetes-Heart Attack","Education-Heart attack")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Age-Heart attack","BMI-Heart attack","Cancer by 50-Heart attack","Claiming disability-ADL","Diabetes by 50-Heart attack","Diabetes-Heart Attack","Education-Heart attack")

* "Heart disease by 50-Heart attack","Heart disease-Smoking status","Hypertension by 50-Heart Attack","Hypertension-BMI","Hypertension-Heart attack","Hypertension-Stroke"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Heart disease by 50-Heart attack","Heart disease-Smoking status","Hypertension by 50-Heart Attack","Hypertension-BMI","Hypertension-Heart attack","Hypertension-Stroke")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Heart disease by 50-Heart attack","Heart disease-Smoking status","Hypertension by 50-Heart Attack","Hypertension-BMI","Hypertension-Heart attack","Hypertension-Stroke")

* "Interview spacing-Heart attack","Lung disease by 50-Heart attack","Nursing home-Alzheimer's disease","Nursing home-Heart attack","Number of diseases"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Interview spacing-Heart attack","Lung disease by 50-Heart attack","Nursing home-Alzheimer's disease","Nursing home-Heart attack","Number of diseases")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Interview spacing-Heart attack","Lung disease by 50-Heart attack","Nursing home-Alzheimer's disease","Nursing home-Heart attack","Number of diseases")

* "Race-Heart attack" "Relationship status-Heart attack","Sex-Education-Heart attack","Sex-Heart attack","Sex-Race-Heart attack"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Race-Heart attack","Relationship status-Heart attack","Sex-Education-Heart attack","Sex-Heart attack","Sex-Race-Heart attack")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Race-Heart attack","Relationship status-Heart attack","Sex-Education-Heart attack","Sex-Heart attack","Sex-Race-Heart attack")

* "Smoking status at 50-Heart attack","Smoking status-Heart attack","Stroke by 50-Heart disease"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Smoking status at 50-Heart attack","Smoking status-Heart attack","Stroke by 50-Heart disease")
replace input_grp_lvl_2 = "T: Interactions" if inlist(concept,"Smoking status at 50-Heart attack","Smoking status-Heart attack","Stroke by 50-Heart disease")

*** Macroeconomic factors
* "Unemployment rate"
replace input_grp_lvl_1 = "T: Predictors" if inlist(concept,"Unemployment rate")
replace input_grp_lvl_2 = "T: Macroeconomic" if inlist(concept,"Unemployment rate")
replace input_grp_lvl_3 = "T: Time-varying" if inlist(concept,"Unemployment rate")

tab input_grp_lvl_1
tab input_grp_lvl_2
tab input_grp_lvl_3

tab concept if missing(input_grp_lvl_1)

* Classify outputs

* Transitioned
** Health Status
*** Mortality
* "died"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"died")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"died")
replace output_grp_lvl_3 = "T+1: Mortality" if inlist(target,"died")
*** Risk factors (age, bmi, smoking, exercise)
* "logbmi","anyexercise","smoke_start","smoke_stop"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"logbmi","anyexercise","smoke_start","smoke_stop")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"logbmi","anyexercise","smoke_start","smoke_stop")
replace output_grp_lvl_3 = "T+1: Risk factors" if inlist(target,"logbmi","anyexercise","smoke_start","smoke_stop")
*** Chronic conditions (cancer, diabetes, heart disease, hypertension, lung disease, stroke)
* "cancre","diabe","hearte","hibpe","lunge","stroke"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"cancre","diabe","hearte","hibpe","lunge","stroke")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"cancre","diabe","hearte","hibpe","lunge","stroke")
replace output_grp_lvl_3 = "T+1: Chronic conditions" if inlist(target,"cancre","diabe","hearte","hibpe","lunge","stroke")
*** Functional limitations (ADL, IADL)
* "adlstat","iadlstat"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"adlstat","iadlstat")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"adlstat","iadlstat")
replace output_grp_lvl_3 = "T+1: Functional limitations" if inlist(target,"adlstat","iadlstat")
*** Mental distress
* "k6score"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"k6score")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"k6score")
replace output_grp_lvl_3 = "T+1: Mental distress" if inlist(target,"k6score")

* Transitioned
** Econonmic Status
*** Employment status (laborforce, full/part time
* "laborforcestat","fullparttime"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"laborforcestat","fullparttime")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"laborforcestat","fullparttime")
replace output_grp_lvl_3 = "T+1: Employment status" if inlist(target,"laborforcestat","fullparttime")
*** Income and assets (any earnings/amount, any wealth/amount, any capital/amount)
* "any_iearn_nl","any_iearn_ue","hatota","hicap","hicap_nonzero","lniearn_ft","lniearn_nl","lniearn_pt","lniearn_ue","wlth_nonzero"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"any_iearn_nl","any_iearn_ue","hatota","hicap","hicap_nonzero")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"any_iearn_nl","any_iearn_ue","hatota","hicap","hicap_nonzero")
replace output_grp_lvl_3 = "T+1: Income and assets" if inlist(target,"any_iearn_nl","any_iearn_ue","hatota","hicap","hicap_nonzero")

replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"lniearn_ft","lniearn_nl","lniearn_pt","lniearn_ue","wlth_nonzero")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"lniearn_ft","lniearn_nl","lniearn_pt","lniearn_ue","wlth_nonzero")
replace output_grp_lvl_3 = "T+1: Income and assets" if inlist(target,"lniearn_ft","lniearn_nl","lniearn_pt","lniearn_ue","wlth_nonzero")



*** Public program participation (DI, SS, SSI, igxfr)
* "diclaim","igxfr_nonzero","ssclaim","ssiclaim","oasiclaim"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"diclaim","igxfr_nonzero","ssclaim","ssiclaim","oasiclaim")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"diclaim","igxfr_nonzero","ssclaim","ssiclaim","oasiclaim")
replace output_grp_lvl_3 = "T+1: Public program participation" if inlist(target,"diclaim","igxfr_nonzero","ssclaim","ssiclaim","oasiclaim")
*** Health insurance
* "inscat"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"inscat")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"inscat")
replace output_grp_lvl_3 = "T+1: Health insurance" if inlist(target,"inscat")
* Transitioned
** Life events (births, relationship change/new, become widow)
* "births","cohab2married_f","cohab2married_m","exitcohab_f","exitcohab_m","exitmarried_f","exitmarried_m","exitsingle_f","exitsingle_m","married2cohab_f","married2cohab_m","partdied","paternity","single2married_f","single2married_m"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"births","cohab2married_f","cohab2married_m","exitcohab_f","exitcohab_m","exitmarried_f","exitmarried_m","exitsingle_f","exitsingle_m")
replace output_grp_lvl_2 = "T+1: Life events" if inlist(target,"births","cohab2married_f","cohab2married_m","exitcohab_f","exitcohab_m","exitmarried_f","exitmarried_m","exitsingle_f","exitsingle_m")

replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"married2cohab_f","married2cohab_m","partdied","paternity","single2married_f","single2married_m")
replace output_grp_lvl_2 = "T+1: Life events" if inlist(target,"married2cohab_f","married2cohab_m","partdied","paternity","single2married_f","single2married_m")

* Contemporaneous
**Medical cost and use
*** Total expenditures
* "totmd_mcbs","totmd_meps"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"totmd_mcbs","totmd_meps")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"totmd_mcbs","totmd_meps")
replace output_grp_lvl_3 = "T: Total expenditures" if inlist(target,"totmd_mcbs","totmd_meps")
*** Medicare
* "mcare","mcare_pta","mcare_ptb"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"mcare","mcare_pta","mcare_ptb")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"mcare","mcare_pta","mcare_ptb")
replace output_grp_lvl_3 = "T: Medicare" if inlist(target,"mcare","mcare_pta","mcare_ptb")
*** Medicaid
* "medicaid_elig","caidmd_mcbs","caidmd_meps"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"medicaid_elig","caidmd_mcbs","caidmd_meps")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"medicaid_elig","caidmd_mcbs","caidmd_meps")
replace output_grp_lvl_3 = "T: Medicaid" if inlist(target,"medicaid_elig","caidmd_mcbs","caidmd_meps")
*** Individual
* "anyrx_meps","rxexp_meps","oopmd_mcbs","oopmd_meps"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"anyrx_meps","rxexp_meps","oopmd_mcbs","oopmd_meps")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"anyrx_meps","rxexp_meps","oopmd_mcbs","oopmd_meps")
replace output_grp_lvl_3 = "T: Individual" if inlist(target,"anyrx_meps","rxexp_meps","oopmd_mcbs","oopmd_meps")
*** Utilization
* "doctim","hspnit","hsptim"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"doctim","hspnit","hsptim")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"doctim","hspnit","hsptim")
replace output_grp_lvl_3 = "T: Utilization" if inlist(target,"doctim","hspnit","hsptim")

* Contemporaneous
** Government Transfers (DI, SSI, OASI, igxfr)
* "igxfr","ssdiamt","ssiamt","oasiamt"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"igxfr","ssdiamt","ssiamt","oasiamt")
replace output_grp_lvl_2 = "T: Government transfers" if inlist(target,"igxfr","ssdiamt","ssiamt","oasiamt")

* Contemporaneous
** Taxes paid (federal, state)
* "fu_fiitax_ind","fu_siitax_ind"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"fu_fiitax_ind","fu_siitax_ind")
replace output_grp_lvl_2 = "T: Taxes paid" if inlist(target,"fu_fiitax_ind","fu_siitax_ind")

* Contemporaneous
** Subjective wellbeing (qaly, satisfaction, srh)
* "qaly","satisfaction","srh"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"qaly","satisfaction","srh")
replace output_grp_lvl_2 = "T: Subjective well-being" if inlist(target,"qaly","satisfaction","srh")

* Contemporaneous
** Workforce absenteeism (any missed work, days missed)


*** FEM adds *** 
* Chronic health
* "alzhe","chfe"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"alzhe","chfe")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"alzhe","chfe")
replace output_grp_lvl_3 = "T+1: Chronic conditions" if inlist(target,"alzhe","chfe")

* private health insurance
* "anyhi"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"anyhi")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"anyhi")
replace output_grp_lvl_3 = "T+1: Health insurance" if inlist(target,"anyhi")

* Any Rx
* "anyrx_mcbs","anyrx_mcbs_di"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"anyrx_mcbs","anyrx_mcbs_di")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"anyrx_mcbs","anyrx_mcbs_di")
replace output_grp_lvl_3 = "T: Individual" if inlist(target,"anyrx_meps","anyrx_mcbs","anyrx_mcbs_di")


* Diabetes-related outcomes
* "bpcontrol","diabkidney","insulin"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"bpcontrol","diabkidney","insulin")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"bpcontrol","diabkidney","insulin")
replace output_grp_lvl_3 = "T+1: Diabetes-related outcomes" if inlist(target,"bpcontrol","diabkidney","insulin")


* Cognition
* "cogstate","memrye"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"cogstate","memrye")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"cogstate","memrye")
replace output_grp_lvl_3 = "T+1: Cognition" if inlist(target,"cogstate","memrye")


* Private pension
* "dbclaim"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"dbclaim")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"dbclaim")
replace output_grp_lvl_3 = "T+1: Private program participation" if inlist(target,"dbclaim")

* Depressive symptoms
* "deprsymp"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"deprsymp")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"deprsymp")
replace output_grp_lvl_3 = "T+1: Mental distress" if inlist(target,"deprsymp")


* Transfers
* "gkcarehrs","parhelphours","volhours","helphoursyr","helphoursyr_nonsp","helphoursyr_sp","ihs_tcamt_cpl","tcamt_cpl"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"gkcarehrs","parhelphours","volhours","helphoursyr","helphoursyr_nonsp","helphoursyr_sp","ihs_tcamt_cpl","tcamt_cpl")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"gkcarehrs","parhelphours","volhours","helphoursyr","helphoursyr_nonsp","helphoursyr_sp","ihs_tcamt_cpl","tcamt_cpl")
replace output_grp_lvl_3 = "T+1: Transfers" if inlist(target,"gkcarehrs","parhelphours","volhours","helphoursyr","helphoursyr_nonsp","helphoursyr_sp","ihs_tcamt_cpl","tcamt_cpl")


* heart attack
* "hearta"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"hearta")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"hearta")
replace output_grp_lvl_3 = "T+1: Health event" if inlist(target,"hearta")

* Earnings
* "iearn","iearnuc"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"iearn","iearnuc")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"iearn","iearnuc")
replace output_grp_lvl_3 = "T+1: Income and assets" if inlist(target,"iearn","iearnuc")


* Lung disease related
* "lungoxy"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"lungoxy")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"lungoxy")
replace output_grp_lvl_3 = "T+1: Diabetes-related outcomes" if inlist(target,"lungoxy")

* Medicare
* "mcare_pta_enroll","mcare_ptb_enroll","mcare_ptd","mcare_ptd_enroll"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"mcare_pta_enroll","mcare_ptb_enroll","mcare_ptd","mcare_ptd_enroll")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"mcare_pta_enroll","mcare_ptb_enroll","mcare_ptd","mcare_ptd_enroll")
replace output_grp_lvl_3 = "T: Medicare" if inlist(target,"mcare_pta_enroll","mcare_ptb_enroll","mcare_ptd","mcare_ptd_enroll")

* Nursing home, pain
* "nhmliv","painstat"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"nhmliv","painstat")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"nhmliv","painstat")
replace output_grp_lvl_3 = "T+1: Functional limitations" if inlist(target,"nhmliv","painstat")

* Government payments
* "proptax","proptax_nonzero"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"proptax","proptax_nonzero")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"proptax","proptax_nonzero")
replace output_grp_lvl_3 = "T+1: Taxes" if inlist(target,"proptax","proptax_nonzero")

* Drugs
* "rxexp_mcbs","rxexp_mcbs_di"
replace output_grp_lvl_1 = "T: Contemporaneous" if inlist(target,"rxexp_mcbs","rxexp_mcbs_di")
replace output_grp_lvl_2 = "T: Medical cost and use" if inlist(target,"rxexp_mcbs","rxexp_mcbs_di")
replace output_grp_lvl_3 = "T: Individual" if inlist(target,"rxexp_mcbs","rxexp_mcbs_di")

* Smoking 
* "smkstat"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"smkstat")
replace output_grp_lvl_2 = "T+1: Health status" if inlist(target,"smkstat")
replace output_grp_lvl_3 = "T+1: Risk factors" if inlist(target,"smkstat")

* Working
* "work"
replace output_grp_lvl_1 = "T+1: Transitioned" if inlist(target,"work")
replace output_grp_lvl_2 = "T+1: Economic status" if inlist(target,"work")
replace output_grp_lvl_3 = "T+1: Employment status" if inlist(target,"work")


tab target if missing(output_grp_lvl_1)



tab output_grp_lvl_1
tab output_grp_lvl_2
tab output_grp_lvl_3

gen str outcome = ""

replace outcome = "T+1: ADL" if target == "adlstat"
replace outcome = "T+1: Any earnings" if target == "any_iearn_nl"
replace outcome = "T+1: Any earnings" if target == "any_iearn_ue"
replace outcome = "T+1: Exercise" if target == "anyexercise"
replace outcome = "T: Any Rx" if target == "anyrx_meps"
replace outcome = "T+1: Children" if target == "births"
replace outcome = "T: Medicaid expenditures" if target == "caidmd_mcbs"
replace outcome = "T: Medicaid expenditures" if target == "caidmd_meps"
replace outcome = "T+1: Cancer" if target == "cancre"
replace outcome = "T+1: Relationship status" if target == "cohab2married_f"
replace outcome = "T+1: Relationship status" if target == "cohab2married_m"
replace outcome = "T+1: Diabetes" if target == "diabe"
replace outcome = "T+1: Disability" if target == "diclaim"
replace outcome = "T+1: Died" if target == "died"
replace outcome = "T: Doctors visits" if target == "doctim"
replace outcome = "T+1: Relationship status" if target == "exitcohab_f"
replace outcome = "T+1: Relationship status" if target == "exitcohab_m"
replace outcome = "T+1: Relationship status" if target == "exitmarried_f"
replace outcome = "T+1: Relationship status" if target == "exitmarried_m"
replace outcome = "T+1: Relationship status" if target == "exitsingle_f"
replace outcome = "T+1: Relationship status" if target == "exitsingle_m"
replace outcome = "T: Federal taxes" if target == "fu_fiitax_ind"
replace outcome = "T: State taxes" if target == "fu_siitax_ind"
replace outcome = "T+1: Full or part-time" if target == "fullparttime"
replace outcome = "T+1: Wealth" if target == "hatota"
replace outcome = "T+1: Heart Disease" if target == "hearte"
replace outcome = "T+1: Hypertension" if target == "hibpe"
replace outcome = "T+1: Capital income" if target == "hicap"
replace outcome = "T+1: Any capital income" if target == "hicap_nonzero"
replace outcome = "T: Hospital nights" if target == "hspnit"
replace outcome = "T: Hospital encounters" if target == "hsptim"
replace outcome = "T+1: IADL" if target == "iadlstat"
replace outcome = "T+1: Other government transfers" if target == "igxfr"
replace outcome = "T+1: Any other government transfers" if target == "igxfr_nonzero"
replace outcome = "T+1: Health insurance type" if target == "inscat"
replace outcome = "T+1: Kessler 6" if target == "k6score"
replace outcome = "T+1: Labor force status" if target == "laborforcestat"
replace outcome = "T+1: Earnings" if target == "lniearn_ft"
replace outcome = "T+1: Earnings" if target == "lniearn_nl"
replace outcome = "T+1: Earnings" if target == "lniearn_pt"
replace outcome = "T+1: Earnings" if target == "lniearn_ue"
replace outcome = "T+1: BMI" if target == "logbmi"
replace outcome = "T+1: Lung disease" if target == "lunge"
replace outcome = "T+1: Relationship status" if target == "married2cohab_f"
replace outcome = "T+1: Relationship status" if target == "married2cohab_m"
replace outcome = "T: Medicare expenditures" if target == "mcare"
replace outcome = "T: Medicare part A expenditures" if target == "mcare_pta"
replace outcome = "T: Medicare part B expenditures" if target == "mcare_ptb"
replace outcome = "T: Medicaid eligibility" if target == "medicaid_elig"
replace outcome = "T: Out of pocket expenditures" if target == "oopmd_mcbs"
replace outcome = "T: Out of pocket expenditures" if target == "oopmd_meps"
replace outcome = "T+1: Partner died" if target == "partdied"
replace outcome = "T+1: Children" if target == "paternity"
replace outcome = "T: QALY" if target == "qaly"
replace outcome = "T: Rx expenditures" if target == "rxexp_meps"
replace outcome = "T: Life satisfaction" if target == "satisfaction"
replace outcome = "T+1: Relationship status" if target == "single2married_f"
replace outcome = "T+1: Relationship status" if target == "single2married_m"
replace outcome = "T+1: Start smoking" if target == "smoke_start"
replace outcome = "T+1: Stop smoking" if target == "smoke_stop"
replace outcome = "T: Self-reported health" if target == "srh"
replace outcome = "T+1: SS claiming" if target == "ssclaim"
replace outcome = "T: SSDI amount" if target == "ssdiamt"
replace outcome = "T: SSI amount" if target == "ssiamt"
replace outcome = "T+1: SSI claiming" if target == "ssiclaim"
replace outcome = "T+1: Stroke" if target == "stroke"
replace outcome = "T: Total medical expenditures" if target == "totmd_mcbs"
replace outcome = "T: Total medical expenditures" if target == "totmd_meps"
replace outcome = "T+1: Any wealth" if target == "wlth_nonzero"
replace outcome = "T+1: Alzheimer's disease" if target == "alzhe"
replace outcome = "T+1: Private health insurance" if target == "anyhi"
replace outcome = "T: Any Rx" if target == "anyrx_mcbs"
replace outcome = "T: Any Rx" if target == "anyrx_mcbs_di"
replace outcome = "T+1: Blood pressure controlled" if target == "bpcontrol"
replace outcome = "T+1: Congestive heart failure" if target == "chfe"
replace outcome = "T+1: Cognitive ability" if target == "cogstate"
replace outcome = "T+1: Claiming DB pension" if target == "dbclaim"
replace outcome = "T+1: Depressive symptoms" if target == "deprsymp"
replace outcome = "T+1: Diabetes with kidney problems" if target == "diabkidney"
replace outcome = "T+1: Grandchild care hours" if target == "gkcarehrs"
replace outcome = "T+1: Heart attack" if target == "hearta"
replace outcome = "T+1: Help hours" if target == "helphoursyr"
replace outcome = "T+1: Help hours - nonspouse" if target == "helphoursyr_nonsp"
replace outcome = "T+1: Help hours - spouse" if target == "helphoursyr_sp"
replace outcome = "T+1: Earnings" if target == "iearn"
replace outcome = "T+1: Earnings" if target == "iearnuc"
replace outcome = "T+1: Financial transfers" if target == "ihs_tcamt_cpl"
replace outcome = "T+1: Diabetes with insulin" if target == "insulin"
replace outcome = "T+1: Lung disease with oxygen use" if target == "lungoxy"
replace outcome = "T: Medicare part A enrolled" if target == "mcare_pta_enroll"
replace outcome = "T: Medicare part B enrolled" if target == "mcare_ptb_enroll"
replace outcome = "T: Medicare part D amount" if target == "mcare_ptd"
replace outcome = "T: Medicare part D enrolled" if target == "mcare_ptd_enroll"
replace outcome = "T+1: Memory-related diseases" if target == "memrye"
replace outcome = "T+1: Nursing home residence" if target == "nhmliv"
replace outcome = "T+1: Level of pain" if target == "painstat"
replace outcome = "T+1: Parent help hours" if target == "parhelphours"
replace outcome = "T+1: Property tax amount" if target == "proptax"
replace outcome = "T+1: Property tax non-zero" if target == "proptax_nonzero"
replace outcome = "T: Rx amount" if target == "rxexp_mcbs"
replace outcome = "T: Rx amount" if target == "rxexp_mcbs_di"
replace outcome = "T+1: Smoking status" if target == "smkstat"
replace outcome = "T+1: Financial transfers" if target == "tcamt_cpl"
replace outcome = "T+1: Volunteer hours" if target == "volhours"
replace outcome = "T+1: Working for pay" if target == "work"
replace outcome = "T+1: Claiming OASI" if target == "oasiclaim"
replace outcome = "T+1: OASI amount" if target == "ssoasiamt"


levelsof target if missing(outcome), local(outcome_missing)
local outcome_missing_cnt : word count `outcome_missing'
if `outcome_missing_cnt' > 0 {
	forvalues x = 1/`outcome_missing_cnt' {
		local tgt : word `x' of `outcome_missing'
		di as txt "Warning: `tgt' is not assigned an OUTCOME group"
	}
}

tab outcome if missing(output_grp_lvl_1)

tab target if missing(output_grp_lvl_1)

rename concept predictor

#d ;
order predictor input_grp_lvl_1 input_grp_lvl_2 input_grp_lvl_3
			outcome 	output_grp_lvl_1 output_grp_lvl_2 output_grp_lvl_3
			;
			
#d cr

save `edges_nodes_file', replace

capture log close
