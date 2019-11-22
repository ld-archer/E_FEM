clear all
set more off
include ../../../../../fem_env.do

capture confirm file "$routput_dir/vMultiplier"
if _rc {
  local output $output_dir/vMultiplier
}
else {
  local output $routput_dir/vMultiplier
}

** NHEA personal health expenditures (PHE) are from NHEA report by age 2004 for ages 55-64 and from NHEA report by age 2010 for ages 65p
	local NHEA_totmd_5564_2004 = 7787
	local NHEA_mcare_5564_2004 = 706
	local NHEA_caidmd_5564_2004 = 1026

	local NHEA_totmd_65p_2010 = 18424
	local NHEA_mcare_65p_2010 = 10016
	local NHEA_caidmd_65p_2010 = 2047

use "`output'/vMultiplier_summary.dta", clear

foreach var in totmd caidmd mcare {
	gen `var'_65p = t_`var'_65p + (dt_`var'_65p/2)
	gen pc_`var'_65p = `var'_65p / m_startpop_65p / 1000000
	
	gen `var'_5564 = t_`var'_5564 + (dt_`var'_5564/2)
	gen pc_`var'_5564 = `var'_5564 / m_startpop_5564 / 1000000
}

keep year pc_totmd_5564 pc_mcare_5564 pc_caidmd_5564 pc_totmd_65p pc_mcare_65p pc_caidmd_65p 


file open myfile using "`output'/spending_adjustment_factors.csv", write replace
file write myfile "Payment_sources" _tab "NHEA_5564_2004" _tab "FEM_5564_2004" _tab "Multiplier_5564" _tab "NHEA_65p_2010" _tab "FEM_65p_2010" _tab "Multiplier_65p" _n
	
		foreach var in totmd mcare caidmd {	
		sum pc_`var'_5564 if year==2004
		local pc_`var'_5564_2004 = r(mean)
	
		sum pc_`var'_65p if year==2010
		local pc_`var'_65p_2010 = r(mean)
		
		local mult_`var'_5564 = `NHEA_`var'_5564_2004' / `pc_`var'_5564_2004'
		local mult_`var'_65p = `NHEA_`var'_65p_2010' / `pc_`var'_65p_2010'
	}
		
 	file write myfile %15s "Total" _tab %15.5f (`NHEA_totmd_5564_2004') _tab %15.0f (`pc_totmd_5564_2004') _tab %15.5f (`mult_totmd_5564') _tab %15.5f (`NHEA_totmd_65p_2010') _tab %15.0f (`pc_totmd_65p_2010') _tab %15.5f (`mult_totmd_65p') _n
 	file write myfile %15s "Medicare" _tab %15.5f (`NHEA_mcare_5564_2004') _tab %15.0f (`pc_mcare_5564_2004') _tab %15.5f (`mult_mcare_5564') _tab %15.5f (`NHEA_mcare_65p_2010') _tab %15.0f (`pc_mcare_65p_2010') _tab %15.5f (`mult_mcare_65p') _n
 	file write myfile %15s "Medicaid" _tab %15.5f (`NHEA_caidmd_5564_2004') _tab %15.0f (`pc_caidmd_5564_2004') _tab %15.5f (`mult_caidmd_5564') _tab %15.5f (`NHEA_caidmd_65p_2010') _tab %15.0f (`pc_caidmd_65p_2010') _tab %15.5f (`mult_caidmd_65p') _n

file close myfile

insheet using "`output'/spending_adjustment_factors.csv", clear
format nhea_5564_2004 fem_5564_2004 nhea_65p_2010 fem_65p_2010 multiplier_5564 multiplier_65p %9.2f
desc
li

#d ;
listtex using NHEA_adjustment.tex, replace rstyle(tabular) 
head(
"\begin{tabular}{c|*{3}{r}|*{3}{r}}"
" \multicolumn{1}{c}{} & \multicolumn{3}{c}{Ages 55-64} & \multicolumn{3}{c}{Ages 65 and over}\\"
\hhline{~------}
"         & NHEA        & FEM 2004,         & Adjustment & NHEA        & FEM 2010,         & Adjustment\\"
" Payment & 2004 (\\\$) & unadjusted (\\\$) & factor     & 2010 (\\\$) & unadjusted (\\\$) & factor\\"
" sources & (A)         & (B)               & (A)/(B)    & (C)         & (D)               & (C)/(D)\\"
\hline
)
foot("\hline\end{tabular}")
;
#d cr

exit, STATA clear
