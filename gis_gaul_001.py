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
gaul.plot()

# FILTER ETHIOPIA
eth_gaul = gaul[gaul['name0']=='Ethiopia']
eth_gaul.plot()


# LOAD GIS SHAPEFILE
os.chdir("/Users/jen/jen/datakind/march2021datadive/testdata/ethiopia_shape")
eth_03_zone = gpd.read_file("eth_admbnda_adm2_csa_bofed_20201008.shp")


# TRY TO MERGE DIRECTLY
gis_adm2 = eth_03_zone[['ADM2_EN']]
gaul_adm2 = eth_gaul[['name1']]
direct_gis_gaul = gis_adm2.merge(gaul_adm2, how='outer', 
                      left_on='ADM2_EN', right_on='name1',
                      indicator=True)

direct_gis_gaul['_merge'].value_counts()

# ONLY 39 EXACT MATCHES
# DOESNT MAP OUT OF THE BOX SO MUST TRY FUZZY
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

fuzzy_gis_gaul = fuzzy_merge(gis_adm2, gaul_adm2, 'ADM2_EN', 'name1', 
                    threshold=90, limit=1)

fuzzy_gis_gaul = fuzzy_gis_gaul.merge(gaul_adm2, how='outer',
                                      left_on='matches', right_on='name1',
                                      indicator=True)

fuzzy_gis_gaul['_merge'].value_counts()
# ABLE TO MATCH MORE AND QUALITY SEEMS REASONABLE, BUT A LOT LEFT


