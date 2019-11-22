clear


use input_data/baseline_diabe.dta

rename p_diabe_all baseline_diabe
label variable baseline_diabe `"No intervention"'

merge 1:1 year using input_data/baseline_diabe03.dta

drop _merge

rename p_diabe_all diabe03
label variable diabe03 `"30% Reduction"'

merge 1:1 year using input_data/baseline_diabe06.dta

drop _merge

rename p_diabe_all diabe06
label variable diabe06 `"60% Reduction"'

twoway scatter *diabe* year


save input_data/diabetes_data.dta, replace

graph save Graph "/home/ld-archer/Documents/UK_FEM/trunk/output/Graphs/Diabetes_intervention_graph.gph"
