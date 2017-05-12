# Lat: y-axis
# Lon: x-axis

library(geoR)
library(rcommon)
library(sqldf)
library(maps)
source('plotPerCounty.R')

### Entire Data ###
dat <- read.csv('../dat/annual_all_2015.csv')
site <- read.csv('../dat/aqs_sites.csv')

### Counts of All States ###
all_states <- sqldf('
  SELECT `State.Name`, COUNT(*) AS Counts
  FROM (
    SELECT `State.Name` FROM dat
    /*SELECT dat.`State.Name` FROM dat LEFT JOIN site*/
    WHERE
      `Parameter.Name`="Ozone" AND
      `Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
      `Pollutant.Standard`="Ozone 8-Hour 2008" AND
      `Event.Type` IN("No Events","Concurred Events Excluded","Events Excluded") AND
      `Completeness.Indicator` ="Y" AND
      `POC` = "1"
      /*
      dat.`State.Name` = site.`State.Name` AND
      dat.`County.Name` = site.`County.Name` AND
      dat.`Site.Num` = site.`Site.Number` AND
      */
      /*site.`Elevation` > 50*/
    GROUP BY 
      dat.`State.Code`, dat.`County.Code`, dat.`Site.Num`, dat.`POC`
  )
  GROUP BY `State.Name`
')
dim(all_states)

### Assert that California has > 100 observation stations ###
stopifnot(all_states[which(all_states$State == "California"), "Counts"] > 100)

### Make sure I'm doing this right ###
#`State.Name` IN ("Washington","Oregon")
#`State.Name` IN ("Pennsylvania", "Ohio", "New York")
#`State.Name` IN ("Wyoming", "Idaho", "Montana", "Utah", "Colorado","Nevada","Arizona")
# `State.Name` IN ("Arizona","Texas","New Mexico")
# Matt Heiner got 112, I'm getting 115
sqldf('
  SELECT SUM(COUNTS) FROM all_states
  WHERE
    `State.Name` IN ("Tennessee", "Kentucky", "Virginia", "North Carolina")
')


### California Data ###
ca <- sqldf('
  SELECT * FROM dat
  WHERE
    `State.Name` IN("California") AND
    `Parameter.Name`="Ozone" AND
    `Sample.Duration`="8-HR RUN AVG BEGIN HOUR" AND
    `Pollutant.Standard`="Ozone 8-Hour 2008" AND
    `Event.Type` IN("No Events","Concurred Events Excluded","Events Excluded") AND
    `Completeness.Indicator` ="Y"
')
dim(ca)

### CA Site Data ###
site_ca <- sqldf('
  SELECT 
    `State.Name`,
    `County.Name`,
    `County.Code`,
    `Site.Number`,
    `Elevation`
  FROM site
  WHERE
    `State.Name`="California" AND `State.Code`="06"
')

ca_all <- sqldf('
  SELECT ca.*, site_ca.Elevation FROM ca LEFT JOIN site_ca
  WHERE 
    ca.`State.Name` = site_ca.`State.Name` AND
    ca.`County.Name` = site_ca.`County.Name` AND
    ca.`Site.Num` = site_ca.`Site.Number` AND
    site_ca.Elevation > 10
')

### Maps ###
s <- ca_all[c('Latitude', 'Longitude')]
counties <- as.character(unique(ca_all$County.Name))
state_county <- tolower(paste0('California,', counties))

### Check all counties in data can be mapped ###
map('county', 'California', col='transparent')
for (i in 1:length(state_county)) {
  map('county', state_county[i], names=TRUE, fill=TRUE, add=TRUE,
      border='white', col=rgb(1,0,0,.5))
}
### 


### Compute Means ###
county_means <- sqldf('
  SELECT 
    `County.Name` AS cname, 
    AVG(`Arithmetic.Mean`) AS cmean, 
    COUNT(`County.Name`) AS ccount,
    Elevation
  FROM ca_all 
  GROUP BY `County.Name`
')

plot.per.county(log(county_means$cmean), 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)
plot.per.county(county_means$Elevation, 'california', county_means$cname, 
                levels=7, measure='Count Elevation', text.name=FALSE)


### Explore location vs altitude ###
hist(ca_all$Arithmetic.Mean)
hist((sqrt(ca_all$Arithmetic.Mean)))
hist(log(sqrt(ca_all$Arithmetic.Mean)))
hist(log(ca_all$Arithmetic.Mean))


vars <- cbind(ca_all$Lat, ca_all$Lon, ca_all$Arithmetic.Mean, ca_all$Elevation)
colnames(vars) <- c('Lat', 'Lon', 'Mean', 'Elevation')
my.pairs(vars)

vars <- cbind(ca_all$Arithmetic.Mean, 
              ca_all$Lat,
              ca_all$Lon,
              log(ca_all$Elevation))
colnames(vars) <- c('Mean', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars)

### Variogram ###
plot(variog(data=ca_all$Arithmetic.Mean, coords=s, op='cloud'))
plot(variog(data=ca_all$Arithmetic.Mean, coords=s), type='b')

### Transform and detrend ###
y <- ca_all$Arithmetic.Mean
alt <- ca_all$Elevation
plot(alt, y)
plot(log(alt), y)
#lon <- ca_all$Lon
#tlon <- log(lon-min(lon)+1)
#plot(lon, y)
#plot(tlon, y)
#mod <- lm(y ~ tlon)

mod <- lm(y ~ log(alt))
abline(mod)

vars.new <- cbind(y - cbind(1, log(alt)) %*% mod$coef, #mod$resid
                  ca_all$Lat, ca_all$Lon,
                  log(alt))
colnames(vars.new) <- c('Mean.detrended', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars.new)

par(mfrow=c(2,1))
plot(variog(data=ca_all$Arithmetic.Mean, coords=s),
     type='b', main='Semi-variogram')
plot(variog(data=mod$resid, coord=s),
     type='b', main='Semi-variogram after detrend')
par(mfrow=c(1,1))

par(mfrow=2:1)
plot(variog4(data=ca_all$Arithmetic.Mean, coords=s), type='b')
title(main='Semi-variogram')
plot(variog4(data=mod$resid, coord=s), type='b')
title(main='Semi-variogram after detrend')
par(mfrow=c(1,1))
