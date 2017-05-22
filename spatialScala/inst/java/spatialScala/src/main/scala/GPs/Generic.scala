//package spatialScala.GPs
//
//trait Generic {
//  import breeze.linalg.{DenseMatrix, DenseVector, inv}
//  import breeze.numerics.{pow, lgamma, exp, log, sqrt}
//  import breeze.stats.distributions.{MultivariateGaussian=>MvNorm}
//  import spatialScala.mcmc._
//
//  def dist(si: DenseVector[Double], sj: DenseVector[Double]): Double = {
//    require(si.length == sj.length)
//    val n = si.length
//
//    val diffSq = Vector.tabulate(n){ k => pow(si(k) - sj(k), 2) }
//    sqrt( diffSq.sum )
//  }
//
//  def trans_param(v: DenseVector[Double]): DenseVector[Double]
//  def inv_trans_param(x: DenseVector[Double]): DenseVector[Double]
//
//  type Prior
//  type CF
//
//  def fit(
//    y: DenseVector[Double], // Observations (Univariate)
//    X: DenseMatrix[Double], // Covariates
//    s: DenseMatrix[Double], // Locations
//    stepSigCov: DenseMatrix[Double],
//    prior:Prior, corr: CF,
//    B: Int, burn: Int, printEvery: Int = 0) {
//
//    val (n,k) = (X.rows, X.cols)
//    require(y.length == n && s.rows == n)
//    
//    val D = DenseMatrix.tabulate(n,n){ 
//      (i,j) => dist(s(i, ::).t, s(j, ::).t)
//    }
//
//    val In = DenseMatrix.eye[Double](n)
//
//    def update(st: StateMatern) = {
//      val R = D.map(d => CorrFn.matern(d, st.phi, st.nu))
//      val V = st.tau2 * In + st.sig2 * R
//
//      // beta
//      val beta = {
//        lazy val Vi = inv(V)
//        lazy val XtVi = X.t * Vi
//        val SigHat = inv(XtVi * X)
//        val betaHat = SigHat * XtVi * y
//        MvNorm(betaHat, SigHat).sample
//      }
//
//      // cov params
//      val covParams = {
//        def ll(p: DenseVector[Double]) = {
//          MvNorm(X*beta, V).logPdf(y)
//        }
//
//        def lp(p: DenseVector[Double]) = {
//          Metropolis.lpLogInvGamma(p(0), aTau, bTau) + 
//          Metropolis.lpLogInvGamma(p(1), aSig, bSig) + 
//          Metropolis.lpLogitUnif(p(2)) + 
//          Metropolis.lpLogitUnif(p(3)) 
//        }
//
//        val curr = DenseVector(
//          log(st.tau2),
//          log(st.sig2), 
//          Metropolis.logit(st.phi, aPhi, bPhi), 
//          Metropolis.logit(st.nu, aNu, bNu)
//        )
//
//        Metropolis.Multivariate.update(curr, ll, lp, stepSigCov)
//      }
//
//      val tau2 = exp(covParams(0))
//      val sig2 = exp(covParams(1))
//      val phi = Metropolis.invLogit(covParams(2), aPhi, bPhi)
//      val nu = Metropolis.invLogit(covParams(3), aNu, bNu)
//
//      StateMatern(beta, tau2, sig2, phi, nu)
//    }
//
//    val init = StateMatern(
//      beta=DenseVector.zeros[Double](k),
//      tau2=1,
//      sig2=1,
//      phi=(aPhi + bPhi) / 2,
//      nu=(aNu + aNu) / 2
//    )
//    
//    val mcmcOut = Gibbs.sample(init, update, B, burn, printEvery)
//
//    lazy val betas = mcmcOut.map(_.beta)
//    lazy val betaMat = new DenseMatrix(betas.head.size, betas.size,
//      betas.map(_.toArray).toArray.flatten
//    ) // k by B
//
//    lazy val covParams = mcmcOut.map(m => 
//      Array(m.tau2, m.sig2, m.phi, m.nu)
//    )
//    lazy val covParamsMat = new DenseMatrix(4, covParams.size,
//      covParams.toArray.flatten
//    )
//
//    DenseMatrix.horzcat(betaMat, covParamsMat)
//  }
//
//}
