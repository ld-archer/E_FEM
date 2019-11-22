clear all
set more off
include ../../fem_env.do

set matsize 500

local varsout : env MODELS
local table : env TABLE

*use $outdata/hrs19_transition

foreach v of local varsout {
  est use $local_path/Estimates/`v'.ster
  est store `v'
}

esttab `varsout' using table`table'.csv, csv replace label noobs nostar

clear
insheet using table`table'.csv, comma
rowrename 2
drop in 1/2

export excel using techappendix.xls, sheetreplace sheet("Table `table'") firstrow(varlabels)

exit, STATA clear
