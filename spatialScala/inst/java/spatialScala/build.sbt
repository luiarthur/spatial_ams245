name := "spatialScala"

version := "0.1.0"

scalaVersion := "2.11.8"

libraryDependencies ++= Seq(
  "org.scalanlp" %% "breeze" % "0.13",
  "org.scalanlp" %% "breeze-natives" % "0.13",
  "org.apache.commons" % "commons-math3" % "3.6.1", // For bessel functions
  "org.scalatest" %% "scalatest" % "3.0.0" % "test"
)

