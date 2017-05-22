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
    val u = d / phi
    val logR = -((nu-1) * log(2) + lgamma(nu)) + 
                 nu * log(u) + log(besselJ(u, nu))

    exp(logR)
  }

  trait Generic {
    def f(d: Double): Double
  }

  case class Matern(var phi: Double = 0, var nu: Double = 0) extends Generic {
    def f(d: Double):Double = {
      matern(d, phi, nu)
    }
  }

}
