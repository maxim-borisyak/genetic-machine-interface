name := "genetic-machine-interface"

version := "0.1"

lazy val root = (project in file(".")).enablePlugins(PlayScala)
  .aggregate(geneticMachine)
  .dependsOn(geneticMachine)

lazy val geneticMachine = project in file("./genetic-machine")

scalaVersion := "2.11.1"

scalacOptions += "-feature"

libraryDependencies ++= Seq(
  "com.typesafe.akka" %% "akka-actor" % "2.3.2",
  "com.typesafe.akka" %% "akka-remote" % "2.3.2"
)

libraryDependencies += "com.github.romix.akka" %% "akka-kryo-serialization" % "0.3.2"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws
)