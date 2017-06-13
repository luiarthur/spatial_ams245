### All differences are (conv - gmrf) model ###

### Compare Common Model Parameters ###
post_summary(cbind(b-b2, tau2-1/lamy))

### HD ###
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred-pred2)), 100, 100)
#image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_comp)
image.plot(xyz$xyz.est, add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

### Compare Residuals
resid_diff <- 
  apply(resid_c, 2, function(c) sum(c^2)) -
  apply(resid_g, 2, function(c) sum(c^2))

mean(resid_diff)
quantile(resid_diff, c(.025, .975))
