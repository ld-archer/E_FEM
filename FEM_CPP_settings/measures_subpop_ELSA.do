/*Measures you want to include:

Conventions: 
p_var -> variable prevalence  	(ex. p_diabe is the prevalence of diabetes)
i_var -> variable incidence   	(ex. i_diabe is the incidence of diabetes) 
n_var -> variable total (count)	(ex. n_diabe is the number of individuals with diabetes)
t_var -> variable total (cost)	(ex. t_totmd is the total medical costs)
a_var -> average		(ex. a_totmd is the average medical cost)	
qnum_var -> quintile  		(ex. q05_totmd -> fifth percentile of total medical costs)
d_age -> average death age	(ex. d_age_blk is the average age of those who died, requires ldied ==0 & ldied == 1)

(Startpop is different since it uses the variable "weight" not "startpop")
m_startpop -> count (millions)	(ex. m_startpop -> starting population in millions
m_endpop -> count (millions)	(ex. m_endpop -> ending population in millions
*/


#d ;
local measures 	
			m_startpop
			m_endpop
					p_diabe     i_diabe 	n_diabe 
					p_hibpe	    i_hibpe 	n_hibpe
					p_lunge	    i_lunge 	n_lunge 
					p_stroke    i_stroke    n_stroke
					p_hearte    i_hearte    n_hearte
					p_cancre    i_cancre    n_cancre
					p_arthre    i_arthre    n_arthre
					p_psyche    i_psyche    n_psyche
					p_asthmae   i_asthmae   n_asthmae
					p_parkine   i_parkine   n_parkine
					p_alzhe		i_alzhe		n_alzhe
					p_demene	i_demene	n_demene
						i_died    n_died
						a_bmi     q05_bmi   q50_bmi   q95_bmi
						p_adl1	  p_adl2    p_adl3p
						p_iadl1   p_iadl2p
						a_adlstat a_iadlstat
						a_anyadl  n_anyadl  p_anyadl
						a_anyiadl n_anyiadl p_anyiadl
						a_age     d_age
						p_smoken  i_smoken  n_smoken
						p_smokev  i_smokev  n_smokev
						n_smoke_start
						n_smoke_stop
						p_heavy_smoker i_heavy_smoker n_heavy_smoker
						t_atotb 	a_atotb
						t_itot		a_itot
					p_drink		i_drink		n_drink
					p_problem_drinker i_problem_drinker n_problem_drinker
					p_abstainer			n_abstainer
					p_moderate			n_moderate
					p_increasingRisk	n_increasingRisk
					p_highRisk			n_highRisk
					a_alcbase_m 	q05_alcbase_m q50_alcbase_m q95_alcbase_m
					a_alcbase_f 	q05_alcbase_f q50_alcbase_f q95_alcbase_f
					a_exstat	p_exstat1 	p_exstat2	p_exstat3
					a_mstat 	p_single 	p_married	p_widowed	p_cohab
					a_lnly		p_lnly1		p_lnly2 	p_lnly3
					a_workstat
					p_employed  i_employed  n_employed
					p_unemployed i_unemployed n_unemployed
					p_retired	i_retired	n_retired
					n_anydisease 	p_anydisease	a_anydisease
					n_nodisease		p_nodisease		a_nodisease
					n_disabled		p_disabled		a_disabled
					n_not_disabled  p_not_disabled	a_not_disabled
			
										
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

local subpop all m f 60p 5059 m_6064 f_6064 m_6569 f_6569 m_7074 f_7074 m_7579 f_7579 m_8084 f_8084 m_8589 f_8589 m_9094 f_9094 m_9599 f_9599 m_100p f_100p
* CORE_DEBUG: 
* HANDOVERS: 55p_f_l 55p_m_l
* ANALYSIS: educ1 educ2 educ3 exstat1 exstat2 exstat3 anyadl noadl
*
* DEFUNKT: 6569 7074 7579 8084 8589 9094 9599 100p
