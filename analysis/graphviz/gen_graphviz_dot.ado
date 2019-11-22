cap program drop gen_graphviz_dot
program define gen_graphviz_dot
	version 13
	syntax [if] [in], dotout(str) input_groups(int) output_groups(int) input_groups_viz(int) output_groups_viz(int) showedges(int) lhs(int) rhs(int)

* List of categories in each group 
* Input (number of groups might not be the same for input and output, so keeping separate
forvalues i = 1/`input_groups' {
	levelsof input_grp_lvl_`i', local(inp_`i')
	local input_grp_lvl_`i'_cnt : word count `inp_`i''
	di "`input_grp_lvl_`i'_cnt'"
	di `inp_`i''
}	

* Output
forvalues i = 1/`output_groups' {
	levelsof output_grp_lvl_`i', local(out_`i')
	local output_grp_lvl_`i'_cnt : word count `out_`i''
	di "`output_grp_lvl_`i'_cnt'"
	di `out_`i''
}	

* Find the level of the node 
gen input_grp_lvl = .
forvalues i = `input_groups' (-1) 1 {
	replace input_grp_lvl = `i' if missing(input_grp_lvl) & !missing(input_grp_lvl_`i')
}
replace input_grp_lvl = 0 if missing(input_grp_lvl)
	
gen output_grp_lvl = .
forvalues i = `output_groups' (-1) 1 {
	replace output_grp_lvl = `i' if missing(output_grp_lvl) & !missing(output_grp_lvl_`i')
}
replace output_grp_lvl = 0 if missing(output_grp_lvl)


* file with edges
if `showedges' {
preserve 
keep if input_grp_lvl <= `input_groups_viz' & output_grp_lvl <= `output_groups_viz'
keep predictor outcome
duplicates drop
tempfile edges
save `edges'
restore 
}
 
* Initialize the file
qui file open outfile using `dotout'.dot, write text replace

* header with settings
file write outfile "digraph {" _n
file write outfile _tab "rankdir=LR;" _n
file write outfile _tab "nodesep=0.05;" _n
file write outfile _tab "ranksep=1.4;" _n
file write outfile _tab "splines=true;" _n
* file write outfile _tab `"sep="+25,25";"' _n
* file write outfile _tab "overlap=scalexy;" _n



* Build the groups-nodes

* input level 1
if `rhs' {
* loop over the groups at level 1
levelsof input_grp_lvl_1, local(inp_1)
local input_grp_lvl_1_cnt : word count `inp_1'
forvalues i = 1/`input_grp_lvl_1_cnt' {
	local subgroup_1 : word `i' of `inp_1'
	file write outfile _tab "subgraph cluster_in_`i' {" _n
	file write outfile _tab _tab "penwidth=3;" _n
	file write outfile _tab _tab `"label = "`subgroup_1'";"' _n
	
	* List any nodes at this level (i.e., in this group )
	levelsof predictor if input_grp_lvl == 1 & input_grp_lvl_1 == "`subgroup_1'", local(inp_nodes_1)
	di `inp_nodes_1'
	local inp_nodes_1_cnt : word count `inp_nodes_1'
	forvalues x = 1/`inp_nodes_1_cnt' {
		local node_out : word `x' of `inp_nodes_1'
		di "`node_out'"
		file write outfile _tab _tab `""`node_out'";"' _n	
	}
	
	if `input_groups_viz' > 1 {
	
		* Level 2
		* Calculate the number of groups at level 2 that are in level 1
		levelsof input_grp_lvl_2 if input_grp_lvl_1 == "`subgroup_1'", local(inp_2)
		local input_grp_lvl_2_cnt : word count `inp_2'
		forvalues j = 1/`input_grp_lvl_2_cnt' {
			levelsof input_grp_lvl_2 if input_grp_lvl_1 == "`subgroup_1'", local(inp_subgrp_2)
			local subgroup_2 : word `j' of `inp_subgrp_2' 
			file write outfile _tab _tab "subgraph cluster_in_`i'_`j' {" _n 
			file write outfile _tab _tab _tab "penwidth=2;" _n
			file write outfile _tab _tab _tab `"label = "`subgroup_2'";"' _n 
		
	
			* List any nodes at this level
			levelsof predictor if input_grp_lvl == 2 & input_grp_lvl_2 == "`subgroup_2'", local(inp_nodes_2)
			di `inp_nodes_2'
			local inp_nodes_2_cnt : word count `inp_nodes_2'
			forvalues y = 1/`inp_nodes_2_cnt' {
				local node_out : word `y' of `inp_nodes_2'
				di "`node_out'"
				file write outfile _tab _tab _tab `""`node_out'";"' _n	
			}
			
			if `input_groups_viz' > 2 {
			
				* Level 3
				* Calculate the number of groups at level 3 that are in this particular level 2
				levelsof input_grp_lvl_3 if input_grp_lvl_2 == "`subgroup_2'", local(inp_3)
				local input_grp_lvl_3_cnt : word count `inp_3'
				forvalues k = 1/`input_grp_lvl_3_cnt' {
					levelsof input_grp_lvl_3 if input_grp_lvl_1 == "`subgroup_1'" & input_grp_lvl_2 == "`subgroup_2'", local(inp_subgrp_3)
					local subgroup_3 : word `k' of `inp_subgrp_3'
					file write outfile _tab _tab _tab `"subgraph cluster_in_`i'_`j'_`k' {"' _n 
					file write outfile _tab _tab _tab _tab "penwidth=1;" _n
					file write outfile _tab _tab _tab _tab `"label = "`subgroup_3'";"' _n 
				
				* List any nodes at this level 
				levelsof predictor if input_grp_lvl == 3 & input_grp_lvl_3 == "`subgroup_3'", local(inp_nodes_3)
				di `inp_nodes_3'
				local inp_nodes_3_cnt : word count `inp_nodes_3'
				forvalues z = 1/`inp_nodes_3_cnt' {
					local node_out : word `z' of `inp_nodes_3'
					di "`node_out'"
					file write outfile _tab _tab _tab _tab `""`node_out'";"' _n	
				}
				file write outfile _tab _tab _tab "}" _n
				} // close conditional for level 3
			} // Close level 3		
			file write outfile _tab _tab "}" _n 
		} // close conditional for level 2 	
	} // Close level 2
	file write outfile _tab "}" _n 
}	// Close level 1	
}		
	
di "Are we here??????"	
		
* output level 1
if `lhs' {
* loop over the groups at level 1
levelsof output_grp_lvl_1, local(out_1)
local output_grp_lvl_1_cnt : word count `out_1'
forvalues i = 1/`output_grp_lvl_1_cnt' {
	local subgroup_1 : word `i' of `out_1'
	file write outfile _tab "subgraph cluster_out_`i' {" _n
	file write outfile _tab _tab "penwidth=3;" _n
	file write outfile _tab _tab `"label = "`subgroup_1'";"' _n
	
	* List any nodes at this level (i.e., in this group )
	levelsof outcome if output_grp_lvl == 1 & output_grp_lvl_1 == "`subgroup_1'", local(out_nodes_1)
	di `out_nodes_1'
	local out_nodes_1_cnt : word count `out_nodes_1'
	forvalues x = 1/`out_nodes_1_cnt' {
		local node_out : word `x' of `out_nodes_1'
		di "`node_out'"
		file write outfile _tab _tab `""`node_out'";"' _n	
	}
	
	if `output_groups_viz' > 1 {
	
		* Level 2
		* Calculate the number of groups at level 2 that are in level 1
		levelsof output_grp_lvl_2 if output_grp_lvl_1 == "`subgroup_1'", local(out_2)
		local output_grp_lvl_2_cnt : word count `out_2'  
		forvalues j = 1/`output_grp_lvl_2_cnt' {
			levelsof output_grp_lvl_2 if output_grp_lvl_1 == "`subgroup_1'", local(out_subgrp_2)
			local subgroup_2 : word `j' of `out_subgrp_2' 
			file write outfile _tab _tab "subgraph cluster_out_`i'_`j' {" _n 
			file write outfile _tab _tab _tab "penwidth=2;" _n
			file write outfile _tab _tab _tab `"label = "`subgroup_2'";"' _n 
		
	
			* List any nodes at this level
			levelsof outcome if output_grp_lvl == 2 & output_grp_lvl_2 == "`subgroup_2'", local(out_nodes_2)
			di `out_nodes_2'
			local out_nodes_2_cnt : word count `out_nodes_2'
			forvalues y = 1/`out_nodes_2_cnt' {
				local node_out : word `y' of `out_nodes_2'
				di "`node_out'"
				file write outfile _tab _tab _tab `""`node_out'";"' _n	
			}
			
			if `output_groups_viz' > 2 {
			
				* Level 3
				* Calculate the number of groups at level 3 that are in this particular level 2
				levelsof output_grp_lvl_3 if output_grp_lvl_2 == "`subgroup_2'", local(out_3)
				local output_grp_lvl_3_cnt : word count `out_3'
				forvalues k = 1/`output_grp_lvl_3_cnt' {
					levelsof output_grp_lvl_3 if output_grp_lvl_1 == "`subgroup_1'" & output_grp_lvl_2 == "`subgroup_2'", local(out_subgrp_3)
					local subgroup_3 : word `k' of `out_subgrp_3'
					file write outfile _tab _tab _tab `"subgraph cluster_out_`i'_`j'_`k' {"' _n 
					file write outfile _tab _tab _tab _tab "penwidth=1;" _n
					file write outfile _tab _tab _tab _tab `"label = "`subgroup_3'";"' _n 
				
				* List any nodes at this level 
				levelsof outcome if output_grp_lvl == 3 & output_grp_lvl_3 == "`subgroup_3'", local(out_nodes_3)
				di `out_nodes_3'
				local out_nodes_3_cnt : word count `out_nodes_3'
				forvalues z = 1/`out_nodes_3_cnt' {
					local node_out : word `z' of `out_nodes_3'
					di "`node_out'"
					file write outfile _tab _tab _tab _tab `""`node_out'";"' _n	
				}
				file write outfile _tab _tab _tab "}" _n
				} // close conditional for level 3
			} // Close level 3		
			file write outfile _tab _tab "}" _n 
		} // close conditional for level 2 	
	} // Close level 2
	file write outfile _tab "}" _n 
}	// Close level 1	
}
				
		
		

* Build the edges
if `showedges' {
	use `edges', replace 
	local cnt = _N
	forvalues i = 1/`cnt' {	
		local pred = predictor[`i']
		local outc = outcome[`i']
		* Add this back once the group structure is built
		file write outfile `"	"`pred'"->"`outc'";"' _n
	}
}
	
* Close the file
file write outfile "}"	
file close outfile		

end
