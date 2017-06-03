# Lat: y-axis
# Lon: x-axis

library(xtable)
library(rcommon)
library(sqldf)
library(fields) # quilt.plot
library(maps)   # map
source("../../hw3/src/plotPerCounty.R")

### Entire Data ###
#dat <- read.csv('../../hw3/dat/annual_all_2015.csv')
#site <- read.csv('../../hw3/dat/aqs_sites.csv')
NO2 <-  read.csv('../dat/daily/daily_NO2_2015.csv')
ozone <-  read.csv('../dat/daily/daily_ozone_2015.csv')
pm25 <-  read.csv('../dat/daily/daily_pm25_2015.csv')
site <- read.csv('../../hw3/dat/aqs_sites.csv')

# dim = 135, 56
ca <- sqldf('
  SELECT dat.*, site.Elevation FROM dat LEFT JOIN site
  WHERE
    dat.`State.Name` IN("California") AND
    dat.`Parameter.Name` IN("Ozone") AND
    dat.`Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
    dat.`Pollutant.Standard`="Ozone 8-Hour 2008" AND
    dat.`Event.Type` IN("No Events",
                        "Concurred Events Excluded",
                        "Events Excluded") AND
    dat.`Completeness.Indicator` ="Y" AND
    dat.`State.Name` = site.`State.Name` AND
    dat.`County.Name` = site.`County.Name` AND
    dat.`Site.Num` = site.`Site.Number` AND
    site.Elevation > 10
')
dim(ca)


