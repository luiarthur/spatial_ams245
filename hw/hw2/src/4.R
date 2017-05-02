library(rootSolve)
install.packages("rootSolve")
combine <- function(x,y) {
  stopifnot(length(x) == length(y))
  n <- length(x)
  z <- rep(NA,n)
  for (i in 1:n) {
    z[2*i - 1] <- x[i]
    z[2*i] <- y[i]
  }
  z
}

# Karhunen-Loeve Representation for exponential covariance fn
KL_exp <- function(s, J=100, L=1, sig2=1, phi=1, interval=c(0,100), inf=1E3) {

  w1_tmp <- uniroot.all(function(w) tan(w*L) - phi/w , interval)
  w2_tmp <- uniroot.all(function(w) tan(w*L) + w/phi , interval)
  w1 <- w1_tmp[which(tan(w1_tmp/L) < inf)]
  w2 <- w2_tmp[which(tan(w2_tmp/L) < inf)]
  print(length(w1))
  print(length(w2))
  w <- cbind(head(w1,J), head(w2,J))

  lam12 <- apply(w, 2, function(wi) (2 * phi) / (wi^2 + phi^2) )
  lam <- head(combine(lam12[,1], lam12[,2]), J)

  # returns the vectors of length J
  psi1 <- function(s) cos(w1*s) / sqrt(L + sin(2*w1*L) / (2*w1))
  psi2 <- function(s) sin(w2*s) / sqrt(L - sin(2*w2*L) / (2*w2))
  psi <- function(s) head(combine(psi1(s), psi2(s)), J)

  n <- length(s)
  C <- matrix(NA, n, n)
  for (i in 1:n) {
    for (j in 1:n) {
      C[i,j] <- sum(lam * psi(s[i]) * Conj(psi(s[j])))
    }
  }

  C
}


s <- seq(-1, 1, len=100)
x <- KL_exp(s, J=10)
x
plot(x[1,])

n <- 1000
w <- seq(-10,10,len=n)
phi <- 1
L <- 1

plot(w, tan(w*L), ylim=c(-10,10), pch=20, cex=.5)
points(w, phi/w, col='red', cex=.5, pch=20)
lines(w, -w/phi, col='blue', lwd=2)

tmp <- uniroot.all(function(w) tan(w*L) - phi/w , c(0,100))
tmp <- tmp[which(abs(tan(tmp*L)) < 1000)]
points(tmp, tan(tmp/L), col='red', pch=20, cex=2)

tmp <- uniroot.all(function(w) tan(w*L) + w/phi , c(-10,10))
tmp <- tmp[which(abs(tan(tmp*L)) < 1000)]
points(tmp, tan(tmp/L),col='blue', pch=20, cex=2)
