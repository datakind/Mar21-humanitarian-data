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
chicken_by_region['region'] = chicken_by_region['saq01'].str.split('. ').str[1]
chicken_by_region['region'] = chicken_by_region['region'].str.lower()
chicken_by_region = chicken_by_region[['region', 'nr_chicken']]
eth_02_region['region']=eth_02_region['ADM1_EN'].str.lower()


# DO THE MERGE
regional_chicken = eth_02_region.merge(chicken_by_region, 
                                       left_on='region', right_on='region',
                                       how='left')

# VIZUALIZE THE CHICKEN BY REGION
regional_chicken.plot(column='nr_chicken', cmap='Reds', 
                      legend = True)


