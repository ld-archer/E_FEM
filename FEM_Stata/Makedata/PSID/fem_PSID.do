clear all
set more off
set mem 800m
set mat 1000

include "../../../fem_env.do"

* Define paths
global workdir "$local_path/Makedata/HRS"
use "$indata/fem1", clear

gen fam_id03=ER33701
gen ind_id03=ER33702
gen fam_id05=ER33801
gen ind_id05=ER33802
gen fam_id07=ER33901
gen ind_id07=ER33902

for var fam_id*: label var X "family ID number"
for var ind_id*: label var X "individual ID number"

*Weighting
gen family_wgt03=ER24179
gen ind_wgt03=ER33740
gen family_wgt05=ER28078
gen ind_wgt05=ER33848
gen family_wgt07=ER41069
gen ind_wgt07=ER33950

for var family_wgt*: label var X "PSID weights, family-level"
for var ind_wgt*: label var X "PSID weights, indiv-level"

gen head03=(ER33703==10)
gen wife03=(ER33703>19 & ER33703<30)
gen head05=(ER33803==10)
gen wife05=(ER33803>19 & ER33803<30)
gen head07=(ER33903==10)
gen wife07=(ER33903>19 & ER33903<30)

gen male03=(ER21018==1)*(head03==1)+(ER21018==0)*(wife03==1)
gen male05=(ER25018==1)*(head05==1)+(ER25018==0)*(wife05==1)
gen male07=(ER36018==1)*(head07==1)+(ER36018==0)*(wife07==1)

gen widow03=(ER21023==3)*(head03==1)
gen widow05=(ER25023==3)*(head05==1)
gen widow07=(ER36023==3)*(head07==1)

gen single03=(ER21023>1 & ER21023<8)*(head03==1)
gen single05=(ER25023>1 & ER25023<8)*(head05==1)
gen single07=(ER36023>1 & ER36023<8)*(head07==1)

gen black03=(ER23334==2)*(wife03==1)+(ER23426==2)*(head03==1)
gen hispanic03=(ER23334==5)*(wife03==1)+(ER23426==5)*(head03==1)
gen black05=(ER27297==2)*(wife05==1)+(ER27393==2)*(head05==1)
gen hispanic05=(ER27296>0 & ER27296<8)*(wife05==1)+(ER27392>0 & ER27392<8)*(head05==1)
gen black07=(ER40472==2)*(wife07==1)+(ER40565==2)*(head07==1)
gen hispanic07=(ER40471>0 & ER40471<8)*(wife07==1)+(ER40564>0 & ER40564<8)*(head07==1)

gen white03=(ER23334==1)*(wife03==1)+(ER23426==1)*(head03==1)
gen native03=(ER23334==3)*(wife03==1)+(ER23426==3)*(head03==1)
gen asian03=(ER23334==4)*(wife03==1)+(ER23426==4)*(head03==1)
gen hawaii03=(ER23334==5)*(wife03==1)+(ER23426==5)*(head03==1)
gen white05=(ER27297==1)*(wife05==1)+(ER27393==1)*(head05==1)
gen native05=(ER27297==3)*(wife05==1)+(ER27393==3)*(head05==1)
gen asian05=(ER27297==4)*(wife05==1)+(ER27393==4)*(head05==1)
gen hawaii05=(ER27297==5)*(wife05==1)+(ER27393==5)*(head05==1)
gen white07=(ER40472==1)*(wife07==1)+(ER40565==1)*(head07==1)
gen native07=(ER40472==3)*(wife07==1)+(ER40565==3)*(head07==1)
gen asian07=(ER40472==4)*(wife07==1)+(ER40565==4)*(head07==1)
gen hawaii07=(ER40472==5)*(wife07==1)+(ER40565==5)*(head07==1)

gen cancer03=(ER23035==1)*(head03==1)+(ER23162==1)*(wife03==1)
gen cancer05=(ER27038==1)*(head05==1)+(ER27161==1)*(wife05==1)
gen cancer07=(ER38249==1)*(head07==1)+(ER39346==1)*(wife07==1)

gen hypertension03=(ER23023==1)*(head03==1)+(ER23150==1)*(wife03==1)
gen hypertension05=(ER27010==1)*(head05==1)+(ER27133==1)*(wife05==1)
gen hypertension07=(ER38221==1)*(head07==1)+(ER39318==1)*(wife07==1)

gen diabetes03=(ER23029==1)*(head03==1)+(ER23156==1)*(wife03==1)
gen diabetes05=(ER27022==1)*(head05==1)+(ER27145==1)*(wife05==1)
gen diabetes07=(ER38233==1)*(head07==1)+(ER39330==1)*(wife07==1)

gen lungdisease03=(ER23041==1)*(head03==1)+(ER23168==1)*(wife03==1)
gen lungdisease05=(ER27018==1)*(head05==1)+(ER27141==1)*(wife05==1)
gen lungdisease07=(ER38229==1)*(head07==1)+(ER39326==1)*(wife07==1)

gen stroke03=(ER23017==1)*(head03==1)+(ER23144==1)*(wife03==1)
gen stroke05=(ER26998==1)*(head05==1)+(ER27121==1)*(wife05==1)
gen stroke07=(ER38209==1)*(head07==1)+(ER39306==1)*(wife07==1)

gen heartdisease03=(ER23053==1)*(head03==1)+(ER23180==1)*(wife03==1)
gen heartdisease05=(ER27006==1)*(head05==1)+(ER27129==1)*(wife05==1)
gen heartdisease07=(ER38217==1)*(head07==1)+(ER39314==1)*(wife07==1)


*difficulties with...
gen bathing03=(ER23092==1)*(head03==1)+(ER23219==1)*(wife03==1)
gen dressing03=(ER23094==1)*(head03==1)+(ER23221==1)*(wife03==1)
gen eating03=(ER23096==1)*(head03==1)+(ER23223==1)*(wife03==1)
gen gettingup03=(ER23098==1)*(head03==1)+(ER23225==1)*(wife03==1)
gen walking03=(ER23100==1)*(head03==1)+(ER23227==1)*(wife03==1)
gen gettingout03=(ER23102==1)*(head03==1)+(ER23229==1)*(wife03==1)
gen toilet03=(ER23104==1)*(head03==1)+(ER23231==1)*(wife03==1)
gen cook03=(ER23106==1)*(head03==1)+(ER23233==1)*(wife03==1)
gen shop03=(ER23108==1)*(head03==1)+(ER23235==1)*(wife03==1)
gen money03=(ER23110==1)*(head03==1)+(ER23237==1)*(wife03==1)
gen phone03=(ER23112==1)*(head03==1)+(ER23239==1)*(wife03==1)
gen housework03=(ER23114==1)*(head03==1)+(ER23239==1)*(wife03==1)
gen lighthousework03=(ER23116==1)*(head03==1)+(ER23241==1)*(wife03==1)

gen bathing05=(ER27059==1)*(head05==1)+(ER27182==1)*(wife05==1)
gen dressing05=(ER27062==1)*(head05==1)+(ER27185==1)*(wife05==1)
gen eating05=(ER27065==1)*(head05==1)+(ER27188==1)*(wife05==1)
gen gettingup05=(ER27068==1)*(head05==1)+(ER27191==1)*(wife05==1)
gen walking05=(ER27071==1)*(head05==1)+(ER27194==1)*(wife05==1)
gen gettingout05=(ER27074==1)*(head05==1)+(ER27197==1)*(wife05==1)
gen toilet05=(ER27077==1)*(head05==1)+(ER27200==1)*(wife05==1)
gen cook05=(ER27080==1)*(head05==1)+(ER27203==1)*(wife05==1)
gen shop05=(ER27082==1)*(head05==1)+(ER27205==1)*(wife05==1)
gen money05=(ER27084==1)*(head05==1)+(ER27207==1)*(wife05==1)
gen phone05=(ER27086==1)*(head05==1)+(ER27209==1)*(wife05==1)
gen housework05=(ER27088==1)*(head05==1)+(ER27211==1)*(wife05==1)
gen lighthousework05=(ER27090==1)*(head05==1)+(ER27213==1)*(wife05==1)

gen bathing07=(ER38270==1)*(head07==1)+(ER39367==1)*(wife07==1)
gen dressing07=(ER38273==1)*(head07==1)+(ER39370==1)*(wife07==1)
gen eating07=(ER38276==1)*(head07==1)+(ER39373==1)*(wife07==1)
gen gettingup07=(ER38279==1)*(head07==1)+(ER39376==1)*(wife07==1)
gen walking07=(ER38282==1)*(head07==1)+(ER39379==1)*(wife07==1)
gen gettingout07=(ER38285==1)*(head07==1)+(ER39382==1)*(wife07==1)
gen toilet07=(ER38288==1)*(head07==1)+(ER39385==1)*(wife07==1)
gen cook07=(ER38291==1)*(head07==1)+(ER39388==1)*(wife07==1)
gen shop07=(ER38293==1)*(head07==1)+(ER39390==1)*(wife07==1)
gen money07=(ER38295==1)*(head07==1)+(ER39392==1)*(wife07==1)
gen phone07=(ER38297==1)*(head07==1)+(ER39394==1)*(wife07==1)
gen housework07=(ER38299==1)*(head07==1)+(ER39396==1)*(wife07==1)
gen lighthousework07=(ER38301==1)*(head07==1)+(ER39398==1)*(wife07==1)
for var bathing03-lighthousework07: label var X "difficulties with..."

*gen adl05=bathing05+dressing05+eating05+gettingout05+gettingup05+walking05+toilet05+cook05+shop05+money05+phone05+housework05+lighthousework05

*Medical Expends
gen medicalexpends03=ER23297
gen medicalexpends05=ER27257
gen medicalexpends07=ER40432
for var medicalexpends*: replace X=. if X>=99999998
for var medicalexpends*: label var X "total cost of all medical care in previous 2 years (t-1, t-2)"

gen smoke03=(ER23123==1)*(head03==1)+(ER23250==1)*(wife03==1)
gen eversmoke03=(ER23126==1)*(head03==1)+(ER23253==1)*(wife03==1)
gen smoke05=(ER27098==1)*(head05==1)+(ER27101==1)*(wife05==1)
gen eversmoke05=(ER27221==1)*(head05==1)+(ER27224==1)*(wife05==1)
gen smoke07=(ER38309==1)*(head07==1)+(ER39406==1)*(wife07==1)
gen eversmoke07=(ER38312==1)*(head07==1)+(ER39409==1)*(wife07==1)

gen age03=ER33704
gen age05=ER33804
gen age07=ER33904

gen educ03=ER33716
gen educ05=ER33817
gen educ07=ER33917

*equal to 1 if health poor or fair
gen hlthstatus03=(ER23009==4 | ER23009==5)*(head03==1)+(ER23136==4 | ER23136==5)*(wife03==1)
gen hlthstatus05=(ER26990==4 | ER26990==5)*(head05==1)+(ER27113==4 | ER27113==5)*(wife05==1)
gen hlthstatus07=(ER38202==4 | ER38202==5)*(head07==1)+(ER39299==4 | ER39299==5)*(wife07==1)
for var hlthstatu*: label var X "poor or fair health"

for var ER23133 ER27110 ER27233 ER23260 ER38321 ER39418: replace X=. if X<2 | X>7
for var ER23134 ER23261 ER27234 ER27111 ER38322 ER39419: replace X=. if X>11
gen height03=(ER23133*12+ER23134)*(head03==1)+(ER23260*12+ER23261)*(wife03==1)
gen height05=(ER27110*12+ER27111)*(head05==1)+(ER27233*12+ER27234)*(wife05==1)
gen height07=(ER38321*12+ER38322)*(head07==1)+(ER39418*12+ER39419)*(wife07==1)

gen weight03=(ER23132)*(head03==1)+(ER23259)*(wife03==1)
replace weight03=. if weight03<50 | weight03>900
gen weight05=(ER27109)*(head05==1)+(ER27232)*(wife05==1)
*max weight05 is 400
replace weight05=. if weight05<50 | weight05>900
gen weight07=(ER38320)*(head07==1)+(ER39417)*(wife07==1)
*max weight07 is 400
replace weight07=. if weight07<50 | weight07>900

for var weight*: label var X "in pounds"
for var height*: label var X "in inches"

for num 3 5 7: gen bmi0X=(weight0X*703)/(height0X^2)
/*
*how define single?
gen widow03=(ER21023==3)
gen single03=(ER21023~=1)
gen widow05=(ER25023==3)
gen single05=(ER25023~=1)
gen widow07=(ER36023==3)
gen single07=(ER36023~=1)
*/

*labor
gen laborincome03=ER24116*(head03==1)+ER24135*(wife03==1)
gen laborincome05=ER27931*(head05==1)+ER27943*(wife05==1)
gen laborincome07=ER40921*(head07==1)+ER40933*(wife07==1)
for var laborincome*: label var X "labor income in previous year"

for num 3 5 7: gen positive_earnings0X=(laborincome0X>0 & laborincome0X<.)
for var positive_earnings*: label var X "laborincome > 0"

gen yearsworked03=ER23384*(wife03==1)+ER23476*(head03==1)
gen yearsworkedft03=ER23385*(wife03==1)+ER23477*(head03==1)
gen yearsworked05=ER27348*(wife05==1)+ER27444*(head05==1)
gen yearsworkedft05=ER27349*(wife05==1)+ER27445*(head05==1)
gen yearsworked07=ER40523*(wife07==1)+ER40616*(head07==1)
gen yearsworkedft07=ER40524*(wife07==1)+ER40617*(head07==1)

for var yearsworked*: replace X=. if X==99
for var yearsworked0*: label var X "years worked since 18"
for var yearsworkedft*: label var X "years worked FT since 18"

*Wealth
gen wealth1_03=S616
gen wealth2_03=S617
gen wealth1_05=S716
gen wealth2_05=S717
gen wealth1_07=S816
gen wealth2_07=S817

for var wealth1_*: label var X "not including main home equity"
for var wealth2_*: label var X "including main home equity"

*pensions
gen db03=(ER22738==1 | ER22738==3)*(head03==1)+(ER22882==1 | ER22882==3)*(wife03==1)
gen dc03=(ER22738==5 | ER22738==3)*(head03==1)+(ER22882==5 | ER22882==3)*(wife03==1)
*only include current job's DC plans, though amts in past job's DC plans available
gen dcamt03=ER22744 if head03==1
replace dcamt03=. if ER22744>999999997
replace dcamt03=ER22888 if wife03==1
replace dcamt03=. if ER22888>999999997 & wife03==1
gen db05=(ER26719==1 | ER26719==3)*(head05==1)+(ER26863==1 | ER26863==3)*(wife05==1)
gen dc05=(ER26719==5 | ER26719==3)*(head05==1)+(ER26863==5 | ER26863==3)*(wife05==1)
gen dcamt05=ER26725 if head05==1
replace dcamt05=. if ER26725>999999997
replace dcamt05=ER26869 if wife05==1
replace dcamt05=. if ER26869>999999997 & wife05==1
gen db07=(ER37755==1 | ER37755==3)*(head07==1)+(ER37987==1 | ER37987==3)*(wife07==1)
gen dc07=(ER37755==5 | ER37755==3)*(head07==1)+(ER37987==5 | ER37987==3)*(wife07==1)
gen dcamt07=ER37761 if head07==1
replace dcamt07=. if ER37761>999999997
replace dcamt07=ER37993 if wife07==1
replace dcamt07=. if ER37993>999999997 & wife07==1

for var dcamt*: label var X "DC amount if account, current job"
for var dc03 dc05 dc07: label var X "DC plan"
for var db03 db05 db07: label var X "DB plan"


keep fam_id03-dcamt07

save "$outdata/PSIDfem.dta", replace
