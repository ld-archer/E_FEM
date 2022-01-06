
#pragma once
#include <string>
namespace Vars
{
  /** This enum lists all the possible variables in the simulation. Details are added using the VarsInfo::VarsInfo constructor.
   */
	enum Vars_t
	{
	  active=0,                       ///< true if the person is active in the simulation
		adl1,                     ///< ADL 1 [0, 1], stored as Boolean
		adl2,                     ///< ADL 2 [0, 1], stored as Boolean
		adl3p,                    ///< ADL 3 or more [0, 1], stored as Boolean
		adlstat,                     ///< ADL status (1=0 ADLS, 2=1 ADL, 3=2 ADLs, 4=3+ ADLs)
		admin_ssi,                ///< SSI Claiming Adjustment, Stored as Double
		afibe,			  ///< Non-valvular AFib [0, 1]
		age,                      ///< Exact age on July 1st, (year - rbyr) + (7-rbmonth)/12, stored as Double
		agec,                     ///< Approx Range [51, 85], stored as Short
		aime_org,                 ///< AIME valued at year of reaching 60 or year 2004,whichever earlier, Approx Range [0.14767, 8433.632], stored as Double
		alzhmr,                   ///< Alzheimer's disase, stored as Boolean
		//alzhe,                   ///< Alzheimer's disase from HRS wave 10 data, stored as Boolean
		anydb,                    ///< Any DB from current job RND VG [0, 1], stored as Boolean
		anydc,                    ///< Any DC from current job RND VG [0, 1], stored as Boolean
		anyexercise,							///< Any phyisical activity, stored as Boolean
		anyhi,                    ///< HI cov -gov/emp/other [0, 1], stored as Boolean
		any_iearn_nl,							/// Any earnings if not in the labor force
		any_iearn_ue,							/// Any earnings if unemployed
		anyrx_mcbs,								///< Any prescriptions from MCBS model
		anyrx_mcbs_di,								///< Any prescriptions for DI recipients from MCBS model
		anyrx_meps,								///< Any prescriptions from MEPS model
		arthre,					///< Arthritis ever, stored as Boolean
		asthmae,				///< Asthma ever, stored as Boolean
		atotb,                  ///< Total Family Wealth
		itot,                    ///< Total Family Income
		births,                   ///< Count of childbirth events (0,1,2), stored as Short
		black,                    ///< Non-Hispanic black [0, 1], stored as Boolean
		bornus,                   ///< Born in the U.S.? [0, 1], stored as Boolean
		bpcontrol,                ///< Blood pressure under control for hibpe
		bs_treated,               ///< Treated with Bariatric Surgery intervention, Boolean
		bweight,                  ///< Approx Range [0, 16153], stored as Double
		caidmd,                   ///< Medicaid cost, adjusted
		caidmd_mcbs,              ///< Medicaid cost estimated using the MCBS dataset, stored as Double
		caidmd_meps,              ///< Medicaid cost estimated using the MEPS dataset, stored as Double
		cancre,                   ///< Cancer [0, 1], stored as Boolean
		catholic,									///< Religion - Catholic
		chfe,											///< Congestive heart failure {0,1}, stored as Boolean
		deprsymp,										///< CESD 5+ depression symptoms
		chldsrh,											///< Self-reported health as a child
		hchole,                      ///< High Cholesterol Ever, stored as Boolean
		clmwv,                    ///< Approx Range [1, 7], stored as Short
		cogstate1,                ///< cogstate 1 [0, 1], stored as Boolean
		cogstate2,                ///< cogstate 2 [0, 1], stored as Boolean
		cogstate3,                ///< cogstate 3 or more [0, 1], stored as Boolean
		cogstate,                 // Cognitive Impairment state, (1, 2, 3) = (Demented, CIND, Normal)
		cohab,						        ///< Marital status - Cohabitating, stored as Boolean
		cohab_cond1,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab_cond2,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab_cond3,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab_cond4,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab_cond5,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab_cond6,						  ///< Marital status - VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		cohab2married_f,					///< female: lag cohab, now married
		cohab2married_m,					///< male: lag cohab, now married
		college,                  ///< Some college and above [0, 1], stored as Boolean
		ctax,                     ///< City Tax, stored as Double
		cum_totmd,                ///< Cumulative Medical Costs, stored as Double
		db_tenure,                ///< Approx Range [-2, 54.5], stored as Double
		dbage,                    ///< Age started claiming pension, stored as Short
		dbclaim,                  ///< Claiming DB [0, 1], stored as Boolean
		dbpen,                    ///< Pension Benefit amount?
		dcwlth,                   ///< Individual DC wlth wv1-5 only in 1000s Approx Range [0, 1250], stored as Short
		dcwlthx,                  ///< Individual DC wlth wv1-5 only in 1000s(=dcwlth) Approx Range [0, 1250], stored as Short
		diabe,                    ///< Diabetes [0, 1], stored as Boolean
		diabkidney,               ///< Has your diabetes caused kidney problems
		diben,                    ///< Amount of DI Benefits
		diclaim,                  ///< Claiming SSDI [0, 1], stored as Boolean
		died,                     ///< Died [0, 1], stored as Boolean
		doctim,                   ///< Times at a doctor Approx Range [0.0182607,80.70206], stored as Double
		drink,						///< Whether drinks alcohol at all, stored asl Boolean
		heavy_drinker,              ///< Heavy Drinker (>14 units/week), stored as Boolean
		freq_drinker,               ///< Frequent Drinker (>5 days/week), stored as Boolean
		problem_drinker,            ///< Problem Drinker (binge/frequent), stored as Boolean
		//drinkd, 					///< How many days per week drinking alcohol, stored as Short
		//drinkwn,					///< Number of drinks per week, stored as Double
		//drinkd1,					///< Drinkd 1 [0, 1], stored as Boolean
		//drinkd2,					///< Drinkd 2 [0, 1], stored as Boolean
		//drinkd3,					///< Drinkd 3 [0, 1], stored as Boolean
		//drinkd4,					///< Drinkd 4 [0, 1], stored as Boolean
		//drinkd_stat,				///< Drinkd Status (1=0 days, 2 = 1/2 days, 3 = 3/4, 4 = 5-7)
		educ,                     ///< Education recoded Approx Range [1, 3], stored as Short
		educlvl,									///< Six-level education variable, all educ vars should derive from this for FAM
		educ_t1, 									///< Transition variable from educlvl1
		educ_t2, 									///< Transition variable from educlvl2
		educ_t3, 									///< Transition variable from educlvl3
		educ_t4, 									///< Transition variable from educlvl4	
		missing_educ,				///< Dummy variable for missing education data		
		educl,						///< Spouses Harmonized Education Level
		ramomeduage,				///< Age mother finished education
		radadeduage,				///< Age father finished education
		entry,                    ///< Year of entry into the model, stored as Short
		era,                      ///< RECODE of rdb_ea_c (RECODE of eage_db (Early ret age for curren... Approx Range [0, 60], stored as Short
		everm,                    ///< Ever married? [0, 1], stored as Boolean
		eversep,                  ///< Ever separated (previous marriage or cohabitation)? [0, 1], stored as Boolean
		exitcohab_f,							///< female: lag cohab, now not cohab
		exitcohab_m,							///< male: lag cohab, now not cohab
		exitmarried_f,						///< female: lag married, now not married
		exitmarried_m,						///< male: lag married, now not married
		exitsingle_f,							///< female: lag single, now not single
		exitsingle_m,							///< male: lag single, now not single
		exurb,										///< Lives in exurbs
	    fanydb,                         ///< Init.of any defined benefit pension plan
		fcanc50,                  ///< Init.of Cancer [0, 1] at age 50, stored as Boolean
		fdiabe50,                   ///< Init.of Diabetes [0, 1] at age 50, stored as Boolean
		fheart50,                  ///< Init.of Heart disease [0, 1] at age 50, stored as Boolean
		fhibp50,                   ///< Init.of Hypertension [0, 1] at age 50, stored as Boolean
		fiearnuc,		     ///< Init. of Uncapped Earnings
		fkids,										///< Number of children in 2004, stored as Float
		flogbmi50,			      ///< Init.of Log(BMI) at age 50, stored as Double
		flogiearnuc, 		     ///< Initial value of log uncapped earnings
		flogiearnx,               ///< Approx Range [0, 0.0599147], stored as Double
		flung50,                   ///< Init.of Lung disease [0, 1] at age 50, stored as Boolean
		fmarried50,                 ///< Init.of Married [0, 1] at age 50, stored as Boolean
		fmcare_pta_premium,       ///< Lag of mcare_pta_premium
		fmcare_ptb_premium,       ///< Init. of mcare_ptb_premium
		fpoor,										///< Poor as a child
		fproptax,									///< Initial of proptax, stored as Double
		fproptax_nonzero,					///< Init of proptax_nonzero, stored as Boolean
		fraime,                   ///< Initial AIME, stored as Double
	    frbyr,
		frich,										///< Rich as a child
		frq,                      ///< Init.of number of quarters earned, stored as Short
		fsingle50,                  ///< Init.of Single [0, 1] at age 50, stored as Boolean
		fsmoken50,                  ///< Init.of Current smoking [0, 1] at age 50, stored as Boolean
		fsmokev,
		fstrok50,                  ///< Init.of Stroke [0, 1] at age 50, stored as Boolean
		ftax,                     ///< Federal Tax, stored as Double
		fthreduc1,									///< Father Education level 1
		fthreduc2,                  ///< Father Education level 2
		fthreduc3,                  ///< Father Education level 3
		fthreduc4,                  ///< Father Education level 4
		fu_fiitax_ind,						///< Federal taxes at family unit, divided between head/wife
		fu_siitax_ind,						///< State taxes at family unit, divided between head/wife
		fullparttime,							///< Part-time (0) or full-time (1)
		fvolhours,								///< Init.of volunteer hours
		fwhtcoll,									///< Longest held occupation - white collar reported in 2004
		fwidowed,                 ///< Init.of Widowed [0, 1], stored as Boolean
		fwidowed50,                 ///< Init.of Widowed [0, 1] at age 50, stored as Boolean
		gkcarehrs,  								///< Grandchild care hours in previous two years
		gross,                    ///< Gross Income, stored as Double
		hacohort,                 ///< hacohort: sample cohort Approx Range [0, 5], stored as Short
		hatota,                   ///< HH wlth in 1000s Approx Range [-2245.5, 74459], stored as Double
		hatotax,                  ///< HH wlth in 1000s if positive-max 2000,zero otherwise Approx Range [-2245.5, 2000], stored as Double
		hearte,                   ///< Heart disease [0, 1], stored as Boolean
		hearta,                   ///< Heart attack since last wave [0,1], stored as Boolean
		heartae,                   ///< Ever had heart attack [0,1], stored as Boolean
		agi,                      ///< Individual Adjusted Gross Income, calculated in GovExpModule
		helphoursyr,							///< Total annual help hours received 
		helphoursyr_sp,						///< Total annual help hours received from spouse
		helphoursyr_nonsp,				///< Total annual help hours received from non-spouse
		help_to_spouse,						///< Help given from respondent to spouse
		hhearn,                   ///< Total household earnings, stored as Double
		hhid,                     ///< Wave specific household ID Approx Range [30, 5027610], stored as Double
		hhidpn,                   ///< R person unique identifier Approx Range [3010, 503000000], stored as Double
		hhttlinc,                 ///< Total household income (just hhearn, stored as Double
		hhwealth,                 ///< hatotax * 1000, stored as Double
		hicap,                   ///< Household Capital Income
		hicap_real,              ///< Household Capital Income (not inflation adjusted)		
		hicap_nonzero,           ///< Household Capital Income not zero
		hibpe,                    ///< Hypertension [0, 1], stored as Boolean
		hipe,                       ///< Hip Fracture Ever, stored as Boolean
		hispan,                   ///< Hispanic [0, 1], stored as Boolean
		hmed,                     ///< Household Medicare tax, stored as Double
		hoasi,                    ///< Household OASI tax, stored as Double
		hsless,                   ///< Less than high school [0, 1], stored as Boolean
		hspnit,                   ///< Number of nights spent at the hospital Approx Range [0.0715097,35.58515], stored as Double
		hsptim,                   ///< Number of inpatient events Approx Range [0.0305709,4.899286], stored as Double
		iadl1,                    ///< IADL 1 [0, 1], stored as Boolean
		iadl2p,                   ///< IADL 2 or more [0, 1], stored as Boolean
		iadlstat,                    ///< IADL Status (1=0 IADLs, 2=1 IADL, 3=2+ IADLs)
		iearn,                    ///< Individual earnings in 1000s Approx Range [0, 646], stored as Short		
		iearn_real,              ///< Individual earnings in 1000s (not inflation adjusted) Approx Range [0, 646], stored as Short
		iearnuc,		     ///< Indiviaul earnings in 1000s, stored as Short
		iearnx,                   ///< Individual earnings in 1000s-max 200 Approx Range [0, 200], stored as Short
		igxfr,                    ///< Misc government transfers
		igxfr_nonzero,            ///< Whehter igxfr is nonzero
		ihs_tcamt_cpl,            ///< IHS of transfers to children
		inlaborforce, 						///< Working for pay or unemployed
		inpatient_ever,                ///< If the person is ever an inpatient
		insamp,                   ///< Approx Range [1, 2], stored as Short
		inscat,										///< Categorical health insurance variable (none, public only, any private)
		insulin,                  ///< Diabetic taking insulin
		internal_id,							///< simulation internal ID, used for debugging
		isret,                    ///< income: R SoCSec Retirment Approx Range [0, 47046.87], stored as Double
		iwbeg,                    ///< R interview begin date Approx Range [16116, 16451], stored as Double
		iwstat,                   ///< R interview status Approx Range [1, 1], stored as Short
		jewish,										///< Religion - Jewish
		kid_byravg,								///< Mean birth year of children
		k6score,									///<K6 score
		k6severe,									///< Kessler 6 score is severe
		laborforcestat,						///< Labor force status 1 = out of labor force, 2 = unemployed, 3 = employed
		l2births,                  ///< Lag of Count of childbirth events (0,1,2), stored as Short
		l2cohab,						        ///< Lag of Cohabitating, stored as Boolean
		l2educlvl, 								///< Lag of educlvl
		l2everm,                   ///< Lag of ever married [0, 1], stored as Boolean		
		l2eversep,                 ///< Lag of ever separated [0, 1], stored as Boolean		
		l2inlaborforce,						///> Lag of in labor force
		l2inscat,									///> Lag of insurance category
		//l2mstat_new,										///< Lag of Marital Status [1,3], stored as Short
        l2mstat,										///< Lag of Marital Status [1,4], stored as Short
		l2numbiokids,              ///< Lag of Number of biological children, stored as Short

		l2adl1,                    ///< Lag of ADL 1, [0, 1], stored as Boolean
		l2adl2,                    ///< Lag of ADL 2, [0, 1], stored as Boolean
		l2adl3p,                   ///< Lag of ADL 3 or more, [0, 1], stored as Boolean
		l2adlstat,                 ///< Lag of number of ADLs
		l2afibe,			    				 ///< Lag of NVAF
		l2age,                     ///< Lag of exact age on July 1st, (year - rbyr) + (7-rbmonth)/12, Stored as Double
		l2alzhmr,                  ///< Lag of Alzheimer's disease, stored as Boolean
		//l2alzhe,                  ///< Lag of Alzheimer's disease from HRS, stored as Boolean
		l2anyexercise,							///< Lag of any physical activity, stored as Boolean
		l2anyhi,                   ///< Lag of HI cov -gov/emp/other, [0, 1], stored as Boolean
		l2arthre,					///< Lag of arthritis ever, stored as Boolean
		l2asthmae,					///< Lag of asthma ever, stored as Boolean
		l2atotb,                    ///< Lag of Total Family Wealth
		l2itot,                      ///< Lag of Total Family Income
		l2bpcontrol,               ///< Lag of bpcontrol
		l2bs_treated,              ///< Lag of treated with bariatric surgery, stored as Boolean
		l2cancre,                  ///< Lag of Cancer, [0, 1], stored as Boolean
		l2chfe,										 ///< Lag of Congestive heart failure {0,1}, stored as Boolean
		l2hchole,                    ///< Lag of High Cholesterol, stored as Boolean
		l2cogstate1,                ///< Lag of cogstate 1 [0, 1], stored as Boolean
		l2cogstate2,                ///< Lag of cogstate 2 [0, 1], stored as Boolean
		l2cogstate3,                ///< Lag of cogstate 3 or more [0, 1], stored as Boolean
		l2cogstate,                // Lag of Cognitive Impairment state, (1, 2, 3) = (Demented, CIND, Normal)
		l2deprsymp,									///< Lag of CESD 5+ depression symptoms, stored as Boolean
		l2dbclaim,                 ///< Lag of Claiming DB, [0, 1], stored as Boolean
		l2diabe,                   ///< Lag of Diabetes, [0, 1], stored as Boolean
		l2diabkidney,              ///< Lag of diabkidney
		l2diclaim,                 ///< Lag of Claiming SSDI, [0, 1], stored as Boolean
		l2died,                    ///< Lag of Died, [0, 1], stored as Boolean
		l2drink,					///< Lag of whether drinks alcohol at all, stored as Boolean
		l2heavy_drinker,            ///< Lag of Heavy Drinker
		l2freq_drinker,             ///< Lag of Frequent Drinker
		l2problem_drinker,          ///< Lag of Problem Drinker
		//l2drinkd,					///< Lag of how many days per week drinking alcohol, stored as Short
		//l2drinkwn,					///< Lag of number of drinks per week, stored as Double
		//l2drinkd1,					///< Lag of drinkd 1 [0, 1], stored as Boolean
		//l2drinkd2,					///< Lag of drinkd 2 [0, 1], stored as Boolean
		//l2drinkd3,					///< Lag of drinkd 3 [0, 1], stored as Boolean
		//l2drinkd4,					///< Lag of drinkd 4 [0, 1], stored as Boolean
		//l2drinkd_stat,				///< Lag of drinkd status
		l2gkcarehrs,								///< Lag of grandkid care hours
		l2hatota,                  ///< Lag of HH wlth in 1000s, Approx Range [-2245.5, 74459], stored as Double
		l2hatotax,                 ///< Lag of HH wlth in 1000s if positive-max 2000,zero otherwise, Approx Range [-2245.5, 2000], stored as Double
		l2hearte,                  ///< Lag of Heart disease, [0, 1], stored as Boolean
		l2hearta,                  ///< Lag of heart attack since last wave, [0, 1], stored as Boolean
		l2heartae,                  ///< Lag of ever had heart attack since last wave, [0, 1], stored as Boolean		    
		l2helphoursyr,							///< Lag of Total annual help hours received 
		l2helphoursyr_sp,					///< Lag of Total annual help hours received from spouse
		l2helphoursyr_nonsp,				///< Lag of Total annual help hours received from non-spouse
		l2hibpe,                   ///< Lag of Hypertension, [0, 1], stored as Boolean
		l2hicap,                   ///< Lag of hicap
		l2hicap_nonzero,           ///< Lag of hicap_nonzero
		l2hipe,                     ///< Lag of Hip Fracture Ever, stored as Boolean
		l2iadl1,                   ///< Lag of IADL 1, [0, 1], stored as Boolean
		l2iadl2p,                  ///< Lag of IADL 2 or more, [0, 1], stored as Boolean
		l2iadlstat,                   ///< Lag of number of IADLs
		l2iearn,                   ///< Lag of Individual earnings in 1000s, Approx Range [0, 646], stored as Short
		l2iearnuc, 		     ///< lag of uncapped individual earnings in 1000s
		l2iearnx,                  ///< Lag of Individual earnings in 1000s-max 200, Approx Range [0, 200], stored as Short
		l2insulin,                 ///< Lag of insulin
		l2iwstat,                  ///< Lag of R interview status, Approx Range [1, 1], stored as Short
		l2k6score, 								///<Lag of Kessler 6 score
		l2k6severe,									///< Lag of Kessler 6 score is severe
		l2logbmi,				  ///< Lag of Log(BMI), stored as Double
		l2loghatota,               ///< Lag of loghatota, Approx Range [-0.0840983, 0.1191115], stored as Double
		l2loghatotax,              ///< Lag of loghatotax, Approx Range [-0.0840983, 0.0829405], stored as Double
		l2logiearn,                ///< Lag of logiearn, Approx Range [0, 0.0716395], stored as Double
		l2logiearnuc,		     ///< Laog of logiearnuc
		l2logiearnx,               ///< Lag of logiearnx, Approx Range [0, 0.0599147], stored as Double
		l2low_tics,                ///< Lag of low_tics, stored as Short
		l2lunge,                   ///< Lag of Lung disease, [0, 1], stored as Boolean
		l2lungoxy,                 ///< Lag of lungoxy
		l2married,                 ///< Lag of Married, [0, 1], stored as Boolean
		l2mcare_pta_enroll,        ///< Lag of Medicare Part A Enrollment
		l2mcare_pta_premium,       ///< Lag of Medicare Part A Premium
		l2mcare_ptb_enroll,        ///< Lag of Medicare Part B Enrollment
		l2mcare_ptb_premium,       ///< Lag of Medicare Part B Premium
		l2medicare_elig,           ///< Lag of Medicare Eligibility
		l2memrye,                  ///< Lag of R memory-related diseases, [0, 1], stored as Boolean
		l2nhmliv,                  ///< Lag of R live in nursingh ome at interview, [0, 1], stored as Boolean
		l2oasiclaim, 							///< Lag of claiming SS OASI benefits in PSID, [0, 1], stored as Boolean
		logbmi,					  				///< Log(BMI), stored as Double
		logdcwlthx,               ///< (IHT of DC wlth in 1000s)/100 if any DC,zero otherwise Approx Range [0, 0.0782405], stored as Double
		loghatota,                ///< Approx Range [-0.0840983, 0.1191115], stored as Double
		loghatotax,               ///< (IHT of hh wlth in 1000s if positive)/100,zero otherwise Approx Range [-0.0840983, 0.0829405], stored as Double
		logiearn,                 ///< Approx Range [0, 0.0716395], stored as Double
		logiearnuc,		     ///< Log of uncapped individual earnings
		logiearnx,                ///< (IHT of earnings in 1000s)/100 if working,zero otherwise Approx Range [0, 0.0599147], stored as Double
		low_tics,			      ///< low_tics score, stored as Short
		l2partdied,								///< Lag of partner/spouse died
		l2paternity,               ///< Lag of Count of children fathered (0,1,2), stored as Short
		l2painstat,								///< Lag of pain status
		l2painmild,								///< Lag of pain mild
		l2painmoderate,						///< Lag of pain moderate
		l2painsevere,							///< Lag of pain severe
		l2parhelphours,								///< Lag of hours spent helping parents and in-laws
		l2parkine,					///< Lag of parkinsons disease, stored as Boolean
		l2proptax,                 ///< Lag of the linear property taxes, predicted independently from logproptax \note not a transform
		l2proptax_nonzero,         ///< Lag of the linear property taxes being nonzero, predicted independently from logproptax_nonzero, \note not a transform
		l2psyche,					///< Lag of psychiatric problems ever, stored as Boolean
		l2rxchol,                 ///< Lag of cholesterol drugs [0, 1], stored as Boolean
		//l2retemp,					///< Lag of whether considers self retired, stored as Boolean
		l2selfmem1,                ///< Lag of selfmem 1 [0, 1], stored as Boolean
		l2selfmem2,                ///< Lag of selfmem 2 [0, 1], stored as Boolean
		l2selfmem3,                ///< Lag of selfmem 3 or more [0, 1], stored as Boolean
		l2selfmem,                /// Lag of Self-rating Memory status, (1, 2, 3) = (Good, Fair, Poor)
		l2smkstat,                 ///< Lag of Smoking status, Approx Range [1, 3], stored as Short
		l2smoken,                  ///< Lag of Current smoking, [0, 1], stored as Boolean
		l2smokev,					///< Lag of ever smoked
		l2smokef,					///< Lag of number cigarettes/day
		l2srh,                      ///< Lag of Self Reported Health
		l2srh1,                     ///< Lag of Excellent Self Reported Health
        l2srh2,                     ///< Lag of Very Good Self Reported Health
        l2srh3,                     ///< Lag of Good Self Reported Health
        l2srh4,                     ///< Lag of Fair Self Reported Health
        l2srh5,                     ///< Lag of Poor Self Reported Health
		l2ssclaim,                 ///< Lag of Claiming OASI, [0, 1], stored as Boolean
		l2ssiclaim,                ///< Lag of Claiming SSI, [0, 1], stored as Boolean
		l2stroke,                  ///< Lag of Stroke, [0, 1], stored as Boolean
		l2single,                   ///< Lag of marital status: single [0, 1], stored as Boolean
		l2htcamt,                   ///< Lag of transfers
		l2tcamt_cpl,               ///< lag of couples tcamt_cpl
		lunge,                    ///< Lung disease [0, 1], stored as Boolean
		lungoxy,                  ///< Taking supplemental oxygen for lung condition
		l2volhours,								///< Lag of volunteer hours
		l2widowed,                 ///< Lag of Widowed, [0, 1], stored as Boolean
		l2wlp_treated,             ///< Lag of Treated with a Weight Loss Pill, [0, 1], stored as Boolean
		l2wlth_nonzero,            ///< Lag of Non-pension wlth(hatota) not zero, [0, 1], stored as Boolean
		l2work,                    ///< Lag of R working for pay, [0, 1] (NOW DEFUNKT), stored as Boolean
		l2workcat,                 ////<Lag of workcat, stored as Short
		//l2workstat,								///< Lag of workstat, stored as Short
		l2workstat_alt,								///< Lag of workstat_alt, stored as Short
		l2yrsnclastkid,						///< Lag of Years since last kid was born, stored as Float
		lipidrx,                  ///< Cholesterol Drugs [0, 1], stored as Boolean
		l2lipidrx,                 ///< Lag of cholesterol drugs [0, 1], stored as Boolean
		lipidrx_start,             ///< Star taking cholesterol drugs [0, 1], stored as Boolean
		lipidrx_stop,              ///< Stop taking cholesterol Drugs [0, 1], stored as Boolean
		lniearn_ft,								///< ln(iearn_ft)
		lniearn_nl,								///< ln(iearn_nl)
		lniearn_pt,								///< ln(iearn_pt)
		lniearn_ue,								///< ln(iearn_ue)
		male,                     ///< Male [0, 1], stored as Boolean
		married,                  ///< Married [0, 1], stored as Boolean
		married_cond1,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married_cond2,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married_cond3,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married_cond4,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married_cond5,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married_cond6,            ///< Married [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		married2cohab_f,					///< female: lag married, now cohab
		married2cohab_m,					///< male: lag married, now cohab
		matchyr,                  ///< Approx Range [1992, 2004], stored as Short
		mcare,                    ///< Total Medicare costs, adjusted, stored as Double
		mcare_pta,                ///< Medicare Part A costs, stored as Double
		mcare_ptb,                ///< Medicare Part B costs, stored as Double
		mcare_ptd,                ///< Medicare Part d costs, stored as Double
		mcare_pta_enroll,         ///< Medicare Part A Enrolled, stored as Boolean
		mcare_ptb_enroll,         ///< Medicare Part B Enrolled, stored as Boolean
		mcare_ptd_enroll,         ///< Medicare Part B Enrolled, stored as Boolean
		mcare_pta_premium,        ///< Medicare Part A premium, usually zero except in some reforms
		mcare_ptb_premium,        ///< Medicare Part B premium
		mcare_pta_subsidy,        ///< Subsidy paid for Part A premiums
		mcare_ptb_subsidy,        ///< Subsidy paid for Part B premiums
		mcrep,                    ///< Current MC repetition
		medicare_elig,            ///< Stores Medicare Eligibility
		medicaid_elig,            ///< Individual eligible for Medicaid this timestep
		memrye,                   ///< R memory-related diseases [0, 1], stored as Boolean
		more_educ,								////< Pursing more education, stored as Boolean
		//mstat_new,										///< Marital status [1,3], stored as Short
        mstat,										///< Marital status [1,4], stored as Short
		mstat_new_cond1,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mstat_new_cond2,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mstat_new_cond3,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mstat_new_cond4,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mstat_new_cond5,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mstat_new_cond6,					///< Marital status (DO NOT USE FOR OUTPUT) [1,3], stored as Short
		mthreduc1,								///< Mothers education less than H.S., stored as Boolean
		mthreduc2,								///< Mothers education H.S. grad, stored as Boolean
		mthreduc3,								///< Mothers education some college, stored as Boolean
		mthreduc4,								///< Mothers education college+, stored as Boolean
		net,                      ///< Net Income, stored as Double
		nhmliv,                   ///< R live in nursingh ome at interview [0, 1], stored as Boolean
		nkid_liv10mi,							///< Number of children living within 10 miles of respondent
		nra,                      ///< RECODE of rdb_na_c (RECODE of nage_db (Normal ret age for curre... Approx Range [0, 65], stored as Short
		numbiokids,               ///< Number of biological children, stored as Short
		oasi_wd,                  ///< Minimum OASI benefits for widow(er)s, stored as Double
		uncovered_upper,              ///< Upper Bound on Uncovered Medical costs of Medicare Eligible, stored as Double
		uncovered_lower,              ///< Lower Bound on Uncovered Medical costs of Medicare Eligible, stored as Double
		oasiclaim, 								///< Claiming SS OASI benefits in PSID, [0, 1], stored as Boolean
		oopmd,										///< Estimated Out-Of_Pocket Expenditures, stored as Double
		oopmd_mcbs,               ///< Out of Pocket Medical costs estimated using the MCBS dataset, stored as Double
		oopmd_meps,               ///< Out of Pocket Medical costs estimated using the MEPS dataset, stored as Double
		padlstat1,                   ///< Probability of adlstat==1
		padlstat2,                   ///< Probability of adlstat==2
		padlstat3,                   ///< Probability of adlstat==3
		padlstat4,                   ///< Probability of adlstat==4
		painstat,									///< Pain status (1= no pain, 2= mild pain, 3= moderate pain, 4= severe pain)
		painmild,									///< Pain mild most of the time
		painmoderate,							///< Pain moderate most of the time
		painsevere,								///< Pain severe most of the time
		parhelphours,								///< Hours spent helping parents and in-laws
		par10mi_fixed,							///< Dummy variable if any parents live within 10 miles of respondent
		partdied,									///< Partner/spouse died?
		parthre,					///< Probability of arthritis, stored as Float
		pasthmae,					///< Probability of asthma, stored as Float
		parkine,					///< Parkinsons disease ever, stored as Boolean
		pparkine, 					///< Probability of Parkinsons disease, stored as Float
		paternity,                ///< Count of children fathered (0,1,2), stored as Short
		pcancre,			      ///< Probability of cancer, stored as Double
		phchole,                     ///< Probability of High Cholesterol, stored as Float
		pcogstate1,               // Probability cogstate == 1
		pcogstate2,               // Probability cogstate == 2
		pcogstate3,               // Probability cogstate == 3
		phearta,                  ///< Probability of heart attack, stored as Double
		pdbclaim,                 ///< Probability of claiming defined benefits, stored as Double
		pdiabe,                   ///< Probability of diabetes, stored as Double
		pdied,                    ///< Probability of death, stored as Double
		pdrink,						///< Probability of whether drinks alcohol at all, stored as Double
		pheavy_drinker,             ///< Probability of being a heavy drinker, stored as Double
		pfreq_drinker,              ///< Probability of being a frequent drinker, stored as Double
		pproblem_drinker,           ///< Probability of being a problem drinker, stored as Double
		//pdrinkd_stat1,				///< Probability of drinkd_stat==1, stored as Float
		//pdrinkd_stat2,				///< Probability of drinkd_stat==2, stored as Float
		//pdrinkd_stat3,				///< Probability of drinkd_stat==3, stored as Float
		//pdrinkd_stat4,				///< Probability of drinkd_stat==4, stored as Float
		phearte,                  ///< Probability of heart disease, stored as Double
		phibpe,                   ///< Probability of hypertension, stored as Double
		phicap_nonzero,           ///< Probability of nonzero household capital income, Double
		phipe,                      ///< Probability of Hip Fracture Ever, Float
        piadlstat1,                  ///< Probability of iadlstat==1
		piadlstat2,                  ///< Probability of iadlstat==2
		piadlstat3,                  ///< Probability of iadlstat==3
		pinpatient_ever,		  ///< Probability of inpatient_ever, stored as Double
		pk6severe,									///< Probability of severe Kessler 6 score 	
		plunge,                   ///< Probability of lung cancer, stored as Double
		poasiclaim, 							///<Probability of SS OASI claiming in PSID, Stored as Double
		proptax,                  ///< Linear property taxes, predicted independently from logproptax \note not a transform
		proptax_nonzero,          ///< Linear property taxes being nonzero, predicted independently from logproptax_nonzero, \note not a transform
		//pretemp,				/// Probability of considering self retired, stored as Float
		pssclaim,                 ///< Probability of SS claiming, stored as Double
		pstroke,                  ///< Probability of stroke, stored as Double
		psyche,					///< Psychatric problems ever, stored as Boolean
		ppsyche,				///< Probability of psychiatric problems ever, stored as Double
		pwlth_nonzero,            ///< Probability of nonzero wealth, stored as Double
		//pwork,                    ///< Probability of working, stored as Double
		pselfmem1,               /// Probability selfmem == 1
		pselfmem2,               /// Probability selfmem == 2
		pselfmem3,               /// Probability selfmem == 3
		psmkstat1,				  ///< Probability of first smoking state (never smoked), stored as Float
		psmkstat2,				  ///< Probability of second smoking state (smoke ever), stored as Float
		psmkstat3,				  ///< Probability of third smoking state (smoke now), stored as Float
		psmoken,				///< Probability of smoking now, stored as Float
		psrh1,                  ///< Probability of Excellent Self Reported Health
        psrh2,                  ///< Probability of Very Good Self Reported Health
        psrh3,                  ///< Probability of Good Self Reported Health
        psrh4,                  ///< Probability of Fair Self Reported Health
        psrh5,                  ///< Probability of Poor Self Reported Health
		period,                   ///< Approx Range [1, 1], stored as Short
		qaly,                     ///< Quality Adjusted Life Year, stored as Double
		rabyear,                  ///< Approx Range [1896, 1972], stored as Short
		racegrp,                  ///< Approx Range [1, 4], stored as Short
		raime,                    ///< Current AIME, stored as Double
		rbmonth,				  ///< Month person as born, stored as Short
		rbyr,                     ///< Year person was born, stored as Short
		rdbclyr,                  ///< Year started claiming DB, 2100 otherwise, stored as Short
		relnone,									///< Religion - None
		rel_notimp,								///< Religion not important
		reloth,										///< Religion - Other
		rel_someimp,							///< Religion somewhat important
		//retemp,						///< Whether considers self retired, stored as Boolean
		//retage,						///< Retirement age, stored as Float
		rpia,											///< SS Primary Insurance Amount
		rq,                       ///< Approx Range [1, 212], stored as Short
		rssclyr,                  ///< Approx Range [1969, 2100], stored as Short
		running_educ,								///< Binary indicating running education module, stored as Boolean
		rsswclyr,									///< Year respondent claims SS widow benefits
		rxchol,                  ///< Cholesterol Drugs [0, 1], stored as Boolean
		rxchol_start,             ///< Star taking cholesterol drugs [0, 1], stored as Boolean
		rxchol_stop,              ///< Stop taking cholesterol Drugs [0, 1], stored as Boolean
		rxexp,										///< Annual Total Drug Spending
		rxexp_mcbs,								///< Drug spending from MCBS model
		rxexp_mcbs_di,						///< Drug spending for DI recipients from MCBS model
		rxexp_meps,								///< Drug spending from MEPS model
		ry_earn,                  ///< iearnx * 1000, stored as Double
		ry_earnuc,                  ///< iearnuc * 1000, stored as Double
		//	sdbage,                   ///< Year spouse started claiming DB, stored as Short
		satisfaction,							/// Life satisfaction (1-5, highest to lowest)
		selfmem1,                ///< selfmem 1 [0, 1], stored as Boolean
		selfmem2,                ///< selfmem 2 [0, 1], stored as Boolean
		selfmem3,                ///< selfmem 3 or more [0, 1], stored as Boolean
		selfmem,                 // Self-rating memory status, (1, 2, 3) = (Good, Fair, Poor)
		shlt,                     ///< Health fair/poor [0, 1], stored as Boolean
		single,                   ///< Single [0, 1], stored as Boolean
		single_cond1,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single_cond2,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single_cond3,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single_cond4,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single_cond5,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single_cond6,             ///< Single [0, 1], VARIABLE REQUIRED FOR BLOWFISH, DO NOT USE FOR OUTPUT
		single2married_f,					///< female: lag single, now married
		single2married_m,					///< male: lag single, now married
		smkstat,                  ///< Smoking status Approx Range [1, 3], stored as Short
		smoken,                   ///< Current smoking [0, 1], stored as Boolean
		smokev,                   ///< Ever smoked [0, 1], stored as Boolean
		smokef,						///< Number cigarettes/day, stored as Double
		smoke_start,				///< Whether person transitions from not smoking to smoking
		psmoke_start,				///< Probability of transition from not smoking to smoking
		//l2smoke_start, 				///< Lag of transition from not smoking to smoking
		smoke_stop,               ///< Whether person transitions from smoking to not smoking
		psmoke_stop,				///< Probability of transition from smoking to not smoking
		//l2smoke_stop, 				///< Lag of transition from smoking to not smoking
		srh,											///< Self-reported health (cross-sectional)
		srh1,                       ///< Excellent Self Reported Health
        srh2,                       ///< Very Good Self Reported Health
        srh3,                       ///< Good Self Reported Health
        srh4,                       ///< Fair Self Reported Health
        srh5,                       ///< Poor Self Reported Health
		ssage,                    ///< Year started claiming SS benefits, stored as Short
		ssamt, 										///< SS OASI benefits, stored as Double
		ssdiamt,                  ///< SS OASI Benefits for PSID regression model, stored as Double
		ssben,                    ///< SS Benefits, stored as Double
		ssclaim,                  ///< Claiming OASI [0, 1], stored as Boolean
		sswclaim,									///< Claiming SS widows benefits
		ssiamt,                   ///< SSI Benefits for PSID regression model, stored as Double
		ssiben,                   ///< SSI Benefits, Stored as Double
		ssiclaim,                 ///< Claiming SSI [0, 1], stored as Boolean
		ssoasiamt, 								///< SS OASI benefits amount for PSID regression model, stored as Double
		ssretbegyear,             ///< SS ret claim beg year Approx Range [-1, 2026], stored as Short
		ssretflag,                ///< SS ret claim type flag Approx Range [1, 6], stored as Short
		//	sssage,                   ///< Year spouse started claiming SS benefits, stored as Short
		stax,                     ///< State Tax, stored as Double
		stroke,                   ///< Stroke [0, 1], stored as Boolean
		suburb,										///< Lives in suburbs
		sumwt,                    ///< Approx Range [0, 1728878], stored as Double
		htcamt,                    ///< Household transfers
		tcamt_cpl,                ///< Individual transfers to children
		totmd,                    ///< Total Medical costs, adjusted, stored as Double
		totmd_mcbs,               ///< Total Medical costs estimated using the MCBS dataset, stored as Double
		totmd_meps,               ///< Total Medical costs estimated using the MEPS dataset, stored as Double
		treat_effective,          ///< Whether the treatment was effective. . 0/1 Indicator, stored as Boolean
		treat_now,                ///< Whether the person was treated. . 0/1 Indicator, stored as Boolean
		volhours,									///< Volunteer hours in previous two years
		wave,                     ///< Wave of interview Approx Range [7, 7], stored as Short
		weight,                   ///< R person level weight Approx Range [0, 76727.77], stored as Double
		white,                    ///< Non-Hispanic white [0, 1], stored as Boolean
		widowed,                  ///< Widowed [0, 1], stored as Boolean
		widowev,                  ///< Ever widowed [0, 1], stored as Boolean
		wlp_treated,              ///< Treated with a Weight Loss Pill, [0, 1], stored as Boolean
		wlth_nonzero,             ///< Non-pension wlth(hatota) not zero [0, 1], stored as Boolean
		work,                     ///< R working for pay [0, 1] (NOW DEFUNKT, REPLACED BY WORKSTAT == 1, EMPLOYED), stored as Boolean
		workcat, 								  ///< Categorical variable for workstat, stored as Short
		//workstat,									///< Categorical variable for workstat, stored as Short
		workstat_alt,							///< Three levels of workstat - unemployed, part-time, full-time
		wthh,                     ///< Household weight Approx Range [0, 15569], stored as Double
		year,                     ///< Year Approx Range [2004, 2050], stored as Short
		yrsnclastkid,							///< Years since last kid was born, stored as Float
		vgactx_e,					///< Number of times done vigorous exercise per week, stored as Short
		mdactx_e,					///< Number of times done moderate exercise per week, stored as Short
		ltactx_e,					///< Number of times done light exercise per week, stored as Short
		l2vgactx_e,					///< Lag of Number of times done vigorous exercise per week, stored as Short
		l2mdactx_e,					///< Lag of  Number of times done moderate exercise per week, stored as Short
		l2ltactx_e,					///< Lag of  Number of times done light exercise per week, stored as Short
		exstat,						///< Exercise Status, Approx. range [0, 1], stored as Short
		l2exstat,					///< Lag of exercise Status, Approx. range [0, 1], stored as Short
		exstat1,					///< exstat1 [0, 1]
		exstat2,					///< exstat2 [0, 1]
		exstat3,					///< exstat3 [0, 1]
		l2exstat1,					///< l2exstat1 [0, 1]
		l2exstat2,					///< l2exstat2 [0, 1]
		l2exstat3,					///< l2exstat3 [0, 1]
		pexstat1,					///< Probability of exstat==1
		pexstat2,					///< Probability of exstat==2
		pexstat3,					///< Probability of exstat==3
		rdd_treated,				///< Whether treated with ReduceDrinkDays intervention
		l2rdd_treated,				///< Lag of whether treated with ReduceDrinkDays intervention
		ssi_treated,				///< Whether treated with SmokeStopIntervention
		l2ssi_treated,				///< Lag of whether treated with SmokeStopIntervention
		mei_treated,                ///< Whether treated with Moderate Exercise Increase intervention
		l2mei_treated,              ///< Lag of whether treated with Moderate Exercise Increase intervention
		ei_treated,					///< Whether treated with Exercise Intervention
		l2ei_treated,				///< Lag of whether treated with Exercise Intervention
		lnly,                       ///< Loneliness Score, Low to High [1, 3]
		lnly1,                      ///< Loneliness Score: Low
        lnly2,                      ///< Loneliness Score: Medium
        lnly3,                      ///< Loneliness Score: High
        l2lnly,                       ///< Lag of Loneliness Score, Low to High [1, 3]
        l2lnly1,                      ///< Lag of Loneliness Score: Low
        l2lnly2,                      ///< Lag of Loneliness Score: Medium
        l2lnly3,                      ///< Lag of Loneliness Score: High
        plnly1,                     ///< Probability of lnly == 1
        plnly2,                     ///< Probability of lnly == 2
        plnly3,                     ///< Probability of lnly == 3
        alzhe,                      ///< Alzheimers ever
        l2alzhe,                    ///< Lag of Alzheimers ever
        palzhe,                     ///< Probability of Alzheimers ever
        demene,                     ///< Dementia ever
        l2demene,                   ///< Lag of Dementia ever
        pdemene,                    ///< Probability of Dementia ever
        workstat,                   ///< Work Status
        l2workstat,                 ///< Lag of workstat
        employed,                   ///< Employed
        unemployed,                 ///< Unemployed
        retired,                    ///< Retired
        l2employed,                 ///< Lag of Employed
        l2unemployed,               ///< Lag of Unemployed
        l2retired,                  ///< Lag of Retired
        pworkstat1,                  ///< Probability of Employed (workstat == 1)
        pworkstat2,                ///< Probability of Unemployed (workstat == 2)
        pworkstat3,                   ///< Probability of Retired (workstat == 3)
        heavy_smoker,               ///< Heavy Smoker (10+ cigs/day)
        l2heavy_smoker,             ///< Lag of Heavy Smoker (10+ cigs/day)
        pheavy_smoker,              ///< Probability of Heavy Smoker (10+ cigs/day)
        beer,                       ///< Number of pints of beer consumed in week before survey
        l2beer,                     ///< Lag of Number of pints of beer consumed in week before survey
        wine,                       ///< Number of glasses of wine consumed in week before survey
        l2wine,                     ///< Lag of Number of glasses of wine consumed in week before survey
        spirits,                    ///< Number of measures of spirits consumed in week before survey
        l2spirits,                  ///< Lag of Number of measures of spirits consumed in week before survey
        abstainer,                  ///< Abstains from alcohol consumption. (alcstat == 1)
        moderate,                   ///< Moderate alcohol consumption (Women: 1-14 u/w; Men: 1-21 u/w. (alcstat == 2)
        increasingRisk,             ///< Increasing-risk alcohol consumption (Women: 15-35 u/w; Men: 22-50 u/w. (alcstat == 3)
        highRisk,                   ///< High-risk alcohol consumption (Women: 35+ u/w; Men: 50+ u/w. (alcstat == 4)
		NVars,                    ///< A counter for the number of valid variables
		_NONE                     ///< A special value for no variable, used in mappings where there is no valid second
		};

	/** prefix operator ++v
	    @param[in,out] orig Original variable
	*/
	Vars_t& operator++(Vars_t& orig);

	/** postfix operator v++
	    @param[in,out] orig Original variable
	    @param[in]     i    integer to add, ignored, assumed to be one
	*/
	Vars_t operator++(Vars_t& orig, int i);
}

namespace VarTypes {
  /** These variable types correspond one-to-one with the possible Stata datatypes for easy generation of the binary files. */
  enum VarTypes_t {
    Boolean, ///< Boolean true/false only
    Short,   ///< A small integer
    Long,    ///< A large integer
    Float,   ///< A small floating point value
    Double,  ///< A large floating point value
    NTypes   ///< The number of data types
  };
}

/** This class holds a bunch of meta-data about an individual variable, specificed by the Vars_t enum. */
class VarInfo {
public:
  VarInfo(); ///< Default constructor, doesn't do much
  /** This version of VarInfo is for real (non-dummy) variables.
      @param[in] label      The name of the variable. Convenient if it is the same as the name of the corresponding Vars_t entry
      @param[in] desc       The long description of the variable. This will get passed through in any Stata output
      @param[in] type       The type of the variable (bool, short, etc.)
      @param[in] is_categorical If set to true, this variable is a categorical type that can be used to automatically update its category indicator dummies.
  */
  VarInfo(std::string label, std::string desc, VarTypes::VarTypes_t type, bool is_categorical = false);
  /** This version of VarInfo is for construcing the indicator dummies of an categorical variable. Note that a type entry is not required because all dummies are booleans.
      @param[in] label         The name of the variable. Convenient if it is the same as the name of the corresponding Vars_t entry
      @param[in] desc          The long description of the variable. This will get passed through in any Stata output
      @param[in] type          The type of the variable (bool, short, etc.)
      @param[in] dummy_for     The categorical variable that this is acting as a dummy for
      @param[in] category_index Which category this variable will be a dummy indicator for
  */
  VarInfo(std::string label, std::string desc, VarTypes::VarTypes_t type, Vars::Vars_t dummy_for, int category_index);

  std::string label; ///< The string short label
  std::string desc; ///< The string long description
  VarTypes::VarTypes_t type; ///< The type (bool, short, etc.)
  bool is_categorical; ///< True if this variable is categorical instead of just a regular integer
  Vars::Vars_t dummy_for; ///< If this variable is a dummy, this is the categorical variable it is a dummy for
  int category_index; ///< If this variable is a dummy, this is the category that it corresponds to
};

/** This class is a useful container for lots of static methods relating to the relationships between variables. */
class VarsInfo {
public:
	VarsInfo();

	static Vars::Vars_t indexOf(std::string label);
	static Vars::Vars_t indexOf(const char* label);
	static std::string labelOf(Vars::Vars_t v);
	static std::string labelOf(VarTypes::VarTypes_t v);
	static VarInfo infoOf(Vars::Vars_t v);
	static unsigned int NVars(VarTypes::VarTypes_t type) { return NVarsPerType[type];}
	static unsigned int typeIndexOf(Vars::Vars_t v) {return index_map[info[v].type][v];}
	static VarTypes::VarTypes_t typeOf(Vars::Vars_t v) {return info[v].type;}
	static Vars::Vars_t lagOf(Vars::Vars_t v) {return lag_map[v];}
	static Vars::Vars_t probOf(Vars::Vars_t v) {return prob_map[v];}

protected:
	static VarInfo info[Vars::NVars];
	static unsigned int NVarsPerType[VarTypes::NTypes];
	static unsigned int index_map[VarTypes::NTypes][Vars::NVars];
	static Vars::Vars_t lag_map[Vars::NVars];
	static Vars::Vars_t prob_map[Vars::NVars];
};
