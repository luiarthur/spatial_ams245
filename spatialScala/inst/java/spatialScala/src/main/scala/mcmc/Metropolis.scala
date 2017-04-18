package spatialScala.mcmc

object Metropolis {
  import math.{exp, log}

  private[Metropolis] trait GenericMetropolis {
    // To Implement:
    type State
    type Cov
    def rnorm(mu:State,sig:Cov): State

    // Pre-implemented:
    def update(curr:State, ll:State=>Double, lp:State=>Double,
               candSig:Cov): State = {
      def logLikePlusLogPrior(x:State) = ll(x) + lp(x)
      val cand = rnorm(curr,candSig)
      val u = math.log(scala.util.Random.nextDouble)
      val p = logLikePlusLogPrior(cand) - 
              logLikePlusLogPrior(curr)

      if (p > u) cand else curr
    }
  }

  object Univariate extends GenericMetropolis {
    type State = Double
    type Cov = Double
    def rnorm(x: State, sig:Cov) = {
      breeze.stats.distributions.Gaussian(x,sig).sample
    }
  }

  object Multivariate extends GenericMetropolis {
    import breeze.linalg.{DenseMatrix, DenseVector}
    type State = DenseVector[Double]
    type Cov = DenseMatrix[Double]
    def rnorm(x: State, cov:Cov) = {
      breeze.stats.distributions.MultivariateGaussian(x,cov).sample
    }
  }

  /** Retruns the log density of log(X) given (a two-parameter) density of X*/
  def logDensityLogXTwoParam(lf:(Double,Double,Double) => Double) = { // GOOD
    (logx:Double, a:Double, b:Double) => lf(exp(logx), a, b) + logx
  }

  /** log (prior) distribution of Gamma parameter without normalizing constant*/
  def lpGamma(x:Double, shape:Double, rate:Double) = { // GOOD
    (shape - 1) * log(x) - rate * x
  }

  /** log (prior) distribution of Gamma parameter with normalizing constant*/
  def lpGammaWithConst(x:Double, shape:Double, rate:Double) = { // GOOD
    import breeze.numerics.lgamma
    lpGamma(x, shape, rate) + shape * log(rate) - lgamma(shape)
  }

  /** log (prior) distribution of Inverse Gamma parameter 
   *  without normalizing constant*/
  def lpInvGamma(x:Double, a:Double, bNumer:Double) = { // GOOD
    -(a + 1) * log(x) - bNumer / x 
  }

  /** log (prior) distribution of Inverse Gamma parameter 
   *  with normalizing constant*/
  def lpInvGammaWithConst(x:Double, a:Double, bNumer:Double) = { // GOOD
    import breeze.numerics.lgamma
    lpInvGamma(x,a,bNumer) + a * log(bNumer) - lgamma(a)
  }

  /** log (prior) distribution of log(X) where parameter X ~ Gamma(a,b) 
   *  without normalizing constant*/
  val lpLogGamma = logDensityLogXTwoParam(lpGamma) // GOOD
  /** log (prior) distribution of log(X) where parameter X ~ InverseGamma(a,b) 
   *  without normalizing constant*/
  val lpLogInvGamma = logDensityLogXTwoParam(lpInvGamma) // GOOD

  def invLogit(x:Double, a:Double=0.0, b:Double=1.0) = { // GOOD
    (b * exp(x) + a) / (1 + exp(x)) 
  }

  def logit(p:Double, a:Double=0.0, b:Double=1.0) = { // GOOD
    log((p-a) / (b-p))
  }

  /** log (prior) distribution of logit of U, where U ~ Unif(a,b) */
  def lpLogitUnif(logitU:Double) = { // GOOD
    logitU - 2 * log(1 + exp(logitU))
  }

}
