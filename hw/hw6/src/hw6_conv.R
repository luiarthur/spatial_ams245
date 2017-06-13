### Process Convolution with Normal weight coefficients
source("conv.R", chdir=TRUE)
set.seed(1)
out <- gp_conv_fit(y, X, u=u, s=s, cs_v=.5,
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

#post <- cbind(b, w, sig2, tau2, v)
post <- cbind(b, sig2, tau2, v)
post_summary(post)


system.time(pred <- gp_conv_pred(y, X, s, X_new, s_new, u, out))
dim(pred)

### Plot Pred
zlim <- c(25, 60)

par(mfrow=c(2,3))
map('state','california', col='transparent')
quilt.plot(s_new[,1], s_new[,2], rowMeans(pred), add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=T, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s_new[,1], s_new[,2], rowMeans(X_new%*%t(b)), add=T, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

### HD
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz_dat <- mba.surf(cbind(s, y), 100, 100)
image.plot(xyz_dat$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
par(mfrow=c(1,1))

