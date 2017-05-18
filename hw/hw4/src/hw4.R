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
s <- ca[c('Latitude', 'Longitude')]
counties <- as.character(unique(ca$County.Name))
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
  FROM ca
  GROUP BY `County.Name`
')

pdf('../tex/img/logCountyMeans.pdf')
plot.per.county(log(county_means$cmean), 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)
dev.off()
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

pdf('../tex/img/mypairs.pdf')
vars <- cbind(ca_all$Arithmetic.Mean, 
              ca_all$Lat,
              ca_all$Lon,
              log(ca_all$Elevation))
colnames(vars) <- c('Mean', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars)
dev.off()

### Variogram ###
plot(variog(data=ca_all$Arithmetic.Mean, coords=s, op='cloud'))
plot(variog(data=ca_all$Arithmetic.Mean, coords=s), type='b')

### Transform and detrend ###
y <- ca_all$Arithmetic.Mean * 1000
alt <- ca_all$Elevation

mod <- lm(y ~ ca_all$Lon + log(alt))

plot.per.county(mod$resid, 'california', county_means$cname, 
                levels=7, measure='log county means', text.name=FALSE)

pdf('../tex/img/detrendedPairs.pdf')
vars.new <- cbind(mod$resid,
                  ca_all$Lat, ca_all$Lon,
                  log(alt))
colnames(vars.new) <- c('Mean.detrended', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(vars.new)
dev.off()

pdf('../tex/img/vario.pdf')
par(mfrow=2:1)
plot(variog4(data=y, coords=s))
title(main='Semi-variogram')
#plot(variog4(data=mod$resid, coord=s), type='b')
#plot(variog4(data=y, coords=s, 
#             trend= ~ s[,1] + s[,2] + log(alt)))
plot(variog4(data=y, coords=s, 
             trend= ~ s[,2] + log(alt)))
title(main='Semi-variogram after detrend (longitude + log(alt))')
par(mfrow=c(1,1))
dev.off()

#vario <- variog(data=ca_all$Arithmetic.Mean, coords=s, 
#                trend=ca_all$Arithmetic.Mean ~ s[,1] + s[,2] + log(alt),
#                message=FALSE)

#vario <- variog(data=ca_all$Arithmetic.Mean, coords=s, 
#                trend=ca_all$Arithmetic.Mean ~ s[,2] + alt,
#                message=FALSE)

vario <- variog(data=y, coords=s, 
                trend= ~ ca_all$Lon + log(alt),
                message=FALSE)

#vario <- variog(data=mod$res, coords=s, message=FALSE)

# initial sig2, range
#init <- expand.grid(seq(0,1E-5, len=100), seq(0,10,len=100))
init <- expand.grid(seq(0,100, len=10), seq(0,1,len=10))

variofit(vario, kappa=0.5)
variofit(vario, kappa=1.5)

vf1 <- variofit(vario, ini.cov.pars=init, kappa=0.5, nugget=0, fix.nug=F)
vf2 <- variofit(vario, ini.cov.pars=init, kappa=1.0, nugget=0, fix.nug=F)
vf3 <- variofit(vario, ini.cov.pars=init, kappa=1.5, nugget=0, fix.nug=F)
vf4 <- variofit(vario, ini.cov.pars=init, kappa=2.0, nugget=0, fix.nug=F)
vf <- list(vf1, vf2, vf3, vf4)

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

pdf('../tex/img/covario.pdf')
par(mfrow=c(2,2))
plt_result(vf1, vario, main=paste('Kappa = 0.5,  SS =',round(vf1$value)))
plt_result(vf2, vario, main=paste('Kappa = 1.0,  SS =',round(vf2$value)))
plt_result(vf3, vario, main=paste('Kappa = 1.5,  SS =',round(vf3$value)))
plt_result(vf4, vario, main=paste('Kappa = 2.0,  SS =',round(vf4$value)))
par(mfrow=c(1,1))
dev.off()

vf.best <- vf[[ which.min(sapply(vf, function(x) x$value)) ]]
X <- as.matrix(cbind(1,mod$model[,-1]))

#loglikeSillRange(sig2=vf4$cov.p[1], phi=vf4$cov.p[2],
#                 tau2=0, kappa=2, y, X) 

kappa_list <- as.list(c(.5, 1, 1.5, 2))
J <- 20
sig2.grid <- seq(0, 30, len=J)
phi.grid <- seq(0, 2.5, len=J)
#sig2.grid <- seq(0, 100, len=J)
#phi.grid <- seq(0, 100, len=J)

out <- lapply(kappa_list, function(k) {
  out <- matrix(NA, J, J)
  for (i in 1:J) for (j in 1:J) {
    out[i,j] <- loglikeSillRange(sig2=sig2.grid[j], phi=phi.grid[i],
                                 tau2=vf.best$nugget, kappa=k, y, X, s=s)
  }
  out
})

contour_plt <- function(o, ...) {
  contour(phi.grid, sig2.grid, o, ylab='sig2', xlab='phi', ...)
  idx <- which(o == max(o), arr.ind = TRUE)
  points(phi.grid[idx[1]], sig2.grid[idx[2]], pch=3, lwd=2)
}

pdf('../tex/img/marginalSig2Range.pdf')
par(mfrow=c(2,2))
contour_plt(out[[1]], main='kappa = 0.5')
contour_plt(out[[2]], main='kappa = 1.0')
contour_plt(out[[3]], main='kappa = 1.5')
contour_plt(out[[4]], main='kappa = 2.0')
par(mfrow=c(1,1))
dev.off()

### loglike of phi ###
#out <- sapply(phi.grid, function(phi) {

out_phi <- as.list(1:4)
for (i in 1:4) {
  out_phi[[i]] <- sapply(phi.grid, function(phi) {
    loglikeRange(phi=phi, 
                 tau2OverSig2=vf[[i]]$nugget / vf[[i]]$cov.p[1],
                 kappa=kappa_list[[i]], y=y, X=X, s=s)
  })
}

pdf('../tex/img/philike.pdf')
par(mfrow=c(2,2))
for (i in 1:4) {
  plot(phi.grid, out_phi[[i]], xlab='phi', ylab='loglike', 
       main=paste0('kappa = ', kappa_list[[i]]))
  abline(v=phi.grid[which.max(out_phi[[i]])], lty=2)
}
par(mfrow=c(1,1))
dev.off()
