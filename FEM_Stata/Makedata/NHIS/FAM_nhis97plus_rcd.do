
capture log close
log using nhis9709_rcd.log, replace

use $outdata/nhis97plus.dta, clear
keep if inrange(srvy_yr, $firstyear, $lastyear)

*************************************************************************
*    RECODE HEALTH STATUS AND FUNCTIONING
*	    NHIS 1997 - 2006
*         DEC 12, 2005: recode under-weight
*************************************************************************


label define yesno 0  "0 no", modify
label define yesno 1 "1 yes", modify

******Rename age
ren age_p age
ren srvy_yr year

******Recode health condition and functioning variables*************
  
  gen hibpe = (hypev ==1) if inlist(hypev, 1, 2)
  
  gen chd = (chdev ==1) if inlist(chdev, 1, 2)
  gen ang = (angev ==1) if inlist(angev, 1, 2)
  gen myocar = (miev ==1) if inlist(miev, 1, 2)
  gen othart = (hrtev ==1) if inlist(hrtev, 1, 2)
  gen hearte = (chd ==1|ang==1|myocar==1|othart ==1) 
  replace hearte = . if (chd==. | ang==. | myocar==. | othart==.) & hearte ==0

  gen stroke =(strev ==1) if inlist(strev, 1, 2)

*value 3 of dibev means "borderline"
  gen diabe = (dibev ==1) if inlist(dibev, 1, 2, 3)
  gen diabdr = (dibev ==3) if inlist(dibev, 1, 2, 3)

*Recode lung disease variable
 gen lunge = (cbrchyr==1| ephev ==1)  
 replace lunge=. if (inlist(cbrchyr, 7, 8, 9, .) | inlist(ephev,7,8,9, .)) & lunge ==0
 
  *exclude skin cancer

*subcategories of cancer
  gen skin_ca = (cnkind22 ==1 | cnkind23 ==1)
  replace skin_ca =. if (inlist(cnkind22, 7, 8, 9, .) | inlist(cnkind23, 7, 8, 9, .)) & skin_ca ==0
  gen lunge_ca = (cnkind14 ==1) if inlist(cnkind14, 1, 2)
  gen brest_ca = (cnkind5 ==1) if inlist(cnkind5, 1, 2)
  replace brest_ca = 0 if sex == 1
  gen prost_ca = (cnkind20 ==1) if inlist(cnkind20, 1, 2)
  replace prost_ca = 0 if sex == 2
  gen colon_ca = (cnkind7 ==1) if inlist(cnkind7, 1, 2)
  gen uterus_ca = (cnkind29 ==1) if inlist(cnkind29, 1, 2)
  replace uterus_ca = 0 if sex ==1
  gen  throat_ca = (cnkind27 ==1) if inlist(cnkind27, 1, 2)
  gen blad_ca  = (cnkind1 ==1) if inlist(cnkind1, 1, 2)
  gen kidney_ca = (cnkind10 ==1) if inlist(cnkind10, 1, 2)
  gen brain_ca = (cnkind4 ==1) if inlist(cnkind4, 1, 2)
  gen ovary_ca = (cnkind18 ==1) if inlist(cnkind18, 1, 2)
  gen cervx_ca = (cnkind6 ==1) if inlist(cnkind6, 1, 2)

*cancer in general, excluding skin cancers
  gen cancre =0 if inlist(canev,1,2)
   forvalues i=1(1)21{
             replace cancre=1 if cnkind`i' ==1
                     }
   forvalues i=24(1)30{
             replace cancre=1 if cnkind`i' ==1
                     }
 
  replace cancre = 1 if canev==1 & (cnkind22==2) & (cnkind23 ==2)  & cancre==0

*Other cancers: cancers except lung, colon, breast, uter, prostate, bladder
*Ovary, stomach, cervix, brain, kidney, throat, head, back, skin
  	gen other_ca = 0 if inlist(canev,1,2)
  	foreach var in 2 3 8 9 11 12 13 15 16 17 19 21 24 26 28 30{
        replace other_ca = 1 if cnkind`var' == 1
                          }

	#d;  
		foreach var in  lunge_ca brest_ca prost_ca colon_ca ovary_ca cervx_ca
			uterus_ca throat_ca blad_ca kidney_ca brain_ca other_ca{;
              replace `var' = 0 if cancre ==0;
                     };
	#d cr
	
  label var hibpe "ever told had hypertension"
  label var chd "ever told had coronary heart disease"
  label var ang "ever told had angina"
  label var myocar "ever told had myocardial infarction"
  label var othart "ever told had other heart conditions"
  label var hearte "any heart conditions"
  label var stroke "ever told had a stroke"
  label var lunge "had lung diseases: emphysema or chr.bronchitis"
  label var diabe "ever told had diabetes"
  label var diabdr "diabetes borderline"
  label var cancre "ever told had cancer or malignancy (excl.skin)"
  label var wtfa "weight - final annual: personsx"
  label var wtfa_sa "weight - final annual: sample adult"
  
  *value labels
  foreach var in cancre hearte chd ang myocar othart stroke diabe diabdr hibpe lunge ephev ///
                             skin_ca lunge_ca brest_ca prost_ca colon_ca uterus_ca throat_ca ///
   										blad_ca kidney_ca brain_ca ovary_ca cervx_ca other_ca{
                                     label values `var' yesno
   }
                                            
/* recode the arthritis variable
 gen arthr = (arth ==1) if inlist(arth, 1,2)
 gen arthr1 = (arth1 ==1) if inlist(arth1, 1, 2)
 label var arthr "Ever told had arthritis 1/yes 0/no"
 label var arthr1 "Ever told had arthritis, gout, lupus 1/yes 0/no,"
 label values arthr yesno
 label values arthr1 yesno
*/
  
*Recode the disability variables
  gen lwk = (plawklim==0|plawklim==1) if inlist(plawklim, 0, 1, 2)
  label var lwk "limited in work or unable to work"
 
  gen ssrrdb = (pssrrdb ==1) if inlist(pssrrdb, 1, 2) 
  replace ssrrdb = 0 if pssrr==2
  *In 1997, only SSDI asked
  replace ssrrdb=(pssdi==1)  if inlist(pssdi, 1, 2) & year==1997

  label var ssrrdb "received SSDI or Railroad retirement as disability (last year)"

  gen ssrrd = (pssrrd == 1) if  inlist(pssrrd,1,2)
  replace ssrrd = (sdpdisb==1) if inlist(sdpdisb, 1, 2) & year ==1997
  replace ssrrd = 0 if ssrrdb == 0
  label var ssrrd "Received SS or RR disability benefit because being disabled"
  
	gen ssi = (pssi==1) if inlist(pssi, 1, 2)
  label var ssi "receive inc from SSI "

  gen ssid = (pssid ==1) if inlist(pssid, 1, 2)
  replace ssid=0 if ssi ==0
  label var ssid "rec SSI due to disability" 

  gen ssdissi = (ssrrdb== 1|ssi == 1)
  replace ssdissi=. if (ssrrdb==. | ssi==. ) & ssdissi ==0
  label var ssdissi "rec SS,RR, or SSI dis. benefit "
  
  gen ssdissid = (ssrrd==1 | ssid==1) 
  replace ssdissid=. if (ssrrd==.| ssi==.) & ssdissid ==0
  label var ssdissid "rec SS, RR, or SSI dis. benefit due to dis."

*Recode smoking variables
  gen smokev = (smkev==1) if inlist(smkev,1, 2)
  gen smoken = (smknow==1|smknow==2) if inlist(smknow,1,2,3)
  replace smoken = 0 if smkev ==2
  label var smokev "ever smoke 100 cigarettes"
  label var smoken "smoke now"

*Recode obese and over-weight
  gen obese = (bmi>=30) if bmi!=.
  gen overwt = (bmi>=25 & bmi<30) if bmi!=.
  gen underwt = (bmi<18.5) if bmi!=.

  label var obese "obese (bmi>=30)"
  label var overwt "over-weight, (25<=bmi<30)"
  label var underwt "under-weight:bmi<20"

 foreach var in lwk ssrrdb ssrrd ssi ssid ssdissi ///
                           ssdissid smokev smoken obese overwt{
                                    label values `var' yesno
                                     }
* recode race
gen black = race == 2 if race < .
gen white = race == 1 if race < .

label var black "Black"
recode origin_i (2 = 0 ) (1 = 1) (missing=.), gen(hispanic)
label var hispanic "Hispanic"

* recode education
replace educ_r1 = . if inlist(educ_r1, 97,98,99)

gen hsdrop  = inlist(educ_r1,1,2) if educ_r1 < .
gen hsgrad  = inlist(educ_r1,3,4) if educ_r1 < .
gen somecol = inlist(educ_r1,5,6,7) if educ_r1 < .
gen colgrad = inlist(educ_r1,8,9) if educ_r1 < .
gen college = inlist(educ_r1,5,6,7,8,9) if educ_r1 < .

label var hsdrop "Less than high school"
label var hsgrad "High school graduate"
label var somecol "Some college but no degree"
label var colgrad "College graduate"
label var college "Some college and above"

* Year 2004 and beyond have different education variables
replace educ1 = . if inrange(educ1,96,99)
replace hsdrop = inrange(educ1,0,12) if educ1<. & inrange(year,2004,$lastyear)
replace hsgrad = inlist(educ1,13,14) if educ1<. & inrange(year,2004,$lastyear)
replace somecol = inlist(educ1,15) if educ1<. & inrange(year,2004,$lastyear)
replace colgrad = inrange(educ1,16,21) if educ1<. & inrange(year,2004,$lastyear)
replace college = inrange(educ1,15,21) if educ1<. & inrange(year,2004,$lastyear)

* Drop variables
drop cnkind* *_ca 

* Health insurance variables
* After 1997 we could use the constructed variable of NOTCOV: 1 = not covered 2 = covered 9 = don't know
* In 1997 we need to examine existence of medicare medicaid private ihs military otherpub othergov
gen anyhi = notcov == 2 if inlist(notcov, 1,2) & year >= 1998
replace anyhi = 0 if year == 1997 & private <= 3
foreach v in  medicare medicaid private  ihs military otherpub othergov{
	replace anyhi = 1 if year == 1997 & inlist(`v',1,2)
}
label var anyhi "Any Health insurance coverage"
* Private
gen anyhi_prv = inlist(private,1,2) if private <= 3 
label var anyhi_prv "Any private health insurance coverage"

* Public
gen anyhi_pub = 0 if anyhi < . 
label var anyhi_pub "Medicare/Caid/IHS/Military/Otherpub/Othergov/SCHIP"

foreach v in medicare medicaid ihs military otherpub othergov chip schip {
		replace anyhi_pub = 1 if inlist(`v',1,2)
}

save $outdata/FAM_nhis97plus_selected.dta, replace

*describe the data
 describe

log close
