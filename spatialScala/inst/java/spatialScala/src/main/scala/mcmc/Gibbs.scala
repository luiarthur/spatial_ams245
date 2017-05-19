package spatialScala.mcmc

object Gibbs {

  def sample[S](init:S, update:S=>S, B:Int, burn:Int, printEvery:Int=0) = {
    require(printEvery > 0, "printEvery > 0")
    require(B > 0, "B > 0")
    require(burn > 0, "burn > 0")

    def loop(S: List[S], i: Int): List[S] = {
      if (printEvery > 0 && i % printEvery == 0) 
        print("\rProgress: " + i +"/"+ (B+burn) + "\t" + 
          java.util.Calendar.getInstance.getTime() + "\t")

      if (i < B + burn) {
        val newState = if (i <= burn) 
          List( update(S.head) )
        else 
          update(S.head) :: S
        
        loop(newState, i + 1)
      } else S
    }

    lazy val out = loop(List(init), 0)
    if (printEvery > 0) println()

    out
  }

}
