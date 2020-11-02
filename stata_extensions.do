/* Extensions to Stata used in the Makedata and Estimation.  New extensions should be added here, not in individual .do files.

*/

ssc install xml_tab, replace
ssc install estout, replace
ssc install mfx2, replace
ssc install hotdeck, replace
ssc install matsave, replace
ssc install csipolate, replace
ssc install outtex, replace
ssc install listtex, replace
ssc install tabout, replace
ssc install descsave, replace
ssc install hotdeck, replace
ssc install listtab, replace
ssc install nrow, replace
do FEM_Stata/utilities/cmp.mata

shell touch stata_extensions.txt
