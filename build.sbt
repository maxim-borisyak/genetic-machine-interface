name := "genetic-machine-interface"

version := "0.1"

lazy val root = (project in file(".")).enablePlugins(PlayScala)
  .aggregate(geneticMachine)
  .dependsOn(geneticMachine)

lazy val geneticMachine = project in file("./genetic-machine")

scalaVersion := "2.11.1"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws
)