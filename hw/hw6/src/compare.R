### All differences are (conv - gmrf) model ###

### Compare Common Model Parameters ###
#plotPosts(b2)
#plotPosts(b)
#plotPosts(b2-b)
post_tab <- post_summary(cbind(b-b2, tau2-tau2g, v-v2))
sink('../tex/img/post.tex')
rownames(post_tab)[4:5] <- c("$\\tau^2$","$\\nu$")
print(xtable(post_tab,label='post'),sanitize.text=identity)
sink()

### HD ###
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred-pred2)), 100, 100)
#image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_comp)
image.plot(xyz$xyz.est, add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

### Compare Residuals
ss_resid_c <- apply(resid_c, 2, function(c) sum(c^2)) 
ss_resid_g <- apply(resid_g, 2, function(c) sum(c^2)) 
ss_resid_diff <- ss_resid_c - ss_resid_g
sink("../tex/img/postResidProb.tex")
cat(mean(ss_resid_c > ss_resid_g))
sink()

par(mfrow=c(1,2))
map('state','california', col='transparent')
quilt.plot(s[1:n,1], s[1:n,2], rowMeans(resid_c), add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)
#
map('state','california', col='transparent')
quilt.plot(s[1:n,1], s[1:n,2], rowMeans(resid_g), add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)
par(mfrow=c(1,1))


### Compare Variance
pdf('../tex/img/predvar.pdf', w=13, h=10)
par(mfrow=c(2,3))
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, pred_sd), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_sd1)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, apply(X_new %*% t(b), 1, sd)), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim_sd2)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)


map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, pred2_sd), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_sd1)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, apply(X_new %*% t(b2), 1, sd)), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim_sd2)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
par(mfrow=c(1,1))
dev.off()

### Compare Means
pdf('../tex/img/pred.pdf', w=13, h=10)
par(mfrow=c(2,3))
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)


map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred2)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('county','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b2))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('county','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
par(mfrow=c(1,1))
dev.off()
