package spatialScala

object GP {
  import org.apache.commons.math3.special.BesselJ
  import breeze.linalg.{DenseMatrix, DenseVector}
  import breeze.numerics.{pow, lgamma, exp, log}

  def gamma(x: Double): Double = exp( lgamma(x) )

  /* Modified Bessel Function of Second Kind seems to be fast*/
  def besselJ(x: Double, nu: Double): Double = BesselJ.value(nu, x)

  def matern(tau: Double, phi: Double, nu: Double): Double = {
    val logOut = 
      -((nu-1) * log(2) + lgamma(nu)) + nu * log(tau / phi) + log(besselJ(tau,nu))
    exp(logOut)
  }

}
