GP <- function(y, X, loc, stepSigCov, a_tau, b_tau, 
               a_sig, b_sig, a_phi, b_phi, 
               a_nu, b_nu, B, burn, print_every=0,
               cov_fn="matern") {
  #' rBreeze_repeat
  #' @export
  #rscala::scalaEval(s,'rBreeze.repeat(@{n})')
  #rscala::s$do()
  rscala::"%~%"(s, '
    spatialScala.GPs.fitMatern(
      DenseVector(@{y}),
      DenseMatrix(@{X}),
      DenseMatrix(@{loc}),
      DenseMatrix(@{stepSigCov}),
      @{a_tau},
      @{b_tau},
      @{a_sig},
      @{b_sig},
      @{a_phi},
      @{b_phi},
      @{a_nu},
      @{b_nu},
      @{B}, @{burn}, @{print_every}
    )
  ')
}
