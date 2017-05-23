# Note: Rcpp has R::bessel_k
#       see: http://dirk.eddelbuettel.com/code/rcpp/html/Rmath_8h_source.html
# Lat: y-axis
# Lon: x-axis

'%btwn%' <- function(x,y) x >= y[1] & x <= y[2]

library(rcommon)
library(sqldf)
library(fields) # quilt.plot
library(maps)   # map
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
new_vars <- cbind(ca$Arithmetic.Mean, 
              ca$Lat,
              ca$Lon,
              log(ca$Elevation))
colnames(new_vars) <- c('Mean', 'Lat', 'Lon', 'log(Elevation)')
my.pairs(new_vars)
#dev.off()

#### TEST ####
### Rscala
#devtools::install_github("luiarthur/spatial_ams245/spatialScala")
#library(spatialScala)
#
#y <- ca$Arithmetic.Mean
#X <- vars[,-1]
#out <- GP(y,X,s,diag(4), 2, 1, 2, 1, 0,2, 1.5, 2.5, 1000, 300)

### RCPP
#library(Rcpp)
#Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
#sourceCpp("GP/gp.cpp")
##
#y <- ca$Arithmetic.Mean
#X <- vars[,-1]
#out <- fit(y, X, s, diag(4), 
#           init_beta=rep(0,ncol(X)),
#           a_tau=2, b_tau=1, init_tau2=1,
#           a_sig=2, b_sig=1, init_sig2=1,
#           a_phi=0, b_phi=2, init_phi=.5,
#           a_nu=1.5, b_nu=2.5, init_nu=2, 
#           B=1000, burn=300, printEvery=10)
#

### R
source("GP_R/gp.R", chdir=TRUE)
y <- ca$Arithmetic.Mean * 1000
X <- cbind(1, new_vars[, c("Lon", "log(Elevation)")])
#X <- cbind(1, new_vars[, "log(Elevation)"])

map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, y, add=TRUE)

#f <- function(x) x^2 + 10 
#X.test <- matrix(1, 30)
#x <- rnorm(length(X.test))
#y.test <- as.numeric(f(x) + X.test)
#plot(x,y.test)
#test <- gp(y.test, X.test, x, diag(3), 
#           a_sig=2, b_sig=10,
#           nu_choice=2.5,
#           B=1000, burn=3000, print_every=10)
#nrow(unique(test[, c(2:4)])) / nrow(test)
#cov(test[, 2:4])
#plotPosts(test[, 1:4])
#table(test[,5]) / nrow(test)

source("GP_R/gp.R", chdir=TRUE)
system.time(
burn <- gp(y, X, s, 
           a_z=0, b_z=3, 
           B=1000, burn=2000, print_every=100)
)
plotPosts(burn[, 1:ncol(X)])
plotPosts(burn[, c('phi','tau2','sig2', 'z')])
nrow(unique(burn)) / nrow(burn)
table(burn[,'nu']) / nrow(burn)

system.time(
out <- gp(y, X, s, 
          stepSigPsi=cov(burn[,c('gam2','phi','z')]) * 10,
          a_tau=100, b_tau=300,
          a_tau=30, b_tau=10,
          a_z=0, b_z=3,
          B=1000, burn=2000, print_every=100)
)
plotPosts(out[, 1:ncol(X)])
plotPosts(out[, c('phi','tau2','sig2', 'z')])
nrow(unique(out)) / nrow(out)

### Predict / Krig
system.time(pred <- gp.predict(y, X, s, X, s, out))

pred.mean <- apply(pred, 1, mean)
pred.ci <- apply(pred, 1, quantile, c(.025, .975))

par(mfrow=c(1,2))
map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, y, add=TRUE)
map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, pred.mean, add=TRUE)
par(mfrow=c(1,1))

coverage <- mean(sapply(1:length(y), function(i) y[i] %btwn% pred.ci[,i]))

plot(y, pred.mean, pch=20, col='grey30', fg='grey',
     ylim=range(post.ci), xlim=range(post.ci),
     xlab='Observed Values', ylab='Predicted Values',
     main='Predicted (mean and 95% CI) vs Observed')
add.errbar(ci=t(pred.ci), x=y, col='grey30')
abline(a=0, b=1, col='grey30', lty=2)
legend('bottomright', legend=paste0('Coverage = ', round(coverage,2)),
       bty='n', cex=2, text.col='grey30')
