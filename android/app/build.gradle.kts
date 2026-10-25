import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing details are read from android/app/keystore.properties
// (see keystore.properties.example). The release workflow writes this file
// from GitHub secrets.
val keystorePropertiesFile = file("keystore.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val releaseStoreFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
val hasReleaseSigning = releaseStoreFile?.exists() == true

// F-Droid signs APKs itself, so its build recipe sets UNSIGNED_RELEASE=true
// to produce an unsigned release APK.
val unsignedRelease = System.getenv("UNSIGNED_RELEASE") == "true"

android {
    namespace = "com.asptechinc.steerwise"
    compileSdk = libs.versions.compileSdk.get().toInt()
    ndkVersion = libs.versions.ndk.get()

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.asptechinc.steerwise"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin", "src/main/java")
        }
    }

    // Omit Google's encrypted dependency metadata blob, which F-Droid rejects
    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Fall back to the debug key so `flutter run --release` works
            // without a keystore. Published builds must use the release key.
            signingConfig = if (unsignedRelease) {
                null
            } else if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("keystore.properties or its storeFile is missing: signing release with the debug key.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}
