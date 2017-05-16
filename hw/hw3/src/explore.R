# Lat: y-axis
# Lon: x-axis

library(geoR)
library(rcommon)
library(sqldf)
library(maps)
source('plotPerCounty.R')
source('loglikeSillRange.R')
#source('../../hw1/src/cov_fn.R')

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
plot(ca_all$Elevation, ca_all$Arithmetic.Mean)

vars <- cbind(ca_all$Arithmetic.Mean,
              ca_all$Lat, ca_all$Lon, ca_all$Elevation)
colnames(vars) <- c('Mean', 'Lat', 'Lon', 'Elevation')
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
old_mean <- ca_all$Arithmetic.Mean
ca_all$Arithmetic.Mean <- old_mean * 100
y <- ca_all$Arithmetic.Mean
alt <- ca_all$Elevation

mod <- lm(y ~ ca_all$Lon + log(alt))

plot.per.county(mod$resid, 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)

vars.new <- cbind(mod$resid,
                  ca_all$Lat, ca_all$Lon,
                  log(alt))
colnames(vars.new) <- c('Mean.detrended', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars.new)

par(mfrow=2:1)
plot(variog4(data=ca_all$Arithmetic.Mean, coords=s))
title(main='Semi-variogram')
#plot(variog4(data=mod$resid, coord=s), type='b')
#plot(variog4(data=ca_all$Arithmetic.Mean, coords=s, 
#             trend=ca_all$Arithmetic.Mean ~ s[,1] + s[,2] + log(alt)))
plot(variog4(data=ca_all$Arithmetic.Mean, coords=s, 
             trend=ca_all$Arithmetic.Mean ~ s[,2] + log(alt)))
title(main='Semi-variogram after detrend (location + log(alt))')
par(mfrow=c(1,1))

#vario <- variog(data=ca_all$Arithmetic.Mean, coords=s, 
#                trend=ca_all$Arithmetic.Mean ~ s[,1] + s[,2] + log(alt),
#                message=FALSE)

#vario <- variog(data=ca_all$Arithmetic.Mean, coords=s, 
#                trend=ca_all$Arithmetic.Mean ~ s[,2] + alt,
#                message=FALSE)
vario <- variog(data=ca_all$Arithmetic.Mean, coords=s, 
                trend=ca_all$Arithmetic.Mean ~ s[,2] + log(alt),
                message=FALSE)

# initial sig2, range
#init <- expand.grid(seq(0,1E-5, len=100), seq(0,10,len=100))
init <- expand.grid(seq(0,1, len=100), seq(0,2,len=100))

variofit(vario, kappa=0.5)
variofit(vario, kappa=1.5)

vf1 <- variofit(vario, ini.cov.pars=init, kappa=0.5)
vf2 <- variofit(vario, ini.cov.pars=init, kappa=1.0)
vf3 <- variofit(vario, ini.cov.pars=init, kappa=1.5)
vf4 <- variofit(vario, ini.cov.pars=init, kappa=2.0)

plt_result <- function(vf, vario, leg.col=rgb(.9,.9,.9,.8), ...) {
  plot(vario, bty='n', fg='grey', pch=20, col='grey30',...)
  abline(h=vf$cov.pars[1] + vf$nugget, col='orange')
  abline(h=vf$nugget, lty=3, col='orange')
  abline(v=vf$practicalRange, col='blue')
  abline(v=vf$cov.pars[2], lty=3, col='blue')
  lines(vf, col='grey30', lty=2)
  #lines(0:10, (1-geoR::matern(0:10,phi=vf2$cov.pars[2],kappa=vf2$kappa)) * vf2$cov.pars[1] + vf2$nugget)
  legend('bottomright',
         legend=c('fitted','nugget','sill','range','practical range'),
         col=c('grey30', 'orange', 'orange', 'blue', 'blue'),
         lty=c(2,3,1,3,1),
         bg=leg.col, box.col=leg.col)
}

par(mfrow=c(2,2))
plt_result(vf1, vario, main=paste('Kappa = 0.5,  loss =',round(vf1$value,3)))
plt_result(vf2, vario, main=paste('Kappa = 1.0,  loss =',round(vf2$value,3)))
plt_result(vf3, vario, main=paste('Kappa = 1.5,  loss =',round(vf3$value,3)))
plt_result(vf4, vario, main=paste('Kappa = 2.0,  loss =',round(vf4$value,3)))
par(mfrow=c(1,1))

vf <- list(vf1, vf2, vf3, vf4)

vf.best <- vf[[ which.min(sapply(vf, function(x) x$value)) ]]

X <- as.matrix(cbind(1,mod$model[,-1]))
loglikeSillRange(sig2=.22, phi=.426, tau2=vf.best$nug+.1, kappa=1, y, X) 

loglikeSillRange()
