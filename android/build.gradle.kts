allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // The integration_test plugin asks for these by version range (1.2+,
    // 3.3+). Gradle must ask the repository which versions exist to resolve
    // a range, so the build fails whenever Google's Maven is unreachable,
    // even with the files already cached. Exact versions skip that lookup.
    configurations.all {
        resolutionStrategy.force(
            "androidx.test:runner:1.7.0",
            "androidx.test:rules:1.7.0",
            "androidx.test.espresso:espresso-core:3.7.0",
        )
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
