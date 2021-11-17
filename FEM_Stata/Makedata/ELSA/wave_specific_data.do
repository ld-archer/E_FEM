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
        keep idauniq scako scal7a scal7b scdrspi scdrwin scdrpin GOR
    }
    if `wv' == 7 | `wv' == 8 {
        keep idauniq scako scal7a scal7b scdrspi scdrwin scdrpin gor
        * Rename for consistency
        rename gor GOR
    }
    else if `wv' == 9 {
        keep idauniq scalcm scalcy scalcd scsprt scwine scbeer GOR
        * Rename for consistency
        rename scsprt scdrspi
        rename scwine scdrwin
        rename scbeer scdrpin
        rename scalcm scako
        rename scalcy scal7a
        rename scalcd scal7b
    }
    else if `wv' == 1 {
        keep idauniq gor heala
        rename gor GOR
    }
    else if `wv' == 2 {
        keep idauniq gor scako scal7a scal7b
        rename gor GOR
    }
    else if `wv' == 3 {
        keep idauniq GOR scako scal7a scal7b
    }

    * Can infer abstainers from waves 1-3 but not much else
    if `wv' == 1 {
        gen r1alcbase = .
        replace r1alcbase = 0 if heala == 6
    }

    if `wv' == 2 | `wv' == 3 {
        gen whether_abstainer = 1 if scako == 8 /* scako == 8 is not at all in last 12 months */
        replace whether_abstainer = 1 if scal7a == 2 /* scal7a == 2 is not drank in last 7 days */
        replace whether_abstainer = 0 if inlist(scako, 1, 2, 3, 4) /* These are ranging from drank every day to once or twice a week */
        replace whether_abstainer = 0 if scal7a == 1  /* scal7a == 1 is drank in last 7 days */
        replace whether_abstainer = 0 if scal7b >= 1 /* scal7b is how many days drinking alcohol in past week, so 1+ is not abstainer */
        
        gen r`wv'alcbase = .
        replace r`wv'alcbase = 0 if whether_abstainer == 1
    }

    * Do all the alcohol stuff for wave 4 onwards
    if `wv' > 3 {
        * Now calculate units from each of beer, wine and spirits using NHS values from following link
        * https://www.nhs.uk/live-well/alcohol-support/calculating-alcohol-units/
        * (assuming a pint of beer is 5%)
        gen unitspirit = scdrspi * 1 if scdrspi >= 0
        gen unitwine = scdrwin * 2.1 if scdrwin >= 0
        gen unitbeer = scdrpin * 2.8 if scdrpin >= 0

        * Use info from scako (how often drank in last 12 months) & scal7a (whether drank in last 7 days) together to paint whole picture
        gen whether_abstainer = 1 if scako == 8 /* scako == 8 is not at all in last 12 months */
        replace whether_abstainer = 1 if scal7a == 2 /* scal7a == 2 is not drank in last 7 days */
        replace whether_abstainer = 0 if inlist(scako, 1, 2, 3, 4) /* These are ranging from drank every day to once or twice a week */
        replace whether_abstainer = 0 if scal7a == 1 /* scal7a == 1 is drank in last 7 days */
        replace whether_abstainer = 0 if scal7b >= 1 /* scal7b is how many days drinking alcohol in past week, so 1+ is not abstainer */

        * Now add them all together for total units in past week
        gen alcbase = .
        replace alcbase = 0 if !missing(unitspirit)
        replace alcbase = 0 if !missing(unitwine)
        replace alcbase = 0 if !missing(unitbeer)
        replace alcbase = 0 if whether_abstainer == 1
        replace alcbase = alcbase + unitspirit if !missing(unitspirit)
        replace alcbase = alcbase + unitwine if !missing(unitwine)
        replace alcbase = alcbase + unitbeer if !missing(unitbeer)
        
        * Handle some weird floating point issues, some values coming out as xx.799999 for example when should just be .8
        replace alcbase = round(alcbase, 0.1)

        * drop everything else now, don't need it
        *drop scdr* unit* scal7a scako whether_abstainer

        rename scdr* r`wv'scdr*
        rename unit* r`wv'unit*
        rename scako r`wv'scako
        rename whether_abstainer r`wv'whether_abstainer

        * Now rename alc var to be wave based
        rename alcbase r`wv'alcbase

    }

    * also rename GOR to be wave based
    rename GOR r`wv'GOR
    
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

