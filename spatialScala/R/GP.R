gp_wrapper <- rscala::"%~%"(
  s$def(y, X, loc, stepSigCov, a_tau, b_tau, 
        a_sig, b_sig, a_phi, b_phi, 
        a_nu, b_nu, B, burn, print_every=0,
        cov_fn="matern"), '
        val n = y.size
        val p = 2
        val k = 3
        spatialScala.GPs.fitMatern(
          breeze.linalg.DenseVector(y),
          new breeze.linalg.DenseMatrix(k,n,X).t,
          new breeze.linalg.DenseMatrix(p,n,loc).t,
          new breeze.linalg.DenseMatrix(4,4,stepSigCov),
          a_tau,
          b_tau,
          a_sig,
          b_sig,
          a_phi,
          b_phi,
          a_nu},
          b_nu},
          B, burn, print_every
        )
')


#GP <- function(y, X, loc, stepSigCov, a_tau, b_tau, 
#               a_sig, b_sig, a_phi, b_phi, 
#               a_nu, b_nu, B, burn, print_every=0,
#               cov_fn="matern") {
#  #' rBreeze_repeat
#  #' @export
#  #rscala::scalaEval(s,'rBreeze.repeat(@{n})')
#  #rscala::s$do()
#  n <- nrow(X)
#  k <- ncol(X)
#  p <- ncol(loc)
#
#  rscala::"%~%"(s, '
#    spatialScala.GPs.fitMatern(
#      breeze.linalg.DenseVector(@{y}),
#      new breeze.linalg.DenseMatrix(@{k},@{n},@{X}).t,
#      new breeze.linalg.DenseMatrix(@{p},@{n},@{loc}).t,
#      new breeze.linalg.DenseMatrix(4,4,@{stepSigCov}),
#      @{a_tau},
#      @{b_tau},
#      @{a_sig},
#      @{b_sig},
#      @{a_phi},
#      @{b_phi},
#      @{a_nu},
#      @{b_nu},
#      @{B}, @{burn}, @{print_every}
#    )
#  ')
#}
