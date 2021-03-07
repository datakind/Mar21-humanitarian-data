## Merge the GIS data with the demographic data

#Read the district boundaries (ADM2 level) GIS data 
base_path = ''
admin2_shp = gpd.read_file(base_path + 'bgd_adm_bbs_20201113_SHP/bgd_admbnda_adm2_bbs_20201113.shp')

#Read the demographic data, with district level granularity 
# (Courtesy World Bank Poverty Maps, 2016 - https://designstudio.worldbank.org/maps/2016/3323/res/data/zila_and_upazila_data.zip)
pov_df = pd.read_excel(base_path + "zila_and_upazila_data/zila_indicators.xlsx")

#Ensure the name of the districts are lower case in both datasets in order to merge
admin2_shp.ADM2_EN = admin2_shp.ADM2_EN.str.lower()
pov_df['Zila Name'] = pov_df['Zila Name'].str.lower()  

merged_data2 = admin2_shp.merge(pov_df, left_on = "ADM2_EN", right_on = "Zila Name")
