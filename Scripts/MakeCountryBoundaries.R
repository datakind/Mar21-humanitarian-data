---
title: "HumDat Country Boundaries"
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


##Read in topojson for whole world at ADM1 (less granular subnational regions) and ADM2 (more granular subnational regions)
##From https://www.geoboundaries.org/
#Must give reference in final product

worldadm1<-topojson_read("https://www.geoboundaries.org/data/geoBoundariesCGAZ-3_0_0/ADM1/simplifyRatio_25/geoBoundariesCGAZ_ADM1.topojson")
worldadm2<-topojson_read("https://www.geoboundaries.org/data/geoBoundariesCGAZ-3_0_0/ADM2/simplifyRatio_25/geoBoundariesCGAZ_ADM2.topojson")

#Filter Ethiopia
ETH1<-worldadm1%>%
  filter(shapeGroup=="ETH")

ETH2<-worldadm2%>%
  filter(shapeGroup=="ETH")

##Filter Mali
MLI1<-worldadm1%>%
  filter(shapeGroup=="MLI")

MLI2<-worldadm2%>%
  filter(shapeGroup=="MLI")

##Filter Bangladesh

BGD1<-worldadm1%>%
  filter(shapeGroup=="BGD")

BGD2<-worldadm2%>%
  filter(shapeGroup=="BGD")

##Filter Iraq

IRQ1<-worldadm1%>%
  filter(shapeGroup=="IRQ")

IRQ2<-worldadm2%>%
  filter(shapeGroup=="IRQ")



##Sample Simple Plots

ggplot(MLI1)+
  geom_sf()

ggplot(ETH2)+
  geom_sf()

ggplot(IRQ2)+
  geom_sf()

ggplot(BGD1)+
  geom_sf()



## After looking at Ethipia pop data, realized unique ID's were not the same. So, replacing ETH2 with a different source:
###Download Shapefile from https://data.humdata.org/dataset/ethiopia-cod-ab

#create a couple temp files
temp <- tempfile()
temp2 <- tempfile()
download.file("https://data.humdata.org/dataset/cb58fa1f-687d-4cac-81a7-655ab1efb2d0/resource/63c4a9af-53a7-455b-a4d2-adcc22b48d28/download/eth-administrative-divisions-shapefiles.zip",temp)
#unzip the contents in 'temp' and save unzipped content in 'temp2'
unzip(zipfile = temp, exdir = temp2)
#finds the filepath of the shapefile (.shp) file in the temp2 unzip folder
#the $ at the end of ".shp$" ensures you are not also finding files such as .shp.xml 
your_SHP_file<-list.files(temp2, pattern = ".shp$",full.names=TRUE)
ETH2<-st_read(your_SHP_file[3])
ETH2 = ms_simplify(ETH2, dTolerance = 2000)  # 2000 m



##change to local dir
setwd("C:/Users/rcarder/documents/dev/Mar21-humanitarian-data/Country Boundaries")

topojson_write(ETH1,file="EthiopiaADM1.topojson")
topojson_write(ETH2,file="EthiopiaADM2.topojson") 
topojson_write(IRQ1,file="IraqADM1.topojson")
topojson_write(IRQ2,file="IraqADM2.topojson")
topojson_write(BGD1,file="BangladeshADM1.topojson")
topojson_write(BGD2,file="BangladeshADM2.topojson")
topojson_write(MLI1,file="MaliADM1.topojson")
topojson_write(MLI2,file="MaliADM2.topojson")


