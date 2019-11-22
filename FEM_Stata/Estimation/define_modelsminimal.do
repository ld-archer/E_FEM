/*****************************************************************************************************************************************/
/*** Covariates used in init_transition.do ***/ 

/*** binary outcomes - probit - bin_econ ***/

foreach n of varlist $bin_econ{
		global allvars_`n' $dvars l2age65l l2age6574 l2age75p
	}

/*** binary outcomes - probit - bin_hlth ***/
foreach n of varlist $bin_hlth{
		global allvars_`n' $dvars l2age65l l2age6574 l2age75p
	}

/*** single stage model - OLS ***/

global allvars_tcamt_cpl $dvars l2age65l l2age6574 l2age75p
global allvars_ihs_tcamt_cpl $dvars l2age65l l2age6574 l2age75p

global allvars_helphoursyr $dvars l2age65l l2age6574 l2age75p
global allvars_helphoursyr_nonsp $dvars l2age65l l2age6574 l2age75p
global allvars_helphoursyr_sp $dvars l2age65l l2age6574 l2age75p

global allvars_logbmi $dvars l2age65l l2age6574 l2age75p

/*** ordered outcomes - oprobit ***/

foreach n of varlist $order{
	global allvars_`n' $dvars l2age65l l2age6574 l2age75p 
}
/*** capital income - OLS ***/
global allvars_hicap $dvars l2age65l l2age6574 l2age75p
global allvars_igxfr $dvars l2age65l l2age6574 l2age75p
global allvars_proptax $dvars l2age65l l2age6574 l2age75p

global allvars_volhours $dvars l2age65l l2age6574 l2age75p
global allvars_parhelphours $dvars l2age65l l2age6574 l2age75p
global allvars_gkcarehrs $dvars l2age65l l2age6574 l2age75p


/*****************************************************************************************************************************************/
/**** ADJUST COVARIATES FOR MODELS IN PROGRAM ghreg_estimations.do ****/

takestring, oldlist($allvars_econ1) newname("allvars_iearn")  extlist("l2age75p")

*Bryan's addition for uncapping income model
takestring, oldlist($allvars_econ1) newname("allvars_iearnuc")  extlist("l2age75p")
disp "$allvars_iearnuc"
global allvars_iearnuc $allvars_iearnuc llogiearnuc flogiearnuc
disp "$allvars_iearnuc"	

takestring, oldlist($allvars_econ3) newname("allvars_hatota")  extlist("")
