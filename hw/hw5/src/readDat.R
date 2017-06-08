# Lat: y-axis
# Lon: x-axis

set.seed(1)
library(MBA)    # High resolution images
library(spBayes)
library(xtable)
library(rcommon)
library(sqldf)
library(fields) # quilt.plot
library(maps)   # map
source("../../hw3/src/plotPerCounty.R")

### Entire Data ###
dat <- read.csv('../../hw3/dat/annual_all_2015.csv')
site <- read.csv('../../hw3/dat/aqs_sites.csv')

no2 <- sqldf('
  SELECT *, AVG(`Arithmetic.Mean`) AS `Mean` from dat
  WHERE
    `State.Name` IN("California") AND
    `Parameter.Name` = "Nitrogen dioxide (NO2)" AND
    `Sample.Duration` = "1 HOUR"
  GROUP BY
    `Longitude`, `Latitude`
')

# dim = 228, 56
ca <- sqldf('
  SELECT dat.*, site.Elevation, AVG(`Arithmetic.Mean`) AS `MEAN`
  FROM dat LEFT JOIN site
  WHERE
    dat.`State.Name` IN("California") AND
    (
      (
      dat.`Parameter.Name` = "Ozone" AND
      dat.`Pollutant.Standard`="Ozone 8-Hour 2008" AND
      dat.`Sample.Duration`="8-HR RUN AVG BEGIN HOUR"
      ) OR (
      dat.`Parameter.Name` = "Nitrogen dioxide (NO2)" AND
      dat.`Pollutant.Standard`="NO2 1-hour" AND
      dat.`Sample.Duration`="1 HOUR" 
      ) OR (
      dat.`Parameter.Name` = "PM2.5 Raw Data"
      )
    ) AND
    /*
    dat.`Parameter.Name` = "Ozone" AND
    dat.`Pollutant.Standard`="Ozone 8-Hour 2008" AND
    dat.`Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
    */
    dat.`Event.Type` IN("No Events",
                        "Concurred Events Excluded",
                        "Events Excluded") AND
    dat.`Completeness.Indicator` ="Y" AND
    dat.`State.Name` = site.`State.Name` AND
    dat.`County.Name` = site.`County.Name` AND
    dat.`Site.Num` = site.`Site.Number` AND
    site.Elevation > 10
  GROUP BY
    dat.`Parameter.Name`, dat.`Longitude`, dat.`Latitude`
')
dim(ca)


