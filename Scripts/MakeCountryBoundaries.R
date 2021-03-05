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

##change to local dir
#setwd("C:/Users/rcarder/documents/dev/Mar21-humanitarian-data/Country Boundaries")

topojson_write(ETH1,file="EthiopiaADM1.topojson")
topojson_write(ETH2,file="EthiopiaADM2.topojson")
topojson_write(IRQ1,file="IraqADM1.topojson")
topojson_write(IRQ2,file="IraqADM2.topojson")
topojson_write(BGD1,file="BangladeshADM1.topojson")
topojson_write(BGD2,file="BangladeshADM2.topojson")
topojson_write(MLI1,file="MaliADM1.topojson")
topojson_write(MLI2,file="MaliADM2.topojson")

