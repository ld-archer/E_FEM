# -*- coding: utf-8 -*-
"""
Created Tue 10 December

@author: Luke Archer
            l.archer@leeds.ac.uk

Converting the original reshape_long.do Stata file to Python.
"""

import pandas as pd
import re

# Convert this line later (when I figured out how to do it after converting the rest of the script)
# quietly include ../../../fem_env.do

# Read in the Stata data file
# TODO: Check if the Harmonised ELSA dataset is available in any other format (i.e. csv)
print('Reading in datafile...')
H_ELSA = pd.read_stata("../../../input_data/H_ELSA.dta")
print('File read')

# Assign values for first and last wave
# TODO: Use the newly harmonized dataset that includes wave 8
firstwave = 1
lastwave = 7

"""
Variables from Harmonized ELSA:

Section A: Demographics, Identifiers, and Weights::
Person unique ID; CoupleID number; Spouse unique ID;
Interview status (morbidity); Stratification variable; 
Clustering variable; Person-level cross-sectional weight; 
Individual interview year; Individual interview month; Birth year; 
Death year; Age at interview (years); Gender; Education (categ).

Section B: Health::
ADLs. Some difficulty:
Walking across room; Dressing; Bathing/Shower; Eating;
Getting in/out of bed; Using the toilet.

IADLs. Some difficulty:
Using a map; Using a telephone; Managing money; 
Taking Medications; Shopping for groceries;
Preparing a hot meal; Doing work around the house or garden.

Doctor diagnosed health problems. Ever have condition:
High blood pressure; Diabetes; Cancer; Lung Disease;
Heart problems; Stroke; Psychological problems; 
Arthritis, Asthma, Parkinson's disease.

Height, Weight, BMI:
Height in meters; Weight in kilograms; BMI

Health Behaviours:
Smoke ever; Smoke now; How many cigs per day (avg);
Exercise(vigorous, moderate, light); Drinking ever;
# days/week drinks; # drinks/week.

Whether Health Limits Work.

Section E Financial and Housing Wealth::
Net Value of Non-Housing Financial Wealth;

Section F: Income and Consumption::
Individual employment earnings; Public pension income;
"""

# Dropping the longitudinal sample weights
H_ELSA.drop(list(H_ELSA.filter(regex='r.lwtresp')), axis=1, inplace=True)

# Keep these variables using exact name from harmonized ELSA
keep_cols = ['idauniq',
             'raclust',
             'rabyear',
             'radyear',
             'ragender',
             'raeduc_e',
             'raeducl']

# Following list contains column names that have to be expanded before filtering the original H_ELSA dataset
# This is because it was tricky to filter the dataframe using a combination of names and regex's
# Therefore, the following names are all expanded to the format r[1-7]<name>
expand_cols = ['iwstat',
               'strat',
               'cwtresp',
               'iwindy',
               'iwindm',
               'agey',
               'walkra',
               'dressa',
               'batha',
               'eata',
               'beda',
               'toilta',
               'mapa',
               'phonea',
               'moneya',
               'medsa',
               'shopa',
               'mealsa',
               'housewka',
               'hibpe',
               'diabe',
               'cancre',
               'lunge',
               'hearte',
               'stroke',
               'psyche',
               'arthre',
               'bmi',
               'smokev',
               'smoken',
               'smokef',
               'work',
               'hlthlm',
               'arthre',
               'psyche',
               'asthmae',
               'parkine',
               'retemp',
               'retage',
               'ipubpen',
               'itearn',
               'vgactx_e',
               'mdactx_e',
               'ltactx_e',
               'drink',
               'drinkd_e',
               'drinkwn_e']

# Expand idauniq to generate column names for spouse idauniq for each wave (idauniq is the only spouse var we keep)
for x in range(firstwave, lastwave):
    new_name = 's' + str(x) + 'idauniq'
    keep_cols.append(new_name)

# Expand coupid and atotf to generate colnames for household variables
household_vars = ['coupid', 'atotf']
for var in household_vars:
    for x in range(firstwave, lastwave):
        new_name = 'h' + str(x) + var
        keep_cols.append(new_name)

# Expand all columns in expand_cols to generate colnames for each wave
for col in expand_cols:
    for x in range(firstwave, lastwave):
        new_name = 'r' + str(x) + col
        keep_cols.append(new_name)

# Not all variables exist for every wave (i.e. BMI data only collected on waves 2, 4, & 6
# Therefore we need to remove some items from keep_cols before we use it to filter the H_ELSA dataframe
missing = ['r1bmi', 'r3bmi', 'r5bmi', 'r1drinkd_e', 'r1drinkwn_e', 'r2drinkwn_e', 'r3drinkwn_e', 'r3strat', 'r4strat', 'r5strat', 'r6strat', 'r1hlthlm', 'r2cwtresp']

# Now remove the missing variables from keep_cols
for var in missing:
    keep_cols.remove(var)

# Now keep only keep_cols in the original dataset. Leaving print checks here for checking in future
print('\nThere are {} columns in H_ELSA'.format(len(H_ELSA.columns)))
print('Filtering out unnecessary columns')
H_ELSA = H_ELSA[keep_cols]
print('There are now {} columns in H_ELSA after filtering out the unnecessary columns'.format(len(H_ELSA.columns)))


def rename_all_cols(colname):
    """
    This function takes a column name in the format (<r|h><wavenum><name>), and renames it as (<name><wavenum>)
    :param colname: Column name from H_ELSA
    :return: Renamed column name in specified format
    """
    # if colname.isalpha() == False, then colname contains a number
    # Only want to rename columns that contain a number i.e. r1agey to agey1
    if not colname.isalpha():
        # colname is in the format r<wavenum><name>; we want to change this to <name><wavenum>
        wavenum = colname[1]
        new_colname = colname[2:] + wavenum
        return new_colname
    else:
        return colname


# Now rename all variables to make the reshape easier and have names consistent with the US FEM
# The pandas df.rename() function can accept a function
H_ELSA.rename(columns=rename_all_cols, inplace=True)

print(list(H_ELSA.columns))

# Now onto the reshape, this might be tricky
# This: http://www.danielmsullivan.com/pages/tutorial_stata_to_python.html contains some useful information here
# Python/Pandas functions that work similarly to reshape are stack and unstack

