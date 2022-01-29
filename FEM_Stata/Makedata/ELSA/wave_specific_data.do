/*
This script will add data to the harmonised data file that only exists in wave specific files.

It has been created specifically to calculate the consumption of alcohol in units rather 
than number of drinks, which is reported in the harmonised data and is less useful.
Additionally, this script will add Government Office Region to each idauniq at each wave,
which could be important for having some spatial information attached to each respondent.

Created: 4/11/21
Author: Luke Archer
        l.archer@leeds.ac.uk

Assuming that the wide format harmonised ELSA data file has already been read into memory in
the reshape_long script, and that we are running this therefore from the FEM_Stata/Makedata/ELSA
directory.
*/

/*
For wave 2-3, drinks variables are only recorded for heaviest day in the past 7 weeks.
Therefore not useful, impute these instead.

From wave 4-8, drinks variables are called:
`scdrspi': Number of measures of spirits the respondent had last in the last 7 days (not my bad grammar, copied from variable label)
`scdrwin': Number of glasses of wine the respondent had last in the last 7 days
`scdrpin': Number of pints of beer the respondent had last in the last 7 days

Wave 9, drinks variables are called:
`scsprt': Measures of spirits the respondent had in the last 7 days
`scwine': Glasses of wine the respondent had in the last 7 days
`scbeer': Pints of beer the respondent had in the last 7 days
*/

clear
set maxvar 15000
log using wave_specific_data.log, replace

clear
set maxvar 15000
log using wave_specific_data.log, replace

quietly include ../../../fem_env.do


*** IMPORTANT
* Reset the wv_specific H_ELSA file before this starts so we don't keep adding information
use $outdata/H_ELSA_g2.dta, replace
save $outdata/H_ELSA_g2_wv_specific.dta, replace

clear

forvalues wv = 1/9 {

    * Handle the discrepancies in version number in filename (god this is stupid isn't it)
    if `wv' == 1 | `wv' == 4 {
        local version 3
    }
    else if `wv' == 2 | `wv' == 3 | `wv' == 5 {
        local version 4
    }
    else if `wv' == 6 | `wv' == 8 {
        local version 2
    }
    else if `wv' == 9 {
        local version 1
    }

    * Load in wave specific file (wave 7 has no version number, more stupid)
    if `wv' == 1 | `wv' == 2 {
        use $outdata/wave_specific/wave_`wv'_core_data_v`version'.dta, replace
        *use ../../../input_data/wave_specific/wave_`wv'_core_data_v`version'.dta, replace
    }
    else if `wv' == 3 | `wv' == 4 | `wv' == 5 | `wv' == 6 {
        use $outdata/wave_specific/wave_`wv'_elsa_data_v`version'.dta, replace
        *use ../../../input_data/wave_specific/wave_`wv'_elsa_data_v`version'.dta, replace
    }
    else if `wv' == 7 {
        use $outdata/wave_specific/wave_`wv'_elsa_data.dta, replace
        *use ../../../input_data/wave_specific/wave_`wv'_elsa_data.dta, replace
    }
    else if `wv' == 8 | `wv' == 9 {
        use $outdata/wave_specific/wave_`wv'_elsa_data_eul_v`version'.dta, replace
        *use ../../../input_data/wave_specific/wave_`wv'_elsa_data_eul_v`version'.dta, replace
    }
    
    * Now keep only idauniq and the drinks variables (wave 9 names are different) and GOR
    * (stupidity knows no bounds here - gor/GOR come on)
    if `wv' > 3 & `wv' < 7 {
        keep idauniq scako scdrspi scdrwin scdrpin GOR
    }
    if `wv' == 7 | `wv' == 8 {
        keep idauniq scako scdrspi scdrwin scdrpin gor
        * Rename for consistency
        rename gor GOR
    }
    else if `wv' == 9 {
        keep idauniq scalcm scsprt scwine scbeer GOR
        * Rename for consistency
        rename scsprt scdrspi
        rename scwine scdrwin
        rename scbeer scdrpin
        rename scalcm scako
    }
    else if `wv' == 1 {
        keep idauniq gor heala
        rename gor GOR
    }
    else if `wv' == 2 {
        keep idauniq gor scako
        rename gor GOR
    }
    else if `wv' == 3 {
        keep idauniq GOR scako
    }

    * Rename vars to be wave specific
    rename GOR r`wv'GOR

    if `wv' > 3 {
        rename scdr* r`wv'scdr*
    }
    
    if `wv' == 1 {
        merge 1:1 idauniq using $outdata/H_ELSA_g2.dta, nogenerate update replace
        *merge 1:1 idauniq using ../../../input_data/H_ELSA_g2.dta, nogenerate update
    }
    else if `wv' > 1 {
        merge 1:1 idauniq using $outdata/H_ELSA_g2_wv_specific.dta, nogenerate update replace
        *merge 1:1 idauniq using ../../../input_data/H_ELSA_g2_wv_specific.dta, nogenerate update
    }
    
    
    save $outdata/H_ELSA_g2_wv_specific.dta, replace
    *save ../../../input_data/H_ELSA_g2_wv_specific.dta, replace
}

capture log close
