.onLoad <- function(libname, pkgname) {

  ### SET THESE: ###
  SCALA_PACKAGE_NAME <- "spatialScala"
  SCALA_JAR_PATH_REL_JAVA_DIR <- "spatialScala/target/scala-2.11/spatialScala-assembly-0.1.0.jar"
  ##################

  lib_java_path <- paste0(libname, "/", pkgname, "/java")
  jars <- grep("*.jar", list.files(lib_java_path))
  no_jar <- identical(jars, integer(0))

  if (no_jar) {
    # Compile the jar from src
    compile_jar <- "sbt assembly;"
    cd_path <- paste0("cd ",lib_java_path, "/", SCALA_PACKAGE_NAME, ";")
    mv_jar <- paste0("mv ", SCALA_JAR_PATH_REL_JAVA_DIR , "../")

    system(paste(cd_path, compile_jar, mv_jar))
  }

  rscala::.rscalaPackage(pkgname)

}
