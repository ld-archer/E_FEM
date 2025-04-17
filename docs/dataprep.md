# Data Preparation

On this page, I will list the key scripts and provide some more information on each.

## Generating Input Populations

### H_ELSA_long.do

Harmonises the disparate ELSA files into a single .dta file named ELSA_long.dta. Each subsequent data release on the UK Data Service is associated with a specific version of the H_ELSA_long.do file, which can be accessed on the g2aging.org website.

### reshape_long.do

Reshape and filter the harmonised dataset to produce a long version with just the variables we require (ELSA_long.dta). We also generate lots of additional variables we are interested in as well as the lagged variables, all named l2{var} to signify the 2 year lag. Be aware that the script is currently (Sep 2024) using a harmonised datafile that is has been modified to add some additional variables that have not been harmonised (H_ELSA_g2_wv_specific.dta). The additional variables include Government Office Region (GOR), social contact variables for loneliness and social isolation models, and an attempt to produce a variable for alcohol consumption in units.
When adding new variables into the model, this is the first script to modify. Be aware that variables can have different prefixes to determine the source of the variable, such as r for respondent, h for household, s for spouse and others.

### generate_stock_pop.do

Generates the stock population datafiles (of which there are multiple, but they use the same format - ELSA_stock*.dta). This script is very simple, as all it does is grab specific waves and saves them to use as starting populations for different simulations. The important thing that happens here, is that it also runs the imputation script called kludge.do.

### kludge.do

*kludge - Any construction or practice, typically inelegant, designed to solve a problem temporarily or expediently.*

This script runs lots of imputations on the stock datafiles, to ensure that these files do not contain any missing data in important variables. This is necessary as the simulation fails if it encounters any missing value in variables used in the transition models. There are a few types of imputation employed here:

- hotdecking
- Forward or backward filling from/to lag variable
- Mean imputation
- Set value 1 or 0 (for binary vars)

Setting a value is only used as a last resort, when there are only a few records still missing after running through hotdecking and forward/backward filling. I do not know why some of these records are still missing after the hotdeck but the numbers are always so small its not worth the hassle.

### generate_replenishing_pop.do

This script produces the replenishing populations for every wave (2 year period) from 2012 to 2082. Replenishing populations for each wave consist of the 51 and 52 year old respondents from 2010, 2012, and 2014, however with birth years and year of entry modified to fit the year they are included into the model.

### generate_transition_pop.do

Generates the transition population (ELSA_transition.dta). This population is used to fit the transition models to later in the pipeline. It is a fairly simple script, generating a couple of variables required like age splines and some dummys.

## Transition Probabilities

### Transitions

This section will mention the scripts used in estimating transition models for the simulation.

### ELSA_init_transitions.do

This is the main script that will run through estimation of all the transition models, although it is supported by other scripts. It is organised in multiple sections:

- Set up Directories
- Use Data and Recode - This is where we include the covariate definitions (separate one for each scenario set). These scripts are named ELSA_covariate_definitions*.do. We also include the sample selections from ELSA_sample_selections.do More info on both these scripts below
- Binary Outcomes - Fit Probit models to binary outcomes
- OLS Regression - OLS regression for the continuous vars
- Count models - poisson models for counts
- Ordered Outcomes - oprobit (Ordered Probit) for ordered outcomes
- Unordered Outcomes - mlogit (Multinomial Logit) for unordered outcomes
- Write models to file - Save models as .ster files in FEM\_Stata/Estimates

### ELSA_covariate_definitions*.do

These scripts are the control point for specifying transition models and their predictors. All dependent variables are listed at the top and organised into categories by their transition model type (i.e. binary health variable, count variable). Most of the rest of the script is dedicated to specifying the transition models for each dependent variable listed at the top, as well as creating some variable groups to make the specifications more readable.

In most cases, the predictors were chosen based on both literature and "common sense" (maybe better described as personal opinion). Sometimes a key piece of literature is included next to a variable to show where certain decisions came from, although this hasn't been done for everyone.

One important thing to mention here, is that the script ELSA_covariate_definitionsminimal.do is set up to specify the models for the "minimal" model run. This means that every transition model includes only gender and age as predictors.

### ELSA_sample_selections.do

The sample selections for each model are fairly simple and mostly fit 2 rules. PREVALENCE models are fit on every individual who is not dead. These variables can change each wave and have no set rules for how they can transition (e.g. logatotb - wealth). INCIDENCE models are fit on individuals who are not dead and have not previously had the variable. These variables are in an absorbing state, so once they are triggered can never revert back to their original state. For example, chronic disease variables such as hibpe (hypertension). These variables relate to "has a doctor ever told you you have X condition?". If an individual has ever been told they have hypertension, this can never "unhappen".

Some variables have some more complicated rules for who be included in the sample, and these are written below the prevalence and incidence models. For example, the logbmi model includes individuals from waves 2,4,6,8,9. This is because the logbmi variable is only included in ELSA for these waves.

## Saving Estimates

### save_est_cpp.do

This script takes the binary estimation objects created during the transitions phase (.ster files) and spits them out in plain text to be used in the simulation (.est files). Custom code has been written in the C++ files to be able to read in model specifications in plain text and use them for predictions. Plain text files are saved in the Estimates directory (in a subdirectory).

Of note here is that this script uses a custom stata function written by the American team, named save_eststore_txt. This package has to be installed into the local stata installation.

## Summary Output Generation

Not to be confused with actually generating summary outputs, this step is where we create some files that indicate what summary output measures the model should produce.

### summary_output_gen.do

This script runs in conjunction with measures_subpop_ELSA.do which will be discussed more below. In brief, it takes the summary measures listed in measures_subpop_ELSA.do and writes them to a text file to be used by the simulation. It also specifies some of the selection logic for the sub-populations we want to produce summary measures for, e.g. 55-64 year olds are age>54 & and age<65.

### measures_subpop_ELSA.do

Here is where the bulk of the output measures are listed. In a local variable named "measures", there are lots of variables with a prefix added. Here is what the prefixes mean (also listed at top of script):

- p_var -> variable prevalence  	(ex. p_diabe is the prevalence of diabetes)
- i_var -> variable incidence   	(ex. i_diabe is the incidence of diabetes)
- n_var -> variable total (count)	(ex. n_diabe is the number of individuals with diabetes)
- t_var -> variable total (cost)	(ex. t_totmd is the total medical costs)
- a_var -> average		(ex. a_totmd is the average medical cost)
- qnum_var -> quintile  		(ex. q05_totmd -> fifth percentile of total medical costs)
- d_age -> average death age	(ex. d_age_blk is the average age of those who died, requires ldied ==0 & ldied == 1)
- m_startpop -> count (millions)	(ex. m_startpop -> starting population in millions
- m_endpop -> count (millions)	(ex. m_endpop -> ending population in millions

## Simulation Settings

Simulation relies on a couple of files to specify where to find the input data, which scenarios to run and what variables to transition in each scenario, whether to run an intervention, whole population or cohort run etc.

### ELSA_*.settings.txt

This file contains a lot of the configurations for each run. Information like where to find the scenarios file (ELSA_*.csv), the variable definitions file (ELSA_vars.txt), input data directory, summary output variables (summary_output_ELSA_*.txt), which variables to include in any detailed outputs, and some other less important parameters.

### ELSA_*.csv

The scenarios csv file is a very important file which specifies a lot of important information. Each row in this file below the header specifies a scenario to run with all the information on what variables to transition (categorised to things like binary\_health, continuous etc.), whether to run an intervention and any parameters associated (such as eligibile group and "strength" of intervention, whether it is a cohort or replenishing run, and more.

Important Categories:

- base_cohort_name :: Specify the base cohort. For cohort runs this will be ELSA_repl (or some version of), and for whole pop runs will be ELSA_stock. (Note for cohort runs the "new_cohort_model" points to 'status_quo', which means no replenishment. For whole pop this should be ELSA_repl).
- nreps :: How many runs to complete per scenario. Publication level results should be based on 100 runs minimum.
- interventions (and init_interventions) :: Specify an intervention to run in this scenario. Requires additional columns to add parameters for the intervention. EXAMPLE:
- interventions == PDiedMult :: P - modify probability; Died - target mortality; Mult - apply a multiplication factor. Altogether, modify probability of mortality using a multiplication factor.
- ADDITIONAL COLUMN - mult_pdied :: multiplication factor to modify mortality probability
- ADDITIONAL COLUMN - elig_mult_pdied :: Who is eligible for the intervention? 'all_pop' obviously indicates the whole pop, and smaller subgroups can be targeted.
- condlist :: chronic conditions to transition
- ordered :: ordered variables to transition
- continuous :: continuous variables to transition
- detailed\_output :: Whether to produce detailed output
- elsa_data :: A binary switch to indicate that this simulation is using ELSA data
