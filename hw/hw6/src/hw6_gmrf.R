### Process Convolution with GMRF weight coefficients
source("gmrf.R", chdir=TRUE)
set.seed(1)
out2 <- gp_conv_gmrf_fit(y, X, u=u, s=s, 
                         cs_v=.5, B=3000, burn=1000, print_freq=100)

b2 <- t(sapply(out2, function(o) o$beta))
colnames(b2) <- colnames(X)
plotPosts(b2, trace=F)

z <- t(sapply(out2, function(o) o$z))
colnames(z) <- paste0("w",1:nrow(u))
plotPosts(z[,1:4], trace=F)
plotPosts(z[,5:8], trace=F)
plotPosts(z[,9:12], trace=F)

lamy <- sapply(out2, function(o) o$lamy)
lamz <- sapply(out2, function(o) o$lamz)
v2 <- sapply(out2, function(o) o$v)
plotPosts(v2)

plotPosts(cbind(lamy, lamz, v2), acc=F)

#post <- cbind(b, w, sig2, tau2, v)
post <- cbind(b2, lamy, lamz, v2)
post_summary(post)

system.time(pred2 <- gp_conv_gmrf_pred(y, X, s, X_new, s_new, u, out2))
dim(pred)

### Plot Pred
zlim <- c(25, 60)

par(mfrow=c(2,3))
map('state','california', col='transparent')
quilt.plot(s_new[,1], s_new[,2], rowMeans(pred2), add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=T, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s_new[,1], s_new[,2], rowMeans(X_new%*%t(b2)), add=T, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

### HD
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred2)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz_dat <- mba.surf(cbind(s, y), 100, 100)
image.plot(xyz_dat$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b2))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
par(mfrow=c(1,1))

### Residuals ###
resid_g <- apply(pred2[1:n,], 2, function(c) c-y)
map('state','california', col='transparent')
quilt.plot(s[1:n,1], s[1:n,2], rowMeans(resid_g), add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

