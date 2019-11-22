/** Set or changes e(_estimates_title) in the current estimation.
The xml_tab packages uses e(_estimates_title) to label a column 
that spans all columns of the estimation results. This program 
allows you to customize labels before writing estimations with 
xml_tab.
Usage: 
. ch_est_title "New Label"
will assign "New Label" to the current e(_estimates_title)
*/
program ch_est_title, eclass
ereturn local _estimates_title `0'
end
