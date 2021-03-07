# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

#LOAD THE PACKAGES

import os
import matplotlib as mpl
import geopandas as gpd
import pandas as pd
import numpy as np

# LOAD THE SHAPEFILES
os.chdir("/Users/jen/jen/datakind/march2021datadive/testdata/ethiopia_shape")
eth_01_country = gpd.read_file("eth_admbnda_adm0_csa_bofed_20201008.shp")
eth_02_region = gpd.read_file("eth_admbnda_adm1_csa_bofed_20201008.shp")
eth_03_zone = gpd.read_file("eth_admbnda_adm2_csa_bofed_20201008.shp")
eth_04_woreda = gpd.read_file("eth_admbnda_adm3_csa_bofed_20201027.shp")

eth_01_country.plot()
eth_02_region.plot()
eth_03_zone.plot()
eth_04_woreda.plot()

# LOAD THE CHICKEN
os.chdir("/Users/jen/jen/datakind/march2021datadive/testdata")
livestock = pd.read_csv('sect10d1_hh_w4_livestock.csv') 
# data dic https://microdata.worldbank.org/index.php/catalog/3823/data-dictionary/F22?file_name=sect10d1_hh_w4.dta

# PREP THE CHICKEN BY REGION
chicken = livestock[livestock['livestock_cd']=='513. Chicken']
 
chicken_by_region = pd.pivot_table(chicken, values='s10dq02', index='saq01', 
                               aggfunc=np.sum).reset_index()

chicken_by_region.rename(columns = {'s10dq02':'nr_chicken'}, inplace = True)

# PREP THE MERGE
chicken_by_region['region'] = chicken_by_region['saq01'].str.split('.').str[1]
chicken_by_region['region'] = chicken_by_region['region'].str.lstrip()
chicken_by_region['region'] = chicken_by_region['region'].str.lower()
chicken_by_region = chicken_by_region[['region', 'nr_chicken']]
eth_02_region['region']=eth_02_region['ADM1_EN'].str.lower()


# DO THE MERGE
regional_chicken = eth_02_region.merge(chicken_by_region, 
                                       left_on='region', right_on='region',
                                       how='outer', indicator = True)

regional_chicken['_merge'].value_counts()

# VIZUALIZE THE CHICKEN BY REGION
regional_chicken = regional_chicken[regional_chicken['_merge']!='right_only']
regional_chicken.plot(column='nr_chicken', cmap='Reds', 
                      legend = True)



# TRY TO MERGE FUZZY
def fuzzy_merge(df_1, df_2, key1, key2, threshold=90, limit=2):
    """
    :param df_1: the left table to join
    :param df_2: the right table to join
    :param key1: key column of the left table
    :param key2: key column of the right table
    :param threshold: how close the matches should be to return a match, based on Levenshtein distance
    :param limit: the amount of matches that will get returned, these are sorted high to low
    :return: dataframe with boths keys and matches
    """
    s = df_2[key2].tolist()
    
    m = df_1[key1].apply(lambda x: process.extract(x, s, limit=limit))    
    df_1['matches'] = m
    
    m2 = df_1['matches'].apply(lambda x: ', '.\
                               join([i[0] for i in x if i[1] >= threshold]))
    df_1['matches'] = m2
    
    return df_1

from fuzzywuzzy import fuzz
from fuzzywuzzy import process

fuzzy_chicken = fuzzy_merge(eth_02_region, chicken_by_region,
                             'region', 'region', 
                             threshold=90, limit=1)

fuzzy_chicken = fuzzy_chicken.merge(chicken_by_region, how='outer',
                                      left_on='matches', 
                                      right_on='region',
                                      indicator=True)

fuzzy_chicken['_merge'].value_counts()


# VISUALIZE FUZZY MERGE
fuzzy_chicken = fuzzy_chicken[fuzzy_chicken['_merge']!='right_only']
fuzzy_chicken.plot(column='nr_chicken', cmap='Reds', 
                      legend = True)



