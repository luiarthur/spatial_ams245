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
  seq(min(s[,1]), max(s[,1]), len=10),
  seq(min(s[,2]), max(s[,2]), len=10))
x <- map('state','california',plot=F)
u <- as.matrix(u[in.ca(u),])
colnames(u) <- colnames(s)
m <- nrow(u)


### Plot Data & Knots
map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=T)
points(u[,1], u[,2], pch=4, lwd=2, col='grey30', cex=2)
map('state','california', col='grey', add=T)

source("conv.R", chdir=TRUE)
set.seed(1)
out <- gp_conv_fit(y, X, u=u, s=s, cs_v=1,
                   B=3000, burn=1000, print_freq=100)

b <- t(sapply(out, function(o) o$beta))
colnames(b) <- colnames(X)
plotPosts(b, trace=F)

w <- t(sapply(out, function(o) o$w))
colnames(w) <- paste0("w",1:nrow(u))
plotPosts(w[,1:4], trace=F)
plotPosts(w[,5:8], trace=F)
plotPosts(w[,9:12], trace=F)

sig2 <- sapply(out, function(o) o$sig2)
tau2 <- sapply(out, function(o) o$tau2)
v <- sapply(out, function(o) o$v)
plotPosts(v)

plotPosts(cbind(sig2, tau2, v), acc=F)

source("conv.R", chdir=TRUE)
post <- cbind(b, w, sig2, tau2, v)
post_summary(post)

#X_new <- cbind(1, pred_locs[,2], log(pred_locs[,1]))
#s_new <- as.matrix(pred_locs[,-1])
s_new <- expand.grid(
  seq(min(s[,1]), max(s[,1]), len=30),
  seq(min(s[,2]), max(s[,2]), len=30))
x <- map('state','california',plot=F)
s_new <- as.matrix(s_new[in.ca(s_new),])
X_new <- cbind(1, s_new[,1], mean(X[,3]))
s_new <- rbind(s, s_new); X_new <- rbind(X, X_new)

system.time(pred <- gp_conv_pred(y, X, s, X_new, s_new, u, out))
dim(pred)

### Plot Pred
zlim <- c(25, 60)

par(mfrow=c(1,2))
map('state','california', col='transparent')
#quilt.plot(s_new[,1], s_new[,2], rowMeans(pred), add=TRUE, zlim=zlim)
xyz <- mba.surf(cbind(s_new, rowMeans(pred)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=T, zlim=zlim)
#xyz_dat <- mba.surf(cbind(s, y), 100, 100)
#image.plot(xyz_dat$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)
par(mfrow=c(1,1))


