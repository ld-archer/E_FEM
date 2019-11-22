/** \file nhis_main.do This is the main file for extracting the NHIS trends.

\date Nov 13, 2005

	NHIS data is used to generate weight matrix for the incoming cohort over years 
	DEC 12, 2005: consider under-weight, but found that under-weight in aged 55 about 3% 
	and descreased to 0 after 24 years, consider remove under-weight

\date Oct 4, 2006

Updated.

\todo Divide this file in to components with the Makefile

\ Modifying for FAM use - need to have trends for 25 year olds.

*/


  
* Set the parameter for mortality improvement

include "../../../fem_env.do"
set more off
set mem 3000M
set maxvar 10000

***
*** The following do files should be run sequentially
***
global firstyear = 1997
global lastyear  = 2009

***
*** Selected variables from year 1997-2009
***

do FAM_nhis97plus_rcd.do
  
  

	
***
*** Smooth age-specific prevalence rates for risk factors AND diseases from 1997-2009
***
	global outcome "cancre diabe hearte hibpe lunge stroke"
	global poutcome "pcancre pdiabe phearte phibpe plunge pstroke"
	
	do FAM_smoothprevalence.do

  
***
*** Predict prevalence of risk factors and diseases for the aged 51-52 using synthetic cohort approach and 1997-2005
***
	
	do FAM_prediction_synthetic.do

exit, clear STATA
