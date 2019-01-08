name := "count_git_edits"

version := "1.0"

scalaVersion := "2.12.4"

scalacOptions ++= Seq("-unchecked", "-deprecation", "-feature")

libraryDependencies += "org.eclipse.jgit" % "org.eclipse.jgit" % "5.2.0.201812061821-r"
libraryDependencies += "org.slf4j" % "slf4j-api" % "1.7.25"
