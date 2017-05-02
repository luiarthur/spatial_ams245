# Karhunen-Loeve Representation for exponential covariance fn
KL_exp <- function(J=100, L=100, sig2=1, phi=1) {
  w <- 
  lam <- 2*phi / (w[,1]^2 + phi^2) 
}

n <- 100
w <- seq(-n,n,len=n)
phi <- 1
L <- 1
plot(w, tan(w*L),type='l', ylim=c(-n,n))
lines(w, phi/w)
lines(w, -w/phi)
