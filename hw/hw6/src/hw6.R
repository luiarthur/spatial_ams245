# Lat: y-axis
# Lon: x-axis

set.seed(1)
library(MBA)    # High resolution images
library(xtable)
library(rcommon)
#devtools::install_github("luiarthur/rcommon")
library(sqldf)
library(fields) # quilt.plot
library(maps)   # map
source("conv.R", chdir=TRUE)

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

pred_locs <- sqldf('
  SELECT site.Elevation, dat.Longitude, dat.Latitude
  FROM dat LEFT JOIN site
  WHERE
    dat.`State.Name` = "California" AND
    dat.`State.Name` = site.`State.Name` AND
    dat.`County.Name` = site.`County.Name` AND
    dat.`Site.Num` = site.`Site.Number` AND
    site.Elevation > 10
  GROUP BY
    site.Elevation, dat.Longitude, dat.Latitude
')
###################################3

y <- ca$Arithmetic.Mean * 1000 # ppb
X <- cbind(1, ca$Longitude, log(ca$Elevation))
colnames(X) <- c("Intercept", "Longitude", "LogElevation")
s <- as.matrix(ca[,c("Longitude", "Latitude")])
n <- nrow(s)
m <- round(sqrt(n)) # 30
u <- cbind(seq(min(s[,1]), max(s[,1]), len=m),
           seq(min(s[,2]), max(s[,2]), len=m))

source("conv.R", chdir=TRUE)
out <- gp_conv_fit(y, X, u=u, s=s, cs_v=1,
                   B=3000, burn=1000, print_freq=100)

b <- t(sapply(out, function(o) o$beta))
plotPosts(b, trace=F, cnames=colnames(X))

w <- t(sapply(out, function(o) o$w))
plotPosts(w[,1:4], trace=F)
plotPosts(w[,5:8], trace=F)
plotPosts(w[,9:12], trace=F)

sig2 <- sapply(out, function(o) o$sig2)
tau2 <- sapply(out, function(o) o$tau2)
v <- sapply(out, function(o) o$v)

plotPosts(cbind(sig2, tau2, v), acc=F)


