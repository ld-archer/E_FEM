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
    if `wv' == 1 {
        keep idauniq gor heala scchd scchdg scchdh scchdi scfam scfamg scfami scfrd scfrdg scfrdh scfrdi
        rename gor GOR
    }
    else if `wv' == 2 {
        keep idauniq gor scako scchd scchdg scchdh scchdi scfam scfamg scfamh scfami scfrd scfrdg scfrdh scfrdi
        rename gor GOR
    }
    else if `wv' == 3 {
        keep idauniq GOR scako scchd scchdg scchdh scchdi scfam scfamg scfamh scfami scfrd scfrdg scfrdh scfrdi
    }
    else if `wv' == 4 {
        keep idauniq scako scdrspi scdrwin scdrpin GOR scchd scchdg scchdh scchdi scfam scfamg scfami scfrd scfrdg scfrdh scfrdi
    }
    else if `wv' == 5 {
        keep idauniq scako scdrspi scdrwin scdrpin GOR scchd scchdg scchdh scchdi scfam scfamg scfamh scfami scfrd scfrdg scfrdh scfrdi
    }
    else if `wv' == 6 {
        keep idauniq scako scdrspi scdrwin scdrpin GOR scchd scchdg scchdh scchdi scchdt scfam scfamg scfamh scfami scfamt scfrd scfrdg scfrdh scfrdi scfrdt
    }
    else if `wv' == 7 {
        keep idauniq scako scdrspi scdrwin scdrpin gor scchd scchdh scchdi scchdj scchdk scfam scfamh scfami scfamj scfamk scfrd scfrdh scfrdi scfrdj scfrdk
        * Rename for consistency
        rename gor GOR
        rename scchdh scchdg
        rename scchdi scchdh
        rename scchdj scchdi
        rename scchdk scchdt
        rename scfamh scfamg
        rename scfami scfamh
        rename scfamj scfami
        rename scfamk scfamt
        rename scfrdh scfrdg
        rename scfrdi scfrdh
        rename scfrdj scfrdi
        rename scfrdk scfrdt
    }
    else if `wv' == 8 {
        keep idauniq scako scdrspi scdrwin scdrpin gor scchd scchdh scchdi scchdj scchdk scfam scfamh scfami scfamj scfamk scfrd scfrdh scfrdi scfrdj scfrdk
        * Rename for consistency
        rename gor GOR
        rename scchdh scchdg
        rename scchdi scchdh
        rename scchdj scchdi
        rename scchdk scchdt
        rename scfamh scfamg
        rename scfami scfamh
        rename scfamj scfami
        rename scfamk scfamt
        rename scfrdh scfrdg
        rename scfrdi scfrdh
        rename scfrdj scfrdi
        rename scfrdk scfrdt
    }
    else if `wv' == 9 {
        keep idauniq scalcm scsprt scwine scbeer GOR scchd scchdh scchdi scchdj scchdk scfam scfamh scfami scfamj scfamk scfrd scfrdh scfrdi scfrdj scfrdk
        * Rename for consistency
        rename scsprt scdrspi
        rename scwine scdrwin
        rename scbeer scdrpin
        rename scalcm scako
        rename scchdh scchdg
        rename scchdi scchdh
        rename scchdj scchdi
        rename scchdk scchdt
        rename scfamh scfamg
        rename scfami scfamh
        rename scfamj scfami
        rename scfamk scfamt
        rename scfrdh scfrdg
        rename scfrdi scfrdh
        rename scfrdj scfrdi
        rename scfrdk scfrdt
    }
    

    * Rename vars to be wave specific
    rename GOR r`wv'GOR
    if `wv' > 1 {
        rename scako r`wv'scako
    }

    * Do all the alcohol stuff for wave 4 onwards
    if `wv' > 3 {
        * Now calculate units from each of beer, wine and spirits using NHS values from following link
        * https://www.nhs.uk/live-well/alcohol-support/calculating-alcohol-units/
        * (assuming a pint of beer is 5%)
        gen unitspirit = scdrspi * 1 if scdrspi >= 0
        gen unitwine = scdrwin * 2.1 if scdrwin >= 0
        gen unitbeer = scdrpin * 2.8 if scdrpin >= 0
        * Replace any missing values with 0 so it doesn't mess up the total
        replace unitspirit = 0 if missing(unitspirit)
        replace unitwine = 0 if missing(unitwine)
        replace unitbeer = 0 if missing(unitbeer)

        * Now add them all together for total units in past week
        gen alcbase = unitspirit + unitwine + unitbeer
        
        * Handle some weird floating point issues, some values coming out as xx.799999 for example when should just be .8
        replace alcbase = round(alcbase, 0.1)

        * drop everything else now, don't need it
        drop scdr* unit*

        * Now rename alc var to be wave based
        rename alcbase r`wv'alcbase
    }


    ****** Social Isolation Variables ******
    * Children (varname - kcntm : kids contact monthly)
    if `wv' <= 5 {
        gen kcntm = .
        replace kcntm = 0 if scchd == 2 /*No children*/
        replace kcntm = 1 if scchdg > 0 & scchdg < 4 & !missing(scchdg) /*Not missing & meet up at least once or twice a month*/
        replace kcntm = 0 if scchdg >= 4 & !missing(scchdg) /*meet up less than once or twice a month*/
        replace kcntm = 1 if scchdh > 0 & scchdh < 4 & !missing(scchdh) /*Not missing & speak on phone at least once or twice a month*/
        replace kcntm = 0 if scchdh >= 4 & !missing(scchdh) /*speak on phone less than once or twice a month*/
        replace kcntm = 1 if scchdi > 0 & scchdi < 4 & !missing(scchdi) /*Not missing & write/email at least once or twice a month*/
        replace kcntm = 0 if scchdi >= 4 & !missing(scchdi) /*Not missing & write/email less than once or twice a month*/

        rename kcntm r`wv'kcntm
    }
    else if `wv' >=6 {
        * Wave 6 onwards includes text
        gen kcntm = .
        replace kcntm = 0 if scchd == 2 /*No children*/
        replace kcntm = 1 if scchdg > 0 & scchdg < 4 & !missing(scchdg) /*Not missing & meet up at least once or twice a month*/
        replace kcntm = 0 if scchdg >= 4 & !missing(scchdg) /*meet up less than once or twice a month*/
        replace kcntm = 1 if scchdh > 0 & scchdh < 4 & !missing(scchdh) /*Not missing & speak on phone at least once or twice a month*/
        replace kcntm = 0 if scchdh >= 4 & !missing(scchdh) /*speak on phone less than once or twice a month*/
        replace kcntm = 1 if scchdi > 0 & scchdi < 4 & !missing(scchdi) /*Not missing & write/email at least once or twice a month*/
        replace kcntm = 0 if scchdi >= 4 & !missing(scchdi) /*Not missing & write/email less than once or twice a month*/
        replace kcntm = 1 if scchdt > 0 & scchdt < 4 & !missing(scchdt) /*Not missing & text at least once or twice a month*/
        replace kcntm = 0 if scchdt >= 4 & !missing(scchdt) /*Not missing & text less than once or twice a month*/

        rename kcntm r`wv'kcntm
    }
    * Relatives (varname - rcntm : relatives contact monthly)
    if inlist(`wv', 1, 4) {
        gen rcntm = .
        replace rcntm = 0 if scfam == 2 /*No relatives*/
        replace rcntm = 1 if scfamg > 0 & scfamg < 4 & !missing(scfamg) /*Not missing & meet up at least once or twice a month*/
        replace rcntm = 0 if scfamg >= 4 & !missing(scfamg) /*meet up less than once or twice a month*/
        replace rcntm = 1 if scfami > 0 & scfami < 4 & !missing(scfami) /*Not missing & write/email at least once or twice a month*/
        replace rcntm = 0 if scfami >= 4 & !missing(scfami) /*write/email less than once or twice a month*/

        rename rcntm r`wv'rcntm
    }
    else if inlist(`wv', 2, 3, 5) {
        gen rcntm = .
        replace rcntm = 0 if scfam == 2 /*No relatives*/
        replace rcntm = 1 if scfamg > 0 & scfamg < 4 & !missing(scfamg) /*Not missing & meet up at least once or twice a month*/
        replace rcntm = 0 if scfamg >= 4 & !missing(scfamg) /*meet up less than once or twice a month*/
        replace rcntm = 1 if scfami > 0 & scfami < 4 & !missing(scfami) /*Not missing & write/email at least once or twice a month*/
        replace rcntm = 0 if scfami >= 4 & !missing(scfami) /*write/email less than once or twice a month*/
        replace rcntm = 1 if scfamh > 0 & scfamh < 4 & !missing(scfamh) /*Not missing & speak on phone at least once or twice a month*/
        replace rcntm = 0 if scfamh >= 4 & !missing(scfamh) /*speak on phone less than once or twice a month*/

        rename rcntm r`wv'rcntm
    }
    else if inlist(`wv', 6, 7, 8, 9) {
        gen rcntm = .
        replace rcntm = 0 if scfam == 2 /*No relatives*/
        replace rcntm = 1 if scfamg > 0 & scfamg < 4 & !missing(scfamg) /*Not missing & meet up at least once or twice a month*/
        replace rcntm = 0 if scfamg >= 4 & !missing(scfamg) /*meet up less than once or twice a month*/
        replace rcntm = 1 if scfami > 0 & scfami < 4 & !missing(scfami) /*Not missing & write/email at least once or twice a month*/
        replace rcntm = 0 if scfami >= 4 & !missing(scfami) /*write/email less than once or twice a month*/
        replace rcntm = 1 if scfamh > 0 & scfamh < 4 & !missing(scfamh) /*Not missing & speak on phone at least once or twice a month*/
        replace rcntm = 0 if scfamh >= 4 & !missing(scfamh) /*speak on phone less than once or twice a month*/
        replace rcntm = 1 if scfamt > 0 & scfamt < 4 & !missing(scfamt) /*Not missing & text at least once or twice a month*/
        replace rcntm = 0 if scfamt >= 4 & !missing(scfamt) /*Not missing & text less than once or twice a month*/

        rename rcntm r`wv'rcntm
    }
    * Friends (varname - fcntm : friends contact monthly)
    if `wv' <= 5 {
        gen fcntm = .
        replace fcntm = 0 if scfrd == 2 /*No friends*/
        replace fcntm = 1 if scfrdg > 0 & scfrdg < 4 & !missing(scfrdg) /*Not missing & meet up at least once or twice a month*/
        replace fcntm = 0 if scfrdg >= 4 & !missing(scfrdg) /*meet up less than once or twice a month*/
        replace fcntm = 1 if scfrdh > 0 & scfrdh < 4 & !missing(scfrdh) /*Not missing & speak on phone at least once or twice a month*/
        replace fcntm = 0 if scfrdh >= 4 & !missing(scfrdh) /*speak on phone less than once or twice a month*/
        replace fcntm = 1 if scfrdi > 0 & scfrdi < 4 & !missing(scfrdi) /*Not missing & write/email at least once or twice a month*/
        replace fcntm = 0 if scfrdi >= 4 & !missing(scfrdi) /*Not missing & write/email less than once or twice a month*/

        rename fcntm r`wv'fcntm
    }
    else if `wv' >=6 {
        * Wave 6 onwards includes text
        gen fcntm = .
        replace fcntm = 0 if scfrd == 2 /*No friends*/
        replace fcntm = 1 if scfrdg > 0 & scfrdg < 4 & !missing(scfrdg) /*Not missing & meet up at least once or twice a month*/
        replace fcntm = 0 if scfrdg >= 4 & !missing(scfrdg) /*meet up less than once or twice a month*/
        replace fcntm = 1 if scfrdh > 0 & scfrdh < 4 & !missing(scfrdh) /*Not missing & speak on phone at least once or twice a month*/
        replace fcntm = 0 if scfrdh >= 4 & !missing(scfrdh) /*speak on phone less than once or twice a month*/
        replace fcntm = 1 if scfrdi > 0 & scfrdi < 4 & !missing(scfrdi) /*Not missing & write/email at least once or twice a month*/
        replace fcntm = 0 if scfrdi >= 4 & !missing(scfrdi) /*Not missing & write/email less than once or twice a month*/
        replace fcntm = 1 if scfrdt > 0 & scfrdt < 4 & !missing(scfrdt) /*Not missing & text at least once or twice a month*/
        replace fcntm = 0 if scfrdt >= 4 & !missing(scfrdt) /*Not missing & text less than once or twice a month*/

        rename fcntm r`wv'fcntm
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
