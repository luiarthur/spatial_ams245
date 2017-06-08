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

### Naming Data
X <- cbind(ca$Lon, log(ca$Elevation))
colnames(X) <- c('Longitude', 'log(Elevation)')
y <- ca$Arithmetic.Mean
s <- as.matrix(ca[c('Longitude', 'Latitude')])
n <- nrow(X)


### Indices
NO2 <- which(ca$Parameter.Name=="Nitrogen dioxide (NO2)")
PM <- which(ca$Parameter.Name=="PM2.5 Raw Data")
Ozone <- which(ca$Parameter.Name=="Ozone")
list_idx <- list(NO2=NO2, PM=PM, Ozone=Ozone)

X_ls <- lapply(list_idx, function(i) X[i,])
y_ls <- lapply(list_idx, function(i) y[i])
y_ls$Ozone <- y_ls$Ozone * 1000 # ppb
s_ls <- lapply(list_idx, function(i) s[i,])
n_ls <- lapply(y_ls, length)

### Pairs
my.pairs(cbind(y_ls$N,X_ls$N))
my.pairs(cbind(y_ls$P,X_ls$P))
my.pairs(cbind(y_ls$O,X_ls$O))

### Fit Model

prior <- list(sigma.sq.ig=c(2,1), tau.sq.ig=c(2,1),
              phi.unif=c(.5, 10), nu.unif=c(1,3))
starting <- list(phi=mean(prior$phi), sigma.sq=1, tau.sq=1, 
                 nu=mean(prior$nu))
tuning <- list(phi=.1, sigma.sq=.1, tau.sq=.1, nu=.1)
invert_phi <- function(M) {
  M[,"phi"] <- 1 / M[,"phi"]
  M
}

### Ozone
out_Ozone <- spLM(y_ls$Oz ~ X_ls$Oz, n.samp=2000, coords=s_ls$Oz,
                  cov.model="matern",
                  starting=starting, prior=prior, tuning=tuning)
m_Ozone <- spRecover(out_Ozone, start=1001)

plotPosts( as.matrix(m_Ozone$p.beta) )
plotPosts( invert_phi(as.matrix(m_Ozone$p.theta.rec)) )

### NO2
out_NO2 <- spLM(y_ls$N ~ X_ls$N, n.samp=5000, coords=s_ls$N,
                cov.model="matern",
                starting=starting, prior=prior, tuning=tuning)
m_NO2 <- spRecover(out_NO2, start=4001)

plotPosts( as.matrix(m_NO2$p.beta) )
plotPosts( invert_phi(as.matrix(m_NO2$p.theta.rec)) )

### PM2.5
out_PM <- spLM(y_ls$P ~ X_ls$P, n.samp=10000, coords=s_ls$P,
               cov.model="matern",
               starting=starting, prior=prior, tuning=tuning)
m_PM <- spRecover(out_PM, start=9001, end=10000)

plotPosts( as.matrix(m_PM$p.beta) )
plotPosts( invert_phi(as.matrix(m_PM$p.theta.rec)) )

### 
u <- jitter(s)
O_pred <- spPredict(out_Ozone, pred.coords=u, pred.covars=cbind(1,X))
N_pred <- spPredict(out_NO2, pred.coords=u, pred.covars=cbind(1,X))
P_pred <- spPredict(out_PM, pred.coords=u, pred.covars=cbind(1,X))

### Ozone Maps
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=apply(O_pred$p,1,mean), add=TRUE)
title(main="Ozone Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$O[,"Longitude"], y=s_ls$O[,"Latitude"],
           z=y_ls$O, add=TRUE)
title(main="Ozone Truth")
par(mfrow=c(1,1))

### NO2 Maps
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=apply(N_pred$p,1,mean), add=TRUE)
title(main="NO2 Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$N[,"Longitude"], y=s_ls$N[,"Latitude"],
           z=y_ls$N, add=TRUE)
title(main="NO2 Truth")
par(mfrow=c(1,1))

### PM2.5 Maps
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=apply(P_pred$p,1,mean), add=TRUE)
title(main="PM2.5 Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$P[,"Longitude"], y=s_ls$P[,"Latitude"],
           z=y_ls$P, add=TRUE)
title(main="PM2.5 Truth")
par(mfrow=c(1,1))

### Higher Resolution
map('county', 'california', col='transparent')
xyz_P <- mba.surf(cbind(u, apply(P_pred$p,1,mean)), 1000, 1000)
image.plot(xyz_P$xyz.est, add=TRUE)
map('county', 'california', col='grey', add=TRUE)
title(main="PM2.5 Prediction")

