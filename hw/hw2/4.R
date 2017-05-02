# Karhunen-Loeve Representation for exponential covariance fn
KL_exp <- function(s, J=100, L=1, sig2=1, phi=1, N=1E6, eps=1E-3) {
  w_grid <- seq(-L, L, len=N)
  w1 <- w_grid[head(which(abs(tan(w_grid*L) - phi/w) < eps & w > 0), J)]
  w2 <- w_grid[head(which(abs(tan(w_grid*L) + w/phi) < eps), J)]
  w <- cbind(w1, w2)

  lam <- apply(w, 2, function(wi) (2 * phi) / (wi^2 + phi^2) )

  psi1 <- function(s) cos(w1(s)) / sqrt(L + sin(2*w1*L) / (2*w1))
  psi2 <- function(s) sin(w2(s)) / sqrt(L - sin(2*w2*L) / (2*w2))

   
}


x <- KL_exp()

#n <- 1E6
#w <- seq(-10,10,len=n)
#phi <- 1
#L <- 1
#plot(w, tan(w*L),type='l', ylim=c(-10,10), xlim=range(w))
#lines(w, phi/w, col='red', lwd=2)
#lines(w, -w/phi, col='blue', lwd=2)
#
#
#head(which(abs(tan(w*L) - phi/w) < .001 & w > 0),10)
#which(abs(tan(w*L) - w/phi) < .001)
