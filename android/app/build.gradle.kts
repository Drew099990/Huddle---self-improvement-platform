import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // No version here — it's inherited from the root plugins block above.
    id("com.google.gms.google-services")
}

val signingProperties = Properties().apply {
    val signingPropertiesFile = rootProject.file("key.properties")
    if (signingPropertiesFile.exists()) {
        signingPropertiesFile.inputStream().use(::load)
    }
}

android {
    namespace = "com.example.huddle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
 
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
 
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sleepypanda.huddle"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = signingProperties.getProperty("storeFile")
                ?: throw GradleException("Missing storeFile in android/key.properties.")
            storeFile = file(storeFilePath)
            keyAlias = signingProperties.getProperty("keyAlias")
                ?: throw GradleException("Missing keyAlias in android/key.properties.")
            storePassword = signingProperties.getProperty("storePassword")
                ?: throw GradleException("Missing storePassword in android/key.properties.")
            keyPassword = signingProperties.getProperty("keyPassword")
                ?: throw GradleException("Missing keyPassword in android/key.properties.")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
 
flutter {
    source = "../.."
}
 
dependencies {
    // Import the Firebase BoM — this pins compatible versions for you,
    // so don't specify versions on individual Firebase libraries below.
    implementation(platform("com.google.firebase:firebase-bom:34.17.0"))
 
    // Add the Firebase products you actually use, no version numbers needed:
    implementation("com.google.firebase:firebase-analytics")
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
    // https://firebase.google.com/docs/android/setup#available-libraries
}
 
