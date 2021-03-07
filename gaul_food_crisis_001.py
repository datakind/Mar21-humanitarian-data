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

# LOAD GAUL SHAPEFILE
os.chdir("/Users/jen/jen/datakind/march2021datadive/testdata/gaul1_asap")
gaul = gpd.read_file("gaul1_asap.shp")

# FILTER ETHIOPIA
eth_gaul = gaul[gaul['name0']=='Ethiopia']


# LOAD THE FOOD CRISIS DATA
os.chdir("/Users/jen/jen/datakind/march2021datadive/testdata")
food_crisis = pd.read_csv('predicting_food_crises_data.csv') 
# data dic https://microdata.worldbank.org/index.php/catalog/3811/related-materials

eth_food_crisis = food_crisis[food_crisis['country']=='Ethiopia']
eth_food_crisis = eth_food_crisis[eth_food_crisis['year_month']=='2020_02']


# TRY TO MERGE DIRECTLY
gaul_adm2 = eth_gaul[['name1']]
direct_merge = gaul_adm2.merge(eth_food_crisis, how='outer', 
                      left_on='name1', right_on='admin_name',
                      indicator=True)

direct_merge['_merge'].value_counts()

# VISUALIZE DIRECT MERGE
viz_direct = eth_gaul.merge(eth_food_crisis, how='left', 
                      left_on='name1', right_on='admin_name')
viz_direct.plot(column='cropland_pct', cmap='Reds', 
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

fuzzy_food = fuzzy_merge(gaul_adm2, eth_food_crisis,
                             'name1', 'admin_name', 
                             threshold=90, limit=1)

fuzzy_food = fuzzy_food.merge(eth_food_crisis, how='outer',
                                      left_on='matches', 
                                      right_on='admin_name',
                                      indicator=True)

fuzzy_food['_merge'].value_counts()


# VISUALIZE FUZZY MERGE
fuzzy_viz = fuzzy_merge(eth_gaul, eth_food_crisis,
                             'name1', 'admin_name', 
                             threshold=90, limit=1)
fuzzy_viz = fuzzy_viz.merge(eth_food_crisis, how='left', 
                      left_on='matches', right_on='admin_name')
fuzzy_viz.plot(column='cropland_pct', cmap='Reds', 
                      legend = True)









