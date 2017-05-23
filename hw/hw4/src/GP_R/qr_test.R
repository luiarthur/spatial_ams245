# TEST. Always use backsolve instead of forwardsolve

source("mcmc.R")
n <- 1000
k <- 100
X <- matrix(rnorm(n*k), n, k)
b <- 1:k
sig <- .3
y <- X %*% b + rnorm(n) * sig

### TIMINGS ##################################################### TIMES
system.time(for (i in 1:100) qr.solve(X, y))                    #  .720
system.time(for (i in 1:100) solve(t(X) %*% X, t(X) %*% y))     #  .291
system.time(for (i in 1:100) solve(t(X) %*% X) %*% t(X) %*% y)  #  .412
system.time(for (i in 1:100) lm(y ~ X - 1))                     # 1.584

### Answers the same
qr.solve(X, y)
solve(t(X) %*% X, t(X) %*% y)
solve(t(X) %*% X) %*% t(X) %*% y
lm(y ~ X - 1)

### TEST 2
D <- as.matrix(dist(y))
V <- exp(-D/10) * 100
y <- mvrnorm(X%*%b, V)

system.time(b.hat <- solve(t(X) %*% solve(V, X), t(X) %*% solve(V, y)))

system.time({ # FASTER
  U <- chol(V)
  z <- backsolve(U, y, transpose=TRUE)
  G <- backsolve(U, X, transpose=TRUE)
  #b.hat.qr <- qr.solve(G, z)
  qr.G <- qr(G)
  b <- qr.qty(qr.G, z)
  b.hat.qr <- backsolve(qr.G$qr, b)
  Sig.hat.qr <- chol2inv(qr.G$qr)
  sse <- sum(qr.resid(qr.G, z)^2)
})

all(abs(b.hat.qr - b.hat) < 1E-5)

system.time(Sig.hat <- solve(t(X) %*% solve(V) %*% X))
system.time(solve(t(G) %*% G))

all(abs(Sig.hat - Sig.hat.qr) < 1E-4)

all(t(y - X %*% b.hat) %*% solve(V) %*% (y - X %*% b.hat) - sse < 1E-4)


