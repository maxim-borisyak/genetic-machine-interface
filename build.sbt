name := "genetic-machine-interface"

version := "0.1"

lazy val root = Project(id = "genetic-machine-interface", base = file(".")).enablePlugins(PlayScala)
  .aggregate(geneticMachine)
  .dependsOn(geneticMachine)

lazy val geneticMachine = Project(id = "genetic-machine", base = file("./genetic-machine"))

scalaVersion := "2.11.1"

scalacOptions += "-feature"

resolvers += "Typesafe Snapshots" at "http://repo.typesafe.com/typesafe/snapshots/"

libraryDependencies ++= Seq(
  "com.typesafe.akka" %% "akka-actor" % "2.3.4",
  "com.typesafe.akka" %% "akka-remote" % "2.3.4"
)

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws
)