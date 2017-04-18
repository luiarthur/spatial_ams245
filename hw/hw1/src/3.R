### HW: ###
# Plot all the covariograms and variograms in the tables of the second set of
# slides. Take the variance to be 1, and take the range parameter to be such
# that the correlation is .05 at a distance of one unit

source("cov_fn.R")

### MAIN ###

### phi for which corr is 0.05 at distance 1 and variance=1, nu=1 ###
phi <- lapply(cov_fn, function(x) find_phi(x, r=.05, d=1, nu=1)$root)

### Plot Colors ###
plot_colors <- c('red', 'blue', 'green', 'pink', 'orange')


pdf("../img/cov.pdf")
par(mfrow=c(2,1))
### Plot Covariance ###
plot(0, type='n', xlim=c(0,3), ylim=c(-.2,1), fg='grey', bty='n', 
     xlab='Distance', ylab='Covariance', main='Covariance with respect to Distance')

dummy <- lapply(as.list(1:length(phi)), function(i) {
  f <- function(x) cov_fn[[i]](x, phi[[i]], sig2=1, nu=1)
  curve(f, col=plot_colors[i], lwd=3, add=TRUE)
})

abline(h=.05, v=1, lty=2, col='grey')
legend("topright", legend=names(phi), bty='n', col=plot_colors, lwd=3)


### Plot Semi-Variogram ###
plot(0, type='n', xlim=c(0,3), ylim=c(0,1.2), fg='grey', bty='n', 
     xlab='Distance', ylab='semi-variogram', 
     main='Semi-variogram with respect to Distance')

dummy <- lapply(as.list(1:length(phi)), function(i) {
  f <- function(x) semi_variogram(cov_fn[[i]],d_zero=1E-10)(x, phi[[i]], sig2=1, nu=1)
  curve(f, col=plot_colors[i], lwd=3, add=TRUE)
})

abline(h=1, v=1, lty=2, col='grey')
legend("bottomright", legend=names(phi), bty='n', col=plot_colors, lwd=3)
par(mfrow=c(2,1))
dev.off()
