program define load_scenarios
version 10
args output_dir scenario_names keeplist

local workdir : pwd()
foreach v in `scenario_names' {
  
** A script to calculate the life expectancy of a cohort simulation
local cohort_dir "`output_dir'/`v'/detailed_output"

** Read in all the data files, dropping records dead for more than one timestep
cd `cohort_dir'

load_all "`keeplist'"
qui drop if ldied==1

cd `workdir'
qui compress
tempfile all`v'

save `all`v'', replace

}

clear
gen scenario_name = ""
gen s = .
scalar snum = 0
foreach v in `scenario_names' {
  append using `all`v''
  replace scenario_name = "`v'" if scenario_name==""
  replace s = snum if missing(s)
  scalar snum = snum + 1
}

end
