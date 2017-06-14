### All differences are (conv - gmrf) model ###

### Compare Common Model Parameters ###
#plotPosts(b2)
#plotPosts(b)
#plotPosts(b2-b)
post_tab <- post_summary(cbind(b-b2, tau2-tau2g, v-v2))
sink('../tex/img/post.tex')
rownames(post_tab)[4:5] <- c("$\\tau^2$","$\\nu$")
print(xtable(post_tab),sanitize.text=identity,
      floating=getOption("xtable.floating",F))
sink()

### HD ###
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred-pred2)), 100, 100)
#image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_comp)
image.plot(xyz$xyz.est, add=TRUE)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)

### Compare Residuals
ss_resid_c <- apply(resid_c, 2, function(c) sum(c^2)) 
ss_resid_g <- apply(resid_g, 2, function(c) sum(c^2)) 
ss_resid_diff <- ss_resid_c - ss_resid_g
sink("../tex/img/postResidProb.tex")
cat(mean(ss_resid_c > ss_resid_g))
sink()

pdf('../tex/img/resid.pdf', w=7, h=13)
par(mfrow=c(2,1))
map('state','california', col='transparent')
quilt.plot(s[1:n,1], s[1:n,2], rowMeans(resid_c), add=TRUE)
#xyz <- mba.surf(cbind(s, rowMeans(resid_c)), 100, 100)
#image.plot(xyz$xyz.est, add=T)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main="Residuals under M1")
#
map('state','california', col='transparent')
quilt.plot(s[1:n,1], s[1:n,2], rowMeans(resid_g), add=TRUE)
#xyz <- mba.surf(cbind(s, rowMeans(resid_g)), 100, 100)
#image.plot(xyz$xyz.est, add=T)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main="Residuals under M2")
par(mfrow=c(1,1))
dev.off()

#hist(rowMeans(resid_c), fg='grey', border='white', col='grey', xlab='', prob=T, main="Histogram of Residuals (M1)")
#hist(rowMeans(resid_g), fg='grey', border='white', col='grey', xlab='', prob=T, main="Histogram of Residuals (M2)")

### Compare Predictions
cex.main <- 2.5
pdf('../tex/img/pred.pdf', w=13, h=20)
par(mfrow=c(4,3))
### Mean
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main=expression( "E["~y^"*"~"|"~y~"]" ~ " for " ~ M[1]),
      cex.main=cex.main)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main=expression(paste("Data")), cex.main=cex.main)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('state','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
title(main=expression( "E["~X^"*"~beta~"|"~y~"]" ~ paste(" for ") ~ M[1]),
      cex.main=cex.main)


map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(pred2)), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main=expression( "E["~y^"*"~"|"~y~"]" ~ " for " ~ M[2]),
      cex.main=cex.main)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, rowMeans(X_new %*% t(b2))), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim)
map('state','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
title(main=expression( "E["~X^"*"~beta~"|"~y~"]" ~ paste(" for ") ~ M[2]),
      cex.main=cex.main)

### SD
map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, pred_sd), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_sd1)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main=expression( "SD["~y^"*"~"|"~y~"]" ~ " for " ~ M[1]),
      cex.main=cex.main)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, apply(X_new %*% t(b), 1, sd)), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim_sd2)
map('state','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
title(main=expression( "SD["~X^"*"~beta~"|"~y~"]" ~ paste(" for ") ~ M[1]),
      cex.main=cex.main)


map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, pred2_sd), 100, 100)
image.plot(xyz$xyz.est, add=TRUE, zlim=zlim_sd1)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)
title(main=expression( "SD["~y^"*"~"|"~y~"]" ~ " for " ~ M[2]),
      cex.main=cex.main)

map('state','california', col='transparent')
quilt.plot(s[,1], s[,2], y, add=TRUE, zlim=zlim)
points(u[,1], u[,2], col='grey30', cex=1)
map('state','california', col='grey', add=T)

map('state','california', col='transparent')
xyz <- mba.surf(cbind(s_new, apply(X_new %*% t(b2), 1, sd)), 100, 100)
image.plot(xyz$xyz.est, add=T, zlim=zlim_sd2)
map('state','california', col='grey', add=T)
points(u[,1], u[,2], col='grey30', cex=1)
title(main=expression( "SD["~X^"*"~beta~"|"~y~"]" ~ paste(" for ") ~ M[2]),
      cex.main=cex.main)

par(mfrow=c(1,1))
dev.off()
### End of Mean


