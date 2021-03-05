---
title: "Ethiopia data ingestion and joins"
author: "DataKind"
date: "March 4, 2021"
---

##Load Packages; Probably not all needed
library(dplyr)      
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


## Plot simple maps to see what they look like
ggplot(ETH1)+
  geom_sf()

ggplot(ETH2)+
  geom_sf()

ggplot(ETH3)+
  geom_sf()


#Load in population data from https://data.humdata.org/dataset/ethiopia-population-data-_-admin-level-0-3

ETH2Pop<-read_csv("https://data.humdata.org/dataset/3d9b037f-5112-4afd-92a7-190a9082bd80/resource/bfb57304-3e22-498f-8a82-a345a8976852/download/eth_admpop_adm2_20201028.csv")
ETH3Pop<-read_csv("https://data.humdata.org/dataset/3d9b037f-5112-4afd-92a7-190a9082bd80/resource/3f8150d4-6d5d-4659-a0a8-586e4689ae65/download/eth_admpop_adm3_20201102.csv")

#Join population to geometry, calculate population density
ETH2<-ETH2%>%
  left_join(ETH2Pop, by="ADM2_PCODE")%>%
  mutate(Density=Total/Shape_Area)

ETH3<-ETH3%>%
  left_join(ETH3Pop, by="ADM3_PCODE")%>%
  mutate(Density=Total/Shape_Area)



##Plot with pop 
ggplot(ETH2)+
  geom_sf(aes(fill=Total), color="#bebebe")+
  scale_fill_distiller(palette = "Greens", direction = 1)

ggplot(ETH3)+
  geom_sf(aes(fill=Total), color="#bebebe")+
  scale_fill_distiller(palette = "Greens", direction = 1)


##Load in some point features

##Medical sites from https://data.humdata.org/dataset/ethiopia-healthsites
medical<-geojson_sf("https://data.humdata.org/dataset/0cc29a44-cc6d-449a-b3b7-d28fb2066c26/resource/efba3ee3-7594-4ad9-bcbf-971687bb2d5e/download/ethiopia.geojson")





## Refugee Camp Locations from https://data.humdata.org/dataset/ethiopia-refugee-camp-locations




