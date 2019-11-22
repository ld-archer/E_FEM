* Name your output file
local filename summary_output_psid_example.txt

/*Measures you want to include:

Conventions: 
p_var -> variable prevalence  	(ex. p_diabe is the prevalence of diabetes)
i_var -> variable incidence   	(ex. i_diabe is the incidence of diabetes) 
n_var -> variable total (count)	(ex. n_diabe is the number of individuals with diabetes)
t_var -> variable total (cost)	(ex. t_totmd is the total medical costs)
a_var -> average								(ex. a_totmd is the average medical cost)	
qnum_var -> quintile  					(ex. q05_totmd -> fifth percentile of total medical costs)
d_age -> average death age		  (ex. d_age_blk is the average age of those who died, requires ldied ==0 & ldied == 1)

(Startpop is different since it uses the variable "weight" not "startpop")
m_startpop -> count (millions)				(ex. m_startpop -> starting population in millions
m_endpop -> count (millions)					(ex. m_endpop -> ending population in millions
*/

#d ;
local measures 	
			m_startpop
			m_endpop
			a_iearn
			a_hatotax
			p_workcat1 	p_workcat2	p_workcat3	p_workcat4
			p_cancre p_diabe p_hearte p_hibpe p_lunge p_stroke 
			p_more_educ
			p_educ1 p_educ2 p_educ3 p_educ4 
			p_overwt p_obese_1 p_obese_2 p_obese_3		
			p_adl1 p_adl2 p_adl3p
			p_iadl1 p_iadl2p
			p_oasiclaim p_ssiclaim p_diclaim
			p_anyhi
			t_totmd t_mcare t_caidmd
			a_totmd a_mcare a_caidmd
			p_medicaid_elig p_mcare_pta_enroll p_mcare_ptb_enroll p_mcare_ptd_enroll
			p_inscat1 p_inscat2 p_inscat3
			i_cancre i_diabe i_hearte i_hibpe i_lunge i_stroke i_died
			p_smokev p_smoken
			a_bmi
			P_srh1 P_srh2 P_srh3 P_srh4 P_srh5
			P_srh3p P_srh2l
			P_satisfaction
			P_qaly
			P_k6score
			P_anyexercise
			a_ssdiamt a_ssoasiamt a_ssiamt
			t_ssdiamt t_ssoasiamt t_ssiamt
			a_fu_fiitax_ind a_fu_siitax_ind
			t_fu_fiitax_ind t_fu_siitax_ind
;
#d cr


/* Subpopulations you wish to analyze:

Conventions:
all - full living sample (ldied == 0)
wht - white
blk - black
his - hispanic
m - male
f - female
5564 - 55 to 64
6574 - 65 to 74
7584 - 75 to 84
85p - 85 plus
65p - 65 plus
*/

local subpop all m f 

* all 2534 3544 4554 5564 6574 7584 85p

* 2549_m 5064_m 65p_m 2549_f 5064_f 65p_f