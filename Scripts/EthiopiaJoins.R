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


## Topojson boundaries from https://www.geoboundaries.org/
## MakeCountyBoudaries script filtered to each country and wrote separate topojson files. 
## Here we can read them back in from GitHub.

st_read("eth-administrative-divisions-shapefiles")

##Read in Ethiopia ADM2 Boundaries (most granular)
ETH2<-topojson_read("https://raw.githubusercontent.com/datakind/Mar21-humanitarian-data/283620af73d1f1b74ad47de7af4caceb6599a377/Country%20Boundaries/EthiopiaADM2.topojson")






ETHPop<-read_csv("https://data.humdata.org/dataset/3d9b037f-5112-4afd-92a7-190a9082bd80/resource/bfb57304-3e22-498f-8a82-a345a8976852/download/eth_admpop_adm2_20201028.csv")

##View Boundaries
ggplot(ETH)+
  geom_sf()




