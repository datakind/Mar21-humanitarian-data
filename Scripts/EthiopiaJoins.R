---
title: "Ethiopia data ingestion and joins"
author: "DataKind"
date: "March 4, 2021"
---

##Load Packages; Probably not all needed
library(gridExtra)
library(forcats) 
library(lubridate)
library(RJSONIO)
library(maps)
library(mapdata)
library(ggplot2)
library(tools)
library(mapplots)
library(viridis)
library(ggrepel)
library(directlabels)
library(statebins)
library(rworldmap)
library(tidyverse)
library(tidyselect)
library(googlesheets4)
library(formattable)
library(kableExtra)
library(ggthemes)
library(knitr)
library(sf)
library(haven)
library(jsonlite)
library(geojsonio)
library(lwgeom)
library(janitor)
library(readxl)

downloader::download(filepath, destfile = xltemp, mode="wb")


options(scipen=999)#Disables scientific notation
## First, FUNCTIONS for reading all Ecxel sheets in humanitarian data from Robin

read_excel_allsheets <- function(filepath, prefix) {
  temp_read_excel <- tempfile()
  downloader::download(filepath, destfile = temp_read_excel, mode="wb")
  sheets <- readxl::excel_sheets(temp_read_excel)
  sheets_f <- sheets %>%
    str_replace_all("[[:punct:]]", " ")%>%
    str_replace(" ", "_")%>%
    str_replace_all(" ", "")
  
  for (i in 1:length(sheets)){
    print(paste(i, ":", sheets_f[i]))
    df_temp <- read_excel(temp_read_excel, sheet = sheets[i])
    assign(paste0(prefix, "_",i,"_", sheets_f[i]), df_temp, envir = globalenv())
  }
}

rt_fun_df <- function(df, desc, col_range){
  df1 <- df[col_range]%>%
    row_to_names(row_number = 1)
  
  colnames(df1) <- paste0(desc, "_", colnames(df1))
  
  df1<- df1%>%
    clean_names()%>%
    rename(admin3Pcode = paste0(desc, "_admin3pcode"))
  
  df1_d <- df1[1,]%>%
    t()%>%
    as.data.frame()%>%
    rownames_to_column()
  
  df1 <- df1%>%
    filter(!str_starts(admin3Pcode, "#"))
  
  return(df1)
}
rt_fun_df_d <- function(df, desc, col_range){
  df1 <- df[col_range]%>%
    row_to_names(row_number = 1)
  
  df1_d <- df1[1,]%>%
    t()%>%
    as.data.frame()%>%
    rownames_to_column()
  return(df1_d)
}


##Download shapefiles ADM1, ADM2, and ADM3 together from https://data.humdata.org/dataset/ethiopia-cod-ab. All are contained in one zip file.
temp <- tempfile()
temp2 <- tempfile()

##URL below obtained by copying link address from download button for ETH Administrative Divisions Shapefiles.zipSHP (19.8M)
download.file("https://data.humdata.org/dataset/cb58fa1f-687d-4cac-81a7-655ab1efb2d0/resource/63c4a9af-53a7-455b-a4d2-adcc22b48d28/download/eth-administrative-divisions-shapefiles.zip",temp)

#unzip the contents in 'temp' and save unzipped content in 'temp2'
unzip(zipfile = temp, exdir = temp2)
#finds the filepath of the shapefile (.shp) file in the temp2 unzip folder
#the $ at the end of ".shp$" ensures you are not also finding files such as .shp.xml 
ETH_SHP_files<-list.files(temp2, pattern = ".shp$",full.names=TRUE)

##Load in the 3 shapefiles
ETH1<-st_read(ETH_SHP_files[2])
ETH2<-st_read(ETH_SHP_files[3])
ETH3<-st_read(ETH_SHP_files[4])

#Load in population data from https://data.humdata.org/dataset/ethiopia-population-data-_-admin-level-0-3

ETH2Pop<-read_csv("https://data.humdata.org/dataset/3d9b037f-5112-4afd-92a7-190a9082bd80/resource/bfb57304-3e22-498f-8a82-a345a8976852/download/eth_admpop_adm2_20201028.csv")
ETH3Pop<-read_csv("https://data.humdata.org/dataset/3d9b037f-5112-4afd-92a7-190a9082bd80/resource/3f8150d4-6d5d-4659-a0a8-586e4689ae65/download/eth_admpop_adm3_20201102.csv")


##Medical sites from https://data.humdata.org/dataset/ethiopia-healthsites
medical<-geojson_sf("https://data.humdata.org/dataset/0cc29a44-cc6d-449a-b3b7-d28fb2066c26/resource/efba3ee3-7594-4ad9-bcbf-971687bb2d5e/download/ethiopia.geojson")

ggplot(ETH2)+
  geom_sf()+
  geom_sf(data=medical, aes(color=amenity))+
  labs(title = "Medical Sites")

## Refugee Camp Locations from https://data.humdata.org/dataset/ethiopia-refugee-camp-locations
download.file("https://data.humdata.org/dataset/19ba356b-170e-430e-82d8-7d1acdb58ffc/resource/b469e2cb-7eb6-4e62-a303-41ad51f9e0b7/download/eth_refugee_camps_unhcr_2019.zip",temp)
#unzip the contents in 'temp' and save unzipped content in 'temp2'
unzip(zipfile = temp, exdir = temp2)
ETH_SHP_files<-list.files(temp2, pattern = ".shp$",full.names=TRUE)
##Load in the shapefile
refugeeCamps<-st_read(ETH_SHP_files[7])

ggplot(ETH2)+
  geom_sf()+
  geom_point(data=refugeeCamps, aes(x=Longitude, y=Latitude, color=LocationTy))+
  labs(title = "Refugee Camps")


## Load in humanitarian needs using excel functions from top

filepath <- "https://data.humdata.org/dataset/882d0746-ac2a-4471-b40d-a92dee832ee2/resource/04e357f9-9ab7-4d6b-8102-2503bf02c6be/download/ethiopia-2020-humanitarian-needs-overview.xlsx"

read_excel_allsheets(filepath, prefix = 'df')

## Adjust dfs

##df_2
df <- df_2_PIN_bySAADAdmin3

#data
df1 <- rt_fun_df(df, "overall_in_need", c(6, 7:14))
df1_d <- rt_fun_df_d(df, "overall_in_need", c(6, 7:14))

df2 <- rt_fun_df(df, "wellbeing_consq", c(6, 15:21))
df2_d <- rt_fun_df_d(df, "wellbeing_consq", c(6, 15:21))

df3 <- rt_fun_df(df, "living_stds_consq", c(6, 22:28))
df3_d <- rt_fun_df_d(df, "living_stds_consq", c(6, 22:28))

df0 <- rt_fun_df(df, "keys", c(1:6))
df0_d <- rt_fun_df_d(df, "keys", c(1:6))

## df_3 
df_3_d  <- df_3_Sectoral_PINbyAdmin3[1,c(6:14)] %>%
  t()%>%
  as.data.frame()%>%
  rownames_to_column()

df_3 <- df_3_Sectoral_PINbyAdmin3[,c(6:14)] %>%
  filter(!str_starts(admin3Pcode, "#"))%>%
  mutate(across(-c(1), as.numeric))

## df_3
df_3_d  <- df_3_Sectoral_PINbyAdmin3[1,c(6:14)] %>%
  t()%>%
  as.data.frame()%>%
  rownames_to_column()

df_3 <- df_3_Sectoral_PINbyAdmin3[,c(6:14)] %>%
  filter(!str_starts(admin3Pcode, "#"))
colnames(df_3) <- paste0("sectoral_PIN_", colnames(df_3))
df_3 <- df_3%>%
  clean_names()%>%
  rename(admin3Pcode = "sectoral_pin_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

## df_4
df_4 <- df_4_Conflict_IDPsinsites[,c(9:12)]
colnames(df_4) <- paste0("conflict_idps_in_sites_", colnames(df_4))
df_4 <- df_4 %>%
  clean_names()%>%
  rename(admin3Pcode = "conflict_idps_in_sites_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))


## df_5
df_5 <- df_5_IDPs_inHostcommunities[,c(6:9)]
colnames(df_5) <- paste0("idps_inHostCommunities_", colnames(df_5))
df_5 <- df_5 %>%
  clean_names()%>%
  rename(admin3Pcode = "idps_in_host_communities_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

## df_6
df_6 <- df_6_Returnees_tooriginnothome[,c(6:9)]
colnames(df_6) <- paste0("returnees_to_orign_not_home_", colnames(df_6))
df_6 <- df_6 %>%
  clean_names()%>%
  rename(admin3Pcode = "returnees_to_orign_not_home_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

## df_7
df_7 <- df_7_Returned_tohome[,c(6:9)]
colnames(df_7) <- paste0("returned_to_home_", colnames(df_7))
df_7 <- df_7 %>%
  clean_names() %>%
  rename(admin3Pcode = "returned_to_home_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

## df_8
df_8<- df_8_Drought_inducedIDPs[,c(6:9)]
colnames(df_8) <- paste0("drought_induced_idps_", colnames(df_8))
df_8 <- df_8 %>%
  clean_names() %>%
  rename(admin3Pcode = "drought_induced_idps_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

## df_9
df_9 <- df_9_Flood_inducedIDPs[,c(6:9)]
colnames(df_9) <- paste0("flood_induced_idps_", colnames(df_9))
df_9<- df_9 %>%
  clean_names() %>%
  rename(admin3Pcode = "flood_induced_idps_admin3pcode")%>%
  mutate(across(-c(1), as.numeric))

df_all <- df0 %>%
  full_join(df1, on = admin3Pcode)%>%
  full_join(df2, on = admin3Pcode)%>%
  full_join(df3, on = admin3Pcode)%>%
  full_join(df_3, on = admin3Pcode)%>%
  full_join(df_4, on = admin3Pcode)%>%
  full_join(df_5, on = admin3Pcode)%>%
  full_join(df_6, on = admin3Pcode)%>%
  full_join(df_7, on = admin3Pcode)%>%
  full_join(df_8, on = admin3Pcode)%>%
  full_join(df_9, on = admin3Pcode)

df_all %>%
  filter(admin3Pcode == 'ET020106')


##Livelihood Boundaries from https://fews.net/data
download.file("https://fews.net/data_portal_download/download?data_file_path=http%3A//s3.amazonaws.com/shapefiles.fews.net/LHZ/ET_LHZ_2018.zip",temp)
unzip(zipfile = temp, exdir = temp2)
ETH_SHP_files<-list.files(temp2, pattern = ".shp$",full.names=TRUE)
livelihoodBoundaries<-st_read(ETH_SHP_files[1])

ggplot(livelihoodBoundaries)+
  geom_sf()


##Food Security Boundaries from https://fews.net/data
##Running into error when reading directly from site. So, had to download
setwd("C://users/rcarder/downloads")

foodSecurity<-st_read("ET_202101",layer="ET_202101_ML2")
foodSecurityJoin<-st_drop_geometry(foodSecurity)


##############################
###Joins at the ADM3 level####
##############################

##Get all datasets that need to retain geometry in the same CRS (using 3857 as that is what Mapbox requires)

ETH1<-st_transform(ETH1, crs=3857,proj4string="+proj=longlat +datum=WGS84 +no_defs")
ETH2<-st_transform(ETH2, crs=3857,proj4string="+proj=longlat +datum=WGS84 +no_defs")
ETH3<-st_transform(ETH3, crs=3857,proj4string="+proj=longlat +datum=WGS84 +no_defs")
refugeeCamps<-st_transform(refugeeCamps, crs=3857,proj4string="+proj=longlat +datum=WGS84 +no_defs")
medical<-st_transform(medical, crs=3857,proj4string="+proj=longlat +datum=WGS84 +no_defs")




#Join population, humanitarian needs, and food security to geometry, and calculate densities

ETH3master<-ETH3%>%
  left_join(ETH3Pop, by="ADM3_PCODE")%>%
  left_join(df_all, by=c("ADM3_PCODE"="admin3Pcode"))%>%
  mutate(Density=Total/Shape_Area)%>%
  left_join(foodSecurityJoin, by=c("ADM3_EN.x"="ADMIN3"))


ETH3master$refugeeCamps <- lengths(st_intersects(ETH3master, refugeeCamps))

#Split medical places into different types
for (i in unique(medical$amenity)){
  dat<-medical%>%
    filter(amenity==i)
  
  assign(paste0("medical",i),dat)
}



#calculate how many of each type are contained within each boundary polygon
ETH3master$doctors <- lengths(st_intersects(ETH3master, medicaldoctors))
ETH3master$clinics <- lengths(st_intersects(ETH3master, medicalclinic))
ETH3master$hospitals <- lengths(st_intersects(ETH3master, medicalhospital))
ETH3master$pharmacies <- lengths(st_intersects(ETH3master, medicalpharmacy))

######################
########Plots#########
######################

## Plot simple maps to see what each boundary level looks like
ggplot(ETH1)+
  geom_sf()+
  labs(title = "ADM1")

ggplot(ETH2)+
  geom_sf()+
  labs(title = "ADM2")

ggplot(ETH3)+
  geom_sf()+
  labs(title = "ADM3")

##Plot with pop 
ggplot(ETH3master)+
  geom_sf(aes(fill=Total), color="#bebebe")+
  scale_fill_distiller(palette = "Greens", direction = 1)+
  labs(title="Total Popualtion, ADM 2")


## Plot of food security

ggplot(foodSecurity, aes(fill=ML2))+
  geom_sf(color="#bebebe", size=.001)+
  scale_fill_distiller(palette ="YlOrRd", direction=1)+
  labs(title="Food Security Classification", fill="Insecurity Level")


#plot of food security after join
ggplot(ETH3master, aes(fill=ML2))+
  geom_sf(color="#bebebe", size=.001)+
  scale_fill_distiller(palette ="YlOrRd", direction=1)+
  labs(title="Food Security Classification", fill="Insecurity Level")






##Write Output Files


setwd("C://users/rcarder/downloads")
ETH3masterFlat<-st_drop_geometry(ETH3master)

write.csv(ETH3masterFlat,"ETHADM3Join.csv")




            