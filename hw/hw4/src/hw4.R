# Note: Rcpp has R::bessel_k
#       see: http://dirk.eddelbuettel.com/code/rcpp/html/Rmath_8h_source.html
# Lat: y-axis
# Lon: x-axis

library(xtable)
library(rcommon)
library(sqldf)
library(fields) # quilt.plot
library(maps)   # map
source("../../hw3/src/plotPerCounty.R")

### Entire Data ###
dat <- read.csv('../../hw3/dat/annual_all_2015.csv')
site <- read.csv('../../hw3/dat/aqs_sites.csv')
pred_locs <- read.csv('../dat/predlocs.csv')

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

### Explore location vs altitude ###
pdf('../tex/img/pairsRaw.pdf')
vars <- cbind(ca$Arithmetic.Mean,
              ca$Lat, ca$Lon, ca$Elevation)
colnames(vars) <- c('Ozone Mean', 'Latitude', 'Longitude', 'Elevation')
my.pairs(vars)
dev.off()

pdf('../tex/img/mypairs.pdf')
new_vars <- cbind(ca$Arithmetic.Mean, 
              ca$Lat,
              ca$Lon,
              log(ca$Elevation))
colnames(new_vars) <- c('Ozone Mean', 'Latitude', 'Longitude', 'log(Elevation)')
my.pairs(new_vars)
dev.off()



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
set.seed(1)
source("GP_R/gp.R", chdir=TRUE)
y <- ca$Arithmetic.Mean * 1000
X <- cbind(1, new_vars[, c("Longitude", "log(Elevation)")])
colnames(X) <- c("intercept", "Longitude", "Log Elevation")

pdf('../tex/img/map.pdf')
map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, y, add=TRUE)
dev.off()

system.time(
burn <- gp(y, X, s, b_sig=1,
           B=1000, burn=2000, print_every=100)
)

#plotPosts(burn[, 1:ncol(X)])
#plotPosts(burn[, c('phi','tau2','gam2', 'z')])
#plotPosts(burn[, c('phi','tau2','sig2', 'z')])
#nrow(unique(burn)) / nrow(burn)
#table(burn[,'nu']) / nrow(burn)

system.time(
out <- gp(y, X, s, b_sig=1,
          stepSigPsi=cov(burn[,c('gam2','phi','z')]) * 10,
          B=1000, burn=4000, print_every=100)
)

colnames(out)[1:ncol(X)] <- colnames(X)
pdf('../tex/img/beta.pdf')
plotPosts(out[, 1:ncol(X)])
dev.off()

pdf('../tex/img/psi.pdf')
plotPosts(out[, c('phi','tau2','sig2')])
dev.off()

nrow(unique(out)) / nrow(out)
nu_mat <- t(table(out[,'nu']) / nrow(out))
colnames(nu_mat) <- paste0("$\\kappa$=", colnames(nu_mat))
rownames(nu_mat) <- "Posterior Probability"
sink("../tex/img/kappa_mat.tex")
print(xtable(nu_mat, digits=3), sanitize.text.function=identity)
sink()

### Predict / Krig
source("GP_R/gp.R", chdir=TRUE)
system.time(pred <- gp.predict(y, X, s, X, s, out))

pred.mean <- apply(pred, 1, mean)
pred.ci <- apply(pred, 1, quantile, c(.025, .975))

#par(mfrow=c(1,2), mar=mar.default())
#map('county', 'california')
#quilt.plot(ca$Lon, ca$Lat, y, add=TRUE)
#map('county', 'california')
#quilt.plot(ca$Lon, ca$Lat, pred.mean, add=TRUE)
#par(mfrow=c(1,1), mar=mar.default())

#map('county', 'california')
#quilt.plot(ca$Lon, ca$Lat, apply(pred, 1, sd), add=TRUE)

coverage <- mean(sapply(1:length(y), function(i) y[i] %btwn% pred.ci[,i]))

pdf('../tex/img/qq.pdf')
plot(y, pred.mean, pch=20, col='grey30', fg='grey',
     ylim=range(pred.ci,y), xlim=range(pred.ci,y),
     xlab='Observed Values', ylab='Predicted Values')
#title(main='Predicted (mean and 95% CI) vs Observed')
add.errbar(ci=t(pred.ci), x=y, col=rgb(0,0,0,.2))
abline(a=0, b=1, col='grey30', lty=2)
legend('bottomright', legend=paste0('Coverage = ', round(coverage,2)),
       bty='n', cex=2, text.col='grey50')
dev.off()

pdf('../tex/img/resid.pdf')
map('county', 'california')
quilt.plot(ca$Lon, ca$Lat, y-pred.mean, add=TRUE)
dev.off()



#### KRIG
#s_new <- sample(1:nrow(pred_locs), 200)
#X_new <- ???
#system.time(pred_new <- gp.predict(y,X,s,X_new,s_new,out))

