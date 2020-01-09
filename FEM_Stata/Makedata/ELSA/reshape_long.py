# -*- coding: utf-8 -*-
"""
Created Tue 10 December

@author: Luke Archer
            l.archer@leeds.ac.uk

Converting the original reshape_long.do Stata file to Python.
"""

import pandas as pd
# import re

# Convert this line later (when I figured out how to do it after converting the rest of the script)
# quietly include ../../../fem_env.do

print('Reading in datafile...')
H_ELSA = pd.read_stata("../../../input_data/H_ELSA.dta")
print('File read')

firstwave = 1
lastwave = 7

# print('Dropping variables related to spouse')
# H_ELSA.drop(str.startswith(str('s')))
# print('Spouse variables removed')

# print('There are {} columns in H_ELSA before dropping r.lwtresp'.format(len(H_ELSA.columns)))
# Dropping the longitudinal sample weights
H_ELSA.drop(list(H_ELSA.filter(regex='r.lwtresp')), axis=1, inplace=True)
# print('There are {} columns in H_ELSA after dropping r.lwtresp'.format(len(H_ELSA.columns)))

print("\nRegex=id.....:")
print(H_ELSA.filter(regex='id.....'))

print("\nregex=idauniq:")
print(H_ELSA.filter(regex='idauniq'))

"""
print('There are {} columns in H_ELSA before dropping idauniq'.format(len(H_ELSA.columns)))

H_ELSA.drop(labels='idanuiq', axis=1)

print('There are {} columns in H_ELSA after dropping idanuiq'.format(len(H_ELSA.columns)))

# Keep only these variables from harmonized ELSA
important_cols = ['idanuiq',
                  'raclust',
                  'rabyear',
                  'radyear',
                  'ragender',
                  'raeduc_e',
                  'raeducl']

print('There are {} columns in H_ELSA before dropping important_cols'.format(len(H_ELSA.columns)))

H_ELSA.drop(columns=important_cols)

print('There are {} columns in H_ELSA before dropping important_cols'.format(len(H_ELSA.columns)))
""""""
regex_cols = ['s.idanuiq',
              'h.coupid',
              'r.iwstat',
              'r.strat',
              'r.cwtresp',
              'r.iwindy',
              'r.iwindm',
              'r.agey',
              'r.walkra',
              'r.dressa',
              'r.batha',
              'r.eata',
              'r.beda',
              'r.toilta',
              'r.mapa',
              'r.phonea',
              'r.moneya',
              'r.medsa',
              'r.shopa',
              'r.mealsa',
              'r.housewka',
              'r.hibpe',
              'r.diabe',
              'r.cancre',
              'r.lunge',
              'r.hearte',
              'r.stroke',
              'r.psyche',
              'r.arthre',
              'r.bmi',
              'r.smokev',
              'r.smoken',
              'r.smokef',
              'r.work',
              'r.hlthlm',
              'r.arthre',
              'r.psyche',
              'r.asthmae',
              'r.parkine',
              'r.retemp',
              'r.retage',
              'r.ipubpen',
              'r.itearn',
              'r.atotf',
              'r.vgactx_e',
              'r.mdactx_e',
              'r.ltactx_e',
              'r.drink',
              'r.drinkd_e',
              'r.drinkwn_e']

test_list = [r'r*parkine',
             r'r*retemp']

print('There are {} columns in H_ELSA'.format(len(H_ELSA.columns)))

print('Keeping the columns that dont have regexs')
# Now keep only the columns listed above
# H_ELSA_temp = H_ELSA[important_cols]

print('Trying the regexs, fingers crossed!')
keep_cols = []
for reg in regex_cols:
    keep_col = H_ELSA.filter(axis=1, regex=reg)
    # print(str(keep_col.columns))
    keep_cols.append(keep_col)

# H_ELSA_reg = H_ELSA.filter(regex=test_list)

print('There are {} columns in keep_cols'.format(len(keep_cols)))

print(keep_cols)

# print(H_ELSA_test.columns())
"""
