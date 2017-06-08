### Read CA Data ###
source("readDat.R", chdir=TRUE)

### Naming Data
X <- cbind(ca$Lon, log(ca$Elevation))
colnames(X) <- c('Longitude', 'log(Elevation)')
y <- ca$MEAN
s <- as.matrix(ca[c('Longitude', 'Latitude')])
n <- nrow(X)

### Indices
NO2 <- which(ca$Parameter.Name=="Nitrogen dioxide (NO2)")
PM <- which(ca$Parameter.Name=="PM2.5 Raw Data")
Ozone <- which(ca$Parameter.Name=="Ozone")
list_idx <- list(NO2=NO2, PM=PM, Ozone=Ozone)

X_ls <- lapply(list_idx, function(i) X[i,])
y_ls <- lapply(list_idx, function(i) y[i])
y_ls$Ozone <- y_ls$Ozone * 1000 # ppb
s_ls <- lapply(list_idx, function(i) s[i,])
n_ls <- lapply(y_ls, length)
df_ls <- lapply(list_idx, function(i) ca[i, 
                c("Longitude","Latitude", "Elevation", "MEAN")])

### MERGED TABLE
X_ON  <- merge(df_ls$O, df_ls$N, by=c("Longitude", "Latitude", "Elevation"), all=TRUE)
X_ON$MEAN.x <- X_ON$MEAN.x * 1000 # ppb
X_ONP <- merge(X_ON, df_ls$P, by=c("Longitude", "Latitude", "Elevation"), all=TRUE)

### Make sure that the resulting merged table has all the data
stopifnot(sum(!is.na(X_ONP[,4:6])) == nrow(X))
head(X_ONP)

colnames(X_ONP)[4:6] <- c("Ozone", "NO2", "PM")
X_ONP$LogElevation <- log(X_ONP$Elevation)
######

### Pairs
my.pairs(cbind(y_ls$N,X_ls$N))
my.pairs(cbind(y_ls$P,X_ls$P))
my.pairs(cbind(y_ls$O,X_ls$O))


### Fit Model

prior <- list(sigma.sq.ig=c(2,1), tau.sq.ig=c(2,1),
              phi.unif=c(.5, 10), nu.unif=c(1,3))
starting <- list(phi=mean(prior$phi), sigma.sq=1, tau.sq=1, 
                 nu=mean(prior$nu))
tuning <- list(phi=.1, sigma.sq=.1, tau.sq=.1, nu=.1)
invert_phi <- function(M) {
  M[,"phi"] <- 1 / M[,"phi"]
  M
}

### Ozone
out_Ozone <- spLM(y_ls$Oz ~ X_ls$Oz, n.samp=2000, coords=s_ls$Oz,
                  cov.model="matern",
                  starting=starting, prior=prior, tuning=tuning)
m_Ozone <- spRecover(out_Ozone, start=1001)

pdf("../tex/img/ozoneBeta.pdf")
plotPosts( as.matrix(m_Ozone$p.beta) )
dev.off()
pdf("../tex/img/ozoneCov.pdf")
plotPosts( invert_phi(as.matrix(m_Ozone$p.theta.rec)) )
dev.off()

### NO2
out_NO2 <- spLM(y_ls$N ~ X_ls$N, n.samp=5000, coords=s_ls$N,
                cov.model="matern",
                starting=starting, prior=prior, tuning=tuning)
m_NO2 <- spRecover(out_NO2, start=4001)

pdf("../tex/img/NO2Beta.pdf")
plotPosts( as.matrix(m_NO2$p.beta) )
dev.off()
pdf("../tex/img/NO2Cov.pdf")
plotPosts( invert_phi(as.matrix(m_NO2$p.theta.rec)) )
dev.off()

### PM2.5
out_PM <- spLM(y_ls$P ~ X_ls$P, n.samp=10000, coords=s_ls$P,
               cov.model="matern",
               starting=starting, prior=prior, tuning=tuning)
m_PM <- spRecover(out_PM, start=9001, end=10000)

pdf("../tex/img/PMBeta.pdf")
plotPosts( as.matrix(m_PM$p.beta) )
dev.off()
pdf("../tex/img/PMCov.pdf")
plotPosts( invert_phi(as.matrix(m_PM$p.theta.rec)) )
dev.off()

### 
#u <- jitter(s)
#O_pred <- spPredict(out_Ozone, pred.coords=u, pred.covars=cbind(1,X))
#N_pred <- spPredict(out_NO2, pred.coords=u, pred.covars=cbind(1,X))
#P_pred <- spPredict(out_PM, pred.coords=u, pred.covars=cbind(1,X))
### Predict at each location
u <- jitter(as.matrix(X_ONP[,1:2]))
X_all <- cbind(1, as.matrix(X_ONP[,c("Longitude", "LogElevation")]))
O_pred <- spPredict(out_Ozone, pred.coords=u, pred.covars=X_all)
N_pred <- spPredict(out_NO2,   pred.coords=u, pred.covars=X_all)
P_pred <- spPredict(out_PM,    pred.coords=u, pred.covars=X_all)

O_mean <- rowMeans(O_pred$p)
N_mean <- rowMeans(N_pred$p)
P_mean <- rowMeans(P_pred$p)

### Ozone Maps
lim_ozone <- c(25,56)
pdf("../tex/img/ozone.pdf", w=13,h=7)
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=O_mean, add=TRUE, zlim=lim_ozone)
title(main="Ozone Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$O[,"Longitude"], y=s_ls$O[,"Latitude"],
           z=y_ls$O, add=TRUE, zlim=lim_ozone)
title(main="Ozone Truth")
par(mfrow=c(1,1))
dev.off()

### NO2 Maps
lim_no2 <- c(4,35)
pdf("../tex/img/NO2", w=13,h=7)
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=N_mean, add=TRUE, zlim=lim_no2)
title(main="NO2 Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$N[,"Longitude"], y=s_ls$N[,"Latitude"],
           z=y_ls$N, add=TRUE, zlim=lim_no2)
title(main="NO2 Truth")
par(mfrow=c(1,1))
dev.off()

### PM2.5 Maps
lim_pm <- c(4,20)
pdf("../tex/img/PM.pdf", w=13,h=7)
par(mfrow=c(1,2))
map('county', 'california', col='grey')
quilt.plot(x=u[,"Longitude"], y=u[,"Latitude"],
           z=P_mean, add=TRUE, zlim=lim_pm)
title(main="PM2.5 Prediction")
#
map('county', 'california', col='grey')
quilt.plot(x=s_ls$P[,"Longitude"], y=s_ls$P[,"Latitude"],
           z=y_ls$P, add=TRUE, zlim=lim_pm)
title(main="PM2.5 Truth")
par(mfrow=c(1,1))
dev.off()

### Higher Resolution
plotP <- function() {
  map('county', 'california', col='transparent')
  xyz_P <- mba.surf(cbind(u, P_mean), 600, 600)
  image.plot(xyz_P$xyz.est, add=TRUE, zlim=lim_pm)
  map('county', 'california', col='grey', add=TRUE)
  title(main="PM2.5 Prediction")
}
pdf("../tex/img/PMHD.pdf")
plotP()
dev.off()

plotN <- function() {
  map('county', 'california', col='transparent')
  xyz_N <- mba.surf(cbind(u, N_mean), 600, 600)
  image.plot(xyz_N$xyz.est, add=TRUE, zlim=lim_no2)
  map('county', 'california', col='grey', add=TRUE)
  title(main="NO2 Prediction")
}
pdf("../tex/img/NO2HD.pdf")
plotN()
dev.off()

plotO <- function() {
  map('county', 'california', col='transparent')
  xyz_O <- mba.surf(cbind(u, O_mean), 600, 600)
  image.plot(xyz_O$xyz.est, add=TRUE,zlim=lim_ozone)
  map('county', 'california', col='grey', add=TRUE)
  title(main="Ozone Prediction")
}
pdf("../tex/img/ozoneHD.pdf")
plotO()
dev.off()

### Imputed: Combined Data

#### spMvLM
Y <- cbind(O_mean,N_mean,P_mean)
q <- ncol(Y)
N <- nrow(Y)
m <- 30
set.seed(1)

mv_prior <- list(Psi.ig=list(rep(2,q), rep(.1,q)),
                 phi.unif=list(rep(.5,q), rep(10,q)),
                 K.iw = list(q+1, diag(.1, q)),
                 nu.unif=list(rep(1,q), rep(3,q)) )

A.starting <- diag(1,q)[lower.tri(diag(1,q), TRUE)]
mv_starting <- list(phi=rep(1,q), Psi=rep(1,q), A=A.starting, nu=rep(2,q))

mv_tuning <- list(phi=rep(.01,q), A=rep(.01, length(A.starting)),
                  Psi=rep(.01,q), nu=rep(.01, q))

mv_mod <- spMvLM(list(O_mean ~ Longitude + LogElevation,
                      N_mean ~ Longitude + LogElevation,
                      P_mean ~ Longitude + LogElevation),
                 n.samp=2000, 
                 #knots=knots, # Why won't you work?...
                 knots=c(6,6),
                 coords=as.matrix(X_ONP[,c("Longitude","Latitude")]),
                 cov.model="matern",
                 starting=mv_starting, prior=mv_prior, tuning=mv_tuning,
                 data=X_ONP)

mv_mod_recover <- spRecover(mv_mod, start=1001)

pdf("../tex/img/ozoneMVBeta.pdf")
plotPosts( as.matrix(mv_mod_recover$p.beta.rec)[,1:3] )
dev.off()
pdf("../tex/img/NO2MVBeta.pdf")
plotPosts( as.matrix(mv_mod_recover$p.beta.rec)[,4:6] )
dev.off()
pdf("../tex/img/PMMVBeta.pdf")
plotPosts( as.matrix(mv_mod_recover$p.beta.rec)[,7:9] )
dev.off()
#plotPosts( invert_phi(as.matrix(mv_mod_recover$p.theta.rec)) )

### Predict at each location

new_X <- as.matrix(cbind(1,pred_locs[,2],log(pred_locs[,1])))
new_mv_X <- mkMvX(list(new_X, new_X, new_X))
mv_pred <- spPredict(mv_mod, 
  pred.coords=jitter(as.matrix(pred_locs[,-1])),
  pred.covars=new_mv_X,
  start=1801)
  #pred.covars=mv_mod$X, start=801)

mv_mean <- rowMeans(mv_pred$p)
mv_O_mean <- mv_mean[seq(1,length(mv_mean),by=3)]
mv_N_mean <- mv_mean[seq(2,length(mv_mean),by=3)]
mv_P_mean <- mv_mean[seq(3,length(mv_mean),by=3)]


### Higher Resolution Multivariate Predictions
plotMVO <- function() {
  map('county', 'california', col='transparent')
  xyz_O <- mba.surf(cbind(pred_locs[,-1], mv_O_mean), 600, 600)
  image.plot(xyz_O$xyz.est, add=TRUE, zlim=lim_ozone)
  #quilt.plot(pred_locs[,2], pred_locs[,3], mv_O_mean, add=TRUE, zlim=lim_ozone)
  map('county', 'california', col='grey', add=TRUE)
  title(main="Ozone Prediction (Multivariate GP)")
}
pdf("../tex/img/mvozoneHD.pdf")
plotMVO()
dev.off()

plotMVN <- function() {
  map('county', 'california', col='transparent')
  xyz_N <- mba.surf(cbind(pred_locs[,-1], mv_N_mean), 600, 600)
  image.plot(xyz_N$xyz.est, add=TRUE, zlim=lim_no2)
  map('county', 'california', col='grey', add=TRUE)
  title(main="NO2 Prediction (Multivariate GP)")
}
pdf("../tex/img/mvNO2HD.pdf")
plotMVN()
dev.off()

plotMVP <- function() {
  map('county', 'california', col='transparent')
  xyz_P <- mba.surf(cbind(pred_locs[,-1], mv_P_mean), 600, 600)
  image.plot(xyz_P$xyz.est, add=TRUE, zlim=lim_pm)
  map('county', 'california', col='grey', add=TRUE)
  title(main="PM2.5 Prediction (Multivariate GP)")
}
pdf("../tex/img/mvPMHD.pdf")
plotMVP()
dev.off()


#####################################
pdf("../tex/img/allHD.pdf",h=13,w=10)
par(mfrow=c(3,3))

# Ozone
map('county','california',col='transparent')
quilt.plot(s_ls$O[,1], s_ls$O[,2], y_ls$O, zlim=lim_ozone, add=TRUE)
title(main="Ozone Data")
map('county','california',col='grey', add=TRUE)
plotO(); plotMVO()

# NO2
map('county','california',col='transparent')
quilt.plot(s_ls$N[,1], s_ls$N[,2], y_ls$N, zlim=lim_no2, add=TRUE)
title(main="NO2 Data")
map('county','california',col='grey', add=TRUE)
plotN(); plotMVN()

# PM2.5
map('county','california',col='transparent')
quilt.plot(s_ls$P[,1], s_ls$P[,2], y_ls$P, zlim=lim_pm, add=TRUE)
title(main="PM2.5 Data")
map('county','california',col='grey', add=TRUE)
plotP(); plotMVP()

par(mfrow=c(1,1))
dev.off()


