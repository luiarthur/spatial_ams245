# Note: Rcpp has R::bessel_k
#       see: http://dirk.eddelbuettel.com/code/rcpp/html/Rmath_8h_source.html
# Lat: y-axis
# Lon: x-axis

library(rcommon)
library(sqldf)
library(maps)
source("../../hw3/src/plotPerCounty.R")

### Entire Data ###
dat <- read.csv('../../hw3/dat/annual_all_2015.csv')
site <- read.csv('../../hw3/dat/aqs_sites.csv')

# dim = 135, 56
ca <- sqldf('
  SELECT dat.*, site.Elevation FROM dat LEFT JOIN site
  WHERE
    dat.`State.Name` IN("California") AND
    dat.`Parameter.Name`="Ozone" AND
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

### Maps ###
s <- as.matrix(ca[c('Latitude', 'Longitude')])
counties <- as.character(unique(ca$County.Name))
state_county <- tolower(paste0('California,', counties))


### Compute Means ###
county_means <- sqldf('
  SELECT 
    `County.Name` AS cname, 
    AVG(`Arithmetic.Mean`) AS cmean, 
    COUNT(`County.Name`) AS ccount,
    Elevation
  FROM ca
  GROUP BY `County.Name`
')

#pdf('../tex/img/logCountyMeans.pdf')
plot.per.county(log(county_means$cmean), 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)
#dev.off()


### Explore location vs altitude ###
vars <- cbind(ca$Arithmetic.Mean,
              ca$Lat, ca$Lon, ca$Elevation)
colnames(vars) <- c('Mean', 'Lat', 'Lon', 'Elevation')
my.pairs(vars)

#pdf('../tex/img/mypairs.pdf')
vars <- cbind(ca$Arithmetic.Mean, 
              ca$Lat,
              ca$Lon,
              log(ca$Elevation))
colnames(vars) <- c('Mean', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars)
#dev.off()

#### TEST ####
#devtools::install_github("luiarthur/spatial_ams245/spatialScala")
#library(spatialScala)
#
#y <- ca$Arithmetic.Mean
#X <- vars[,-1]
#out <- GP(y,X,s,diag(4), 2, 1, 2, 1, 0,2, 1.5, 2.5, 1000, 300)
library(Rcpp)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
sourceCpp("GP/gp.cpp")

y <- ca$Arithmetic.Mean
X <- vars[,-1]
out <- fit(y, X, s, diag(4), 2, 1, 2, 1, 0, 2, 1.5, 2.5, 1000, 300, 0)



