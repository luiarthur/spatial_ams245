package spatialScala

object GP {
  import breeze.linalg.{DenseMatrix, DenseVector}
  import breeze.numerics.{pow, lgamma, exp}

  def gamma(x: Double): Double = exp( lgamma(x) )
  def factorial(x: Int):Double = gamma(x+1)

  /** Modified Bessel of the first kind
   *  See: https://en.wikipedia.org/wiki/Bessel_function#Modified_Bessel_functions_:_I.CE.B1.2C_K.CE.B1
   *  */
  def besselI(x: Double, nu: Double, n: Int=10): Double = {
    // FIXME
    // Not exactly correct. Can I do this in terms of I0, and I1?
    List.tabulate(n)(m => 
      pow(x / 2, 2 * m + nu) / (factorial(m) * gamma(m + nu + 1))
    ).sum
  }
  def besselJ(x: Double, nu: Double, n: Int=10): Double = {
    // FIXME
    if (x == 0) 0 else {
      math.Pi / 2 * 
      ( besselI(x, -nu, n) - besselI(x, nu, n) ) / math.sin(nu * math.Pi)
    }
  }
  /**
   import spatialScala.timer
   timer{ List.fill(1000)(besselI(1,2)) }
   timer{ List.fill(1000)(besselI(0,2)) }
   besselJ(1,2)
   */

  trait Correlation {
    def at(tau: Double): Double
  }

  case class matern(
    D: DenseMatrix[Double], 
    nu: Double, 
    phi: Double
  ) extends Correlation {
    def at(tau: Double): Double = {
      ???
    }
  }

}
