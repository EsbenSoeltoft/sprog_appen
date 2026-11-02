import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Optional locally; release builds require a complete private signing file.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.isFile) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val signingKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val hasReleaseSigning = signingKeys.all {
    !keystoreProperties.getProperty(it).isNullOrBlank()
}

// Resolve the private keystore once for both signing and validation.
// Absolute paths and ~/ are supported; relative paths are based on android/.
val releaseKeystoreFile = keystoreProperties.getProperty("storeFile")
    ?.takeIf { it.isNotBlank() }
    ?.let { configuredPath ->
        val expandedPath = if (configuredPath.startsWith("~/")) {
            File(System.getProperty("user.home"), configuredPath.removePrefix("~/")).path
        } else {
            configuredPath
        }
        rootProject.file(expandedPath)
    }

android {
    namespace = "com.incipier.sprog_appen"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent identity under incipier.com, distinct from com.incipier.incipier.
        applicationId = "com.incipier.sprog_appen"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                // Relative paths in key.properties resolve from android/.
                storeFile = releaseKeystoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildFeatures {
        resValues = true
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            resValue("string", "app_name", "Sprog Appen (Debug)")
            signingConfig = signingConfigs.getByName("debug")
        }
        // The Flutter plugin creates profile; configure it rather than recreating it.
        getByName("profile") {
            applicationIdSuffix = ".profile"
            versionNameSuffix = "-profile"
            resValue("string", "app_name", "Sprog Appen (Profile)")
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            isDebuggable = false
            resValue("string", "app_name", "Sprog Appen")
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else null
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Fail only when building release, so debug/profile work without private keys.
val validateReleaseSigning = tasks.register("validateReleaseSigning") {
    doLast {
        check(hasReleaseSigning) {
            "Release signing requires android/key.properties with storeFile, storePassword, keyAlias and keyPassword. See docs/android_release.md."
        }
        check(releaseKeystoreFile?.isFile == true) {
            "Release keystore not found. Set storeFile in android/key.properties to an existing keystore (absolute path, ~/ path, or relative to android/)."
        }
    }
}
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn(validateReleaseSigning)
}
