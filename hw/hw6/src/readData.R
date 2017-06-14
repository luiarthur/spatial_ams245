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
  SELECT Elevation, Longitude, Latitude
  FROM site
  WHERE
    `State.Name` = "California" AND
    Elevation > 10
  GROUP BY
    Elevation, Longitude, Latitude
')
###################################3

### CRUDE
#plot(x); abline(-81, -1); abline(-85, -1)
in.ca <- function(s) {
  s[,2] < -s[,1]-81 & s[,2] > -s[,1]-85
}

y <- ca$Arithmetic.Mean * 1000 # ppb
X <- cbind(1, ca$Longitude, log(ca$Elevation))
colnames(X) <- c("Intercept", "Longitude", "LogElevation")
s <- as.matrix(ca[,c("Longitude", "Latitude")])
n <- nrow(s)
u <- expand.grid(
  seq(min(s[,1]), max(s[,1]), by=1),
  seq(min(s[,2]), max(s[,2]), by=1))
x <- map('state','california',plot=F)
u <- as.matrix(u[in.ca(u),])
colnames(u) <- colnames(s)
m <- nrow(u)


### Plot Data & Knots
pdf('../tex/img/data.pdf')
map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=T)
points(u[,1], u[,2], col='grey30')
map('state','california', col='grey', add=T)
dev.off()

### New Prediction Locations
X_new <- cbind(1, pred_locs[,2], log(pred_locs[,1]))
s_new <- as.matrix(pred_locs[,-1])
s_new <- rbind(s, s_new)
X_new <- rbind(X, X_new)

#s_new <- expand.grid(
#  seq(min(s[,1]), max(s[,1]), len=30),
#  seq(min(s[,2]), max(s[,2]), len=30))
#x <- map('state','california',plot=F)
#s_new <- as.matrix(s_new[in.ca(s_new),])
#X_new <- cbind(1, s_new[,1], mean(X[,3]))
#s_new <- rbind(s, s_new); X_new <- rbind(X, X_new)
