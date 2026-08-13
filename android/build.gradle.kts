plugins {
    // Add the dependency for the Google services Gradle plugin here (root),
    // but don't apply it at the root — it gets applied in app/build.gradle.kts.
    id("com.google.gms.google-services") version "4.5.0" apply false
}
 
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
 
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)
 
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
 
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
 
