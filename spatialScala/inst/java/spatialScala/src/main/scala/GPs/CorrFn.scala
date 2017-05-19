package spatialScala.GPs

object CorrFn {

  import org.apache.commons.math3.special.BesselJ
  import breeze.numerics.{pow, lgamma, exp, log}

  def gamma(x: Double): Double = exp( lgamma(x) )

  /* Modified Bessel Function of Second Kind seems to be fast.
   * Same as besselK in R.
   * */
  def besselJ(x: Double, nu: Double): Double = BesselJ.value(nu, x)


  // d:    distance
  // phi:  range
  // nu:   smoothness
  def matern(d: Double, phi: Double, nu: Double): Double = {
    val logR = -((nu-1) * log(2) + lgamma(nu)) + 
                 nu * log(d / phi) + log(besselJ(d, nu))

    exp(logR)
  }
}
