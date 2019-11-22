/* Produce input files for graphviz that layout the directed graphs.  Build the subgroup structure with nodes and the edges */

quietly include gen_graphviz_dot.ado 

local simdir : env simtype
local edges_nodes_file : env filein  

log using make_figures_`simdir'.log, replace

 
use `edges_nodes_file', replace


* See what we're working with
tab input_grp_lvl_1
tab input_grp_lvl_2
tab input_grp_lvl_3

tab output_grp_lvl_1
tab output_grp_lvl_2
tab output_grp_lvl_3

*** Chronic disease in t and t+1 ***
preserve
keep if inlist(output_grp_lvl_3,"T+1: Chronic conditions") & inlist(input_grp_lvl_3,"T: Chronic conditions")
local dotout = "chronic"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(1) lhs(1) rhs(1)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore

*** Risk factors, chronic disease, and functional limitations ***
preserve
#d ;
keep if inlist(output_grp_lvl_3,"T+1: Chronic conditions","T+1: Functional limitations","T+1: Risk factors") 
		& inlist(input_grp_lvl_3,"T: Chronic conditions","T: Functional limitations","T: Risk factors")
;
#d cr
local dotout = "health"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(1) lhs(1) rhs(1)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore

*** Structure at level 1 ***
preserve
keep output_grp_lvl_1 input_grp_lvl_1 
gen str predictor = "_void1"
gen str outcome = "_void2"
duplicates drop 
local dotout = "structure_lvl_1"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(1) output_groups(1) input_groups_viz(1) output_groups_viz(1) showedges(0) lhs(1) rhs(1)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore

*** All predictors ***
preserve
keep if inlist(input_grp_lvl_1,"T: Predictors")
local dotout = "all_predictors"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(0) lhs(0) rhs(1)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore

*** Transitioned outcomes ***
preserve
keep if inlist(output_grp_lvl_1,"T+1: Transitioned")
local dotout = "transitioned"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(0) lhs(1) rhs(0)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore

*** Contemporaneous outcomes ***
preserve
keep if inlist(output_grp_lvl_1,"T: Contemporaneous")
local dotout = "contemporaneous"
gen_graphviz_dot, dotout(`simdir'/dot/`dotout') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(0) lhs(1) rhs(0)
! dot `simdir'/dot/`dotout'.dot -Tpng -o `simdir'/png/`dotout'.png	
restore


* All outcomes individually
levelsof outcome, local(all_outcome)
local all_outcome_cnt : word count `all_outcome'
forvalues x = 1/`all_outcome_cnt' {
	preserve
	local outcome_out: word `x' of `all_outcome'
	keep if inlist(outcome,"`outcome_out'")

	if substr("`outcome_out'",1,5) == "T+1: " {
		local suf = "_tplus1"
		local outcome_out = substr("`outcome_out'",6,.)
	}
	else if substr("`outcome_out'",1,3) == "T: " {
		local suf = "_t"
		local outcome_out = substr("`outcome_out'",4,.)
	}
	else {
		local suf = ""
	}

	* Eat the spaces for the filename, replace with underscores
	local fname = subinstr("`outcome_out'"," ","_",.)
	di "local fname is: `fname'"
	* Eat the ' symbol
	local fname = subinstr("`fname'","'","",.)
	di "local fname is: `fname'"
	local fname = "`fname'" + "`suf'"
	di "local fname is: `fname'"
	
	quietly gen_graphviz_dot, dotout(`simdir'/dot/models/`fname') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(1) lhs(1) rhs(1)
	! dot `simdir'/dot/models/`fname'.dot -Tpng -o `simdir'/png/models/`fname'.png	
	restore
}

* All predictors individually - transitioned outcomes 
levelsof predictor, local(all_predictor)
local all_predictor_cnt : word count `all_predictor'
forvalues x = 1/`all_predictor_cnt' {
	preserve
	local predictor_out: word `x' of `all_predictor'
	di "Building `predictor_out' for transitioned outcomes"
	keep if inlist(predictor,"`predictor_out'") & output_grp_lvl_1 == "T+1: Transitioned"
	if _N > 0 {
		* Eat the spaces for the filename, replace with underscores
		local fname = subinstr("`predictor_out'"," ","_",.)
		* Eat the ' symbol
		local fname = subinstr("`fname'","'","",.)
		local fname = "`fname'" + "_tplus1"
		di "local fname is: `fname'"
		gen_graphviz_dot, dotout(`simdir'/dot/predictors/`fname') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(1) lhs(1) rhs(1)
		! dot `simdir'/dot/predictors/`fname'.dot -Tpng -o `simdir'/png/predictors/`fname'.png	
	}
	restore
}

* All predictors individually - contemporaneous outcomes 
levelsof predictor, local(all_predictor)
local all_predictor_cnt : word count `all_predictor'
forvalues x = 1/`all_predictor_cnt' {
	preserve
	local predictor_out: word `x' of `all_predictor'
	di "Building `predictor_out' for contemporaneous outcomes"
	keep if inlist(predictor,"`predictor_out'") & output_grp_lvl_1 == "T: Contemporaneous"
	if _N > 0 {
		* local dotout = "predictor_`x'_cont"
		* Eat the spaces for the filename
		local fname = subinstr("`predictor_out'"," ","_",.)
		local fname = subinstr("`fname'","'","",.)
		local fname = "`fname'" + "_t"
		gen_graphviz_dot, dotout(`simdir'/dot/predictors/`fname') input_groups(3) output_groups(3) input_groups_viz(3) output_groups_viz(3) showedges(1) lhs(1) rhs(1)
		! dot `simdir'/dot/predictors/`fname'.dot -Tpng -o `simdir'/png/predictors/`fname'.png	
	}
	restore
}
		
capture log close
		