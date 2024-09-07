val scala3Version = "3.5.0"

lazy val root = project
  .in(file("."))
  .settings(
    name := "EscCloudFunctionExample",
    version := "0.1.0",

    scalaVersion := scala3Version,

    libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test,
    libraryDependencies += "com.google.cloud.functions" % "functions-framework-api" % "1.1.0",
    libraryDependencies += "esc" % "esc.asderix.com" % "2.4.0" from "https://esc.asderix.com/download/EscEntitySimilarityChecker_2.4.0.jar"
  )

assembly / assemblyMergeStrategy := {
  case "module-info.class" => MergeStrategy.discard
  case x =>
    val oldStrategy = (assembly / assemblyMergeStrategy).value
    oldStrategy(x)
}

assembly / assemblyJarName := "EscCloudFunctionsExample.jar"
