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
								p_diabe 	i_diabe 	n_diabe 
								p_hibpe		i_hibpe 	n_hibpe
								p_lunge		i_lunge 	n_lunge 
								p_stroke	i_stroke  n_stroke
								p_hearte  i_hearte  n_hearte
								p_cancre  i_cancre  n_cancre
													i_died		n_died
													a_bmi
													p_adl1	p_adl2 p_adl3p
													p_iadl1 p_iadl2p
													p_anyadl p_anyiadl
													a_age
													p_smoken p_smokev
													p_work
																		
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

local subpop all m f 55p_m_l 55p_f_l 
